package vcs

import (
	"context"

	"agnts/internal/domain"
)

// MaxJobLogBytes caps how much of a job's log is read.
const MaxJobLogBytes = 2 << 20

// CIHost reads CI runs, their failed jobs and logs, re-runs failed jobs,
// and keeps one comment per pull request up to date.
type CIHost interface {
	// CIRuns returns the newest finished runs, newest first.
	CIRuns(ctx context.Context, repo domain.Repository, perPage int) ([]domain.CIRun, error)
	// FailedJobs returns the failed jobs of a run (the latest attempt).
	FailedJobs(ctx context.Context, repo domain.Repository, runID int64) ([]domain.CIJob, error)
	// JobLog returns the end of a job's log, at most MaxJobLogBytes.
	JobLog(ctx context.Context, repo domain.Repository, jobID int64) (string, error)
	// RerunFailed re-runs a run's failed jobs.
	RerunFailed(ctx context.Context, repo domain.Repository, runID int64) error
	// UpsertComment posts body on a pull request, or edits the comment id
	// when it is not empty; it returns the comment's id.
	UpsertComment(ctx context.Context, repo domain.Repository, number int, id, body string) (string, error)
}

// CIRuns implements CIHost.
func (m *Multi) CIRuns(ctx context.Context, repo domain.Repository, perPage int) ([]domain.CIRun, error) {
	p, err := m.pick(repo)
	if err != nil {
		return nil, err
	}
	return p.CIRuns(ctx, repo, perPage)
}

// FailedJobs implements CIHost.
func (m *Multi) FailedJobs(ctx context.Context, repo domain.Repository, runID int64) ([]domain.CIJob, error) {
	p, err := m.pick(repo)
	if err != nil {
		return nil, err
	}
	return p.FailedJobs(ctx, repo, runID)
}

// JobLog implements CIHost.
func (m *Multi) JobLog(ctx context.Context, repo domain.Repository, jobID int64) (string, error) {
	p, err := m.pick(repo)
	if err != nil {
		return "", err
	}
	return p.JobLog(ctx, repo, jobID)
}

// RerunFailed implements CIHost.
func (m *Multi) RerunFailed(ctx context.Context, repo domain.Repository, runID int64) error {
	p, err := m.pick(repo)
	if err != nil {
		return err
	}
	defer m.Forget(repo.ID)
	return p.RerunFailed(ctx, repo, runID)
}

// UpsertComment implements CIHost.
func (m *Multi) UpsertComment(ctx context.Context, repo domain.Repository, number int, id, body string) (string, error) {
	p, err := m.pick(repo)
	if err != nil {
		return "", err
	}
	return p.UpsertComment(ctx, repo, number, id, body)
}
