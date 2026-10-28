package orchestrator

import (
	"context"
	"errors"
	"fmt"
	"slices"
	"strings"
	"time"
	"unicode/utf8"

	"agnts/internal/domain"
)

// Code mode in the chat: a person picks repositories and asks for a change,
// and the conversation drives an ordinary ticket. A message goes to the
// conversation's current ticket by the ticket's state (routeCode), never by
// a model's reading of it: it starts a ticket, answers its questions, asks
// for changes, continues or retries it, or waits until the running stage
// ends. Approve, reject and push are the ticket's own buttons. The chat
// stores only the person's messages; what the work does is the ticket's
// events, which the timeline merges in.

// EventCodeMessage says a Code message was stored or did something (a
// queued one was sent): the person's open chats refresh. Live only.
const EventCodeMessage = "code_message"

// CodeChatStore keeps Code conversations (with the assistant's store).
// Every call names the person, as AssistantStore's do.
type CodeChatStore interface {
	CreateCodeConversation(ctx context.Context, userID int64, title string, repos domain.RepoChoice, kind string, quick bool) (domain.AssistantConversation, error)
	SetCodeRepos(ctx context.Context, userID, id int64, repos domain.RepoChoice) error
	// LinkCodeTicket makes key the conversation's current ticket and
	// returns the person's other conversation that had it (0: none).
	LinkCodeTicket(ctx context.Context, conversationID int64, key string) (int64, error)
	SetCodeRouted(ctx context.Context, ids []int64, routed domain.CodeRouted, key, why string) error
	QueuedCodeMessages(ctx context.Context, conversationID int64, key string) ([]domain.AssistantMessage, error)
	// QueuedCodeTickets lists, in every workspace, tickets that stopped
	// with Code messages waiting for them.
	QueuedCodeTickets(ctx context.Context) ([]QueuedCode, error)
	CodeEvents(ctx context.Context, keys, types []string, limit int) ([]domain.Event, error)
	RunningCodeTickets(ctx context.Context, userID int64) (int, error)
	CodeConversationOfTicket(ctx context.Context, userID int64, key string) (int64, error)
	// CodeOwnersOfTicket lists the conversations that have ticket key now.
	CodeOwnersOfTicket(ctx context.Context, key string) ([]CodeOwner, error)
}

// CodeOwner is a Code conversation that has a ticket, and whose it is.
type CodeOwner struct {
	ConversationID int64
	UserID         int64
}

// QueuedCode is a ticket with Code messages of one conversation waiting for
// it, and whose they are.
type QueuedCode struct {
	WorkspaceID    int64
	UserID         int64
	Username       string
	ConversationID int64
	TicketKey      string
}

// RoleOf returns a person's role in a workspace.
type RoleOf func(ctx context.Context, ws, userID int64) (domain.WorkspaceRole, error)

// SetCodeChat turns Code mode on with its store; role keeps viewers out
// (nil lets everyone in). Code mode also needs the assistant (SetAssistant):
// its conversations are the same.
func (o *Orchestrator) SetCodeChat(st CodeChatStore, role RoleOf) { o.codeChat, o.codeRole = st, role }

// CodeReady reports whether Code mode is available.
func (o *Orchestrator) CodeReady() bool { return o.assistant != nil && o.codeChat != nil }

// CodeStart is a new Code conversation: its first message, and the
// repositories its tickets work in, or the ticket it picks up.
type CodeStart struct {
	Text  string
	Files []int64 // uploads that go with the message
	Repos domain.RepoChoice
	Kind  string // a ticket kind, or "" / "auto" for agnts to pick
	Quick bool   // tickets skip their checks
	// TicketKey picks up an existing ticket instead of starting one; its
	// repositories become the conversation's.
	TicketKey string
}

// CodeSend is a message in a Code conversation. Answers answer the
// ticket's questions one by one (the question card); without them, a
// ticket that asks one question takes the text as its answer.
type CodeSend struct {
	Text    string
	Files   []int64
	Answers []domain.Answer
}

// coder returns the person ctx acts for, who must be able to change the
// workspace.
func (o *Orchestrator) coder(ctx context.Context) (int64, int64, error) {
	if !o.CodeReady() {
		return 0, 0, invalid("Code mode is not available")
	}
	ws, user, err := asker(ctx)
	if err != nil {
		return 0, 0, err
	}
	if o.codeRole != nil {
		r, err := o.codeRole(ctx, ws, user)
		if err != nil {
			return 0, 0, err
		}
		if !r.CanEdit() {
			return 0, 0, domain.ErrForbidden
		}
	}
	return ws, user, nil
}

