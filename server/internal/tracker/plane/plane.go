// Package plane is the Plane adapter (https://plane.so, cloud or
// self-hosted): REST v1 client, webhook receiver and the reconcile that
// catches missed webhook deliveries.
//
// Tickets keep Plane's human keys (WEB-123: project identifier and
// sequence id). Most API calls take UUIDs, so the client resolves keys,
// projects, states and labels and caches them.
package plane

import (
	"bytes"
	"context"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"strconv"
	"strings"
	"sync"
	"time"

	"golang.org/x/time/rate"

	"agnts/internal/orchestrator"
)

// Config is the Plane connection, stored encrypted in the integrations table.
type Config struct {
	BaseURL   string `json:"base_url"`  // https://api.plane.so, or the self-hosted instance
	Workspace string `json:"workspace"` // workspace slug
	APIKey    string `json:"api_key"`
	// Label marks work items agnts picks up and lets agnts pick their kind;
	// Label-<kind> (agnts-plan, agnts-bug, ...) also picks them up, with that kind.
	Label         string
	WebhookSecret string            // the secret Plane generated for the webhook
	Statuses      map[string]string // agnts milestone -> Plane state name ("" falls back by state group)
	// Comments says which kinds of comment agnts posts (questions, plan, pr,
	// summary, status). A missing kind means on.
	Comments map[string]bool
}

// DefaultBaseURL is Plane Cloud's API host.
const DefaultBaseURL = "https://api.plane.so"

// FromIntegration builds the config from the stored integration: secrets
// in the encrypted token (JSON), the rest in settings.
func FromIntegration(token string, settings map[string]string, connected bool) (Config, bool, error) {
	var sec struct {
		APIKey        string `json:"api_key"`
		WebhookSecret string `json:"webhook_secret"`
	}
	if token != "" {
		if err := json.Unmarshal([]byte(token), &sec); err != nil {
			return Config{}, false, fmt.Errorf("plane secrets: %w", err)
		}
	}
	c := Config{
		BaseURL: strings.TrimRight(strings.TrimSpace(settings["base_url"]), "/"), Workspace: strings.TrimSpace(settings["workspace"]),
		Label: settings["label"], APIKey: sec.APIKey, WebhookSecret: sec.WebhookSecret,
		Statuses: map[string]string{
			"started": settings["status_started"], "in_review": settings["status_in_review"], "rejected": settings["status_rejected"],
			"merged": settings["status_merged"],
		},
		Comments: map[string]bool{},
	}
	for _, k := range []string{"questions", "plan", "pr", "summary", "status"} {
		c.Comments[k] = settings["comment_"+k] != "false"
	}
	if c.BaseURL == "" {
		c.BaseURL = DefaultBaseURL
	}
	c.BaseURL = strings.TrimSuffix(c.BaseURL, "/api/v1")
	if c.Label == "" {
		c.Label = "agnts"
	}
	return c, connected && c.Workspace != "" && c.APIKey != "", nil
}

// SecretsToken packs the Plane secrets for the encrypted token column.
func SecretsToken(apiKey, webhookSecret string) string {
	b, _ := json.Marshal(map[string]string{"api_key": apiKey, "webhook_secret": webhookSecret}) //nolint:gosec // G117: encrypted before storage
	return string(b)
}

// SettingKeys are the settings the Plane integration accepts.
var SettingKeys = []string{"base_url", "workspace", "label", "status_started", "status_in_review", "status_rejected", "status_merged",
	"comment_questions", "comment_plan", "comment_pr", "comment_summary", "comment_status"}

// ConfigSource loads the current config, so changes apply without a restart.
// It returns ok=false when Plane is not connected.
type ConfigSource func(ctx context.Context) (cfg Config, ok bool, err error)

// Client talks to the Plane REST API v1.
type Client struct {
	cfg ConfigSource
	hc  *http.Client
	// sleep waits out a rate limit; tests replace it.
	sleep func(ctx context.Context, d time.Duration) error
	// limits keep every caller of one API key together under Plane's 60
	// requests a minute per key, with room for the person using it.
	limits map[string]*rate.Limiter

	mu sync.Mutex
	// caches hold what was read, per Plane connection (base URL, Plane
	// workspace and key): agnts workspaces never see each other's.
	caches map[string]*scopeCache
}

// scopeCache is what one Plane connection has read. Guarded by Client.mu.
type scopeCache struct {
	refs  map[string]ref    // WEB-123 -> ids; ids never change
	projs map[string]string // project id -> identifier, and identifier -> project id ("#WEB")
	// states and labels are per project and change rarely; they are
	// reloaded after stateTTL.
	states map[string]cached[[]State]
	labels map[string]cached[[]label]
}

