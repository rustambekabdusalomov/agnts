package orchestrator_test

import (
	"slices"
	"strings"
	"testing"

	"agnts/internal/domain"
	"agnts/internal/guard"
	"agnts/internal/orchestrator"
)

// The commands that save and restore a stopped run's unfinished change.
const (
	gitStatus = "git status --porcelain --untracked-files=all"
	saveDiff  = "git add -A && git diff --cached --binary HEAD > /agnts/out/wip.patch && wc -c < /agnts/out/wip.patch"
	applyDiff = "git apply --binary /agnts/out/wip.patch"
	wipPatch  = "/agnts/out/wip.patch"
)

// unfinished makes the next coding run leave refund.go changed and
// refund_test.go new, with the workspace checked out at commit base.
func (h *harness) unfinished(base string) {
	h.runner.head = base
	h.runner.execs[gitStatus] = []orchestrator.ExecResult{{Output: " M refund.go\n?? refund_test.go"}}
	h.runner.execs[saveDiff] = []orchestrator.ExecResult{{Output: "5"}}
}

func (h *harness) savedWork(key string) []string {
	h.t.Helper()
	v, err := h.o.View(h.ctx, key)
	if err != nil {
		h.t.Fatal(err)
	}
	return v.SavedWork
}

func (h *harness) hasEvent(key, typ, text string) bool {
	h.t.Helper()
	for _, e := range h.events(key, typ) {
		if strings.Contains(e.Message, text) {
			return true
		}
	}
	return false
}

func TestStopKeepsWorkAndRetryContinues(t *testing.T) {
	h := newHarness(t)
	h.ingest("PAY-30")
	notes := "## Plan\n1. round half up (done)\n2. test"
	h.runner.scripts = []script{
		{result: ok("s30"), files: map[string]string{orchestrator.AnalysisPath: analysis(0)}},
		{result: ok("s30"), files: map[string]string{wipPatch: "PATCH", guard.ProgressPath: notes}},
		{result: ok("s30"), edit: "v1"},
	}
	h.step()
	h.unfinished("base1")

	// Stopped mid-run and retried at once, while the run still tears down.
	calls := 0
	h.runner.onClaude = func(orchestrator.ClaudeRequest) {
		if calls++; calls > 1 {
			return
		}
		if _, err := h.o.Stop(h.ctx, "PAY-30", domain.OriginWeb); err != nil {
			t.Error(err)
		}
		if _, err := h.o.Retry(h.ctx, "PAY-30", domain.OriginWeb); err != nil {
			t.Error(err)
		}
		// Nothing claims it before the stopped run has saved its work.
		if claimed, err := h.o.RunOnce(h.ctx); claimed || err != nil {
			t.Errorf("claimed while the stopped run was ending: %v %v", claimed, err)
		}
	}
	h.step()
	h.expect("PAY-30", domain.StateCoding)
	if !h.progress.has("PAY-30") || !h.hasEvent("PAY-30", domain.EventTicketUpdated, "kept the unfinished change (2 files)") {
		t.Fatal("the stopped run's work was not kept")
	}

	h.step()
	h.expect("PAY-30", domain.StateWaitingForReview)
	if h.runner.written[wipPatch] != "PATCH" || !slices.Contains(h.runner.ran, applyDiff) {
		t.Fatalf("patch not applied: wrote %q, ran %q", h.runner.written[wipPatch], h.runner.ran)
	}
	if h.runner.written[guard.ProgressPath] != notes {
		t.Fatalf("progress notes not put back: %q", h.runner.written[guard.ProgressPath])
	}
	p := lastPrompt(h)
	if !strings.Contains(p, "was stopped before it finished") || !strings.Contains(p, "- refund_test.go") || strings.Contains(p, "failed before") {
		t.Fatalf("resume prompt:\n%s", p)
	}
	if r := h.runner.resumes[len(h.runner.resumes)-1]; r != "s30" {
		t.Fatalf("resumed session %q", r)
	}
	if h.progress.has("PAY-30") {
		t.Fatal("saved work kept after the commit")
	}
}

