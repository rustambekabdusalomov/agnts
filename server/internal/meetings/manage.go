package meetings

import (
	"context"
	"errors"
	"os"
	"path/filepath"
	"slices"
	"time"

	"agnts/internal/domain"
	"agnts/internal/store/postgres"
)

// Invites are who to invite: members by id and people by email.
type Invites struct {
	Users  []int64
	Emails []string
}

// Detail is a meeting as its page shows it.
type Detail struct {
	Meeting   domain.Meeting
	Invitees  []domain.Invitee
	MyRSVP    string // "" when the caller is not invited
	CanManage bool
	Link      string
}

func (s *Service) detail(ctx context.Context, c Caller, m domain.Meeting) (Detail, error) {
	inv, err := s.d.Store.Invitees(ctx, m.ID)
	if err != nil {
		return Detail{}, err
	}
	d := Detail{Meeting: m, Invitees: inv, CanManage: canManage(c, m), Link: s.Link(m.Code)}
	for _, i := range inv {
		if i.UserID != nil && *i.UserID == c.UserID {
			d.MyRSVP = i.RSVP
		}
	}
	return d, nil
}

// Create makes a meeting hosted by the caller and invites people.
func (s *Service) Create(ctx context.Context, c Caller, in domain.MeetingInput, inv Invites) (Detail, error) {
	if !s.Ready() {
		return Detail{}, unavailable("meetings need a LiveKit server (AGNTS_LIVEKIT_URL)")
	}
	if !c.Role.CanEdit() {
		return Detail{}, forbidden("viewers can join meetings but not create them")
	}
	if err := in.Clean(s.now(), true); err != nil {
		return Detail{}, err
	}
	invitees, err := s.checkInvites(ctx, c, inv)
	if err != nil {
		return Detail{}, err
	}
	var m domain.Meeting
	for range 5 {
		code, err := domain.NewMeetingCode()
		if err != nil {
			return Detail{}, err
		}
		m, err = s.d.Store.CreateMeeting(ctx, domain.Meeting{Code: code, Title: in.Title, Description: in.Description, HostID: &c.UserID,
			Kind: in.Kind, StartsAt: in.StartsAt, DurationMin: in.DurationMin, TimeZone: in.TimeZone, Access: in.Access, Guests: in.Guests,
			AutoRecord: in.AutoRecord, AutoNotes: in.AutoNotes, Language: in.Language})
		if errors.Is(err, postgres.ErrCodeTaken) {
			continue
		}
		if err != nil {
			return Detail{}, err
		}
		break
	}
	if m.ID == 0 {
		return Detail{}, errors.New("could not pick a meeting code")
	}
	if err := s.invite(ctx, c, m, invitees); err != nil {
		return Detail{}, err
	}
	s.publishChanged(ctx, c.WorkspaceID)
	return s.Get(ctx, c, m.ID)
}

// Get returns a meeting the caller may see.
func (s *Service) Get(ctx context.Context, c Caller, id int64) (Detail, error) {
	m, err := s.meeting(ctx, c, id)
	if err != nil {
		return Detail{}, err
	}
	return s.detail(ctx, c, m)
}

// List returns the meetings the caller sees in a view.
func (s *Service) List(ctx context.Context, c Caller, view postgres.MeetingView) ([]domain.Meeting, error) {
	return s.d.Store.ListMeetings(ctx, postgres.MeetingFilter{View: view, UserID: c.UserID, Owner: c.Role == domain.RoleOwner})
}

// Past returns ended sessions of the meetings the caller sees.
func (s *Service) Past(ctx context.Context, c Caller, before *time.Time, limit int) ([]postgres.SessionSummary, error) {
	return s.d.Store.PastSessions(ctx, c.UserID, c.Role == domain.RoleOwner, before, limit)
}

// Update changes a meeting's settings. A new time or a cancellation sends
// the invitees an updated invitation.
func (s *Service) Update(ctx context.Context, c Caller, id int64, in domain.MeetingInput) (Detail, error) {
	m, err := s.meeting(ctx, c, id)
	if err != nil {
		return Detail{}, err
	}
	if !canManage(c, m) {
		return Detail{}, forbidden("only the meeting's hosts can change it")
	}
	if m.CancelledAt != nil {
		return Detail{}, invalid("the meeting was cancelled")
	}
	if err := in.Clean(s.now(), false); err != nil {
		return Detail{}, err
	}
	moved := !sameTime(m.StartsAt, in.StartsAt) || m.DurationMin != in.DurationMin || m.Kind != in.Kind
	retitled := m.Title != in.Title || m.Description != in.Description
	nm, err := s.d.Store.UpdateMeeting(ctx, id, in, moved || retitled)
	if err != nil {
		return Detail{}, err
	}
	if moved {
		if err := s.d.Store.ResetReminders(ctx, id); err != nil {
			return Detail{}, err
		}
	}
	if (moved || retitled) && nm.Kind == domain.MeetingScheduled {
		s.sendInvitations(ctx, nm, nil, false)
	}
	if nm.Live != nil && (m.Guests != nm.Guests || m.Title != nm.Title) {
		s.roomChanged(ctx, nm, *nm.Live)
	}
	s.publishChanged(ctx, c.WorkspaceID)
	return s.detail(ctx, c, nm)
}

