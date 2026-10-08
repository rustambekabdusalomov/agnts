// Package usage tracks the Claude plan limits from Claude Code's
// rate_limit_event lines, decides when new runs must wait, and refreshes the
// reading with a tiny run when agnts is idle.
package usage

import (
	"archive/tar"
	"bytes"
	"context"
	"errors"
	"log/slog"
	"math"
	"strconv"
	"strings"
	"sync"
	"time"

	"agnts/internal/domain"
	"agnts/internal/orchestrator"
	"agnts/internal/store/postgres"
)

// Store persists snapshots, per Claude account.
type Store interface {
	Insert(ctx context.Context, s postgres.UsageSnapshot) error
	Latest(ctx context.Context, conn *int64) (postgres.UsageSnapshot, bool, error)
}

// connOf is the Claude account ctx runs on: a connection, or nil for
// agnts's own key and for installs that never picked one.
func connOf(ctx context.Context) *int64 {
	if a, ok := domain.ClaudeOf(ctx); ok && a.ConnectionID > 0 {
		id := a.ConnectionID
		return &id
	}
	return nil
}

// onCredits reports whether ctx runs on agnts's key, paid with credits:
// plan limits do not apply to it.
func onCredits(ctx context.Context) bool {
	a, ok := domain.ClaudeOf(ctx)
	return ok && a.Credits
}

// Events appends to the event log (so SSE clients refresh).
type Events interface {
	AppendEvent(ctx context.Context, ev domain.Event) error
}

// Tracker implements orchestrator.UsageGate.
type Tracker struct {
	store  Store
	events Events
	log    *slog.Logger
	now    func() time.Time
	// paused learns when an account reaches or leaves its limit, so the
	// account's row can show it.
	paused func(ctx context.Context, conn int64, until *time.Time)
	// resolve finds the account a context without one reads.
	resolve func(ctx context.Context) (domain.ClaudeAccount, bool)

	mu         sync.Mutex
	refreshing bool
}

// SetResolver sets how a reading is found for a context without a Claude
// account (pages and the refresh button): the account the workspace's
// person would run on.
func (t *Tracker) SetResolver(f func(ctx context.Context) (domain.ClaudeAccount, bool)) {
	t.resolve = f
}

// account returns ctx with its Claude account, resolving one when needed.
func (t *Tracker) account(ctx context.Context) context.Context {
	if _, ok := domain.ClaudeOf(ctx); ok || t.resolve == nil {
		return ctx
	}
	if a, ok := t.resolve(ctx); ok {
		return domain.WithClaude(ctx, a)
	}
	return ctx
}

// OnPaused sets what learns that an account reached (until set) or left
// (nil) its limit.
func (t *Tracker) OnPaused(f func(ctx context.Context, conn int64, until *time.Time)) { t.paused = f }

var _ orchestrator.UsageGate = (*Tracker)(nil)

// New returns a usage tracker.
func New(store Store, events Events, log *slog.Logger) *Tracker {
	return &Tracker{store: store, events: events, log: log, now: time.Now}
}

// View is the current usage as the API shows it.
type View struct {
	FiveHour       *float64
	FiveHourResets *time.Time
	SevenDay       *float64
	SevenDayResets *time.Time
	Status         string
	UpdatedAt      *time.Time
	Paused         bool
	PausedUntil    *time.Time
	PauseAbove     int
	Refreshing     bool
}

