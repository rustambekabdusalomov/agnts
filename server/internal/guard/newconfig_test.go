package guard

import (
	"errors"
	"os"
	"os/exec"
	"path/filepath"
	"testing"
	"time"

	"agnts/internal/domain"
)

// gitEnv runs commands in dir, a real workspace.
type gitEnv struct{ dir string }

func (e gitEnv) Run(cmd string, _ time.Duration) (int, string, time.Duration) {
	c := exec.Command("sh", "-c", cmd)
	c.Dir = e.dir
	out, err := c.CombinedOutput()
	if x := (*exec.ExitError)(nil); errors.As(err, &x) {
		return x.ExitCode(), string(out), 0
	}
	if err != nil {
		return 1, err.Error(), 0
	}
	return 0, string(out), 0
}

func (e gitEnv) ReadFile(string) ([]byte, error) { return nil, os.ErrNotExist }
func (e gitEnv) Now() time.Time                  { return time.Unix(1_800_000_000, 0) }

// gitRepo makes a repository in dir whose main has .golangci.yml, with
// the change's branch checked out.
func gitRepo(t *testing.T, dir string) {
	t.Helper()
	if err := os.MkdirAll(dir, 0o755); err != nil {
		t.Fatal(err)
	}
	if err := os.WriteFile(filepath.Join(dir, ".golangci.yml"), []byte("linters: {}\n"), 0o644); err != nil {
		t.Fatal(err)
	}
	for _, args := range [][]string{
		{"init", "-q", "-b", "main"}, {"add", "."}, {"-c", "user.email=a@b.c", "-c", "user.name=a", "commit", "-qm", "base"},
		{"checkout", "-qb", "SHOP-1"},
	} {
		if out, err := exec.Command("git", append([]string{"-C", dir}, args...)...).CombinedOutput(); err != nil {
			t.Fatalf("git %v: %v\n%s", args, err, out)
		}
	}
}

// A check configuration the change creates may be written (a new
// repository's first lint setup); one its base has may not, even
// deleted and written again; without a base nothing is let through.
func TestCheckConfigNewOnTheBranch(t *testing.T) {
	if _, err := exec.LookPath("git"); err != nil {
		t.Skip("no git")
	}
	ws := t.TempDir()
	gitRepo(t, ws)
	gitRepo(t, filepath.Join(ws, "web"))
	write := func(p string) Input {
		return toolInput("Write", map[string]string{"file_path": "/workspace/" + p, "content": "export default []\n"})
	}
	one := []RepoBase{{Branch: "main"}}
	multi := []RepoBase{{Folder: "web", Branch: "main"}}
	for _, c := range []struct {
		name  string
		bases []RepoBase
		in    Input
		block bool
	}{
		{"new eslint config", one, write("eslint.config.js"), false},
		{"new eslint config in a repository's folder", multi, write("web/eslint.config.js"), false},
		{"the base's lint config", one, edit1(".golangci.yml", "linters: {}", "linters: {disable-all: true}"), true},
		{"the base's lint config in a folder", multi, write("web/.golangci.yml"), true},
		{"no base known", nil, write("eslint.config.js"), true},
		{"another repository's folder", multi, write("api/eslint.config.js"), true},
	} {
		t.Run(c.name, func(t *testing.T) {
			res, log := Handle("pre", c.in, Config{Profile: Standard, Bases: c.bases}, &State{}, gitEnv{ws})
			if blocked := res.Exit == 2 && len(log) == 1 && log[0].Kind == domain.FlagCheckConfig; blocked != c.block {
				t.Fatalf("blocked %v, want %v: exit %d %+v %s", blocked, c.block, res.Exit, log, res.Stderr)
			}
		})
	}

	// Deleted and written again, it is still the base's.
	if err := os.Remove(filepath.Join(ws, ".golangci.yml")); err != nil {
		t.Fatal(err)
	}
	if res, _ := Handle("pre", write(".golangci.yml"), Config{Profile: Standard, Bases: one}, &State{}, gitEnv{ws}); res.Exit != 2 {
		t.Fatalf("a deleted base config was written again: %s", res.Stderr)
	}
}