func sameTime(a, b *time.Time) bool {
	if a == nil || b == nil {
		return a == nil && b == nil
	}
	return a.Equal(*b)
}

// SetInvitees invites more people, and uninvites by invitee id.
func (s *Service) SetInvitees(ctx context.Context, c Caller, id int64, add Invites, remove []int64) (Detail, error) {
	m, err := s.meeting(ctx, c, id)
	if err != nil {
		return Detail{}, err
	}
	if !canManage(c, m) {
		return Detail{}, forbidden("only the meeting's hosts can invite people")
	}
	if len(remove) > 0 {
		if err := s.d.Store.RemoveInvitees(ctx, id, remove); err != nil {
			return Detail{}, err
		}
	}
	invitees, err := s.checkInvites(ctx, c, add)
	if err != nil {
		return Detail{}, err
	}
	if err := s.invite(ctx, c, m, invitees); err != nil {
		return Detail{}, err
	}
	return s.Get(ctx, c, id)
}

// checkInvites keeps members of the workspace and valid addresses; an
// address of a member invites the member.
func (s *Service) checkInvites(ctx context.Context, c Caller, inv Invites) ([]postgres.NewInvitee, error) {
	if len(inv.Users)+len(inv.Emails) == 0 {
		return nil, nil
	}
	if len(inv.Users)+len(inv.Emails) > domain.MeetingMaxInvitees {
		return nil, invalid("invite at most %d people at once", domain.MeetingMaxInvitees)
	}
	members, err := s.d.Workspaces.Members(ctx, c.WorkspaceID)
	if err != nil {
		return nil, err
	}
	byID := map[int64]bool{}
	byMail := map[string]int64{}
	for _, mb := range members {
		byID[mb.UserID] = true
		if mb.Email != "" {
			byMail[lower(mb.Email)] = mb.UserID
		}
	}
	var out []postgres.NewInvitee
	seen := map[int64]bool{}
	addUser := func(id int64) {
		if !seen[id] {
			seen[id] = true
			out = append(out, postgres.NewInvitee{UserID: &id})
		}
	}
	for _, id := range inv.Users {
		if !byID[id] {
			return nil, invalid("user %d is not a member of the workspace", id)
		}
		addUser(id)
	}
	mails := map[string]bool{}
	for _, e := range inv.Emails {
		e, err := domain.CleanInviteEmail(e)
		if err != nil {
			return nil, err
		}
		if id, ok := byMail[e]; ok {
			addUser(id)
			continue
		}
		if !mails[e] {
			mails[e] = true
			out = append(out, postgres.NewInvitee{Email: e})
		}
	}
	return out, nil
}

// invite stores the invitees, gives addresses their personal links and
// tells everyone new.
func (s *Service) invite(ctx context.Context, c Caller, m domain.Meeting, in []postgres.NewInvitee) error {
	if len(in) == 0 {
		return nil
	}
	tokens := map[string]string{}
	for i := range in {
		if in[i].UserID != nil {
			continue
		}
		tok, h, err := domain.NewGuestToken()
		if err != nil {
			return err
		}
		in[i].TokenHash, tokens[in[i].Email] = h, tok
	}
	added, err := s.d.Store.AddInvitees(ctx, m.ID, in)
	if err != nil {
		return err
	}
	var members []int64
	for _, a := range added {
		if a.UserID != nil && *a.UserID != c.UserID {
			members = append(members, *a.UserID)
		}
	}
	if m.Kind == domain.MeetingScheduled {
		s.sendInvitations(ctx, m, addedWithTokens(added, tokens), true)
	}
	for _, u := range members {
		s.publish(c.WorkspaceID, u, domain.EventMeetings, map[string]any{"meetingId": m.ID})
	}
	if m.Kind == domain.MeetingScheduled && s.d.Pusher != nil && len(members) > 0 {
		s.d.Pusher.MeetingPush(ctx, members, Push{Title: inviteTitle(m), Body: s.whenText(m), Code: m.Code, Tag: "meeting-invite-" + m.Code})
	}
	return nil
}

