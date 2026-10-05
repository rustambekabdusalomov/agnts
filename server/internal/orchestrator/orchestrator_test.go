package orchestrator_test

import (
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"io"
	"log/slog"
	"os"
	"slices"
	"strings"
	"sync"
	"testing"
	"time"

	"hiro/internal/domain"
	"hiro/internal/orchestrator"
	"hiro/internal/store/postgres"
)

// ---- fakes ----

// script is what the fake Claude does on each invocation, in order.
type script struct {
	result orchestrator.ClaudeResult
	files  map[string]string // files it writes (e.g. analysis.json)
	edit   string            // marker written to the repo, so Commit sees a change
	err    error
}

type fakeRunner struct {
	mu       sync.Mutex
	scripts  []script
	prompts  []string
	resumes  []string
	execs    map[string][]orchestrator.ExecResult // command -> results in order
	opened   int
	closed   int
	lastHome []byte
	onClaude func(orchestrator.ClaudeRequest)
}

func (f *fakeRunner) Open(_ context.Context, spec orchestrator.WorkspaceSpec) (orchestrator.Workspace, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	f.opened++
	f.lastHome = spec.ClaudeHome
	_, _ = io.Copy(io.Discard, spec.Repo)
	return &fakeWS{r: f, files: map[string]string{}}, nil
}

type fakeWS struct {
	r     *fakeRunner
	files map[string]string
	edits []string
}

func (w *fakeWS) ID() string { return "ctr-1" }

func (w *fakeWS) Claude(_ context.Context, req orchestrator.ClaudeRequest, on func(orchestrator.ClaudeEvent)) (orchestrator.ClaudeResult, error) {
	w.r.mu.Lock()
	defer w.r.mu.Unlock()
	w.r.prompts = append(w.r.prompts, req.Prompt)
	if w.r.onClaude != nil {
		w.r.onClaude(req)
	}
	w.r.resumes = append(w.r.resumes, req.Resume)
	if len(w.r.scripts) == 0 {
		return orchestrator.ClaudeResult{}, errors.New("unexpected claude call")
	}
	s := w.r.scripts[0]
	w.r.scripts = w.r.scripts[1:]
	on(orchestrator.ClaudeEvent{Kind: orchestrator.ClaudeInit, Data: map[string]any{"session_id": s.result.SessionID}})
	on(orchestrator.ClaudeEvent{Kind: orchestrator.ClaudeTool, Tool: "Read: main.go"})
	for k, v := range s.files {
		w.files[k] = v
	}
	if s.edit != "" {
		w.edits = append(w.edits, s.edit)
	}
	return s.result, s.err
}

func (w *fakeWS) Exec(_ context.Context, cmd string, _ time.Duration) (orchestrator.ExecResult, error) {
	w.r.mu.Lock()
	defer w.r.mu.Unlock()
	rs := w.r.execs[cmd]
	if len(rs) == 0 {
		return orchestrator.ExecResult{ExitCode: 0, Output: "ok"}, nil
	}
	w.r.execs[cmd] = rs[1:]
	return rs[0], nil
}

func (w *fakeWS) ReadFile(_ context.Context, p string) ([]byte, error) {
	if v, ok := w.files[p]; ok {
		return []byte(v), nil
	}
	return nil, domain.ErrNotFound
}

func (w *fakeWS) WriteFile(_ context.Context, p string, data []byte) error {
	w.files[p] = string(data)
	return nil
}

func (w *fakeWS) ExportRepo(context.Context) (io.ReadCloser, error) {
	return io.NopCloser(strings.NewReader(strings.Join(w.edits, "\n"))), nil
}

func (w *fakeWS) ExportClaudeHome(context.Context) ([]byte, error) { return []byte("home"), nil }

func (w *fakeWS) Close(context.Context) error {
	w.r.mu.Lock()
	w.r.closed++
	w.r.mu.Unlock()
	return nil
}

type fakeGit struct {
	mu      sync.Mutex
	commits int
	pushed  []string
}

func (g *fakeGit) Prepare(context.Context, domain.Repository, string) error { return nil }
func (g *fakeGit) Archive(context.Context, domain.Repository, string) (io.ReadCloser, error) {
	return io.NopCloser(bytes.NewReader(nil)), nil
}

