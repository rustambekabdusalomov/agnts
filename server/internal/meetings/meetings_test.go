package meetings_test

import (
	"context"
	"encoding/base64"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"log/slog"
	"os"
	"path/filepath"
	"strings"
	"sync"
	"testing"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"

	"agnts/internal/documents"
	"agnts/internal/domain"
	"agnts/internal/livekit"
	"agnts/internal/mail"
	"agnts/internal/meetings"
	"agnts/internal/orchestrator"
	"agnts/internal/store/postgres"
	"agnts/internal/store/postgres/pgtest"
)

// fakeLiveKit records what the service asks LiveKit to do.
type fakeLiveKit struct {
	mu           sync.Mutex
	rooms        map[string]livekit.NewRoom
	metadata     map[string]string
	participants map[string][]livekit.Participant
	calls        []string
	data         []sent
	egress       int
	egresses     map[string]livekit.RoomRecording
}

type sent struct {
	room, topic string
	body        map[string]any
	to          []string
}

func newFakeLiveKit() *fakeLiveKit {
	return &fakeLiveKit{rooms: map[string]livekit.NewRoom{}, metadata: map[string]string{}, participants: map[string][]livekit.Participant{},
		egresses: map[string]livekit.RoomRecording{}}
}

func (f *fakeLiveKit) log(s string) { f.calls = append(f.calls, s) }

func (f *fakeLiveKit) CreateRoom(_ context.Context, r livekit.NewRoom) (livekit.Room, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	f.log("create " + r.Name)
	f.rooms[r.Name], f.metadata[r.Name] = r, r.Metadata
	return livekit.Room{Name: r.Name, SID: "RM_" + r.Name}, nil
}

func (f *fakeLiveKit) ListRooms(_ context.Context, names ...string) ([]livekit.Room, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	var out []livekit.Room
	for _, n := range names {
		if _, ok := f.rooms[n]; ok {
			out = append(out, livekit.Room{Name: n})
		}
	}
	return out, nil
}

func (f *fakeLiveKit) DeleteRoom(_ context.Context, room string) error {
	f.mu.Lock()
	defer f.mu.Unlock()
	f.log("delete " + room)
	if _, ok := f.rooms[room]; !ok {
		return livekit.ErrNotFound
	}
	delete(f.rooms, room)
	return nil
}

func (f *fakeLiveKit) ListParticipants(_ context.Context, room string) ([]livekit.Participant, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	return f.participants[room], nil
}

func (f *fakeLiveKit) RemoveParticipant(_ context.Context, room, identity string) error {
	f.mu.Lock()
	defer f.mu.Unlock()
	f.log("remove " + identity)
	return nil
}

func (f *fakeLiveKit) MuteTrack(_ context.Context, room, identity, sid string) error {
	f.mu.Lock()
	defer f.mu.Unlock()
	f.log("mute " + identity + " " + sid)
	return nil
}

func (f *fakeLiveKit) UpdateParticipant(_ context.Context, room, identity string, perm *livekit.Permission, attrs map[string]string) error {
	f.mu.Lock()
	defer f.mu.Unlock()
	srcs := ""
	if perm != nil {
		srcs = strings.Join(perm.Sources, ",")
	}
	f.log(fmt.Sprintf("update %s [%s] %v", identity, srcs, attrs))
	return nil
}

func (f *fakeLiveKit) UpdateRoomMetadata(_ context.Context, room, md string) error {
	f.mu.Lock()
	defer f.mu.Unlock()
	f.metadata[room] = md
	return nil
}

func (f *fakeLiveKit) SendData(_ context.Context, room, topic string, data []byte, to ...string) error {
	f.mu.Lock()
	defer f.mu.Unlock()
	var body map[string]any
	_ = json.Unmarshal(data, &body)
	f.data = append(f.data, sent{room, topic, body, to})
	return nil
}

func (f *fakeLiveKit) StartRoomRecording(_ context.Context, r livekit.RoomRecording) (livekit.Egress, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	f.egress++
	id := fmt.Sprintf("EG_%d_%d", time.Now().UnixNano(), f.egress)
	f.egresses[id] = r
	f.log(fmt.Sprintf("record %s audio=%v %s", r.Room, r.AudioOnly, r.FileType))
	return livekit.Egress{EgressID: id, RoomName: r.Room}, nil
}

func (f *fakeLiveKit) StartTrackRecording(_ context.Context, room, sid, path string) (livekit.Egress, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	f.egress++
	id := fmt.Sprintf("EG_T_%d_%d", time.Now().UnixNano(), f.egress)
	f.egresses[id] = livekit.RoomRecording{Room: room, Path: path}
	return livekit.Egress{EgressID: id, RoomName: room}, nil
}

