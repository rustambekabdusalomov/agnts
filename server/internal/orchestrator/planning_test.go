package orchestrator_test

import (
	"encoding/json"
	"strings"
	"testing"

	"agnts/internal/domain"
	"agnts/internal/orchestrator"
)

// The coding model re-checks the analysis of a complex ticket, in the
// analysis session, and complex work thinks harder.
func TestRecheckComplexAnalysis(t *testing.T) {
	h := newHarness(t)
	h.settings.s.RecheckComplex = true
	h.settings.s.AskFirst = false
	var reqs []orchestrator.ClaudeRequest
	h.runner.onClaude = func(r orchestrator.ClaudeRequest) { reqs = append(reqs, r) }
	rechecked := strings.Replace(complexAnalysis, `"plan":["Add a ledger"]`, `"plan":["Add a ledger","Backfill old refunds"]`, 1)
	h.ingest("PAY-1")
	h.runner.scripts = []script{
		{result: ok("s1"), files: map[string]string{orchestrator.AnalysisPath: complexAnalysis}},
		{result: ok("s1"), files: map[string]string{orchestrator.AnalysisPath: rechecked}},
		{result: ok("s1"), edit: "fix"},
	}
	h.step() // analyze, then re-check
	h.step() // code
	h.expect("PAY-1", domain.StateWaitingForReview)
	if len(reqs) != 3 {
		t.Fatalf("requests: %d", len(reqs))
	}
	an, re, code := reqs[0], reqs[1], reqs[2]
	if an.Model != "sonnet" || an.Effort != "" || re.Model != "opus" || re.Resume != "s1" || re.Effort != "high" || re.MaxTurns != 30 ||
		code.Model != "opus" || code.Effort != "high" {
		t.Fatalf("analyze %s/%q, re-check %s/%q resume %q turns %d, code %s/%q", an.Model, an.Effort, re.Model, re.Effort, re.Resume, re.MaxTurns, code.Model, code.Effort)
	}
	if p := h.runner.prompts[1]; !strings.Contains(p, "You rated this ticket complex") || !strings.Contains(p, orchestrator.AnalysisPath) {
		t.Fatalf("re-check prompt:\n%s", p)
	}
	if v, _ := h.o.View(h.ctx, "PAY-1"); v.Analysis == nil || len(v.Analysis.Plan) != 2 {
		t.Fatalf("kept analysis: %+v", v.Analysis)
	}
	if evs := h.events("PAY-1", domain.EventAnalysisChecked); len(evs) != 1 || !strings.Contains(evs[0].Message, "opus re-checked") ||
		!strings.Contains(evs[0].Message, "changed the plan") {
		t.Fatalf("events: %+v", evs)
	}

	// A simple ticket is not re-checked and thinks at the default effort.
	reqs = nil
	h.ingest("PAY-2")
	h.runner.scripts = []script{
		{result: ok("s2"), files: map[string]string{orchestrator.AnalysisPath: analysis(0)}},
		{result: ok("s2"), edit: "fix"},
	}
	h.step()
	h.step()
	if len(reqs) != 2 || reqs[1].Effort != "" {
		t.Fatalf("simple ticket: %d requests, coding effort %q", len(reqs), reqs[len(reqs)-1].Effort)
	}
}

// Files the analysis says to copy or reuse must exist: the analysis is
// asked once to fix them, and what is still missing is dropped.
func TestAnalysisPathsMustExist(t *testing.T) {
	h := newHarness(t)
	var a map[string]any
	_ = json.Unmarshal([]byte(analysis(0)), &a)
	a["patterns"] = []any{map[string]any{"file": "refund.go", "like": "pay/charge.go"}, map[string]any{"file": "money.go", "like": "nope/ghost.go"}}
	a["reuse"] = []any{map[string]any{"name": "money.Round", "where": "money/round.go"}}
	b, _ := json.Marshal(a)
	check := `for f in 'pay/charge.go' 'nope/ghost.go' 'money/round.go'; do [ -e "$f" ] || printf '%s\n' "$f"; done`
	h.runner.execs[check] = []orchestrator.ExecResult{{Output: "nope/ghost.go\n"}, {Output: "nope/ghost.go\n"}}
	h.ingest("PAY-1")
	h.runner.scripts = []script{
		{result: ok("s1"), files: map[string]string{orchestrator.AnalysisPath: string(b)}},
		{result: ok("s1"), files: map[string]string{orchestrator.AnalysisPath: string(b)}}, // "fixed" nothing
		{result: ok("s1"), edit: "fix"},
	}
	h.step() // analyze, then fix the paths
	if p := h.runner.prompts[1]; !strings.Contains(p, "These files in your analysis do not exist") || !strings.Contains(p, "- nope/ghost.go") {
		t.Fatalf("fix prompt:\n%s", p)
	}
	v, _ := h.o.View(h.ctx, "PAY-1")
	if len(v.Analysis.Patterns) != 1 || v.Analysis.Patterns[0].Like != "pay/charge.go" || len(v.Analysis.Reuse) != 1 {
		t.Fatalf("patterns after the check: %+v %+v", v.Analysis.Patterns, v.Analysis.Reuse)
	}
	if evs := h.events("PAY-1", domain.EventAnalysisChecked); len(evs) != 1 || !strings.Contains(evs[0].Message, "dropped: nope/ghost.go") {
		t.Fatalf("events: %+v", evs)
	}
}

