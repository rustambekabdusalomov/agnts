package orchestrator

import (
	"archive/tar"
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"path"
	"regexp"
	"slices"
	"strconv"
	"strings"
	"sync"
	"time"
	"unicode"
	"unicode/utf8"

	"agnts/internal/domain"
)

// The assistant answers a person's questions about their workspace from a
// snapshot of it, written as files into a run container. The run can read
// those files and write its answer, nothing else: it has no repository, no
// agnts token, and its permission rules deny commands and the web. Asked to
// act, it can only propose actions in its answer: agnts checks them, and
// only the asker's confirm does them (AssistantActions).

// Where the assistant's files go in its container. Each question gets its
// own folder and answer file, so a container kept warm between questions
// never shows one question another's files.
const (
	assistantContextRoot = "/agnts/context"
	assistantOutRoot     = "/agnts/out"
)

const (
	assistantMaxTurns = 6
	assistantTimeout  = 2 * time.Minute
	assistantMemoryMB = 1024
	// assistantWarm is how long a person's container is kept after an
	// answer, for their next question.
	assistantWarm = 5 * time.Minute
	// assistantMaxSnapshot caps the snapshot kept with an answer for replays.
	assistantMaxSnapshot = 512 << 10
)

// Live assistant events. They go to the asking person's open event
// streams only and are not stored: questions are private.
const (
	EventAssistantAnswering = "assistant_answering"
	EventAssistantProgress  = "assistant_progress"
	EventAssistantPartial   = "assistant_partial"
	EventAssistantAnswered  = "assistant_answered"
	EventAssistantFailed    = "assistant_failed"
	// EventAssistantAction says a proposed action was confirmed (done or
	// failed) or declined.
	EventAssistantAction = "assistant_action"
)

// AssistantActions checks, stores and does the writes the assistant
// proposes. Every call names the person: an action is theirs alone.
type AssistantActions interface {
	// Propose checks the proposals of answer messageID and stores the ones
	// that pass for user to confirm; it says why the others did not.
	Propose(ctx context.Context, user, messageID int64, ps []domain.AssistantProposal) ([]domain.AssistantAction, []string)
	Confirm(ctx context.Context, user int64, id string) (domain.AssistantAction, error)
	Cancel(ctx context.Context, user int64, id string) (domain.AssistantAction, error)
}

// AssistantStore keeps conversations. Every call names the person; a
// conversation of someone else is domain.ErrNotFound.
type AssistantStore interface {
	CreateAssistantConversation(ctx context.Context, userID int64, title string) (domain.AssistantConversation, error)
	AssistantConversation(ctx context.Context, userID, id int64) (domain.AssistantConversation, error)
	AssistantConversations(ctx context.Context, userID int64, mode domain.ChatMode, limit int) ([]domain.AssistantConversation, error)
	DeleteAssistantConversation(ctx context.Context, userID, id int64) error
	AddAssistantMessage(ctx context.Context, m domain.AssistantMessage) (domain.AssistantMessage, error)
	SetAssistantStatus(ctx context.Context, id int64, status domain.AssistantStatus) error
	FinishAssistantMessage(ctx context.Context, m domain.AssistantMessage, snapshot []byte) error
	AssistantHistory(ctx context.Context, conversationID, beforeID int64, n int) ([]domain.AssistantMessage, error)
	AssistantMessage(ctx context.Context, userID, id int64) (domain.AssistantMessage, error)
	RateAssistantMessage(ctx context.Context, userID, id int64, rating int, comment string, share bool) (domain.AssistantMessage, error)
	FailOpenAssistant(ctx context.Context, reason string) (int64, error)
	PruneAssistant(ctx context.Context, before time.Time) (int64, error)
	AssistantAsked(ctx context.Context, userID int64, since time.Time) (int, time.Time, error)
	AssistantStats(ctx context.Context, days int) (domain.AssistantStats, error)
	AssistantRated(ctx context.Context, rating, limit int) ([]domain.AssistantRated, error)
}

// AssistantQuestion is what a snapshot is taken for.
type AssistantQuestion struct {
	Question string
	History  []domain.AssistantMessage // earlier messages, oldest first
	// Keys are the ticket keys the question and the history name.
	Keys []string
	// Topics are the parts of the workspace the question is about; nil
	// for all of them.
	Topics map[AssistantTopic]bool
}

// AssistantTopic is a part of the workspace a question can be about.
type AssistantTopic string

// Topics. Tickets and the inbox are always in the snapshot.
const (
	TopicCI      AssistantTopic = "ci"
	TopicSpend   AssistantTopic = "spend"
	TopicLessons AssistantTopic = "lessons"
	TopicRepos   AssistantTopic = "repos"
	// TopicAct is a question that asks to create work (a task, a report's
	// code task, follow-ups) or to change code (offered in Code mode): the
	// snapshot then has the repositories and groups the action may name.
	TopicAct AssistantTopic = "act"
)

// AssistantFile is one file of a snapshot.
type AssistantFile struct {
	Name    string `json:"name"`
	Content string `json:"content"`
}

// AssistantSnapshotter reads the workspace for a question. It makes the
// same reads as the MCP server's read tools, so both see the same data.
type AssistantSnapshotter interface {
	Snapshot(ctx context.Context, q AssistantQuestion) ([]AssistantFile, error)
}

