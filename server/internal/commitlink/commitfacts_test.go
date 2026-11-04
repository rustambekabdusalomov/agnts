package commitlink

import (
	"context"
	"io"
	"log/slog"
	"slices"
	"testing"
	"time"

	"agnts/internal/domain"
)

// mergeStore is memStore with the pull request lookups.
type mergeStore struct {
	*memStore
	pulls     map[string]domain.CommitPull // by sha
	prCommits map[int][]domain.PushedCommit
	marked    []domain.DefaultCommit
}

func (m *mergeStore) CommitPulls(_ context.Context, _ int64, shas []string) (map[string]domain.CommitPull, error) {
	out := map[string]domain.CommitPull{}
	for _, sha := range shas {
		if cp, ok := m.pulls[sha]; ok {
			out[sha] = cp
		}
	}
	return out, nil
}

func (m *mergeStore) SaveCommitPull(_ context.Context, _ int64, sha string, cp domain.CommitPull) error {
	m.pulls[sha] = cp
	return nil
}

func (m *mergeStore) SavePullCommits(_ context.Context, _ int64, n int, cs []domain.PushedCommit) error {
	m.prCommits[n] = cs
	return nil
}

func (m *mergeStore) MarkOnDefault(_ context.Context, _ int64, facts []domain.DefaultCommit) error {
	m.marked = append(m.marked, facts...)
	return nil
}

// mergeHost is fakeHost with pull requests.
type mergeHost struct {
	*fakeHost
	merges  map[string][]domain.MergedPull // by sha
	commits map[int][]domain.PushedCommit
	asked   []string
}

func (h *mergeHost) CommitMerges(_ context.Context, _ domain.Repository, sha string) ([]domain.MergedPull, error) {
	h.asked = append(h.asked, sha)
	return h.merges[sha], nil
}

func (h *mergeHost) PullCommits(_ context.Context, _ domain.Repository, n int) ([]domain.PushedCommit, error) {
	return h.commits[n], nil
}

func mergeSetup() (*Service, *mergeStore, *mergeHost) {
	_, mem, fh := setup()
	st := &mergeStore{memStore: mem, pulls: map[string]domain.CommitPull{}, prCommits: map[int][]domain.PushedCommit{}}
	h := &mergeHost{fakeHost: fh, merges: map[string][]domain.MergedPull{}, commits: map[int][]domain.PushedCommit{}}
	s := New(st, h, slog.New(slog.NewTextHandler(io.Discard, nil)))
	s.async = func(f func()) { f() }
	return s, st, h
}

// A squash on the default branch without the ticket's number is linked
// through its pull request's title, marked a squash, and its pull
// request's commits are kept for the shares.
func TestSquashLinksThroughPullRequest(t *testing.T) {
	s, st, h := mergeSetup()
	squash := commit("SQ1", "Add login (#7)")
	squash.Parents = []string{"base"}
	squash.AuthorEmail = "alice@x.io"
	own := []domain.PushedCommit{commit("b1", "wip"), commit("b2", "Add login")}
	h.ahead["base..SQ1"] = []domain.PushedCommit{squash}
	h.merges["sq1"] = []domain.MergedPull{{Number: 7, Title: "VIS-3: Add login", HeadBranch: "alice/login", BaseBranch: "main", MergeSHA: "sq1"}}
	h.commits[7] = own
	err := s.Push(context.Background(), domain.Push{Provider: "github", Repo: "acme/api", Branch: "main", Before: "base", After: "SQ1",
		Commits: []domain.PushedCommit{squash}, Total: 1})
	if err != nil {
		t.Fatal(err)
	}
	got := st.linksOf(3)
	if len(got) != 1 || got[0].SHA != "sq1" || !slices.Equal(got[0].MatchedOn, []string{domain.MatchPullRequest}) ||
		got[0].MergeKind != domain.MergeKindSquash || got[0].PRNumber == nil || *got[0].PRNumber != 7 || got[0].OnDefaultAt == nil ||
		got[0].AuthorEmail != "alice@x.io" {
		t.Fatalf("links: %+v", got)
	}
	if len(st.prCommits[7]) != 2 {
		t.Fatalf("pull request commits: %+v", st.prCommits)
	}
	if len(st.marked) != 1 || st.marked[0].SHA != "sq1" || st.marked[0].MergeKind != domain.MergeKindSquash {
		t.Fatalf("marked: %+v", st.marked)
	}
	// The lookup is asked once: the next push reuses it.
	_ = s.Push(context.Background(), domain.Push{Provider: "github", Repo: "acme/api", Branch: "main", Before: "base", After: "SQ1",
		Commits: []domain.PushedCommit{squash}, Total: 1})
	if len(h.asked) != 1 {
		t.Fatalf("asked: %v", h.asked)
	}
}

// A merge commit is marked a merge and not looked up; a rebased commit
// keeps its subject and is not a squash; a revert's target is parsed.
func TestDefaultBranchCommitKinds(t *testing.T) {
	s, st, h := mergeSetup()
	merge := commit("M1", "Merge pull request #8 from x/VIS-3")
	merge.Parents = []string{"a", "b"}
	rebased := commit("R1", "VIS-3 step two")
	rebased.Parents = []string{"a"}
	revert := commit("V1", "Revert \"VIS-3 step two\"\n\nThis reverts commit ABCDEF1234567.")
	revert.Parents = []string{"r1"}
	h.ahead["a..V1"] = []domain.PushedCommit{merge, rebased, revert}
	h.merges["r1"] = []domain.MergedPull{{Number: 9, Title: "VIS-3", BaseBranch: "main", MergeSHA: "r1"}}
	h.commits[9] = []domain.PushedCommit{commit("orig", "VIS-3 step two")}
	if err := s.Push(context.Background(), domain.Push{Provider: "github", Repo: "acme/api", Branch: "main", Before: "a", After: "V1", Total: 3}); err != nil {
		t.Fatal(err)
	}
	byS := map[string]domain.CommitLink{}
	for _, l := range st.linksOf(3) {
		byS[l.SHA] = l
	}
	if byS["m1"].MergeKind != domain.MergeKindMerge || slices.Contains(h.asked, "m1") {
		t.Fatalf("merge: %+v asked %v", byS["m1"], h.asked)
	}
	if byS["r1"].MergeKind != "" || byS["r1"].PRNumber == nil || *byS["r1"].PRNumber != 9 {
		t.Fatalf("rebased: %+v", byS["r1"])
	}
	if byS["v1"].Reverts != "abcdef1234567" || byS["v1"].OnDefaultAt == nil {
		t.Fatalf("revert: %+v", byS["v1"])
	}
}

// A scan dates a default-branch commit by its own date.
func TestScanDatesDefaultCommits(t *testing.T) {
	s, st, h := mergeSetup()
	old := commit("o1", "VIS-3 old work")
	old.Date = time.Now().Add(-10 * 24 * time.Hour)
	h.history = []domain.PushedCommit{old}
	if err := s.ScanRepo(context.Background(), st.repos[0], nil); err != nil {
		t.Fatal(err)
	}
	got := st.linksOf(3)
	if len(got) != 1 || got[0].OnDefaultAt == nil || !got[0].OnDefaultAt.Equal(old.Date) {
		t.Fatalf("links: %+v", got)
	}
}
