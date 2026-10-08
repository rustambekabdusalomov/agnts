package orchestrator_test

import (
	"encoding/json"
	"strings"
	"testing"

	"agnts/internal/domain"
	"agnts/internal/orchestrator"
)

// designAnalysis is a complex analysis with two approaches, the second
// chosen, scope and ship notes; extra questions are added as given.
func designAnalysis(questions ...map[string]any) string {
	qs := []any{}
	for _, q := range questions {
		qs = append(qs, q)
	}
	b, _ := json.Marshal(map[string]any{
		"summary": "Refunds round in refund.go.", "plan": []string{"Add a rounding helper", "Use it in refund.go"},
		"complexity": "complex", "questions": qs,
		"approaches": []any{
			map[string]any{"title": "Round in the handler", "sketch": "Round where the request is parsed.", "why": "Other callers would still truncate."},
			map[string]any{"title": "  Money type  ", "sketch": "Round inside the money package.", "pros": []string{"one place"}, "chosen": true, "why": "Every caller gets it."},
			map[string]any{"title": " ", "sketch": "dropped: no title"},
		},
		"outOfScope": []string{"Rewriting the currency table", " "},
		"ship":       map[string]any{"migrations": "", "compatibility": "Stored amounts stay as they are.", "rollout": " "},
	})
	return string(b)
}

func TestDesignApproachQuestionAndCodingPrompt(t *testing.T) {
	h := newHarness(t)
	h.ingest("PAY-1")
	h.runner.scripts = []script{{result: ok("s1"), files: map[string]string{orchestrator.AnalysisPath: designAnalysis(
		map[string]any{"text": "Keep cents?", "options": []string{"yes", "no"}},
	)}}}
	h.step() // analyze
	h.expect("PAY-1", domain.StateWaitingForAnswers)
	p := h.runner.prompts[0]
	if !strings.Contains(p, "## Design") || !strings.Contains(p, `"approaches"`) || !strings.Contains(p, "add a question asking which one to take") {
		t.Fatalf("analysis prompt without the design step:\n%s", p)
	}

	v, err := h.o.View(h.ctx, "PAY-1")
	if err != nil {
		t.Fatal(err)
	}
	if len(v.Questions) != 2 || v.Questions[0].Position != 1 || v.Questions[1].Text != "Keep cents?" {
		t.Fatalf("questions: %+v", v.Questions)
	}
	if got := v.Questions[0].Options; len(got) != 2 || got[0] != "Money type" || got[1] != "Round in the handler" {
		t.Fatalf("approach question options: %q", got)
	}
	a := v.Analysis
	if len(a.Approaches) != 2 || a.Chosen().Title != "Money type" || len(a.OutOfScope) != 1 || a.ShipPlan() == nil || a.Ship.Rollout != "" {
		t.Fatalf("normalized design: %+v", a)
	}
	if c := h.tracker.comments; len(c) == 0 || !strings.Contains(c[len(c)-1], "Approach: Money type.") {
		t.Fatalf("tracker comment: %q", c)
	}

	if _, err := h.o.Answer(h.ctx, "PAY-1", h.answers("PAY-1"), domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	h.runner.scripts = []script{{result: ok("s1"), edit: "fix", files: map[string]string{
		orchestrator.SummaryPath: `{"summary":"Rounds in money.","notes":[],"deviations":["Kept the handler check too"]}`,
	}}}
	h.step() // code
	p = h.runner.prompts[1]
	for _, want := range []string{"## Approach", "**Money type**: Round inside the money package.", "unless the author's answers below pick another",
		"Rejected:", "- Round in the handler: Other callers would still truncate.", "## Out of scope", "- Rewriting the currency table",
		"## Shipping", "- Compatibility: Stored amounts stay as they are.", `"deviations"`} {
		if !strings.Contains(p, want) {
			t.Fatalf("coding prompt lacks %q:\n%s", want, p)
		}
	}
	if strings.Contains(p, "- Migrations:") || strings.Contains(p, "- Rollout:") {
		t.Fatalf("empty ship notes reached the prompt:\n%s", p)
	}
}

func TestDesignQuestionNotRepeatedOrForSimpleWork(t *testing.T) {
	h := newHarness(t)
	h.ingest("PAY-1")
	// Claude asked about the approach itself (any case): no second question.
	h.runner.scripts = []script{{result: ok("s1"), files: map[string]string{orchestrator.AnalysisPath: designAnalysis(
		map[string]any{"text": "Qaysi yo'l?", "options": []string{"money type", "Round in the handler"}},
	)}}}
	h.step()
	v, _ := h.o.View(h.ctx, "PAY-1")
	if len(v.Questions) != 1 || v.Questions[0].Text != "Qaysi yo'l?" {
		t.Fatalf("questions: %+v", v.Questions)
	}

	// A simple ticket with one approach and no questions goes straight to coding.
	h.ingest("PAY-2")
	h.runner.scripts = []script{{result: ok("s2"), files: map[string]string{orchestrator.AnalysisPath: `{"summary":"s","plan":["p"],"complexity":"simple","approaches":[{"title":"Just fix it","sketch":"one line"}]}`}}}
	h.step()
	h.expect("PAY-2", domain.StateCoding)
}
