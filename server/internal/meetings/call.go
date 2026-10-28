package meetings

import (
	"context"
	"encoding/json"
	"errors"
	"sort"
	"time"

	"agnts/internal/domain"
	"agnts/internal/livekit"
)

// InCall is a seat's request in a call: who asks, in which meeting and
// session, with what role now.
type InCall struct {
	ctx     context.Context
	Meeting domain.Meeting
	Session domain.MeetingSession
	Seat    domain.MeetingSeat
	Role    domain.MeetingRole
	Rights  domain.Rights
	WSRole  domain.WorkspaceRole // "" for guests
}

// Context is the request's context in the meeting's workspace.
func (c InCall) Context() context.Context { return c.ctx }

// Seat finds the seat a secret names, in the meeting of code, in a live
// session; ErrSeat when it is unknown, removed or over.
func (s *Service) Seat(ctx context.Context, code, secret string) (InCall, error) {
	if secret == "" {
		return InCall{}, ErrSeat
	}
	ref, err := s.d.Store.SeatByToken(domain.System(ctx), domain.GuestTokenHash(secret))
	if errors.Is(err, domain.ErrNotFound) {
		return InCall{}, ErrSeat
	}
	if err != nil {
		return InCall{}, err
	}
	ctx = domain.WithWorkspace(ctx, ref.WorkspaceID)
	m, err := s.d.Store.Meeting(ctx, ref.MeetingID)
	if err != nil {
		return InCall{}, err
	}
	if c, ok := domain.ParseMeetingCode(code); !ok || c != m.Code {
		return InCall{}, ErrSeat
	}
	if !ref.SessionLive || ref.Seat.RemovedAt != nil {
		return InCall{}, ErrSeat
	}
	x, err := s.d.Store.Session(ctx, ref.Seat.SessionID)
	if err != nil {
		return InCall{}, err
	}
	c := InCall{ctx: ctx, Meeting: m, Session: x, Seat: ref.Seat}
	if !ref.Seat.Person.IsGuest() {
		c.WSRole, err = s.d.Workspaces.Role(ctx, m.WorkspaceID, ref.Seat.Person.UserID)
		if err != nil && !errors.Is(err, domain.ErrNotFound) {
			return InCall{}, err
		}
	}
	c.Role = domain.RoleIn(m, ref.Seat.Person, c.WSRole)
	c.Rights = domain.RightsOf(c.Role, x.GuestsQuiet)
	if c.WSRole == domain.RoleOwner {
		// The workspace's owner moderates any of its calls.
		c.Rights.Admit, c.Rights.Moderate, c.Rights.Record = true, true, true
	}
	return c, nil
}

// Refresh hands a seat a new LiveKit token (to reconnect after a long
// drop, or after its rights changed).
func (s *Service) Refresh(c InCall) (Grant, error) {
	g, err := s.grant(c.ctx, c.Meeting, c.Session, c.Seat, "")
	g.Seat = ""
	return g, err
}

// CallPerson is someone in the call as the people panel shows them.
type CallPerson struct {
	Key        string
	Name       string
	Role       domain.MeetingRole
	Identities []string
	Email      string // a guest's, for hosts only
	Knocked    bool
	JoinedAt   time.Time
}

// CallState is a call as a seat sees it.
type CallState struct {
	Meeting  domain.Meeting
	Session  domain.MeetingSession
	Me       CallPerson
	Rights   domain.Rights
	CanAdmit bool
	People   []CallPerson
	Knocks   []domain.MeetingKnock // when the seat can admit
	// What hosts can turn on here.
	RecordingAvailable bool
	NotesAvailable     bool
	Recording          bool
	Workspace          string // slug, for links to the meeting's page
}

