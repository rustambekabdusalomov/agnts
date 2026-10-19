package gitlab

import (
	"context"
	"fmt"
	"net/http"
	"net/url"
	"slices"
	"strconv"
	"strings"
	"time"

	"agnts/internal/domain"
	"agnts/internal/orchestrator"
)

var _ orchestrator.ReviewHost = (*Host)(nil)

type glUser struct {
	Username string `json:"username"`
}

type glMR struct {
	IID          int       `json:"iid"`
	WebURL       string    `json:"web_url"`
	Title        string    `json:"title"`
	Description  string    `json:"description"`
	State        string    `json:"state"` // opened, closed, locked, merged
	Draft        bool      `json:"draft"`
	WIP          bool      `json:"work_in_progress"`
	Author       glUser    `json:"author"`
	SourceBranch string    `json:"source_branch"`
	TargetBranch string    `json:"target_branch"`
	SHA          string    `json:"sha"`
	Assignees    []glUser  `json:"assignees"`
	Reviewers    []glUser  `json:"reviewers"`
	UpdatedAt    time.Time `json:"updated_at"`
	DiffRefs     struct {
		BaseSHA  string `json:"base_sha"`
		HeadSHA  string `json:"head_sha"`
		StartSHA string `json:"start_sha"`
	} `json:"diff_refs"`
}

func (m glMR) domain(login, why string) domain.PullRequest {
	state := domain.PullOpen
	switch m.State {
	case "merged":
		state = domain.PullMerged
	case "closed":
		state = domain.PullClosed
	}
	return domain.PullRequest{
		Number: m.IID, URL: m.WebURL, Title: m.Title, Body: m.Description, Author: m.Author.Username,
		HeadRef: m.SourceBranch, HeadSHA: m.SHA, BaseRef: m.TargetBranch, FetchRef: "refs/merge-requests/" + strconv.Itoa(m.IID) + "/head",
		Draft: m.Draft || m.WIP, State: state, Login: login, Why: why, UpdatedAt: m.UpdatedAt,
		BaseSHA: m.DiffRefs.BaseSHA, StartSHA: m.DiffRefs.StartSHA,
	}
}

func hasUser(us []glUser, login string) bool {
	return slices.ContainsFunc(us, func(u glUser) bool { return strings.EqualFold(u.Username, login) })
}

// ReviewQueue returns the open merge requests of repo assigned to the
// token's user or, with requested, that list them as a reviewer. With all,
// every other open merge request comes too, their own included (else left
// out).
func (h *Host) ReviewQueue(ctx context.Context, repo domain.Repository, requested, all bool) ([]domain.PullRequest, error) {
	p, err := h.project(ctx, repo)
	if err != nil {
		return nil, err
	}
	login, err := h.User(ctx)
	if err != nil {
		return nil, err
	}
	var out []domain.PullRequest
	for page := 1; page <= 5; page++ {
		var batch []glMR
		q := url.Values{"state": {"opened"}, "per_page": {"100"}, "page": {strconv.Itoa(page)}, "order_by": {"updated_at"}}
		if _, err := h.call(ctx, http.MethodGet, p+"/merge_requests?"+q.Encode(), nil, &batch); err != nil {
			return nil, err
		}
		for _, m := range batch {
			if strings.EqualFold(m.Author.Username, login) {
				if all {
					out = append(out, m.domain(login, domain.PullOwn))
				}
				continue
			}
			switch {
			case hasUser(m.Assignees, login):
				out = append(out, m.domain(login, domain.PullAssigned))
			case requested && hasUser(m.Reviewers, login):
				out = append(out, m.domain(login, domain.PullReviewRequested))
			case all:
				out = append(out, m.domain(login, domain.PullOpenRepo))
			}
		}
		if len(batch) < 100 {
			break
		}
	}
	return out, nil
}

// PullRequest returns one merge request (by IID) as it stands now.
func (h *Host) PullRequest(ctx context.Context, repo domain.Repository, number int) (domain.PullRequest, error) {
	p, err := h.project(ctx, repo)
	if err != nil {
		return domain.PullRequest{}, err
	}
	var m glMR
	if _, err := h.call(ctx, http.MethodGet, p+"/merge_requests/"+strconv.Itoa(number), nil, &m); err != nil {
		return domain.PullRequest{}, err
	}
	login, _ := h.User(ctx)
	why := domain.PullOpenRepo
	switch {
	case strings.EqualFold(m.Author.Username, login):
		why = domain.PullOwn
	case hasUser(m.Assignees, login):
		why = domain.PullAssigned
	case hasUser(m.Reviewers, login):
		why = domain.PullReviewRequested
	}
	return m.domain(login, why), nil
}

// MergePR merges a merge request whose head is sha. GitLab has no rebase
// merge here: "rebase" merges the way the project is set up to.
func (h *Host) MergePR(ctx context.Context, repo domain.Repository, number int, sha, method string) error {
	p, err := h.project(ctx, repo)
	if err != nil {
		return err
	}
	status, err := h.call(ctx, http.MethodPut, p+"/merge_requests/"+strconv.Itoa(number)+"/merge",
		map[string]any{"sha": sha, "squash": method == "squash"}, nil)
	switch status {
	case http.StatusConflict:
		return fmt.Errorf("the head of the merge request moved: %w", err)
	case http.StatusMethodNotAllowed, http.StatusNotAcceptable, http.StatusUnprocessableEntity:
		return fmt.Errorf("GitLab cannot merge it yet (pipeline, approvals, conflicts or a draft): %w", err)
	}
	return err
}

// CommentPR posts a note on a merge request (by IID).
func (h *Host) CommentPR(ctx context.Context, repo domain.Repository, number int, body string) error {
	p, err := h.project(ctx, repo)
	if err != nil {
		return err
	}
	_, err = h.call(ctx, http.MethodPost, p+"/merge_requests/"+strconv.Itoa(number)+"/notes", map[string]any{"body": body}, nil)
	return err
}
