package orchestrator_test

import (
	"slices"
	"strings"
	"testing"

	"agnts/internal/domain"
	"agnts/internal/orchestrator"
)

// A check that fails on the commit the work starts from is not the
// ticket's: the coder hears of it, the stop gate leaves it out, no fix
// attempt goes to it, and the reviewer sees it failed before. Tickets from
// the same commit share the baseline.
func TestBaselineChecks(t *testing.T) {
	h := newHarness(t)
	h.runner.execs["git rev-parse HEAD"] = []orchestrator.ExecResult{{Output: "abc1234def5678\n"}, {Output: "abc1234def5678\n"}}
	h.runner.execs["go test ./..."] = []orchestrator.ExecResult{
		{ExitCode: 1, Output: "--- FAIL: TestFlakyClock"}, // the base commit
		{ExitCode: 1, Output: "--- FAIL: TestFlakyClock"}, // after the change
		{ExitCode: 1, Output: "--- FAIL: TestFlakyClock"}, // PAY-2, after its change
	}
	h.ingest("PAY-1")
	h.runner.scripts = []script{
		{result: ok("s1"), files: map[string]string{orchestrator.AnalysisPath: analysis(0)}},
		{result: ok("s1"), edit: "fix"},
	}
	h.step() // analyze
	h.step() // code
	tk := h.expect("PAY-1", domain.StateWaitingForReview)
	code := h.runner.prompts[1]
	if !strings.Contains(code, "## Already failing before your change") || !strings.Contains(code, "- test: `go test ./...` (exit 1)") ||
		!strings.Contains(code, "TestFlakyClock") {
		t.Fatalf("coding prompt:\n%s", code)
	}
	if evs := h.events("PAY-1", domain.EventBaseline); len(evs) != 1 || !strings.Contains(evs[0].Message, "test already fails on the commit") {
		t.Fatalf("baseline events: %+v", evs)
	}
	var fixes int
	var failed []string
	if err := h.pool.QueryRow(h.ctx, `SELECT fix_attempts, COALESCE(ARRAY(SELECT jsonb_array_elements_text(harness->'baselineFailed')), '{}')
		FROM runs WHERE ticket_id = $1 AND stage = 'code'`, tk.ID).Scan(&fixes, &failed); err != nil {
		t.Fatal(err)
	}
	if fixes != 0 || !slices.Equal(failed, []string{"test"}) {
		t.Fatalf("fix attempts %d, baseline failed %v", fixes, failed)
	}
	r, err := h.store.LatestResult(h.ctx, tk.ID, domain.StageCode)
	if err != nil || !slices.Equal(r.Harness.Preexisting, []string{"test"}) {
		t.Fatalf("result: %+v %v", r.Harness, err)
	}

	// PAY-2 starts from the same commit: the baseline is not run again.
	h.ingest("PAY-2")
	h.runner.scripts = []script{
		{result: ok("s2"), files: map[string]string{orchestrator.AnalysisPath: analysis(0)}},
		{result: ok("s2"), edit: "fix"},
	}
	h.step()
	h.step()
	h.expect("PAY-2", domain.StateWaitingForReview)
	n := 0
	for _, c := range h.runner.ran {
		if c == "go test ./..." {
			n++
		}
	}
	if n != 3 {
		t.Fatalf("go test ran %d times, want 3 (one baseline, one check per ticket)", n)
	}
}
