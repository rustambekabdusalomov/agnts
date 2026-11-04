package postgres

import (
	"context"
	"errors"
	"testing"
	"time"

	"agnts/internal/domain"
)

// A score run owns its Claude calls and is charged once, with reason
// score.
func TestScoreRunSpend(t *testing.T) {
	users, _ := testDB(t)
	ctx, ws := testWS(t, users)
	s := NewAgent(users.db)
	credits := NewCredits(users.db)
	sys := domain.System(context.Background())

	repo, err := s.SaveRepository(ctx, domain.Repository{Name: "api", Kind: "side", Provider: "github", CloneURL: "https://github.com/a/api.git", DefaultBranch: "main"})
	if err != nil {
		t.Fatal(err)
	}
	tk, err := s.CreateTicket(ctx, domain.Ticket{Key: "SC-1", Source: domain.SourceJira, Kind: domain.KindCode, RepoID: &repo.ID, Title: "t", Priority: "medium",
		State: domain.StateWaitingForAnswers, ResumeState: domain.StateNew, AfterApprove: "pr"}, domain.Event{TicketKey: "SC-1", Type: domain.EventTicketCreated})
	if err != nil {
		t.Fatal(err)
	}
	if _, err := s.UpsertCommitLinks(ctx, []domain.CommitLink{{TicketID: tk.ID, RepoID: repo.ID, SHA: "c1", Subject: "x", CommittedAt: time.Now(),
		MatchedOn: []string{domain.MatchMessage}, Token: "sc-1"}}); err != nil {
		t.Fatal(err)
	}
	_ = s.MarkOnDefault(ctx, repo.ID, []domain.DefaultCommit{{SHA: "c1", At: time.Now()}})
	now := time.Now()
	_ = s.SetTrackerResolution(ctx, domain.SourceJira, "SC-1", &now, "Done")

	if _, err := s.EnsurePromptVersion(ctx, "v1", "haiku", []byte(`[{"title":"a","points":1}]`)); err != nil {
		t.Fatal(err)
	}
	// An existing version keeps its frozen anchors.
	v, err := s.EnsurePromptVersion(ctx, "v1", "haiku", []byte(`[]`))
	if err != nil || string(v.Anchors) == "[]" {
		t.Fatalf("version: %s %v", v.Anchors, err)
	}
	if n, err := s.QueueScores(ctx, "v1", nil); err != nil || n != 1 {
		t.Fatalf("queue: %d %v", n, err)
	}
	if n, _ := s.QueueScores(ctx, "v1", nil); n != 0 {
		t.Fatal("queued twice")
	}
	run, ok, err := s.ClaimScoreRun(ctx)
	if err != nil || !ok || run.TicketKey != "SC-1" || run.Attempts != 1 {
		t.Fatalf("claim: %+v %v %v", run, ok, err)
	}
	if err := s.RecordScoreCall(ctx, run.ID, domain.ClaudeCall{ModelStage: "score", Model: "haiku", OnCredits: true,
		Usage: domain.TokenUsage{Input: 10, CostUSD: 0.42}}); err != nil {
		t.Fatal(err)
	}
	var ticketID int64
	if err := s.db.QueryRow(sys, `SELECT ticket_id FROM claude_calls WHERE score_run_id = $1`, run.ID).Scan(&ticketID); err != nil || ticketID != tk.ID {
		t.Fatalf("call: %d %v", ticketID, err)
	}
	if usd, err := credits.ScoreRunCostUSD(ctx, run.ID); err != nil || usd < 0.41 || usd > 0.43 {
		t.Fatalf("cost: %v %v", usd, err)
	}
	if _, err := credits.Add(ctx, LedgerEntry{WorkspaceID: ws, Amount: -42, Reason: CreditScore, ScoreRunID: &run.ID, TicketKey: "SC-1"}); err != nil {
		t.Fatal(err)
	}
	if _, err := credits.Add(ctx, LedgerEntry{WorkspaceID: ws, Amount: -42, Reason: CreditScore, ScoreRunID: &run.ID}); !errors.Is(err, ErrAlreadyCharged) {
		t.Fatalf("charged twice: %v", err)
	}
	if err := s.FinishScoreRun(ctx, run, domain.ScoreResult{Status: domain.ScoreDone, Score: &domain.TicketScore{Status: domain.ScoreScored, Points: 5,
		Authors: []domain.ScoreAuthor{{Key: "user:1", Share: 0.8, Days: 4}, {Key: "agent", Share: 0.2, Days: 1}}}}); err != nil {
		t.Fatal(err)
	}
	var points, authors int
	_ = s.db.QueryRow(sys, `SELECT points, (SELECT count(*) FROM ticket_score_authors WHERE ticket_id = $1) FROM ticket_scores WHERE ticket_id = $1`, tk.ID).
		Scan(&points, &authors)
	if points != 5 || authors != 2 {
		t.Fatalf("score: %d points, %d authors", points, authors)
	}
}
