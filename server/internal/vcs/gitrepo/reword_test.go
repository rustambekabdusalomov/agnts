package gitrepo

import (
	"context"
	"errors"
	"testing"

	"github.com/go-git/go-git/v5"
	"github.com/go-git/go-git/v5/plumbing"

	"agnts/internal/domain"
)

// Two runs' commits on a branch never pushed: rewording the first keeps
// both trees and the second's message, and the branch pushes as usual.
func TestRewordCommit(t *testing.T) {
	ctx := context.Background()
	bare := upstream(t)
	g := newRepos(t)
	repo := domain.Repository{ID: 1, WorkspaceID: 1, Name: "demo", CloneURL: bare, DefaultBranch: "main", Provider: "github"}
	if err := g.Prepare(ctx, repo, "agnts/PAY-1"); err != nil {
		t.Fatal(err)
	}
	if cs, err := g.BranchCommits(ctx, repo, "agnts/PAY-1"); err != nil || len(cs) != 0 {
		t.Fatalf("a new branch's commits: %v %v", cs, err)
	}
	first, _, _, err := g.Commit(ctx, repo, "agnts/PAY-1", tarOf(t, map[string]string{"README.md": "# one\n"}), "PAY-1: Login")
	if err != nil {
		t.Fatal(err)
	}
	second, _, _, err := g.Commit(ctx, repo, "agnts/PAY-1", tarOf(t, map[string]string{"README.md": "# two\n"}), "PAY-1: Login (revision 1)")
	if err != nil {
		t.Fatal(err)
	}
	cs, err := g.BranchCommits(ctx, repo, "agnts/PAY-1")
	if err != nil || len(cs) != 2 || cs[0].SHA != second || cs[1].SHA != first || cs[1].Message != "PAY-1: Login" {
		t.Fatalf("commits %+v %v", cs, err)
	}

	head, err := g.RewordCommits(ctx, repo, "agnts/PAY-1", map[string]string{first: "feat(auth): add the login form\n\nPAY-1"})
	if err != nil {
		t.Fatal(err)
	}
	cs, _ = g.BranchCommits(ctx, repo, "agnts/PAY-1")
	if len(cs) != 2 || cs[0].SHA != head || cs[1].Message != "feat(auth): add the login form\n\nPAY-1" || cs[0].Message != "PAY-1: Login (revision 1)" {
		t.Fatalf("after reword: %+v", cs)
	}
	r, _ := git.PlainOpen(g.mirrorDir(repo))
	was, _ := r.CommitObject(plumbing.NewHash(second))
	now, _ := r.CommitObject(plumbing.NewHash(head))
	if was.TreeHash != now.TreeHash || was.Author != now.Author {
		t.Fatal("rewording changed the tree or the author")
	}

	if same, err := g.RewordCommits(ctx, repo, "agnts/PAY-1", map[string]string{head: "PAY-1: Login (revision 1)"}); err != nil || same != head {
		t.Fatalf("same message: %s %v", same, err)
	}
	if _, err := g.RewordCommits(ctx, repo, "agnts/PAY-1", map[string]string{first: "x"}); !errors.Is(err, domain.ErrNotFound) {
		t.Fatalf("a commit no longer on the branch: %v", err)
	}
	if _, err := g.RewordCommits(ctx, repo, "agnts/NOPE", map[string]string{head: "x"}); !errors.Is(err, domain.ErrNotFound) {
		t.Fatalf("a missing branch: %v", err)
	}
	if err := g.Push(ctx, repo, "agnts/PAY-1"); err != nil {
		t.Fatal(err)
	}
	up, _ := git.PlainOpen(bare)
	if ref, err := up.Reference(plumbing.NewBranchReferenceName("agnts/PAY-1"), true); err != nil || ref.Hash().String() != head {
		t.Fatalf("pushed: %v %v", ref, err)
	}

	// Both at once, in one pass: both messages change, trees stay.
	cs, _ = g.BranchCommits(ctx, repo, "agnts/PAY-1")
	if cs[0].When.IsZero() {
		t.Fatal("no commit time")
	}
	head2, err := g.RewordCommits(ctx, repo, "agnts/PAY-1", map[string]string{cs[0].SHA: "fix: two", cs[1].SHA: "feat: one"})
	if err != nil {
		t.Fatal(err)
	}
	cs, _ = g.BranchCommits(ctx, repo, "agnts/PAY-1")
	if cs[0].SHA != head2 || cs[0].Message != "fix: two" || cs[1].Message != "feat: one" {
		t.Fatalf("both: %+v", cs)
	}
}
