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
)

// fakeConversation serves one pull request's conversation and records the
// writes.
type fakeConversation struct {
	mu     sync.Mutex
	writes []string         // "METHOD path"
	bodies []map[string]any // their JSON bodies
}

func (f *fakeConversation) record(r *http.Request) map[string]any {
	var b map[string]any
	_ = json.NewDecoder(r.Body).Decode(&b)
	f.mu.Lock()
	defer f.mu.Unlock()
	f.writes = append(f.writes, r.Method+" "+r.URL.Path)
	f.bodies = append(f.bodies, b)
	return b
}

const threadsGraphQL = `{"data":{"viewer":{"login":"me"},"repository":{"pullRequest":{"reviewThreads":{
  "pageInfo":{"hasNextPage":false,"endCursor":""},
  "nodes":[
    {"id":"PRRT_a","isResolved":false,"isOutdated":false,"path":"cache.go","line":12,"originalLine":12,"startLine":null,"originalStartLine":null,"diffSide":"RIGHT",
     "comments":{"nodes":[
       {"databaseId":101,"body":"Why not LRU?","createdAt":"2026-10-01T10:00:00Z","lastEditedAt":null,"url":"u101","diffHunk":"@@ -1,3 +10,4 @@","author":{"login":"bob","avatarUrl":"av"},"commit":{"oid":"c2"},"originalCommit":{"oid":"c1"}},
       {"databaseId":102,"body":"Fair, will do","createdAt":"2026-10-01T11:00:00Z","lastEditedAt":"2026-10-01T11:05:00Z","url":"u102","diffHunk":"","author":{"login":"me","avatarUrl":""},"commit":null,"originalCommit":null}]}},
    {"id":"PRRT_b","isResolved":true,"isOutdated":true,"path":"old.go","line":null,"originalLine":7,"startLine":null,"originalStartLine":null,"diffSide":"LEFT",
     "comments":{"nodes":[{"databaseId":103,"body":"drop this","createdAt":"2026-09-30T09:00:00Z","lastEditedAt":null,"url":"u103","diffHunk":"","author":null,"commit":null,"originalCommit":{"oid":"c0"}}]}}
  ]}}}}}`

func conversationServer(t *testing.T, f *fakeConversation) *httptest.Server {
	t.Helper()
	return httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		p := r.URL.Path
		switch {
		case p == "/user":
			_, _ = io.WriteString(w, `{"login":"me"}`)
		case p == "/graphql":
			b := f.record(r)
			if q, _ := b["query"].(string); strings.Contains(q, "resolveReviewThread") || strings.Contains(q, "unresolveReviewThread") {
				_, _ = io.WriteString(w, `{"data":{"resolveReviewThread":{"thread":{"isResolved":true}}}}`)
				return
			}
			_, _ = io.WriteString(w, threadsGraphQL)
		case r.Method == "GET" && p == "/repos/acme/api/issues/4/comments":
			_, _ = io.WriteString(w, `[{"id":201,"user":{"login":"carol"},"body":"Looks good overall","created_at":"2026-10-01T09:00:00Z","updated_at":"2026-10-01T09:00:00Z","html_url":"u201"}]`)
		case r.Method == "GET" && p == "/repos/acme/api/pulls/4/reviews":
			_, _ = io.WriteString(w, `[
			  {"id":301,"user":{"login":"bob"},"body":"","state":"COMMENTED","submitted_at":"2026-10-01T10:00:00Z"},
			  {"id":302,"user":{"login":"bob"},"body":"Please fix the cache","state":"CHANGES_REQUESTED","commit_id":"c1","submitted_at":"2026-10-01T10:01:00Z"},
			  {"id":303,"user":{"login":"me"},"body":"draft","state":"PENDING","submitted_at":"2026-10-01T10:02:00Z"}]`)
		case r.Method == "GET" && p == "/repos/acme/api/pulls/4/files":
			_, _ = io.WriteString(w, `[{"filename":"cache.go","additions":3,"deletions":1,"patch":"@@ -10,3 +10,5 @@\n a\n+b"}]`)
		case r.Method == "POST" && p == "/repos/acme/api/pulls/4/comments":
			b := f.record(r)
			if b["line"] == float64(999) {
				w.WriteHeader(http.StatusUnprocessableEntity)
				_, _ = io.WriteString(w, `{"message":"Validation Failed","errors":["line must be part of the diff"]}`)
				return
			}
			_, _ = io.WriteString(w, `{"id":401,"user":{"login":"me"},"body":"nit","path":"cache.go","line":12,"side":"RIGHT","commit_id":"c2"}`)
		case r.Method == "POST" && p == "/repos/acme/api/pulls/4/comments/101/replies":
			f.record(r)
			_, _ = io.WriteString(w, `{"id":402,"user":{"login":"me"},"body":"done"}`)
		case r.Method == "GET" && p == "/repos/acme/api/issues/comments/201":
			_, _ = io.WriteString(w, `{"id":201,"user":{"login":"carol"},"body":"Looks good overall\nmore"}`)
		case r.Method == "POST" && p == "/repos/acme/api/issues/4/comments":
			f.record(r)
			_, _ = io.WriteString(w, `{"id":202,"user":{"login":"me"},"body":"x"}`)
		case r.Method == "PATCH" && (p == "/repos/acme/api/issues/comments/202" || p == "/repos/acme/api/pulls/comments/402"):
			b := f.record(r)
			_, _ = io.WriteString(w, `{"id":202,"user":{"login":"me"},"body":`+mustJSON(b["body"])+`}`)
		case r.Method == "DELETE" && (p == "/repos/acme/api/issues/comments/202" || p == "/repos/acme/api/pulls/comments/999"):
			f.record(r)
			if strings.HasSuffix(p, "999") {
				w.WriteHeader(http.StatusNotFound)
				return
			}
			w.WriteHeader(http.StatusNoContent)
		case r.Method == "POST" && p == "/repos/acme/api/pulls/4/reviews":
			f.record(r)
			_, _ = io.WriteString(w, `{"id":501,"user":{"login":"me"},"state":"COMMENTED"}`)
		case r.Method == "GET" && p == "/repos/acme/api/pulls/4/reviews/501/comments":
			_, _ = io.WriteString(w, `[{"id":602,"path":"b.go","line":3,"side":"RIGHT","body":"second","user":{"login":"me"}},
			                          {"id":601,"path":"a.go","line":1,"side":"RIGHT","body":"first","user":{"login":"me"}}]`)
		default:
			t.Errorf("unexpected %s %s", r.Method, r.URL)
			w.WriteHeader(http.StatusNotFound)
		}
	}))
}

