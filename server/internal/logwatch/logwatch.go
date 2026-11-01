// Package logwatch reads projects' logs (through package logsource),
// groups what the detectors find into findings, and, as the workspace's
// settings say, records, reports or opens a ticket for each. Tickets go
// through the usual flow: nothing is pushed before someone approves.
package logwatch

import (
	"context"
	"errors"
	"fmt"
	"log/slog"
	"regexp"
	"slices"
	"strings"
	"sync"
	"time"

	"agnts/internal/domain"
	"agnts/internal/logsource"
	"agnts/internal/orchestrator"
	"agnts/internal/store/postgres"
)

// Store keeps sources, services and findings (postgres.Logs).
type Store interface {
	LogSources(ctx context.Context) ([]domain.LogSource, error)
	PullSources(ctx context.Context) ([]domain.LogSource, error)
	LogSource(ctx context.Context, id int64, withAuth bool) (domain.LogSource, error)
	LogSourceByPushToken(ctx context.Context, hash []byte) (domain.LogSource, error)
	SaveLogSource(ctx context.Context, x domain.LogSource, keepAuth bool) (domain.LogSource, error)
	DeleteLogSource(ctx context.Context, id int64) error
	SetLogPushToken(ctx context.Context, id int64, hash []byte) error
	SaveLogRead(ctx context.Context, id int64, st postgres.LogReadState) error
	SetLogServices(ctx context.Context, sourceID int64, svcs []domain.LogService) ([]domain.LogService, error)
	LogKey(ctx context.Context) ([]byte, error)
	RotateLogKey(ctx context.Context) error
	LogFinding(ctx context.Context, id int64) (domain.LogFinding, error)
	LogFindingByTicket(ctx context.Context, key string) (domain.LogFinding, error)
	ListLogFindings(ctx context.Context, q domain.LogFindingFilter) ([]domain.LogFinding, error)
	UpsertLogFinding(ctx context.Context, key domain.LogFinding, sample string, mut func(f *domain.LogFinding, isNew bool) error) (domain.LogFinding, error)
	UpdateLogFinding(ctx context.Context, id int64, mut func(f *domain.LogFinding) error) (domain.LogFinding, error)
	MergeLogScope(ctx context.Context, from, to string, repos []int64) error
	AutoLogTickets(ctx context.Context, since time.Time) (int, error)
	PruneLogSamples(ctx context.Context) (int64, error)
}

// Tickets reads tickets and repositories and writes events.
type Tickets interface {
	TicketByKey(ctx context.Context, key string) (domain.Ticket, error)
	RepositoryByID(ctx context.Context, id int64) (domain.Repository, error)
	ListRepositories(ctx context.Context) ([]domain.Repository, error)
	AppendEvent(ctx context.Context, ev domain.Event) error
}

// Work is the orchestrator: it creates tickets.
type Work interface {
	CreateLogTicket(ctx context.Context, in orchestrator.LogTicketInput, origin domain.Origin) (domain.Ticket, error)
}

// Settings reads the workspace's settings.
type Settings interface {
	Get(ctx context.Context) (domain.Settings, error)
}

// Ancestry tells whether a deployed revision has a fix. Optional.
type Ancestry interface {
	IsAncestor(ctx context.Context, repo domain.Repository, ancestor, sha string) (bool, error)
}

// Triager asks a model about a new finding. Optional (phase 2): with none,
// or none of today's budget left, the rules' result stands.
type Triager interface {
	Triage(ctx context.Context, f domain.LogFinding, sample string) (Triage, error)
}

// Triage is a model's take on a finding.
type Triage struct {
	Class       domain.LogClass
	Severity    domain.LogSeverity
	Title       string
	Remediation string
}

// Service is the log watcher.
type Service struct {
	store    Store
	tickets  Tickets
	work     Work
	settings Settings
	ancestry Ancestry
	triager  Triager
	dialer   logsource.Dialer
	log      *slog.Logger
	now      func() time.Time
	// newPuller makes a source's reader; tests replace it.
	newPuller func(domain.LogSource, *logsource.Client) (logsource.Puller, error)

	rates *rates

	mu      sync.Mutex
	loops   map[int64]context.CancelFunc
	wake    chan struct{}
	digests map[int64]time.Time // workspace → last digest
	triaged map[string]int      // workspace/day → triage calls
}

