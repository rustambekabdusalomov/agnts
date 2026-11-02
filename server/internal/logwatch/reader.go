package logwatch

import (
	"context"
	"time"

	"agnts/internal/domain"
	"agnts/internal/logsource"
	"agnts/internal/store/postgres"
)

// Reader limits.
const (
	pullLimit     = 5000      // entries per service per pull
	minuteCap     = 50000     // entries per source per minute, then "behind"
	catchUpWindow = time.Hour // after a longer outage the cursor jumps
	reloadEvery   = 5 * time.Minute
	backoffMin    = 15 * time.Second
	backoffMax    = 5 * time.Minute
)

// Wake makes the supervisor reload the sources now (one was saved).
func (s *Service) Wake() {
	select {
	case s.wake <- struct{}{}:
	default:
	}
}

// Run supervises one reading loop per enabled pulling source of every
// workspace until ctx ends. ctx is a system context.
func (s *Service) Run(ctx context.Context) {
	t := time.NewTicker(reloadEvery)
	defer t.Stop()
	for {
		s.reload(ctx)
		select {
		case <-ctx.Done():
			s.mu.Lock()
			for id, stop := range s.loops {
				stop()
				delete(s.loops, id)
			}
			s.mu.Unlock()
			return
		case <-t.C:
		case <-s.wake:
		}
	}
}

// reload starts loops for new sources and stops the ones that went.
func (s *Service) reload(ctx context.Context) {
	srcs, err := s.store.PullSources(domain.System(ctx))
	if err != nil {
		if ctx.Err() == nil {
			s.log.Warn("log sources", "err", err)
		}
		return
	}
	want := map[int64]domain.LogSource{}
	for _, x := range srcs {
		want[x.ID] = x
	}
	s.mu.Lock()
	defer s.mu.Unlock()
	for id, stop := range s.loops {
		if _, ok := want[id]; !ok {
			stop()
			delete(s.loops, id)
		}
	}
	for id, x := range want {
		if _, ok := s.loops[id]; ok {
			continue
		}
		lctx, stop := context.WithCancel(domain.WithWorkspace(ctx, x.WorkspaceID))
		s.loops[id] = stop
		go s.loop(lctx, id)
	}
}

// loop reads one source until its context ends or its credentials are
// refused.
func (s *Service) loop(ctx context.Context, id int64) {
	backoff := backoffMin
	var minute time.Time
	read := 0
	for {
		src, err := s.store.LogSource(ctx, id, true)
		if err != nil || !src.Enabled || src.Status == domain.LogSourceAuthFailed {
			s.forget(id)
			return
		}
		if time.Since(minute) > time.Minute {
			minute, read = time.Now(), 0
		}
		n, more, err := s.readOnce(ctx, src, read >= minuteCap)
		read += n
		wait := time.Duration(src.PollSeconds) * time.Second
		switch {
		case logsource.Unauthorized(err):
			s.forget(id)
			return
		case err != nil:
			if ctx.Err() != nil {
				return
			}
			wait, backoff = backoff, min(backoff*2, backoffMax)
		default:
			backoff = backoffMin
			if more && read < minuteCap {
				wait = 0
			}
		}
		select {
		case <-ctx.Done():
			return
		case <-time.After(wait):
		}
	}
}

func (s *Service) forget(id int64) {
	s.mu.Lock()
	if stop, ok := s.loops[id]; ok {
		stop()
		delete(s.loops, id)
	}
	s.mu.Unlock()
}

// readOnce pulls one batch, ingests it and saves the cursor. over: the
// source is over its per-minute cap, so this read only moves on.
func (s *Service) readOnce(ctx context.Context, src domain.LogSource, over bool) (int, bool, error) {
	now := s.now()
	cur := src.Cursor
	state := postgres.LogReadState{Status: domain.LogSourceOK}
	if cur.Time.IsZero() {
		// The first read starts now: agnts watches from here on.
		cur = domain.LogCursor{Time: now.Add(-time.Duration(src.PollSeconds) * time.Second)}
	} else if now.Sub(cur.Time) > catchUpWindow+logsource.Lag {
		from, to := cur.Time, now.Add(-catchUpWindow)
		state.GapFrom, state.GapTo = &from, &to
		cur = domain.LogCursor{Time: to}
	}
	st, err := s.settings.Get(ctx)
	if err != nil {
		return 0, false, err
	}
	fail := func(err error) (int, bool, error) {
		state.Status, state.LastError, state.Cursor = domain.LogSourceFailing, err.Error(), src.Cursor
		if logsource.Unauthorized(err) {
			state.Status = domain.LogSourceAuthFailed
			s.sourceEvent(ctx, src, "the credentials were refused: reading stopped until the source is saved again", true)
		}
		if serr := s.store.SaveLogRead(ctx, src.ID, state); serr != nil && ctx.Err() == nil {
			s.log.Warn("log read state", "source", src.ID, "err", serr)
		}
		return 0, false, err
	}
	c, err := s.dialer.For(src.WorkspaceID, src)
	if err != nil {
		return fail(err)
	}
	p, err := s.newPuller(src, c)
	if err != nil {
		return fail(err)
	}
	pctx, cancel := context.WithTimeout(ctx, 2*time.Minute)
	defer cancel()
	b, err := p.Pull(pctx, src.Services, logsource.DefaultFilter(st.LogWatch.Patterns), cur, pullLimit)
	if err != nil {
		return fail(err)
	}
	state.Cursor, state.NetworkID = b.Cursor, c.NetworkID
	if over {
		// Over the per-minute cap: count what is skipped, don't process it.
		state.Status, state.Dropped = domain.LogSourceBehind, int64(len(b.Entries))
	} else if _, err := s.Ingest(ctx, src, b.Entries); err != nil {
		return fail(err)
	} else if b.More {
		state.Status = domain.LogSourceBehind
	}
	state.ReadAt = &now
	if src.Status == domain.LogSourceFailing {
		s.sourceEvent(ctx, src, "reading again", false)
	}
	if err := s.store.SaveLogRead(ctx, src.ID, state); err != nil {
		return len(b.Entries), b.More, err
	}
	return len(b.Entries), b.More, nil
}

// sourceEvent records (and notifies) a change in a source's health.
func (s *Service) sourceEvent(ctx context.Context, src domain.LogSource, msg string, notify bool) {
	ev := domain.Event{Type: domain.EventLogSource, Origin: domain.OriginSystem, Level: domain.LevelWarn, Message: src.Name + ": " + msg,
		Data: map[string]any{"sourceId": src.ID, "name": src.Name, "notify": notify}}
	if err := s.tickets.AppendEvent(ctx, ev); err != nil {
		s.log.Warn("log source event", "source", src.ID, "err", err)
	}
}
