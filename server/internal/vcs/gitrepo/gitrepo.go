// Package gitrepo keeps server-side clones with go-git: one bare mirror per
// repository, every ticket branch a ref in it. A new branch costs no clone:
// workspaces get their files and .git built from the mirror (workspace.go).
// It is the only place push credentials are used.
package gitrepo

import (
	"context"
	"errors"
	"fmt"
	"io/fs"
	"os"
	"path/filepath"
	"slices"
	"strconv"
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

// mirrorName is the mirror's directory inside the repository's. Git refuses
// branch names starting with a dot, so no old per-branch checkout has it.
const mirrorName = ".mirror"

// originRefs keeps every branch on the git host under refs/remotes/origin,
// apart from agnts's own branches in refs/heads.
const originRefs = config.RefSpec("+refs/heads/*:refs/remotes/origin/*")

// Repos implements orchestrator.Git.
type Repos struct {
	dir    string
	token  TokenSource
	author func(ctx context.Context) (Author, error)

	mu    sync.Mutex
	locks map[string]*sync.RWMutex
	trees treeCache
}

var (
	_ orchestrator.Git           = (*Repos)(nil)
	_ orchestrator.DriftChecker  = (*Repos)(nil)
	_ orchestrator.TreeReader    = (*Repos)(nil)
	_ orchestrator.BranchRenamer = (*Repos)(nil)
)

// New keeps clones under dir.
func New(dir string, token TokenSource, author func(ctx context.Context) (Author, error)) *Repos {
	return &Repos{dir: dir, token: token, author: author, locks: map[string]*sync.RWMutex{}}
}

func clean(s string) string {
	return strings.Map(func(r rune) rune {
		if r >= 'a' && r <= 'z' || r >= 'A' && r <= 'Z' || r >= '0' && r <= '9' || r == '-' || r == '_' || r == '.' {
			return r
		}
		return '_'
	}, s)
}

// repoDir holds the repository's mirror, as <dir>/<workspace>/<repo id>,
// so two workspaces' repositories never share a folder. A repository not
// saved yet (detection) gets new-<name> in its workspace. Before the mirror
// it held one checkout per branch, which open imports.
func (g *Repos) repoDir(repo domain.Repository) string {
	name := "new-" + clean(repo.Name)
	if repo.ID > 0 {
		name = strconv.FormatInt(repo.ID, 10)
	}
	return filepath.Join(g.dir, strconv.FormatInt(repo.WorkspaceID, 10), name)
}

// legacyDir is where the repository lived before workspaces.
func (g *Repos) legacyDir(repo domain.Repository) string {
	return filepath.Join(g.dir, clean(repo.Name))
}

// AdoptLegacy moves the folders of repositories kept before workspaces
// (<dir>/<name>) to their place in the workspace the install migrated
// into. Only that workspace's repositories may take them: a folder named
// like another workspace's repository is not theirs.
func (g *Repos) AdoptLegacy(repos []domain.Repository) error {
	var errs []error
	for _, r := range repos {
		old, dir := g.legacyDir(r), g.repoDir(r)
		if _, err := os.Stat(filepath.Join(old, mirrorName)); err != nil {
			if _, err := os.Stat(old); err != nil {
				continue
			}
		}
		if _, err := os.Stat(dir); err == nil {
			continue
		}
		if err := os.MkdirAll(filepath.Dir(dir), 0o750); err != nil {
			return err
		}
		errs = append(errs, os.Rename(old, dir))
	}
	return errors.Join(errs...)
}

// Remove deletes a repository's mirror (the repository was deleted).
func (g *Repos) Remove(repo domain.Repository) error {
	unlock := g.lock(repo)
	defer unlock()
	return os.RemoveAll(g.repoDir(repo))
}

// RemoveWorkspace deletes every mirror of a workspace (it was deleted).
func (g *Repos) RemoveWorkspace(ws int64) error {
	if ws <= 0 {
		return nil
	}
	return os.RemoveAll(filepath.Join(g.dir, strconv.FormatInt(ws, 10)))
}

func (g *Repos) mirrorDir(repo domain.Repository) string {
	return filepath.Join(g.repoDir(repo), mirrorName)
}

// rw returns the repository's lock: fetches, commits and pushes write the
// mirror, archives and listings only read it.
func (g *Repos) rw(repo domain.Repository) *sync.RWMutex {
	dir := g.repoDir(repo)
	g.mu.Lock()
	defer g.mu.Unlock()
	l, ok := g.locks[dir]
	if !ok {
		l = &sync.RWMutex{}
		g.locks[dir] = l
	}
	return l
}

func (g *Repos) lock(repo domain.Repository) func() {
	l := g.rw(repo)
	l.Lock()
	return l.Unlock
}

func (g *Repos) rlock(repo domain.Repository) func() {
	l := g.rw(repo)
	l.RLock()
	return l.RUnlock
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

// open returns the repository's mirror, making an empty one when there is
// none (no network: Prepare fetches) and importing old checkouts. Call it
// with the write lock held.
func (g *Repos) open(repo domain.Repository) (*git.Repository, error) {
	dir := g.mirrorDir(repo)
	r, err := git.PlainOpen(dir)
	if errors.Is(err, git.ErrRepositoryNotExists) {
		if err := os.MkdirAll(dir, 0o750); err != nil {
			return nil, err
		}
		if r, err = git.PlainInit(dir, true); err != nil {
			_ = os.RemoveAll(dir)
			return nil, err
		}
	} else if err != nil {
		return nil, err
	}
	if _, err := r.Remote("origin"); errors.Is(err, git.ErrRemoteNotFound) {
		if _, err := r.CreateRemote(&config.RemoteConfig{Name: "origin", URLs: []string{repo.CloneURL}, Fetch: []config.RefSpec{originRefs}}); err != nil {
			return nil, err
		}
	}
	if err := importCheckouts(r, g.repoDir(repo)); err != nil {
		return nil, fmt.Errorf("import old checkouts: %w", err)
	}
	return r, nil
}

// importCheckouts moves the checkouts agnts kept before the mirror, one
// directory per branch, into it: the branch, with any commits not pushed
// yet, becomes a ref of the mirror, and the directory goes.
func importCheckouts(r *git.Repository, root string) error {
	entries, err := os.ReadDir(root)
	if err != nil {
		return err
	}
	for _, e := range entries {
		if !e.IsDir() || e.Name() == mirrorName {
			continue
		}
		dir := filepath.Join(root, e.Name())
		old, err := git.PlainOpen(dir)
		if err != nil {
			continue // not a checkout: left alone
		}
		head, err := old.Head()
		if err != nil || !head.Name().IsBranch() {
			continue
		}
		spec := config.RefSpec(fmt.Sprintf("+%s:%s", head.Name(), head.Name()))
		from := git.NewRemote(r.Storer, &config.RemoteConfig{Name: "import", URLs: []string{dir}})
		if err := from.Fetch(&git.FetchOptions{RemoteName: "import", RefSpecs: []config.RefSpec{spec}, Tags: git.NoTags}); err != nil && !errors.Is(err, git.NoErrAlreadyUpToDate) {
			return fmt.Errorf("%s: %w", e.Name(), err)
		}
		if err := os.RemoveAll(dir); err != nil {
			return err
		}
	}
	return nil
}

// fetch brings refs from origin into the mirror: only what it lacks moves.
func fetch(ctx context.Context, r *git.Repository, repo domain.Repository, auth transport.AuthMethod, prune bool, refs ...config.RefSpec) error {
	err := r.FetchContext(ctx, &git.FetchOptions{RemoteName: "origin", RemoteURL: repo.CloneURL, Auth: auth, Force: true, Prune: prune, RefSpecs: refs})
	if err != nil && !errors.Is(err, git.NoErrAlreadyUpToDate) {
		return fmt.Errorf("fetch %s: %w", repo.CloneURL, err)
	}
	return nil
}

// Prepare fetches and points branch at what it should start from: the
// existing local or remote branch, or a new one from the default branch.
func (g *Repos) Prepare(ctx context.Context, repo domain.Repository, branch string) error {
	defer g.lock(repo)()
	auth, err := g.auth(ctx, repo)
	if err != nil {
		return err
	}
	r, err := g.open(repo)
	if err != nil {
		return err
	}
	if err := fetch(ctx, r, repo, auth, true, originRefs); err != nil {
		return err
	}

	local := plumbing.NewBranchReferenceName(branch)
	if cur, err := r.Reference(local, true); err == nil {
		return fastForward(r, repo, branch, cur)
	}
	// No local branch yet: start from the remote branch if it exists
	// (agnts pushed it before), else from the default branch.
	from, err := r.Reference(plumbing.NewRemoteReferenceName("origin", branch), true)
	if err != nil {
		if from, err = r.Reference(plumbing.NewRemoteReferenceName("origin", repo.DefaultBranch), true); err != nil {
			return fmt.Errorf("default branch %q not found on remote: %w", repo.DefaultBranch, err)
		}
	}
	return r.Storer.SetReference(plumbing.NewHashReference(local, from.Hash()))
}

// DeleteBranch removes agnts's local branch of a ticket that is merged or
// rejected; the git host keeps its copy. The default branch is never
// removed.
func (g *Repos) DeleteBranch(_ context.Context, repo domain.Repository, branch string) error {
	if branch == "" || branch == repo.DefaultBranch {
		return nil
	}
	defer g.lock(repo)()
	r, err := git.PlainOpen(g.mirrorDir(repo))
	if errors.Is(err, git.ErrRepositoryNotExists) {
		return nil
	}
	if err != nil {
		return err
	}
	err = r.Storer.RemoveReference(plumbing.NewBranchReferenceName(branch))
	if errors.Is(err, plumbing.ErrReferenceNotFound) {
		return nil
	}
	return err
}

// RestoreBranch points a ticket's deleted local branch back at sha, the
// head agnts saved, when a rejected ticket is continued. DeleteBranch only
// drops the ref, so the commits are still in the mirror; when they are
// not (a fresh clone), it returns domain.ErrNotFound. A branch that still
// exists is left alone.
func (g *Repos) RestoreBranch(_ context.Context, repo domain.Repository, branch, sha string) error {
	if branch == "" || branch == repo.DefaultBranch {
		return nil
	}
	defer g.lock(repo)()
	r, err := git.PlainOpen(g.mirrorDir(repo))
	if errors.Is(err, git.ErrRepositoryNotExists) {
		return domain.ErrNotFound
	}
	if err != nil {
		return err
	}
	local := plumbing.NewBranchReferenceName(branch)
	if _, err := r.Reference(local, true); err == nil {
		return nil
	}
	if sha == "" {
		return domain.ErrNotFound
	}
	h := plumbing.NewHash(sha)
	if _, err := r.CommitObject(h); err != nil {
		if errors.Is(err, plumbing.ErrObjectNotFound) {
			return domain.ErrNotFound
		}
		return err
	}
	return r.Storer.SetReference(plumbing.NewHashReference(local, h))
}

// renameFetchTimeout bounds the fetch RenameBranch checks the new name
// with.
var renameFetchTimeout = 20 * time.Second

// RenameBranch renames a ticket's local branch that was never pushed, so it
// is pushed under the new name. It fetches first and refuses (with
// domain.ErrConflict) a name agnts or the git host already has, or one
// that clashes with a branch as a folder (a and a/b): pushing there would
// add the work to someone else's branch. domain.ErrNotFound means the
// branch is gone; context.DeadlineExceeded, that the git host did not
// answer within renameFetchTimeout.
func (g *Repos) RenameBranch(ctx context.Context, repo domain.Repository, from, to string) error {
	if from == to {
		return nil
	}
	if to == repo.DefaultBranch {
		return fmt.Errorf("%w: %s is the default branch", domain.ErrConflict, to)
	}
	defer g.lock(repo)()
	r, err := git.PlainOpen(g.mirrorDir(repo))
	if errors.Is(err, git.ErrRepositoryNotExists) {
		return domain.ErrNotFound
	}
	if err != nil {
		return err
	}
	auth, err := g.auth(ctx, repo)
	if err != nil {
		return err
	}
	// A person waits on this, and the repository's lock is held: a git
	// host that does not answer (a private network that is down) fails it
	// soon instead of after the system's TCP timeout.
	fctx, cancel := context.WithTimeout(ctx, renameFetchTimeout)
	defer cancel()
	if err := fetch(fctx, r, repo, auth, true, originRefs); err != nil {
		if errors.Is(fctx.Err(), context.DeadlineExceeded) && ctx.Err() == nil {
			return fmt.Errorf("%w: %w", context.DeadlineExceeded, err)
		}
		return err
	}
	old, err := r.Reference(plumbing.NewBranchReferenceName(from), true)
	if errors.Is(err, plumbing.ErrReferenceNotFound) {
		return domain.ErrNotFound
	}
	if err != nil {
		return err
	}
	refs, err := r.References()
	if err != nil {
		return err
	}
	clash := func(name string) bool {
		return name == to || strings.HasPrefix(name, to+"/") || strings.HasPrefix(to, name+"/")
	}
	err = refs.ForEach(func(ref *plumbing.Reference) error {
		switch n := ref.Name(); {
		case n.IsBranch() && n.Short() != from && clash(n.Short()):
			return fmt.Errorf("%w: agnts already has a branch %s", domain.ErrConflict, n.Short())
		case n.IsRemote() && strings.HasPrefix(n.String(), "refs/remotes/origin/"):
			if name := strings.TrimPrefix(n.String(), "refs/remotes/origin/"); name != "HEAD" && clash(name) {
				return fmt.Errorf("%w: the branch %s already exists on the git host", domain.ErrConflict, name)
			}
		}
		return nil
	})
	if err != nil {
		return err
	}
	if err := r.Storer.SetReference(plumbing.NewHashReference(plumbing.NewBranchReferenceName(to), old.Hash())); err != nil {
		return err
	}
	return r.Storer.RemoveReference(old.Name())
}

// Push sends branch to origin. Only fast-forwards: agnts never rewrites history.
func (g *Repos) Push(ctx context.Context, repo domain.Repository, branch string) error {
	return g.push(ctx, repo, branch, branch)
}

// PushTo fast-forwards target on origin to branch's head. It fails if
// target moved on since the branch was cut: agnts never force-pushes.
func (g *Repos) PushTo(ctx context.Context, repo domain.Repository, branch, target string) error {
	err := g.push(ctx, repo, branch, target)
	if err != nil && strings.Contains(err.Error(), "non-fast-forward") {
		return fmt.Errorf("%s moved on since agnts started; switch the task to a pull request or retry to rebuild from %s: %w", target, target, err)
	}
	return err
}

func (g *Repos) push(ctx context.Context, repo domain.Repository, branch, target string) error {
	defer g.lock(repo)()
	r, err := git.PlainOpen(g.mirrorDir(repo))
	if err != nil {
		return err
	}
	auth, err := g.auth(ctx, repo)
	if err != nil {
		return err
	}
	ref := config.RefSpec(fmt.Sprintf("refs/heads/%s:refs/heads/%s", branch, target))
	err = r.PushContext(ctx, &git.PushOptions{RemoteName: "origin", RemoteURL: repo.CloneURL, RefSpecs: []config.RefSpec{ref}, Auth: auth})
	if errors.Is(err, git.NoErrAlreadyUpToDate) {
		return nil
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
			return nil // nothing to compare with
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
	defer g.lock(repo)()
	r, err := git.PlainOpen(g.mirrorDir(repo))
	if err != nil {
		return nil, err
	}
	auth, err := g.auth(ctx, repo)
	if err != nil {
		return nil, err
	}
	def := config.RefSpec(fmt.Sprintf("+refs/heads/%s:refs/remotes/origin/%s", repo.DefaultBranch, repo.DefaultBranch))
	if err := fetch(ctx, r, repo, auth, false, def); err != nil {
		return nil, err
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

// maxCount caps commit counting so a long-lived branch cannot stall a page.
const maxCount = 1000

// LocalBranches lists agnts's branches in the repository's mirror, newest
// commit first.
func (g *Repos) LocalBranches(repo domain.Repository) ([]vcs.LocalBranch, error) {
	if _, err := os.Stat(g.repoDir(repo)); errors.Is(err, fs.ErrNotExist) {
		return nil, nil
	}
	defer g.lock(repo)() // open may import old checkouts
	r, err := g.open(repo)
	if err != nil {
		return nil, err
	}
	refs, err := r.References()
	if err != nil {
		return nil, err
	}
	var out []vcs.LocalBranch
	err = refs.ForEach(func(ref *plumbing.Reference) error {
		if ref.Name().IsBranch() && ref.Type() == plumbing.HashReference {
			if b, ok := localBranch(r, ref, repo.DefaultBranch); ok {
				out = append(out, b)
			}
		}
		return nil
	})
	slices.SortFunc(out, func(a, b vcs.LocalBranch) int { return b.Date.Compare(a.Date) })
	return out, err
}

func localBranch(r *git.Repository, ref *plumbing.Reference, defaultBranch string) (vcs.LocalBranch, bool) {
	c, err := r.CommitObject(ref.Hash())
	if err != nil {
		return vcs.LocalBranch{}, false
	}
	name := ref.Name().Short()
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

// BaseOf returns the commit a change at sha started from: its merge base
// with the default branch.
func (g *Repos) BaseOf(ctx context.Context, repo domain.Repository, sha string) (string, error) {
	defer g.lock(repo)()
	r, err := g.open(repo)
	if err != nil {
		return "", err
	}
	head, err := r.CommitObject(plumbing.NewHash(sha))
	if err != nil {
		return "", fmt.Errorf("commit %s is gone from agnts's clone: %w", shortSHA(sha), err)
	}
	defRef, err := r.Reference(plumbing.NewRemoteReferenceName("origin", repo.DefaultBranch), true)
	if err != nil {
		return "", err
	}
	defC, err := r.CommitObject(defRef.Hash())
	if err != nil {
		return "", err
	}
	bases, err := defC.MergeBase(head)
	if err != nil {
		return "", err
	}
	if len(bases) == 0 {
		return "", fmt.Errorf("commit %s shares no history with %s", shortSHA(sha), repo.DefaultBranch)
	}
	return bases[0].Hash.String(), nil
}

// PrepareAt fetches repo and makes sure branch exists: the existing branch
// as it is (never fast-forwarded), else new at commit base. Replays use
// it, so their work starts where the original's did.
func (g *Repos) PrepareAt(ctx context.Context, repo domain.Repository, branch, base string) error {
	defer g.lock(repo)()
	auth, err := g.auth(ctx, repo)
	if err != nil {
		return err
	}
	r, err := g.open(repo)
	if err != nil {
		return err
	}
	if err := fetch(ctx, r, repo, auth, true, originRefs); err != nil {
		return err
	}
	local := plumbing.NewBranchReferenceName(branch)
	if _, err := r.Reference(local, true); err == nil {
		return nil
	}
	h := plumbing.NewHash(base)
	if _, err := r.CommitObject(h); err != nil {
		return fmt.Errorf("base commit %s not found: %w", shortSHA(base), err)
	}
	return r.Storer.SetReference(plumbing.NewHashReference(local, h))
}

func shortSHA(s string) string {
	if len(s) > 7 {
		return s[:7]
	}
	return s
}

var _ orchestrator.PRFetcher = (*Repos)(nil)

// FetchPR fetches a pull request's head from ref (refs/pull/42/head on
// GitHub, refs/merge-requests/42/head on GitLab: they work for forks too)
// into the local branch, and base into origin/base. It returns the head
// and the change from the merge base with base, as a reviewer sees it.
// The branch is agnts's copy: it is never pushed.
func (g *Repos) FetchPR(ctx context.Context, repo domain.Repository, ref, branch, base string) (string, []domain.FileChange, error) {
	if !strings.HasPrefix(ref, "refs/") || strings.ContainsAny(ref, " :*\\") || branch == "" || branch == repo.DefaultBranch {
		return "", nil, fmt.Errorf("cannot fetch %q into %q", ref, branch)
	}
	defer g.lock(repo)()
	auth, err := g.auth(ctx, repo)
	if err != nil {
		return "", nil, err
	}
	r, err := g.open(repo)
	if err != nil {
		return "", nil, err
	}
	refs := []config.RefSpec{
		config.RefSpec(fmt.Sprintf("+%s:refs/heads/%s", ref, branch)),
		config.RefSpec(fmt.Sprintf("+refs/heads/%s:refs/remotes/origin/%s", base, base)),
	}
	for _, rs := range refs {
		if err := rs.Validate(); err != nil {
			return "", nil, err
		}
	}
	if err := fetch(ctx, r, repo, auth, false, refs...); err != nil {
		return "", nil, err
	}
	head, err := r.Reference(plumbing.NewBranchReferenceName(branch), true)
	if err != nil {
		return "", nil, err
	}
	files, err := branchDiff(r, base, head.Hash())
	if err != nil {
		return "", nil, err
	}
	return head.Hash().String(), files, nil
}

// IsAncestor fetches repo and reports whether commit ancestor is in the
// history of commit sha. A commit the clone does not have gives an error.
func (g *Repos) IsAncestor(ctx context.Context, repo domain.Repository, ancestor, sha string) (bool, error) {
	defer g.lock(repo)()
	auth, err := g.auth(ctx, repo)
	if err != nil {
		return false, err
	}
	r, err := g.open(repo)
	if err != nil {
		return false, err
	}
	if err := fetch(ctx, r, repo, auth, false, originRefs); err != nil {
		return false, err
	}
	a, err := r.CommitObject(plumbing.NewHash(ancestor))
	if err != nil {
		return false, fmt.Errorf("commit %s not found: %w", shortSHA(ancestor), err)
	}
	c, err := r.CommitObject(plumbing.NewHash(sha))
	if err != nil {
		return false, fmt.Errorf("commit %s not found: %w", shortSHA(sha), err)
	}
	if a.Hash == c.Hash {
		return true, nil
	}
	return a.IsAncestor(c)
}
