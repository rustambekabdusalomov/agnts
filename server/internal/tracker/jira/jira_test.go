package jira

import (
	"context"
	"crypto/hmac"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"io"
	"log/slog"
	"net/http"
	"net/http/httptest"
	"strings"
	"sync"
	"testing"

	"agnts/internal/domain"
	"agnts/internal/orchestrator"
)

type fakeIngester struct {
	mu  sync.Mutex
	got []orchestrator.Incoming
}

func (f *fakeIngester) Ingest(_ context.Context, in orchestrator.Incoming, _ domain.Origin) (bool, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	f.got = append(f.got, in)
	return true, nil
}

type fakeDedup map[string]bool

func (d fakeDedup) SeenDelivery(_ context.Context, p, id string) (bool, error) {
	k := p + "/" + id
	seen := d[k]
	d[k] = true
	return seen, nil
}

func static(c Config) ConfigSource {
	return func(context.Context) (Config, bool, error) { return c, true, nil }
}

func sign(secret string, body []byte) string {
	m := hmac.New(sha256.New, []byte(secret))
	m.Write(body)
	return "sha256=" + hex.EncodeToString(m.Sum(nil))
}

const payload = `{"webhookEvent":"jira:issue_created","issue":{"key":"PAY-42","fields":{
  "summary":"Fix refund rounding","description":"Refunds round down.\nShould round half up.",
  "labels":["backend","Agnts"],"priority":{"name":"High"},"project":{"key":"PAY"}}}}`

func TestWebhook(t *testing.T) {
	log := slog.New(slog.NewTextHandler(io.Discard, nil))
	ing := &fakeIngester{}
	h := WebhookHandler(static(Config{WebhookSecret: "s3cret", Label: "agnts"}), ing, fakeDedup{}, log)

	post := func(body, sig, id string) int {
		req := httptest.NewRequest("POST", "/webhooks/jira", strings.NewReader(body))
		if sig != "" {
			req.Header.Set("X-Hub-Signature", sig)
		}
		if id != "" {
			req.Header.Set("X-Atlassian-Webhook-Identifier", id)
		}
		rec := httptest.NewRecorder()
		h.ServeHTTP(rec, req)
		return rec.Code
	}

	if c := post(payload, "", "1"); c != http.StatusUnauthorized {
		t.Fatalf("unsigned: %d", c)
	}
	if c := post(payload, sign("wrong", []byte(payload)), "1"); c != http.StatusUnauthorized {
		t.Fatalf("bad signature: %d", c)
	}
	if c := post(payload, sign("s3cret", []byte(payload)), "d-1"); c != http.StatusNoContent {
		t.Fatalf("valid: %d", c)
	}
	if c := post(payload, sign("s3cret", []byte(payload)), "d-1"); c != http.StatusNoContent {
		t.Fatalf("duplicate: %d", c)
	}
	if len(ing.got) != 1 {
		t.Fatalf("ingested %d times, want 1 (dedup)", len(ing.got))
	}
	in := ing.got[0]
	if in.Key != "PAY-42" || in.Project != "PAY" || in.Priority != "High" || !strings.Contains(in.Description, "half up") || in.Kind != "" {
		t.Fatalf("incoming: %+v", in)
	}

	// A kind label alone hands the issue to agnts with that kind.
	planned := strings.Replace(payload, `"Agnts"`, `"agnts-plan"`, 1)
	if c := post(planned, sign("s3cret", []byte(planned)), "d-3"); c != http.StatusNoContent || len(ing.got) != 2 {
		t.Fatalf("kind label: %d, %d", c, len(ing.got))
	}
	if k := ing.got[1].Kind; k != domain.KindPlan {
		t.Fatalf("kind from label: %q", k)
	}

	unlabelled := strings.Replace(payload, `"Agnts"`, `"other"`, 1)
	if c := post(unlabelled, sign("s3cret", []byte(unlabelled)), "d-2"); c != http.StatusNoContent || len(ing.got) != 2 {
		t.Fatalf("unlabelled issue ingested: %d, %d", c, len(ing.got))
	}

	notConnected := WebhookHandler(func(context.Context) (Config, bool, error) { return Config{}, false, nil }, ing, fakeDedup{}, log)
	rec := httptest.NewRecorder()
	notConnected.ServeHTTP(rec, httptest.NewRequest("POST", "/webhooks/jira", strings.NewReader(payload)))
	if rec.Code != http.StatusServiceUnavailable {
		t.Fatalf("not connected: %d", rec.Code)
	}
}

