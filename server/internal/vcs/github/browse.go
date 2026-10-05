package github

import (
	"context"
	"fmt"
	"net/http"
	"net/url"
	"strings"
	"time"

	"hiro/internal/domain"
	"hiro/internal/vcs"
)

var _ vcs.Provider = (*Host)(nil)

func (h *Host) base(repo domain.Repository) (string, error) {
	owner, name, err := OwnerRepo(repo.CloneURL)
	if err != nil {
		return "", err
	}
	return "/repos/" + url.PathEscape(owner) + "/" + url.PathEscape(name), nil
}

type ghCommit struct {
	SHA     string `json:"sha"`
	HTMLURL string `json:"html_url"`
	Commit  struct {
		Message string `json:"message"`
		Author  struct {
			Name string    `json:"name"`
			Date time.Time `json:"date"`
		} `json:"author"`
	} `json:"commit"`
	Stats *struct {
		Additions int `json:"additions"`
		Deletions int `json:"deletions"`
	} `json:"stats"`
}

func firstLine(s string) string {
	if i := strings.IndexByte(s, '\n'); i >= 0 {
		return s[:i]
	}
	return s
}

// checkStatus summarises the check runs on a commit.
func (h *Host) checkStatus(ctx context.Context, base, sha string) string {
	var res struct {
		Total int `json:"total_count"`
		Runs  []struct {
			Status     string `json:"status"`
			Conclusion string `json:"conclusion"`
		} `json:"check_runs"`
	}
	if _, err := h.call(ctx, http.MethodGet, base+"/commits/"+sha+"/check-runs?per_page=50", nil, &res); err != nil || res.Total == 0 {
		return vcs.CINone
	}
	st := vcs.CIOK
	for _, r := range res.Runs {
		switch {
		case r.Status != "completed":
			st = vcs.CIRun
		case r.Conclusion == "failure" || r.Conclusion == "timed_out":
			return vcs.CIFail
		}
	}
	return st
}

// Branches lists up to 30 branches with their tip, ahead/behind and checks.
func (h *Host) Branches(ctx context.Context, repo domain.Repository) ([]vcs.Branch, error) {
	base, err := h.base(repo)
	if err != nil {
		return nil, err
	}
	var list []struct {
		Name   string `json:"name"`
		Commit struct {
			SHA string `json:"sha"`
		} `json:"commit"`
	}
	if _, err := h.call(ctx, http.MethodGet, base+"/branches?per_page=30", nil, &list); err != nil {
		return nil, err
	}
	out := make([]vcs.Branch, len(list))
	vcs.Limit(list, 6, func(i int, b struct {
		Name   string `json:"name"`
		Commit struct {
			SHA string `json:"sha"`
		} `json:"commit"`
	}) {
		br := vcs.Branch{Name: b.Name, SHA: b.Commit.SHA, Default: b.Name == repo.DefaultBranch}
		var c ghCommit
		if _, err := h.call(ctx, http.MethodGet, base+"/commits/"+b.Commit.SHA, nil, &c); err == nil {
			br.Message, br.Author, br.Date = firstLine(c.Commit.Message), c.Commit.Author.Name, c.Commit.Author.Date
		}
		if !br.Default {
			var cmp struct {
				Ahead  int `json:"ahead_by"`
				Behind int `json:"behind_by"`
			}
			if _, err := h.call(ctx, http.MethodGet, base+"/compare/"+url.PathEscape(repo.DefaultBranch)+"..."+url.PathEscape(b.Name), nil, &cmp); err == nil {
				br.Ahead, br.Behind = cmp.Ahead, cmp.Behind
			}
		}
		br.CI = h.checkStatus(ctx, base, b.Commit.SHA)
		out[i] = br
	})
	return out, nil
}

// Commits lists recent commits on the default branch.
func (h *Host) Commits(ctx context.Context, repo domain.Repository, page, perPage int) ([]vcs.Commit, error) {
	base, err := h.base(repo)
	if err != nil {
		return nil, err
	}
	var list []ghCommit
	q := url.Values{"sha": {repo.DefaultBranch}, "per_page": {fmt.Sprint(min(max(perPage, 1), 100))}, "page": {fmt.Sprint(max(page, 1))}}
	if _, err := h.call(ctx, http.MethodGet, base+"/commits?"+q.Encode(), nil, &list); err != nil {
		return nil, err
	}
	out := make([]vcs.Commit, len(list))
	for i, c := range list {
		out[i] = vcs.Commit{SHA: c.SHA, Message: firstLine(c.Commit.Message), Author: c.Commit.Author.Name, Date: c.Commit.Author.Date, URL: c.HTMLURL, CI: vcs.CINone}
	}
	// Checks for the newest few only (first page): one API call each.
	n := min(len(out), 10)
	if page > 1 {
		n = 0
	}
	vcs.Limit(out[:n], 5, func(i int, c vcs.Commit) { out[i].CI = h.checkStatus(ctx, base, c.SHA) })
	return out, nil
}

func actionsStatus(status, conclusion string) string {
	switch status {
	case "queued", "waiting", "pending", "requested":
		return vcs.CIPending
	case "in_progress":
		return vcs.CIRun
	}
	switch conclusion {
	case "success":
		return vcs.CIOK
	case "failure", "timed_out", "startup_failure":
		return vcs.CIFail
	case "cancelled":
		return vcs.CICanceled
	case "skipped", "neutral":
		return vcs.CISkip
	case "action_required":
		return vcs.CIManual
	}
	return vcs.CINone
}

