package gitrepo

import (
	"archive/tar"
	"bytes"
	"context"
	"errors"
	"fmt"
	"io"
	"io/fs"
	"maps"
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
	"github.com/go-git/go-git/v5/plumbing/filemode"
	"github.com/go-git/go-git/v5/plumbing/format/index"
	"github.com/go-git/go-git/v5/plumbing/object"
	"github.com/go-git/go-git/v5/plumbing/storer"

	"agnts/internal/domain"
	"agnts/internal/toolchain"
)

// maxFileSize caps one file taken from a workspace.
const maxFileSize = 512 << 20

// branchCommit returns branch's head commit in the mirror.
func (g *Repos) branchCommit(repo domain.Repository, branch string) (*git.Repository, *object.Commit, error) {
	r, err := git.PlainOpen(g.mirrorDir(repo))
	if err != nil {
		return nil, nil, err
	}
	ref, err := r.Reference(plumbing.NewBranchReferenceName(branch), true)
	if err != nil {
		return nil, nil, fmt.Errorf("branch %s: %w", branch, err)
	}
	c, err := r.CommitObject(ref.Hash())
	if err != nil {
		return nil, nil, err
	}
	return r, c, nil
}

// Archive returns branch as a checkout would have it (call Prepare first):
// its files and a .git with the mirror's objects, the branch, origin's
// branches and tags, and an index, all owned by the agent user.
func (g *Repos) Archive(_ context.Context, repo domain.Repository, branch string) (io.ReadCloser, error) {
	pr, pw := io.Pipe()
	go func() {
		unlock := g.rlock(repo)
		defer unlock()
		_ = pw.CloseWithError(g.archive(pw, repo, branch))
	}()
	return pr, nil
}

func (g *Repos) archive(w io.Writer, repo domain.Repository, branch string) error {
	r, c, err := g.branchCommit(repo, branch)
	if err != nil {
		return err
	}
	tree, err := c.Tree()
	if err != nil {
		return err
	}
	a := archiver{tw: tar.NewWriter(w), s: r.Storer, when: c.Committer.When}
	if err := a.tree(tree, ""); err != nil {
		return err
	}
	if err := a.gitDir(r, g.mirrorDir(repo), repo, branch); err != nil {
		return err
	}
	return a.tw.Close()
}

type archiver struct {
	tw    *tar.Writer
	s     storer.EncodedObjectStorer
	when  time.Time
	index []*index.Entry
}

func (a *archiver) header(h *tar.Header) error {
	h.Uid, h.Gid, h.Uname, h.Gname = AgentUID, AgentUID, "agent", "agent"
	if h.ModTime.IsZero() {
		h.ModTime = a.when
	}
	return a.tw.WriteHeader(h)
}

func (a *archiver) dir(name string) error {
	return a.header(&tar.Header{Name: name + "/", Typeflag: tar.TypeDir, Mode: 0o755})
}

func (a *archiver) file(name string, mode int64, body []byte) error {
	if err := a.header(&tar.Header{Name: name, Typeflag: tar.TypeReg, Mode: mode, Size: int64(len(body))}); err != nil {
		return err
	}
	_, err := a.tw.Write(body)
	return err
}

