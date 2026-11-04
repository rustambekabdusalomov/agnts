package domain

import (
	"crypto/rand"
	"errors"
	"fmt"
	"math/big"
	"regexp"
	"strconv"
	"strings"
	"time"
	"unicode/utf8"
)

// Meetings: video calls of a workspace. A meeting is a reusable link; a
// session is one time it was live. LiveKit carries the media, agnts
// decides who may join with what rights (see DecideJoin and RightsOf).

// MeetingKind says how a meeting was made.
type MeetingKind string

// Meeting kinds.
const (
	MeetingInstant   MeetingKind = "instant"
	MeetingScheduled MeetingKind = "scheduled"
)

// MeetingAccess says which members join without knocking.
type MeetingAccess string

// Meeting access settings.
const (
	// AccessWorkspace: every member of the workspace joins.
	AccessWorkspace MeetingAccess = "workspace"
	// AccessInvited: only the invitees (and the hosts) join; other members knock.
	AccessInvited MeetingAccess = "invited"
)

// Valid reports whether a is a known access setting.
func (a MeetingAccess) Valid() bool { return a == AccessWorkspace || a == AccessInvited }

// GuestMode says what people without a membership may do.
type GuestMode string

// Guest modes.
const (
	GuestsOff   GuestMode = "off"   // they can't even knock
	GuestsKnock GuestMode = "knock" // they wait to be admitted
	GuestsOpen  GuestMode = "open"  // they join without waiting, until the session ends
)

// Valid reports whether g is a known guest mode.
func (g GuestMode) Valid() bool { return g == GuestsOff || g == GuestsKnock || g == GuestsOpen }

// MeetingLanguages are the languages a meeting's notes may be heard in;
// "auto" lets the speech service decide.
var MeetingLanguages = []string{"auto", "en", "ru", "uz"}

// Meeting is a meeting link and its settings.
type Meeting struct {
	ID          int64
	WorkspaceID int64
	Code        string // 10 lowercase letters; FormatMeetingCode shows it
	Title       string
	Description string
	HostID      *int64
	HostName    string // read with the meeting
	Kind        MeetingKind
	StartsAt    *time.Time // scheduled only
	DurationMin int
	TimeZone    string
	Access      MeetingAccess
	Guests      GuestMode
	Locked      bool
	AutoRecord  bool
	AutoNotes   bool
	Language    string
	ICSSequence int
	CancelledAt *time.Time
	CreatedAt   time.Time
	UpdatedAt   time.Time
	// Read with the meeting.
	CohostIDs []int64
	Live      *MeetingSession // the session now live, if any
	InCall    int             // people in the live session
}

// EndsAt is when a scheduled meeting is planned to end.
func (m Meeting) EndsAt() *time.Time {
	if m.StartsAt == nil {
		return nil
	}
	t := m.StartsAt.Add(time.Duration(m.DurationMin) * time.Minute)
	return &t
}

// IsHost reports whether userID is the meeting's host.
func (m Meeting) IsHost(userID int64) bool { return m.HostID != nil && *m.HostID == userID }

// IsCohost reports whether userID is one of the meeting's co-hosts.
func (m Meeting) IsCohost(userID int64) bool {
	for _, id := range m.CohostIDs {
		if id == userID {
			return true
		}
	}
	return false
}

// MeetingEarlyJoin is how long before its start a scheduled meeting can be
// joined by people other than its hosts.
const MeetingEarlyJoin = 15 * time.Minute

// Limits of meetings.
const (
	MeetingMaxTitle       = 200
	MeetingMaxDescription = 4000
	MeetingMaxInvitees    = 200
	MeetingMaxMessage     = 2000
	MeetingMaxName        = 80
	// MeetingKnockWait is how long a knock waits before it expires.
	MeetingKnockWait = 10 * time.Minute
	// MeetingDenyCooldown is how long a denied person waits to knock again.
	MeetingDenyCooldown = 5 * time.Minute
	// MeetingUnconnected is how long a session may wait for its first
	// connection before it is closed (someone opened the lobby and left).
	MeetingUnconnected = 2 * time.Minute
	// MeetingDeparture is how long a room lives after the last person
	// leaves, so a dropped connection comes back to the same session.
	MeetingDeparture = 2 * time.Minute
)