func inviteTitle(m domain.Meeting) string {
	if m.HostName != "" {
		return m.HostName + " invited you: " + titleOf(m)
	}
	return "You're invited: " + titleOf(m)
}

func titleOf(m domain.Meeting) string {
	if m.Title != "" {
		return m.Title
	}
	return "Meeting " + domain.FormatMeetingCode(m.Code)
}

// RSVP records the caller's answer to an invitation.
func (s *Service) RSVP(ctx context.Context, c Caller, id int64, answer string) error {
	if !domain.ValidRSVP(answer) {
		return invalid("answer yes, no or maybe")
	}
	if _, err := s.meeting(ctx, c, id); err != nil {
		return err
	}
	if err := s.d.Store.SetRSVP(ctx, id, c.UserID, answer); errors.Is(err, domain.ErrNotFound) {
		return invalid("you are not invited to this meeting")
	} else if err != nil {
		return err
	}
	return nil
}

// Cancel cancels a scheduled meeting and tells the invitees.
func (s *Service) Cancel(ctx context.Context, c Caller, id int64) error {
	m, err := s.meeting(ctx, c, id)
	if err != nil {
		return err
	}
	if !canManage(c, m) {
		return forbidden("only the meeting's hosts can cancel it")
	}
	if err := s.d.Store.CancelMeeting(ctx, id); err != nil {
		return err
	}
	m, err = s.d.Store.Meeting(ctx, id)
	if err != nil {
		return err
	}
	if m.Live != nil {
		s.end(ctx, m, *m.Live)
	}
	if m.Kind == domain.MeetingScheduled {
		s.sendInvitations(ctx, m, nil, false)
	}
	s.publishChanged(ctx, c.WorkspaceID)
	return nil
}

// Delete deletes a meeting with its sessions, recordings and transcripts.
// The notes documents stay.
func (s *Service) Delete(ctx context.Context, c Caller, id int64) error {
	m, err := s.meeting(ctx, c, id)
	if err != nil {
		return err
	}
	if c.Role != domain.RoleOwner && !m.IsHost(c.UserID) {
		return forbidden("only the meeting's host or the workspace's owner can delete it")
	}
	if m.Live != nil {
		s.end(ctx, m, *m.Live)
	}
	files, err := s.d.Store.DeleteMeeting(ctx, id)
	if err != nil {
		return err
	}
	for _, f := range files {
		s.removeFile(f)
	}
	s.publishChanged(ctx, c.WorkspaceID)
	return nil
}

// SetHost hands a meeting to another member.
func (s *Service) SetHost(ctx context.Context, c Caller, id, to int64) (Detail, error) {
	m, err := s.meeting(ctx, c, id)
	if err != nil {
		return Detail{}, err
	}
	if c.Role != domain.RoleOwner && !m.IsHost(c.UserID) {
		return Detail{}, forbidden("only the host or the workspace's owner can hand the meeting over")
	}
	if role, err := s.d.Workspaces.Role(ctx, c.WorkspaceID, to); err != nil || role == "" || role == domain.RoleViewer {
		return Detail{}, invalid("the new host must be a member who can edit")
	}
	if err := s.d.Store.SetMeetingHost(ctx, id, to); err != nil {
		return Detail{}, err
	}
	if m.Live != nil {
		s.rolesChanged(ctx, m.ID)
	}
	return s.Get(ctx, c, id)
}

// SetCohosts replaces a meeting's co-hosts.
func (s *Service) SetCohosts(ctx context.Context, c Caller, id int64, users []int64) (Detail, error) {
	m, err := s.meeting(ctx, c, id)
	if err != nil {
		return Detail{}, err
	}
	if c.Role != domain.RoleOwner && !m.IsHost(c.UserID) {
		return Detail{}, forbidden("only the host can choose co-hosts")
	}
	for _, u := range users {
		if role, err := s.d.Workspaces.Role(ctx, c.WorkspaceID, u); err != nil || role == "" {
			return Detail{}, invalid("co-hosts are members of the workspace")
		}
	}
	for _, u := range m.CohostIDs {
		if !slices.Contains(users, u) {
			if err := s.d.Store.SetCohost(ctx, id, u, false); err != nil {
				return Detail{}, err
			}
		}
	}
	for _, u := range users {
		if !m.IsHost(u) {
			if err := s.d.Store.SetCohost(ctx, id, u, true); err != nil {
				return Detail{}, err
			}
		}
	}
	if m.Live != nil {
		s.rolesChanged(ctx, m.ID)
	}
	return s.Get(ctx, c, id)
}

