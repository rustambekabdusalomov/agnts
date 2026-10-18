package orchestrator

import (
	"testing"
	"time"

	"agnts/internal/domain"
)

// Each commit takes the commit info of the run whose result was saved
// right after it; one after every result has none.
func TestRunCommitAt(t *testing.T) {
	t0 := time.Date(2026, 10, 18, 11, 0, 0, 0, time.UTC)
	runs := []domain.RunCommit{
		{At: t0.Add(5 * time.Minute)},
		{At: t0.Add(31 * time.Minute)},
		{At: t0.Add(155 * time.Minute), Info: domain.CommitInfo{Type: "fix", Scope: "survey", Subject: "use local zone"}},
	}
	for _, c := range []struct {
		at   time.Duration
		want string
	}{
		{5*time.Minute - 2*time.Second, ""},                 // the first run (no info)
		{31*time.Minute - 3*time.Second, ""},                // the second
		{155*time.Minute - 4*time.Second, "use local zone"}, // the third
		{155*time.Minute + 2*time.Second, "use local zone"}, // clocks a little apart
		{200 * time.Minute, ""},                             // after every result
	} {
		if got := runCommitAt(runs, t0.Add(c.at)).Subject; got != c.want {
			t.Errorf("commit at +%s: %q, want %q", c.at, got, c.want)
		}
	}
}
