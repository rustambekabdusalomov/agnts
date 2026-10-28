// Package meetings runs video calls of a workspace's members and the
// guests they let in. LiveKit carries the media; this package decides who
// joins which session with what rights (domain.DecideJoin, RightsOf),
// keeps what happened (attendance, chat, recordings, the transcript) and
// turns a session into notes that Muse writes and action items that
// become tickets.
//
// Members manage meetings in their workspace (Caller); everyone in a call,
// members and guests alike, acts through the seat their join handed out,
// so the call page never depends on which workspace a person has open.
package meetings

import (
	"context"
	"errors"
	"fmt"
	"log/slog"
	"strings"
	"time"

	"agnts/internal/documents"
	"agnts/internal/domain"
	"agnts/internal/livekit"
	"agnts/internal/mail"
	"agnts/internal/orchestrator"
	"agnts/internal/store/postgres"
)

// Store is where meetings live (postgres.Meetings).
type Store interface {
	CreateMeeting(ctx context.Context, m domain.Meeting) (domain.Meeting, error)
	Meeting(ctx context.Context, id int64) (domain.Meeting, error)
	MeetingByCode(ctx context.Context, code string) (domain.Meeting, error)
	ListMeetings(ctx context.Context, f postgres.MeetingFilter) ([]domain.Meeting, error)
	CanSeeMeeting(ctx context.Context, id, userID int64, owner bool) (bool, error)
	UpdateMeeting(ctx context.Context, id int64, in domain.MeetingInput, bump bool) (domain.Meeting, error)
	SetMeetingLocked(ctx context.Context, id int64, locked bool) error
	SetMeetingGuests(ctx context.Context, id int64, g domain.GuestMode) error
	SetMeetingHost(ctx context.Context, id, userID int64) error
	SetCohost(ctx context.Context, id, userID int64, on bool) error
	CancelMeeting(ctx context.Context, id int64) error
	DeleteMeeting(ctx context.Context, id int64) ([]string, error)

	AddInvitees(ctx context.Context, meetingID int64, in []postgres.NewInvitee) ([]domain.Invitee, error)
	RemoveInvitees(ctx context.Context, meetingID int64, ids []int64) error
	Invitees(ctx context.Context, meetingID int64) ([]domain.Invitee, error)
	IsInvited(ctx context.Context, meetingID, userID int64) (bool, error)
	InviteeByToken(ctx context.Context, meetingID int64, h []byte) (domain.Invitee, error)
	SetRSVP(ctx context.Context, meetingID, userID int64, rsvp string) error
	SetInviteeToken(ctx context.Context, id int64, h []byte) error
	ResetReminders(ctx context.Context, meetingID int64) error
	DueReminders(ctx context.Context) ([]postgres.Reminder, error)
	MarkReminded(ctx context.Context, inviteeID int64) (bool, error)
	MeetingReminderMin(ctx context.Context, userID int64) (int, error)
	SetMeetingReminderMin(ctx context.Context, userID int64, n int) error

	OpenSession(ctx context.Context, meetingID int64) (domain.MeetingSession, bool, error)
	Session(ctx context.Context, id int64) (domain.MeetingSession, error)
	SessionWorkspace(ctx context.Context, id int64) (postgres.SessionRef, error)
	Sessions(ctx context.Context, meetingID int64, limit int) ([]domain.MeetingSession, error)
	EndSession(ctx context.Context, id int64, at time.Time) (bool, error)
	LiveSessions(ctx context.Context) ([]postgres.LiveSession, error)
	SetGuestsQuiet(ctx context.Context, id int64, quiet bool) error
	SetNotes(ctx context.Context, id int64, on bool, by int64) error
	SetNotesStatus(ctx context.Context, id int64, st domain.NotesStatus, msg string) error
	SetNotesDocument(ctx context.Context, id, docID int64) error
	ClaimNotes(ctx context.Context) (domain.MeetingSession, bool, error)
	RequeueNotes(ctx context.Context) (int64, error)
	PastSessions(ctx context.Context, userID int64, owner bool, before *time.Time, limit int) ([]postgres.SessionSummary, error)

	CreateMeetingGuest(ctx context.Context, g domain.MeetingGuest, tokenHash []byte) (domain.MeetingGuest, error)
	MeetingGuestByToken(ctx context.Context, meetingID int64, h []byte) (domain.MeetingGuest, error)
	MeetingGuestByUser(ctx context.Context, meetingID, userID int64) (domain.MeetingGuest, error)
	MeetingGuest(ctx context.Context, id int64) (domain.MeetingGuest, error)
	RenameMeetingGuest(ctx context.Context, id int64, name string) error

	CreateSeat(ctx context.Context, x domain.MeetingSeat, tokenHash []byte) (domain.MeetingSeat, error)
	SeatByToken(ctx context.Context, h []byte) (postgres.SeatRef, error)
	Seat(ctx context.Context, id int64) (domain.MeetingSeat, error)
	ReplaceSeatToken(ctx context.Context, id int64, h []byte) error
	PersonStatus(ctx context.Context, sessionID int64, p domain.Person) (postgres.SeatStatus, error)
	RemovePerson(ctx context.Context, sessionID int64, p domain.Person) ([]string, error)
	PersonIdentities(ctx context.Context, sessionID int64, p domain.Person) ([]string, error)

	CreateKnock(ctx context.Context, k domain.MeetingKnock, tokenHash []byte) (domain.MeetingKnock, error)
	KnockByToken(ctx context.Context, id int64, h []byte) (domain.MeetingKnock, error)
	Knock(ctx context.Context, id int64) (domain.MeetingKnock, error)
	WaitingKnocks(ctx context.Context, sessionID int64) ([]domain.MeetingKnock, error)
	DecideKnock(ctx context.Context, id int64, state domain.KnockState, by int64, seatID *int64) (bool, error)
	DeniedSince(ctx context.Context, sessionID int64, p domain.Person, since time.Time) (bool, error)

	ParticipantJoined(ctx context.Context, sessionID int64, identity string, p domain.Person, name string, at time.Time) error
	ParticipantLeft(ctx context.Context, sessionID int64, identity string, p domain.Person, name string, joined, at time.Time) error
	PresentPeople(ctx context.Context, sessionID int64) ([]postgres.Present, error)
	SyncPresent(ctx context.Context, sessionID int64, identities []string, at time.Time) (int64, error)
	Attendance(ctx context.Context, sessionID int64) ([]domain.MeetingAttendee, error)
	AttendedMembers(ctx context.Context, sessionID int64) ([]int64, error)
	Attended(ctx context.Context, meetingID, sessionID, userID int64) (bool, error)

	AddMessage(ctx context.Context, m domain.MeetingMessage) (domain.MeetingMessage, error)
	Messages(ctx context.Context, sessionID, after int64, limit int) ([]domain.MeetingMessage, error)
	MessagesSince(ctx context.Context, sessionID int64, p domain.Person, since time.Time) (int, error)

	CreateMedia(ctx context.Context, m domain.MeetingMedia) (domain.MeetingMedia, error)
	Media(ctx context.Context, id int64) (domain.MeetingMedia, error)
	MediaByEgress(ctx context.Context, egressID string) (domain.MeetingMedia, error)
	SessionMedia(ctx context.Context, sessionID int64, kinds ...domain.MediaKind) ([]domain.MeetingMedia, error)
	FinishMedia(ctx context.Context, egressID string, st domain.MediaStatus, bytes int64, endedAt time.Time, msg string) (domain.MeetingMedia, error)
	SetMediaStatus(ctx context.Context, id int64, st domain.MediaStatus) error
	ActiveRecordings(ctx context.Context) (int, error)
	MediaBytes(ctx context.Context) (int64, error)
	StaleActiveMedia(ctx context.Context, before time.Time) ([]domain.MeetingMedia, error)
	ExpiredMedia(ctx context.Context, days int) ([]postgres.ExpiredFile, error)
	ExpireTranscripts(ctx context.Context, days int) (int64, error)

	ReplaceSegments(ctx context.Context, sessionID int64, segs []domain.MeetingSegment) error
	Segments(ctx context.Context, sessionID int64) ([]domain.MeetingSegment, error)
	SearchTranscripts(ctx context.Context, userID int64, owner bool, query string, limit int) ([]postgres.TranscriptHit, error)
	ActionItems(ctx context.Context, sessionID int64) ([]domain.ActionItem, error)
	ActionItem(ctx context.Context, id int64) (domain.ActionItem, error)
	SetActionItemTicket(ctx context.Context, itemID, ticketID, by int64) (bool, error)
	MeetingTickets(ctx context.Context, meetingID, ticketID int64) ([]postgres.MeetingTicket, error)
	LinkMeetingTicket(ctx context.Context, meetingID, ticketID, by int64) error
	UnlinkMeetingTicket(ctx context.Context, meetingID, ticketID int64) error

	FirstSeen(ctx context.Context, eventID string) (bool, error)
	PruneEvents(ctx context.Context) error
	MeetingUsage(ctx context.Context, from, to time.Time) ([]postgres.MeetingUsageDay, error)
}

