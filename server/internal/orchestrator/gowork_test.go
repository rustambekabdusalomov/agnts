package orchestrator

import (
	"archive/tar"
	"bytes"
	"io"
	"slices"
	"strings"
	"testing"

	"agnts/internal/domain"
	"agnts/internal/toolchain"
)

const (
	gatewayMod = `module gitlab.iman.uz/iman_invest/invest_admin_api_gateway

go 1.22

require (
	gitlab.iman.uz/core-service/grpc_contracts v1.0.0
	gitlab.iman.uz/iman-invest/protos v1.63.0
)
`
	protosMod = "module gitlab.iman.uz/iman-invest/protos\n\ngo 1.23.4\n"
	webMod    = "module gitlab.iman.uz/iman-invest/web\n\ngo 1.24\n"
)

func goRepos(names ...string) []runRepo {
	rs := make([]runRepo, len(names))
	for i, n := range names {
		rs[i] = runRepo{Repository: domain.Repository{Name: n}, Row: domain.TicketRepo{Folder: n}}
	}
	return rs
}

func TestGoWork(t *testing.T) {
	rs := goRepos("gateway", "protos", "web")
	trees := []toolchain.Tree{{"go.mod": []byte(gatewayMod)}, {"go.mod": []byte(protosMod)}, {"go.mod": []byte(webMod)}}
	got := goWorkFor(rs, trees)
	// The newest go line of the modules used; web requires neither, so it is left out.
	if !strings.Contains(got, "go 1.23.4\n\nuse (\n\t./gateway\n\t./protos\n)\n") || strings.Contains(got, "web") {
		t.Fatalf("go.work:\n%s", got)
	}
	if !slices.Equal(rs[0].GoLocal, []string{"protos"}) || rs[1].GoLocal != nil {
		t.Fatalf("GoLocal: %v %v", rs[0].GoLocal, rs[1].GoLocal)
	}
}

func TestGoWorkNone(t *testing.T) {
	for name, trees := range map[string][]toolchain.Tree{
		"no requirement between them": {{"go.mod": []byte(protosMod)}, {"go.mod": []byte(webMod)}},
		"replaced already":            {{"go.mod": []byte(gatewayMod + "\nreplace gitlab.iman.uz/iman-invest/protos => ../protos\n")}, {"go.mod": []byte(protosMod)}},
		"own go.work":                 {{"go.mod": []byte(gatewayMod), "go.work": []byte("go 1.22\n")}, {"go.mod": []byte(protosMod)}},
		"vendored":                    {{"go.mod": []byte(gatewayMod), "vendor/": nil}, {"go.mod": []byte(protosMod)}},
		"not Go":                      {{"package.json": []byte("{}")}, {"go.mod": []byte(protosMod)}},
	} {
		if got := goWorkFor(goRepos("gateway", "protos"), trees); got != "" {
			t.Errorf("%s: go.work:\n%s", name, got)
		}
	}
}

func TestWorkspaceTreeGoWork(t *testing.T) {
	empty := func() io.Reader {
		var b bytes.Buffer
		_ = tar.NewWriter(&b).Close()
		return &b
	}
	rc := workspaceTree(func(int) (io.ReadCloser, error) { return io.NopCloser(empty()), nil }, goRepos("gateway", "protos"), "go 1.22\n")
	defer func() { _ = rc.Close() }()
	tr := tar.NewReader(rc)
	for {
		h, err := tr.Next()
		if err != nil {
			t.Fatal("no go.work in the tree")
		}
		if h.Name == "go.work" {
			b, _ := io.ReadAll(tr)
			if string(b) != "go 1.22\n" || h.Uid != agentUID {
				t.Fatalf("go.work %q uid %d", b, h.Uid)
			}
			return
		}
	}
}

func TestNewerGo(t *testing.T) {
	for _, c := range []struct {
		a, b string
		want bool
	}{{"1.22", "", true}, {"1.23.4", "1.22", true}, {"1.22", "1.22.1", false}, {"1.10", "1.9", true}, {"1.22", "1.22", false}} {
		if got := newerGo(c.a, c.b); got != c.want {
			t.Errorf("newerGo(%q, %q) = %v", c.a, c.b, got)
		}
	}
}
