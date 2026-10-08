package gitrepo

import (
	"archive/tar"
	"bytes"
	"context"
	"io"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"testing"
	"time"

	"github.com/go-git/go-git/v5"
	"github.com/go-git/go-git/v5/config"
	"github.com/go-git/go-git/v5/plumbing"
	"github.com/go-git/go-git/v5/plumbing/filemode"
	"github.com/go-git/go-git/v5/plumbing/object"
	"github.com/go-git/go-git/v5/storage/memory"

	"agnts/internal/domain"
)

// upstream creates a bare repository with one commit on main.
func upstream(t *testing.T) string {
	t.Helper()
	bare := filepath.Join(t.TempDir(), "upstream.git")
	if _, err := git.PlainInit(bare, true); err != nil {
		t.Fatal(err)
	}
	work := t.TempDir()
	r, err := git.PlainInitWithOptions(work, &git.PlainInitOptions{
		InitOptions: git.InitOptions{DefaultBranch: plumbing.NewBranchReferenceName("main")},
	})
	if err != nil {
		t.Fatal(err)
	}
	for name, body := range map[string]string{"README.md": "# demo\n", "main.go": "package main\n\nfunc main() {}\n", "old.txt": "remove me\n"} {
		if err := os.WriteFile(filepath.Join(work, name), []byte(body), 0o600); err != nil {
			t.Fatal(err)
		}
	}
	wt, _ := r.Worktree()
	if err := wt.AddWithOptions(&git.AddOptions{All: true}); err != nil {
		t.Fatal(err)
	}
	sig := &object.Signature{Name: "u", Email: "u@x", When: time.Now()}
	if _, err := wt.Commit("init", &git.CommitOptions{Author: sig}); err != nil {
		t.Fatal(err)
	}
	if _, err := r.CreateRemote(&config.RemoteConfig{Name: "origin", URLs: []string{bare}}); err != nil {
		t.Fatal(err)
	}
	if err := r.Push(&git.PushOptions{RefSpecs: []config.RefSpec{"refs/heads/main:refs/heads/main"}}); err != nil {
		t.Fatal(err)
	}
	return bare
}

func newRepos(t *testing.T) *Repos {
	return New(t.TempDir(),
		func(context.Context, string) (string, error) { return "", nil },
		func(context.Context) (Author, error) { return Author{Name: "Rustam", Email: "rustam@example.com"}, nil })
}

func tarOf(t *testing.T, files map[string]string) io.Reader {
	t.Helper()
	var buf bytes.Buffer
	tw := tar.NewWriter(&buf)
	for name, body := range files {
		if err := tw.WriteHeader(&tar.Header{Name: name, Mode: 0o644, Size: int64(len(body)), Typeflag: tar.TypeReg}); err != nil {
			t.Fatal(err)
		}
		_, _ = tw.Write([]byte(body))
	}
	_ = tw.Close()
	return &buf
}

