package orchestrator_test

import (
	"errors"
	"io"
	"log/slog"
	"strings"
	"sync"
	"testing"

	"agnts/internal/domain"
	"agnts/internal/orchestrator"
	"agnts/internal/store/postgres/pgtest"
)

// draftsHarness is a harness with a git host that has conversations, and
// a person acting in agnts.
func draftsHarness(t *testing.T) (*harness, *convHost, *pullGit) {
	h := newHarness(t)
	host := newConvHost()
	git := &pullGit{fakeGit: h.git, host: host.reviewHost}
	h.o = orchestrator.New(orchestrator.DefaultConfig(), orchestrator.Deps{
		Store: h.store, Runner: h.runner, Git: git, Host: host, Homes: &memHomes{}, Settings: h.settings, Usage: h.usage,
		PullReviews: h.store, PRPosts: h.store, ReviewDrafts: h.store,
	}, slog.New(slog.NewTextHandler(io.Discard, nil)))
	pool := pgtest.Open(t)
	h.ctx = domain.WithActor(h.ctx, domain.Actor{UserID: pgtest.User(t, pool, "rustam"), Username: "rustam"})
	diff := "@@ -1,2 +1,4 @@\n a\n+b\n+c\n d"
	host.files = []domain.FileChange{{Path: "cache.go", Diff: diff}}
	git.prFiles = []domain.FileChange{{Path: "cache.go", Add: 2, Diff: diff}}
	return h, host, git
}

// unassigned is a pull request waiting for someone else.
func unassigned(n int, sha string) domain.PullRequest {
	p := pull(n, sha)
	p.Why, p.BaseSHA, p.StartSHA = "", "base0", "start0"
	return p
}

func (h *harness) drafts(key string) map[string]domain.ReviewDraft {
	h.t.Helper()
	ds, err := h.o.TicketDrafts(h.ctx, key)
	if err != nil {
		h.t.Fatal(err)
	}
	out := map[string]domain.ReviewDraft{}
	for _, d := range ds {
		k := d.Kind
		if d.Kind == domain.DraftFinding {
			k = d.Title
		}
		if d.Kind == domain.DraftComment {
			k = "comment:" + d.Body
		}
		out[k] = d
	}
	return out
}

func (h *harness) decide(key string, id int64, state string, reason string) domain.ReviewDraft {
	h.t.Helper()
	ch := orchestrator.DraftChange{State: &state}
	if reason != "" {
		ch.Reason = &reason
	}
	d, err := h.o.UpdateDraft(h.ctx, key, id, ch, domain.OriginWeb)
	if err != nil {
		h.t.Fatalf("%s draft %d: %v", state, id, err)
	}
	return d
}

const evicts, nit = "The cache never evicts", "Name could be clearer"

