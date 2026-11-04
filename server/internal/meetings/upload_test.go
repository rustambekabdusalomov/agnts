package meetings_test

import (
	"bytes"
	"context"
	"errors"
	"os"
	"strings"
	"testing"
	"time"

	"agnts/internal/domain"
	"agnts/internal/meetings"
)

// waitNotes runs the notes worker until session id's notes are past
// hearing.
func (h harness) waitNotes(id int64) domain.MeetingSession {
	h.t.Helper()
	ctx, cancel := context.WithTimeout(domain.System(context.Background()), 5*time.Second)
	defer cancel()
	go h.svc.RunNotes(ctx)
	h.svc.WakeNotes()
	for ctx.Err() == nil {
		x, err := h.store.Session(h.ctx, id)
		if err != nil {
			h.t.Fatal(err)
		}
		if x.NotesStatus == domain.NotesWriting || x.NotesStatus == domain.NotesFailed {
			return x
		}
		time.Sleep(30 * time.Millisecond)
	}
	h.t.Fatal("the notes worker did not hear the upload")
	return domain.MeetingSession{}
}

func TestUploadRecording(t *testing.T) {
	h := newHarness(t)
	m := h.create(domain.MeetingInput{Title: "Client call"}, meetings.Invites{})
	held := time.Now().Add(-48 * time.Hour).Truncate(time.Second)
	up := func(c meetings.Caller, name, body string, people ...int64) (domain.MeetingSession, error) {
		return h.svc.Upload(h.ctx, c, m.ID, meetings.Upload{Name: name, Body: strings.NewReader(body), StartedAt: held, People: people})
	}

	// Who may upload, and what.
	if _, err := up(h.caller(h.member), "call.mp4", "video"); !errors.Is(err, domain.ErrForbidden) {
		t.Errorf("a member who doesn't host it uploaded: %v", err)
	}
	if _, err := up(h.caller(h.host), "slides.pdf", "pdf"); !errors.Is(err, domain.ErrMeetingInvalid) {
		t.Errorf("a pdf was taken: %v", err)
	}
	if _, err := up(h.caller(h.host), "call.mp4", ""); !errors.Is(err, domain.ErrMeetingInvalid) {
		t.Errorf("an empty file was taken: %v", err)
	}
	if _, err := up(h.caller(h.host), "call.mp4", "video", h.other.ID); !errors.Is(err, domain.ErrMeetingInvalid) {
		t.Errorf("an outsider was put in the recording: %v", err)
	}
	if _, err := h.svc.Upload(h.ctx, h.caller(h.host), m.ID, meetings.Upload{Name: "call.mp4", Body: bytes.NewReader(make([]byte, 1<<20+1))}); !errors.Is(err, meetings.ErrTooBig) {
		t.Errorf("a file over the limit was taken: %v", err)
	}
	if files, _ := os.ReadDir(h.media); len(files) != 0 {
		t.Fatalf("refused uploads left files: %v", files)
	}

	x, err := up(h.caller(h.host), "Call.MP4", "the whole video", h.member.ID)
	if err != nil {
		t.Fatal(err)
	}
	if !x.Uploaded || x.EndedAt == nil || x.NotesStatus != domain.NotesQueued || !x.StartedAt.Equal(held) || len(x.People) != 1 {
		t.Fatalf("upload session %+v", x)
	}
	// The member in it sees the session; another member doesn't.
	if _, err := h.svc.Session(h.ctx, h.caller(h.member), m.ID, x.ID); err != nil {
		t.Errorf("the member in the recording can't see it: %v", err)
	}

	x = h.waitNotes(x.ID)
	if x.NotesStatus != domain.NotesWriting {
		t.Fatalf("notes %s: %s", x.NotesStatus, x.NotesError)
	}
	if len(h.sound.took) != 1 || h.sound.took[0] != "the whole video" {
		t.Errorf("sound taken from %q", h.sound.took)
	}
	// The video is gone; the sound was heard and is gone too (no audio kept).
	if files, _ := os.ReadDir(h.media); len(files) != 0 {
		t.Errorf("files left: %v", files)
	}
	media, _ := h.store.SessionMedia(h.ctx, x.ID, domain.MediaUpload)
	if len(media) != 1 || !strings.HasSuffix(media[0].File, ".sound.ogg") || media[0].Status != domain.MediaDeleted {
		t.Errorf("upload media %+v", media)
	}
	if x.EndedAt == nil || x.EndedAt.Sub(x.StartedAt) != 8*time.Second {
		t.Errorf("length from the sound: %v", x.EndedAt)
	}
	h.notes.mu.Lock()
	n := h.notes.made[len(h.notes.made)-1]
	h.notes.mu.Unlock()
	if n.SessionID != x.ID || n.RequestedBy != h.host.ID {
		t.Errorf("notes %+v", n)
	}
	viewer := false
	for _, v := range n.Viewers {
		viewer = viewer || v == h.member.ID
	}
	if !viewer {
		t.Errorf("the member in the recording can't read the notes: %v", n.Viewers)
	}
	in, err := h.store.NotesInput(h.ctx, x.ID)
	if err != nil || len(in.People) != 1 || in.People[0] != "Member" || in.Speakers {
		t.Errorf("notes input %+v %v", in.People, err)
	}
	if cands, _ := h.store.NameCandidates(h.ctx, x.ID); !nearOf(cands, h.member.ID) {
		t.Errorf("the member in the recording is not near: %+v", cands)
	}

	// A recording without sound fails its notes with the reason.
	h.sound.fail = meetings.ErrNoSound
	x2, err := up(h.caller(h.host), "screen.webm", "pictures only")
	if err != nil {
		t.Fatal(err)
	}
	x2 = h.waitNotes(x2.ID)
	if x2.NotesStatus != domain.NotesFailed || !strings.Contains(x2.NotesError, "no sound") {
		t.Errorf("silent upload %s %q", x2.NotesStatus, x2.NotesError)
	}
}

func nearOf(cands []domain.NameCandidate, id int64) bool {
	for _, c := range cands {
		if c.UserID == id {
			return c.Near
		}
	}
	return false
}