func codeText(s string, files []int64) (string, error) {
	s = strings.TrimSpace(s)
	switch n := utf8.RuneCountInString(s); {
	case n == 0 && len(files) == 0:
		return "", invalid("write what you want done")
	case n > domain.CodeMaxMessage:
		return "", invalid("a message is at most %d characters", domain.CodeMaxMessage)
	case n == 0:
		s = "See the attached files."
	}
	return s, nil
}

// StartCode starts a Code conversation with its first message, which goes
// to a new ticket in in.Repos, or to the ticket in.TicketKey.
func (o *Orchestrator) StartCode(ctx context.Context, in CodeStart) (domain.AssistantConversation, error) {
	_, user, err := o.coder(ctx)
	if err != nil {
		return domain.AssistantConversation{}, err
	}
	text, err := codeText(in.Text, in.Files)
	if err != nil {
		return domain.AssistantConversation{}, err
	}
	kind := strings.TrimSpace(in.Kind)
	if kind == "auto" {
		kind = ""
	}
	k, auto, err := parseKind(kind)
	if err != nil {
		return domain.AssistantConversation{}, err
	}
	repos, key := in.Repos, strings.ToUpper(strings.TrimSpace(in.TicketKey))
	if key != "" {
		t, err := o.store.TicketByKey(ctx, key)
		if errors.Is(err, domain.ErrNotFound) {
			return domain.AssistantConversation{}, invalid("there is no ticket %s", key)
		}
		if err != nil {
			return domain.AssistantConversation{}, err
		}
		if t.Kind == domain.KindReview || t.Kind == domain.KindSwaggerTest {
			return domain.AssistantConversation{}, invalid("%s is a %s ticket; Code mode works on changes and reports", key, t.Kind)
		}
		repos = ticketChoice(t)
	} else {
		if repos.Empty() {
			return domain.AssistantConversation{}, invalid("pick the repositories to work in")
		}
		if err := repos.Check(); err != nil {
			return domain.AssistantConversation{}, invalid("%v", err)
		}
		if _, err := o.resolveRepos(ctx, repos, k, auto); err != nil {
			return domain.AssistantConversation{}, err
		}
	}
	c, err := o.codeChat.CreateCodeConversation(ctx, user, domain.AssistantTitle(text), repos, kind, in.Quick)
	if err != nil {
		return c, err
	}
	if key != "" {
		if _, err := o.codeChat.LinkCodeTicket(ctx, c.ID, key); err != nil {
			_ = o.assistant.DeleteAssistantConversation(ctx, user, c.ID)
			return domain.AssistantConversation{}, err
		}
		if c, err = o.assistant.AssistantConversation(ctx, user, c.ID); err != nil {
			return c, err
		}
	}
	if _, err := o.sendCode(ctx, c, CodeSend{Text: text, Files: in.Files}); err != nil {
		// A conversation is its messages: without its first one it is gone.
		_ = o.assistant.DeleteAssistantConversation(ctx, user, c.ID)
		return domain.AssistantConversation{}, err
	}
	return o.assistant.AssistantConversation(ctx, user, c.ID)
}

// ticketChoice is the repositories a ticket works in, as a choice.
func ticketChoice(t domain.Ticket) domain.RepoChoice {
	if t.GroupID != nil {
		return domain.RepoChoice{GroupID: *t.GroupID}
	}
	var ids []int64
	for _, r := range t.Repos {
		ids = append(ids, r.RepoID)
	}
	switch {
	case len(ids) > 1:
		return domain.RepoChoice{RepoIDs: ids}
	case len(ids) == 1:
		return domain.RepoChoice{RepoID: ids[0]}
	case t.RepoID != nil:
		return domain.RepoChoice{RepoID: *t.RepoID}
	}
	return domain.RepoChoice{}
}

// SendCode sends a message in one of the person's Code conversations: it
// goes to the current ticket by its state, or waits for its running stage.
func (o *Orchestrator) SendCode(ctx context.Context, conversationID int64, in CodeSend) (domain.AssistantMessage, error) {
	_, user, err := o.coder(ctx)
	if err != nil {
		return domain.AssistantMessage{}, err
	}
	if in.Text, err = codeText(in.Text, in.Files); err != nil && len(in.Answers) == 0 {
		return domain.AssistantMessage{}, err
	}
	c, err := o.assistant.AssistantConversation(ctx, user, conversationID)
	if err != nil {
		return domain.AssistantMessage{}, err
	}
	if c.Mode != domain.ChatModeCode {
		return domain.AssistantMessage{}, invalid("this is a Chat conversation: ask the assistant instead")
	}
	return o.sendCode(ctx, c, in)
}

