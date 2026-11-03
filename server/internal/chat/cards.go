package chat

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"strconv"
	"strings"
	"time"

	"agnts/internal/actions"
	"agnts/internal/domain"
	"agnts/internal/orchestrator"
	"agnts/internal/store/postgres"
	"agnts/internal/vcs"
)

// cursorName is the chat's position in the event log.
const cursorName = "chat"

// onEvent turns a ticket or log event into cards and notes.
func (s *Service) onEvent(ctx context.Context, e domain.Event) {
	if e.WorkspaceID == 0 || strings.HasPrefix(e.Type, "chat_") {
		return
	}
	ctx = domain.WithWorkspace(ctx, e.WorkspaceID)
	var err error
	switch e.Type {
	case domain.EventLogFinding:
		if k, _ := e.Data["kind"].(string); k == "new" || k == "regression" {
			err = s.findingCard(ctx, e)
		}
	case domain.EventStateChanged, domain.EventReadyForReview:
		err = s.ticketMoved(ctx, e)
	case domain.EventPROpened:
		if n, ok := e.Data["number"].(float64); ok {
			err = s.prCard(ctx, e, int(n))
		}
	case domain.EventMerged:
		err = s.merged(ctx, e)
	case domain.EventCIFailure, domain.EventPipeline:
		err = s.refreshChecks(ctx, e.TicketKey)
	}
	if err != nil && !errors.Is(err, domain.ErrNotFound) {
		s.Log.Warn("chat: card", "event", e.ID, "type", e.Type, "ticket", e.TicketKey, "err", err)
	}
}

// channelFor is where a ticket's cards go: the channel of its first card
// (the finding or draft it came from), else agnts's channel.
func (s *Service) channelFor(ctx context.Context, key string) (int64, error) {
	if key != "" {
		if cs, err := s.Store.CardsOf(ctx, key); err == nil && len(cs) > 0 {
			return cs[0].ChannelID, nil
		}
	}
	c, err := s.Store.AgentChannel(ctx)
	return c.ID, err
}

func (s *Service) post(ctx context.Context, key string, m domain.ChatMessage) (domain.ChatMessage, error) {
	ch, err := s.channelFor(ctx, key)
	if err != nil {
		return m, err
	}
	m.ChannelID, m.TicketKey, m.WorkspaceID = ch, key, domain.WorkspaceOf(ctx)
	if m.Kind == "" {
		m.Kind = domain.ChatKindCard
	}
	if m.Card != nil && key != "" {
		m.Refs = append(m.Refs, domain.ChatRef{Type: domain.RefTicket, ID: key, Source: domain.RefCard, Confidence: 1})
	}
	return s.Store.Post(ctx, m)
}

// ---------------------------------------------------------------------
// Log findings

func (s *Service) findingCard(ctx context.Context, e domain.Event) error {
	if s.Logs == nil {
		return nil
	}
	id, _ := e.Data["findingId"].(float64)
	f, err := s.Logs.Finding(ctx, int64(id))
	if err != nil {
		return err
	}
	card := &domain.ChatCard{Type: domain.CardLogFinding, State: domain.CardOpen,
		Title:   fmt.Sprintf("%s in %s", f.Category, f.Service),
		Summary: f.Title,
		Data: map[string]any{"findingId": f.ID, "service": f.Service, "severity": string(f.Severity), "category": string(f.Category),
			"count": f.Count, "repos": f.RepoNames, "remediation": f.Remediation, "kind": e.Data["kind"], "route": f.Route,
			"revision": f.Revision, "mask": f.SecretMask},
	}
	switch {
	case f.TicketKey != "":
		card.Actions = []string{domain.CardMute}
		card.Data["ticketKey"] = f.TicketKey
		card.Result = "agnts opened " + f.TicketKey + " to fix it"
	case len(f.RepoIDs) == 0:
		card.Actions = []string{domain.CardMute}
		card.Result = "No repository runs " + f.Service + ": reported only"
	default:
		card.Actions = []string{domain.CardFix, domain.CardMute}
	}
	m := domain.ChatMessage{Card: card,
		Refs: []domain.ChatRef{{Type: domain.RefFinding, ID: strconv.FormatInt(f.ID, 10), Source: domain.RefCard, Confidence: 1, Label: f.Title}}}
	_, err = s.post(ctx, f.TicketKey, m)
	return err
}

