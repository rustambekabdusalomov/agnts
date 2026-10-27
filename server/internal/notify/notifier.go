package notify

import (
	"context"
	"crypto/rand"
	"encoding/hex"
	"errors"
	"fmt"
	"io"
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
	RequestChanges(ctx context.Context, key, feedback string, shots []domain.ShotRef, files []int64, origin domain.Origin) (domain.Ticket, error)
	Reject(ctx context.Context, key, reason string, origin domain.Origin) (domain.Ticket, error)
	Retry(ctx context.Context, key string, origin domain.Origin) (domain.Ticket, error)
	RestartWithUpdate(ctx context.Context, key string, origin domain.Origin) (domain.Ticket, error)
	KeepCurrentVersion(ctx context.Context, key string, origin domain.Origin) (domain.Ticket, error)
	OpenShot(ctx context.Context, key string, runID int64, shotID string) (io.ReadCloser, error)
}

// Store is what the notifier persists.
type Store interface {
	Events(ctx context.Context, f orchestrator.EventFilter) ([]domain.Event, error)
	MaxEventID(ctx context.Context) (int64, error)
	Cursor(ctx context.Context, name string) (int64, error)
	SetCursor(ctx context.Context, name string, id int64) error
	Devices(ctx context.Context, ws int64) ([]postgres.Device, error)
	OwnerDevices(ctx context.Context, ws int64, key string) (int64, []postgres.Device, error)
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
	ci       CIFixer // nil: no Fix it button
}

// CIFixer opens a ticket for a CI failure (Telegram's Fix it button).
type CIFixer interface {
	FixIt(ctx context.Context, id int64, origin domain.Origin) (domain.Ticket, error)
}

// SetCIFixer enables the Fix it button on CI messages.
func (n *Notifier) SetCIFixer(c CIFixer) { n.ci = c }

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
	ctx = domain.System(ctx)
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

// kind of notification for a state change, or "" for none. "progress" is
// an agent finishing a step on its own: the analysis (on to coding) or
// the code (on to the tests). Tests sending the code back stay quiet.
func kindFor(from, to domain.TicketState) string {
	if from == domain.StateRejected {
		return "" // a person continued it: they know where it is
	}
	switch to {
	case domain.StateWaitingForAnswers, domain.StateWaitingForReview:
		return "needs"
	case domain.StateFailed, domain.StateRateLimited:
		return "stopped"
	case domain.StateDone:
		return "done"
	case domain.StateCoding:
		if from == domain.StateAnalyzing {
			return "progress"
		}
	case domain.StateTesting:
		if from == domain.StateCoding {
			return "progress"
		}
	}
	return ""
}

