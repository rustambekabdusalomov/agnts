package gitlab

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

const mrJSON = `{"iid":4,"web_url":"https://gl/acme/api/-/merge_requests/4","sha":"h2",
  "diff_refs":{"base_sha":"b1","head_sha":"h2","start_sha":"s1"}}`

const discussionsJSON = `[
  {"id":"d1","individual_note":true,"notes":[
    {"id":11,"body":"Looks good","author":{"username":"carol"},"created_at":"2026-10-01T09:00:00Z","updated_at":"2026-10-01T09:00:00Z"}]},
  {"id":"d2","individual_note":false,"notes":[
    {"id":21,"body":"Why not LRU?","author":{"username":"bob"},"created_at":"2026-10-01T10:00:00Z","updated_at":"2026-10-01T10:00:00Z",
     "resolvable":true,"resolved":false,"position":{"base_sha":"b1","start_sha":"s1","head_sha":"h2","old_path":"cache.go","new_path":"cache.go","new_line":12}},
    {"id":22,"body":"Fixed","author":{"username":"me"},"created_at":"2026-10-01T11:00:00Z","updated_at":"2026-10-01T11:00:00Z","resolvable":true,"resolved":false}]},
  {"id":"d3","individual_note":false,"notes":[
    {"id":31,"body":"drop","author":{"username":"bob"},"created_at":"2026-09-30T08:00:00Z","updated_at":"2026-09-30T08:00:00Z",
     "resolvable":true,"resolved":true,"position":{"head_sha":"h1","old_path":"old.go","new_path":"old.go","old_line":7}}]},
  {"id":"d4","individual_note":true,"notes":[
    {"id":41,"body":"added 2 commits","system":true,"author":{"username":"bob"},"created_at":"2026-10-01T12:00:00Z","updated_at":"2026-10-01T12:00:00Z"}]}
]`

type glFake struct {
	mu       sync.Mutex
	writes   []string
	bodies   []map[string]any
	noDrafts bool
	drafts   int
}

func (f *glFake) record(r *http.Request) map[string]any {
	var b map[string]any
	_ = json.NewDecoder(r.Body).Decode(&b)
	f.mu.Lock()
	defer f.mu.Unlock()
	f.writes = append(f.writes, r.Method+" "+r.URL.EscapedPath()+"?"+r.URL.RawQuery)
	f.bodies = append(f.bodies, b)
	return b
}