func TestPrepareArchiveCommitPush(t *testing.T) {
	ctx := context.Background()
	bare := upstream(t)
	g := newRepos(t)
	repo := domain.Repository{Name: "demo", CloneURL: bare, DefaultBranch: "main", Provider: "github"}

	if err := g.Prepare(ctx, repo, "agnts/PAY-1"); err != nil {
		t.Fatal(err)
	}

	// The archive carries the checkout and .git, owned by the agent user.
	rc, err := g.Archive(ctx, repo, "agnts/PAY-1")
	if err != nil {
		t.Fatal(err)
	}
	names := map[string]bool{}
	tr := tar.NewReader(rc)
	for {
		h, err := tr.Next()
		if err == io.EOF {
			break
		}
		if err != nil {
			t.Fatal(err)
		}
		names[h.Name] = true
		if h.Uid != AgentUID {
			t.Fatalf("%s owned by %d", h.Name, h.Uid)
		}
	}
	_ = rc.Close()
	if !names["README.md"] || !names[".git/"] || !names["main.go"] {
		t.Fatalf("archive entries: %v", names)
	}

	// Claude edited main.go, added a file, deleted old.txt, and tried to
	// smuggle in .git content; only the real changes are committed.
	tree := tarOf(t, map[string]string{
		"README.md":   "# demo\n",
		"main.go":     "package main\n\nfunc main() { println(\"hi\") }\n",
		"refund.go":   "package main\n",
		".git/config": "[remote \"origin\"]\nurl = https://evil.example/x.git\n",
	})
	sha, files, _, err := g.Commit(ctx, repo, "agnts/PAY-1", tree, "PAY-1: fix")
	if err != nil {
		t.Fatal(err)
	}
	got := map[string]domain.FileChange{}
	for _, f := range files {
		got[f.Path] = f
	}
	if len(got) != 3 || got["main.go"].Add != 1 || got["main.go"].Del != 1 || got["old.txt"].Del != 1 || got["refund.go"].Add != 1 {
		t.Fatalf("diff: %+v", files)
	}
	if !strings.Contains(got["main.go"].Diff, `+func main() { println("hi") }`) {
		t.Fatalf("patch text: %s", got["main.go"].Diff)
	}

	// Same tree again: no new commit, same diff against main.
	sha2, files2, _, err := g.Commit(ctx, repo, "agnts/PAY-1", tarOf(t, map[string]string{
		"README.md": "# demo\n", "main.go": "package main\n\nfunc main() { println(\"hi\") }\n", "refund.go": "package main\n",
	}), "PAY-1: again")
	if err != nil || sha2 != sha || len(files2) != 3 {
		t.Fatalf("unchanged commit: %s vs %s, %d files, %v", sha2, sha, len(files2), err)
	}

	r, _ := git.PlainOpen(g.mirrorDir(repo))
	c, _ := r.CommitObject(plumbing.NewHash(sha))
	if c.Author.Email != "rustam@example.com" || c.Message != "PAY-1: fix" {
		t.Fatalf("commit: %+v", c)
	}
	cfg, _ := r.Config()
	if cfg.Remotes["origin"].URLs[0] != bare {
		t.Fatal("remote was changed by the workspace tree")
	}

	if err := g.Push(ctx, repo, "agnts/PAY-1"); err != nil {
		t.Fatal(err)
	}
	up, _ := git.PlainOpen(bare)
	ref, err := up.Reference(plumbing.NewBranchReferenceName("agnts/PAY-1"), true)
	if err != nil || ref.Hash().String() != sha {
		t.Fatalf("pushed ref: %v %v", ref, err)
	}

	// A fresh checkout (e.g. after a restart) resumes from the pushed branch.
	g2 := newRepos(t)
	if err := g2.Prepare(ctx, repo, "agnts/PAY-1"); err != nil {
		t.Fatal(err)
	}
	if archived(t, g2, repo, "agnts/PAY-1")["refund.go"] != "package main\n" {
		t.Fatal("second checkout did not start from the pushed branch")
	}
}

func TestBuildTreeRejectsEscapes(t *testing.T) {
	build := func(hs ...*tar.Header) (*memory.Storage, plumbing.Hash, []string, error) {
		var buf bytes.Buffer
		tw := tar.NewWriter(&buf)
		for _, h := range hs {
			_ = tw.WriteHeader(h)
			if h.Size > 0 {
				_, _ = tw.Write(bytes.Repeat([]byte("x"), int(h.Size)))
			}
		}
		_ = tw.Close()
		s := memory.NewStorage()
		h, dropped, err := buildTree(s, &buf, nil)
		return s, h, dropped, err
	}
	for name, entry := range map[string]*tar.Header{
		"dotdot":   {Name: "../evil", Typeflag: tar.TypeReg, Mode: 0o644},
		"absolute": {Name: "/etc/evil", Typeflag: tar.TypeReg, Mode: 0o644},
	} {
		if _, _, _, err := build(entry); err == nil {
			t.Errorf("%s: accepted", name)
		}
	}
	// Links out of the repository are left out, not followed or fatal.
	for name, entry := range map[string]*tar.Header{
		"symlink":  {Name: "link", Typeflag: tar.TypeSymlink, Linkname: "../../etc/passwd"},
		"abs link": {Name: "link", Typeflag: tar.TypeSymlink, Linkname: "/etc/passwd"},
		"parent":   {Name: "website/dist", Typeflag: tar.TypeSymlink, Linkname: "../.."},
	} {
		s, h, dropped, err := build(entry)
		if err != nil || len(dropped) != 1 || dropped[0] != entry.Name {
			t.Errorf("%s: dropped %v, err %v", name, dropped, err)
		}
		if tr, _ := object.GetTree(s, h); tr == nil || len(tr.Entries) != 0 {
			t.Errorf("%s: link stored", name)
		}
	}
	s, h, dropped, err := build(
		&tar.Header{Name: "pkg/ok.go", Typeflag: tar.TypeReg, Mode: 0o755, Size: 2},
		&tar.Header{Name: "pkg/link", Typeflag: tar.TypeSymlink, Linkname: "ok.go"},
		&tar.Header{Name: ".git/config", Typeflag: tar.TypeReg, Mode: 0o644, Size: 1},
	)
	if err != nil || dropped != nil {
		t.Fatal(dropped, err)
	}
	tr, _ := object.GetTree(s, h)
	if len(tr.Entries) != 1 || tr.Entries[0].Name != "pkg" {
		t.Fatalf("root entries: %+v", tr.Entries)
	}
	if e, err := tr.FindEntry("pkg/ok.go"); err != nil || e.Mode != filemode.Executable {
		t.Fatalf("executable bit lost: %+v %v", e, err)
	}
	if e, err := tr.FindEntry("pkg/link"); err != nil || e.Mode != filemode.Symlink {
		t.Fatalf("link: %+v %v", e, err)
	}
}

