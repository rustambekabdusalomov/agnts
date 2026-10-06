package notify

import (
	"context"
	"crypto/rand"
	"encoding/hex"
	"errors"
	"fmt"
	"log/slog"
	"strings"
	"time"

	"agnts/internal/domain"
	"agnts/internal/orchestrator"
	"agnts/internal/store/postgres"
)

// Actions are the ticket use cases the bot can trigger.
type Actions interface {
	View(ctx context.Context, key string) (orchestrator.TicketView, error)
	AnswerOne(ctx context.Context, key string, a domain.Answer, origin domain.Origin) (bool, error)
	Approve(ctx context.Context, key string, assignees []string, postReport bool, origin domain.Origin) (domain.Ticket, error)
	RequestChanges(ctx context.Context, key, feedback string, origin domain.Origin) (domain.Ticket, error)
	Reject(ctx context.Context, key, reason string, origin domain.Origin) (domain.Ticket, error)
	Retry(ctx context.Context, key string, origin domain.Origin) (domain.Ticket, error)
}

// Store is what the notifier persists.
type Store interface {
	Events(ctx context.Context, f orchestrator.EventFilter) ([]domain.Event, error)
	MaxEventID(ctx context.Context) (int64, error)
	Cursor(ctx context.Context, name string) (int64, error)
	SetCursor(ctx context.Context, name string, id int64) error
	Devices(ctx context.Context) ([]postgres.Device, error)
	DeleteDevice(ctx context.Context, token string) error
	SaveTelegramMessage(ctx context.Context, m postgres.TelegramMessage) error
	TelegramMessage(ctx context.Context, chatID, messageID int64) (postgres.TelegramMessage, error)
	CreatePending(ctx context.Context, a postgres.PendingAction) error
	ConfirmPending(ctx context.Context, id string, origin domain.Origin) (postgres.PendingAction, error)
	CancelPending(ctx context.Context, id string) error
	SeenDelivery(ctx context.Context, provider, id string) (bool, error)
	AppendEvent(ctx context.Context, ev domain.Event) error
}

// TelegramSource loads the current Telegram connection (ok=false if none).
type TelegramSource func(ctx context.Context) (cfg TelegramConfig, ok bool, err error)

// Notifier turns state changes into push and Telegram messages.
type Notifier struct {
	store    Store
	actions  Actions
	settings orchestrator.SettingsSource
	fcm      *FCM // nil when push is not configured
	telegram TelegramSource
	botAPI   string
	log      *slog.Logger
	wake     chan struct{}
}

// New returns a notifier. fcm may be nil.
func New(store Store, actions Actions, settings orchestrator.SettingsSource, fcm *FCM, telegram TelegramSource, botAPI string, log *slog.Logger) *Notifier {
	return &Notifier{store: store, actions: actions, settings: settings, fcm: fcm, telegram: telegram, botAPI: botAPI, log: log, wake: make(chan struct{}, 1)}
}

// Wake asks the loop to look for new events now.
func (n *Notifier) Wake() {
	select {
	case n.wake <- struct{}{}:
	default:
	}
}

const cursorName = "notifier"

// Run follows the event log from a saved cursor, so a restart neither
// loses nor repeats notifications.
func (n *Notifier) Run(ctx context.Context) {
	cur, err := n.store.Cursor(ctx, cursorName)
	if err != nil {
		n.log.Error("notifier: read cursor", "err", err)
		return
	}
	if cur < 0 { // first start: don't notify about history
		if cur, err = n.store.MaxEventID(ctx); err != nil {
			n.log.Error("notifier: start", "err", err)
			return
		}
		_ = n.store.SetCursor(ctx, cursorName, cur)
	}
	tick := time.NewTicker(30 * time.Second)
	defer tick.Stop()
	for {
		for {
			evs, err := n.store.Events(ctx, orchestrator.EventFilter{AfterID: cur, Limit: 200})
			if err != nil {
				if ctx.Err() == nil {
					n.log.Warn("notifier: read events", "err", err)
				}
				break
			}
			for _, e := range evs {
				n.handle(ctx, e)
				cur = e.ID
			}
			if len(evs) > 0 {
				if err := n.store.SetCursor(ctx, cursorName, cur); err != nil {
					n.log.Warn("notifier: save cursor", "err", err)
				}
			}
			if len(evs) < 200 {
				break
			}
		}
		select {
		case <-ctx.Done():
			return
		case <-n.wake:
		case <-tick.C:
		}
	}
}

