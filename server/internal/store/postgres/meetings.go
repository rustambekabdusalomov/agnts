package postgres

import (
	"context"
	"errors"
	"fmt"
	"strings"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgconn"
	"github.com/jackc/pgx/v5/pgxpool"

	"agnts/internal/domain"
)

// Meetings is the store of meetings, their sessions and what happened in
// them.
type Meetings struct{ db *pgxpool.Pool }

// NewMeetings returns the meeting store.
func NewMeetings(db *pgxpool.Pool) *Meetings { return &Meetings{db: db} }

// ErrCodeTaken means a new meeting's code is already used; pick another.
var ErrCodeTaken = errors.New("meeting code taken")

const meetingCols = `m.id, m.workspace_id, m.code, m.title, m.description, m.host_id, COALESCE(NULLIF(u.display_name, ''), u.username, ''),
	m.kind, m.starts_at, m.duration_min, m.time_zone, m.access, m.guests, m.locked, m.auto_record, m.auto_notes, m.language,
	m.ics_sequence, m.cancelled_at, m.created_at, m.updated_at,
	COALESCE((SELECT array_agg(c.user_id ORDER BY c.user_id) FROM meeting_cohosts c WHERE c.meeting_id = m.id), '{}'),
	s.id, s.room, s.started_at, s.connected_at, s.guests_quiet, s.notes_on, s.notes_status,
	(SELECT count(DISTINCT COALESCE('u' || p.user_id, 'g' || p.guest_id)) FROM meeting_participants p WHERE p.session_id = s.id AND p.left_at IS NULL),
	EXISTS (SELECT 1 FROM meeting_media r WHERE r.session_id = s.id AND r.kind = 'recording' AND r.status = 'active')`

const meetingFrom = ` FROM meetings m LEFT JOIN users u ON u.id = m.host_id
	LEFT JOIN meeting_sessions s ON s.meeting_id = m.id AND s.ended_at IS NULL`

func scanMeeting(row pgx.Row) (domain.Meeting, error) {
	var m domain.Meeting
	var kind, access, guests string
	var sid *int64
	var room *string
	var started *time.Time
	var connected *time.Time
	var quiet *bool
	var notesOn *bool
	var notesStatus *string
	var inCall int
	var recording bool
	err := row.Scan(&m.ID, &m.WorkspaceID, &m.Code, &m.Title, &m.Description, &m.HostID, &m.HostName,
		&kind, &m.StartsAt, &m.DurationMin, &m.TimeZone, &access, &guests, &m.Locked, &m.AutoRecord, &m.AutoNotes, &m.Language,
		&m.ICSSequence, &m.CancelledAt, &m.CreatedAt, &m.UpdatedAt, &m.CohostIDs,
		&sid, &room, &started, &connected, &quiet, &notesOn, &notesStatus, &inCall, &recording)
	if err != nil {
		return m, notFound(err)
	}
	m.Kind, m.Access, m.Guests = domain.MeetingKind(kind), domain.MeetingAccess(access), domain.GuestMode(guests)
	if sid != nil {
		m.Live = &domain.MeetingSession{ID: *sid, WorkspaceID: m.WorkspaceID, MeetingID: m.ID, Room: *room, StartedAt: *started,
			ConnectedAt: connected, GuestsQuiet: *quiet, NotesOn: *notesOn, NotesStatus: domain.NotesStatus(*notesStatus), Recording: recording}
		m.InCall = inCall
	}
	return m, nil
}

// CreateMeeting adds a meeting; ErrCodeTaken when its code is used.
func (s *Meetings) CreateMeeting(ctx context.Context, m domain.Meeting) (domain.Meeting, error) {
	var id int64
	err := s.db.QueryRow(ctx, `INSERT INTO meetings (code, title, description, host_id, kind, starts_at, duration_min, time_zone,
			access, guests, auto_record, auto_notes, language)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13) RETURNING id`,
		m.Code, m.Title, m.Description, m.HostID, string(m.Kind), m.StartsAt, m.DurationMin, m.TimeZone,
		string(m.Access), string(m.Guests), m.AutoRecord, m.AutoNotes, m.Language).Scan(&id)
	var pe *pgconn.PgError
	if errors.As(err, &pe) && pe.Code == "23505" && strings.Contains(pe.ConstraintName, "code") {
		return domain.Meeting{}, ErrCodeTaken
	}
	if err != nil {
		return domain.Meeting{}, err
	}
	return s.Meeting(ctx, id)
}

// Meeting returns a meeting with its live session.
func (s *Meetings) Meeting(ctx context.Context, id int64) (domain.Meeting, error) {
	return scanMeeting(s.db.QueryRow(ctx, `SELECT `+meetingCols+meetingFrom+` WHERE m.id = $1`, id))
}

// MeetingByCode finds a meeting by its code in any workspace: call it in
// the system scope (public links don't name the workspace), then act in
// the meeting's workspace.
func (s *Meetings) MeetingByCode(ctx context.Context, code string) (domain.Meeting, error) {
	return scanMeeting(s.db.QueryRow(ctx, `SELECT `+meetingCols+meetingFrom+` WHERE m.code = $1`, code))
}

// MeetingView is which meetings a list shows.
type MeetingView string

// Meeting views.
const (
	ViewUpcoming MeetingView = "upcoming" // live ones, then scheduled ones that have not ended
	ViewLive     MeetingView = "live"
	ViewMine     MeetingView = "mine" // meetings the person hosts, newest first
	// ViewAgenda: the person's own meetings (host, co-host, or invited and
	// not declined) that are live or start within the next 36 hours and
	// have not ended. The client cuts it to its own today.
	ViewAgenda MeetingView = "agenda"
)

// MeetingFilter picks meetings for one person.
type MeetingFilter struct {
	View   MeetingView
	UserID int64
	Owner  bool // the workspace's owner sees every meeting
	Limit  int
}

// meetingVisibleTo is the condition of meetings user $1 may see (owners: all).
const meetingVisibleTo = `($2 OR m.access = 'workspace' OR m.host_id = $1
	OR EXISTS (SELECT 1 FROM meeting_cohosts c WHERE c.meeting_id = m.id AND c.user_id = $1)
	OR EXISTS (SELECT 1 FROM meeting_invitees i WHERE i.meeting_id = m.id AND i.user_id = $1)
	OR EXISTS (SELECT 1 FROM meeting_participants p JOIN meeting_sessions ps ON ps.id = p.session_id
	           WHERE ps.meeting_id = m.id AND p.user_id = $1)
	OR EXISTS (SELECT 1 FROM meeting_sessions us WHERE us.meeting_id = m.id AND $1 = ANY(us.people)))`

// ListMeetings returns the meetings a person sees in a view.
func (s *Meetings) ListMeetings(ctx context.Context, f MeetingFilter) ([]domain.Meeting, error) {
	if f.Limit <= 0 || f.Limit > 200 {
		f.Limit = 100
	}
	where, order := "", ""
	switch f.View {
	case ViewLive:
		where, order = `s.id IS NOT NULL`, `s.started_at DESC`
	case ViewMine:
		where, order = `m.host_id = $1 AND m.cancelled_at IS NULL`, `m.created_at DESC`
	case ViewAgenda:
		where = `m.cancelled_at IS NULL AND (m.host_id = $1
			OR EXISTS (SELECT 1 FROM meeting_cohosts c WHERE c.meeting_id = m.id AND c.user_id = $1)
			OR EXISTS (SELECT 1 FROM meeting_invitees i WHERE i.meeting_id = m.id AND i.user_id = $1 AND i.rsvp <> 'no'))
			AND (s.id IS NOT NULL OR (m.kind = 'scheduled' AND m.starts_at < now() + interval '36 hours'
				AND m.starts_at + make_interval(mins => m.duration_min) > now()))`
		order = `(s.id IS NULL), COALESCE(m.starts_at, s.started_at)`
	default:
		where = `m.cancelled_at IS NULL AND (s.id IS NOT NULL OR (m.kind = 'scheduled'
			AND m.starts_at + make_interval(mins => m.duration_min) > now()))`
		order = `(s.id IS NULL), COALESCE(m.starts_at, s.started_at)`
	}
	rows, err := s.db.Query(ctx, `SELECT `+meetingCols+meetingFrom+` WHERE `+where+` AND `+meetingVisibleTo+
		` ORDER BY `+order+` LIMIT `+fmt.Sprint(f.Limit), f.UserID, f.Owner)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := []domain.Meeting{}
	for rows.Next() {
		m, err := scanMeeting(rows)
		if err != nil {
			return nil, err
		}
		out = append(out, m)
	}
	return out, rows.Err()
}

// CanSeeMeeting reports whether a person may see a meeting.
func (s *Meetings) CanSeeMeeting(ctx context.Context, id, userID int64, owner bool) (bool, error) {
	var ok bool
	err := s.db.QueryRow(ctx, `SELECT EXISTS (SELECT 1 FROM meetings m WHERE m.id = $3 AND `+meetingVisibleTo+`)`, userID, owner, id).Scan(&ok)
	return ok, err
}

// UpdateMeeting changes a meeting's settings. bump raises its calendar
// sequence (the time or place changed, so invitations are sent again).
func (s *Meetings) UpdateMeeting(ctx context.Context, id int64, in domain.MeetingInput, bump bool) (domain.Meeting, error) {
	inc := 0
	if bump {
		inc = 1
	}
	tag, err := s.db.Exec(ctx, `UPDATE meetings SET title = $2, description = $3, kind = $4, starts_at = $5, duration_min = $6,
			time_zone = $7, access = $8, guests = $9, auto_record = $10, auto_notes = $11, language = $12,
			ics_sequence = ics_sequence + $13, updated_at = now()
		WHERE id = $1`, id, in.Title, in.Description, string(in.Kind), in.StartsAt, in.DurationMin, in.TimeZone,
		string(in.Access), string(in.Guests), in.AutoRecord, in.AutoNotes, in.Language, inc)
	if err != nil {
		return domain.Meeting{}, err
	}
	if tag.RowsAffected() == 0 {
		return domain.Meeting{}, domain.ErrNotFound
	}
	return s.Meeting(ctx, id)
}