// AssistantEvents delivers a live event to one person's open streams.
type AssistantEvents interface {
	PublishTo(ws, userID int64, e domain.Event)
}

// RateLimitedError says the person asked too much; RetryAfter says when
// they may ask again.
type RateLimitedError struct{ RetryAfter time.Duration }

func (e *RateLimitedError) Error() string {
	return fmt.Sprintf("you asked %d questions in the last hour; ask again in %s", domain.AssistantPerHour, e.RetryAfter.Round(time.Minute))
}

// assistantState is the assistant's per-person state.
type assistantState struct {
	mu    sync.Mutex
	locks map[string]*sync.Mutex // one answer at a time per person
	warm  map[string]*warmBox    // a container kept for the person's next question
}

type warmBox struct {
	ws    Workspace
	timer *time.Timer
}

// SetAssistant turns the assistant on with its store and the snapshot
// reads. Without them the assistant is not available.
func (o *Orchestrator) SetAssistant(st AssistantStore, snap AssistantSnapshotter) {
	o.assistant, o.snapshots = st, snap
}

// SetAssistantEvents sets where live assistant events go (the event
// stream); without it answers are only stored.
func (o *Orchestrator) SetAssistantEvents(ev AssistantEvents) { o.assistantEv = ev }

// SetAssistantActions lets the assistant propose actions; without it,
// asked to act, it says where in the app to do it.
func (o *Orchestrator) SetAssistantActions(a AssistantActions) { o.assistantActs = a }

// AssistantReady reports whether the assistant can answer.
func (o *Orchestrator) AssistantReady() bool { return o.assistant != nil && o.snapshots != nil }

func personKey(ws, user int64) string {
	return strconv.FormatInt(ws, 10) + "/" + strconv.FormatInt(user, 10)
}

// asker returns the person ctx acts for.
func asker(ctx context.Context) (int64, int64, error) {
	ws, err := domain.MustWorkspace(ctx)
	if err != nil {
		return 0, 0, err
	}
	a, ok := domain.ActorOf(ctx)
	if !ok || a.UserID == 0 {
		return 0, 0, invalid("the assistant answers people, not agnts")
	}
	return ws, a.UserID, nil
}

// Ask stores a question in a conversation (a new one when conversationID
// is 0) and starts answering it. It returns at once with the conversation,
// its answer pending; the answer is stored when ready and announced with
// an assistant_answered (or assistant_failed) event to the asker.
func (o *Orchestrator) Ask(ctx context.Context, conversationID int64, question, lang string) (domain.AssistantConversation, error) {
	if !o.AssistantReady() {
		return domain.AssistantConversation{}, invalid("the assistant is not available")
	}
	ws, user, err := asker(ctx)
	if err != nil {
		return domain.AssistantConversation{}, err
	}
	question = strings.TrimSpace(question)
	switch n := utf8.RuneCountInString(question); {
	case n == 0:
		return domain.AssistantConversation{}, invalid("ask a question")
	case n > domain.AssistantMaxQuestion:
		return domain.AssistantConversation{}, invalid("a question is at most %d characters", domain.AssistantMaxQuestion)
	}
	if _, ok := domain.AssistantLanguages[lang]; !ok {
		lang = "en"
	}
	now := time.Now()
	asked, oldest, err := o.assistant.AssistantAsked(ctx, user, now.Add(-time.Hour))
	if err != nil {
		return domain.AssistantConversation{}, err
	}
	if asked >= domain.AssistantPerHour {
		return domain.AssistantConversation{}, &RateLimitedError{RetryAfter: max(time.Minute, oldest.Add(time.Hour).Sub(now))}
	}

	var c domain.AssistantConversation
	if conversationID == 0 {
		if c, err = o.assistant.CreateAssistantConversation(ctx, user, domain.AssistantTitle(question)); err != nil {
			return c, err
		}
	} else if c, err = o.assistant.AssistantConversation(ctx, user, conversationID); err != nil {
		return c, err
	} else if c.Mode == domain.ChatModeCode {
		return c, invalid("this is a Code conversation: send it a message instead")
	}
	q, err := o.assistant.AddAssistantMessage(ctx, domain.AssistantMessage{ConversationID: c.ID, Role: domain.AssistantUser, Text: question,
		Status: domain.AssistantDone, Lang: lang})
	if err != nil {
		return c, err
	}
	a, err := o.assistant.AddAssistantMessage(ctx, domain.AssistantMessage{ConversationID: c.ID, Role: domain.AssistantReply,
		Status: domain.AssistantPending, Lang: lang, PromptVersion: PromptVersion})
	if err != nil {
		return c, err
	}
	// The answer outlives the request: a phone that goes to the background
	// still finds it stored.
	o.answering.Add(1)
	go func() {
		defer o.answering.Done()
		o.answer(context.WithoutCancel(ctx), ws, user, q, a)
	}()
	return o.assistant.AssistantConversation(ctx, user, c.ID)
}

// WaitAnswers waits for the answers being made (tests and shutdown).
func (o *Orchestrator) WaitAnswers() { o.answering.Wait() }

// AssistantConversations lists the asker's conversations of mode ("" for
// both), newest first.
func (o *Orchestrator) AssistantConversations(ctx context.Context, mode domain.ChatMode) ([]domain.AssistantConversation, error) {
	if !o.AssistantReady() {
		return nil, invalid("the assistant is not available")
	}
	_, user, err := asker(ctx)
	if err != nil {
		return nil, err
	}
	return o.assistant.AssistantConversations(ctx, user, mode, 50)
}