// LiveKit is the media server (livekit.Client).
type LiveKit interface {
	CreateRoom(ctx context.Context, r livekit.NewRoom) (livekit.Room, error)
	ListRooms(ctx context.Context, names ...string) ([]livekit.Room, error)
	DeleteRoom(ctx context.Context, room string) error
	ListParticipants(ctx context.Context, room string) ([]livekit.Participant, error)
	RemoveParticipant(ctx context.Context, room, identity string) error
	MuteTrack(ctx context.Context, room, identity, trackSID string) error
	UpdateParticipant(ctx context.Context, room, identity string, perm *livekit.Permission, attrs map[string]string) error
	UpdateRoomMetadata(ctx context.Context, room, metadata string) error
	SendData(ctx context.Context, room, topic string, data []byte, to ...string) error
	StartRoomRecording(ctx context.Context, r livekit.RoomRecording) (livekit.Egress, error)
	StartTrackRecording(ctx context.Context, room, trackSID, path string) (livekit.Egress, error)
	StopEgress(ctx context.Context, id string) (livekit.Egress, error)
	ListEgress(ctx context.Context, room string, active bool) ([]livekit.Egress, error)
}

// Workspaces gives roles, members and workspace names.
type Workspaces interface {
	Role(ctx context.Context, ws, userID int64) (domain.WorkspaceRole, error)
	Members(ctx context.Context, ws int64) ([]domain.Member, error)
	ByID(ctx context.Context, id int64) (domain.Workspace, error)
}

