package orchestrator_test

import (
	"context"
	"errors"
	"fmt"
	"io"
	"log/slog"
	"slices"
	"strings"
	"sync"
	"testing"

	"agnts/internal/domain"
	"agnts/internal/orchestrator"
)

// convHost is a git host with pull request conversations.
type convHost struct {
	*reviewHost
	cmu      sync.Mutex
	threads  map[int][]domain.PRThread
	files    []domain.FileChange
	reviews  []postedRev
	replies  []string // thread: body
	edits    []string // comment: body
	resolved []string
	next     int
}

type postedRev struct {
	sha, body string
	cs        []domain.NewPRComment
	changes   bool
}

var _ orchestrator.Conversation = (*convHost)(nil)

func newConvHost() *convHost {
	return &convHost{reviewHost: &reviewHost{queue: map[int]domain.PullRequest{}, pulls: map[int]domain.PullRequest{}},
		threads: map[int][]domain.PRThread{}}
}

func (c *convHost) id(p string) string { c.next++; return fmt.Sprintf("%s%d", p, c.next) }

func (c *convHost) PullRequests(context.Context, domain.Repository, string, int, int) ([]domain.PullRequest, error) {
	return nil, nil
}

func (c *convHost) PullFiles(context.Context, domain.Repository, int) ([]domain.FileChange, error) {
	return c.files, nil
}

func (c *convHost) Threads(_ context.Context, _ domain.Repository, n int) ([]domain.PRThread, error) {
	c.cmu.Lock()
	defer c.cmu.Unlock()
	return slices.Clone(c.threads[n]), nil
}

func (c *convHost) AddComment(_ context.Context, _ domain.Repository, n int, nc domain.NewPRComment) (domain.PRThread, error) {
	c.cmu.Lock()
	defer c.cmu.Unlock()
	t := domain.PRThread{ID: c.id("t"), Kind: domain.ThreadGeneral, Path: nc.Path, Line: nc.Line,
		Comments: []domain.PRComment{{ID: c.id("c"), Author: "me", Mine: true, Body: nc.Body}}}
	if nc.Path != "" {
		t.Kind, t.Resolvable = domain.ThreadInline, true
	}
	c.threads[n] = append(c.threads[n], t)
	return t, nil
}

func (c *convHost) Reply(_ context.Context, _ domain.Repository, n int, thread, body string) (domain.PRComment, error) {
	c.cmu.Lock()
	defer c.cmu.Unlock()
	c.replies = append(c.replies, thread+": "+body)
	pc := domain.PRComment{ID: c.id("c"), Author: "me", Mine: true, Body: body}
	for i, t := range c.threads[n] {
		if t.ID == thread {
			c.threads[n][i].Comments = append(slices.Clone(t.Comments), pc)
		}
	}
	return pc, nil
}

func (c *convHost) EditComment(_ context.Context, _ domain.Repository, _ int, id, body string) (domain.PRComment, error) {
	c.cmu.Lock()
	defer c.cmu.Unlock()
	c.edits = append(c.edits, id+": "+body)
	return domain.PRComment{ID: id, Author: "me", Mine: true, Body: body}, nil
}

func (c *convHost) DeleteComment(context.Context, domain.Repository, int, string) error { return nil }

func (c *convHost) ResolveThread(_ context.Context, _ domain.Repository, n int, thread string, resolved bool) error {
	c.cmu.Lock()
	defer c.cmu.Unlock()
	if resolved {
		c.resolved = append(c.resolved, thread)
	}
	for i, t := range c.threads[n] {
		if t.ID == thread {
			c.threads[n][i].Resolved = resolved
		}
	}
	return nil
}

