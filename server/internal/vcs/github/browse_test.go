package github

import (
	"context"
	"encoding/json"
	"io"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"agnts/internal/domain"
	"agnts/internal/vcs"
)

func TestBrowse(t *testing.T) {
	var dispatched map[string]any
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		p := r.URL.Path
		switch {
		case p == "/repos/acme/api/branches":
			_, _ = io.WriteString(w, `[{"name":"main","commit":{"sha":"m1"}},{"name":"agnts/PAY-1","commit":{"sha":"h1"}}]`)
		case strings.HasPrefix(p, "/repos/acme/api/commits/") && strings.HasSuffix(p, "/check-runs"):
			if strings.Contains(p, "h1") {
				_, _ = io.WriteString(w, `{"total_count":2,"check_runs":[{"status":"completed","conclusion":"success"},{"status":"completed","conclusion":"failure"}]}`)
				return
			}
			_, _ = io.WriteString(w, `{"total_count":1,"check_runs":[{"status":"completed","conclusion":"success"}]}`)
		case strings.HasPrefix(p, "/repos/acme/api/commits/"):
			_, _ = io.WriteString(w, `{"sha":"x","commit":{"message":"PAY-1: fix\n\nbody","author":{"name":"Rustam","date":"2026-10-01T10:00:00Z"}}}`)
		case p == "/repos/acme/api/compare/main...agnts/PAY-1":
			_, _ = io.WriteString(w, `{"ahead_by":2,"behind_by":1}`)
		case p == "/repos/acme/api/actions/runs":
			_, _ = io.WriteString(w, `{"workflow_runs":[{"id":9,"name":"CI","display_title":"PAY-1: fix","head_branch":"agnts/PAY-1","head_sha":"h1","event":"pull_request","status":"completed","conclusion":"failure","created_at":"2026-10-01T10:00:00Z","updated_at":"2026-10-01T10:03:00Z"}]}`)
		case p == "/repos/acme/api/actions/runs/9/jobs":
			_, _ = io.WriteString(w, `{"jobs":[{"id":1,"name":"test","status":"completed","conclusion":"failure","started_at":"2026-10-01T10:00:00Z","completed_at":"2026-10-01T10:02:00Z"}]}`)
		case r.Method == "POST" && p == "/repos/acme/api/actions/workflows/deploy.yml/dispatches":
			_ = json.NewDecoder(r.Body).Decode(&dispatched)
			w.WriteHeader(204)
		default:
			w.WriteHeader(404)
		}
	}))
	defer srv.Close()
	h := New(srv.URL, func(context.Context) (string, error) { return "tok", nil })
	repo := domain.Repository{CloneURL: "https://github.com/acme/api.git", DefaultBranch: "main"}
	ctx := context.Background()

	bs, err := h.Branches(ctx, repo)
	if err != nil || len(bs) != 2 {
		t.Fatalf("branches: %+v %v", bs, err)
	}
	if !bs[0].Default || bs[0].CI != vcs.CIOK || bs[1].Ahead != 2 || bs[1].Behind != 1 || bs[1].CI != vcs.CIFail || bs[1].Message != "PAY-1: fix" {
		t.Fatalf("branch details: %+v", bs)
	}
	pl, err := h.Pipelines(ctx, repo, 1, 5)
	if err != nil || len(pl) != 1 || pl[0].Status != vcs.CIFail || len(pl[0].Stages) != 1 || pl[0].Duration.Minutes() != 3 {
		t.Fatalf("pipelines: %+v %v", pl, err)
	}
	if err := h.Deploy(ctx, repo, vcs.Deploy{}); err == nil {
		t.Fatal("deploy without a workflow should fail")
	}
	repo.DeployWorkflow = "deploy.yml"
	if err := h.Deploy(ctx, repo, vcs.Deploy{}); err != nil || dispatched["ref"] != "main" {
		t.Fatalf("deploy: %v %v", err, dispatched)
	}
	if envs, err := h.Environments(ctx, repo); err != nil || len(envs) != 0 {
		t.Fatalf("missing environments should be empty: %v %v", envs, err)
	}
}

