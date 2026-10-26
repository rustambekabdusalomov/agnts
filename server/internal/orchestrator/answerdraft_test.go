package orchestrator_test

import (
	"errors"
	"strings"
	"testing"

	"agnts/internal/domain"
	"agnts/internal/orchestrator"
)

func TestSaveAnswerDraft(t *testing.T) {
	h := newHarness(t)
	h.ingest("PAY-60")
	h.runner.scripts = []script{{result: ok("s"), files: map[string]string{orchestrator.AnalysisPath: analysis(2)}}}
	h.step()
	tk := h.expect("PAY-60", domain.StateWaitingForAnswers)
	qs, err := h.store.Questions(h.ctx, tk.ID)
	if err != nil || len(qs) != 2 {
		t.Fatalf("questions: %v %v", qs, err)
	}

	if err := h.o.SaveAnswerDraft(h.ctx, "PAY-60", []domain.Answer{{QuestionID: qs[0].ID + 1000, Answer: "x"}}); !errors.Is(err, orchestrator.ErrInvalid) {
		t.Fatalf("another ticket's question: %v", err)
	}
	if err := h.o.SaveAnswerDraft(h.ctx, "PAY-60", []domain.Answer{{QuestionID: qs[0].ID, Note: strings.Repeat("a", 5001)}}); !errors.Is(err, orchestrator.ErrInvalid) {
		t.Fatalf("a note too long: %v", err)
	}

	// Files that are not pending uploads are left out.
	file, err := h.store.SaveAttachment(h.ctx, domain.Attachment{Name: "a.txt", ContentType: "text/plain"}, []byte("hi"))
	if err != nil {
		t.Fatal(err)
	}
	if err := h.o.SaveAnswerDraft(h.ctx, "PAY-60", []domain.Answer{{QuestionID: qs[0].ID, Note: "half", Attachments: []int64{file.ID, file.ID + 1000}}}); err != nil {
		t.Fatal(err)
	}
	qs, _ = h.store.Questions(h.ctx, tk.ID)
	if d := qs[0].Draft; d == nil || d.Note != "half" || len(d.Files) != 1 || d.Files[0].ID != file.ID {
		t.Fatalf("draft: %+v", d)
	}

	// A question answered one by one keeps its answer.
	if _, err := h.o.AnswerOne(h.ctx, "PAY-60", domain.Answer{QuestionID: qs[1].ID, Answer: "half up"}, domain.OriginTelegram); err != nil {
		t.Fatal(err)
	}
	if err := h.o.SaveAnswerDraft(h.ctx, "PAY-60", []domain.Answer{{QuestionID: qs[1].ID, Answer: "banker's"}}); err != nil {
		t.Fatalf("draft of an answered question: %v", err)
	}
	if qs, _ = h.store.Questions(h.ctx, tk.ID); qs[1].Draft != nil || *qs[1].Answer != "half up" {
		t.Fatalf("answered question: %+v", qs[1])
	}

	if _, err := h.o.Answer(h.ctx, "PAY-60", []domain.Answer{{QuestionID: qs[0].ID, Answer: "half up"}}, domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	if err := h.o.SaveAnswerDraft(h.ctx, "PAY-60", []domain.Answer{{QuestionID: qs[0].ID, Answer: "late"}}); !errors.Is(err, domain.ErrConflict) {
		t.Fatalf("draft after answering: %v", err)
	}
}
