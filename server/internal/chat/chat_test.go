package chat

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"log/slog"
	"strings"
	"sync"
	"testing"

	"github.com/jackc/pgx/v5/pgxpool"

	"agnts/internal/actions"
	"agnts/internal/domain"
	"agnts/internal/orchestrator"
	"agnts/internal/store/postgres"
	"agnts/internal/store/postgres/pgtest"
	"agnts/internal/vcs"
)

// ---------------------------------------------------------------------
// Fakes

type fakeTickets struct {
	mu     sync.Mutex
	views  map[string]orchestrator.TicketView
	merged []string
	err    error
}

func (f *fakeTickets) View(_ context.Context, key string) (orchestrator.TicketView, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	v, ok := f.views[key]
	if !ok {
		return v, domain.ErrNotFound
	}
	return v, nil
}

func (f *fakeTickets) MergeTicketPR(_ context.Context, key string, origin domain.Origin) (domain.Ticket, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	if f.err != nil {
		return domain.Ticket{}, f.err
	}
	if origin != domain.OriginChat {
		return domain.Ticket{}, errors.New("origin must be chat")
	}
	f.merged = append(f.merged, key)
	return f.views[key].Ticket, nil
}

type fakeActions struct {
	mu   sync.Mutex
	done []postgres.PendingAction
}

func (f *fakeActions) Prepare(_ context.Context, tool string, args json.RawMessage) (actions.Prepared, error) {
	var a map[string]any
	_ = json.Unmarshal(args, &a)
	key, _ := a["key"].(string)
	return actions.Prepared{Tool: tool, TicketKey: key, Summary: "do " + tool + " " + key, Args: a}, nil
}

func (f *fakeActions) Execute(_ context.Context, a postgres.PendingAction, origin domain.Origin) (actions.Result, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	if origin != domain.OriginChat {
		return actions.Result{}, errors.New("origin must be chat")
	}
	f.done = append(f.done, a)
	t := domain.Ticket{Key: a.TicketKey}
	if a.Tool == actions.CreateTask {
		t.Key = "NEW-1"
	}
	return actions.Result{Done: a.Summary, Ticket: &t}, nil
}

type fakeChecks struct{ state string }

func (f fakeChecks) CommitChecks(context.Context, domain.Repository, string) (string, []string, error) {
	if f.state == vcs.CIFail {
		return f.state, []string{"lint"}, nil
	}
	return f.state, nil, nil
}

type fakeRepos struct{}

func (fakeRepos) RepositoryByID(_ context.Context, id int64) (domain.Repository, error) {
	return domain.Repository{ID: id, Name: "api"}, nil
}

type fakeBrain struct {
	mu      sync.Mutex
	replies map[string]string // kind → the model's text
	prompts map[string]string
	code    orchestrator.ChatCodeResult
}

func (f *fakeBrain) ChatModel(_ context.Context, c orchestrator.ChatModelCall) (orchestrator.ChatModelResult, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	if f.prompts == nil {
		f.prompts = map[string]string{}
	}
	f.prompts[c.Kind] = c.Prompt
	return orchestrator.ChatModelResult{Text: f.replies[c.Kind], AI: domain.ChatAI{Provider: "muse", Model: "muse-spark", MS: 1200}}, nil
}

func (f *fakeBrain) ChatCode(_ context.Context, c orchestrator.ChatCodeCall) (orchestrator.ChatCodeResult, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	f.prompts["code"] = c.Prompt
	return f.code, nil
}

func (f *fakeBrain) RepoBrief(context.Context, int64) (domain.RepoBrief, error) {
	return domain.RepoBrief{Body: "api is a Go service; auth lives in internal/auth."}, nil
}

type fakeLive struct{ n int }

func (f *fakeLive) PublishWorkspace(int64, domain.Event) { f.n++ }

// ---------------------------------------------------------------------

type harness struct {
	s       *Service
	pool    *pgxpool.Pool
	store   *postgres.Chat
	tickets *fakeTickets
	acts    *fakeActions
	brain   *fakeBrain
	ctx     context.Context
	ws      int64
	ann     int64
}

