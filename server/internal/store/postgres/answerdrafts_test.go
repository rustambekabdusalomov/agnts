package postgres

import (
	"errors"
	"testing"
	"time"

	"agnts/internal/domain"
)

func TestAnswerDrafts(t *testing.T) {
	users, _ := testDB(t)
	ctx, _ := testWS(t, users)
	s := NewAgent(users.db)

	repo, err := s.SaveRepository(ctx, domain.Repository{Name: "api", Kind: "side", Provider: "github", CloneURL: "https://github.com/a/api.git", DefaultBranch: "main"})
	if err != nil {
		t.Fatal(err)
	}
	tk, err := s.CreateTicket(ctx, domain.Ticket{Key: "AD-1", Source: domain.SourceLocal, Kind: domain.KindCode, RepoID: &repo.ID,
		Title: "t", Priority: "medium", State: domain.StateWaitingForAnswers, ResumeState: domain.StateNew, AfterApprove: "pr"},
		domain.Event{TicketKey: "AD-1", Type: domain.EventTicketCreated})
	if err != nil {
		t.Fatal(err)
	}
	if err := s.ReplaceQuestions(ctx, tk.ID, []domain.Question{{Position: 1, Text: "a?"}, {Position: 2, Text: "b?", Options: []string{"x", "y"}}}); err != nil {
		t.Fatal(err)
	}
	qs, err := s.Questions(ctx, tk.ID)
	if err != nil || len(qs) != 2 || qs[0].Draft != nil {
		t.Fatalf("questions before a draft: %+v %v", qs, err)
	}
	file, err := s.SaveAttachment(ctx, domain.Attachment{Name: "a.txt", ContentType: "text/plain"}, []byte("hi"))
	if err != nil {
		t.Fatal(err)
	}

	if err := s.SaveAnswerDraft(ctx, tk.ID, []domain.Answer{{QuestionID: qs[0].ID, Answer: "half", Note: "n", Attachments: []int64{file.ID}}}); err != nil {
		t.Fatal(err)
	}
	if err := s.SaveAnswerDraft(ctx, tk.ID, []domain.Answer{{QuestionID: qs[1].ID, Answer: "y"}}); err != nil {
		t.Fatal(err)
	}
	if err := s.SaveAnswerDraft(ctx, tk.ID+1000, []domain.Answer{{QuestionID: qs[1].ID, Answer: "y"}}); err == nil {
		t.Error("a draft for another ticket's question was saved")
	}
	qs, _ = s.Questions(ctx, tk.ID)
	if d := qs[0].Draft; d == nil || d.Answer != "half" || d.Note != "n" || len(d.Files) != 1 || d.Files[0].Name != "a.txt" || d.At.IsZero() {
		t.Fatalf("first draft: %+v", d)
	}
	if d := qs[1].Draft; d == nil || d.Answer != "y" || len(d.Files) != 0 {
		t.Fatalf("second draft (and the first kept): %+v", d)
	}
	if qs[0].Answer != nil {
		t.Error("a draft counts as an answer")
	}

	// The cleanup keeps a file a draft names.
	if n, err := s.PrunePendingAttachments(domain.System(ctx), time.Now().Add(time.Hour)); err != nil {
		t.Fatal(err)
	} else if as, _ := s.Attachments(ctx, []int64{file.ID}); len(as) != 1 {
		t.Fatalf("pruned a draft's file (%d pruned)", n)
	}

	// Answering clears the draft and links its file.
	if err := s.SaveAnswers(ctx, tk.ID, []domain.Answer{{QuestionID: qs[0].ID, Answer: "half", Attachments: []int64{file.ID}}}); err != nil {
		t.Fatal(err)
	}
	qs, _ = s.Questions(ctx, tk.ID)
	if qs[0].Draft != nil || qs[0].Answer == nil || qs[1].Draft == nil {
		t.Fatalf("after answering: %+v %+v", qs[0], qs[1])
	}
	// A draft that arrives after the answer keeps nothing.
	if err := s.SaveAnswerDraft(ctx, tk.ID, []domain.Answer{{QuestionID: qs[0].ID, Answer: "late"}}); !errors.Is(err, domain.ErrConflict) {
		t.Fatalf("draft of an answered question: %v", err)
	}

	// Once the ticket stops waiting for answers, drafts are refused and
	// their files are left to the cleanup.
	late, err := s.SaveAttachment(ctx, domain.Attachment{Name: "b.txt", ContentType: "text/plain"}, []byte("hi"))
	if err != nil {
		t.Fatal(err)
	}
	if err := s.SaveAnswerDraft(ctx, tk.ID, []domain.Answer{{QuestionID: qs[1].ID, Answer: "y", Attachments: []int64{late.ID}}}); err != nil {
		t.Fatal(err)
	}
	if _, err := s.Transition(ctx, "AD-1", domain.StateRejected, domain.Event{TicketKey: "AD-1", Type: domain.EventStateChanged}, nil); err != nil {
		t.Fatal(err)
	}
	if err := s.SaveAnswerDraft(ctx, tk.ID, []domain.Answer{{QuestionID: qs[1].ID, Answer: "x"}}); !errors.Is(err, domain.ErrConflict) {
		t.Fatalf("draft of a rejected ticket: %v", err)
	}
	if _, err := s.PrunePendingAttachments(domain.System(ctx), time.Now().Add(time.Hour)); err != nil {
		t.Fatal(err)
	}
	if as, _ := s.Attachments(ctx, []int64{late.ID}); len(as) != 0 {
		t.Fatal("kept a rejected ticket's draft file")
	}
}
