package gitlab

import (
	"context"
	"encoding/json"
	"errors"
	"io"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"agnts/internal/domain"
	"agnts/internal/orchestrator"
	"agnts/internal/vcs"
)

func TestProjectPath(t *testing.T) {
	for _, c := range []struct{ inst, url, want string }{
		{"https://gitlab.com", "https://gitlab.com/acme/api.git", "acme/api"},
		{"https://gitlab.com/", "https://gitlab.com/acme/team/api", "acme/team/api"},
		{"https://git.corp.uz/gitlab", "https://git.corp.uz/gitlab/pay/core.git", "pay/core"},
	} {
		if got, err := ProjectPath(c.inst, c.url); err != nil || got != c.want {
			t.Errorf("%s %s: %q %v", c.inst, c.url, got, err)
		}
	}
	if _, err := ProjectPath("https://gitlab.com", "https://github.com/acme/api"); err == nil {
		t.Error("other host accepted")
	}
}

func TestMergeRequestAndPipelines(t *testing.T) {
	exists := false
	var played string
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.Header.Get("PRIVATE-TOKEN") != "glpat" {
			w.WriteHeader(401)
			return
		}
		p := r.URL.EscapedPath()
		switch {
		case r.Method == "POST" && p == "/api/v4/projects/acme%2Fapi/merge_requests":
			var b map[string]any
			_ = json.NewDecoder(r.Body).Decode(&b)
			if exists {
				w.WriteHeader(409)
				return
			}
			if !strings.HasPrefix(b["title"].(string), "Draft: ") {
				w.WriteHeader(400)
				return
			}
			_, _ = io.WriteString(w, `{"iid":5,"web_url":"https://gitlab.com/acme/api/-/merge_requests/5"}`)
		case r.Method == "GET" && p == "/api/v4/projects/acme%2Fapi/merge_requests":
			_, _ = io.WriteString(w, `[{"iid":5,"web_url":"https://gitlab.com/acme/api/-/merge_requests/5"}]`)
		case p == "/api/v4/projects/acme%2Fapi/pipelines":
			_, _ = io.WriteString(w, `[{"id":77,"sha":"abc","ref":"main","status":"manual","source":"push","created_at":"2026-10-01T10:00:00Z","updated_at":"2026-10-01T10:05:00Z","web_url":"u"}]`)
		case p == "/api/v4/projects/acme%2Fapi/pipelines/77/jobs":
			_, _ = io.WriteString(w, `[{"id":3,"name":"production","stage":"deploy","status":"manual","duration":0,"commit":{"title":"Fix"}},
			  {"id":2,"name":"unit","stage":"test","status":"success","duration":61.5,"commit":{"title":"Fix"}},
			  {"id":1,"name":"compile","stage":"build","status":"success","duration":30,"commit":{"title":"Fix"}}]`)
		case r.Method == "POST" && p == "/api/v4/projects/acme%2Fapi/jobs/3/play":
			played = "3"
			_, _ = io.WriteString(w, `{}`)
		default:
			w.WriteHeader(404)
		}
	}))
	defer srv.Close()
	h := WithConfig(Config{URL: srv.URL, Token: "glpat"})
	repo := domain.Repository{CloneURL: srv.URL + "/acme/api.git", DefaultBranch: "main", Provider: "gitlab"}
	ctx := context.Background()

	n, u, err := h.OpenPR(ctx, repo, orchestrator.PR{Branch: "agnts/X-1", Title: "X-1: fix", Draft: true})
	if err != nil || n != 5 || u == "" {
		t.Fatalf("create MR: %d %s %v", n, u, err)
	}
	exists = true
	if n, _, err = h.OpenPR(ctx, repo, orchestrator.PR{Branch: "agnts/X-1", Title: "X-1: fix"}); err != nil || n != 5 {
		t.Fatalf("existing MR: %d %v", n, err)
	}

	pls, err := h.Pipelines(ctx, repo, 1, 10)
	if err != nil || len(pls) != 1 {
		t.Fatalf("pipelines: %+v %v", pls, err)
	}
	st := pls[0].Stages
	if len(st) != 3 || st[0].Name != "build: compile" || st[2].Status != vcs.CIManual || !st[2].Manual || pls[0].Message != "Fix" {
		t.Fatalf("stages: %+v", st)
	}
	if err := h.Deploy(ctx, repo, vcs.Deploy{JobID: 3}); err != nil || played != "3" {
		t.Fatalf("deploy: %v %q", err, played)
	}
}