// archived returns the regular files of branch's archive.
func archived(t *testing.T, g *Repos, repo domain.Repository, branch string) map[string]string {
	t.Helper()
	rc, err := g.Archive(context.Background(), repo, branch)
	if err != nil {
		t.Fatal(err)
	}
	defer func() { _ = rc.Close() }()
	out := map[string]string{}
	tr := tar.NewReader(rc)
	for {
		h, err := tr.Next()
		if err == io.EOF {
			return out
		}
		if err != nil {
			t.Fatal(err)
		}
		if h.Typeflag == tar.TypeReg && !strings.HasPrefix(h.Name, ".git/") {
			b, _ := io.ReadAll(tr)
			out[h.Name] = string(b)
		}
	}
}

// unpack extracts branch's archive into a new directory.
func unpack(t *testing.T, g *Repos, repo domain.Repository, branch string) string {
	t.Helper()
	dir := t.TempDir()
	rc, err := g.Archive(context.Background(), repo, branch)
	if err != nil {
		t.Fatal(err)
	}
	defer func() { _ = rc.Close() }()
	tr := tar.NewReader(rc)
	for {
		h, err := tr.Next()
		if err == io.EOF {
			return dir
		}
		if err != nil {
			t.Fatal(err)
		}
		p := filepath.Join(dir, filepath.FromSlash(h.Name))
		switch h.Typeflag {
		case tar.TypeDir:
			_ = os.MkdirAll(p, 0o750)
		case tar.TypeSymlink:
			_ = os.Symlink(h.Linkname, p)
		case tar.TypeReg:
			b, _ := io.ReadAll(tr)
			if err := os.WriteFile(p, b, os.FileMode(h.Mode)); err != nil { //nolint:gosec // test archive
				t.Fatal(err)
			}
		}
	}
}

// Every branch lives in the one mirror: a second ticket fetches, it never
// clones again.
func TestBranchesShareTheMirror(t *testing.T) {
	ctx := context.Background()
	bare := upstream(t)
	g := newRepos(t)
	repo := domain.Repository{Name: "demo", CloneURL: bare, DefaultBranch: "main", Provider: "github"}
	for _, b := range []string{"agnts/PAY-1", "agnts/PAY-2", "main"} {
		if err := g.Prepare(ctx, repo, b); err != nil {
			t.Fatal(err)
		}
	}
	entries, _ := os.ReadDir(g.repoDir(repo))
	if len(entries) != 1 || entries[0].Name() != mirrorName {
		t.Fatalf("repository directory: %v", entries)
	}
	if got := archived(t, g, repo, "agnts/PAY-2")["README.md"]; got != "# demo\n" {
		t.Fatalf("PAY-2 README: %q", got)
	}
}