// ---------------------------------------------------------------------
// Tickets

// ticketMoved posts a review card when a ticket starts waiting for
// review, and settles open review cards when it moved on elsewhere.
func (s *Service) ticketMoved(ctx context.Context, e domain.Event) error {
	if e.TicketKey == "" {
		return nil
	}
	to, _ := e.Data["to"].(string)
	if quiet, _ := e.Data["quiet"].(bool); quiet {
		return nil // agnts's own review runs first; review_ready announces it
	}
	cards, err := s.Store.CardsOf(ctx, e.TicketKey)
	if err != nil {
		return err
	}
	if to == string(domain.StateWaitingForReview) {
		v, err := s.Tickets.View(ctx, e.TicketKey)
		if err != nil {
			return err
		}
		for _, c := range cards {
			if c.Card != nil && c.Card.Type == domain.CardReviewReady && c.Card.State == domain.CardOpen {
				if rev, _ := c.Card.Data["revision"].(float64); int(rev) == v.Ticket.Revision {
					return nil // already shown
				}
				s.settle(ctx, c.ID, domain.CardExpired, "", "", "A newer revision is ready below")
			}
		}
		_, err = s.post(ctx, e.TicketKey, domain.ChatMessage{Card: reviewCard(v)})
		return err
	}
	if to == "" {
		return nil
	}
	for _, c := range cards {
		if c.Card != nil && c.Card.Type == domain.CardReviewReady && c.Card.State == domain.CardOpen {
			who := e.Username
			msg := "Moved on: " + strings.ReplaceAll(to, "_", " ")
			if who != "" {
				msg += " (" + who + ")"
			}
			s.settle(ctx, c.ID, domain.CardExpired, who, "", msg)
		}
	}
	return nil
}

func reviewCard(v orchestrator.TicketView) *domain.ChatCard {
	t := v.Ticket
	files, add, del := 0, 0, 0
	var paths []string
	summary := ""
	if v.Result != nil {
		files = len(v.Result.Files)
		for _, f := range v.Result.Files {
			add += f.Add
			del += f.Del
			if len(paths) < 6 {
				paths = append(paths, f.Path)
			}
		}
		summary = resultSummary(v.Result)
	}
	data := map[string]any{"key": t.Key, "title": t.Title, "files": files, "add": add, "del": del, "paths": paths,
		"costUsd": v.Spend.CostUSD, "revision": t.Revision, "kind": string(t.Kind), "repo": v.RepoName}
	if v.Review != nil {
		data["reviewFindings"] = len(v.Review.Findings)
	}
	what := "push the branch and open a pull request"
	if t.Kind.Report() {
		what = "close the report and keep it in agnts"
	} else if t.Source == domain.SourceLocal && t.AfterApprove == "main" {
		what = "push straight to the default branch"
	}
	data["approveDoes"] = what
	return &domain.ChatCard{Type: domain.CardReviewReady, State: domain.CardOpen,
		Title: t.Key + " is ready for review", Summary: strings.TrimSpace(t.Title + "\n" + summary),
		Actions: []string{domain.CardApprove, domain.CardRequestChanges}, Data: data}
}

func firstLines(s string, n int) string {
	lines := strings.Split(strings.TrimSpace(s), "\n")
	if len(lines) > n {
		lines = lines[:n]
	}
	return strings.Join(lines, "\n")
}

