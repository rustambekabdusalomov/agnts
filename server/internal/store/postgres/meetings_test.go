package postgres

import (
	"context"
	"errors"
	"fmt"
	"sync"
	"testing"
	"time"

	"agnts/internal/domain"
)

type meetFixture struct {
	ctx          context.Context
	ws           int64
	s            *Meetings
	owner        int64
	alice, bob   int64
	otherCtx     context.Context // another workspace
	otherMeeting domain.Meeting
}

func newMeetFixture(t *testing.T) meetFixture {
	t.Helper()
	users, _ := testDB(t)
	ctx, ws := testWS(t, users)
	sys := domain.System(context.Background())
	w, err := NewWorkspaces(users.db).ByID(sys, ws)
	if err != nil {
		t.Fatal(err)
	}
	f := meetFixture{ctx: ctx, ws: ws, s: NewMeetings(users.db), owner: w.OwnerID}
	add := func(name string) int64 {
		u, err := users.Create(sys, domain.User{Username: fmt.Sprintf("%s-%d-%s", name, ws, t.Name()), PasswordHash: "h"})
		if err != nil {
			t.Fatal(err)
		}
		if err := NewWorkspaces(users.db).AddMember(sys, ws, u.ID, domain.RoleUser); err != nil {
			t.Fatal(err)
		}
		return u.ID
	}
	f.alice, f.bob = add("alice"), add("bob")
	var other int64
	f.otherCtx, other = testWS(t, users)
	_ = other
	f.otherMeeting = f.create(t, f.otherCtx, nil, domain.AccessWorkspace)
	return f
}

var codeSeq int

func nextCode() string {
	codeSeq++
	b := []byte("aaaaaaaaaa")
	n := codeSeq + int(time.Now().UnixNano()%1_000_000)*1000
	for i := len(b) - 1; i >= 0 && n > 0; i-- {
		b[i] = byte('a' + n%26)
		n /= 26
	}
	return string(b)
}

func (f meetFixture) create(t *testing.T, ctx context.Context, host *int64, access domain.MeetingAccess) domain.Meeting {
	t.Helper()
	m, err := f.s.CreateMeeting(ctx, domain.Meeting{Code: nextCode(), Title: "Standup", HostID: host, Kind: domain.MeetingInstant,
		DurationMin: 30, TimeZone: "UTC", Access: access, Guests: domain.GuestsKnock, Language: "auto"})
	if err != nil {
		t.Fatal(err)
	}
	return m
}

func TestMeetingsCreateAndFind(t *testing.T) {
	f := newMeetFixture(t)
	m := f.create(t, f.ctx, &f.alice, domain.AccessWorkspace)
	if m.WorkspaceID != f.ws || m.HostName == "" || m.Live != nil || !m.IsHost(f.alice) {
		t.Fatalf("created %+v", m)
	}
	// The same code again: taken, in any workspace.
	_, err := f.s.CreateMeeting(f.otherCtx, domain.Meeting{Code: m.Code, Kind: domain.MeetingInstant, DurationMin: 30, TimeZone: "UTC",
		Access: domain.AccessWorkspace, Guests: domain.GuestsKnock, Language: "auto"})
	if !errors.Is(err, ErrCodeTaken) {
		t.Fatalf("duplicate code: %v", err)
	}
	// Workspaces don't see each other's meetings, but the code finds it
	// from the system scope.
	if _, err := f.s.Meeting(f.otherCtx, m.ID); !errors.Is(err, domain.ErrNotFound) {
		t.Errorf("another workspace read the meeting: %v", err)
	}
	if _, err := f.s.MeetingByCode(f.otherCtx, m.Code); !errors.Is(err, domain.ErrNotFound) {
		t.Errorf("another workspace found the code: %v", err)
	}
	got, err := f.s.MeetingByCode(domain.System(context.Background()), m.Code)
	if err != nil || got.ID != m.ID || got.WorkspaceID != f.ws {
		t.Fatalf("by code %+v %v", got, err)
	}

	if err := f.s.SetCohost(f.ctx, m.ID, f.bob, true); err != nil {
		t.Fatal(err)
	}
	m, _ = f.s.Meeting(f.ctx, m.ID)
	if !m.IsCohost(f.bob) {
		t.Errorf("cohosts %v", m.CohostIDs)
	}
	if err := f.s.SetMeetingHost(f.ctx, m.ID, f.bob); err != nil {
		t.Fatal(err)
	}
	m, _ = f.s.Meeting(f.ctx, m.ID)
	if !m.IsHost(f.bob) || m.IsCohost(f.bob) {
		t.Errorf("handed over: host %v cohosts %v", m.HostID, m.CohostIDs)
	}
}