// SetMeetingLocked locks or unlocks a meeting.
func (s *Meetings) SetMeetingLocked(ctx context.Context, id int64, locked bool) error {
	return s.exec1(ctx, `UPDATE meetings SET locked = $2, updated_at = now() WHERE id = $1`, id, locked)
}

// SetMeetingGuests changes who without a membership may come in.
func (s *Meetings) SetMeetingGuests(ctx context.Context, id int64, g domain.GuestMode) error {
	return s.exec1(ctx, `UPDATE meetings SET guests = $2, updated_at = now() WHERE id = $1`, id, string(g))
}

// SetMeetingHost hands a meeting to another member; they stop being a
// co-host if they were one.
func (s *Meetings) SetMeetingHost(ctx context.Context, id, userID int64) error {
	return pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		if _, err := tx.Exec(ctx, `DELETE FROM meeting_cohosts WHERE meeting_id = $1 AND user_id = $2`, id, userID); err != nil {
			return err
		}
		tag, err := tx.Exec(ctx, `UPDATE meetings SET host_id = $2, updated_at = now() WHERE id = $1`, id, userID)
		if err == nil && tag.RowsAffected() == 0 {
			return domain.ErrNotFound
		}
		return err
	})
}

// HostlessMeetings moves the meetings of a member who left (hostless
// ones too) to the workspace's owner.
func (s *Meetings) HostlessMeetings(ctx context.Context, owner int64) (int64, error) {
	tag, err := s.db.Exec(ctx, `UPDATE meetings m SET host_id = $1, updated_at = now()
		WHERE m.host_id IS NULL OR NOT EXISTS (SELECT 1 FROM memberships ms WHERE ms.workspace_id = m.workspace_id AND ms.user_id = m.host_id)`, owner)
	return tag.RowsAffected(), err
}

// SetCohost makes a member a co-host, or not.
func (s *Meetings) SetCohost(ctx context.Context, id, userID int64, on bool) error {
	var err error
	if on {
		_, err = s.db.Exec(ctx, `INSERT INTO meeting_cohosts (meeting_id, user_id) VALUES ($1, $2) ON CONFLICT DO NOTHING`, id, userID)
	} else {
		_, err = s.db.Exec(ctx, `DELETE FROM meeting_cohosts WHERE meeting_id = $1 AND user_id = $2`, id, userID)
	}
	return err
}

// CancelMeeting cancels a scheduled meeting; its sequence goes up so the
// cancellation replaces the invitation in calendars.
func (s *Meetings) CancelMeeting(ctx context.Context, id int64) error {
	return s.exec1(ctx, `UPDATE meetings SET cancelled_at = now(), ics_sequence = ics_sequence + 1, updated_at = now()
		WHERE id = $1 AND cancelled_at IS NULL`, id)
}

// DeleteMeeting deletes a meeting with its sessions and what they hold;
// it returns the names of the files to delete.
func (s *Meetings) DeleteMeeting(ctx context.Context, id int64) ([]string, error) {
	var files []string
	err := pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		rows, err := tx.Query(ctx, `SELECT r.file FROM meeting_media r JOIN meeting_sessions ss ON ss.id = r.session_id
			WHERE ss.meeting_id = $1 AND r.status IN ('active', 'ready', 'failed')`, id)
		if err != nil {
			return err
		}
		files, err = pgx.CollectRows(rows, pgx.RowTo[string])
		if err != nil {
			return err
		}
		tag, err := tx.Exec(ctx, `DELETE FROM meetings WHERE id = $1`, id)
		if err == nil && tag.RowsAffected() == 0 {
			return domain.ErrNotFound
		}
		return err
	})
	return files, err
}

func (s *Meetings) exec1(ctx context.Context, sql string, args ...any) error {
	tag, err := s.db.Exec(ctx, sql, args...)
	if err != nil {
		return err
	}
	if tag.RowsAffected() == 0 {
		return domain.ErrNotFound
	}
	return nil
}

// --- Invitees ---

// NewInvitee is someone to invite: a member, or an address with the hash
// of their personal link's token.
type NewInvitee struct {
	UserID    *int64
	Email     string
	TokenHash []byte
}

// AddInvitees invites people who are not invited yet and returns those
// added (with their ids).
func (s *Meetings) AddInvitees(ctx context.Context, meetingID int64, in []NewInvitee) ([]domain.Invitee, error) {
	var out []domain.Invitee
	err := pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		for _, n := range in {
			var id int64
			var err error
			if n.UserID != nil {
				err = tx.QueryRow(ctx, `INSERT INTO meeting_invitees (meeting_id, user_id) VALUES ($1, $2)
					ON CONFLICT (meeting_id, user_id) WHERE user_id IS NOT NULL DO NOTHING RETURNING id`, meetingID, *n.UserID).Scan(&id)
			} else {
				err = tx.QueryRow(ctx, `INSERT INTO meeting_invitees (meeting_id, email, token_hash) VALUES ($1, $2, $3)
					ON CONFLICT (meeting_id, lower(email)) WHERE email <> '' DO NOTHING RETURNING id`, meetingID, n.Email, n.TokenHash).Scan(&id)
			}
			if errors.Is(err, pgx.ErrNoRows) {
				continue
			}
			if err != nil {
				return err
			}
			out = append(out, domain.Invitee{ID: id, MeetingID: meetingID, UserID: n.UserID, Email: n.Email, RSVP: domain.RSVPNone})
		}
		return nil
	})
	return out, err
}

// RemoveInvitees uninvites people by invitee id.
func (s *Meetings) RemoveInvitees(ctx context.Context, meetingID int64, ids []int64) error {
	_, err := s.db.Exec(ctx, `DELETE FROM meeting_invitees WHERE meeting_id = $1 AND id = ANY($2)`, meetingID, ids)
	return err
}