func newHarness(t *testing.T) *harness {
	pool := pgtest.Open(t)
	slug := strings.ToLower(strings.ReplaceAll(t.Name(), "/", "-"))
	ctx, ws := pgtest.Workspace(t, pool, "chat-"+slug)
	ann := pgtest.User(t, pool, "ann-"+slug)
	pgtest.Exec(t, pool, `DELETE FROM chat_channels WHERE workspace_id = $1`, ws)
	pgtest.Exec(t, pool, `DELETE FROM chat_jobs`)
	ctx = domain.WithActor(ctx, domain.Actor{UserID: ann, Username: "ann"})
	store := postgres.NewChat(pool)
	h := &harness{pool: pool, store: store, tickets: &fakeTickets{views: map[string]orchestrator.TicketView{}}, acts: &fakeActions{},
		brain: &fakeBrain{replies: map[string]string{}}, ctx: ctx, ws: ws, ann: ann}
	h.s = New(Deps{Store: store, Memory: store, Tickets: h.tickets, Actions: h.acts, Repos: fakeRepos{}, Checks: fakeChecks{state: vcs.CIFail},
		Live: &fakeLive{}, Brain: h.brain, Log: slog.New(slog.NewTextHandler(io.Discard, nil))})
	return h
}

func (h *harness) view(key string, state domain.TicketState, rev int) {
	pr := 14
	h.tickets.views[key] = orchestrator.TicketView{RepoName: "api",
		Ticket: domain.Ticket{Key: key, Title: "Fix refund rounding", State: state, Revision: rev, Kind: domain.KindCode,
			Repos: []domain.TicketRepo{{RepoID: 1, RepoName: "api", HeadSHA: "abc", PRNumber: &pr, PRURL: "https://github.com/a/api/pull/14"}}},
		Result: &domain.Result{Files: []domain.FileChange{{Path: "refund.go", Add: 10, Del: 2}}, Summary: json.RawMessage(`{"summary":"Round half up"}`)},
		Spend:  domain.TokenUsage{CostUSD: 0.31}}
}

func (h *harness) agentMessages(t *testing.T) []domain.ChatMessage {
	t.Helper()
	ch, err := h.store.AgentChannel(h.ctx)
	if err != nil {
		t.Fatal(err)
	}
	ms, err := h.store.Messages(h.ctx, ch.ID, 0, 0, 100)
	if err != nil {
		t.Fatal(err)
	}
	return ms
}

func (h *harness) event(typ, key string, data map[string]any, user string) {
	h.s.onEvent(domain.System(context.Background()), domain.Event{ID: 1, WorkspaceID: h.ws, Type: typ, TicketKey: key, Data: data, Username: user})
}

