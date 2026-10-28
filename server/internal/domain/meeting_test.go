package domain

import (
	"errors"
	"strings"
	"testing"
	"time"
)

func TestMeetingCode(t *testing.T) {
	seen := map[string]bool{}
	for range 200 {
		c, err := NewMeetingCode()
		if err != nil {
			t.Fatal(err)
		}
		if len(c) != MeetingCodeLen || strings.Trim(c, "abcdefghijklmnopqrstuvwxyz") != "" {
			t.Fatalf("bad code %q", c)
		}
		if seen[c] {
			t.Fatalf("repeated code %q", c)
		}
		seen[c] = true
	}
	if got := FormatMeetingCode("abcdefghij"); got != "abc-defg-hij" {
		t.Errorf("format = %q", got)
	}
	for in, want := range map[string]string{
		"abc-defg-hij":                        "abcdefghij",
		"ABC DEFG HIJ":                        "abcdefghij",
		" abcdefghij ":                        "abcdefghij",
		"https://agnts.uz/m/abc-defg-hij":     "abcdefghij",
		"https://agnts.uz/m/abc-defg-hij?i=x": "abcdefghij",
	} {
		got, ok := ParseMeetingCode(in)
		if !ok || got != want {
			t.Errorf("ParseMeetingCode(%q) = %q, %v", in, got, ok)
		}
	}
	for _, in := range []string{"", "abc", "abc-defg-hi1", "abcdefghijk", "abc_defg_hij", "../../etc"} {
		if _, ok := ParseMeetingCode(in); ok {
			t.Errorf("ParseMeetingCode(%q) took it", in)
		}
	}
}

func TestMeetingRoomAndIdentity(t *testing.T) {
	name := MeetingRoomName(3, 14, 159)
	if name != "ws3-m14-s159" {
		t.Fatalf("room = %q", name)
	}
	ws, m, s, ok := ParseMeetingRoomName(name)
	if !ok || ws != 3 || m != 14 || s != 159 {
		t.Fatalf("parse = %d %d %d %v", ws, m, s, ok)
	}
	for _, bad := range []string{"", "ws3-m14", "ws0-m1-s1", "ws3-m14-s159x", "xws3-m14-s159"} {
		if _, _, _, ok := ParseMeetingRoomName(bad); ok {
			t.Errorf("parsed %q", bad)
		}
	}

	id := MeetingIdentity(Person{UserID: 7}, "abcd1234")
	if id != "u7-abcd1234" {
		t.Fatalf("identity = %q", id)
	}
	p, dev, ok := ParseMeetingIdentity(id)
	if !ok || p.UserID != 7 || dev != "abcd1234" {
		t.Fatalf("parse identity = %+v %q %v", p, dev, ok)
	}
	p, _, ok = ParseMeetingIdentity("g12-zz99")
	if !ok || p.GuestID != 12 || !p.IsGuest() {
		t.Fatalf("guest identity = %+v %v", p, ok)
	}
	for _, bad := range []string{"u7", "u7-AB", "x7-abcd", "u0-abcd", "u7-abcd-efgh", "egress-abcd"} {
		if _, _, ok := ParseMeetingIdentity(bad); ok {
			t.Errorf("parsed identity %q", bad)
		}
	}
	if d := CleanDevice("Phone-1"); len(d) != 8 {
		t.Errorf("a bad device id is replaced: %q", d)
	}
	if d := CleanDevice("laptop01"); d != "laptop01" {
		t.Errorf("a good device id is kept: %q", d)
	}
}