func mustJSON(v any) string {
	b, _ := json.Marshal(v)
	return string(b)
}

func TestThreads(t *testing.T) {
	f := &fakeConversation{}
	srv := conversationServer(t, f)
	defer srv.Close()
	h := New(srv.URL, func(context.Context) (string, error) { return "tok", nil })
	repo := domain.Repository{CloneURL: "https://github.com/acme/api.git"}

	ts, err := h.Threads(context.Background(), repo, 4)
	if err != nil {
		t.Fatal(err)
	}
	// Ordered by first comment: old.go (09-30), carol (10-01 09:00),
	// cache.go (10:00), the review with a body (10:01). The bare COMMENTED
	// review and the pending one are left out.
	if len(ts) != 4 {
		t.Fatalf("threads: %+v", ts)
	}
	old, general, inline, review := ts[0], ts[1], ts[2], ts[3]
	if old.ID != "th:PRRT_b:103" || old.OldLine != 7 || old.Line != 0 || !old.Outdated || !old.Resolved || old.Comments[0].Author != "ghost" || old.CommitSHA != "c0" {
		t.Errorf("outdated thread on a removed line: %+v", old)
	}
	if general.ID != "ic:201" || general.Kind != domain.ThreadGeneral || general.Comments[0].Mine || general.Resolvable {
		t.Errorf("general: %+v", general)
	}
	if inline.ID != "th:PRRT_a:101" || inline.Kind != domain.ThreadInline || inline.Path != "cache.go" || inline.Line != 12 || !inline.Resolvable ||
		len(inline.Comments) != 2 || inline.Comments[0].ID != "rc:101" || inline.Comments[0].Mine || !inline.Comments[1].Mine ||
		!inline.Comments[1].Edited() || inline.CommitSHA != "c1" || inline.DiffHunk == "" {
		t.Errorf("inline: %+v", inline)
	}
	if review.ID != "rv:302" || review.Kind != domain.ThreadReview || review.ReviewState != "CHANGES_REQUESTED" {
		t.Errorf("review: %+v", review)
	}
}

