package meetings

import (
	"context"
	"errors"
	"fmt"
	"path/filepath"
	"time"

	"agnts/internal/domain"
	"agnts/internal/livekit"
)

// mediaFile is the name of a new file of a session, in the meetings
// directory: flat (no folders, which Egress would own) and named from ids.
func (s *Service) mediaFile(x domain.MeetingSession, kind domain.MediaKind, ext string) string {
	return fmt.Sprintf("ws%d-s%d-%s-%d.%s", x.WorkspaceID, x.ID, kind, s.now().UnixNano(), ext)
}

// StartRecording records the call as video.
func (s *Service) StartRecording(c InCall) error {
	if !c.Rights.Record {
		return forbidden("only the hosts can record")
	}
	if !s.RecordingReady() {
		return unavailable("recording needs LiveKit Egress")
	}
	if !s.settings(c.ctx).AllowRecording {
		return forbidden("recording is turned off for this workspace (Settings → Meetings)")
	}
	if c.Session.Recording {
		return nil
	}
	by := c.Seat.Person.UserID
	return s.startRecording(c.ctx, c.Meeting, c.Session, &by)
}

func (s *Service) startRecording(ctx context.Context, m domain.Meeting, x domain.MeetingSession, by *int64) error {
	n, err := s.d.Store.ActiveRecordings(domain.System(ctx))
	if err != nil {
		return err
	}
	if n >= s.cfg.MaxRecordings {
		return fmt.Errorf("%w: the server is recording as many calls as it can; try again later", ErrTooMany)
	}
	if n, err := s.d.Store.ActiveRecordings(ctx); err != nil || n > 0 {
		if err != nil {
			return err
		}
		return fmt.Errorf("%w: another call of this workspace is being recorded", ErrTooMany)
	}
	file := s.mediaFile(x, domain.MediaRecording, "mp4")
	eg, err := s.d.LiveKit.StartRoomRecording(ctx, livekit.RoomRecording{Room: x.Room, Layout: "speaker", FileType: "MP4",
		Path: filepath.Join(s.cfg.EgressDir, file)})
	if err != nil {
		return fmt.Errorf("start recording: %w", err)
	}
	if _, err := s.d.Store.CreateMedia(ctx, domain.MeetingMedia{SessionID: x.ID, Kind: domain.MediaRecording, EgressID: eg.EgressID, File: file,
		StartedBy: by}); err != nil {
		_, _ = s.d.LiveKit.StopEgress(context.WithoutCancel(ctx), eg.EgressID)
		return err
	}
	s.roomChanged(ctx, m, x)
	return nil
}

// StopRecording stops the call's video recording.
func (s *Service) StopRecording(c InCall) error {
	if !c.Rights.Record {
		return forbidden("only the hosts can stop the recording")
	}
	s.stopEgress(c.ctx, c.Session, domain.MediaRecording)
	s.roomChanged(c.ctx, c.Meeting, c.Session)
	return nil
}

// StartNotes has agnts take notes: the call's audio is recorded and, when
// the call ends, Muse hears it and writes the notes.
func (s *Service) StartNotes(c InCall) error {
	if !c.Rights.Record {
		return forbidden("only the hosts can turn notes on")
	}
	if !s.NotesReady() {
		return unavailable("notes need LiveKit Egress and Muse")
	}
	by := c.Seat.Person.UserID
	if by == 0 && c.Meeting.HostID != nil {
		by = *c.Meeting.HostID
	}
	return s.startNotes(c.ctx, c.Meeting, c.Session, by)
}