// The archive's .git is a working repository for the git CLI in the
// workspace: clean status, history, and only its own branch.
func TestArchiveIsAGitCheckout(t *testing.T) {
	if _, err := exec.LookPath("git"); err != nil {
		t.Skip("git not installed")
	}
	ctx := context.Background()
	bare := upstream(t)
	g := newRepos(t)
	repo := domain.Repository{Name: "demo", CloneURL: bare, DefaultBranch: "main", Provider: "github"}
	for _, b := range []string{"agnts/PAY-1", "agnts/PAY-2"} {
		if err := g.Prepare(ctx, repo, b); err != nil {
			t.Fatal(err)
		}
	}
	if _, _, _, err := g.Commit(ctx, repo, "agnts/PAY-1", tarOf(t, map[string]string{"README.md": "# one\n", "run.sh": "#!/bin/sh\n"}), "PAY-1: one"); err != nil {
		t.Fatal(err)
	}
	dir := unpack(t, g, repo, "agnts/PAY-1")
	run := func(args ...string) string {
		t.Helper()
		cmd := exec.Command("git", append([]string{"-C", dir}, args...)...) //nolint:gosec // test
		out, err := cmd.CombinedOutput()
		if err != nil {
			t.Fatalf("git %v: %v\n%s", args, err, out)
		}
		return strings.TrimSpace(string(out))
	}
	if st := run("status", "--porcelain"); st != "" {
		t.Fatalf("status not clean:\n%s", st)
	}
	if log := run("log", "--format=%s"); log != "PAY-1: one\ninit" {
		t.Fatalf("log: %q", log)
	}
	if br := run("branch", "--list", "--format=%(refname:short)"); br != "agnts/PAY-1" {
		t.Fatalf("branches: %q", br)
	}
	if d := run("diff", "--stat", "origin/main"); !strings.Contains(d, "README.md") {
		t.Fatalf("diff against origin/main: %q", d)
	}
	run("fsck", "--no-dangling")
}

// Checkouts from before the mirror are imported, commits not pushed yet
// included, and removed.
func TestImportsOldCheckouts(t *testing.T) {
	ctx := context.Background()
	bare := upstream(t)
	g := newRepos(t)
	repo := domain.Repository{Name: "demo", CloneURL: bare, DefaultBranch: "main", Provider: "github"}

	old := filepath.Join(g.repoDir(repo), "agnts_PAY-9")
	r, err := git.PlainClone(old, false, &git.CloneOptions{URL: bare, ReferenceName: plumbing.NewBranchReferenceName("main")})
	if err != nil {
		t.Fatal(err)
	}
	local := plumbing.NewBranchReferenceName("agnts/PAY-9")
	head, _ := r.Head()
	_ = r.Storer.SetReference(plumbing.NewHashReference(local, head.Hash()))
	wt, _ := r.Worktree()
	if err := wt.Checkout(&git.CheckoutOptions{Branch: local}); err != nil {
		t.Fatal(err)
	}
	_ = os.WriteFile(filepath.Join(old, "wip.go"), []byte("package main\n"), 0o600)
	_, _ = wt.Add("wip.go")
	sig := &object.Signature{Name: "a", Email: "a@x", When: time.Now()}
	unpushed, err := wt.Commit("PAY-9: wip", &git.CommitOptions{Author: sig})
	if err != nil {
		t.Fatal(err)
	}

	got, err := g.LocalBranches(repo)
	if err != nil || len(got) != 1 || got[0].Name != "agnts/PAY-9" || got[0].SHA != unpushed.String() {
		t.Fatalf("imported branches: %+v %v", got, err)
	}
	if _, err := os.Stat(old); !os.IsNotExist(err) {
		t.Fatalf("old checkout kept: %v", err)
	}
	if err := g.Prepare(ctx, repo, "agnts/PAY-9"); err != nil {
		t.Fatal(err)
	}
	if archived(t, g, repo, "agnts/PAY-9")["wip.go"] != "package main\n" {
		t.Fatal("unpushed commit lost")
	}
}

