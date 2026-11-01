package orchestrator_test

import (
	"archive/tar"
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"log/slog"
	"slices"
	"strings"
	"sync"
	"testing"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"

	"agnts/internal/ai"
	"agnts/internal/ai/aitest"
	"agnts/internal/domain"
	"agnts/internal/orchestrator"
	"agnts/internal/store/postgres"
	"agnts/internal/store/postgres/pgtest"
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
	onExec   func(cmd string)  // called for every command, with the lock held
	head     string            // what git rev-parse HEAD prints, when set
	written  map[string]string // every file agnts put into a workspace, last write wins
	// stream, when set, sends more events during every invocation.
	stream func(on func(orchestrator.ClaudeEvent))
	// exported are the folders the runs exported, in order ("" for
	// /workspace); trees are the names in each run's starting tar.
	exported []string
	trees    [][]string
	specs    []orchestrator.WorkspaceSpec
	ran      []string // every command run in a workspace, in order
}

func (f *fakeRunner) Open(_ context.Context, spec orchestrator.WorkspaceSpec) (orchestrator.Workspace, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	f.opened++
	f.lastHome = spec.ClaudeHome
	var names []string
	tr := tar.NewReader(spec.Repo)
	for {
		h, err := tr.Next()
		if err != nil {
			break
		}
		names = append(names, h.Name)
	}
	_, _ = io.Copy(io.Discard, spec.Repo)
	f.trees = append(f.trees, names)
	f.specs = append(f.specs, spec)
	return &fakeWS{r: f, files: map[string]string{}}, nil
}

type fakeWS struct {
	r     *fakeRunner
	files map[string]string
	edits []string
}

func (w *fakeWS) ID() string { return "ctr-1" }

// The gateway's stand-in providers ask the box (aitest.Scripted); a fake
// workspace runs no processes.
func (w *fakeWS) Run(context.Context, ai.Cmd, io.Writer, io.Writer) (int, error) { return 0, nil }
func (w *fakeWS) Attach(context.Context, ai.Cmd, io.Writer) (ai.Process, error) {
	return nil, errors.New("fakeWS: no processes")
}
func (w *fakeWS) OOM(context.Context, int) error { return nil }

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
	if w.r.stream != nil {
		// WriteFile takes the lock: let go of it while the stream runs.
		w.r.mu.Unlock()
		w.r.stream(on)
		w.r.mu.Lock()
	}
	for k, v := range s.files {
		w.files[k] = v
	}
	if s.edit != "" {
		w.edits = append(w.edits, strings.Split(s.edit, "\n")...) // "api:v1\nweb:v1": one edit per line
	}
	return s.result, s.err
}

func (w *fakeWS) Exec(_ context.Context, cmd string, _ time.Duration) (orchestrator.ExecResult, error) {
	w.r.mu.Lock()
	defer w.r.mu.Unlock()
	w.r.ran = append(w.r.ran, cmd)
	if w.r.onExec != nil {
		w.r.onExec(cmd)
	}
	if cmd == "git rev-parse HEAD" && w.r.head != "" {
		return orchestrator.ExecResult{Output: w.r.head + "\n"}, nil
	}
	if strings.HasPrefix(cmd, "git apply ") {
		w.edits = append(w.edits, "restored") // a saved change put back is in the tree
	}
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
	w.r.mu.Lock()
	if w.r.written == nil {
		w.r.written = map[string]string{}
	}
	w.r.written[p] = string(data)
	w.r.mu.Unlock()
	return nil
}

// ExportRepo returns the edits made in a folder: an edit "web:x" is in
// the folder web, one without a folder in /workspace.
func (w *fakeWS) ExportRepo(_ context.Context, dir string) (io.ReadCloser, error) {
	w.r.mu.Lock()
	w.r.exported = append(w.r.exported, dir)
	w.r.mu.Unlock()
	var mine []string
	for _, e := range w.edits {
		folder, _, ok := strings.Cut(e, ":")
		if (!ok && dir == "") || (ok && folder == dir) {
			mine = append(mine, e)
		}
	}
	return io.NopCloser(strings.NewReader(strings.Join(mine, "\n"))), nil
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
	// failPush makes the next push of a repository (by name) fail.
	failPush map[string]bool
	// committed names the repository of each commit with a change.
	committed []string
	messages  []string            // the message of each commit with a change
	files     []domain.FileChange // what Commit reports, when set
	// preparedAt records PrepareAt calls as branch@base.
	preparedAt []string
	// restored records RestoreBranch calls as branch@sha; branchesGone
	// makes them report the commits gone.
	restored     []string
	branchesGone bool
	// renamed records RenameBranch calls as from->to.
	renamed []string
	// reworded is the message RewordCommit gave the branch's commit.
	reworded string
}

