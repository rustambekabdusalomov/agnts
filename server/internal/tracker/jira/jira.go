// Package jira is the Jira Cloud adapter: REST v3 client, webhook receiver
// and the JQL reconcile that catches missed webhook deliveries.
package jira

import (
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"strconv"
	"strings"
	"time"

	"hiro/internal/domain"
	"hiro/internal/orchestrator"
)

// Config is the Jira connection, stored encrypted in the integrations table.
type Config struct {
	Site     string `json:"site"` // https://your-team.atlassian.net
	Email    string `json:"email"`
	APIToken string `json:"api_token"`
	// Label marks tickets hiro picks up and lets hiro pick their kind;
	// Label-<kind> (hiro-plan, hiro-bug, ...) also picks them up, with that kind.
	Label         string            `json:"label"`
	WebhookSecret string            `json:"webhook_secret"` // HMAC key for deliveries
	Statuses      map[string]string `json:"statuses"`       // hiro milestone -> Jira status name
	// Comments says which kinds of comment hiro posts (questions, plan, pr,
	// summary, status). A missing kind means on.
	Comments map[string]bool `json:"comments"`
}

// FromIntegration builds the config from the stored integration: secrets
// in the encrypted token (JSON), the rest in settings.
func FromIntegration(token string, settings map[string]string, connected bool) (Config, bool, error) {
	var sec struct {
		APIToken      string `json:"api_token"`
		WebhookSecret string `json:"webhook_secret"`
	}
	if token != "" {
		if err := json.Unmarshal([]byte(token), &sec); err != nil {
			return Config{}, false, fmt.Errorf("jira secrets: %w", err)
		}
	}
	c := Config{
		Site: settings["site"], Email: settings["email"], Label: settings["label"],
		APIToken: sec.APIToken, WebhookSecret: sec.WebhookSecret,
		Statuses: map[string]string{
			"started": settings["status_started"], "in_review": settings["status_in_review"], "rejected": settings["status_rejected"],
			"merged": settings["status_merged"],
		},
		Comments: map[string]bool{},
	}
	for _, k := range []string{"questions", "plan", "pr", "summary", "status"} {
		c.Comments[k] = settings["comment_"+k] != "false"
	}
	if c.Label == "" {
		c.Label = "hiro"
	}
	return c, connected && c.Site != "" && c.APIToken != "", nil
}

// SecretsToken packs the Jira secrets for the encrypted token column.
func SecretsToken(apiToken, webhookSecret string) string {
	b, _ := json.Marshal(map[string]string{"api_token": apiToken, "webhook_secret": webhookSecret}) //nolint:gosec // G117: encrypted before storage
	return string(b)
}

// SettingKeys are the settings the Jira integration accepts.
var SettingKeys = []string{"site", "email", "label", "status_started", "status_in_review", "status_rejected", "status_merged",
	"comment_questions", "comment_plan", "comment_pr", "comment_summary", "comment_status"}

// Myself checks the credentials and returns the account's display name.
func (c *Client) Myself(ctx context.Context) (string, error) {
	var me struct {
		DisplayName  string `json:"displayName"`
		EmailAddress string `json:"emailAddress"`
	}
	if err := c.call(ctx, http.MethodGet, "/rest/api/3/myself", nil, &me); err != nil {
		return "", err
	}
	if me.DisplayName != "" {
		return me.DisplayName, nil
	}
	return me.EmailAddress, nil
}

// ConfigSource loads the current config, so changes apply without a restart.
// It returns ok=false when Jira is not connected.
type ConfigSource func(ctx context.Context) (cfg Config, ok bool, err error)

// Client talks to Jira Cloud REST v3.
type Client struct {
	cfg ConfigSource
	hc  *http.Client
}

var _ orchestrator.Tracker = (*Client)(nil)

// New returns a Jira client.
func New(cfg ConfigSource) *Client {
	return &Client{cfg: cfg, hc: &http.Client{Timeout: 30 * time.Second}}
}

// ErrNotConnected is returned when Jira has not been configured.
var ErrNotConnected = errors.New("jira is not connected")

