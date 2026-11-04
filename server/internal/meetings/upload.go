package meetings

import (
	"context"
	"crypto/rand"
	"encoding/hex"
	"errors"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"slices"
	"strings"
	"time"

	"agnts/internal/domain"
	"agnts/internal/store/postgres"
)

// Uploaded recordings: a host uploads a meeting held elsewhere (a video
// or audio file). It becomes an ended session of the meeting with notes
// on; the notes worker takes its sound out (SoundTaker), deletes the
// file as sent, and hears the sound like a call's. See
// plans/Meeting tasks plan.md.

// UploadTypes are the recordings a host may upload, by extension.
var UploadTypes = []string{"mp4", "mov", "m4v", "webm", "mkv", "ogg", "opus", "oga", "m4a", "mp3", "wav"}

// Upload is a recording as it arrives.
type Upload struct {
	Name      string    // the file's name, for its extension
	Body      io.Reader // read to the end, at most MaxUploadBytes
	StartedAt time.Time // when the meeting was held; zero is now
	People    []int64   // members in it
}

// ErrTooBig says the upload is over the size limit.
var ErrTooBig = errors.New("the recording is too big")

// UploadsReady reports whether recordings can be uploaded and heard.
func (s *Service) UploadsReady() bool {
	return s.cfg.MediaDir != "" && s.d.Sound != nil && s.d.Notes != nil && s.d.Hearer != nil && s.d.Hearer.CanHearMeetings()
}

// MaxUploadBytes is the largest recording a host may upload.
func (s *Service) MaxUploadBytes() int64 { return s.cfg.MaxUploadBytes }

// Upload stores an uploaded recording as a new ended session of a meeting
// and queues its notes.
func (s *Service) Upload(ctx context.Context, c Caller, meetingID int64, u Upload) (domain.MeetingSession, error) {
	if !s.UploadsReady() {
		return domain.MeetingSession{}, unavailable("uploaded recordings")
	}
	m, err := s.meeting(ctx, c, meetingID)
	if err != nil {
		return domain.MeetingSession{}, err
	}
	if !canManage(c, m) {
		return domain.MeetingSession{}, forbidden("only the meeting's hosts can upload a recording")
	}
	ext := strings.ToLower(strings.TrimPrefix(filepath.Ext(u.Name), "."))
	if !slices.Contains(UploadTypes, ext) {
		return domain.MeetingSession{}, invalid("upload a video or audio file (%s)", strings.Join(UploadTypes, ", "))
	}
	now := s.now()
	if u.StartedAt.IsZero() {
		u.StartedAt = now
	}
	if u.StartedAt.After(now.Add(time.Hour)) {
		return domain.MeetingSession{}, invalid("the meeting can't have been held in the future")
	}
	if days := s.settings(ctx).RetentionDays; days > 0 && u.StartedAt.Before(now.AddDate(0, 0, -days)) {
		return domain.MeetingSession{}, invalid("the workspace keeps transcripts for %d days: a meeting held before that would be deleted at once", days)
	}
	people := slices.Compact(slices.Sorted(slices.Values(u.People)))
	for _, p := range people {
		if role, err := s.d.Workspaces.Role(ctx, c.WorkspaceID, p); err != nil || role == "" {
			return domain.MeetingSession{}, invalid("someone picked as in the recording is not a member of this workspace")
		}
	}
	tag := make([]byte, 8)
	_, _ = rand.Read(tag)
	id := "upload-" + hex.EncodeToString(tag)
	file := fmt.Sprintf("ws%d-m%d-%s.%s", c.WorkspaceID, m.ID, id, ext)
	n, err := s.writeUpload(filepath.Join(s.cfg.MediaDir, file), u.Body)
	if err != nil {
		return domain.MeetingSession{}, err
	}
	x, err := s.d.Store.CreateUploadSession(ctx, postgres.NewUpload{MeetingID: m.ID, StartedAt: u.StartedAt, By: c.UserID, People: people,
		EgressID: id, File: file, Bytes: n})
	if err != nil {
		s.removeFile(file)
		return x, err
	}
	if err := s.d.Store.SetNotesStatus(ctx, x.ID, domain.NotesQueued, ""); err != nil {
		return x, err
	}
	s.WakeNotes()
	s.publishChanged(ctx, c.WorkspaceID)
	return s.d.Store.Session(ctx, x.ID)
}

// writeUpload copies an upload to path, at most MaxUploadBytes, and
// returns its size; a failed or too big upload leaves no file.
func (s *Service) writeUpload(path string, body io.Reader) (int64, error) {
	f, err := os.OpenFile(path, os.O_WRONLY|os.O_CREATE|os.O_EXCL, 0o600) //nolint:gosec // G304: a name agnts made, in the meetings directory
	if err != nil {
		return 0, err
	}
	n, err := io.Copy(f, io.LimitReader(body, s.cfg.MaxUploadBytes+1))
	if cerr := f.Close(); err == nil {
		err = cerr
	}
	switch {
	case err != nil:
	case n > s.cfg.MaxUploadBytes:
		err = fmt.Errorf("%w: at most %d MB", ErrTooBig, s.cfg.MaxUploadBytes>>20)
	case n == 0:
		err = invalid("the file is empty")
	}
	if err != nil {
		_ = os.Remove(path)
		return 0, err
	}
	return n, nil
}

// takeSound replaces an uploaded file by its sound, unless that was done.
func (s *Service) takeSound(ctx context.Context, md domain.MeetingMedia) (domain.MeetingMedia, error) {
	if strings.HasSuffix(md.File, soundSuffix) {
		return md, nil
	}
	if filepath.Base(md.File) != md.File {
		return md, errors.New("the upload's file name is not agnts's")
	}
	sound := strings.TrimSuffix(md.File, filepath.Ext(md.File)) + soundSuffix
	src, dst := filepath.Join(s.cfg.MediaDir, md.File), filepath.Join(s.cfg.MediaDir, sound)
	if err := s.d.Sound.TakeSound(ctx, src, dst); err != nil {
		_ = os.Remove(dst)
		return md, err
	}
	info, err := os.Stat(dst)
	if err != nil {
		return md, err
	}
	if err := s.d.Store.SetMediaFile(ctx, md.ID, sound, info.Size()); err != nil {
		_ = os.Remove(dst)
		return md, err
	}
	s.removeFile(md.File) // the picture is gone for good
	md.File, md.Bytes = sound, info.Size()
	return md, nil
}

// soundSuffix ends the name of an upload's sound.
const soundSuffix = ".sound.ogg"