// Invitees returns a meeting's invitees, members first.
func (s *Meetings) Invitees(ctx context.Context, meetingID int64) ([]domain.Invitee, error) {
	rows, err := s.db.Query(ctx, `SELECT i.id, i.meeting_id, i.user_id, CASE WHEN i.user_id IS NULL THEN i.email ELSE COALESCE(u.email, '') END,
			COALESCE(NULLIF(u.display_name, ''), u.username, ''), i.rsvp, i.reminded_at
		FROM meeting_invitees i LEFT JOIN users u ON u.id = i.user_id
		WHERE i.meeting_id = $1 ORDER BY (i.user_id IS NULL), lower(COALESCE(NULLIF(u.display_name, ''), u.username, i.email))`, meetingID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := []domain.Invitee{}
	for rows.Next() {
		var i domain.Invitee
		if err := rows.Scan(&i.ID, &i.MeetingID, &i.UserID, &i.Email, &i.Name, &i.RSVP, &i.RemindedAt); err != nil {
			return nil, err
		}
		out = append(out, i)
	}
	return out, rows.Err()
}

// IsInvited reports whether a member is invited.
func (s *Meetings) IsInvited(ctx context.Context, meetingID, userID int64) (bool, error) {
	var ok bool
	err := s.db.QueryRow(ctx, `SELECT EXISTS (SELECT 1 FROM meeting_invitees WHERE meeting_id = $1 AND user_id = $2)`, meetingID, userID).Scan(&ok)
	return ok, err
}

// InviteeByToken returns the email invitee whose link token hashes to h.
func (s *Meetings) InviteeByToken(ctx context.Context, meetingID int64, h []byte) (domain.Invitee, error) {
	var i domain.Invitee
	err := s.db.QueryRow(ctx, `SELECT id, meeting_id, email, rsvp FROM meeting_invitees WHERE meeting_id = $1 AND token_hash = $2`,
		meetingID, h).Scan(&i.ID, &i.MeetingID, &i.Email, &i.RSVP)
	return i, notFound(err)
}

// SetRSVP records a member's answer.
func (s *Meetings) SetRSVP(ctx context.Context, meetingID, userID int64, rsvp string) error {
	return s.exec1(ctx, `UPDATE meeting_invitees SET rsvp = $3 WHERE meeting_id = $1 AND user_id = $2`, meetingID, userID, rsvp)
}

// SetInviteeToken gives an email invitee a new personal link.
func (s *Meetings) SetInviteeToken(ctx context.Context, id int64, h []byte) error {
	return s.exec1(ctx, `UPDATE meeting_invitees SET token_hash = $2 WHERE id = $1 AND user_id IS NULL`, id, h)
}

// ResetReminders makes the reminders of a meeting due again (its time
// changed).
func (s *Meetings) ResetReminders(ctx context.Context, meetingID int64) error {
	_, err := s.db.Exec(ctx, `UPDATE meeting_invitees SET reminded_at = NULL WHERE meeting_id = $1`, meetingID)
	return err
}

// Reminder is a member to remind of a meeting.
type Reminder struct {
	InviteeID   int64
	WorkspaceID int64
	MeetingID   int64
	UserID      int64
}

// DueReminders returns the members (invitees and hosts) whose reminder
// of a meeting is due, across workspaces: call it in the system scope.
func (s *Meetings) DueReminders(ctx context.Context) ([]Reminder, error) {
	rows, err := s.db.Query(ctx, `SELECT i.id, m.workspace_id, m.id, i.user_id
		FROM meeting_invitees i JOIN meetings m ON m.id = i.meeting_id JOIN users u ON u.id = i.user_id
		WHERE i.user_id IS NOT NULL AND i.reminded_at IS NULL AND i.rsvp <> 'no' AND m.cancelled_at IS NULL AND m.kind = 'scheduled'
		  AND u.meeting_reminder_min > 0 AND m.starts_at > now() - interval '5 minutes'
		  AND m.starts_at <= now() + make_interval(mins => u.meeting_reminder_min)`)
	if err != nil {
		return nil, err
	}
	return pgx.CollectRows(rows, func(r pgx.CollectableRow) (Reminder, error) {
		var x Reminder
		err := r.Scan(&x.InviteeID, &x.WorkspaceID, &x.MeetingID, &x.UserID)
		return x, err
	})
}

// MarkReminded records that a reminder went out; false if another worker
// sent it first.
func (s *Meetings) MarkReminded(ctx context.Context, inviteeID int64) (bool, error) {
	tag, err := s.db.Exec(ctx, `UPDATE meeting_invitees SET reminded_at = now() WHERE id = $1 AND reminded_at IS NULL`, inviteeID)
	return tag.RowsAffected() == 1, err
}

// MeetingReminderMin is a person's reminder setting.
func (s *Meetings) MeetingReminderMin(ctx context.Context, userID int64) (int, error) {
	var n int
	err := s.db.QueryRow(ctx, `SELECT meeting_reminder_min FROM users WHERE id = $1`, userID).Scan(&n)
	return n, notFound(err)
}

// SetMeetingReminderMin changes a person's reminder setting.
func (s *Meetings) SetMeetingReminderMin(ctx context.Context, userID int64, n int) error {
	return s.exec1(ctx, `UPDATE users SET meeting_reminder_min = $2 WHERE id = $1`, userID, n)
}

// --- Sessions ---

const sessionCols = `s.id, s.workspace_id, s.meeting_id, s.room, s.started_at, s.connected_at, s.ended_at, s.guests_quiet, s.notes_on, s.notes_status,
	s.notes_error, s.notes_by, s.document_id, s.uploaded, s.people,
	EXISTS (SELECT 1 FROM meeting_media r WHERE r.session_id = s.id AND r.kind = 'recording' AND r.status = 'active')`

func scanSession(row pgx.Row) (domain.MeetingSession, error) {
	var x domain.MeetingSession
	var st string
	err := row.Scan(&x.ID, &x.WorkspaceID, &x.MeetingID, &x.Room, &x.StartedAt, &x.ConnectedAt, &x.EndedAt, &x.GuestsQuiet, &x.NotesOn, &st,
		&x.NotesError, &x.NotesBy, &x.DocumentID, &x.Uploaded, &x.People, &x.Recording)
	x.NotesStatus = domain.NotesStatus(st)
	return x, notFound(err)
}

// SessionRef is where a session is, read across workspaces.
type SessionRef struct {
	WorkspaceID int64
	MeetingID   int64
	Room        string
}

// SessionWorkspace returns where a session is: call it in the system
// scope (the sweep works across workspaces).
func (s *Meetings) SessionWorkspace(ctx context.Context, id int64) (SessionRef, error) {
	var r SessionRef
	err := s.db.QueryRow(ctx, `SELECT workspace_id, meeting_id, room FROM meeting_sessions WHERE id = $1`, id).Scan(&r.WorkspaceID, &r.MeetingID, &r.Room)
	return r, notFound(err)
}

// SetGuestsQuiet turns guests' chat and screen sharing off (or on) for a session.
func (s *Meetings) SetGuestsQuiet(ctx context.Context, id int64, quiet bool) error {
	return s.exec1(ctx, `UPDATE meeting_sessions SET guests_quiet = $2 WHERE id = $1 AND ended_at IS NULL`, id, quiet)
}

// OpenSession returns the meeting's live session, starting one when
// there is none; created says it is new. Concurrent joins get the same
// session (the live index allows one).
func (s *Meetings) OpenSession(ctx context.Context, meetingID int64) (domain.MeetingSession, bool, error) {
	for range 3 {
		x, err := scanSession(s.db.QueryRow(ctx, `SELECT `+sessionCols+` FROM meeting_sessions s WHERE s.meeting_id = $1 AND s.ended_at IS NULL`, meetingID))
		if err == nil {
			return x, false, nil
		}
		if !errors.Is(err, domain.ErrNotFound) {
			return x, false, err
		}
		var id, ws int64
		err = s.db.QueryRow(ctx, `INSERT INTO meeting_sessions (workspace_id, meeting_id)
			SELECT workspace_id, id FROM meetings WHERE id = $1
			ON CONFLICT (meeting_id) WHERE ended_at IS NULL DO NOTHING RETURNING id, workspace_id`, meetingID).Scan(&id, &ws)
		if errors.Is(err, pgx.ErrNoRows) {
			continue // someone else started it a moment ago
		}
		if err != nil {
			return domain.MeetingSession{}, false, err
		}
		if _, err := s.db.Exec(ctx, `UPDATE meeting_sessions SET room = $2 WHERE id = $1`, id, domain.MeetingRoomName(ws, meetingID, id)); err != nil {
			return domain.MeetingSession{}, false, err
		}
		x, err = s.Session(ctx, id)
		return x, err == nil, err
	}
	return domain.MeetingSession{}, false, errors.New("could not open a session")
}

// Session returns a session.
func (s *Meetings) Session(ctx context.Context, id int64) (domain.MeetingSession, error) {
	return scanSession(s.db.QueryRow(ctx, `SELECT `+sessionCols+` FROM meeting_sessions s WHERE s.id = $1`, id))
}

// Sessions returns a meeting's sessions, newest first.
func (s *Meetings) Sessions(ctx context.Context, meetingID int64, limit int) ([]domain.MeetingSession, error) {
	rows, err := s.db.Query(ctx, `SELECT `+sessionCols+` FROM meeting_sessions s WHERE s.meeting_id = $1 ORDER BY s.started_at DESC LIMIT $2`,
		meetingID, max(1, min(limit, 200)))
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := []domain.MeetingSession{}
	for rows.Next() {
		x, err := scanSession(rows)
		if err != nil {
			return nil, err
		}
		out = append(out, x)
	}
	return out, rows.Err()
}

// MarkConnected records a session's first connection.
func (s *Meetings) MarkConnected(ctx context.Context, id int64, at time.Time) error {
	_, err := s.db.Exec(ctx, `UPDATE meeting_sessions SET connected_at = LEAST(COALESCE(connected_at, $2), $2) WHERE id = $1`, id, at)
	return err
}

// EndSession closes a session and everyone's open attendance. ended is
// false when it had ended already. Notes that were being recorded are
// queued when the session has notes audio.
func (s *Meetings) EndSession(ctx context.Context, id int64, at time.Time) (ended bool, err error) {
	err = pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		tag, err := tx.Exec(ctx, `UPDATE meeting_sessions SET ended_at = GREATEST($2, started_at) WHERE id = $1 AND ended_at IS NULL`, id, at)
		if err != nil || tag.RowsAffected() == 0 {
			return err
		}
		ended = true
		if _, err := tx.Exec(ctx, `UPDATE meeting_participants SET left_at = GREATEST($2, joined_at) WHERE session_id = $1 AND left_at IS NULL`, id, at); err != nil {
			return err
		}
		if _, err := tx.Exec(ctx, `UPDATE meeting_knocks SET state = 'expired', decided_at = now() WHERE session_id = $1 AND state = 'waiting'`, id); err != nil {
			return err
		}
		_, err = tx.Exec(ctx, `UPDATE meeting_sessions SET notes_on = false,
				notes_status = CASE WHEN EXISTS (SELECT 1 FROM meeting_media r WHERE r.session_id = $1 AND r.kind IN ('audio', 'audio-mixed')
				                                 AND r.status IN ('active', 'ready'))
				               THEN 'queued' ELSE 'none' END
			WHERE id = $1 AND notes_status = 'recording'`, id)
		if err != nil {
			return err
		}
		// "open" lets guests in until the session ends.
		_, err = tx.Exec(ctx, `UPDATE meetings SET guests = 'knock' WHERE id = (SELECT meeting_id FROM meeting_sessions WHERE id = $1) AND guests = 'open'`, id)
		return err
	})
	return ended, err
}

// LiveSession is a live session, for the sweeper and the reconciler.
type LiveSession struct {
	ID          int64
	WorkspaceID int64
	MeetingID   int64
	Room        string
	StartedAt   time.Time
	ConnectedAt *time.Time
}

// LiveSessions returns every live session on the server: call it in the
// system scope.
func (s *Meetings) LiveSessions(ctx context.Context) ([]LiveSession, error) {
	rows, err := s.db.Query(ctx, `SELECT id, workspace_id, meeting_id, room, started_at, connected_at FROM meeting_sessions WHERE ended_at IS NULL`)
	if err != nil {
		return nil, err
	}
	return pgx.CollectRows(rows, func(r pgx.CollectableRow) (LiveSession, error) {
		var x LiveSession
		err := r.Scan(&x.ID, &x.WorkspaceID, &x.MeetingID, &x.Room, &x.StartedAt, &x.ConnectedAt)
		return x, err
	})
}

// SetNotes turns a session's notes on (by a person) or off.
func (s *Meetings) SetNotes(ctx context.Context, id int64, on bool, by int64) error {
	if on {
		return s.exec1(ctx, `UPDATE meeting_sessions SET notes_on = true, notes_by = COALESCE(notes_by, $2),
			notes_status = CASE WHEN notes_status IN ('none', 'failed') THEN 'recording' ELSE notes_status END, notes_error = ''
			WHERE id = $1 AND ended_at IS NULL`, id, by)
	}
	return s.exec1(ctx, `UPDATE meeting_sessions SET notes_on = false WHERE id = $1`, id)
}

// SetNotesStatus moves a session's notes on.
func (s *Meetings) SetNotesStatus(ctx context.Context, id int64, st domain.NotesStatus, msg string) error {
	return s.exec1(ctx, `UPDATE meeting_sessions SET notes_status = $2, notes_error = $3 WHERE id = $1`, id, string(st), msg)
}

// SetNotesDocument records the document a session's notes are written in.
func (s *Meetings) SetNotesDocument(ctx context.Context, id, docID int64) error {
	return s.exec1(ctx, `UPDATE meeting_sessions SET document_id = $2, notes_status = 'writing', notes_error = '' WHERE id = $1`, id, docID)
}

// ClaimNotes takes one session whose notes wait for transcription, across
// workspaces (call it in the system scope), and marks it transcribing.
func (s *Meetings) ClaimNotes(ctx context.Context) (domain.MeetingSession, bool, error) {
	var id int64
	err := s.db.QueryRow(ctx, `UPDATE meeting_sessions SET notes_status = 'transcribing'
		WHERE id = (SELECT id FROM meeting_sessions WHERE notes_status = 'queued' ORDER BY ended_at NULLS LAST, id
		            FOR UPDATE SKIP LOCKED LIMIT 1)
		RETURNING id`).Scan(&id)
	if errors.Is(err, pgx.ErrNoRows) {
		return domain.MeetingSession{}, false, nil
	}
	if err != nil {
		return domain.MeetingSession{}, false, err
	}
	x, err := s.Session(ctx, id)
	return x, err == nil, err
}

