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
	"slices"
	"strconv"
	"strings"
	"sync"
	"time"

	"agnts/internal/domain"
	"agnts/internal/netroute"
	"agnts/internal/orchestrator"
)

// Config is the Jira connection, stored encrypted in the integrations table.
type Config struct {
	Site     string `json:"site"` // https://your-team.atlassian.net
	Email    string `json:"email"`
	APIToken string `json:"api_token"`
	// Label marks tickets agnts picks up and lets agnts pick their kind;
	// Label-<kind> (agnts-plan, agnts-bug, ...) also picks them up, with that kind.
	Label         string            `json:"label"`
	WebhookSecret string            `json:"webhook_secret"` // HMAC key for deliveries
	Statuses      map[string]string `json:"statuses"`       // agnts milestone -> Jira status name
	// Comments says which kinds of comment agnts posts (questions, plan, pr,
	// summary, status). A missing kind means on.
	Comments map[string]bool `json:"comments"`
	// IssueType is the type of the issues agnts files for follow-ups.
	IssueType string `json:"issue_type"`
	// AssignedOnly takes only issues assigned to the connected account
	// (with agnts's label); on unless the setting says "false".
	AssignedOnly bool `json:"assigned_only"`
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
		Comments:     map[string]bool{},
		IssueType:    strings.TrimSpace(settings["issue_type"]),
		AssignedOnly: settings["assigned_only"] != "false",
	}
	for _, k := range []string{"questions", "plan", "pr", "summary", "status"} {
		c.Comments[k] = settings["comment_"+k] != "false"
	}
	if c.Label == "" {
		c.Label = "agnts"
	}
	if c.IssueType == "" {
		c.IssueType = "Task"
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
	"comment_questions", "comment_plan", "comment_pr", "comment_summary", "comment_status", "issue_type",
	"assigned_only"}

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

// AccountID returns the connected account's Jira account id, asked once
// per site and email.
func (c *Client) AccountID(ctx context.Context) (string, error) {
	cfg, ok, err := c.cfg(ctx)
	if err != nil {
		return "", err
	}
	if !ok {
		return "", ErrNotConnected
	}
	key := cfg.Site + "\x00" + cfg.Email
	if v, ok := c.accounts.Load(key); ok {
		return v.(string), nil
	}
	var me struct {
		AccountID string `json:"accountId"`
	}
	if err := c.call(ctx, http.MethodGet, "/rest/api/3/myself", nil, &me); err != nil {
		return "", err
	}
	if me.AccountID == "" {
		return "", errors.New("jira did not say which account the token belongs to")
	}
	c.accounts.Store(key, me.AccountID)
	return me.AccountID, nil
}

// ConfigSource loads the current config, so changes apply without a restart.
// It returns ok=false when Jira is not connected.
type ConfigSource func(ctx context.Context) (cfg Config, ok bool, err error)

// Client talks to Jira Cloud REST v3.
type Client struct {
	cfg      ConfigSource
	hc       *http.Client
	accounts sync.Map // site and email -> account id
}

var (
	_ orchestrator.Tracker      = (*Client)(nil)
	_ orchestrator.IssueCreator = (*Client)(nil)
)