// sendCode routes a message of conversation c and stores it with what it
// did. One conversation's messages go one at a time.
func (o *Orchestrator) sendCode(ctx context.Context, c domain.AssistantConversation, in CodeSend) (domain.AssistantMessage, error) {
	ws, user, err := asker(ctx)
	if err != nil {
		return domain.AssistantMessage{}, err
	}
	lock := o.personLock(codeLockKey(ws, c.ID))
	lock.Lock()
	defer lock.Unlock()
	// Read again under the lock: a message just before may have made a
	// ticket.
	if c, err = o.assistant.AssistantConversation(ctx, user, c.ID); err != nil {
		return domain.AssistantMessage{}, err
	}
	text := in.Text
	if text == "" {
		text = answersText(in.Answers)
	}
	routed, key, err := o.routeCode(ctx, c, text, in.Files, in.Answers)
	if err != nil {
		return domain.AssistantMessage{}, err
	}
	m, err := o.assistant.AddAssistantMessage(ctx, domain.AssistantMessage{ConversationID: c.ID, Role: domain.AssistantUser, Text: text,
		Status: domain.AssistantDone, Lang: "en", TicketKey: key, Routed: routed, Attachments: in.Files})
	if err != nil {
		return m, err
	}
	o.publish(ws, user, EventCodeMessage, m, map[string]any{"routed": string(routed), "ticket_key": key})
	return m, nil
}

func codeLockKey(ws, conversation int64) string { return fmt.Sprintf("code/%d/%d", ws, conversation) }

// answersText is how answers given in the question card read in the chat.
func answersText(as []domain.Answer) string {
	var b strings.Builder
	for i, a := range as {
		if i > 0 {
			b.WriteString("\n\n")
		}
		b.WriteString(strings.TrimSpace(a.Answer))
	}
	return b.String()
}

// routeCode does what a message does to conversation c's current ticket,
// by the ticket's state, and says what that was and which ticket it went
// to. A ticket that is working gets nothing now: the message is queued.
func (o *Orchestrator) routeCode(ctx context.Context, c domain.AssistantConversation, text string, files []int64, answers []domain.Answer) (domain.CodeRouted, string, error) {
	cur := c.CurrentTicket()
	if cur == nil {
		return o.newCodeTicket(ctx, c, text, files, "")
	}
	t, err := o.store.TicketByKey(ctx, cur.Key)
	if errors.Is(err, domain.ErrNotFound) { // deleted
		return o.newCodeTicket(ctx, c, text, files, "")
	}
	if err != nil {
		return "", "", err
	}
	if len(answers) > 0 && t.State != domain.StateWaitingForAnswers {
		return "", "", &domain.TransitionError{Key: t.Key, From: t.State, To: domain.StateCoding}
	}
	switch t.State {
	case domain.StateDone:
		return o.newCodeTicket(ctx, c, text, files, t.Key)
	case domain.StateRejected:
		if !domain.CanContinue(t) {
			return o.newCodeTicket(ctx, c, text, files, t.Key)
		}
		_, err := o.Continue(ctx, t.Key, text, files, domain.OriginAssistant)
		if errors.Is(err, ErrInvalid) && strings.Contains(err.Error(), "continue without a note") {
			// It goes back where no run follows (waiting for answers, say):
			// continue it, and the message waits for that stage.
			if _, err = o.Continue(ctx, t.Key, "", nil, domain.OriginAssistant); err == nil {
				return domain.RoutedQueued, t.Key, nil
			}
		}
		return domain.RoutedContinued, t.Key, err
	case domain.StateWaitingForAnswers:
		if len(answers) == 0 {
			qs, err := o.store.Questions(ctx, t.ID)
			if err != nil {
				return "", "", err
			}
			var open []domain.Question
			for _, q := range qs {
				if q.Answer == nil {
					open = append(open, q)
				}
			}
			if len(open) != 1 {
				return "", "", invalid("%s asks %d questions: answer each one in its card", t.Key, len(open))
			}
			answers = []domain.Answer{{QuestionID: open[0].ID, Answer: text, Attachments: files}}
		}
		_, err := o.Answer(ctx, t.Key, answers, domain.OriginAssistant)
		return domain.RoutedAnswered, t.Key, err
	case domain.StateWaitingForReview:
		if err := o.codeChecks(ctx, t, c.Quick); err != nil {
			return "", "", err
		}
		_, err := o.RequestChanges(ctx, t.Key, text, nil, files, domain.OriginAssistant)
		return domain.RoutedChanges, t.Key, err
	case domain.StateFailed, domain.StateRateLimited:
		if err := o.codeChecks(ctx, t, c.Quick); err != nil {
			return "", "", err
		}
		if t.ResumeState == domain.StatePushing {
			// Pushing runs no model to read a note: push, and the message
			// waits for what comes after.
			if _, err := o.Retry(ctx, t.Key, domain.OriginAssistant); err != nil {
				return "", "", err
			}
			return domain.RoutedQueued, t.Key, nil
		}
		_, err := o.RetryWithNote(ctx, t.Key, text, files, domain.OriginAssistant)
		return domain.RoutedRetried, t.Key, err
	}
	// New, analyzing, coding, testing or pushing: a stage is running.
	if o.steerCode(ctx, t, text) {
		return domain.RoutedSteered, t.Key, nil
	}
	return domain.RoutedQueued, t.Key, nil
}

