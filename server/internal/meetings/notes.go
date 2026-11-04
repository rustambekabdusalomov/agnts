package meetings

import (
	"context"
	"errors"
	"fmt"
	"os"
	"path/filepath"
	"slices"
	"sort"
	"strings"
	"time"
	"unicode"

	"agnts/internal/documents"
	"agnts/internal/domain"
)

// WakeNotes has the notes worker look at its queue now.
func (s *Service) WakeNotes() {
	select {
	case s.wake <- struct{}{}:
	default:
	}
}

// RunNotes hears the sessions whose notes are queued, one at a time, until
// ctx ends. Call it in the system scope.
func (s *Service) RunNotes(ctx context.Context) {
	if n, err := s.d.Store.RequeueNotes(ctx); err == nil && n > 0 {
		s.d.Log.Info("requeued meeting notes a restart interrupted", "count", n)
	}
	t := time.NewTicker(30 * time.Second)
	defer t.Stop()
	for {
		for ctx.Err() == nil {
			x, ok, err := s.d.Store.ClaimNotes(ctx)
			if err != nil {
				s.d.Log.Warn("claim meeting notes", "err", err)
				break
			}
			if !ok {
				break
			}
			s.hear(ctx, x)
		}
		select {
		case <-ctx.Done():
			return
		case <-s.wake:
		case <-t.C:
		}
	}
}

// audioWait is how long the worker waits for the audio's recorder to
// finish writing it after the call ends.
const audioWait = 10 * time.Minute

// hear transcribes a session's audio, stores the transcript and queues the
// notes document.
func (s *Service) hear(ctx context.Context, x domain.MeetingSession) {
	ctx = domain.WithWorkspace(ctx, x.WorkspaceID)
	log := s.d.Log.With("workspace", x.WorkspaceID, "session", x.ID)
	fail := func(err error) {
		log.Warn("meeting notes failed", "err", err)
		if err := s.d.Store.SetNotesStatus(context.WithoutCancel(ctx), x.ID, domain.NotesFailed, err.Error()); err != nil {
			log.Error("record failed notes", "err", err)
		}
		s.notesDone(ctx, x.ID)
	}
	if (x.Uploaded && !s.UploadsReady()) || (!x.Uploaded && !s.NotesReady()) {
		fail(errors.New("notes are not available on this server"))
		return
	}
	media, err := s.d.Store.SessionMedia(ctx, x.ID, domain.MediaAudioMixed, domain.MediaAudio, domain.MediaUpload)
	if err != nil {
		fail(err)
		return
	}
	for i, md := range media {
		if md.Kind != domain.MediaUpload || md.Status != domain.MediaReady {
			continue
		}
		if s.d.Sound == nil {
			fail(errors.New("uploaded recordings are not available on this server"))
			return
		}
		if media[i], err = s.takeSound(ctx, md); err != nil {
			fail(err)
			return
		}
	}
	for _, md := range media {
		if md.Status == domain.MediaActive && s.now().Sub(md.StartedAt) < 6*time.Hour && x.EndedAt != nil && s.now().Sub(*x.EndedAt) < audioWait {
			// Egress is still writing it: try again shortly.
			_ = s.d.Store.SetNotesStatus(ctx, x.ID, domain.NotesQueued, "")
			go func() {
				time.Sleep(30 * time.Second)
				s.WakeNotes()
			}()
			return
		}
	}
	m, err := s.d.Store.Meeting(ctx, x.MeetingID)
	if err != nil {
		fail(err)
		return
	}
	user := int64(0)
	switch {
	case x.NotesBy != nil:
		user = *x.NotesBy
	case m.HostID != nil:
		user = *m.HostID
	}
	segs, heard, err := s.transcribe(ctx, x, media, user)
	if err != nil {
		fail(err)
		return
	}
	if heard == 0 {
		fail(errors.New("no audio was recorded"))
		return
	}
	if len(segs) == 0 {
		fail(errors.New("nobody was heard: the recording has no words in it"))
		return
	}
	if err := s.d.Store.ReplaceSegments(ctx, x.ID, segs); err != nil {
		fail(err)
		return
	}
	if x.Uploaded {
		if err := s.d.Store.SetUploadLength(ctx, x.ID, segs[len(segs)-1].EndMS); err != nil {
			log.Warn("uploaded recording's length", "err", err)
		}
	}
	if !s.settings(ctx).KeepAudio {
		for _, md := range media {
			if md.Status == domain.MediaReady {
				s.removeFile(md.File)
				_ = s.d.Store.SetMediaStatus(ctx, md.ID, domain.MediaDeleted)
			}
		}
	}
	if err := s.writeNotes(ctx, m, x, user, segs); err != nil {
		fail(err)
		return
	}
	log.Info("meeting heard; writing the notes", "segments", len(segs))
}

