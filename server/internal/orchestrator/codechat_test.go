package orchestrator_test

import (
	"context"
	"errors"
	"strings"
	"testing"
	"time"

	"agnts/internal/ai"
	"agnts/internal/domain"
	"agnts/internal/orchestrator"
	"agnts/internal/store/postgres"
	"agnts/internal/store/postgres/pgtest"
)

type codeHarness struct {
	*assistantHarness
	repo   int64
	viewer context.Context
}

func newCodeHarness(t *testing.T) *codeHarness {
	t.Helper()
	a := newAssistantHarness(t)
	c := &codeHarness{assistantHarness: a, repo: a.sideRepo()}
	viewer := pgtest.User(t, a.db, "watcher")
	c.viewer = domain.WithActor(a.ctx, domain.Actor{UserID: viewer, Username: "watcher"})
	a.o.SetCodeChat(postgres.NewAssistant(a.db, mustBox(t)), func(_ context.Context, _, user int64) (domain.WorkspaceRole, error) {
		if user == viewer {
			return domain.RoleViewer, nil
		}
		return domain.RoleUser, nil
	})
	return c
}

func (c *codeHarness) start(text string) domain.AssistantConversation {
	c.t.Helper()
	conv, err := c.o.StartCode(c.ask, orchestrator.CodeStart{Text: text, Repos: domain.RepoChoice{RepoID: c.repo}})
	if err != nil {
		c.t.Fatal(err)
	}
	return conv
}

func (c *codeHarness) send(id int64, text string) domain.AssistantMessage {
	c.t.Helper()
	m, err := c.o.SendCode(c.ask, id, orchestrator.CodeSend{Text: text})
	if err != nil {
		c.t.Fatal(err)
	}
	return m
}

func (c *codeHarness) conv(id int64) domain.AssistantConversation {
	c.t.Helper()
	conv, err := c.o.AssistantConversation(c.ask, id)
	if err != nil {
		c.t.Fatal(err)
	}
	return conv
}

func routes(conv domain.AssistantConversation) string {
	var out []string
	for _, m := range conv.Messages {
		out = append(out, string(m.Routed)+":"+m.TicketKey)
	}
	return strings.Join(out, " ")
}