// codeChecks makes a stopped ticket's checks follow the conversation's
// Quick switch before it runs again.
func (o *Orchestrator) codeChecks(ctx context.Context, t domain.Ticket, quick bool) error {
	if t.SkipChecks == quick {
		return nil
	}
	_, err := o.SetSkipChecks(ctx, t.Key, quick, domain.OriginAssistant)
	return err
}

// newCodeTicket starts the conversation's next ticket from a message;
// after names the ticket it follows, if any.
func (o *Orchestrator) newCodeTicket(ctx context.Context, c domain.AssistantConversation, text string, files []int64, after string) (domain.CodeRouted, string, error) {
	_, user, err := asker(ctx)
	if err != nil {
		return "", "", err
	}
	n, err := o.codeChat.RunningCodeTickets(ctx, user)
	if err != nil {
		return "", "", err
	}
	if n >= domain.CodeMaxRunning {
		return "", "", invalid("%d of your Code tickets are running; wait for one to finish or need you, then send this again", n)
	}
	desc := text
	if after != "" {
		desc += "\n\nThis follows " + after + ", done in the same conversation."
	}
	in := TaskInput{RepoID: c.Repos.RepoID, RepoIDs: c.Repos.RepoIDs, GroupID: c.Repos.GroupID, Kind: c.Kind,
		Title: domain.AssistantTitle(text), Description: desc, Priority: "medium", AfterApprove: "pr", Start: "code",
		SkipChecks: c.Quick}
	if len(files) > 0 {
		in.Attachments = &files
	}
	t, err := o.CreateTask(ctx, in, domain.OriginAssistant)
	if err != nil {
		return "", "", err
	}
	if _, err := o.codeChat.LinkCodeTicket(ctx, c.ID, t.Key); err != nil {
		return "", "", err
	}
	return domain.RoutedCreated, t.Key, nil
}

// SetCodeRepos changes the repositories of one of the person's Code
// conversations. The next ticket works in them; the current one moves too
// while it has not started on code.
func (o *Orchestrator) SetCodeRepos(ctx context.Context, conversationID int64, repos domain.RepoChoice) (domain.AssistantConversation, error) {
	_, user, err := o.coder(ctx)
	if err != nil {
		return domain.AssistantConversation{}, err
	}
	c, err := o.assistant.AssistantConversation(ctx, user, conversationID)
	if err != nil {
		return c, err
	}
	if c.Mode != domain.ChatModeCode {
		return c, invalid("only Code conversations have repositories")
	}
	if repos.Empty() {
		return c, invalid("pick the repositories to work in")
	}
	if err := repos.Check(); err != nil {
		return c, invalid("%v", err)
	}
	k, auto, err := parseKind(c.Kind)
	if err != nil {
		return c, err
	}
	if _, err := o.resolveRepos(ctx, repos, k, auto); err != nil {
		return c, err
	}
	if cur := c.CurrentTicket(); cur != nil && (cur.State == domain.StateNew || cur.State == domain.StateWaitingForAnswers) {
		if _, err := o.SetRepos(ctx, cur.Key, repos, domain.OriginAssistant); err != nil {
			return c, err
		}
	}
	if err := o.codeChat.SetCodeRepos(ctx, user, c.ID, repos); err != nil {
		return c, err
	}
	return o.assistant.AssistantConversation(ctx, user, c.ID)
}