// Pipelines lists GitHub Actions runs with their jobs as stages.
func (h *Host) Pipelines(ctx context.Context, repo domain.Repository, page, perPage int) ([]vcs.Pipeline, error) {
	base, err := h.base(repo)
	if err != nil {
		return nil, err
	}
	var runs struct {
		Runs []struct {
			ID           int64     `json:"id"`
			Name         string    `json:"name"`
			DisplayTitle string    `json:"display_title"`
			HeadBranch   string    `json:"head_branch"`
			HeadSHA      string    `json:"head_sha"`
			Event        string    `json:"event"`
			Status       string    `json:"status"`
			Conclusion   string    `json:"conclusion"`
			CreatedAt    time.Time `json:"created_at"`
			UpdatedAt    time.Time `json:"updated_at"`
			HTMLURL      string    `json:"html_url"`
		} `json:"workflow_runs"`
	}
	if status, err := h.call(ctx, http.MethodGet, fmt.Sprintf("%s/actions/runs?per_page=%d&page=%d", base, min(max(perPage, 1), 50), max(page, 1)), nil, &runs); err != nil {
		return nil, needs(status, err, "Actions: Read")
	}
	out := make([]vcs.Pipeline, len(runs.Runs))
	for i, r := range runs.Runs {
		out[i] = vcs.Pipeline{ID: r.ID, Name: r.Name, Branch: r.HeadBranch, SHA: r.HeadSHA, Message: r.DisplayTitle,
			Trigger: strings.ReplaceAll(r.Event, "_", " "), Status: actionsStatus(r.Status, r.Conclusion), Created: r.CreatedAt, URL: r.HTMLURL}
		if r.Status == "completed" {
			out[i].Duration = r.UpdatedAt.Sub(r.CreatedAt)
		}
	}
	vcs.Limit(out, 5, func(i int, p vcs.Pipeline) {
		var jobs struct {
			Jobs []struct {
				ID          int64      `json:"id"`
				Name        string     `json:"name"`
				Status      string     `json:"status"`
				Conclusion  string     `json:"conclusion"`
				StartedAt   *time.Time `json:"started_at"`
				CompletedAt *time.Time `json:"completed_at"`
			} `json:"jobs"`
		}
		if _, err := h.call(ctx, http.MethodGet, fmt.Sprintf("%s/actions/runs/%d/jobs", base, p.ID), nil, &jobs); err != nil {
			return
		}
		for _, j := range jobs.Jobs {
			st := vcs.Stage{ID: j.ID, Name: j.Name, Status: actionsStatus(j.Status, j.Conclusion)}
			if j.StartedAt != nil && j.CompletedAt != nil {
				st.Duration = j.CompletedAt.Sub(*j.StartedAt)
			}
			out[i].Stages = append(out[i].Stages, st)
		}
	})
	return out, nil
}

// Environments lists deployment environments with their latest deployment.
func (h *Host) Environments(ctx context.Context, repo domain.Repository) ([]vcs.Environment, error) {
	base, err := h.base(repo)
	if err != nil {
		return nil, err
	}
	var envs struct {
		Environments []struct {
			Name    string `json:"name"`
			HTMLURL string `json:"html_url"`
		} `json:"environments"`
	}
	if status, err := h.call(ctx, http.MethodGet, base+"/environments", nil, &envs); err != nil {
		if status == http.StatusNotFound {
			return []vcs.Environment{}, nil
		}
		return nil, needs(status, err, "Actions: Read")
	}
	out := make([]vcs.Environment, len(envs.Environments))
	vcs.Limit(envs.Environments, 4, func(i int, e struct {
		Name    string `json:"name"`
		HTMLURL string `json:"html_url"`
	}) {
		out[i] = vcs.Environment{Name: e.Name, URL: e.HTMLURL}
		var deps []struct {
			SHA       string    `json:"sha"`
			CreatedAt time.Time `json:"created_at"`
		}
		q := url.Values{"environment": {e.Name}, "per_page": {"1"}}
		if _, err := h.call(ctx, http.MethodGet, base+"/deployments?"+q.Encode(), nil, &deps); err == nil && len(deps) > 0 {
			out[i].SHA, out[i].DeployedAt = deps[0].SHA, &deps[0].CreatedAt
		}
	})
	return out, nil
}

// Deploy runs the repository's deploy workflow (workflow_dispatch) on a ref.
func (h *Host) Deploy(ctx context.Context, repo domain.Repository, d vcs.Deploy) error {
	if repo.DeployWorkflow == "" {
		return fmt.Errorf("set a deploy workflow (e.g. deploy.yml) on this repository first")
	}
	base, err := h.base(repo)
	if err != nil {
		return err
	}
	ref := d.Ref
	if ref == "" {
		ref = repo.DefaultBranch
	}
	status, err := h.call(ctx, http.MethodPost, base+"/actions/workflows/"+url.PathEscape(repo.DeployWorkflow)+"/dispatches",
		map[string]any{"ref": ref}, nil)
	return needs(status, err, "Actions: Read and write")
}