func TestHomes(t *testing.T) {
	dir := t.TempDir()
	// A home from before workspaces moves into the migrated workspace.
	if err := os.WriteFile(filepath.Join(dir, "OLD-1.tar"), []byte("old"), 0o600); err != nil {
		t.Fatal(err)
	}
	h := NewHomes(dir)
	if err := h.AdoptLegacy(1); err != nil {
		t.Fatal(err)
	}
	if b, _ := h.Load(1, "OLD-1"); string(b) != "old" {
		t.Fatalf("adopted home: %q", b)
	}
	if b, err := h.Load(2, "PAY-1"); b != nil || err != nil {
		t.Fatalf("empty load: %v %v", b, err)
	}
	if err := h.Save(2, "PAY-1", []byte("tar")); err != nil {
		t.Fatal(err)
	}
	if b, _ := h.Load(2, "PAY-1"); string(b) != "tar" {
		t.Fatal("round trip")
	}
	if b, _ := h.Load(3, "PAY-1"); b != nil {
		t.Fatal("another workspace loaded the home")
	}
	if err := h.Save(2, "../escape", []byte("x")); err == nil {
		t.Fatal("unsafe key accepted")
	}
	if err := h.Delete(2); err != nil {
		t.Fatal(err)
	}
	if b, _ := h.Load(2, "PAY-1"); b != nil {
		t.Fatal("deleted workspace's home kept")
	}
}

func TestLocalBranches(t *testing.T) {
	ctx := context.Background()
	bare := upstream(t)
	g := newRepos(t)
	repo := domain.Repository{Name: "demo", CloneURL: bare, DefaultBranch: "main", Provider: "github"}

	if got, err := g.LocalBranches(repo); err != nil || len(got) != 0 {
		t.Fatalf("before any checkout: %v %v", got, err)
	}

	// PAY-1: two commits, never pushed.
	for _, b := range []string{"agnts/PAY-1", "agnts/PAY-2"} {
		if err := g.Prepare(ctx, repo, b); err != nil {
			t.Fatal(err)
		}
	}
	if _, _, _, err := g.Commit(ctx, repo, "agnts/PAY-1", tarOf(t, map[string]string{"README.md": "# one\n"}), "PAY-1: one"); err != nil {
		t.Fatal(err)
	}
	if _, _, _, err := g.Commit(ctx, repo, "agnts/PAY-1", tarOf(t, map[string]string{"README.md": "# two\n"}), "PAY-1: two"); err != nil {
		t.Fatal(err)
	}
	// PAY-2: one commit, pushed.
	if _, _, _, err := g.Commit(ctx, repo, "agnts/PAY-2", tarOf(t, map[string]string{"README.md": "# pay2\n"}), "PAY-2: change"); err != nil {
		t.Fatal(err)
	}
	if err := g.Push(ctx, repo, "agnts/PAY-2"); err != nil {
		t.Fatal(err)
	}
	if err := g.Prepare(ctx, repo, "agnts/PAY-2"); err != nil { // fetch: origin now has it
		t.Fatal(err)
	}

	got, err := g.LocalBranches(repo)
	if err != nil || len(got) != 2 {
		t.Fatalf("local branches: %+v %v", got, err)
	}
	by := map[string]int{}
	for i, b := range got {
		by[b.Name] = i
	}
	one, two := got[by["agnts/PAY-1"]], got[by["agnts/PAY-2"]]
	if one.Ahead != 2 || one.Behind != 0 || one.Unpushed != -1 || one.Message != "PAY-1: two" || one.Author != "Rustam" {
		t.Errorf("PAY-1 = %+v", one)
	}
	if two.Ahead != 1 || two.Unpushed != 0 {
		t.Errorf("PAY-2 = %+v", two)
	}
}

// mergeToMain commits files on a fresh branch and fast-forwards main to it,
// as merging a pull request would.
func mergeToMain(t *testing.T, g *Repos, repo domain.Repository, branch string, files map[string]string) {
	t.Helper()
	ctx := context.Background()
	if err := g.Prepare(ctx, repo, branch); err != nil {
		t.Fatal(err)
	}
	if _, _, _, err := g.Commit(ctx, repo, branch, tarOf(t, files), branch); err != nil {
		t.Fatal(err)
	}
	if err := g.PushTo(ctx, repo, branch, "main"); err != nil {
		t.Fatal(err)
	}
}