// ErrMeetingInvalid wraps the reasons a meeting's input is refused.
var ErrMeetingInvalid = errors.New("invalid meeting")

func meetingInvalid(format string, args ...any) error {
	return fmt.Errorf("%w: %s", ErrMeetingInvalid, fmt.Sprintf(format, args...))
}

// MeetingInput is what a person sets when they create or change a meeting.
type MeetingInput struct {
	Title       string
	Description string
	Kind        MeetingKind
	StartsAt    *time.Time
	DurationMin int
	TimeZone    string
	Access      MeetingAccess
	Guests      GuestMode
	AutoRecord  bool
	AutoNotes   bool
	Language    string
}

// Clean validates in and fills its defaults; now is for "starts in the past".
func (in *MeetingInput) Clean(now time.Time, creating bool) error {
	in.Title = strings.TrimSpace(in.Title)
	in.Description = strings.TrimSpace(strings.ReplaceAll(in.Description, "\r\n", "\n"))
	switch {
	case !utf8.ValidString(in.Title) || !utf8.ValidString(in.Description):
		return meetingInvalid("the text is not valid UTF-8")
	case utf8.RuneCountInString(in.Title) > MeetingMaxTitle:
		return meetingInvalid("the title is longer than %d characters", MeetingMaxTitle)
	case utf8.RuneCountInString(in.Description) > MeetingMaxDescription:
		return meetingInvalid("the description is longer than %d characters", MeetingMaxDescription)
	}
	if in.Kind == "" {
		in.Kind = MeetingInstant
	}
	if in.Kind != MeetingInstant && in.Kind != MeetingScheduled {
		return meetingInvalid("kind is instant or scheduled")
	}
	if in.DurationMin == 0 {
		in.DurationMin = 30
	}
	if in.DurationMin < 5 || in.DurationMin > 720 {
		return meetingInvalid("the duration is 5 to 720 minutes")
	}
	if in.TimeZone == "" {
		in.TimeZone = "UTC"
	}
	if _, err := time.LoadLocation(in.TimeZone); err != nil {
		return meetingInvalid("unknown time zone %q", in.TimeZone)
	}
	if in.Kind == MeetingScheduled {
		if in.StartsAt == nil {
			return meetingInvalid("a scheduled meeting needs a start time")
		}
		if creating && in.StartsAt.Before(now.Add(-5*time.Minute)) {
			return meetingInvalid("the start time is in the past")
		}
		t := in.StartsAt.UTC().Truncate(time.Minute)
		in.StartsAt = &t
	} else {
		in.StartsAt = nil
	}
	if in.Access == "" {
		in.Access = AccessWorkspace
		if in.Kind == MeetingScheduled {
			in.Access = AccessInvited
		}
	}
	if !in.Access.Valid() {
		return meetingInvalid("access is workspace or invited")
	}
	if in.Guests == "" {
		in.Guests = GuestsKnock
	}
	if !in.Guests.Valid() {
		return meetingInvalid("guests is off, knock or open")
	}
	if in.Language == "" {
		in.Language = "auto"
	}
	if !containsString(MeetingLanguages, in.Language) {
		return meetingInvalid("language is auto, en, ru or uz")
	}
	if in.Title == "" {
		if in.Kind == MeetingScheduled {
			return meetingInvalid("a scheduled meeting needs a title")
		}
	}
	return nil
}

func containsString(list []string, s string) bool {
	for _, v := range list {
		if v == s {
			return true
		}
	}
	return false
}

// MeetingCodeLen is the number of letters of a meeting code.
const MeetingCodeLen = 10

// NewMeetingCode returns a random meeting code: 10 lowercase letters
// (26^10, about 1.4e14 codes).
func NewMeetingCode() (string, error) {
	const letters = "abcdefghijklmnopqrstuvwxyz"
	b := make([]byte, MeetingCodeLen)
	for i := range b {
		n, err := rand.Int(rand.Reader, big.NewInt(int64(len(letters))))
		if err != nil {
			return "", err
		}
		b[i] = letters[n.Int64()]
	}
	return string(b), nil
}

// FormatMeetingCode shows a code as abc-defg-hij.
func FormatMeetingCode(code string) string {
	if len(code) != MeetingCodeLen {
		return code
	}
	return code[:3] + "-" + code[3:7] + "-" + code[7:]
}