// AssistantConversation returns one of the asker's conversations.
func (o *Orchestrator) AssistantConversation(ctx context.Context, id int64) (domain.AssistantConversation, error) {
	if !o.AssistantReady() {
		return domain.AssistantConversation{}, invalid("the assistant is not available")
	}
	_, user, err := asker(ctx)
	if err != nil {
		return domain.AssistantConversation{}, err
	}
	return o.assistant.AssistantConversation(ctx, user, id)
}

// DeleteAssistantConversation deletes one of the asker's conversations.
func (o *Orchestrator) DeleteAssistantConversation(ctx context.Context, id int64) error {
	if !o.AssistantReady() {
		return invalid("the assistant is not available")
	}
	_, user, err := asker(ctx)
	if err != nil {
		return err
	}
	return o.assistant.DeleteAssistantConversation(ctx, user, id)
}

// RateAnswer stores the asker's rating of an answer: 1 (helpful), -1 (not)
// or 0 to take it back. share lets agnts keep the answer's snapshot to try
// new prompts on (only with a rating).
func (o *Orchestrator) RateAnswer(ctx context.Context, messageID int64, rating int, comment string, share bool) (domain.AssistantMessage, error) {
	if !o.AssistantReady() {
		return domain.AssistantMessage{}, invalid("the assistant is not available")
	}
	if rating < -1 || rating > 1 {
		return domain.AssistantMessage{}, invalid("rating is 1, -1 or 0")
	}
	_, user, err := asker(ctx)
	if err != nil {
		return domain.AssistantMessage{}, err
	}
	comment = strings.TrimSpace(comment)
	if utf8.RuneCountInString(comment) > domain.AssistantMaxQuestion {
		return domain.AssistantMessage{}, invalid("a comment is at most %d characters", domain.AssistantMaxQuestion)
	}
	if rating == 0 {
		comment, share = "", false
	}
	return o.assistant.RateAssistantMessage(ctx, user, messageID, rating, comment, share)
}

// ConfirmAssistantAction does one of the asker's proposed actions and tells
// their open streams how it went.
func (o *Orchestrator) ConfirmAssistantAction(ctx context.Context, id string) (domain.AssistantAction, error) {
	return o.assistantAction(ctx, id, AssistantActions.Confirm)
}

// CancelAssistantAction declines one of the asker's proposed actions.
func (o *Orchestrator) CancelAssistantAction(ctx context.Context, id string) (domain.AssistantAction, error) {
	return o.assistantAction(ctx, id, AssistantActions.Cancel)
}

func (o *Orchestrator) assistantAction(ctx context.Context, id string,
	do func(AssistantActions, context.Context, int64, string) (domain.AssistantAction, error)) (domain.AssistantAction, error) {
	if !o.AssistantReady() || o.assistantActs == nil {
		return domain.AssistantAction{}, invalid("the assistant cannot act here")
	}
	ws, user, err := asker(ctx)
	if err != nil {
		return domain.AssistantAction{}, err
	}
	a, err := do(o.assistantActs, ctx, user, strings.TrimSpace(id))
	if err != nil {
		return a, err
	}
	o.publish(ws, user, EventAssistantAction, domain.AssistantMessage{ID: a.MessageID, ConversationID: a.ConversationID},
		map[string]any{"action_id": a.ID, "status": string(a.Status), "result": a.Result, "ticket_key": a.TicketKey})
	return a, nil
}

// AssistantStats reports how the workspace's assistant did (Analytics).
func (o *Orchestrator) AssistantStats(ctx context.Context, days int) (domain.AssistantStats, error) {
	if !o.AssistantReady() {
		return domain.AssistantStats{}, invalid("the assistant is not available")
	}
	if days != 30 && days != 90 {
		days = 7
	}
	return o.assistant.AssistantStats(ctx, days)
}

// AssistantRated lists the workspace's rated answers with their questions.
func (o *Orchestrator) AssistantRated(ctx context.Context, rating int) ([]domain.AssistantRated, error) {
	if !o.AssistantReady() {
		return nil, invalid("the assistant is not available")
	}
	return o.assistant.AssistantRated(ctx, rating, 100)
}

// recoverAssistant fails the answers a stopped server left open.
func (o *Orchestrator) recoverAssistant(ctx context.Context) {
	if o.assistant == nil {
		return
	}
	if n, err := o.assistant.FailOpenAssistant(ctx, "agnts restarted while answering; ask again"); err != nil {
		o.log.Warn("fail interrupted assistant answers", "err", err)
	} else if n > 0 {
		o.log.Warn("failed interrupted assistant answers", "count", n)
	}
}

// pruneAssistant deletes conversations nobody touched for a month.
func (o *Orchestrator) pruneAssistant(ctx context.Context) {
	if o.assistant == nil {
		return
	}
	if n, err := o.assistant.PruneAssistant(ctx, time.Now().AddDate(0, 0, -domain.AssistantKeepDays)); err != nil {
		o.log.Warn("prune assistant conversations", "err", err)
	} else if n > 0 {
		o.log.Info("pruned assistant conversations", "count", n)
	}
}

