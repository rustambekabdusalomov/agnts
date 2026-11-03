package orchestrator

import (
	"context"
	"fmt"

	"agnts/internal/domain"
)

// MergeTicketPR merges the open pull requests a done ticket opened, on the
// git host, with the workspace's merge method. A pull request whose head
// moved since agnts pushed it is refused: someone pushed commits nobody
// approved here. CI is not checked; the caller shows its state.
func (o *Orchestrator) MergeTicketPR(ctx context.Context, key string, origin domain.Origin) (domain.Ticket, error) {
	t, err := o.store.TicketByKey(ctx, key)
	if err != nil {
		return t, err
	}
	if t.State != domain.StateDone || !t.AnyPR() {
		return t, invalid("%s has no pull request to merge (it is %s)", t.Key, t.State)
	}
	if t.MergedAt != nil {
		return t, invalid("%s is already merged", t.Key)
	}
	rh, ok := o.host.(ReviewHost)
	if !ok {
		return t, invalid("merging is not available on this server")
	}
	s, err := o.settings.Get(ctx)
	if err != nil {
		return t, err
	}
	method := s.PullReviews.MergeMethod
	if method == "" {
		method = "merge"
	}
	for _, r := range t.OpenedPRs() {
		if r.MergedAt != nil || r.ClosedAt != nil {
			continue
		}
		repo, err := o.store.RepositoryByID(ctx, r.RepoID)
		if err != nil {
			return t, err
		}
		n := *r.PRNumber
		pr, err := rh.PullRequest(ctx, repo, n)
		if err != nil {
			return t, fmt.Errorf("read #%d: %w", n, err)
		}
		switch {
		case pr.State == domain.PullMerged:
			if t, err = o.markRepoMerged(ctx, t, r.RepoID, origin, fmt.Sprintf("#%d was already merged on the git host", n)); err != nil {
				return t, err
			}
			continue
		case pr.State != domain.PullOpen:
			return t, invalid("#%d is closed on the git host", n)
		case r.HeadSHA != "" && pr.HeadSHA != r.HeadSHA:
			return t, invalid("not merged: new commits were pushed to #%d after agnts pushed it (%s, pushed %s); review them on the git host",
				n, shortSHA(pr.HeadSHA), shortSHA(r.HeadSHA))
		}
		if err := rh.MergePR(ctx, repo, n, pr.HeadSHA, method); err != nil {
			return t, fmt.Errorf("%w: merge #%d: %w", ErrHost, n, err)
		}
		if t, err = o.markRepoMerged(ctx, t, r.RepoID, origin, fmt.Sprintf("pull request #%d merged (%s)", n, method)); err != nil {
			return t, err
		}
	}
	return t, nil
}
