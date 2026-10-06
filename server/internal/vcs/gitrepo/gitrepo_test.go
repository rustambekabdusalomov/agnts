package gitrepo

import (
	"archive/tar"
	"bytes"
	"context"
	"io"
	"os"
	"path/filepath"
	"strings"
	"testing"
	"time"

	"github.com/go-git/go-git/v5"
	"github.com/go-git/go-git/v5/config"
	"github.com/go-git/go-git/v5/plumbing"
	"github.com/go-git/go-git/v5/plumbing/object"

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
	sha, files, err := g.Commit(ctx, repo, "agnts/PAY-1", tree, "PAY-1: fix")
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
	sha2, files2, err := g.Commit(ctx, repo, "agnts/PAY-1", tarOf(t, map[string]string{
		"README.md": "# demo\n", "main.go": "package main\n\nfunc main() { println(\"hi\") }\n", "refund.go": "package main\n",
	}), "PAY-1: again")
	if err != nil || sha2 != sha || len(files2) != 3 {
		t.Fatalf("unchanged commit: %s vs %s, %d files, %v", sha2, sha, len(files2), err)
	}

	r, _ := git.PlainOpen(g.checkoutDir(repo, "agnts/PAY-1"))
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
	b, _ := os.ReadFile(filepath.Join(g2.checkoutDir(repo, "agnts/PAY-1"), "refund.go"))
	if string(b) != "package main\n" {
		t.Fatal("second checkout did not start from the pushed branch")
	}
}

func TestExtractRejectsEscapes(t *testing.T) {
	for name, entry := range map[string]*tar.Header{
		"dotdot":   {Name: "../evil", Typeflag: tar.TypeReg, Mode: 0o644},
		"absolute": {Name: "/etc/evil", Typeflag: tar.TypeReg, Mode: 0o644},
		"symlink":  {Name: "link", Typeflag: tar.TypeSymlink, Linkname: "../../etc/passwd"},
		"abs link": {Name: "link", Typeflag: tar.TypeSymlink, Linkname: "/etc/passwd"},
	} {
		var buf bytes.Buffer
		tw := tar.NewWriter(&buf)
		_ = tw.WriteHeader(entry)
		_ = tw.Close()
		if err := extract(&buf, t.TempDir()); err == nil {
			t.Errorf("%s: accepted", name)
		}
	}
	dir := t.TempDir()
	var buf bytes.Buffer
	tw := tar.NewWriter(&buf)
	_ = tw.WriteHeader(&tar.Header{Name: "pkg/ok.go", Typeflag: tar.TypeReg, Mode: 0o755, Size: 2})
	_, _ = tw.Write([]byte("ok"))
	_ = tw.WriteHeader(&tar.Header{Name: "pkg/link", Typeflag: tar.TypeSymlink, Linkname: "ok.go"})
	_ = tw.Close()
	if err := extract(&buf, dir); err != nil {
		t.Fatal(err)
	}
	if fi, err := os.Stat(filepath.Join(dir, "pkg", "ok.go")); err != nil || fi.Mode().Perm()&0o100 == 0 {
		t.Fatalf("executable bit lost: %v %v", fi, err)
	}
}

func TestHomes(t *testing.T) {
	h := NewHomes(t.TempDir())
	if b, err := h.Load("PAY-1"); b != nil || err != nil {
		t.Fatalf("empty load: %v %v", b, err)
	}
	if err := h.Save("PAY-1", []byte("tar")); err != nil {
		t.Fatal(err)
	}
	if b, _ := h.Load("PAY-1"); string(b) != "tar" {
		t.Fatal("round trip")
	}
	if err := h.Save("../escape", []byte("x")); err == nil {
		t.Fatal("unsafe key accepted")
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
	if _, _, err := g.Commit(ctx, repo, "agnts/PAY-1", tarOf(t, map[string]string{"README.md": "# one\n"}), "PAY-1: one"); err != nil {
		t.Fatal(err)
	}
	if _, _, err := g.Commit(ctx, repo, "agnts/PAY-1", tarOf(t, map[string]string{"README.md": "# two\n"}), "PAY-1: two"); err != nil {
		t.Fatal(err)
	}
	// PAY-2: one commit, pushed.
	if _, _, err := g.Commit(ctx, repo, "agnts/PAY-2", tarOf(t, map[string]string{"README.md": "# pay2\n"}), "PAY-2: change"); err != nil {
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