func scopeOf(cfg Config) string {
	sum := sha256.Sum256([]byte(cfg.APIKey))
	return cfg.BaseURL + "|" + cfg.Workspace + "|" + hex.EncodeToString(sum[:8])
}

// cache returns cfg's cache; call it with c.mu held.
func (c *Client) cache(cfg Config) *scopeCache {
	k := scopeOf(cfg)
	sc, ok := c.caches[k]
	if !ok {
		sc = &scopeCache{refs: map[string]ref{}, projs: map[string]string{},
			states: map[string]cached[[]State]{}, labels: map[string]cached[[]label]{}}
		c.caches[k] = sc
	}
	return sc
}

// limiter returns the rate limiter of cfg's API key.
func (c *Client) limiter(cfg Config) *rate.Limiter {
	c.mu.Lock()
	defer c.mu.Unlock()
	k := scopeOf(cfg)
	l, ok := c.limits[k]
	if !ok {
		l = rate.NewLimiter(rate.Every(1200*time.Millisecond), 10)
		c.limits[k] = l
	}
	return l
}

type ref struct{ project, id string }

type cached[T any] struct {
	at time.Time
	v  T
}

const stateTTL = 10 * time.Minute

var (
	_ orchestrator.Tracker      = (*Client)(nil)
	_ orchestrator.IssueCreator = (*Client)(nil)
)

// New returns a Plane client.
func New(cfg ConfigSource) *Client {
	return &Client{cfg: cfg, hc: &http.Client{Timeout: 30 * time.Second}, sleep: sleepCtx,
		limits: map[string]*rate.Limiter{}, caches: map[string]*scopeCache{}}
}

// ErrNotConnected is returned when Plane has not been configured.
var ErrNotConnected = errors.New("plane is not connected")

// errNotFound is a 404 from Plane.
var errNotFound = errors.New("not found")

func sleepCtx(ctx context.Context, d time.Duration) error {
	t := time.NewTimer(d)
	defer t.Stop()
	select {
	case <-ctx.Done():
		return ctx.Err()
	case <-t.C:
		return nil
	}
}

// config loads the config of the agnts workspace ctx acts in.
func (c *Client) config(ctx context.Context) (Config, error) {
	cfg, ok, err := c.cfg(ctx)
	if err != nil {
		return Config{}, err
	}
	if !ok {
		return Config{}, ErrNotConnected
	}
	return cfg, nil
}

// ws is the workspace path prefix.
func ws(cfg Config) string { return "/workspaces/" + url.PathEscape(cfg.Workspace) }

// call sends one request to /api/v1+path, at most 50 a minute. A 429 is
// waited out once.
func (c *Client) call(ctx context.Context, cfg Config, method, path string, in, out any) error {
	var body []byte
	if in != nil {
		var err error
		if body, err = json.Marshal(in); err != nil {
			return err
		}
	}
	for attempt := 0; ; attempt++ {
		if err := c.limiter(cfg).Wait(ctx); err != nil {
			return err
		}
		req, err := http.NewRequestWithContext(ctx, method, cfg.BaseURL+"/api/v1"+path, bytes.NewReader(body))
		if err != nil {
			return err
		}
		req.Header.Set("X-API-Key", cfg.APIKey)
		req.Header.Set("Accept", "application/json")
		if in != nil {
			req.Header.Set("Content-Type", "application/json")
		}
		resp, err := c.hc.Do(req)
		if err != nil {
			return fmt.Errorf("plane %s %s: %w", method, path, err)
		}
		if resp.StatusCode == http.StatusTooManyRequests && attempt == 0 {
			wait := retryAfter(resp.Header, time.Now())
			_ = resp.Body.Close()
			if err := c.sleep(ctx, wait); err != nil {
				return err
			}
			continue
		}
		defer func() { _ = resp.Body.Close() }()
		if resp.StatusCode == http.StatusNotFound {
			return fmt.Errorf("plane %s %s: %w", method, path, errNotFound)
		}
		if resp.StatusCode >= 300 {
			b, _ := io.ReadAll(io.LimitReader(resp.Body, 4096))
			return fmt.Errorf("plane %s %s: %s: %s", method, path, resp.Status, strings.TrimSpace(string(b)))
		}
		if out == nil {
			return nil
		}
		return json.NewDecoder(resp.Body).Decode(out)
	}
}

