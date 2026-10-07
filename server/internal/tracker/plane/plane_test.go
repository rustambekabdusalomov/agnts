package plane

import (
	"bytes"
	"context"
	"crypto/hmac"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"io"
	"log/slog"
	"net/http"
	"net/http/httptest"
	"strconv"
	"strings"
	"sync"
	"testing"
	"time"

	"golang.org/x/time/rate"

	"agnts/internal/domain"
	"agnts/internal/orchestrator"
)

// fakePlane is the slice of the Plane API v1 the adapter uses, in memory.
type fakePlane struct {
	t  *testing.T
	mu sync.Mutex
	// items by id; project p1 is WEB.
	items     map[string]map[string]any
	labels    []label
	states    []State
	relations map[string]map[string][]relRef
	comments  []string // "<item id>: <html>"
	patches   []string // "<item id>: <json>"
	posts     []string // created labels, items and relations
	tooMany   int      // answer this many requests with 429 first
	calls     int
	pageSize  int // work item list page size (0: all on one page)
}

func newFakePlane(t *testing.T) *fakePlane {
	return &fakePlane{t: t,
		items: map[string]map[string]any{
			"i12": {"id": "i12", "sequence_id": 12, "name": "Fix refund rounding", "priority": "urgent", "project": "p1",
				"state": "s-todo", "labels": []string{"l-code"},
				"description_html": `<p>Round <strong>half up</strong>.</p><ul><li><p>see <a href="https://x.dev/a">docs</a></p></li></ul><pre><code>x := 1</code></pre>`},
			"i3":  {"id": "i3", "sequence_id": 3, "name": "Add the column", "priority": "none", "project": "p1", "state": "s-todo", "labels": []string{"l-agnts"}},
			"i4":  {"id": "i4", "sequence_id": 4, "name": "Not for agnts", "priority": "low", "project": "p1", "state": "s-todo", "labels": []string{}},
			"i5":  {"id": "i5", "sequence_id": 5, "name": "Already shipped", "priority": "low", "project": "p1", "state": "s-done", "labels": []string{"l-agnts"}},
			"i20": {"id": "i20", "sequence_id": 20, "name": "Waits for 12", "priority": "medium", "project": "p1", "state": "s-todo", "labels": []string{"l-agnts"}},
		},
		labels: []label{{ID: "l-agnts", Name: "agnts"}, {ID: "l-code", Name: "agnts-code"}, {ID: "l-ui", Name: "ui"}},
		states: []State{{ID: "s-back", Name: "Backlog", Group: "backlog"}, {ID: "s-todo", Name: "Todo", Group: "unstarted"},
			{ID: "s-prog", Name: "In Progress", Group: "started"}, {ID: "s-rev", Name: "In Review", Group: "started"},
			{ID: "s-done", Name: "Done", Group: "completed"}, {ID: "s-cancel", Name: "Cancelled", Group: "cancelled"}},
		relations: map[string]map[string][]relRef{
			"i12": {"blocked_by": {{ProjectID: "p1", IssueID: "i3"}}, "blocking": {{ProjectID: "p1", IssueID: "i20"}}},
		},
	}
}

func (f *fakePlane) expanded(it map[string]any) map[string]any {
	out := map[string]any{}
	for k, v := range it {
		out[k] = v
	}
	for _, s := range f.states {
		if s.ID == it["state"] {
			out["state"] = s
		}
	}
	var ls []label
	for _, id := range it["labels"].([]string) {
		for _, l := range f.labels {
			if l.ID == id {
				ls = append(ls, l)
			}
		}
	}
	out["labels"] = ls
	return out
}