func (s *Service) startNotes(ctx context.Context, m domain.Meeting, x domain.MeetingSession, by int64) error {
	if err := s.d.Store.SetNotes(ctx, x.ID, true, by); err != nil {
		return err
	}
	x.NotesOn = true
	if s.cfg.NotesAudio == NotesPerSpeaker {
		ps, err := s.d.LiveKit.ListParticipants(ctx, x.Room)
		if err != nil {
			return err
		}
		for _, p := range ps {
			for _, t := range p.Tracks {
				if t.IsMicrophone() {
					s.recordMicrophone(ctx, x, p.Identity, t.SID)
				}
			}
		}
	} else if err := s.recordMixed(ctx, x); err != nil {
		_ = s.d.Store.SetNotes(context.WithoutCancel(ctx), x.ID, false, by)
		return err
	}
	s.roomChanged(ctx, m, x)
	return nil
}

// recordMixed records everyone's audio in one file, unless it is being
// recorded already.
func (s *Service) recordMixed(ctx context.Context, x domain.MeetingSession) error {
	ms, err := s.d.Store.SessionMedia(ctx, x.ID, domain.MediaAudioMixed)
	if err != nil {
		return err
	}
	for _, m := range ms {
		if m.Status == domain.MediaActive {
			return nil
		}
	}
	file := s.mediaFile(x, domain.MediaAudioMixed, "ogg")
	eg, err := s.d.LiveKit.StartRoomRecording(ctx, livekit.RoomRecording{Room: x.Room, AudioOnly: true, FileType: "OGG",
		Path: filepath.Join(s.cfg.EgressDir, file)})
	if err != nil {
		return fmt.Errorf("record the audio: %w", err)
	}
	_, err = s.d.Store.CreateMedia(ctx, domain.MeetingMedia{SessionID: x.ID, Kind: domain.MediaAudioMixed, EgressID: eg.EgressID, File: file})
	return err
}

// recordMicrophone records one microphone track for notes per speaker.
func (s *Service) recordMicrophone(ctx context.Context, x domain.MeetingSession, identity, trackSID string) {
	ms, err := s.d.Store.SessionMedia(ctx, x.ID, domain.MediaAudio)
	if err != nil {
		return
	}
	for _, m := range ms {
		if m.Identity == identity && m.Status == domain.MediaActive {
			return
		}
	}
	file := s.mediaFile(x, domain.MediaAudio, "ogg")
	eg, err := s.d.LiveKit.StartTrackRecording(ctx, x.Room, trackSID, filepath.Join(s.cfg.EgressDir, file))
	if err != nil {
		s.d.Log.Warn("record a microphone", "room", x.Room, "identity", identity, "err", err)
		return
	}
	if _, err := s.d.Store.CreateMedia(ctx, domain.MeetingMedia{SessionID: x.ID, Kind: domain.MediaAudio, EgressID: eg.EgressID, Identity: identity, File: file}); err != nil {
		s.d.Log.Warn("record a microphone", "room", x.Room, "identity", identity, "err", err)
	}
}

// StopNotes stops taking notes; what was recorded is still heard when the
// call ends.
func (s *Service) StopNotes(c InCall) error {
	if !c.Rights.Record {
		return forbidden("only the hosts can turn notes off")
	}
	if err := s.d.Store.SetNotes(c.ctx, c.Session.ID, false, 0); err != nil {
		return err
	}
	s.stopEgress(c.ctx, c.Session, domain.MediaAudioMixed)
	s.stopEgress(c.ctx, c.Session, domain.MediaAudio)
	s.roomChanged(c.ctx, c.Meeting, c.Session)
	return nil
}

// stopEgress stops the session's running files of a kind ("" for all).
// They end with egress_ended.
func (s *Service) stopEgress(ctx context.Context, x domain.MeetingSession, kind domain.MediaKind) {
	var kinds []domain.MediaKind
	if kind != "" {
		kinds = append(kinds, kind)
	}
	ms, err := s.d.Store.SessionMedia(ctx, x.ID, kinds...)
	if err != nil {
		return
	}
	for _, m := range ms {
		if m.Status != domain.MediaActive {
			continue
		}
		eg, err := s.d.LiveKit.StopEgress(ctx, m.EgressID)
		switch {
		case err == nil:
			if done, _ := eg.Done(); done {
				s.finishEgress(ctx, eg)
			}
		case errors.Is(err, livekit.ErrNotFound):
			_, _ = s.d.Store.FinishMedia(ctx, m.EgressID, domain.MediaFailed, 0, s.now(), "the recorder lost it")
		default:
			// Stopping an egress that already ended is an error too: the
			// sweep asks Egress how it ended.
			s.d.Log.Info("stop egress", "egress", m.EgressID, "err", err)
		}
	}
}

