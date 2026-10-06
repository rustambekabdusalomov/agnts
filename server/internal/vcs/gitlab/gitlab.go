// Package gitlab is the GitLab adapter: merge requests and the repository
// views, through the REST API v4 (gitlab.com or a self-hosted instance).
package gitlab

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
	"time"

	"agnts/internal/domain"
	"agnts/internal/orchestrator"
	"agnts/internal/vcs"
)

// Config is the GitLab connection.
type Config struct {
	URL   string // https://gitlab.com or your instance
	Token string // personal access token: api, read_repository, write_repository
}

// ConfigSource loads the current connection (ok=false when not connected).
type ConfigSource func(ctx context.Context) (Config, bool, error)

// Host implements vcs.Provider for GitLab.
type Host struct {
	cfg ConfigSource
	hc  *http.Client
}

var _ vcs.Provider = (*Host)(nil)

// New returns a GitLab host.
func New(cfg ConfigSource) *Host {
	return &Host{cfg: cfg, hc: &http.Client{Timeout: 30 * time.Second}}
}

// WithConfig returns a host with a fixed connection (to test one before saving).
func WithConfig(c Config) *Host {
	return New(func(context.Context) (Config, bool, error) { return c, true, nil })
}

// ProjectPath returns "group/sub/project" for a clone URL on the instance.
func ProjectPath(instance, cloneURL string) (string, error) {
	iu, err := url.Parse(strings.TrimRight(instance, "/"))
	if err != nil || iu.Host == "" {
		return "", errors.New("gitlab instance URL is not set")
	}
	cu, err := url.Parse(strings.TrimSuffix(strings.TrimSpace(cloneURL), ".git"))
	if err != nil || !strings.EqualFold(cu.Host, iu.Host) {
		return "", fmt.Errorf("%q is not on %s", cloneURL, iu.Host)
	}
	p := strings.Trim(strings.TrimPrefix(cu.Path, strings.TrimRight(iu.Path, "/")), "/")
	if strings.Count(p, "/") < 1 {
		return "", fmt.Errorf("%q is not a project URL", cloneURL)
	}
	return p, nil
}

func (h *Host) call(ctx context.Context, method, path string, in, out any) (int, error) {
	c, ok, err := h.cfg(ctx)
	if err != nil {
		return 0, err
	}
	if !ok || c.Token == "" {
		return 0, fmt.Errorf("gitlab is %w", vcs.ErrNotConnected)
	}
	var body io.Reader
	if in != nil {
		b, _ := json.Marshal(in)
		body = bytes.NewReader(b)
	}
	req, err := http.NewRequestWithContext(ctx, method, strings.TrimRight(c.URL, "/")+"/api/v4"+path, body)
	if err != nil {
		return 0, err
	}
	req.Header.Set("PRIVATE-TOKEN", c.Token)
	if in != nil {
		req.Header.Set("Content-Type", "application/json")
	}
	resp, err := h.hc.Do(req)
	if err != nil {
		return 0, err
	}
	defer func() { _ = resp.Body.Close() }()
	if resp.StatusCode >= 300 {
		b, _ := io.ReadAll(io.LimitReader(resp.Body, 4096))
		return resp.StatusCode, fmt.Errorf("gitlab %s %s: %s: %s", method, path, resp.Status, strings.TrimSpace(string(b)))
	}
	if out != nil {
		return resp.StatusCode, json.NewDecoder(resp.Body).Decode(out)
	}
	return resp.StatusCode, nil
}

func (h *Host) project(ctx context.Context, repo domain.Repository) (string, error) {
	c, _, err := h.cfg(ctx)
	if err != nil {
		return "", err
	}
	p, err := ProjectPath(c.URL, repo.CloneURL)
	if err != nil {
		return "", err
	}
	return "/projects/" + url.PathEscape(p), nil
}

// User returns the token's username (a connection check).
func (h *Host) User(ctx context.Context) (string, error) {
	var u struct {
		Username string `json:"username"`
	}
	_, err := h.call(ctx, http.MethodGet, "/user", nil, &u)
	return u.Username, err
}

type mr struct {
	IID    int    `json:"iid"`
	WebURL string `json:"web_url"`
}