// AttachCodeTicket makes an existing ticket the current one of a Code
// conversation: the next message goes to it. The person's other
// conversation that had it lets it go.
func (o *Orchestrator) AttachCodeTicket(ctx context.Context, conversationID int64, key string) (domain.AssistantConversation, error) {
	ws, user, err := o.coder(ctx)
	if err != nil {
		return domain.AssistantConversation{}, err
	}
	c, err := o.assistant.AssistantConversation(ctx, user, conversationID)
	if err != nil {
		return c, err
	}
	if c.Mode != domain.ChatModeCode {
		return c, invalid("tickets go to Code conversations")
	}
	key = strings.ToUpper(strings.TrimSpace(key))
	if _, err := o.store.TicketByKey(ctx, key); errors.Is(err, domain.ErrNotFound) {
		return c, invalid("there is no ticket %s", key)
	} else if err != nil {
		return c, err
	}
	from, err := o.codeChat.LinkCodeTicket(ctx, c.ID, key)
	if err != nil {
		return c, err
	}
	if from != 0 {
		o.publish(ws, user, EventCodeMessage, domain.AssistantMessage{ConversationID: from}, map[string]any{"ticket_key": key, "moved": true})
	}
	return o.assistant.AssistantConversation(ctx, user, c.ID)
}

// SendQueuedNow stops the current ticket's running stage and sends the
// messages waiting for it at once.
func (o *Orchestrator) SendQueuedNow(ctx context.Context, conversationID int64) (domain.AssistantConversation, error) {
	_, user, err := o.coder(ctx)
	if err != nil {
		return domain.AssistantConversation{}, err
	}
	c, err := o.assistant.AssistantConversation(ctx, user, conversationID)
	if err != nil {
		return c, err
	}
	cur := c.CurrentTicket()
	if c.Mode != domain.ChatModeCode || cur == nil {
		return c, invalid("nothing is waiting to be sent")
	}
	queued, err := o.codeChat.QueuedCodeMessages(ctx, c.ID, cur.Key)
	if err != nil {
		return c, err
	}
	if len(queued) == 0 {
		return c, invalid("nothing is waiting to be sent")
	}
	if !domain.CodeStopped(cur.State) {
		if _, err := o.Stop(ctx, cur.Key, domain.OriginAssistant); err != nil {
			return c, err
		}
	}
	o.sendQueued(ctx, c.ID, cur.Key)
	return o.assistant.AssistantConversation(ctx, user, c.ID)
}

// FlushCodeQueues sends the Code messages that waited for a ticket whose
// running stage has ended, in every workspace. The loop calls it on every
// poll.
func (o *Orchestrator) FlushCodeQueues(ctx context.Context) {
	if o.codeChat == nil || o.assistant == nil {
		return
	}
	qs, err := o.codeChat.QueuedCodeTickets(ctx)
	if err != nil {
		if ctx.Err() == nil {
			o.log.Warn("code chat: list queued messages", "err", err)
		}
		return
	}
	for _, q := range qs {
		wctx := domain.WithActor(domain.WithWorkspace(ctx, q.WorkspaceID), domain.Actor{UserID: q.UserID, Username: q.Username})
		o.sendQueued(wctx, q.ConversationID, q.TicketKey)
	}
}

