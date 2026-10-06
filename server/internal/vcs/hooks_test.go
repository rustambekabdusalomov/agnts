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

func (s *sink) MarkMerged(_ context.Context, url, branch string, _ domain.Origin) (bool, error) {
	s.merged = append(s.merged, url+"|"+branch)
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
	h := GitHubWebhook("s3cret", sk, st, nil, log)
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
	h := GitLabWebhook("tok", sk, st, func() { pinged++ }, slog.New(slog.NewTextHandler(io.Discard, nil)))
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
