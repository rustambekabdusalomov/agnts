package orchestrator_test

import (
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"strings"
	"sync"
	"testing"

	"github.com/jackc/pgx/v5/pgxpool"

	"agnts/internal/ai"
	"agnts/internal/domain"
	"agnts/internal/orchestrator"
	"agnts/internal/secret"
	"agnts/internal/store/postgres"
	"agnts/internal/store/postgres/pgtest"
)

type fakeSnap struct {
	mu   sync.Mutex
	seen []orchestrator.AssistantQuestion
}

func (f *fakeSnap) Snapshot(_ context.Context, q orchestrator.AssistantQuestion) ([]orchestrator.AssistantFile, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	f.seen = append(f.seen, q)
	return []orchestrator.AssistantFile{{Name: "inbox.json", Content: `{"needs_you":[{"key":"PAY-214"}]}`}, {Name: "tickets.json", Content: `{}`}}, nil
}

type fakeLive struct {
	mu    sync.Mutex
	got   []string // event types, in order
	users map[int64]bool
}

func (f *fakeLive) PublishTo(_, user int64, e domain.Event) {
	f.mu.Lock()
	defer f.mu.Unlock()
	f.got = append(f.got, e.Type)
	if f.users == nil {
		f.users = map[int64]bool{}
	}
	f.users[user] = true
}

type assistantHarness struct {
	*harness
	snap  *fakeSnap
	live  *fakeLive
	db    *pgxpool.Pool
	ask   context.Context // acts for the asker
	other context.Context // another person in the same workspace
	user  int64
	reqs  []ai.Request
}

func newAssistantHarness(t *testing.T) *assistantHarness {
	t.Helper()
	h := newHarness(t)
	pool := pgtest.Open(t)
	box, err := secret.NewBox(bytes.Repeat([]byte{3}, 32))
	if err != nil {
		t.Fatal(err)
	}
	a := &assistantHarness{harness: h, snap: &fakeSnap{}, live: &fakeLive{}, db: pool}
	h.o.SetAssistant(postgres.NewAssistant(pool, box), a.snap)
	h.o.SetAssistantEvents(a.live)
	a.user = pgtest.User(t, pool, "asker")
	a.ask = domain.WithActor(h.ctx, domain.Actor{UserID: a.user, Username: "asker"})
	a.other = domain.WithActor(h.ctx, domain.Actor{UserID: pgtest.User(t, pool, "someone"), Username: "someone"})
	h.runner.onClaude = func(r ai.Request) { a.reqs = append(a.reqs, r) }
	return a
}

// answers scripts Claude's next run writing answer id.
func (a *assistantHarness) answers(id int64, answer string) {
	a.runner.scripts = append(a.runner.scripts, script{result: ok("s"), files: map[string]string{orchestrator.AssistantAnswerPath(id): answer}})
}

func (a *assistantHarness) conversation(id int64) domain.AssistantConversation {
	a.t.Helper()
	a.o.WaitAnswers()
	c, err := a.o.AssistantConversation(a.ask, id)
	if err != nil {
		a.t.Fatal(err)
	}
	return c
}