// New returns the service. ancestry and triager may be nil.
func New(store Store, tickets Tickets, work Work, settings Settings, ancestry Ancestry, dialer logsource.Dialer, log *slog.Logger) *Service {
	return &Service{store: store, tickets: tickets, work: work, settings: settings, ancestry: ancestry, dialer: dialer, log: log,
		now: time.Now, newPuller: logsource.New, rates: newRates(), loops: map[int64]context.CancelFunc{},
		wake: make(chan struct{}, 1), digests: map[int64]time.Time{}, triaged: map[string]int{}}
}

// SetTriager adds model triage (phase 2).
func (s *Service) SetTriager(t Triager) { s.triager = t }

// Errors the HTTP layer maps.
var ErrInvalid = errors.New("invalid")

func invalid(format string, a ...any) error {
	return fmt.Errorf("%w: %s", ErrInvalid, fmt.Sprintf(format, a...))
}

// IngestResult says what one batch did.
type IngestResult struct {
	Entries  int `json:"entries"`
	Events   int `json:"events"`
	Hits     int `json:"hits"`
	Findings int `json:"findings"`
	New      int `json:"new"`
}

// agg is the hits of one batch with the same scope and fingerprint.
type agg struct {
	hit      domain.LogHit
	svc      domain.LogService
	count    int
	first    time.Time
	last     time.Time
	revision string
	burst    bool
}

// Ingest runs one batch of a source's entries through the detectors and
// records what they find. ctx acts in the source's workspace.
func (s *Service) Ingest(ctx context.Context, src domain.LogSource, entries []domain.LogEntry) (IngestResult, error) {
	res := IngestResult{Entries: len(entries)}
	if len(entries) == 0 {
		return res, nil
	}
	st, err := s.settings.Get(ctx)
	if err != nil {
		return res, err
	}
	key, err := s.store.LogKey(ctx)
	if err != nil {
		return res, err
	}
	pats := domain.CompileLogPatterns(st.LogWatch.Patterns)
	extra := make([]*regexp.Regexp, 0, len(pats))
	for _, p := range pats {
		extra = append(extra, p.Re)
	}
	rules := domain.LogRules{Key: key, Production: src.Environment == "production", Patterns: pats}
	services := map[string]domain.LogService{}
	for _, v := range src.Services {
		services[v.Name] = v
	}
	groups := map[string]*agg{}
	var order []string
	add := func(h domain.LogHit, ev domain.LogEvent, burst bool) {
		svc, ok := services[ev.Service]
		if !ok {
			svc = domain.LogService{SourceID: src.ID, Name: ev.Service}
		}
		if svc.Name == "" {
			svc.Name = src.Name
		}
		svc.SourceID = src.ID
		k := svc.Scope() + "\x00" + h.Fingerprint
		g := groups[k]
		if g == nil {
			g = &agg{hit: h, svc: svc, first: ev.Time, last: ev.Time, burst: burst}
			groups[k] = g
			order = append(order, k)
		}
		g.count++
		if ev.Time.Before(g.first) {
			g.first = ev.Time
		}
		if !ev.Time.Before(g.last) {
			g.last = ev.Time
			if ev.Revision != "" {
				g.revision = ev.Revision
			}
		}
		res.Hits++
	}
	for _, ev := range domain.FrameLogs(entries, src.Fields) {
		res.Events++
		if !domain.PassesLogPrefilter(ev, extra) {
			continue
		}
		for _, h := range domain.DetectLog(ev, rules) {
			add(h, ev, false)
		}
		if h, ok := domain.ProbeExposed(ev); ok {
			add(h, ev, false)
		}
		if h, ok := s.rates.observe(src.WorkspaceID, ev); ok {
			add(h, ev, true)
		}
	}
	for _, k := range order {
		g := groups[k]
		isNew, err := s.record(ctx, st, src, g)
		if err != nil {
			return res, err
		}
		res.Findings++
		if isNew {
			res.New++
		}
	}
	return res, nil
}

