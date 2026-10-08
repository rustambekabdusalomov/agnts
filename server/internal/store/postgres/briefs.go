package postgres

import (
	"context"
	"errors"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"agnts/internal/domain"
	"agnts/internal/orchestrator"
)

// Briefs stores what agnts knows about each repository.
type Briefs struct{ db *pgxpool.Pool }

var _ orchestrator.Briefs = (*Briefs)(nil)

// NewBriefs returns the brief store.
func NewBriefs(db *pgxpool.Pool) *Briefs { return &Briefs{db: db} }

const briefCols = `b.repo_id, b.workspace_id, r.name, b.body, b.body_sha, b.draft, b.draft_sha, b.status, b.merges_since,
	b.error, b.revision, b.surveyed_at, b.approved_at, b.updated_at`

const briefFrom = ` FROM repo_briefs b JOIN repositories r ON r.id = b.repo_id`

func scanBrief(row pgx.Row) (domain.RepoBrief, error) {
	var b domain.RepoBrief
	var status string
	err := row.Scan(&b.RepoID, &b.WorkspaceID, &b.RepoName, &b.Body, &b.BodySHA, &b.Draft, &b.DraftSHA, &status, &b.MergesSince,
		&b.Error, &b.Revision, &b.SurveyedAt, &b.ApprovedAt, &b.UpdatedAt)
	if err != nil {
		return b, notFound(err)
	}
	b.Status = domain.BriefStatus(status)
	return b, nil
}

// Brief returns a repository's brief, or domain.ErrNotFound when it has
// never had one.
func (s *Briefs) Brief(ctx context.Context, repoID int64) (domain.RepoBrief, error) {
	return scanBrief(s.db.QueryRow(ctx, `SELECT `+briefCols+briefFrom+` WHERE b.repo_id = $1`, repoID))
}

// UpdateBrief applies mut to the locked brief of repoID, creating an empty
// one first when the repository has none, and saves it with the event ev
// builds (nil for none) in one transaction. mut's error aborts the update
// and is returned as is. A repository that does not exist gives
// domain.ErrNotFound.
func (s *Briefs) UpdateBrief(ctx context.Context, repoID int64, mut func(*domain.RepoBrief) error, ev func(domain.RepoBrief) *domain.Event) (domain.RepoBrief, error) {
	var out domain.RepoBrief
	err := pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		// The repository's own workspace, so a system context can create it.
		if _, err := tx.Exec(ctx, `INSERT INTO repo_briefs (repo_id, workspace_id)
			SELECT id, workspace_id FROM repositories WHERE id = $1 ON CONFLICT (repo_id) DO NOTHING`, repoID); err != nil {
			return err
		}
		b, err := scanBrief(tx.QueryRow(ctx, `SELECT `+briefCols+briefFrom+` WHERE b.repo_id = $1 FOR UPDATE OF b`, repoID))
		if err != nil {
			return err
		}
		if err := mut(&b); err != nil {
			return err
		}
		if _, err := tx.Exec(ctx, `UPDATE repo_briefs SET body = $2, body_sha = $3, draft = $4, draft_sha = $5, status = $6,
			merges_since = $7, error = $8, revision = $9, surveyed_at = $10, approved_at = $11, updated_at = now()
			WHERE repo_id = $1`,
			b.RepoID, b.Body, b.BodySHA, b.Draft, b.DraftSHA, string(b.Status), b.MergesSince, b.Error, b.Revision,
			b.SurveyedAt, b.ApprovedAt); err != nil {
			return err
		}
		if out, err = scanBrief(tx.QueryRow(ctx, `SELECT `+briefCols+briefFrom+` WHERE b.repo_id = $1`, repoID)); err != nil {
			return err
		}
		if ev == nil {
			return nil
		}
		if e := ev(out); e != nil {
			return insertEvent(ctx, tx, *e)
		}
		return nil
	})
	return out, err
}

// ClaimBrief moves the oldest pending brief to surveying and returns it; ok
// is false when none is waiting.
func (s *Briefs) ClaimBrief(ctx context.Context) (domain.RepoBrief, bool, error) {
	var id int64
	err := s.db.QueryRow(ctx, `UPDATE repo_briefs SET status = 'surveying', updated_at = now()
		WHERE repo_id = (SELECT repo_id FROM repo_briefs WHERE status = 'pending' ORDER BY updated_at, repo_id LIMIT 1 FOR UPDATE SKIP LOCKED)
		RETURNING repo_id`).Scan(&id)
	if errors.Is(err, pgx.ErrNoRows) {
		return domain.RepoBrief{}, false, nil
	}
	if err != nil {
		return domain.RepoBrief{}, false, err
	}
	b, err := s.Brief(ctx, id)
	return b, err == nil, err
}

// PendingBriefWorkspaces returns the workspaces with briefs waiting for a
// survey (a system context sees them all).
func (s *Briefs) PendingBriefWorkspaces(ctx context.Context) ([]int64, error) {
	rows, err := s.db.Query(ctx, `SELECT DISTINCT workspace_id FROM repo_briefs WHERE status = 'pending' ORDER BY 1`)
	if err != nil {
		return nil, err
	}
	return pgx.CollectRows(rows, pgx.RowTo[int64])
}

// RecoverBriefs requeues surveys a crash left running.
func (s *Briefs) RecoverBriefs(ctx context.Context) (int, error) {
	tag, err := s.db.Exec(ctx, `UPDATE repo_briefs SET status = 'pending', updated_at = now() WHERE status = 'surveying'`)
	return int(tag.RowsAffected()), err
}
