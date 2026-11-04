package perfreview

import (
	"testing"
	"time"

	"agnts/internal/domain"
)

func TestTotalsWithPenalties(t *testing.T) {
	scores := []domain.TicketScore{
		{Status: domain.ScoreScored, Points: 8, RevertedShare: 1.0 / 12, Authors: []domain.ScoreAuthor{{Key: "user:1", Share: 1}}},
		{Status: domain.ScoreScored, Points: 5, OverridePoints: ptr(3), Authors: []domain.ScoreAuthor{{Key: "user:1", Share: 0.8}, {Key: "agent", Share: 0.2}}},
		{Status: domain.ScoreScored, Points: 8, Regressions: 1, Authors: []domain.ScoreAuthor{{Key: "user:2", Share: 1}}},
		{Status: domain.ScoreUnscored, Authors: []domain.ScoreAuthor{{Key: "user:2", Share: 1}}},
	}
	got := Totals(scores)
	if len(got) != 3 || got[0].Key != "agent" || got[0].Points != 0.6 {
		t.Fatalf("totals: %+v", got)
	}
	// 7.33 + 3 × 0.8 = 9.73; one revert.
	if got[1].Key != "user:1" || got[1].Points != 9.73 || got[1].Tickets != 2 || got[1].Reverts != 1 || got[1].Average() != 4.87 {
		t.Fatalf("user 1: %+v", got[1])
	}
	if got[2].Points != 5.6 || got[2].Regressions != 1 || got[2].Tickets != 1 {
		t.Fatalf("user 2: %+v", got[2])
	}
}

func TestMonthGrace(t *testing.T) {
	tz := time.FixedZone("UTC+5", 5*3600)
	m, ok := ParseMonth("2026-10", tz)
	if !ok || m.Name() != "2026-10" || !m.End.Equal(time.Date(2026, 11, 1, 0, 0, 0, 0, tz)) {
		t.Fatalf("month: %+v", m)
	}
	at := func(day, hour int) time.Time { return time.Date(2026, 11, day, hour, 0, 0, 0, tz) }
	cases := []struct {
		now     time.Time
		pending int
		want    bool
	}{
		{at(1, 1), 0, false},  // the 1st: scores of the last day may still come
		{at(3, 0), 0, true},   // the 3rd, nothing pending
		{at(3, 0), 2, false},  // the 3rd, two still waiting
		{at(9, 23), 2, false}, // waits up to the 10th
		{at(10, 0), 2, true},  // then closes anyway
	}
	for i, c := range cases {
		if got := m.CloseDue(c.now, c.pending); got != c.want {
			t.Errorf("case %d: got %v", i, got)
		}
	}
	if MonthOf(time.Date(2026, 10, 31, 20, 0, 0, 0, time.UTC), tz).Name() != "2026-11" {
		t.Fatal("a day is the workspace's")
	}
}

func TestUndoneWithReland(t *testing.T) {
	shas := []string{"aaaa1111", "bbbb2222"}
	// r1 reverts a; r2 reverts r1 (a re-land): a is back. r3 reverts b.
	got := Undone(shas, map[string]string{"r1": "aaaa111", "r2": "r1", "r3": "bbbb2222"})
	if got["aaaa1111"] || !got["bbbb2222"] {
		t.Fatalf("undone: %v", got)
	}
	// A revert of the re-land takes a away again.
	got = Undone(shas, map[string]string{"r1": "aaaa111", "r2": "r1", "r4": "r2"})
	if !got["aaaa1111"] {
		t.Fatalf("revert of a re-land: %v", got)
	}
}
