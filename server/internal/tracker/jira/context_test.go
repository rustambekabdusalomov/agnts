package jira

import (
	"context"
	"io"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
)

// TicketContext reads the parent with its description, links, subtasks,
// people's comments (not agnts's), the description's links and images,
// and image attachments; other attachments are left out.
func TestTicketContext(t *testing.T) {
	var srv *httptest.Server
	srv = httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		switch r.URL.Path {
		case "/rest/api/3/issue/PAY-7":
			_, _ = io.WriteString(w, `{"fields":{
				"description":{"type":"doc","content":[{"type":"paragraph","content":[
					{"type":"text","text":"see the design","marks":[{"type":"link","attrs":{"href":"https://figma.com/x"}}]},
					{"type":"inlineCard","attrs":{"url":"https://acme.atlassian.net/browse/PAY-3"}}]},
					{"type":"mediaSingle","content":[{"type":"media","attrs":{"alt":"cart.png"}}]}]},
				"parent":{"key":"PAY-1","fields":{"summary":"Refunds","status":{"name":"In Progress"}}},
				"issuelinks":[{"type":{"inward":"is blocked by","outward":"blocks"},"inwardIssue":{"key":"PAY-2","fields":{"summary":"Ledger","status":{"name":"Done"}}}}],
				"subtasks":[{"key":"PAY-8","fields":{"summary":"UI","status":{"name":"To Do"}}}],
				"comment":{"comments":[
					{"author":{"accountId":"me","displayName":"agnts"},"body":"I have a question","created":"2026-10-01T10:00:00.000+0000"},
					{"author":{"accountId":"bob","displayName":"Bob"},"body":{"type":"doc","content":[{"type":"paragraph","content":[{"type":"text","text":"Round half up, not down."}]}]},"created":"2026-10-02T10:00:00.000+0000"}]},
				"attachment":[
					{"filename":"cart.png","mimeType":"image/png","size":4,"content":"`+srv.URL+`/rest/api/3/attachment/content/1"},
					{"filename":"spec.pdf","mimeType":"application/pdf","size":4,"content":"`+srv.URL+`/rest/api/3/attachment/content/2"},
					{"filename":"evil.png","mimeType":"image/png","size":4,"content":"https://evil.example/x.png"}]}}`)
		case "/rest/api/3/issue/PAY-1":
			_, _ = io.WriteString(w, `{"fields":{"description":"Refunds must be auditable."}}`)
		case "/rest/api/3/myself":
			_, _ = io.WriteString(w, `{"accountId":"me"}`)
		case "/rest/api/3/attachment/content/1":
			_, _ = io.WriteString(w, "\x89PNG")
		default:
			w.WriteHeader(http.StatusNotFound)
		}
	}))
	defer srv.Close()
	cfg, _, err := FromIntegration(`{"api_token":"tok"}`, map[string]string{"site": srv.URL, "email": "me@x.com"}, true)
	if err != nil {
		t.Fatal(err)
	}
	c, err := New(static(cfg)).TicketContext(context.Background(), "PAY-7")
	if err != nil {
		t.Fatal(err)
	}
	if c.Parent == nil || c.Parent.Key != "PAY-1" || c.Parent.Status != "In Progress" || c.Parent.Description != "Refunds must be auditable." {
		t.Fatalf("parent: %+v", c.Parent)
	}
	if len(c.Links) != 1 || c.Links[0].Relation != "is blocked by" || c.Links[0].Key != "PAY-2" || len(c.Subtasks) != 1 {
		t.Fatalf("links %+v subtasks %+v", c.Links, c.Subtasks)
	}
	if len(c.Comments) != 1 || c.Comments[0].Author != "Bob" || c.Comments[0].Body != "Round half up, not down." || c.Comments[0].At.Day() != 2 {
		t.Fatalf("comments: %+v", c.Comments)
	}
	refs := strings.Join(c.Refs, "\n")
	if !strings.Contains(refs, "see the design: https://figma.com/x") || !strings.Contains(refs, "https://acme.atlassian.net/browse/PAY-3") ||
		!strings.Contains(refs, "image cart.png") {
		t.Fatalf("refs: %q", c.Refs)
	}
	if len(c.Images) != 1 || c.Images[0].Name != "cart.png" || string(c.Images[0].Data) != "\x89PNG" {
		t.Fatalf("images: %+v", c.Images)
	}
}