func (g *fakeGit) Prepare(context.Context, domain.Repository, string) error { return nil }

// BaseOf and PrepareAt make fakeGit a Replayer.
func (g *fakeGit) BaseOf(_ context.Context, _ domain.Repository, sha string) (string, error) {
	return "base-of-" + sha, nil
}

func (g *fakeGit) PrepareAt(_ context.Context, _ domain.Repository, branch, base string) error {
	g.mu.Lock()
	defer g.mu.Unlock()
	g.preparedAt = append(g.preparedAt, branch+"@"+base)
	return nil
}
func (g *fakeGit) Archive(context.Context, domain.Repository, string) (io.ReadCloser, error) {
	return io.NopCloser(bytes.NewReader(nil)), nil
}

func (g *fakeGit) Commit(_ context.Context, repo domain.Repository, _ string, tree io.Reader, message string) (string, []domain.FileChange, []string, error) {
	b, _ := io.ReadAll(tree)
	if len(b) == 0 {
		return "base", nil, nil, nil
	}
	g.mu.Lock()
	defer g.mu.Unlock()
	g.commits++
	g.committed = append(g.committed, repo.Name)
	g.messages = append(g.messages, message)
	if g.files != nil {
		return "sha" + string(rune('0'+g.commits)), g.files, nil, nil
	}
	return "sha" + string(rune('0'+g.commits)), []domain.FileChange{{Path: "main.go", Add: 3, Del: 1, Diff: "+fix"}}, nil, nil
}

func (g *fakeGit) PushTo(_ context.Context, _ domain.Repository, branch, target string) error {
	g.mu.Lock()
	defer g.mu.Unlock()
	g.pushed = append(g.pushed, branch+"->"+target)
	return nil
}

func (g *fakeGit) Push(_ context.Context, repo domain.Repository, branch string) error {
	g.mu.Lock()
	defer g.mu.Unlock()
	if g.failPush[repo.Name] {
		delete(g.failPush, repo.Name)
		return errors.New("remote rejected")
	}
	if repo.Name != "api" {
		branch = repo.Name + ":" + branch
	}
	g.pushed = append(g.pushed, branch)
	return nil
}

type fakeHost struct {
	opened   int
	last     orchestrator.PR
	bodies   []string // each opened pull request's body, after its repository's name
	comments []string
	assigned map[int][]string
	merged   map[int]bool // pull requests PRState reports merged
	closed   map[int]bool // pull requests PRState reports closed without a merge
	asked    []int        // pull requests PRState was asked about
}

func (h *fakeHost) PRState(_ context.Context, _ domain.Repository, number int) (string, error) {
	h.asked = append(h.asked, number)
	switch {
	case h.merged[number]:
		return domain.PullMerged, nil
	case h.closed[number]:
		return domain.PullClosed, nil
	}
	return domain.PullOpen, nil
}

func (h *fakeHost) Assign(_ context.Context, _ domain.Repository, number int, usernames []string) error {
	if h.assigned == nil {
		h.assigned = map[int][]string{}
	}
	h.assigned[number] = usernames
	return nil
}

func (h *fakeHost) OpenPR(_ context.Context, repo domain.Repository, pr orchestrator.PR) (int, string, error) {
	h.opened++
	h.last = pr
	h.bodies = append(h.bodies, repo.Name+": "+pr.Body)
	if repo.Name != "api" && repo.Name != "" {
		n := 100 + h.opened
		return n, fmt.Sprintf("https://github.com/acme/%s/pull/%d", repo.Name, n), nil
	}
	return 7, "https://github.com/acme/api/pull/7", nil
}

func (h *fakeHost) UpsertComment(_ context.Context, repo domain.Repository, number int, id, body string) (string, error) {
	h.comments = append(h.comments, fmt.Sprintf("%s#%d %s: %s", repo.Name, number, id, body))
	return id, nil
}