func (o *Orchestrator) personLock(key string) *sync.Mutex {
	o.asst.mu.Lock()
	defer o.asst.mu.Unlock()
	if o.asst.locks == nil {
		o.asst.locks = map[string]*sync.Mutex{}
	}
	l, ok := o.asst.locks[key]
	if !ok {
		l = &sync.Mutex{}
		o.asst.locks[key] = l
	}
	return l
}

func (o *Orchestrator) publish(ws, user int64, typ string, m domain.AssistantMessage, data map[string]any) {
	if o.assistantEv == nil || user == 0 { // replays have nobody to tell
		return
	}
	d := map[string]any{"conversation_id": m.ConversationID, "message_id": m.ID}
	for k, v := range data {
		d[k] = v
	}
	o.assistantEv.PublishTo(ws, user, domain.Event{WorkspaceID: ws, UserID: user, Type: typ, Data: d, CreatedAt: time.Now()})
}

// answer makes and stores the answer a to question q. One person's
// questions are answered one at a time, in order: a second question waits
// for the first, then sees it in its history.
func (o *Orchestrator) answer(ctx context.Context, ws, user int64, q, a domain.AssistantMessage) {
	lock := o.personLock(personKey(ws, user))
	lock.Lock()
	defer lock.Unlock()

	started := time.Now()
	if err := o.assistant.SetAssistantStatus(ctx, a.ID, domain.AssistantAnswering); err != nil {
		o.log.Warn("assistant: mark answering", "message", a.ID, "err", err)
	}
	o.publish(ws, user, EventAssistantAnswering, a, nil)

	out, snapshot, err := o.makeAnswer(ctx, ws, user, q, a)
	out.ID, out.ConversationID, out.Role, out.Lang, out.PromptVersion = a.ID, a.ConversationID, domain.AssistantReply, a.Lang, PromptVersion
	out.DurationMS = time.Since(started).Milliseconds()
	if err != nil {
		out.Status, out.Error, snapshot = domain.AssistantFailed, assistantErrorText(err), nil
		o.log.Warn("assistant: no answer", "message", a.ID, "err", err)
	} else {
		out.Status = domain.AssistantDone
	}
	if len(snapshot) > assistantMaxSnapshot {
		snapshot = nil
	}
	if err := o.assistant.FinishAssistantMessage(ctx, out, snapshot); err != nil {
		o.log.Error("assistant: store answer", "message", a.ID, "err", err)
		out.Status = domain.AssistantFailed
	}
	if out.Status == domain.AssistantDone {
		o.publish(ws, user, EventAssistantAnswered, out, map[string]any{"duration_ms": out.DurationMS})
	} else {
		o.publish(ws, user, EventAssistantFailed, out, map[string]any{"error": out.Error})
	}
}

// assistantErrorText is what the person reads when an answer failed.
func assistantErrorText(err error) string {
	var ae *assistantError
	switch {
	case errors.As(err, &ae):
		return ae.msg
	case errors.Is(err, ErrPlanLimit):
		return domain.ToolName() + " plan limit reached; ask again after it resets."
	case errors.Is(err, context.DeadlineExceeded):
		return "The answer took too long. Ask again, or ask something narrower."
	}
	return "Something went wrong while answering. Ask again in a moment."
}

// assistantError is a failure the person can act on, in their words.
type assistantError struct{ msg string }

func (e *assistantError) Error() string { return e.msg }

// makeAnswer takes the snapshot, runs Claude on it and reads the answer.
// It returns the snapshot it used (JSON), for replays.
func (o *Orchestrator) makeAnswer(ctx context.Context, ws, user int64, q, a domain.AssistantMessage) (domain.AssistantMessage, []byte, error) {
	var out domain.AssistantMessage
	s, err := o.settings.Get(ctx)
	if err != nil {
		return out, nil, err
	}
	if ctx, err = o.assistantAccount(ctx, s, user); err != nil {
		return out, nil, err
	}

	t0 := time.Now()
	history, err := o.assistant.AssistantHistory(ctx, a.ConversationID, q.ID, domain.AssistantHistory)
	if err != nil {
		return out, nil, err
	}
	question := AssistantQuestion{Question: q.Text, History: history, Topics: AssistantTopicsOf(q.Text, history)}
	texts := []string{q.Text}
	for _, m := range history {
		texts = append(texts, m.Text)
	}
	question.Keys = domain.TicketKeysIn(texts...)
	files, err := o.snapshots.Snapshot(ctx, question)
	if err != nil {
		return out, nil, fmt.Errorf("snapshot: %w", err)
	}
	files = append(files, assistantConversationFiles(q.Text, history)...)
	snapshot, _ := json.Marshal(files)
	out.Timing.SnapshotMS = time.Since(t0).Milliseconds()

	t1 := time.Now()
	key := personKey(ws, user)
	box, warm, err := o.assistantWorkspace(ctx, key, a.ConversationID)
	if err != nil {
		return out, nil, fmt.Errorf("start container: %w", err)
	}
	out.Timing.StartMS, out.Timing.Warm = time.Since(t1).Milliseconds(), warm
	keep := false
	defer func() {
		if keep {
			o.keepWarm(key, box)
			return
		}
		if err := box.Close(context.WithoutCancel(ctx)); err != nil {
			o.log.Warn("remove assistant container", "err", err)
		}
	}()

	res, err := o.runAssistant(ctx, s, ws, user, box, a, files)
	out.Timing.ClaudeMS = res.Duration.Milliseconds()
	out.Model, out.Tokens, out.CostUSD = res.Model, int(res.Usage.Total()), res.Usage.CostUSD
	if err != nil {
		return out, nil, err
	}
	keep = true
	raw, err := box.ReadFile(ctx, AssistantAnswerPath(a.ID))
	if err != nil {
		if res.IsError {
			return out, nil, fmt.Errorf("%s ended with %s: %s", domain.AgentName(res.Model), res.Subtype, truncate(res.Text, 500))
		}
		return out, nil, fmt.Errorf("%s did not write its answer: %w", domain.AgentName(res.Model), err)
	}
	ans, err := ParseAssistantAnswer(raw)
	if err != nil {
		return out, nil, err
	}
	out.Text, out.Speech, out.Links = ans.Answer, ans.Speech, ans.Links
	if len(ans.Actions) > 0 {
		if o.assistantActs == nil {
			out.ActionErrors = []string{"The assistant cannot act here; use the links instead."}
		} else {
			out.Actions, out.ActionErrors = o.assistantActs.Propose(ctx, user, a.ID, ans.Actions)
			for i := range out.Actions {
				out.Actions[i].ConversationID = a.ConversationID
			}
		}
	}
	if ans.Code != nil {
		out.Handoff = o.codeHandoff(ctx, ws, user, *ans.Code)
	}
	for _, f := range files {
		out.Files = append(out.Files, f.Name)
	}
	return out, snapshot, nil
}