// sendQueued sends conversation id's messages waiting for ticket key as
// one, if the ticket takes them now, and marks them sent (or failed, with
// why).
func (o *Orchestrator) sendQueued(ctx context.Context, conversationID int64, key string) {
	ws, user, err := asker(ctx)
	if err != nil {
		return
	}
	lock := o.personLock(codeLockKey(ws, conversationID))
	lock.Lock()
	defer lock.Unlock()
	msgs, err := o.codeChat.QueuedCodeMessages(ctx, conversationID, key)
	if err != nil || len(msgs) == 0 {
		return
	}
	c, err := o.assistant.AssistantConversation(ctx, user, conversationID)
	if err != nil {
		return
	}
	var texts []string
	var files, ids []int64
	for _, m := range msgs {
		texts = append(texts, m.Text)
		files = append(files, m.Attachments...)
		ids = append(ids, m.ID)
	}
	// They go to the ticket they waited for, even if the conversation has
	// moved on to another since.
	if cur := c.CurrentTicket(); cur == nil || cur.Key != key {
		c.Tickets = append(c.Tickets, domain.CodeTicket{Key: key, Current: true})
	}
	routed, to, err := o.routeCode(ctx, c, strings.Join(texts, "\n\n"), slices.Compact(files), nil)
	switch {
	case err != nil:
		o.log.Info("code chat: queued messages not taken", "ticket", key, "err", err)
		err = o.codeChat.SetCodeRouted(ctx, ids, domain.RoutedFailed, key, codeErrorText(err))
	case routed == domain.RoutedQueued && to == key:
		return // it went back to work before they could go
	default:
		err = o.codeChat.SetCodeRouted(ctx, ids, domain.RoutedSent, to, "")
	}
	if err != nil {
		o.log.Warn("code chat: mark queued messages", "ticket", key, "err", err)
		return
	}
	o.publish(ws, user, EventCodeMessage, domain.AssistantMessage{ConversationID: conversationID, ID: ids[len(ids)-1]},
		map[string]any{"routed": string(domain.RoutedSent), "ticket_key": to})
}

// codeErrorText is why a ticket did not take a message, in the person's
// words.
func codeErrorText(err error) string {
	var te *domain.TransitionError
	if errors.As(err, &te) {
		return fmt.Sprintf("%s is %s now and cannot take this", te.Key, strings.ReplaceAll(string(te.From), "_", " "))
	}
	if errors.Is(err, ErrInvalid) {
		return strings.TrimPrefix(err.Error(), ErrInvalid.Error()+": ")
	}
	return "Something went wrong sending this; send it again."
}

// CodeTimeline returns one of the person's Code conversations with its
// timeline: their messages and the events of its tickets, oldest first.
func (o *Orchestrator) CodeTimeline(ctx context.Context, conversationID int64) (domain.AssistantConversation, []domain.TimelineItem, error) {
	if !o.CodeReady() {
		return domain.AssistantConversation{}, nil, invalid("Code mode is not available")
	}
	_, user, err := asker(ctx)
	if err != nil {
		return domain.AssistantConversation{}, nil, err
	}
	c, err := o.assistant.AssistantConversation(ctx, user, conversationID)
	if err != nil {
		return c, nil, err
	}
	if c.Mode != domain.ChatModeCode {
		return c, nil, invalid("only Code conversations have a timeline")
	}
	keys := make([]string, 0, len(c.Tickets))
	for _, t := range c.Tickets {
		keys = append(keys, t.Key)
	}
	evs, err := o.codeChat.CodeEvents(ctx, keys, domain.CodeTimelineTypes, domain.CodeTimelineEvents)
	if err != nil {
		return c, nil, err
	}
	return c, mergeTimeline(c.Messages, evs, c.Tickets), nil
}

// mergeTimeline puts messages and events in time order. A ticket's events
// from before the conversation picked it up stay out, except the ones of
// tickets it started.
func mergeTimeline(msgs []domain.AssistantMessage, evs []domain.Event, tickets []domain.CodeTicket) []domain.TimelineItem {
	since := map[string]time.Time{}
	for _, t := range tickets {
		if s, ok := since[t.Key]; !ok || t.AttachedAt.Before(s) {
			since[t.Key] = t.AttachedAt
		}
	}
	out := make([]domain.TimelineItem, 0, len(msgs)+len(evs))
	for i := range msgs {
		out = append(out, domain.TimelineItem{At: msgs[i].CreatedAt, Message: &msgs[i]})
	}
	for i := range evs {
		// The ticket's creation is a moment before its link: keep it.
		if s, ok := since[evs[i].TicketKey]; ok && evs[i].CreatedAt.Before(s.Add(-time.Minute)) {
			continue
		}
		out = append(out, domain.TimelineItem{At: evs[i].CreatedAt, Event: &evs[i]})
	}
	slices.SortStableFunc(out, func(a, b domain.TimelineItem) int { return a.At.Compare(b.At) })
	return out
}

// TicketConversation returns the person's Code conversation that has
// ticket key now, or ErrNotFound.
func (o *Orchestrator) TicketConversation(ctx context.Context, key string) (int64, error) {
	if !o.CodeReady() {
		return 0, domain.ErrNotFound
	}
	_, user, err := asker(ctx)
	if err != nil {
		return 0, err
	}
	return o.codeChat.CodeConversationOfTicket(ctx, user, strings.ToUpper(strings.TrimSpace(key)))
}
