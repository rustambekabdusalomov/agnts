package gitlab

import (
	"context"
	"fmt"
	"net/http"
	"net/url"
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
	AuthoredDate time.Time `json:"authored_date"`
	WebURL       string    `json:"web_url"`
}

func (c glHistoryCommit) pushed() domain.PushedCommit {
	return domain.PushedCommit{SHA: c.ID, Message: c.Message, Author: c.AuthorName, Date: c.AuthoredDate, URL: c.WebURL}
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
