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

func TestTranslateTextsBatchesAndStores(t *testing.T) {
	h := newHarness(t)
	big := strings.Repeat("a", 30<<10)
	texts := []string{"# Plan", big, big + "b"}

	// Over 40 KB the texts go in two calls in one container: the title
	// and the first long text, then the second.
	h.runner.scripts = []script{
		{result: ok("t1"), files: map[string]string{orchestrator.TranslationPath: `{"texts": [{"id": 0, "text": "# Reja"}, {"id": 1, "text": "A"}]}`}},
		{result: ok("t2"), files: map[string]string{orchestrator.TranslationPath: `{"texts": [{"id": 0, "text": "B"}]}`}},
	}
	got, err := h.o.TranslateTexts(h.ctx, "document-7", "uz", texts)
	if err != nil {
		t.Fatal(err)
	}
	if len(got) != 3 || got["# Plan"] != "# Reja" || got[big] != "A" || got[big+"b"] != "B" {
		t.Fatalf("translation = %v", got)
	}
	if len(h.runner.prompts) != 2 || h.runner.opened != 1 {
		t.Fatalf("claude ran %d times in %d containers, want 2 in 1", len(h.runner.prompts), h.runner.opened)
	}

	// A changed text is the only one sent again.
	h.runner.scripts = []script{{result: ok("t3"), files: map[string]string{orchestrator.TranslationPath: `{"texts": [{"id": 0, "text": "Yangi"}]}`}}}
	got, err = h.o.TranslateTexts(h.ctx, "document-7", "uz", []string{"# Plan", "New"})
	if err != nil || got["New"] != "Yangi" || got["# Plan"] != "# Reja" {
		t.Fatalf("second translation = %v, %v", got, err)
	}
	if w := h.runner.written[orchestrator.SourcePath]; strings.Contains(w, "Plan") {
		t.Fatalf("sent again: %s", w)
	}
}

func TestTranslateTextsFailsWhenAnswerIsMissing(t *testing.T) {
	h := newHarness(t)
	h.runner.scripts = []script{{result: ok("t1")}}
	if _, err := h.o.TranslateTexts(h.ctx, "document-7", "ru", []string{"Hello"}); err == nil || !strings.Contains(err.Error(), "did not write") {
		t.Fatalf("err = %v", err)
	}
	if _, err := h.o.TranslateTexts(h.ctx, "document-7", "xx", []string{"Hello"}); !errors.Is(err, orchestrator.ErrInvalid) {
		t.Fatalf("unknown language: %v", err)
	}
}
