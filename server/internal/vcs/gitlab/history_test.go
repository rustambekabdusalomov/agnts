package gitlab

import (
	"context"
	"io"
	"net/http"
	"net/http/httptest"
	"slices"
	"testing"

	"agnts/internal/domain"
)

func TestHistory(t *testing.T) {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		q := r.URL.Query()
		switch p := r.URL.EscapedPath(); {
		case p == "/api/v4/projects/acme%2Fapi/repository/branches":
			_, _ = io.WriteString(w, `[{"name":"main"},{"name":"feature/AMANAT-1"}]`)
		case p == "/api/v4/projects/acme%2Fapi/repository/commits" && q.Get("ref_name") == "main":
			_, _ = io.WriteString(w, `[{"id":"c1","message":"AMANAT-1: fix\n\nbody","author_name":"Bo","authored_date":"2026-10-01T10:00:00Z",
				"web_url":"https://gitlab.com/acme/api/-/commit/c1"}]`)
		case p == "/api/v4/projects/acme%2Fapi/repository/compare" && q.Get("from") == "main" && q.Get("to") == "feature/AMANAT-1":
			_, _ = io.WriteString(w, `{"commits":[{"id":"f1","message":"wip"},{"id":"f2","message":"more"}]}`)
		default:
			w.WriteHeader(404)
		}
	}))
	defer srv.Close()
	h := WithConfig(Config{URL: srv.URL, Token: "glpat"})
	repo := domain.Repository{CloneURL: srv.URL + "/acme/api.git", DefaultBranch: "main", Provider: "gitlab"}
	ctx := context.Background()

	if names, err := h.BranchNames(ctx, repo, 300); err != nil || !slices.Equal(names, []string{"main", "feature/AMANAT-1"}) {
		t.Fatalf("branches: %v %v", names, err)
	}
	cs, err := h.History(ctx, repo, "main", 1, 100)
	if err != nil || len(cs) != 1 || cs[0].Message != "AMANAT-1: fix\n\nbody" || cs[0].Author != "Bo" || cs[0].Date.IsZero() || cs[0].URL == "" {
		t.Fatalf("history: %+v %v", cs, err)
	}
	ahead, err := h.Ahead(ctx, repo, "main", "feature/AMANAT-1")
	if err != nil || len(ahead) != 2 || ahead[1].SHA != "f2" {
		t.Fatalf("ahead: %+v %v", ahead, err)
	}
}