// RequeueNotes puts transcriptions a restart interrupted back in the queue.
func (s *Meetings) RequeueNotes(ctx context.Context) (int64, error) {
	tag, err := s.db.Exec(ctx, `UPDATE meeting_sessions SET notes_status = 'queued' WHERE notes_status = 'transcribing'`)
	return tag.RowsAffected(), err
}

// SessionSummary is a past session as lists show it.
type SessionSummary struct {
	Session      domain.MeetingSession
	Meeting      domain.Meeting
	People       int
	Recordings   int
	ActionItems  int
	DocumentName string
}

// PastSessions returns ended sessions of the meetings a person sees,
// newest first; before pages back.
func (s *Meetings) PastSessions(ctx context.Context, userID int64, owner bool, before *time.Time, limit int) ([]SessionSummary, error) {
	limit = max(1, min(limit, 100))
	rows, err := s.db.Query(ctx, `SELECT `+sessionCols+`, m.id, m.code, m.title, m.kind,
			(SELECT count(DISTINCT COALESCE('u' || p.user_id, 'g' || p.guest_id)) FROM meeting_participants p WHERE p.session_id = s.id),
			(SELECT count(*) FROM meeting_media r WHERE r.session_id = s.id AND r.kind = 'recording' AND r.status = 'ready'),
			(SELECT count(*) FROM meeting_action_items a WHERE a.session_id = s.id),
			COALESCE(d.title, '')
		FROM meeting_sessions s JOIN meetings m ON m.id = s.meeting_id LEFT JOIN documents d ON d.id = s.document_id AND d.deleted_at IS NULL
		WHERE s.ended_at IS NOT NULL AND s.connected_at IS NOT NULL AND ($3::timestamptz IS NULL OR s.started_at < $3) AND `+meetingVisibleTo+`
		ORDER BY s.started_at DESC LIMIT $4`, userID, owner, before, limit)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := []SessionSummary{}
	for rows.Next() {
		var x SessionSummary
		var st, kind string
		v := &x.Session
		if err := rows.Scan(&v.ID, &v.WorkspaceID, &v.MeetingID, &v.Room, &v.StartedAt, &v.ConnectedAt, &v.EndedAt, &v.GuestsQuiet, &v.NotesOn, &st,
			&v.NotesError, &v.NotesBy, &v.DocumentID, &v.Uploaded, &v.People, &v.Recording,
			&x.Meeting.ID, &x.Meeting.Code, &x.Meeting.Title, &kind, &x.People, &x.Recordings, &x.ActionItems, &x.DocumentName); err != nil {
			return nil, err
		}
		v.NotesStatus, x.Meeting.Kind = domain.NotesStatus(st), domain.MeetingKind(kind)
		out = append(out, x)
	}
	return out, rows.Err()
}

// --- Guests, seats and knocks ---

// CreateMeetingGuest adds a guest of a meeting with the hash of its token.
func (s *Meetings) CreateMeetingGuest(ctx context.Context, g domain.MeetingGuest, tokenHash []byte) (domain.MeetingGuest, error) {
	err := s.db.QueryRow(ctx, `INSERT INTO meeting_guests (workspace_id, meeting_id, name, email, via, user_id, invitee_id, token_hash)
		SELECT workspace_id, id, $2, $3, $4, $5, $6, $7 FROM meetings WHERE id = $1 RETURNING id, created_at`,
		g.MeetingID, g.Name, g.Email, string(g.Via), g.UserID, g.InviteeID, tokenHash).Scan(&g.ID, &g.CreatedAt)
	return g, notFound(err)
}

const guestCols = `id, meeting_id, name, email, via, user_id, invitee_id, created_at`

func scanGuest(row pgx.Row) (domain.MeetingGuest, error) {
	var g domain.MeetingGuest
	var via string
	err := row.Scan(&g.ID, &g.MeetingID, &g.Name, &g.Email, &via, &g.UserID, &g.InviteeID, &g.CreatedAt)
	g.Via = domain.GuestVia(via)
	return g, notFound(err)
}

// MeetingGuestByToken returns the guest of a meeting whose token hashes to h.
func (s *Meetings) MeetingGuestByToken(ctx context.Context, meetingID int64, h []byte) (domain.MeetingGuest, error) {
	return scanGuest(s.db.QueryRow(ctx, `SELECT `+guestCols+` FROM meeting_guests WHERE meeting_id = $1 AND token_hash = $2`, meetingID, h))
}

// MeetingGuestByUser returns the guest a signed-in person of another
// workspace was in a meeting, so they are one guest across sessions.
func (s *Meetings) MeetingGuestByUser(ctx context.Context, meetingID, userID int64) (domain.MeetingGuest, error) {
	return scanGuest(s.db.QueryRow(ctx, `SELECT `+guestCols+` FROM meeting_guests WHERE meeting_id = $1 AND user_id = $2 AND via = 'account'
		ORDER BY id DESC LIMIT 1`, meetingID, userID))
}

// MeetingGuest returns a guest.
func (s *Meetings) MeetingGuest(ctx context.Context, id int64) (domain.MeetingGuest, error) {
	return scanGuest(s.db.QueryRow(ctx, `SELECT `+guestCols+` FROM meeting_guests WHERE id = $1`, id))
}

// RenameMeetingGuest changes the name a guest goes by.
func (s *Meetings) RenameMeetingGuest(ctx context.Context, id int64, name string) error {
	return s.exec1(ctx, `UPDATE meeting_guests SET name = $2 WHERE id = $1`, id, name)
}

func personArgs(p domain.Person) (user, guest *int64) {
	if p.UserID != 0 {
		return &p.UserID, nil
	}
	return nil, &p.GuestID
}

// CreateSeat gives a person a seat in a session.
func (s *Meetings) CreateSeat(ctx context.Context, x domain.MeetingSeat, tokenHash []byte) (domain.MeetingSeat, error) {
	u, g := personArgs(x.Person)
	err := s.db.QueryRow(ctx, `INSERT INTO meeting_seats (workspace_id, session_id, user_id, guest_id, device, name, knocked, token_hash)
		SELECT workspace_id, id, $2, $3, $4, $5, $6, $7 FROM meeting_sessions WHERE id = $1 RETURNING id, created_at`,
		x.SessionID, u, g, x.Device, x.Name, x.Knocked, tokenHash).Scan(&x.ID, &x.CreatedAt)
	return x, notFound(err)
}

// SeatRef is a seat found by its token, with where it is: what in-call
// requests are checked against. Look it up in the system scope.
type SeatRef struct {
	Seat        domain.MeetingSeat
	WorkspaceID int64
	MeetingID   int64
	SessionLive bool
}

// SeatByToken returns the seat whose token hashes to h.
func (s *Meetings) SeatByToken(ctx context.Context, h []byte) (SeatRef, error) {
	var r SeatRef
	var u, g *int64
	var ended *time.Time
	x := &r.Seat
	err := s.db.QueryRow(ctx, `SELECT st.id, st.session_id, st.user_id, st.guest_id, st.device, st.name, st.knocked, st.removed_at, st.created_at,
			ss.workspace_id, ss.meeting_id, ss.ended_at
		FROM meeting_seats st JOIN meeting_sessions ss ON ss.id = st.session_id WHERE st.token_hash = $1`, h).
		Scan(&x.ID, &x.SessionID, &u, &g, &x.Device, &x.Name, &x.Knocked, &x.RemovedAt, &x.CreatedAt, &r.WorkspaceID, &r.MeetingID, &ended)
	if u != nil {
		x.Person.UserID = *u
	}
	if g != nil {
		x.Person.GuestID = *g
	}
	r.SessionLive = ended == nil
	return r, notFound(err)
}

// SeatStatus is what a session knows of a person: admitted before, or
// removed.
type SeatStatus struct {
	Admitted bool
	Removed  bool
}

// PersonStatus reports whether a person has a seat in a session, and
// whether they were removed from it.
func (s *Meetings) PersonStatus(ctx context.Context, sessionID int64, p domain.Person) (SeatStatus, error) {
	u, g := personArgs(p)
	var st SeatStatus
	err := s.db.QueryRow(ctx, `SELECT
			EXISTS (SELECT 1 FROM meeting_seats WHERE session_id = $1 AND user_id IS NOT DISTINCT FROM $2 AND guest_id IS NOT DISTINCT FROM $3 AND removed_at IS NULL),
			EXISTS (SELECT 1 FROM meeting_seats WHERE session_id = $1 AND user_id IS NOT DISTINCT FROM $2 AND guest_id IS NOT DISTINCT FROM $3 AND removed_at IS NOT NULL)`,
		sessionID, u, g).Scan(&st.Admitted, &st.Removed)
	return st, err
}

// RemovePerson ends all of a person's seats in a session and returns
// their identities, to disconnect.
func (s *Meetings) RemovePerson(ctx context.Context, sessionID int64, p domain.Person) ([]string, error) {
	u, g := personArgs(p)
	rows, err := s.db.Query(ctx, `UPDATE meeting_seats SET removed_at = COALESCE(removed_at, now())
		WHERE session_id = $1 AND user_id IS NOT DISTINCT FROM $2 AND guest_id IS NOT DISTINCT FROM $3 RETURNING device`, sessionID, u, g)
	if err != nil {
		return nil, err
	}
	devices, err := pgx.CollectRows(rows, pgx.RowTo[string])
	if err != nil {
		return nil, err
	}
	out := make([]string, len(devices))
	for i, d := range devices {
		out[i] = domain.MeetingIdentity(p, d)
	}
	return out, nil
}

// PersonIdentities returns the identities a person has (had) in a session.
func (s *Meetings) PersonIdentities(ctx context.Context, sessionID int64, p domain.Person) ([]string, error) {
	u, g := personArgs(p)
	rows, err := s.db.Query(ctx, `SELECT DISTINCT device FROM meeting_seats
		WHERE session_id = $1 AND user_id IS NOT DISTINCT FROM $2 AND guest_id IS NOT DISTINCT FROM $3 AND removed_at IS NULL`, sessionID, u, g)
	if err != nil {
		return nil, err
	}
	devices, err := pgx.CollectRows(rows, pgx.RowTo[string])
	out := make([]string, len(devices))
	for i, d := range devices {
		out[i] = domain.MeetingIdentity(p, d)
	}
	return out, err
}