func TestCodeConversationDrivesATicket(t *testing.T) {
	c := newCodeHarness(t)
	conv := c.start("  Add a rest timer between sets  ")
	if conv.Mode != domain.ChatModeCode || conv.Title != "Add a rest timer between sets" || len(conv.Tickets) != 1 {
		t.Fatalf("started: %+v", conv)
	}
	cur := conv.CurrentTicket()
	if cur == nil || cur.Key != "VIS-1" || cur.State != domain.StateNew || strings.Join(cur.Repos, ",") != "visper" {
		t.Fatalf("ticket: %+v", cur)
	}
	if routes(conv) != "created:VIS-1" {
		t.Fatalf("routes = %s", routes(conv))
	}
	tk := c.state("VIS-1")
	if tk.Title != "Add a rest timer between sets" || tk.AskFirst || tk.Held || tk.CreatedBy == nil || *tk.CreatedBy != c.user {
		t.Fatalf("ticket = %+v", tk)
	}

	// While a stage runs, a message waits for it.
	if m := c.send(conv.ID, "show the seconds too"); m.Routed != domain.RoutedQueued || m.TicketKey != "VIS-1" {
		t.Fatalf("while new: %+v", m)
	}
	c.runner.scripts = []script{
		{result: ok("v1"), files: map[string]string{orchestrator.AnalysisPath: analysis(0)}},
		{result: ok("v1"), edit: "timer"},
		{result: ok("v1"), edit: "seconds"},
		{result: ok("v1"), edit: "rename"},
	}
	c.step() // analyze
	c.expect("VIS-1", domain.StateCoding)
	c.o.FlushCodeQueues(c.ctx) // still working: it keeps waiting
	if got := routes(c.conv(conv.ID)); got != "created:VIS-1 queued:VIS-1" {
		t.Fatalf("routes while coding = %s", got)
	}
	c.step() // code
	c.expect("VIS-1", domain.StateWaitingForReview)
	c.o.FlushCodeQueues(c.ctx)
	if tk := c.expect("VIS-1", domain.StateCoding); tk.Feedback != "show the seconds too" {
		t.Fatalf("queued message went as %q", tk.Feedback)
	}
	if got := routes(c.conv(conv.ID)); got != "created:VIS-1 sent:VIS-1" {
		t.Fatalf("routes after flush = %s", got)
	}
	c.step()
	c.expect("VIS-1", domain.StateWaitingForReview)

	// Waiting for review: a message asks for changes.
	if m := c.send(conv.ID, "call it Rest"); m.Routed != domain.RoutedChanges {
		t.Fatalf("at review: %+v", m)
	}
	if tk := c.expect("VIS-1", domain.StateCoding); tk.Feedback != "call it Rest" {
		t.Fatalf("feedback = %q", tk.Feedback)
	}
	evs, _ := c.store.Events(c.ctx, orchestrator.EventFilter{TicketKey: "VIS-1"})
	if last := evs[len(evs)-1]; last.Type != domain.EventFeedback || last.Origin != domain.OriginAssistant || last.UserID != c.user {
		t.Fatalf("feedback event = %+v", last)
	}
	c.step()
	c.expect("VIS-1", domain.StateWaitingForReview)

	// The timeline has the messages and the ticket's events, in order.
	got, items, err := c.o.CodeTimeline(c.ask, conv.ID)
	if err != nil || got.ID != conv.ID {
		t.Fatal(err)
	}
	var kinds []string
	for i, it := range items {
		if i > 0 && it.At.Before(items[i-1].At) {
			t.Fatalf("timeline out of order at %d", i)
		}
		switch {
		case it.Message != nil:
			kinds = append(kinds, "msg")
		case it.Event.Type == domain.EventStateChanged:
			kinds = append(kinds, it.Event.Data["to"].(string))
		}
	}
	if s := strings.Join(kinds, " "); !strings.HasPrefix(s, "msg msg") || !strings.Contains(s, "waiting_for_review") || strings.Count(s, "msg") != 3 {
		t.Fatalf("timeline = %s", s)
	}

	// Once it is done, the next message starts the next ticket in the same
	// repositories.
	if _, err := c.o.Approve(c.ctx, "VIS-1", nil, false, domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	c.step()
	c.expect("VIS-1", domain.StateDone)
	if m := c.send(conv.ID, "now add a sound when it ends"); m.Routed != domain.RoutedCreated || m.TicketKey != "VIS-2" {
		t.Fatalf("after done: %+v", m)
	}
	if tk := c.state("VIS-2"); !strings.Contains(tk.Description, "This follows VIS-1") {
		t.Fatalf("next ticket = %+v", tk)
	}
	conv = c.conv(conv.ID)
	if len(conv.Tickets) != 2 || conv.Tickets[0].Current || conv.CurrentTicket().Key != "VIS-2" {
		t.Fatalf("tickets = %+v", conv.Tickets)
	}
}

func TestCodeAnswersRetriesAndContinues(t *testing.T) {
	c := newCodeHarness(t)
	c.ingest("PAY-1")
	c.runner.scripts = []script{{result: ok("p1"), files: map[string]string{orchestrator.AnalysisPath: analysis(1)}}}
	c.step()
	c.expect("PAY-1", domain.StateWaitingForAnswers)

	// Picking up a ticket that asks one question: the message answers it.
	conv, err := c.o.StartCode(c.ask, orchestrator.CodeStart{Text: "half up", TicketKey: "pay-1"})
	if err != nil {
		t.Fatal(err)
	}
	if routes(conv) != "answered:PAY-1" || conv.Repos.RepoID != c.apiRepo() {
		t.Fatalf("picked up: %s %+v", routes(conv), conv.Repos)
	}
	c.expect("PAY-1", domain.StateCoding)
	if _, err := c.o.SendCode(c.ask, conv.ID, orchestrator.CodeSend{Answers: []domain.Answer{{QuestionID: 1, Answer: "x"}}}); !isConflict(err) {
		t.Fatalf("answers while coding: %v", err)
	}

	// Stopped: the message is the retry's note.
	if _, err := c.o.Stop(c.ctx, "PAY-1", domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	if m := c.send(conv.ID, "use math.Round"); m.Routed != domain.RoutedRetried {
		t.Fatalf("after stop: %+v", m)
	}
	if tk := c.expect("PAY-1", domain.StateCoding); !strings.Contains(tk.Feedback, "use math.Round") {
		t.Fatalf("retry feedback = %q", tk.Feedback)
	}

	// Rejected: the message continues it.
	c.runner.scripts = []script{{result: ok("p1"), edit: "fix"}}
	c.step()
	c.expect("PAY-1", domain.StateWaitingForReview)
	if _, err := c.o.Reject(c.ctx, "PAY-1", "not now", domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	if m := c.send(conv.ID, "try again, smaller"); m.Routed != domain.RoutedContinued {
		t.Fatalf("after reject: %+v", m)
	}
	if tk := c.expect("PAY-1", domain.StateCoding); tk.Feedback != "try again, smaller" {
		t.Fatalf("continue feedback = %q", tk.Feedback)
	}
}

func isConflict(err error) bool {
	var te *domain.TransitionError
	return errors.As(err, &te)
}

func TestCodeSendNowStopsAndSends(t *testing.T) {
	c := newCodeHarness(t)
	conv := c.start("Add a rest timer")
	c.runner.scripts = []script{{result: ok("v1"), files: map[string]string{orchestrator.AnalysisPath: analysis(0)}}}
	c.step()
	c.expect("VIS-1", domain.StateCoding)
	c.send(conv.ID, "in minutes")
	c.send(conv.ID, "and seconds")
	if _, err := c.o.SendQueuedNow(c.ask, conv.ID); err != nil {
		t.Fatal(err)
	}
	if tk := c.expect("VIS-1", domain.StateCoding); !strings.Contains(tk.Feedback, "in minutes\n\nand seconds") {
		t.Fatalf("sent as %q", tk.Feedback)
	}
	if got := routes(c.conv(conv.ID)); got != "created:VIS-1 sent:VIS-1 sent:VIS-1" {
		t.Fatalf("routes = %s", got)
	}
	if _, err := c.o.SendQueuedNow(c.ask, conv.ID); !errors.Is(err, orchestrator.ErrInvalid) {
		t.Fatalf("nothing queued: %v", err)
	}
}

func TestCodeModeChecks(t *testing.T) {
	c := newCodeHarness(t)
	if _, err := c.o.StartCode(c.viewer, orchestrator.CodeStart{Text: "x", Repos: domain.RepoChoice{RepoID: c.repo}}); !errors.Is(err, domain.ErrForbidden) {
		t.Fatalf("viewer started: %v", err)
	}
	if _, err := c.o.StartCode(c.ask, orchestrator.CodeStart{Text: "x"}); !errors.Is(err, orchestrator.ErrInvalid) {
		t.Fatalf("no repositories: %v", err)
	}
	if _, err := c.o.StartCode(c.ask, orchestrator.CodeStart{Text: "x", TicketKey: "NOPE-1"}); !errors.Is(err, orchestrator.ErrInvalid) {
		t.Fatalf("unknown ticket: %v", err)
	}
	if _, err := c.o.StartCode(c.ask, orchestrator.CodeStart{Text: strings.Repeat("x", domain.CodeMaxMessage+1), Repos: domain.RepoChoice{RepoID: c.repo}}); !errors.Is(err, orchestrator.ErrInvalid) {
		t.Fatalf("too long: %v", err)
	}
	if list, _ := c.o.AssistantConversations(c.ask, ""); len(list) != 0 {
		t.Fatalf("failed starts left conversations: %+v", list)
	}

	conv := c.start("Add a rest timer")
	if _, err := c.o.SendCode(c.other, conv.ID, orchestrator.CodeSend{Text: "mine now"}); !errors.Is(err, domain.ErrNotFound) {
		t.Fatalf("someone else's conversation: %v", err)
	}
	if _, err := c.o.Ask(c.ask, conv.ID, "what is waiting?", "en", nil); !errors.Is(err, orchestrator.ErrInvalid) {
		t.Fatalf("asked in a Code conversation: %v", err)
	}
	chat, err := c.o.Ask(c.ask, 0, "what is waiting?", "en", nil)
	if err != nil {
		t.Fatal(err)
	}
	if _, err := c.o.SendCode(c.ask, chat.ID, orchestrator.CodeSend{Text: "x"}); !errors.Is(err, orchestrator.ErrInvalid) {
		t.Fatalf("code message in a Chat conversation: %v", err)
	}
	if list, _ := c.o.AssistantConversations(c.ask, domain.ChatModeCode); len(list) != 1 || list[0].ID != conv.ID || len(list[0].Tickets) != 1 {
		t.Fatalf("code list = %+v", list)
	}
	// Code messages are not questions: they don't count toward the hourly limit.
	asked, _, _ := postgres.NewAssistant(c.db, nil).AssistantAsked(c.ask, c.user, conv.CreatedAt.Add(-1))
	if asked != 1 {
		t.Fatalf("asked = %d", asked)
	}

	// At most CodeMaxRunning of a person's tickets run at once.
	c.start("two")
	c.start("three")
	if _, err := c.o.StartCode(c.ask, orchestrator.CodeStart{Text: "four", Repos: domain.RepoChoice{RepoID: c.repo}}); !errors.Is(err, orchestrator.ErrInvalid) {
		t.Fatalf("fourth running ticket: %v", err)
	}
}

func TestCodeTicketLivesInOneConversation(t *testing.T) {
	c := newCodeHarness(t)
	first := c.start("Add a rest timer")
	second := c.start("Something else")
	moved, err := c.o.AttachCodeTicket(c.ask, second.ID, "VIS-1")
	if err != nil || moved.CurrentTicket().Key != "VIS-1" {
		t.Fatalf("attach: %+v %v", moved, err)
	}
	f := c.conv(first.ID)
	if f.CurrentTicket() != nil || !f.Tickets[0].Moved {
		t.Fatalf("first still has it: %+v", f.Tickets)
	}
	if id, err := c.o.TicketConversation(c.ask, "vis-1"); err != nil || id != second.ID {
		t.Fatalf("ticket's conversation = %d %v", id, err)
	}
	if _, err := c.o.TicketConversation(c.other, "VIS-1"); !errors.Is(err, domain.ErrNotFound) {
		t.Fatalf("someone else's: %v", err)
	}
	// A message in the first one starts a new ticket there.
	if m := c.send(first.ID, "a timer after all"); m.Routed != domain.RoutedCreated || m.TicketKey == "VIS-1" {
		t.Fatalf("after move: %+v", m)
	}
}

func TestCodeQueuedMessageTheTicketWontTake(t *testing.T) {
	c := newCodeHarness(t)
	c.ingest("PAY-1")
	conv, err := c.o.StartCode(c.ask, orchestrator.CodeStart{Text: "round half up", TicketKey: "PAY-1"})
	if err != nil || routes(conv) != "queued:PAY-1" {
		t.Fatalf("picked up a new ticket: %s %v", routes(conv), err)
	}
	c.runner.scripts = []script{{result: ok("p1"), files: map[string]string{orchestrator.AnalysisPath: analysis(2)}}}
	c.step()
	c.expect("PAY-1", domain.StateWaitingForAnswers)
	c.o.FlushCodeQueues(c.ctx)
	m := c.conv(conv.ID).Messages[0]
	if m.Routed != domain.RoutedFailed || m.Status != domain.AssistantFailed || !strings.Contains(m.Error, "asks 2 questions") {
		t.Fatalf("queued message = %+v", m)
	}
	c.expect("PAY-1", domain.StateWaitingForAnswers)
	c.o.FlushCodeQueues(c.ctx) // sent once: nothing left
	if got := routes(c.conv(conv.ID)); got != "failed:PAY-1" {
		t.Fatalf("routes = %s", got)
	}
}

func TestPruneKeepsCodeConversationsWithOpenTickets(t *testing.T) {
	c := newCodeHarness(t)
	code := c.start("Add a rest timer")
	c.answers(3, `{"answer":"Nothing waits on you."}`)
	chat, err := c.o.Ask(c.ask, 0, "what waits on me?", "en", nil)
	if err != nil {
		t.Fatal(err)
	}
	c.o.WaitAnswers()
	if _, err := postgres.NewAssistant(c.db, nil).PruneAssistant(c.ctx, time.Now().Add(time.Hour)); err != nil {
		t.Fatal(err)
	}
	if _, err := c.o.AssistantConversation(c.ask, chat.ID); !errors.Is(err, domain.ErrNotFound) {
		t.Fatalf("old chat kept: %v", err)
	}
	c.conv(code.ID) // still there: VIS-1 is open
	if _, err := c.o.Reject(c.ctx, "VIS-1", "no", domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	if _, err := postgres.NewAssistant(c.db, nil).PruneAssistant(c.ctx, time.Now().Add(time.Hour)); err != nil {
		t.Fatal(err)
	}
	if _, err := c.o.AssistantConversation(c.ask, code.ID); !errors.Is(err, domain.ErrNotFound) {
		t.Fatalf("finished code conversation kept: %v", err)
	}
}

func TestChatAnswerOffersCodeMode(t *testing.T) {
	c := newCodeHarness(t)
	c.answers(2, `{"answer":"I can do this in Code mode.","code":{"request":"Round refunds half up","repositories":["visper","nope","visper"]}}`)
	conv, err := c.o.Ask(c.ask, 0, "Fix the refund rounding", "en", nil)
	if err != nil {
		t.Fatal(err)
	}
	h := c.conversation(conv.ID).Messages[1].Handoff
	if h == nil || h.Request != "Round refunds half up" || len(h.RepoIDs) != 1 || h.RepoIDs[0] != c.repo || h.Repos[0] != "visper" {
		t.Fatalf("handoff = %+v", h)
	}

	// A viewer is offered nothing.
	c.answers(4, `{"answer":"I can do this in Code mode.","code":{"request":"Round refunds half up","repositories":["visper"]}}`)
	vconv, err := c.o.Ask(c.viewer, 0, "Fix the refund rounding", "en", nil)
	if err != nil {
		t.Fatal(err)
	}
	c.o.WaitAnswers()
	got, err := c.o.AssistantConversation(c.viewer, vconv.ID)
	if err != nil || got.Messages[1].Handoff != nil {
		t.Fatalf("viewer handoff = %+v %v", got.Messages[1].Handoff, err)
	}
}

func TestParseCodeOffer(t *testing.T) {
	a, err := orchestrator.ParseAssistantAnswer([]byte(`{"answer":"x","code":{"request":"  ","repositories":["api"]}}`))
	if err != nil || a.Code != nil {
		t.Fatalf("empty request kept: %+v %v", a.Code, err)
	}
	if p := orchestrator.CheckCode(nil, true); len(p) != 1 {
		t.Fatalf("missing offer not reported: %v", p)
	}
	if p := orchestrator.CheckCode(&orchestrator.AssistantCodeOffer{Request: "x"}, false); len(p) != 1 {
		t.Fatalf("unasked offer not reported: %v", p)
	}
}

// A Muse run on a ticket someone follows in a chat is live: their message
// goes into the running turn, and a tool call the run asks about is
// decided in the chat.
func TestCodeLiveMuseRun(t *testing.T) {
	c := newCodeHarness(t)
	c.settings.s.Models.Coding, c.settings.s.Models.Analyze = "muse:spark", "muse:spark"
	conv := c.start("Add a rest timer")
	c.runner.scripts = []script{
		{result: ok("v1"), files: map[string]string{orchestrator.AnalysisPath: analysis(0)}},
		{result: ok("v1"), edit: "timer"},
	}
	c.step() // analyze
	c.expect("VIS-1", domain.StateCoding)

	var steered string
	var asked, decided bool
	c.runner.onClaude = func(r ai.Request) {
		if r.Steer == nil || r.Ask == nil {
			t.Errorf("the coding run is not live: steer %v ask %v", r.Steer != nil, r.Ask != nil)
			return
		}
		m := c.send(conv.ID, "show the seconds too")
		if m.Routed != domain.RoutedSteered {
			t.Errorf("message while coding: %+v", m)
		}
		steered = <-r.Steer
		answer := r.Ask(orchestrator.ToolQuestion{Tool: "Bash", Command: "npm install left-pad", Reason: "it adds a dependency to the project"})
		aps, err := c.o.CodeApprovals(c.ask, conv.ID)
		if err != nil || len(aps) != 1 || aps[0].Status != domain.ApprovalPending || aps[0].Command != "npm install left-pad" {
			t.Errorf("approvals = %+v %v", aps, err)
			return
		}
		asked = true
		if _, err := c.o.DecideCodeApproval(c.other, aps[0].ID, true); !errors.Is(err, domain.ErrNotFound) {
			t.Errorf("someone else decided: %v", err)
		}
		if a, err := c.o.DecideCodeApproval(c.ask, aps[0].ID, true); err != nil || a.Status != domain.ApprovalAllowed {
			t.Errorf("decide: %+v %v", a, err)
		}
		if _, err := c.o.DecideCodeApproval(c.ask, aps[0].ID, false); !errors.Is(err, domain.ErrConflict) {
			t.Errorf("decided twice: %v", err)
		}
		decided = <-answer
	}
	c.step() // code
	c.expect("VIS-1", domain.StateWaitingForReview)
	if steered != "show the seconds too" || !asked || !decided {
		t.Fatalf("steered %q, asked %v, decided %v", steered, asked, decided)
	}
	// The run is over: nothing is live, and a message waits for the next one.
	if aps, _ := c.o.CodeApprovals(c.ask, conv.ID); len(aps) != 0 {
		t.Fatalf("approvals after the run = %+v", aps)
	}
	if got := routes(c.conv(conv.ID)); got != "created:VIS-1 steered:VIS-1" {
		t.Fatalf("routes = %s", got)
	}

	// A Claude Code run is not live.
	c.settings.s.Models.Coding = "sonnet"
	c.send(conv.ID, "and minutes")
	c.runner.scripts = []script{{result: ok("v1"), edit: "minutes"}}
	c.runner.onClaude = func(r ai.Request) {
		if r.Steer != nil || r.Ask != nil {
			t.Errorf("a Claude run got steer or ask")
		}
	}
	c.step()
}

func TestCodeMessageNamesRepos(t *testing.T) {
	c := newCodeHarness(t)
	gym, err := c.store.SaveRepository(c.ctx, domain.Repository{
		Name: "gymlog", Kind: "side", Provider: "github", CloneURL: "https://github.com/me/gymlog.git",
		DefaultBranch: "main", TaskPrefix: "GYM",
	})
	if err != nil {
		t.Fatal(err)
	}

	// None picked: the repository the message names, even without an @.
	conv, err := c.o.StartCode(c.ask, orchestrator.CodeStart{Text: "Add a rest timer to Visper."})
	if err != nil {
		t.Fatal(err)
	}
	if cur := conv.CurrentTicket(); cur == nil || cur.Key != "VIS-1" || conv.Repos.RepoID != c.repo {
		t.Fatalf("named without @: %+v %+v", cur, conv.Repos)
	}
	if _, err := c.o.StartCode(c.ask, orchestrator.CodeStart{Text: "Add a rest timer"}); !errors.Is(err, orchestrator.ErrInvalid) {
		t.Fatalf("nothing named: %v", err)
	}

	// Picked ones, but the message says @gymlog: its ticket works there,
	// and the conversation's next tickets too.
	conv = c.start("@gymlog log the weight of each set")
	if cur := conv.CurrentTicket(); cur == nil || cur.Key != "GYM-1" || conv.Repos.RepoID != gym.ID {
		t.Fatalf("named with @: %+v %+v", cur, conv.Repos)
	}

	// Both, by @: one ticket in the two.
	conv = c.start("rename the app in @visper and @GymLog, please")
	if cur := conv.CurrentTicket(); cur == nil || len(cur.Repos) != 2 || len(conv.Repos.RepoIDs) != 2 {
		t.Fatalf("named both: %+v %+v", cur, conv.Repos)
	}
}