// codeHandoff turns an answer's offer to do a code change into the card the
// person opens in Code mode: its repositories by id (names the workspace
// does not have are left out). Viewers, and servers without Code mode, get
// none.
func (o *Orchestrator) codeHandoff(ctx context.Context, ws, user int64, c AssistantCodeOffer) *domain.CodeHandoff {
	if !o.CodeReady() {
		return nil
	}
	if o.codeRole != nil {
		if r, err := o.codeRole(ctx, ws, user); err != nil || !r.CanEdit() {
			return nil
		}
	}
	h := &domain.CodeHandoff{Request: c.Request}
	for _, name := range c.Repositories {
		r, err := o.store.RepositoryByName(ctx, strings.TrimSpace(name))
		if err != nil || r.ArchivedAt != nil || slices.Contains(h.RepoIDs, r.ID) {
			continue
		}
		h.RepoIDs, h.Repos = append(h.RepoIDs, r.ID), append(h.Repos, r.Name)
	}
	return h
}

// ReplayAnswer answers a stored question again, from the snapshot its
// answer was made from (JSON, as kept with the answer), with the current
// prompt: `agnts eval assistant` compares the two. user is whose Claude
// account it runs on in per-member mode (0: the workspace's default).
func (o *Orchestrator) ReplayAnswer(ctx context.Context, snapshot []byte, lang string, user int64) (AssistantAnswer, ClaudeResult, error) {
	var files []AssistantFile
	if err := json.Unmarshal(snapshot, &files); err != nil {
		return AssistantAnswer{}, ClaudeResult{}, fmt.Errorf("the snapshot is not readable: %w", err)
	}
	if len(files) == 0 {
		return AssistantAnswer{}, ClaudeResult{}, errors.New("the snapshot is empty")
	}
	s, err := o.settings.Get(ctx)
	if err != nil {
		return AssistantAnswer{}, ClaudeResult{}, err
	}
	if ctx, err = o.assistantAccount(ctx, s, user); err != nil {
		return AssistantAnswer{}, ClaudeResult{}, err
	}
	box, _, err := o.assistantWorkspace(ctx, "replay", 0)
	if err != nil {
		return AssistantAnswer{}, ClaudeResult{}, fmt.Errorf("start container: %w", err)
	}
	defer func() { _ = box.Close(context.WithoutCancel(ctx)) }()
	m := domain.AssistantMessage{Lang: lang}
	if _, ok := domain.AssistantLanguages[lang]; !ok {
		m.Lang = "en"
	}
	res, err := o.runAssistant(ctx, s, 0, 0, box, m, files)
	if err != nil {
		return AssistantAnswer{}, res, err
	}
	raw, err := box.ReadFile(ctx, AssistantAnswerPath(0))
	if err != nil {
		return AssistantAnswer{}, res, fmt.Errorf("%s did not write its answer: %w", domain.AgentName(res.Model), err)
	}
	a, err := ParseAssistantAnswer(raw)
	return a, res, err
}

// assistantConversationFiles are the question and the talk before it.
func assistantConversationFiles(question string, history []domain.AssistantMessage) []AssistantFile {
	type turn struct {
		Role string `json:"role"`
		Text string `json:"text"`
	}
	conv := make([]turn, 0, len(history))
	for _, m := range history {
		text := m.Text
		// What became of the actions the answer proposed, so "and the
		// other one?" knows.
		for _, a := range m.Actions {
			text += "\n\n[action " + string(a.Status) + ": " + a.Summary
			if a.Result != "" {
				text += " → " + a.Result
			}
			text += "]"
		}
		for _, e := range m.ActionErrors {
			text += "\n\n[action not offered: " + e + "]"
		}
		conv = append(conv, turn{Role: string(m.Role), Text: text})
	}
	b, _ := json.MarshalIndent(conv, "", " ")
	return []AssistantFile{{Name: "conversation.json", Content: string(b)}, {Name: "question.txt", Content: question}}
}