func TestDecideJoin(t *testing.T) {
	now := time.Date(2026, 10, 28, 12, 0, 0, 0, time.UTC)
	host := int64(1)
	base := Meeting{ID: 1, HostID: &host, CohostIDs: []int64{2}, Kind: MeetingInstant, Access: AccessWorkspace, Guests: GuestsKnock}
	later := now.Add(time.Hour)
	soon := now.Add(10 * time.Minute)
	sched := base
	sched.Kind, sched.StartsAt = MeetingScheduled, &later
	schedSoon := sched
	schedSoon.StartsAt = &soon
	invited := base
	invited.Access = AccessInvited
	locked := base
	locked.Locked = true
	open := base
	open.Guests = GuestsOpen
	off := base
	off.Guests = GuestsOff
	cancelled := base
	cancelled.CancelledAt = &now

	member := Person{UserID: 5}
	guest := Person{GuestID: 9}
	cases := []struct {
		name    string
		r       JoinRequest
		outcome JoinOutcome
		reason  string
		role    MeetingRole
	}{
		{"host joins", JoinRequest{Meeting: base, Person: Person{UserID: 1}, WorkspaceRole: RoleUser}, JoinNow, "", RoleHost},
		{"co-host joins a locked meeting", JoinRequest{Meeting: locked, Person: Person{UserID: 2}, WorkspaceRole: RoleUser}, JoinNow, "", RoleCohost},
		{"owner joins a locked meeting", JoinRequest{Meeting: locked, Person: member, WorkspaceRole: RoleOwner}, JoinNow, "", RoleMember},
		{"member joins workspace access", JoinRequest{Meeting: base, Person: member, WorkspaceRole: RoleUser}, JoinNow, "", RoleMember},
		{"viewer joins too", JoinRequest{Meeting: base, Person: member, WorkspaceRole: RoleViewer}, JoinNow, "", RoleMember},
		{"member knocks on invited access", JoinRequest{Meeting: invited, Person: member, WorkspaceRole: RoleUser}, JoinKnock, "", RoleMember},
		{"invited member joins", JoinRequest{Meeting: invited, Person: member, WorkspaceRole: RoleUser, Invited: true}, JoinNow, "", RoleMember},
		{"guest knocks", JoinRequest{Meeting: base, Person: guest}, JoinKnock, "", RoleGuest},
		{"account of another workspace is a guest", JoinRequest{Meeting: base, Person: Person{UserID: 77}}, JoinKnock, "", RoleGuest},
		{"invited guest joins", JoinRequest{Meeting: invited, Person: guest, Invited: true}, JoinNow, "", RoleGuest},
		{"guest joins open", JoinRequest{Meeting: open, Person: guest}, JoinNow, "", RoleGuest},
		{"guests off", JoinRequest{Meeting: off, Person: guest}, JoinRefused, RefuseGuestsOff, RoleGuest},
		{"locked refuses a member", JoinRequest{Meeting: locked, Person: member, WorkspaceRole: RoleUser}, JoinRefused, RefuseLocked, RoleMember},
		{"locked lets the admitted back", JoinRequest{Meeting: locked, Person: guest, Admitted: true}, JoinNow, "", RoleGuest},
		{"admitted guest rejoins without knocking", JoinRequest{Meeting: base, Person: guest, Admitted: true}, JoinNow, "", RoleGuest},
		{"removed can't come back", JoinRequest{Meeting: base, Person: member, WorkspaceRole: RoleUser, Admitted: true, Removed: true}, JoinRefused, RefuseRemoved, RoleMember},
		{"removed host can't either", JoinRequest{Meeting: base, Person: Person{UserID: 2}, WorkspaceRole: RoleUser, Removed: true}, JoinRefused, RefuseRemoved, RoleCohost},
		{"cancelled", JoinRequest{Meeting: cancelled, Person: Person{UserID: 1}, WorkspaceRole: RoleUser}, JoinRefused, RefuseCancelled, RoleHost},
		{"full", JoinRequest{Meeting: base, Person: member, WorkspaceRole: RoleUser, InCall: 50, MaxPeople: 50}, JoinRefused, RefuseFull, RoleMember},
		{"full refuses the host too", JoinRequest{Meeting: base, Person: Person{UserID: 1}, WorkspaceRole: RoleUser, InCall: 50, MaxPeople: 50}, JoinRefused, RefuseFull, RoleHost},
		{"scheduled too early", JoinRequest{Meeting: sched, Person: member, WorkspaceRole: RoleUser, Invited: true}, JoinRefused, RefuseNotYet, RoleMember},
		{"scheduled within 15 minutes", JoinRequest{Meeting: schedSoon, Person: member, WorkspaceRole: RoleUser, Invited: true}, JoinNow, "", RoleMember},
		{"host may start early", JoinRequest{Meeting: sched, Person: Person{UserID: 1}, WorkspaceRole: RoleUser}, JoinNow, "", RoleHost},
		{"denied a moment ago", JoinRequest{Meeting: base, Person: guest, DeniedRecently: true}, JoinRefused, RefuseDenied, RoleGuest},
	}
	for _, c := range cases {
		c.r.Now = now
		got := DecideJoin(c.r)
		if got.Outcome != c.outcome || got.Reason != c.reason || got.Role != c.role {
			t.Errorf("%s: got %+v, want %s %q %s", c.name, got, c.outcome, c.reason, c.role)
		}
	}
}

