// Package gitrepo keeps server-side clones with go-git: one checkout per
// ticket branch. It is the only place push credentials are used.
package gitrepo

import (
	"archive/tar"
	"context"
	"errors"
	"fmt"
	"io"
	"io/fs"
	"os"
	"path"
	"path/filepath"
	"slices"
	"strings"
	"sync"
	"time"

	"github.com/go-git/go-git/v5"
	"github.com/go-git/go-git/v5/config"
	"github.com/go-git/go-git/v5/plumbing"
	"github.com/go-git/go-git/v5/plumbing/object"
	"github.com/go-git/go-git/v5/plumbing/transport"
	githttp "github.com/go-git/go-git/v5/plumbing/transport/http"

	"agnts/internal/domain"
	"agnts/internal/orchestrator"
	"agnts/internal/vcs"
)

// TokenSource returns the token for a git host ("github", "gitlab").
type TokenSource func(ctx context.Context, provider string) (string, error)

// Author signs agnts's commits ("commit as you").
type Author struct {
	Name  string
	Email string
}

// AgentUID is the runner image's agent user; archive entries are owned by it.
const AgentUID = 1000

// maxDiffPerFile caps the stored diff of one file.
const maxDiffPerFile = 200 << 10

// Repos implements orchestrator.Git.
type Repos struct {
	dir    string
	token  TokenSource
	author func(ctx context.Context) (Author, error)

	mu    sync.Mutex
	locks map[string]*sync.Mutex
}

var (
	_ orchestrator.Git          = (*Repos)(nil)
	_ orchestrator.DriftChecker = (*Repos)(nil)
)

// New keeps clones under dir.
func New(dir string, token TokenSource, author func(ctx context.Context) (Author, error)) *Repos {
	return &Repos{dir: dir, token: token, author: author, locks: map[string]*sync.Mutex{}}
}

func (g *Repos) checkoutDir(repo domain.Repository, branch string) string {
	clean := func(s string) string {
		return strings.Map(func(r rune) rune {
			if r >= 'a' && r <= 'z' || r >= 'A' && r <= 'Z' || r >= '0' && r <= '9' || r == '-' || r == '_' || r == '.' {
				return r
			}
			return '_'
		}, s)
	}
	return filepath.Join(g.dir, clean(repo.Name), clean(branch))
}

func (g *Repos) lock(dir string) func() {
	g.mu.Lock()
	l, ok := g.locks[dir]
	if !ok {
		l = &sync.Mutex{}
		g.locks[dir] = l
	}
	g.mu.Unlock()
	l.Lock()
	return l.Unlock
}

func (g *Repos) auth(ctx context.Context, repo domain.Repository) (transport.AuthMethod, error) {
	tok, err := g.token(ctx, repo.Provider)
	if err != nil {
		return nil, err
	}
	if tok == "" {
		return nil, nil // public repository
	}
	user := "x-access-token" // GitHub
	if repo.Provider == "gitlab" {
		user = "oauth2"
	}
	return &githttp.BasicAuth{Username: user, Password: tok}, nil
}