func TestMeetingsVisibility(t *testing.T) {
	f := newMeetFixture(t)
	open := f.create(t, f.ctx, &f.alice, domain.AccessWorkspace)
	private := f.create(t, f.ctx, &f.alice, domain.AccessInvited)
	start := time.Now().Add(time.Hour)
	in := domain.MeetingInput{Title: "Planning", Kind: domain.MeetingScheduled, StartsAt: &start, DurationMin: 30, TimeZone: "UTC",
		Access: domain.AccessInvited, Guests: domain.GuestsKnock, Language: "auto"}
	if _, err := f.s.UpdateMeeting(f.ctx, private.ID, in, true); err != nil {
		t.Fatal(err)
	}
	see := func(user int64, owner bool) map[int64]bool {
		ms, err := f.s.ListMeetings(f.ctx, MeetingFilter{View: ViewUpcoming, UserID: user, Owner: owner})
		if err != nil {
			t.Fatal(err)
		}
		out := map[int64]bool{}
		for _, m := range ms {
			out[m.ID] = true
		}
		return out
	}
	if got := see(f.bob, false); got[private.ID] {
		t.Errorf("bob sees the invited-only meeting: %v", got)
	}
	if got := see(f.owner, true); !got[private.ID] {
		t.Errorf("the owner sees every meeting: %v", got)
	}
	added, err := f.s.AddInvitees(f.ctx, private.ID, []NewInvitee{{UserID: &f.bob}, {Email: "client@example.com", TokenHash: []byte("h1")}, {UserID: &f.bob}})
	if err != nil || len(added) != 2 {
		t.Fatalf("invitees %+v %v", added, err)
	}
	if got := see(f.bob, false); !got[private.ID] {
		t.Errorf("an invitee sees it: %v", got)
	}
	if ok, _ := f.s.IsInvited(f.ctx, private.ID, f.bob); !ok {
		t.Error("bob is invited")
	}
	inv, err := f.s.InviteeByToken(f.ctx, private.ID, []byte("h1"))
	if err != nil || inv.Email != "client@example.com" {
		t.Errorf("invitee by token %+v %v", inv, err)
	}
	// An instant meeting is upcoming only while live.
	if got := see(f.bob, false); got[open.ID] {
		t.Errorf("an instant meeting that is not live is upcoming: %v", got)
	}
	if _, _, err := f.s.OpenSession(f.ctx, open.ID); err != nil {
		t.Fatal(err)
	}
	if got := see(f.bob, false); !got[open.ID] {
		t.Errorf("a live meeting is upcoming: %v", got)
	}
	if ok, _ := f.s.CanSeeMeeting(f.ctx, private.ID, f.bob, false); !ok {
		t.Error("CanSeeMeeting for an invitee")
	}
	if err := f.s.SetRSVP(f.ctx, private.ID, f.bob, domain.RSVPYes); err != nil {
		t.Fatal(err)
	}
	invs, _ := f.s.Invitees(f.ctx, private.ID)
	if len(invs) != 2 || invs[0].UserID == nil || invs[0].RSVP != domain.RSVPYes || invs[1].Email != "client@example.com" {
		t.Errorf("invitees %+v", invs)
	}
}