func (f *fakeLiveKit) StopEgress(_ context.Context, id string) (livekit.Egress, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	f.log("stop " + id)
	return livekit.Egress{EgressID: id, Status: "EGRESS_ENDING"}, nil
}

func (f *fakeLiveKit) ListEgress(_ context.Context, room string, _ bool) ([]livekit.Egress, error) {
	return nil, nil
}

func (f *fakeLiveKit) called(prefix string) bool {
	f.mu.Lock()
	defer f.mu.Unlock()
	for _, c := range f.calls {
		if strings.HasPrefix(c, prefix) {
			return true
		}
	}
	return false
}

type fakeHearer struct{ segs []domain.MeetingSegment }

func (fakeHearer) CanHearMeetings() bool { return true }
func (h fakeHearer) HearMeeting(_ context.Context, _ int64, audio []byte, ext string) ([]domain.MeetingSegment, error) {
	if len(audio) == 0 || ext != "ogg" {
		return nil, errors.New("bad audio")
	}
	return h.segs, nil
}

type fakeNotes struct {
	mu    sync.Mutex
	docs  *postgres.Documents
	made  []documents.MeetingNotes
	again int
}

func (n *fakeNotes) CreateMeetingNotes(ctx context.Context, in documents.MeetingNotes) (int64, error) {
	n.mu.Lock()
	defer n.mu.Unlock()
	n.made = append(n.made, in)
	d, err := n.docs.CreateDocument(ctx, domain.Document{Title: in.Title, OwnerID: in.OwnerID, Language: in.Language, Kind: domain.DocKindPage}, nil)
	return d.ID, err
}

func (n *fakeNotes) RegenerateMeetingNotes(context.Context, int64, int64, int64) error {
	n.again++
	return nil
}

type fakeTickets struct{ made []orchestrator.TaskInput }

func (t *fakeTickets) TicketByKey(context.Context, string) (domain.Ticket, error) {
	return domain.Ticket{}, domain.ErrNotFound
}

func (t *fakeTickets) CreateTask(_ context.Context, in orchestrator.TaskInput, _ domain.Origin) (domain.Ticket, error) {
	t.made = append(t.made, in)
	return domain.Ticket{}, errors.New("no tickets in this test")
}

type pushed struct {
	users []int64
	p     meetings.Push
}

type fakePusher struct {
	mu  sync.Mutex
	all []pushed
}

func (f *fakePusher) MeetingPush(_ context.Context, users []int64, p meetings.Push) {
	f.mu.Lock()
	defer f.mu.Unlock()
	f.all = append(f.all, pushed{users, p})
}

type fakeMail struct {
	mu   sync.Mutex
	sent []mail.Message
}

func (m *fakeMail) Send(_ context.Context, msg mail.Message) error {
	m.mu.Lock()
	defer m.mu.Unlock()
	m.sent = append(m.sent, msg)
	return nil
}
func (*fakeMail) Enabled() bool { return true }

type harness struct {
	t      *testing.T
	pool   *pgxpool.Pool
	ctx    context.Context
	ws     int64
	svc    *meetings.Service
	store  *postgres.Meetings
	lk     *fakeLiveKit
	notes  *fakeNotes
	push   *fakePusher
	mail   *fakeMail
	media  string
	owner  domain.User
	host   domain.User // a member
	member domain.User
	viewer domain.User
	other  domain.User // an account of another workspace
}

func (h harness) caller(u domain.User) meetings.Caller {
	role, err := postgres.NewWorkspaces(h.pool).Role(h.ctx, h.ws, u.ID)
	if err != nil {
		h.t.Fatal(err)
	}
	return meetings.Caller{WorkspaceID: h.ws, UserID: u.ID, Role: role}
}

