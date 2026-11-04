package gitlab

import (
	"context"
	"fmt"
	"net/http"
	"net/url"
	"slices"
	"time"

	"agnts/internal/domain"
	"agnts/internal/vcs"
)

var _ vcs.HistoryReader = (*Host)(nil)

// glHistoryCommit is a commit as the commits and compare APIs list it.
type glHistoryCommit struct {
	ID           string    `json:"id"`
	Message      string    `json:"message"`
	AuthorName   string    `json:"author_name"`
	AuthorEmail  string    `json:"author_email"`
	AuthoredDate time.Time `json:"authored_date"`
	WebURL       string    `json:"web_url"`
	ParentIDs    []string  `json:"parent_ids"`
}

func (c glHistoryCommit) pushed() domain.PushedCommit {
	return domain.PushedCommit{SHA: c.ID, Message: c.Message, Author: c.AuthorName, AuthorEmail: c.AuthorEmail, Date: c.AuthoredDate,
		URL: c.WebURL, Parents: c.ParentIDs}
}

// BranchNames implements vcs.HistoryReader.
func (h *Host) BranchNames(ctx context.Context, repo domain.Repository, max int) ([]string, error) {
	p, err := h.project(ctx, repo)
	if err != nil {
		return nil, err
	}
	var out []string
	for page := 1; len(out) < max; page++ {
		var list []struct {
			Name string `json:"name"`
		}
		if _, err := h.call(ctx, http.MethodGet, fmt.Sprintf("%s/repository/branches?per_page=100&page=%d", p, page), nil, &list); err != nil {
			return out, err
		}
		for _, b := range list {
			out = append(out, b.Name)
		}
		if len(list) < 100 {
			break
		}
	}
	return out[:min(len(out), max)], nil
}

// History implements vcs.HistoryReader.
func (h *Host) History(ctx context.Context, repo domain.Repository, ref string, page, perPage int) ([]domain.PushedCommit, error) {
	p, err := h.project(ctx, repo)
	if err != nil {
		return nil, err
	}
	var list []glHistoryCommit
	q := url.Values{"ref_name": {ref}, "per_page": {fmt.Sprint(min(max(perPage, 1), 100))}, "page": {fmt.Sprint(max(page, 1))}}
	if _, err := h.call(ctx, http.MethodGet, p+"/repository/commits?"+q.Encode(), nil, &list); err != nil {
		return nil, err
	}
	out := make([]domain.PushedCommit, len(list))
	for i, c := range list {
		out[i] = c.pushed()
	}
	return out, nil
}

// Ahead implements vcs.HistoryReader.
func (h *Host) Ahead(ctx context.Context, repo domain.Repository, base, head string) ([]domain.PushedCommit, error) {
	p, err := h.project(ctx, repo)
	if err != nil {
		return nil, err
	}
	var cmp struct {
		Commits []glHistoryCommit `json:"commits"`
	}
	q := url.Values{"from": {base}, "to": {head}, "straight": {"false"}}
	if _, err := h.call(ctx, http.MethodGet, p+"/repository/compare?"+q.Encode(), nil, &cmp); err != nil {
		return nil, err
	}
	out := make([]domain.PushedCommit, len(cmp.Commits))
	for i, c := range cmp.Commits {
		out[i] = c.pushed()
	}
	return out, nil
}

var _ vcs.MergeReader = (*Host)(nil)

// CommitMerges implements vcs.MergeReader: the merged merge requests the
// commit is in. GitLab says whether one was squashed.
func (h *Host) CommitMerges(ctx context.Context, repo domain.Repository, sha string) ([]domain.MergedPull, error) {
	p, err := h.project(ctx, repo)
	if err != nil {
		return nil, err
	}
	var list []struct {
		IID             int        `json:"iid"`
		Title           string     `json:"title"`
		State           string     `json:"state"`
		MergedAt        *time.Time `json:"merged_at"`
		SourceBranch    string     `json:"source_branch"`
		TargetBranch    string     `json:"target_branch"`
		Squash          bool       `json:"squash"`
		SquashCommitSHA string     `json:"squash_commit_sha"`
		MergeCommitSHA  string     `json:"merge_commit_sha"`
		SHA             string     `json:"sha"`
	}
	if _, err := h.call(ctx, http.MethodGet, p+"/repository/commits/"+url.PathEscape(sha)+"/merge_requests", nil, &list); err != nil {
		return nil, err
	}
	var out []domain.MergedPull
	for _, m := range list {
		if m.State != "merged" {
			continue
		}
		mp := domain.MergedPull{Number: m.IID, Title: m.Title, HeadBranch: m.SourceBranch, BaseBranch: m.TargetBranch, MergedAt: m.MergedAt,
			MergeSHA: m.MergeCommitSHA, Squash: m.Squash && m.SquashCommitSHA != "", SquashKnown: true}
		if mp.Squash {
			mp.MergeSHA = m.SquashCommitSHA
		} else if mp.MergeSHA == "" {
			mp.MergeSHA = m.SHA // a fast-forward merge: the head is on the target
		}
		out = append(out, mp)
	}
	return out, nil
}

// PullCommits implements vcs.MergeReader: up to 300 of the merge
// request's commits, oldest first.
func (h *Host) PullCommits(ctx context.Context, repo domain.Repository, number int) ([]domain.PushedCommit, error) {
	p, err := h.project(ctx, repo)
	if err != nil {
		return nil, err
	}
	var out []domain.PushedCommit
	for page := 1; page <= 3; page++ {
		var list []glHistoryCommit
		if _, err := h.call(ctx, http.MethodGet, fmt.Sprintf("%s/merge_requests/%d/commits?per_page=100&page=%d", p, number, page), nil, &list); err != nil {
			return nil, err
		}
		for _, c := range list {
			out = append(out, c.pushed())
		}
		if len(list) < 100 {
			break
		}
	}
	slices.Reverse(out) // GitLab lists them newest first
	return out, nil
}