// transcribe hears each audio file of a session and returns the segments
// in time order, with times from the session's start; heard counts the
// files read.
func (s *Service) transcribe(ctx context.Context, x domain.MeetingSession, media []domain.MeetingMedia, user int64) ([]domain.MeetingSegment, int, error) {
	names := map[string]string{}
	if att, err := s.d.Store.Attendance(ctx, x.ID); err == nil {
		for _, a := range att {
			names[a.Person.Key()] = a.Name
		}
	}
	var out []domain.MeetingSegment
	heard := 0
	var firstErr error
	for _, md := range media {
		if md.Status != domain.MediaReady && md.Status != domain.MediaActive {
			continue
		}
		if filepath.Base(md.File) != md.File {
			continue // names come from ids (mediaFile), never from input
		}
		path := filepath.Join(s.cfg.MediaDir, md.File)
		info, err := os.Stat(path)
		if err != nil || info.Size() == 0 {
			continue
		}
		if info.Size() > s.cfg.MaxAudioBytes {
			return nil, heard, fmt.Errorf("the meeting's audio is too long to hear (%d MB)", info.Size()>>20)
		}
		data, err := os.ReadFile(path) //nolint:gosec // G304: a name agnts made, in the meetings directory
		if err != nil {
			return nil, heard, err
		}
		heard++
		segs, err := s.d.Hearer.HearMeeting(ctx, user, data, strings.TrimPrefix(filepath.Ext(md.File), "."))
		if err != nil {
			if firstErr == nil {
				firstErr = err
			}
			continue
		}
		offset := int(md.StartedAt.Sub(x.StartedAt).Milliseconds())
		if md.Kind == domain.MediaUpload {
			offset = 0 // the file is the whole meeting
		}
		var who string
		if md.Kind == domain.MediaAudio {
			if p, _, ok := domain.ParseMeetingIdentity(md.Identity); ok {
				who = names[p.Key()]
			}
		}
		for _, g := range segs {
			g.StartMS, g.EndMS = max(0, g.StartMS+offset), max(0, g.EndMS+offset)
			if md.Kind == domain.MediaAudio {
				g.Identity, g.Name = md.Identity, who
			}
			out = append(out, g)
		}
	}
	if len(out) == 0 && firstErr != nil {
		return nil, heard, firstErr
	}
	sort.SliceStable(out, func(i, j int) bool { return out[i].StartMS < out[j].StartMS })
	return out, heard, nil
}

// writeNotes makes the notes document of a session and queues its
// generation: a private page of the host's that the people who were there
// and the invitees can read.
func (s *Service) writeNotes(ctx context.Context, m domain.Meeting, x domain.MeetingSession, user int64, segs []domain.MeetingSegment) error {
	owner := user
	if m.HostID != nil {
		owner = *m.HostID
	}
	if owner == 0 {
		w, err := s.d.Workspaces.ByID(ctx, m.WorkspaceID)
		if err != nil {
			return err
		}
		owner = w.OwnerID
	}
	if role, err := s.d.Workspaces.Role(ctx, m.WorkspaceID, owner); err != nil || role == "" {
		w, err := s.d.Workspaces.ByID(ctx, m.WorkspaceID)
		if err != nil {
			return err
		}
		owner = w.OwnerID // the host left the workspace
	}
	viewers, err := s.d.Store.AttendedMembers(ctx, x.ID)
	if err != nil {
		return err
	}
	if inv, err := s.d.Store.Invitees(ctx, m.ID); err == nil {
		for _, i := range inv {
			if i.UserID != nil {
				viewers = append(viewers, *i.UserID)
			}
		}
	}
	viewers = append(viewers, m.CohostIDs...)
	viewers = append(viewers, x.People...) // an upload's people
	if x.NotesBy != nil {
		viewers = append(viewers, *x.NotesBy)
	}
	slices.Sort(viewers)
	viewers = slices.Compact(viewers)
	lang := m.Language
	if lang == "auto" || lang == "" {
		lang = guessLanguage(segs)
	}
	loc, _ := time.LoadLocation(m.TimeZone)
	if loc == nil {
		loc = time.UTC
	}
	title := fmt.Sprintf("Notes: %s · %s", titleOf(m), x.StartedAt.In(loc).Format("2 Jan 2006"))
	doc, err := s.d.Notes.CreateMeetingNotes(ctx, documents.MeetingNotes{OwnerID: owner, Title: title, Language: lang, SessionID: x.ID,
		Viewers: viewers, RequestedBy: user})
	if err != nil {
		return err
	}
	return s.d.Store.SetNotesDocument(ctx, x.ID, doc)
}

