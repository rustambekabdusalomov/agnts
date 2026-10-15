package postgres

import (
	"errors"
	"testing"
	"time"

	"agnts/internal/domain"
)

func TestReviewDrafts(t *testing.T) {
	users, _ := testDB(t)
	ctx, _ := testWS(t, users)
	other, _ := testWS(t, users)
	s := NewAgent(users.db)

	repo, err := s.SaveRepository(ctx, domain.Repository{Name: "api", Kind: "side", Provider: "github", CloneURL: "https://github.com/a/api.git", DefaultBranch: "main"})
	if err != nil {
		t.Fatal(err)
	}
	n := 4
	tk, err := s.CreateTicket(ctx, domain.Ticket{Key: "API-PR4", Source: domain.SourceGit, Kind: domain.KindReview, RepoID: &repo.ID, Title: "x",
		Priority: "medium", State: domain.StateNew, ResumeState: domain.StateNew, AfterApprove: domain.AfterApproveNone, PRNumber: &n},
		domain.Event{TicketKey: "API-PR4", Type: domain.EventTicketCreated})
	if err != nil || tk.AfterApprove != domain.AfterApproveNone {
		t.Fatalf("a review that never merges: %+v %v", tk.AfterApprove, err)
	}
	mk := func(kind, key, state string) domain.ReviewDraft {
		return domain.ReviewDraft{TicketID: tk.ID, RepoID: repo.ID, Number: 4, Kind: kind, Key: key, Body: key, State: state, Path: "a.go", Line: 3, HeadSHA: "h", Confidence: 0.9}
	}
	err = s.SyncReviewDrafts(ctx, tk.ID, func(cur []domain.ReviewDraft) []domain.ReviewDraft {
		if len(cur) != 0 {
			t.Fatalf("drafts before any: %+v", cur)
		}
		return []domain.ReviewDraft{mk(domain.DraftSummary, domain.DraftSummary, domain.DraftOpen), mk(domain.DraftFinding, "k1", domain.DraftAccepted),
			mk(domain.DraftFinding, "k2", domain.DraftAccepted)}
	})
	if err != nil {
		t.Fatal(err)
	}
	ds, err := s.ReviewDrafts(ctx, tk.ID)
	if err != nil || len(ds) != 3 || ds[0].Kind != domain.DraftSummary || ds[1].Confidence < 0.89 {
		t.Fatalf("drafts: %+v %v", ds, err)
	}
	if _, err := s.AddReviewDraft(ctx, mk(domain.DraftFinding, "k1", domain.DraftOpen)); !errors.Is(err, domain.ErrConflict) {
		t.Fatalf("a second draft for one finding: %v", err)
	}
	if ds, _ := s.ReviewDrafts(other, tk.ID); len(ds) != 0 {
		t.Fatalf("another workspace sees the drafts: %+v", ds)
	}

	// Claiming takes each accepted draft once.
	claimed, err := s.ClaimReviewDrafts(ctx, tk.ID, time.Now().Add(-time.Hour))
	if err != nil || len(claimed) != 2 || claimed[0].State != domain.DraftPublishing {
		t.Fatalf("claim: %+v %v", claimed, err)
	}
	if again, _ := s.ClaimReviewDrafts(ctx, tk.ID, time.Now().Add(-time.Hour)); len(again) != 0 {
		t.Fatalf("claimed twice: %+v", again)
	}
	post, err := s.AddPRPost(ctx, domain.PRPost{RepoID: repo.ID, Number: 4, CommentID: "rc:1", Kind: domain.PostFinding, FindingKey: "k1"})
	if err != nil {
		t.Fatal(err)
	}
	if err := s.FinishReviewDraft(ctx, claimed[0].ID, true, &post.ID, ""); err != nil {
		t.Fatal(err)
	}
	if d, _ := s.ReviewDraft(ctx, tk.ID, claimed[0].ID); d.State != domain.DraftPublished || d.PostID == nil || *d.PostID != post.ID {
		t.Fatalf("published: %+v", d)
	}
	// A claim left behind by a crash is taken again once it is stale.
	if again, _ := s.ClaimReviewDrafts(ctx, tk.ID, time.Now().Add(time.Minute)); len(again) != 1 || again[0].Key != "k2" {
		t.Fatalf("stale claim: %+v", again)
	}
	if err := s.FinishReviewDraft(ctx, claimed[1].ID, false, nil, "refused"); err != nil {
		t.Fatal(err)
	}
	if d, _ := s.ReviewDraft(ctx, tk.ID, claimed[1].ID); d.State != domain.DraftAccepted || d.Error != "refused" {
		t.Fatalf("failed: %+v", d)
	}

	d, err := s.UpdateReviewDraft(ctx, tk.ID, ds[0].ID, func(d *domain.ReviewDraft) error {
		d.Body, d.Edited = "mine", true
		return nil
	})
	if err != nil || d.Body != "mine" || !d.Edited {
		t.Fatalf("update: %+v %v", d, err)
	}
	if err := s.DeleteReviewDraft(ctx, tk.ID, ds[0].ID); err != nil {
		t.Fatal(err)
	}
	if err := s.DeleteReviewDraft(ctx, tk.ID, ds[0].ID); !errors.Is(err, domain.ErrNotFound) {
		t.Fatalf("delete twice: %v", err)
	}
}