// Users reads accounts.
type Users interface {
	ByID(ctx context.Context, id int64) (domain.User, error)
}

// Settings gives the workspace's settings (Settings.Meetings).
type Settings interface {
	Get(ctx context.Context) (domain.Settings, error)
}

// Stream sends an event to one person's live streams in a workspace.
type Stream interface {
	PublishTo(ws, user int64, e domain.Event)
}

// Push is a meeting notification on people's phones and in Telegram.
type Push struct {
	Title string
	Body  string
	Code  string // the meeting's code: the app opens /m/<code>
	Tag   string // replaces the previous push with this tag
}

// Pusher sends pushes to members (notify.Notifier).
type Pusher interface {
	MeetingPush(ctx context.Context, users []int64, p Push)
}

// Notes makes the notes document (documents.Service).
type Notes interface {
	CreateMeetingNotes(ctx context.Context, n documents.MeetingNotes) (int64, error)
	RegenerateMeetingNotes(ctx context.Context, docID, sessionID, by int64) error
}

// Hearer hears a meeting's audio with Muse (orchestrator.Orchestrator).
type Hearer interface {
	CanHearMeetings() bool
	HearMeeting(ctx context.Context, user int64, audio []byte, ext string) ([]domain.MeetingSegment, error)
}

// Tickets makes tickets of action items (orchestrator.Orchestrator).
type Tickets interface {
	CreateTask(ctx context.Context, in orchestrator.TaskInput, origin domain.Origin) (domain.Ticket, error)
	TicketByKey(ctx context.Context, key string) (domain.Ticket, error)
}