// prCard posts the pull request a ticket opened, with its CI state and a
// Merge button. A ticket in several repositories gets one per PR.
func (s *Service) prCard(ctx context.Context, e domain.Event, number int) error {
	v, err := s.Tickets.View(ctx, e.TicketKey)
	if err != nil {
		return err
	}
	cards, err := s.Store.CardsOf(ctx, e.TicketKey)
	if err != nil {
		return err
	}
	url, _ := e.Data["url"].(string)
	repoID, _ := e.Data["repoId"].(float64)
	for _, c := range cards {
		if c.Card == nil {
			continue
		}
		if c.Card.Type == domain.CardPROpened && c.Card.Data["url"] == url {
			return nil
		}
		if c.Card.Type == domain.CardReviewReady && c.Card.State == domain.CardOpen {
			s.settle(ctx, c.ID, domain.CardDone, e.Username, domain.CardApprove, "Approved: pull request opened")
		}
	}
	data := map[string]any{"key": v.Ticket.Key, "title": v.Ticket.Title, "number": number, "url": url, "repoId": int64(repoID), "repo": v.RepoName}
	s.checksInto(ctx, v.Ticket, int64(repoID), data)
	card := &domain.ChatCard{Type: domain.CardPROpened, State: domain.CardOpen,
		Title: fmt.Sprintf("Pull request #%d is open", number), Summary: v.Ticket.Key + ": " + v.Ticket.Title,
		Actions: []string{domain.CardMerge}, Data: data}
	repoName := v.RepoName
	if r, ok := v.Ticket.RepoState(int64(repoID)); ok && r.RepoName != "" {
		repoName = r.RepoName
	}
	refs := []domain.ChatRef{{Type: domain.RefPR, ID: fmt.Sprintf("%s#%d", repoName, number), Source: domain.RefCard, Confidence: 1, URL: url}}
	_, err = s.post(ctx, e.TicketKey, domain.ChatMessage{Card: card, Refs: refs})
	return err
}

// checksInto puts what CI says about the pull request's head into a card.
func (s *Service) checksInto(ctx context.Context, t domain.Ticket, repoID int64, data map[string]any) {
	data["ci"] = vcs.CINone
	if s.Checks == nil || s.Repos == nil {
		return
	}
	r, ok := t.RepoState(repoID)
	if !ok {
		r, ok = t.RepoState(t.RepoIDs()[0])
	}
	if !ok || r.HeadSHA == "" {
		return
	}
	repo, err := s.Repos.RepositoryByID(ctx, r.RepoID)
	if err != nil {
		return
	}
	ctx, cancel := context.WithTimeout(ctx, 10*time.Second)
	defer cancel()
	st, names, err := s.Checks.CommitChecks(ctx, repo, r.HeadSHA)
	if err != nil {
		return
	}
	data["ci"] = st
	if len(names) > 0 {
		data["ciChecks"] = names
	}
	data["ciAt"] = time.Now().UTC().Format(time.RFC3339)
}

// refreshChecks updates the CI state on open pull request cards: of one
// ticket, or every open one when key is "" (a pipeline finished somewhere).
func (s *Service) refreshChecks(ctx context.Context, key string) error {
	if s.Checks == nil {
		return nil
	}
	var cards []domain.ChatMessage
	if key != "" {
		cs, err := s.Store.CardsOf(ctx, key)
		if err != nil {
			return err
		}
		cards = cs
	} else {
		cards = s.openPRCards(ctx)
	}
	for _, c := range cards {
		if c.Card == nil || c.Card.Type != domain.CardPROpened || c.Card.State != domain.CardOpen {
			continue
		}
		v, err := s.Tickets.View(ctx, c.TicketKey)
		if err != nil {
			continue
		}
		data := map[string]any{}
		repoID, _ := c.Card.Data["repoId"].(float64)
		s.checksInto(ctx, v.Ticket, int64(repoID), data)
		if data["ci"] == c.Card.Data["ci"] && fmt.Sprint(data["ciChecks"]) == fmt.Sprint(c.Card.Data["ciChecks"]) {
			continue
		}
		_, _ = s.Store.Update(ctx, c.ID, func(m *domain.ChatMessage) error {
			for k, v := range data {
				m.Card.Data[k] = v
			}
			if data["ciChecks"] == nil {
				delete(m.Card.Data, "ciChecks")
			}
			return nil
		})
	}
	return nil
}

// openPRCards are this workspace's open pull request cards of the last
// day, from its agnts channel.
func (s *Service) openPRCards(ctx context.Context) []domain.ChatMessage {
	ch, err := s.Store.AgentChannel(ctx)
	if err != nil {
		return nil
	}
	ms, err := s.Store.Messages(ctx, ch.ID, 0, 0, 200)
	if err != nil {
		return nil
	}
	var out []domain.ChatMessage
	for _, m := range ms {
		if m.Card != nil && m.Card.Type == domain.CardPROpened && m.Card.State == domain.CardOpen && time.Since(m.CreatedAt) < 24*time.Hour {
			out = append(out, m)
		}
	}
	return out
}