func TestRepos(t *testing.T) {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		q := r.URL.Query()
		if r.URL.Path != "/api/v4/projects" || q.Get("membership") != "true" || q.Get("min_access_level") != "30" {
			w.WriteHeader(404)
			return
		}
		_, _ = io.WriteString(w, `[{"path_with_namespace":"pay/core","http_url_to_repo":"https://git.corp.uz/pay/core.git","default_branch":"main","visibility":"internal"},
			{"path_with_namespace":"pay/docs","http_url_to_repo":"https://git.corp.uz/pay/docs.git","visibility":"public"}]`)
	}))
	defer srv.Close()

	got, err := WithConfig(Config{URL: srv.URL, Token: "glpat"}).Repos(context.Background())
	if err != nil || len(got) != 2 {
		t.Fatalf("%d projects, %v", len(got), err)
	}
	if got[0].FullName != "pay/core" || !got[0].Private || got[1].Private {
		t.Errorf("got %+v", got)
	}
	if _, err := WithConfig(Config{URL: srv.URL}).Repos(context.Background()); !errors.Is(err, vcs.ErrNotConnected) {
		t.Errorf("no token: %v", err)
	}
}

func TestMembersAndAssign(t *testing.T) {
	var put map[string][]int64
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		p := r.URL.EscapedPath()
		switch {
		case r.Method == "GET" && p == "/api/v4/projects/acme%2Fapi/members/all":
			_, _ = io.WriteString(w, `[{"id":11,"username":"alice","name":"Alice A","access_level":40,"state":"active","web_url":"https://gitlab.com/alice"},
				{"id":12,"username":"bob","name":"Bob","access_level":30,"state":"active"},
				{"id":13,"username":"gone","access_level":30,"state":"blocked"}]`)
		case r.Method == "PUT" && p == "/api/v4/projects/acme%2Fapi/merge_requests/5":
			_ = json.NewDecoder(r.Body).Decode(&put)
			_, _ = io.WriteString(w, `{}`)
		default:
			w.WriteHeader(404)
		}
	}))
	defer srv.Close()

	h := WithConfig(Config{URL: srv.URL, Token: "glpat"})
	repo := domain.Repository{CloneURL: srv.URL + "/acme/api.git"}
	ms, err := h.Members(context.Background(), repo)
	if err != nil || len(ms) != 2 || ms[0].Role != "Maintainer" || ms[0].Name != "Alice A" || ms[1].Role != "Developer" {
		t.Fatalf("members %+v %v", ms, err)
	}
	err = h.Assign(context.Background(), repo, 5, []string{"Alice", "stranger"})
	if got := put["assignee_ids"]; len(got) != 1 || got[0] != 11 {
		t.Fatalf("assignee ids %v", put)
	}
	if err == nil || !strings.Contains(err.Error(), "stranger") {
		t.Fatalf("unknown user not reported: %v", err)
	}
}

func TestCommitsPaging(t *testing.T) {
	var got string
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		got = r.URL.Query().Get("page") + "/" + r.URL.Query().Get("per_page")
		_, _ = io.WriteString(w, `[]`)
	}))
	defer srv.Close()
	h := WithConfig(Config{URL: srv.URL, Token: "glpat"})
	if _, err := h.Commits(context.Background(), domain.Repository{CloneURL: srv.URL + "/acme/api.git", DefaultBranch: "main"}, 2, 50); err != nil {
		t.Fatal(err)
	}
	if got != "2/50" {
		t.Fatalf("requested %q", got)
	}
}

