package ciwatch

import (
	"context"
	"io"
	"log/slog"
	"slices"
	"strings"
	"sync"
	"testing"
	"time"

	"agnts/internal/domain"
	"agnts/internal/orchestrator"
)

// ---- fakes ----

type fakeStore struct {
	mu      sync.Mutex
	watches map[int64]domain.CIWatch
	groups  []domain.CIFailure
	samples map[int64]string
	auto    int
}

func newStore() *fakeStore {
	return &fakeStore{watches: map[int64]domain.CIWatch{}, samples: map[int64]string{}}
}

func (s *fakeStore) CIWatch(_ context.Context, id int64) (domain.CIWatch, error) {
	s.mu.Lock()
	defer s.mu.Unlock()
	if w, ok := s.watches[id]; ok {
		return w, nil
	}
	return domain.DefaultCIWatch(id), nil
}

func (s *fakeStore) EnabledCIWatches(context.Context) ([]domain.CIWatch, error) {
	s.mu.Lock()
	defer s.mu.Unlock()
	var out []domain.CIWatch
	for _, w := range s.watches {
		if w.Enabled {
			out = append(out, w)
		}
	}
	return out, nil
}

func (s *fakeStore) SaveCIWatch(_ context.Context, w domain.CIWatch) (domain.CIWatch, error) {
	s.mu.Lock()
	defer s.mu.Unlock()
	s.watches[w.RepoID] = w
	return w, nil
}

func (s *fakeStore) get(id int64) (*domain.CIFailure, bool) {
	for i := range s.groups {
		if s.groups[i].ID == id {
			return &s.groups[i], true
		}
	}
	return nil, false
}

func (s *fakeStore) CIFailure(_ context.Context, id int64) (domain.CIFailure, error) {
	s.mu.Lock()
	defer s.mu.Unlock()
	g, ok := s.get(id)
	if !ok {
		return domain.CIFailure{}, domain.ErrNotFound
	}
	out := *g
	out.Sample = s.samples[id]
	return out, nil
}

func (s *fakeStore) CIFailureByTicket(_ context.Context, key string) (domain.CIFailure, error) {
	s.mu.Lock()
	defer s.mu.Unlock()
	for _, g := range s.groups {
		if g.TicketKey == key {
			return g, nil
		}
	}
	return domain.CIFailure{}, domain.ErrNotFound
}

func (s *fakeStore) ListCIFailures(_ context.Context, f domain.CIFilter) ([]domain.CIFailure, error) {
	s.mu.Lock()
	defer s.mu.Unlock()
	out := []domain.CIFailure{}
	for _, g := range s.groups {
		if (f.RepoID == 0 || g.RepoID == f.RepoID) && (f.Branch == "" || g.Branch == f.Branch) && (f.Workflow == "" || g.Workflow == f.Workflow) &&
			(len(f.Statuses) == 0 || slices.Contains(f.Statuses, g.Status)) {
			out = append(out, g)
		}
	}
	return out, nil
}

func (s *fakeStore) UpsertCIFailure(_ context.Context, key domain.CIFailure, sample string, mut func(*domain.CIFailure, bool) error) (domain.CIFailure, error) {
	s.mu.Lock()
	defer s.mu.Unlock()
	for i := range s.groups {
		g := &s.groups[i]
		if g.RepoID == key.RepoID && g.Branch == key.Branch && g.Workflow == key.Workflow && g.Fingerprint == key.Fingerprint {
			c := *g
			c.Occurrences = slices.Clone(g.Occurrences)
			if err := mut(&c, false); err != nil {
				return c, err
			}
			*g = c
			if sample != "" {
				s.samples[g.ID] = sample
			}
			return c, nil
		}
	}
	f := key
	f.ID = int64(len(s.groups) + 1)
	f.Status = domain.CIOpen
	f.Count = 1
	f.FirstSeenAt = time.Now()
	if err := mut(&f, true); err != nil {
		return f, err
	}
	s.groups = append(s.groups, f)
	s.samples[f.ID] = sample
	return f, nil
}