func TestMeetingsAgenda(t *testing.T) {
	f := newMeetFixture(t)
	schedule := func(m domain.Meeting, in time.Duration, access domain.MeetingAccess) {
		t.Helper()
		start := time.Now().Add(in)
		if _, err := f.s.UpdateMeeting(f.ctx, m.ID, domain.MeetingInput{Title: m.Title, Kind: domain.MeetingScheduled, StartsAt: &start,
			DurationMin: 30, TimeZone: "UTC", Access: access, Guests: domain.GuestsKnock, Language: "auto"}, true); err != nil {
			t.Fatal(err)
		}
	}
	invited := f.create(t, f.ctx, &f.alice, domain.AccessInvited)
	schedule(invited, time.Hour, domain.AccessInvited)
	declined := f.create(t, f.ctx, &f.alice, domain.AccessInvited)
	schedule(declined, 2*time.Hour, domain.AccessInvited)
	open := f.create(t, f.ctx, &f.alice, domain.AccessWorkspace) // bob may join, but isn't invited
	schedule(open, time.Hour, domain.AccessWorkspace)
	cancelled := f.create(t, f.ctx, &f.alice, domain.AccessInvited)
	schedule(cancelled, time.Hour, domain.AccessInvited)
	later := f.create(t, f.ctx, &f.alice, domain.AccessInvited)
	schedule(later, 3*24*time.Hour, domain.AccessInvited)
	over := f.create(t, f.ctx, &f.alice, domain.AccessInvited)
	schedule(over, -2*time.Hour, domain.AccessInvited)
	cohosted := f.create(t, f.ctx, &f.alice, domain.AccessWorkspace) // instant: on the agenda only while live
	for _, m := range []domain.Meeting{invited, declined, cancelled, later, over} {
		if _, err := f.s.AddInvitees(f.ctx, m.ID, []NewInvitee{{UserID: &f.bob}}); err != nil {
			t.Fatal(err)
		}
	}
	if err := f.s.SetRSVP(f.ctx, declined.ID, f.bob, domain.RSVPNo); err != nil {
		t.Fatal(err)
	}
	if err := f.s.CancelMeeting(f.ctx, cancelled.ID); err != nil {
		t.Fatal(err)
	}
	if err := f.s.SetCohost(f.ctx, cohosted.ID, f.bob, true); err != nil {
		t.Fatal(err)
	}
	agenda := func(user int64, owner bool) []int64 {
		t.Helper()
		ms, err := f.s.ListMeetings(f.ctx, MeetingFilter{View: ViewAgenda, UserID: user, Owner: owner})
		if err != nil {
			t.Fatal(err)
		}
		out := []int64{}
		for _, m := range ms {
			out = append(out, m.ID)
		}
		return out
	}
	if got := agenda(f.bob, false); fmt.Sprint(got) != fmt.Sprint([]int64{invited.ID}) {
		t.Errorf("bob's agenda %v, want only %d", got, invited.ID)
	}
	if _, _, err := f.s.OpenSession(f.ctx, cohosted.ID); err != nil {
		t.Fatal(err)
	}
	if got := agenda(f.bob, false); fmt.Sprint(got) != fmt.Sprint([]int64{cohosted.ID, invited.ID}) {
		t.Errorf("bob's agenda with a live meeting %v, want it first", got)
	}
	// The owner sees every meeting, but their agenda has only their own.
	if got := agenda(f.owner, true); len(got) != 0 {
		t.Errorf("the owner's agenda %v", got)
	}
	if got := agenda(f.alice, false); len(got) != 4 {
		t.Errorf("the host's agenda %v, want invited, declined, open and the live one", got)
	}
}

