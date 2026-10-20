package github

import (
	"context"
	"fmt"
	"io"
	"net/http"
	"net/http/httptest"
	"slices"
	"testing"

	"agnts/internal/domain"
)

func TestHistory(t *testing.T) {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		switch p := r.URL.EscapedPath(); {
		case p == "/repos/acme/api/branches" && r.URL.Query().Get("page") == "1":
			_, _ = io.WriteString(w, "[")
			for i := range 100 {
				if i > 0 {
					_, _ = io.WriteString(w, ",")
				}
				_, _ = fmt.Fprintf(w, `{"name":"b%d"}`, i)
			}
			_, _ = io.WriteString(w, "]")
		case p == "/repos/acme/api/branches":
			_, _ = io.WriteString(w, `[{"name":"last"}]`)
		case p == "/repos/acme/api/commits" && r.URL.Query().Get("sha") == "main" && r.URL.Query().Get("page") == "2":
			_, _ = io.WriteString(w, `[{"sha":"c1","html_url":"https://github.com/acme/api/commit/c1","commit":{"message":"AMANAT-1: fix\n\nbody",
				"author":{"name":"Alice","date":"2026-10-01T10:00:00Z"}},"author":{"login":"alice"}},
				{"sha":"c2","commit":{"message":"x","author":{"name":"Bot"}},"author":null}]`)
		case p == "/repos/acme/api/compare/main...feature%2FAMANAT-1":
			_, _ = io.WriteString(w, `{"commits":[{"sha":"f1","commit":{"message":"wip","author":{"name":"Alice"}}}]}`)
		default:
			w.WriteHeader(404)
		}
	}))
	defer srv.Close()
	h := New(srv.URL, func(context.Context) (string, error) { return "tok", nil })
	repo := domain.Repository{CloneURL: "https://github.com/acme/api.git", DefaultBranch: "main"}
	ctx := context.Background()

	names, err := h.BranchNames(ctx, repo, 300)
	if err != nil || len(names) != 101 || names[100] != "last" {
		t.Fatalf("branches: %d %v", len(names), err)
	}
	if names, _ := h.BranchNames(ctx, repo, 5); !slices.Equal(names, []string{"b0", "b1", "b2", "b3", "b4"}) {
		t.Fatalf("capped: %v", names)
	}
	cs, err := h.History(ctx, repo, "main", 2, 100)
	if err != nil || len(cs) != 2 || cs[0].Message != "AMANAT-1: fix\n\nbody" || cs[0].AuthorLogin != "alice" || cs[0].Date.IsZero() ||
		cs[0].URL == "" || cs[1].AuthorLogin != "" {
		t.Fatalf("history: %+v %v", cs, err)
	}
	ahead, err := h.Ahead(ctx, repo, "main", "feature/AMANAT-1")
	if err != nil || len(ahead) != 1 || ahead[0].SHA != "f1" {
		t.Fatalf("ahead: %+v %v", ahead, err)
	}
}