// kind of notification for a state, or "" for none.
func kindFor(to domain.TicketState) string {
	switch to {
	case domain.StateWaitingForAnswers, domain.StateWaitingForReview:
		return "needs"
	case domain.StateFailed, domain.StateRateLimited:
		return "stopped"
	case domain.StateDone:
		return "done"
	}
	return ""
}

func (n *Notifier) handle(ctx context.Context, e domain.Event) {
	if e.Type == domain.EventLessons {
		n.lessons(ctx, e)
		return
	}
	if e.Type == domain.EventReview {
		n.review(ctx, e)
		return
	}
	if e.Type == domain.EventFollowUps {
		n.followUps(ctx, e)
		return
	}
	to, _ := e.Data["to"].(string)
	if e.TicketKey == "" || to == "" {
		return
	}
	kind := kindFor(domain.TicketState(to))
	if kind == "" {
		return
	}
	s, err := n.settings.Get(ctx)
	if err != nil {
		return
	}
	on := map[string]bool{"needs": s.Notify.NeedsYou, "stopped": s.Notify.Stopped, "done": s.Notify.Done}[kind]
	if !on {
		return
	}
	v, err := n.actions.View(ctx, e.TicketKey)
	if err != nil {
		return // deleted since
	}
	if v.Ticket.State != domain.TicketState(to) {
		return // already moved on; don't ask about a stale state
	}
	title, body := pushText(v, e)
	if s.Notify.Push && n.fcm != nil {
		n.push(ctx, Push{Title: title, Body: body, Ticket: v.Ticket.Key})
	}
	if s.Notify.Telegram {
		if err := n.sendTelegram(ctx, v, e); err != nil {
			n.log.Warn("telegram notify", "ticket", e.TicketKey, "err", err)
		}
	}
}

// lessons announces what a learn run found. Runs that found nothing stay quiet.
func (n *Notifier) lessons(ctx context.Context, e domain.Event) {
	count, _ := e.Data["count"].(float64) // numbers come back from JSON as float64
	if count < 1 || e.TicketKey == "" {
		return
	}
	s, err := n.settings.Get(ctx)
	if err != nil || !s.Notify.Lessons {
		return
	}
	var titles []string
	if ts, ok := e.Data["titles"].([]any); ok {
		for _, t := range ts {
			if t, ok := t.(string); ok {
				titles = append(titles, t)
			}
		}
	}
	route := "/learn?ticket=" + e.TicketKey
	if ids, ok := e.Data["ids"].([]any); ok && len(ids) == 1 {
		if id, ok := ids[0].(float64); ok {
			route = fmt.Sprintf("/learn/%d", int64(id))
		}
	}
	title := fmt.Sprintf("%s: %d new lessons to learn", e.TicketKey, int(count))
	if count == 1 {
		title = e.TicketKey + ": a new lesson to learn"
	}
	if s.Notify.Push && n.fcm != nil {
		n.push(ctx, Push{Title: title, Body: truncate(strings.Join(titles, " · "), 180), Ticket: e.TicketKey, Route: route})
	}
	if !s.Notify.Telegram {
		return
	}
	b, cfg, ok := n.bot(ctx)
	if !ok {
		return
	}
	text := fmt.Sprintf("agnts used something new in this codebase while working on %s:\n", e.TicketKey)
	for _, t := range titles {
		text += "\n• " + t
	}
	text += "\n\nRead the lessons and take the quiz under Learn in agnts."
	if _, err := b.Send(ctx, cfg.ChatID, text, nil, false); err != nil {
		n.log.Warn("telegram notify", "ticket", e.TicketKey, "err", err)
	}
}

// followUps announces follow-up tickets a run suggested. They wait for
// someone to pick them on the ticket page.
func (n *Notifier) followUps(ctx context.Context, e domain.Event) {
	count, _ := e.Data["count"].(float64) // numbers come back from JSON as float64
	if count < 1 || e.TicketKey == "" {
		return
	}
	s, err := n.settings.Get(ctx)
	if err != nil || !s.Notify.FollowUps {
		return
	}
	var titles []string
	if ts, ok := e.Data["titles"].([]any); ok {
		for _, t := range ts {
			if t, ok := t.(string); ok {
				titles = append(titles, t)
			}
		}
	}
	title := fmt.Sprintf("%s suggests %d follow-up tickets", e.TicketKey, int(count))
	if count == 1 {
		title = e.TicketKey + " suggests a follow-up ticket"
	}
	if s.Notify.Push && n.fcm != nil {
		n.push(ctx, Push{Title: title, Body: truncate(strings.Join(titles, " · "), 180), Ticket: e.TicketKey})
	}
	if !s.Notify.Telegram {
		return
	}
	b, cfg, ok := n.bot(ctx)
	if !ok {
		return
	}
	text := fmt.Sprintf("Finishing %s may need more tickets:\n", e.TicketKey)
	for _, t := range titles {
		text += "\n• " + t
	}
	text += "\n\nPick the ones you want on the ticket page in agnts; they are created queued."
	if _, err := b.Send(ctx, cfg.ChatID, text, nil, false); err != nil {
		n.log.Warn("telegram notify", "ticket", e.TicketKey, "err", err)
	}
}

