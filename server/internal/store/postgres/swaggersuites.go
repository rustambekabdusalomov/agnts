package postgres

import (
	"context"
	"encoding/json"
	"errors"
	"strconv"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"agnts/internal/domain"
	"agnts/internal/orchestrator"
	"agnts/internal/secret"
)

var _ orchestrator.SwaggerSuites = (*SwaggerSuites)(nil)

// SwaggerSuites stores saved Swagger test suites.
type SwaggerSuites struct {
	db  *pgxpool.Pool
	box *secret.Box
}

// NewSwaggerSuites returns the suite store.
func NewSwaggerSuites(db *pgxpool.Pool, box *secret.Box) *SwaggerSuites {
	return &SwaggerSuites{db: db, box: box}
}

func suiteAAD(id int64) []byte { return []byte("swagger-suite:" + strconv.FormatInt(id, 10)) }

const suiteCols = `id, workspace_id, name, spec_url, spec, base_url, operations, write_enabled, auth_kind, auth_name, auth_sealed IS NOT NULL,
	rate_limit, max_requests, repo_id, notes, schedule, hour, enabled, hook_hash <> '', last_run_at, next_run_at, last_ticket, created_at`

// suiteRow is a suite with its workspace (the due list spans workspaces).
type suiteRow struct {
	domain.SwaggerSuite
	Workspace int64
}

func scanSuite(row pgx.Row) (suiteRow, error) {
	var s suiteRow
	var ops []byte
	err := row.Scan(&s.ID, &s.Workspace, &s.Name, &s.SpecURL, &s.Spec, &s.BaseURL, &ops, &s.WriteEnabled, &s.Auth.Kind, &s.Auth.Name, &s.HasSecret,
		&s.RateLimit, &s.MaxRequests, &s.RepoID, &s.Notes, &s.Schedule, &s.Hour, &s.Enabled, &s.HookSet, &s.LastRunAt, &s.NextRunAt,
		&s.LastTicketKey, &s.CreatedAt)
	if err != nil {
		return s, notFound(err)
	}
	_ = json.Unmarshal(ops, &s.Operations)
	return s, nil
}

// SaveSuite creates (ID 0) or updates a suite; a non-nil cred replaces its
// credential. The next run follows the schedule.
func (s *SwaggerSuites) SaveSuite(ctx context.Context, su domain.SwaggerSuite, cred *string) (domain.SwaggerSuite, error) {
	ops, err := json.Marshal(su.Operations)
	if err != nil {
		return su, err
	}
	next := su.Schedule.NextRun(time.Now(), su.Hour)
	var createdBy *int64
	if a, ok := domain.ActorOf(ctx); ok && a.UserID > 0 {
		createdBy = &a.UserID
	}
	err = pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		if su.ID == 0 {
			if err := tx.QueryRow(ctx, `INSERT INTO swagger_suites (name, spec_url, spec, base_url, operations, write_enabled, auth_kind, auth_name,
				rate_limit, max_requests, repo_id, notes, schedule, hour, enabled, next_run_at, created_by)
				VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17) RETURNING id`,
				su.Name, su.SpecURL, []byte(su.Spec), su.BaseURL, ops, su.WriteEnabled, string(su.Auth.Kind), su.Auth.Name, su.RateLimit, su.MaxRequests,
				su.RepoID, su.Notes, string(su.Schedule), su.Hour, su.Enabled, next, createdBy).Scan(&su.ID); err != nil {
				return err
			}
		} else {
			tag, err := tx.Exec(ctx, `UPDATE swagger_suites SET name = $2, base_url = $3, operations = $4, write_enabled = $5, auth_kind = $6, auth_name = $7,
				rate_limit = $8, max_requests = $9, repo_id = $10, notes = $11, schedule = $12, hour = $13, enabled = $14, next_run_at = $15, updated_at = now()
				WHERE id = $1`, su.ID, su.Name, su.BaseURL, ops, su.WriteEnabled, string(su.Auth.Kind), su.Auth.Name, su.RateLimit, su.MaxRequests,
				su.RepoID, su.Notes, string(su.Schedule), su.Hour, su.Enabled, next)
			if err != nil {
				return err
			}
			if tag.RowsAffected() == 0 {
				return domain.ErrNotFound
			}
		}
		if cred == nil {
			return nil
		}
		var sealed []byte
		if *cred != "" {
			var err error
			if sealed, err = s.box.Seal([]byte(*cred), suiteAAD(su.ID)); err != nil {
				return err
			}
		}
		_, err := tx.Exec(ctx, `UPDATE swagger_suites SET auth_sealed = $2 WHERE id = $1`, su.ID, sealed)
		return err
	})
	if err != nil {
		return su, err
	}
	return s.Suite(ctx, su.ID)
}