// retryAfter reads how long to wait from Retry-After (seconds) or
// X-RateLimit-Reset (epoch seconds), between 1 s and a minute.
func retryAfter(h http.Header, now time.Time) time.Duration {
	wait := 5 * time.Second
	if s, err := strconv.Atoi(strings.TrimSpace(h.Get("Retry-After"))); err == nil {
		wait = time.Duration(s) * time.Second
	} else if r, err := strconv.ParseInt(strings.TrimSpace(h.Get("X-RateLimit-Reset")), 10, 64); err == nil {
		wait = time.Unix(r, 0).Sub(now)
	}
	return min(max(wait, time.Second), time.Minute)
}

// list fetches every page of a list endpoint. Plane returns either a plain
// array or a page ({results, next_cursor, next_page_results}).
func (c *Client) list(ctx context.Context, cfg Config, path string, q url.Values, each func(json.RawMessage) error) error {
	if q == nil {
		q = url.Values{}
	}
	q.Set("per_page", "100")
	for page := 0; page < 100; page++ {
		var raw json.RawMessage
		if err := c.call(ctx, cfg, http.MethodGet, path+"?"+q.Encode(), nil, &raw); err != nil {
			return err
		}
		var items []json.RawMessage
		if json.Unmarshal(raw, &items) == nil {
			for _, it := range items {
				if err := each(it); err != nil {
					return err
				}
			}
			return nil
		}
		var p struct {
			Results         []json.RawMessage `json:"results"`
			NextCursor      string            `json:"next_cursor"`
			NextPageResults bool              `json:"next_page_results"`
		}
		if err := json.Unmarshal(raw, &p); err != nil {
			return fmt.Errorf("plane %s: unexpected list response: %w", path, err)
		}
		for _, it := range p.Results {
			if err := each(it); err != nil {
				return err
			}
		}
		if !p.NextPageResults || p.NextCursor == "" {
			return nil
		}
		q.Set("cursor", p.NextCursor)
	}
	return nil
}

// Me checks the credentials and returns the account's display name.
func (c *Client) Me(ctx context.Context) (string, error) {
	cfg, err := c.config(ctx)
	if err != nil {
		return "", err
	}
	var me struct {
		DisplayName string `json:"display_name"`
		FirstName   string `json:"first_name"`
		LastName    string `json:"last_name"`
		Email       string `json:"email"`
	}
	if err := c.call(ctx, cfg, http.MethodGet, "/users/me/", nil, &me); err != nil {
		return "", err
	}
	// The key must also reach the workspace.
	if _, err := c.Projects(ctx); err != nil {
		return "", fmt.Errorf("workspace %q: %w", cfg.Workspace, err)
	}
	if n := strings.TrimSpace(me.FirstName + " " + me.LastName); n != "" {
		return n, nil
	}
	if me.DisplayName != "" {
		return me.DisplayName, nil
	}
	return me.Email, nil
}

// Project is a Plane project.
type Project struct {
	ID         string `json:"id"`
	Identifier string `json:"identifier"`
	Name       string `json:"name"`
}

// Projects lists the workspace's projects the key can see, and fills the
// project cache.
func (c *Client) Projects(ctx context.Context) ([]Project, error) {
	cfg, err := c.config(ctx)
	if err != nil {
		return nil, err
	}
	var out []Project
	err = c.list(ctx, cfg, ws(cfg)+"/projects/", nil, func(raw json.RawMessage) error {
		var p Project
		if err := json.Unmarshal(raw, &p); err != nil {
			return err
		}
		out = append(out, p)
		return nil
	})
	if err != nil {
		return nil, err
	}
	c.mu.Lock()
	for _, p := range out {
		c.cache(cfg).projs[p.ID], c.cache(cfg).projs["#"+strings.ToUpper(p.Identifier)] = p.Identifier, p.ID
	}
	c.mu.Unlock()
	return out, nil
}

// projectID returns the id of the project with this identifier.
func (c *Client) projectID(ctx context.Context, identifier string) (string, error) {
	cfg, err := c.config(ctx)
	if err != nil {
		return "", err
	}
	identifier = strings.ToUpper(identifier)
	c.mu.Lock()
	id, ok := c.cache(cfg).projs["#"+identifier]
	c.mu.Unlock()
	if ok {
		return id, nil
	}
	if _, err := c.Projects(ctx); err != nil {
		return "", err
	}
	c.mu.Lock()
	id, ok = c.cache(cfg).projs["#"+identifier]
	c.mu.Unlock()
	if !ok {
		return "", fmt.Errorf("no Plane project %s in this workspace (or the API key cannot see it)", identifier)
	}
	return id, nil
}