// A review asked for from the pull request page: for any open pull
// request, once at a time, with the person's focus; it is kept up to date
// with the sync off, and approving it never merges.
func TestReviewPullManual(t *testing.T) {
	h, host, _ := draftsHarness(t)
	host.pulls[9] = unassigned(9, "aaa1111")
	closed := unassigned(10, "fff")
	closed.State = domain.PullClosed
	host.pulls[10] = closed
	repo := int64(1)

	if _, err := h.o.ReviewPull(h.ctx, repo, 10, orchestrator.ReviewPullOptions{}, domain.OriginWeb); !errors.Is(err, orchestrator.ErrInvalid) {
		t.Fatalf("a closed pull request: %v", err)
	}
	if _, err := h.o.ReviewPull(h.ctx, repo, 9, orchestrator.ReviewPullOptions{Deep: "sometimes"}, domain.OriginWeb); !errors.Is(err, orchestrator.ErrInvalid) {
		t.Fatalf("an unknown deep choice: %v", err)
	}
	tk, err := h.o.ReviewPull(h.ctx, repo, 9, orchestrator.ReviewPullOptions{Focus: "the migration", Deep: domain.DeepAlways}, domain.OriginWeb)
	if err != nil {
		t.Fatal(err)
	}
	if tk.Key != "API-PR9" || tk.Kind != domain.KindReview || tk.AfterApprove != domain.AfterApproveNone ||
		tk.Pull.Focus != "the migration" || tk.CreatedBy == nil {
		t.Fatalf("ticket: %+v pull %+v", tk, tk.Pull)
	}
	var exists *orchestrator.ReviewExistsError
	if _, err := h.o.ReviewPull(h.ctx, repo, 9, orchestrator.ReviewPullOptions{}, domain.OriginWeb); !errors.As(err, &exists) ||
		exists.Key != "API-PR9" || !errors.Is(err, domain.ErrConflict) {
		t.Fatalf("asked twice: %v", err)
	}

	h.step() // fetch
	h.runner.scripts = []script{{result: ok("r1"), files: map[string]string{orchestrator.ReviewPath: pullReviewJSON}}}
	h.step() // review
	h.expect("API-PR9", domain.StateWaitingForReview)
	p := h.runner.prompts[0]
	for _, want := range []string{"What to look at especially", "the migration", "Specialist passes"} {
		if !strings.Contains(p, want) {
			t.Fatalf("prompt lacks %q:\n%s", want, p)
		}
	}
	ds := h.drafts("API-PR9")
	if len(ds) != 3 || ds[evicts].State != domain.DraftOpen || ds[evicts].Line != 3 || ds[evicts].BaseSHA != "base0" ||
		!strings.Contains(ds["summary"].Body, "## agnts review") || strings.Contains(ds["summary"].Body, evicts) {
		t.Fatalf("drafts: %+v", ds)
	}
	// A person's rewrite survives the review of new commits.
	body := "Bound the cache, please."
	if _, err := h.o.UpdateDraft(h.ctx, "API-PR9", ds[evicts].ID, orchestrator.DraftChange{Body: &body}, domain.OriginWeb); err != nil {
		t.Fatal(err)
	}

	// New commits: the sync records them, and the review is asked to look
	// again.
	host.mu.Lock()
	p2 := unassigned(9, "bbb2222")
	p2.BaseSHA = "base1"
	host.pulls[9] = p2
	host.mu.Unlock()
	if res, err := h.o.SyncReviews(h.ctx, domain.OriginSystem); err != nil || res.Rereview != 0 || res.Open != 1 {
		t.Fatalf("sync: %+v %v", res, err)
	}
	if _, err := h.o.RequestChanges(h.ctx, "API-PR9", "Look at the new commits.", nil, nil, domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	if tk := h.state("API-PR9"); tk.Pull.Focus != "the migration" || tk.Pull.HeadSHA != "bbb2222" {
		t.Fatalf("the sync dropped what the review was asked for: %+v", tk.Pull)
	}
	h.runner.scripts = []script{{result: ok("r2"), files: map[string]string{orchestrator.ReviewPath: pullReviewJSON}}}
	h.step()
	ds = h.drafts("API-PR9")
	if d := ds[evicts]; d.Body != body || !d.Edited || d.HeadSHA != "bbb2222" || d.BaseSHA != "base1" {
		t.Fatalf("after the re-review: %+v", d)
	}

	// Approving finishes the review and leaves the pull request alone.
	if _, err := h.o.Approve(h.ctx, "API-PR9", nil, false, domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	h.step()
	h.expect("API-PR9", domain.StateDone)
	if len(host.merges) != 0 {
		t.Fatalf("merged a pull request that was not ours: %v", host.merges)
	}
	// It can be asked for again.
	if tk, err := h.o.ReviewPull(h.ctx, repo, 9, orchestrator.ReviewPullOptions{}, domain.OriginWeb); err != nil || tk.Key != "API-PR9-2" {
		t.Fatalf("again: %+v %v", tk.Key, err)
	}
}

// Only the drafts a person accepts reach the git host; the rest stay in
// agnts. Publishing can happen again for drafts accepted later, never
// posts a draft twice, and anchors comments on the commit agnts reviewed.
func TestPublishDrafts(t *testing.T) {
	h, host, _ := draftsHarness(t)
	host.pulls[9] = unassigned(9, "aaa1111")
	if _, err := h.o.ReviewPull(h.ctx, 1, 9, orchestrator.ReviewPullOptions{}, domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	h.step()
	h.runner.scripts = []script{{result: ok("r1"), files: map[string]string{orchestrator.ReviewPath: pullReviewJSON}}}
	h.step()
	const key = "API-PR9"
	ds := h.drafts(key)

	if _, _, err := h.o.PublishDrafts(h.ctx, key, orchestrator.PublishOptions{}, domain.OriginWeb); !errors.Is(err, orchestrator.ErrInvalid) {
		t.Fatalf("nothing accepted: %v", err)
	}
	h.decide(key, ds[evicts].ID, domain.DraftAccepted, "")
	h.decide(key, ds[nit].ID, domain.DraftDismissed, "Naming is not my concern.")
	notes, _ := h.store.ReviewerNotes(h.ctx, "me", 0, 10)
	if len(notes) != 1 || notes[0].Kind != domain.NoteDraft || !strings.Contains(notes[0].Note, "Naming is not my concern.") {
		t.Fatalf("notes: %+v", notes)
	}
	c, err := h.o.AddDraftComment(h.ctx, key, domain.NewPRComment{Body: "Please add a test.", Path: "cache.go", Line: 2})
	if err != nil || c.State != domain.DraftAccepted || c.HeadSHA != "aaa1111" || c.Author != "rustam" {
		t.Fatalf("own comment: %+v %v", c, err)
	}

	tk, did, err := h.o.PublishDrafts(h.ctx, key, orchestrator.PublishOptions{}, domain.OriginWeb)
	if err != nil || did.Inline != 2 || did.Summary != "" || len(host.reviews) != 1 {
		t.Fatalf("publish: %+v %v (%d reviews)", did, err, len(host.reviews))
	}
	r := host.reviews[0]
	byLine := map[int]string{}
	for _, c := range r.cs {
		byLine[c.Line] = c.Body
	}
	if r.sha != "aaa1111" || r.body != "" || len(r.cs) != 2 ||
		!strings.Contains(byLine[3], evicts) || !strings.Contains(byLine[3], "<!-- agnts -->") ||
		!strings.Contains(byLine[2], "Please add a test.") || !strings.Contains(byLine[2], "via agnts · rustam") || strings.Contains(byLine[2], "<!-- agnts -->") {
		t.Fatalf("review: %+v", r)
	}
	if tk.Pull.PostedSHA != "aaa1111" {
		t.Fatalf("posted mark: %+v", tk.Pull)
	}
	ds = h.drafts(key)
	body := "x"
	if ds[evicts].State != domain.DraftPublished || ds["comment:Please add a test."].State != domain.DraftPublished ||
		ds[nit].State != domain.DraftDismissed || ds["summary"].State != domain.DraftOpen {
		t.Fatalf("after publishing: %+v", ds)
	}
	if _, err := h.o.UpdateDraft(h.ctx, key, ds[evicts].ID, orchestrator.DraftChange{Body: &body}, domain.OriginWeb); !errors.Is(err, orchestrator.ErrInvalid) {
		t.Fatalf("edited a published draft: %v", err)
	}
	if _, _, err := h.o.PublishDrafts(h.ctx, key, orchestrator.PublishOptions{}, domain.OriginWeb); !errors.Is(err, orchestrator.ErrInvalid) {
		t.Fatalf("published nothing twice: %v", err)
	}

	// The summary, later: the dismissed nit does not leak into it.
	h.decide(key, ds["summary"].ID, domain.DraftAccepted, "")
	_, did, err = h.o.PublishDrafts(h.ctx, key, orchestrator.PublishOptions{}, domain.OriginWeb)
	if err != nil || did.Summary != "posted" || did.Inline != 0 || len(host.reviews) != 2 {
		t.Fatalf("summary: %+v %v", did, err)
	}
	if b := host.reviews[1].body; !strings.Contains(b, "Adds a cache without eviction.") || strings.Contains(b, nit) {
		t.Fatalf("summary body:\n%s", b)
	}

	// Two publishes at once post once.
	for _, txt := range []string{"One.", "Two."} {
		if _, err := h.o.AddDraftComment(h.ctx, key, domain.NewPRComment{Body: txt}); err != nil {
			t.Fatal(err)
		}
	}
	var wg sync.WaitGroup
	errs := make([]error, 2)
	for i := range 2 {
		wg.Go(func() { _, _, errs[i] = h.o.PublishDrafts(h.ctx, key, orchestrator.PublishOptions{}, domain.OriginWeb) })
	}
	wg.Wait()
	if len(host.reviews) != 3 || (errs[0] == nil) == (errs[1] == nil) {
		t.Fatalf("concurrent: %d reviews, errors %v", len(host.reviews), errs)
	}
	if b := host.reviews[2].body; !strings.Contains(b, "Not on a changed line") || !strings.Contains(b, "One.") || !strings.Contains(b, "Two.") {
		t.Fatalf("general comments:\n%s", b)
	}

	// New commits nobody reviewed yet: a comment accepted now still goes
	// on the version agnts reviewed, with that version's diff.
	host.mu.Lock()
	host.pulls[9] = unassigned(9, "ccc3333")
	host.mu.Unlock()
	host.files = nil
	h.decide(key, ds[nit].ID, domain.DraftOpen, "")
	if _, err := h.o.AddDraftComment(h.ctx, key, domain.NewPRComment{Body: "Old line.", Path: "cache.go", Line: 3, HeadSHA: "aaa1111"}); err != nil {
		t.Fatal(err)
	}
	if _, _, err := h.o.PublishDrafts(h.ctx, key, orchestrator.PublishOptions{}, domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	if r := host.reviews[3]; r.sha != "aaa1111" || len(r.cs) != 1 || r.cs[0].HeadSHA != "aaa1111" || r.cs[0].Line != 3 {
		t.Fatalf("on the reviewed commit: %+v", r)
	}

	// Closed on the git host: the drafts can only be read.
	host.close(9, domain.PullMerged)
	host.mu.Lock()
	host.pulls[9] = func() domain.PullRequest { p := unassigned(9, "ccc3333"); p.State = domain.PullMerged; return p }()
	host.mu.Unlock()
	h.decide(key, ds[nit].ID, domain.DraftAccepted, "")
	if _, _, err := h.o.PublishDrafts(h.ctx, key, orchestrator.PublishOptions{}, domain.OriginWeb); !errors.Is(err, orchestrator.ErrInvalid) {
		t.Fatalf("published on a merged pull request: %v", err)
	}
	if ds := h.drafts(key); ds[nit].State != domain.DraftAccepted {
		t.Fatalf("a refused publish lost the acceptance: %+v", ds[nit])
	}
}

// The token's user cannot request changes on their own pull request: the
// review goes out as comments instead of failing.
func TestPublishDraftsOwnPull(t *testing.T) {
	h, host, _ := draftsHarness(t)
	p := unassigned(9, "aaa1111")
	p.Author = p.Login // the token's user opened it
	host.pulls[9] = p
	if _, err := h.o.ReviewPull(h.ctx, 1, 9, orchestrator.ReviewPullOptions{}, domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	h.step()
	h.runner.scripts = []script{{result: ok("r1"), files: map[string]string{orchestrator.ReviewPath: pullReviewJSON}}}
	h.step()
	h.decide("API-PR9", h.drafts("API-PR9")[evicts].ID, domain.DraftAccepted, "")
	_, did, err := h.o.PublishDrafts(h.ctx, "API-PR9", orchestrator.PublishOptions{RequestChanges: true}, domain.OriginWeb)
	if err != nil || did.Inline != 1 || len(host.reviews) != 1 || host.reviews[0].changes || host.reviews[0].body != "" {
		t.Fatalf("own pull request: %+v %v %+v", did, err, host.reviews)
	}
}