func TestADFDescription(t *testing.T) {
	adf := `{"type":"doc","version":1,"content":[
	  {"type":"paragraph","content":[{"type":"text","text":"First line"},{"type":"hardBreak"},{"type":"text","text":"second"}]},
	  {"type":"bulletList","content":[{"type":"listItem","content":[{"type":"paragraph","content":[{"type":"text","text":"item"}]}]}]},
	  {"type":"codeBlock","content":[{"type":"text","text":"x := 1"}]}]}`
	got := descriptionText(json.RawMessage(adf))
	for _, want := range []string{"First line\nsecond", "- item", "```\nx := 1\n```"} {
		if !strings.Contains(got, want) {
			t.Errorf("missing %q in %q", want, got)
		}
	}
	if descriptionText(json.RawMessage(`null`)) != "" || descriptionText(nil) != "" {
		t.Error("empty description")
	}
}

func TestClient(t *testing.T) {
	var mu sync.Mutex
	var calls []string
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		mu.Lock()
		calls = append(calls, r.Method+" "+r.URL.Path)
		mu.Unlock()
		if u, p, _ := r.BasicAuth(); u != "me@x.com" || p != "tok" {
			w.WriteHeader(http.StatusUnauthorized)
			return
		}
		switch r.Method + " " + r.URL.Path {
		case "POST /rest/api/3/issue/PAY-1/comment":
			var b map[string]any
			_ = json.NewDecoder(r.Body).Decode(&b)
			if b["body"].(map[string]any)["type"] != "doc" {
				w.WriteHeader(http.StatusBadRequest)
			}
			w.WriteHeader(http.StatusCreated)
		case "GET /rest/api/3/issue/PAY-1/transitions":
			_, _ = io.WriteString(w, `{"transitions":[{"id":"11","name":"Start","to":{"name":"In Progress"}},{"id":"21","name":"Review","to":{"name":"In Review"}}]}`)
		case "POST /rest/api/3/issue/PAY-1/transitions":
			var b struct{ Transition struct{ ID string } }
			_ = json.NewDecoder(r.Body).Decode(&b)
			if b.Transition.ID != "21" {
				w.WriteHeader(http.StatusBadRequest)
			}
			w.WriteHeader(http.StatusNoContent)
		case "POST /rest/api/3/search/jql":
			var b map[string]any
			_ = json.NewDecoder(r.Body).Decode(&b)
			if !strings.HasPrefix(b["jql"].(string), `labels in ("agnts", "agnts-code", "agnts-test", "agnts-plan", "agnts-analysis", "agnts-bug")`) {
				w.WriteHeader(http.StatusBadRequest)
				return
			}
			if _, ok := b["nextPageToken"]; !ok {
				_, _ = io.WriteString(w, `{"issues":[{"key":"PAY-1","fields":{"summary":"a","project":{"key":"PAY"}}}],"nextPageToken":"p2"}`)
				return
			}
			_, _ = io.WriteString(w, `{"issues":[{"key":"PAY-2","fields":{"summary":"b","labels":["agnts-bug"]}}],"isLast":true}`)
		default:
			w.WriteHeader(http.StatusNotFound)
		}
	}))
	defer srv.Close()

	c := New(static(Config{Site: srv.URL, Email: "me@x.com", APIToken: "tok", Label: "agnts",
		Statuses: map[string]string{"in_review": "in review"}, IssueType: "Task"}))
	ctx := context.Background()
	if posted, err := c.Comment(ctx, "PAY-1", orchestrator.CommentPR, "hello\n\nworld"); err != nil || !posted {
		t.Fatal(err)
	}
	if err := c.MoveTo(ctx, "PAY-1", orchestrator.TrackerInReview); err != nil {
		t.Fatal(err)
	}
	if err := c.MoveTo(ctx, "PAY-1", orchestrator.TrackerStarted); err != nil { // not configured: no call
		t.Fatal(err)
	}
	issues, err := c.Search(ctx)
	if err != nil || len(issues) != 2 || issues[1].Project != "PAY" || issues[0].Kind != "" || issues[1].Kind != domain.KindBug {
		t.Fatalf("search: %+v %v", issues, err)
	}
	if n := len(calls); n != 5 {
		t.Fatalf("calls: %v", calls)
	}
}