func newHarness(t *testing.T) harness {
	t.Helper()
	p := pgtest.Open(t)
	ctx, ws := pgtest.Workspace(t, p, fmt.Sprintf("meet-%d", time.Now().UnixNano()))
	sys := domain.System(context.Background())
	users := postgres.NewUsers(p)
	wss := postgres.NewWorkspaces(p)
	w, err := wss.ByID(sys, ws)
	if err != nil {
		t.Fatal(err)
	}
	add := func(name string, role domain.WorkspaceRole) domain.User {
		u, err := users.Create(sys, domain.User{Username: fmt.Sprintf("%s-%d", name, time.Now().UnixNano()), DisplayName: name, PasswordHash: "h",
			Email: fmt.Sprintf("%s-%d@example.com", strings.ToLower(name), time.Now().UnixNano())})
		if err != nil {
			t.Fatal(err)
		}
		if role != "" {
			if err := wss.AddMember(sys, ws, u.ID, role); err != nil {
				t.Fatal(err)
			}
		}
		return u
	}
	owner, err := users.ByID(sys, w.OwnerID)
	if err != nil {
		t.Fatal(err)
	}
	h := harness{t: t, pool: p, ctx: ctx, ws: ws, store: postgres.NewMeetings(p), lk: newFakeLiveKit(), notes: &fakeNotes{docs: postgres.NewDocuments(p)}, push: &fakePusher{},
		mail: &fakeMail{}, media: t.TempDir(), owner: owner}
	h.host, h.member, h.viewer, h.other = add("Host", domain.RoleUser), add("Member", domain.RoleUser), add("Viewer", domain.RoleViewer), add("Outsider", "")
	h.svc = meetings.New(meetings.Config{LiveKitURL: "wss://lk.example", Keys: livekit.Keys{Key: "k", Secret: "secret-of-at-least-32-characters-long"},
		PublicURL: "https://app.example", MediaDir: h.media, Egress: true, MaxRecordings: 2},
		meetings.Deps{Store: h.store, LiveKit: h.lk, Workspaces: wss, Users: users, Settings: postgres.NewSettings(p, domain.DefaultSettings()),
			Pusher: h.push, Mailer: h.mail, Notes: h.notes, Hearer: fakeHearer{segs: []domain.MeetingSegment{
				{StartMS: 1000, EndMS: 4000, Text: "We ship refunds on Friday."}, {StartMS: 5000, EndMS: 8000, Text: "Aziza writes the migration."}}},
			Tickets: &fakeTickets{}, Log: slog.New(slog.NewTextHandler(io.Discard, nil))})
	return h
}

func (h harness) create(in domain.MeetingInput, inv meetings.Invites) domain.Meeting {
	h.t.Helper()
	d, err := h.svc.Create(h.ctx, h.caller(h.host), in, inv)
	if err != nil {
		h.t.Fatal(err)
	}
	return d.Meeting
}

// joined is a participant_joined webhook for a grant.
func (h harness) joined(g *meetings.Grant, name string) {
	h.t.Helper()
	m := h.sessionRoom(g.SessionID)
	err := h.svc.Webhook(h.ctx, livekit.Event{ID: fmt.Sprintf("EV_%d", time.Now().UnixNano()), Event: livekit.EventParticipantJoined,
		Room: &livekit.Room{Name: m}, Participant: &livekit.Participant{Identity: g.Identity, Name: name, JoinedAt: livekit.Int64(time.Now().Unix())}})
	if err != nil {
		h.t.Fatal(err)
	}
	h.lk.mu.Lock()
	h.lk.participants[m] = append(h.lk.participants[m], livekit.Participant{Identity: g.Identity,
		Tracks: []livekit.Track{{SID: "TR_mic_" + g.Identity, Source: "MICROPHONE", Type: "AUDIO"}}})
	h.lk.mu.Unlock()
}

func (h harness) sessionRoom(id int64) string {
	x, err := h.store.Session(h.ctx, id)
	if err != nil {
		h.t.Fatal(err)
	}
	return x.Room
}

func claimsOf(t *testing.T, tok string) map[string]any {
	t.Helper()
	parts := strings.Split(tok, ".")
	b, err := base64.RawURLEncoding.DecodeString(parts[1])
	if err != nil {
		t.Fatal(err)
	}
	var c map[string]any
	_ = json.Unmarshal(b, &c)
	return c
}