func TestUnstartedBranchFollowsDefault(t *testing.T) {
	ctx := context.Background()
	bare := upstream(t)
	g := newRepos(t)
	repo := domain.Repository{Name: "demo", CloneURL: bare, DefaultBranch: "main", Provider: "github"}

	// PAY-2 is analysed (its branch is cut), then waits for PAY-1.
	if err := g.Prepare(ctx, repo, "agnts/PAY-2"); err != nil {
		t.Fatal(err)
	}
	mergeToMain(t, g, repo, "agnts/PAY-1", map[string]string{
		"README.md": "# demo\n", "main.go": "package main\n\nfunc main() { tasks() }\n", "old.txt": "remove me\n", "tasks.go": "package main\n\nfunc tasks() {}\n",
	})

	// When PAY-2 starts coding, its branch has nothing of its own: it moves
	// onto main, which now has PAY-1's change.
	if err := g.Prepare(ctx, repo, "agnts/PAY-2"); err != nil {
		t.Fatal(err)
	}
	if b := archived(t, g, repo, "agnts/PAY-2")["tasks.go"]; !strings.Contains(b, "func tasks") {
		t.Fatalf("unstarted branch did not follow main: %q", b)
	}

	// A branch with commits of its own is never moved.
	if _, _, _, err := g.Commit(ctx, repo, "agnts/PAY-2", tarOf(t, map[string]string{
		"README.md": "# demo\n", "main.go": "package main\n\nfunc main() { tasks(); list() }\n", "old.txt": "remove me\n",
		"tasks.go": "package main\n\nfunc tasks() {}\n", "list.go": "package main\n\nfunc list() {}\n",
	}), "PAY-2"); err != nil {
		t.Fatal(err)
	}
	r, _ := git.PlainOpen(g.mirrorDir(repo))
	before, _ := r.Reference(plumbing.NewBranchReferenceName("agnts/PAY-2"), true)
	mergeToMain(t, g, repo, "agnts/PAY-3", map[string]string{
		"README.md": "# demo, now with docs\n", "main.go": "package main\n\nfunc main() { tasks(); audit() }\n", "old.txt": "remove me\n",
		"tasks.go": "package main\n\nfunc tasks() {}\n",
	})
	if err := g.Prepare(ctx, repo, "agnts/PAY-2"); err != nil {
		t.Fatal(err)
	}
	after, _ := r.Reference(plumbing.NewBranchReferenceName("agnts/PAY-2"), true)
	if before.Hash() != after.Hash() {
		t.Fatal("a branch with its own commit was moved")
	}

	// Drift is what landed on main since PAY-2's branch point: PAY-3's
	// edit of the same line of main.go, and the README.
	drift, err := g.Drift(ctx, repo, "agnts/PAY-2")
	if err != nil {
		t.Fatal(err)
	}
	paths := map[string]bool{}
	for _, f := range drift {
		paths[f.Path] = true
	}
	if len(drift) != 2 || !paths["main.go"] || !paths["README.md"] {
		t.Fatalf("drift: %+v", drift)
	}
	r2, _ := git.PlainOpen(g.mirrorDir(repo))
	head, _ := r2.Reference(plumbing.NewBranchReferenceName("agnts/PAY-2"), true)
	mine, err := branchDiff(r2, "main", head.Hash())
	if err != nil {
		t.Fatal(err)
	}
	var hit []string
	for _, c := range domain.DiffConflicts(mine, drift) {
		if c.Lines {
			hit = append(hit, c.Path)
		}
	}
	if len(hit) != 1 || hit[0] != "main.go" {
		t.Fatalf("line conflicts with drift: %v (mine %+v)", hit, mine)
	}
}