func (c *Client) call(ctx context.Context, method, path string, in, out any) error {
	cfg, ok, err := c.cfg(ctx)
	if err != nil {
		return err
	}
	if !ok {
		return ErrNotConnected
	}
	var body io.Reader
	if in != nil {
		b, err := json.Marshal(in)
		if err != nil {
			return err
		}
		body = bytes.NewReader(b)
	}
	req, err := http.NewRequestWithContext(ctx, method, strings.TrimRight(cfg.Site, "/")+path, body)
	if err != nil {
		return err
	}
	req.SetBasicAuth(cfg.Email, cfg.APIToken)
	req.Header.Set("Accept", "application/json")
	if in != nil {
		req.Header.Set("Content-Type", "application/json")
	}
	resp, err := c.hc.Do(req)
	if err != nil {
		return fmt.Errorf("jira %s %s: %w", method, path, err)
	}
	defer func() { _ = resp.Body.Close() }()
	if resp.StatusCode >= 300 {
		b, _ := io.ReadAll(io.LimitReader(resp.Body, 4096))
		return fmt.Errorf("jira %s %s: %s: %s", method, path, resp.Status, strings.TrimSpace(string(b)))
	}
	if out == nil {
		return nil
	}
	return json.NewDecoder(resp.Body).Decode(out)
}

// Comment posts a plain-text comment (one ADF paragraph per line) unless
// that kind of comment is turned off.
func (c *Client) Comment(ctx context.Context, key string, kind orchestrator.CommentKind, text string) (bool, error) {
	cfg, ok, err := c.cfg(ctx)
	if err != nil || !ok {
		return false, err
	}
	if on, set := cfg.Comments[string(kind)]; set && !on {
		return false, nil
	}
	err = c.call(ctx, http.MethodPost, "/rest/api/3/issue/"+url.PathEscape(key)+"/comment",
		map[string]any{"body": adfFromText(text)}, nil)
	return err == nil, err
}

// MoveTo applies the transition leading to the status configured for s.
// It does nothing when no status is configured for that milestone.
func (c *Client) MoveTo(ctx context.Context, key string, s orchestrator.TrackerStatus) error {
	cfg, ok, err := c.cfg(ctx)
	if err != nil || !ok {
		return err
	}
	want := strings.TrimSpace(cfg.Statuses[string(s)])
	if want == "" {
		return nil
	}
	var tr struct {
		Transitions []struct {
			ID   string `json:"id"`
			Name string `json:"name"`
			To   struct {
				Name string `json:"name"`
			} `json:"to"`
		} `json:"transitions"`
	}
	path := "/rest/api/3/issue/" + url.PathEscape(key) + "/transitions"
	if err := c.call(ctx, http.MethodGet, path, nil, &tr); err != nil {
		return err
	}
	for _, t := range tr.Transitions {
		if strings.EqualFold(t.To.Name, want) || strings.EqualFold(t.Name, want) {
			return c.call(ctx, http.MethodPost, path, map[string]any{"transition": map[string]string{"id": t.ID}}, nil)
		}
	}
	return fmt.Errorf("no transition to %q from the issue's current status", want)
}

// Search returns open issues carrying the hiro label (the reconcile query).
func (c *Client) Search(ctx context.Context) ([]orchestrator.Incoming, error) {
	cfg, ok, err := c.cfg(ctx)
	if err != nil || !ok {
		return nil, err
	}
	quoted := make([]string, 0, len(domain.Kinds)+1)
	for _, l := range labels(cfg.Label) {
		quoted = append(quoted, strconv.Quote(l))
	}
	jql := fmt.Sprintf(`labels in (%s) AND statusCategory != Done ORDER BY created ASC`, strings.Join(quoted, ", "))
	var out []orchestrator.Incoming
	token := ""
	for page := 0; page < 20; page++ {
		req := map[string]any{
			"jql": jql, "maxResults": 50,
			"fields": []string{"summary", "description", "priority", "project", "labels"},
		}
		if token != "" {
			req["nextPageToken"] = token
		}
		var resp struct {
			Issues        []issue `json:"issues"`
			NextPageToken string  `json:"nextPageToken"`
			IsLast        bool    `json:"isLast"`
		}
		if err := c.call(ctx, http.MethodPost, "/rest/api/3/search/jql", req, &resp); err != nil {
			return nil, err
		}
		for _, is := range resp.Issues {
			out = append(out, is.incoming(cfg.Label))
		}
		if resp.IsLast || resp.NextPageToken == "" {
			break
		}
		token = resp.NextPageToken
	}
	return out, nil
}

