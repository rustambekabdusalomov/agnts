package github

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

// ghHistoryCommit is a commit as the commits and compare APIs list it.
type ghHistoryCommit struct {
	SHA     string `json:"sha"`
	HTMLURL string `json:"html_url"`
	Commit  struct {
		Message string `json:"message"`
		Author  struct {
			Name string    `json:"name"`
			Date time.Time `json:"date"`
		} `json:"author"`
	} `json:"commit"`
	Author *struct {
		Login string `json:"login"`
	} `json:"author"`
}

func (c ghHistoryCommit) pushed() domain.PushedCommit {
	out := domain.PushedCommit{SHA: c.SHA, Message: c.Commit.Message, Author: c.Commit.Author.Name, Date: c.Commit.Author.Date, URL: c.HTMLURL}
	if c.Author != nil {
		out.AuthorLogin = c.Author.Login
	}
	return out
}

// BranchNames implements vcs.HistoryReader.
func (h *Host) BranchNames(ctx context.Context, repo domain.Repository, max int) ([]string, error) {
	base, err := h.base(repo)
	if err != nil {
		return nil, err
	}
	var out []string
	for page := 1; len(out) < max; page++ {
		var list []struct {
			Name string `json:"name"`
		}
		if _, err := h.call(ctx, http.MethodGet, fmt.Sprintf("%s/branches?per_page=100&page=%d", base, page), nil, &list); err != nil {
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
	base, err := h.base(repo)
	if err != nil {
		return nil, err
	}
	var list []ghHistoryCommit
	q := url.Values{"sha": {ref}, "per_page": {fmt.Sprint(min(max(perPage, 1), 100))}, "page": {fmt.Sprint(max(page, 1))}}
	if _, err := h.call(ctx, http.MethodGet, base+"/commits?"+q.Encode(), nil, &list); err != nil {
		return nil, err
	}
	out := make([]domain.PushedCommit, len(list))
	for i, c := range list {
		out[i] = c.pushed()
	}
	return out, nil
}

// Ahead implements vcs.HistoryReader.
func (h *Host) Ahead(ctx context.Context, repo domain.Repository, from, head string) ([]domain.PushedCommit, error) {
	base, err := h.base(repo)
	if err != nil {
		return nil, err
	}
	var cmp struct {
		Commits []ghHistoryCommit `json:"commits"`
	}
	if _, err := h.call(ctx, http.MethodGet, base+"/compare/"+url.PathEscape(from)+"..."+url.PathEscape(head), nil, &cmp); err != nil {
		return nil, err
	}
	out := make([]domain.PushedCommit, len(cmp.Commits))
	for i, c := range cmp.Commits {
		out[i] = c.pushed()
	}
	return out, nil
}