func TestCardsFollowTheTicket(t *testing.T) {
	h := newHarness(t)
	h.view("PAY-1", domain.StateWaitingForReview, 1)

	// Waiting for review: one card, not two for the same revision.
	h.event(domain.EventStateChanged, "PAY-1", map[string]any{"to": "waiting_for_review"}, "")
	h.event(domain.EventStateChanged, "PAY-1", map[string]any{"to": "waiting_for_review"}, "")
	ms := h.agentMessages(t)
	if len(ms) != 1 || ms[0].Card == nil || ms[0].Card.Type != domain.CardReviewReady || ms[0].TicketKey != "PAY-1" {
		t.Fatalf("review card %+v", ms)
	}
	review := ms[0]
	if review.Card.Data["files"].(float64) != 1 || review.Card.Data["costUsd"].(float64) != 0.31 || !strings.Contains(review.Card.Summary, "Round half up") {
		t.Fatalf("review card data %+v %q", review.Card.Data, review.Card.Summary)
	}

	// A button the card does not have, then Approve, then a second press.
	if _, err := h.s.Act(h.ctx, review.ID, ActInput{Action: domain.CardMerge}); !errors.Is(err, ErrInvalid) {
		t.Fatalf("merge on a review card: %v", err)
	}
	got, err := h.s.Act(h.ctx, review.ID, ActInput{Action: domain.CardApprove})
	if err != nil || got.Card.State != domain.CardDone || got.Card.By != "ann" {
		t.Fatalf("approve %v %+v", err, got.Card)
	}
	if len(h.acts.done) != 1 || h.acts.done[0].Tool != actions.ApproveTicket || h.acts.done[0].TicketKey != "PAY-1" {
		t.Fatalf("actions run %+v", h.acts.done)
	}
	if _, err := h.s.Act(h.ctx, review.ID, ActInput{Action: domain.CardApprove}); !errors.Is(err, ErrSettled) || !strings.Contains(err.Error(), "approved by ann") {
		t.Fatalf("second press: %v", err)
	}

	// The PR opens: a card with CI's state and Merge.
	h.view("PAY-1", domain.StateDone, 1)
	h.event(domain.EventPROpened, "PAY-1", map[string]any{"number": float64(14), "url": "https://github.com/a/api/pull/14", "repoId": float64(1)}, "")
	h.event(domain.EventPROpened, "PAY-1", map[string]any{"number": float64(14), "url": "https://github.com/a/api/pull/14", "repoId": float64(1)}, "")
	ms = h.agentMessages(t)
	if len(ms) != 2 || ms[1].Card.Type != domain.CardPROpened || ms[1].Card.Data["ci"] != vcs.CIFail {
		t.Fatalf("pr card %+v", ms[1:])
	}
	pr := ms[1]
	if pr.Refs[len(pr.Refs)-1].ID != "api#14" && pr.Refs[0].ID != "api#14" {
		t.Fatalf("pr refs %+v", pr.Refs)
	}

	// A refused merge keeps the card open and says why.
	h.tickets.err = fmt.Errorf("%w: not merged: new commits were pushed", orchestrator.ErrInvalid)
	if _, err := h.s.Act(h.ctx, pr.ID, ActInput{Action: domain.CardMerge}); !errors.Is(err, ErrInvalid) {
		t.Fatalf("refused merge: %v", err)
	}
	if m, _ := h.store.Message(h.ctx, pr.ID); m.Card.State != domain.CardOpen || !strings.Contains(m.Card.Result, "new commits") {
		t.Fatalf("card after a refused merge %+v", m.Card)
	}
	h.tickets.err = nil
	if _, err := h.s.Act(h.ctx, pr.ID, ActInput{Action: domain.CardMerge}); err != nil || len(h.tickets.merged) != 1 {
		t.Fatalf("merge %v %v", err, h.tickets.merged)
	}

	// The merge event says so in the channel.
	h.event(domain.EventMerged, "PAY-1", map[string]any{"url": "https://github.com/a/api/pull/14"}, "ann")
	ms = h.agentMessages(t)
	last := ms[len(ms)-1]
	if last.Kind != domain.ChatKindAgent || !strings.Contains(last.Body, "Merged ✅ #14") || !strings.Contains(last.Body, "by ann") {
		t.Fatalf("merged note %+v", last)
	}
}

func TestReviewCardExpiresWhenTheTicketMovesOn(t *testing.T) {
	h := newHarness(t)
	h.view("PAY-2", domain.StateWaitingForReview, 1)
	h.event(domain.EventStateChanged, "PAY-2", map[string]any{"to": "waiting_for_review"}, "")
	h.event(domain.EventStateChanged, "PAY-2", map[string]any{"to": "rejected"}, "bob")
	ms := h.agentMessages(t)
	if ms[0].Card.State != domain.CardExpired || !strings.Contains(ms[0].Card.Result, "rejected (bob)") {
		t.Fatalf("expired card %+v", ms[0].Card)
	}
	if _, err := h.s.Act(h.ctx, ms[0].ID, ActInput{Action: domain.CardApprove}); !errors.Is(err, ErrSettled) {
		t.Fatalf("approve an expired card: %v", err)
	}
}

func (h *harness) send(t *testing.T, ch int64, body string) domain.ChatMessage {
	t.Helper()
	m, created, err := h.s.Send(h.ctx, domain.ChatSend{ChannelID: ch, ClientMsgID: newUUID(), Body: body})
	if err != nil || !created {
		t.Fatalf("send %v %v", err, created)
	}
	return m
}

var uuidSeq int

func newUUID() string {
	uuidSeq++
	return fmt.Sprintf("10000000-0000-4000-8000-%012d", uuidSeq)
}

func (h *harness) runJobs(t *testing.T) {
	t.Helper()
	sys := domain.System(context.Background())
	for range 10 {
		j, ok, err := h.store.TakeJob(sys)
		if err != nil {
			t.Fatal(err)
		}
		if !ok {
			return
		}
		h.s.runJob(sys, j)
	}
}

