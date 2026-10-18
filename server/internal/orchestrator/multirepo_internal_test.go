package orchestrator

import (
	"archive/tar"
	"bytes"
	"context"
	"io"
	"testing"

	"agnts/internal/domain"
)

func TestWorkspaceTreePrefixesFolders(t *testing.T) {
	mk := func(names ...string) io.Reader {
		var b bytes.Buffer
		tw := tar.NewWriter(&b)
		for _, n := range names {
			_ = tw.WriteHeader(&tar.Header{Name: n, Typeflag: tar.TypeReg, Mode: 0o644, Size: 1})
			_, _ = tw.Write([]byte("x"))
		}
		_ = tw.Close()
		return &b
	}
	rs := []runRepo{{Row: domain.TicketRepo{Folder: "api"}}, {Row: domain.TicketRepo{Folder: "web"}}}
	trees := []io.Reader{mk("go.mod", ".git/HEAD"), mk("package.json")}
	rc := workspaceTree(func(i int) (io.ReadCloser, error) { return io.NopCloser(trees[i]), nil }, rs, "")
	defer func() { _ = rc.Close() }()
	var names []string
	tr := tar.NewReader(rc)
	for {
		h, err := tr.Next()
		if err != nil {
			break
		}
		names = append(names, h.Name)
	}
	want := []string{"api/", "api/go.mod", "api/.git/HEAD", "web/", "web/package.json"}
	if len(names) != len(want) {
		t.Fatalf("names %v, want %v", names, want)
	}
	for i := range want {
		if names[i] != want[i] {
			t.Fatalf("names %v, want %v", names, want)
		}
	}
}

func TestCompatibility(t *testing.T) {
	o := &Orchestrator{}
	c := o.CheckCompatible(context.Background(), []domain.Repository{
		{Name: "api", Toolchains: []domain.Toolchain{{Tool: "go", Version: "1.24"}}, BuildEnvNames: []string{"NPM_TOKEN"}},
		{Name: "web", Toolchains: []domain.Toolchain{{Tool: "go", Version: "1.23"}, {Tool: "node", Version: "22", Dir: "app"}}, BuildEnvNames: []string{"NPM_TOKEN"}},
	})
	if len(c.Errors) != 1 || len(c.Warnings) != 1 {
		t.Fatalf("compatibility: %+v", c)
	}
	if c := o.CheckCompatible(context.Background(), []domain.Repository{{Name: "a", RunnerImage: "x"}, {Name: "b"}}); c.OK() {
		t.Fatal("different images share a container")
	}
}
