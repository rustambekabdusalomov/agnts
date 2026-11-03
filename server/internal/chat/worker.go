package chat

import (
	"context"
	"encoding/json"
	"fmt"
	"time"

	"agnts/internal/domain"
	"agnts/internal/orchestrator"
	"agnts/internal/store/postgres"
)

// maxAttempts is how often a job is tried before it is dropped.
const maxAttempts = 3

// jobWorkers is how many jobs run at once: links stay quick while a code
// question reads a repository.
const jobWorkers = 4

// Run turns events into cards and does the queued model work, until ctx
// ends. Call Wake on every new event row.
func (s *Service) Run(ctx context.Context) {
	ctx = domain.System(ctx)
	if err := s.Store.RequeueStale(ctx, 10*time.Minute); err != nil {
		s.Log.Warn("chat: requeue", "err", err)
	}
	cur, err := s.Events.Cursor(ctx, cursorName)
	if err != nil {
		s.Log.Error("chat: read cursor", "err", err)
		return
	}
	if cur < 0 { // first start: no cards for history
		if cur, err = s.Events.MaxEventID(ctx); err != nil {
			s.Log.Error("chat: start", "err", err)
			return
		}
		_ = s.Events.SetCursor(ctx, cursorName, cur)
	}
	jobs := make(chan struct{}, jobWorkers)
	for range jobWorkers {
		go s.jobLoop(ctx, jobs)
	}
	tick := time.NewTicker(5 * time.Second)
	defer tick.Stop()
	ci := time.NewTicker(45 * time.Second)
	defer ci.Stop()
	for {
		cur = s.drain(ctx, cur)
		for range jobWorkers {
			select {
			case jobs <- struct{}{}:
			default:
			}
		}
		select {
		case <-ctx.Done():
			return
		case <-s.wake:
		case <-tick.C:
		case <-ci.C:
			s.refreshAllChecks(ctx)
		}
	}
}

// drain handles the events after cur and returns the new cursor.
func (s *Service) drain(ctx context.Context, cur int64) int64 {
	for {
		evs, err := s.Events.Events(ctx, orchestrator.EventFilter{AfterID: cur, Limit: 200})
		if err != nil {
			if ctx.Err() == nil {
				s.Log.Warn("chat: read events", "err", err)
			}
			return cur
		}
		for _, e := range evs {
			s.onEvent(ctx, e)
			cur = e.ID
		}
		if len(evs) > 0 {
			if err := s.Events.SetCursor(ctx, cursorName, cur); err != nil {
				s.Log.Warn("chat: save cursor", "err", err)
			}
		}
		if len(evs) < 200 {
			return cur
		}
	}
}

// jobLoop takes jobs while there are any, each time it is poked.
func (s *Service) jobLoop(ctx context.Context, poke <-chan struct{}) {
	for {
		select {
		case <-ctx.Done():
			return
		case <-poke:
		}
		for ctx.Err() == nil {
			j, ok, err := s.Store.TakeJob(ctx)
			if err != nil {
				s.Log.Warn("chat: take job", "err", err)
				break
			}
			if !ok {
				break
			}
			s.runJob(ctx, j)
		}
	}
}

func (s *Service) runJob(ctx context.Context, j postgres.ChatJob) {
	jctx := domain.WithWorkspace(ctx, j.WorkspaceID)
	if j.UserID > 0 {
		jctx = domain.WithActor(jctx, domain.Actor{UserID: j.UserID})
	}
	timeout := 3 * time.Minute
	if j.Kind == postgres.ChatJobCodeAnswer {
		timeout = 6 * time.Minute
	}
	jctx, cancel := context.WithTimeout(jctx, timeout)
	defer cancel()
	start := time.Now()
	var err error
	func() {
		defer func() {
			if r := recover(); r != nil {
				err = fmt.Errorf("panic: %v", r)
			}
		}()
		switch j.Kind {
		case postgres.ChatJobLink:
			err = s.link(jctx, j)
		case postgres.ChatJobAnswer:
			err = s.answer(jctx, j)
		case postgres.ChatJobCodeAnswer:
			err = s.codeAnswer(jctx, j)
		case postgres.ChatJobTicket:
			err = s.draft(jctx, j)
		default:
			err = fmt.Errorf("unknown job %q", j.Kind)
		}
	}()
	if err != nil {
		s.Log.Warn("chat: job", "job", j.ID, "kind", j.Kind, "attempt", j.Attempts, "err", err)
		if j.Attempts >= maxAttempts {
			s.gaveUp(jctx, j, err)
		}
	} else {
		s.Log.Debug("chat: job done", "job", j.ID, "kind", j.Kind, "ms", time.Since(start).Milliseconds())
	}
	if ferr := s.Store.FinishJob(domain.WithWorkspace(ctx, j.WorkspaceID), j, err, maxAttempts); ferr != nil {
		s.Log.Warn("chat: finish job", "job", j.ID, "err", ferr)
	}
}

// gaveUp tells the asker when a question or draft could not be done.
func (s *Service) gaveUp(ctx context.Context, j postgres.ChatJob, err error) {
	if j.Kind != postgres.ChatJobAnswer && j.Kind != postgres.ChatJobTicket {
		return
	}
	q, qerr := s.Store.Message(context.WithoutCancel(ctx), j.MessageID)
	if qerr != nil {
		return
	}
	what := "answer that"
	if j.Kind == postgres.ChatJobTicket {
		what = "draft a ticket from this"
	}
	_, _ = s.reply(context.WithoutCancel(ctx), q, "I could not "+what+": "+clip(userError(err), 300), nil)
}

// refreshAllChecks updates CI on every workspace's open PR cards.
func (s *Service) refreshAllChecks(ctx context.Context) {
	if s.Checks == nil {
		return
	}
	ids, err := s.Store.OpenPRWorkspaces(ctx)
	if err != nil {
		return
	}
	for _, ws := range ids {
		_ = s.refreshChecks(domain.WithWorkspace(ctx, ws), "")
	}
}

// resultSummary is the summary agnts wrote of its change.
func resultSummary(r *domain.Result) string {
	var sum orchestrator.Summary
	if json.Unmarshal(r.Summary, &sum) == nil && sum.Summary != "" {
		return sum.Summary
	}
	if r.Report != "" {
		return firstLines(r.Report, 3)
	}
	return ""
}