func TestStopDuringChecksRunsTheChecksAgain(t *testing.T) {
	h := newHarness(t)
	h.ingest("PAY-31")
	h.runner.scripts = []script{
		{result: ok("s31"), files: map[string]string{orchestrator.AnalysisPath: analysis(0)}},
		{result: ok("s31"), edit: "v1", files: map[string]string{wipPatch: "PATCH", orchestrator.SummaryPath: `{"summary":"Rounded half up."}`}},
	}
	h.step()
	h.unfinished("base1")
	stopped := false
	h.runner.onExec = func(cmd string) {
		if cmd == "go test ./..." && len(h.runner.prompts) == 2 && !stopped {
			stopped = true
			if _, err := h.o.Stop(h.ctx, "PAY-31", domain.OriginWeb); err != nil {
				t.Error(err)
			}
		}
	}
	h.step()
	tk := h.expect("PAY-31", domain.StateFailed)
	if !stopped || tk.ResumeState != domain.StateCoding {
		t.Fatalf("stopped=%v resume state %s", stopped, tk.ResumeState)
	}
	if got := h.savedWork("PAY-31"); !slices.Equal(got, []string{"refund.go", "refund_test.go"}) {
		t.Fatalf("saved work on the ticket page: %q", got)
	}

	if _, err := h.o.Retry(h.ctx, "PAY-31", domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	h.step() // no Claude script left: a Claude call would fail the run
	h.expect("PAY-31", domain.StateWaitingForReview)
	if len(h.runner.prompts) != 2 || !h.hasEvent("PAY-31", domain.EventTicketUpdated, "had finished the change before the stop") {
		t.Fatalf("Claude ran again: %d prompts", len(h.runner.prompts))
	}
	if h.runner.written[orchestrator.SummaryPath] != `{"summary":"Rounded half up."}` {
		t.Fatalf("summary not put back: %q", h.runner.written[orchestrator.SummaryPath])
	}
}

func TestSavedWorkDroppedWhenTheBranchMoved(t *testing.T) {
	h := newHarness(t)
	h.ingest("PAY-32")
	h.runner.scripts = []script{
		{result: ok("s32"), files: map[string]string{orchestrator.AnalysisPath: analysis(0)}},
		{result: ok("s32"), files: map[string]string{wipPatch: "PATCH"}},
		{result: ok("s32"), edit: "v2"},
	}
	h.step()
	h.unfinished("base1")
	h.runner.onClaude = func(orchestrator.ClaudeRequest) {
		if len(h.runner.prompts) == 2 {
			if _, err := h.o.Stop(h.ctx, "PAY-32", domain.OriginWeb); err != nil {
				t.Error(err)
			}
		}
	}
	h.step()
	h.expect("PAY-32", domain.StateFailed)
	h.runner.head = "base2" // someone moved the branch meanwhile
	if _, err := h.o.Retry(h.ctx, "PAY-32", domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	h.step()
	h.expect("PAY-32", domain.StateWaitingForReview)
	if slices.Contains(h.runner.ran, applyDiff) {
		t.Fatal("applied a patch saved on another commit")
	}
	if !h.hasEvent("PAY-32", domain.EventTicketUpdated, "no longer applies") {
		t.Fatal("no warning that the saved work was dropped")
	}
	if p := lastPrompt(h); strings.Contains(p, "stopped before it finished") || strings.Contains(p, "put its uncommitted changes back") {
		t.Fatalf("the prompt speaks of restored work:\n%s", p)
	}
}

func TestFailedChecksKeepWorkAndTheError(t *testing.T) {
	h := newHarness(t)
	h.ingest("PAY-33")
	h.runner.scripts = []script{
		{result: ok("s33"), files: map[string]string{orchestrator.AnalysisPath: analysis(0)}},
		{result: ok("s33"), edit: "v1", files: map[string]string{wipPatch: "PATCH"}},
		{result: ok("s33"), edit: "v2"}, // the fix attempt
		{result: ok("s33"), edit: "v3"},
	}
	h.step()
	h.unfinished("base1")
	h.runner.execs["go test ./..."] = []orchestrator.ExecResult{{ExitCode: 1, Output: "boom"}, {ExitCode: 1, Output: "boom"}}
	h.step()
	h.expect("PAY-33", domain.StateFailed)
	if len(h.savedWork("PAY-33")) != 2 {
		t.Fatalf("saved work: %q", h.savedWork("PAY-33"))
	}

	if _, err := h.o.Retry(h.ctx, "PAY-33", domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	h.step()
	h.expect("PAY-33", domain.StateWaitingForReview)
	if p := lastPrompt(h); !strings.Contains(p, "failed before it finished") || !strings.Contains(p, "boom") {
		t.Fatalf("resume prompt without the error:\n%s", p)
	}
}

func TestDiscardWorkStartsFromTheLastCommit(t *testing.T) {
	h := newHarness(t)
	h.ingest("PAY-34")
	h.runner.scripts = []script{
		{result: ok("s34"), files: map[string]string{orchestrator.AnalysisPath: analysis(0)}},
		{result: ok("s34"), files: map[string]string{wipPatch: "PATCH"}},
		{result: ok("s34"), edit: "v2"},
	}
	h.step()
	h.unfinished("base1")
	h.runner.onClaude = func(orchestrator.ClaudeRequest) {
		if len(h.runner.prompts) == 2 {
			if _, err := h.o.Stop(h.ctx, "PAY-34", domain.OriginWeb); err != nil {
				t.Error(err)
			}
		}
	}
	h.step()
	h.expect("PAY-34", domain.StateFailed)
	if err := h.o.DiscardWork(h.ctx, "PAY-34", domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	if h.progress.has("PAY-34") || h.savedWork("PAY-34") != nil || !h.hasEvent("PAY-34", domain.EventTicketUpdated, "discarded the unfinished change") {
		t.Fatal("work not discarded")
	}
	if _, err := h.o.Retry(h.ctx, "PAY-34", domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	h.step()
	h.expect("PAY-34", domain.StateWaitingForReview)
	if slices.Contains(h.runner.ran, applyDiff) || strings.Contains(lastPrompt(h), "stopped before it finished") {
		t.Fatal("discarded work came back")
	}
}

func TestRejectedWorkContinuesOrStartsOver(t *testing.T) {
	for _, over := range []bool{false, true} {
		h := newHarness(t)
		h.ingest("PAY-35")
		h.runner.scripts = []script{
			{result: ok("s35"), files: map[string]string{orchestrator.AnalysisPath: analysis(0)}},
			{result: ok("s35"), files: map[string]string{wipPatch: "PATCH"}},
		}
		h.step()
		h.unfinished("base1")
		h.runner.onClaude = func(orchestrator.ClaudeRequest) {
			if len(h.runner.prompts) == 2 {
				if _, err := h.o.Reject(h.ctx, "PAY-35", "later", domain.OriginWeb); err != nil {
					t.Error(err)
				}
			}
		}
		h.step()
		h.expect("PAY-35", domain.StateRejected)
		if len(h.savedWork("PAY-35")) != 2 {
			t.Fatalf("saved work of a rejected ticket: %q", h.savedWork("PAY-35"))
		}
		if over {
			if _, err := h.o.StartOver(h.ctx, "PAY-35", domain.OriginWeb); err != nil {
				t.Fatal(err)
			}
			if h.progress.has("PAY-35") {
				t.Fatal("start over kept the saved work")
			}
			continue
		}
		h.runner.scripts = []script{{result: ok("s35"), edit: "v1"}}
		if _, err := h.o.Continue(h.ctx, "PAY-35", "", nil, domain.OriginWeb); err != nil {
			t.Fatal(err)
		}
		h.expect("PAY-35", domain.StateCoding)
		h.step()
		h.expect("PAY-35", domain.StateWaitingForReview)
		if !slices.Contains(h.runner.ran, applyDiff) || !strings.Contains(lastPrompt(h), "was stopped before it finished") {
			t.Fatalf("continue did not pick the work up:\n%s", lastPrompt(h))
		}
	}
}

func TestTooLargeWorkIsNotKept(t *testing.T) {
	h := newHarness(t)
	h.ingest("PAY-36")
	h.runner.scripts = []script{
		{result: ok("s36"), files: map[string]string{orchestrator.AnalysisPath: analysis(0)}},
		{result: ok("s36"), files: map[string]string{wipPatch: "PATCH"}},
	}
	h.step()
	h.unfinished("base1")
	h.runner.execs[saveDiff] = []orchestrator.ExecResult{{Output: "warning: CRLF will be replaced by LF\n5000000"}}
	h.runner.onClaude = func(orchestrator.ClaudeRequest) {
		if len(h.runner.prompts) == 2 {
			if _, err := h.o.Stop(h.ctx, "PAY-36", domain.OriginWeb); err != nil {
				t.Error(err)
			}
		}
	}
	h.step()
	h.expect("PAY-36", domain.StateFailed)
	if h.progress.has("PAY-36") || !h.hasEvent("PAY-36", domain.EventTicketUpdated, "too large to keep") {
		t.Fatal("a too large change was kept, or nobody was told")
	}
}

func TestRestoredWorkWithoutASessionGetsTheFullTask(t *testing.T) {
	h := newHarness(t)
	h.ingest("PAY-37")
	h.runner.scripts = []script{ // no session id: nothing to resume
		{result: ok(""), files: map[string]string{orchestrator.AnalysisPath: analysis(0)}},
		{result: ok(""), files: map[string]string{wipPatch: "PATCH"}},
		{result: ok(""), edit: "v1"},
	}
	h.step()
	h.unfinished("base1")
	h.runner.onClaude = func(orchestrator.ClaudeRequest) {
		if len(h.runner.prompts) == 2 {
			if _, err := h.o.Stop(h.ctx, "PAY-37", domain.OriginWeb); err != nil {
				t.Error(err)
			}
		}
	}
	h.step()
	if _, err := h.o.Retry(h.ctx, "PAY-37", domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	h.step()
	h.expect("PAY-37", domain.StateWaitingForReview)
	p := lastPrompt(h)
	if !strings.Contains(p, "Implement the ticket below") || !strings.Contains(p, "put its uncommitted changes back") || !strings.Contains(p, "- refund.go") {
		t.Fatalf("full task with the restored files expected:\n%s", p)
	}
	if !slices.Contains(h.runner.ran, applyDiff) {
		t.Fatal("work not restored")
	}
}
