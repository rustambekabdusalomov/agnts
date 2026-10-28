package meetings

import (
	"context"
	"errors"
	"time"

	"agnts/internal/domain"
	"agnts/internal/livekit"
)

// ErrBadWebhook means a webhook was not signed by our LiveKit server.
var ErrBadWebhook = livekit.ErrBadWebhook

// HandleWebhook checks a webhook's signature and handles its event.
func (s *Service) HandleWebhook(ctx context.Context, auth string, body []byte) error {
	e, err := s.cfg.Keys.ReadWebhook(auth, body, s.now())
	if err != nil {
		return err
	}
	return s.Webhook(ctx, e)
}

// Webhook handles one event LiveKit sent. Events of rooms that are not
// agnts's are ignored; each event is handled once.
func (s *Service) Webhook(ctx context.Context, e livekit.Event) error {
	ws, _, sid, ok := domain.ParseMeetingRoomName(e.RoomName())
	if !ok {
		return nil
	}
	first, err := s.d.Store.FirstSeen(domain.System(ctx), e.ID)
	if err != nil || !first {
		return err
	}
	ctx = domain.WithWorkspace(ctx, ws)
	x, err := s.d.Store.Session(ctx, sid)
	if errors.Is(err, domain.ErrNotFound) {
		return nil
	}
	if err != nil {
		return err
	}
	at := e.At(s.now())
	switch e.Event {
	case livekit.EventRoomFinished:
		m, err := s.d.Store.Meeting(ctx, x.MeetingID)
		if err != nil {
			return err
		}
		s.sessionEnded(ctx, m, x, at)
	case livekit.EventParticipantJoined:
		p, _, ok := personOf(e.Participant)
		if !ok {
			return nil // a recorder
		}
		joined := at
		if e.Participant.JoinedAt > 0 {
			joined = time.Unix(int64(e.Participant.JoinedAt), 0)
		}
		return s.d.Store.ParticipantJoined(ctx, x.ID, e.Participant.Identity, p, e.Participant.Name, joined)
	case livekit.EventParticipantLeft:
		p, _, ok := personOf(e.Participant)
		if !ok {
			return nil
		}
		var joined time.Time
		if e.Participant.JoinedAt > 0 {
			joined = time.Unix(int64(e.Participant.JoinedAt), 0)
		}
		return s.d.Store.ParticipantLeft(ctx, x.ID, e.Participant.Identity, p, e.Participant.Name, joined, at)
	case livekit.EventTrackPublished:
		if s.cfg.NotesAudio != NotesPerSpeaker || !x.NotesOn || x.EndedAt != nil || e.Track == nil || !e.Track.IsMicrophone() {
			return nil
		}
		if _, _, ok := personOf(e.Participant); ok {
			s.recordMicrophone(ctx, x, e.Participant.Identity, e.Track.SID)
		}
	case livekit.EventEgressEnded:
		if e.Egress != nil {
			s.finishEgress(ctx, *e.Egress)
		}
	}
	return nil
}

// personOf reads the person behind a participant from its identity.
func personOf(p *livekit.Participant) (domain.Person, string, bool) {
	if p == nil {
		return domain.Person{}, "", false
	}
	return domain.ParseMeetingIdentity(p.Identity)
}

// sessionEnded closes a session once: attendance, knocks and recordings
// end with it, and its notes are queued when it had them.
func (s *Service) sessionEnded(ctx context.Context, m domain.Meeting, x domain.MeetingSession, at time.Time) {
	ended, err := s.d.Store.EndSession(ctx, x.ID, at)
	if err != nil {
		s.d.Log.Error("end meeting session", "session", x.ID, "err", err)
		return
	}
	if !ended {
		return
	}
	s.stopEgress(ctx, x, "")
	s.d.Log.Info("meeting session ended", "workspace", x.WorkspaceID, "meeting", m.ID, "session", x.ID)
	s.publishChanged(ctx, x.WorkspaceID)
	s.WakeNotes()
}

// Sweep keeps the database in step with LiveKit: it closes sessions
// nobody connected to, sessions whose room is gone (a lost room_finished)
// and connections LiveKit no longer has (a lost participant_left), and
// asks Egress how recordings that should have ended did. Call it every
// minute in the system scope.
func (s *Service) Sweep(ctx context.Context) {
	if !s.Ready() {
		return
	}
	live, err := s.d.Store.LiveSessions(ctx)
	if err != nil {
		s.d.Log.Warn("sweep meetings", "err", err)
		return
	}
	rooms := map[string]bool{}
	if len(live) > 0 {
		names := make([]string, len(live))
		for i, x := range live {
			names[i] = x.Room
		}
		got, err := s.d.LiveKit.ListRooms(ctx, names...)
		if err != nil {
			s.d.Log.Warn("sweep meetings: list rooms", "err", err)
			return
		}
		for _, r := range got {
			rooms[r.Name] = true
		}
	}
	now := s.now()
	for _, l := range live {
		wctx := domain.WithWorkspace(ctx, l.WorkspaceID)
		x, err := s.d.Store.Session(wctx, l.ID)
		if err != nil {
			continue
		}
		m, err := s.d.Store.Meeting(wctx, l.MeetingID)
		if err != nil {
			continue
		}
		switch {
		case l.ConnectedAt == nil && now.Sub(l.StartedAt) > domain.MeetingUnconnected:
			// Someone opened the lobby and left; the room closes too.
			s.end(wctx, m, x)
		case !rooms[l.Room] && now.Sub(l.StartedAt) > time.Minute:
			s.sessionEnded(wctx, m, x, now)
		case rooms[l.Room]:
			ps, err := s.d.LiveKit.ListParticipants(wctx, l.Room)
			if err != nil {
				continue
			}
			ids := make([]string, 0, len(ps))
			for _, p := range ps {
				ids = append(ids, p.Identity)
			}
			if _, err := s.d.Store.SyncPresent(wctx, l.ID, ids, now); err != nil {
				s.d.Log.Warn("sync attendance", "session", l.ID, "err", err)
			}
		}
	}
	if stale, err := s.d.Store.StaleActiveMedia(ctx, now.Add(-10*time.Minute)); err == nil {
		for _, md := range stale {
			s.reconcileEgress(ctx, md)
		}
	}
	if err := s.d.Store.PruneEvents(ctx); err != nil {
		s.d.Log.Warn("prune livekit events", "err", err)
	}
}

// reconcileEgress finds how a recording whose end was not heard ended.
func (s *Service) reconcileEgress(ctx context.Context, md domain.MeetingMedia) {
	ref, err := s.d.Store.SessionWorkspace(ctx, md.SessionID)
	if err != nil {
		return
	}
	wctx := domain.WithWorkspace(ctx, ref.WorkspaceID)
	egs, err := s.d.LiveKit.ListEgress(wctx, ref.Room, false)
	if err != nil {
		return
	}
	for _, eg := range egs {
		if eg.EgressID == md.EgressID {
			if done, _ := eg.Done(); done {
				s.finishEgress(wctx, eg)
				return
			}
			if _, err := s.d.LiveKit.StopEgress(wctx, eg.EgressID); err != nil {
				s.d.Log.Info("stop a lost egress", "egress", eg.EgressID, "err", err)
			}
			return
		}
	}
	_, _ = s.d.Store.FinishMedia(wctx, md.EgressID, domain.MediaFailed, 0, s.now(), "the recorder lost it")
}