// review announces a finished code review while its ticket still waits
// for the human review.
func (n *Notifier) review(ctx context.Context, e domain.Event) {
	s, err := n.settings.Get(ctx)
	if err != nil || !s.Notify.Review || e.TicketKey == "" {
		return
	}
	v, err := n.actions.View(ctx, e.TicketKey)
	if err != nil || v.Ticket.State != domain.StateWaitingForReview || v.Review == nil || v.Review.Revision != v.Ticket.Revision {
		return // approved or sent back since
	}
	verdict := map[string]string{
		domain.VerdictLooksGood: "looks good", domain.VerdictHasConcerns: "has concerns", domain.VerdictNeedsChanges: "needs changes",
	}[v.Review.Verdict]
	title := fmt.Sprintf("%s: code review %s", v.Ticket.Key, verdict)
	counts := v.Review.Counts()
	var parts []string
	for _, sev := range domain.FindingSeverities {
		if c := counts[sev]; c > 0 {
			parts = append(parts, fmt.Sprintf("%d %s", c, sev))
		}
	}
	body := "No findings."
	if len(parts) > 0 {
		body = strings.Join(parts, ", ")
	}
	if s.Notify.Push && n.fcm != nil {
		n.push(ctx, Push{Title: title, Body: body, Ticket: v.Ticket.Key})
	}
	if !s.Notify.Telegram {
		return
	}
	b, cfg, ok := n.bot(ctx)
	if !ok {
		return
	}
	text := fmt.Sprintf("agnts reviewed its work on %s: %s.\n\n%s", v.Ticket.Key, verdict, v.Review.Summary)
	for i, f := range v.Review.Findings {
		if i == 5 {
			text += fmt.Sprintf("\n… and %d more", len(v.Review.Findings)-5)
			break
		}
		text += fmt.Sprintf("\n• [%s] %s", f.Severity, f.Title)
	}
	text += "\n\nThe full review is on the ticket in agnts."
	if _, err := b.Send(ctx, cfg.ChatID, truncate(text, 3500), nil, false); err != nil {
		n.log.Warn("telegram notify", "ticket", e.TicketKey, "err", err)
	}
}

func pushText(v orchestrator.TicketView, e domain.Event) (string, string) {
	k := v.Ticket.Key
	switch v.Ticket.State {
	case domain.StateWaitingForAnswers:
		return fmt.Sprintf("%s: %d questions", k, len(v.Questions)), v.Ticket.Title
	case domain.StateWaitingForReview:
		return k + " is ready for review", v.Ticket.Title
	case domain.StateRateLimited:
		return k + " paused at the plan limit", "It resumes after the limit resets."
	case domain.StateFailed:
		return k + " stopped", truncate(e.Message, 180)
	default:
		if v.Ticket.Kind.Report() {
			return k + " is done", v.Ticket.Title
		}
		return k + " pushed", v.Ticket.PRURL
	}
}

func (n *Notifier) push(ctx context.Context, p Push) {
	devs, err := n.store.Devices(ctx)
	if err != nil {
		n.log.Warn("push: devices", "err", err)
		return
	}
	for _, d := range devs {
		err := n.fcm.Send(ctx, d.FCMToken, p)
		switch {
		case errors.Is(err, ErrUnregistered):
			_ = n.store.DeleteDevice(ctx, d.FCMToken)
		case err != nil:
			n.log.Warn("push", "device", d.ID, "err", err)
		}
	}
}

func (n *Notifier) bot(ctx context.Context) (*Bot, TelegramConfig, bool) {
	if n.telegram == nil {
		return nil, TelegramConfig{}, false
	}
	cfg, ok, err := n.telegram(ctx)
	if err != nil || !ok || cfg.ChatID == 0 || cfg.BotToken == "" {
		return nil, cfg, false
	}
	return NewBot(n.botAPI, cfg.BotToken), cfg, true
}