// immediate: a finding that acts on its first sighting. Only plain
// errors and exceptions (and custom patterns) wait for the threshold;
// a debug-mode banner is logged once at start, a burst is already a count.
func immediate(f domain.LogFinding) bool {
	if f.Severity.AtLeast(domain.LogHigh) || f.Class == domain.LogClassLeak {
		return true
	}
	return f.Detector != "error" && f.Detector != "exception" && !strings.HasPrefix(f.Detector, "pattern:")
}

// record upserts one aggregated hit and acts on it.
func (s *Service) record(ctx context.Context, st domain.Settings, src domain.LogSource, g *agg) (bool, error) {
	h := g.hit
	now := s.now()
	key := domain.LogFinding{Scope: g.svc.Scope(), Service: g.svc.Name, RepoIDs: g.svc.RepoIDs, Category: h.Category,
		Detector: h.Detector, Class: h.Class, Severity: h.Severity, Fingerprint: h.Fingerprint, Title: h.Title, FirstSeenAt: g.first}
	if g.svc.ID != 0 {
		id := g.svc.ID
		key.ServiceID = &id
	}
	sample := sampleText(h, src, g.svc.Name)
	var recurred, newHour bool
	var created bool
	f, err := s.store.UpsertLogFinding(ctx, key, sample, func(f *domain.LogFinding, isNew bool) error {
		created = isNew
		if isNew {
			f.Count, f.HourCount, f.HourStart = 0, 0, now
			f.Remediation, f.SecretMask, f.SecretHMAC, f.Route = h.Remediation, h.SecretMask, h.SecretHMAC, h.Route
		}
		f.Count += int64(g.count)
		if now.Sub(f.HourStart) > time.Hour {
			f.HourStart, f.HourCount, newHour = now, 0, !isNew
		}
		f.HourCount += g.count
		if g.last.After(f.LastSeenAt) {
			f.LastSeenAt = g.last
		}
		if g.revision != "" {
			f.Revision = g.revision
		}
		if h.Severity.Rank() > f.Severity.Rank() {
			f.Severity = h.Severity
		}
		if f.Service == "" || g.svc.ID != 0 {
			f.Service = g.svc.Name
			if g.svc.ID != 0 {
				id := g.svc.ID
				f.ServiceID = &id
			}
		}
		f.RepoIDs = g.svc.RepoIDs
		f.Occurrences = append(f.Occurrences, domain.LogOccurrence{At: g.last, SourceID: src.ID, Service: g.svc.Name, Revision: g.revision, Count: g.count})
		if g.burst {
			f.Bursts = append(pruneBursts(f.Bursts, now), now)
		}
		switch f.Status {
		case domain.LogResolved:
			f.Status, f.Reason = domain.LogOpen, ""
		case domain.LogFixed:
			recurred = g.last.After(derefTime(f.FixedAt))
		}
		return nil
	})
	if err != nil {
		return false, err
	}
	if recurred {
		f = s.recurred(ctx, f)
	}
	if created && s.triager != nil {
		f = s.triage(ctx, st, f, sample)
	}
	if f.Status == domain.LogFixing && newHour && f.TicketKey != "" {
		_ = s.tickets.AppendEvent(ctx, domain.Event{TicketKey: f.TicketKey, Type: domain.EventLogFinding, Origin: domain.OriginSystem,
			Message: fmt.Sprintf("still in the logs: ×%d in the last hour, ×%d in all", f.HourCount, f.Count),
			Data:    map[string]any{"findingId": f.ID, "notify": false}})
	}
	return created, s.act(ctx, st, src, f)
}

func derefTime(t *time.Time) time.Time {
	if t == nil {
		return time.Time{}
	}
	return *t
}

func pruneBursts(b []time.Time, now time.Time) []time.Time {
	out := b[:0]
	for _, t := range b {
		if now.Sub(t) <= 7*24*time.Hour {
			out = append(out, t)
		}
	}
	return out
}