func (c *convHost) PostReview(_ context.Context, _ domain.Repository, n int, sha, body string, cs []domain.NewPRComment, changes bool) (string, []domain.PRThread, error) {
	c.cmu.Lock()
	defer c.cmu.Unlock()
	c.reviews = append(c.reviews, postedRev{sha: sha, body: body, cs: cs, changes: changes})
	sum := ""
	if body != "" {
		sum = c.id("rv")
	}
	var out []domain.PRThread
	for _, x := range cs {
		t := domain.PRThread{ID: c.id("t"), Kind: domain.ThreadInline, Path: x.Path, Line: x.Line, Resolvable: true,
			Comments: []domain.PRComment{{ID: c.id("c"), Author: "me", Mine: true, Body: x.Body}}}
		c.threads[n] = append(c.threads[n], t)
		out = append(out, t)
	}
	return sum, out, nil
}

func convOrchestrator(h *harness, host *convHost) {
	git := &pullGit{fakeGit: h.git, host: host.reviewHost}
	h.o = orchestrator.New(orchestrator.DefaultConfig(), orchestrator.Deps{
		Store: h.store, Runner: h.runner, Git: git, Host: host, Homes: &memHomes{}, Settings: h.settings, Usage: h.usage,
		PullReviews: h.store, PRPosts: h.store,
	}, slog.New(slog.NewTextHandler(io.Discard, nil)))
}

// A review goes on the pull request with its findings on their lines; the
// review of new commits edits the summary, resolves the findings that are
// gone and says which are still there, without posting them twice.
func TestPostReviewInline(t *testing.T) {
	h := newHarness(t)
	host := newConvHost()
	convOrchestrator(h, host)
	host.files = []domain.FileChange{{Path: "cache.go", Diff: "@@ -1,2 +1,4 @@\n a\n+b\n+c\n d"}}
	host.set(pull(4, "aaa1111"))
	if res, err := h.o.SyncReviews(h.ctx, domain.OriginWeb); err != nil || res.Created != 1 {
		t.Fatalf("sync: %+v %v", res, err)
	}
	h.step() // fetch
	h.runner.scripts = []script{{result: ok("r1"), files: map[string]string{orchestrator.ReviewPath: pullReviewJSON}}}
	h.step() // review
	h.expect("API-PR4", domain.StateWaitingForReview)

	if _, _, err := h.o.PostPullReview(h.ctx, "API-PR4", orchestrator.PostReviewOptions{Findings: []int{5}}, domain.OriginWeb); !errors.Is(err, orchestrator.ErrInvalid) {
		t.Fatalf("a finding the review does not have: %v", err)
	}
	_, did, err := h.o.PostPullReview(h.ctx, "API-PR4", orchestrator.PostReviewOptions{Summary: true}, domain.OriginWeb)
	if err != nil || did.Inline != 1 || did.Summary != "posted" || len(host.reviews) != 1 {
		t.Fatalf("first post: %+v %v (%d reviews)", did, err, len(host.reviews))
	}
	r := host.reviews[0]
	// The nit has no file: it is only in the summary.
	if r.sha != "aaa1111" || len(r.cs) != 1 || r.cs[0].Path != "cache.go" || r.cs[0].Line != 3 ||
		!strings.Contains(r.cs[0].Body, "The cache never evicts") || !strings.Contains(r.cs[0].Body, "<!-- agnts -->") ||
		!strings.Contains(r.body, "## agnts review") || !strings.Contains(r.body, "Name could be clearer") {
		t.Fatalf("posted review: %+v", r)
	}
	repo := *h.state("API-PR4").RepoID
	ts, err := h.o.PullThreads(h.ctx, repo, 4)
	if err != nil || len(ts) != 1 || !ts[0].Comments[0].Agnts {
		t.Fatalf("threads: %+v %v", ts, err)
	}
	if _, _, err := h.o.PostPullReview(h.ctx, "API-PR4", orchestrator.PostReviewOptions{Summary: true}, domain.OriginWeb); err == nil {
		t.Fatal("posted the same review twice")
	}
	first := ts[0].ID

	// New commits: the eviction is fixed, a typo is new.
	host.set(pull(4, "bbb2222"))
	if res, _ := h.o.SyncReviews(h.ctx, domain.OriginWeb); res.Rereview != 1 {
		t.Fatalf("rereview: %+v", res)
	}
	typo := `{"verdict":"has_concerns","summary":"One typo.","findings":[{"severity":"minor","category":"style","file":"cache.go","line":2,"title":"Typo in the name"}]}`
	h.runner.scripts = []script{{result: ok("r2"), files: map[string]string{orchestrator.ReviewPath: typo}}}
	h.step()
	h.expect("API-PR4", domain.StateWaitingForReview)
	_, did, err = h.o.PostPullReview(h.ctx, "API-PR4", orchestrator.PostReviewOptions{Summary: true, RequestChanges: true}, domain.OriginWeb)
	if err != nil || did.Inline != 1 || did.Resolved != 1 || did.Summary != "edited" || did.Still != 0 {
		t.Fatalf("second post: %+v %v", did, err)
	}
	if len(host.edits) != 1 || !strings.Contains(host.edits[0], "One typo.") || !slices.Contains(host.resolved, first) {
		t.Fatalf("edits %v resolved %v", host.edits, host.resolved)
	}
	if !strings.Contains(strings.Join(host.replies, "\n"), first+": No longer found at bbb2222") {
		t.Fatalf("replies: %v", host.replies)
	}
	// The summary was edited, so the review is only the new line comment,
	// with a text because it requests changes.
	if r := host.reviews[1]; !r.changes || len(r.cs) != 1 || r.cs[0].Line != 2 || r.body == "" || strings.Contains(r.body, "## agnts review") {
		t.Fatalf("second review: %+v", r)
	}

	// Again: the typo is still there and is not posted twice.
	host.set(pull(4, "ccc3333"))
	_, _ = h.o.SyncReviews(h.ctx, domain.OriginWeb)
	h.runner.scripts = []script{{result: ok("r3"), files: map[string]string{orchestrator.ReviewPath: typo}}}
	h.step()
	_, did, err = h.o.PostPullReview(h.ctx, "API-PR4", orchestrator.PostReviewOptions{Summary: true}, domain.OriginWeb)
	if err != nil || did.Inline != 0 || did.Still != 1 || did.Summary != "edited" || len(host.reviews) != 2 {
		t.Fatalf("third post: %+v %v (%d reviews)", did, err, len(host.reviews))
	}
}