// Prepare clones (or fetches) and checks out branch: the existing local or
// remote branch, or a new one from the default branch.
func (g *Repos) Prepare(ctx context.Context, repo domain.Repository, branch string) error {
	dir := g.checkoutDir(repo, branch)
	defer g.lock(dir)()
	auth, err := g.auth(ctx, repo)
	if err != nil {
		return err
	}

	r, err := git.PlainOpen(dir)
	if errors.Is(err, git.ErrRepositoryNotExists) {
		if err := os.MkdirAll(filepath.Dir(dir), 0o750); err != nil {
			return err
		}
		r, err = git.PlainCloneContext(ctx, dir, false, &git.CloneOptions{
			URL: repo.CloneURL, Auth: auth, ReferenceName: plumbing.NewBranchReferenceName(repo.DefaultBranch),
			SingleBranch: false, NoCheckout: true,
		})
		if err != nil {
			_ = os.RemoveAll(dir)
			return fmt.Errorf("clone %s: %w", repo.CloneURL, err)
		}
	} else if err != nil {
		return err
	} else {
		err = r.FetchContext(ctx, &git.FetchOptions{Auth: auth, Force: true,
			RefSpecs: []config.RefSpec{"+refs/heads/*:refs/remotes/origin/*"}})
		if err != nil && !errors.Is(err, git.NoErrAlreadyUpToDate) {
			return fmt.Errorf("fetch: %w", err)
		}
	}

	local := plumbing.NewBranchReferenceName(branch)
	if cur, err := r.Reference(local, true); err == nil {
		if err := fastForward(r, repo, branch, cur); err != nil {
			return err
		}
	} else {
		// No local branch yet: start from the remote branch if it exists
		// (agnts pushed it before), else from the default branch.
		from, err := r.Reference(plumbing.NewRemoteReferenceName("origin", branch), true)
		if err != nil {
			if from, err = r.Reference(plumbing.NewRemoteReferenceName("origin", repo.DefaultBranch), true); err != nil {
				return fmt.Errorf("default branch %q not found on remote: %w", repo.DefaultBranch, err)
			}
		}
		if err := r.Storer.SetReference(plumbing.NewHashReference(local, from.Hash())); err != nil {
			return err
		}
	}
	wt, err := r.Worktree()
	if err != nil {
		return err
	}
	return wt.Checkout(&git.CheckoutOptions{Branch: local, Force: true})
}

// Archive returns a tar of the checkout, .git included, owned by the agent user.
func (g *Repos) Archive(_ context.Context, repo domain.Repository, branch string) (io.ReadCloser, error) {
	dir := g.checkoutDir(repo, branch)
	pr, pw := io.Pipe()
	go func() {
		unlock := g.lock(dir)
		defer unlock()
		tw := tar.NewWriter(pw)
		err := filepath.WalkDir(dir, func(p string, d fs.DirEntry, err error) error {
			if err != nil {
				return err
			}
			rel, err := filepath.Rel(dir, p)
			if err != nil || rel == "." {
				return err
			}
			info, err := d.Info()
			if err != nil {
				return err
			}
			link := ""
			if info.Mode()&fs.ModeSymlink != 0 {
				if link, err = os.Readlink(p); err != nil {
					return err
				}
			}
			h, err := tar.FileInfoHeader(info, link)
			if err != nil {
				return err
			}
			h.Name = filepath.ToSlash(rel)
			if d.IsDir() {
				h.Name += "/"
			}
			h.Uid, h.Gid, h.Uname, h.Gname = AgentUID, AgentUID, "agent", "agent"
			if err := tw.WriteHeader(h); err != nil {
				return err
			}
			if info.Mode().IsRegular() {
				f, err := os.Open(p) //nolint:gosec // G304: walking our own checkout
				if err != nil {
					return err
				}
				_, err = io.Copy(tw, f)
				_ = f.Close()
				return err
			}
			return nil
		})
		if err == nil {
			err = tw.Close()
		}
		_ = pw.CloseWithError(err)
	}()
	return pr, nil
}

// Commit replaces the working tree with tree's files, commits any change,
// and returns the head plus the branch's diff against the default branch.
func (g *Repos) Commit(ctx context.Context, repo domain.Repository, branch string, tree io.Reader, message string) (string, []domain.FileChange, error) {
	dir := g.checkoutDir(repo, branch)
	defer g.lock(dir)()

	r, err := git.PlainOpen(dir)
	if err != nil {
		return "", nil, err
	}
	wt, err := r.Worktree()
	if err != nil {
		return "", nil, err
	}
	if err := wipeWorktree(dir); err != nil {
		return "", nil, err
	}
	if err := extract(tree, dir); err != nil {
		return "", nil, err
	}
	if err := wt.AddWithOptions(&git.AddOptions{All: true}); err != nil {
		return "", nil, fmt.Errorf("stage: %w", err)
	}
	st, err := wt.Status()
	if err != nil {
		return "", nil, err
	}
	head, err := r.Head()
	if err != nil {
		return "", nil, err
	}
	sha := head.Hash()
	if !st.IsClean() {
		a, err := g.author(ctx)
		if err != nil {
			return "", nil, err
		}
		sig := &object.Signature{Name: a.Name, Email: a.Email, When: time.Now()}
		if sha, err = wt.Commit(message, &git.CommitOptions{Author: sig, Committer: sig}); err != nil {
			return "", nil, fmt.Errorf("commit: %w", err)
		}
	}
	files, err := branchDiff(r, repo.DefaultBranch, sha)
	return sha.String(), files, err
}