func (f *fakePlane) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	f.mu.Lock()
	defer f.mu.Unlock()
	f.calls++
	if f.tooMany > 0 {
		f.tooMany--
		w.Header().Set("Retry-After", "2")
		w.WriteHeader(http.StatusTooManyRequests)
		return
	}
	if r.Header.Get("X-API-Key") != "key" {
		w.WriteHeader(http.StatusUnauthorized)
		return
	}
	p := strings.TrimPrefix(r.URL.Path, "/api/v1")
	body, _ := io.ReadAll(r.Body)
	send := func(v any) { _ = json.NewEncoder(w).Encode(v) }
	page := func(results []any) {
		send(map[string]any{"results": results, "next_cursor": "", "next_page_results": false})
	}
	seg := strings.Split(strings.Trim(p, "/"), "/")
	switch {
	case p == "/users/me/":
		send(map[string]string{"first_name": "Rustam", "last_name": "A", "email": "r@example.com"})
	case p == "/workspaces/acme/projects/":
		page([]any{map[string]string{"id": "p1", "identifier": "WEB", "name": "Web"}})
	case strings.HasPrefix(p, "/workspaces/acme/work-items/"):
		key := seg[3]
		for _, it := range f.items {
			if "WEB-"+strconv.Itoa(it["sequence_id"].(int)) == key {
				send(it)
				return
			}
		}
		w.WriteHeader(http.StatusNotFound)
	case p == "/workspaces/acme/projects/p1/states/":
		send(f.states) // a plain array: list must take both forms
	case p == "/workspaces/acme/projects/p1/labels/" && r.Method == http.MethodGet:
		var out []any
		for _, l := range f.labels {
			out = append(out, l)
		}
		page(out)
	case p == "/workspaces/acme/projects/p1/labels/" && r.Method == http.MethodPost:
		var in label
		_ = json.Unmarshal(body, &in)
		in.ID = "l-new-" + in.Name
		f.labels = append(f.labels, in)
		f.posts = append(f.posts, "label "+in.Name)
		send(in)
	case p == "/workspaces/acme/projects/p1/work-items/" && r.Method == http.MethodGet:
		ids := []string{"i12", "i20", "i3", "i4", "i5"}
		size := f.pageSize
		if size == 0 {
			size = len(ids)
		}
		start := 0
		if c := r.URL.Query().Get("cursor"); c != "" {
			start, _ = strconv.Atoi(c)
		}
		end := min(start+size, len(ids))
		var out []any
		for _, id := range ids[start:end] {
			out = append(out, f.expanded(f.items[id]))
		}
		next := ""
		if end < len(ids) {
			next = strconv.Itoa(end)
		}
		send(map[string]any{"results": out, "next_cursor": next, "next_page_results": next != ""})
	case p == "/workspaces/acme/projects/p1/work-items/" && r.Method == http.MethodPost:
		var in map[string]any
		_ = json.Unmarshal(body, &in)
		f.posts = append(f.posts, "item "+in["name"].(string)+" "+in["priority"].(string))
		it := map[string]any{"id": "i77", "sequence_id": 77, "name": in["name"], "project": "p1", "state": "s-back", "labels": []string{}}
		f.items["i77"] = it
		w.WriteHeader(http.StatusCreated)
		send(it)
	case len(seg) == 6 && seg[4] == "work-items":
		it, ok := f.items[seg[5]]
		if !ok {
			w.WriteHeader(http.StatusNotFound)
			return
		}
		switch r.Method {
		case http.MethodGet:
			if strings.Contains(r.URL.Query().Get("expand"), "labels") {
				send(f.expanded(it))
			} else {
				send(it)
			}
		case http.MethodPatch:
			f.patches = append(f.patches, seg[5]+": "+string(body))
			var in map[string]any
			_ = json.Unmarshal(body, &in)
			if ls, ok := in["labels"].([]any); ok {
				var ids []string
				for _, l := range ls {
					ids = append(ids, l.(string))
				}
				it["labels"] = ids
			}
			send(it)
		}
	case len(seg) == 7 && seg[6] == "comments":
		var in struct {
			CommentHTML string `json:"comment_html"`
		}
		_ = json.Unmarshal(body, &in)
		f.comments = append(f.comments, seg[5]+": "+in.CommentHTML)
		w.WriteHeader(http.StatusCreated)
		send(map[string]string{"id": "c1"})
	case len(seg) == 7 && seg[6] == "relations" && r.Method == http.MethodGet:
		rs := f.relations[seg[5]]
		send(map[string]any{"blocking": nonNil(rs["blocking"]), "blocked_by": nonNil(rs["blocked_by"]), "relates_to": []any{}})
	case len(seg) == 7 && seg[6] == "relations" && r.Method == http.MethodPost:
		f.posts = append(f.posts, "relation "+seg[5]+" "+string(body))
		w.WriteHeader(http.StatusCreated)
		send([]any{})
	default:
		f.t.Errorf("unexpected %s %s", r.Method, r.URL)
		w.WriteHeader(http.StatusNotFound)
	}
}

func nonNil(rs []relRef) []relRef {
	if rs == nil {
		return []relRef{}
	}
	return rs
}

type setup struct {
	fake *fakePlane
	srv  *httptest.Server
	cfg  Config
	c    *Client
}