// State returns the call as the seat sees it.
func (s *Service) State(c InCall) (CallState, error) {
	ctx := c.ctx
	present, err := s.d.Store.PresentPeople(ctx, c.Session.ID)
	if err != nil {
		return CallState{}, err
	}
	out := CallState{Meeting: c.Meeting, Session: c.Session, Rights: c.Rights, Recording: c.Session.Recording,
		RecordingAvailable: s.RecordingReady() && s.settings(ctx).AllowRecording, NotesAvailable: s.NotesReady()}
	if w, err := s.d.Workspaces.ByID(ctx, c.Meeting.WorkspaceID); err == nil && c.WSRole != "" {
		out.Workspace = w.Slug
	}
	people := map[domain.Person]*CallPerson{}
	var order []domain.Person
	for _, p := range present {
		cp := people[p.Person]
		if cp == nil {
			role, err := s.roleOf(ctx, c.Meeting, p.Person)
			if err != nil {
				return CallState{}, err
			}
			cp = &CallPerson{Key: p.Person.Key(), Name: p.Name, Role: role, Knocked: p.Knocked, JoinedAt: p.JoinedAt}
			people[p.Person] = cp
			order = append(order, p.Person)
		}
		cp.Identities = append(cp.Identities, p.Identity)
	}
	for _, p := range order {
		out.People = append(out.People, *people[p])
	}
	sort.SliceStable(out.People, func(i, j int) bool { return rank(out.People[i].Role) < rank(out.People[j].Role) })
	out.Me = CallPerson{Key: c.Seat.Person.Key(), Name: c.Seat.Name, Role: c.Role, Identities: []string{c.Seat.Identity()}}
	out.CanAdmit, err = s.canAdmit(c)
	if err != nil {
		return out, err
	}
	if out.CanAdmit {
		if out.Knocks, err = s.d.Store.WaitingKnocks(ctx, c.Session.ID); err != nil {
			return out, err
		}
	}
	if c.Rights.Moderate {
		for i, p := range out.People {
			if pp, ok := domain.ParsePersonKey(p.Key); ok && pp.IsGuest() {
				if g, err := s.d.Store.MeetingGuest(ctx, pp.GuestID); err == nil {
					out.People[i].Email = g.Email
				}
			}
		}
	}
	return out, nil
}

func rank(r domain.MeetingRole) int {
	return map[domain.MeetingRole]int{domain.RoleHost: 0, domain.RoleCohost: 1, domain.RoleMember: 2, domain.RoleGuest: 3}[r]
}

// canAdmit reports whether the seat may let knockers in.
func (s *Service) canAdmit(c InCall) (bool, error) {
	if c.Rights.Admit {
		return true, nil
	}
	if c.Role != domain.RoleMember || c.Seat.Knocked {
		return false, nil
	}
	a, err := s.admitters(c.ctx, c.Meeting, c.Session)
	if err != nil {
		return false, err
	}
	return a.people[c.Seat.Person], nil
}

// Admit lets a knocker in (a seat for them; their poll collects it).
func (s *Service) Admit(c InCall, knockID int64) error {
	ok, err := s.canAdmit(c)
	if err != nil {
		return err
	}
	if !ok {
		return forbidden("only the hosts can let people in")
	}
	return s.admit(c, knockID)
}

func (s *Service) admit(c InCall, knockID int64) error {
	ctx := c.ctx
	k, err := s.d.Store.Knock(ctx, knockID)
	if err != nil || k.SessionID != c.Session.ID {
		return domain.ErrNotFound
	}
	if k.State != domain.KnockWaiting {
		return nil
	}
	seat, _, err := s.seat(ctx, c.Session, k.Person, k.Name, k.Device, true)
	if err != nil {
		return err
	}
	if _, err := s.d.Store.DecideKnock(ctx, k.ID, domain.KnockAdmitted, c.Seat.Person.UserID, &seat.ID); err != nil {
		return err
	}
	s.knocksChanged(c)
	return nil
}

// AdmitAll lets everyone waiting in.
func (s *Service) AdmitAll(c InCall) error {
	ok, err := s.canAdmit(c)
	if err != nil {
		return err
	}
	if !ok {
		return forbidden("only the hosts can let people in")
	}
	ks, err := s.d.Store.WaitingKnocks(c.ctx, c.Session.ID)
	if err != nil {
		return err
	}
	for _, k := range ks {
		if err := s.admit(c, k.ID); err != nil {
			return err
		}
	}
	return nil
}

// Deny turns a knocker away.
func (s *Service) Deny(c InCall, knockID int64) error {
	ok, err := s.canAdmit(c)
	if err != nil {
		return err
	}
	if !ok {
		return forbidden("only the hosts can turn people away")
	}
	k, err := s.d.Store.Knock(c.ctx, knockID)
	if err != nil || k.SessionID != c.Session.ID {
		return domain.ErrNotFound
	}
	if _, err := s.d.Store.DecideKnock(c.ctx, k.ID, domain.KnockDenied, c.Seat.Person.UserID, nil); err != nil {
		return err
	}
	s.knocksChanged(c)
	return nil
}

// knocksChanged has the other admitters refresh their waiting room.
func (s *Service) knocksChanged(c InCall) {
	if a, err := s.admitters(c.ctx, c.Meeting, c.Session); err == nil && len(a.identities) > 0 {
		_ = s.d.LiveKit.SendData(c.ctx, c.Session.Room, TopicKnock, mustJSON(map[string]any{}), a.identities...)
	}
}