func TestJoinAndKnock(t *testing.T) {
	h := newHarness(t)
	m := h.create(domain.MeetingInput{}, meetings.Invites{})
	if _, err := h.svc.Create(h.ctx, h.caller(h.viewer), domain.MeetingInput{}, meetings.Invites{}); !errors.Is(err, domain.ErrForbidden) {
		t.Errorf("a viewer created a meeting: %v", err)
	}

	// The host joins: the session starts and its room is made.
	r, err := h.svc.Join(h.ctx, domain.FormatMeetingCode(m.Code), meetings.Joiner{User: &h.host, Device: "laptop01"})
	if err != nil || r.Grant == nil {
		t.Fatalf("host join %+v %v", r, err)
	}
	g := r.Grant
	if g.Role != domain.RoleHost || !g.Rights.Admit || g.URL != "wss://lk.example" || g.Identity != fmt.Sprintf("u%d-laptop01", h.host.ID) {
		t.Errorf("host grant %+v", g)
	}
	room := h.sessionRoom(g.SessionID)
	if !h.lk.called("create " + room) {
		t.Fatalf("no room created: %v", h.lk.calls)
	}
	c := claimsOf(t, g.Token)
	video := c["video"].(map[string]any)
	if video["room"] != room || c["sub"] != g.Identity || c["attributes"].(map[string]any)[meetings.AttrRole] != "host" ||
		len(video["canPublishSources"].([]any)) != 4 || video["roomAdmin"] != nil {
		t.Errorf("token claims %v", c)
	}
	h.joined(g, "Host")

	// A member joins the same session without knocking.
	r2, err := h.svc.Join(h.ctx, m.Code, meetings.Joiner{User: &h.member, Device: "phone001"})
	if err != nil || r2.Grant == nil || r2.Grant.SessionID != g.SessionID || r2.Grant.Role != domain.RoleMember {
		t.Fatalf("member join %+v %v", r2, err)
	}
	h.joined(r2.Grant, "Member")

	// A guest knocks; the host hears about it in the room.
	r3, err := h.svc.Join(h.ctx, m.Code, meetings.Joiner{Name: "  Client  Co ", Device: "guest001"})
	if err != nil || r3.Grant != nil || r3.KnockID == 0 || r3.GuestToken == "" || r3.GuestName != "Client Co" {
		t.Fatalf("guest knock %+v %v", r3, err)
	}
	found := false
	for _, d := range h.lk.data {
		if d.topic == meetings.TopicKnock && len(d.to) == 1 && d.to[0] == g.Identity {
			found = true
		}
	}
	if !found {
		t.Errorf("the host was not told: %+v", h.lk.data)
	}
	// Still waiting.
	w, err := h.svc.WaitKnock(h.ctx, m.Code, r3.KnockID, r3.KnockToken, 0)
	if err != nil || w.Grant != nil {
		t.Fatalf("waiting %+v %v", w, err)
	}
	// The member can't admit while the host is in the call.
	member, err := h.svc.Seat(h.ctx, m.Code, r2.Grant.Seat)
	if err != nil {
		t.Fatal(err)
	}
	if err := h.svc.Admit(member, r3.KnockID); !errors.Is(err, domain.ErrForbidden) {
		t.Errorf("a member admitted with the host there: %v", err)
	}
	host, err := h.svc.Seat(h.ctx, m.Code, g.Seat)
	if err != nil {
		t.Fatal(err)
	}
	st, err := h.svc.State(host)
	if err != nil || !st.CanAdmit || len(st.Knocks) != 1 || len(st.People) != 2 || st.People[0].Role != domain.RoleHost {
		t.Fatalf("host state %+v %v", st, err)
	}
	if err := h.svc.Admit(host, r3.KnockID); err != nil {
		t.Fatal(err)
	}
	w, err = h.svc.WaitKnock(h.ctx, m.Code, r3.KnockID, r3.KnockToken, time.Second)
	if err != nil || w.Grant == nil || w.Grant.Role != domain.RoleGuest || w.Grant.Seat == "" {
		t.Fatalf("admitted %+v %v", w, err)
	}
	h.joined(w.Grant, "Client Co")

	// The guest comes back (a reload) with their token: no knock.
	r4, err := h.svc.Join(h.ctx, m.Code, meetings.Joiner{GuestToken: r3.GuestToken, Device: "guest002"})
	if err != nil || r4.Grant == nil || r4.GuestToken != "" {
		t.Fatalf("returning guest %+v %v", r4, err)
	}

	// Removed: disconnected on every device, and can't come back.
	if err := h.svc.Remove(member, "g1"); !errors.Is(err, domain.ErrForbidden) {
		t.Errorf("a member removed someone: %v", err)
	}
	guestKey := domain.Person{GuestID: mustGuestID(t, w.Grant.Identity)}.Key()
	if err := h.svc.Remove(host, guestKey); err != nil {
		t.Fatal(err)
	}
	if !h.lk.called("remove " + w.Grant.Identity) {
		t.Errorf("not disconnected: %v", h.lk.calls)
	}
	var refused *meetings.RefusedError
	if _, err := h.svc.Join(h.ctx, m.Code, meetings.Joiner{GuestToken: r3.GuestToken, Device: "guest003"}); !errors.As(err, &refused) || refused.Reason != domain.RefuseRemoved {
		t.Errorf("removed guest rejoined: %v", err)
	}
	if _, err := h.svc.Seat(h.ctx, m.Code, w.Grant.Seat); !errors.Is(err, meetings.ErrSeat) {
		t.Errorf("a removed seat still works: %v", err)
	}

	// Lock: a new guest is refused, the member's second device joins.
	if err := h.svc.Lock(host, true); err != nil {
		t.Fatal(err)
	}
	if !strings.Contains(h.lk.metadata[room], `"locked":true`) {
		t.Errorf("room metadata %s", h.lk.metadata[room])
	}
	if _, err := h.svc.Join(h.ctx, m.Code, meetings.Joiner{Name: "Late", Device: "late0001"}); !errors.As(err, &refused) || refused.Reason != domain.RefuseLocked {
		t.Errorf("joined a locked meeting: %v", err)
	}
	if r, err := h.svc.Join(h.ctx, m.Code, meetings.Joiner{User: &h.member, Device: "tablet01"}); err != nil || r.Grant == nil {
		t.Errorf("an admitted member's second device: %v", err)
	}

	// Co-host: their connected devices get the new role.
	if err := h.svc.SetCohost(member, fmt.Sprintf("u%d", h.member.ID), true); !errors.Is(err, domain.ErrForbidden) {
		t.Errorf("a member chose a co-host: %v", err)
	}
	if err := h.svc.SetCohost(host, fmt.Sprintf("u%d", h.member.ID), true); err != nil {
		t.Fatal(err)
	}
	if !h.lk.called(fmt.Sprintf("update u%d-phone001 [camera,microphone,screen_share,screen_share_audio] map[agnts.role:cohost]", h.member.ID)) {
		t.Errorf("co-host not updated: %v", h.lk.calls)
	}
	member, _ = h.svc.Seat(h.ctx, m.Code, r2.Grant.Seat)
	if member.Role != domain.RoleCohost || !member.Rights.Moderate {
		t.Errorf("co-host seat %+v", member)
	}

	// Mute: the member's microphone.
	if err := h.svc.Mute(host, fmt.Sprintf("u%d", h.member.ID), livekit.SourceMicrophone); err != nil {
		t.Fatal(err)
	}
	if !h.lk.called(fmt.Sprintf("mute u%d-phone001 TR_mic_u%d-phone001", h.member.ID, h.member.ID)) {
		t.Errorf("not muted: %v", h.lk.calls)
	}

	// Chat: stored, sent into the room, secrets refused.
	msg, err := h.svc.Send(host, "the spec is in AMANAT-12")
	if err != nil || msg.ID == 0 {
		t.Fatalf("send %+v %v", msg, err)
	}
	if _, err := h.svc.Send(host, "token ghp_abcdefghijklmnopqrstuvwxyz0123456789"); !errors.Is(err, domain.ErrMeetingInvalid) {
		t.Errorf("a secret was sent: %v", err)
	}
	msgs, _ := h.svc.Messages(host, 0)
	if len(msgs) != 1 {
		t.Errorf("messages %+v", msgs)
	}

	// End for everyone: only the host.
	if err := h.svc.End(member); !errors.Is(err, domain.ErrForbidden) {
		t.Errorf("a co-host ended the call: %v", err)
	}
	if err := h.svc.End(host); err != nil {
		t.Fatal(err)
	}
	if !h.lk.called("delete " + room) {
		t.Errorf("room not deleted: %v", h.lk.calls)
	}
	x, _ := h.store.Session(h.ctx, g.SessionID)
	if x.EndedAt == nil {
		t.Errorf("session not ended: %+v", x)
	}
	// The meeting unlocks for its next session only by hand; a new join
	// starts a new session.
	if err := h.store.SetMeetingLocked(h.ctx, m.ID, false); err != nil {
		t.Fatal(err)
	}
	r5, err := h.svc.Join(h.ctx, m.Code, meetings.Joiner{User: &h.member, Device: "phone001"})
	if err != nil || r5.Grant == nil || r5.Grant.SessionID == g.SessionID {
		t.Errorf("next session %+v %v", r5, err)
	}
}