// CreateKnock puts someone in the waiting room.
func (s *Meetings) CreateKnock(ctx context.Context, k domain.MeetingKnock, tokenHash []byte) (domain.MeetingKnock, error) {
	u, g := personArgs(k.Person)
	err := s.db.QueryRow(ctx, `INSERT INTO meeting_knocks (workspace_id, session_id, user_id, guest_id, device, name, token_hash)
		SELECT workspace_id, id, $2, $3, $4, $5, $6 FROM meeting_sessions WHERE id = $1 AND ended_at IS NULL RETURNING id, state, created_at`,
		k.SessionID, u, g, k.Device, k.Name, tokenHash).Scan(&k.ID, &k.State, &k.CreatedAt)
	return k, notFound(err)
}

const knockCols = `k.id, k.session_id, k.user_id, k.guest_id, k.device, k.name, COALESCE(g.email, ''), k.state, k.seat_id, k.created_at`

func scanKnock(row pgx.Row) (domain.MeetingKnock, error) {
	var k domain.MeetingKnock
	var u, g *int64
	var st string
	err := row.Scan(&k.ID, &k.SessionID, &u, &g, &k.Device, &k.Name, &k.Email, &st, &k.SeatID, &k.CreatedAt)
	if u != nil {
		k.Person.UserID = *u
	}
	if g != nil {
		k.Person.GuestID = *g
	}
	k.State = domain.KnockState(st)
	return k, notFound(err)
}

// KnockByToken returns the knock whose token hashes to h (the knocker's).
func (s *Meetings) KnockByToken(ctx context.Context, id int64, h []byte) (domain.MeetingKnock, error) {
	return scanKnock(s.db.QueryRow(ctx, `SELECT `+knockCols+` FROM meeting_knocks k LEFT JOIN meeting_guests g ON g.id = k.guest_id
		WHERE k.id = $1 AND k.token_hash = $2`, id, h))
}

// Knock returns a knock.
func (s *Meetings) Knock(ctx context.Context, id int64) (domain.MeetingKnock, error) {
	return scanKnock(s.db.QueryRow(ctx, `SELECT `+knockCols+` FROM meeting_knocks k LEFT JOIN meeting_guests g ON g.id = k.guest_id WHERE k.id = $1`, id))
}

// WaitingKnocks returns who waits in a session's waiting room, first come
// first; knocks older than the wait expire first.
func (s *Meetings) WaitingKnocks(ctx context.Context, sessionID int64) ([]domain.MeetingKnock, error) {
	if _, err := s.db.Exec(ctx, `UPDATE meeting_knocks SET state = 'expired', decided_at = now()
		WHERE session_id = $1 AND state = 'waiting' AND created_at < now() - $2::interval`, sessionID, domain.MeetingKnockWait.String()); err != nil {
		return nil, err
	}
	rows, err := s.db.Query(ctx, `SELECT `+knockCols+` FROM meeting_knocks k LEFT JOIN meeting_guests g ON g.id = k.guest_id
		WHERE k.session_id = $1 AND k.state = 'waiting' ORDER BY k.created_at, k.id`, sessionID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := []domain.MeetingKnock{}
	for rows.Next() {
		k, err := scanKnock(rows)
		if err != nil {
			return nil, err
		}
		out = append(out, k)
	}
	return out, rows.Err()
}

// DecideKnock admits (with the seat made for it) or denies a waiting
// knock; false when it was decided already.
func (s *Meetings) DecideKnock(ctx context.Context, id int64, state domain.KnockState, by int64, seatID *int64) (bool, error) {
	var byID *int64
	if by != 0 {
		byID = &by
	}
	tag, err := s.db.Exec(ctx, `UPDATE meeting_knocks SET state = $2, decided_by = $3, seat_id = $4, decided_at = now()
		WHERE id = $1 AND state = 'waiting'`, id, string(state), byID, seatID)
	return tag.RowsAffected() == 1, err
}

// DeniedSince reports whether a person's knock on a session was denied
// after since.
func (s *Meetings) DeniedSince(ctx context.Context, sessionID int64, p domain.Person, since time.Time) (bool, error) {
	u, g := personArgs(p)
	var ok bool
	err := s.db.QueryRow(ctx, `SELECT EXISTS (SELECT 1 FROM meeting_knocks WHERE session_id = $1 AND user_id IS NOT DISTINCT FROM $2
		AND guest_id IS NOT DISTINCT FROM $3 AND state = 'denied' AND decided_at > $4)`, sessionID, u, g, since).Scan(&ok)
	return ok, err
}

// Seat returns a seat (the one an admitted knock got, say).
func (s *Meetings) Seat(ctx context.Context, id int64) (domain.MeetingSeat, error) {
	var x domain.MeetingSeat
	var u, g *int64
	err := s.db.QueryRow(ctx, `SELECT id, session_id, user_id, guest_id, device, name, knocked, removed_at, created_at FROM meeting_seats WHERE id = $1`, id).
		Scan(&x.ID, &x.SessionID, &u, &g, &x.Device, &x.Name, &x.Knocked, &x.RemovedAt, &x.CreatedAt)
	if u != nil {
		x.Person.UserID = *u
	}
	if g != nil {
		x.Person.GuestID = *g
	}
	return x, notFound(err)
}

// ReplaceSeatToken gives a seat a new secret (the admitted knocker
// collects it once).
func (s *Meetings) ReplaceSeatToken(ctx context.Context, id int64, h []byte) error {
	return s.exec1(ctx, `UPDATE meeting_seats SET token_hash = $2 WHERE id = $1`, id, h)
}

// --- Attendance ---

// ParticipantJoined records a connection; a repeated webhook changes
// nothing. first says it was the session's first connection.
func (s *Meetings) ParticipantJoined(ctx context.Context, sessionID int64, identity string, p domain.Person, name string, at time.Time) error {
	u, g := personArgs(p)
	return pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		// A left webhook may come first: it made a closed row already.
		var exists bool
		if err := tx.QueryRow(ctx, `SELECT EXISTS (SELECT 1 FROM meeting_participants WHERE session_id = $1 AND identity = $2
			AND joined_at BETWEEN $3::timestamptz - interval '2 seconds' AND $3::timestamptz + interval '2 seconds')`, sessionID, identity, at).Scan(&exists); err != nil {
			return err
		}
		if !exists {
			// The same identity reconnecting closes its older row.
			if _, err := tx.Exec(ctx, `UPDATE meeting_participants SET left_at = $3 WHERE session_id = $1 AND identity = $2 AND left_at IS NULL AND joined_at < $3`,
				sessionID, identity, at); err != nil {
				return err
			}
			if _, err := tx.Exec(ctx, `INSERT INTO meeting_participants (workspace_id, session_id, identity, user_id, guest_id, name, joined_at)
				SELECT workspace_id, id, $2, $3, $4, $5, $6 FROM meeting_sessions WHERE id = $1
				ON CONFLICT (session_id, identity, joined_at) DO NOTHING`, sessionID, identity, u, g, name, at); err != nil {
				return err
			}
		}
		_, err := tx.Exec(ctx, `UPDATE meeting_sessions SET connected_at = LEAST(COALESCE(connected_at, $2), $2) WHERE id = $1`, sessionID, at)
		return err
	})
}

// ParticipantLeft closes a connection's attendance. A left webhook
// without its joined one records the connection as seen only when it
// left.
func (s *Meetings) ParticipantLeft(ctx context.Context, sessionID int64, identity string, p domain.Person, name string, joined, at time.Time) error {
	tag, err := s.db.Exec(ctx, `UPDATE meeting_participants SET left_at = GREATEST($3, joined_at)
		WHERE id = (SELECT id FROM meeting_participants WHERE session_id = $1 AND identity = $2 AND left_at IS NULL ORDER BY joined_at DESC LIMIT 1)`,
		sessionID, identity, at)
	if err != nil || tag.RowsAffected() > 0 {
		return err
	}
	if joined.IsZero() || joined.After(at) {
		joined = at
	}
	u, g := personArgs(p)
	_, err = s.db.Exec(ctx, `INSERT INTO meeting_participants (workspace_id, session_id, identity, user_id, guest_id, name, joined_at, left_at)
		SELECT workspace_id, id, $2, $3, $4, $5, $6, $7 FROM meeting_sessions WHERE id = $1
		ON CONFLICT (session_id, identity, joined_at) DO UPDATE SET left_at = EXCLUDED.left_at`, sessionID, identity, u, g, name, joined, at)
	return err
}

// Present is someone connected to a session now.
type Present struct {
	Identity string
	Person   domain.Person
	Name     string
	JoinedAt time.Time
	Knocked  bool // came in through the waiting room
}

// PresentPeople returns the open connections of a session.
func (s *Meetings) PresentPeople(ctx context.Context, sessionID int64) ([]Present, error) {
	rows, err := s.db.Query(ctx, `SELECT p.identity, p.user_id, p.guest_id, p.name, p.joined_at,
			COALESCE((SELECT bool_and(st.knocked) FROM meeting_seats st WHERE st.session_id = p.session_id
				AND st.user_id IS NOT DISTINCT FROM p.user_id AND st.guest_id IS NOT DISTINCT FROM p.guest_id), false)
		FROM meeting_participants p WHERE p.session_id = $1 AND p.left_at IS NULL ORDER BY p.joined_at`, sessionID)
	if err != nil {
		return nil, err
	}
	return pgx.CollectRows(rows, func(r pgx.CollectableRow) (Present, error) {
		var x Present
		var u, g *int64
		err := r.Scan(&x.Identity, &u, &g, &x.Name, &x.JoinedAt, &x.Knocked)
		if u != nil {
			x.Person.UserID = *u
		}
		if g != nil {
			x.Person.GuestID = *g
		}
		return x, err
	})
}

// SyncPresent closes the open connections of a session that are not in
// identities (LiveKit no longer has them): what the reconciler does when
// a left webhook was lost.
func (s *Meetings) SyncPresent(ctx context.Context, sessionID int64, identities []string, at time.Time) (int64, error) {
	tag, err := s.db.Exec(ctx, `UPDATE meeting_participants SET left_at = GREATEST($3, joined_at)
		WHERE session_id = $1 AND left_at IS NULL AND NOT (identity = ANY($2)) AND joined_at < $3::timestamptz - interval '30 seconds'`, sessionID, identities, at)
	return tag.RowsAffected(), err
}