// Suite returns one suite of the workspace ctx acts in.
func (s *SwaggerSuites) Suite(ctx context.Context, id int64) (domain.SwaggerSuite, error) {
	r, err := scanSuite(s.db.QueryRow(ctx, `SELECT `+suiteCols+` FROM swagger_suites WHERE id = $1`, id))
	return r.SwaggerSuite, err
}

// Suites lists the workspace's suites by name.
func (s *SwaggerSuites) Suites(ctx context.Context) ([]domain.SwaggerSuite, error) {
	rows, err := s.db.Query(ctx, `SELECT `+suiteCols+` FROM swagger_suites ORDER BY lower(name), id LIMIT 500`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := []domain.SwaggerSuite{}
	for rows.Next() {
		r, err := scanSuite(rows)
		if err != nil {
			return nil, err
		}
		r.Spec = nil // lists do not carry the spec
		out = append(out, r.SwaggerSuite)
	}
	return out, rows.Err()
}

// DeleteSuite deletes a suite; its past runs stay, unlinked.
func (s *SwaggerSuites) DeleteSuite(ctx context.Context, id int64) error {
	tag, err := s.db.Exec(ctx, `DELETE FROM swagger_suites WHERE id = $1`, id)
	if err == nil && tag.RowsAffected() == 0 {
		return domain.ErrNotFound
	}
	return err
}

// SuiteAuth opens a suite's credential ("" when it has none).
func (s *SwaggerSuites) SuiteAuth(ctx context.Context, id int64) (string, error) {
	var sealed []byte
	if err := s.db.QueryRow(ctx, `SELECT auth_sealed FROM swagger_suites WHERE id = $1`, id).Scan(&sealed); err != nil {
		return "", notFound(err)
	}
	if sealed == nil {
		return "", nil
	}
	b, err := s.box.Open(sealed, suiteAAD(id))
	if err != nil {
		return "", errors.New("the suite's stored token cannot be opened (the server key changed?): enter it again")
	}
	return string(b), nil
}

// SetSuiteHook stores the hash of a new deploy hook token ("" removes it).
func (s *SwaggerSuites) SetSuiteHook(ctx context.Context, id int64, hash string) error {
	tag, err := s.db.Exec(ctx, `UPDATE swagger_suites SET hook_hash = $2, updated_at = now() WHERE id = $1`, id, hash)
	if err == nil && tag.RowsAffected() == 0 {
		return domain.ErrNotFound
	}
	return err
}

// SuiteByHook finds the suite a deploy hook token's hash belongs to, in any
// workspace, and its workspace.
func (s *SwaggerSuites) SuiteByHook(ctx context.Context, hash string) (domain.SwaggerSuite, int64, error) {
	if hash == "" {
		return domain.SwaggerSuite{}, 0, domain.ErrNotFound
	}
	r, err := scanSuite(s.db.QueryRow(domain.System(ctx), `SELECT `+suiteCols+` FROM swagger_suites WHERE hook_hash = $1`, hash))
	return r.SwaggerSuite, r.Workspace, err
}

// DueSuites lists the enabled suites whose next scheduled run is due, in
// every workspace.
func (s *SwaggerSuites) DueSuites(ctx context.Context, now time.Time) ([]orchestrator.DueSuite, error) {
	rows, err := s.db.Query(domain.System(ctx), `SELECT id, workspace_id FROM swagger_suites
		WHERE enabled AND schedule <> 'off' AND next_run_at IS NOT NULL AND next_run_at <= $1 ORDER BY next_run_at LIMIT 100`, now)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var out []orchestrator.DueSuite
	for rows.Next() {
		var d orchestrator.DueSuite
		if err := rows.Scan(&d.ID, &d.Workspace); err != nil {
			return nil, err
		}
		out = append(out, d)
	}
	return out, rows.Err()
}

// MarkSuiteRun records a run started (ticket key "" when it was skipped)
// and moves the next scheduled run.
func (s *SwaggerSuites) MarkSuiteRun(ctx context.Context, id int64, ticketKey string, at time.Time) error {
	su, err := s.Suite(ctx, id)
	if err != nil {
		return err
	}
	next := su.Schedule.NextRun(at, su.Hour)
	if ticketKey == "" {
		_, err = s.db.Exec(ctx, `UPDATE swagger_suites SET next_run_at = $2 WHERE id = $1`, id, next)
		return err
	}
	_, err = s.db.Exec(ctx, `UPDATE swagger_suites SET last_run_at = $2, last_ticket = $3, next_run_at = $4 WHERE id = $1`, id, at, ticketKey, next)
	return err
}
