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

	"hiro/internal/domain"
	"hiro/internal/orchestrator"
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
  "labels":["backend","Hiro"],"priority":{"name":"High"},"project":{"key":"PAY"}}}}`

func TestWebhook(t *testing.T) {
	log := slog.New(slog.NewTextHandler(io.Discard, nil))
	ing := &fakeIngester{}
	h := WebhookHandler(static(Config{WebhookSecret: "s3cret", Label: "hiro"}), ing, fakeDedup{}, log)

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
	if in.Key != "PAY-42" || in.Project != "PAY" || in.Priority != "High" || !strings.Contains(in.Description, "half up") {
		t.Fatalf("incoming: %+v", in)
	}

	unlabelled := strings.Replace(payload, `"Hiro"`, `"other"`, 1)
	if c := post(unlabelled, sign("s3cret", []byte(unlabelled)), "d-2"); c != http.StatusNoContent || len(ing.got) != 1 {
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
			if _, ok := b["nextPageToken"]; !ok {
				_, _ = io.WriteString(w, `{"issues":[{"key":"PAY-1","fields":{"summary":"a","project":{"key":"PAY"}}}],"nextPageToken":"p2"}`)
				return
			}
			_, _ = io.WriteString(w, `{"issues":[{"key":"PAY-2","fields":{"summary":"b"}}],"isLast":true}`)
		default:
			w.WriteHeader(http.StatusNotFound)
		}
	}))
	defer srv.Close()

	c := New(static(Config{Site: srv.URL, Email: "me@x.com", APIToken: "tok", Label: "hiro",
		Statuses: map[string]string{"in_review": "in review"}}))
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
	if err != nil || len(issues) != 2 || issues[1].Project != "PAY" {
		t.Fatalf("search: %+v %v", issues, err)
	}
	if n := len(calls); n != 5 {
		t.Fatalf("calls: %v", calls)
	}
}