// Push sends branch to origin. Only fast-forwards: agnts never rewrites history.
func (g *Repos) Push(ctx context.Context, repo domain.Repository, branch string) error {
	dir := g.checkoutDir(repo, branch)
	defer g.lock(dir)()
	r, err := git.PlainOpen(dir)
	if err != nil {
		return err
	}
	auth, err := g.auth(ctx, repo)
	if err != nil {
		return err
	}
	ref := config.RefSpec(fmt.Sprintf("refs/heads/%s:refs/heads/%s", branch, branch))
	err = r.PushContext(ctx, &git.PushOptions{RemoteName: "origin", RefSpecs: []config.RefSpec{ref}, Auth: auth})
	if errors.Is(err, git.NoErrAlreadyUpToDate) {
		return nil
	}
	return err
}

// PushTo fast-forwards target on origin to branch's head. It fails if
// target moved on since the branch was cut: agnts never force-pushes.
func (g *Repos) PushTo(ctx context.Context, repo domain.Repository, branch, target string) error {
	dir := g.checkoutDir(repo, branch)
	defer g.lock(dir)()
	r, err := git.PlainOpen(dir)
	if err != nil {
		return err
	}
	auth, err := g.auth(ctx, repo)
	if err != nil {
		return err
	}
	ref := config.RefSpec(fmt.Sprintf("refs/heads/%s:refs/heads/%s", branch, target))
	err = r.PushContext(ctx, &git.PushOptions{RemoteName: "origin", RefSpecs: []config.RefSpec{ref}, Auth: auth})
	if errors.Is(err, git.NoErrAlreadyUpToDate) {
		return nil
	}
	if err != nil && strings.Contains(err.Error(), "non-fast-forward") {
		return fmt.Errorf("%s moved on since agnts started; switch the task to a pull request or retry to rebuild from %s: %w", target, target, err)
	}
	return err
}

// fastForward moves a local branch that has nothing of its own onto what
// it should start from: its remote branch when agnts pushed it before,
// else the default branch. A ticket's branch is cut when it is analysed;
// one that waited for other tickets to merge then codes on top of them
// instead of on the default branch as it was. Only fast-forwards: a branch
// with commits of its own is never moved.
func fastForward(r *git.Repository, repo domain.Repository, branch string, cur *plumbing.Reference) error {
	target, err := r.Reference(plumbing.NewRemoteReferenceName("origin", branch), true)
	if err != nil {
		if target, err = r.Reference(plumbing.NewRemoteReferenceName("origin", repo.DefaultBranch), true); err != nil {
			return nil // nothing to compare with; Checkout reports real problems
		}
	}
	if target.Hash() == cur.Hash() {
		return nil
	}
	curC, err := r.CommitObject(cur.Hash())
	if err != nil {
		return err
	}
	targetC, err := r.CommitObject(target.Hash())
	if err != nil {
		return err
	}
	behind, err := curC.IsAncestor(targetC)
	if err != nil || !behind {
		return err
	}
	return r.Storer.SetReference(plumbing.NewHashReference(cur.Name(), target.Hash()))
}

// Drift fetches and returns what landed on the default branch since its
// merge base with branch: the changes a pull request from branch has to
// merge with.
func (g *Repos) Drift(ctx context.Context, repo domain.Repository, branch string) ([]domain.FileChange, error) {
	dir := g.checkoutDir(repo, branch)
	defer g.lock(dir)()
	r, err := git.PlainOpen(dir)
	if err != nil {
		return nil, err
	}
	auth, err := g.auth(ctx, repo)
	if err != nil {
		return nil, err
	}
	err = r.FetchContext(ctx, &git.FetchOptions{Auth: auth, Force: true,
		RefSpecs: []config.RefSpec{config.RefSpec(fmt.Sprintf("+refs/heads/%s:refs/remotes/origin/%s", repo.DefaultBranch, repo.DefaultBranch))}})
	if err != nil && !errors.Is(err, git.NoErrAlreadyUpToDate) {
		return nil, fmt.Errorf("fetch: %w", err)
	}
	head, err := r.Reference(plumbing.NewBranchReferenceName(branch), true)
	if err != nil {
		return nil, err
	}
	headC, err := r.CommitObject(head.Hash())
	if err != nil {
		return nil, err
	}
	defRef, err := r.Reference(plumbing.NewRemoteReferenceName("origin", repo.DefaultBranch), true)
	if err != nil {
		return nil, err
	}
	defC, err := r.CommitObject(defRef.Hash())
	if err != nil {
		return nil, err
	}
	bases, err := defC.MergeBase(headC)
	if err != nil || len(bases) == 0 {
		return nil, err
	}
	return treeDiff(bases[0], defC)
}