func (s *fakeStore) UpdateCIFailure(_ context.Context, id int64, mut func(*domain.CIFailure) error) (domain.CIFailure, error) {
	s.mu.Lock()
	defer s.mu.Unlock()
	g, ok := s.get(id)
	if !ok {
		return domain.CIFailure{}, domain.ErrNotFound
	}
	c := *g
	c.Occurrences = slices.Clone(g.Occurrences)
	if err := mut(&c); err != nil {
		return c, err
	}
	*g = c
	return c, nil
}

func (s *fakeStore) AutoCITickets(context.Context, time.Time) (int, error) { return s.auto, nil }
func (s *fakeStore) PruneCISamples(context.Context) (int64, error)         { return 0, nil }

type fakeTickets struct {
	repos   []domain.Repository
	tickets map[string]domain.Ticket
	events  []domain.Event
}

func (f *fakeTickets) TicketByKey(_ context.Context, key string) (domain.Ticket, error) {
	if t, ok := f.tickets[key]; ok {
		return t, nil
	}
	return domain.Ticket{}, domain.ErrNotFound
}

func (f *fakeTickets) TicketByPR(_ context.Context, _, branch string) (domain.Ticket, error) {
	for _, t := range f.tickets {
		if t.Branch == branch {
			return t, nil
		}
	}
	return domain.Ticket{}, domain.ErrNotFound
}

func (f *fakeTickets) UnmergedPRs(context.Context, int) ([]domain.Ticket, error) { return nil, nil }
func (f *fakeTickets) ListRepositories(context.Context) ([]domain.Repository, error) {
	return f.repos, nil
}

func (f *fakeTickets) RepositoryByID(_ context.Context, id int64) (domain.Repository, error) {
	for _, r := range f.repos {
		if r.ID == id {
			return r, nil
		}
	}
	return domain.Repository{}, domain.ErrNotFound
}

func (f *fakeTickets) AppendEvent(_ context.Context, ev domain.Event) error {
	f.events = append(f.events, ev)
	return nil
}

type fakeWork struct {
	feedback []string
	created  []orchestrator.CITicketInput
	n        int
}

func (w *fakeWork) CIFeedback(_ context.Context, key, feedback, _ string, rounds int) (domain.Ticket, orchestrator.CIFeedbackResult, error) {
	w.feedback = append(w.feedback, key+"\n"+feedback)
	return domain.Ticket{Key: key}, orchestrator.CIFeedbackSent, nil
}

func (w *fakeWork) CreateCITicket(_ context.Context, in orchestrator.CITicketInput, _ domain.Origin) (domain.Ticket, error) {
	w.created = append(w.created, in)
	w.n++
	return domain.Ticket{Key: "CI-" + string(rune('0'+w.n))}, nil
}

type fakeHost struct {
	jobs     map[int64][]domain.CIJob
	logs     map[int64]string
	reruns   []int64
	comments []string
	rerunErr error
}

func (h *fakeHost) CIRuns(context.Context, domain.Repository, int) ([]domain.CIRun, error) {
	return nil, nil
}
func (h *fakeHost) FailedJobs(_ context.Context, _ domain.Repository, run int64) ([]domain.CIJob, error) {
	return h.jobs[run], nil
}
func (h *fakeHost) JobLog(_ context.Context, _ domain.Repository, job int64) (string, error) {
	return h.logs[job], nil
}
func (h *fakeHost) RerunFailed(_ context.Context, _ domain.Repository, run int64) error {
	h.reruns = append(h.reruns, run)
	return h.rerunErr
}
func (h *fakeHost) UpsertComment(_ context.Context, _ domain.Repository, _ int, id, body string) (string, error) {
	h.comments = append(h.comments, body)
	if id == "" {
		id = "c1"
	}
	return id, nil
}

type fakeAncestry struct{ yes bool }

func (a fakeAncestry) IsAncestor(context.Context, domain.Repository, string, string) (bool, error) {
	return a.yes, nil
}

type fakeSettings struct{ s domain.Settings }

func (f fakeSettings) Get(context.Context) (domain.Settings, error) { return f.s, nil }

// ---- helpers ----

const testFail = `--- FAIL: TestApplyCoupon (0.01s)
    billing_test.go:42: expected 90, got 100
FAIL
FAIL	acme/api/billing	0.233s`

type world struct {
	svc     *Service
	store   *fakeStore
	tickets *fakeTickets
	work    *fakeWork
	host    *fakeHost
	st      domain.Settings
}