// New returns a Jira client.
func New(cfg ConfigSource) *Client {
	return &Client{cfg: cfg, hc: netroute.Client(30 * time.Second)}
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

// CreateIssue files an issue of the configured type, without agnts's
// labels. Projects whose create screen has no priority field reject one,
// so a refused create is tried once more without it.
func (c *Client) CreateIssue(ctx context.Context, in orchestrator.NewIssue) (string, error) {
	cfg, ok, err := c.cfg(ctx)
	if err != nil {
		return "", err
	}
	if !ok {
		return "", ErrNotConnected
	}
	fields := map[string]any{
		"project":     map[string]string{"key": in.Project},
		"issuetype":   map[string]string{"name": cfg.IssueType},
		"summary":     in.Title,
		"description": adfFromText(in.Description),
	}
	if p := jiraPriority(in.Priority); p != "" {
		fields["priority"] = map[string]string{"name": p}
	}
	var out struct {
		Key string `json:"key"`
	}
	err = c.call(ctx, http.MethodPost, "/rest/api/3/issue", map[string]any{"fields": fields}, &out)
	if _, set := fields["priority"]; err != nil && set && strings.Contains(err.Error(), "400") {
		delete(fields, "priority")
		err = c.call(ctx, http.MethodPost, "/rest/api/3/issue", map[string]any{"fields": fields}, &out)
	}
	if err != nil {
		return "", err
	}
	if out.Key == "" {
		return "", errors.New("jira created the issue but returned no key")
	}
	return out.Key, nil
}

// jiraPriority is the default Jira priority name for an agnts priority.
func jiraPriority(p string) string {
	switch p {
	case "low":
		return "Low"
	case "medium":
		return "Medium"
	case "high":
		return "High"
	}
	return ""
}

// LabelIssue adds the kind label (agnts-code, agnts-plan, ...), which hands
// the issue to agnts with that kind.
func (c *Client) LabelIssue(ctx context.Context, key string, kind domain.TicketKind) error {
	cfg, ok, err := c.cfg(ctx)
	if err != nil {
		return err
	}
	if !ok {
		return ErrNotConnected
	}
	label := cfg.Label + "-" + string(kind)
	return c.call(ctx, http.MethodPut, "/rest/api/3/issue/"+url.PathEscape(key),
		map[string]any{"update": map[string]any{"labels": []map[string]string{{"add": label}}}}, nil)
}

// LinkIssues links key to other with Jira's standard "Relates" link.
func (c *Client) LinkIssues(ctx context.Context, key, other string) error {
	return c.call(ctx, http.MethodPost, "/rest/api/3/issueLink", map[string]any{
		"type":         map[string]string{"name": "Relates"},
		"inwardIssue":  map[string]string{"key": key},
		"outwardIssue": map[string]string{"key": other},
	}, nil)
}

// Search returns open issues carrying the agnts label (the reconcile query).
func (c *Client) Search(ctx context.Context) ([]orchestrator.Incoming, error) {
	cfg, ok, err := c.cfg(ctx)
	if err != nil || !ok {
		return nil, err
	}
	quoted := make([]string, 0, len(domain.Kinds)+1)
	for _, l := range labels(cfg.Label) {
		quoted = append(quoted, strconv.Quote(l))
	}
	mine := ""
	if cfg.AssignedOnly {
		mine = " AND assignee = currentUser()"
	}
	jql := fmt.Sprintf(`labels in (%s) AND statusCategory != Done%s ORDER BY created ASC`, strings.Join(quoted, ", "), mine)
	var out []orchestrator.Incoming
	token := ""
	for page := 0; page < 20; page++ {
		req := map[string]any{
			"jql": jql, "maxResults": 50,
			"fields": []string{"summary", "description", "priority", "project", "labels", "issuelinks"},
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
		Assignee *struct {
			AccountID string `json:"accountId"`
		} `json:"assignee"`
		// IssueLinks is nil when the payload left the field out.
		IssueLinks *[]issueLink `json:"issuelinks"`
		Status     *struct {
			StatusCategory struct {
				Key string `json:"key"` // new, indeterminate, done
			} `json:"statusCategory"`
		} `json:"status"`
		Resolution *struct {
			Name string `json:"name"`
		} `json:"resolution"`
		ResolutionDate string `json:"resolutiondate"`
	} `json:"fields"`
}

// resolution is how the issue ended, as far as the payload says; ok is
// false when it has no status (a payload that left it out).
func (is issue) resolution() (domain.TrackerResolution, bool) {
	if is.Fields.Status == nil {
		return domain.TrackerResolution{}, false
	}
	r := domain.TrackerResolution{Closed: is.Fields.Status.StatusCategory.Key == "done"}
	if is.Fields.Resolution != nil {
		r.Resolution = is.Fields.Resolution.Name
	}
	if at, ok := jiraTime(is.Fields.ResolutionDate); ok && r.Closed {
		r.At = &at
	}
	return r, true
}

// jiraTime reads Jira's timestamps (2026-11-04T10:00:00.000+0000).
func jiraTime(s string) (time.Time, bool) {
	for _, layout := range []string{"2006-01-02T15:04:05.000-0700", time.RFC3339Nano, time.RFC3339} {
		if t, err := time.Parse(layout, s); err == nil {
			return t, true
		}
	}
	return time.Time{}, false
}

// issueLink is one link on an issue. Jira fills inwardIssue or
// outwardIssue: the link reads "this issue <inward> inwardIssue" or "this
// issue <outward> outwardIssue".
type issueLink struct {
	Type struct {
		Name    string `json:"name"`
		Inward  string `json:"inward"`
		Outward string `json:"outward"`
	} `json:"type"`
	InwardIssue  *struct{ Key string } `json:"inwardIssue"`
	OutwardIssue *struct{ Key string } `json:"outwardIssue"`
}

// waitPhrases read as "this issue waits for the linked one"; heldPhrases
// as "the linked one waits for this issue". Jira's standard Blocks type
// and the usual custom dependency types use these.
var (
	waitPhrases = []string{"is blocked by", "blocked by", "depends on", "is dependent on", "requires", "needs"}
	heldPhrases = []string{"blocks", "is depended on by", "is required by", "is needed by", "is a prerequisite of", "is a prerequisite for"}
)

// dependencies reads the issue's blocking links: the issues it waits for,
// and the issues that wait for it. Other links (relates, duplicates) do
// not order work.
func (is issue) dependencies() (dependsOn, dependents []string) {
	if is.Fields.IssueLinks == nil {
		return nil, nil
	}
	classify := func(phrase string) (waits, held bool) {
		p := strings.ToLower(strings.TrimSpace(phrase))
		return slices.Contains(waitPhrases, p), slices.Contains(heldPhrases, p)
	}
	for _, l := range *is.Fields.IssueLinks {
		var other, phrase string
		switch {
		case l.InwardIssue != nil:
			other, phrase = l.InwardIssue.Key, l.Type.Inward
		case l.OutwardIssue != nil:
			other, phrase = l.OutwardIssue.Key, l.Type.Outward
		default:
			continue
		}
		waits, held := classify(phrase)
		switch {
		case waits && !slices.Contains(dependsOn, other):
			dependsOn = append(dependsOn, other)
		case held && !slices.Contains(dependents, other):
			dependents = append(dependents, other)
		}
	}
	return dependsOn, dependents
}

func (is issue) incoming(label string) orchestrator.Incoming {
	in := orchestrator.Incoming{
		Key: is.Key, Project: is.Fields.Project.Key, Title: is.Fields.Summary,
		Description: descriptionText(is.Fields.Description), Kind: is.kind(label),
		Repo: domain.RepoFromLabels(is.Fields.Labels), Repos: domain.ReposFromLabels(is.Fields.Labels), Group: domain.GroupFromLabels(is.Fields.Labels),
	}
	if in.Project == "" {
		if i := strings.LastIndex(is.Key, "-"); i > 0 {
			in.Project = is.Key[:i]
		}
	}
	if is.Fields.Priority != nil {
		in.Priority = is.Fields.Priority.Name
	}
	if is.Fields.IssueLinks != nil {
		in.LinksKnown = true
		in.DependsOn, in.Dependents = is.dependencies()
	}
	return in
}

// labels are the labels that hand an issue to agnts: the base label and
// one per kind.
func labels(base string) []string {
	out := []string{base}
	for _, k := range domain.Kinds {
		out = append(out, base+"-"+string(k))
	}
	return out
}

// forAgnts reports whether the issue carries any of agnts's labels.
func (is issue) forAgnts(base string) bool {
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
// there are several), or "" for agnts to pick.
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