func (g *fakeGit) Commit(_ context.Context, _ domain.Repository, _ string, tree io.Reader, _ string) (string, []domain.FileChange, error) {
	b, _ := io.ReadAll(tree)
	if len(b) == 0 {
		return "base", nil, nil
	}
	g.mu.Lock()
	defer g.mu.Unlock()
	g.commits++
	return "sha" + string(rune('0'+g.commits)), []domain.FileChange{{Path: "main.go", Add: 3, Del: 1, Diff: "+fix"}}, nil
}

func (g *fakeGit) PushTo(_ context.Context, _ domain.Repository, branch, target string) error {
	g.mu.Lock()
	defer g.mu.Unlock()
	g.pushed = append(g.pushed, branch+"->"+target)
	return nil
}

func (g *fakeGit) Push(_ context.Context, _ domain.Repository, branch string) error {
	g.mu.Lock()
	defer g.mu.Unlock()
	g.pushed = append(g.pushed, branch)
	return nil
}

type fakeHost struct {
	opened   int
	last     orchestrator.PR
	assigned map[int][]string
}

func (h *fakeHost) Assign(_ context.Context, _ domain.Repository, number int, usernames []string) error {
	if h.assigned == nil {
		h.assigned = map[int][]string{}
	}
	h.assigned[number] = usernames
	return nil
}

func (h *fakeHost) OpenPR(_ context.Context, _ domain.Repository, pr orchestrator.PR) (int, string, error) {
	h.opened++
	h.last = pr
	return 7, "https://github.com/acme/api/pull/7", nil
}

type fakeTracker struct {
	mu       sync.Mutex
	comments []string
	moves    []orchestrator.TrackerStatus
}

func (t *fakeTracker) Comment(_ context.Context, _ string, _ orchestrator.CommentKind, text string) (bool, error) {
	t.mu.Lock()
	defer t.mu.Unlock()
	t.comments = append(t.comments, text)
	return true, nil
}

// settings and usage fakes
type fakeSettings struct{ s domain.Settings }

func (f *fakeSettings) Get(context.Context) (domain.Settings, error) { return f.s, nil }

type fakeUsage struct {
	mu      sync.Mutex
	paused  bool
	records int
}

func (f *fakeUsage) Paused(context.Context, domain.Settings) (bool, time.Time) {
	f.mu.Lock()
	defer f.mu.Unlock()
	return f.paused, time.Time{}
}

func (f *fakeUsage) Record(context.Context, map[string]any) {
	f.mu.Lock()
	f.records++
	f.mu.Unlock()
}

func (f *fakeUsage) RecordLimited(context.Context) {
	f.mu.Lock()
	f.paused = true
	f.mu.Unlock()
}

func (t *fakeTracker) MoveTo(_ context.Context, _ string, s orchestrator.TrackerStatus) error {
	t.mu.Lock()
	defer t.mu.Unlock()
	t.moves = append(t.moves, s)
	return nil
}

type memHomes struct{ m sync.Map }

func (h *memHomes) Load(k string) ([]byte, error) {
	if v, ok := h.m.Load(k); ok {
		return v.([]byte), nil
	}
	return nil, nil
}
func (h *memHomes) Save(k string, b []byte) error { h.m.Store(k, b); return nil }

// ---- harness ----

type harness struct {
	t        *testing.T
	ctx      context.Context
	store    *postgres.Agent
	o        *orchestrator.Orchestrator
	runner   *fakeRunner
	git      *fakeGit
	host     *fakeHost
	tracker  *fakeTracker
	settings *fakeSettings
	usage    *fakeUsage
}

func newHarness(t *testing.T) *harness {
	t.Helper()
	url := os.Getenv("HIRO_TEST_DATABASE_URL")
	if url == "" {
		t.Skip("HIRO_TEST_DATABASE_URL not set")
	}
	ctx := context.Background()
	pool, err := postgres.Open(ctx, url)
	if err != nil {
		t.Fatal(err)
	}
	t.Cleanup(pool.Close)
	log := slog.New(slog.NewTextHandler(io.Discard, nil))
	if err := postgres.Migrate(ctx, pool, "up", log); err != nil {
		t.Fatal(err)
	}
	if _, err := pool.Exec(ctx, `TRUNCATE tickets, runs, results, questions, events, repositories, webhook_deliveries RESTART IDENTITY CASCADE`); err != nil {
		t.Fatal(err)
	}
	store := postgres.NewAgent(pool)
	if _, err := store.SaveRepository(ctx, domain.Repository{
		Name: "api", Kind: "jira", Provider: "github", CloneURL: "https://github.com/acme/api.git",
		DefaultBranch: "main", TestCmd: "go test ./...", JiraProject: "PAY",
	}); err != nil {
		t.Fatal(err)
	}
	h := &harness{t: t, ctx: ctx, store: store,
		runner: &fakeRunner{execs: map[string][]orchestrator.ExecResult{}}, git: &fakeGit{}, host: &fakeHost{}, tracker: &fakeTracker{}}
	cfg := orchestrator.DefaultConfig()
	cfg.FixAttempts = 1
	h.settings = &fakeSettings{s: domain.DefaultSettings()}
	h.settings.s.Git.AuthorName, h.settings.s.Git.AuthorEmail = "Rustam", "r@example.com"
	h.usage = &fakeUsage{}
	h.o = orchestrator.New(cfg, orchestrator.Deps{
		Store: store, Runner: h.runner, Git: h.git, Host: h.host, Tracker: h.tracker, Homes: &memHomes{},
		Settings: h.settings, Usage: h.usage,
	}, log)
	return h
}

