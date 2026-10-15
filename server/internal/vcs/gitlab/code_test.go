package gitlab

import (
	"context"
	"encoding/base64"
	"fmt"
	"io"
	"net/http"
	"net/http/httptest"
	"testing"

	"agnts/internal/domain"
	"agnts/internal/vcs"
)

func TestCode(t *testing.T) {
	gets := 0
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		const p = "/api/v4/projects/acme%2Fapi/repository/"
		switch r.URL.EscapedPath() {
		case p + "tree":
			q := r.URL.Query()
			if q.Get("ref") != "dev" || q.Get("path") != "src" {
				t.Errorf("tree query: %s", r.URL.RawQuery)
			}
			if q.Get("page") == "1" {
				_, _ = io.WriteString(w, "[")
				for i := range 100 {
					if i > 0 {
						_, _ = io.WriteString(w, ",")
					}
					_, _ = fmt.Fprintf(w, `{"name":"f%03d.go","path":"src/f%03d.go","type":"blob","mode":"100644"}`, i, i)
				}
				_, _ = io.WriteString(w, "]")
				return
			}
			_, _ = io.WriteString(w, `[{"name":"lib","path":"src/lib","type":"tree"},{"name":"link","path":"src/link","type":"blob","mode":"120000"},
				{"name":"ext","path":"src/ext","type":"commit"}]`)
		case p + "files/src%2Fmain.go":
			w.Header().Set("X-Gitlab-Size", "12")
			if r.Method == http.MethodHead {
				return
			}
			gets++
			_, _ = io.WriteString(w, `{"size":12,"encoding":"base64","content":"`+base64.StdEncoding.EncodeToString([]byte("package main"))+`"}`)
		case p + "files/big.bin":
			w.Header().Set("X-Gitlab-Size", "9000000")
			if r.Method != http.MethodHead {
				t.Error("a large file was downloaded")
			}
		default:
			w.WriteHeader(404)
		}
	}))
	defer srv.Close()
	h := WithConfig(Config{URL: srv.URL, Token: "glpat"})
	repo := domain.Repository{CloneURL: srv.URL + "/acme/api.git"}
	ctx := context.Background()

	es, err := h.Tree(ctx, repo, "dev", "src")
	if err != nil {
		t.Fatal(err)
	}
	if len(es) != 103 || es[0].Name != "lib" || es[0].Type != vcs.EntryDir {
		t.Fatalf("tree: %d %+v", len(es), es[:2])
	}
	types := map[string]string{}
	for _, e := range es {
		types[e.Name] = e.Type
	}
	if types["link"] != vcs.EntrySymlink || types["ext"] != vcs.EntrySubmodule || types["f000.go"] != vcs.EntryFile {
		t.Fatalf("types: %v", types)
	}

	f, err := h.File(ctx, repo, "feature/x", "src/main.go")
	if err != nil || f.Content != "package main" || f.Size != 12 || gets != 1 {
		t.Fatalf("file: %+v %v", f, err)
	}
	if want := srv.URL + "/acme/api/-/blob/feature/x/src/main.go"; f.URL != want {
		t.Fatalf("url: %s, want %s", f.URL, want)
	}
	if f, err := h.File(ctx, repo, "dev", "big.bin"); err != nil || !f.TooLarge || f.Size != 9000000 {
		t.Fatalf("large: %+v %v", f, err)
	}
}
