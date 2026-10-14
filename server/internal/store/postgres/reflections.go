package postgres

import (
	"context"
	"errors"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"agnts/internal/domain"
	"agnts/internal/orchestrator"
)

// Reflections stores the feedback agnts learns from.
type Reflections struct{ db *pgxpool.Pool }

var _ orchestrator.Reflections = (*Reflections)(nil)

// NewReflections returns the reflection store.
func NewReflections(db *pgxpool.Pool) *Reflections { return &Reflections{db: db} }

const reflectionCols = `id, workspace_id, ticket_key, repo_id, source, feedback, status, suggested, error, created_at`

func scanReflection(row pgx.Row) (domain.Reflection, error) {
	var r domain.Reflection
	err := row.Scan(&r.ID, &r.WorkspaceID, &r.TicketKey, &r.RepoID, &r.Source, &r.Feedback, &r.Status, &r.Suggested, &r.Error, &r.CreatedAt)
	return r, notFound(err)
}

// QueueReflection stores feedback for a reflect run, in the workspace the
// context acts in.
func (s *Reflections) QueueReflection(ctx context.Context, r domain.Reflection) error {
	_, err := s.db.Exec(ctx, `INSERT INTO reflections (ticket_key, repo_id, source, feedback, repo_ids) VALUES ($1, $2, $3, $4, $5)`,
		r.TicketKey, r.RepoID, r.Source, r.Feedback, nonNilIDs(r.RepoIDs))
	return err
}

// ClaimReflection moves the oldest pending reflection to running; ok is
// false when none is waiting.
func (s *Reflections) ClaimReflection(ctx context.Context) (domain.Reflection, bool, error) {
	r, err := scanReflection(s.db.QueryRow(ctx, `UPDATE reflections SET status = 'running', updated_at = now()
		WHERE id = (SELECT id FROM reflections WHERE status = 'pending' ORDER BY updated_at, id LIMIT 1 FOR UPDATE SKIP LOCKED)
		RETURNING `+reflectionCols))
	if errors.Is(err, domain.ErrNotFound) {
		return r, false, nil
	}
	return r, err == nil, err
}

// FinishReflection records how a reflect run ended: done with the number
// of rules it suggested, failed with why, or pending to run again.
func (s *Reflections) FinishReflection(ctx context.Context, id int64, status string, suggested int, errMsg string) error {
	_, err := s.db.Exec(ctx, `UPDATE reflections SET status = $2, suggested = $3, error = $4, updated_at = now() WHERE id = $1`,
		id, status, suggested, errMsg)
	return err
}

// Reflections returns a ticket's reflections, oldest first.
func (s *Reflections) Reflections(ctx context.Context, key string) ([]domain.Reflection, error) {
	rows, err := s.db.Query(ctx, `SELECT `+reflectionCols+` FROM reflections WHERE ticket_key = $1 ORDER BY id`, key)
	if err != nil {
		return nil, err
	}
	return pgx.CollectRows(rows, func(row pgx.CollectableRow) (domain.Reflection, error) { return scanReflection(row) })
}

// PendingReflectionWorkspaces returns the workspaces with reflections
// waiting (a system context sees them all).
func (s *Reflections) PendingReflectionWorkspaces(ctx context.Context) ([]int64, error) {
	rows, err := s.db.Query(ctx, `SELECT DISTINCT workspace_id FROM reflections WHERE status = 'pending' ORDER BY 1`)
	if err != nil {
		return nil, err
	}
	return pgx.CollectRows(rows, pgx.RowTo[int64])
}

// RecoverReflections requeues reflect runs a crash left running.
func (s *Reflections) RecoverReflections(ctx context.Context) (int, error) {
	tag, err := s.db.Exec(ctx, `UPDATE reflections SET status = 'pending', updated_at = now() WHERE status = 'running'`)
	return int(tag.RowsAffected()), err
}