// branchDiff is what a reviewer sees: changes from the merge base with the
// default branch to head.
func branchDiff(r *git.Repository, defaultBranch string, head plumbing.Hash) ([]domain.FileChange, error) {
	headC, err := r.CommitObject(head)
	if err != nil {
		return nil, err
	}
	baseRef, err := r.Reference(plumbing.NewRemoteReferenceName("origin", defaultBranch), true)
	if err != nil {
		return nil, err
	}
	baseC, err := r.CommitObject(baseRef.Hash())
	if err != nil {
		return nil, err
	}
	if bases, err := baseC.MergeBase(headC); err == nil && len(bases) > 0 {
		baseC = bases[0]
	}
	return treeDiff(baseC, headC)
}

// treeDiff returns the per-file changes from base to head.
func treeDiff(baseC, headC *object.Commit) ([]domain.FileChange, error) {
	baseT, err := baseC.Tree()
	if err != nil {
		return nil, err
	}
	headT, err := headC.Tree()
	if err != nil {
		return nil, err
	}
	changes, err := object.DiffTree(baseT, headT)
	if err != nil {
		return nil, err
	}
	out := make([]domain.FileChange, 0, len(changes))
	for _, ch := range changes {
		p, err := ch.Patch()
		if err != nil {
			return nil, err
		}
		fc := domain.FileChange{Path: ch.To.Name}
		if fc.Path == "" {
			fc.Path = ch.From.Name
		}
		for _, s := range p.Stats() {
			fc.Add += s.Addition
			fc.Del += s.Deletion
		}
		fc.Diff = p.String()
		if len(fc.Diff) > maxDiffPerFile {
			fc.Diff = fc.Diff[:maxDiffPerFile] + "\n… diff truncated …\n"
		}
		out = append(out, fc)
	}
	return out, nil
}

// wipeWorktree deletes everything except .git, so files Claude deleted
// disappear when the exported tree is extracted.
func wipeWorktree(dir string) error {
	entries, err := os.ReadDir(dir)
	if err != nil {
		return err
	}
	for _, e := range entries {
		if e.Name() == ".git" {
			continue
		}
		if err := os.RemoveAll(filepath.Join(dir, e.Name())); err != nil {
			return err
		}
	}
	return nil
}

// extract unpacks a tar into dir, refusing entries that would escape it or
// touch .git (the container's git metadata is never trusted).
func extract(r io.Reader, dir string) error {
	tr := tar.NewReader(r)
	for {
		h, err := tr.Next()
		if errors.Is(err, io.EOF) {
			return nil
		}
		if err != nil {
			return fmt.Errorf("read workspace tar: %w", err)
		}
		name := path.Clean(strings.TrimPrefix(h.Name, "./"))
		if name == "." || name == ".git" || strings.HasPrefix(name, ".git/") {
			continue
		}
		if path.IsAbs(name) || name == ".." || strings.HasPrefix(name, "../") {
			return fmt.Errorf("workspace tar entry escapes the repository: %q", h.Name)
		}
		target := filepath.Join(dir, filepath.FromSlash(name))
		switch h.Typeflag {
		case tar.TypeDir:
			if err := os.MkdirAll(target, 0o750); err != nil {
				return err
			}
		case tar.TypeReg:
			if err := os.MkdirAll(filepath.Dir(target), 0o750); err != nil {
				return err
			}
			mode := os.FileMode(0o644)
			if h.Mode&0o111 != 0 {
				mode = 0o755
			}
			f, err := os.OpenFile(target, os.O_CREATE|os.O_WRONLY|os.O_TRUNC, mode) //nolint:gosec // G304: target checked above
			if err != nil {
				return err
			}
			_, err = io.Copy(f, io.LimitReader(tr, 512<<20)) //nolint:gosec // G110: bounded per file
			if cerr := f.Close(); err == nil {
				err = cerr
			}
			if err != nil {
				return err
			}
		case tar.TypeSymlink:
			// This is the traversal guard for links (TestExtractRejectsEscapes).
			if path.IsAbs(h.Linkname) || strings.HasPrefix(path.Clean(path.Join(path.Dir(name), h.Linkname)), "../") { //nolint:gosec // G305: guard, not a sink
				return fmt.Errorf("symlink %q points outside the repository", h.Name)
			}
			if err := os.MkdirAll(filepath.Dir(target), 0o750); err != nil {
				return err
			}
			_ = os.Remove(target)
			if err := os.Symlink(h.Linkname, target); err != nil {
				return err
			}
		}
	}
}

