package gitrepo

import (
	"context"
	"errors"
	"strings"
	"time"

	"github.com/go-git/go-git/v5"
	"github.com/go-git/go-git/v5/plumbing"
	"github.com/go-git/go-git/v5/plumbing/object"

	"agnts/internal/domain"
)

// Before a ticket's branch is pushed, its commits are agnts's alone, so
// their messages can still change: rewording one makes it and the commits
// after it again, with the same trees and authors. Nothing pushed is ever
// rewritten; the caller checks the branch never was.

// maxBranchCommits caps the commits of a branch listed for rewording.
const maxBranchCommits = 50

// BranchCommits lists the commits on branch that the default branch lacks,
// newest first, back to the first merge (which, and everything before it,
// is left out). None when the branch has no commits of its own.
func (g *Repos) BranchCommits(_ context.Context, repo domain.Repository, branch string) ([]domain.BranchCommit, error) {
	defer g.rlock(repo)()
	r, head, err := g.branchCommit(repo, branch)
	if err != nil {
		return nil, notFoundBranch(err)
	}
	chain, err := ownCommits(r, repo.DefaultBranch, head)
	if err != nil {
		return nil, err
	}
	out := make([]domain.BranchCommit, len(chain))
	for i, c := range chain {
		out[i] = domain.BranchCommit{SHA: c.Hash.String(), Message: strings.TrimRight(c.Message, "\n"), When: c.Author.When}
	}
	return out, nil
}

// RewordCommits gives each commit in messages (by sha), all among
// branch's own commits (see BranchCommits), its new message in one pass,
// makes the commits after the oldest of them again on top, and moves
// branch to the new head, which it returns. domain.ErrNotFound: the branch
// is gone, or a sha is not one of its own commits. Messages a commit has
// already change nothing.
func (g *Repos) RewordCommits(_ context.Context, repo domain.Repository, branch string, messages map[string]string) (string, error) {
	defer g.lock(repo)()
	r, head, err := g.branchCommit(repo, branch)
	if err != nil {
		return "", notFoundBranch(err)
	}
	chain, err := ownCommits(r, repo.DefaultBranch, head)
	if err != nil {
		return "", err
	}
	oldest := -1 // index in chain (newest first) of the oldest commit that changes
	found := 0
	for i, c := range chain {
		msg, ok := messages[c.Hash.String()]
		if !ok {
			continue
		}
		found++
		if strings.TrimRight(c.Message, "\n") != msg {
			oldest = i
		}
	}
	if found != len(messages) {
		return "", domain.ErrNotFound
	}
	if oldest < 0 {
		return head.Hash.String(), nil
	}
	parent := chain[oldest].ParentHashes[0]
	now := time.Now()
	for i := oldest; i >= 0; i-- {
		c := chain[i]
		committer := c.Committer
		committer.When = now
		nc := &object.Commit{Author: c.Author, Committer: committer, Message: c.Message, TreeHash: c.TreeHash, ParentHashes: []plumbing.Hash{parent}}
		if msg, ok := messages[c.Hash.String()]; ok {
			nc.Message = msg
		}
		if parent, err = store(r.Storer, nc); err != nil {
			return "", err
		}
	}
	if err := r.Storer.SetReference(plumbing.NewHashReference(plumbing.NewBranchReferenceName(branch), parent)); err != nil {
		return "", err
	}
	return parent.String(), nil
}

// ownCommits walks from head back along its parents to where it meets the
// default branch, newest first: the branch's own commits. It stops at a
// merge or a root commit, and after maxBranchCommits.
func ownCommits(r *git.Repository, defaultBranch string, head *object.Commit) ([]*object.Commit, error) {
	baseRef, err := r.Reference(plumbing.NewRemoteReferenceName("origin", defaultBranch), true)
	if err != nil {
		return nil, err
	}
	base, err := r.CommitObject(baseRef.Hash())
	if err != nil {
		return nil, err
	}
	stop := map[plumbing.Hash]bool{base.Hash: true}
	if bases, err := base.MergeBase(head); err == nil {
		for _, b := range bases {
			stop[b.Hash] = true
		}
	}
	var out []*object.Commit
	for c := head; !stop[c.Hash] && len(c.ParentHashes) == 1 && len(out) < maxBranchCommits; {
		out = append(out, c)
		if c, err = c.Parent(0); err != nil {
			return nil, err
		}
	}
	return out, nil
}

// notFoundBranch is domain.ErrNotFound for a branch or mirror that is gone.
func notFoundBranch(err error) error {
	if errors.Is(err, plumbing.ErrReferenceNotFound) || errors.Is(err, git.ErrRepositoryNotExists) {
		return domain.ErrNotFound
	}
	return err
}
