package meetings

import (
	"context"
	"errors"
	"fmt"
	"time"

	"agnts/internal/domain"
	"agnts/internal/livekit"
	"agnts/internal/store/postgres"
)

// Attributes agnts sets on participants; clients read them.
const (
	AttrPerson = "agnts.person" // u<id> or g<id>
	AttrRole   = "agnts.role"   // host, cohost, member or guest
	AttrHand   = "agnts.hand"   // set by the client when the hand is up; agnts clears it
)

// Data message topics agnts sends into a room.
const (
	TopicChat      = "agnts.chat"       // a chat message (JSON of the message)
	TopicKnock     = "agnts.knock"      // someone knocks; refresh the waiting room
	TopicState     = "agnts.state"      // roles or settings changed; refresh the call's state
	TopicAskUnmute = "agnts.ask-unmute" // a host asks you to unmute
)

// Grant is what a client connects to the call with.
type Grant struct {
	URL       string // LiveKit's wss:// address
	Token     string // the LiveKit access token
	Identity  string
	Seat      string // the seat's secret, for in-call requests
	Role      domain.MeetingRole
	Rights    domain.Rights
	SessionID int64
	Name      string
}

// Joiner is who asks to join, as the request says.
type Joiner struct {
	User *domain.User // signed in to agnts, if they are
	// GuestToken is a returning guest's token for this meeting.
	GuestToken string
	// Name is the name typed in the lobby (guests).
	Name string
	// Google: a guest Google vouched for.
	GoogleName, GoogleEmail string
	// InviteToken is an email invitee's personal link's token.
	InviteToken string
	Device      string
}

// JoinResult is the answer to a join: joined (Grant) or waiting (Knock).
type JoinResult struct {
	Meeting domain.Meeting
	Grant   *Grant
	// Knock is the waiting room: poll it with its secret.
	KnockID    int64
	KnockToken string
	// GuestToken is a new guest's token; the client keeps it to come back
	// as the same guest.
	GuestToken string
	GuestName  string
}

// PublicInfo is what anyone with the link sees before joining.
type PublicInfo struct {
	Meeting   domain.Meeting // title, host name, times, guest mode, live
	Workspace string
	// Member: the signed-in person is a member of the meeting's workspace.
	Member bool
	Name   string // the signed-in person's name
	// Recording and Notes are on in the live session: the lobby says so.
	Recording bool
	Notes     bool
	InCall    int
}

// byCode finds a meeting by its code and returns a context in its
// workspace.
func (s *Service) byCode(ctx context.Context, code string) (context.Context, domain.Meeting, error) {
	code, ok := domain.ParseMeetingCode(code)
	if !ok {
		return ctx, domain.Meeting{}, domain.ErrNotFound
	}
	m, err := s.d.Store.MeetingByCode(domain.System(ctx), code)
	if err != nil {
		return ctx, m, err
	}
	return domain.WithWorkspace(ctx, m.WorkspaceID), m, nil
}

// Info is the lobby's view of a meeting.
func (s *Service) Info(ctx context.Context, code string, u *domain.User) (PublicInfo, error) {
	if !s.Ready() {
		return PublicInfo{}, unavailable("meetings")
	}
	ctx, m, err := s.byCode(ctx, code)
	if err != nil {
		return PublicInfo{}, err
	}
	out := PublicInfo{Meeting: m, InCall: m.InCall}
	if w, err := s.d.Workspaces.ByID(ctx, m.WorkspaceID); err == nil {
		out.Workspace = w.Name
	}
	if u != nil {
		out.Name = displayName(*u)
		if role, err := s.d.Workspaces.Role(ctx, m.WorkspaceID, u.ID); err == nil && role != "" {
			out.Member = true
		}
	}
	if m.Live != nil {
		out.Recording, out.Notes = m.Live.Recording, m.Live.NotesOn
	}
	return out, nil
}