func (n *Notifier) sendTelegram(ctx context.Context, v orchestrator.TicketView, e domain.Event) error {
	b, cfg, ok := n.bot(ctx)
	if !ok {
		return nil
	}
	t := v.Ticket
	save := func(id int64, kind string, ref *int64) error {
		return n.store.SaveTelegramMessage(ctx, postgres.TelegramMessage{ChatID: cfg.ChatID, MessageID: id, TicketKey: t.Key, Kind: kind, Ref: ref})
	}
	switch t.State {
	case domain.StateWaitingForAnswers:
		head := fmt.Sprintf("%s: %s\n\nagnts has %d question(s) before coding. Tap an option, or reply to a question with your own answer.", t.Key, t.Title, len(v.Questions))
		if v.Analysis != nil {
			head += "\n\nWhat agnts found: " + truncate(v.Analysis.Summary, 600)
		}
		if _, err := b.Send(ctx, cfg.ChatID, head, nil, false); err != nil {
			return err
		}
		for _, q := range v.Questions {
			if q.Answer != nil {
				continue
			}
			var rows [][]Button
			for i, o := range q.Options {
				rows = append(rows, []Button{{Text: truncate(o, 60), Data: fmt.Sprintf("ans:%d:%d", q.ID, i)}})
			}
			id, err := b.Send(ctx, cfg.ChatID, fmt.Sprintf("%d. %s", q.Position, q.Text), rows, len(rows) == 0)
			if err != nil {
				return err
			}
			qid := q.ID
			if err := save(id, "question", &qid); err != nil {
				return err
			}
		}
		return nil
	case domain.StateWaitingForReview:
		text := fmt.Sprintf("%s is ready for review: %s", t.Key, t.Title)
		approve := "Approve and push"
		if t.Kind.Report() {
			// A report keeps to agnts from here; posting it to Jira is a choice made in the app.
			approve = "Approve"
			text = fmt.Sprintf("The %s report on %s is ready for review: %s", t.Kind, t.Key, t.Title)
			if r := v.Result; r != nil {
				if sum := summaryText(r.Summary); sum != "" {
					text += "\n\n" + truncate(sum, 900)
				}
			}
			text += "\n\nRead the report in agnts before approving. Approving here keeps it in agnts; to post it to Jira, approve in the app."
		} else if r := v.Result; r != nil {
			add, del := 0, 0
			for _, f := range r.Files {
				add += f.Add
				del += f.Del
			}
			text += fmt.Sprintf("\n\n%d files changed, +%d −%d.", len(r.Files), add, del)
			if sum := summaryText(r.Summary); sum != "" {
				text += "\n\n" + truncate(sum, 900)
			}
		}
		if !t.Kind.Report() {
			text += "\n\nOpen the diff in agnts before approving."
		}
		id, err := b.Send(ctx, cfg.ChatID, text, [][]Button{
			{{Text: approve, Data: "apr:" + t.Key}},
			{{Text: "Request changes", Data: "chg:" + t.Key}, {Text: "Reject", Data: "rej:" + t.Key}},
		}, false)
		if err != nil {
			return err
		}
		return save(id, "review", nil)
	case domain.StateFailed:
		id, err := b.Send(ctx, cfg.ChatID, fmt.Sprintf("%s stopped: %s\n\n%s", t.Key, t.Title, truncate(e.Message, 600)),
			[][]Button{{{Text: "Retry", Data: "rty:" + t.Key}}}, false)
		if err != nil {
			return err
		}
		return save(id, "notice", nil)
	case domain.StateRateLimited:
		_, err := b.Send(ctx, cfg.ChatID, fmt.Sprintf("%s paused at the Claude plan limit. It resumes after the limit resets.", t.Key), nil, false)
		return err
	case domain.StateDone:
		msg := t.Key + " is pushed."
		if t.Kind.Report() {
			msg = t.Key + ": report approved."
		} else if t.PRURL != "" {
			msg = fmt.Sprintf("%s: pull request opened\n%s", t.Key, t.PRURL)
		}
		_, err := b.Send(ctx, cfg.ChatID, msg, nil, false)
		return err
	}
	return nil
}

func summaryText(raw []byte) string {
	var s orchestrator.Summary
	if err := jsonUnmarshal(raw, &s); err != nil {
		return ""
	}
	return s.Summary
}

func truncate(s string, n int) string {
	s = strings.TrimSpace(s)
	if len(s) <= n {
		return s
	}
	return s[:n] + "…"
}

func newID() string {
	b := make([]byte, 6)
	_, _ = rand.Read(b)
	return hex.EncodeToString(b)
}