func TestPRState(t *testing.T) {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		switch r.URL.EscapedPath() {
		case "/api/v4/projects/acme%2Fapi/merge_requests/5":
			_, _ = w.Write([]byte(`{"iid":5,"state":"merged"}`))
		case "/api/v4/projects/acme%2Fapi/merge_requests/6":
			_, _ = w.Write([]byte(`{"iid":6,"state":"opened"}`))
		case "/api/v4/projects/acme%2Fapi/merge_requests/7":
			_, _ = w.Write([]byte(`{"iid":7,"state":"closed"}`))
		default:
			http.NotFound(w, r)
		}
	}))
	defer srv.Close()
	h := WithConfig(Config{URL: srv.URL, Token: "glpat"})
	repo := domain.Repository{CloneURL: srv.URL + "/acme/api.git", DefaultBranch: "main", Provider: "gitlab"}
	ctx := context.Background()
	if s, err := h.PRState(ctx, repo, 5); err != nil || s != domain.PullMerged {
		t.Fatalf("merged: %v %v", s, err)
	}
	if s, err := h.PRState(ctx, repo, 6); err != nil || s != domain.PullOpen {
		t.Fatalf("open: %v %v", s, err)
	}
	if s, err := h.PRState(ctx, repo, 7); err != nil || s != domain.PullClosed {
		t.Fatalf("closed: %v %v", s, err)
	}
}

func TestCommitDetail(t *testing.T) {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		const c = "/api/v4/projects/acme%2Fapi/repository/commits/"
		switch p := r.URL.EscapedPath(); p {
		case c + "abc1234":
			_, _ = io.WriteString(w, `{"id":"abc1234full","message":"PAY-1: fix\n","author_name":"Rustam","author_email":"r@x.io",
				"authored_date":"2026-10-01T10:00:00Z","committer_name":"Rustam","committed_date":"2026-10-01T10:00:00Z",
				"parent_ids":["p1","p2"],"web_url":"u","stats":{"additions":2,"deletions":1}}`)
		case c + "abc1234full/diff":
			_, _ = io.WriteString(w, `[{"old_path":"a.go","new_path":"a.go","diff":"@@ -1 +1,2 @@\n-x\n+y\n+z\n"},{"old_path":"b.go","new_path":"b.go","deleted_file":true,"diff":""}]`)
		case "/api/v4/projects/acme%2Fapi/pipelines":
			if r.URL.Query().Get("sha") != "abc1234full" {
				t.Errorf("pipelines query: %s", r.URL.RawQuery)
			}
			_, _ = io.WriteString(w, `[{"id":7,"sha":"abc1234full","ref":"main","status":"success","source":"push"}]`)
		case "/api/v4/projects/acme%2Fapi/pipelines/7/jobs":
			_, _ = io.WriteString(w, `[{"id":1,"name":"unit","stage":"test","status":"success","duration":3}]`)
		case c + "abc1234full/merge_requests":
			_, _ = io.WriteString(w, `[{"iid":5,"title":"Fix","state":"opened","web_url":"m"}]`)
		case "/api/v4/avatar":
			_, _ = io.WriteString(w, `{"avatar_url":"https://a/r"}`)
		default:
			w.WriteHeader(404)
		}
	}))
	defer srv.Close()
	h := WithConfig(Config{URL: srv.URL, Token: "glpat"})
	got, err := h.CommitDetail(context.Background(), domain.Repository{CloneURL: srv.URL + "/acme/api.git"}, "abc1234")
	if err != nil {
		t.Fatal(err)
	}
	if got.SHA != "abc1234full" || len(got.Parents) != 2 || got.Add != 2 || got.AuthorAvatar != "https://a/r" {
		t.Fatalf("commit: %+v", got)
	}
	if len(got.Files) != 2 || got.Files[0].Add != 2 || got.Files[0].Del != 1 || got.Files[1].Path != "b.go" {
		t.Fatalf("files: %+v", got.Files)
	}
	if len(got.Pipelines) != 1 || got.Pipelines[0].Status != vcs.CIOK || len(got.Pipelines[0].Stages) != 1 {
		t.Fatalf("pipelines: %+v", got.Pipelines)
	}
	if len(got.Pulls) != 1 || got.Pulls[0].State != "open" || got.Pulls[0].Number != 5 {
		t.Fatalf("pulls: %+v", got.Pulls)
	}
}