// Attendance returns who was in a session and for how long, in the order
// they first came.
func (s *Meetings) Attendance(ctx context.Context, sessionID int64) ([]domain.MeetingAttendee, error) {
	rows, err := s.db.Query(ctx, `SELECT p.user_id, p.guest_id, (array_agg(p.name ORDER BY p.joined_at DESC))[1], min(p.joined_at),
			CASE WHEN bool_or(p.left_at IS NULL) THEN NULL ELSE max(p.left_at) END,
			COALESCE(sum(EXTRACT(EPOCH FROM (COALESCE(p.left_at, now()) - p.joined_at)))::bigint, 0),
			COALESCE(max(g.email), '')
		FROM meeting_participants p LEFT JOIN meeting_guests g ON g.id = p.guest_id
		WHERE p.session_id = $1 GROUP BY p.user_id, p.guest_id ORDER BY min(p.joined_at)`, sessionID)
	if err != nil {
		return nil, err
	}
	return pgx.CollectRows(rows, func(r pgx.CollectableRow) (domain.MeetingAttendee, error) {
		var a domain.MeetingAttendee
		var u, g *int64
		err := r.Scan(&u, &g, &a.Name, &a.FirstIn, &a.LastOut, &a.Seconds, &a.GuestMail)
		if u != nil {
			a.Person.UserID = *u
		}
		if g != nil {
			a.Person.GuestID, a.IsGuest = *g, true
		}
		return a, err
	})
}

// AttendedMembers returns the members who were in a session.
func (s *Meetings) AttendedMembers(ctx context.Context, sessionID int64) ([]int64, error) {
	rows, err := s.db.Query(ctx, `SELECT DISTINCT user_id FROM meeting_participants WHERE session_id = $1 AND user_id IS NOT NULL`, sessionID)
	if err != nil {
		return nil, err
	}
	return pgx.CollectRows(rows, pgx.RowTo[int64])
}

// Attended reports whether a member was in any session of a meeting, or
// in one session when sessionID is set (or in its uploaded recording).
func (s *Meetings) Attended(ctx context.Context, meetingID, sessionID, userID int64) (bool, error) {
	var ok bool
	err := s.db.QueryRow(ctx, `SELECT EXISTS (SELECT 1 FROM meeting_participants p JOIN meeting_sessions ss ON ss.id = p.session_id
		WHERE ss.meeting_id = $1 AND ($2 = 0 OR ss.id = $2) AND p.user_id = $3)
		OR EXISTS (SELECT 1 FROM meeting_sessions ss WHERE ss.meeting_id = $1 AND ($2 = 0 OR ss.id = $2) AND $3 = ANY(ss.people))`,
		meetingID, sessionID, userID).Scan(&ok)
	return ok, err
}

// --- Chat ---

// AddMessage stores a chat message.
func (s *Meetings) AddMessage(ctx context.Context, m domain.MeetingMessage) (domain.MeetingMessage, error) {
	u, g := personArgs(m.Person)
	err := s.db.QueryRow(ctx, `INSERT INTO meeting_messages (workspace_id, session_id, user_id, guest_id, name, body)
		SELECT workspace_id, id, $2, $3, $4, $5 FROM meeting_sessions WHERE id = $1 RETURNING id, created_at`,
		m.SessionID, u, g, m.Name, m.Body).Scan(&m.ID, &m.CreatedAt)
	return m, notFound(err)
}

// Messages returns a session's chat after a message id, oldest first.
func (s *Meetings) Messages(ctx context.Context, sessionID, after int64, limit int) ([]domain.MeetingMessage, error) {
	rows, err := s.db.Query(ctx, `SELECT id, session_id, user_id, guest_id, name, body, created_at FROM meeting_messages
		WHERE session_id = $1 AND id > $2 ORDER BY id LIMIT $3`, sessionID, after, max(1, min(limit, 1000)))
	if err != nil {
		return nil, err
	}
	return pgx.CollectRows(rows, func(r pgx.CollectableRow) (domain.MeetingMessage, error) {
		var m domain.MeetingMessage
		var u, g *int64
		err := r.Scan(&m.ID, &m.SessionID, &u, &g, &m.Name, &m.Body, &m.CreatedAt)
		if u != nil {
			m.Person.UserID = *u
		}
		if g != nil {
			m.Person.GuestID = *g
		}
		return m, err
	})
}

// MessagesSince counts what a person wrote in a session after since, for
// the rate limit.
func (s *Meetings) MessagesSince(ctx context.Context, sessionID int64, p domain.Person, since time.Time) (int, error) {
	u, g := personArgs(p)
	var n int
	err := s.db.QueryRow(ctx, `SELECT count(*) FROM meeting_messages WHERE session_id = $1 AND user_id IS NOT DISTINCT FROM $2
		AND guest_id IS NOT DISTINCT FROM $3 AND created_at > $4`, sessionID, u, g, since).Scan(&n)
	return n, err
}

// --- Media ---

const mediaCols = `id, session_id, kind, egress_id, identity, file, bytes, started_at, ended_at, status, started_by, error`

func scanMedia(row pgx.Row) (domain.MeetingMedia, error) {
	var m domain.MeetingMedia
	var kind, st string
	err := row.Scan(&m.ID, &m.SessionID, &kind, &m.EgressID, &m.Identity, &m.File, &m.Bytes, &m.StartedAt, &m.EndedAt, &st, &m.StartedBy, &m.Error)
	m.Kind, m.Status = domain.MediaKind(kind), domain.MediaStatus(st)
	return m, notFound(err)
}

// CreateMedia records a file Egress started writing.
func (s *Meetings) CreateMedia(ctx context.Context, m domain.MeetingMedia) (domain.MeetingMedia, error) {
	var id int64
	err := s.db.QueryRow(ctx, `INSERT INTO meeting_media (workspace_id, session_id, kind, egress_id, identity, file, started_by)
		SELECT workspace_id, id, $2, $3, $4, $5, $6 FROM meeting_sessions WHERE id = $1
		ON CONFLICT (egress_id) DO UPDATE SET egress_id = EXCLUDED.egress_id RETURNING id`,
		m.SessionID, string(m.Kind), m.EgressID, m.Identity, m.File, m.StartedBy).Scan(&id)
	if err != nil {
		return m, notFound(err)
	}
	return s.Media(ctx, id)
}

// Media returns a file.
func (s *Meetings) Media(ctx context.Context, id int64) (domain.MeetingMedia, error) {
	return scanMedia(s.db.QueryRow(ctx, `SELECT `+mediaCols+` FROM meeting_media WHERE id = $1`, id))
}

// MediaByEgress returns the file an egress writes.
func (s *Meetings) MediaByEgress(ctx context.Context, egressID string) (domain.MeetingMedia, error) {
	return scanMedia(s.db.QueryRow(ctx, `SELECT `+mediaCols+` FROM meeting_media WHERE egress_id = $1`, egressID))
}

// SessionMedia returns a session's files, of the kinds asked (all when none).
func (s *Meetings) SessionMedia(ctx context.Context, sessionID int64, kinds ...domain.MediaKind) ([]domain.MeetingMedia, error) {
	ks := make([]string, len(kinds))
	for i, k := range kinds {
		ks[i] = string(k)
	}
	rows, err := s.db.Query(ctx, `SELECT `+mediaCols+` FROM meeting_media WHERE session_id = $1 AND (cardinality($2::text[]) = 0 OR kind = ANY($2))
		ORDER BY started_at, id`, sessionID, ks)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := []domain.MeetingMedia{}
	for rows.Next() {
		m, err := scanMedia(rows)
		if err != nil {
			return nil, err
		}
		out = append(out, m)
	}
	return out, rows.Err()
}

// FinishMedia records how an egress ended.
func (s *Meetings) FinishMedia(ctx context.Context, egressID string, st domain.MediaStatus, bytes int64, endedAt time.Time, msg string) (domain.MeetingMedia, error) {
	var id int64
	err := s.db.QueryRow(ctx, `UPDATE meeting_media SET status = $2, bytes = GREATEST(bytes, $3), ended_at = COALESCE(ended_at, $4), error = $5
		WHERE egress_id = $1 AND status = 'active' RETURNING id`, egressID, string(st), bytes, endedAt, msg).Scan(&id)
	if errors.Is(err, pgx.ErrNoRows) {
		return s.MediaByEgress(ctx, egressID) // ended already: a repeated webhook
	}
	if err != nil {
		return domain.MeetingMedia{}, err
	}
	return s.Media(ctx, id)
}

// SetMediaStatus changes a file's status (deleted, expired).
func (s *Meetings) SetMediaStatus(ctx context.Context, id int64, st domain.MediaStatus) error {
	return s.exec1(ctx, `UPDATE meeting_media SET status = $2 WHERE id = $1`, id, string(st))
}

// SetMediaFile records that a file was replaced by another (an upload by
// its sound) of bytes bytes.
func (s *Meetings) SetMediaFile(ctx context.Context, id int64, file string, bytes int64) error {
	return s.exec1(ctx, `UPDATE meeting_media SET file = $2, bytes = $3 WHERE id = $1`, id, file, bytes)
}

// NewUpload is a recording a host uploaded, as its session is made.
type NewUpload struct {
	MeetingID int64
	StartedAt time.Time // when the meeting was held
	By        int64
	People    []int64 // members in it
	EgressID  string  // the media's unique id ("upload-…")
	File      string
	Bytes     int64
}

// CreateUploadSession makes the ended session of an uploaded recording
// and its file, with notes on and not yet queued (QueueNotes).
func (s *Meetings) CreateUploadSession(ctx context.Context, u NewUpload) (domain.MeetingSession, error) {
	var id int64
	if u.People == nil {
		u.People = []int64{} // the column is NOT NULL
	}
	err := pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		if err := tx.QueryRow(ctx, `INSERT INTO meeting_sessions (workspace_id, meeting_id, started_at, connected_at, ended_at, notes_on, notes_by, uploaded, people)
			SELECT workspace_id, id, $2, $2, $2, true, $3, true, $4 FROM meetings WHERE id = $1 RETURNING id`,
			u.MeetingID, u.StartedAt, u.By, u.People).Scan(&id); err != nil {
			return notFound(err)
		}
		_, err := tx.Exec(ctx, `INSERT INTO meeting_media (workspace_id, session_id, kind, egress_id, file, bytes, started_at, ended_at, status, started_by)
			SELECT workspace_id, id, 'upload', $2, $3, $4, now(), now(), 'ready', $5 FROM meeting_sessions WHERE id = $1`,
			id, u.EgressID, u.File, u.Bytes, u.By)
		return err
	})
	if err != nil {
		return domain.MeetingSession{}, err
	}
	return s.Session(ctx, id)
}

