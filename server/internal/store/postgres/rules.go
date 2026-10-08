package postgres

import (
	"context"
	"encoding/json"
	"errors"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"agnts/internal/domain"
	"agnts/internal/orchestrator"
)

// Rules stores the rules agnts follows on tickets.
type Rules struct{ db *pgxpool.Pool }

var _ orchestrator.Rules = (*Rules)(nil)

// NewRules returns the rules store.
func NewRules(db *pgxpool.Pool) *Rules { return &Rules{db: db} }

const ruleCols = `x.id, x.repo_id, coalesce(r.name, ''), x.title, x.body, x.enabled, x.status, x.interpretation,
	x.clarified, x.questions, x.rounds, x.revision, x.error, x.analyzed_at, x.created_at, x.updated_at, x.workspace_id,
	x.kind, x.source_ticket, x.reason`

const ruleFrom = ` FROM rules x LEFT JOIN repositories r ON r.id = x.repo_id`

func scanRule(row pgx.Row) (domain.Rule, error) {
	var x domain.Rule
	var status, kind string
	var qs []byte
	err := row.Scan(&x.ID, &x.RepoID, &x.RepoName, &x.Title, &x.Body, &x.Enabled, &status, &x.Interpretation,
		&x.Clarified, &qs, &x.Rounds, &x.Revision, &x.Error, &x.AnalyzedAt, &x.CreatedAt, &x.UpdatedAt, &x.WorkspaceID,
		&kind, &x.SourceTicket, &x.Reason)
	if err != nil {
		return x, notFound(err)
	}
	x.Status, x.Kind = domain.RuleStatus(status), domain.RuleKind(kind)
	_ = json.Unmarshal(qs, &x.Questions)
	return x, nil
}

func (s *Rules) query(ctx context.Context, sql string, args ...any) ([]domain.Rule, error) {
	rows, err := s.db.Query(ctx, sql, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := []domain.Rule{}
	for rows.Next() {
		x, err := scanRule(rows)
		if err != nil {
			return nil, err
		}
		out = append(out, x)
	}
	return out, rows.Err()
}

// ListRules returns every rule but dismissed suggestions: global ones
// first, then by repository.
func (s *Rules) ListRules(ctx context.Context) ([]domain.Rule, error) {
	return s.query(ctx, `SELECT `+ruleCols+ruleFrom+` WHERE x.status <> 'dismissed' ORDER BY x.repo_id NULLS FIRST, r.name, x.id`)
}

// KnownRules returns every rule of the workspace that tickets in repoID
// could get (nil: global ones only), in any status, dismissed suggestions
// included: what a reflect run must not suggest again.
func (s *Rules) KnownRules(ctx context.Context, repoID *int64) ([]domain.Rule, error) {
	return s.query(ctx, `SELECT `+ruleCols+ruleFrom+` WHERE x.repo_id IS NULL OR x.repo_id = $1 ORDER BY x.repo_id NULLS FIRST, x.id`, repoID)
}

// ActiveRules returns the rules tickets in repoID follow: enabled, reviewed,
// global ones first. repoID nil gives the global rules only.
func (s *Rules) ActiveRules(ctx context.Context, repoID *int64) ([]domain.Rule, error) {
	return s.query(ctx, `SELECT `+ruleCols+ruleFrom+`
		WHERE x.enabled AND x.status = 'ready' AND (x.repo_id IS NULL OR x.repo_id = $1)
		ORDER BY x.repo_id NULLS FIRST, x.id`, repoID)
}

// Rule returns one rule, or domain.ErrNotFound.
func (s *Rules) Rule(ctx context.Context, id int64) (domain.Rule, error) {
	return scanRule(s.db.QueryRow(ctx, `SELECT `+ruleCols+ruleFrom+` WHERE x.id = $1`, id))
}

// CreateRule inserts a rule and its event in one transaction.
func (s *Rules) CreateRule(ctx context.Context, x domain.Rule, ev func(domain.Rule) domain.Event) (domain.Rule, error) {
	var out domain.Rule
	err := pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		var id int64
		kind := x.Kind
		if !kind.Valid() {
			kind = domain.KindInstruction
		}
		if err := tx.QueryRow(ctx, `INSERT INTO rules (repo_id, title, body, enabled, status, kind, source_ticket, reason)
			VALUES ($1, $2, $3, $4, $5, $6, $7, $8) RETURNING id`,
			x.RepoID, x.Title, x.Body, x.Enabled, string(x.Status), string(kind), x.SourceTicket, x.Reason).Scan(&id); err != nil {
			return err
		}
		var err error
		if out, err = scanRule(tx.QueryRow(ctx, `SELECT `+ruleCols+ruleFrom+` WHERE x.id = $1`, id)); err != nil {
			return err
		}
		return insertEvent(ctx, tx, ev(out))
	})
	return out, err
}