// The coder is told what done means (criteria, tests, edge cases) and says
// how it met each criterion; the reviewer sees all of it.
func TestDoneWhenReachesCoderAndReviewer(t *testing.T) {
	h, _ := newReviewHarness(t)
	var a map[string]any
	_ = json.Unmarshal([]byte(analysis(0)), &a)
	a["acceptance"] = []any{map[string]any{"id": "a1", "criterion": "Refunds of 0.005 round to 0.01", "check": "test"}}
	a["testPlan"] = []any{map[string]any{"file": "/workspace/refund_test.go", "what": "half-cent refunds round up"}}
	a["edgeCases"] = []string{"a zero refund stays zero", " "}
	a["footprint"] = map[string]any{"files": []string{"refund.go"}}
	b, _ := json.Marshal(a)
	h.ingest("PAY-1")
	h.runner.scripts = []script{
		{result: ok("s1"), files: map[string]string{orchestrator.AnalysisPath: string(b)}},
		{result: ok("s1"), edit: "fix", files: map[string]string{orchestrator.SummaryPath: `{"summary":"Rounds half up.","criteria":[{"id":"a1","met":true,"how":"TestRefundHalfCent"}]}`}},
	}
	h.step() // analyze
	h.step() // code
	code := h.runner.prompts[1]
	for _, want := range []string{"## Done when", "- a1: Refunds of 0.005 round to 0.01", "- refund_test.go: half-cent refunds round up",
		"- a zero refund stays zero", "Tests for the behaviour you add or change are part of the work", `"criteria": [{"id": "a1"`,
		"## Checklists", orchestrator.ChecklistDir + "/go.md", "do not run the whole suite again and again"} {
		if !strings.Contains(code, want) {
			t.Fatalf("coding prompt lacks %q:\n%s", want, code)
		}
	}
	h.runner.scripts = []script{reviewScript("r1", codeReviewJSON("looks_good"))}
	h.step() // review
	rv := h.runner.prompts[len(h.runner.prompts)-1]
	for _, want := range []string{"Acceptance criteria:", "- criterion a1: met: TestRefundHalfCent", "Tests the plan asked for:",
		"Edge cases the plan asked to handle:", "a missing test for new behaviour is major"} {
		if !strings.Contains(rv, want) {
			t.Fatalf("review prompt lacks %q:\n%s", want, rv)
		}
	}
}

// A prompt too long for the command line goes into a file the run reads.
func TestLongPromptGoesToAFile(t *testing.T) {
	h := newHarness(t)
	h.ingest("PAY-1")
	tk := h.state("PAY-1")
	tk.Description = strings.Repeat("Refunds must round half up. ", 5000) // ~140 KB
	if _, err := h.store.UpdateTicket(h.ctx, "PAY-1", nil, func(x *domain.Ticket) { x.Description = tk.Description }); err != nil {
		t.Fatal(err)
	}
	h.runner.scripts = []script{{result: ok("s1"), files: map[string]string{orchestrator.AnalysisPath: analysis(0)}}}
	h.step()
	if p := h.runner.prompts[0]; len(p) > 1000 || !strings.Contains(p, orchestrator.PromptPath) {
		t.Fatalf("prompt (%d bytes): %.200s", len(p), p)
	}
	if w := h.runner.written[orchestrator.PromptPath]; !strings.Contains(w, "Refunds must round half up.") || !strings.Contains(w, "## Kind of work") {
		t.Fatalf("prompt file: %.200s", w)
	}
}