// SetUploadLength sets an uploaded session's end from how long its sound
// runs, once it is heard.
func (s *Meetings) SetUploadLength(ctx context.Context, id int64, ms int) error {
	return s.exec1(ctx, `UPDATE meeting_sessions SET ended_at = started_at + make_interval(secs => $2::float8 / 1000) WHERE id = $1 AND uploaded`, id, ms)
}

// ActiveRecordings counts the video recordings running in the scope's
// workspace, or on the server in the system scope.
func (s *Meetings) ActiveRecordings(ctx context.Context) (int, error) {
	var n int
	err := s.db.QueryRow(ctx, `SELECT count(*) FROM meeting_media WHERE kind = 'recording' AND status = 'active'`).Scan(&n)
	return n, err
}

// MediaBytes is the size of the scope's kept meeting files.
func (s *Meetings) MediaBytes(ctx context.Context) (int64, error) {
	var n int64
	err := s.db.QueryRow(ctx, `SELECT COALESCE(sum(bytes), 0) FROM meeting_media WHERE status IN ('ready', 'active')`).Scan(&n)
	return n, err
}

// ExpiredFile is a meeting file past its workspace's retention.
type ExpiredFile struct {
	ID          int64
	WorkspaceID int64
	File        string
}

// StaleActiveMedia returns files still marked active long after their
// egress should have ended (a lost webhook), across workspaces.
func (s *Meetings) StaleActiveMedia(ctx context.Context, before time.Time) ([]domain.MeetingMedia, error) {
	rows, err := s.db.Query(ctx, `SELECT r.id, r.session_id, r.kind, r.egress_id, r.identity, r.file, r.bytes, r.started_at, r.ended_at, r.status,
			r.started_by, r.error
		FROM meeting_media r JOIN meeting_sessions ss ON ss.id = r.session_id
		WHERE r.status = 'active' AND ss.ended_at IS NOT NULL AND ss.ended_at < $1`, before)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var out []domain.MeetingMedia
	for rows.Next() {
		m, err := scanMedia(rows)
		if err != nil {
			return nil, err
		}
		out = append(out, m)
	}
	return out, rows.Err()
}

// ExpiredMedia returns the files older than days (per workspace,
// retention > 0) in the scope's workspace.
func (s *Meetings) ExpiredMedia(ctx context.Context, days int) ([]ExpiredFile, error) {
	rows, err := s.db.Query(ctx, `SELECT id, workspace_id, file FROM meeting_media
		WHERE status IN ('ready', 'failed') AND started_at < now() - make_interval(days => $1)`, days)
	if err != nil {
		return nil, err
	}
	return pgx.CollectRows(rows, func(r pgx.CollectableRow) (ExpiredFile, error) {
		var x ExpiredFile
		err := r.Scan(&x.ID, &x.WorkspaceID, &x.File)
		return x, err
	})
}

// ExpireTranscripts deletes the transcripts of sessions older than days.
func (s *Meetings) ExpireTranscripts(ctx context.Context, days int) (int64, error) {
	tag, err := s.db.Exec(ctx, `DELETE FROM meeting_segments g USING meeting_sessions ss
		WHERE ss.id = g.session_id AND ss.started_at < now() - make_interval(days => $1)`, days)
	return tag.RowsAffected(), err
}

// --- Transcripts and notes ---

// ReplaceSegments stores a session's transcript, replacing any earlier one.
func (s *Meetings) ReplaceSegments(ctx context.Context, sessionID int64, segs []domain.MeetingSegment) error {
	return pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		if _, err := tx.Exec(ctx, `DELETE FROM meeting_segments WHERE session_id = $1`, sessionID); err != nil {
			return err
		}
		var ws int64
		if err := tx.QueryRow(ctx, `SELECT workspace_id FROM meeting_sessions WHERE id = $1`, sessionID).Scan(&ws); err != nil {
			return notFound(err)
		}
		// COPY is refused under row-level security: insert from arrays.
		for start := 0; start < len(segs); start += 1000 {
			part := segs[start:min(start+1000, len(segs))]
			ids, names, starts, ends, texts := make([]string, len(part)), make([]string, len(part)), make([]int64, len(part)),
				make([]int64, len(part)), make([]string, len(part))
			for i, g := range part {
				ids[i], names[i], starts[i], ends[i], texts[i] = g.Identity, g.Name, int64(g.StartMS), int64(g.EndMS), g.Text
			}
			if _, err := tx.Exec(ctx, `INSERT INTO meeting_segments (workspace_id, session_id, identity, name, start_ms, end_ms, text)
				SELECT $1, $2, i, n, s, e, t FROM unnest($3::text[], $4::text[], $5::bigint[], $6::bigint[], $7::text[]) AS x(i, n, s, e, t)`,
				ws, sessionID, ids, names, starts, ends, texts); err != nil {
				return err
			}
		}
		return nil
	})
}

// Segments returns a session's transcript in time order.
func (s *Meetings) Segments(ctx context.Context, sessionID int64) ([]domain.MeetingSegment, error) {
	rows, err := s.db.Query(ctx, `SELECT id, identity, name, start_ms, end_ms, text FROM meeting_segments WHERE session_id = $1 ORDER BY start_ms, id`, sessionID)
	if err != nil {
		return nil, err
	}
	return pgx.CollectRows(rows, func(r pgx.CollectableRow) (domain.MeetingSegment, error) {
		var g domain.MeetingSegment
		err := r.Scan(&g.ID, &g.Identity, &g.Name, &g.StartMS, &g.EndMS, &g.Text)
		return g, err
	})
}

// TranscriptHit is a stretch of a transcript that matches a search.
type TranscriptHit struct {
	SessionID    int64
	MeetingID    int64
	MeetingTitle string
	StartedAt    time.Time
	Segment      domain.MeetingSegment
}

// SearchTranscripts finds what was said, in the sessions of the meetings
// a person sees, newest first.
func (s *Meetings) SearchTranscripts(ctx context.Context, userID int64, owner bool, query string, limit int) ([]TranscriptHit, error) {
	rows, err := s.db.Query(ctx, `SELECT ss.id, m.id, m.title, ss.started_at, g.id, g.identity, g.name, g.start_ms, g.end_ms, g.text
		FROM meeting_segments g JOIN meeting_sessions ss ON ss.id = g.session_id JOIN meetings m ON m.id = ss.meeting_id
		WHERE g.search @@ plainto_tsquery('simple', $3) AND `+meetingVisibleTo+`
		ORDER BY ss.started_at DESC, g.start_ms LIMIT $4`, userID, owner, query, max(1, min(limit, 100)))
	if err != nil {
		return nil, err
	}
	return pgx.CollectRows(rows, func(r pgx.CollectableRow) (TranscriptHit, error) {
		var h TranscriptHit
		g := &h.Segment
		err := r.Scan(&h.SessionID, &h.MeetingID, &h.MeetingTitle, &h.StartedAt, &g.ID, &g.Identity, &g.Name, &g.StartMS, &g.EndMS, &g.Text)
		return h, err
	})
}

const actionItemCols = `a.id, a.session_id, a.position, a.text, a.who, a.due, a.at_ms, a.quote, a.speaker, a.who_user_id, a.who_set_by, a.drafted,
	a.ticket_id, COALESCE(t.key, ''), COALESCE(NULLIF(u.display_name, ''), u.username, '')`

const actionItemFrom = `meeting_action_items a LEFT JOIN tickets t ON t.id = a.ticket_id LEFT JOIN users u ON u.id = a.who_user_id`

func scanActionItem(r pgx.Row) (domain.ActionItem, error) {
	var a domain.ActionItem
	err := r.Scan(&a.ID, &a.SessionID, &a.Position, &a.Text, &a.Who, &a.Due, &a.AtMS, &a.Quote, &a.Speaker, &a.WhoUserID, &a.WhoSetBy, &a.Drafted,
		&a.TicketID, &a.TicketKey, &a.WhoName)
	return a, err
}

// ActionItems returns a session's action items in order, with their tickets.
func (s *Meetings) ActionItems(ctx context.Context, sessionID int64) ([]domain.ActionItem, error) {
	rows, err := s.db.Query(ctx, `SELECT `+actionItemCols+` FROM `+actionItemFrom+` WHERE a.session_id = $1 ORDER BY a.position, a.id`, sessionID)
	if err != nil {
		return nil, err
	}
	return pgx.CollectRows(rows, func(r pgx.CollectableRow) (domain.ActionItem, error) { return scanActionItem(r) })
}

// ActionItem returns one action item.
func (s *Meetings) ActionItem(ctx context.Context, id int64) (domain.ActionItem, error) {
	a, err := scanActionItem(s.db.QueryRow(ctx, `SELECT `+actionItemCols+` FROM `+actionItemFrom+` WHERE a.id = $1`, id))
	return a, notFound(err)
}

// SetActionItemMember records the member who takes an action item: by is
// who picked them by hand, 0 when agnts matched the name. A matched member
// never replaces one picked by hand.
func (s *Meetings) SetActionItemMember(ctx context.Context, itemID int64, userID *int64, by int64) error {
	if by == 0 {
		_, err := s.db.Exec(ctx, `UPDATE meeting_action_items SET who_user_id = $2 WHERE id = $1 AND who_set_by IS NULL`, itemID, userID)
		return err
	}
	return s.exec1(ctx, `UPDATE meeting_action_items SET who_user_id = $2, who_set_by = $3 WHERE id = $1`, itemID, userID, by)
}

// SetActionItemsDrafted marks action items as having (true) or not
// having had (false) their draft ticket made.
func (s *Meetings) SetActionItemsDrafted(ctx context.Context, ids []int64, drafted bool) error {
	_, err := s.db.Exec(ctx, `UPDATE meeting_action_items SET drafted = $2 WHERE id = ANY($1)`, ids, drafted)
	return err
}

