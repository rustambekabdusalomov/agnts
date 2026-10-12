// Package github opens pull requests through the GitHub REST API.
package github

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"strconv"
	"strings"
	"time"

	"agnts/internal/domain"
	"agnts/internal/netroute"
	"agnts/internal/orchestrator"
	"agnts/internal/vcs"
)

// TokenSource returns the current GitHub token (fine-grained PAT with
// contents and pull requests write access to the repositories agnts uses).
type TokenSource func(ctx context.Context) (string, error)

// Host implements orchestrator.Host for GitHub.
type Host struct {
	api   string
	token TokenSource
	hc    *http.Client
	etags *etags
}

var _ orchestrator.Host = (*Host)(nil)

// New returns a GitHub host. api is https://api.github.com unless testing.
func New(api string, token TokenSource) *Host {
	return &Host{api: strings.TrimRight(api, "/"), token: token, hc: netroute.Client(30 * time.Second), etags: newEtags()}
}

// OwnerRepo extracts owner and name from an https or ssh GitHub URL.
func OwnerRepo(cloneURL string) (string, string, error) {
	s := strings.TrimSuffix(strings.TrimSpace(cloneURL), ".git")
	if rest, ok := strings.CutPrefix(s, "git@github.com:"); ok {
		s = "https://github.com/" + rest
	}
	u, err := url.Parse(s)
	if err != nil || u.Host != "github.com" {
		return "", "", fmt.Errorf("not a github.com URL: %q", cloneURL)
	}
	parts := strings.Split(strings.Trim(u.Path, "/"), "/")
	if len(parts) != 2 || parts[0] == "" || parts[1] == "" {
		return "", "", fmt.Errorf("not a github.com repository URL: %q", cloneURL)
	}
	return parts[0], parts[1], nil
}

func (h *Host) call(ctx context.Context, method, path string, in, out any) (int, error) {
	tok, err := h.token(ctx)
	if err != nil {
		return 0, err
	}
	if tok == "" {
		return 0, fmt.Errorf("github is %w; run `agnts integration set github`", vcs.ErrNotConnected)
	}
	var body io.Reader
	if in != nil {
		b, _ := json.Marshal(in)
		body = bytes.NewReader(b)
	}
	target := h.api + path
	if strings.Contains(path, "://") {
		target = path // GraphQL lives outside the REST address on Enterprise Server
	}
	req, err := http.NewRequestWithContext(ctx, method, target, body)
	if err != nil {
		return 0, err
	}
	req.Header.Set("Authorization", "Bearer "+tok)
	req.Header.Set("Accept", "application/vnd.github+json")
	req.Header.Set("X-GitHub-Api-Version", "2022-11-28")
	key, cached := "", []byte(nil)
	if method == http.MethodGet {
		key = etagKey(tok, path)
		if etag, body, ok := h.etags.get(key); ok {
			req.Header.Set("If-None-Match", etag)
			cached = body
		}
	}
	resp, err := h.hc.Do(req)
	if err != nil {
		return 0, err
	}
	defer func() { _ = resp.Body.Close() }()
	if resp.StatusCode == http.StatusNotModified && cached != nil {
		return http.StatusOK, decode(cached, out)
	}
	if resp.StatusCode >= 300 {
		b, _ := io.ReadAll(io.LimitReader(resp.Body, 4096))
		return resp.StatusCode, fmt.Errorf("github %s %s: %s: %s", method, path, resp.Status, strings.TrimSpace(string(b)))
	}
	if key == "" {
		if out != nil {
			return resp.StatusCode, json.NewDecoder(resp.Body).Decode(out)
		}
		return resp.StatusCode, nil
	}
	b, err := io.ReadAll(resp.Body)
	if err != nil {
		return resp.StatusCode, err
	}
	h.etags.put(key, resp.Header.Get("ETag"), b)
	return resp.StatusCode, decode(b, out)
}

func decode(b []byte, out any) error {
	if out == nil {
		return nil
	}
	return json.Unmarshal(b, out)
}

type pull struct {
	Number  int    `json:"number"`
	HTMLURL string `json:"html_url"`
}

// OpenPR opens a pull request from branch into the default branch, or
// returns the open one if it already exists (safe to retry).
func (h *Host) OpenPR(ctx context.Context, repo domain.Repository, pr orchestrator.PR) (int, string, error) {
	branch := pr.Branch
	owner, name, err := OwnerRepo(repo.CloneURL)
	if err != nil {
		return 0, "", err
	}
	base := "/repos/" + url.PathEscape(owner) + "/" + url.PathEscape(name) + "/pulls"
	var p pull
	status, err := h.call(ctx, http.MethodPost, base, map[string]any{
		"title": pr.Title, "head": branch, "base": repo.DefaultBranch, "body": pr.Body, "draft": pr.Draft,
	}, &p)
	if err == nil {
		return p.Number, p.HTMLURL, nil
	}
	if status != http.StatusUnprocessableEntity {
		return 0, "", err
	}
	var open []pull
	q := url.Values{"head": {owner + ":" + branch}, "state": {"open"}}
	if _, lerr := h.call(ctx, http.MethodGet, base+"?"+q.Encode(), nil, &open); lerr != nil || len(open) == 0 {
		return 0, "", err // the original 422 explains more than an empty list
	}
	return open[0].Number, open[0].HTMLURL, nil
}