func (n *Notifier) handle(ctx context.Context, e domain.Event) {
	if e.WorkspaceID == 0 {
		return // server-wide events reach nobody's phone
	}
	// Everything below acts in the event's workspace: its settings, its
	// Telegram connection, its members' phones.
	ctx = domain.WithWorkspace(ctx, e.WorkspaceID)
	if e.Type == domain.EventLessons {
		n.lessons(ctx, e)
		return
	}
	if e.Type == domain.EventReview {
		n.review(ctx, e)
		return
	}
	if e.Type == domain.EventPreview {
		n.preview(ctx, e)
		return
	}
	if e.Type == domain.EventFollowUps {
		n.followUps(ctx, e)
		return
	}
	if e.Type == domain.EventTrackerChanged {
		n.trackerChanged(ctx, e)
		return
	}
	if e.Type == domain.EventCIFailure {
		n.ciFailure(ctx, e)
		return
	}
	to, _ := e.Data["to"].(string)
	if e.TicketKey == "" || to == "" {
		return
	}
	if quiet, _ := e.Data["quiet"].(bool); quiet {
		return // announced later, once agnts's own review lets it through
	}
	from, _ := e.Data["from"].(string)
	kind := kindFor(domain.TicketState(from), domain.TicketState(to))
	if kind == "" {
		return
	}
	s, err := n.settings.Get(ctx)
	if err != nil {
		return
	}
	on := map[string]bool{"needs": s.Notify.NeedsYou, "stopped": s.Notify.Stopped, "done": s.Notify.Done, "progress": s.Notify.Progress}[kind]
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
		// One notification per ticket for its steps: each replaces the last.
		p := Push{Title: title, Body: body, Ticket: v.Ticket.Key, Tag: v.Ticket.Key + ":state", Quiet: kind == "progress", Actor: e.UserID}
		if v.Swagger != nil && v.Ticket.State == domain.StateWaitingForReview {
			p.Route = "/tickets/" + v.Ticket.Key + "/api-results" // the app's results screen
		}
		n.push(ctx, p)
	}
	if s.Notify.Telegram && kind != "progress" { // steps would flood a shared chat
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
// trackerChanged asks whether to restart a started ticket whose issue
// changed in the tracker, or keep the version agnts works from.
func (n *Notifier) trackerChanged(ctx context.Context, e domain.Event) {
	s, err := n.settings.Get(ctx)
	if err != nil || !s.Notify.NeedsYou || e.TicketKey == "" {
		return
	}
	v, err := n.actions.View(ctx, e.TicketKey)
	if err != nil || v.Ticket.Update == nil {
		return // decided already
	}
	src := v.Ticket.Source.Name()
	title := fmt.Sprintf("%s changed in %s", e.TicketKey, src)
	if s.Notify.Push && n.fcm != nil {
		n.push(ctx, Push{Title: title, Body: "agnts started on the old version: restart with the new one, or keep going?", Ticket: e.TicketKey})
	}
	if !s.Notify.Telegram {
		return
	}
	b, cfg, ok := n.bot(ctx)
	if !ok {
		return
	}
	text := fmt.Sprintf("%s changed in %s after agnts started on it (%s).\n\nNow: %s\n\n%s\n\nRestart drops the work so far and starts over from the new version; Keep finishes the current one.",
		e.TicketKey, src, strings.ReplaceAll(string(v.Ticket.State), "_", " "), v.Ticket.Update.Title, truncate(v.Ticket.Update.Description, 900))
	id, err := b.Send(ctx, cfg.ChatID, text, [][]Button{
		{{Text: "Restart with the new version", Data: "rsu:" + e.TicketKey}},
		{{Text: "Keep the current version", Data: "kpv:" + e.TicketKey}},
	}, false)
	if err != nil {
		n.log.Warn("telegram notify", "ticket", e.TicketKey, "err", err)
		return
	}
	_ = n.store.SaveTelegramMessage(ctx, postgres.TelegramMessage{ChatID: cfg.ChatID, MessageID: id, TicketKey: e.TicketKey, Kind: "notice"})
}

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

// maxPreviewPhotos is how many screenshots go to Telegram with a preview.
const maxPreviewPhotos = 4

// preview announces screenshots of the change under review, with the
// phone-width ones attached in Telegram when asked for.
func (n *Notifier) preview(ctx context.Context, e domain.Event) {
	s, err := n.settings.Get(ctx)
	if err != nil || !s.Notify.Preview || e.TicketKey == "" {
		return
	}
	v, err := n.actions.View(ctx, e.TicketKey)
	p := v.Preview
	if err != nil || v.Ticket.State != domain.StateWaitingForReview || p == nil || p.Revision != v.Ticket.Revision {
		return // approved or sent back since
	}
	k := v.Ticket.Key
	title := fmt.Sprintf("%s: %d %s", k, len(p.Shots), plural(len(p.Shots), "screenshot", "screenshots"))
	body := "No visual problems seen."
	switch {
	case p.Status == domain.PreviewBroken:
		title, body = k+": the app did not start", "The change may have broken it; the log is on the ticket."
	case len(p.Issues) > 0:
		body = fmt.Sprintf("%d %s, the worst %s.", len(p.Issues), plural(len(p.Issues), "issue", "issues"), p.Issues[0].Severity)
	}
	if s.Notify.Push && n.fcm != nil {
		n.push(ctx, Push{Title: title, Body: body, Ticket: k})
	}
	if !s.Notify.Telegram {
		return
	}
	b, cfg, ok := n.bot(ctx)
	if !ok {
		return
	}
	text := fmt.Sprintf("Screenshots of %s are ready.\n\n%s", k, p.Summary)
	if p.Status == domain.PreviewBroken {
		text = fmt.Sprintf("agnts could not start the app for %s.\n\n%s", k, truncate(p.Summary, 1500))
	}
	for i, is := range p.Issues {
		if i == 5 {
			text += fmt.Sprintf("\n… and %d more", len(p.Issues)-5)
			break
		}
		text += fmt.Sprintf("\n• [%s] %s", is.Severity, is.Description)
	}
	text += "\n\nAll screenshots are on the ticket in agnts."
	if _, err := b.Send(ctx, cfg.ChatID, truncate(text, 3500), nil, false); err != nil {
		n.log.Warn("telegram notify", "ticket", k, "err", err)
		return
	}
	if !s.Notify.PreviewPhotos {
		return
	}
	var photos [][]byte
	for _, want := range []string{"phone", "desktop"} {
		for _, sh := range p.Shots {
			if len(photos) == maxPreviewPhotos || len(photos) > 0 && want == "desktop" {
				break // phone shots first; desktop ones only when there are none
			}
			if sh.Viewport != want || sh.Side != "after" {
				continue
			}
			rc, err := n.actions.OpenShot(ctx, k, p.RunID, sh.ID)
			if err != nil {
				continue
			}
			img, err := io.ReadAll(io.LimitReader(rc, 10<<20))
			_ = rc.Close()
			if err == nil {
				photos = append(photos, img)
			}
		}
	}
	if err := b.SendPhotos(ctx, cfg.ChatID, truncate(k+" · "+p.Summary, 1000), photos); err != nil {
		n.log.Warn("telegram photos", "ticket", k, "err", err)
	}
}

// swaggerLine is "API-7: 37 passed, 3 failed", new failures first for a
// test compared with its last run.
func swaggerLine(key string, sw orchestrator.SwaggerView) string {
	line := key + ": " + sw.Run.Results.Counts().SummaryLine()
	if n := len(sw.NewFailures); n > 0 {
		line = fmt.Sprintf("%s: %d new %s · %s", key, n, plural(n, "failure", "failures"), sw.Run.Results.Counts().SummaryLine())
	}
	return line
}

// swaggerText is a Swagger test's results for Telegram: the counts, what
// is new, and the first failures.
func swaggerText(t domain.Ticket, sw orchestrator.SwaggerView) string {
	text := swaggerLine(t.Key, sw) + "\n" + t.Title
	if len(sw.NewFailures) > 0 {
		text += "\n\nNew since the last run:\n- " + truncate(strings.Join(sw.NewFailures, "\n- "), 900)
	}
	shown := 0
	for _, c := range sw.Run.Results.Cases {
		if c.Verdict != domain.VerdictFail {
			continue
		}
		if shown == 0 {
			text += "\n\nFailures:"
		}
		if shown == 5 {
			text += "\n…"
			break
		}
		text += "\n- " + c.Operation + " · " + truncate(c.Case+": "+c.Reason, 200)
		shown++
	}
	return text + "\n\nOpen the API results in agnts for the request and response behind each one."
}

func plural(n int, one, many string) string {
	if n == 1 {
		return one
	}
	return many
}

func pushText(v orchestrator.TicketView, e domain.Event) (string, string) {
	k := v.Ticket.Key
	switch v.Ticket.State {
	case domain.StateCoding:
		return k + ": analysis done, coding", v.Ticket.Title
	case domain.StateTesting:
		return k + ": code written, running checks", v.Ticket.Title
	case domain.StateWaitingForAnswers:
		return fmt.Sprintf("%s: %d questions", k, len(v.Questions)), v.Ticket.Title
	case domain.StateWaitingForReview:
		if sw := v.Swagger; sw != nil && sw.Run != nil {
			return swaggerLine(k, *sw), v.Ticket.Title
		}
		return k + " is ready for review", v.Ticket.Title
	case domain.StateRateLimited:
		return k + " paused at the plan limit", "It resumes after the limit resets."
	case domain.StateFailed:
		return k + " stopped", truncate(e.Message, 180)
	default:
		if v.Ticket.Kind == domain.KindReview {
			return k + " merged", v.Ticket.PRURL
		}
		if v.Ticket.Kind.Report() {
			return k + " is done", v.Ticket.Title
		}
		if prs := v.Ticket.OpenedPRs(); len(prs) > 1 {
			return fmt.Sprintf("%s pushed: %d pull requests", k, len(prs)), prURLs(prs)
		} else if len(prs) == 1 {
			return k + " pushed", prs[0].PRURL // the primary may have had nothing to push
		}
		return k + " pushed", v.Ticket.PRURL
	}
}

// prURLs lists the pull requests of a ticket in several repositories.
func prURLs(prs []domain.TicketRepo) string {
	urls := make([]string, len(prs))
	for i, r := range prs {
		urls[i] = r.PRURL
	}
	return strings.Join(urls, "\n")
}

// push sends p to the phones of the ticket's owner, unless the owner did
// what it announces. A push about no ticket (a red branch) goes to every
// member.
func (n *Notifier) push(ctx context.Context, p Push) {
	ws := domain.WorkspaceOf(ctx)
	p.Workspace = ws
	var devs []postgres.Device
	var err error
	if p.Ticket == "" {
		devs, err = n.store.Devices(ctx, ws)
	} else {
		var owner int64
		owner, devs, err = n.store.OwnerDevices(ctx, ws, p.Ticket)
		if owner != 0 && owner == p.Actor {
			return // they know: they did it
		}
	}
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
			text := fmt.Sprintf("%d. %s", q.Position, q.Text)
			if q.Multiple {
				text += "\n\nSeveral options can apply: tap one, or reply with all that do."
			}
			id, err := b.Send(ctx, cfg.ChatID, text, rows, len(rows) == 0)
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
		approve, change, reject := "Approve and push", "Request changes", "Reject"
		if t.Kind == domain.KindReview && t.Pull != nil {
			approve, change, reject = "Merge", "Review again", "Dismiss"
			text = fmt.Sprintf("agnts reviewed #%d by @%s (%s): %s", t.Pull.Number, t.Pull.Author, t.Key, t.Title)
			if rv := v.Review; rv != nil {
				text += "\n\nVerdict: " + strings.ReplaceAll(rv.Verdict, "_", " ") + "\n" + truncate(rv.Summary, 900)
				for i, f := range rv.Findings {
					if i == 5 {
						text += fmt.Sprintf("\n… and %d more", len(rv.Findings)-5)
						break
					}
					text += "\n- [" + f.Severity + "] " + truncate(f.Title, 200)
				}
			}
			text += "\n\n" + t.PRURL + "\n\nMerge merges it at the commit agnts reviewed; Review again takes your note; Dismiss leaves it to you on the git host."
		} else if sw := v.Swagger; t.Kind == domain.KindSwaggerTest && sw != nil && sw.Run != nil {
			approve = "Approve"
			text = swaggerText(t, *sw)
		} else if t.Kind.Report() {
			// A report keeps to agnts from here; posting it to the tracker is a choice made in the app.
			approve = "Approve"
			text = fmt.Sprintf("The %s report on %s is ready for review: %s", t.Kind, t.Key, t.Title)
			if r := v.Result; r != nil {
				if sum := summaryText(r.Summary); sum != "" {
					text += "\n\n" + truncate(sum, 900)
				}
			}
			text += "\n\nRead the report in agnts before approving. Approving here keeps it in agnts"
			if t.Source.Tracked() {
				text += "; to post it to " + t.Source.Name() + ", approve in the app"
			}
			text += "."
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
			{{Text: change, Data: "chg:" + t.Key}, {Text: reject, Data: "rej:" + t.Key}},
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
		_, err := b.Send(ctx, cfg.ChatID, fmt.Sprintf("%s paused at the %s plan limit. It resumes after the limit resets.", t.Key, domain.ToolName()), nil, false)
		return err
	case domain.StateDone:
		msg := t.Key + " is pushed."
		if t.Kind == domain.KindReview {
			msg = fmt.Sprintf("%s: pull request merged\n%s", t.Key, t.PRURL)
		} else if t.Kind.Report() {
			msg = t.Key + ": report approved."
		} else if prs := t.OpenedPRs(); len(prs) > 1 {
			msg = fmt.Sprintf("%s: %d pull requests opened\n%s", t.Key, len(prs), prURLs(prs))
		} else if len(prs) == 1 {
			msg = fmt.Sprintf("%s: pull request opened\n%s", t.Key, prs[0].PRURL)
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

// ciFailure announces a watched branch going red (once per failure group),
// or a fixed failure coming back. Infra failures and the CI rounds of
// agnts's own pull requests stay quiet.
func (n *Notifier) ciFailure(ctx context.Context, e domain.Event) {
	if on, _ := e.Data["notify"].(bool); !on {
		return
	}
	s, err := n.settings.Get(ctx)
	if err != nil || !s.Notify.CI {
		return
	}
	repo, _ := e.Data["repo"].(string)
	branch, _ := e.Data["branch"].(string)
	what, _ := e.Data["title"].(string)
	kind, _ := e.Data["kind"].(string)
	id, _ := e.Data["failureId"].(float64)
	title := fmt.Sprintf("%s: %s is red", repo, branch)
	if kind == "regression" {
		title = fmt.Sprintf("%s: a fixed CI failure is back on %s", repo, branch)
	}
	if s.Notify.Push && n.fcm != nil {
		route := fmt.Sprintf("/ci/%d", int64(id))
		if e.TicketKey != "" {
			route = "" // the ticket fixing it
		}
		n.push(ctx, Push{Title: title, Body: truncate(what, 180), Ticket: e.TicketKey, Route: route})
	}
	if !s.Notify.Telegram {
		return
	}
	b, cfg, ok := n.bot(ctx)
	if !ok {
		return
	}
	text := title + "\n\n" + truncate(what, 600)
	var buttons [][]Button
	if e.TicketKey != "" {
		text += "\n\nagnts opened " + e.TicketKey + " to fix it; you review the fix before anything is pushed."
	} else if n.ci != nil && id > 0 {
		text += "\n\nagnts can fix it: the fix waits for your review before anything is pushed."
		buttons = [][]Button{{{Text: "Fix it", Data: fmt.Sprintf("cif:%d", int64(id))}}}
	}
	if _, err := b.Send(ctx, cfg.ChatID, text, buttons, false); err != nil {
		n.log.Warn("telegram notify", "ci", int64(id), "err", err)
	}
}