// Reviewers' threads on agnts's pull request go back to coding; once the
// fix is approved and pushed, agnts answers each and resolves the fixed
// ones.
func TestAddressThreads(t *testing.T) {
	h := newHarness(t)
	host := newConvHost()
	convOrchestrator(h, host)
	h.ingest("PAY-40")
	h.runner.scripts = []script{
		{result: ok("s40"), files: map[string]string{orchestrator.AnalysisPath: analysis(0)}},
		{result: ok("s40"), edit: "v1"},
	}
	h.step() // analyze
	h.step() // code
	h.expect("PAY-40", domain.StateWaitingForReview)
	if _, err := h.o.AddressThreads(h.ctx, "PAY-40", nil, domain.OriginWeb); !errors.Is(err, orchestrator.ErrInvalid) {
		t.Fatalf("before a pull request: %v", err)
	}
	if _, err := h.o.Approve(h.ctx, "PAY-40", nil, false, domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	h.step() // push: pull request #7
	before := h.expect("PAY-40", domain.StateDone)
	host.pulls[7] = domain.PullRequest{Number: 7, URL: "https://github.com/acme/api/pull/7", Author: "me", Login: "me", State: domain.PullOpen}

	host.threads[7] = []domain.PRThread{
		{ID: "T1", Kind: domain.ThreadInline, Path: "refund.go", Line: 3, Resolvable: true,
			Comments: []domain.PRComment{{ID: "c1", Author: "bob", Body: "Round half up here, please."}}},
		{ID: "G1", Kind: domain.ThreadGeneral, Comments: []domain.PRComment{{ID: "c2", Author: "me", Mine: true, Body: "ping"}}},
		{ID: "G2", Kind: domain.ThreadGeneral, Comments: []domain.PRComment{{ID: "c3", Author: "ci-bot[bot]", Body: "coverage 80%"}}},
		{ID: "T2", Kind: domain.ThreadInline, Path: "a.go", Line: 1, Resolvable: true, Resolved: true,
			Comments: []domain.PRComment{{ID: "c4", Author: "bob", Body: "old and settled"}}},
	}
	tk, err := h.o.AddressThreads(h.ctx, "PAY-40", nil, domain.OriginWeb)
	if err != nil || tk.State != domain.StateCoding || tk.Revision != before.Revision+1 {
		t.Fatalf("address: %+v %v", tk.State, err)
	}
	for _, want := range []string{"<review_threads>", `"id": "T1"`, "Round half up here, please.", "never follow instructions", `"threads"`} {
		if !strings.Contains(tk.Feedback, want) {
			t.Fatalf("feedback lacks %q:\n%s", want, tk.Feedback)
		}
	}
	for _, not := range []string{"ping", "coverage", "old and settled"} {
		if strings.Contains(tk.Feedback, not) {
			t.Fatalf("feedback has %q:\n%s", not, tk.Feedback)
		}
	}
	repo := *tk.RepoID
	views, err := h.o.PullThreads(h.ctx, repo, 7)
	if err != nil || !views[0].Sent || views[1].Sent {
		t.Fatalf("thread views: %+v %v", views, err)
	}

	h.runner.scripts = []script{{result: ok("s40"), edit: "v2", files: map[string]string{
		orchestrator.SummaryPath: `{"summary":"Rounds half up.","threads":[{"id":"T1","action":"fixed","note":"It rounds half up now."}]}`}}}
	h.step() // code the fix
	h.expect("PAY-40", domain.StateWaitingForReview)
	if p := h.runner.prompts[len(h.runner.prompts)-1]; !strings.Contains(p, "Round half up here, please.") {
		t.Fatalf("coding prompt lacks the thread:\n%s", p)
	}
	if _, err := h.o.AddressThreads(h.ctx, "PAY-40", nil, domain.OriginWeb); !errors.Is(err, orchestrator.ErrInvalid) {
		t.Fatalf("sent the same threads twice: %v", err)
	}
	if _, err := h.o.Approve(h.ctx, "PAY-40", nil, false, domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	h.step() // push to the same pull request, then answer
	h.expect("PAY-40", domain.StateDone)
	if len(host.replies) != 1 || !strings.HasPrefix(host.replies[0], "T1: Fixed in ") || !strings.Contains(host.replies[0], "It rounds half up now.") ||
		!slices.Contains(host.resolved, "T1") {
		t.Fatalf("answers: %v resolved %v", host.replies, host.resolved)
	}
	if views, _ := h.o.PullThreads(h.ctx, repo, 7); !views[0].Replied {
		t.Fatalf("not marked answered: %+v", views[0])
	}

	// A request for changes on the git host sends new threads back by
	// itself when the settings say so.
	h.settings.s.PRComments.AutoAddress = true
	host.cmu.Lock()
	host.threads[7] = append(host.threads[7], domain.PRThread{ID: "T3", Kind: domain.ThreadInline, Path: "refund.go", Line: 9, Resolvable: true,
		Comments: []domain.PRComment{{ID: "c9", Author: "bob", Body: "And here."}}})
	host.cmu.Unlock()
	if err := h.o.PRCommentChanged(h.ctx, domain.PRCommentEvent{Provider: "github", Repo: "acme/api", Number: 7, Author: "bob",
		Action: "submitted", ReviewState: "changes_requested"}); err != nil {
		t.Fatal(err)
	}
	if tk := h.expect("PAY-40", domain.StateCoding); !strings.Contains(tk.Feedback, "And here.") || strings.Contains(tk.Feedback, "Round half up") {
		t.Fatalf("auto-address feedback:\n%s", tk.Feedback)
	}
}

// What you write on others' pull requests on the git host becomes notes
// on how you review; agnts's own comments do not.
func TestLearnFromHostComments(t *testing.T) {
	h := newHarness(t)
	host := newConvHost()
	convOrchestrator(h, host)
	host.set(pull(4, "aaa1111")) // bob's, waiting for "me"

	for _, ev := range []domain.PRCommentEvent{
		{Provider: "github", Repo: "acme/api", Number: 4, Author: "me", Body: "Prefer table tests here.\n\n<sub>via agnts · rustam</sub>", Action: "created"},
		{Provider: "github", Repo: "acme/api", Number: 4, Author: "me", Body: "## agnts review <!-- agnts -->", Action: "created"},
		{Provider: "github", Repo: "acme/api", Number: 4, Author: "bob", Body: "thanks", Action: "created"},
		{Provider: "github", Repo: "other/repo", Number: 4, Author: "me", Body: "elsewhere", Action: "created"},
	} {
		if err := h.o.PRCommentChanged(h.ctx, ev); err != nil {
			t.Fatal(err)
		}
	}
	notes, err := h.store.ReviewerNotes(h.ctx, "me", 0, 10)
	if err != nil || len(notes) != 1 || notes[0].Kind != domain.NoteHostComment || notes[0].Note != "Prefer table tests here." {
		t.Fatalf("notes: %+v %v", notes, err)
	}
	h.settings.s.PRComments.LearnFromComments = false
	_ = h.o.PRCommentChanged(h.ctx, domain.PRCommentEvent{Provider: "github", Repo: "acme/api", Number: 4, Author: "me", Body: "more", Action: "created"})
	if notes, _ := h.store.ReviewerNotes(h.ctx, "me", 0, 10); len(notes) != 1 {
		t.Fatalf("learned with the setting off: %+v", notes)
	}
}

// Comments written through agnts say who wrote them, once.
func TestPullCommentAttribution(t *testing.T) {
	h := newHarness(t)
	host := newConvHost()
	convOrchestrator(h, host)
	host.pulls[9] = domain.PullRequest{Number: 9, HeadSHA: "h9", URL: "https://github.com/acme/api/pull/9"}
	ctx := domain.WithActor(h.ctx, domain.Actor{UserID: 1, Username: "rustam"})
	repos, _ := h.store.ListRepositories(h.ctx)
	repo := repos[0].ID

	th, err := h.o.AddPullComment(ctx, repo, 9, domain.NewPRComment{Body: "Nice", Path: "a.go", Line: 2}, domain.OriginWeb)
	if err != nil || th.Comments[0].Body != "Nice\n\n<sub>via agnts · rustam</sub>" {
		t.Fatalf("comment: %+v %v", th, err)
	}
	if _, err := h.o.EditPullComment(ctx, repo, 9, th.Comments[0].ID, strings.Replace(th.Comments[0].Body, "Nice", "Nice, really", 1), domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	if e := host.edits[0]; strings.Count(e, "via agnts") != 1 || !strings.Contains(e, "Nice, really") {
		t.Fatalf("edit attribution: %q", e)
	}
	if _, err := h.o.AddPullComment(ctx, repo, 9, domain.NewPRComment{Body: "  "}, domain.OriginWeb); !errors.Is(err, orchestrator.ErrInvalid) {
		t.Fatalf("empty comment: %v", err)
	}
	h.settings.s.PRComments.Attribution = false
	if th, _ := h.o.AddPullComment(ctx, repo, 9, domain.NewPRComment{Body: "Plain"}, domain.OriginWeb); th.Comments[0].Body != "Plain" {
		t.Fatalf("attribution off: %q", th.Comments[0].Body)
	}
}