// OpenPR opens a merge request, or returns the open one for the branch.
func (h *Host) OpenPR(ctx context.Context, repo domain.Repository, pr orchestrator.PR) (int, string, error) {
	p, err := h.project(ctx, repo)
	if err != nil {
		return 0, "", err
	}
	title := pr.Title
	if pr.Draft {
		title = "Draft: " + title
	}
	var m mr
	status, err := h.call(ctx, http.MethodPost, p+"/merge_requests", map[string]any{
		"source_branch": pr.Branch, "target_branch": repo.DefaultBranch, "title": title, "description": pr.Body,
		"remove_source_branch": true,
	}, &m)
	if err == nil {
		return m.IID, m.WebURL, nil
	}
	if status != http.StatusConflict {
		return 0, "", err
	}
	var open []mr
	q := url.Values{"source_branch": {pr.Branch}, "state": {"opened"}}
	if _, lerr := h.call(ctx, http.MethodGet, p+"/merge_requests?"+q.Encode(), nil, &open); lerr != nil || len(open) == 0 {
		return 0, "", err
	}
	return open[0].IID, open[0].WebURL, nil
}

func ciStatus(s string) string {
	switch s {
	case "success":
		return vcs.CIOK
	case "failed":
		return vcs.CIFail
	case "running":
		return vcs.CIRun
	case "pending", "created", "waiting_for_resource", "preparing", "scheduled":
		return vcs.CIPending
	case "manual":
		return vcs.CIManual
	case "skipped":
		return vcs.CISkip
	case "canceled":
		return vcs.CICanceled
	}
	return vcs.CINone
}

type glCommit struct {
	ID            string    `json:"id"`
	Title         string    `json:"title"`
	AuthorName    string    `json:"author_name"`
	CommittedDate time.Time `json:"committed_date"`
	WebURL        string    `json:"web_url"`
	Stats         *struct {
		Additions int `json:"additions"`
		Deletions int `json:"deletions"`
	} `json:"stats"`
	LastPipeline *struct {
		Status string `json:"status"`
	} `json:"last_pipeline"`
}

// Branches lists branches with ahead/behind against the default branch.
func (h *Host) Branches(ctx context.Context, repo domain.Repository) ([]vcs.Branch, error) {
	p, err := h.project(ctx, repo)
	if err != nil {
		return nil, err
	}
	var list []struct {
		Name    string   `json:"name"`
		Default bool     `json:"default"`
		Commit  glCommit `json:"commit"`
	}
	if _, err := h.call(ctx, http.MethodGet, p+"/repository/branches?per_page=30", nil, &list); err != nil {
		return nil, err
	}
	out := make([]vcs.Branch, len(list))
	vcs.Limit(list, 6, func(i int, b struct {
		Name    string   `json:"name"`
		Default bool     `json:"default"`
		Commit  glCommit `json:"commit"`
	}) {
		br := vcs.Branch{Name: b.Name, Default: b.Default || b.Name == repo.DefaultBranch, SHA: b.Commit.ID, Message: b.Commit.Title,
			Author: b.Commit.AuthorName, Date: b.Commit.CommittedDate, CI: vcs.CINone}
		var c glCommit
		if _, err := h.call(ctx, http.MethodGet, p+"/repository/commits/"+url.PathEscape(b.Commit.ID), nil, &c); err == nil && c.LastPipeline != nil {
			br.CI = ciStatus(c.LastPipeline.Status)
		}
		if !br.Default {
			count := func(from, to string) int {
				var cmp struct {
					Commits []json.RawMessage `json:"commits"`
				}
				q := url.Values{"from": {from}, "to": {to}, "straight": {"false"}}
				if _, err := h.call(ctx, http.MethodGet, p+"/repository/compare?"+q.Encode(), nil, &cmp); err != nil {
					return 0
				}
				return len(cmp.Commits)
			}
			br.Ahead, br.Behind = count(repo.DefaultBranch, b.Name), count(b.Name, repo.DefaultBranch)
		}
		out[i] = br
	})
	return out, nil
}

// Commits lists recent commits on the default branch.
func (h *Host) Commits(ctx context.Context, repo domain.Repository, page, perPage int) ([]vcs.Commit, error) {
	p, err := h.project(ctx, repo)
	if err != nil {
		return nil, err
	}
	var list []glCommit
	q := url.Values{"ref_name": {repo.DefaultBranch}, "per_page": {fmt.Sprint(min(max(perPage, 1), 100))}, "page": {fmt.Sprint(max(page, 1))}, "with_stats": {"true"}}
	if _, err := h.call(ctx, http.MethodGet, p+"/repository/commits?"+q.Encode(), nil, &list); err != nil {
		return nil, err
	}
	out := make([]vcs.Commit, len(list))
	for i, c := range list {
		out[i] = vcs.Commit{SHA: c.ID, Message: c.Title, Author: c.AuthorName, Date: c.CommittedDate, URL: c.WebURL, CI: vcs.CINone}
		if c.Stats != nil {
			out[i].Add, out[i].Del = c.Stats.Additions, c.Stats.Deletions
		}
	}
	return out, nil
}