// person works out who a joiner is: a member, a returning guest, an email
// invitee, or a new guest (made here; GuestToken in the result).
func (s *Service) person(ctx context.Context, m domain.Meeting, j Joiner, res *JoinResult) (domain.Person, domain.WorkspaceRole, string, bool, error) {
	if j.User != nil {
		role, err := s.d.Workspaces.Role(ctx, m.WorkspaceID, j.User.ID)
		if err != nil && !errors.Is(err, domain.ErrNotFound) {
			return domain.Person{}, "", "", false, err
		}
		if role != "" {
			invited, err := s.d.Store.IsInvited(ctx, m.ID, j.User.ID)
			return domain.Person{UserID: j.User.ID}, role, displayName(*j.User), invited, err
		}
	}
	if j.GuestToken != "" {
		g, err := s.d.Store.MeetingGuestByToken(ctx, m.ID, domain.GuestTokenHash(j.GuestToken))
		if err == nil {
			if name, err := domain.CleanPersonName(j.Name); err == nil && name != g.Name && g.Via == domain.GuestByName {
				if err := s.d.Store.RenameMeetingGuest(ctx, g.ID, name); err == nil {
					g.Name = name
				}
			}
			return domain.Person{GuestID: g.ID}, "", g.Name, g.InviteeID != nil, nil
		}
		if !errors.Is(err, domain.ErrNotFound) {
			return domain.Person{}, "", "", false, err
		}
	}
	g := domain.MeetingGuest{MeetingID: m.ID, Via: domain.GuestByName}
	invited := false
	switch {
	case j.InviteToken != "":
		inv, err := s.d.Store.InviteeByToken(ctx, m.ID, domain.GuestTokenHash(j.InviteToken))
		if err != nil {
			if errors.Is(err, domain.ErrNotFound) {
				return domain.Person{}, "", "", false, invalid("this invitation link is no longer valid")
			}
			return domain.Person{}, "", "", false, err
		}
		g.Email, g.Via, g.InviteeID, invited = inv.Email, domain.GuestByInvite, &inv.ID, true
		g.Name = j.Name
		if g.Name == "" {
			g.Name = inv.Email
		}
	case j.GoogleEmail != "":
		g.Name, g.Email, g.Via = j.GoogleName, j.GoogleEmail, domain.GuestByGoogle
	case j.User != nil:
		// Signed in, but not a member: the same guest every time.
		if prev, err := s.d.Store.MeetingGuestByUser(ctx, m.ID, j.User.ID); err == nil {
			tok, _, err := s.reissueGuest(ctx, prev)
			res.GuestToken, res.GuestName = tok, prev.Name
			return domain.Person{GuestID: prev.ID}, "", prev.Name, false, err
		}
		g.Name, g.Email, g.Via, g.UserID = displayName(*j.User), j.User.Email, domain.GuestByAccount, &j.User.ID
	default:
		g.Name = j.Name
	}
	name, err := domain.CleanPersonName(g.Name)
	if err != nil {
		return domain.Person{}, "", "", false, err
	}
	g.Name = name
	tok, hash, err := domain.NewGuestToken()
	if err != nil {
		return domain.Person{}, "", "", false, err
	}
	g, err = s.d.Store.CreateMeetingGuest(ctx, g, hash)
	if err != nil {
		return domain.Person{}, "", "", false, err
	}
	res.GuestToken, res.GuestName = tok, g.Name
	return domain.Person{GuestID: g.ID}, "", g.Name, invited, nil
}

// reissueGuest is a guest of another workspace's account coming back:
// they get a fresh token for their browser (the old one stays valid).
func (s *Service) reissueGuest(ctx context.Context, g domain.MeetingGuest) (string, []byte, error) {
	tok, hash, err := domain.NewGuestToken()
	if err != nil {
		return "", nil, err
	}
	if _, err := s.d.Store.CreateMeetingGuest(ctx, domain.MeetingGuest{MeetingID: g.MeetingID, Name: g.Name, Email: g.Email, Via: g.Via,
		UserID: g.UserID}, hash); err != nil {
		return "", nil, err
	}
	return tok, hash, nil
}