// ParseMeetingCode reads a code as people type or paste it: any case, with
// or without dashes and spaces, or the whole link. ok is false for
// anything that is not a code.
func ParseMeetingCode(s string) (string, bool) {
	s = strings.TrimSpace(s)
	if i := strings.LastIndex(s, "/m/"); i >= 0 {
		s = s[i+3:]
	}
	if i := strings.IndexAny(s, "?#"); i >= 0 {
		s = s[:i]
	}
	var b strings.Builder
	for _, r := range strings.ToLower(s) {
		switch {
		case r >= 'a' && r <= 'z':
			b.WriteRune(r)
		case r == '-' || r == ' ':
		default:
			return "", false
		}
	}
	out := b.String()
	return out, len(out) == MeetingCodeLen
}

// NotesStatus is where a session's notes are.
type NotesStatus string

// Notes statuses.
const (
	NotesNone         NotesStatus = "none"
	NotesRecording    NotesStatus = "recording"    // notes are on; audio is being recorded
	NotesQueued       NotesStatus = "queued"       // the session ended; waiting for transcription
	NotesTranscribing NotesStatus = "transcribing" // Muse is hearing the audio
	NotesWriting      NotesStatus = "writing"      // Muse is writing the notes document
	NotesDone         NotesStatus = "done"
	NotesFailed       NotesStatus = "failed"
)

// MeetingSession is one time a meeting was live.
type MeetingSession struct {
	ID          int64
	WorkspaceID int64
	MeetingID   int64
	Room        string
	StartedAt   time.Time
	ConnectedAt *time.Time
	EndedAt     *time.Time
	// GuestsQuiet: guests can't chat or share their screen (the host's choice).
	GuestsQuiet bool
	NotesOn     bool
	NotesStatus NotesStatus
	NotesError  string
	NotesBy     *int64
	DocumentID  *int64
	// Uploaded: a recording a host uploaded, not a call. People are the
	// members the uploader said are in it.
	Uploaded bool
	People   []int64
	// Read with the session.
	Recording bool // a video recording is running
}

// Live reports whether the session has not ended.
func (s MeetingSession) Live() bool { return s.EndedAt == nil }

// MeetingRoomName is the LiveKit room of a session.
func MeetingRoomName(ws, meeting, session int64) string {
	return fmt.Sprintf("ws%d-m%d-s%d", ws, meeting, session)
}

var roomNameRe = regexp.MustCompile(`^ws(\d+)-m(\d+)-s(\d+)$`)

// ParseMeetingRoomName reads a room name back into its ids.
func ParseMeetingRoomName(name string) (ws, meeting, session int64, ok bool) {
	m := roomNameRe.FindStringSubmatch(name)
	if m == nil {
		return 0, 0, 0, false
	}
	ws, _ = strconv.ParseInt(m[1], 10, 64)
	meeting, _ = strconv.ParseInt(m[2], 10, 64)
	session, _ = strconv.ParseInt(m[3], 10, 64)
	return ws, meeting, session, ws > 0 && meeting > 0 && session > 0
}

// Person is someone in a meeting: a user or a guest of the meeting.
type Person struct {
	UserID  int64 // 0 for a guest
	GuestID int64 // 0 for a user
}

// Key is the person as clients name them: u<id> or g<id>.
func (p Person) Key() string {
	if p.UserID != 0 {
		return "u" + strconv.FormatInt(p.UserID, 10)
	}
	return "g" + strconv.FormatInt(p.GuestID, 10)
}

// IsGuest reports whether p is a guest.
func (p Person) IsGuest() bool { return p.UserID == 0 }

// ParsePersonKey reads u<id> or g<id>.
func ParsePersonKey(s string) (Person, bool) {
	if len(s) < 2 {
		return Person{}, false
	}
	id, err := strconv.ParseInt(s[1:], 10, 64)
	if err != nil || id <= 0 {
		return Person{}, false
	}
	switch s[0] {
	case 'u':
		return Person{UserID: id}, true
	case 'g':
		return Person{GuestID: id}, true
	}
	return Person{}, false
}

var deviceRe = regexp.MustCompile(`^[a-z0-9]{4,16}$`)

