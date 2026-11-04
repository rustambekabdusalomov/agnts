package perfreview

import (
	"slices"
	"time"

	"agnts/internal/domain"
)

// Total is one author's delivered complexity for a period.
type Total struct {
	Key         string  `json:"key"`
	Points      float64 `json:"points"`
	Tickets     int     `json:"tickets"`
	Reverts     int     `json:"reverts"`
	Regressions int     `json:"regressions"`
}

// Average is the points per ticket: it tells "many small" from "few
// hard".
func (t Total) Average() float64 {
	if t.Tickets == 0 {
		return 0
	}
	return round2(t.Points / float64(t.Tickets))
}

// Earned is what one author's share of a scored delivery is worth.
func Earned(s domain.TicketScore, share float64) float64 {
	return round2(AfterPenalties(s.Effective(), s.RevertedShare, s.Regressions) * share)
}

// Totals adds up scored deliveries per author; unscored ones are left
// out (and counted by the caller).
func Totals(scores []domain.TicketScore) []Total {
	by := map[string]*Total{}
	for _, s := range scores {
		if s.Status != domain.ScoreScored {
			continue
		}
		after := AfterPenalties(s.Effective(), s.RevertedShare, s.Regressions)
		for _, a := range s.Authors {
			t := by[a.Key]
			if t == nil {
				t = &Total{Key: a.Key}
				by[a.Key] = t
			}
			t.Points += after * a.Share
			t.Tickets++
			if s.RevertedShare > 0 {
				t.Reverts++
			}
			t.Regressions += s.Regressions
		}
	}
	out := make([]Total, 0, len(by))
	for _, t := range by {
		t.Points = round2(t.Points)
		out = append(out, *t)
	}
	slices.SortFunc(out, func(a, b Total) int {
		if a.Key < b.Key {
			return -1
		}
		if a.Key > b.Key {
			return 1
		}
		return 0
	})
	return out
}

// Month is a calendar month in a zone: [Start, End).
type Month struct {
	Start, End time.Time
}

// MonthOf returns the month t falls in, in tz.
func MonthOf(t time.Time, tz *time.Location) Month {
	t = t.In(tz)
	start := time.Date(t.Year(), t.Month(), 1, 0, 0, 0, 0, tz)
	return Month{Start: start, End: start.AddDate(0, 1, 0)}
}

// ParseMonth reads "2026-10" as a month in tz.
func ParseMonth(s string, tz *time.Location) (Month, bool) {
	t, err := time.ParseInLocation("2006-01", s, tz)
	if err != nil {
		return Month{}, false
	}
	return MonthOf(t, tz), true
}

// Name is the month as "2026-10".
func (m Month) Name() string { return m.Start.Format("2006-01") }

// Grace periods of a month's close: on the 3rd of the next month, or
// later while scores are pending, up to the 10th.
const (
	graceDays = 2
	hardDays  = 9
)

// ClosesOn is when the month closes on its own if no score is pending.
func (m Month) ClosesOn() time.Time { return m.End.AddDate(0, 0, graceDays) }

// LatestClose is when it closes whatever is pending.
func (m Month) LatestClose() time.Time { return m.End.AddDate(0, 0, hardDays) }

// CloseDue reports whether the month closes now on its own: past the 3rd
// with nothing pending, or past the 10th.
func (m Month) CloseDue(now time.Time, pending int) bool {
	return !now.Before(m.LatestClose()) || (!now.Before(m.ClosesOn()) && pending == 0)
}
