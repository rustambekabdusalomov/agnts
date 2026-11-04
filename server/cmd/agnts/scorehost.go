package main

import (
	"context"

	"agnts/internal/domain"
	"agnts/internal/vcs"
)

// scoreHost reads performance review diffs from the git hosts.
type scoreHost struct{ m *vcs.Multi }

// PullFiles implements orchestrator.ScoreHost.
func (h scoreHost) PullFiles(ctx context.Context, repo domain.Repository, number int) ([]domain.FileChange, error) {
	return h.m.PullFiles(ctx, repo, number)
}

// CommitFiles implements orchestrator.ScoreHost: a commit's files with
// their patches.
func (h scoreHost) CommitFiles(ctx context.Context, repo domain.Repository, sha string) ([]domain.FileChange, error) {
	d, err := h.m.CommitDetail(ctx, repo, sha)
	if err != nil {
		return nil, err
	}
	return d.Files, nil
}