func mustGuestID(t *testing.T, identity string) int64 {
	t.Helper()
	p, _, ok := domain.ParseMeetingIdentity(identity)
	if !ok || !p.IsGuest() {
		t.Fatalf("not a guest identity %q", identity)
	}
	return p.GuestID
}

func TestAccessAndInvites(t *testing.T) {
	h := newHarness(t)
	start := time.Now().Add(10 * time.Minute)
	m := h.create(domain.MeetingInput{Title: "Planning", Kind: domain.MeetingScheduled, StartsAt: &start, TimeZone: "Asia/Tashkent"},
		meetings.Invites{Users: []int64{h.member.ID}, Emails: []string{"Client@Example.com", h.viewer.Email}})
	if m.Access != domain.AccessInvited {
		t.Fatalf("access %s", m.Access)
	}
	d, err := h.svc.Get(h.ctx, h.caller(h.host), m.ID)
	if err != nil || len(d.Invitees) != 3 || !d.CanManage {
		t.Fatalf("detail %+v %v", d, err)
	}
	// The email invitee and the members got the invitation with its event.
	time.Sleep(200 * time.Millisecond)
	h.mail.mu.Lock()
	var clientMail *mail.Message
	for i, msg := range h.mail.sent {
		if msg.To == "client@example.com" {
			clientMail = &h.mail.sent[i]
		}
	}
	h.mail.mu.Unlock()
	if clientMail == nil || len(clientMail.Attachments) != 1 || !strings.Contains(string(clientMail.Attachments[0].Data), "METHOD:REQUEST") {
		t.Fatalf("invitation mail %+v", clientMail)
	}
	link := clientMail.Body[strings.Index(clientMail.Body, "https://app.example/m/"):]
	link = strings.Fields(link)[0]
	tok := link[strings.Index(link, "?i=")+3:]

	// A member who is not invited knocks; the invited one joins.
	other, err := postgres.NewUsers(h.pool).Create(domain.System(context.Background()), domain.User{Username: fmt.Sprintf("second-%d", time.Now().UnixNano()), PasswordHash: "h"})
	if err != nil {
		t.Fatal(err)
	}
	if err := postgres.NewWorkspaces(h.pool).AddMember(domain.System(context.Background()), h.ws, other.ID, domain.RoleUser); err != nil {
		t.Fatal(err)
	}
	host, err := h.svc.Join(h.ctx, m.Code, meetings.Joiner{User: &h.host, Device: "host0001"})
	if err != nil || host.Grant == nil {
		t.Fatal(err)
	}
	h.joined(host.Grant, "Host")
	if r, err := h.svc.Join(h.ctx, m.Code, meetings.Joiner{User: &other, Device: "other001"}); err != nil || r.KnockID == 0 {
		t.Errorf("an uninvited member should knock: %+v %v", r, err)
	}
	if r, err := h.svc.Join(h.ctx, m.Code, meetings.Joiner{User: &h.member, Device: "mem00001"}); err != nil || r.Grant == nil {
		t.Errorf("an invited member: %+v %v", r, err)
	}
	// The email invitee joins with their link, without knocking.
	r, err := h.svc.Join(h.ctx, m.Code, meetings.Joiner{InviteToken: tok, Name: "Client", Device: "client01"})
	if err != nil || r.Grant == nil || r.Grant.Role != domain.RoleGuest {
		t.Fatalf("email invitee %+v %v", r, err)
	}
	if _, err := h.svc.Join(h.ctx, m.Code, meetings.Joiner{InviteToken: "nope", Name: "Fake"}); !errors.Is(err, domain.ErrMeetingInvalid) {
		t.Errorf("a made-up invitation link: %v", err)
	}
	// An account of another workspace is a guest and knocks.
	if r, err := h.svc.Join(h.ctx, m.Code, meetings.Joiner{User: &h.other, Device: "out00001"}); err != nil || r.KnockID == 0 || r.GuestName != "Outsider" {
		t.Errorf("another workspace's account %+v %v", r, err)
	}
	// RSVP.
	if err := h.svc.RSVP(h.ctx, h.caller(h.member), m.ID, "yes"); err != nil {
		t.Fatal(err)
	}
	// Someone who can't see the meeting can't answer it.
	if err := h.svc.RSVP(h.ctx, h.caller(other), m.ID, "yes"); !errors.Is(err, domain.ErrNotFound) {
		t.Errorf("RSVP without an invitation: %v", err)
	}
	// The owner sees it, but isn't invited.
	if err := h.svc.RSVP(h.ctx, h.caller(h.owner), m.ID, "yes"); !errors.Is(err, domain.ErrMeetingInvalid) {
		t.Errorf("RSVP of the owner: %v", err)
	}

	// Moving the meeting sends updates with a new sequence.
	later := start.Add(time.Hour)
	if _, err := h.svc.Update(h.ctx, h.caller(h.host), m.ID, domain.MeetingInput{Title: "Planning", Kind: domain.MeetingScheduled, StartsAt: &later,
		TimeZone: "Asia/Tashkent", Access: domain.AccessInvited}); err != nil {
		t.Fatal(err)
	}
	if _, err := h.svc.Update(h.ctx, h.caller(h.member), m.ID, domain.MeetingInput{Title: "x"}); !errors.Is(err, domain.ErrForbidden) {
		t.Errorf("a member changed the meeting: %v", err)
	}
	time.Sleep(200 * time.Millisecond)
	h.mail.mu.Lock()
	updated := false
	for _, msg := range h.mail.sent {
		if strings.HasPrefix(msg.Subject, "Updated:") && strings.Contains(string(msg.Attachments[0].Data), "SEQUENCE:1") {
			updated = true
		}
	}
	h.mail.mu.Unlock()
	if !updated {
		t.Errorf("no update sent: %d mails", len(h.mail.sent))
	}
}

