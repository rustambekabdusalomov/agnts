package github

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

type ghUser struct {
	Login string `json:"login"`
}

type ghPull struct {
	Number  int    `json:"number"`
	HTMLURL string `json:"html_url"`
	Title   string `json:"title"`
	Body    string `json:"body"`
	State   string `json:"state"`
	Draft   bool   `json:"draft"`
	Merged  bool   `json:"merged"`
	User    ghUser `json:"user"`
	Head    struct {
		Ref string `json:"ref"`
		SHA string `json:"sha"`
	} `json:"head"`
	Base struct {
		Ref string `json:"ref"`
	} `json:"base"`
	MergedAt           *time.Time `json:"merged_at"`
	Assignees          []ghUser   `json:"assignees"`
	RequestedReviewers []ghUser   `json:"requested_reviewers"`
	Additions          int        `json:"additions"`
	Deletions          int        `json:"deletions"`
	UpdatedAt          time.Time  `json:"updated_at"`
}

func (p ghPull) domain(login, why string) domain.PullRequest {
	state := domain.PullOpen
	switch {
	case p.Merged || p.MergedAt != nil:
		state = domain.PullMerged
	case p.State == "closed":
		state = domain.PullClosed
	}
	return domain.PullRequest{
		Number: p.Number, URL: p.HTMLURL, Title: p.Title, Body: p.Body, Author: p.User.Login,
		HeadRef: p.Head.Ref, HeadSHA: p.Head.SHA, BaseRef: p.Base.Ref, FetchRef: "refs/pull/" + strconv.Itoa(p.Number) + "/head",
		Draft: p.Draft, State: state, Login: login, Why: why, Additions: p.Additions, Deletions: p.Deletions, UpdatedAt: p.UpdatedAt,
	}
}

func has(us []ghUser, login string) bool {
	return slices.ContainsFunc(us, func(u ghUser) bool { return strings.EqualFold(u.Login, login) })
}

func pullsPath(repo domain.Repository) (string, error) {
	owner, name, err := OwnerRepo(repo.CloneURL)
	if err != nil {
		return "", err
	}
	return "/repos/" + url.PathEscape(owner) + "/" + url.PathEscape(name) + "/pulls", nil
}

// ReviewQueue returns the open pull requests of repo assigned to the
// token's user or, with requested, waiting for their review. With all,
// every other open pull request comes too, their own included (else left
// out).
func (h *Host) ReviewQueue(ctx context.Context, repo domain.Repository, requested, all bool) ([]domain.PullRequest, error) {
	base, err := pullsPath(repo)
	if err != nil {
		return nil, err
	}
	login, err := h.User(ctx)
	if err != nil {
		return nil, err
	}
	var out []domain.PullRequest
	for page := 1; page <= 5; page++ {
		var batch []ghPull
		q := url.Values{"state": {"open"}, "per_page": {"100"}, "page": {strconv.Itoa(page)}, "sort": {"updated"}, "direction": {"desc"}}
		if _, err := h.call(ctx, http.MethodGet, base+"?"+q.Encode(), nil, &batch); err != nil {
			return nil, err
		}
		for _, p := range batch {
			if strings.EqualFold(p.User.Login, login) {
				if all {
					out = append(out, p.domain(login, domain.PullOwn))
				}
				continue
			}
			switch {
			case has(p.Assignees, login):
				out = append(out, p.domain(login, domain.PullAssigned))
			case requested && has(p.RequestedReviewers, login):
				out = append(out, p.domain(login, domain.PullReviewRequested))
			case all:
				out = append(out, p.domain(login, domain.PullOpenRepo))
			}
		}
		if len(batch) < 100 {
			break
		}
	}
	return out, nil
}

// PullRequest returns one pull request as it stands now.
func (h *Host) PullRequest(ctx context.Context, repo domain.Repository, number int) (domain.PullRequest, error) {
	base, err := pullsPath(repo)
	if err != nil {
		return domain.PullRequest{}, err
	}
	var p ghPull
	if _, err := h.call(ctx, http.MethodGet, base+"/"+strconv.Itoa(number), nil, &p); err != nil {
		return domain.PullRequest{}, err
	}
	login, _ := h.User(ctx)
	why := domain.PullOpenRepo
	switch {
	case strings.EqualFold(p.User.Login, login):
		why = domain.PullOwn
	case has(p.Assignees, login):
		why = domain.PullAssigned
	case has(p.RequestedReviewers, login):
		why = domain.PullReviewRequested
	}
	return p.domain(login, why), nil
}

// MergePR merges a pull request whose head is sha; GitHub refuses when the
// head moved, or the branch protection rules are not met.
func (h *Host) MergePR(ctx context.Context, repo domain.Repository, number int, sha, method string) error {
	base, err := pullsPath(repo)
	if err != nil {
		return err
	}
	status, err := h.call(ctx, http.MethodPut, base+"/"+strconv.Itoa(number)+"/merge", map[string]any{"sha": sha, "merge_method": method}, nil)
	switch status {
	case http.StatusConflict:
		return fmt.Errorf("the head of the pull request moved: %w", err)
	case http.StatusMethodNotAllowed:
		return fmt.Errorf("GitHub cannot merge it yet (checks, reviews or branch protection; or %s merges are off for the repository): %w", method, err)
	}
	return needs(status, err, "Contents: Read and write")
}

// CommentPR posts a comment on a pull request (pull requests are issues to
// the comments API).
func (h *Host) CommentPR(ctx context.Context, repo domain.Repository, number int, body string) error {
	owner, name, err := OwnerRepo(repo.CloneURL)
	if err != nil {
		return err
	}
	path := "/repos/" + url.PathEscape(owner) + "/" + url.PathEscape(name) + "/issues/" + strconv.Itoa(number) + "/comments"
	status, err := h.call(ctx, http.MethodPost, path, map[string]any{"body": body}, nil)
	return needs(status, err, "Pull requests: Read and write")
}
