package postgres

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"time"

	"github.com/jackc/pgx/v5"

	"agnts/internal/domain"
	"agnts/internal/orchestrator"
)

var _ orchestrator.ScoreRuns = (*Agent)(nil)

// EnsurePromptVersion makes version the workspace's current scoring
// version, creating it with anchors when it is new; an existing version
// keeps its frozen anchors.
func (s *Agent) EnsurePromptVersion(ctx context.Context, version, model string, anchors []byte) (domain.PromptVersionRow, error) {
	if len(anchors) == 0 {
		anchors = []byte("[]")
	}
	_, err := s.db.Exec(ctx, `INSERT INTO prompt_versions (version, model, anchors) VALUES ($1, $2, $3)
		ON CONFLICT (workspace_id, version) DO NOTHING`, version, model, anchors)
	if err != nil {
		return domain.PromptVersionRow{}, err
	}
	return s.PromptVersion(ctx, version)
}

// PromptVersion returns one of the workspace's scoring versions.
func (s *Agent) PromptVersion(ctx context.Context, version string) (domain.PromptVersionRow, error) {
	var v domain.PromptVersionRow
	err := s.db.QueryRow(ctx, `SELECT version, model, anchors, current_from FROM prompt_versions WHERE version = $1`, version).
		Scan(&v.Version, &v.Model, &v.Anchors, &v.CurrentFrom)
	return v, notFound(err)
}

// CurrentPromptVersion returns the workspace's newest scoring version.
func (s *Agent) CurrentPromptVersion(ctx context.Context) (domain.PromptVersionRow, error) {
	var v domain.PromptVersionRow
	err := s.db.QueryRow(ctx, `SELECT version, model, anchors, current_from FROM prompt_versions ORDER BY current_from DESC, version DESC LIMIT 1`).
		Scan(&v.Version, &v.Model, &v.Anchors, &v.CurrentFrom)
	return v, notFound(err)
}

// PerfReviewSince is when the workspace first scored (its first scoring
// version): deliveries from then on are scored on their own, earlier
// ones only by a backfill the owner confirms.
func (s *Agent) PerfReviewSince(ctx context.Context) (*time.Time, error) {
	var at *time.Time
	err := s.db.QueryRow(ctx, `SELECT min(current_from) FROM prompt_versions`).Scan(&at)
	return at, err
}

// AverageScoreCostUSD is the workspace's average API cost of a finished
// score run, and how many it averages.
func (s *Agent) AverageScoreCostUSD(ctx context.Context) (float64, int, error) {
	var avg float64
	var n int
	err := s.db.QueryRow(ctx, `SELECT COALESCE(avg(c), 0)::float8, count(*) FROM (
			SELECT sum(cc.cost_usd) c FROM claude_calls cc JOIN score_runs r ON r.id = cc.score_run_id
			WHERE r.status = 'done' GROUP BY r.id ORDER BY r.id DESC LIMIT 200) x`).Scan(&avg, &n)
	return avg, n, err
}

// PromptVersionAt returns the version current at a time (the one a month
// closes with).
func (s *Agent) PromptVersionAt(ctx context.Context, at time.Time) (domain.PromptVersionRow, error) {
	var v domain.PromptVersionRow
	err := s.db.QueryRow(ctx, `SELECT version, model, anchors, current_from FROM prompt_versions WHERE current_from <= $1
		ORDER BY current_from DESC, version DESC LIMIT 1`, at).Scan(&v.Version, &v.Model, &v.Anchors, &v.CurrentFrom)
	if errors.Is(notFound(err), domain.ErrNotFound) {
		return s.CurrentPromptVersion(ctx)
	}
	return v, err
}

// QueueScores queues a score run for each delivery of the workspace that
// has no score under version and no run on the way, and returns how many.
// since, when set, limits it to deliveries from then on (a backfill).
func (s *Agent) QueueScores(ctx context.Context, version string, since *time.Time) (int, error) {
	tag, err := s.db.Exec(ctx, `INSERT INTO score_runs (workspace_id, ticket_id, delivery, prompt_version)
		SELECT d.workspace_id, d.ticket_id, d.delivery, $1 FROM ticket_deliveries d
		WHERE ($2::timestamptz IS NULL OR d.delivered_at >= $2)
		  AND NOT EXISTS (SELECT 1 FROM ticket_scores x WHERE x.ticket_id = d.ticket_id AND x.delivery = d.delivery AND x.prompt_version = $1)
		  AND NOT EXISTS (SELECT 1 FROM score_runs r WHERE r.ticket_id = d.ticket_id AND r.delivery = d.delivery AND r.prompt_version = $1
		                  AND r.status IN ('queued', 'scoring'))
		ON CONFLICT DO NOTHING`, version, since)
	return int(tag.RowsAffected()), err
}