// merged settles the ticket's pull request cards and says so.
func (s *Service) merged(ctx context.Context, e domain.Event) error {
	if e.TicketKey == "" {
		return nil
	}
	cards, err := s.Store.CardsOf(ctx, e.TicketKey)
	if err != nil {
		return err
	}
	url, _ := e.Data["url"].(string)
	number := 0
	for _, c := range cards {
		if c.Card == nil || c.Card.Type != domain.CardPROpened {
			continue
		}
		if url != "" && c.Card.Data["url"] != url {
			continue
		}
		if n, ok := c.Card.Data["number"].(float64); ok {
			number = int(n)
		}
		if c.Card.State == domain.CardOpen { // merged on the git host, not with the card
			s.settle(ctx, c.ID, domain.CardDone, e.Username, domain.CardMerge, "Merged")
		}
	}
	if len(cards) == 0 {
		return nil // not a ticket the chat follows
	}
	body := "Merged ✅ " + e.TicketKey
	if number > 0 {
		body = fmt.Sprintf("Merged ✅ #%d (%s)", number, e.TicketKey)
	}
	if e.Username != "" {
		body += " by " + e.Username
	}
	_, err = s.post(ctx, e.TicketKey, domain.ChatMessage{Kind: domain.ChatKindAgent, Body: body})
	return err
}

// settle marks a card done, failed or expired.
func (s *Service) settle(ctx context.Context, id int64, state, by, action, result string) {
	now := time.Now().UTC()
	_, err := s.Store.Update(ctx, id, func(m *domain.ChatMessage) error {
		if m.Card == nil || m.Card.State != domain.CardOpen {
			return ErrSettled
		}
		m.Card.State, m.Card.By, m.Card.Done, m.Card.Result, m.Card.At = state, by, action, result, &now
		return nil
	})
	if err != nil && !errors.Is(err, ErrSettled) {
		s.Log.Warn("chat: settle card", "message", id, "err", err)
	}
}

// ---------------------------------------------------------------------
// Buttons

// ActInput is a button pressed on a card.
type ActInput struct {
	Action   string
	Feedback string
	Draft    *DraftEdit
}

// DraftEdit is a ticket draft as the person edited it.
type DraftEdit struct {
	Title, Description string
	RepoID             int64
}

// Act runs a card's button: the real action, with the same checks as the
// ticket page, then settles the card. A card is pressed once; a second
// press says who pressed it.
func (s *Service) Act(ctx context.Context, msg int64, in ActInput) (domain.ChatMessage, error) {
	m, err := s.Store.Message(ctx, msg)
	if err != nil {
		return m, err
	}
	if m.Card == nil {
		return m, invalid("message %d is not a card", msg)
	}
	if m.Card.State != domain.CardOpen {
		return m, fmt.Errorf("%w: %s", ErrSettled, settledText(*m.Card))
	}
	if !m.Card.Has(in.Action) {
		return m, invalid("this card has no %q button", in.Action)
	}
	s.mu.Lock()
	if s.busy[msg] {
		s.mu.Unlock()
		return m, fmt.Errorf("%w: someone just pressed it", ErrBusy)
	}
	s.busy[msg] = true
	s.mu.Unlock()
	defer func() {
		s.mu.Lock()
		delete(s.busy, msg)
		s.mu.Unlock()
	}()

	_, who := actor(ctx)
	result, key, err := s.run(ctx, m, in)
	if err != nil {
		// The card stays open, with why it did not work.
		_, _ = s.Store.Update(ctx, msg, func(x *domain.ChatMessage) error {
			if x.Card.State != domain.CardOpen {
				return ErrSettled
			}
			x.Card.Result = "Not done: " + userError(err)
			return nil
		})
		if errors.Is(err, domain.ErrNotFound) || errors.Is(err, ErrInvalid) {
			return m, err
		}
		return m, fmt.Errorf("%w: %s", ErrInvalid, userError(err))
	}
	now := time.Now().UTC()
	return s.Store.Update(ctx, msg, func(x *domain.ChatMessage) error {
		if key != "" {
			x.TicketKey = key
			x.Card.Data["ticketKey"] = key
		}
		if x.Card.State != domain.CardOpen {
			return nil // the event it caused settled it already
		}
		x.Card.State, x.Card.By, x.Card.Done, x.Card.Result, x.Card.At = domain.CardDone, who, in.Action, result, &now
		return nil
	})
}