// CleanDevice returns a client's device id if it is one (4–16 lowercase
// letters and digits), else a new random one.
func CleanDevice(s string) string {
	s = strings.ToLower(strings.TrimSpace(s))
	if deviceRe.MatchString(s) {
		return s
	}
	b := make([]byte, 8)
	for i := range b {
		n, _ := rand.Int(rand.Reader, big.NewInt(36))
		b[i] = "abcdefghijklmnopqrstuvwxyz0123456789"[n.Int64()]
	}
	return string(b)
}

// MeetingIdentity is one connection's LiveKit identity: the person and
// their device, so two devices of one person are two participants.
func MeetingIdentity(p Person, device string) string { return p.Key() + "-" + device }

// ParseMeetingIdentity reads an identity back into the person and device.
func ParseMeetingIdentity(identity string) (Person, string, bool) {
	key, device, ok := strings.Cut(identity, "-")
	if !ok || !deviceRe.MatchString(device) {
		return Person{}, "", false
	}
	p, ok := ParsePersonKey(key)
	return p, device, ok
}

// MeetingRole is what a person is in a call.
type MeetingRole string

// Roles in a call.
const (
	RoleHost   MeetingRole = "host"
	RoleCohost MeetingRole = "cohost"
	RoleMember MeetingRole = "member"
	RoleGuest  MeetingRole = "guest"
)

// RoleIn is p's role in meeting m: wsRole is their role in the meeting's
// workspace ("" when they are not a member, which makes them a guest even
// with an account).
func RoleIn(m Meeting, p Person, wsRole WorkspaceRole) MeetingRole {
	switch {
	case p.IsGuest() || wsRole == "":
		return RoleGuest
	case m.IsHost(p.UserID):
		return RoleHost
	case m.IsCohost(p.UserID):
		return RoleCohost
	}
	return RoleMember
}

// Rights are what a role may do in a call. One table for the LiveKit
// token, the API and what the clients show.
type Rights struct {
	Publish       bool // camera and microphone
	ScreenShare   bool
	Chat          bool
	Admit         bool // admit and deny knocks
	Moderate      bool // mute, remove, lock, lower hands
	Record        bool // start and stop recording and notes
	ManageCohosts bool // make co-hosts, change access, end for everyone
}

// RightsOf is what role may do in meeting m. guestsQuiet turns guests'
// chat and screen sharing off (the host's choice in the call).
func RightsOf(role MeetingRole, guestsQuiet bool) Rights {
	switch role {
	case RoleHost:
		return Rights{Publish: true, ScreenShare: true, Chat: true, Admit: true, Moderate: true, Record: true, ManageCohosts: true}
	case RoleCohost:
		return Rights{Publish: true, ScreenShare: true, Chat: true, Admit: true, Moderate: true, Record: true}
	case RoleMember:
		return Rights{Publish: true, ScreenShare: true, Chat: true}
	}
	return Rights{Publish: true, ScreenShare: !guestsQuiet, Chat: !guestsQuiet}
}

// JoinOutcome is what happens when someone asks to join.
type JoinOutcome string

// Join outcomes.
const (
	JoinNow     JoinOutcome = "join"
	JoinKnock   JoinOutcome = "knock"
	JoinRefused JoinOutcome = "refused"
)

// Reasons a join is refused (the API's codes).
const (
	RefuseCancelled = "cancelled"
	RefuseNotYet    = "not_started"
	RefuseLocked    = "locked"
	RefuseFull      = "full"
	RefuseRemoved   = "removed"
	RefuseGuestsOff = "guests_off"
	RefuseDenied    = "denied" // denied a moment ago; wait before knocking again
)

// JoinRequest is everything DecideJoin weighs.
type JoinRequest struct {
	Meeting Meeting
	Person  Person
	// WorkspaceRole is the person's role in the meeting's workspace, ""
	// when they are not a member.
	WorkspaceRole WorkspaceRole
	Invited       bool // an invitee (a member, or with their invitation link)
	// Admitted: already let into this session (a seat, an admitted knock).
	Admitted bool
	Removed  bool // removed from this session
	// DeniedRecently: a knock of theirs was denied within the cooldown.
	DeniedRecently bool
	InCall         int // people in the session now
	MaxPeople      int // the workspace's limit, 0 for none
	Now            time.Time
}

