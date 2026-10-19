package orchestrator

import (
	"context"
	"fmt"
	"slices"
	"sync"

	"agnts/internal/domain"
)

// OpenPull is an open pull request on the Reviews page, with its newest
// review (nil before the first).
type OpenPull struct {
	Repo   domain.Repository
	Pull   domain.PullRequest
	Review *domain.Ticket
}

// OpenPulls is what the Reviews page lists: the open pull requests, and
// the repositories the git host did not answer for.
type OpenPulls struct {
	Pulls  []OpenPull
	Errors []string
}

// openPullsAtOnce caps the repositories asked at the same time.
const openPullsAtOnce = 4

// OpenPulls asks the git host for the open pull requests of every
// repository, as PullReviewSettings pick them (only those waiting for you,
// or all; drafts or not), most recently updated first. Nothing is
// reviewed: a review starts from the pull request's page.
func (o *Orchestrator) OpenPulls(ctx context.Context) (OpenPulls, error) {
	var out OpenPulls
	rh, err := o.pullReviewsReady()
	if err != nil {
		return out, err
	}
	s, err := o.settings.Get(ctx)
	if err != nil {
		return out, err
	}
	repos, err := o.pulls.ListRepositories(ctx)
	if err != nil {
		return out, err
	}
	repos = slices.DeleteFunc(repos, func(r domain.Repository) bool {
		return r.ArchivedAt != nil || (r.Provider != "github" && r.Provider != "gitlab")
	})
	pulls := make([][]OpenPull, len(repos))
	errs := make([]string, len(repos))
	sem := make(chan struct{}, openPullsAtOnce)
	var wg sync.WaitGroup
	for i, repo := range repos {
		wg.Add(1)
		go func() {
			defer wg.Done()
			sem <- struct{}{}
			defer func() { <-sem }()
			prs, err := rh.ReviewQueue(ctx, repo, s.PullReviews.ReviewRequested, s.PullReviews.All)
			if err != nil {
				errs[i] = fmt.Sprintf("%s: %v", repo.Name, err)
				return
			}
			latest, err := o.pulls.LatestReviews(ctx, repo.ID)
			if err != nil {
				errs[i] = fmt.Sprintf("%s: %v", repo.Name, err)
				return
			}
			for _, pr := range prs {
				pr.Clean()
				if pr.Draft && s.PullReviews.SkipDrafts {
					continue
				}
				p := OpenPull{Repo: repo, Pull: pr}
				if t, ok := latest[pr.Number]; ok {
					p.Review = &t
				}
				pulls[i] = append(pulls[i], p)
			}
		}()
	}
	wg.Wait()
	for i := range repos {
		out.Pulls = append(out.Pulls, pulls[i]...)
		if errs[i] != "" {
			out.Errors = append(out.Errors, errs[i])
		}
	}
	slices.SortStableFunc(out.Pulls, func(a, b OpenPull) int { return b.Pull.UpdatedAt.Compare(a.Pull.UpdatedAt) })
	return out, nil
}
