package domain

import (
	"slices"
	"testing"
	"time"
)

func TestTicketTokens(t *testing.T) {
	for _, c := range []struct {
		in   string
		want []string
	}{
		{"feature/AMANAT-2288-login", []string{"amanat-2288"}},
		{"AMANAT-2288: fix token refresh", []string{"amanat-2288"}},
		{"[amanat-2288] fix", []string{"amanat-2288"}},
		{"fix(VIS-1): a, VIS-2 and vis-1", []string{"vis-1", "vis-2"}},
		{"Merge branch 'feature/AMANAT-2288' into 'main'", []string{"amanat-2288"}},
		{"AMANAT-22880", []string{"amanat-22880"}},
		{"XAMANAT-2288", []string{"xamanat-2288"}},
		{"AMANAT-2288x", nil},
		{"9AMANAT-2288", nil},
		{"agnts/web_api-12", []string{"web_api-12"}},
		{"no number here, utf-8 neither", []string{"utf-8"}},
		{"Ünï-5", nil}, // ASCII only
		{"", nil},
	} {
		if got := TicketTokens(c.in); !slices.Equal(got, c.want) {
			t.Errorf("TicketTokens(%q) = %q, want %q", c.in, got, c.want)
		}
	}
}

func TestSubject(t *testing.T) {
	if s := Subject("\n  AMANAT-1: fix  \n\nbody"); s != "AMANAT-1: fix" {
		t.Fatalf("subject: %q", s)
	}
}

func TestPickTicket(t *testing.T) {
	now := time.Now()
	open := Ticket{ID: 1, Key: "VIS-1", TicketNumber: "AMANAT-1", State: StateWaitingForReview, UpdatedAt: now.Add(-time.Hour)}
	oldDone := Ticket{ID: 2, Key: "VIS-2", TicketNumber: "AMANAT-1", State: StateDone, UpdatedAt: now.Add(-2 * time.Hour)}
	newDone := Ticket{ID: 3, Key: "VIS-3", TicketNumber: "AMANAT-1", State: StateRejected, UpdatedAt: now}
	keyed := Ticket{ID: 4, Key: "AMANAT-1", State: StateDone}

	pick := func(ts ...Ticket) int64 {
		got, ok := PickTicket("amanat-1", ts)
		if !ok {
			return 0
		}
		return got.ID
	}
	if id := pick(oldDone, newDone, open, keyed); id != 1 {
		t.Errorf("an open ticket with the number wins: %d", id)
	}
	if id := pick(oldDone, newDone, keyed); id != 4 {
		t.Errorf("then the ticket with the key: %d", id)
	}
	if id := pick(oldDone, newDone); id != 3 {
		t.Errorf("then the closed one updated last: %d", id)
	}
	if id := pick(); id != 0 {
		t.Errorf("none: %d", id)
	}
	if toks := TicketTokensOf(open); !slices.Equal(toks, []string{"vis-1", "amanat-1"}) {
		t.Errorf("tokens of: %q", toks)
	}
}

func TestPushBranchState(t *testing.T) {
	zero := "0000000000000000000000000000000000000000"
	if p := (Push{Before: zero, After: "abc"}); !p.NewBranch() || p.Deleted() {
		t.Error("new branch")
	}
	if p := (Push{Before: "abc", After: zero}); p.NewBranch() || !p.Deleted() {
		t.Error("deleted branch")
	}
}