// Config is how the service reaches LiveKit and where files go.
type Config struct {
	// LiveKitURL is the wss:// address clients connect to.
	LiveKitURL string
	Keys       livekit.Keys
	// PublicURL is agnts's address, for meeting links in emails.
	PublicURL string
	// MediaDir is where agnts reads Egress's files; EgressDir is the same
	// directory as the Egress container sees it.
	MediaDir  string
	EgressDir string
	// Egress says LiveKit Egress runs (recordings and notes need it).
	Egress bool
	// MaxRecordings caps the video recordings running on the server.
	MaxRecordings int
	// NotesAudio is "mixed" (one file of everyone) or "per-speaker".
	NotesAudio string
	// MaxAudioBytes caps the audio one session's notes may hear.
	MaxAudioBytes int64
}

// NotesPerSpeaker is the NotesAudio setting that records each microphone.
const NotesPerSpeaker = "per-speaker"

// Deps are the service's collaborators. Optional ones may be nil.
type Deps struct {
	Store      Store
	LiveKit    LiveKit
	Workspaces Workspaces
	Users      Users
	Settings   Settings
	Stream     Stream // nil: nobody hears live events
	Pusher     Pusher // nil: no pushes
	Mailer     mail.Sender
	Notes      Notes   // nil: no notes
	Hearer     Hearer  // nil: no notes
	Tickets    Tickets // nil: action items can't become tickets
	Log        *slog.Logger
}

// Service is the Meetings module.
type Service struct {
	cfg  Config
	d    Deps
	now  func() time.Time
	wake chan struct{} // the notes worker's queue changed
}

// New returns the service.
func New(cfg Config, d Deps) *Service {
	if d.Log == nil {
		d.Log = slog.Default()
	}
	if cfg.MaxRecordings <= 0 {
		cfg.MaxRecordings = 2
	}
	if cfg.MaxAudioBytes <= 0 {
		cfg.MaxAudioBytes = 512 << 20
	}
	if cfg.EgressDir == "" {
		cfg.EgressDir = cfg.MediaDir
	}
	return &Service{cfg: cfg, d: d, now: time.Now, wake: make(chan struct{}, 1)}
}

// Caller is a signed-in member acting in their workspace.
type Caller struct {
	WorkspaceID int64
	UserID      int64
	Role        domain.WorkspaceRole
}

// Errors the handlers translate.
var (
	// ErrUnavailable: meetings, recording or notes are off on this server.
	ErrUnavailable = errors.New("not available on this server")
	// ErrTooMany: too many messages or requests; wait a little.
	ErrTooMany = errors.New("too many requests; wait a moment")
	// ErrSeat: the in-call request's seat is unknown, removed or over.
	ErrSeat = errors.New("you are not in this call")
)

// RefusedError says why someone may not join.
type RefusedError struct{ Reason string }

func (e *RefusedError) Error() string {
	switch e.Reason {
	case domain.RefuseCancelled:
		return "this meeting was cancelled"
	case domain.RefuseNotYet:
		return "this meeting hasn't started yet; you can join 15 minutes before it starts"
	case domain.RefuseLocked:
		return "the meeting is locked; nobody new can join"
	case domain.RefuseFull:
		return "this meeting is full"
	case domain.RefuseRemoved:
		return "you were removed from this meeting"
	case domain.RefuseGuestsOff:
		return "this meeting is for members of the workspace only"
	case domain.RefuseDenied:
		return "you were not let in; try again in a few minutes"
	}
	return "you can't join this meeting"
}