func TestMeetingSessions(t *testing.T) {
	f := newMeetFixture(t)
	m := f.create(t, f.ctx, &f.alice, domain.AccessWorkspace)

	// Concurrent joins open one session.
	var wg sync.WaitGroup
	ids := make([]int64, 8)
	created := make([]bool, 8)
	for i := range ids {
		wg.Add(1)
		go func(i int) {
			defer wg.Done()
			x, c, err := f.s.OpenSession(f.ctx, m.ID)
			if err != nil {
				t.Error(err)
				return
			}
			ids[i], created[i] = x.ID, c
		}(i)
	}
	wg.Wait()
	n := 0
	for i, id := range ids {
		if id != ids[0] {
			t.Fatalf("two sessions: %v", ids)
		}
		if created[i] {
			n++
		}
	}
	if n != 1 {
		t.Errorf("%d joins say they created it", n)
	}
	x, err := f.s.Session(f.ctx, ids[0])
	if err != nil || x.Room != domain.MeetingRoomName(f.ws, m.ID, x.ID) {
		t.Fatalf("session %+v %v", x, err)
	}

	// Seats and knocks.
	alice := domain.Person{UserID: f.alice}
	seat, err := f.s.CreateSeat(f.ctx, domain.MeetingSeat{SessionID: x.ID, Person: alice, Device: "laptop01", Name: "Alice"}, []byte("seat-a"))
	if err != nil {
		t.Fatal(err)
	}
	ref, err := f.s.SeatByToken(domain.System(context.Background()), []byte("seat-a"))
	if err != nil || ref.Seat.ID != seat.ID || ref.WorkspaceID != f.ws || ref.MeetingID != m.ID || !ref.SessionLive || ref.Seat.Person != alice {
		t.Fatalf("seat by token %+v %v", ref, err)
	}
	g, err := f.s.CreateMeetingGuest(f.ctx, domain.MeetingGuest{MeetingID: m.ID, Name: "Client", Via: domain.GuestByName}, []byte("guest-1"))
	if err != nil {
		t.Fatal(err)
	}
	guest := domain.Person{GuestID: g.ID}
	k, err := f.s.CreateKnock(f.ctx, domain.MeetingKnock{SessionID: x.ID, Person: guest, Device: "phone001", Name: "Client"}, []byte("knock-1"))
	if err != nil || k.State != domain.KnockWaiting {
		t.Fatalf("knock %+v %v", k, err)
	}
	waiting, _ := f.s.WaitingKnocks(f.ctx, x.ID)
	if len(waiting) != 1 || waiting[0].Person != guest {
		t.Fatalf("waiting %+v", waiting)
	}
	if ok, _ := f.s.DecideKnock(f.ctx, k.ID, domain.KnockDenied, f.alice, nil); !ok {
		t.Fatal("deny")
	}
	if ok, _ := f.s.DecideKnock(f.ctx, k.ID, domain.KnockAdmitted, f.alice, nil); ok {
		t.Error("a decided knock decided again")
	}
	if denied, _ := f.s.DeniedSince(f.ctx, x.ID, guest, time.Now().Add(-time.Minute)); !denied {
		t.Error("denied a moment ago")
	}
	st, _ := f.s.PersonStatus(f.ctx, x.ID, alice)
	if !st.Admitted || st.Removed {
		t.Errorf("alice %+v", st)
	}
	if _, err := f.s.CreateSeat(f.ctx, domain.MeetingSeat{SessionID: x.ID, Person: alice, Device: "phone002", Name: "Alice"}, []byte("seat-a2")); err != nil {
		t.Fatal(err)
	}
	gone, err := f.s.RemovePerson(f.ctx, x.ID, alice)
	if err != nil || len(gone) != 2 {
		t.Fatalf("removed identities %v %v", gone, err)
	}
	st, _ = f.s.PersonStatus(f.ctx, x.ID, alice)
	if st.Admitted || !st.Removed {
		t.Errorf("removed alice %+v", st)
	}

	// Attendance from webhooks, out of order and repeated.
	t0 := time.Now().Add(-10 * time.Minute).Truncate(time.Second)
	bob := domain.Person{UserID: f.bob}
	if err := f.s.ParticipantJoined(f.ctx, x.ID, "u1-aaaa", bob, "Bob", t0); err != nil {
		t.Fatal(err)
	}
	if err := f.s.ParticipantJoined(f.ctx, x.ID, "u1-aaaa", bob, "Bob", t0); err != nil {
		t.Fatal(err)
	}
	// Bob's phone: left arrives before joined.
	if err := f.s.ParticipantLeft(f.ctx, x.ID, "u1-bbbb", bob, "Bob", t0.Add(time.Minute), t0.Add(2*time.Minute)); err != nil {
		t.Fatal(err)
	}
	if err := f.s.ParticipantJoined(f.ctx, x.ID, "u1-bbbb", bob, "Bob", t0.Add(time.Minute)); err != nil {
		t.Fatal(err)
	}
	if err := f.s.ParticipantJoined(f.ctx, x.ID, "g1-cccc", guest, "Client", t0.Add(time.Minute)); err != nil {
		t.Fatal(err)
	}
	present, _ := f.s.PresentPeople(f.ctx, x.ID)
	if len(present) != 2 {
		t.Fatalf("present %+v", present)
	}
	m, _ = f.s.Meeting(f.ctx, m.ID)
	if m.InCall != 2 || m.Live == nil || m.Live.ConnectedAt == nil {
		t.Errorf("in call %d, live %+v", m.InCall, m.Live)
	}
	// The reconciler: LiveKit has only Bob's laptop.
	closed, err := f.s.SyncPresent(f.ctx, x.ID, []string{"u1-aaaa"}, time.Now())
	if err != nil || closed != 1 {
		t.Errorf("sync closed %d %v", closed, err)
	}
	att, _ := f.s.Attendance(f.ctx, x.ID)
	if len(att) != 2 || att[0].Person != bob || att[0].LastOut != nil || !att[1].IsGuest || att[1].LastOut == nil {
		t.Errorf("attendance %+v", att)
	}

	// Chat.
	msg, err := f.s.AddMessage(f.ctx, domain.MeetingMessage{SessionID: x.ID, Person: guest, Name: "Client", Body: "hello"})
	if err != nil {
		t.Fatal(err)
	}
	msgs, _ := f.s.Messages(f.ctx, x.ID, 0, 10)
	if len(msgs) != 1 || msgs[0].ID != msg.ID || msgs[0].Person != guest {
		t.Errorf("messages %+v", msgs)
	}

	// Notes on, the audio recorded; ending queues the transcription.
	if err := f.s.SetNotes(f.ctx, x.ID, true, f.alice); err != nil {
		t.Fatal(err)
	}
	if _, err := f.s.CreateMedia(f.ctx, domain.MeetingMedia{SessionID: x.ID, Kind: domain.MediaAudioMixed, EgressID: "EG_" + nextCode(), File: "a.ogg"}); err != nil {
		t.Fatal(err)
	}
	ended, err := f.s.EndSession(f.ctx, x.ID, time.Now())
	if err != nil || !ended {
		t.Fatalf("end %v %v", ended, err)
	}
	if ended, _ := f.s.EndSession(f.ctx, x.ID, time.Now()); ended {
		t.Error("ended twice")
	}
	x, _ = f.s.Session(f.ctx, x.ID)
	if x.NotesStatus != domain.NotesQueued || x.NotesOn || x.EndedAt == nil {
		t.Errorf("ended session %+v", x)
	}
	present, _ = f.s.PresentPeople(f.ctx, x.ID)
	if len(present) != 0 {
		t.Errorf("still present %+v", present)
	}
	claimed, ok, err := f.s.ClaimNotes(domain.System(context.Background()))
	if err != nil || !ok || claimed.ID != x.ID || claimed.NotesStatus != domain.NotesTranscribing {
		t.Fatalf("claim %+v %v %v", claimed, ok, err)
	}
	if _, ok, _ := f.s.ClaimNotes(domain.System(context.Background())); ok {
		t.Error("claimed twice")
	}
	// A new join after the end opens a new session.
	y, created2, err := f.s.OpenSession(f.ctx, m.ID)
	if err != nil || !created2 || y.ID == x.ID {
		t.Fatalf("next session %+v %v %v", y, created2, err)
	}
	past, err := f.s.PastSessions(f.ctx, f.bob, false, nil, 10)
	if err != nil || len(past) != 1 || past[0].Session.ID != x.ID || past[0].People != 2 {
		t.Errorf("past %+v %v", past, err)
	}

	// Segments.
	segs := []domain.MeetingSegment{{StartMS: 0, EndMS: 4000, Text: "Let's ship the refund flow"}, {StartMS: 4000, EndMS: 9000, Text: "Bob will write the migration"}}
	if err := f.s.ReplaceSegments(f.ctx, x.ID, segs); err != nil {
		t.Fatal(err)
	}
	got, _ := f.s.Segments(f.ctx, x.ID)
	if len(got) != 2 || got[1].Text != segs[1].Text {
		t.Errorf("segments %+v", got)
	}
	hits, err := f.s.SearchTranscripts(f.ctx, f.bob, false, "migration", 10)
	if err != nil || len(hits) != 1 || hits[0].SessionID != x.ID {
		t.Errorf("search %+v %v", hits, err)
	}
	in, err := f.s.NotesInput(f.ctx, x.ID)
	if err != nil || len(in.Segments) != 2 || in.Speakers || len(in.Attendees) != 2 || len(in.Messages) != 1 {
		t.Errorf("notes input %+v %v", in, err)
	}
	usage, err := f.s.MeetingUsage(f.ctx, time.Now().Add(-24*time.Hour), time.Now().Add(time.Hour))
	if err != nil || len(usage) == 0 || usage[len(usage)-1].ParticipantMinutes == 0 {
		t.Errorf("usage %+v %v", usage, err)
	}
	// Other workspaces see none of it.
	if _, err := f.s.Session(f.otherCtx, x.ID); !errors.Is(err, domain.ErrNotFound) {
		t.Errorf("another workspace read the session: %v", err)
	}
	if got, _ := f.s.Segments(f.otherCtx, x.ID); len(got) != 0 {
		t.Errorf("another workspace read the transcript: %+v", got)
	}
	files, err := f.s.DeleteMeeting(f.ctx, m.ID)
	if err != nil || len(files) != 1 || files[0] != "a.ogg" {
		t.Errorf("delete %v %v", files, err)
	}
}

func TestLivekitEventsSeenOnce(t *testing.T) {
	f := newMeetFixture(t)
	sys := domain.System(context.Background())
	id := "EV_" + nextCode()
	if first, err := f.s.FirstSeen(sys, id); err != nil || !first {
		t.Fatalf("first %v %v", first, err)
	}
	if first, _ := f.s.FirstSeen(sys, id); first {
		t.Error("seen twice")
	}
}
