package orchestrator_test

import (
	"errors"
	"strings"
	"testing"

	"agnts/internal/orchestrator"
)

func TestTranslateStoresEachTextOnce(t *testing.T) {
	h := newHarness(t)
	h.ingest("PAY-1")

	// Texts go in page order: the title, then the description.
	h.runner.scripts = []script{{result: ok("t1"), files: map[string]string{
		orchestrator.TranslationPath: `{"texts": [{"id": 0, "text": "Исправить округление возврата"}, {"id": 1, "text": "Округлять половину вверх."}]}`,
	}}}
	got, err := h.o.Translate(h.ctx, "PAY-1", "ru")
	if err != nil {
		t.Fatal(err)
	}
	if len(got) != 2 || got[0].Source != "Fix refund rounding" || got[0].Text != "Исправить округление возврата" || got[1].Text != "Округлять половину вверх." {
		t.Fatalf("translation = %+v", got)
	}
	if p := h.runner.prompts[0]; !strings.Contains(p, "into Russian") || !strings.Contains(p, orchestrator.SourcePath) {
		t.Fatalf("prompt = %q", p)
	}

	// Asked again, the store answers: no script is left, so a Claude call fails.
	again, err := h.o.Translate(h.ctx, "PAY-1", "ru")
	if err != nil || len(again) != 2 || again[1].Text != "Округлять половину вверх." {
		t.Fatalf("second translation = %+v, %v", again, err)
	}
	if len(h.runner.prompts) != 1 {
		t.Fatalf("claude ran %d times, want 1", len(h.runner.prompts))
	}
}

func TestTranslateRejectsUnknownLanguageAndWaitsOutPlanLimit(t *testing.T) {
	h := newHarness(t)
	h.ingest("PAY-1")
	if _, err := h.o.Translate(h.ctx, "PAY-1", "xx"); !errors.Is(err, orchestrator.ErrInvalid) {
		t.Fatalf("unknown language: %v", err)
	}
	h.usage.paused = true
	if _, err := h.o.Translate(h.ctx, "PAY-1", "de"); !errors.Is(err, orchestrator.ErrPlanLimit) {
		t.Fatalf("paused: %v", err)
	}
}