func TestSendValidates(t *testing.T) {
	h := newHarness(t)
	cs, _ := h.s.Channels(h.ctx)
	if _, _, err := h.s.Send(h.ctx, domain.ChatSend{ChannelID: cs[0].ID, ClientMsgID: "nope", Body: "hi"}); !errors.Is(err, ErrInvalid) {
		t.Fatalf("bad client id: %v", err)
	}
	if _, _, err := h.s.Send(h.ctx, domain.ChatSend{ChannelID: cs[0].ID, ClientMsgID: newUUID(), Body: "   "}); !errors.Is(err, ErrInvalid) {
		t.Fatalf("empty body: %v", err)
	}
	if _, err := h.s.CreateChannel(h.ctx, "#Payments Team", "", false); err != nil {
		t.Fatal(err)
	}
	if _, err := h.s.UpdateChannel(h.ctx, cs[0].ID, nil, nil, true); !errors.Is(err, ErrInvalid) {
		t.Fatalf("archive agnts's channel: %v", err)
	}
}

func TestAnswerCitesOnlyWhatItWasGiven(t *testing.T) {
	h := newHarness(t)
	cs, _ := h.s.Channels(h.ctx)
	ch := cs[0].ID
	said := h.send(t, ch, "the CSV export on payments times out for big merchants")
	h.runJobs(t)
	h.brain.replies["answer"] = fmt.Sprintf(`Sure: {"answer_md": "Bo reported export timeouts [msg:%d] and it was fixed in [ticket:FAKE-9].", "citations": ["msg:%d"], "insufficient": false, "needs_code": null}`, said.ID, said.ID)
	q := h.send(t, ch, "@agnts why does the CSV export time out?")
	h.runJobs(t)
	ms, _ := h.store.Messages(h.ctx, ch, 0, 0, 50)
	a := ms[len(ms)-1]
	if a.Kind != domain.ChatKindAgent || a.ReplyTo == nil || *a.ReplyTo != q.ID || a.AI == nil || a.AI.MS != 1200 {
		t.Fatalf("answer %+v", a)
	}
	if !strings.Contains(a.Body, fmt.Sprintf("[msg:%d]", said.ID)) || strings.Contains(a.Body, "FAKE-9") {
		t.Fatalf("citations not checked: %q", a.Body)
	}
	if p := h.brain.prompts["answer"]; !strings.Contains(p, fmt.Sprintf("[msg:%d]", said.ID)) || !strings.Contains(p, "big merchants") {
		t.Fatalf("the answer's context lacks the message:\n%s", p)
	}

	// No valid citation and not admitted: the honest reply instead.
	h.brain.replies["answer"] = `{"answer_md": "It is fixed in [ticket:NOPE-1].", "citations": [], "insufficient": false}`
	h.send(t, ch, "@agnts who fixed it?")
	h.runJobs(t)
	ms, _ = h.store.Messages(h.ctx, ch, 0, 0, 50)
	if b := ms[len(ms)-1].Body; b != noAnswer {
		t.Fatalf("uncited answer posted: %q", b)
	}
}

func (h *harness) repo(t *testing.T, name string) int64 {
	t.Helper()
	r, err := postgres.NewAgent(h.pool).SaveRepository(h.ctx, domain.Repository{Name: name, Kind: "side", Provider: "github",
		CloneURL: "https://github.com/acme/" + name + ".git", DefaultBranch: "main"})
	if err != nil {
		t.Fatal(err)
	}
	return r.ID
}

func TestCodeQuestion(t *testing.T) {
	h := newHarness(t)
	id := h.repo(t, "gateway")
	cs, _ := h.s.Channels(h.ctx)
	ch := cs[0].ID
	h.brain.replies["answer"] = `{"answer_md": "The brief does not say.", "citations": [], "insufficient": true, "needs_code": "gateway"}`
	h.brain.code = orchestrator.ChatCodeResult{Text: "JWTs are verified with RS256 [file:internal/auth/jwt.go:42], see [repo:gateway].",
		SHA: "cafe", Repo: domain.Repository{ID: id, CloneURL: "https://github.com/acme/gateway.git", Provider: "github"},
		Lines: map[string]int{"internal/auth/jwt.go": 80}, AI: domain.ChatAI{Provider: "muse", MS: 41000}}
	q := h.send(t, ch, "@agnts how is auth implemented on gateway?")
	h.runJobs(t)
	ms, _ := h.store.Messages(h.ctx, ch, 0, 0, 50)
	a := ms[len(ms)-1]
	if a.ReplyTo == nil || *a.ReplyTo != q.ID || a.AI == nil || a.AI.MS != 41000 {
		t.Fatalf("code answer %+v", a)
	}
	if !strings.Contains(a.Body, "https://github.com/acme/gateway/blob/cafe/internal/auth/jwt.go#L42") || !strings.Contains(a.Body, "[repo:gateway]") ||
		strings.Contains(a.Body, "Looking at") {
		t.Fatalf("code answer body %q", a.Body)
	}
	if !strings.Contains(h.brain.prompts["code"], "auth lives in internal/auth") {
		t.Fatalf("the code prompt lacks the brief:\n%s", h.brain.prompts["code"])
	}
}