func TestRightsOf(t *testing.T) {
	if r := RightsOf(RoleHost, false); !r.ManageCohosts || !r.Record || !r.Admit {
		t.Errorf("host: %+v", r)
	}
	if r := RightsOf(RoleCohost, false); r.ManageCohosts || !r.Moderate || !r.Admit {
		t.Errorf("co-host: %+v", r)
	}
	if r := RightsOf(RoleMember, true); r.Admit || r.Moderate || !r.ScreenShare || !r.Chat {
		t.Errorf("member: %+v", r)
	}
	if r := RightsOf(RoleGuest, false); !r.Chat || !r.ScreenShare || r.Admit {
		t.Errorf("guest: %+v", r)
	}
	if r := RightsOf(RoleGuest, true); r.Chat || r.ScreenShare || !r.Publish {
		t.Errorf("quiet guest: %+v", r)
	}
}

func TestMeetingInputClean(t *testing.T) {
	now := time.Date(2026, 10, 28, 12, 0, 0, 0, time.UTC)
	in := MeetingInput{}
	if err := in.Clean(now, true); err != nil {
		t.Fatal(err)
	}
	if in.Kind != MeetingInstant || in.Access != AccessWorkspace || in.Guests != GuestsKnock || in.DurationMin != 30 || in.Language != "auto" {
		t.Errorf("instant defaults: %+v", in)
	}
	start := now.Add(time.Hour + 30*time.Second)
	sch := MeetingInput{Title: " Planning ", Kind: MeetingScheduled, StartsAt: &start, TimeZone: "Asia/Tashkent"}
	if err := sch.Clean(now, true); err != nil {
		t.Fatal(err)
	}
	if sch.Access != AccessInvited || sch.Title != "Planning" || sch.StartsAt.Second() != 0 {
		t.Errorf("scheduled defaults: %+v", sch)
	}
	past := now.Add(-time.Hour)
	for name, bad := range map[string]MeetingInput{
		"no start":       {Kind: MeetingScheduled, Title: "x"},
		"no title":       {Kind: MeetingScheduled, StartsAt: &start},
		"past":           {Kind: MeetingScheduled, Title: "x", StartsAt: &past},
		"bad zone":       {TimeZone: "Mars/Olympus"},
		"bad access":     {Access: "everyone"},
		"bad guests":     {Guests: "maybe"},
		"bad language":   {Language: "fr"},
		"short":          {DurationMin: 2},
		"long title":     {Title: strings.Repeat("a", MeetingMaxTitle+1)},
		"unknown kind":   {Kind: "weekly"},
		"too long a day": {DurationMin: 721},
	} {
		if err := bad.Clean(now, true); !errors.Is(err, ErrMeetingInvalid) {
			t.Errorf("%s: err = %v", name, err)
		}
	}
	// An existing meeting may keep a start in the past.
	old := MeetingInput{Kind: MeetingScheduled, Title: "x", StartsAt: &past}
	if err := old.Clean(now, false); err != nil {
		t.Errorf("update of a past meeting: %v", err)
	}
}

func TestCleanActionItems(t *testing.T) {
	neg := -5
	at := 61000
	out, err := CleanActionItems([]ActionItem{
		{Text: "  Ship the refund flow ", Who: "Rustam", AtMS: &at},
		{Text: "   "},
		{Text: "Write the migration", AtMS: &neg, Quote: strings.Repeat("q", 600)},
	})
	if err != nil {
		t.Fatal(err)
	}
	if len(out) != 2 || out[0].Text != "Ship the refund flow" || out[1].Position != 1 || out[1].AtMS != nil || len(out[1].Quote) != ActionItemMaxQuote {
		t.Fatalf("got %+v", out)
	}
	if _, err := CleanActionItems(make([]ActionItem, ActionItemsMax+1)); err == nil {
		t.Error("too many items accepted")
	}
}

func TestFormatOffset(t *testing.T) {
	for ms, want := range map[int]string{0: "0:00", 61_000: "1:01", 3_725_000: "1:02:05"} {
		if got := FormatOffset(ms); got != want {
			t.Errorf("FormatOffset(%d) = %q, want %q", ms, got, want)
		}
	}
}

func TestMeetingSettingsValidate(t *testing.T) {
	if err := DefaultMeetingSettings().Validate(); err != nil {
		t.Fatal(err)
	}
	if err := (MeetingSettings{MaxParticipants: 1}).Validate(); err == nil {
		t.Error("one person per call accepted")
	}
	if err := (MeetingSettings{MaxParticipants: 10, RetentionDays: -1}).Validate(); err == nil {
		t.Error("negative retention accepted")
	}
}