func newWorld(t *testing.T) *world {
	t.Helper()
	w := &world{store: newStore(), work: &fakeWork{}, host: &fakeHost{jobs: map[int64][]domain.CIJob{}, logs: map[int64]string{}}}
	w.tickets = &fakeTickets{repos: []domain.Repository{{ID: 1, Name: "api", Provider: "github", CloneURL: "https://github.com/acme/api.git", DefaultBranch: "main"}},
		tickets: map[string]domain.Ticket{}}
	w.st = domain.DefaultSettings()
	w.st.CI.AutoFix = true
	w.store.watches[1] = domain.CIWatch{RepoID: 1, Enabled: true, Ignore: domain.DefaultCIIgnore, PRs: domain.CIPROff}
	w.build()
	return w
}

func (w *world) build() {
	w.svc = New(w.store, w.tickets, w.work, w.host, fakeAncestry{yes: true}, fakeSettings{w.st}, slog.New(slog.NewTextHandler(io.Discard, nil)))
	w.svc.async = func(f func()) { f() }
}

var t0 = time.Date(2026, 10, 12, 9, 0, 0, 0, time.UTC)

func failedRun(id int64, sha string, at time.Time) domain.CIRun {
	return domain.CIRun{Provider: "github", Repo: "acme/api", RunID: id, Attempt: 1, Workflow: "ci.yml", Name: "CI", Branch: "main",
		SHA: sha, Conclusion: "failure", URL: "https://github.com/acme/api/actions/runs/1", Finished: at}
}

func (w *world) failJob(run, job int64, name, log string) {
	w.host.jobs[run] = append(w.host.jobs[run], domain.CIJob{ID: job, Name: name, Conclusion: "failure"})
	w.host.logs[job] = log
}

func (w *world) process(t *testing.T, r domain.CIRun) {
	t.Helper()
	if err := w.svc.CIRunFinished(context.Background(), r); err != nil {
		t.Fatal(err)
	}
}

// ---- tests ----

func TestSameRepo(t *testing.T) {
	for _, c := range []struct {
		url, name string
		want      bool
	}{
		{"https://github.com/acme/api.git", "acme/api", true},
		{"https://github.com/Acme/API", "acme/api", true},
		{"git@github.com:acme/api.git", "acme/api", true},
		{"https://gitlab.example.com/gitlab/group/sub/proj.git", "group/sub/proj", true},
		{"https://github.com/acme/api-v2.git", "acme/api", false},
		{"https://github.com/acme/api.git", "", false},
	} {
		if got := SameRepo(c.url, c.name); got != c.want {
			t.Errorf("SameRepo(%q, %q) = %v", c.url, c.name, got)
		}
	}
}

func TestNewFailureIsRerunThenTicketed(t *testing.T) {
	w := newWorld(t)
	w.failJob(10, 100, "test", testFail)
	w.process(t, failedRun(10, "aaaaaaa1", t0))
	if len(w.store.groups) != 1 || w.store.groups[0].Status != domain.CITriage {
		t.Fatalf("groups after first failure: %+v", w.store.groups)
	}
	if !slices.Equal(w.host.reruns, []int64{10}) {
		t.Fatalf("reruns %v", w.host.reruns)
	}
	if len(w.work.created) != 0 {
		t.Fatal("ticket before the re-run confirmed it")
	}
	// The re-run fails too: same run, attempt 2, later.
	again := failedRun(10, "aaaaaaa1", t0.Add(5*time.Minute))
	again.Attempt = 2
	w.process(t, again)
	g := w.store.groups[0]
	if g.Status != domain.CIFixing || g.TicketKey == "" || len(w.work.created) != 1 {
		t.Fatalf("after confirmed failure: %+v, created %d", g, len(w.work.created))
	}
	in := w.work.created[0]
	if !strings.Contains(in.Title, "TestApplyCoupon") || !strings.Contains(in.Description, "expected 90, got 100") || in.Priority != "highest" {
		t.Errorf("ticket input %+v", in)
	}
	if !strings.Contains(in.Log, "=== first error ===") {
		t.Errorf("log not attached: %q", in.Log)
	}
	if len(w.tickets.events) == 0 || w.tickets.events[0].Type != domain.EventCIFailure {
		t.Errorf("no announcement: %+v", w.tickets.events)
	}
}