// JoinDecision is the outcome and, for a refusal, its reason.
type JoinDecision struct {
	Outcome JoinOutcome
	Reason  string
	Role    MeetingRole
}

// DecideJoin decides whether a person joins a meeting now, knocks, or is
// refused. The rules, in order:
//
//   - a cancelled meeting takes nobody; a removed person can't come back;
//   - hosts and co-hosts (and the workspace's owner) always join;
//   - a scheduled meeting takes others from 15 minutes before its start;
//   - a locked meeting takes nobody new; a full one nobody at all;
//   - someone already admitted to this session joins again;
//   - members join under workspace access, invitees under both;
//   - other members knock; guests knock or join by the guest mode.
func DecideJoin(r JoinRequest) JoinDecision {
	m := r.Meeting
	role := RoleIn(m, r.Person, r.WorkspaceRole)
	d := func(o JoinOutcome, reason string) JoinDecision {
		return JoinDecision{Outcome: o, Reason: reason, Role: role}
	}
	if m.CancelledAt != nil {
		return d(JoinRefused, RefuseCancelled)
	}
	if r.Removed {
		return d(JoinRefused, RefuseRemoved)
	}
	full := r.MaxPeople > 0 && r.InCall >= r.MaxPeople
	if role == RoleHost || role == RoleCohost || r.WorkspaceRole == RoleOwner {
		if full {
			return d(JoinRefused, RefuseFull)
		}
		return d(JoinNow, "")
	}
	if m.Kind == MeetingScheduled && m.StartsAt != nil && r.Now.Before(m.StartsAt.Add(-MeetingEarlyJoin)) {
		return d(JoinRefused, RefuseNotYet)
	}
	if full {
		return d(JoinRefused, RefuseFull)
	}
	if r.Admitted {
		return d(JoinNow, "")
	}
	if m.Locked {
		return d(JoinRefused, RefuseLocked)
	}
	if role == RoleMember && (m.Access == AccessWorkspace || r.Invited) {
		return d(JoinNow, "")
	}
	if role == RoleGuest && r.Invited {
		return d(JoinNow, "")
	}
	if role == RoleGuest {
		switch m.Guests {
		case GuestsOff:
			return d(JoinRefused, RefuseGuestsOff)
		case GuestsOpen:
			return d(JoinNow, "")
		}
	}
	if r.DeniedRecently {
		return d(JoinRefused, RefuseDenied)
	}
	return d(JoinKnock, "")
}

// MeetingSeat is one person's right to be in a session from one device.
type MeetingSeat struct {
	ID        int64
	SessionID int64
	Person    Person
	Device    string
	Name      string
	Knocked   bool
	RemovedAt *time.Time
	CreatedAt time.Time
}

// Identity is the seat's LiveKit identity.
func (s MeetingSeat) Identity() string { return MeetingIdentity(s.Person, s.Device) }

// KnockState is where a knock is.
type KnockState string

// Knock states.
const (
	KnockWaiting  KnockState = "waiting"
	KnockAdmitted KnockState = "admitted"
	KnockDenied   KnockState = "denied"
	KnockExpired  KnockState = "expired"
)

// MeetingKnock is someone waiting to be let in.
type MeetingKnock struct {
	ID        int64
	SessionID int64
	Person    Person
	Device    string
	Name      string
	Email     string // a guest's, when Google or an account vouched for them
	State     KnockState
	SeatID    *int64
	CreatedAt time.Time
}

// MeetingGuest is a guest of a meeting.
type MeetingGuest struct {
	ID        int64
	MeetingID int64
	Name      string
	Email     string
	Via       GuestVia
	UserID    *int64
	InviteeID *int64
	CreatedAt time.Time
}

// GuestByInvite is a guest who came with an invitee's personal link.
const GuestByInvite GuestVia = "invite"

// CleanPersonName trims a name typed in the lobby.
func CleanPersonName(s string) (string, error) {
	s = strings.Join(strings.Fields(s), " ")
	switch {
	case s == "":
		return "", meetingInvalid("type your name")
	case !utf8.ValidString(s):
		return "", meetingInvalid("the name is not valid UTF-8")
	case utf8.RuneCountInString(s) > MeetingMaxName:
		return "", meetingInvalid("the name is longer than %d characters", MeetingMaxName)
	}
	return s, nil
}