// Pipelines lists pipelines with their jobs grouped into stages. A manual
// job (e.g. "deploy to production") shows as a startable stage.
func (h *Host) Pipelines(ctx context.Context, repo domain.Repository, page, perPage int) ([]vcs.Pipeline, error) {
	p, err := h.project(ctx, repo)
	if err != nil {
		return nil, err
	}
	var list []struct {
		ID        int64     `json:"id"`
		SHA       string    `json:"sha"`
		Ref       string    `json:"ref"`
		Status    string    `json:"status"`
		Source    string    `json:"source"`
		CreatedAt time.Time `json:"created_at"`
		UpdatedAt time.Time `json:"updated_at"`
		WebURL    string    `json:"web_url"`
	}
	if _, err := h.call(ctx, http.MethodGet, fmt.Sprintf("%s/pipelines?per_page=%d&page=%d", p, min(max(perPage, 1), 50), max(page, 1)), nil, &list); err != nil {
		return nil, err
	}
	out := make([]vcs.Pipeline, len(list))
	for i, x := range list {
		out[i] = vcs.Pipeline{ID: x.ID, Branch: x.Ref, SHA: x.SHA, Trigger: strings.ReplaceAll(x.Source, "_", " "),
			Status: ciStatus(x.Status), Created: x.CreatedAt, URL: x.WebURL}
		if out[i].Status == vcs.CIOK || out[i].Status == vcs.CIFail {
			out[i].Duration = x.UpdatedAt.Sub(x.CreatedAt)
		}
	}
	vcs.Limit(out, 5, func(i int, pl vcs.Pipeline) {
		var jobs []struct {
			ID       int64   `json:"id"`
			Name     string  `json:"name"`
			Stage    string  `json:"stage"`
			Status   string  `json:"status"`
			Duration float64 `json:"duration"`
			Commit   struct {
				Title string `json:"title"`
			} `json:"commit"`
		}
		if _, err := h.call(ctx, http.MethodGet, fmt.Sprintf("%s/pipelines/%d/jobs?per_page=100&include_retried=false", p, pl.ID), nil, &jobs); err != nil {
			return
		}
		// GitLab lists jobs newest first; stages run in reverse order of that.
		for j := len(jobs) - 1; j >= 0; j-- {
			jb := jobs[j]
			if out[i].Message == "" {
				out[i].Message = jb.Commit.Title
			}
			out[i].Stages = append(out[i].Stages, vcs.Stage{ID: jb.ID, Name: jb.Stage + ": " + jb.Name, Status: ciStatus(jb.Status),
				Duration: time.Duration(jb.Duration * float64(time.Second)), Manual: jb.Status == "manual"})
		}
	})
	return out, nil
}

// Environments lists available environments with their last deployment.
func (h *Host) Environments(ctx context.Context, repo domain.Repository) ([]vcs.Environment, error) {
	p, err := h.project(ctx, repo)
	if err != nil {
		return nil, err
	}
	var list []struct {
		ID          int64  `json:"id"`
		Name        string `json:"name"`
		ExternalURL string `json:"external_url"`
	}
	if _, err := h.call(ctx, http.MethodGet, p+"/environments?states=available&per_page=20", nil, &list); err != nil {
		return nil, err
	}
	out := make([]vcs.Environment, len(list))
	vcs.Limit(list, 4, func(i int, e struct {
		ID          int64  `json:"id"`
		Name        string `json:"name"`
		ExternalURL string `json:"external_url"`
	}) {
		out[i] = vcs.Environment{Name: e.Name, URL: e.ExternalURL}
		var one struct {
			LastDeployment *struct {
				SHA       string    `json:"sha"`
				CreatedAt time.Time `json:"created_at"`
			} `json:"last_deployment"`
		}
		if _, err := h.call(ctx, http.MethodGet, fmt.Sprintf("%s/environments/%d", p, e.ID), nil, &one); err == nil && one.LastDeployment != nil {
			out[i].SHA, out[i].DeployedAt = one.LastDeployment.SHA, &one.LastDeployment.CreatedAt
		}
	})
	return out, nil
}

// Deploy starts a manual job.
func (h *Host) Deploy(ctx context.Context, repo domain.Repository, d vcs.Deploy) error {
	if d.JobID == 0 {
		return errors.New("choose the manual deploy job to start")
	}
	p, err := h.project(ctx, repo)
	if err != nil {
		return err
	}
	_, err = h.call(ctx, http.MethodPost, fmt.Sprintf("%s/jobs/%d/play", p, d.JobID), map[string]any{}, nil)
	return err
}