func (h *harness) ingest(key string) {
	h.t.Helper()
	created, err := h.o.Ingest(h.ctx, orchestrator.Incoming{Key: key, Project: "PAY", Title: "Fix refund rounding", Description: "Round half up."}, domain.OriginWebhook)
	if err != nil || !created {
		h.t.Fatalf("ingest: %v %v", created, err)
	}
}

func (h *harness) step() {
	h.t.Helper()
	ok, err := h.o.RunOnce(h.ctx)
	if err != nil || !ok {
		h.t.Fatalf("RunOnce: ok=%v err=%v", ok, err)
	}
}

func (h *harness) idle() {
	h.t.Helper()
	if ok, err := h.o.RunOnce(h.ctx); err != nil || ok {
		h.t.Fatalf("expected no work: ok=%v err=%v", ok, err)
	}
}

func (h *harness) state(key string) domain.Ticket {
	h.t.Helper()
	tk, err := h.store.TicketByKey(h.ctx, key)
	if err != nil {
		h.t.Fatal(err)
	}
	return tk
}

func (h *harness) expect(key string, want domain.TicketState) domain.Ticket {
	h.t.Helper()
	tk := h.state(key)
	if tk.State != want {
		evs, _ := h.store.Events(h.ctx, orchestrator.EventFilter{TicketKey: key})
		var lines []string
		for _, e := range evs {
			lines = append(lines, e.Type+": "+e.Message)
		}
		h.t.Fatalf("%s is %s, want %s\nevents:\n%s", key, tk.State, want, strings.Join(lines, "\n"))
	}
	return tk
}

func analysis(questions int) string {
	a := map[string]any{"summary": "Refund amounts are truncated in refund.go.", "plan": []string{"Use math.Round", "Add a test"}, "questions": []any{}}
	qs := []any{}
	for i := 0; i < questions; i++ {
		qs = append(qs, map[string]any{"text": "Which rounding mode?", "options": []string{"half up", "banker's"}})
	}
	a["questions"] = qs
	b, _ := json.Marshal(a)
	return string(b)
}

func ok(session string) orchestrator.ClaudeResult {
	return orchestrator.ClaudeResult{SessionID: session, Turns: 5, Subtype: "success", Text: "done"}
}

// ---- tests ----