func forbidden(format string, args ...any) error {
	return fmt.Errorf("%w: %s", domain.ErrForbidden, fmt.Sprintf(format, args...))
}

func invalid(format string, args ...any) error {
	return fmt.Errorf("%w: %s", domain.ErrMeetingInvalid, fmt.Sprintf(format, args...))
}

func unavailable(what string) error { return fmt.Errorf("%w: %s", ErrUnavailable, what) }

// Ready reports whether calls can be made: LiveKit is configured.
func (s *Service) Ready() bool {
	return s.d.LiveKit != nil && s.cfg.Keys.Valid() && s.cfg.LiveKitURL != ""
}

// RecordingReady reports whether video recordings can be made.
func (s *Service) RecordingReady() bool { return s.Ready() && s.cfg.Egress && s.cfg.MediaDir != "" }

// NotesReady reports whether notes can be taken.
func (s *Service) NotesReady() bool {
	return s.RecordingReady() && s.d.Notes != nil && s.d.Hearer != nil && s.d.Hearer.CanHearMeetings()
}

// Link is a meeting's public link.
func (s *Service) Link(code string) string {
	return strings.TrimRight(s.cfg.PublicURL, "/") + "/m/" + domain.FormatMeetingCode(code)
}

func (s *Service) settings(ctx context.Context) domain.MeetingSettings {
	st, err := s.d.Settings.Get(ctx)
	if err != nil {
		return domain.DefaultMeetingSettings()
	}
	return st.Meetings
}

func (s *Service) publish(ws, user int64, typ string, data map[string]any) {
	if s.d.Stream != nil {
		s.d.Stream.PublishTo(ws, user, domain.Event{WorkspaceID: ws, Type: typ, Data: data, CreatedAt: s.now()})
	}
}

// canManage reports whether a member may change a meeting: its host,
// co-hosts and the workspace's owner.
func canManage(c Caller, m domain.Meeting) bool {
	return c.Role == domain.RoleOwner || m.IsHost(c.UserID) || m.IsCohost(c.UserID)
}

// meeting opens a meeting a member may see (ErrNotFound otherwise).
func (s *Service) meeting(ctx context.Context, c Caller, id int64) (domain.Meeting, error) {
	m, err := s.d.Store.Meeting(ctx, id)
	if err != nil {
		return m, err
	}
	ok, err := s.d.Store.CanSeeMeeting(ctx, id, c.UserID, c.Role == domain.RoleOwner)
	if err != nil {
		return m, err
	}
	if !ok {
		return m, domain.ErrNotFound
	}
	return m, nil
}

// sessionOf opens a session of a meeting the member may read: its hosts,
// the owner, its invitees, and the members who were in that session.
func (s *Service) sessionOf(ctx context.Context, c Caller, meetingID, sessionID int64) (domain.Meeting, domain.MeetingSession, error) {
	m, err := s.meeting(ctx, c, meetingID)
	if err != nil {
		return m, domain.MeetingSession{}, err
	}
	x, err := s.d.Store.Session(ctx, sessionID)
	if err != nil || x.MeetingID != m.ID {
		return m, x, domain.ErrNotFound
	}
	if canManage(c, m) {
		return m, x, nil
	}
	if ok, err := s.d.Store.IsInvited(ctx, m.ID, c.UserID); err != nil || ok {
		return m, x, err
	}
	ok, err := s.d.Store.Attended(ctx, m.ID, x.ID, c.UserID)
	if err != nil {
		return m, x, err
	}
	if !ok {
		return m, x, forbidden("only the people who were in this call, the invitees and the hosts can read it")
	}
	return m, x, nil
}