// Branches come from one GraphQL request when GitHub answers it; partial
// data (a rollup the token may not read) still counts.
func TestBranchesGraphQL(t *testing.T) {
	var rest int
	var vars map[string]any
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.Method != "POST" || r.URL.Path != "/graphql" {
			rest++
			w.WriteHeader(404)
			return
		}
		var req struct {
			Variables map[string]any `json:"variables"`
		}
		_ = json.NewDecoder(r.Body).Decode(&req)
		vars = req.Variables
		_, _ = io.WriteString(w, `{"data":{"repository":{
			"base":{"name":"main","target":{"oid":"m1","messageHeadline":"init","author":{"name":"U","date":"2026-10-01T09:00:00Z"},"statusCheckRollup":{"state":"SUCCESS"}}},
			"refs":{"nodes":[
				{"name":"agnts/PAY-1","target":{"oid":"h1","messageHeadline":"PAY-1: fix","author":{"name":"Rustam","date":"2026-10-01T10:00:00Z"},"statusCheckRollup":{"state":"FAILURE"}},"compare":{"aheadBy":1,"behindBy":2}},
				{"name":"main","target":{"oid":"m1"},"compare":{"aheadBy":0,"behindBy":0}},
				{"name":"wip","target":{"oid":"w1","messageHeadline":"wip","author":{"name":"U","date":null},"statusCheckRollup":null},"compare":null}
			]}}},
			"errors":[{"message":"Resource not accessible by personal access token"}]}`)
	}))
	defer srv.Close()
	h := New(srv.URL, func(context.Context) (string, error) { return "tok", nil })
	repo := domain.Repository{CloneURL: "https://github.com/acme/api.git", DefaultBranch: "main"}
	bs, err := h.Branches(context.Background(), repo)
	if err != nil || len(bs) != 3 || rest != 0 {
		t.Fatalf("branches: %+v %v (rest calls %d)", bs, err, rest)
	}
	if vars["owner"] != "acme" || vars["name"] != "api" || vars["base"] != "main" || vars["qualified"] != "refs/heads/main" {
		t.Fatalf("variables: %v", vars)
	}
	m, pay, wip := bs[0], bs[1], bs[2]
	if !m.Default || m.CI != vcs.CIOK || m.Message != "init" {
		t.Errorf("main = %+v", m)
	}
	if pay.Ahead != 2 || pay.Behind != 1 || pay.CI != vcs.CIFail || pay.Message != "PAY-1: fix" || pay.Author != "Rustam" || pay.Date.Hour() != 10 {
		t.Errorf("PAY-1 = %+v", pay)
	}
	if wip.CI != vcs.CINone || !wip.Date.IsZero() {
		t.Errorf("wip = %+v", wip)
	}
}

func TestGraphQLURL(t *testing.T) {
	for api, want := range map[string]string{
		"https://api.github.com":       "https://api.github.com/graphql",
		"https://ghe.acme.com/api/v3":  "https://ghe.acme.com/api/graphql",
		"https://ghe.acme.com/api/v3/": "https://ghe.acme.com/api/graphql",
	} {
		if got := New(api, nil).graphqlURL(); got != want {
			t.Errorf("%s: %s", api, got)
		}
	}
}

func TestCommitDetail(t *testing.T) {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		switch p := r.URL.Path; p {
		case "/repos/acme/api/commits/abc1234":
			_, _ = io.WriteString(w, `{"sha":"abc1234full","html_url":"https://github.com/acme/api/commit/abc1234full",
				"commit":{"message":"PAY-1: fix\n\nbody","author":{"name":"Rustam","email":"r@x.io","date":"2026-10-01T10:00:00Z"},
				"committer":{"name":"GitHub","email":"noreply@github.com","date":"2026-10-01T10:05:00Z"}},
				"author":{"login":"rustam","avatar_url":"https://a/1"},"parents":[{"sha":"p1"}],
				"stats":{"additions":3,"deletions":1},"files":[{"filename":"a.go","additions":3,"deletions":1,"patch":"@@ -1 +1,3 @@"}]}`)
		case "/repos/acme/api/actions/runs":
			if r.URL.Query().Get("head_sha") != "abc1234full" {
				t.Errorf("runs query: %s", r.URL.RawQuery)
			}
			_, _ = io.WriteString(w, `{"workflow_runs":[{"id":9,"name":"CI","head_sha":"abc1234full","status":"in_progress"}]}`)
		case "/repos/acme/api/actions/runs/9/jobs":
			_, _ = io.WriteString(w, `{"jobs":[{"id":1,"name":"test","status":"in_progress"}]}`)
		case "/repos/acme/api/commits/abc1234full/pulls":
			_, _ = io.WriteString(w, `[{"number":4,"title":"Fix","state":"closed","merged_at":"2026-10-02T00:00:00Z","html_url":"u"}]`)
		default:
			w.WriteHeader(404)
		}
	}))
	defer srv.Close()
	h := New(srv.URL, func(context.Context) (string, error) { return "tok", nil })
	c, err := h.CommitDetail(context.Background(), domain.Repository{CloneURL: "https://github.com/acme/api.git"}, "abc1234")
	if err != nil {
		t.Fatal(err)
	}
	if c.SHA != "abc1234full" || c.Message != "PAY-1: fix\n\nbody" || c.AuthorLogin != "rustam" || c.Committer != "GitHub" || len(c.Parents) != 1 || c.Add != 3 {
		t.Fatalf("commit: %+v", c)
	}
	if len(c.Files) != 1 || c.Files[0].Diff == "" {
		t.Fatalf("files: %+v", c.Files)
	}
	if len(c.Pipelines) != 1 || c.Pipelines[0].Status != vcs.CIRun || len(c.Pipelines[0].Stages) != 1 {
		t.Fatalf("pipelines: %+v", c.Pipelines)
	}
	if len(c.Pulls) != 1 || c.Pulls[0].State != "merged" {
		t.Fatalf("pulls: %+v", c.Pulls)
	}
}