// Repos lists the projects the token can push to (Developer or higher),
// most recently active first, up to vcs.MaxRemoteRepos.
func (h *Host) Repos(ctx context.Context) ([]vcs.RemoteRepo, error) {
	var out []vcs.RemoteRepo
	for page := 1; len(out) < vcs.MaxRemoteRepos; page++ {
		var batch []struct {
			PathWithNamespace string    `json:"path_with_namespace"`
			HTTPURLToRepo     string    `json:"http_url_to_repo"`
			DefaultBranch     string    `json:"default_branch"`
			Visibility        string    `json:"visibility"`
			Description       string    `json:"description"`
			LastActivityAt    time.Time `json:"last_activity_at"`
		}
		q := url.Values{
			"membership": {"true"}, "min_access_level": {"30"}, "archived": {"false"},
			"order_by": {"last_activity_at"}, "simple": {"true"}, "per_page": {"100"}, "page": {strconv.Itoa(page)},
		}
		if _, err := h.call(ctx, http.MethodGet, "/projects?"+q.Encode(), nil, &batch); err != nil {
			return nil, err
		}
		for _, p := range batch {
			out = append(out, vcs.RemoteRepo{FullName: p.PathWithNamespace, CloneURL: p.HTTPURLToRepo, DefaultBranch: p.DefaultBranch,
				Private: p.Visibility != "public", Description: p.Description, UpdatedAt: p.LastActivityAt})
		}
		if len(batch) < 100 {
			break
		}
	}
	return out, nil
}

// gitlabRoles names GitLab's access levels.
var gitlabRoles = map[int]string{5: "Minimal access", 10: "Guest", 15: "Planner", 20: "Reporter", 30: "Developer", 40: "Maintainer", 50: "Owner"}

type glMember struct {
	ID          int64  `json:"id"`
	Username    string `json:"username"`
	Name        string `json:"name"`
	AvatarURL   string `json:"avatar_url"`
	WebURL      string `json:"web_url"`
	State       string `json:"state"`
	AccessLevel int    `json:"access_level"`
}

func (h *Host) members(ctx context.Context, repo domain.Repository) ([]glMember, error) {
	p, err := h.project(ctx, repo)
	if err != nil {
		return nil, err
	}
	var out []glMember
	for page := 1; len(out) < vcs.MaxRemoteRepos; page++ {
		var batch []glMember
		q := url.Values{"per_page": {"100"}, "page": {strconv.Itoa(page)}}
		if _, err := h.call(ctx, http.MethodGet, p+"/members/all?"+q.Encode(), nil, &batch); err != nil {
			return nil, err
		}
		for _, m := range batch {
			if m.State == "" || m.State == "active" {
				out = append(out, m)
			}
		}
		if len(batch) < 100 {
			break
		}
	}
	return out, nil
}

// Members lists the project's members, including those inherited from groups.
func (h *Host) Members(ctx context.Context, repo domain.Repository) ([]vcs.Member, error) {
	ms, err := h.members(ctx, repo)
	if err != nil {
		return nil, err
	}
	out := make([]vcs.Member, len(ms))
	for i, m := range ms {
		role := gitlabRoles[m.AccessLevel]
		if role == "" {
			role = strconv.Itoa(m.AccessLevel)
		}
		out[i] = vcs.Member{Username: m.Username, Name: m.Name, AvatarURL: m.AvatarURL, URL: m.WebURL, Role: role}
	}
	return out, nil
}

// Assign sets a merge request's assignees. GitLab wants user ids, so the
// usernames are looked up among the project's members.
func (h *Host) Assign(ctx context.Context, repo domain.Repository, number int, usernames []string) error {
	ms, err := h.members(ctx, repo)
	if err != nil {
		return err
	}
	ids := make([]int64, 0, len(usernames))
	var unknown []string
	for _, u := range usernames {
		i := slices.IndexFunc(ms, func(m glMember) bool { return strings.EqualFold(m.Username, u) })
		if i < 0 {
			unknown = append(unknown, u)
			continue
		}
		ids = append(ids, ms[i].ID)
	}
	if len(ids) > 0 {
		p, err := h.project(ctx, repo)
		if err != nil {
			return err
		}
		if _, err := h.call(ctx, http.MethodPut, p+"/merge_requests/"+strconv.Itoa(number), map[string]any{"assignee_ids": ids}, nil); err != nil {
			return err
		}
	}
	if len(unknown) > 0 {
		return fmt.Errorf("not members of the project: %s", strings.Join(unknown, ", "))
	}
	return nil
}