// Ring rings members into a live (or about to start) meeting: their phone
// and their open agnts pages, for half a minute.
func (s *Service) Ring(ctx context.Context, c Caller, id int64, users []int64) error {
	m, err := s.meeting(ctx, c, id)
	if err != nil {
		return err
	}
	if m.CancelledAt != nil {
		return invalid("the meeting was cancelled")
	}
	members, err := s.d.Workspaces.Members(ctx, c.WorkspaceID)
	if err != nil {
		return err
	}
	in := map[int64]bool{}
	for _, mb := range members {
		in[mb.UserID] = true
	}
	who := s.callerName(ctx, c.UserID)
	var ring []int64
	for _, u := range users {
		if in[u] && u != c.UserID && !slices.Contains(ring, u) {
			ring = append(ring, u)
		}
	}
	if len(ring) == 0 {
		return invalid("choose members of the workspace to call")
	}
	for _, u := range ring {
		s.publish(c.WorkspaceID, u, domain.EventMeetingCalling, map[string]any{"meetingId": m.ID, "code": m.Code, "title": titleOf(m),
			"from": who, "until": s.now().Add(30 * time.Second)})
	}
	if s.d.Pusher != nil {
		s.d.Pusher.MeetingPush(ctx, ring, Push{Title: who + " is calling you", Body: titleOf(m), Code: m.Code, Tag: "meeting-call-" + m.Code})
	}
	return nil
}

func (s *Service) callerName(ctx context.Context, userID int64) string {
	u, err := s.d.Users.ByID(ctx, userID)
	if err != nil {
		return "Someone"
	}
	return displayName(u)
}

func displayName(u domain.User) string {
	if u.DisplayName != "" {
		return u.DisplayName
	}
	return u.Username
}

// ReminderMinutes is the caller's reminder setting.
func (s *Service) ReminderMinutes(ctx context.Context, userID int64) (int, error) {
	return s.d.Store.MeetingReminderMin(ctx, userID)
}

// SetReminderMinutes changes it: 0, 5, 10 or 15.
func (s *Service) SetReminderMinutes(ctx context.Context, userID int64, n int) error {
	if !slices.Contains([]int{0, 5, 10, 15}, n) {
		return invalid("remind 5, 10 or 15 minutes before, or 0 for never")
	}
	return s.d.Store.SetMeetingReminderMin(ctx, userID, n)
}

// publishChanged tells the workspace's members their meeting lists changed.
func (s *Service) publishChanged(ctx context.Context, ws int64) {
	if s.d.Stream == nil {
		return
	}
	members, err := s.d.Workspaces.Members(ctx, ws)
	if err != nil {
		return
	}
	for _, mb := range members {
		s.publish(ws, mb.UserID, domain.EventMeetings, nil)
	}
}

// removeFile deletes a meeting file by its name in the media directory.
func (s *Service) removeFile(name string) {
	if s.cfg.MediaDir == "" || name == "" || filepath.Base(name) != name {
		return
	}
	if err := os.Remove(filepath.Join(s.cfg.MediaDir, name)); err != nil && !errors.Is(err, os.ErrNotExist) {
		s.d.Log.Warn("remove meeting file", "file", name, "err", err)
	}
}

func lower(s string) string {
	b := []byte(s)
	for i, c := range b {
		if c >= 'A' && c <= 'Z' {
			b[i] = c + 32
		}
	}
	return string(b)
}

// Search finds what was said in the meetings the caller sees.
func (s *Service) Search(ctx context.Context, c Caller, q string) ([]postgres.TranscriptHit, error) {
	if len([]rune(q)) < 2 {
		return nil, invalid("search for at least two letters")
	}
	return s.d.Store.SearchTranscripts(ctx, c.UserID, c.Role == domain.RoleOwner, q, 50)
}

// TicketMeetings returns the meetings a ticket is linked to that the
// caller sees.
func (s *Service) TicketMeetings(ctx context.Context, c Caller, key string) ([]postgres.MeetingTicket, error) {
	if s.d.Tickets == nil {
		return nil, nil
	}
	t, err := s.d.Tickets.TicketByKey(ctx, key)
	if err != nil {
		return nil, err
	}
	links, err := s.d.Store.MeetingTickets(ctx, 0, t.ID)
	if err != nil {
		return nil, err
	}
	out := links[:0]
	for _, l := range links {
		if ok, err := s.d.Store.CanSeeMeeting(ctx, l.MeetingID, c.UserID, c.Role == domain.RoleOwner); err == nil && ok {
			out = append(out, l)
		}
	}
	return out, nil
}

// Usage sums the workspace's meetings per day (the owner's page).
func (s *Service) Usage(ctx context.Context, c Caller, from, to time.Time) ([]postgres.MeetingUsageDay, error) {
	if c.Role != domain.RoleOwner {
		return nil, forbidden("only the workspace's owner sees its usage")
	}
	return s.d.Store.MeetingUsage(ctx, from, to)
}