// Join lets someone into a meeting's live session (starting it when there
// is none), puts them in the waiting room, or refuses them.
func (s *Service) Join(ctx context.Context, code string, j Joiner) (JoinResult, error) {
	if !s.Ready() {
		return JoinResult{}, unavailable("meetings")
	}
	ctx, m, err := s.byCode(ctx, code)
	if err != nil {
		return JoinResult{}, err
	}
	var res JoinResult
	res.Meeting = m
	p, wsRole, name, invited, err := s.person(ctx, m, j, &res)
	if err != nil {
		return res, err
	}
	device := domain.CleanDevice(j.Device)
	req := domain.JoinRequest{Meeting: m, Person: p, WorkspaceRole: wsRole, Invited: invited, MaxPeople: s.settings(ctx).MaxParticipants, Now: s.now()}
	// Look before starting a session: a refusal must not open one. Only
	// what doesn't depend on the session decides here: a locked meeting
	// still lets back whoever was let into its live session.
	if pre := domain.DecideJoin(req); pre.Outcome == domain.JoinRefused {
		switch pre.Reason {
		case domain.RefuseCancelled, domain.RefuseNotYet, domain.RefuseGuestsOff:
			return res, &RefusedError{Reason: pre.Reason}
		case domain.RefuseLocked:
			if m.Live == nil {
				return res, &RefusedError{Reason: pre.Reason}
			}
		}
	}
	x, created, err := s.d.Store.OpenSession(ctx, m.ID)
	if err != nil {
		return res, err
	}
	if created {
		if err := s.startRoom(ctx, m, x); err != nil {
			_, _ = s.d.Store.EndSession(context.WithoutCancel(ctx), x.ID, s.now())
			return res, err
		}
	}
	st, err := s.d.Store.PersonStatus(ctx, x.ID, p)
	if err != nil {
		return res, err
	}
	req.Admitted, req.Removed = st.Admitted, st.Removed
	present, err := s.d.Store.PresentPeople(ctx, x.ID)
	if err != nil {
		return res, err
	}
	req.InCall = countPeople(present, p)
	if !req.Admitted {
		if req.DeniedRecently, err = s.d.Store.DeniedSince(ctx, x.ID, p, s.now().Add(-domain.MeetingDenyCooldown)); err != nil {
			return res, err
		}
	}
	d := domain.DecideJoin(req)
	switch d.Outcome {
	case domain.JoinRefused:
		return res, &RefusedError{Reason: d.Reason}
	case domain.JoinKnock:
		k, tok, err := s.knock(ctx, m, x, p, name, device)
		if err != nil {
			return res, err
		}
		res.KnockID, res.KnockToken = k.ID, tok
		return res, nil
	}
	seat, secret, err := s.seat(ctx, x, p, name, device, false)
	if err != nil {
		return res, err
	}
	g, err := s.grant(ctx, m, x, seat, secret)
	if err != nil {
		return res, err
	}
	res.Grant = &g
	if created {
		s.wentLive(ctx, m, p)
	}
	return res, nil
}

// countPeople counts the people in a call, not counting p (a second
// device of someone already there doesn't take a place).
func countPeople(present []postgres.Present, p domain.Person) int {
	seen := map[domain.Person]bool{}
	for _, x := range present {
		if x.Person != p {
			seen[x.Person] = true
		}
	}
	return len(seen)
}

// seat gives a person a seat in the session and returns its secret.
func (s *Service) seat(ctx context.Context, x domain.MeetingSession, p domain.Person, name, device string, knocked bool) (domain.MeetingSeat, string, error) {
	tok, hash, err := domain.NewGuestToken()
	if err != nil {
		return domain.MeetingSeat{}, "", err
	}
	seat, err := s.d.Store.CreateSeat(ctx, domain.MeetingSeat{SessionID: x.ID, Person: p, Device: device, Name: name, Knocked: knocked}, hash)
	return seat, tok, err
}

// grant is the LiveKit token of a seat, with the rights of the person's
// role now.
func (s *Service) grant(ctx context.Context, m domain.Meeting, x domain.MeetingSession, seat domain.MeetingSeat, secret string) (Grant, error) {
	role, err := s.roleOf(ctx, m, seat.Person)
	if err != nil {
		return Grant{}, err
	}
	rights := domain.RightsOf(role, x.GuestsQuiet)
	tok, err := s.cfg.Keys.JoinToken(livekit.Join{Room: x.Room, Identity: seat.Identity(), Name: seat.Name,
		Attributes: map[string]string{AttrPerson: seat.Person.Key(), AttrRole: string(role)},
		Sources:    sources(rights), Data: true, Valid: 10 * time.Minute}, s.now())
	if err != nil {
		return Grant{}, err
	}
	return Grant{URL: s.cfg.LiveKitURL, Token: tok, Identity: seat.Identity(), Seat: secret, Role: role, Rights: rights, SessionID: x.ID, Name: seat.Name}, nil
}