func TestDuplicateDeliveryCountsOnce(t *testing.T) {
	w := newWorld(t)
	w.st.CI.RetryFlaky = false
	w.build()
	w.failJob(10, 100, "test", testFail)
	r := failedRun(10, "aaaaaaa1", t0)
	w.process(t, r)
	w.process(t, r)                                                // the webhook again
	if err := w.svc.Process(context.Background(), r); err != nil { // the poller, past the in-memory guard
		t.Fatal(err)
	}
	if g := w.store.groups[0]; g.Count != 1 || len(g.Occurrences) != 1 {
		t.Fatalf("count %d, occurrences %d", g.Count, len(g.Occurrences))
	}
	if len(w.work.created) != 1 {
		t.Fatalf("created %d tickets", len(w.work.created))
	}
	if n := countEvents(w.tickets.events, domain.EventCIFailure); n != 1 {
		t.Fatalf("announced %d times", n)
	}
}

func countEvents(evs []domain.Event, typ string) int {
	n := 0
	for _, e := range evs {
		if e.Type == typ {
			n++
		}
	}
	return n
}

func TestSameFailureOnNewCommitIsOneGroup(t *testing.T) {
	w := newWorld(t)
	w.st.CI.RetryFlaky = false
	w.build()
	w.failJob(10, 100, "test", testFail)
	w.process(t, failedRun(10, "aaaaaaa1", t0))
	w.failJob(11, 101, "test", strings.ReplaceAll(testFail, "0.233s", "0.301s"))
	w.process(t, failedRun(11, "bbbbbbb2", t0.Add(time.Hour)))
	if len(w.store.groups) != 1 || w.store.groups[0].Count != 2 || w.store.groups[0].LastSHA != "bbbbbbb2" {
		t.Fatalf("groups %+v", w.store.groups)
	}
	if len(w.work.created) != 1 {
		t.Fatalf("one group, %d tickets", len(w.work.created))
	}
}

func TestRerunPassingMarksFlaky(t *testing.T) {
	w := newWorld(t)
	w.failJob(10, 100, "test", testFail)
	w.process(t, failedRun(10, "aaaaaaa1", t0))
	pass := failedRun(10, "aaaaaaa1", t0.Add(4*time.Minute))
	pass.Attempt, pass.Conclusion = 2, "success"
	w.process(t, pass)
	g := w.store.groups[0]
	if g.Status != domain.CIFlaky || g.FlakyCount != 1 || g.Class != domain.CIClassFlaky {
		t.Fatalf("group %+v", g)
	}
	if len(w.work.created) != 0 {
		t.Fatal("ticket for a flaky test")
	}
}

func TestInfraNeverTickets(t *testing.T) {
	w := newWorld(t)
	w.failJob(10, 100, "test", "Run make test\nThe runner has received a shutdown signal.\n##[error]The operation was canceled.")
	w.process(t, failedRun(10, "aaaaaaa1", t0))
	g := w.store.groups[0]
	if g.Status != domain.CIInfra || len(w.work.created) != 0 || len(w.host.reruns) != 0 {
		t.Fatalf("group %+v, created %d, reruns %v", g, len(w.work.created), w.host.reruns)
	}
}

