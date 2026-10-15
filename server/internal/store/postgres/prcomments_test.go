package postgres

import (
	"testing"

	"agnts/internal/domain"
)

func TestPRPostsAndThreadFeedback(t *testing.T) {
	users, _ := testDB(t)
	ctx, _ := testWS(t, users)
	other, _ := testWS(t, users)
	s := NewAgent(users.db)

	repo, err := s.SaveRepository(ctx, domain.Repository{Name: "api", Kind: "side", Provider: "github", CloneURL: "https://github.com/a/api.git", DefaultBranch: "main"})
	if err != nil {
		t.Fatal(err)
	}
	tk, err := s.CreateTicket(ctx, domain.Ticket{Key: "API-1", Source: domain.SourceLocal, Kind: domain.KindCode, RepoID: &repo.ID, Title: "x",
		Priority: "medium", State: domain.StateNew, ResumeState: domain.StateNew, AfterApprove: "pr"}, domain.Event{TicketKey: "API-1", Type: domain.EventTicketCreated})
	if err != nil {
		t.Fatal(err)
	}

	p, err := s.AddPRPost(ctx, domain.PRPost{RepoID: repo.ID, Number: 4, TicketID: &tk.ID, CommentID: "rc:1", ThreadID: "th::1",
		Kind: domain.PostFinding, FindingKey: "k1", HeadSHA: "a"})
	if err != nil || p.ID == 0 || p.FindingKey != "k1" {
		t.Fatalf("add: %+v %v", p, err)
	}
	// The same comment again updates the record.
	if _, err := s.AddPRPost(ctx, domain.PRPost{RepoID: repo.ID, Number: 4, CommentID: "rc:1", ThreadID: "th:N:1", Kind: domain.PostFinding, FindingKey: "k1", HeadSHA: "b"}); err != nil {
		t.Fatal(err)
	}
	if _, err := s.AddPRPost(ctx, domain.PRPost{RepoID: repo.ID, Number: 4, CommentID: "rv:9", Kind: domain.PostSummary}); err != nil {
		t.Fatal(err)
	}
	posts, err := s.PRPosts(ctx, repo.ID, 4)
	if err != nil || len(posts) != 2 || posts[0].ThreadID != "th:N:1" || posts[0].HeadSHA != "b" {
		t.Fatalf("posts: %+v %v", posts, err)
	}
	if err := s.UpdatePRPost(ctx, posts[0].ID, "c", true); err != nil {
		t.Fatal(err)
	}
	if posts, _ := s.PRPosts(ctx, repo.ID, 4); !posts[0].Resolved || posts[0].HeadSHA != "c" {
		t.Fatalf("update: %+v", posts[0])
	}
	if posts, _ := s.PRPosts(other, repo.ID, 4); len(posts) != 0 {
		t.Fatalf("another workspace sees the posts: %+v", posts)
	}
	if err := s.DeletePRPost(ctx, repo.ID, 4, "rv:9"); err != nil {
		t.Fatal(err)
	}
	if posts, _ := s.PRPosts(ctx, repo.ID, 4); len(posts) != 1 {
		t.Fatalf("after delete: %+v", posts)
	}

	fs := []domain.PRThreadFeedback{
		{TicketID: tk.ID, RepoID: repo.ID, Number: 4, ThreadID: "th:A:1", LastCommentID: "rc:2", Revision: 1},
		{TicketID: tk.ID, RepoID: repo.ID, Number: 4, ThreadID: "ic:7", LastCommentID: "ic:7", Revision: 1},
	}
	if err := s.SaveThreadFeedback(ctx, fs); err != nil {
		t.Fatal(err)
	}
	if err := s.MarkThreadReplied(ctx, tk.ID, "th:A:1"); err != nil {
		t.Fatal(err)
	}
	got, err := s.ThreadFeedback(ctx, tk.ID)
	if err != nil || len(got) != 2 {
		t.Fatalf("feedback: %+v %v", got, err)
	}
	replied := map[string]bool{}
	for _, f := range got {
		replied[f.ThreadID] = f.Replied
	}
	if !replied["th:A:1"] || replied["ic:7"] {
		t.Fatalf("replied: %v", replied)
	}
	// Sent again (a newer comment): not answered any more.
	fs[0].LastCommentID, fs[0].Revision = "rc:3", 2
	if err := s.SaveThreadFeedback(ctx, fs[:1]); err != nil {
		t.Fatal(err)
	}
	got, _ = s.ThreadFeedback(ctx, tk.ID)
	for _, f := range got {
		if f.ThreadID == "th:A:1" && (f.Replied || f.LastCommentID != "rc:3" || f.Revision != 2) {
			t.Fatalf("sent again: %+v", f)
		}
	}
	if got, _ := s.ThreadFeedback(other, tk.ID); len(got) != 0 {
		t.Fatalf("another workspace sees the feedback: %+v", got)
	}

	// Reviewer notes take comments from the git host.
	if _, err := s.AddReviewerNote(ctx, domain.ReviewerNote{Login: "me", Kind: domain.NoteHostComment, Note: "Prefer table tests."}); err != nil {
		t.Fatalf("host comment note: %v", err)
	}
}