// sources are what rights let a participant publish.
func sources(r domain.Rights) []string {
	var out []string
	if r.Publish {
		out = append(out, livekit.SourceCamera, livekit.SourceMicrophone)
	}
	if r.ScreenShare {
		out = append(out, livekit.SourceScreenShare, livekit.SourceScreenShareAudio)
	}
	return out
}

// roleOf is a person's role in a meeting now (co-hosts change).
func (s *Service) roleOf(ctx context.Context, m domain.Meeting, p domain.Person) (domain.MeetingRole, error) {
	if p.IsGuest() {
		return domain.RoleGuest, nil
	}
	wsRole, err := s.d.Workspaces.Role(ctx, m.WorkspaceID, p.UserID)
	if errors.Is(err, domain.ErrNotFound) {
		return domain.RoleGuest, nil
	}
	if err != nil {
		return "", err
	}
	return domain.RoleIn(m, p, wsRole), nil
}

// startRoom creates the session's LiveKit room with its settings, and
// starts what the meeting does on its own (recording, notes).
func (s *Service) startRoom(ctx context.Context, m domain.Meeting, x domain.MeetingSession) error {
	max := s.settings(ctx).MaxParticipants
	if _, err := s.d.LiveKit.CreateRoom(ctx, livekit.NewRoom{Name: x.Room, EmptyTimeout: int(domain.MeetingUnconnected.Seconds()),
		DepartureTimeout: int(domain.MeetingDeparture.Seconds()), MaxParticipants: max + 5, Metadata: roomMetadata(m, x)}); err != nil {
		return fmt.Errorf("start the call: %w", err)
	}
	return nil
}

// wentLive tells the invitees and hosts who aren't in the call that it
// started, and starts what the meeting does on its own.
func (s *Service) wentLive(ctx context.Context, m domain.Meeting, by domain.Person) {
	go func() {
		ctx := context.WithoutCancel(ctx)
		live, err := s.d.Store.Meeting(ctx, m.ID)
		if err != nil || live.Live == nil {
			return
		}
		if m.AutoNotes && s.NotesReady() && m.HostID != nil {
			if err := s.startNotes(ctx, live, *live.Live, *m.HostID); err != nil {
				s.d.Log.Warn("start notes on their own", "meeting", m.ID, "err", err)
			}
		}
		if m.AutoRecord && s.RecordingReady() && s.settings(ctx).AllowRecording {
			if err := s.startRecording(ctx, live, *live.Live, m.HostID); err != nil {
				s.d.Log.Warn("start recording on its own", "meeting", m.ID, "err", err)
			}
		}
		if m.Kind != domain.MeetingScheduled {
			return
		}
		inv, err := s.d.Store.Invitees(ctx, m.ID)
		if err != nil {
			return
		}
		var users []int64
		for _, i := range inv {
			if i.UserID != nil && *i.UserID != by.UserID && i.RSVP != domain.RSVPNo {
				users = append(users, *i.UserID)
				s.publish(m.WorkspaceID, *i.UserID, domain.EventMeetingLive, map[string]any{"meetingId": m.ID, "code": m.Code, "title": titleOf(m)})
			}
		}
		if s.d.Pusher != nil && len(users) > 0 {
			s.d.Pusher.MeetingPush(ctx, users, Push{Title: titleOf(m) + " has started", Body: "Tap to join", Code: m.Code, Tag: "meeting-live-" + m.Code})
		}
	}()
}

// knock puts someone in the waiting room and tells those who can admit.
func (s *Service) knock(ctx context.Context, m domain.Meeting, x domain.MeetingSession, p domain.Person, name, device string) (domain.MeetingKnock, string, error) {
	tok, hash, err := domain.NewGuestToken()
	if err != nil {
		return domain.MeetingKnock{}, "", err
	}
	k, err := s.d.Store.CreateKnock(ctx, domain.MeetingKnock{SessionID: x.ID, Person: p, Device: device, Name: name}, hash)
	if err != nil {
		return k, "", err
	}
	admitters, err := s.admitters(ctx, m, x)
	if err != nil {
		return k, tok, nil
	}
	if len(admitters.identities) > 0 {
		_ = s.d.LiveKit.SendData(ctx, x.Room, TopicKnock, mustJSON(map[string]any{"name": name, "knockId": k.ID}), admitters.identities...)
	}
	// A host who is not in the call hears about it on their phone.
	if m.HostID != nil && !admitters.hostIn {
		s.publish(m.WorkspaceID, *m.HostID, domain.EventMeetingKnock, map[string]any{"meetingId": m.ID, "code": m.Code, "name": name})
		if s.d.Pusher != nil {
			s.d.Pusher.MeetingPush(ctx, []int64{*m.HostID}, Push{Title: name + " wants to join", Body: titleOf(m), Code: m.Code, Tag: "meeting-knock-" + m.Code})
		}
	}
	return k, tok, nil
}