// guessLanguage picks the notes' language from the transcript: Russian
// when it is mostly Cyrillic, Uzbek when it has Uzbek's letters, else
// English.
func guessLanguage(segs []domain.MeetingSegment) string {
	var cyr, lat, uz int
	for _, g := range segs {
		low := strings.ToLower(g.Text)
		uz += strings.Count(low, "oʻ") + strings.Count(low, "gʻ") + strings.Count(low, "o'") + strings.Count(low, "g'") +
			strings.Count(low, " va ") + strings.Count(low, "bu ")
		for _, r := range low {
			switch {
			case unicode.Is(unicode.Cyrillic, r):
				cyr++
			case r >= 'a' && r <= 'z':
				lat++
			}
		}
	}
	switch {
	case cyr > lat:
		return "ru"
	case uz > 3 && uz*200 > lat:
		return "uz"
	}
	return "en"
}

// NotesChanged tells the people who can read a session's notes that they
// are ready (or failed). The documents module calls it when a notes
// generation ends.
func (s *Service) NotesChanged(ctx context.Context, d domain.Document) {
	if d.Source == nil || d.Source.Kind != domain.SourceMeeting || d.Run == nil {
		return
	}
	if d.Run.Status != domain.DocRunDone && d.Run.Status != domain.DocRunFailed {
		return
	}
	// Done or failed, the items are the ones to keep: the new notes', or
	// the earlier ones a failed rewrite left.
	if x, err := s.d.Store.Session(ctx, d.Source.SessionID); err == nil {
		if m, err := s.d.Store.Meeting(ctx, x.MeetingID); err == nil {
			s.settleActionItems(ctx, x, m)
		}
	}
	s.notesDone(ctx, d.Source.SessionID)
}

// notesDone tells the session's readers the notes ended, done or not.
func (s *Service) notesDone(ctx context.Context, sessionID int64) {
	x, err := s.d.Store.Session(ctx, sessionID)
	if err != nil {
		return
	}
	m, err := s.d.Store.Meeting(ctx, x.MeetingID)
	if err != nil {
		return
	}
	users, _ := s.d.Store.AttendedMembers(ctx, x.ID)
	if m.HostID != nil {
		users = append(users, *m.HostID)
	}
	users = append(users, x.People...)
	if x.NotesBy != nil {
		users = append(users, *x.NotesBy)
	}
	slices.Sort(users)
	users = slices.Compact(users)
	for _, u := range users {
		s.publish(m.WorkspaceID, u, domain.EventMeetingNotes, map[string]any{"meetingId": m.ID, "sessionId": x.ID, "status": x.NotesStatus,
			"documentId": x.DocumentID})
	}
	if s.d.Pusher != nil && len(users) > 0 {
		p := Push{Title: "Notes of " + titleOf(m) + " are ready", Body: "Decisions and action items, written by Muse", Code: m.Code, Tag: "meeting-notes-" + m.Code}
		if x.NotesStatus == domain.NotesFailed {
			if m.HostID == nil {
				return
			}
			users = []int64{*m.HostID}
			p = Push{Title: "Notes of " + titleOf(m) + " could not be written", Body: x.NotesError, Code: m.Code, Tag: p.Tag}
		}
		s.d.Pusher.MeetingPush(ctx, users, p)
	}
}