// MeetingParticipant is one connection to a session, from LiveKit's webhooks.
type MeetingParticipant struct {
	ID        int64
	SessionID int64
	Identity  string
	Person    Person
	Name      string
	JoinedAt  time.Time
	LeftAt    *time.Time
}

// MeetingAttendee is one person's time in a session, their connections
// summed.
type MeetingAttendee struct {
	Person    Person
	Name      string
	FirstIn   time.Time
	LastOut   *time.Time // nil while still in the call
	Seconds   int64
	IsGuest   bool
	GuestMail string
}

// MeetingMessage is one chat message of a session.
type MeetingMessage struct {
	ID        int64
	SessionID int64
	Person    Person
	Name      string
	Body      string
	CreatedAt time.Time
}

// CleanChatMessage trims a chat message and checks its length.
func CleanChatMessage(s string) (string, error) {
	s = strings.TrimSpace(strings.ReplaceAll(s, "\r\n", "\n"))
	switch {
	case s == "":
		return "", meetingInvalid("the message is empty")
	case !utf8.ValidString(s):
		return "", meetingInvalid("the message is not valid UTF-8")
	case utf8.RuneCountInString(s) > MeetingMaxMessage:
		return "", meetingInvalid("a message is at most %d characters", MeetingMaxMessage)
	}
	return s, nil
}

// MediaKind is what a meeting file holds.
type MediaKind string

// Media kinds.
const (
	MediaRecording  MediaKind = "recording"   // the call as video (MP4)
	MediaAudioMixed MediaKind = "audio-mixed" // everyone's audio in one file, for notes
	MediaAudio      MediaKind = "audio"       // one microphone, for notes per speaker
	// MediaUpload is a recording a host uploaded: until its sound is
	// taken out (see meetings.Service.Upload) the file as sent, then an
	// Ogg of its sound only.
	MediaUpload MediaKind = "upload"
)

// MediaStatus is where a meeting file is.
type MediaStatus string

// Media statuses.
const (
	MediaActive  MediaStatus = "active"
	MediaReady   MediaStatus = "ready"
	MediaFailed  MediaStatus = "failed"
	MediaExpired MediaStatus = "expired"
	MediaDeleted MediaStatus = "deleted"
)

// MeetingMedia is a file LiveKit Egress writes for a session.
type MeetingMedia struct {
	ID        int64
	SessionID int64
	Kind      MediaKind
	EgressID  string
	Identity  string
	File      string // the name in the meetings directory
	Bytes     int64
	StartedAt time.Time
	EndedAt   *time.Time
	Status    MediaStatus
	StartedBy *int64
	Error     string
}

// Seconds is how long the file runs, 0 while it is being written.
func (m MeetingMedia) Seconds() int64 {
	if m.EndedAt == nil {
		return 0
	}
	return int64(m.EndedAt.Sub(m.StartedAt).Seconds())
}

// MeetingSegment is a stretch of what was said.
type MeetingSegment struct {
	ID       int64
	Identity string // empty when speakers are unknown
	Name     string
	StartMS  int
	EndMS    int
	Text     string
}

// ActionItem is something someone in a meeting is to do.
type ActionItem struct {
	ID        int64
	SessionID int64
	Position  int
	Text      string
	Who       string // as said, not an account
	Due       string // as said
	AtMS      *int   // when it was said, from the session's start
	Quote     string
	// Speaker is who said the line where it was taken, as the transcript
	// names them; empty when the transcript does not say who spoke.
	Speaker string
	// WhoUserID is the member who takes it: matched from Who (or Speaker),
	// or picked by hand (WhoSetBy). nil when nobody matched.
	WhoUserID *int64
	WhoSetBy  *int64
	// Drafted: its draft ticket was made. A person deleting that ticket
	// does not bring another.
	Drafted   bool
	TicketID  *int64
	TicketKey string // read with the item
	WhoName   string // read with the item: WhoUserID's name
}

// Limits of action items, as the notes generation writes them.
const (
	ActionItemsMax     = 50
	ActionItemMaxText  = 300
	ActionItemMaxQuote = 500
)