type issue struct {
	Key    string `json:"key"`
	Fields struct {
		Summary     string          `json:"summary"`
		Description json.RawMessage `json:"description"` // ADF object (v3) or string (webhooks)
		Labels      []string        `json:"labels"`
		Priority    *struct {
			Name string `json:"name"`
		} `json:"priority"`
		Project struct {
			Key string `json:"key"`
		} `json:"project"`
	} `json:"fields"`
}

func (is issue) incoming(label string) orchestrator.Incoming {
	in := orchestrator.Incoming{
		Key: is.Key, Project: is.Fields.Project.Key, Title: is.Fields.Summary,
		Description: descriptionText(is.Fields.Description), Kind: is.kind(label),
	}
	if in.Project == "" {
		if i := strings.LastIndex(is.Key, "-"); i > 0 {
			in.Project = is.Key[:i]
		}
	}
	if is.Fields.Priority != nil {
		in.Priority = is.Fields.Priority.Name
	}
	return in
}

// labels are the labels that hand an issue to hiro: the base label and
// one per kind.
func labels(base string) []string {
	out := []string{base}
	for _, k := range domain.Kinds {
		out = append(out, base+"-"+string(k))
	}
	return out
}

// forHiro reports whether the issue carries any of hiro's labels.
func (is issue) forHiro(base string) bool {
	for _, want := range labels(base) {
		for _, l := range is.Fields.Labels {
			if strings.EqualFold(l, want) {
				return true
			}
		}
	}
	return false
}

// kind is the kind its labels name (the first in domain.Kinds order when
// there are several), or "" for hiro to pick.
func (is issue) kind(base string) domain.TicketKind {
	for _, k := range domain.Kinds {
		for _, l := range is.Fields.Labels {
			if strings.EqualFold(l, base+"-"+string(k)) {
				return k
			}
		}
	}
	return ""
}

// descriptionText accepts a plain string or an Atlassian Document Format tree.
func descriptionText(raw json.RawMessage) string {
	if len(raw) == 0 || string(raw) == "null" {
		return ""
	}
	var s string
	if json.Unmarshal(raw, &s) == nil {
		return strings.TrimSpace(s)
	}
	var node adfNode
	if json.Unmarshal(raw, &node) != nil {
		return ""
	}
	var b strings.Builder
	node.text(&b)
	return strings.TrimSpace(b.String())
}

type adfNode struct {
	Type    string    `json:"type"`
	Text    string    `json:"text"`
	Content []adfNode `json:"content"`
}

func (n adfNode) text(b *strings.Builder) {
	switch n.Type {
	case "text":
		b.WriteString(n.Text)
	case "hardBreak":
		b.WriteString("\n")
	case "listItem":
		b.WriteString("- ")
	case "codeBlock":
		b.WriteString("```\n")
	}
	for _, c := range n.Content {
		c.text(b)
	}
	switch n.Type {
	case "paragraph", "heading", "blockquote":
		b.WriteString("\n\n")
	case "codeBlock":
		b.WriteString("\n```\n\n")
	}
}

func adfFromText(text string) map[string]any {
	var paras []map[string]any
	for _, line := range strings.Split(strings.TrimSpace(text), "\n") {
		if strings.TrimSpace(line) == "" {
			continue
		}
		paras = append(paras, map[string]any{
			"type": "paragraph", "content": []map[string]any{{"type": "text", "text": line}},
		})
	}
	return map[string]any{"type": "doc", "version": 1, "content": paras}
}