// UnscoredDeliveries counts the workspace's deliveries from since on that
// have no score under version: what a backfill would score.
func (s *Agent) UnscoredDeliveries(ctx context.Context, version string, since *time.Time) (int, error) {
	var n int
	err := s.db.QueryRow(ctx, `SELECT count(*) FROM ticket_deliveries d
		WHERE ($2::timestamptz IS NULL OR d.delivered_at >= $2)
		  AND NOT EXISTS (SELECT 1 FROM ticket_scores x WHERE x.ticket_id = d.ticket_id AND x.delivery = d.delivery AND x.prompt_version = $1)`,
		version, since).Scan(&n)
	return n, err
}

// PerfReviewWorkspaces returns the workspaces that may have something
// to score: they have deliveries (system scope). Whether performance
// reviews are on is the settings' to say.
func (s *Agent) PerfReviewWorkspaces(ctx context.Context) ([]int64, error) {
	rows, err := s.db.Query(ctx, `SELECT w.id FROM workspaces w
		WHERE w.deleted_at IS NULL AND w.suspended_at IS NULL
		  AND EXISTS (SELECT 1 FROM ticket_deliveries d WHERE d.workspace_id = w.id) ORDER BY w.id`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	return pgx.CollectRows(rows, pgx.RowTo[int64])
}

// PendingScoreWorkspaces returns the workspaces with score runs waiting
// (system scope).
func (s *Agent) PendingScoreWorkspaces(ctx context.Context) ([]int64, error) {
	rows, err := s.db.Query(ctx, `SELECT DISTINCT workspace_id FROM score_runs WHERE status = 'queued' ORDER BY workspace_id`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	return pgx.CollectRows(rows, pgx.RowTo[int64])
}

const scoreRunCols = `r.id, r.workspace_id, r.ticket_id, t.key, r.delivery, r.prompt_version, r.status, r.attempts, r.error, r.created_at`

func scanScoreRun(row pgx.Row) (domain.ScoreRun, error) {
	var r domain.ScoreRun
	err := row.Scan(&r.ID, &r.WorkspaceID, &r.TicketID, &r.TicketKey, &r.Delivery, &r.PromptVersion, &r.Status, &r.Attempts, &r.Error, &r.CreatedAt)
	return r, notFound(err)
}

// ClaimScoreRun moves the workspace's oldest queued score run to scoring.
func (s *Agent) ClaimScoreRun(ctx context.Context) (domain.ScoreRun, bool, error) {
	r, err := scanScoreRun(s.db.QueryRow(ctx, `WITH c AS (
			UPDATE score_runs SET status = 'scoring', started_at = now(), attempts = attempts + 1
			WHERE id = (SELECT id FROM score_runs WHERE status = 'queued' ORDER BY created_at, id LIMIT 1 FOR UPDATE SKIP LOCKED)
			RETURNING *)
		SELECT `+scoreRunCols+` FROM c r JOIN tickets t ON t.id = r.ticket_id`))
	if errors.Is(err, domain.ErrNotFound) {
		return r, false, nil
	}
	return r, err == nil, err
}

// RecoverScoreRuns requeues score runs a crash left scoring.
func (s *Agent) RecoverScoreRuns(ctx context.Context) (int, error) {
	tag, err := s.db.Exec(ctx, `UPDATE score_runs SET status = 'queued', started_at = NULL WHERE status = 'scoring'`)
	return int(tag.RowsAffected()), err
}

// SetScoreRunAccount records the account a score run runs on.
func (s *Agent) SetScoreRunAccount(ctx context.Context, runID int64, conn *int64, credits bool) error {
	_, err := s.db.Exec(ctx, `UPDATE score_runs SET connection_id = $2, on_credits = $3 WHERE id = $1`, runID, conn, credits)
	return err
}

// RecordScoreCall stores the spend of a score run's Claude invocation;
// the ticket is the run's.
func (s *Agent) RecordScoreCall(ctx context.Context, runID int64, c domain.ClaudeCall) error {
	u := c.Usage
	var transcript *int64
	if c.TranscriptID > 0 {
		transcript = &c.TranscriptID
	}
	tag, err := s.db.Exec(ctx, `INSERT INTO claude_calls (score_run_id, ticket_id, model_stage, model,
			input_tokens, output_tokens, cache_read_tokens, cache_write_tokens, cost_usd, turns, duration_ms, partial, transcript_id,
			provider, connection_id, on_credits)
		SELECT id, ticket_id, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15 FROM score_runs WHERE id = $1`,
		runID, c.ModelStage, c.Model, u.Input, u.Output, u.CacheRead, u.CacheWrite, u.CostUSD,
		c.Turns, c.Duration.Milliseconds(), c.Partial, transcript, callProvider(c), nullID(c.ConnectionID), c.OnCredits)
	if err != nil {
		return err
	}
	if tag.RowsAffected() == 0 {
		return fmt.Errorf("record score call: score run %d: %w", runID, domain.ErrNotFound)
	}
	return nil
}

// FinishScoreRun records how a score run ended and, with a score, stores
// it and its authors, in one transaction. A run to try again goes back to
// the queue.
func (s *Agent) FinishScoreRun(ctx context.Context, run domain.ScoreRun, res domain.ScoreResult) error {
	return pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		finished := "now()"
		if res.Status == domain.ScoreQueued {
			finished = "NULL"
		}
		if _, err := tx.Exec(ctx, `UPDATE score_runs SET status = $2, error = $3, finished_at = `+finished+`,
				started_at = CASE WHEN $2 = 'queued' THEN NULL ELSE started_at END WHERE id = $1`, run.ID, res.Status, res.Error); err != nil {
			return err
		}
		if res.Score == nil {
			return nil
		}
		return upsertScore(ctx, tx, run, *res.Score)
	})
}

