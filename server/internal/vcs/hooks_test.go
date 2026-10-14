package vcs

import (
	"context"
	"crypto/hmac"
	"crypto/sha256"
	"encoding/hex"
	"io"
	"log/slog"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"agnts/internal/domain"
)

type sink struct{ merged []string }

func (s *sink) MarkMerged(_ context.Context, ref domain.PRRef, _ domain.Origin) (bool, error) {
	s.merged = append(s.merged, ref.URL+"|"+ref.Branch)
	return true, nil
}

type store struct {
	seen   map[string]bool
	events []domain.Event
}

func (s *store) SeenDelivery(_ context.Context, p, id string) (bool, error) {
	if s.seen == nil {
		s.seen = map[string]bool{}
	}
	k := p + id
	v := s.seen[k]
	s.seen[k] = true
	return v, nil
}
func (s *store) AppendEvent(_ context.Context, e domain.Event) error {
	s.events = append(s.events, e)
	return nil
}

func TestGitHubWebhook(t *testing.T) {
	sk, st := &sink{}, &store{}
	log := slog.New(slog.NewTextHandler(io.Discard, nil))
	h := GitHubWebhook(func(context.Context) string { return "s3cret" }, sk, st, nil, log)
	body := `{"action":"closed","pull_request":{"merged":true,"html_url":"https://github.com/a/b/pull/7","head":{"ref":"agnts/PAY-1"}}}`
	post := func(sig, id, event string) int {
		req := httptest.NewRequest("POST", "/webhooks/github", strings.NewReader(body))
		req.Header.Set("X-Hub-Signature-256", sig)
		req.Header.Set("X-GitHub-Delivery", id)
		req.Header.Set("X-GitHub-Event", event)
		rec := httptest.NewRecorder()
		h.ServeHTTP(rec, req)
		return rec.Code
	}
	m := hmac.New(sha256.New, []byte("s3cret"))
	m.Write([]byte(body))
	good := "sha256=" + hex.EncodeToString(m.Sum(nil))
	if c := post("sha256=00", "1", "pull_request"); c != http.StatusUnauthorized {
		t.Fatalf("bad signature: %d", c)
	}
	post(good, "1", "pull_request")
	post(good, "1", "pull_request") // redelivery
	if len(sk.merged) != 1 || sk.merged[0] != "https://github.com/a/b/pull/7|agnts/PAY-1" {
		t.Fatalf("merged: %v", sk.merged)
	}
}

func TestGitLabWebhook(t *testing.T) {
	sk, st := &sink{}, &store{}
	pinged := 0
	h := GitLabWebhook(func(context.Context) string { return "tok" }, sk, st, func() { pinged++ }, slog.New(slog.NewTextHandler(io.Discard, nil)))
	post := func(token, body string) int {
		req := httptest.NewRequest("POST", "/webhooks/gitlab", strings.NewReader(body))
		req.Header.Set("X-Gitlab-Token", token)
		rec := httptest.NewRecorder()
		h.ServeHTTP(rec, req)
		return rec.Code
	}
	mr := `{"object_kind":"merge_request","object_attributes":{"action":"merge","url":"https://gitlab.com/a/b/-/merge_requests/3","source_branch":"agnts/X-1"}}`
	if c := post("wrong", mr); c != http.StatusUnauthorized {
		t.Fatalf("bad token: %d", c)
	}
	post("tok", mr)
	post("tok", `{"object_kind":"pipeline","project":{"path_with_namespace":"a/b"}}`)
	if len(sk.merged) != 1 || pinged != 1 || len(st.events) != 1 {
		t.Fatalf("merged %v pinged %d events %d", sk.merged, pinged, len(st.events))
	}
	if DeriveSecret([]byte("k"), "github") == DeriveSecret([]byte("k"), "gitlab") {
		t.Fatal("secrets must differ per provider")
	}
}

type closeSink struct {
	sink
	closed []string
}

func (s *closeSink) MarkPRClosed(_ context.Context, ref domain.PRRef, closed bool, _ domain.Origin) (bool, error) {
	s.closed = append(s.closed, ref.URL+"|"+ref.Branch+"|"+map[bool]string{true: "closed", false: "reopened"}[closed])
	return true, nil
}