// Current returns the latest reading with windows that have reset rolled
// over to zero, and whether new runs are paused.
func (t *Tracker) Current(ctx context.Context, s domain.Settings) (View, error) {
	ctx = t.account(ctx)
	if onCredits(ctx) {
		return View{Status: "allowed", PauseAbove: s.PauseAbove}, nil
	}
	snap, ok, err := t.store.Latest(ctx, connOf(ctx))
	if err != nil {
		return View{}, err
	}
	v := View{Status: "unknown", PauseAbove: s.PauseAbove}
	t.mu.Lock()
	v.Refreshing = t.refreshing
	t.mu.Unlock()
	if !ok {
		return v, nil
	}
	now := t.now()
	v.Status, v.UpdatedAt = snap.Status, &snap.CreatedAt
	v.FiveHour, v.FiveHourResets = roll(snap.FiveHour, snap.FiveHourResets, now)
	v.SevenDay, v.SevenDayResets = roll(snap.SevenDay, snap.SevenDayResets, now)
	if v.Status == "" {
		v.Status = "unknown"
	}

	limit := float64(s.PauseAbove) / 100
	switch {
	case v.Status == "rejected" && anyFuture(now, v.FiveHourResets, v.SevenDayResets):
		v.Paused, v.PausedUntil = true, latest(now, v.FiveHourResets, v.SevenDayResets)
	case v.Status == "rejected" && snap.FiveHourResets == nil && snap.SevenDayResets == nil && now.Sub(snap.CreatedAt) < 30*time.Minute:
		// Refused without a reset time: wait a while, then try again.
		until := snap.CreatedAt.Add(30 * time.Minute)
		v.Paused, v.PausedUntil = true, &until
	case v.FiveHour != nil && *v.FiveHour >= limit:
		v.Paused, v.PausedUntil = true, v.FiveHourResets
	case v.SevenDay != nil && *v.SevenDay >= 1:
		v.Paused, v.PausedUntil = true, v.SevenDayResets
	}
	return v, nil
}

// roll zeroes a window whose reset time has passed.
func roll(u *float64, resets *time.Time, now time.Time) (*float64, *time.Time) {
	if u != nil && resets != nil && !now.Before(*resets) {
		zero := 0.0
		return &zero, nil
	}
	return u, resets
}

func anyFuture(now time.Time, ts ...*time.Time) bool {
	for _, t := range ts {
		if t != nil && t.After(now) {
			return true
		}
	}
	return false
}

func latest(now time.Time, ts ...*time.Time) *time.Time {
	var out *time.Time
	for _, t := range ts {
		if t != nil && t.After(now) && (out == nil || t.After(*out)) {
			out = t
		}
	}
	return out
}

// Paused implements orchestrator.UsageGate.
func (t *Tracker) Paused(ctx context.Context, s domain.Settings) (bool, time.Time) {
	v, err := t.Current(ctx, s)
	if err != nil {
		t.log.Warn("usage: read", "err", err)
		return false, time.Time{} // unknown usage never blocks work
	}
	if v.PausedUntil != nil {
		return v.Paused, *v.PausedUntil
	}
	return v.Paused, time.Time{}
}

// Record implements orchestrator.UsageGate.
func (t *Tracker) Record(ctx context.Context, data map[string]any) {
	r := Parse(data)
	if r.empty() {
		return
	}
	conn := connOf(ctx)
	prev, ok, err := t.store.Latest(ctx, conn)
	if err != nil {
		t.log.Warn("usage: read", "err", err)
	}
	snap := postgres.UsageSnapshot{ConnectionID: conn, Status: r.Status, Raw: data}
	if ok {
		snap.FiveHour, snap.FiveHourResets = roll(prev.FiveHour, prev.FiveHourResets, t.now())
		snap.SevenDay, snap.SevenDayResets = roll(prev.SevenDay, prev.SevenDayResets, t.now())
		if snap.Status == "" {
			snap.Status = prev.Status
		}
	}
	if r.FiveHour != nil {
		snap.FiveHour = r.FiveHour
	}
	if r.FiveHourResets != nil {
		snap.FiveHourResets = r.FiveHourResets
	}
	if r.SevenDay != nil {
		snap.SevenDay = r.SevenDay
	}
	if r.SevenDayResets != nil {
		snap.SevenDayResets = r.SevenDayResets
	}
	if err := t.store.Insert(ctx, snap); err != nil {
		t.log.Warn("usage: save", "err", err)
		return
	}
	if conn != nil && t.paused != nil {
		if v, err := t.Current(ctx, domain.Settings{PauseAbove: 100}); err == nil {
			if v.Paused {
				t.paused(ctx, *conn, v.PausedUntil)
			} else {
				t.paused(ctx, *conn, nil)
			}
		}
	}
	t.announce(ctx, snap)
}