func TestHappyPathWithQuestions(t *testing.T) {
	h := newHarness(t)
	h.ingest("PAY-1")
	h.runner.scripts = []script{
		{result: ok("s1"), files: map[string]string{orchestrator.AnalysisPath: analysis(1)}},
		{result: ok("s1"), edit: "fix", files: map[string]string{orchestrator.SummaryPath: `{"summary":"Rounds half up now.","notes":["check currency"]}`}},
	}

	h.step() // analyze
	h.expect("PAY-1", domain.StateWaitingForAnswers)
	h.idle() // waiting for a human: nothing to claim

	v, err := h.o.View(h.ctx, "PAY-1")
	if err != nil || len(v.Questions) != 1 || v.Analysis == nil || len(v.Analysis.Plan) != 2 {
		t.Fatalf("view: %+v %v", v, err)
	}
	if _, err := h.o.Answer(h.ctx, "PAY-1", nil, domain.OriginWeb); !errors.Is(err, orchestrator.ErrInvalid) {
		t.Fatalf("missing answers accepted: %v", err)
	}
	if _, err := h.o.Answer(h.ctx, "PAY-1", []domain.Answer{{QuestionID: v.Questions[0].ID, Answer: "half up"}}, domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	h.expect("PAY-1", domain.StateCoding)

	h.step() // code + checks
	tk := h.expect("PAY-1", domain.StateWaitingForReview)
	if tk.Branch != "hiro/PAY-1" || tk.HeadSHA == "" || tk.Turns == 0 {
		t.Fatalf("ticket after coding: %+v", tk)
	}
	if !strings.Contains(h.runner.prompts[1], "A: half up") || !strings.Contains(h.runner.prompts[1], "Use math.Round") {
		t.Fatalf("coding prompt lacks answers or plan:\n%s", h.runner.prompts[1])
	}
	if h.runner.resumes[1] != "s1" {
		t.Fatalf("coding did not resume the analysis session: %q", h.runner.resumes[1])
	}
	if string(h.runner.lastHome) != "home" {
		t.Fatal("claude home not carried from analysis to coding")
	}

	// No push without approval: nothing to claim while waiting for review.
	h.idle()
	if len(h.git.pushed) != 0 {
		t.Fatal("pushed before approval")
	}

	if _, err := h.o.Approve(h.ctx, "PAY-1", nil, domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	if _, err := h.o.Approve(h.ctx, "PAY-1", nil, domain.OriginWeb); !errors.Is(err, domain.ErrConflict) {
		t.Fatalf("double approve: %v", err)
	}
	h.step() // push
	tk = h.expect("PAY-1", domain.StateDone)
	if tk.PRNumber == nil || *tk.PRNumber != 7 || len(h.git.pushed) != 1 {
		t.Fatalf("after push: %+v pushed=%v", tk, h.git.pushed)
	}
	if h.runner.opened != 2 || h.runner.closed != 2 {
		t.Fatalf("containers opened %d closed %d", h.runner.opened, h.runner.closed)
	}
	if len(h.tracker.moves) != 2 || len(h.tracker.comments) < 2 {
		t.Fatalf("tracker: moves=%v comments=%d", h.tracker.moves, len(h.tracker.comments))
	}
}

func TestCheckFailureIsFixed(t *testing.T) {
	h := newHarness(t)
	h.ingest("PAY-2")
	h.runner.scripts = []script{
		{result: ok("s2"), files: map[string]string{orchestrator.AnalysisPath: analysis(0)}},
		{result: ok("s2"), edit: "v1"},
		{result: ok("s2"), edit: "v2"},
	}
	h.runner.execs["go test ./..."] = []orchestrator.ExecResult{{ExitCode: 1, Output: "--- FAIL: TestRefund"}, {ExitCode: 0}}

	h.step()
	h.expect("PAY-2", domain.StateCoding) // no questions
	h.step()
	h.expect("PAY-2", domain.StateWaitingForReview)
	if !strings.Contains(h.runner.prompts[2], "--- FAIL: TestRefund") {
		t.Fatalf("fix prompt lacks the failure:\n%s", h.runner.prompts[2])
	}
	v, _ := h.o.View(h.ctx, "PAY-2")
	if v.Result == nil || len(v.Result.Files) != 1 {
		t.Fatalf("result: %+v", v.Result)
	}
}

func TestChecksKeepFailingThenRetry(t *testing.T) {
	h := newHarness(t)
	h.ingest("PAY-3")
	h.runner.scripts = []script{
		{result: ok("s3"), files: map[string]string{orchestrator.AnalysisPath: analysis(0)}},
		{result: ok("s3"), edit: "v1"},
		{result: ok("s3"), edit: "v2"},
	}
	h.runner.execs["go test ./..."] = []orchestrator.ExecResult{{ExitCode: 1, Output: "boom"}, {ExitCode: 1, Output: "boom"}}

	h.step()
	h.step()
	tk := h.expect("PAY-3", domain.StateFailed)
	if tk.ResumeState != domain.StateCoding {
		t.Fatalf("resume state %s", tk.ResumeState)
	}
	h.idle()
	if _, err := h.o.Retry(h.ctx, "PAY-3", domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	h.expect("PAY-3", domain.StateCoding)
}

func TestRateLimitedAnalysis(t *testing.T) {
	h := newHarness(t)
	h.ingest("PAY-4")
	h.runner.scripts = []script{{result: orchestrator.ClaudeResult{SessionID: "s4", RateLimited: true, IsError: true}}}
	h.step()
	tk := h.expect("PAY-4", domain.StateRateLimited)
	if tk.ResumeState != domain.StateNew {
		t.Fatalf("resume state %s", tk.ResumeState)
	}
	if _, err := h.o.Retry(h.ctx, "PAY-4", domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	h.expect("PAY-4", domain.StateNew)
}

func TestRequestChangesResumesSession(t *testing.T) {
	h := newHarness(t)
	h.ingest("PAY-5")
	h.runner.scripts = []script{
		{result: ok("s5"), files: map[string]string{orchestrator.AnalysisPath: analysis(0)}},
		{result: ok("s5"), edit: "v1"},
		{result: ok("s5b"), edit: "v2"},
	}
	h.step()
	h.step()
	h.expect("PAY-5", domain.StateWaitingForReview)

	if _, err := h.o.RequestChanges(h.ctx, "PAY-5", "  ", domain.OriginWeb); !errors.Is(err, orchestrator.ErrInvalid) {
		t.Fatalf("empty feedback: %v", err)
	}
	tk, err := h.o.RequestChanges(h.ctx, "PAY-5", "Also handle negative amounts.", domain.OriginMobile)
	if err != nil || tk.Revision != 1 || tk.State != domain.StateCoding {
		t.Fatalf("request changes: %+v %v", tk, err)
	}
	h.step()
	tk = h.expect("PAY-5", domain.StateWaitingForReview)
	last := h.runner.prompts[len(h.runner.prompts)-1]
	if !strings.Contains(last, "negative amounts") || h.runner.resumes[len(h.runner.resumes)-1] != "s5" {
		t.Fatalf("feedback run: prompt=%q resume=%q", last, h.runner.resumes[len(h.runner.resumes)-1])
	}
	if tk.Feedback != "" {
		t.Fatal("feedback not cleared after the run")
	}
}

func TestRejectAndNoRepo(t *testing.T) {
	h := newHarness(t)
	if _, err := h.o.Ingest(h.ctx, orchestrator.Incoming{Key: "OPS-1", Project: "OPS", Title: "No repo"}, domain.OriginWebhook); err != nil {
		t.Fatal(err)
	}
	h.step()
	tk := h.expect("OPS-1", domain.StateFailed)
	if tk.ResumeState != domain.StateNew {
		t.Fatalf("resume %s", tk.ResumeState)
	}
	if _, err := h.o.Reject(h.ctx, "OPS-1", "not for hiro", domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	h.expect("OPS-1", domain.StateRejected)
	if _, err := h.o.Retry(h.ctx, "OPS-1", domain.OriginWeb); !errors.Is(err, domain.ErrConflict) {
		t.Fatalf("retry rejected: %v", err)
	}
}

func TestIngestIsIdempotentAndRefreshesText(t *testing.T) {
	h := newHarness(t)
	h.ingest("PAY-6")
	created, err := h.o.Ingest(h.ctx, orchestrator.Incoming{Key: "PAY-6", Project: "PAY", Title: "Renamed", Description: "new"}, domain.OriginSystem)
	if err != nil || created {
		t.Fatalf("second ingest: %v %v", created, err)
	}
	if tk := h.state("PAY-6"); tk.Title != "Renamed" {
		t.Fatalf("title not refreshed: %q", tk.Title)
	}
}

func TestRecoverInterrupted(t *testing.T) {
	h := newHarness(t)
	h.ingest("PAY-7")
	// Claim (moves to analyzing, opens a run) and "crash" before working.
	_, _, ok, err := h.store.ClaimNext(h.ctx)
	if err != nil || !ok {
		t.Fatal(err)
	}
	h.expect("PAY-7", domain.StateAnalyzing)
	h.idle() // active run blocks a second claim
	n, err := h.store.RecoverInterrupted(h.ctx)
	if err != nil || n != 1 {
		t.Fatalf("recover: %d %v", n, err)
	}
	h.expect("PAY-7", domain.StateNew)
}

// ---- phase 2 ----

func (h *harness) sideRepo() int64 {
	h.t.Helper()
	r, err := h.store.SaveRepository(h.ctx, domain.Repository{
		Name: "visper", Kind: "side", Provider: "github", CloneURL: "https://github.com/me/visper.git",
		DefaultBranch: "main", TaskPrefix: "VIS",
	})
	if err != nil {
		h.t.Fatal(err)
	}
	return r.ID
}

func TestTaskLifecyclePushToMain(t *testing.T) {
	h := newHarness(t)
	repo := h.sideRepo()

	// "queue" keeps the task until started.
	tk, err := h.o.CreateTask(h.ctx, orchestrator.TaskInput{RepoID: repo, Title: "Rest timer", Priority: "high", AfterApprove: "main", Start: "queue"}, domain.OriginWeb)
	if err != nil || tk.Key != "VIS-1" || !tk.Held {
		t.Fatalf("create: %+v %v", tk, err)
	}
	h.idle()
	if _, err := h.o.UpdateTask(h.ctx, "VIS-1", orchestrator.TaskInput{Title: "Rest timer between sets"}, domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	if _, err := h.o.Start(h.ctx, "VIS-1", domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	h.runner.scripts = []script{
		{result: ok("v1"), files: map[string]string{orchestrator.AnalysisPath: analysis(1)}},
		{result: ok("v1"), edit: "x"},
	}
	h.step()
	// Queued tasks take the ask-first default from settings (true).
	h.expect("VIS-1", domain.StateWaitingForAnswers)
	if _, err := h.o.UpdateTask(h.ctx, "VIS-1", orchestrator.TaskInput{Title: "late edit"}, domain.OriginWeb); !errors.Is(err, domain.ErrConflict) {
		t.Fatalf("edit after start: %v", err)
	}
	v, _ := h.o.View(h.ctx, "VIS-1")
	if _, err := h.o.Answer(h.ctx, "VIS-1", []domain.Answer{{QuestionID: v.Questions[0].ID, Answer: "yes"}}, domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	h.step()
	h.expect("VIS-1", domain.StateWaitingForReview)
	if _, err := h.o.Approve(h.ctx, "VIS-1", nil, domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	h.step()
	h.expect("VIS-1", domain.StateDone)
	if len(h.git.pushed) != 1 || h.git.pushed[0] != "hiro/VIS-1->main" || h.host.opened != 0 {
		t.Fatalf("push to main: %v, PRs %d", h.git.pushed, h.host.opened)
	}
	if len(h.tracker.comments) != 0 || len(h.tracker.moves) != 0 {
		t.Fatalf("a local task talked to Jira: %v %v", h.tracker.comments, h.tracker.moves)
	}

	// Next task gets the next number; "code" skips questions.
	tk2, err := h.o.CreateTask(h.ctx, orchestrator.TaskInput{RepoID: repo, Title: "Dark mode", Priority: "low", AfterApprove: "pr", Start: "code"}, domain.OriginWeb)
	if err != nil || tk2.Key != "VIS-2" || tk2.Held || tk2.AskFirst {
		t.Fatalf("second task: %+v %v", tk2, err)
	}
	if err := h.o.DeleteTask(h.ctx, "VIS-2", domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	if _, err := h.store.TicketByKey(h.ctx, "VIS-2"); !errors.Is(err, domain.ErrNotFound) {
		t.Fatal("task not deleted")
	}
	if err := h.o.DeleteTask(h.ctx, "VIS-1", domain.OriginWeb); !errors.Is(err, domain.ErrConflict) {
		t.Fatal("finished task deleted")
	}
	if _, err := h.o.CreateTask(h.ctx, orchestrator.TaskInput{RepoID: repo, Title: "x", Priority: "urgent", AfterApprove: "pr", Start: "ask"}, domain.OriginWeb); !errors.Is(err, orchestrator.ErrInvalid) {
		t.Fatal("bad priority accepted")
	}
}

func TestNoQuestionsWhenAskFirstOff(t *testing.T) {
	h := newHarness(t)
	h.settings.s.AskFirst = false
	h.ingest("PAY-20")
	h.runner.scripts = []script{{result: ok("n1"), files: map[string]string{orchestrator.AnalysisPath: analysis(2)}}}
	h.step()
	h.expect("PAY-20", domain.StateCoding)
	if !strings.Contains(h.runner.prompts[0], "Do not ask questions") {
		t.Fatal("analysis prompt should forbid questions")
	}
}

func TestModelsStopAndPRTemplate(t *testing.T) {
	h := newHarness(t)
	h.settings.s.Git.PRTitle = "[{key}] {title}"
	h.settings.s.Git.Draft = true
	h.ingest("PAY-21")
	if _, err := h.o.SetModels(h.ctx, "PAY-21", map[string]string{"analyze": "haiku", "coding": "default"}, domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	if _, err := h.o.SetModels(h.ctx, "PAY-21", map[string]string{"analyze": "gpt"}, domain.OriginWeb); !errors.Is(err, orchestrator.ErrInvalid) {
		t.Fatal("unknown model accepted")
	}

	var models []string
	h.runner.onClaude = func(req orchestrator.ClaudeRequest) { models = append(models, req.Model) }
	h.runner.scripts = []script{
		{result: ok("m1"), files: map[string]string{orchestrator.AnalysisPath: analysis(0)}},
		{result: ok("m1"), edit: "x"},
	}
	h.step()
	h.step()
	h.expect("PAY-21", domain.StateWaitingForReview)
	if len(models) != 2 || models[0] != "haiku" || models[1] != h.settings.s.Models.Coding {
		t.Fatalf("models used: %v", models)
	}
	if _, err := h.o.Approve(h.ctx, "PAY-21", []string{"bad name"}, domain.OriginWeb); !errors.Is(err, orchestrator.ErrInvalid) {
		t.Fatalf("username with a space accepted: %v", err)
	}
	tk := h.expect("PAY-21", domain.StateWaitingForReview)
	if _, err := h.o.Approve(h.ctx, "PAY-21", []string{" alice ", "bob", "alice", ""}, domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	tk = h.expect("PAY-21", domain.StatePushing)
	if !slices.Equal(tk.Assignees, []string{"alice", "bob"}) {
		t.Fatalf("stored assignees: %q", tk.Assignees)
	}
	h.step()
	if h.host.last.Title != "[PAY-21] Fix refund rounding" || !h.host.last.Draft {
		t.Fatalf("PR: %+v", h.host.last)
	}
	if !slices.Equal(h.host.assigned[7], []string{"alice", "bob"}) {
		t.Fatalf("PR assigned to %q", h.host.assigned[7])
	}

	// Stop: only while a stage runs.
	if _, err := h.o.Stop(h.ctx, "PAY-21", domain.OriginWeb); !errors.Is(err, domain.ErrConflict) {
		t.Fatal("stopped a finished ticket")
	}
	h.ingest("PAY-22")
	if _, _, ok, err := h.store.ClaimNext(h.ctx); err != nil || !ok {
		t.Fatal(err)
	}
	tk, err := h.o.Stop(h.ctx, "PAY-22", domain.OriginWeb)
	if err != nil || tk.State != domain.StateFailed || tk.ResumeState != domain.StateNew {
		t.Fatalf("stop: %+v %v", tk, err)
	}
}

func TestAutoResume(t *testing.T) {
	h := newHarness(t)
	h.ingest("PAY-23")
	h.runner.scripts = []script{{result: orchestrator.ClaudeResult{RateLimited: true, IsError: true}}}
	h.step()
	h.expect("PAY-23", domain.StateRateLimited)

	h.o.AutoResume(h.ctx, h.settings.s) // still paused (the fake recorded the limit)
	h.expect("PAY-23", domain.StateRateLimited)

	h.usage.paused = false
	h.settings.s.AutoResume = false
	h.o.AutoResume(h.ctx, h.settings.s)
	h.expect("PAY-23", domain.StateRateLimited)

	h.settings.s.AutoResume = true
	h.o.AutoResume(h.ctx, h.settings.s)
	h.expect("PAY-23", domain.StateNew)
}

func TestRunLoopRespectsUsagePauseAndParallel(t *testing.T) {
	h := newHarness(t)
	h.ingest("PAY-24")
	h.usage.paused = true
	h.runner.scripts = []script{{result: ok("p1"), files: map[string]string{orchestrator.AnalysisPath: analysis(1)}}}

	ctx, cancel := context.WithCancel(h.ctx)
	done := make(chan struct{})
	go func() { _ = h.o.Run(ctx); close(done) }()
	time.Sleep(300 * time.Millisecond)
	h.expect("PAY-24", domain.StateNew) // paused: not claimed

	h.usage.mu.Lock()
	h.usage.paused = false
	h.usage.mu.Unlock()
	h.o.Wake()
	deadline := time.Now().Add(5 * time.Second)
	for h.state("PAY-24").State != domain.StateWaitingForAnswers && time.Now().Before(deadline) {
		time.Sleep(50 * time.Millisecond)
	}
	cancel()
	<-done
	h.expect("PAY-24", domain.StateWaitingForAnswers)
}

func TestArchivedRepositoryTakesNoNewWork(t *testing.T) {
	h := newHarness(t)
	h.ingest("PAY-31") // known before archiving
	pay, err := h.store.RepositoryByJiraProject(h.ctx, "PAY")
	if err != nil {
		t.Fatal(err)
	}
	if r, err := h.store.SetRepositoryArchived(h.ctx, pay.ID, true); err != nil || r.ArchivedAt == nil {
		t.Fatalf("archive: %+v %v", r, err)
	}

	// New Jira tickets are ignored; known ones still get their text refreshed.
	in := orchestrator.Incoming{Key: "PAY-32", Project: "PAY", Title: "New", Description: "x"}
	if created, err := h.o.Ingest(h.ctx, in, domain.OriginWebhook); err != nil || created {
		t.Fatalf("archived repo took a new ticket: %v %v", created, err)
	}
	if _, err := h.store.TicketByKey(h.ctx, "PAY-32"); !errors.Is(err, domain.ErrNotFound) {
		t.Fatalf("PAY-32 stored: %v", err)
	}
	in = orchestrator.Incoming{Key: "PAY-31", Project: "PAY", Title: "Renamed", Description: "y"}
	if _, err := h.o.Ingest(h.ctx, in, domain.OriginWebhook); err != nil {
		t.Fatal(err)
	}
	if tk := h.state("PAY-31"); tk.Title != "Renamed" {
		t.Fatalf("known ticket not refreshed: %q", tk.Title)
	}

	// No new tasks either, until it is restored.
	side := h.sideRepo()
	if _, err := h.store.SetRepositoryArchived(h.ctx, side, true); err != nil {
		t.Fatal(err)
	}
	task := orchestrator.TaskInput{RepoID: side, Title: "Rest timer", Priority: "high", AfterApprove: "pr", Start: "queue"}
	if _, err := h.o.CreateTask(h.ctx, task, domain.OriginWeb); !errors.Is(err, orchestrator.ErrInvalid) {
		t.Fatalf("task on archived repo: %v", err)
	}
	if r, err := h.store.SetRepositoryArchived(h.ctx, side, false); err != nil || r.ArchivedAt != nil {
		t.Fatalf("restore: %+v %v", r, err)
	}
	if _, err := h.o.CreateTask(h.ctx, task, domain.OriginWeb); err != nil {
		t.Fatalf("task after restore: %v", err)
	}
}

func TestSetRepo(t *testing.T) {
	h := newHarness(t)
	side := h.sideRepo()
	h.ingest("PAY-30")

	// A new ticket can move to another repository.
	tk, err := h.o.SetRepo(h.ctx, "PAY-30", side, domain.OriginWeb)
	if err != nil || tk.RepoID == nil || *tk.RepoID != side {
		t.Fatalf("set repo on new ticket: %v, %+v", err, tk.RepoID)
	}

	// Not to an archived one.
	if _, err := h.store.SetRepositoryArchived(h.ctx, side, true); err != nil {
		t.Fatal(err)
	}
	if _, err := h.o.SetRepo(h.ctx, "PAY-30", side, domain.OriginWeb); !errors.Is(err, orchestrator.ErrInvalid) {
		t.Fatalf("archived repo accepted: %v", err)
	}
	if _, err := h.store.SetRepositoryArchived(h.ctx, side, false); err != nil {
		t.Fatal(err)
	}

	// Not while a stage runs.
	if _, err := h.store.Transition(h.ctx, "PAY-30", domain.StateAnalyzing, domain.Event{TicketKey: "PAY-30", Type: domain.EventStateChanged}, nil); err != nil {
		t.Fatal(err)
	}
	var te *domain.TransitionError
	if _, err := h.o.SetRepo(h.ctx, "PAY-30", side, domain.OriginWeb); !errors.As(err, &te) {
		t.Fatalf("running ticket: %v", err)
	}

	// A ticket stopped mid-coding starts over from analysis in the new repository.
	if _, err := h.store.Transition(h.ctx, "PAY-30", domain.StateFailed, domain.Event{TicketKey: "PAY-30", Type: domain.EventStateChanged},
		func(x *domain.Ticket) { x.ResumeState, x.Branch = domain.StateCoding, "hiro/PAY-30" }); err != nil {
		t.Fatal(err)
	}
	tk, err = h.o.SetRepo(h.ctx, "PAY-30", side, domain.OriginWeb)
	if err != nil {
		t.Fatal(err)
	}
	if tk.ResumeState != domain.StateNew || tk.Branch != "" {
		t.Fatalf("stopped ticket not reset: resume %s, branch %q", tk.ResumeState, tk.Branch)
	}

	// Not once a pull request exists.
	if _, err := h.store.UpdateTicket(h.ctx, "PAY-30", nil, func(x *domain.Ticket) { x.PRURL = "https://github.com/me/visper/pull/1" }); err != nil {
		t.Fatal(err)
	}
	if _, err := h.o.SetRepo(h.ctx, "PAY-30", side, domain.OriginWeb); !errors.As(err, &te) {
		t.Fatalf("ticket with a PR: %v", err)
	}
}