// A pull request closed without a merge, or reopened, reaches a sink that
// takes them; a merge still goes to MarkMerged only.
func TestWebhookClosedPR(t *testing.T) {
	log := slog.New(slog.NewTextHandler(io.Discard, nil))
	gh := &closeSink{}
	h := GitHubWebhook(func(context.Context) string { return "s" }, gh, &store{}, nil, log)
	for i, body := range []string{
		`{"action":"closed","pull_request":{"merged":false,"html_url":"https://github.com/a/b/pull/7","head":{"ref":"agnts/PAY-1"}}}`,
		`{"action":"reopened","pull_request":{"merged":false,"html_url":"https://github.com/a/b/pull/7","head":{"ref":"agnts/PAY-1"}}}`,
		`{"action":"closed","pull_request":{"merged":true,"html_url":"https://github.com/a/b/pull/7","head":{"ref":"agnts/PAY-1"}}}`,
	} {
		m := hmac.New(sha256.New, []byte("s"))
		m.Write([]byte(body))
		req := httptest.NewRequest("POST", "/webhooks/github", strings.NewReader(body))
		req.Header.Set("X-Hub-Signature-256", "sha256="+hex.EncodeToString(m.Sum(nil)))
		req.Header.Set("X-GitHub-Delivery", string(rune('a'+i)))
		req.Header.Set("X-GitHub-Event", "pull_request")
		h.ServeHTTP(httptest.NewRecorder(), req)
	}
	if strings.Join(gh.closed, ",") != "https://github.com/a/b/pull/7|agnts/PAY-1|closed,https://github.com/a/b/pull/7|agnts/PAY-1|reopened" || len(gh.merged) != 1 {
		t.Fatalf("github: closed %v merged %v", gh.closed, gh.merged)
	}

	gl := &closeSink{}
	h = GitLabWebhook(func(context.Context) string { return "tok" }, gl, &store{}, nil, log)
	for _, action := range []string{"close", "reopen", "merge"} {
		body := `{"object_kind":"merge_request","object_attributes":{"action":"` + action + `","url":"https://gitlab.com/a/b/-/merge_requests/3","source_branch":"agnts/X-1"}}`
		req := httptest.NewRequest("POST", "/webhooks/gitlab", strings.NewReader(body))
		req.Header.Set("X-Gitlab-Token", "tok")
		h.ServeHTTP(httptest.NewRecorder(), req)
	}
	if len(gl.closed) != 2 || !strings.HasSuffix(gl.closed[0], "|closed") || !strings.HasSuffix(gl.closed[1], "|reopened") || len(gl.merged) != 1 {
		t.Fatalf("gitlab: closed %v merged %v", gl.closed, gl.merged)
	}
}

type ciSink struct {
	sink
	runs []domain.CIRun
}

func (s *ciSink) CIRunFinished(_ context.Context, r domain.CIRun) error {
	s.runs = append(s.runs, r)
	return nil
}

func TestGitHubWorkflowRun(t *testing.T) {
	sk, st := &ciSink{}, &store{}
	h := GitHubWebhook(func(context.Context) string { return "s" }, sk, st, nil, slog.New(slog.NewTextHandler(io.Discard, nil)))
	post := func(id, body string) {
		m := hmac.New(sha256.New, []byte("s"))
		m.Write([]byte(body))
		req := httptest.NewRequest("POST", "/webhooks/github", strings.NewReader(body))
		req.Header.Set("X-Hub-Signature-256", "sha256="+hex.EncodeToString(m.Sum(nil)))
		req.Header.Set("X-GitHub-Delivery", id)
		req.Header.Set("X-GitHub-Event", "workflow_run")
		h.ServeHTTP(httptest.NewRecorder(), req)
	}
	post("1", `{"action":"in_progress","workflow_run":{"id":5,"status":"in_progress"},"repository":{"full_name":"acme/api"}}`)
	post("2", `{"action":"completed","workflow_run":{"id":5,"name":"CI","path":".github/workflows/ci.yml","head_branch":"main",
		"head_sha":"abc","event":"push","status":"completed","conclusion":"failure","run_attempt":2,"html_url":"https://github.com/acme/api/actions/runs/5",
		"updated_at":"2026-10-12T09:00:00Z","pull_requests":[{"number":9}],"head_commit":{"message":"Fix coupons\n\nbody","author":{"name":"Ann"}},
		"head_repository":{"full_name":"someone/api"}},"repository":{"full_name":"acme/api"}}`)
	if len(sk.runs) != 1 {
		t.Fatalf("runs %+v", sk.runs)
	}
	r := sk.runs[0]
	if r.Repo != "acme/api" || r.RunID != 5 || r.Attempt != 2 || r.Workflow != "ci.yml" || r.Branch != "main" || !r.Failed() ||
		r.Message != "Fix coupons" || r.Author != "Ann" || !r.Fork || len(r.PRNumbers) != 1 || r.PRNumbers[0] != 9 {
		t.Errorf("run %+v", r)
	}
	if len(st.events) != 2 {
		t.Errorf("pipeline events still recorded: %d", len(st.events))
	}
}

func TestGitLabPipelineRun(t *testing.T) {
	sk, st := &ciSink{}, &store{}
	h := GitLabWebhook(func(context.Context) string { return "tok" }, sk, st, nil, slog.New(slog.NewTextHandler(io.Discard, nil)))
	post := func(body string) {
		req := httptest.NewRequest("POST", "/webhooks/gitlab", strings.NewReader(body))
		req.Header.Set("X-Gitlab-Token", "tok")
		h.ServeHTTP(httptest.NewRecorder(), req)
	}
	post(`{"object_kind":"pipeline","object_attributes":{"id":77,"ref":"main","sha":"def","status":"running"},"project":{"path_with_namespace":"g/p"}}`)
	post(`{"object_kind":"pipeline","object_attributes":{"id":77,"ref":"refs/merge-requests/3/head","sha":"def","status":"failed","source":"merge_request_event",
		"finished_at":"2026-10-12 09:00:00 UTC"},"merge_request":{"iid":3,"source_project_id":1,"target_project_id":1,"source_branch":"feat"},
		"project":{"path_with_namespace":"g/p","web_url":"https://gitlab.com/g/p"},"commit":{"message":"Add x","author":{"name":"Bo"}}}`)
	if len(sk.runs) != 1 {
		t.Fatalf("runs %+v", sk.runs)
	}
	r := sk.runs[0]
	if r.Repo != "g/p" || r.RunID != 77 || r.Branch != "feat" || !r.Failed() || r.Fork || r.URL != "https://gitlab.com/g/p/-/pipelines/77" ||
		len(r.PRNumbers) != 1 || r.Finished.Year() != 2026 {
		t.Errorf("run %+v", r)
	}
}