func TestBudgetAndAutoFixOff(t *testing.T) {
	w := newWorld(t)
	w.st.CI.RetryFlaky = false
	w.st.CI.MaxAutoPerDay = 2
	w.store.auto = 2
	w.build()
	w.failJob(10, 100, "test", testFail)
	w.process(t, failedRun(10, "aaaaaaa1", t0))
	if len(w.work.created) != 0 || w.store.groups[0].Status != domain.CIOpen {
		t.Fatalf("over budget: created %d, %+v", len(w.work.created), w.store.groups[0])
	}
	// Fix it ignores the budget.
	if _, err := w.svc.FixIt(context.Background(), w.store.groups[0].ID, domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	if len(w.work.created) != 1 || w.store.groups[0].Status != domain.CIFixing {
		t.Fatal("Fix it did not open a ticket")
	}
	off := false
	w2 := newWorld(t)
	w2.st.CI.RetryFlaky = false
	w2.store.watches[1] = domain.CIWatch{RepoID: 1, Enabled: true, AutoFix: &off}
	w2.build()
	w2.failJob(10, 100, "test", testFail)
	w2.process(t, failedRun(10, "aaaaaaa1", t0))
	if len(w2.work.created) != 0 {
		t.Fatal("auto-fix off for the repository still made a ticket")
	}
}

func TestUnwatchedAndIgnored(t *testing.T) {
	w := newWorld(t)
	w.failJob(10, 100, "test", testFail)
	r := failedRun(10, "aaaaaaa1", t0)
	r.Branch = "feature/x"
	w.process(t, r)
	r2 := failedRun(11, "aaaaaaa1", t0)
	r2.Workflow, r2.Name = "deploy.yml", "Deploy"
	w.host.jobs[11] = w.host.jobs[10]
	w.process(t, r2)
	fork := failedRun(12, "aaaaaaa1", t0)
	fork.Fork = true
	w.host.jobs[12] = w.host.jobs[10]
	w.process(t, fork)
	if len(w.store.groups) != 0 {
		t.Fatalf("recorded %+v", w.store.groups)
	}
}

func TestOwnPullRequestGoesBackToItsTicket(t *testing.T) {
	w := newWorld(t)
	repoID, pr := int64(1), 7
	w.tickets.tickets["API-3"] = domain.Ticket{Key: "API-3", RepoID: &repoID, Branch: "agnts/API-3", HeadSHA: "ccccccc3", PRNumber: &pr,
		State: domain.StateDone, Kind: domain.KindCode}
	w.store.watches[1] = domain.CIWatch{RepoID: 1} // not watched: own PRs still count
	w.failJob(20, 200, "test", testFail)
	r := failedRun(20, "ccccccc3", t0)
	r.Branch = "agnts/API-3"
	w.process(t, r)
	if len(w.work.feedback) != 1 || !strings.Contains(w.work.feedback[0], "API-3\nCI failed on the pull request") ||
		!strings.Contains(w.work.feedback[0], "expected 90, got 100") {
		t.Fatalf("feedback %q", w.work.feedback)
	}
	if len(w.store.groups) != 0 {
		t.Fatal("own PR failures are not groups")
	}
	// A run on an older commit of the branch is ignored.
	old := failedRun(21, "0000000", t0)
	old.Branch = "agnts/API-3"
	w.host.jobs[21] = w.host.jobs[20]
	w.process(t, old)
	if len(w.work.feedback) != 1 {
		t.Fatal("stale run fed back")
	}
}

func TestOwnPullRequestInfraIsRerun(t *testing.T) {
	w := newWorld(t)
	repoID, pr := int64(1), 7
	w.tickets.tickets["API-3"] = domain.Ticket{Key: "API-3", RepoID: &repoID, Branch: "agnts/API-3", HeadSHA: "c3", PRNumber: &pr,
		State: domain.StateDone, Kind: domain.KindCode}
	w.failJob(20, 200, "test", "error: no space left on device")
	r := failedRun(20, "c3", t0)
	r.Branch = "agnts/API-3"
	w.process(t, r)
	if len(w.work.feedback) != 0 || !slices.Equal(w.host.reruns, []int64{20}) {
		t.Fatalf("feedback %d, reruns %v", len(w.work.feedback), w.host.reruns)
	}
}

func TestPullRequestCommentMode(t *testing.T) {
	w := newWorld(t)
	w.st.CI.RetryFlaky = false
	w.build()
	w.store.watches[1] = domain.CIWatch{RepoID: 1, Enabled: true, PRs: domain.CIPRComment}
	// main already fails the same way.
	w.failJob(10, 100, "test", testFail)
	w.process(t, failedRun(10, "aaaaaaa1", t0))
	w.failJob(30, 300, "test", testFail)
	w.failJob(30, 301, "lint", "src/a.go:3:1: error: unused variable x")
	r := failedRun(30, "ddddddd4", t0.Add(time.Hour))
	r.Branch, r.PRNumbers = "feature/x", []int{42}
	w.process(t, r)
	if len(w.host.comments) != 1 {
		t.Fatalf("comments %d", len(w.host.comments))
	}
	c := w.host.comments[0]
	if !strings.Contains(c, "Not caused by this pull request") || !strings.Contains(c, "New in this pull request") {
		t.Errorf("comment:\n%s", c)
	}
	created := len(w.work.created)
	for _, g := range w.store.groups {
		if g.PRNumber == 42 && (g.CommentID != "c1" || g.Branch != "pr/42") {
			t.Errorf("PR group %+v", g)
		}
	}
	if created != 1 { // only main's group
		t.Errorf("created %d tickets; PR failures never make tickets", created)
	}
	// Fix it refuses a PR group.
	for _, g := range w.store.groups {
		if g.PRNumber == 42 {
			if _, err := w.svc.FixIt(context.Background(), g.ID, domain.OriginWeb); err == nil {
				t.Error("Fix it on someone's PR")
			}
		}
	}
}

func TestGreenRunResolvesAndMergeThenRegression(t *testing.T) {
	w := newWorld(t)
	w.st.CI.RetryFlaky = false
	w.build()
	w.failJob(10, 100, "test", testFail)
	w.process(t, failedRun(10, "aaaaaaa1", t0))
	key := w.store.groups[0].TicketKey
	// The fix is merged.
	w.svc.TicketMerged(context.Background(), domain.Ticket{Key: key, Source: domain.SourceCI, HeadSHA: "fffffff9"})
	if g := w.store.groups[0]; g.Status != domain.CIFixed || g.FixedSHA != "fffffff9" || g.FixedAt == nil {
		t.Fatalf("after merge %+v", g)
	}
	// A green run resolves it.
	green := failedRun(12, "fffffff9", t0.Add(2*time.Hour))
	green.Conclusion = "success"
	w.process(t, green)
	if g := w.store.groups[0]; g.Status != domain.CIResolved {
		t.Fatalf("after green %+v", g)
	}

	// Another group: fixed, then failing again on a commit with the fix.
	w.failJob(13, 130, "test", goFail("TestRefund"))
	w.process(t, failedRun(13, "aaaaaaa1", t0))
	g2 := w.store.groups[1]
	w.svc.TicketMerged(context.Background(), domain.Ticket{Key: g2.TicketKey, Source: domain.SourceCI, HeadSHA: "eeeeeee8"})
	w.failJob(14, 140, "test", goFail("TestRefund"))
	w.process(t, failedRun(14, "eeeeeee9", t0.Add(3*time.Hour)))
	if g := w.store.groups[1]; g.Status != domain.CIRegression {
		t.Fatalf("regression not detected: %+v", g)
	}
}

func goFail(test string) string {
	return "--- FAIL: " + test + " (0.01s)\n    x_test.go:1: boom\nFAIL"
}

func TestSyncGivesBackRejectedAndReports(t *testing.T) {
	w := newWorld(t)
	w.store.groups = []domain.CIFailure{
		{ID: 1, RepoID: 1, Status: domain.CIFixing, TicketKey: "CI-1"},
		{ID: 2, RepoID: 1, Status: domain.CIFixing, TicketKey: "CI-2"},
		{ID: 3, RepoID: 1, Status: domain.CIFixing, TicketKey: "CI-3"},
	}
	w.tickets.tickets["CI-1"] = domain.Ticket{Key: "CI-1", State: domain.StateRejected}
	w.tickets.tickets["CI-2"] = domain.Ticket{Key: "CI-2", State: domain.StateDone, Kind: domain.KindBug}
	w.tickets.tickets["CI-3"] = domain.Ticket{Key: "CI-3", State: domain.StateCoding}
	if err := w.svc.Sync(context.Background()); err != nil {
		t.Fatal(err)
	}
	want := []domain.CIStatus{domain.CIOpen, domain.CIOpen, domain.CIFixing}
	for i, g := range w.store.groups {
		if g.Status != want[i] {
			t.Errorf("group %d: %s, want %s", g.ID, g.Status, want[i])
		}
	}
	if w.store.groups[1].Class != "report" {
		t.Errorf("report class %q", w.store.groups[1].Class)
	}
}

func TestRerunRefusedBelievesFailure(t *testing.T) {
	w := newWorld(t)
	w.host.rerunErr = io.ErrUnexpectedEOF
	w.failJob(10, 100, "test", testFail)
	w.process(t, failedRun(10, "aaaaaaa1", t0))
	if g := w.store.groups[0]; g.Status != domain.CIFixing || len(w.work.created) != 1 {
		t.Fatalf("group %+v created %d", g, len(w.work.created))
	}
}