func TestCommentWrites(t *testing.T) {
	f := &fakeConversation{}
	srv := conversationServer(t, f)
	defer srv.Close()
	h := New(srv.URL, func(context.Context) (string, error) { return "tok", nil })
	repo := domain.Repository{CloneURL: "https://github.com/acme/api.git"}
	ctx := context.Background()

	th, err := h.AddComment(ctx, repo, 4, domain.NewPRComment{Body: "nit", Path: "cache.go", Line: 12, HeadSHA: "c2"})
	if err != nil || th.ID != "th::401" || th.Line != 12 || !th.Comments[0].Mine {
		t.Fatalf("inline comment: %+v %v", th, err)
	}
	if b := f.bodies[len(f.bodies)-1]; b["commit_id"] != "c2" || b["side"] != "RIGHT" || b["path"] != "cache.go" {
		t.Errorf("inline body: %v", b)
	}
	if _, err := h.AddComment(ctx, repo, 4, domain.NewPRComment{Body: "x", Path: "cache.go", Line: 999, HeadSHA: "c2"}); !errors.Is(err, domain.ErrNotInDiff) {
		t.Errorf("a line outside the diff: %v", err)
	}
	if _, err := h.AddComment(ctx, repo, 4, domain.NewPRComment{Body: "x", Path: "old.go", OldLine: 7, HeadSHA: "c2"}); err != nil {
		t.Fatal(err)
	}
	if b := f.bodies[len(f.bodies)-1]; b["side"] != "LEFT" || b["line"] != float64(7) {
		t.Errorf("removed line body: %v", b)
	}
	if th, err := h.AddComment(ctx, repo, 4, domain.NewPRComment{Body: "x"}); err != nil || th.ID != "ic:202" {
		t.Errorf("general comment: %+v %v", th, err)
	}

	if c, err := h.Reply(ctx, repo, 4, "th:PRRT_a:101", "done"); err != nil || c.ID != "rc:402" {
		t.Errorf("reply in a thread: %+v %v", c, err)
	}
	// General comments have no threads: the answer quotes them.
	if _, err := h.Reply(ctx, repo, 4, "ic:201", "thanks"); err != nil {
		t.Fatal(err)
	}
	if b := f.bodies[len(f.bodies)-1]; b["body"] != "> @carol: Looks good overall\n\nthanks" {
		t.Errorf("quoted reply: %q", b["body"])
	}

	if c, err := h.EditComment(ctx, repo, 4, "ic:202", "edited"); err != nil || c.Body != "edited" {
		t.Errorf("edit: %+v %v", c, err)
	}
	if _, err := h.EditComment(ctx, repo, 4, "rc:402", "edited"); err != nil {
		t.Errorf("edit review comment: %v", err)
	}
	if err := h.DeleteComment(ctx, repo, 4, "ic:202"); err != nil {
		t.Errorf("delete: %v", err)
	}
	if err := h.DeleteComment(ctx, repo, 4, "rc:999"); err != nil {
		t.Errorf("deleting a comment that is gone: %v", err)
	}
	if err := h.DeleteComment(ctx, repo, 4, "rv:302"); err == nil {
		t.Error("deleted a submitted review")
	}
	if err := h.DeleteComment(ctx, repo, 4, "../../x"); err == nil {
		t.Error("took a malformed id")
	}

	if err := h.ResolveThread(ctx, repo, 4, "th:PRRT_a:101", true); err != nil {
		t.Fatal(err)
	}
	if b := f.bodies[len(f.bodies)-1]; b["variables"].(map[string]any)["id"] != "PRRT_a" {
		t.Errorf("resolve: %v", b)
	}
	// A thread agnts just started: its GraphQL id is looked up first.
	if err := h.ResolveThread(ctx, repo, 4, "th::103", true); err != nil {
		t.Fatal(err)
	}
	if b := f.bodies[len(f.bodies)-1]; b["variables"].(map[string]any)["id"] != "PRRT_b" {
		t.Errorf("resolve a new thread: %v", b)
	}
	if err := h.ResolveThread(ctx, repo, 4, "ic:201", true); err == nil {
		t.Error("resolved a general comment")
	}
}

func TestPostReviewAndFiles(t *testing.T) {
	f := &fakeConversation{}
	srv := conversationServer(t, f)
	defer srv.Close()
	h := New(srv.URL, func(context.Context) (string, error) { return "tok", nil })
	repo := domain.Repository{CloneURL: "https://github.com/acme/api.git"}
	ctx := context.Background()

	cs := []domain.NewPRComment{{Body: "first", Path: "a.go", Line: 1}, {Body: "second", Path: "b.go", Line: 3, StartLine: 1}}
	sum, threads, err := h.PostReview(ctx, repo, 4, "c2", "## agnts review", cs, true)
	if err != nil || sum != "rv:501" || len(threads) != 2 || threads[0].ID != "th::601" || threads[1].ID != "th::602" {
		t.Fatalf("post review: %q %+v %v", sum, threads, err)
	}
	b := f.bodies[len(f.bodies)-1]
	if b["event"] != "REQUEST_CHANGES" || b["commit_id"] != "c2" || len(b["comments"].([]any)) != 2 {
		t.Errorf("review body: %v", b)
	}
	if c := b["comments"].([]any)[1].(map[string]any); c["start_line"] != float64(1) || c["start_side"] != "RIGHT" {
		t.Errorf("range comment: %v", c)
	}

	files, err := h.PullFiles(ctx, repo, 4)
	if err != nil || len(files) != 1 || files[0].Path != "cache.go" || files[0].Add != 3 || !strings.HasPrefix(files[0].Diff, "@@") {
		t.Errorf("files: %+v %v", files, err)
	}
}