// admitterSet is who in a call may admit knocks.
type admitterSet struct {
	identities []string
	people     map[domain.Person]bool
	hostIn     bool
}

// admitters are the people in the call who may admit: hosts, co-hosts
// and the workspace's owner; when none of them is there, the members who
// came in without knocking, so a call doesn't get stuck.
func (s *Service) admitters(ctx context.Context, m domain.Meeting, x domain.MeetingSession) (admitterSet, error) {
	present, err := s.d.Store.PresentPeople(ctx, x.ID)
	if err != nil {
		return admitterSet{}, err
	}
	var strong, fallback admitterSet
	strong.people, fallback.people = map[domain.Person]bool{}, map[domain.Person]bool{}
	for _, p := range present {
		if p.Person.IsGuest() {
			continue
		}
		role, err := s.d.Workspaces.Role(ctx, m.WorkspaceID, p.Person.UserID)
		if err != nil || role == "" {
			continue
		}
		if m.IsHost(p.Person.UserID) {
			strong.hostIn = true
		}
		if m.IsHost(p.Person.UserID) || m.IsCohost(p.Person.UserID) || role == domain.RoleOwner {
			strong.identities = append(strong.identities, p.Identity)
			strong.people[p.Person] = true
		} else if !p.Knocked {
			fallback.identities = append(fallback.identities, p.Identity)
			fallback.people[p.Person] = true
		}
	}
	if len(strong.people) > 0 {
		return strong, nil
	}
	fallback.hostIn = strong.hostIn
	return fallback, nil
}

// WaitKnock waits up to wait for a knock to be decided, and answers like a
// join: admitted (with the grant), still waiting, or refused.
func (s *Service) WaitKnock(ctx context.Context, code string, knockID int64, token string, wait time.Duration) (JoinResult, error) {
	ctx, m, err := s.byCode(ctx, code)
	if err != nil {
		return JoinResult{}, err
	}
	res := JoinResult{Meeting: m, KnockID: knockID, KnockToken: token}
	deadline := s.now().Add(wait)
	for {
		k, err := s.d.Store.KnockByToken(ctx, knockID, domain.GuestTokenHash(token))
		if err != nil {
			return res, err
		}
		x, err := s.d.Store.Session(ctx, k.SessionID)
		if err != nil {
			return res, err
		}
		if k.State == domain.KnockWaiting && (x.EndedAt != nil || s.now().Sub(k.CreatedAt) > domain.MeetingKnockWait) {
			k.State = domain.KnockExpired
		}
		switch k.State {
		case domain.KnockDenied:
			return res, &RefusedError{Reason: domain.RefuseDenied}
		case domain.KnockExpired:
			return res, &RefusedError{Reason: "expired"}
		case domain.KnockAdmitted:
			if k.SeatID == nil {
				return res, &RefusedError{Reason: "expired"}
			}
			seat, err := s.d.Store.Seat(ctx, *k.SeatID)
			if err != nil {
				return res, err
			}
			if seat.RemovedAt != nil {
				return res, &RefusedError{Reason: domain.RefuseRemoved}
			}
			// The seat's secret is handed out here, once per poll: a new one.
			secret, hash, err := domain.NewGuestToken()
			if err != nil {
				return res, err
			}
			if err := s.d.Store.ReplaceSeatToken(ctx, seat.ID, hash); err != nil {
				return res, err
			}
			g, err := s.grant(ctx, m, x, seat, secret)
			if err != nil {
				return res, err
			}
			res.Grant, res.KnockID, res.KnockToken = &g, 0, ""
			return res, nil
		}
		if !s.now().Before(deadline) {
			return res, nil
		}
		select {
		case <-ctx.Done():
			return res, nil
		case <-time.After(time.Second):
		}
	}
}