// RegenerateNotes writes a session's notes again: from the transcript
// when there is one, else by hearing the audio again (when it is kept).
func (s *Service) RegenerateNotes(ctx context.Context, c Caller, meetingID, sessionID int64) error {
	m, x, err := s.sessionOf(ctx, c, meetingID, sessionID)
	if err != nil {
		return err
	}
	if !canManage(c, m) {
		return forbidden("only the meeting's hosts can write the notes again")
	}
	if x.EndedAt == nil {
		return invalid("the call is still going: the notes are written when it ends")
	}
	switch x.NotesStatus {
	case domain.NotesQueued, domain.NotesTranscribing, domain.NotesWriting:
		return fmt.Errorf("%w: the notes are being written", domain.ErrConflict)
	}
	segs, err := s.d.Store.Segments(ctx, x.ID)
	if err != nil {
		return err
	}
	if err := s.dropUntouchedDrafts(ctx, x.ID); err != nil {
		return err
	}
	if len(segs) > 0 {
		if x.DocumentID != nil {
			if err := s.d.Notes.RegenerateMeetingNotes(ctx, *x.DocumentID, x.ID, c.UserID); err == nil {
				return s.d.Store.SetNotesStatus(ctx, x.ID, domain.NotesWriting, "")
			} else if !errors.Is(err, domain.ErrNotFound) {
				return err
			}
		}
		if err := s.d.Store.SetNotesStatus(ctx, x.ID, domain.NotesWriting, ""); err != nil {
			return err
		}
		return s.writeNotes(ctx, m, x, c.UserID, segs)
	}
	media, err := s.d.Store.SessionMedia(ctx, x.ID, domain.MediaAudioMixed, domain.MediaAudio, domain.MediaUpload)
	if err != nil {
		return err
	}
	for _, md := range media {
		if md.Status == domain.MediaReady {
			if err := s.d.Store.SetNotesStatus(ctx, x.ID, domain.NotesQueued, ""); err != nil {
				return err
			}
			s.WakeNotes()
			return nil
		}
	}
	return invalid("there is nothing to write the notes from: the audio is gone and nothing was transcribed")
}

// Transcript returns a session's transcript.
func (s *Service) Transcript(ctx context.Context, c Caller, meetingID, sessionID int64) (domain.Meeting, domain.MeetingSession, []domain.MeetingSegment, error) {
	m, x, err := s.sessionOf(ctx, c, meetingID, sessionID)
	if err != nil {
		return m, x, nil, err
	}
	segs, err := s.d.Store.Segments(ctx, x.ID)
	return m, x, segs, err
}

// TranscriptText is a transcript as plain text: "[m:ss] Name: words".
func TranscriptText(m domain.Meeting, x domain.MeetingSession, segs []domain.MeetingSegment) string {
	var b strings.Builder
	fmt.Fprintf(&b, "%s\n%s\n\n", titleOf(m), x.StartedAt.UTC().Format("2 January 2006 15:04 MST"))
	for _, g := range segs {
		b.WriteString("[" + domain.FormatOffset(g.StartMS) + "] ")
		if g.Name != "" {
			b.WriteString(g.Name + ": ")
		}
		b.WriteString(strings.TrimSpace(g.Text) + "\n")
	}
	return b.String()
}

// TranscriptVTT is a transcript as WebVTT subtitles, to play beside the
// recording.
func TranscriptVTT(segs []domain.MeetingSegment) string {
	var b strings.Builder
	b.WriteString("WEBVTT\n\n")
	ts := func(ms int) string {
		return fmt.Sprintf("%02d:%02d:%02d.%03d", ms/3_600_000, ms/60_000%60, ms/1000%60, ms%1000)
	}
	for i, g := range segs {
		end := g.EndMS
		if end <= g.StartMS {
			end = g.StartMS + 1000
		}
		fmt.Fprintf(&b, "%d\n%s --> %s\n", i+1, ts(g.StartMS), ts(end))
		text := strings.TrimSpace(strings.ReplaceAll(g.Text, "-->", "->"))
		if g.Name != "" {
			text = "<v " + strings.ReplaceAll(g.Name, ">", "") + ">" + text
		}
		b.WriteString(text + "\n\n")
	}
	return b.String()
}

// SessionDetail is a past (or live) session as its page shows it.
type SessionDetail struct {
	Meeting     domain.Meeting
	Session     domain.MeetingSession
	Attendees   []domain.MeetingAttendee
	Media       []domain.MeetingMedia // recordings people can watch
	ActionItems []domain.ActionItem
	Messages    int
	CanManage   bool
}

// Session returns a session's attendance, recordings and action items.
func (s *Service) Session(ctx context.Context, c Caller, meetingID, sessionID int64) (SessionDetail, error) {
	m, x, err := s.sessionOf(ctx, c, meetingID, sessionID)
	if err != nil {
		return SessionDetail{}, err
	}
	d := SessionDetail{Meeting: m, Session: x, CanManage: canManage(c, m)}
	if d.Attendees, err = s.d.Store.Attendance(ctx, x.ID); err != nil {
		return d, err
	}
	media, err := s.d.Store.SessionMedia(ctx, x.ID, domain.MediaRecording)
	if err != nil {
		return d, err
	}
	for _, md := range media {
		if md.Status == domain.MediaReady || md.Status == domain.MediaActive {
			d.Media = append(d.Media, md)
		}
	}
	if d.ActionItems, err = s.d.Store.ActionItems(ctx, x.ID); err != nil {
		return d, err
	}
	msgs, err := s.d.Store.Messages(ctx, x.ID, 0, 1000)
	d.Messages = len(msgs)
	return d, err
}