func TestAssistantAnswersFromTheSnapshot(t *testing.T) {
	a := newAssistantHarness(t)
	a.answers(2, `{"answer":"**PAY-214** waits for your review.","speech":"","links":[{"kind":"ticket","key":"pay-214"},{"kind":"ci","id":0},{"kind":"repo"}]}`)
	c, err := a.o.Ask(a.ask, 0, "  What waits on me? Look at pay-214  ", "ru")
	if err != nil {
		t.Fatal(err)
	}
	if c.Title != "What waits on me? Look at pay-214" || len(c.Messages) != 2 || c.Messages[1].Status == domain.AssistantDone {
		t.Fatalf("asked: %+v", c)
	}
	c = a.conversation(c.ID)
	ans := c.Messages[1]
	if ans.Status != domain.AssistantDone || ans.Text != "**PAY-214** waits for your review." || ans.Speech != "PAY-214 waits for your review." {
		t.Fatalf("answer = %+v", ans)
	}
	if len(ans.Links) != 1 || ans.Links[0] != (domain.AssistantLink{Kind: "ticket", Key: "PAY-214"}) {
		t.Fatalf("links = %+v", ans.Links)
	}
	if strings.Join(ans.Files, ",") != "inbox.json,tickets.json,conversation.json,question.txt" || ans.PromptVersion != orchestrator.PromptVersion || ans.Lang != "ru" {
		t.Fatalf("files/version/lang = %v %q %q", ans.Files, ans.PromptVersion, ans.Lang)
	}
	if got := a.snap.seen[0]; got.Question != "What waits on me? Look at pay-214" || strings.Join(got.Keys, ",") != "PAY-214" || len(got.History) != 0 {
		t.Fatalf("snapshot asked for %+v", got)
	}
	if q := a.runner.written[orchestrator.AssistantDir(2)+"/question.txt"]; q != "What waits on me? Look at pay-214" {
		t.Fatalf("question.txt = %q", q)
	}
	p := a.runner.prompts[0]
	if !strings.Contains(p, "Answer in the language question.txt is written in") || !strings.Contains(p, "answer in Russian, the app's language") ||
		!strings.Contains(p, orchestrator.AssistantDir(2)+"/inbox.json") || !strings.Contains(p, orchestrator.AssistantAnswerPath(2)) {
		t.Fatalf("prompt = %s", p)
	}
	req := a.reqs[0]
	if !req.ReadOnly || req.MaxTurns != 16 || !strings.Contains(req.Settings, `"Bash"`) || !strings.Contains(req.Settings, `"WebFetch"`) {
		t.Fatalf("request = %+v", req)
	}
	if got := strings.Join(a.live.got, " "); got != "assistant_answering assistant_answered" || len(a.live.users) != 1 || !a.live.users[a.user] {
		t.Fatalf("events = %v to %v", got, a.live.users)
	}
}

func TestAssistantFollowUpReusesTheContainerAndSeesHistory(t *testing.T) {
	a := newAssistantHarness(t)
	a.answers(2, `{"answer":"PAY-214 needs you.","speech":"PAY-214 needs you."}`)
	c, err := a.o.Ask(a.ask, 0, "What waits on me?", "en")
	if err != nil {
		t.Fatal(err)
	}
	a.o.WaitAnswers()
	a.answers(4, `{"answer":"main is red since abc123.","speech":"Main is red."}`)
	if _, err := a.o.Ask(a.ask, c.ID, "And why is CI red?", "en"); err != nil {
		t.Fatal(err)
	}
	c = a.conversation(c.ID)
	if len(c.Messages) != 4 || c.Messages[3].Text != "main is red since abc123." {
		t.Fatalf("conversation = %+v", c.Messages)
	}
	if a.runner.opened != 1 || a.runner.closed != 0 {
		t.Fatalf("containers opened %d, closed %d; want one kept warm", a.runner.opened, a.runner.closed)
	}
	if !c.Messages[3].Timing.Warm {
		t.Fatalf("timing = %+v", c.Messages[3].Timing)
	}
	follow := a.snap.seen[1]
	if len(follow.History) != 2 || follow.History[0].Text != "What waits on me?" || follow.History[1].Text != "PAY-214 needs you." {
		t.Fatalf("history = %+v", follow.History)
	}
	if !follow.Topics[orchestrator.TopicCI] || follow.Topics[orchestrator.TopicLessons] {
		t.Fatalf("topics = %v", follow.Topics)
	}
	var conv []map[string]string
	if err := json.Unmarshal([]byte(a.runner.written[orchestrator.AssistantDir(4)+"/conversation.json"]), &conv); err != nil || len(conv) != 2 || conv[0]["role"] != "user" {
		t.Fatalf("conversation.json = %v %v", conv, err)
	}
}

func TestAssistantConversationsArePrivate(t *testing.T) {
	a := newAssistantHarness(t)
	a.answers(2, `{"answer":"Nothing waits on you."}`)
	c, err := a.o.Ask(a.ask, 0, "What waits on me?", "en")
	if err != nil {
		t.Fatal(err)
	}
	a.o.WaitAnswers()
	if _, err := a.o.AssistantConversation(a.other, c.ID); !errors.Is(err, domain.ErrNotFound) {
		t.Fatalf("another person read it: %v", err)
	}
	if _, err := a.o.Ask(a.other, c.ID, "and?", "en"); !errors.Is(err, domain.ErrNotFound) {
		t.Fatalf("another person asked in it: %v", err)
	}
	if list, err := a.o.AssistantConversations(a.other, ""); err != nil || len(list) != 0 {
		t.Fatalf("another person's list: %v %v", list, err)
	}
	if _, err := a.o.RateAnswer(a.other, 2, -1, "", false); !errors.Is(err, domain.ErrNotFound) {
		t.Fatalf("another person rated it: %v", err)
	}
	if err := a.o.DeleteAssistantConversation(a.other, c.ID); !errors.Is(err, domain.ErrNotFound) {
		t.Fatalf("another person deleted it: %v", err)
	}
	if list, err := a.o.AssistantConversations(a.ask, ""); err != nil || len(list) != 1 || len(list[0].Messages) != 1 || list[0].Messages[0].Role != domain.AssistantReply {
		t.Fatalf("own list = %+v %v", list, err)
	}
	if err := a.o.DeleteAssistantConversation(a.ask, c.ID); err != nil {
		t.Fatal(err)
	}
	if _, err := a.o.AssistantConversation(a.ask, c.ID); !errors.Is(err, domain.ErrNotFound) {
		t.Fatalf("deleted conversation: %v", err)
	}
}