// UpdateRule applies mut to the locked rule and saves it with the event ev
// builds, in one transaction. ev may return nil for no event. mut's error
// aborts the update and is returned as is.
func (s *Rules) UpdateRule(ctx context.Context, id int64, mut func(*domain.Rule) error, ev func(domain.Rule) *domain.Event) (domain.Rule, error) {
	var out domain.Rule
	err := pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		x, err := scanRule(tx.QueryRow(ctx, `SELECT `+ruleCols+ruleFrom+` WHERE x.id = $1 FOR UPDATE OF x`, id))
		if err != nil {
			return err
		}
		if err := mut(&x); err != nil {
			return err
		}
		qs, _ := json.Marshal(nonNil(x.Questions))
		if _, err := tx.Exec(ctx, `UPDATE rules SET repo_id = $2, title = $3, body = $4, enabled = $5, status = $6,
			interpretation = $7, clarified = $8, questions = $9, rounds = $10, revision = $11, error = $12,
			analyzed_at = $13, kind = $14, updated_at = now() WHERE id = $1`,
			x.ID, x.RepoID, x.Title, x.Body, x.Enabled, string(x.Status), x.Interpretation, x.Clarified, qs,
			x.Rounds, x.Revision, x.Error, x.AnalyzedAt, string(x.Kind)); err != nil {
			return err
		}
		if out, err = scanRule(tx.QueryRow(ctx, `SELECT `+ruleCols+ruleFrom+` WHERE x.id = $1`, id)); err != nil {
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

// DeleteRule removes a rule and records ev.
func (s *Rules) DeleteRule(ctx context.Context, id int64, ev domain.Event) error {
	return pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		tag, err := tx.Exec(ctx, `DELETE FROM rules WHERE id = $1`, id)
		if err != nil {
			return err
		}
		if tag.RowsAffected() == 0 {
			return domain.ErrNotFound
		}
		return insertEvent(ctx, tx, ev)
	})
}

// ClaimRule moves the oldest pending rule to analyzing and returns it; ok is
// false when none is waiting.
func (s *Rules) ClaimRule(ctx context.Context) (domain.Rule, bool, error) {
	var id int64
	err := s.db.QueryRow(ctx, `UPDATE rules SET status = 'analyzing', updated_at = now()
		WHERE id = (SELECT id FROM rules WHERE status = 'pending' ORDER BY updated_at, id LIMIT 1 FOR UPDATE SKIP LOCKED)
		RETURNING id`).Scan(&id)
	if errors.Is(err, pgx.ErrNoRows) {
		return domain.Rule{}, false, nil
	}
	if err != nil {
		return domain.Rule{}, false, err
	}
	x, err := s.Rule(ctx, id)
	return x, err == nil, err
}

// PendingRuleWorkspaces returns the workspaces with rules waiting for a
// review (a system context sees them all).
func (s *Rules) PendingRuleWorkspaces(ctx context.Context) ([]int64, error) {
	rows, err := s.db.Query(ctx, `SELECT DISTINCT workspace_id FROM rules WHERE status = 'pending' ORDER BY 1`)
	if err != nil {
		return nil, err
	}
	return pgx.CollectRows(rows, pgx.RowTo[int64])
}

// RecoverRules requeues reviews a crash left running.
func (s *Rules) RecoverRules(ctx context.Context) (int, error) {
	tag, err := s.db.Exec(ctx, `UPDATE rules SET status = 'pending', updated_at = now() WHERE status = 'analyzing'`)
	return int(tag.RowsAffected()), err
}
