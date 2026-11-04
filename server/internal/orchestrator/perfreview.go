package orchestrator

import (
	"context"
	"strings"
	"time"

	"agnts/internal/domain"
)

// PerfFacts records the facts performance reviews are made of. A Store
// may implement it; without it nothing is recorded.
type PerfFacts interface {
	// RecordAgentCommits stores shas agnts made in a repository.
	RecordAgentCommits(ctx context.Context, repoID, ticketID int64, shas []string) error
	// AgentCommitsAmong returns which of shas agnts made.
	AgentCommitsAmong(ctx context.Context, repoID int64, shas []string) (map[string]bool, error)
	// SetTrackerResolution records whether a ticket's tracker issue is
	// resolved as done (doneAt) or not (nil).
	SetTrackerResolution(ctx context.Context, source domain.TicketSource, key string, doneAt *time.Time, resolution string) error
}

// TrackerResolved implements the trackers' Resolver: it records whether a
// known ticket's issue is resolved as done, with the workspace's list of
// resolutions that are not. Delivery follows in the database.
func (o *Orchestrator) TrackerResolved(ctx context.Context, source domain.TicketSource, key string, r domain.TrackerResolution) error {
	pf, ok := o.store.(PerfFacts)
	if !ok {
		return nil
	}
	s, err := o.settings.Get(ctx)
	if err != nil {
		return err
	}
	var at *time.Time
	if r.DoneIn(source, s.PerfReview.NotDoneResolutions()) {
		now := time.Now()
		at = &now
		if r.At != nil {
			at = r.At
		}
	}
	return pf.SetTrackerResolution(ctx, source, key, at, r.Resolution)
}

// recordAgentCommits notes commits agnts made; failures are logged, never
// in the way of the run.
func (o *Orchestrator) recordAgentCommits(ctx context.Context, repoID, ticketID int64, shas ...string) {
	pf, ok := o.store.(PerfFacts)
	if !ok || len(shas) == 0 {
		return
	}
	if err := pf.RecordAgentCommits(context.WithoutCancel(ctx), repoID, ticketID, shas); err != nil {
		o.log.Warn("record agent commits", "repo_id", repoID, "err", err)
	}
}

// rewordAgentCommits rewords commits on a ticket's branch. Rewording makes
// new commits; those that replace agnts's own commits are agnts's too.
func (o *Orchestrator) rewordAgentCommits(ctx context.Context, cr CommitRewriter, repo domain.Repository, branch string, ticketID int64, msgs map[string]string) (string, error) {
	before, _ := cr.BranchCommits(ctx, repo, branch)
	head, err := cr.RewordCommits(ctx, repo, branch, msgs)
	if err != nil {
		return head, err
	}
	pf, ok := o.store.(PerfFacts)
	if !ok || len(before) == 0 {
		return head, nil
	}
	after, err := cr.BranchCommits(ctx, repo, branch)
	if err != nil || len(after) != len(before) {
		return head, nil
	}
	shas := make([]string, len(before))
	for i, c := range before {
		shas[i] = c.SHA
	}
	mine, err := pf.AgentCommitsAmong(ctx, repo.ID, shas)
	if err != nil {
		return head, nil
	}
	var made []string
	for i, c := range before { // both newest first, one for one
		if mine[strings.ToLower(c.SHA)] && after[i].SHA != c.SHA {
			made = append(made, after[i].SHA)
		}
	}
	o.recordAgentCommits(ctx, repo.ID, ticketID, made...)
	return head, nil
}