// tree writes t's files under prefix and records each in the index.
func (a *archiver) tree(t *object.Tree, prefix string) error {
	for _, e := range t.Entries {
		name := path.Join(prefix, e.Name)
		entry := &index.Entry{Name: name, Hash: e.Hash, Mode: e.Mode, CreatedAt: a.when, ModifiedAt: a.when, UID: AgentUID, GID: AgentUID}
		switch e.Mode {
		case filemode.Dir:
			sub, err := object.GetTree(a.s, e.Hash)
			if err != nil {
				return err
			}
			if err := a.dir(name); err != nil {
				return err
			}
			if err := a.tree(sub, name); err != nil {
				return err
			}
			continue
		case filemode.Submodule:
			if err := a.dir(name); err != nil { // as a checkout leaves it: empty
				return err
			}
		case filemode.Symlink:
			b, err := object.GetBlob(a.s, e.Hash)
			if err != nil {
				return err
			}
			target, err := blobBytes(b)
			if err != nil {
				return err
			}
			if err := a.header(&tar.Header{Name: name, Typeflag: tar.TypeSymlink, Linkname: string(target), Mode: 0o777}); err != nil {
				return err
			}
			entry.Size = uint32(len(target)) //nolint:gosec // G115: a link target is short
		default: // regular, executable
			b, err := object.GetBlob(a.s, e.Hash)
			if err != nil {
				return err
			}
			mode := int64(0o644)
			if e.Mode == filemode.Executable {
				mode = 0o755
			}
			if err := a.header(&tar.Header{Name: name, Typeflag: tar.TypeReg, Mode: mode, Size: b.Size}); err != nil {
				return err
			}
			rc, err := b.Reader()
			if err != nil {
				return err
			}
			_, err = io.Copy(a.tw, rc)
			_ = rc.Close()
			if err != nil {
				return err
			}
			entry.Size = uint32(b.Size) //nolint:gosec // G115: the index truncates sizes too
		}
		a.index = append(a.index, entry)
	}
	return nil
}

// gitDir writes .git: a repository of its own whose objects are the
// mirror's, with HEAD on branch. Other branches of agnts are left out.
func (a *archiver) gitDir(r *git.Repository, mirror string, repo domain.Repository, branch string) error {
	for _, d := range []string{".git", ".git/refs", ".git/refs/heads", ".git/refs/tags", ".git/refs/remotes"} {
		if err := a.dir(d); err != nil {
			return err
		}
	}
	if err := a.file(".git/HEAD", 0o644, []byte("ref: refs/heads/"+branch+"\n")); err != nil {
		return err
	}

	cfg := config.NewConfig()
	cfg.Core.IsBare = false
	cfg.Remotes["origin"] = &config.RemoteConfig{Name: "origin", URLs: []string{repo.CloneURL}, Fetch: []config.RefSpec{originRefs}}
	body, err := cfg.Marshal()
	if err != nil {
		return err
	}
	if err := a.file(".git/config", 0o644, body); err != nil {
		return err
	}

	refs, err := r.References()
	if err != nil {
		return err
	}
	var packed []string
	own := plumbing.NewBranchReferenceName(branch)
	err = refs.ForEach(func(ref *plumbing.Reference) error {
		n := ref.Name()
		if ref.Type() == plumbing.HashReference && (n == own || n.IsRemote() || n.IsTag()) {
			packed = append(packed, ref.Hash().String()+" "+n.String()+"\n")
		}
		return nil
	})
	if err != nil {
		return err
	}
	slices.SortFunc(packed, func(x, y string) int { return strings.Compare(x[41:], y[41:]) })
	if err := a.file(".git/packed-refs", 0o644, []byte(strings.Join(packed, ""))); err != nil {
		return err
	}

	var idx bytes.Buffer
	if err := index.NewEncoder(&idx).Encode(&index.Index{Version: 2, Entries: a.index}); err != nil {
		return err
	}
	if err := a.file(".git/index", 0o644, idx.Bytes()); err != nil {
		return err
	}

	objects := filepath.Join(mirror, "objects")
	return filepath.WalkDir(objects, func(p string, d fs.DirEntry, err error) error {
		if err != nil {
			return err
		}
		rel, err := filepath.Rel(objects, p)
		if err != nil {
			return err
		}
		name := path.Join(".git/objects", filepath.ToSlash(rel))
		if d.IsDir() {
			return a.dir(name)
		}
		if !d.Type().IsRegular() {
			return nil
		}
		info, err := d.Info()
		if err != nil {
			return err
		}
		if err := a.header(&tar.Header{Name: name, Typeflag: tar.TypeReg, Mode: 0o444, Size: info.Size(), ModTime: info.ModTime()}); err != nil {
			return err
		}
		f, err := os.Open(p) //nolint:gosec // G304: the mirror's own objects
		if err != nil {
			return err
		}
		_, err = io.CopyN(a.tw, f, info.Size())
		_ = f.Close()
		return err
	})
}