// NameCandidates returns the members an action item of a session may
// name, with the names they go by; Near ones were in the call, are
// invited, host it, or are in the uploaded recording.
func (s *Meetings) NameCandidates(ctx context.Context, sessionID int64) ([]domain.NameCandidate, error) {
	rows, err := s.db.Query(ctx, `SELECT u.id, u.display_name, u.username, COALESCE(split_part(u.email, '@', 1), ''),
			COALESCE((SELECT array_agg(DISTINCT p.name) FROM meeting_participants p WHERE p.session_id = ss.id AND p.user_id = u.id), '{}'),
			EXISTS (SELECT 1 FROM meeting_participants p WHERE p.session_id = ss.id AND p.user_id = u.id)
			OR EXISTS (SELECT 1 FROM meeting_invitees i WHERE i.meeting_id = ss.meeting_id AND i.user_id = u.id)
			OR EXISTS (SELECT 1 FROM meeting_cohosts c WHERE c.meeting_id = ss.meeting_id AND c.user_id = u.id)
			OR m.host_id = u.id OR u.id = ANY(ss.people)
		FROM meeting_sessions ss JOIN meetings m ON m.id = ss.meeting_id
		JOIN memberships ms ON ms.workspace_id = ss.workspace_id JOIN users u ON u.id = ms.user_id
		WHERE ss.id = $1 ORDER BY u.id`, sessionID)
	if err != nil {
		return nil, err
	}
	return pgx.CollectRows(rows, func(r pgx.CollectableRow) (domain.NameCandidate, error) {
		var c domain.NameCandidate
		var display, username, mailName string
		var joined []string
		err := r.Scan(&c.UserID, &display, &username, &mailName, &joined, &c.Near)
		for _, n := range append([]string{display, username, mailName}, joined...) {
			if n != "" {
				c.Names = append(c.Names, n)
			}
		}
		return c, err
	})
}

// SetActionItemTicket records the ticket made from an action item, and
// links it to the meeting; false when the item has one already.
func (s *Meetings) SetActionItemTicket(ctx context.Context, itemID, ticketID int64, by int64) (bool, error) {
	ok := false
	err := pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		var meetingID, sessionID int64
		var quote string
		err := tx.QueryRow(ctx, `UPDATE meeting_action_items a SET ticket_id = $2 FROM meeting_sessions ss
			WHERE a.id = $1 AND a.ticket_id IS NULL AND ss.id = a.session_id RETURNING ss.meeting_id, ss.id, a.quote`, itemID, ticketID).
			Scan(&meetingID, &sessionID, &quote)
		if errors.Is(err, pgx.ErrNoRows) {
			return nil
		}
		if err != nil {
			return err
		}
		ok = true
		var byID *int64
		if by != 0 {
			byID = &by
		}
		_, err = tx.Exec(ctx, `INSERT INTO meeting_tickets (meeting_id, ticket_id, session_id, quote, created_by) VALUES ($1, $2, $3, $4, $5)
			ON CONFLICT DO NOTHING`, meetingID, ticketID, sessionID, quote, byID)
		return err
	})
	return ok, err
}

// MeetingTicket is a ticket linked to a meeting.
type MeetingTicket struct {
	MeetingID    int64
	MeetingTitle string
	MeetingCode  string
	SessionID    *int64
	TicketID     int64
	TicketKey    string
	TicketTitle  string
	Quote        string
	CreatedAt    time.Time
}

// MeetingTickets returns the tickets linked to a meeting, or the meetings
// a ticket is linked to.
func (s *Meetings) MeetingTickets(ctx context.Context, meetingID, ticketID int64) ([]MeetingTicket, error) {
	rows, err := s.db.Query(ctx, `SELECT mt.meeting_id, m.title, m.code, mt.session_id, t.id, t.key, t.title, mt.quote, mt.created_at
		FROM meeting_tickets mt JOIN meetings m ON m.id = mt.meeting_id JOIN tickets t ON t.id = mt.ticket_id
		WHERE ($1 = 0 OR mt.meeting_id = $1) AND ($2 = 0 OR mt.ticket_id = $2) ORDER BY mt.created_at`, meetingID, ticketID)
	if err != nil {
		return nil, err
	}
	return pgx.CollectRows(rows, func(r pgx.CollectableRow) (MeetingTicket, error) {
		var x MeetingTicket
		err := r.Scan(&x.MeetingID, &x.MeetingTitle, &x.MeetingCode, &x.SessionID, &x.TicketID, &x.TicketKey, &x.TicketTitle, &x.Quote, &x.CreatedAt)
		return x, err
	})
}

// LinkMeetingTicket links a ticket to a meeting by hand.
func (s *Meetings) LinkMeetingTicket(ctx context.Context, meetingID, ticketID, by int64) error {
	_, err := s.db.Exec(ctx, `INSERT INTO meeting_tickets (meeting_id, ticket_id, created_by) VALUES ($1, $2, $3) ON CONFLICT DO NOTHING`,
		meetingID, ticketID, by)
	return err
}

// UnlinkMeetingTicket removes the link.
func (s *Meetings) UnlinkMeetingTicket(ctx context.Context, meetingID, ticketID int64) error {
	return s.exec1(ctx, `DELETE FROM meeting_tickets WHERE meeting_id = $1 AND ticket_id = $2`, meetingID, ticketID)
}

// NotesInput gathers what a session's notes are written from.
func (s *Meetings) NotesInput(ctx context.Context, sessionID int64) (domain.MeetingNotesInput, error) {
	var in domain.MeetingNotesInput
	x, err := s.Session(ctx, sessionID)
	if err != nil {
		return in, err
	}
	in.Session = x
	if in.Meeting, err = s.Meeting(ctx, x.MeetingID); err != nil {
		return in, err
	}
	if in.Attendees, err = s.Attendance(ctx, sessionID); err != nil {
		return in, err
	}
	if in.Segments, err = s.Segments(ctx, sessionID); err != nil {
		return in, err
	}
	if in.Messages, err = s.Messages(ctx, sessionID, 0, 1000); err != nil {
		return in, err
	}
	for _, g := range in.Segments {
		if g.Identity != "" {
			in.Speakers = true
			break
		}
	}
	if len(x.People) > 0 {
		rows, err := s.db.Query(ctx, `SELECT COALESCE(NULLIF(display_name, ''), username) FROM users WHERE id = ANY($1) ORDER BY 1`, x.People)
		if err != nil {
			return in, err
		}
		if in.People, err = pgx.CollectRows(rows, pgx.RowTo[string]); err != nil {
			return in, err
		}
	}
	return in, nil
}

// --- Webhook bookkeeping ---

// FirstSeen records a LiveKit webhook's id and reports whether it is new.
// Call it in the system scope.
func (s *Meetings) FirstSeen(ctx context.Context, eventID string) (bool, error) {
	if eventID == "" {
		return true, nil
	}
	tag, err := s.db.Exec(ctx, `INSERT INTO livekit_events (id) VALUES ($1) ON CONFLICT DO NOTHING`, eventID)
	return tag.RowsAffected() == 1, err
}

// PruneEvents forgets webhook ids older than a day.
func (s *Meetings) PruneEvents(ctx context.Context) error {
	_, err := s.db.Exec(ctx, `DELETE FROM livekit_events WHERE received_at < now() - interval '1 day'`)
	return err
}

// --- Usage ---

// MeetingUsageDay is a workspace's use of meetings on one day.
type MeetingUsageDay struct {
	Day                time.Time
	Sessions           int
	ParticipantMinutes int64
	RecordingMinutes   int64
	RecordingBytes     int64
	TranscribedMinutes int64
}

// MeetingUsage sums the scope's meeting use per day in [from, to).
func (s *Meetings) MeetingUsage(ctx context.Context, from, to time.Time) ([]MeetingUsageDay, error) {
	rows, err := s.db.Query(ctx, `WITH days AS (
			SELECT date_trunc('day', ss.started_at) AS day, count(*) AS sessions FROM meeting_sessions ss
			WHERE ss.started_at >= $1 AND ss.started_at < $2 AND ss.connected_at IS NOT NULL GROUP BY 1),
		people AS (
			SELECT date_trunc('day', p.joined_at) AS day, sum(EXTRACT(EPOCH FROM (COALESCE(p.left_at, now()) - p.joined_at)) / 60)::bigint AS minutes
			FROM meeting_participants p WHERE p.joined_at >= $1 AND p.joined_at < $2 GROUP BY 1),
		rec AS (
			SELECT date_trunc('day', r.started_at) AS day,
				COALESCE(sum(EXTRACT(EPOCH FROM (r.ended_at - r.started_at)) / 60) FILTER (WHERE r.kind = 'recording'), 0)::bigint AS rec_min,
				COALESCE(sum(r.bytes) FILTER (WHERE r.kind = 'recording'), 0)::bigint AS rec_bytes,
				COALESCE(sum(EXTRACT(EPOCH FROM (r.ended_at - r.started_at)) / 60) FILTER (WHERE r.kind <> 'recording'), 0)::bigint AS audio_min
			FROM meeting_media r WHERE r.started_at >= $1 AND r.started_at < $2 AND r.ended_at IS NOT NULL GROUP BY 1)
		SELECT day, COALESCE(d.sessions, 0), COALESCE(p.minutes, 0), COALESCE(r.rec_min, 0), COALESCE(r.rec_bytes, 0), COALESCE(r.audio_min, 0)
		FROM (SELECT day FROM days UNION SELECT day FROM people UNION SELECT day FROM rec) x
		LEFT JOIN days d USING (day) LEFT JOIN people p USING (day) LEFT JOIN rec r USING (day)
		ORDER BY 1`, from, to)
	if err != nil {
		return nil, err
	}
	return pgx.CollectRows(rows, func(r pgx.CollectableRow) (MeetingUsageDay, error) {
		var u MeetingUsageDay
		var day *time.Time
		err := r.Scan(&day, &u.Sessions, &u.ParticipantMinutes, &u.RecordingMinutes, &u.RecordingBytes, &u.TranscribedMinutes)
		if day != nil {
			u.Day = *day
		}
		return u, err
	})
}