func settledText(c domain.ChatCard) string {
	what := map[string]string{domain.CardApprove: "approved", domain.CardMerge: "merged", domain.CardFix: "sent to fix",
		domain.CardMute: "muted", domain.CardRequestChanges: "sent back", domain.CardCreate: "created", domain.CardCreateAssign: "created"}[c.Done]
	switch {
	case what != "" && c.By != "":
		return "already " + what + " by " + c.By
	case c.Result != "":
		return c.Result
	}
	return "this card is " + c.State
}

func userError(err error) string {
	msg := err.Error()
	for _, p := range []string{"invalid: ", "bad request: "} {
		msg = strings.TrimPrefix(msg, p)
	}
	return msg
}

// run does a card's action; it returns what to say on the card and the
// ticket the action made, if any.
func (s *Service) run(ctx context.Context, m domain.ChatMessage, in ActInput) (string, string, error) {
	c := *m.Card
	key, _ := c.Data["key"].(string)
	switch in.Action {
	case domain.CardFix:
		if s.Logs == nil {
			return "", "", invalid("the log watcher is off")
		}
		id, _ := c.Data["findingId"].(float64)
		t, err := s.Logs.Fix(ctx, int64(id), domain.OriginChat)
		if err != nil {
			return "", "", err
		}
		return "Fixing in " + t.Key, t.Key, nil
	case domain.CardMute:
		if s.Logs == nil {
			return "", "", invalid("the log watcher is off")
		}
		id, _ := c.Data["findingId"].(float64)
		if _, err := s.Logs.Mute(ctx, int64(id), true); err != nil {
			return "", "", err
		}
		return "Muted", "", nil
	case domain.CardApprove:
		return s.do(ctx, actions.ApproveTicket, map[string]any{"key": key})
	case domain.CardRequestChanges:
		fb := strings.TrimSpace(in.Feedback)
		if fb == "" {
			return "", "", invalid("say what to change")
		}
		res, _, err := s.do(ctx, actions.RequestChanges, map[string]any{"key": key, "feedback": fb})
		if err == nil {
			res = "Sent back: " + truncate(fb, 200)
		}
		return res, "", err
	case domain.CardMerge:
		if _, err := s.Tickets.MergeTicketPR(ctx, key, domain.OriginChat); err != nil {
			return "", "", err
		}
		return "Merged", "", nil
	case domain.CardCreate, domain.CardCreateAssign:
		return s.createFromDraft(ctx, m, in)
	}
	return "", "", invalid("unknown action %q", in.Action)
}

// do runs one of the shared write actions: prepared (checked) and then
// executed at once, since a press on the card is the person's consent.
func (s *Service) do(ctx context.Context, tool string, args map[string]any) (string, string, error) {
	raw, _ := json.Marshal(args)
	p, err := s.Actions.Prepare(ctx, tool, raw)
	if err != nil {
		return "", "", err
	}
	u, _ := actor(ctx)
	res, err := s.Actions.Execute(ctx, postgres.PendingAction{WorkspaceID: domain.WorkspaceOf(ctx), Origin: domain.OriginChat,
		Tool: p.Tool, TicketKey: p.TicketKey, Args: p.Args, Summary: p.Summary, UserID: u}, domain.OriginChat)
	if err != nil {
		return "", "", err
	}
	key := ""
	if res.Ticket != nil {
		key = res.Ticket.Key
	}
	return p.Summary, key, nil
}

func truncate(s string, n int) string {
	r := []rune(s)
	if len(r) <= n {
		return s
	}
	return string(r[:n-1]) + "…"
}