type fakeTracker struct {
	mu       sync.Mutex
	comments []string
	moves    []orchestrator.TrackerStatus
	issues   []orchestrator.NewIssue
	calls    []string     // issue calls in order: create KEY, label KEY kind, link KEY OTHER
	onLabel  func(string) // runs inside LabelIssue
	issueErr error
	context  domain.TicketContext // what TicketContext returns
}

func (t *fakeTracker) TicketContext(context.Context, string) (domain.TicketContext, error) {
	t.mu.Lock()
	defer t.mu.Unlock()
	return t.context, nil
}

func (t *fakeTracker) CreateIssue(_ context.Context, in orchestrator.NewIssue) (string, error) {
	t.mu.Lock()
	defer t.mu.Unlock()
	if t.issueErr != nil {
		return "", t.issueErr
	}
	t.issues = append(t.issues, in)
	key := in.Project + "-" + string(rune('0'+len(t.issues))) + "00"
	t.calls = append(t.calls, "create "+key)
	return key, nil
}

func (t *fakeTracker) LabelIssue(_ context.Context, key string, kind domain.TicketKind) error {
	if t.onLabel != nil {
		t.onLabel(key)
	}
	t.mu.Lock()
	defer t.mu.Unlock()
	t.calls = append(t.calls, "label "+key+" "+string(kind))
	return nil
}

