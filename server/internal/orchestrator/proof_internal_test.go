package orchestrator

import (
	"testing"

	"agnts/internal/domain"
)

func TestProofJudgement(t *testing.T) {
	pt := func(before, after int, out string) domain.ProofTest {
		return domain.ProofTest{Name: "TestRefund/rounds_half_up", Before: domain.ProofRun{Exit: before, Output: out}, After: domain.ProofRun{Exit: after}}
	}
	cases := []struct {
		t    domain.ProofTest
		want string
	}{
		{pt(1, 0, "--- FAIL: TestRefund/rounds_half_up (0.00s)"), domain.ProofProven},
		{pt(1, 0, "--- FAIL: TestRefund (0.00s)\n    --- FAIL: rounds_half_up"), domain.ProofProven},
		{pt(0, 0, "ok"), domain.ProofNotReproduced},
		{pt(1, 1, "FAIL"), domain.ProofStillFailing},
		{pt(1, 0, "./refund_test.go:9:2: undefined: RoundHalfUp\nFAIL pay [build failed]"), domain.ProofInconclusive},
		{pt(127, 0, "go: command not found"), domain.ProofInconclusive},
	}
	for _, c := range cases {
		if got := proofTestStatus(c.t); got != c.want {
			t.Errorf("before %d %q after %d: got %s, want %s", c.t.Before.Exit, c.t.Before.Output, c.t.After.Exit, got, c.want)
		}
	}
	all := []domain.ProofTest{{Status: domain.ProofProven}, {Status: domain.ProofInconclusive}}
	if s := proofStatus(all); s != domain.ProofInconclusive {
		t.Errorf("mixed: %s", s)
	}
	if s := proofStatus(all[:1]); s != domain.ProofProven {
		t.Errorf("one proven: %s", s)
	}
}