func blobBytes(b *object.Blob) ([]byte, error) {
	rc, err := b.Reader()
	if err != nil {
		return nil, err
	}
	defer func() { _ = rc.Close() }()
	return io.ReadAll(rc)
}

// Tree reads what toolchain detection needs from branch (call Prepare
// first): paths up to toolchain.MaxDepth segments outside skipped
// directories, with the content of the files it wants. Symlinks are listed
// but never followed. A git tree never changes, so its listing is kept:
// a run on an unchanged branch, or a new branch cut from the default one,
// reads nothing again.
func (g *Repos) Tree(_ context.Context, repo domain.Repository, branch string) (toolchain.Tree, error) {
	defer g.rlock(repo)()
	r, c, err := g.branchCommit(repo, branch)
	if err != nil {
		return nil, err
	}
	if t, ok := g.trees.get(c.TreeHash); ok {
		return t, nil
	}
	root, err := c.Tree()
	if err != nil {
		return nil, err
	}
	out := toolchain.Tree{}
	var walk func(t *object.Tree, prefix string) error
	walk = func(t *object.Tree, prefix string) error {
		for _, e := range t.Entries {
			rel := path.Join(prefix, e.Name)
			depth := strings.Count(rel, "/") + 1
			switch e.Mode {
			case filemode.Dir, filemode.Submodule:
				if depth < toolchain.MaxDepth {
					out[rel+"/"] = nil // still known to exist (tests/, spec/)
				}
				if e.Mode == filemode.Submodule || toolchain.SkipDir(e.Name) || depth >= toolchain.MaxDepth {
					continue
				}
				sub, err := object.GetTree(r.Storer, e.Hash)
				if err != nil {
					return err
				}
				if err := walk(sub, rel); err != nil {
					return err
				}
				continue
			}
			if depth > toolchain.MaxDepth || len(out) > 20000 {
				continue
			}
			out[rel] = nil
			if e.Mode == filemode.Symlink || !toolchain.Wanted(rel) {
				continue
			}
			b, err := object.GetBlob(r.Storer, e.Hash)
			if err != nil || b.Size > toolchain.MaxFileSize {
				continue //nolint:nilerr // unreadable or too big: listed without content
			}
			if body, err := blobBytes(b); err == nil {
				out[rel] = body
			}
		}
		return nil
	}
	if err := walk(root, ""); err != nil {
		return nil, err
	}
	g.trees.put(c.TreeHash, out)
	return maps.Clone(out), nil
}

// treeCacheSize is how many tree listings are kept: a few branches of a
// few repositories.
const treeCacheSize = 16

// treeCache keeps recent Tree listings by git tree hash, oldest out first.
type treeCache struct {
	mu    sync.Mutex
	order []plumbing.Hash
	trees map[plumbing.Hash]toolchain.Tree
}

// get returns a copy: callers may change their listing, not the cache's.
func (c *treeCache) get(h plumbing.Hash) (toolchain.Tree, bool) {
	c.mu.Lock()
	defer c.mu.Unlock()
	t, ok := c.trees[h]
	if !ok {
		return nil, false
	}
	return maps.Clone(t), true
}

func (c *treeCache) put(h plumbing.Hash, t toolchain.Tree) {
	c.mu.Lock()
	defer c.mu.Unlock()
	if c.trees == nil {
		c.trees = map[plumbing.Hash]toolchain.Tree{}
	}
	if _, ok := c.trees[h]; ok {
		return
	}
	c.trees[h] = t
	c.order = append(c.order, h)
	if len(c.order) > treeCacheSize {
		delete(c.trees, c.order[0])
		c.order = c.order[1:]
	}
}