// RecordLimited implements orchestrator.UsageGate.
func (t *Tracker) RecordLimited(ctx context.Context) {
	t.Record(ctx, map[string]any{"rate_limit_info": map[string]any{"status": "rejected"}})
}

func (t *Tracker) announce(ctx context.Context, s postgres.UsageSnapshot) {
	msg := "plan usage updated"
	if s.FiveHour != nil {
		msg = "session usage " + strconv.Itoa(int(math.Round(*s.FiveHour*100))) + "%"
	}
	if s.Status != "" && s.Status != "allowed" {
		msg += ", " + strings.ReplaceAll(s.Status, "_", " ")
	}
	level := domain.LevelInfo
	if s.Status == "rejected" || s.Status == "allowed_warning" {
		level = domain.LevelWarn
	}
	_ = t.events.AppendEvent(ctx, domain.Event{Type: domain.EventUsageUpdated, Level: level, Message: msg})
}

// Reading is what one rate-limit line told us. Absent fields are nil.
type Reading struct {
	Status         string
	FiveHour       *float64
	FiveHourResets *time.Time
	SevenDay       *float64
	SevenDayResets *time.Time
}

func (r Reading) empty() bool {
	return r.Status == "" && r.FiveHour == nil && r.SevenDay == nil && r.FiveHourResets == nil && r.SevenDayResets == nil
}

// Parse reads a rate_limit_event line. The format is undocumented, so it
// accepts the shapes seen so far: a flat object with rateLimitType,
// utilization and resetsAt, or per-window objects (five_hour, seven_day)
// under any key. Unknown shapes produce an empty reading, never an error.
func Parse(data map[string]any) Reading {
	info := data
	if v, ok := data["rate_limit_info"].(map[string]any); ok {
		info = v
	}
	var r Reading
	r.Status, _ = info["status"].(string)

	setWindow := func(name string, w map[string]any) {
		u := utilization(w)
		at := resetsAt(w)
		switch {
		case strings.HasPrefix(name, "five_hour") || name == "session" || name == "5h":
			if u != nil {
				r.FiveHour = u
			}
			if at != nil {
				r.FiveHourResets = at
			}
		case strings.HasPrefix(name, "seven_day") || name == "weekly" || name == "7d":
			// seven_day_opus and similar sub-limits: keep the highest.
			if u != nil && (r.SevenDay == nil || *u > *r.SevenDay) {
				r.SevenDay = u
			}
			if at != nil {
				r.SevenDayResets = at
			}
		}
	}

	if typ, ok := info["rateLimitType"].(string); ok {
		setWindow(typ, info)
	}
	if typ, ok := info["type"].(string); ok && typ != "rate_limit_event" {
		setWindow(typ, info)
	}
	var walk func(m map[string]any, depth int)
	walk = func(m map[string]any, depth int) {
		if depth > 3 {
			return
		}
		for k, v := range m {
			if w, ok := v.(map[string]any); ok {
				setWindow(k, w)
				walk(w, depth+1)
			}
		}
	}
	walk(info, 0)
	return r
}

func number(v any) (float64, bool) {
	switch x := v.(type) {
	case float64:
		return x, true
	case int:
		return float64(x), true
	case int64:
		return float64(x), true
	case string:
		f, err := strconv.ParseFloat(x, 64)
		return f, err == nil
	}
	return 0, false
}

func utilization(w map[string]any) *float64 {
	for _, k := range []string{"utilization", "used", "usage", "percent"} {
		if f, ok := number(w[k]); ok {
			if f > 1.5 { // a percentage
				f /= 100
			}
			f = math.Max(0, math.Min(f, 1))
			return &f
		}
	}
	return nil
}

func resetsAt(w map[string]any) *time.Time {
	for _, k := range []string{"resetsAt", "resets_at", "resetAt", "reset_at"} {
		switch x := w[k].(type) {
		case string:
			if t, err := time.Parse(time.RFC3339, x); err == nil {
				return &t
			}
			if f, err := strconv.ParseFloat(x, 64); err == nil {
				t := epoch(f)
				return &t
			}
		default:
			if f, ok := number(x); ok && f > 0 {
				t := epoch(f)
				return &t
			}
		}
	}
	return nil
}