// Tree listings are kept by git tree hash: a branch cut from main reuses
// main's, an edit makes a new one, and callers cannot change the cached one.
func TestTreeCache(t *testing.T) {
	ctx := context.Background()
	bare := upstream(t)
	g := newRepos(t)
	repo := domain.Repository{Name: "demo", CloneURL: bare, DefaultBranch: "main", Provider: "github"}
	for _, b := range []string{"main", "agnts/PAY-1"} {
		if err := g.Prepare(ctx, repo, b); err != nil {
			t.Fatal(err)
		}
	}
	first, err := g.Tree(ctx, repo, "main")
	if err != nil || !hasKey(first, "main.go") {
		t.Fatalf("tree: %v %v", first, err)
	}
	first["main.go"] = []byte("changed by a caller")
	delete(first, "README.md")
	again, err := g.Tree(ctx, repo, "agnts/PAY-1") // same tree as main
	if err != nil || len(g.trees.order) != 1 || !hasKey(again, "README.md") || string(again["main.go"]) == "changed by a caller" {
		t.Fatalf("cached listing: %d entries, %v %v", len(g.trees.order), again, err)
	}

	if _, _, _, err := g.Commit(ctx, repo, "agnts/PAY-1", tarOf(t, map[string]string{"README.md": "# demo\n", "go.mod": "module demo\n\ngo 1.24\n"}), "PAY-1"); err != nil {
		t.Fatal(err)
	}
	edited, err := g.Tree(ctx, repo, "agnts/PAY-1")
	if err != nil || len(g.trees.order) != 2 || string(edited["go.mod"]) != "module demo\n\ngo 1.24\n" || hasKey(edited, "main.go") {
		t.Fatalf("after an edit: %d entries, %v %v", len(g.trees.order), edited, err)
	}
}

func hasKey(t map[string][]byte, k string) bool {
	_, ok := t[k]
	return ok
}

func TestWorkspaceLayoutAdoptAndDeleteBranch(t *testing.T) {
	ctx := context.Background()
	bare := upstream(t)
	g := newRepos(t)
	// Before workspaces the mirror lived at <dir>/<name>.
	legacy := domain.Repository{Name: "demo", CloneURL: bare, DefaultBranch: "main", Provider: "github"}
	if err := os.MkdirAll(g.legacyDir(legacy), 0o750); err != nil {
		t.Fatal(err)
	}
	old := domain.Repository{ID: 1, Name: "demo", CloneURL: bare, DefaultBranch: "main", Provider: "github"}
	if err := g.Prepare(ctx, domain.Repository{ID: 99, WorkspaceID: 9, Name: "demo", CloneURL: bare, DefaultBranch: "main", Provider: "github"}, "main"); err != nil {
		t.Fatal(err)
	}
	// Prepare a mirror under the legacy path by hand: the old layout.
	if err := os.Rename(g.repoDir(domain.Repository{ID: 99, WorkspaceID: 9}), g.legacyDir(legacy)); err != nil {
		_ = os.RemoveAll(g.legacyDir(legacy))
		if err := os.Rename(g.repoDir(domain.Repository{ID: 99, WorkspaceID: 9}), g.legacyDir(legacy)); err != nil {
			t.Fatal(err)
		}
	}
	moved := old
	moved.WorkspaceID = 3
	if err := g.AdoptLegacy([]domain.Repository{moved}); err != nil {
		t.Fatal(err)
	}
	if _, err := os.Stat(g.legacyDir(legacy)); !os.IsNotExist(err) {
		t.Fatalf("legacy folder kept: %v", err)
	}
	if _, err := os.Stat(filepath.Join(g.repoDir(moved), mirrorName)); err != nil {
		t.Fatalf("mirror not at its workspace path: %v", err)
	}
	// Two workspaces' repositories with the same name live apart.
	other := domain.Repository{ID: 2, WorkspaceID: 4, Name: "demo", CloneURL: bare, DefaultBranch: "main", Provider: "github"}
	if g.repoDir(other) == g.repoDir(moved) {
		t.Fatal("two workspaces share a folder")
	}

	if err := g.Prepare(ctx, moved, "agnts/PAY-1"); err != nil {
		t.Fatal(err)
	}
	branches, _ := g.LocalBranches(moved)
	if len(branches) != 2 {
		t.Fatalf("branches before delete: %+v", branches)
	}
	if err := g.DeleteBranch(ctx, moved, "agnts/PAY-1"); err != nil {
		t.Fatal(err)
	}
	if err := g.DeleteBranch(ctx, moved, "main"); err != nil {
		t.Fatal(err)
	}
	if got, _ := g.LocalBranches(moved); len(got) != 1 || got[0].Name != "main" {
		t.Fatalf("branches after delete (the default branch stays): %+v", got)
	}
	if err := g.RemoveWorkspace(3); err != nil {
		t.Fatal(err)
	}
	if _, err := os.Stat(g.repoDir(moved)); !os.IsNotExist(err) {
		t.Fatal("workspace folder kept")
	}
}
