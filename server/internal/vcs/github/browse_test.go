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