// epoch accepts seconds or milliseconds.
func epoch(f float64) time.Time {
	if f > 1e12 {
		return time.UnixMilli(int64(f))
	}
	return time.Unix(int64(f), 0)
}

// Refresher runs a tiny Claude invocation to get a fresh reading.
type Refresher struct {
	tracker *Tracker
	runner  orchestrator.Runner
	image   string
	log     *slog.Logger
}

// NewRefresher returns a refresher using the runner image.
func NewRefresher(t *Tracker, r orchestrator.Runner, image string, log *slog.Logger) *Refresher {
	return &Refresher{tracker: t, runner: r, image: image, log: log}
}

// ErrBusy is returned when a refresh is already running.
var ErrBusy = errors.New("a usage refresh is already running")

// Refresh starts a refresh in the background, on the account ctx resolves
// to.
func (r *Refresher) Refresh(ctx context.Context) error {
	ctx = r.tracker.account(ctx)
	r.tracker.mu.Lock()
	if r.tracker.refreshing {
		r.tracker.mu.Unlock()
		return ErrBusy
	}
	r.tracker.refreshing = true
	r.tracker.mu.Unlock()
	go func() {
		defer func() {
			r.tracker.mu.Lock()
			r.tracker.refreshing = false
			r.tracker.mu.Unlock()
		}()
		bg, cancel := context.WithTimeout(context.WithoutCancel(ctx), 3*time.Minute)
		defer cancel()
		if err := r.run(bg); err != nil {
			r.log.Warn("usage refresh", "err", err)
			_ = r.tracker.events.AppendEvent(bg, domain.Event{Type: domain.EventUsageUpdated, Level: domain.LevelWarn, Message: "usage refresh failed: " + err.Error()})
		}
	}()
	return nil
}

func (r *Refresher) run(ctx context.Context) error {
	var empty bytes.Buffer
	_ = tar.NewWriter(&empty).Close()
	ws, err := r.runner.Open(ctx, orchestrator.WorkspaceSpec{TicketKey: "usage-refresh", Image: r.image, Repo: &empty})
	if err != nil {
		return err
	}
	defer func() { _ = ws.Close(context.WithoutCancel(ctx)) }()
	got := false
	res, err := ws.Claude(ctx, orchestrator.ClaudeRequest{
		Prompt: "Reply with the single word OK.", Model: "haiku", MaxTurns: 1, Timeout: 2 * time.Minute,
	}, func(e orchestrator.ClaudeEvent) {
		if e.Kind == orchestrator.ClaudeRateLimit {
			got = true
			r.tracker.Record(ctx, e.Data)
		}
	})
	if err != nil {
		return err
	}
	if res.RateLimited {
		r.tracker.RecordLimited(ctx)
	} else if !got {
		// No reading in the stream: at least record that runs are allowed.
		r.tracker.Record(ctx, map[string]any{"rate_limit_info": map[string]any{"status": "allowed"}})
	}
	return nil
}

// IdleLoop refreshes, every interval while no stage is running, the
// accounts accounts lists (the ones paused at their limit: a fresh reading
// lets their runs resume as soon as the limit resets).
func (r *Refresher) IdleLoop(ctx context.Context, every time.Duration, active func() int, accounts func(ctx context.Context) []domain.ClaudeAccount) {
	t := time.NewTicker(every)
	defer t.Stop()
	for {
		select {
		case <-ctx.Done():
			return
		case <-t.C:
			if active() != 0 {
				continue
			}
			for _, a := range accounts(ctx) {
				if ctx.Err() != nil {
					return
				}
				actx, cancel := context.WithTimeout(domain.WithClaude(ctx, a), 3*time.Minute)
				if err := r.run(actx); err != nil {
					r.log.Warn("idle usage refresh", "account", a.ConnectionID, "err", err)
				}
				cancel()
			}
		}
	}
}
