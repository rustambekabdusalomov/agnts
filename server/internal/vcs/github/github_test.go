package github

import (
	"context"
	"encoding/json"
	"errors"
	"io"
	"net/http"
	"net/http/httptest"
	"strings"
	"sync"
	"testing"

	"agnts/internal/domain"
	"agnts/internal/orchestrator"
	"agnts/internal/vcs"
)

func TestOwnerRepo(t *testing.T) {
	for in, want := range map[string]string{
		"https://github.com/acme/api.git": "acme/api",
		"https://github.com/acme/api":     "acme/api",
		"git@github.com:acme/api.git":     "acme/api",
	} {
		o, r, err := OwnerRepo(in)
		if err != nil || o+"/"+r != want {
			t.Errorf("%s: %s/%s %v", in, o, r, err)
		}
	}
	for _, bad := range []string{"https://gitlab.com/a/b", "https://github.com/onlyowner", "nonsense"} {
		if _, _, err := OwnerRepo(bad); err == nil {
			t.Errorf("%s accepted", bad)
		}
	}
}

func TestOpenPR(t *testing.T) {
	exists := false
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.Header.Get("Authorization") != "Bearer tok" {
			w.WriteHeader(http.StatusUnauthorized)
			return
		}
		switch {
		case r.Method == "POST" && r.URL.Path == "/repos/acme/api/pulls":
			if exists {
				w.WriteHeader(http.StatusUnprocessableEntity)
				_, _ = io.WriteString(w, `{"message":"A pull request already exists"}`)
				return
			}
			w.WriteHeader(http.StatusCreated)
			_, _ = io.WriteString(w, `{"number":7,"html_url":"https://github.com/acme/api/pull/7"}`)
		case r.Method == "GET" && r.URL.Path == "/repos/acme/api/pulls" && r.URL.Query().Get("head") == "acme:agnts/PAY-1":
			_, _ = io.WriteString(w, `[{"number":7,"html_url":"https://github.com/acme/api/pull/7"}]`)
		default:
			w.WriteHeader(http.StatusNotFound)
		}
	}))
	defer srv.Close()

	h := New(srv.URL, func(context.Context) (string, error) { return "tok", nil })
	repo := domain.Repository{CloneURL: "https://github.com/acme/api.git", DefaultBranch: "main"}
	n, u, err := h.OpenPR(context.Background(), repo, orchestrator.PR{Branch: "agnts/PAY-1", Title: "PAY-1: x", Body: "body"})
	if err != nil || n != 7 || u == "" {
		t.Fatalf("create: %d %s %v", n, u, err)
	}
	exists = true
	if n, _, err = h.OpenPR(context.Background(), repo, orchestrator.PR{Branch: "agnts/PAY-1", Title: "PAY-1: x", Body: "body"}); err != nil || n != 7 {
		t.Fatalf("existing: %d %v", n, err)
	}
}

func TestRepos(t *testing.T) {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.URL.Path != "/user/repos" {
			w.WriteHeader(http.StatusNotFound)
			return
		}
		if r.URL.Query().Get("page") == "1" {
			_, _ = io.WriteString(w, "["+strings.TrimSuffix(strings.Repeat(`{"full_name":"acme/x","clone_url":"https://github.com/acme/x.git","default_branch":"main"},`, 99), ",")+
				`,{"full_name":"acme/old","archived":true}]`)
			return
		}
		_, _ = io.WriteString(w, `[{"full_name":"acme/api","clone_url":"https://github.com/acme/api.git","default_branch":"dev","private":true,"pushed_at":"2026-01-02T03:04:05Z"}]`)
	}))
	defer srv.Close()

	got, err := New(srv.URL, func(context.Context) (string, error) { return "tok", nil }).Repos(context.Background())
	if err != nil || len(got) != 100 {
		t.Fatalf("%d repos, %v", len(got), err)
	}
	if last := got[99]; last.FullName != "acme/api" || last.DefaultBranch != "dev" || !last.Private || last.UpdatedAt.IsZero() {
		t.Errorf("last = %+v", last)
	}

	_, err = New(srv.URL, func(context.Context) (string, error) { return "", nil }).Repos(context.Background())
	if !errors.Is(err, vcs.ErrNotConnected) {
		t.Errorf("no token: %v", err)
	}
}

