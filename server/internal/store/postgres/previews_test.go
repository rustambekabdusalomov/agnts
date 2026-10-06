package postgres

import (
	"context"
	"slices"
	"testing"

	"agnts/internal/domain"
	"agnts/internal/secret"
)

func TestPreviewClaimRecoverAndEnv(t *testing.T) {
	users, _ := testDB(t)
	ctx := context.Background()
	s := NewAgent(users.db)
	_, _ = s.db.Exec(ctx, `TRUNCATE tickets, runs, events, repositories RESTART IDENTITY CASCADE`)

	repo, err := s.SaveRepository(ctx, domain.Repository{Name: "web", Kind: "side", Provider: "github", CloneURL: "https://github.com/a/web.git", DefaultBranch: "main",
		Preview: domain.PreviewConfig{Command: "npm run dev", Port: 5173, Routes: []string{"/"}, UIPaths: []string{"src/**"}}})
	if err != nil {
		t.Fatal(err)
	}
	if p := repo.Preview; p.Command != "npm run dev" || p.Port != 5173 || p.ReadyPath != "/" || !slices.Equal(p.UIPaths, []string{"src/**"}) || p.EnvSet {
		t.Fatalf("saved preview: %+v", p)
	}
	// Upserting by name (the CLI's repo add) keeps the preview settings.
	again, err := s.SaveRepository(ctx, domain.Repository{Name: "web", Kind: "side", Provider: "github", CloneURL: "https://github.com/a/web.git", DefaultBranch: "main"})
	if err != nil || again.Preview.Command != "npm run dev" {
		t.Fatalf("upsert: %+v %v", again.Preview, err)
	}

	key := make([]byte, 32)
	box, _ := secret.NewBox(key)
	envs := NewPreviewEnvs(users.db, box)
	if err := envs.SetPreviewEnv(ctx, repo.ID, "A=1\nB=two"); err != nil {
		t.Fatal(err)
	}
	if err := envs.SetPreviewEnv(ctx, repo.ID, "not an env"); err == nil {
		t.Fatal("bad env stored")
	}
	if got, err := envs.PreviewEnv(ctx, repo.ID); err != nil || got != "A=1\nB=two" {
		t.Fatalf("env: %q %v", got, err)
	}
	r, _ := s.RepositoryByID(ctx, repo.ID)
	if !r.Preview.EnvSet || !slices.Equal(r.Preview.EnvNames, []string{"A", "B"}) {
		t.Fatalf("env flags: %+v", r.Preview)
	}
	var raw []byte
	_ = s.db.QueryRow(ctx, `SELECT preview_env FROM repositories WHERE id = $1`, repo.ID).Scan(&raw)
	if slices.Contains([]string{"A=1\nB=two"}, string(raw)) {
		t.Fatal("env stored in the clear")
	}
	if err := envs.SetPreviewEnv(ctx, repo.ID, ""); err != nil {
		t.Fatal(err)
	}
	if got, _ := envs.PreviewEnv(ctx, repo.ID); got != "" {
		t.Fatalf("cleared env: %q", got)
	}

	// A pending review goes before a pending preview; learn runs come last.
	for _, row := range []struct{ key, state, review, preview string }{
		{"WEB-1", "waiting_for_review", "", "pending"},
		{"WEB-2", "waiting_for_review", "pending", "pending"},
	} {
		if _, err := s.db.Exec(ctx, `INSERT INTO tickets (key, source, repo_id, title, state, review_state, preview_state, feedback_shots)
			VALUES ($1, 'local', $2, 't', $3, $4, $5, '[{"runId":7,"shotId":"home-phone-after"}]')`, row.key, repo.ID, row.state, row.review, row.preview); err != nil {
			t.Fatal(err)
		}
	}
	claim := func() (domain.Ticket, domain.Run) {
		t.Helper()
		tk, run, ok, err := s.ClaimNext(ctx)
		if err != nil || !ok {
			t.Fatalf("claim: %v %v", ok, err)
		}
		return tk, run
	}
	tk, run := claim()
	if tk.Key != "WEB-2" || run.Stage != domain.StageReview {
		t.Fatalf("first claim: %s %s", tk.Key, run.Stage)
	}
	tk, run = claim()
	if tk.Key != "WEB-1" || run.Stage != domain.StagePreview || tk.PreviewState != domain.PreviewRunning {
		t.Fatalf("second claim: %s %s %q", tk.Key, run.Stage, tk.PreviewState)
	}
	if len(tk.FeedbackShots) != 1 || tk.FeedbackShots[0] != (domain.ShotRef{RunID: 7, ShotID: "home-phone-after"}) {
		t.Fatalf("feedback shots: %+v", tk.FeedbackShots)
	}
	if n, err := s.RecoverInterrupted(ctx); err != nil || n != 2 {
		t.Fatalf("recover: %d %v", n, err)
	}
	if tk, _ := s.TicketByKey(ctx, "WEB-1"); tk.PreviewState != domain.PreviewPending {
		t.Fatalf("interrupted preview: %q", tk.PreviewState)
	}
}