// chatPerMinute caps one person's messages.
const chatPerMinute = 30

// Send posts a chat message to the call.
func (s *Service) Send(c InCall, body string) (domain.MeetingMessage, error) {
	if !c.Rights.Chat {
		return domain.MeetingMessage{}, forbidden("the hosts turned guests' chat off")
	}
	body, err := domain.CleanChatMessage(body)
	if err != nil {
		return domain.MeetingMessage{}, err
	}
	if f := domain.ScanSecrets(body, domain.Redactor{}); len(f) > 0 {
		return domain.MeetingMessage{}, invalid("the message looks like it holds a secret (a token or a password); remove it before sending")
	}
	n, err := s.d.Store.MessagesSince(c.ctx, c.Session.ID, c.Seat.Person, s.now().Add(-time.Minute))
	if err != nil {
		return domain.MeetingMessage{}, err
	}
	if n >= chatPerMinute {
		return domain.MeetingMessage{}, ErrTooMany
	}
	m, err := s.d.Store.AddMessage(c.ctx, domain.MeetingMessage{SessionID: c.Session.ID, Person: c.Seat.Person, Name: c.Seat.Name, Body: body})
	if err != nil {
		return m, err
	}
	_ = s.d.LiveKit.SendData(c.ctx, c.Session.Room, TopicChat, mustJSON(ChatJSON(m)))
	return m, nil
}

// ChatJSON is a message as clients receive it in the room.
func ChatJSON(m domain.MeetingMessage) map[string]any {
	return map[string]any{"id": m.ID, "person": m.Person.Key(), "name": m.Name, "body": m.Body, "at": m.CreatedAt}
}

// Messages returns the session's chat after a message id.
func (s *Service) Messages(c InCall, after int64) ([]domain.MeetingMessage, error) {
	return s.d.Store.Messages(c.ctx, c.Session.ID, after, 500)
}

// target finds a person in the call by key, and the seat's right to act
// on them.
func (s *Service) target(c InCall, key string, right bool, what string) (domain.Person, []string, error) {
	if !right {
		return domain.Person{}, nil, forbidden("only the hosts can %s", what)
	}
	p, ok := domain.ParsePersonKey(key)
	if !ok {
		return p, nil, domain.ErrNotFound
	}
	ids, err := s.presentIdentities(c, p)
	if err != nil {
		return p, nil, err
	}
	if !p.IsGuest() && c.Meeting.IsHost(p.UserID) && !c.Meeting.IsHost(c.Seat.Person.UserID) && c.WSRole != domain.RoleOwner {
		return p, nil, forbidden("co-hosts can't %s the host", what)
	}
	return p, ids, nil
}

func (s *Service) presentIdentities(c InCall, p domain.Person) ([]string, error) {
	present, err := s.d.Store.PresentPeople(c.ctx, c.Session.ID)
	if err != nil {
		return nil, err
	}
	var out []string
	for _, x := range present {
		if x.Person == p {
			out = append(out, x.Identity)
		}
	}
	return out, nil
}

// Mute mutes a person's microphone, camera or screen share on all their
// devices. LiveKit can't unmute someone: AskUnmute asks them.
func (s *Service) Mute(c InCall, key, source string) error {
	_, ids, err := s.target(c, key, c.Rights.Moderate, "mute people")
	if err != nil || len(ids) == 0 {
		return err
	}
	ps, err := s.d.LiveKit.ListParticipants(c.ctx, c.Session.Room)
	if err != nil {
		return err
	}
	for _, id := range ids {
		for _, lp := range ps {
			if lp.Identity != id {
				continue
			}
			for _, t := range lp.Tracks {
				if t.Muted {
					continue
				}
				if (source == livekit.SourceMicrophone && t.IsMicrophone()) || (source == livekit.SourceCamera && t.IsCamera()) ||
					(source == livekit.SourceScreenShare && (t.IsScreenShare() || t.IsScreenAudio())) {
					if err := s.d.LiveKit.MuteTrack(c.ctx, c.Session.Room, id, t.SID); err != nil && !errors.Is(err, livekit.ErrNotFound) {
						return err
					}
				}
			}
		}
	}
	return nil
}