// maxCount caps commit counting so a long-lived branch cannot stall a page.
const maxCount = 1000

// LocalBranches lists the branch checked out in each of the repository's
// checkouts, newest commit first. Broken or half-made checkouts are skipped.
func (g *Repos) LocalBranches(repo domain.Repository) ([]vcs.LocalBranch, error) {
	root := filepath.Dir(g.checkoutDir(repo, "x"))
	entries, err := os.ReadDir(root)
	if errors.Is(err, fs.ErrNotExist) {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}
	var out []vcs.LocalBranch
	for _, e := range entries {
		if !e.IsDir() {
			continue
		}
		if b, ok := localBranch(filepath.Join(root, e.Name()), repo.DefaultBranch); ok {
			out = append(out, b)
		}
	}
	slices.SortFunc(out, func(a, b vcs.LocalBranch) int { return b.Date.Compare(a.Date) })
	return out, nil
}

func localBranch(dir, defaultBranch string) (vcs.LocalBranch, bool) {
	r, err := git.PlainOpen(dir)
	if err != nil {
		return vcs.LocalBranch{}, false
	}
	head, err := r.Head()
	if err != nil || !head.Name().IsBranch() {
		return vcs.LocalBranch{}, false
	}
	c, err := r.CommitObject(head.Hash())
	if err != nil {
		return vcs.LocalBranch{}, false
	}
	name := head.Name().Short()
	b := vcs.LocalBranch{Name: name, SHA: c.Hash.String(), Message: firstLine(c.Message), Author: c.Author.Name, Date: c.Committer.When, Unpushed: -1}
	if def, err := r.Reference(plumbing.NewRemoteReferenceName("origin", defaultBranch), true); err == nil {
		b.Ahead, b.Behind = aheadBehind(r, c, def.Hash())
	}
	if up, err := r.Reference(plumbing.NewRemoteReferenceName("origin", name), true); err == nil {
		b.Unpushed, _ = aheadBehind(r, c, up.Hash())
	}
	return b, true
}

// aheadBehind counts commits on head but not other, and on other but not head.
func aheadBehind(r *git.Repository, head *object.Commit, other plumbing.Hash) (int, int) {
	if head.Hash == other {
		return 0, 0
	}
	o, err := r.CommitObject(other)
	if err != nil {
		return 0, 0
	}
	stop := map[plumbing.Hash]bool{}
	if bases, err := head.MergeBase(o); err == nil {
		for _, b := range bases {
			stop[b.Hash] = true
		}
	}
	return countUntil(r, head.Hash, stop), countUntil(r, other, stop)
}

// countUntil counts commits reachable from from, not walking past stop.
func countUntil(r *git.Repository, from plumbing.Hash, stop map[plumbing.Hash]bool) int {
	seen := map[plumbing.Hash]bool{}
	queue := []plumbing.Hash{from}
	for len(queue) > 0 && len(seen) < maxCount {
		h := queue[0]
		queue = queue[1:]
		if seen[h] || stop[h] {
			continue
		}
		seen[h] = true
		c, err := r.CommitObject(h)
		if err != nil {
			continue
		}
		queue = append(queue, c.ParentHashes...)
	}
	return len(seen)
}

func firstLine(s string) string {
	line, _, _ := strings.Cut(strings.TrimSpace(s), "\n")
	return line
}