func TestNotes(t *testing.T) {
	h := newHarness(t)
	m := h.create(domain.MeetingInput{Title: "Refunds"}, meetings.Invites{})
	r, err := h.svc.Join(h.ctx, m.Code, meetings.Joiner{User: &h.host, Device: "host0001"})
	if err != nil {
		t.Fatal(err)
	}
	h.joined(r.Grant, "Host")
	r2, _ := h.svc.Join(h.ctx, m.Code, meetings.Joiner{User: &h.member, Device: "mem00001"})
	h.joined(r2.Grant, "Member")
	host, _ := h.svc.Seat(h.ctx, m.Code, r.Grant.Seat)
	member, _ := h.svc.Seat(h.ctx, m.Code, r2.Grant.Seat)
	if err := h.svc.StartNotes(member); !errors.Is(err, domain.ErrForbidden) {
		t.Errorf("a member turned notes on: %v", err)
	}
	if err := h.svc.StartNotes(host); err != nil {
		t.Fatal(err)
	}
	room := h.sessionRoom(r.Grant.SessionID)
	if !h.lk.called("record "+room+" audio=true OGG") || !strings.Contains(h.lk.metadata[room], `"notes":true`) {
		t.Fatalf("notes not recorded: %v %s", h.lk.calls, h.lk.metadata[room])
	}
	// Egress wrote the file and said so.
	var egressID string
	for id, rec := range h.lk.egresses {
		if rec.AudioOnly {
			egressID = id
			if err := os.WriteFile(filepath.Join(h.media, filepath.Base(rec.Path)), []byte("OggS fake audio"), 0o644); err != nil {
				t.Fatal(err)
			}
		}
	}
	if err := h.svc.Webhook(h.ctx, livekit.Event{ID: "EV_e_" + egressID, Event: livekit.EventEgressEnded, Egress: &livekit.Egress{EgressID: egressID,
		RoomName: room, Status: "EGRESS_COMPLETE", FileResults: []livekit.FileResult{{Size: 15}}}}); err != nil {
		t.Fatal(err)
	}
	// The room finishes; notes are queued, heard, and the document asked for.
	if err := h.svc.Webhook(h.ctx, livekit.Event{ID: fmt.Sprintf("EV_f_%d", time.Now().UnixNano()), Event: livekit.EventRoomFinished,
		Room: &livekit.Room{Name: room}}); err != nil {
		t.Fatal(err)
	}
	x, _ := h.store.Session(h.ctx, r.Grant.SessionID)
	if x.NotesStatus != domain.NotesQueued || x.EndedAt == nil {
		t.Fatalf("after the call %+v", x)
	}
	ctx, cancel := context.WithTimeout(domain.System(context.Background()), 5*time.Second)
	defer cancel()
	go h.svc.RunNotes(ctx)
	deadline := time.Now().Add(5 * time.Second)
	for time.Now().Before(deadline) {
		h.notes.mu.Lock()
		n := len(h.notes.made)
		h.notes.mu.Unlock()
		if n > 0 {
			break
		}
		time.Sleep(50 * time.Millisecond)
	}
	cancel()
	h.notes.mu.Lock()
	defer h.notes.mu.Unlock()
	if len(h.notes.made) != 1 {
		t.Fatalf("notes documents %+v", h.notes.made)
	}
	n := h.notes.made[0]
	if n.OwnerID != h.host.ID || n.SessionID != x.ID || n.Language != "en" || !strings.HasPrefix(n.Title, "Notes: Refunds") || len(n.Viewers) != 2 {
		t.Errorf("notes %+v", n)
	}
	segs, _ := h.store.Segments(h.ctx, x.ID)
	if len(segs) != 2 {
		t.Errorf("segments %+v", segs)
	}
	// The audio is gone once heard (the workspace keeps none).
	files, _ := os.ReadDir(h.media)
	if len(files) != 0 {
		t.Errorf("audio kept: %v", files)
	}
	x, _ = h.store.Session(h.ctx, x.ID)
	if x.NotesStatus != domain.NotesWriting {
		t.Errorf("status %s", x.NotesStatus)
	}
}