// sampleText is the stored excerpt: what was found, where, and the
// redacted lines.
func sampleText(h domain.LogHit, src domain.LogSource, service string) string {
	var b strings.Builder
	fmt.Fprintf(&b, "source: %s (%s, %s)\nservice: %s\n", src.Name, src.Kind, src.Environment, service)
	if h.Route != "" {
		fmt.Fprintf(&b, "route: %s\n", h.Route)
	}
	if h.SecretMask != "" {
		fmt.Fprintf(&b, "%s: %s\n", h.SecretKind, h.SecretMask)
	}
	b.WriteString("\n")
	for _, l := range h.Lines {
		b.WriteString(l)
		b.WriteByte('\n')
	}
	out := b.String()
	if len(out) > domain.LogEventMaxBytes {
		out = out[:domain.LogEventMaxBytes]
	}
	return out
}

// recurred handles a sighting after the fix merged: a regression when
// the revision is known to contain the fix, "seen again" otherwise.
func (s *Service) recurred(ctx context.Context, f domain.LogFinding) domain.LogFinding {
	reason := "seen again after the fix merged; it may not be deployed yet"
	if f.Revision != "" && f.FixedSHA != "" && s.ancestry != nil {
		for _, id := range f.RepoIDs {
			repo, err := s.tickets.RepositoryByID(ctx, id)
			if err != nil {
				continue
			}
			has, err := s.ancestry.IsAncestor(ctx, repo, f.FixedSHA, f.Revision)
			if err != nil {
				continue
			}
			if !has {
				return f // the deployed revision doesn't have the fix yet
			}
			reason = "back on " + shortSHA(f.Revision) + ", which has the fix"
			break
		}
	}
	out, err := s.store.UpdateLogFinding(ctx, f.ID, func(x *domain.LogFinding) error {
		x.Status, x.Reason = domain.LogRegression, reason
		return nil
	})
	if err != nil {
		s.log.Warn("log regression", "finding", f.ID, "err", err)
		return f
	}
	if out.TicketKey != "" {
		_ = s.tickets.AppendEvent(ctx, domain.Event{TicketKey: out.TicketKey, Type: domain.EventLogFinding, Origin: domain.OriginSystem,
			Level: domain.LevelWarn, Message: "the error this ticket fixed is in the logs again: " + reason,
			Data: map[string]any{"findingId": out.ID, "notify": false}})
	}
	return out
}

func shortSHA(s string) string {
	if len(s) > 10 {
		return s[:10]
	}
	return s
}

// ticketable reports whether a finding may become a ticket by its class:
// attack findings only once they keep coming.
func ticketable(st domain.LogWatchSettings, f domain.LogFinding) bool {
	if f.Class == domain.LogClassAttack {
		return st.AttackTicketAfter > 0 && len(f.Bursts) >= st.AttackTicketAfter
	}
	return f.Class.Ticketable()
}

// serviceKey is how overrides name a service.
func serviceKey(src domain.LogSource, service string) string { return src.Name + "/" + service }

// act applies the policy to a finding that is new, crossed its
// threshold, or regressed.
func (s *Service) act(ctx context.Context, st domain.Settings, src domain.LogSource, f domain.LogFinding) error {
	if f.Status != domain.LogOpen && f.Status != domain.LogRegression {
		return nil // reported, fixing, fixed, muted: already handled
	}
	lw := st.LogWatch
	mode := lw.ModeFor(f.Category, serviceKey(src, f.Service), f.RepoIDs)
	leak := f.Class == domain.LogClassLeak && f.Severity.AtLeast(domain.LogHigh)
	if mode == domain.LogModeOff {
		if !(leak && lw.AlwaysNotifyLeaks) {
			return nil
		}
		mode = domain.LogModeReport
	}
	if f.Class == domain.LogClassNoise || !f.Severity.AtLeast(lw.MinSeverity) {
		return nil
	}
	if !immediate(f) && f.HourCount < lw.Threshold && f.Status != domain.LogRegression {
		return nil
	}
	reason := ""
	if mode == domain.LogModeTicket && f.Status != domain.LogRegression {
		switch {
		case !ticketable(lw, f):
			reason = "not a code bug: see the remediation"
			if f.Class == domain.LogClassAttack {
				reason = fmt.Sprintf("an attack, %d of %d bursts before a hardening ticket", len(f.Bursts), lw.AttackTicketAfter)
			}
		case len(f.RepoIDs) == 0:
			reason = "no repository selected for this service"
		case f.TicketKey != "":
			reason = ""
		default:
			since := s.now().Add(-24 * time.Hour)
			n, err := s.store.AutoLogTickets(ctx, since)
			if err != nil {
				return err
			}
			if n >= lw.MaxAutoPerDay {
				reason = fmt.Sprintf("today's budget of %d automatic tickets is used; Fix it starts one now", lw.MaxAutoPerDay)
				break
			}
			t, err := s.openTicket(ctx, f, domain.OriginSystem)
			if err == nil {
				s.emit(ctx, f, t.Key, "new", !lw.Digest)
				return nil
			}
			s.log.Warn("log ticket", "finding", f.ID, "err", err)
			reason = "could not open a ticket: " + err.Error()
		}
	}
	kind := "new"
	if f.Status == domain.LogRegression {
		kind = "regression"
	}
	now := s.now()
	out, err := s.store.UpdateLogFinding(ctx, f.ID, func(x *domain.LogFinding) error {
		if x.Status == domain.LogOpen {
			x.Status = domain.LogReported
		}
		if reason != "" || x.Status != domain.LogRegression {
			x.Reason = reason
		}
		x.ReportedAt = &now
		return nil
	})
	if err != nil {
		return err
	}
	s.emit(ctx, out, out.TicketKey, kind, !lw.Digest || leak)
	return nil
}