// finishEgress records how an egress ended: ready with its size, or
// failed.
func (s *Service) finishEgress(ctx context.Context, eg livekit.Egress) {
	done, failed := eg.Done()
	if !done {
		return
	}
	ended := s.now()
	if eg.EndedAt > 0 {
		ended = time.Unix(0, int64(eg.EndedAt))
	}
	st, msg := domain.MediaReady, ""
	var size int64
	if f, ok := eg.Result(); ok {
		size = int64(f.Size)
	}
	switch {
	case failed:
		st, msg = domain.MediaFailed, eg.Error
	case size == 0:
		st, msg = domain.MediaFailed, "the recording is empty"
	}
	md, err := s.d.Store.FinishMedia(ctx, eg.EgressID, st, size, ended, msg)
	if err != nil {
		if !errors.Is(err, domain.ErrNotFound) {
			s.d.Log.Warn("finish egress", "egress", eg.EgressID, "err", err)
		}
		return
	}
	if failed {
		s.d.Log.Warn("a meeting recording failed", "egress", eg.EgressID, "kind", md.Kind, "error", msg)
	}
	// The banners follow: a recording that stopped or failed is no longer
	// shown as running.
	if x, err := s.d.Store.Session(ctx, md.SessionID); err == nil && x.EndedAt == nil {
		if m, err := s.d.Store.Meeting(ctx, x.MeetingID); err == nil {
			s.roomChanged(ctx, m, x)
		}
	}
}

// File is a meeting file to stream or download.
type File struct {
	Path  string
	Name  string // to save as
	Media domain.MeetingMedia
}

// Recording returns a session's video recording, for people who may read
// the session.
func (s *Service) Recording(ctx context.Context, c Caller, meetingID, sessionID, mediaID int64) (File, error) {
	m, x, err := s.sessionOf(ctx, c, meetingID, sessionID)
	if err != nil {
		return File{}, err
	}
	md, err := s.d.Store.Media(ctx, mediaID)
	if err != nil || md.SessionID != x.ID || md.Kind != domain.MediaRecording {
		return File{}, domain.ErrNotFound
	}
	if md.Status != domain.MediaReady || s.cfg.MediaDir == "" || filepath.Base(md.File) != md.File {
		return File{}, domain.ErrNotFound
	}
	name := domain.DownloadName(titleOf(m), m.ID, int(md.ID), "mp4")
	return File{Path: filepath.Join(s.cfg.MediaDir, md.File), Name: name, Media: md}, nil
}

// DeleteRecording deletes a recording at once (the meeting's host or the
// workspace's owner).
func (s *Service) DeleteRecording(ctx context.Context, c Caller, meetingID, sessionID, mediaID int64) error {
	m, x, err := s.sessionOf(ctx, c, meetingID, sessionID)
	if err != nil {
		return err
	}
	if c.Role != domain.RoleOwner && !m.IsHost(c.UserID) {
		return forbidden("only the host or the workspace's owner can delete a recording")
	}
	md, err := s.d.Store.Media(ctx, mediaID)
	if err != nil || md.SessionID != x.ID || md.Kind != domain.MediaRecording {
		return domain.ErrNotFound
	}
	if md.Status == domain.MediaActive {
		return invalid("stop the recording first")
	}
	s.removeFile(md.File)
	return s.d.Store.SetMediaStatus(ctx, md.ID, domain.MediaDeleted)
}