func (t *fakeTracker) LinkIssues(_ context.Context, key, other string) error {
	t.mu.Lock()
	defer t.mu.Unlock()
	t.calls = append(t.calls, "link "+key+" "+other)
	return nil
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

func (f *fakeUsage) Paused(context.Context, domain.ClaudeAccount, domain.Settings) (bool, time.Time) {
	f.mu.Lock()
	defer f.mu.Unlock()
	return f.paused, time.Time{}
}

func (f *fakeUsage) Record(context.Context, domain.ClaudeAccount, map[string]any) {
	f.mu.Lock()
	f.records++
	f.mu.Unlock()
}

func (f *fakeUsage) RecordLimited(context.Context, domain.ClaudeAccount) {
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

func (h *memHomes) Load(_ int64, k string) ([]byte, error) {
	if v, ok := h.m.Load(k); ok {
		return v.([]byte), nil
	}
	return nil, nil
}
func (h *memHomes) Save(_ int64, k string, b []byte) error { h.m.Store(k, b); return nil }

// memProgress keeps saved work in memory.
type memProgress struct{ memHomes }

func (p *memProgress) Drop(_ int64, k string) error { p.m.Delete(k); return nil }

func (p *memProgress) has(k string) bool { _, ok := p.m.Load(k); return ok }

// ---- harness ----

type harness struct {
	t        *testing.T
	ctx      context.Context
	store    *postgres.Agent
	o        *orchestrator.Orchestrator
	pool     *pgxpool.Pool
	runner   *fakeRunner
	git      *fakeGit
	host     *fakeHost
	tracker  *fakeTracker
	plane    *fakeTracker
	settings *fakeSettings
	usage    *fakeUsage
	// muse stands in for Muse: tests give it ears.
	muse     *aitest.Provider
	shots    *memShots
	progress *memProgress
}

func newHarness(t *testing.T) *harness {
	t.Helper()
	pool := pgtest.Open(t)
	pgtest.Reset(t, pool)
	ctx, _ := pgtest.Workspace(t, pool, "orch")
	log := slog.New(slog.NewTextHandler(io.Discard, nil))
	store := postgres.NewAgent(pool)
	if _, err := store.SaveRepository(ctx, domain.Repository{
		Name: "api", Kind: "jira", Provider: "github", CloneURL: "https://github.com/acme/api.git",
		DefaultBranch: "main", TestCmd: "go test ./...", JiraProject: "PAY",
	}); err != nil {
		t.Fatal(err)
	}
	h := &harness{t: t, ctx: ctx, store: store, pool: pool,
		runner: &fakeRunner{execs: map[string][]orchestrator.ExecResult{}}, git: &fakeGit{}, host: &fakeHost{}, tracker: &fakeTracker{}, plane: &fakeTracker{},
		shots: &memShots{m: map[string][]byte{}}, progress: &memProgress{}, muse: aitest.Muse()}
	cfg := orchestrator.DefaultConfig()
	cfg.FixAttempts = 1
	h.settings = &fakeSettings{s: domain.DefaultSettings()}
	h.settings.s.Git.AuthorName, h.settings.s.Git.AuthorEmail = "Rustam", "r@example.com"
	h.settings.s.AutoReview = false     // review_test.go turns it on
	h.settings.s.RecheckComplex = false // planning_test.go turns it on
	h.usage = &fakeUsage{}
	h.o = orchestrator.New(cfg, orchestrator.Deps{
		Providers: ai.NewRegistry(h.muse, aitest.Claude(), aitest.Codex()),
		Store:     store, Runner: h.runner, Git: h.git, Host: h.host, Trackers: map[domain.TicketSource]orchestrator.Tracker{domain.SourceJira: h.tracker, domain.SourcePlane: h.plane},
		Homes: &memHomes{}, Progress: h.progress, Settings: h.settings, Usage: h.usage, Translations: postgres.NewTranslations(pool),
		Shots: h.shots, PreviewEnvs: fakeEnvs{},
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
	if tk.Branch != "agnts/PAY-1" || tk.HeadSHA == "" || tk.Turns == 0 {
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

	if _, err := h.o.Approve(h.ctx, "PAY-1", nil, false, domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	if _, err := h.o.Approve(h.ctx, "PAY-1", nil, false, domain.OriginWeb); !errors.Is(err, domain.ErrConflict) {
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

func TestTokenSpendPerStage(t *testing.T) {
	h := newHarness(t)
	h.ingest("PAY-20")
	spend := func(session string, in, out int64, cost float64) orchestrator.ClaudeResult {
		r := ok(session)
		r.Model = "claude-opus-5-5"
		r.Usage = domain.TokenUsage{Input: in, Output: out, CacheRead: 10 * in, CostUSD: cost}
		return r
	}
	h.runner.scripts = []script{
		{result: spend("s20", 100, 10, 0.01), files: map[string]string{orchestrator.AnalysisPath: analysis(0)}},
		{result: spend("s20", 200, 20, 0.02), edit: "v1"},
		{result: spend("s20", 300, 30, 0.03), edit: "v2"},
	}
	h.runner.execs["go test ./..."] = []orchestrator.ExecResult{{ExitCode: 1, Output: "--- FAIL"}, {ExitCode: 0}}

	h.step() // analyze
	h.step() // code, one failed check, one fix attempt
	tk := h.expect("PAY-20", domain.StateWaitingForReview)

	got, err := h.store.TicketUsage(h.ctx, tk.ID)
	if err != nil {
		t.Fatal(err)
	}
	want := []domain.StageUsage{
		{ModelStage: domain.ModelAnalyze, Model: "claude-opus-5-5", Calls: 1, Turns: 5, Usage: domain.TokenUsage{Input: 100, Output: 10, CacheRead: 1000, CostUSD: 0.01}},
		{ModelStage: domain.ModelCoding, Model: "claude-opus-5-5", Calls: 1, Turns: 5, Usage: domain.TokenUsage{Input: 200, Output: 20, CacheRead: 2000, CostUSD: 0.02}},
		{ModelStage: domain.ModelRetry, Model: "claude-opus-5-5", Calls: 1, Turns: 5, Usage: domain.TokenUsage{Input: 300, Output: 30, CacheRead: 3000, CostUSD: 0.03}},
	}
	if len(got) != len(want) {
		t.Fatalf("stages %+v, want %+v", got, want)
	}
	for i := range want {
		if got[i] != want[i] {
			t.Fatalf("stage %d: %+v, want %+v", i, got[i], want[i])
		}
	}

	v, err := h.o.View(h.ctx, "PAY-20")
	total := domain.TokenUsage{Input: 600, Output: 60, CacheRead: 6000, CostUSD: 0.06}
	if err != nil || len(v.Stages) != 3 || v.Spend.Total() != total.Total() || v.Spend.Input != total.Input {
		t.Fatalf("view spend %+v stages %d: %v", v.Spend, len(v.Stages), err)
	}
	if d := v.Spend.CostUSD - total.CostUSD; d > 1e-9 || d < -1e-9 {
		t.Fatalf("view cost %v, want %v", v.Spend.CostUSD, total.CostUSD)
	}
	h.ingest("PAY-22") // no runs yet
	rows, err := h.o.Rows(h.ctx, []domain.Ticket{h.state("PAY-20"), h.state("PAY-22")})
	if err != nil || rows[0].Spend.Total() != total.Total() || !rows[1].Spend.IsZero() {
		t.Fatalf("rows spend: %+v %v", rows, err)
	}
}

func TestPartialSpendIsRecorded(t *testing.T) {
	h := newHarness(t)
	h.ingest("PAY-21")
	cut := orchestrator.ClaudeResult{Partial: true, Usage: domain.TokenUsage{Input: 40, Output: 7}}
	h.runner.scripts = []script{{result: cut, err: errors.New("claude timed out after 1m0s")}}

	h.step()
	tk := h.expect("PAY-21", domain.StateFailed)
	got, err := h.store.TicketUsage(h.ctx, tk.ID)
	if err != nil || len(got) != 1 || !got[0].Partial || got[0].Usage != cut.Usage || got[0].ModelStage != domain.ModelAnalyze {
		t.Fatalf("partial spend: %+v %v", got, err)
	}
}

// A check command that is not installed is a setup problem, not a code
// one: the run stops at once, saying which toolchain to add, instead of
// spending the fix attempts on it.
func TestMissingToolchainStopsWithoutFixAttempts(t *testing.T) {
	h := newHarness(t)
	h.ingest("PAY-7")
	h.runner.scripts = []script{
		{result: ok("s7"), files: map[string]string{orchestrator.AnalysisPath: analysis(0)}},
		{result: ok("s7"), edit: "v1"},
		{result: ok("s7"), edit: "v2"},
	}
	h.runner.execs["go test ./..."] = []orchestrator.ExecResult{{ExitCode: 127, Output: "bash: line 1: go: command not found\n"}}
	h.step()
	h.step()
	h.expect("PAY-7", domain.StateFailed)
	if n := len(h.runner.prompts); n != 2 {
		t.Fatalf("%d Claude calls, want 2 (analyze, code): no fix attempt", n)
	}
	evs, _ := h.store.Events(h.ctx, orchestrator.EventFilter{TicketKey: "PAY-7"})
	if !slices.ContainsFunc(evs, func(e domain.Event) bool {
		return strings.Contains(e.Message, "`go` is not installed in the run container")
	}) {
		t.Fatal("no event names the missing command")
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

// Checks the container cannot run (a private dependency it cannot fetch)
// fail every round; retried with the checks skipped, the coding run goes
// to review on the code alone, and they stay skipped until turned back on.
func TestRetrySkippingChecks(t *testing.T) {
	h := newHarness(t)
	h.ingest("PAY-8")
	h.runner.scripts = []script{
		{result: ok("s8"), files: map[string]string{orchestrator.AnalysisPath: analysis(0)}},
		{result: ok("s8"), edit: "v1"},
		{result: ok("s8"), edit: "v2"},
		{result: ok("s8"), edit: "v3"},
	}
	h.runner.execs["go test ./..."] = []orchestrator.ExecResult{{ExitCode: 1, Output: "boom"}, {ExitCode: 1, Output: "boom"}}
	h.step()
	h.step()
	h.expect("PAY-8", domain.StateFailed)
	h.idle()

	if _, err := h.o.SetSkipChecks(h.ctx, "PAY-8", true, domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	if _, err := h.o.Retry(h.ctx, "PAY-8", domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	h.step()
	tk := h.expect("PAY-8", domain.StateWaitingForReview)
	if !tk.SkipChecks {
		t.Fatal("skipChecks not kept")
	}
	if n := len(h.runner.execs["go test ./..."]); n != 0 {
		t.Fatalf("%d check results left unused, want 0: the skipped run ran no checks", n)
	}
	last := h.runner.prompts[len(h.runner.prompts)-1]
	if !strings.Contains(last, "The checks are skipped for this ticket") || strings.Contains(last, "Run the project's build, lint and tests yourself") {
		t.Fatalf("prompt does not say the checks are skipped:\n%s", last)
	}
	evs, _ := h.store.Events(h.ctx, orchestrator.EventFilter{TicketKey: "PAY-8"})
	if !slices.ContainsFunc(evs, func(e domain.Event) bool { return strings.HasPrefix(e.Message, "checks skipped for this ticket") }) {
		t.Fatal("no event says the checks were skipped")
	}

	// Waiting for review, they can be turned back on; while coding, not.
	if tk, err := h.o.SetSkipChecks(h.ctx, "PAY-8", false, domain.OriginWeb); err != nil || tk.SkipChecks {
		t.Fatalf("turn back on: %+v %v", tk.SkipChecks, err)
	}
	h.ingest("PAY-9")
	if _, err := h.o.SetSkipChecks(h.ctx, "PAY-9", true, domain.OriginWeb); err == nil {
		t.Fatal("skipped the checks of a new ticket")
	}
}

// The ticket number can change in any state until the ticket is closed,
// not to another open ticket's number.
func TestSetTicketNumber(t *testing.T) {
	h := newHarness(t)
	h.ingest("PAY-8")
	h.ingest("PAY-9")
	tk, err := h.o.SetTicketNumber(h.ctx, "PAY-8", " AMANAT-2677 ", domain.OriginWeb)
	if err != nil || tk.TicketNumber != "AMANAT-2677" || tk.Number() != "AMANAT-2677" {
		t.Fatalf("set: %q %v", tk.TicketNumber, err)
	}
	evs, _ := h.store.Events(h.ctx, orchestrator.EventFilter{TicketKey: "PAY-8"})
	if !slices.ContainsFunc(evs, func(e domain.Event) bool { return e.Message == "ticket number set to AMANAT-2677" }) {
		t.Fatal("no event says the number changed")
	}
	if _, err := h.o.SetTicketNumber(h.ctx, "PAY-9", "AMANAT-2677", domain.OriginWeb); err == nil {
		t.Fatal("two open tickets got one number")
	}
	if _, err := h.o.SetTicketNumber(h.ctx, "PAY-9", "bad number", domain.OriginWeb); err == nil {
		t.Fatal("took a number with a space")
	}
	if tk, err := h.o.SetTicketNumber(h.ctx, "PAY-8", "", domain.OriginWeb); err != nil || tk.TicketNumber != "" || tk.Number() != "PAY-8" {
		t.Fatalf("clear: %q %v", tk.TicketNumber, err)
	}
	if _, err := h.o.Reject(h.ctx, "PAY-8", "no", domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	if _, err := h.o.SetTicketNumber(h.ctx, "PAY-8", "AMANAT-1", domain.OriginWeb); err == nil {
		t.Fatal("changed the number of a rejected ticket")
	}
}

type heardNumber struct{ key, number, old string }

type linker struct{ heard []heardNumber }

func (l *linker) TicketNumberChanged(_ context.Context, t domain.Ticket, old string) {
	l.heard = append(l.heard, heardNumber{t.Key, t.TicketNumber, old})
}

// The commit linker hears about new tickets and changed numbers, to scan
// the git host for their commits.
func TestCommitLinkerHearsNumbers(t *testing.T) {
	h := newHarness(t)
	l := &linker{}
	h.o.SetCommitLinker(l)
	h.ingest("PAY-8")
	if _, err := h.o.SetTicketNumber(h.ctx, "PAY-8", "AMANAT-1", domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	if _, err := h.o.SetTicketNumber(h.ctx, "PAY-8", "AMANAT-1", domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	if _, err := h.o.SetTicketNumber(h.ctx, "PAY-8", "AMANAT-2", domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	// A ticket created without a number has its key as its number.
	want := []heardNumber{{"PAY-8", "PAY-8", ""}, {"PAY-8", "AMANAT-1", "PAY-8"}, {"PAY-8", "AMANAT-2", "AMANAT-1"}}
	if !slices.Equal(l.heard, want) {
		t.Fatalf("heard %+v, want %+v", l.heard, want)
	}
}

func TestRetryWithNote(t *testing.T) {
	h := newHarness(t)
	h.ingest("PAY-6")
	h.runner.scripts = []script{
		{result: ok("s6"), files: map[string]string{orchestrator.AnalysisPath: analysis(0)}},
		{result: ok("s6"), edit: "v1"},
		{result: ok("s6"), edit: "v2"},
		{result: ok("s6"), edit: "v3"},
	}
	h.runner.execs["go test ./..."] = []orchestrator.ExecResult{{ExitCode: 1, Output: "boom"}, {ExitCode: 1, Output: "boom"}}
	h.step()
	h.step()
	h.expect("PAY-6", domain.StateFailed)
	h.idle()

	tk, err := h.o.RetryWithNote(h.ctx, "PAY-6", "  Skip the flaky integration test.  ", nil, domain.OriginWeb)
	if err != nil || tk.State != domain.StateCoding {
		t.Fatalf("retry: %+v %v", tk, err)
	}
	if !strings.Contains(tk.Feedback, "boom") || !strings.HasSuffix(tk.Feedback, "Skip the flaky integration test.") {
		t.Fatalf("feedback %q", tk.Feedback)
	}
	h.step()
	tk = h.expect("PAY-6", domain.StateWaitingForReview)
	last := h.runner.prompts[len(h.runner.prompts)-1]
	if !strings.Contains(last, "flaky integration test") || h.runner.resumes[len(h.runner.resumes)-1] != "s6" {
		t.Fatalf("retry run: prompt=%q resume=%q", last, h.runner.resumes[len(h.runner.resumes)-1])
	}
	if tk.Feedback != "" {
		t.Fatal("note not cleared after the run")
	}
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

	if _, err := h.o.RequestChanges(h.ctx, "PAY-5", "  ", nil, nil, domain.OriginWeb); !errors.Is(err, orchestrator.ErrInvalid) {
		t.Fatalf("empty feedback: %v", err)
	}
	tk, err := h.o.RequestChanges(h.ctx, "PAY-5", "Also handle negative amounts.", nil, nil, domain.OriginMobile)
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
	if _, err := h.o.Ingest(h.ctx, orchestrator.Incoming{Key: "OPS-1", Project: "OPS", Title: "No repo", Kind: domain.KindCode}, domain.OriginWebhook); err != nil {
		t.Fatal(err)
	}
	h.step() // code was chosen, so there is nothing to analyse without a repository
	tk := h.expect("OPS-1", domain.StateFailed)
	if tk.ResumeState != domain.StateNew {
		t.Fatalf("resume %s", tk.ResumeState)
	}
	if _, err := h.o.Reject(h.ctx, "OPS-1", "not for agnts", domain.OriginWeb); err != nil {
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
	if _, err := h.o.Approve(h.ctx, "VIS-1", nil, false, domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	h.step()
	h.expect("VIS-1", domain.StateDone)
	if len(h.git.pushed) != 1 || h.git.pushed[0] != "agnts/VIS-1->main" || h.host.opened != 0 {
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
	if _, err := h.o.Approve(h.ctx, "PAY-21", []string{"bad name"}, false, domain.OriginWeb); !errors.Is(err, orchestrator.ErrInvalid) {
		t.Fatalf("username with a space accepted: %v", err)
	}
	tk := h.expect("PAY-21", domain.StateWaitingForReview)
	if _, err := h.o.Approve(h.ctx, "PAY-21", []string{" alice ", "bob", "alice", ""}, false, domain.OriginWeb); err != nil {
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
	pay, err := h.store.RepositoryByTrackerProject(h.ctx, domain.SourceJira, "PAY")
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
		func(x *domain.Ticket) { x.ResumeState, x.Branch = domain.StateCoding, "agnts/PAY-30" }); err != nil {
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

// A Plane work item goes to the repository linked to its Plane project,
// its "blocked by" relations become plane relations, and only the Plane
// tracker hears about it.
func TestPlaneTicketsUseThePlaneTracker(t *testing.T) {
	h := newHarness(t)
	web, err := h.store.SaveRepository(h.ctx, domain.Repository{
		Name: "web", Kind: "plane", Provider: "github", CloneURL: "https://github.com/acme/web.git",
		DefaultBranch: "main", PlaneProject: "WEB",
	})
	if err != nil {
		t.Fatal(err)
	}
	for _, in := range []orchestrator.Incoming{
		{Source: domain.SourcePlane, Key: "WEB-2", Project: "WEB", Title: "Add the API", LinksKnown: true},
		{Source: domain.SourcePlane, Key: "WEB-1", Project: "WEB", Title: "Use the API", LinksKnown: true, DependsOn: []string{"WEB-2"}},
	} {
		if created, err := h.o.Ingest(h.ctx, in, domain.OriginWebhook); err != nil || !created {
			t.Fatalf("ingest %s: %v %v", in.Key, created, err)
		}
	}
	tk := h.state("WEB-1")
	if tk.Source != domain.SourcePlane || tk.RepoID == nil || *tk.RepoID != web.ID {
		t.Fatalf("plane ticket: %+v", tk)
	}
	if rs := h.relations("WEB-1").All; len(rs) != 1 || rs[0].Source != domain.RelFromPlane || rs[0].OtherKey != "WEB-2" {
		t.Fatalf("plane relation: %+v", rs)
	}
	// The link is gone in Plane: the relation goes too.
	if _, err := h.o.Ingest(h.ctx, orchestrator.Incoming{Source: domain.SourcePlane, Key: "WEB-1", Project: "WEB", Title: "Use the API", LinksKnown: true}, domain.OriginWebhook); err != nil {
		t.Fatal(err)
	}
	if rs := h.relations("WEB-1").All; len(rs) != 0 {
		t.Fatalf("relation kept after the link went: %+v", rs)
	}
	if _, err := h.o.Reject(h.ctx, "WEB-1", "not now", domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	if len(h.plane.moves) != 1 || h.plane.moves[0] != orchestrator.TrackerRejected {
		t.Fatalf("plane moves: %v", h.plane.moves)
	}
	if len(h.tracker.moves) != 0 || len(h.tracker.comments) != 0 {
		t.Fatalf("a Plane ticket talked to Jira: %v %v", h.tracker.moves, h.tracker.comments)
	}
}

func TestBranchTemplate(t *testing.T) {
	h := newHarness(t)
	repo, err := h.store.RepositoryByName(h.ctx, "api")
	if err != nil {
		t.Fatal(err)
	}
	repo.BranchTemplate = "{type}/{key}-{slug}"
	if _, err := h.store.UpdateRepository(h.ctx, repo); err != nil {
		t.Fatal(err)
	}
	h.ingest("PAY-7")
	h.runner.scripts = []script{{result: ok("s1"), files: map[string]string{orchestrator.AnalysisPath: analysis(1)}}}

	h.step() // analyze: the branch is named once the kind is settled
	tk := h.expect("PAY-7", domain.StateWaitingForAnswers)
	if tk.Branch != "feature/PAY-7-fix-refund-rounding" {
		t.Fatalf("branch %q", tk.Branch)
	}
}

func TestTicketNumberBranchAndCommit(t *testing.T) {
	h := newHarness(t)
	repo, err := h.store.RepositoryByName(h.ctx, "api")
	if err != nil {
		t.Fatal(err)
	}
	repo.BranchTemplate, repo.CommitTemplate = "{number}", "[{number}] {type}({scope}): {subject}"
	if _, err := h.store.UpdateRepository(h.ctx, repo); err != nil {
		t.Fatal(err)
	}
	number := "AMANAT-2288"
	task := orchestrator.TaskInput{RepoID: repo.ID, Title: "Update protos", Priority: "medium", AfterApprove: "pr", Start: "code", Kind: "code", TicketNumber: &number}
	tk, err := h.o.CreateTask(h.ctx, task, domain.OriginWeb)
	if err != nil || tk.TicketNumber != number {
		t.Fatalf("create: %+v %v", tk, err)
	}
	// Two open tickets with one number would share a branch.
	if _, err := h.o.CreateTask(h.ctx, task, domain.OriginWeb); !errors.Is(err, orchestrator.ErrInvalid) {
		t.Fatalf("duplicate number accepted: %v", err)
	}
	h.runner.scripts = []script{
		{result: ok("s1"), files: map[string]string{orchestrator.AnalysisPath: analysis(0)}},
		{result: ok("s1"), edit: "fix", files: map[string]string{orchestrator.SummaryPath: `{"summary":"Bumped protos.","notes":[],
			"commit":{"type":"chore","scope":"deps","subject":"protos v1.63.0, drop local replace"}}`}},
	}
	h.step() // analyze
	h.step() // code + checks
	tk = h.expect(tk.Key, domain.StateWaitingForReview)
	if tk.Branch != number {
		t.Fatalf("branch %q", tk.Branch)
	}
	if len(h.git.messages) != 1 || !strings.HasPrefix(h.git.messages[0], "[AMANAT-2288] chore(deps): protos v1.63.0, drop local replace\n") {
		t.Fatalf("commit messages %q", h.git.messages)
	}
	if p := h.runner.prompts[1]; !strings.Contains(p, `"commit": {"type": "one of feat, fix,`) {
		t.Fatalf("coding prompt does not ask for the commit:\n%s", p)
	}
	if strings.Contains(h.runner.prompts[0], `"commit"`) {
		t.Fatal("analysis prompt asks for the commit")
	}
}