func TestAssistantFailures(t *testing.T) {
	a := newAssistantHarness(t)
	if _, err := a.o.Ask(a.ask, 0, "   ", "en"); !errors.Is(err, orchestrator.ErrInvalid) {
		t.Fatalf("empty question: %v", err)
	}
	if _, err := a.o.Ask(a.ask, 0, strings.Repeat("я", 1001), "en"); !errors.Is(err, orchestrator.ErrInvalid) {
		t.Fatalf("long question: %v", err)
	}
	if _, err := a.o.Ask(a.ctx, 0, "who am I?", "en"); !errors.Is(err, orchestrator.ErrInvalid) {
		t.Fatalf("no person: %v", err)
	}

	// No answer file: the answer fails, in words the person can read.
	a.runner.scripts = []script{{result: ok("s")}}
	c, err := a.o.Ask(a.ask, 0, "What waits on me?", "xx")
	if err != nil {
		t.Fatal(err)
	}
	c = a.conversation(c.ID)
	if m := c.Messages[1]; m.Status != domain.AssistantFailed || !strings.Contains(m.Error, "Ask again") || m.Lang != "en" {
		t.Fatalf("no file: %+v", m)
	}
	if got := a.live.got[len(a.live.got)-1]; got != "assistant_failed" {
		t.Fatalf("last event %q", got)
	}

	// At the plan limit no run starts.
	a.usage.paused = true
	if _, err := a.o.Ask(a.ask, c.ID, "and now?", "en"); err != nil {
		t.Fatal(err)
	}
	c = a.conversation(c.ID)
	if m := c.Messages[3]; m.Status != domain.AssistantFailed || !strings.Contains(m.Error, "plan limit") {
		t.Fatalf("plan limit: %+v", m)
	}
	if len(a.runner.prompts) != 1 {
		t.Fatalf("claude ran %d times", len(a.runner.prompts))
	}

	// 30 questions an hour.
	for range domain.AssistantPerHour - 2 {
		pgtest.Exec(t, a.db, `INSERT INTO assistant_messages (workspace_id, conversation_id, role, text)
			SELECT workspace_id, id, 'user', 'q' FROM assistant_conversations WHERE id = $1`, c.ID)
	}
	var rl *orchestrator.RateLimitedError
	if _, err := a.o.Ask(a.ask, c.ID, "one more", "en"); !errors.As(err, &rl) || rl.RetryAfter <= 0 {
		t.Fatalf("31st question: %v", err)
	}
}

func TestAssistantRatingsAndStats(t *testing.T) {
	a := newAssistantHarness(t)
	a.answers(2, `{"answer":"PAY-214 needs you."}`)
	c, err := a.o.Ask(a.ask, 0, "What waits on me?", "en")
	if err != nil {
		t.Fatal(err)
	}
	a.o.WaitAnswers()
	if _, err := a.o.RateAnswer(a.ask, 1, 1, "", false); !errors.Is(err, domain.ErrNotFound) {
		t.Fatalf("rated a question: %v", err)
	}
	m, err := a.o.RateAnswer(a.ask, 2, -1, " wrong ticket ", true)
	if err != nil || m.Rating != -1 || m.RatingComment != "wrong ticket" || !m.Shared {
		t.Fatalf("rate = %+v %v", m, err)
	}
	rated, err := a.o.AssistantRated(a.ask, -1)
	if err != nil || len(rated) != 1 || rated[0].Question != "What waits on me?" || rated[0].Username != "asker" || rated[0].Comment != "wrong ticket" {
		t.Fatalf("rated = %+v %v", rated, err)
	}
	st, err := a.o.AssistantStats(a.ask, 7)
	if err != nil || st.Questions != 1 || st.Answered != 1 || st.Down != 1 || st.People != 1 || len(st.Versions) != 1 || st.Versions[0].PromptVersion != orchestrator.PromptVersion {
		t.Fatalf("stats = %+v %v", st, err)
	}
	// Taking the rating back stops sharing too.
	if m, err = a.o.RateAnswer(a.ask, 2, 0, "x", true); err != nil || m.Rating != 0 || m.Shared || m.RatingComment != "" {
		t.Fatalf("cleared = %+v %v", m, err)
	}
	_ = c
}