func TestSweepClosesUnconnected(t *testing.T) {
	h := newHarness(t)
	m := h.create(domain.MeetingInput{}, meetings.Invites{})
	r, err := h.svc.Join(h.ctx, m.Code, meetings.Joiner{User: &h.host, Device: "host0001"})
	if err != nil {
		t.Fatal(err)
	}
	// Nobody connects for three minutes.
	pgtest.Exec(t, h.pool, `UPDATE meeting_sessions SET started_at = now() - interval '3 minutes' WHERE id = $1`, r.Grant.SessionID)
	h.svc.Sweep(domain.System(context.Background()))
	x, _ := h.store.Session(h.ctx, r.Grant.SessionID)
	if x.EndedAt == nil {
		t.Fatalf("the unconnected session is still live: %+v", x)
	}
	// The next join starts a new one.
	r2, err := h.svc.Join(h.ctx, m.Code, meetings.Joiner{User: &h.host, Device: "host0001"})
	if err != nil || r2.Grant.SessionID == r.Grant.SessionID {
		t.Fatalf("next %+v %v", r2, err)
	}
}

func TestICS(t *testing.T) {
	start := time.Date(2026, 11, 2, 9, 0, 0, 0, time.UTC)
	out := string(meetings.ICS(meetings.ICSEvent{UID: "abcdefghij@agnts", Sequence: 2, Method: "REQUEST", Start: start, End: start.Add(30 * time.Minute),
		Summary: "Planning; Q4, refunds", Description: "Agenda:\nrefunds\n\nJoin: https://app.example/m/abc-defg-hij?i=" + strings.Repeat("x", 60),
		Location: "https://app.example/m/abc-defg-hij", Organizer: "Rustam, PM", OrganizerAt: "r@example.com", Attendee: "c@example.com", Stamp: start}))
	for _, want := range []string{"METHOD:REQUEST\r\n", "UID:abcdefghij@agnts\r\n", "SEQUENCE:2\r\n", "DTSTART:20261102T090000Z\r\n",
		"DTEND:20261102T093000Z\r\n", `SUMMARY:Planning\; Q4\, refunds`, `ORGANIZER;CN="Rustam, PM":mailto:r@example.com`, "BEGIN:VALARM"} {
		if !strings.Contains(out, want) {
			t.Errorf("lacks %q:\n%s", want, out)
		}
	}
	for _, l := range strings.Split(out, "\r\n") {
		if len(l) > 75 {
			t.Errorf("unfolded line of %d octets: %q", len(l), l)
		}
	}
	if !strings.Contains(out, "DESCRIPTION:Agenda:\\nrefunds") {
		t.Errorf("newlines not escaped:\n%s", out)
	}
	cancel := string(meetings.ICS(meetings.ICSEvent{UID: "u", Method: "CANCEL", Start: start, End: start, Summary: "x", Stamp: start}))
	if !strings.Contains(cancel, "STATUS:CANCELLED") || strings.Contains(cancel, "VALARM") {
		t.Errorf("cancel:\n%s", cancel)
	}
}

func TestTranscriptFormats(t *testing.T) {
	segs := []domain.MeetingSegment{{StartMS: 61_500, EndMS: 65_000, Text: "Ship it --> now", Name: "Aziza"}, {StartMS: 3_700_000, EndMS: 3_700_000, Text: "Bye"}}
	vtt := meetings.TranscriptVTT(segs)
	for _, want := range []string{"WEBVTT\n\n", "00:01:01.500 --> 00:01:05.000\n<v Aziza>Ship it -> now", "01:01:40.000 --> 01:01:41.000\nBye"} {
		if !strings.Contains(vtt, want) {
			t.Errorf("vtt lacks %q:\n%s", want, vtt)
		}
	}
	txt := meetings.TranscriptText(domain.Meeting{Title: "Sync"}, domain.MeetingSession{StartedAt: time.Unix(0, 0)}, segs)
	if !strings.Contains(txt, "[1:01] Aziza: Ship it --> now") || !strings.Contains(txt, "[1:01:40] Bye") {
		t.Errorf("txt:\n%s", txt)
	}
}