func newSetup(t *testing.T) *setup {
	t.Helper()
	f := newFakePlane(t)
	srv := httptest.NewServer(f)
	t.Cleanup(srv.Close)
	s := &setup{fake: f, srv: srv}
	s.cfg, _, _ = FromIntegration(SecretsToken("key", "hook-secret"), map[string]string{
		"base_url": srv.URL + "/", "workspace": "acme", "status_in_review": "In Review",
	}, true)
	s.c = New(func(context.Context) (Config, bool, error) { return s.cfg, true, nil })
	s.c.limit = rate.NewLimiter(rate.Inf, 1)
	s.c.sleep = func(context.Context, time.Duration) error { return nil }
	return s
}

func TestFromIntegration(t *testing.T) {
	c, ok, err := FromIntegration(SecretsToken("k", ""), map[string]string{"workspace": "acme", "comment_pr": "false",
		"base_url": "https://plane.acme.dev/api/v1/"}, true)
	if err != nil || !ok {
		t.Fatalf("ok=%v err=%v", ok, err)
	}
	if c.BaseURL != "https://plane.acme.dev" || c.Label != "agnts" || c.Comments["pr"] || !c.Comments["plan"] {
		t.Fatalf("config: %+v", c)
	}
	if c, ok, _ := FromIntegration(SecretsToken("k", ""), map[string]string{}, true); ok || c.BaseURL != DefaultBaseURL {
		t.Fatalf("no workspace must not be connected: %+v", c)
	}
}

func TestTextFromHTML(t *testing.T) {
	for _, tc := range []struct{ in, want string }{
		{"", ""},
		{`<p class="editor-paragraph-block">Round <strong>half</strong> up.</p><p></p><p>Then ship.</p>`, "Round half up.\n\nThen ship."},
		{`<ul><li><p>one</p></li><li><p>two</p></li></ul><p>after</p>`, "- one\n- two\n\nafter"},
		{`<p>see <a href="https://x.dev">docs</a> and <a href="https://y.dev">https://y.dev</a></p>`, "see docs (https://x.dev) and https://y.dev"},
		{`<pre><code>if x {
  y()
}</code></pre>`, "```\nif x {\n  y()\n}\n```"},
		{`<p>a<br>b &amp; c</p>`, "a\nb & c"},
	} {
		if got := textFromHTML(tc.in); got != tc.want {
			t.Errorf("textFromHTML(%q)\n got %q\nwant %q", tc.in, got, tc.want)
		}
	}
	got := htmlFromText("agnts opened a pull request: https://github.com/a/b/pull/7.\n\n<b>x</b>")
	want := `<p>agnts opened a pull request: <a href="https://github.com/a/b/pull/7" target="_blank" rel="noopener noreferrer">https://github.com/a/b/pull/7</a>.</p><p>&lt;b&gt;x&lt;/b&gt;</p>`
	if got != want {
		t.Fatalf("htmlFromText\n got %s\nwant %s", got, want)
	}
}

type fakeIngester struct {
	in []orchestrator.Incoming
}

func (f *fakeIngester) Ingest(_ context.Context, in orchestrator.Incoming, _ domain.Origin) (bool, error) {
	f.in = append(f.in, in)
	return true, nil
}

type memDedup map[string]bool

func (m memDedup) SeenDelivery(_ context.Context, provider, id string) (bool, error) {
	k := provider + "/" + id
	seen := m[k]
	m[k] = true
	return seen, nil
}

func sign(secret string, body []byte) string {
	mac := hmac.New(sha256.New, []byte(secret))
	mac.Write(body)
	return hex.EncodeToString(mac.Sum(nil))
}