// Sessions lists a meeting's sessions, newest first.
func (s *Service) Sessions(ctx context.Context, c Caller, meetingID int64) ([]domain.MeetingSession, error) {
	if _, err := s.meeting(ctx, c, meetingID); err != nil {
		return nil, err
	}
	return s.d.Store.Sessions(ctx, meetingID, 50)
}

// SessionMessages returns a past session's chat.
func (s *Service) SessionMessages(ctx context.Context, c Caller, meetingID, sessionID int64) ([]domain.MeetingMessage, error) {
	_, x, err := s.sessionOf(ctx, c, meetingID, sessionID)
	if err != nil {
		return nil, err
	}
	return s.d.Store.Messages(ctx, x.ID, 0, 1000)
}

// TicketOptions are how a ticket is made from an action item.
type TicketOptions struct {
	RepoID int64  // 0: agnts picks, or none
	Start  string // ask, code or queue; "" asks
	Origin domain.Origin
}

// ActionItemTicket makes a ticket of an action item, with the quote that
// shows it, and links it to the meeting.
func (s *Service) ActionItemTicket(ctx context.Context, c Caller, meetingID, sessionID, itemID int64, o TicketOptions) (domain.Ticket, error) {
	if s.d.Tickets == nil {
		return domain.Ticket{}, unavailable("tickets")
	}
	if !c.Role.CanEdit() {
		return domain.Ticket{}, forbidden("viewers can't create tickets")
	}
	m, x, err := s.sessionOf(ctx, c, meetingID, sessionID)
	if err != nil {
		return domain.Ticket{}, err
	}
	it, err := s.d.Store.ActionItem(ctx, itemID)
	if err != nil || it.SessionID != x.ID {
		return domain.Ticket{}, domain.ErrNotFound
	}
	if it.TicketID != nil {
		return domain.Ticket{}, fmt.Errorf("%w: %s was made from this action item already", domain.ErrConflict, it.TicketKey)
	}
	if o.Start == "" {
		o.Start = "ask"
	}
	if o.Origin == "" {
		o.Origin = domain.OriginWeb
	}
	t, err := s.itemTicket(ctx, m, x, it, o.Start, &c.UserID, o.Origin, o.RepoID)
	if err != nil {
		return t, err
	}
	if ok, err := s.d.Store.SetActionItemTicket(ctx, it.ID, t.ID, c.UserID); err != nil {
		return t, err
	} else if !ok {
		s.d.Log.Warn("an action item got two tickets at once", "item", it.ID, "ticket", t.Key)
	}
	return t, nil
}

// itemDescription is a ticket's description from an action item: what,
// who, when, and the words of the meeting that show it.
func (s *Service) itemDescription(ctx context.Context, m domain.Meeting, x domain.MeetingSession, it domain.ActionItem) string {
	var b strings.Builder
	loc, _ := time.LoadLocation(m.TimeZone)
	if loc == nil {
		loc = time.UTC
	}
	fmt.Fprintf(&b, "From the meeting **%s** on %s.\n\n", titleOf(m), x.StartedAt.In(loc).Format("2 January 2006"))
	switch {
	case it.WhoName != "" && it.Who != "" && domain.FoldName(it.Who) != domain.FoldName(it.WhoName):
		fmt.Fprintf(&b, "- Who: %s (said: %s)\n", it.WhoName, it.Who)
	case it.WhoName != "":
		fmt.Fprintf(&b, "- Who: %s\n", it.WhoName)
	case it.Who != "":
		fmt.Fprintf(&b, "- Who: %s (no member matched this name)\n", it.Who)
	}
	if it.Due != "" {
		fmt.Fprintf(&b, "- When: %s\n", it.Due)
	}
	if it.Quote != "" {
		at := ""
		if it.AtMS != nil {
			at = " [" + domain.FormatOffset(*it.AtMS) + "]"
		}
		fmt.Fprintf(&b, "\n> %s%s\n", strings.ReplaceAll(it.Quote, "\n", " "), at)
	}
	if x.DocumentID != nil {
		if w, err := s.d.Workspaces.ByID(ctx, m.WorkspaceID); err == nil {
			fmt.Fprintf(&b, "\nNotes: %s/w/%s/documents/%d\n", strings.TrimRight(s.cfg.PublicURL, "/"), w.Slug, *x.DocumentID)
		}
	}
	return b.String()
}