// Commit makes branch's tree the tar's files and commits it when it
// changed, then returns the head plus the branch's diff against the
// default branch.
func (g *Repos) Commit(ctx context.Context, repo domain.Repository, branch string, tree io.Reader, message string) (string, []domain.FileChange, []string, error) {
	defer g.lock(repo)()
	r, head, err := g.branchCommit(repo, branch)
	if err != nil {
		return "", nil, nil, err
	}
	headTree, err := head.Tree()
	if err != nil {
		return "", nil, nil, err
	}
	root, dropped, err := buildTree(r.Storer, tree, headTree)
	if err != nil {
		return "", nil, nil, err
	}
	sha := head.Hash
	if root != head.TreeHash {
		a, err := g.author(ctx)
		if err != nil {
			return "", nil, nil, err
		}
		sig := object.Signature{Name: a.Name, Email: a.Email, When: time.Now()}
		c := &object.Commit{Author: sig, Committer: sig, Message: message, TreeHash: root, ParentHashes: []plumbing.Hash{head.Hash}}
		if sha, err = store(r.Storer, c); err != nil {
			return "", nil, nil, fmt.Errorf("commit: %w", err)
		}
		if err := r.Storer.SetReference(plumbing.NewHashReference(plumbing.NewBranchReferenceName(branch), sha)); err != nil {
			return "", nil, nil, err
		}
	}
	files, err := branchDiff(r, repo.DefaultBranch, sha)
	return sha.String(), files, dropped, err
}

// store writes o unless the mirror already has it: a workspace sends every
// file, and nearly all of them are unchanged.
func store(s storer.EncodedObjectStorer, o interface {
	Encode(plumbing.EncodedObject) error
}) (plumbing.Hash, error) {
	obj := s.NewEncodedObject()
	if err := o.Encode(obj); err != nil {
		return plumbing.ZeroHash, err
	}
	return storeObject(s, obj)
}

func storeObject(s storer.EncodedObjectStorer, obj plumbing.EncodedObject) (plumbing.Hash, error) {
	h := obj.Hash()
	if s.HasEncodedObject(h) == nil {
		return h, nil
	}
	return s.SetEncodedObject(obj)
}

func storeBlob(s storer.EncodedObjectStorer, r io.Reader) (plumbing.Hash, error) {
	obj := s.NewEncodedObject()
	obj.SetType(plumbing.BlobObject)
	w, err := obj.Writer()
	if err != nil {
		return plumbing.ZeroHash, err
	}
	if _, err := io.Copy(w, r); err != nil {
		_ = w.Close()
		return plumbing.ZeroHash, err
	}
	if err := w.Close(); err != nil {
		return plumbing.ZeroHash, err
	}
	return storeObject(s, obj)
}

// dirNode is a directory of the tree being built.
type dirNode struct {
	files map[string]object.TreeEntry
	dirs  map[string]*dirNode
}

func newDirNode() *dirNode {
	return &dirNode{files: map[string]object.TreeEntry{}, dirs: map[string]*dirNode{}}
}

func (n *dirNode) put(name string, mode filemode.FileMode, h plumbing.Hash) error {
	parts := strings.Split(name, "/")
	for _, p := range parts[:len(parts)-1] {
		if _, ok := n.files[p]; ok {
			return fmt.Errorf("workspace tar has a file and a directory at %q", name)
		}
		sub, ok := n.dirs[p]
		if !ok {
			sub = newDirNode()
			n.dirs[p] = sub
		}
		n = sub
	}
	last := parts[len(parts)-1]
	if _, ok := n.dirs[last]; ok {
		return fmt.Errorf("workspace tar has a file and a directory at %q", name)
	}
	n.files[last] = object.TreeEntry{Name: last, Mode: mode, Hash: h}
	return nil
}