func glServer(t *testing.T, f *glFake) *httptest.Server {
	t.Helper()
	const mr = "/api/v4/projects/acme%2Fapi/merge_requests/4"
	return httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		p := r.URL.EscapedPath()
		switch {
		case p == "/api/v4/user":
			_, _ = io.WriteString(w, `{"username":"me"}`)
		case r.Method == "GET" && p == mr:
			_, _ = io.WriteString(w, mrJSON)
		case r.Method == "GET" && p == mr+"/discussions":
			_, _ = io.WriteString(w, discussionsJSON)
		case r.Method == "GET" && p == mr+"/diffs":
			_, _ = io.WriteString(w, `[{"old_path":"cache.go","new_path":"cache.go","diff":"@@ -1,2 +1,3 @@\n a\n+b\n-c\n+d"}]`)
		case r.Method == "POST" && p == mr+"/notes":
			f.record(r)
			_, _ = io.WriteString(w, `{"id":51,"body":"x","author":{"username":"me"}}`)
		case r.Method == "POST" && p == mr+"/discussions":
			b := f.record(r)
			if pos, _ := b["position"].(map[string]any); pos["new_line"] == float64(999) {
				w.WriteHeader(http.StatusBadRequest)
				_, _ = io.WriteString(w, `{"message":"400 Bad request - Note {:line_code=>[\"can't be blank\"]}"}`)
				return
			}
			_, _ = io.WriteString(w, `{"id":"d9","notes":[{"id":91,"body":"nit","author":{"username":"me"},"resolvable":true,
				"position":{"head_sha":"h2","new_path":"cache.go","old_path":"cache.go","new_line":12}}]}`)
		case r.Method == "POST" && p == mr+"/discussions/d2/notes":
			f.record(r)
			_, _ = io.WriteString(w, `{"id":61,"body":"done","author":{"username":"me"}}`)
		case r.Method == "PUT" && p == mr+"/notes/22":
			b := f.record(r)
			_, _ = io.WriteString(w, `{"id":22,"body":`+mustJSON(b["body"])+`,"author":{"username":"me"}}`)
		case r.Method == "DELETE" && p == mr+"/notes/22":
			f.record(r)
			w.WriteHeader(http.StatusNoContent)
		case r.Method == "PUT" && p == mr+"/discussions/d2":
			f.record(r)
			_, _ = io.WriteString(w, `{"id":"d2"}`)
		case r.Method == "POST" && p == mr+"/draft_notes":
			f.record(r)
			if f.noDrafts {
				w.WriteHeader(http.StatusNotFound)
				return
			}
			f.mu.Lock()
			f.drafts++
			n := f.drafts
			f.mu.Unlock()
			_, _ = io.WriteString(w, `{"id":`+mustJSON(700+n)+`}`)
		case r.Method == "POST" && p == mr+"/draft_notes/bulk_publish":
			f.record(r)
			w.WriteHeader(http.StatusNoContent)
		default:
			t.Errorf("unexpected %s %s", r.Method, p)
			w.WriteHeader(http.StatusNotFound)
		}
	}))
}

func mustJSON(v any) string {
	b, _ := json.Marshal(v)
	return string(b)
}

func TestGitLabThreads(t *testing.T) {
	f := &glFake{}
	srv := glServer(t, f)
	defer srv.Close()
	h := WithConfig(Config{URL: srv.URL, Token: "glpat"})
	repo := domain.Repository{CloneURL: srv.URL + "/acme/api.git"}

	ts, err := h.Threads(context.Background(), repo, 4)
	if err != nil {
		t.Fatal(err)
	}
	if len(ts) != 4 || ts[0].ID != "gd:d3" || ts[1].ID != "gd:d1" || ts[2].ID != "gd:d2" || ts[3].ID != "gd:d4" {
		t.Fatalf("order: %+v", ts)
	}
	old, general, inline, system := ts[0], ts[1], ts[2], ts[3]
	if old.Kind != domain.ThreadInline || old.OldLine != 7 || old.Line != 0 || !old.Outdated || !old.Resolved {
		t.Errorf("thread on an older version: %+v", old)
	}
	if general.Kind != domain.ThreadGeneral || general.Resolvable || general.Comments[0].ID != "n:11" ||
		general.Comments[0].URL != "https://gl/acme/api/-/merge_requests/4#note_11" {
		t.Errorf("general: %+v", general)
	}
	if inline.Path != "cache.go" || inline.Line != 12 || inline.Outdated || !inline.Resolvable || inline.Resolved ||
		len(inline.Comments) != 2 || inline.Comments[0].Mine || !inline.Comments[1].Mine {
		t.Errorf("inline: %+v", inline)
	}
	if !system.Comments[0].System || system.Comments[0].Mine {
		t.Errorf("system note: %+v", system)
	}
}