// assistantAccount puts the Claude account the asker's answers run on into
// ctx: the workspace's, or the asker's own in per-member mode. agnts's own
// key (credits) is not used: an answer is not a run that credits can pay
// for.
func (o *Orchestrator) assistantAccount(ctx context.Context, s domain.Settings, user int64) (context.Context, error) {
	if o.accounts == nil || o.workspaces == nil {
		if paused, _ := o.usage.Paused(ctx, s); paused {
			return ctx, ErrPlanLimit
		}
		return ctx, nil
	}
	w, err := o.workspaces.ByID(ctx, domain.WorkspaceOf(ctx))
	if err != nil {
		return ctx, err
	}
	var member *int64
	if w.ClaudeMode == domain.ClaudePerMember && user > 0 {
		member = &user
	}
	acct, ok, why, _ := o.accounts.Pick(ctx, w, member)
	if !ok {
		return ctx, &assistantError{msg: "The assistant cannot reach " + domain.ToolName() + ": " + why + "."}
	}
	if acct.Credits {
		return ctx, &assistantError{msg: fmt.Sprintf("The assistant needs a connected %[1]s account (Workspace settings → %[1]s); it does not run on credits.", domain.ToolName())}
	}
	return domain.WithClaude(ctx, acct), nil
}

// assistantWorkspace returns the person's warm container, or a new one.
func (o *Orchestrator) assistantWorkspace(ctx context.Context, key string, conversation int64) (Workspace, bool, error) {
	o.asst.mu.Lock()
	b, ok := o.asst.warm[key]
	if ok {
		delete(o.asst.warm, key)
	}
	o.asst.mu.Unlock()
	if ok && b.timer.Stop() {
		return b.ws, true, nil
	}
	var empty bytes.Buffer
	_ = tar.NewWriter(&empty).Close()
	ws, err := o.runner.Open(ctx, WorkspaceSpec{TicketKey: "assistant-" + strconv.FormatInt(conversation, 10), Image: o.cfg.Image,
		Repo: &empty, MemoryMB: assistantMemoryMB})
	return ws, false, err
}

// keepWarm keeps a person's container for their next question, and
// removes it when none comes in time.
func (o *Orchestrator) keepWarm(key string, ws Workspace) {
	o.asst.mu.Lock()
	defer o.asst.mu.Unlock()
	if o.asst.warm == nil {
		o.asst.warm = map[string]*warmBox{}
	}
	if old, ok := o.asst.warm[key]; ok && old.timer.Stop() {
		go func() { _ = old.ws.Close(context.Background()) }()
	}
	b := &warmBox{ws: ws}
	b.timer = time.AfterFunc(assistantWarm, func() {
		o.asst.mu.Lock()
		if o.asst.warm[key] == b {
			delete(o.asst.warm, key)
		}
		o.asst.mu.Unlock()
		if err := ws.Close(context.Background()); err != nil {
			o.log.Warn("remove idle assistant container", "err", err)
		}
	})
	o.asst.warm[key] = b
}

// closeWarm removes every kept container (shutdown).
func (o *Orchestrator) closeWarm(ctx context.Context) {
	o.asst.mu.Lock()
	boxes := o.asst.warm
	o.asst.warm = nil
	o.asst.mu.Unlock()
	for _, b := range boxes {
		if b.timer.Stop() {
			_ = b.ws.Close(ctx)
		}
	}
}

// AssistantDir is the folder of answer id's snapshot in its container.
func AssistantDir(id int64) string { return assistantContextRoot + "/q" + strconv.FormatInt(id, 10) }

// AssistantAnswerPath is where the run writes answer id.
func AssistantAnswerPath(id int64) string {
	return assistantOutRoot + "/answer-" + strconv.FormatInt(id, 10) + ".json"
}

// runAssistant writes the snapshot into the container and runs Claude on
// it, forwarding what it reads and says to the asker as it goes.
func (o *Orchestrator) runAssistant(ctx context.Context, s domain.Settings, wsID, user int64, ws Workspace, a domain.AssistantMessage, files []AssistantFile) (ClaudeResult, error) {
	dir := AssistantDir(a.ID)
	names := make([]string, 0, len(files))
	for _, f := range files {
		if err := ws.WriteFile(ctx, dir+"/"+f.Name, []byte(f.Content)); err != nil {
			return ClaudeResult{}, fmt.Errorf("write %s: %w", f.Name, err)
		}
		names = append(names, f.Name)
	}
	prompt, err := render("assistant", promptData{Language: domain.AssistantLanguages[a.Lang], AssistantDir: dir, AssistantFiles: names,
		AnswerPath: AssistantAnswerPath(a.ID), AsOf: time.Now().UTC().Format("2006-01-02 15:04 UTC"), AssistantTools: AssistantTools})
	if err != nil {
		return ClaudeResult{}, err
	}
	res, err := o.callClaude(ctx, ws, transcriptMeta{Purpose: domain.PurposeAssistant, WorkspaceID: wsID,
		Subject: "message " + strconv.FormatInt(a.ID, 10)}, ClaudeRequest{
		Prompt:   prompt,
		Model:    s.Models.Helper,
		MaxTurns: assistantMaxTurns,
		Timeout:  assistantTimeout,
		Settings: AssistantPermissions(),
		ReadOnly: true,
	}, func(e ClaudeEvent) {
		switch e.Kind {
		case ClaudeRateLimit:
			o.usage.Record(ctx, e.Data)
		case ClaudeTool:
			if f := readFileOf(e.Tool, dir); f != "" {
				o.publish(wsID, user, EventAssistantProgress, a, map[string]any{"file": f})
			}
		case ClaudeText:
			if t := strings.TrimSpace(e.Text); t != "" {
				o.publish(wsID, user, EventAssistantPartial, a, map[string]any{"text": truncate(t, 2000)})
			}
		}
	})
	if err != nil {
		return res, err
	}
	if res.RateLimited {
		o.usage.RecordLimited(ctx)
		return res, ErrPlanLimit
	}
	return res, nil
}