func TestAssistantReplaysSharedAnswers(t *testing.T) {
	a := newAssistantHarness(t)
	store := postgres.NewAssistant(a.db, mustBox(t))
	a.answers(2, `{"answer":"PAY-214 needs you."}`)
	if _, err := a.o.Ask(a.ask, 0, "What waits on me?", "uz"); err != nil {
		t.Fatal(err)
	}
	a.o.WaitAnswers()
	if cases, err := store.AssistantReplays(a.ask, 10); err != nil || len(cases) != 0 {
		t.Fatalf("unshared answers replayed: %v %v", cases, err)
	}
	if _, err := a.o.RateAnswer(a.ask, 2, -1, "", true); err != nil {
		t.Fatal(err)
	}
	cases, err := store.AssistantReplays(a.ask, 10)
	if err != nil || len(cases) != 1 || cases[0].Question != "What waits on me?" || cases[0].Lang != "uz" || cases[0].UserID != a.user {
		t.Fatalf("cases = %+v %v", cases, err)
	}
	a.answers(0, `{"answer":"Ikkita vazifa sizni kutmoqda."}`)
	ans, _, err := a.o.ReplayAnswer(a.ctx, cases[0].Snapshot, cases[0].Lang, cases[0].UserID)
	if err != nil || ans.Answer != "Ikkita vazifa sizni kutmoqda." {
		t.Fatalf("replay = %+v %v", ans, err)
	}
	if q := a.runner.written[orchestrator.AssistantDir(0)+"/question.txt"]; q != "What waits on me?" {
		t.Fatalf("replayed question.txt = %q", q)
	}
	if !strings.Contains(a.runner.prompts[1], "answer in Uzbek, the app's language") {
		t.Fatalf("replay prompt = %s", a.runner.prompts[1])
	}
}

func mustBox(t *testing.T) *secret.Box {
	t.Helper()
	b, err := secret.NewBox(bytes.Repeat([]byte{3}, 32))
	if err != nil {
		t.Fatal(err)
	}
	return b
}

// fakeActs proposes every proposal but "bad", and confirms anything.
type fakeActs struct {
	mu        sync.Mutex
	got       []domain.AssistantProposal
	user, msg int64
}

func (f *fakeActs) Propose(_ context.Context, user, msg int64, ps []domain.AssistantProposal) ([]domain.AssistantAction, []string) {
	f.mu.Lock()
	defer f.mu.Unlock()
	f.got, f.user, f.msg = ps, user, msg
	var out []domain.AssistantAction
	var errs []string
	for _, p := range ps {
		if p.Tool == "bad" {
			errs = append(errs, "bad: unknown action")
			continue
		}
		out = append(out, domain.AssistantAction{ID: p.Tool, MessageID: msg, Tool: p.Tool, Status: domain.ActionProposed})
	}
	return out, errs
}

func (f *fakeActs) Confirm(_ context.Context, user int64, id string) (domain.AssistantAction, error) {
	if user != f.user {
		return domain.AssistantAction{}, domain.ErrNotFound
	}
	return domain.AssistantAction{ID: id, MessageID: f.msg, ConversationID: 1, Tool: id, Status: domain.ActionDone, Result: "PAY-214 is now pushing."}, nil
}

func (f *fakeActs) Cancel(_ context.Context, _ int64, id string) (domain.AssistantAction, error) {
	return domain.AssistantAction{ID: id, Status: domain.ActionCancelled}, nil
}