func TestDraftToTicket(t *testing.T) {
	h := newHarness(t)
	id := h.repo(t, "billing")
	cs, _ := h.s.Channels(h.ctx)
	m := h.send(t, cs[0].ID, "refunds round down to the cent, they should round half up")
	h.brain.replies["ticket"] = `{"title": "Round refunds half up", "description": "Refunds lose a cent.", "acceptance_criteria": ["0.005 rounds to 0.01"], "repo": "billing", "kind": "bug"}`
	if err := h.s.ToTicket(h.ctx, m.ID); err != nil {
		t.Fatal(err)
	}
	h.runJobs(t)
	ms, _ := h.store.Messages(h.ctx, cs[0].ID, 0, 0, 50)
	d := ms[len(ms)-1]
	if d.Card == nil || d.Card.Type != domain.CardTicketDraft || d.Card.Data["repoId"].(float64) != float64(id) || d.AI == nil {
		t.Fatalf("draft %+v", d)
	}
	got, err := h.s.Act(h.ctx, d.ID, ActInput{Action: domain.CardCreateAssign, Draft: &DraftEdit{Title: "Round refunds half up, everywhere"}})
	if err != nil || got.Card.State != domain.CardDone || got.TicketKey != "NEW-1" {
		t.Fatalf("create %v %+v", err, got)
	}
	a := h.acts.done[len(h.acts.done)-1]
	if a.Tool != actions.CreateTask || a.Args["start"] != "code" || a.Args["repository"] != "billing" ||
		a.Args["title"] != "Round refunds half up, everywhere" || !strings.Contains(a.Args["description"].(string), "0.005 rounds to 0.01") {
		t.Fatalf("create task %+v", a.Args)
	}
}

func TestLinkPicksOnlyCandidates(t *testing.T) {
	cands := []postgres.ChatCandidate{{Type: "ticket", ID: "PAY-214", Title: "Payments CSV export"}, {Type: "repo", ID: "api", Title: "api"}}
	text := "```json\n" + `[{"ref_type":"ticket","ref_id":"PAY-214","confidence":0.92,"reason":"mentions the CSV export"},
		{"ref_type":"ticket","ref_id":"PAY-999","confidence":0.99,"reason":"made up"},
		{"ref_type":"repo","ref_id":"api","confidence":0.5,"reason":"weak"}]` + "\n```"
	refs := pickLinks(text, cands, domain.ChatAI{MS: 900})
	if len(refs) != 1 || refs[0].ID != "PAY-214" || refs[0].Source != domain.RefModel || refs[0].Label != "Payments CSV export" || refs[0].AI.MS != 900 {
		t.Fatalf("links %+v", refs)
	}
	if refs := pickLinks("I think PAY-214", cands, domain.ChatAI{}); refs != nil {
		t.Fatalf("prose is not links: %+v", refs)
	}
}

func TestLinkFiles(t *testing.T) {
	repo := domain.Repository{CloneURL: "git@github.com:acme/api.git", Provider: "github"}
	body := "Tokens are checked in [file:internal/auth/jwt.go:42] and [file:internal/auth/jwt.go:900] and [file:made/up.go:3]."
	got := linkFiles(body, repo, "deadbeef", map[string]int{"internal/auth/jwt.go": 120})
	want := "Tokens are checked in [`internal/auth/jwt.go:42`](https://github.com/acme/api/blob/deadbeef/internal/auth/jwt.go#L42) and " +
		"[`internal/auth/jwt.go`](https://github.com/acme/api/blob/deadbeef/internal/auth/jwt.go) and ."
	if got != want {
		t.Fatalf("got  %s\nwant %s", got, want)
	}
	if u := webURL(domain.Repository{CloneURL: "https://x-token:secret@gitlab.com/g/p.git"}); u != "https://gitlab.com/g/p" {
		t.Fatalf("web url %q", u)
	}
}