// readFileOf names the snapshot file a tool call reads ("Read:
// /agnts/context/q9/ci.json" -> "ci.json"), or "".
func readFileOf(tool, dir string) string {
	i := strings.Index(tool, dir+"/")
	if i < 0 {
		return ""
	}
	return path.Base(strings.Fields(tool[i:])[0])
}

// AssistantPermissions are the assistant run's permission rules: read
// anything, write only answers, no commands, no web, and nothing in
// /workspace or the snapshot. Deny rules win over allow rules.
func AssistantPermissions() string {
	b, _ := json.Marshal(map[string]any{"permissions": map[string]any{
		"allow": []string{"Read", "Glob", "Grep", "Write(//agnts/out/**)", "Edit(//agnts/out/**)"},
		"deny": []string{"Bash", "WebFetch", "WebSearch", "Task", "NotebookEdit",
			"Edit(//workspace/**)", "Write(//workspace/**)", "Edit(//agnts/context/**)", "Write(//agnts/context/**)"},
	}})
	return string(b)
}

// AssistantAnswer is what the run writes.
type AssistantAnswer struct {
	Answer string                 `json:"answer"`
	Speech string                 `json:"speech"`
	Links  []domain.AssistantLink `json:"links"`
	// Actions are writes the run proposes; nothing trusts them until
	// they are checked.
	Actions []domain.AssistantProposal `json:"actions"`
	// Code offers to do a code change in Code mode: the person opens it
	// and sends it there. Nothing runs until they do.
	Code *AssistantCodeOffer `json:"code"`
}

// AssistantCodeOffer is a code change an answer offers to do in Code mode.
type AssistantCodeOffer struct {
	Request      string   `json:"request"`
	Repositories []string `json:"repositories"`
}

const assistantMaxLinks = 6

// ParseAssistantAnswer reads an answer file. An answer without speech gets
// the answer's text without Markdown; links the app cannot open are
// dropped, and ticket keys upper-cased. At most AssistantMaxActions actions
// are kept.
func ParseAssistantAnswer(raw []byte) (AssistantAnswer, error) {
	var a AssistantAnswer
	if err := json.Unmarshal(raw, &a); err != nil {
		return a, fmt.Errorf("the answer is not valid JSON: %w", err)
	}
	a.Answer = strings.TrimSpace(a.Answer)
	if a.Answer == "" {
		return a, errors.New("the answer is empty")
	}
	a.Speech = strings.TrimSpace(a.Speech)
	if a.Speech == "" {
		a.Speech = SpeechOf(a.Answer)
	}
	var links []domain.AssistantLink
	for _, l := range a.Links {
		if l.Kind == "ticket" {
			l.Key, l.ID = strings.ToUpper(strings.TrimSpace(l.Key)), 0
		} else {
			l.Key = ""
		}
		if l.Valid() && !slices.Contains(links, l) {
			links = append(links, l)
		}
		if len(links) == assistantMaxLinks {
			break
		}
	}
	a.Links = links
	var acts []domain.AssistantProposal
	for _, p := range a.Actions {
		if p.Tool = strings.TrimSpace(p.Tool); p.Tool != "" {
			acts = append(acts, p)
		}
		if len(acts) == domain.AssistantMaxActions {
			break
		}
	}
	a.Actions = acts
	if c := a.Code; c != nil {
		c.Request = strings.TrimSpace(c.Request)
		if c.Request == "" {
			a.Code = nil
		} else if utf8.RuneCountInString(c.Request) > domain.CodeMaxMessage {
			c.Request = string([]rune(c.Request)[:domain.CodeMaxMessage])
		}
	}
	return a, nil
}

var (
	mdCodeBlock = regexp.MustCompile("(?s)```.*?```")
	mdLink      = regexp.MustCompile(`!?\[([^\]]*)\]\([^)]*\)`)
	mdURL       = regexp.MustCompile(`https?://\S+`)
	mdLineMark  = regexp.MustCompile(`(?m)^\s*(#{1,6}\s+|[-*+]\s+|\d+[.)]\s+|>\s?)`)
	mdEmphasis  = regexp.MustCompile("[*_`~]+")
	sentenceEnd = regexp.MustCompile(`[.!?…](\s|$)`)
)

// SpeechOf turns Markdown into at most three plain sentences.
func SpeechOf(md string) string {
	s := mdCodeBlock.ReplaceAllString(md, " ")
	s = mdLink.ReplaceAllString(s, "$1")
	s = mdURL.ReplaceAllString(s, "")
	s = mdLineMark.ReplaceAllString(s, "")
	s = mdEmphasis.ReplaceAllString(s, "")
	s = strings.Join(strings.Fields(s), " ")
	ends := sentenceEnd.FindAllStringIndex(s, 3)
	if len(ends) == 3 {
		s = s[:ends[2][0]+1]
	}
	return truncate(strings.TrimSpace(s), 400)
}