func TestAssistantProposesActions(t *testing.T) {
	a := newAssistantHarness(t)
	acts := &fakeActs{}
	a.o.SetAssistantActions(acts)
	a.answers(2, `{"answer":"PAY-214 passed review. Confirm to approve it.","actions":[{"tool":"approve_ticket","args":{"key":"PAY-214"}},{"tool":"bad"}]}`)
	c, err := a.o.Ask(a.ask, 0, "Approve PAY-214", "en")
	if err != nil {
		t.Fatal(err)
	}
	ans := a.conversation(c.ID).Messages[1]
	if acts.user != a.user || acts.msg != ans.ID || len(acts.got) != 2 || string(acts.got[0].Args) != `{"key":"PAY-214"}` {
		t.Fatalf("proposed %+v for %d/%d", acts.got, acts.user, acts.msg)
	}
	if strings.Join(ans.ActionErrors, ";") != "bad: unknown action" {
		t.Fatalf("action errors = %v", ans.ActionErrors)
	}
	if p := a.runner.prompts[0]; !strings.Contains(p, "- approve_ticket {") || !strings.Contains(p, "propose it in \"actions\"") {
		t.Fatalf("prompt lacks the actions: %s", p)
	}

	got, err := a.o.ConfirmAssistantAction(a.ask, " approve_ticket ")
	if err != nil || got.Status != domain.ActionDone {
		t.Fatalf("confirm = %+v, %v", got, err)
	}
	if _, err := a.o.ConfirmAssistantAction(a.other, "approve_ticket"); !errors.Is(err, domain.ErrNotFound) {
		t.Fatalf("someone else confirmed: %v", err)
	}
	if last := a.live.got[len(a.live.got)-1]; last != orchestrator.EventAssistantAction {
		t.Fatalf("events = %v", a.live.got)
	}
}

func TestAssistantWithoutActionsSaysSo(t *testing.T) {
	a := newAssistantHarness(t)
	a.answers(2, `{"answer":"Confirm to approve.","actions":[{"tool":"approve_ticket","args":{"key":"PAY-214"}}]}`)
	c, err := a.o.Ask(a.ask, 0, "Approve PAY-214", "en")
	if err != nil {
		t.Fatal(err)
	}
	ans := a.conversation(c.ID).Messages[1]
	if ans.Status != domain.AssistantDone || len(ans.Actions) != 0 || len(ans.ActionErrors) != 1 {
		t.Fatalf("answer = %+v", ans)
	}
	if _, err := a.o.ConfirmAssistantAction(a.ask, "x"); !errors.Is(err, orchestrator.ErrInvalid) {
		t.Fatalf("confirm without actions: %v", err)
	}
}

func TestAssistantCaseReplaysProposeButStoreNothing(t *testing.T) {
	a := newAssistantHarness(t)
	a.o.SetAssistantActions(&fakeActs{})
	cs, err := orchestrator.AssistantCases()
	if err != nil {
		t.Fatal(err)
	}
	c := cs[0] // approve PAY-214
	a.answers(0, `{"answer":"PAY-214 passed review. Confirm to approve it.","actions":[{"tool":"approve_ticket","args":{"key":"PAY-214"}}]}`)
	ans, _, err := a.o.ReplayAnswer(a.ctx, c.Snapshot(), c.Lang, 0)
	if err != nil {
		t.Fatal(err)
	}
	if problems := orchestrator.CheckProposals(ans.Actions, c.Want); problems != nil {
		t.Fatalf("problems: %v", problems)
	}
	if me := a.runner.written[orchestrator.AssistantDir(0)+"/me.json"]; !strings.Contains(me, `"can_act": true`) {
		t.Fatalf("me.json = %q", me)
	}
	var n int
	if err := a.db.QueryRow(a.ctx, `SELECT count(*) FROM pending_actions WHERE origin = 'assistant'`).Scan(&n); err != nil || n != 0 {
		t.Fatalf("a replay stored %d actions (%v)", n, err)
	}
}

func TestAssistantKeepsItsTextWhenItRunsOutOfTurns(t *testing.T) {
	a := newAssistantHarness(t)
	// It replied with the answer, then hit the turn limit before writing the file.
	a.runner.scripts = append(a.runner.scripts, script{result: ai.Result{SessionID: "s", Turns: 16, Subtype: "error_max_turns", IsError: true,
		Text: "Сегодня закрыто 6 задач: 5 готовы, 1 отклонена."}})
	c, err := a.o.Ask(a.ask, 0, "Что сделано сегодня?", "en")
	if err != nil {
		t.Fatal(err)
	}
	got := a.conversation(c.ID)
	last := got.Messages[len(got.Messages)-1]
	if last.Role != domain.AssistantReply || last.Status != domain.AssistantDone || last.Text != "Сегодня закрыто 6 задач: 5 готовы, 1 отклонена." {
		t.Fatalf("answer = %+v", last)
	}
	if a.reqs[0].MaxTurns < 12 {
		t.Fatalf("max turns %d", a.reqs[0].MaxTurns)
	}
}
