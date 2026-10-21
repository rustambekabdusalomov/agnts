package orchestrator_test

import (
	"strings"
	"testing"

	"agnts/internal/domain"
	"agnts/internal/orchestrator"
)

func TestBusinessContextNotes(t *testing.T) {
	h := newRulesHarness(t)
	note, err := h.o.CreateRule(h.ctx, orchestrator.RuleInput{Title: "Refunds", Body: "A payment is refunded at most once; amounts are in tiyin.",
		Enabled: true, Kind: domain.KindContext}, domain.OriginWeb)
	if err != nil || note.Kind != domain.KindContext {
		t.Fatalf("create note: %+v %v", note, err)
	}
	if _, err := h.o.CreateRule(h.ctx, orchestrator.RuleInput{Title: "x", Body: "y", Kind: "other"}, domain.OriginWeb); err == nil {
		t.Fatal("unknown kind accepted")
	}
	h.runner.scripts = []script{{result: ok("r1"), files: map[string]string{orchestrator.RulePath: reviewJSON("A payment is refunded at most once. Amounts are integers in tiyin.")}}}
	h.step() // the note's review
	if p := h.runner.prompts[0]; !strings.Contains(p, "business context note") || !strings.Contains(p, "## The note") {
		t.Fatalf("note review prompt:\n%s", p)
	}

	h.ingest("PAY-1")
	h.runner.scripts = []script{{result: ok("s1"), files: map[string]string{orchestrator.AnalysisPath: analysis(0)}}}
	h.step()
	p := h.runner.prompts[1]
	if !strings.Contains(p, orchestrator.BusinessPath) || strings.Contains(p, "## Team rules") {
		t.Fatalf("analysis prompt: the note must be a context file, not a rule:\n%s", p)
	}
	if got := h.runner.written[orchestrator.BusinessPath]; !strings.Contains(got, "## Refunds (every repository)") || !strings.Contains(got, "integers in tiyin") {
		t.Fatalf("business.md:\n%s", got)
	}

	// Turning it into a rule reviews it again.
	r, err := h.o.UpdateRule(h.ctx, note.ID, orchestrator.RuleInput{Title: note.Title, Body: note.Body, Enabled: true, Kind: domain.KindInstruction}, domain.OriginWeb)
	if err != nil || r.Kind != domain.KindInstruction || r.Status != domain.RulePending {
		t.Fatalf("change kind: %+v %v", r, err)
	}
}

func TestPrecedents(t *testing.T) {
	h := newHarness(t)
	h.git.files = []domain.FileChange{{Path: "refund/refund.go", Add: 3, Del: 1, Diff: "+x"}, {Path: "refund/refund_test.go", Add: 9, Diff: "+y"}}
	h.ingest("PAY-1")
	h.runner.scripts = []script{
		{result: ok("s1"), files: map[string]string{orchestrator.AnalysisPath: analysis(0)}},
		{result: ok("s1"), edit: "fix"},
		{result: ok("s1"), edit: "fix 2", files: map[string]string{orchestrator.SummaryPath: `{"summary":"Round refunds half up in refund.go."}`}},
	}
	h.step()
	h.step()
	if _, err := h.o.RequestChanges(h.ctx, "PAY-1", "Use the money package, not float64.", nil, nil, domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	h.step()
	if _, err := h.o.Approve(h.ctx, "PAY-1", nil, false, domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	h.step() // push
	h.expect("PAY-1", domain.StateDone)
	// Only merged work is a precedent.
	if _, err := h.o.MarkMergedByHand(h.ctx, "PAY-1", domain.OriginWeb); err != nil {
		t.Fatal(err)
	}

	// PAY-3 touched the same file and was rejected: what not to do.
	h.ingest("PAY-3")
	h.runner.scripts = []script{
		{result: ok("s3"), files: map[string]string{orchestrator.AnalysisPath: analysis(0)}},
		{result: ok("s3"), edit: "fix 3"},
	}
	h.step()
	h.step()
	if _, err := h.o.Reject(h.ctx, "PAY-3", "It rewrote the rounding in the handler instead of the money package.", domain.OriginWeb); err != nil {
		t.Fatal(err)
	}

	// PAY-2 is about refunds too: its runs get PAY-1 as a precedent.
	h.ingest("PAY-2")
	h.runner.scripts = []script{{result: ok("s2"), files: map[string]string{orchestrator.AnalysisPath: `{"summary":"s","plan":["p"],"footprint":{"files":["refund/refund.go"]}}`}}}
	h.step()
	if p := h.runner.prompts[len(h.runner.prompts)-1]; !strings.Contains(p, orchestrator.PrecedentsPath) {
		t.Fatalf("analysis prompt without precedents:\n%s", p)
	}
	got := h.runner.written[orchestrator.PrecedentsPath]
	for _, want := range []string{"## PAY-1: Fix refund rounding", "What changed: Round refunds half up in refund.go.",
		"Files: refund/refund.go, refund/refund_test.go", "A reviewer asked: Use the money package, not float64.",
		"From agnts's change:", "--- refund/refund.go\n+x", "# Rejected: what not to do", "## PAY-3:",
		"Why it was rejected: It rewrote the rounding in the handler instead of the money package."} {
		if !strings.Contains(got, want) {
			t.Fatalf("precedents.md lacks %q:\n%s", want, got)
		}
	}
}