func TestWebhook(t *testing.T) {
	s := newSetup(t)
	ing := &fakeIngester{}
	dedup := memDedup{}
	h := WebhookHandler(func(context.Context) (Config, bool, error) { return s.cfg, true, nil }, s.c, ing, dedup,
		slog.New(slog.NewTextHandler(io.Discard, nil)))
	deliver := func(delivery, sig string, body string) int {
		req := httptest.NewRequest(http.MethodPost, "/webhooks/plane", bytes.NewBufferString(body))
		if sig == "" {
			sig = sign("hook-secret", []byte(body))
		}
		req.Header.Set("X-Plane-Signature", sig)
		req.Header.Set("X-Plane-Delivery", delivery)
		rec := httptest.NewRecorder()
		h.ServeHTTP(rec, req)
		return rec.Code
	}
	v1 := `{"event": "issue", "action": "update", "webhook_id": "w", "workspace_id": "ws", "workspace_slug": "acme", "data": {"id": "i12", "project": "p1", "labels": [{"id": "l-code"}]}, "activity": {}}`
	if code := deliver("d0", "deadbeef", v1); code != http.StatusUnauthorized {
		t.Fatalf("bad signature: %d", code)
	}
	if code := deliver("d1", "", v1); code != http.StatusNoContent {
		t.Fatalf("v1 delivery: %d", code)
	}
	if len(ing.in) != 1 {
		t.Fatalf("ingested: %+v", ing.in)
	}
	in := ing.in[0]
	if in.Source != domain.SourcePlane || in.Key != "WEB-12" || in.Project != "WEB" || in.Title != "Fix refund rounding" ||
		in.Priority != "high" || in.Kind != domain.KindCode {
		t.Fatalf("incoming: %+v", in)
	}
	if in.Description != "Round half up.\n\n- see docs (https://x.dev/a)\n\n```\nx := 1\n```" {
		t.Fatalf("description: %q", in.Description)
	}
	if !in.LinksKnown || strings.Join(in.DependsOn, ",") != "WEB-3" || strings.Join(in.Dependents, ",") != "WEB-20" {
		t.Fatalf("links: %+v", in)
	}

	// The same delivery again is ignored.
	if code := deliver("d1", "", v1); code != http.StatusNoContent || len(ing.in) != 1 {
		t.Fatalf("duplicate delivery: %d %d", code, len(ing.in))
	}
	// v2, a work item without agnts's labels, a closed one, a comment and a delete.
	for i, body := range []string{
		`{"version": "v2", "event": "workitem.created", "delivery_id": "x", "data": {"id": "i3", "project_id": "p1"}}`,
		`{"event": "issue", "action": "update", "data": {"id": "i4", "project": "p1"}}`,
		`{"event": "issue", "action": "update", "data": {"id": "i5", "project": "p1"}}`,
		`{"event": "issue_comment", "action": "create", "data": {"id": "c9", "issue": "i12", "project": "p1"}}`,
		`{"event": "issue", "action": "delete", "data": {"id": "i12"}}`,
		`{"event": "issue", "action": "update", "data": {"id": "gone", "project": "p1"}}`,
	} {
		if code := deliver("e"+strconv.Itoa(i), "", body); code != http.StatusNoContent {
			t.Fatalf("delivery %d: %d", i, code)
		}
	}
	if len(ing.in) != 2 || ing.in[1].Key != "WEB-3" || ing.in[1].Kind != "" || ing.in[1].Priority != "" {
		t.Fatalf("after the other deliveries: %+v", ing.in)
	}

	// Without a secret agnts refuses deliveries.
	s.cfg.WebhookSecret = ""
	if code := deliver("f", "", v1); code != http.StatusServiceUnavailable {
		t.Fatalf("no secret: %d", code)
	}
}

func TestSearch(t *testing.T) {
	s := newSetup(t)
	s.fake.pageSize = 2
	got, err := s.c.Search(context.Background(), []string{"web"})
	if err != nil {
		t.Fatal(err)
	}
	var keys []string
	for _, in := range got {
		keys = append(keys, in.Key)
	}
	// i4 has no agnts label and i5 is done.
	if strings.Join(keys, ",") != "WEB-12,WEB-20,WEB-3" {
		t.Fatalf("search: %v", keys)
	}
	if !got[0].LinksKnown || len(got[0].DependsOn) != 1 || !got[1].LinksKnown || len(got[1].DependsOn) != 0 {
		t.Fatalf("links: %+v", got)
	}
	if _, err := s.c.Search(context.Background(), []string{"NOPE"}); err == nil || !strings.Contains(err.Error(), "no Plane project NOPE") {
		t.Fatalf("unknown project: %v", err)
	}
}