// emit writes the finding's event; notify sends it to the phone and
// Telegram (the notifier reads the event).
func (s *Service) emit(ctx context.Context, f domain.LogFinding, ticket, kind string, notify bool) {
	ev := domain.Event{TicketKey: ticket, Type: domain.EventLogFinding, Origin: domain.OriginSystem, Message: f.Title,
		Data: map[string]any{"findingId": f.ID, "title": f.Title, "service": f.Service, "category": string(f.Category),
			"severity": string(f.Severity), "class": string(f.Class), "count": f.Count, "kind": kind, "notify": notify,
			"mask": f.SecretMask, "remediation": f.Remediation, "reason": f.Reason, "repos": strings.Join(f.RepoNames, ", ")}}
	if f.Category == domain.LogSecurity || f.Severity.AtLeast(domain.LogHigh) {
		ev.Level = domain.LevelWarn
	}
	if err := s.tickets.AppendEvent(ctx, ev); err != nil {
		s.log.Warn("log finding event", "finding", f.ID, "err", err)
	}
}

// triage asks the model about a new finding, within today's budget.
func (s *Service) triage(ctx context.Context, st domain.Settings, f domain.LogFinding, sample string) domain.LogFinding {
	if st.LogWatch.TriagePerDay <= 0 {
		return f
	}
	day := fmt.Sprintf("%d/%s", domain.WorkspaceOf(ctx), s.now().Format("2006-01-02"))
	s.mu.Lock()
	if s.triaged[day] >= st.LogWatch.TriagePerDay {
		s.mu.Unlock()
		return f
	}
	s.triaged[day]++
	s.mu.Unlock()
	t, err := s.triager.Triage(ctx, f, sample)
	if err != nil {
		s.log.Info("log triage", "finding", f.ID, "err", err)
		return f
	}
	out, err := s.store.UpdateLogFinding(ctx, f.ID, func(x *domain.LogFinding) error {
		if t.Class != "" && slices.Contains([]domain.LogClass{domain.LogClassCode, domain.LogClassConfig, domain.LogClassInfra,
			domain.LogClassDependency, domain.LogClassLeak, domain.LogClassExposure, domain.LogClassWeakness, domain.LogClassAttack,
			domain.LogClassNoise}, t.Class) {
			x.Class = t.Class
		}
		if t.Severity.Rank() >= 0 {
			x.Severity = t.Severity
		}
		if t.Title = strings.TrimSpace(t.Title); t.Title != "" && len([]rune(t.Title)) <= 160 {
			x.Title = t.Title
		}
		if t.Remediation = strings.TrimSpace(t.Remediation); t.Remediation != "" {
			x.Remediation = t.Remediation
		}
		return nil
	})
	if err != nil {
		return f
	}
	return out
}
