package postgres

import (
	"errors"
	"testing"

	"agnts/internal/domain"
)

func TestPullReviewTicketsNotesAndProfiles(t *testing.T) {
	users, _ := testDB(t)
	ctx, _ := testWS(t, users)
	other, _ := testWS(t, users)
	s := NewAgent(users.db)

	repo, err := s.SaveRepository(ctx, domain.Repository{Name: "api", Kind: "side", Provider: "github", CloneURL: "https://github.com/a/api.git", DefaultBranch: "main"})
	if err != nil {
		t.Fatal(err)
	}
	n := 42
	pr := domain.PullRequest{Number: 42, URL: "https://github.com/a/api/pull/42", Title: "Add caching", Author: "bob",
		HeadRef: "cache", HeadSHA: "abc", BaseRef: "main", FetchRef: "refs/pull/42/head", State: domain.PullOpen, Login: "me", Why: domain.PullAssigned}
	created, err := s.CreateTicket(ctx, domain.Ticket{Key: "API-PR42", Source: domain.SourceGit, Kind: domain.KindReview, RepoID: &repo.ID,
		Title: pr.Title, Priority: "medium", State: domain.StateNew, ResumeState: domain.StateNew, AfterApprove: "pr",
		Branch: "agnts/API-PR42", PRNumber: &n, PRURL: pr.URL, Pull: &pr}, domain.Event{TicketKey: "API-PR42", Type: domain.EventTicketCreated})
	if err != nil {
		t.Fatal(err)
	}
	if created.Pull == nil || *created.Pull != pr || created.Branch != "agnts/API-PR42" || created.PRURL != pr.URL || created.Source != domain.SourceGit {
		t.Fatalf("created: %+v pull %+v", created, created.Pull)
	}
	got, err := s.TicketByPull(ctx, repo.ID, 42)
	if err != nil || got.Key != "API-PR42" {
		t.Fatalf("by pull: %+v %v", got.Key, err)
	}
	if _, err := s.TicketByPull(other, repo.ID, 42); !errors.Is(err, domain.ErrNotFound) {
		t.Fatalf("another workspace sees the review: %v", err)
	}
	updated, err := s.UpdateTicket(ctx, "API-PR42", nil, func(x *domain.Ticket) { x.Pull.HeadSHA = "def" })
	if err != nil || updated.Pull.HeadSHA != "def" {
		t.Fatalf("update pull: %+v %v", updated.Pull, err)
	}
	if open, err := s.OpenReviews(ctx); err != nil || len(open) != 1 {
		t.Fatalf("open reviews: %d %v", len(open), err)
	}
	if _, err := s.Transition(ctx, "API-PR42", domain.StateRejected, domain.Event{TicketKey: "API-PR42", Type: domain.EventStateChanged}, nil); err != nil {
		t.Fatal(err)
	}
	if open, err := s.OpenReviews(ctx); err != nil || len(open) != 0 {
		t.Fatalf("open reviews after rejection: %d %v", len(open), err)
	}

	// Notes: newest first, after a cursor, per login.
	var ids []int64
	for i, note := range []string{"Nits are noise for me.", "Always check the migrations.", "Other person's note"} {
		login := "me"
		if i == 2 {
			login = "you"
		}
		x, err := s.AddReviewerNote(ctx, domain.ReviewerNote{Login: login, RepoID: &repo.ID, TicketKey: "API-PR42", PullTitle: "Add caching", Kind: domain.NoteRereview, Note: note})
		if err != nil {
			t.Fatal(err)
		}
		if x.RepoName != "api" {
			t.Fatalf("note repo name: %+v", x)
		}
		ids = append(ids, x.ID)
	}
	mine, err := s.ReviewerNotes(ctx, "me", 0, 10)
	if err != nil || len(mine) != 2 || mine[0].Note != "Always check the migrations." {
		t.Fatalf("my notes: %+v %v", mine, err)
	}
	if after, _ := s.ReviewerNotes(ctx, "me", ids[0], 10); len(after) != 1 {
		t.Fatalf("notes after the first: %+v", after)
	}
	if all, _ := s.ReviewerNotes(ctx, "", 0, 10); len(all) != 3 {
		t.Fatalf("everyone's notes: %d", len(all))
	}
	if theirs, _ := s.ReviewerNotes(other, "", 0, 10); len(theirs) != 0 {
		t.Fatalf("another workspace sees notes: %+v", theirs)
	}

	// Profiles: learned_through only moves forward, notes add up.
	if _, err := s.ReviewerProfile(ctx, "me"); !errors.Is(err, domain.ErrNotFound) {
		t.Fatalf("profile before any: %v", err)
	}
	p, err := s.SaveReviewerProfile(ctx, "me", "- skip nits", ids[1], 2)
	if err != nil || p.LearnedThrough != ids[1] || p.Notes != 2 || p.Body != "- skip nits" {
		t.Fatalf("learned profile: %+v %v", p, err)
	}
	p, err = s.SaveReviewerProfile(ctx, "me", "- skip nits\n- check migrations", 0, 0) // a person's edit
	if err != nil || p.LearnedThrough != ids[1] || p.Notes != 2 {
		t.Fatalf("edited profile: %+v %v", p, err)
	}
	if ps, _ := s.ReviewerProfiles(ctx); len(ps) != 1 || ps[0].Login != "me" {
		t.Fatalf("profiles: %+v", ps)
	}
	if err := s.DeleteReviewerNote(ctx, ids[2]); err != nil {
		t.Fatal(err)
	}
	if err := s.DeleteReviewerNote(ctx, ids[2]); !errors.Is(err, domain.ErrNotFound) {
		t.Fatalf("delete twice: %v", err)
	}
}