func TestWriteBack(t *testing.T) {
	s := newSetup(t)
	ctx := context.Background()

	// Comments are HTML, on the work item behind the key; a kind turned off posts nothing.
	if ok, err := s.c.Comment(ctx, "WEB-12", orchestrator.CommentPR, "PR: https://github.com/a/b/pull/7"); !ok || err != nil {
		t.Fatalf("comment: %v %v", ok, err)
	}
	s.cfg.Comments["plan"] = false
	if ok, err := s.c.Comment(ctx, "WEB-12", orchestrator.CommentPlan, "the plan"); ok || err != nil {
		t.Fatalf("disabled comment: %v %v", ok, err)
	}
	if len(s.fake.comments) != 1 || !strings.HasPrefix(s.fake.comments[0], `i12: <p>PR: <a href="https://github.com/a/b/pull/7"`) {
		t.Fatalf("comments: %v", s.fake.comments)
	}

	// States: the named one, else the first of the milestone's group; in review
	// moves only to a named state.
	for _, m := range []orchestrator.TrackerStatus{orchestrator.TrackerStarted, orchestrator.TrackerInReview, orchestrator.TrackerMerged} {
		if err := s.c.MoveTo(ctx, "WEB-12", m); err != nil {
			t.Fatalf("move %s: %v", m, err)
		}
	}
	s.cfg.Statuses["in_review"] = ""
	if err := s.c.MoveTo(ctx, "WEB-12", orchestrator.TrackerInReview); err != nil {
		t.Fatal(err)
	}
	s.cfg.Statuses["rejected"] = "Won't do"
	if err := s.c.MoveTo(ctx, "WEB-12", orchestrator.TrackerRejected); err == nil || !strings.Contains(err.Error(), `no state "Won't do"`) {
		t.Fatalf("unknown state: %v", err)
	}
	want := `i12: {"state":"s-prog"}|i12: {"state":"s-rev"}|i12: {"state":"s-done"}`
	if got := strings.Join(s.fake.patches, "|"); got != want {
		t.Fatalf("patches:\n got %s\nwant %s", got, want)
	}

	// A follow-up: created without labels, labelled (the label is created), linked.
	s.fake.patches = nil
	key, err := s.c.CreateIssue(ctx, orchestrator.NewIssue{Project: "WEB", Title: "Add refund_cents", Description: "Follow-up of WEB-12", Priority: "high"})
	if err != nil || key != "WEB-77" {
		t.Fatalf("create: %q %v", key, err)
	}
	if err := s.c.LabelIssue(ctx, key, domain.KindPlan); err != nil {
		t.Fatal(err)
	}
	if err := s.c.LabelIssue(ctx, key, domain.KindPlan); err != nil { // already there: no change
		t.Fatal(err)
	}
	if err := s.c.LinkIssues(ctx, key, "WEB-12"); err != nil {
		t.Fatal(err)
	}
	wantPosts := `item Add refund_cents high|label agnts-plan|relation i77 {"issues":["i12"],"relation_type":"relates_to"}`
	if got := strings.Join(s.fake.posts, "|"); got != wantPosts {
		t.Fatalf("posts:\n got %s\nwant %s", got, wantPosts)
	}
	if got := strings.Join(s.fake.patches, "|"); got != `i77: {"labels":["l-new-agnts-plan"]}` {
		t.Fatalf("label patches: %s", got)
	}
}

func TestRateLimitIsWaitedOut(t *testing.T) {
	s := newSetup(t)
	var waited time.Duration
	s.c.sleep = func(_ context.Context, d time.Duration) error { waited = d; return nil }
	s.fake.tooMany = 1
	name, err := s.c.Me(context.Background())
	if err != nil || name != "Rustam A" || waited != 2*time.Second {
		t.Fatalf("me: %q %v waited %s", name, err, waited)
	}
	s.fake.tooMany = 2
	if _, err := s.c.Me(context.Background()); err == nil || !strings.Contains(err.Error(), "429") {
		t.Fatalf("second 429 must fail: %v", err)
	}
	if d := retryAfter(http.Header{"X-Ratelimit-Reset": {strconv.FormatInt(time.Unix(1000, 0).Unix()+30, 10)}}, time.Unix(1000, 0)); d != 30*time.Second {
		t.Fatalf("reset header: %s", d)
	}
}

func TestPickState(t *testing.T) {
	states := newFakePlane(t).states
	if _, ok, err := pickState(nil, "", orchestrator.TrackerStarted); ok || err != nil {
		t.Fatalf("no states: %v %v", ok, err)
	}
	if st, ok, _ := pickState(states, "in review", orchestrator.TrackerInReview); !ok || st.ID != "s-rev" {
		t.Fatalf("by name, any case: %+v", st)
	}
	if st, ok, _ := pickState(states, "", orchestrator.TrackerRejected); !ok || st.ID != "s-cancel" {
		t.Fatalf("by group: %+v", st)
	}
}