func upsertScore(ctx context.Context, tx pgx.Tx, run domain.ScoreRun, sc domain.TicketScore) error {
	factors, err := json.Marshal(orEmpty(sc.Factors))
	if err != nil {
		return err
	}
	var points *int
	if sc.Status == domain.ScoreScored {
		points = &sc.Points
	}
	if _, err := tx.Exec(ctx, `INSERT INTO ticket_scores (workspace_id, ticket_id, delivery, prompt_version, status, points, from_facts_only, clamped,
			diff_source, rationale, factors, error, model, score_run_id, scored_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, now())
		ON CONFLICT (ticket_id, delivery, prompt_version) DO UPDATE SET status = EXCLUDED.status, points = EXCLUDED.points,
			from_facts_only = EXCLUDED.from_facts_only, clamped = EXCLUDED.clamped, diff_source = EXCLUDED.diff_source,
			rationale = EXCLUDED.rationale, factors = EXCLUDED.factors, error = EXCLUDED.error, model = EXCLUDED.model,
			score_run_id = EXCLUDED.score_run_id, scored_at = now()`,
		run.WorkspaceID, run.TicketID, run.Delivery, run.PromptVersion, sc.Status, points, sc.FromFactsOnly, sc.Clamped,
		sc.DiffSource, sc.Rationale, factors, sc.Error, sc.Model, run.ID); err != nil {
		return err
	}
	if sc.Status != domain.ScoreScored {
		return nil
	}
	// The shares are the delivery's, whichever version scored it last.
	if _, err := tx.Exec(ctx, `DELETE FROM ticket_score_authors WHERE ticket_id = $1 AND delivery = $2`, run.TicketID, run.Delivery); err != nil {
		return err
	}
	for _, a := range sc.Authors {
		if a.Share <= 0 {
			continue
		}
		if _, err := tx.Exec(ctx, `INSERT INTO ticket_score_authors (workspace_id, ticket_id, delivery, author_key, share, days)
			VALUES ($1, $2, $3, $4, $5, $6)`, run.WorkspaceID, run.TicketID, run.Delivery, a.Key, a.Share, a.Days); err != nil {
			return err
		}
	}
	return nil
}

func orEmpty(m map[string]any) map[string]any {
	if m == nil {
		return map[string]any{}
	}
	return m
}

// DeliveryOf returns one delivery of a ticket, with when the one before
// it was made.
func (s *Agent) DeliveryOf(ctx context.Context, ticketID int64, delivery int) (domain.Delivery, error) {
	var d domain.Delivery
	err := s.db.QueryRow(ctx, `SELECT d.ticket_id, t.key, d.delivery, d.delivered_at, d.undelivered_at,
			(SELECT p.delivered_at FROM ticket_deliveries p WHERE p.ticket_id = d.ticket_id AND p.delivery = d.delivery - 1)
		FROM ticket_deliveries d JOIN tickets t ON t.id = d.ticket_id WHERE d.ticket_id = $1 AND d.delivery = $2`, ticketID, delivery).
		Scan(&d.TicketID, &d.TicketKey, &d.Delivery, &d.DeliveredAt, &d.UndeliveredAt, &d.PreviousAt)
	return d, notFound(err)
}

// AllCommitLinksOfTicket returns every commit linked to a ticket, oldest
// first.
func (s *Agent) AllCommitLinksOfTicket(ctx context.Context, ticketID int64) ([]domain.CommitLink, error) {
	rows, err := s.db.Query(ctx, `SELECT `+commitLinkCols+` FROM ticket_commits c
		JOIN tickets t ON t.id = c.ticket_id JOIN repositories r ON r.id = c.repo_id
		WHERE c.ticket_id = $1 ORDER BY c.committed_at, c.sha LIMIT 5000`, ticketID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var out []domain.CommitLink
	for rows.Next() {
		l, err := scanCommitLink(rows)
		if err != nil {
			return nil, err
		}
		out = append(out, l)
	}
	return out, rows.Err()
}