func (n *dirNode) write(s storer.EncodedObjectStorer) (plumbing.Hash, error) {
	t := &object.Tree{}
	for _, e := range n.files {
		t.Entries = append(t.Entries, e)
	}
	for name, sub := range n.dirs {
		h, err := sub.write(s)
		if err != nil {
			return plumbing.ZeroHash, err
		}
		t.Entries = append(t.Entries, object.TreeEntry{Name: name, Mode: filemode.Dir, Hash: h})
	}
	slices.SortFunc(t.Entries, func(a, b object.TreeEntry) int {
		return strings.Compare(sortName(a), sortName(b))
	})
	return store(s, t)
}

// sortName is git's tree order: directories sort as if named "name/".
func sortName(e object.TreeEntry) string {
	if e.Mode == filemode.Dir {
		return e.Name + "/"
	}
	return e.Name
}

// buildTree stores a workspace tar as a tree and returns its hash. Entries
// that would escape the repository are refused, and .git is never taken
// (the container's git metadata is never trusted). Symlinks that point
// outside the repository are left out and returned: build tools make them
// (a dist link into a cache), and they mean nothing in another checkout.
// Submodules of head stay where the workspace still has their directory.
func buildTree(s storer.EncodedObjectStorer, r io.Reader, head *object.Tree) (plumbing.Hash, []string, error) {
	root := newDirNode()
	dirs := map[string]bool{}
	var dropped []string
	tr := tar.NewReader(r)
	for {
		h, err := tr.Next()
		if errors.Is(err, io.EOF) {
			break
		}
		if err != nil {
			return plumbing.ZeroHash, nil, fmt.Errorf("read workspace tar: %w", err)
		}
		name := path.Clean(strings.TrimPrefix(h.Name, "./"))
		if name == "." || name == ".git" || strings.HasPrefix(name, ".git/") {
			continue
		}
		if path.IsAbs(name) || name == ".." || strings.HasPrefix(name, "../") {
			return plumbing.ZeroHash, nil, fmt.Errorf("workspace tar entry escapes the repository: %q", h.Name)
		}
		switch h.Typeflag {
		case tar.TypeDir:
			dirs[name] = true
		case tar.TypeReg:
			hash, err := storeBlob(s, io.LimitReader(tr, maxFileSize))
			if err != nil {
				return plumbing.ZeroHash, nil, err
			}
			mode := filemode.Regular
			if h.Mode&0o111 != 0 {
				mode = filemode.Executable
			}
			if err := root.put(name, mode, hash); err != nil {
				return plumbing.ZeroHash, nil, err
			}
		case tar.TypeSymlink:
			// This is the traversal guard for links (TestBuildTreeRejectsEscapes).
			if to := path.Clean(path.Join(path.Dir(name), h.Linkname)); path.IsAbs(h.Linkname) || to == ".." || strings.HasPrefix(to, "../") { //nolint:gosec // G305: guard, not a sink
				dropped = append(dropped, name)
				continue
			}
			hash, err := storeBlob(s, strings.NewReader(h.Linkname))
			if err != nil {
				return plumbing.ZeroHash, nil, err
			}
			if err := root.put(name, filemode.Symlink, hash); err != nil {
				return plumbing.ZeroHash, nil, err
			}
		}
	}
	if head != nil {
		w := object.NewTreeWalker(head, true, nil)
		defer w.Close()
		for {
			name, e, err := w.Next()
			if errors.Is(err, io.EOF) {
				break
			}
			if err != nil {
				return plumbing.ZeroHash, nil, err
			}
			if e.Mode == filemode.Submodule && dirs[name] {
				if err := root.put(name, e.Mode, e.Hash); err != nil {
					return plumbing.ZeroHash, nil, err
				}
			}
		}
	}
	h, err := root.write(s)
	return h, dropped, err
}