func TestMembersAndAssign(t *testing.T) {
	var assigned map[string][]string
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		switch {
		case r.Method == "GET" && r.URL.Path == "/repos/acme/api/collaborators":
			_, _ = io.WriteString(w, `[{"login":"alice","avatar_url":"https://a/1","html_url":"https://github.com/alice","role_name":"admin"},{"login":"bob","role_name":"write"}]`)
		case r.Method == "POST" && r.URL.Path == "/repos/acme/api/issues/7/assignees":
			_ = json.NewDecoder(r.Body).Decode(&assigned)
			w.WriteHeader(http.StatusCreated)
			_, _ = io.WriteString(w, `{}`)
		default:
			w.WriteHeader(http.StatusNotFound)
		}
	}))
	defer srv.Close()

	h := New(srv.URL, func(context.Context) (string, error) { return "tok", nil })
	repo := domain.Repository{CloneURL: "https://github.com/acme/api.git"}
	ms, err := h.Members(context.Background(), repo)
	if err != nil || len(ms) != 2 || ms[0].Username != "alice" || ms[0].Role != "admin" || ms[0].URL == "" || ms[1].Role != "write" {
		t.Fatalf("members %+v %v", ms, err)
	}
	if err := h.Assign(context.Background(), repo, 7, []string{"alice", "bob"}); err != nil {
		t.Fatal(err)
	}
	if got := assigned["assignees"]; len(got) != 2 || got[0] != "alice" || got[1] != "bob" {
		t.Fatalf("assigned %v", assigned)
	}
}

func TestMissingPermissionIsExplained(t *testing.T) {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		w.WriteHeader(http.StatusForbidden)
		_, _ = io.WriteString(w, `{"message":"Resource not accessible by personal access token","status":"403"}`)
	}))
	defer srv.Close()
	h := New(srv.URL, func(context.Context) (string, error) { return "tok", nil })
	_, err := h.Pipelines(context.Background(), domain.Repository{CloneURL: "https://github.com/acme/api.git"}, 1, 20)
	if err == nil || !strings.Contains(err.Error(), "Actions: Read") {
		t.Fatalf("pipelines: %v", err)
	}
}

func TestCommitsPaging(t *testing.T) {
	var pages []string
	checks := 0
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		switch {
		case r.URL.Path == "/repos/acme/api/commits":
			pages = append(pages, r.URL.Query().Get("page")+"/"+r.URL.Query().Get("per_page"))
			_, _ = io.WriteString(w, `[{"sha":"abc","html_url":"u","commit":{"message":"m","author":{"name":"a","date":"2026-01-01T00:00:00Z"}}}]`)
		case strings.HasSuffix(r.URL.Path, "/check-runs"):
			checks++
			_, _ = io.WriteString(w, `{"total_count":0}`)
		default:
			w.WriteHeader(http.StatusNotFound)
		}
	}))
	defer srv.Close()
	h := New(srv.URL, func(context.Context) (string, error) { return "tok", nil })
	repo := domain.Repository{CloneURL: "https://github.com/acme/api.git", DefaultBranch: "main"}
	if _, err := h.Commits(context.Background(), repo, 1, 50); err != nil {
		t.Fatal(err)
	}
	firstPageChecks := checks
	if _, err := h.Commits(context.Background(), repo, 3, 50); err != nil {
		t.Fatal(err)
	}
	if len(pages) != 2 || pages[0] != "1/50" || pages[1] != "3/50" {
		t.Fatalf("pages requested: %v", pages)
	}
	if firstPageChecks == 0 || checks != firstPageChecks {
		t.Fatalf("CI checks: first page %d, total %d (later pages should not check)", firstPageChecks, checks)
	}
}

func TestPipelinesPaging(t *testing.T) {
	// Pipelines looks up jobs concurrently, so the handler runs on several
	// goroutines at once.
	var mu sync.Mutex
	var asked string
	jobs := 0
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		mu.Lock()
		defer mu.Unlock()
		switch {
		case r.URL.Path == "/repos/acme/api/actions/runs":
			asked = r.URL.Query().Get("page") + "/" + r.URL.Query().Get("per_page")
			_, _ = io.WriteString(w, `{"workflow_runs":[`+strings.TrimSuffix(strings.Repeat(`{"id":1,"status":"completed","conclusion":"success"},`, 20), ",")+`]}`)
		case strings.HasSuffix(r.URL.Path, "/jobs"):
			jobs++
			_, _ = io.WriteString(w, `{"jobs":[{"id":9,"name":"test","status":"completed","conclusion":"success"}]}`)
		default:
			w.WriteHeader(http.StatusNotFound)
		}
	}))
	defer srv.Close()
	h := New(srv.URL, func(context.Context) (string, error) { return "tok", nil })
	ps, err := h.Pipelines(context.Background(), domain.Repository{CloneURL: "https://github.com/acme/api.git"}, 2, 20)
	if err != nil || len(ps) != 20 {
		t.Fatalf("%d pipelines, %v", len(ps), err)
	}
	mu.Lock()
	defer mu.Unlock()
	if asked != "2/20" || jobs != 20 || len(ps[19].Stages) != 1 {
		t.Fatalf("asked %q, %d job lookups, last stages %v", asked, jobs, ps[19].Stages)
	}
}