func TestCreateLabelAndLinkIssue(t *testing.T) {
	var mu sync.Mutex
	var calls []string
	var bodies []map[string]any
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		var b map[string]any
		_ = json.NewDecoder(r.Body).Decode(&b)
		mu.Lock()
		calls = append(calls, r.Method+" "+r.URL.Path)
		bodies = append(bodies, b)
		mu.Unlock()
		switch r.Method + " " + r.URL.Path {
		case "POST /rest/api/3/issue":
			if _, ok := b["fields"].(map[string]any)["priority"]; ok {
				w.WriteHeader(http.StatusBadRequest) // no priority on this create screen
				_, _ = io.WriteString(w, `{"errors":{"priority":"Field 'priority' cannot be set."}}`)
				return
			}
			w.WriteHeader(http.StatusCreated)
			_, _ = io.WriteString(w, `{"id":"10001","key":"PAY-77"}`)
		case "PUT /rest/api/3/issue/PAY-77", "POST /rest/api/3/issueLink":
			w.WriteHeader(http.StatusNoContent)
		default:
			w.WriteHeader(http.StatusNotFound)
		}
	}))
	defer srv.Close()

	cfg, _, err := FromIntegration(`{"api_token":"tok"}`, map[string]string{"site": srv.URL, "email": "me@x.com"}, true)
	if err != nil || cfg.IssueType != "Task" {
		t.Fatalf("config: %+v %v", cfg, err)
	}
	c := New(static(cfg))
	ctx := context.Background()
	key, err := c.CreateIssue(ctx, orchestrator.NewIssue{Project: "PAY", Title: "Add refund_cents", Description: "Do it.\n\nFollow-up of PAY-1", Priority: "high"})
	if err != nil || key != "PAY-77" {
		t.Fatalf("create: %q %v", key, err)
	}
	f := bodies[1]["fields"].(map[string]any)
	if f["project"].(map[string]any)["key"] != "PAY" || f["issuetype"].(map[string]any)["name"] != "Task" || f["summary"] != "Add refund_cents" ||
		f["description"].(map[string]any)["type"] != "doc" {
		t.Fatalf("create fields: %+v", f)
	}
	if err := c.LabelIssue(ctx, key, domain.KindTest); err != nil {
		t.Fatal(err)
	}
	if l := bodies[2]["update"].(map[string]any)["labels"].([]any)[0].(map[string]any)["add"]; l != "agnts-test" {
		t.Fatalf("label: %v", l)
	}
	if err := c.LinkIssues(ctx, key, "PAY-1"); err != nil {
		t.Fatal(err)
	}
	want := "POST /rest/api/3/issue|POST /rest/api/3/issue|PUT /rest/api/3/issue/PAY-77|POST /rest/api/3/issueLink"
	if got := strings.Join(calls, "|"); got != want {
		t.Fatalf("calls: %s", got)
	}
}