// Words that say what a question is about, in the app's languages.
var topicWords = map[AssistantTopic][]string{
	TopicCI: {"ci", "build", "pipeline", "workflow", "red", "failing", "fails", "failed", "flaky", "github actions", "gitlab", "main", "branch",
		"сборк", "пайплайн", "красн", "упал", "падает", "ветк", "тест",
		"qizil", "yiqil"},
	TopicSpend: {"spend", "spent", "cost", "costs", "usage", "limit", "plan", "token", "tokens", "money", "budget", "price", "credits", "week", "today",
		"расход", "потрат", "стоим", "лимит", "токен", "бюджет", "кредит", "недел", "сегодня", "использ",
		"xarajat", "sarf", "narx", "limit", "token", "hafta", "bugun", "kredit"},
	TopicLessons: {"lesson", "lessons", "learn", "learned", "technique", "pattern", "урок", "научи", "изуч", "dars", "o'rgan", "oʻrgan", "texnika"},
	TopicRepos:   {"repo", "repos", "repository", "repositories", "project", "репозитор", "проект", "loyiha", "repozitoriy"},
	TopicAct: {"create", "new task", "implement", "follow-up", "follow up", "follow-ups",
		"fix", "change", "add", "refactor", "rename", "remove", "update",
		"созда", "новую задач", "новая задач", "реализ", "исправ", "добав", "измени", "удали", "переимен",
		"yarat", "yangi vazifa", "amalga osh", "tuzat", "qoʻsh", "qo'sh", "oʻzgartir", "o'zgartir", "olib tashla"},
}

// AssistantTopicsOf returns the parts of the workspace a question is about,
// from its words and the history's; nil when it names none, so the
// snapshot has everything.
func AssistantTopicsOf(question string, history []domain.AssistantMessage) map[AssistantTopic]bool {
	texts := []string{question}
	// The last exchange gives a follow-up ("and yesterday?") its topic.
	if n := len(history); n > 0 {
		for _, m := range history[max(0, n-2):] {
			texts = append(texts, m.Text)
		}
	}
	out := map[AssistantTopic]bool{}
	for _, t := range texts {
		words := strings.ToLower(t)
		for topic, ws := range topicWords {
			for _, w := range ws {
				if containsWord(words, w) {
					out[topic] = true
					break
				}
			}
		}
	}
	if len(out) == 0 {
		return nil
	}
	return out
}

// containsWord reports whether w starts a word of s (so "сборк" matches
// "сборка", and "ci" does not match "decide").
func containsWord(s, w string) bool {
	for i := 0; ; {
		j := strings.Index(s[i:], w)
		if j < 0 {
			return false
		}
		at := i + j
		if at == 0 || !isLetter(s[:at]) {
			return true
		}
		i = at + len(w)
	}
}

// isLetter reports whether s ends in a letter or digit (or the Uzbek
// apostrophes inside words).
func isLetter(s string) bool {
	r, _ := utf8.DecodeLastRuneInString(s)
	return unicode.IsLetter(r) || unicode.IsDigit(r) || r == '\'' || r == 'ʻ'
}

// AssistantTool is a write the assistant may propose, as its prompt lists
// it. The names and inputs are the MCP write tools' (package actions).
type AssistantTool struct{ Name, Args, Does string }

// AssistantTools are the actions the assistant may propose.
var AssistantTools = []AssistantTool{
	{"answer_questions", `{"key", "answers": [{"question_id", "answer"}]}`,
		"answer every question of a ticket waiting for answers (ids in its ticket file); for a question marked multiple, the chosen options one per line. agnts then starts coding"},
	{"start_run", `{"key"}`, "start a ticket held in the queue"},
	{"request_changes", `{"key", "feedback"}`, "send a ticket waiting for review back to coding with the person's feedback"},
	{"retry_run", `{"key"}`, "retry a stopped or paused ticket from where it stopped"},
	{"create_task", `{"title", "description", "kind", "repository" or "repositories" or "group", "priority", "start"}`,
		"a new task. kind: auto (default), code, test, plan, analysis or bug; code and test need a repository (repositories.json) or a group (groups.json). priority low, medium or high; start ask (default), code or queue"},
	{"implement_ticket", `{"key", "repository", "queue"}`, "the code task that carries out a done plan or bug investigation; repository only when it has none; queue true keeps it from starting"},
	{"accept_follow_ups", `{"key", "items": [{"id", "target"}]}`, "create tickets from a ticket's suggested follow-ups (ids in its ticket file); target local (default), jira or plane"},
	{"dismiss_follow_up", `{"key", "id"}`, "decline a suggested follow-up"},
	{"set_ticket_kind", `{"key", "kind"}`, "change what a ticket produces (auto, code, test, plan, analysis or bug), before work starts or on a stopped ticket"},
	{"approve_ticket", `{"key", "post_report"}`, "approve work waiting for review: a change is pushed and its pull request opened; a report closes the ticket. post_report true also posts a report to its Jira or Plane issue, only when asked"},
	{"reject_ticket", `{"key", "reason"}`, "reject a ticket and stop all work on it"},
}