// CleanActionItems checks and trims the action items a generation wrote,
// dropping empty ones; the positions are their order.
func CleanActionItems(in []ActionItem) ([]ActionItem, error) {
	if len(in) > ActionItemsMax {
		return nil, fmt.Errorf("more than %d action items", ActionItemsMax)
	}
	out := make([]ActionItem, 0, len(in))
	for _, it := range in {
		it.Text = truncateRunes(strings.TrimSpace(it.Text), ActionItemMaxText)
		if it.Text == "" {
			continue
		}
		it.Who = truncateRunes(strings.TrimSpace(it.Who), 100)
		it.Speaker = truncateRunes(strings.TrimSpace(it.Speaker), 100)
		it.Due = truncateRunes(strings.TrimSpace(it.Due), 100)
		it.Quote = truncateRunes(strings.TrimSpace(it.Quote), ActionItemMaxQuote)
		if it.AtMS != nil && *it.AtMS < 0 {
			it.AtMS = nil
		}
		it.Position = len(out)
		out = append(out, it)
	}
	return out, nil
}

// SameActionItem reports whether a new action item is one kept from an
// earlier writing of the notes (it has a ticket someone works on): the
// same text, the same quote, or said within 30 seconds by the same person.
func SameActionItem(kept, it ActionItem) bool {
	switch {
	case strings.EqualFold(kept.Text, it.Text):
		return true
	case kept.Quote != "" && strings.EqualFold(kept.Quote, it.Quote):
		return true
	case kept.AtMS != nil && it.AtMS != nil && FoldName(kept.Who) == FoldName(it.Who):
		d := *kept.AtMS - *it.AtMS
		return d >= -30_000 && d <= 30_000
	}
	return false
}

// FormatOffset shows a time from the session's start as m:ss or h:mm:ss.
func FormatOffset(ms int) string {
	s := ms / 1000
	if s >= 3600 {
		return fmt.Sprintf("%d:%02d:%02d", s/3600, s/60%60, s%60)
	}
	return fmt.Sprintf("%d:%02d", s/60, s%60)
}

// MeetingNotesInput is what the notes of a session are written from.
type MeetingNotesInput struct {
	Meeting   Meeting
	Session   MeetingSession
	Attendees []MeetingAttendee
	Segments  []MeetingSegment
	Messages  []MeetingMessage
	// Speakers says whether segments name who spoke (per-speaker audio).
	Speakers bool
	// People are the members an uploaded recording's uploader said are in
	// it (an upload has no attendance).
	People []string
}

// Invitee is someone invited to a meeting: a member or an email address.
type Invitee struct {
	ID         int64
	MeetingID  int64
	UserID     *int64
	Email      string
	Name       string // the member's, read with the invitee
	RSVP       string
	RemindedAt *time.Time
}

// RSVP answers.
const (
	RSVPNone  = "none"
	RSVPYes   = "yes"
	RSVPNo    = "no"
	RSVPMaybe = "maybe"
)

// ValidRSVP reports whether s is an answer a person may give.
func ValidRSVP(s string) bool { return s == RSVPYes || s == RSVPNo || s == RSVPMaybe }

var emailRe = regexp.MustCompile(`^[^@\s]+@[^@\s]+\.[^@\s]+$`)

// CleanInviteEmail lower-cases and checks an invitee's address.
func CleanInviteEmail(s string) (string, error) {
	s = strings.ToLower(strings.TrimSpace(s))
	if len(s) > 254 || !emailRe.MatchString(s) {
		return "", meetingInvalid("%q is not an email address", s)
	}
	return s, nil
}

// Events about meetings, sent to people's live streams (not stored).
const (
	EventMeetingLive     = "meeting_live"     // a meeting you're invited to went live
	EventMeetingEnded    = "meeting_ended"    // a session ended
	EventMeetingKnock    = "meeting_knock"    // someone knocks and you can admit them
	EventMeetingCalling  = "meeting_calling"  // someone rings you into a meeting
	EventMeetingNotes    = "meeting_notes"    // a session's notes are ready (or failed)
	EventMeetingReminder = "meeting_reminder" // a meeting you're invited to starts soon
	EventMeetings        = "meetings_changed"
)