// MuteAll mutes everyone's microphone but the seat's.
func (s *Service) MuteAll(c InCall) error {
	if !c.Rights.Moderate {
		return forbidden("only the hosts can mute everyone")
	}
	ps, err := s.d.LiveKit.ListParticipants(c.ctx, c.Session.Room)
	if err != nil {
		return err
	}
	for _, lp := range ps {
		p, _, ok := domain.ParseMeetingIdentity(lp.Identity)
		if !ok || p == c.Seat.Person {
			continue
		}
		for _, t := range lp.Tracks {
			if t.IsMicrophone() && !t.Muted {
				_ = s.d.LiveKit.MuteTrack(c.ctx, c.Session.Room, lp.Identity, t.SID)
			}
		}
	}
	return nil
}

// AskUnmute asks a muted person to turn their microphone on.
func (s *Service) AskUnmute(c InCall, key string) error {
	_, ids, err := s.target(c, key, c.Rights.Moderate, "ask people to unmute")
	if err != nil || len(ids) == 0 {
		return err
	}
	return s.d.LiveKit.SendData(c.ctx, c.Session.Room, TopicAskUnmute, mustJSON(map[string]any{"from": c.Seat.Name}), ids...)
}

// LowerHand lowers someone's raised hand (or the seat's own).
func (s *Service) LowerHand(c InCall, key string) error {
	_, ids, err := s.target(c, key, c.Rights.Moderate || key == c.Seat.Person.Key(), "lower hands")
	if err != nil {
		return err
	}
	for _, id := range ids {
		if err := s.d.LiveKit.UpdateParticipant(c.ctx, c.Session.Room, id, nil, map[string]string{AttrHand: ""}); err != nil &&
			!errors.Is(err, livekit.ErrNotFound) {
			return err
		}
	}
	return nil
}

// Remove disconnects a person from the session, on every device; they
// can't come back to it.
func (s *Service) Remove(c InCall, key string) error {
	p, _, err := s.target(c, key, c.Rights.Moderate, "remove people")
	if err != nil {
		return err
	}
	if p == c.Seat.Person {
		return invalid("leave the call instead of removing yourself")
	}
	ids, err := s.d.Store.RemovePerson(c.ctx, c.Session.ID, p)
	if err != nil {
		return err
	}
	present, _ := s.presentIdentities(c, p)
	for _, id := range append(ids, present...) {
		if err := s.d.LiveKit.RemoveParticipant(c.ctx, c.Session.Room, id); err != nil && !errors.Is(err, livekit.ErrNotFound) {
			s.d.Log.Warn("remove participant", "room", c.Session.Room, "identity", id, "err", err)
		}
	}
	s.stateChanged(c.ctx, c.Session)
	return nil
}

// SetCohost makes a member in the call a co-host, or not (the host only).
func (s *Service) SetCohost(c InCall, key string, on bool) error {
	p, _, err := s.target(c, key, c.Rights.ManageCohosts || c.WSRole == domain.RoleOwner, "choose co-hosts")
	if err != nil {
		return err
	}
	if p.IsGuest() {
		return invalid("co-hosts are members of the workspace")
	}
	if role, err := s.d.Workspaces.Role(c.ctx, c.Meeting.WorkspaceID, p.UserID); err != nil || role == "" {
		return invalid("co-hosts are members of the workspace")
	}
	if c.Meeting.IsHost(p.UserID) {
		return invalid("the host is the host")
	}
	if err := s.d.Store.SetCohost(c.ctx, c.Meeting.ID, p.UserID, on); err != nil {
		return err
	}
	s.rolesChanged(c.ctx, c.Meeting.ID)
	return nil
}

// Lock locks or unlocks the meeting: nobody new comes in while it is
// locked, not even members.
func (s *Service) Lock(c InCall, locked bool) error {
	if !c.Rights.Moderate {
		return forbidden("only the hosts can lock the meeting")
	}
	if err := s.d.Store.SetMeetingLocked(c.ctx, c.Meeting.ID, locked); err != nil {
		return err
	}
	c.Meeting.Locked = locked
	s.roomChanged(c.ctx, c.Meeting, c.Session)
	return nil
}

// SetGuests changes what guests may do: knock, join without waiting
// ("open", until the session ends) or nothing; quiet turns their chat and
// screen sharing off.
func (s *Service) SetGuests(c InCall, mode domain.GuestMode, quiet *bool) error {
	if !c.Rights.Moderate {
		return forbidden("only the hosts can change who may come in")
	}
	if mode != "" {
		if !mode.Valid() {
			return invalid("guests is off, knock or open")
		}
		if err := s.d.Store.SetMeetingGuests(c.ctx, c.Meeting.ID, mode); err != nil {
			return err
		}
		c.Meeting.Guests = mode
	}
	if quiet != nil && *quiet != c.Session.GuestsQuiet {
		if err := s.d.Store.SetGuestsQuiet(c.ctx, c.Session.ID, *quiet); err != nil {
			return err
		}
		c.Session.GuestsQuiet = *quiet
		s.applyRights(c.ctx, c.Meeting, c.Session)
	}
	s.roomChanged(c.ctx, c.Meeting, c.Session)
	return nil
}