// PRState reports whether pull request number is open, merged or closed
// without a merge (domain.PullOpen, PullMerged, PullClosed).
func (h *Host) PRState(ctx context.Context, repo domain.Repository, number int) (string, error) {
	owner, name, err := OwnerRepo(repo.CloneURL)
	if err != nil {
		return "", err
	}
	var p struct {
		State  string `json:"state"`
		Merged bool   `json:"merged"`
	}
	if _, err := h.call(ctx, http.MethodGet, "/repos/"+url.PathEscape(owner)+"/"+url.PathEscape(name)+"/pulls/"+strconv.Itoa(number), nil, &p); err != nil {
		return "", err
	}
	switch {
	case p.Merged:
		return domain.PullMerged, nil
	case p.State == "closed":
		return domain.PullClosed, nil
	}
	return domain.PullOpen, nil
}

// User returns the login the token belongs to (a connection check).
func (h *Host) User(ctx context.Context) (string, error) {
	var u struct {
		Login string `json:"login"`
	}
	if _, err := h.call(ctx, http.MethodGet, "/user", nil, &u); err != nil {
		return "", err
	}
	return u.Login, nil
}

// HasFile reports whether path exists on the repository's default branch.
func (h *Host) HasFile(ctx context.Context, repo domain.Repository, path string) (bool, error) {
	owner, name, err := OwnerRepo(repo.CloneURL)
	if err != nil {
		return false, err
	}
	q := url.Values{"ref": {repo.DefaultBranch}}
	status, err := h.call(ctx, http.MethodGet, "/repos/"+url.PathEscape(owner)+"/"+url.PathEscape(name)+"/contents/"+path+"?"+q.Encode(), nil, nil)
	if status == http.StatusNotFound {
		return false, nil
	}
	return err == nil, err
}

// needs turns GitHub's "Resource not accessible by personal access token"
// into the fine-grained permission the token is missing.
func needs(status int, err error, permission string) error {
	if err == nil || status != http.StatusForbidden || !strings.Contains(err.Error(), "not accessible by personal access token") {
		return err
	}
	return fmt.Errorf("the GitHub token is missing the %q permission: on GitHub open Settings → Developer settings → Fine-grained tokens, "+
		"edit the token and set Repository permissions → %s", permission, permission)
}

// WithToken returns a host that uses a fixed token (to test one before saving).
func (h *Host) WithToken(token string) *Host {
	return New(h.api, func(context.Context) (string, error) { return token, nil })
}

// Repos lists the repositories the token can reach, most recently updated
// first, up to vcs.MaxRemoteRepos.
func (h *Host) Repos(ctx context.Context) ([]vcs.RemoteRepo, error) {
	var out []vcs.RemoteRepo
	for page := 1; len(out) < vcs.MaxRemoteRepos; page++ {
		var batch []struct {
			FullName      string    `json:"full_name"`
			CloneURL      string    `json:"clone_url"`
			DefaultBranch string    `json:"default_branch"`
			Private       bool      `json:"private"`
			Description   string    `json:"description"`
			PushedAt      time.Time `json:"pushed_at"`
			Archived      bool      `json:"archived"`
		}
		q := url.Values{"per_page": {"100"}, "page": {strconv.Itoa(page)}, "sort": {"pushed"}}
		if _, err := h.call(ctx, http.MethodGet, "/user/repos?"+q.Encode(), nil, &batch); err != nil {
			return nil, err
		}
		for _, r := range batch {
			if r.Archived {
				continue
			}
			out = append(out, vcs.RemoteRepo{FullName: r.FullName, CloneURL: r.CloneURL, DefaultBranch: r.DefaultBranch,
				Private: r.Private, Description: r.Description, UpdatedAt: r.PushedAt})
		}
		if len(batch) < 100 {
			break
		}
	}
	return out, nil
}

// Assign adds assignees to a pull request (pull requests are issues to the
// assignees API). GitHub silently skips users who cannot be assigned.
func (h *Host) Assign(ctx context.Context, repo domain.Repository, number int, usernames []string) error {
	owner, name, err := OwnerRepo(repo.CloneURL)
	if err != nil {
		return err
	}
	path := "/repos/" + url.PathEscape(owner) + "/" + url.PathEscape(name) + "/issues/" + strconv.Itoa(number) + "/assignees"
	status, err := h.call(ctx, http.MethodPost, path, map[string]any{"assignees": usernames}, nil)
	return needs(status, err, "Pull requests: Read and write")
}

// Members lists the repository's collaborators, up to vcs.MaxRemoteRepos.
func (h *Host) Members(ctx context.Context, repo domain.Repository) ([]vcs.Member, error) {
	owner, name, err := OwnerRepo(repo.CloneURL)
	if err != nil {
		return nil, err
	}
	var out []vcs.Member
	for page := 1; len(out) < vcs.MaxRemoteRepos; page++ {
		var batch []struct {
			Login     string `json:"login"`
			AvatarURL string `json:"avatar_url"`
			HTMLURL   string `json:"html_url"`
			RoleName  string `json:"role_name"`
		}
		q := url.Values{"per_page": {"100"}, "page": {strconv.Itoa(page)}}
		if _, err := h.call(ctx, http.MethodGet, "/repos/"+url.PathEscape(owner)+"/"+url.PathEscape(name)+"/collaborators?"+q.Encode(), nil, &batch); err != nil {
			return nil, err
		}
		for _, m := range batch {
			out = append(out, vcs.Member{Username: m.Login, AvatarURL: m.AvatarURL, URL: m.HTMLURL, Role: m.RoleName})
		}
		if len(batch) < 100 {
			break
		}
	}
	return out, nil
}