// projectIdentifier returns the identifier (WEB) of the project with this id.
func (c *Client) projectIdentifier(ctx context.Context, id string) (string, error) {
	cfg, err := c.config(ctx)
	if err != nil {
		return "", err
	}
	c.mu.Lock()
	ident, ok := c.cache(cfg).projs[id]
	c.mu.Unlock()
	if ok {
		return ident, nil
	}
	if _, err := c.Projects(ctx); err != nil {
		return "", err
	}
	c.mu.Lock()
	ident, ok = c.cache(cfg).projs[id]
	c.mu.Unlock()
	if !ok {
		return "", fmt.Errorf("plane project %s is not visible to the API key", id)
	}
	return ident, nil
}

// resolve returns the project and work item ids of key (WEB-123).
func (c *Client) resolve(ctx context.Context, cfg Config, key string) (ref, error) {
	c.mu.Lock()
	r, ok := c.cache(cfg).refs[key]
	c.mu.Unlock()
	if ok {
		return r, nil
	}
	var wi struct {
		ID      string `json:"id"`
		Project string `json:"project"`
	}
	if err := c.call(ctx, cfg, http.MethodGet, ws(cfg)+"/work-items/"+url.PathEscape(key)+"/", nil, &wi); err != nil {
		return ref{}, err
	}
	if wi.ID == "" || wi.Project == "" {
		return ref{}, fmt.Errorf("plane returned no ids for %s", key)
	}
	r = ref{project: wi.Project, id: wi.ID}
	c.remember(cfg, key, r)
	return r, nil
}

func (c *Client) remember(cfg Config, key string, r ref) {
	c.mu.Lock()
	c.cache(cfg).refs[key] = r
	c.mu.Unlock()
}

// State is one of a project's workflow states.
type State struct {
	ID    string `json:"id"`
	Name  string `json:"name"`
	Group string `json:"group"` // backlog, unstarted, started, completed, cancelled, triage
}

// States returns a project's states (cached for a few minutes).
func (c *Client) States(ctx context.Context, projectID string) ([]State, error) {
	cfg, err := c.config(ctx)
	if err != nil {
		return nil, err
	}
	return c.loadStates(ctx, cfg, projectID)
}

func (c *Client) loadStates(ctx context.Context, cfg Config, projectID string) ([]State, error) {
	c.mu.Lock()
	s, ok := c.cache(cfg).states[projectID]
	c.mu.Unlock()
	if ok && time.Since(s.at) < stateTTL {
		return s.v, nil
	}
	var out []State
	err := c.list(ctx, cfg, ws(cfg)+"/projects/"+url.PathEscape(projectID)+"/states/", nil, func(raw json.RawMessage) error {
		var st State
		if err := json.Unmarshal(raw, &st); err != nil {
			return err
		}
		out = append(out, st)
		return nil
	})
	if err != nil {
		return nil, err
	}
	c.mu.Lock()
	c.cache(cfg).states[projectID] = cached[[]State]{at: time.Now(), v: out}
	c.mu.Unlock()
	return out, nil
}

// ProjectStates returns the states of the project with this identifier.
func (c *Client) ProjectStates(ctx context.Context, identifier string) ([]State, error) {
	pid, err := c.projectID(ctx, identifier)
	if err != nil {
		return nil, err
	}
	return c.States(ctx, pid)
}

type label struct {
	ID   string `json:"id"`
	Name string `json:"name"`
}

// loadLabels returns a project's labels; fresh forces a reload.
func (c *Client) loadLabels(ctx context.Context, cfg Config, projectID string, fresh bool) ([]label, error) {
	c.mu.Lock()
	l, ok := c.cache(cfg).labels[projectID]
	c.mu.Unlock()
	if ok && !fresh && time.Since(l.at) < stateTTL {
		return l.v, nil
	}
	var out []label
	err := c.list(ctx, cfg, ws(cfg)+"/projects/"+url.PathEscape(projectID)+"/labels/", nil, func(raw json.RawMessage) error {
		var lb label
		if err := json.Unmarshal(raw, &lb); err != nil {
			return err
		}
		out = append(out, lb)
		return nil
	})
	if err != nil {
		return nil, err
	}
	c.mu.Lock()
	c.cache(cfg).labels[projectID] = cached[[]label]{at: time.Now(), v: out}
	c.mu.Unlock()
	return out, nil
}