// End ends the call for everyone.
func (s *Service) End(c InCall) error {
	if !c.Rights.ManageCohosts && c.WSRole != domain.RoleOwner {
		return forbidden("only the host can end the call for everyone")
	}
	s.end(c.ctx, c.Meeting, c.Session)
	return nil
}

// end stops the session's recordings, closes its room and the session.
func (s *Service) end(ctx context.Context, m domain.Meeting, x domain.MeetingSession) {
	s.stopEgress(ctx, x, "")
	if err := s.d.LiveKit.DeleteRoom(ctx, x.Room); err != nil && !errors.Is(err, livekit.ErrNotFound) {
		s.d.Log.Warn("delete room", "room", x.Room, "err", err)
	}
	s.sessionEnded(ctx, m, x, s.now())
}

// roomMeta is the room's metadata: what every client shows (banners).
type roomMeta struct {
	Title       string `json:"title"`
	Locked      bool   `json:"locked"`
	Guests      string `json:"guests"`
	GuestsQuiet bool   `json:"guestsQuiet"`
	Recording   bool   `json:"recording"`
	Notes       bool   `json:"notes"`
}

func roomMetadata(m domain.Meeting, x domain.MeetingSession) string {
	return string(mustJSON(roomMeta{Title: titleOf(m), Locked: m.Locked, Guests: string(m.Guests), GuestsQuiet: x.GuestsQuiet,
		Recording: x.Recording, Notes: x.NotesOn}))
}

// roomChanged sends the room its new metadata and asks clients to
// refresh.
func (s *Service) roomChanged(ctx context.Context, m domain.Meeting, x domain.MeetingSession) {
	if fresh, err := s.d.Store.Session(ctx, x.ID); err == nil {
		x = fresh
	}
	if fresh, err := s.d.Store.Meeting(ctx, m.ID); err == nil {
		m = fresh
	}
	if err := s.d.LiveKit.UpdateRoomMetadata(ctx, x.Room, roomMetadata(m, x)); err != nil && !errors.Is(err, livekit.ErrNotFound) {
		s.d.Log.Warn("room metadata", "room", x.Room, "err", err)
	}
	s.stateChanged(ctx, x)
}

// stateChanged asks every client to refresh the call's state.
func (s *Service) stateChanged(ctx context.Context, x domain.MeetingSession) {
	_ = s.d.LiveKit.SendData(ctx, x.Room, TopicState, mustJSON(map[string]any{}))
}

// rolesChanged gives everyone in a meeting's live call the rights of
// their role now (co-hosts changed).
func (s *Service) rolesChanged(ctx context.Context, meetingID int64) {
	m, err := s.d.Store.Meeting(ctx, meetingID)
	if err != nil || m.Live == nil {
		return
	}
	s.applyRights(ctx, m, *m.Live)
	s.stateChanged(ctx, *m.Live)
}

// applyRights updates the permissions and role attribute of everyone
// connected to a session.
func (s *Service) applyRights(ctx context.Context, m domain.Meeting, x domain.MeetingSession) {
	present, err := s.d.Store.PresentPeople(ctx, x.ID)
	if err != nil {
		return
	}
	roles := map[domain.Person]domain.MeetingRole{}
	for _, p := range present {
		role, ok := roles[p.Person]
		if !ok {
			if role, err = s.roleOf(ctx, m, p.Person); err != nil {
				continue
			}
			roles[p.Person] = role
		}
		perm := &livekit.Permission{Sources: sources(domain.RightsOf(role, x.GuestsQuiet)), Data: true}
		if err := s.d.LiveKit.UpdateParticipant(ctx, x.Room, p.Identity, perm, map[string]string{AttrRole: string(role)}); err != nil &&
			!errors.Is(err, livekit.ErrNotFound) {
			s.d.Log.Warn("update participant", "room", x.Room, "identity", p.Identity, "err", err)
		}
	}
}

func mustJSON(v any) []byte {
	b, err := json.Marshal(v)
	if err != nil {
		return []byte("{}")
	}
	return b
}
