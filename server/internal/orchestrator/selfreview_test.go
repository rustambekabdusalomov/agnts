package orchestrator_test

import (
	"encoding/json"
	"strings"
	"testing"

	"agnts/internal/domain"
	"agnts/internal/orchestrator"
)

// newSelfReviewHarness has auto review and self-review on.
func newSelfReviewHarness(t *testing.T) *harness {
	t.Helper()
	h, _ := newReviewHarness(t)
	h.settings.s.SelfReview = true
	return h
}

func (h *harness) events(key, typ string) []domain.Event {
	h.t.Helper()
	evs, err := h.store.Events(h.ctx, orchestrator.EventFilter{TicketKey: key})
	if err != nil {
		h.t.Fatal(err)
	}
	var out []domain.Event
	for _, e := range evs {
		if e.Type == typ {
			out = append(out, e)
		}
	}
	return out
}

func majorFinding() map[string]any {
	return map[string]any{"severity": "major", "category": "architecture", "file": "httpapi/refund.go", "line": 40,
		"title": "SQL in the handler", "detail": "The handler queries the database directly.", "suggestion": "Move it to the store."}
}

func TestSelfReviewSendsSeriousFindingsBackOnce(t *testing.T) {
	h := newSelfReviewHarness(t)
	h.toReview("PAY-1", withComplexity("simple"))
	tk := h.state("PAY-1")
	if !tk.QuietReview || tk.ReviewState != domain.ReviewPending {
		t.Fatalf("after coding: quiet=%v review=%q", tk.QuietReview, tk.ReviewState)
	}
	sc := h.events("PAY-1", domain.EventStateChanged)
	if last := sc[len(sc)-1]; last.Data["quiet"] != true || !strings.Contains(last.Message, "agnts reviews the change before you do") {
		t.Fatalf("arrival event: %+v", last)
	}

	// A major finding goes back to the coder, before anyone is told.
	h.runner.scripts = []script{reviewScript("r1", codeReviewJSON("needs_changes", majorFinding(),
		map[string]any{"severity": "minor", "category": "tests", "title": "Name the test better"}))}
	h.step() // review
	tk = h.expect("PAY-1", domain.StateCoding)
	if tk.SelfFixes != 1 || tk.Revision != 1 || tk.QuietReview || !strings.Contains(tk.Feedback, "1. [major, architecture] SQL in the handler (httpapi/refund.go:40)") ||
		!strings.Contains(tk.Feedback, "Suggestion: Move it to the store.") || strings.Contains(tk.Feedback, "Name the test better") {
		t.Fatalf("after the self-review: %+v", tk)
	}
	fb := h.events("PAY-1", domain.EventFeedback)
	if len(fb) != 1 || fb[0].Origin != domain.OriginSystem || fb[0].Data["self"] != true {
		t.Fatalf("feedback event: %+v", fb)
	}
	if len(h.events("PAY-1", domain.EventReadyForReview)) != 0 {
		t.Fatal("announced although it went back to the coder")
	}

	// The fix arrives loudly: agnts's review had its round.
	h.runner.scripts = []script{{result: ok("s-PAY-1"), edit: "fix again"}}
	h.step() // code (feedback)
	tk = h.expect("PAY-1", domain.StateWaitingForReview)
	if tk.QuietReview || !strings.Contains(h.runner.prompts[len(h.runner.prompts)-1], "SQL in the handler") {
		t.Fatalf("after the fix: quiet=%v prompt:\n%s", tk.QuietReview, h.runner.prompts[len(h.runner.prompts)-1])
	}
	h.runner.scripts = []script{reviewScript("r2", codeReviewJSON("needs_changes", majorFinding()))}
	h.step() // review again: findings stay for the person
	tk = h.expect("PAY-1", domain.StateWaitingForReview)
	if tk.SelfFixes != 1 || tk.ReviewState != domain.ReviewDone {
		t.Fatalf("second review: %+v", tk)
	}

	// A person's change request gives agnts's review a new round.
	if _, err := h.o.RequestChanges(h.ctx, "PAY-1", "Use the money type.", nil, nil, domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	if tk = h.state("PAY-1"); tk.SelfFixes != 0 {
		t.Fatalf("self fixes after a person's change request: %d", tk.SelfFixes)
	}
}

func TestSelfReviewAnnouncesWhenClean(t *testing.T) {
	h := newSelfReviewHarness(t)
	h.toReview("PAY-1", withComplexity("simple"))
	h.runner.scripts = []script{reviewScript("r1", codeReviewJSON("looks_good",
		map[string]any{"severity": "minor", "category": "tests", "title": "Name the test better"}))}
	h.step() // review
	tk := h.expect("PAY-1", domain.StateWaitingForReview)
	ready := h.events("PAY-1", domain.EventReadyForReview)
	if tk.QuietReview || len(ready) != 1 || ready[0].Data["to"] != string(domain.StateWaitingForReview) || !strings.Contains(ready[0].Message, "looks good") {
		t.Fatalf("announcement: quiet=%v events=%+v", tk.QuietReview, ready)
	}
	// A failed review run announces too; a second announcement never comes.
	if _, err := h.o.Review(h.ctx, "PAY-1", domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	h.runner.scripts = []script{{result: ok("r2")}} // writes no review
	h.step()
	if n := len(h.events("PAY-1", domain.EventReadyForReview)); n != 1 {
		t.Fatalf("announcements: %d", n)
	}
}

func TestReviewPromptGetsRedFlagsAndDesign(t *testing.T) {
	h := newSelfReviewHarness(t)
	h.git.files = []domain.FileChange{
		{Path: "main.go", Add: 3, Del: 1, Diff: "@@ -1,2 +1,4 @@\n package main\n+//nolint:errcheck\n+func f() {}\n"},
		{Path: "extra.go", Add: 1, Diff: "@@ -0,0 +1 @@\n+package main\n"},
	}
	var a map[string]any
	_ = json.Unmarshal([]byte(designAnalysis()), &a)
	a["complexity"], a["footprint"] = "simple", map[string]any{"files": []string{"main.go"}}
	b, _ := json.Marshal(a)
	h.toReview("PAY-1", string(b))
	evs := h.events("PAY-1", domain.EventRedFlags)
	if len(evs) != 1 || evs[0].Data["count"] != float64(1) {
		t.Fatalf("red flag events: %+v", evs)
	}
	v, _ := h.o.View(h.ctx, "PAY-1")
	if len(v.Result.RedFlags) != 1 || v.Result.RedFlags[0].Kind != domain.FlagSilencedLint || v.Result.RedFlags[0].Line != 2 {
		t.Fatalf("stored red flags: %+v", v.Result.RedFlags)
	}

	h.runner.scripts = []script{reviewScript("r1", codeReviewJSON("looks_good"))}
	h.step()
	p := h.runner.prompts[len(h.runner.prompts)-1]
	for _, want := range []string{"## Decisions from the analysis", "Chosen approach: **Money type**", "Out of scope: Rewriting the currency table",
		"not among the files the analysis expected to change: extra.go", "- main.go:2 [silenced_lint] //nolint:errcheck",
		`(category "architecture")`, `(category "scope")`, "architecture, scope, maintainability"} {
		if !strings.Contains(p, want) {
			t.Fatalf("review prompt lacks %q:\n%s", want, p)
		}
	}
}

func TestDriftCheckpoint(t *testing.T) {
	h := newHarness(t)
	var a map[string]any
	_ = json.Unmarshal([]byte(analysis(0)), &a)
	a["footprint"] = map[string]any{"files": []string{"refund.go"}}
	a["approaches"] = []any{map[string]any{"title": "Round in refund.go", "sketch": "Use math.Round."}}
	b, _ := json.Marshal(a)
	var budgets []int
	h.runner.onClaude = func(r orchestrator.ClaudeRequest) { budgets = append(budgets, r.MaxTurns) }
	h.runner.execs["git status --porcelain --untracked-files=all"] = []orchestrator.ExecResult{{Output: " M refund.go\n?? util/helpers.go\nR  a.go -> b.go\n"}}
	h.ingest("PAY-1")
	h.runner.scripts = []script{
		{result: ok("s1"), files: map[string]string{orchestrator.AnalysisPath: string(b)}},
		{result: orchestrator.ClaudeResult{SessionID: "s1", Turns: 50, Subtype: "error_max_turns", IsError: true}, edit: "half"},
		{result: ok("s1"), edit: "rest"},
	}
	h.step() // analyze
	h.step() // code, with the checkpoint
	tk := h.expect("PAY-1", domain.StateWaitingForReview)
	if len(budgets) != 3 || budgets[1] != 50 || budgets[2] != 100 {
		t.Fatalf("turn budgets: %v", budgets)
	}
	if h.runner.resumes[2] != "s1" {
		t.Fatalf("checkpoint did not resume the session: %q", h.runner.resumes)
	}
	p := h.runner.prompts[2]
	for _, want := range []string{"Checkpoint", "- util/helpers.go", "- b.go", "not among the files the analysis expected to change: util/helpers.go, b.go",
		"The chosen approach: **Round in refund.go**"} {
		if !strings.Contains(p, want) {
			t.Fatalf("checkpoint prompt lacks %q:\n%s", want, p)
		}
	}
	cp := h.events("PAY-1", domain.EventCheckpoint)
	if len(cp) != 1 || !strings.Contains(cp[0].Message, "3 files changed, 2 outside the plan") {
		t.Fatalf("checkpoint event: %+v", cp)
	}
	if tk.Turns != 55 {
		t.Fatalf("turns: %d", tk.Turns)
	}
}