func TestGitLabWrites(t *testing.T) {
	f := &glFake{}
	srv := glServer(t, f)
	defer srv.Close()
	h := WithConfig(Config{URL: srv.URL, Token: "glpat"})
	repo := domain.Repository{CloneURL: srv.URL + "/acme/api.git"}
	ctx := context.Background()

	th, err := h.AddComment(ctx, repo, 4, domain.NewPRComment{Body: "nit", Path: "cache.go", Line: 12})
	if err != nil || th.ID != "gd:d9" || th.Line != 12 {
		t.Fatalf("inline: %+v %v", th, err)
	}
	pos := f.bodies[len(f.bodies)-1]["position"].(map[string]any)
	if pos["base_sha"] != "b1" || pos["start_sha"] != "s1" || pos["head_sha"] != "h2" || pos["new_line"] != float64(12) || pos["position_type"] != "text" {
		t.Errorf("position: %v", pos)
	}
	if _, err := h.AddComment(ctx, repo, 4, domain.NewPRComment{Body: "x", Path: "cache.go", Line: 999}); !errors.Is(err, domain.ErrNotInDiff) {
		t.Errorf("line outside the diff: %v", err)
	}
	if th, err := h.AddComment(ctx, repo, 4, domain.NewPRComment{Body: "x"}); err != nil || th.ID != "gn:51" {
		t.Errorf("general: %+v %v", th, err)
	}
	if c, err := h.Reply(ctx, repo, 4, "gd:d2", "done"); err != nil || c.ID != "n:61" {
		t.Errorf("reply: %+v %v", c, err)
	}
	// A comment agnts just posted: its discussion is looked up.
	if _, err := h.Reply(ctx, repo, 4, "gn:22", "done"); err != nil || !strings.Contains(f.writes[len(f.writes)-1], "/discussions/d2/notes") {
		t.Errorf("reply to a new note: %v %v", err, f.writes)
	}
	if c, err := h.EditComment(ctx, repo, 4, "n:22", "edited"); err != nil || c.Body != "edited" {
		t.Errorf("edit: %+v %v", c, err)
	}
	if err := h.DeleteComment(ctx, repo, 4, "n:22"); err != nil {
		t.Errorf("delete: %v", err)
	}
	if err := h.DeleteComment(ctx, repo, 4, "n:22/../x"); err == nil {
		t.Error("took a malformed id")
	}
	if err := h.ResolveThread(ctx, repo, 4, "gd:d2", true); err != nil || !strings.HasSuffix(f.writes[len(f.writes)-1], "?resolved=true") {
		t.Errorf("resolve: %v %v", err, f.writes)
	}
	files, err := h.PullFiles(ctx, repo, 4)
	if err != nil || len(files) != 1 || files[0].Add != 2 || files[0].Del != 1 {
		t.Errorf("files: %+v %v", files, err)
	}
}

func TestGitLabPostReview(t *testing.T) {
	f := &glFake{}
	srv := glServer(t, f)
	defer srv.Close()
	h := WithConfig(Config{URL: srv.URL, Token: "glpat"})
	repo := domain.Repository{CloneURL: srv.URL + "/acme/api.git"}
	ctx := context.Background()

	// "Fixed" is the token user's note in d2 on cache.go: matched as the
	// inline comment that was published.
	_, threads, err := h.PostReview(ctx, repo, 4, "h2", "summary", []domain.NewPRComment{{Body: "Fixed", Path: "cache.go", Line: 12}}, false)
	if err != nil {
		t.Fatal(err)
	}
	if f.drafts != 2 || !strings.Contains(strings.Join(f.writes, " "), "bulk_publish") {
		t.Errorf("drafts: %d %v", f.drafts, f.writes)
	}
	if len(threads) != 1 {
		t.Fatalf("threads: %+v", threads)
	}

	// Without draft notes the comments go one by one.
	g := &glFake{noDrafts: true}
	srv2 := glServer(t, g)
	defer srv2.Close()
	h2 := WithConfig(Config{URL: srv2.URL, Token: "glpat"})
	repo2 := domain.Repository{CloneURL: srv2.URL + "/acme/api.git"}
	sum, threads, err := h2.PostReview(ctx, repo2, 4, "h2", "summary", []domain.NewPRComment{{Body: "nit", Path: "cache.go", Line: 12}}, false)
	if err != nil || sum != "n:51" || len(threads) != 1 || threads[0].ID != "gd:d9" {
		t.Errorf("one by one: %q %+v %v (%v)", sum, threads, err, g.writes)
	}
}
