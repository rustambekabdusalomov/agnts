package ciwatch

import (
	"context"
	"time"

	"agnts/internal/domain"
)

// pollRuns is how many of the newest runs a poll reads per repository.
const pollRuns = 20

// Poll reads the newest finished runs of every watched repository and of
// the repositories with an open agnts pull request, and processes the ones
// not seen yet. It covers repositories without a webhook; with one, the
// runs are already processed and skipped. A watch's first poll only
// records where it starts: history is not triaged.
func (s *Service) Poll(ctx context.Context) error {
	watches, err := s.store.EnabledCIWatches(ctx)
	if err != nil {
		return err
	}
	byRepo := map[int64]*domain.CIWatch{}
	for i := range watches {
		byRepo[watches[i].RepoID] = &watches[i]
	}
	// Repositories with agnts pull requests waiting, for red-check feedback.
	if open, err := s.tickets.UnmergedPRs(ctx, 50); err == nil {
		for _, t := range open {
			if t.RepoID != nil && byRepo[*t.RepoID] == nil {
				byRepo[*t.RepoID] = nil
			}
		}
	}
	for repoID, w := range byRepo {
		if err := ctx.Err(); err != nil {
			return err
		}
		repo, err := s.tickets.RepositoryByID(ctx, repoID)
		if err != nil || repo.ArchivedAt != nil {
			continue
		}
		runs, err := s.host.CIRuns(ctx, repo, pollRuns)
		if err != nil {
			s.log.Debug("ci poll", "repo", repo.Name, "err", err)
			continue
		}
		var newest int64
		for _, r := range runs {
			newest = max(newest, r.RunID)
		}
		first := w != nil && w.LastPolledRun == 0
		for i := len(runs) - 1; i >= 0; i-- { // oldest first
			r := runs[i]
			if first || time.Since(r.Finished) > 24*time.Hour {
				continue
			}
			if w != nil && r.RunID < w.LastPolledRun {
				continue
			}
			if !s.claim(r) {
				continue
			}
			if err := s.Process(ctx, r); err != nil {
				s.log.Warn("ci poll run", "repo", repo.Name, "run", r.RunID, "err", err)
			}
		}
		if w != nil && newest > w.LastPolledRun {
			w.LastPolledRun = newest
			if _, err := s.store.SaveCIWatch(ctx, *w); err != nil {
				s.log.Warn("ci poll save", "repo", repo.Name, "err", err)
			}
		}
	}
	return nil
}

// Tick is the periodic work of one workspace: poll, follow tickets, and
// drop old log samples.
func (s *Service) Tick(ctx context.Context) {
	if err := s.Poll(ctx); err != nil && ctx.Err() == nil {
		s.log.Warn("ci poll", "err", err)
	}
	if err := s.Sync(ctx); err != nil && ctx.Err() == nil {
		s.log.Warn("ci sync", "err", err)
	}
	if _, err := s.store.PruneCISamples(ctx); err != nil && ctx.Err() == nil {
		s.log.Warn("ci prune", "err", err)
	}
}
