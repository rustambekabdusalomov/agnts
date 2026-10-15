package postgres

import (
	"context"
	"encoding/json"
	"errors"
	"strconv"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"agnts/internal/domain"
	"agnts/internal/secret"
)

// SwaggerTests stores Swagger tests, their sealed credentials and what
// their runs found.
type SwaggerTests struct {
	db  *pgxpool.Pool
	box *secret.Box
}

// NewSwaggerTests returns the Swagger test store.
func NewSwaggerTests(db *pgxpool.Pool, box *secret.Box) *SwaggerTests {
	return &SwaggerTests{db: db, box: box}
}

// swaggerAAD binds a sealed credential to its ticket: copied to another
// ticket's row, it does not open.
func swaggerAAD(ticketID int64) []byte {
	return []byte("swagger-test:" + strconv.FormatInt(ticketID, 10))
}

const swaggerCols = `ticket_id, spec_url, spec, base_url, operations, write_enabled, auth_kind, auth_name,
	auth_sealed IS NOT NULL, rate_limit, max_requests, suite_id, created_at`

func scanSwaggerTest(row pgx.Row) (domain.SwaggerTest, error) {
	var st domain.SwaggerTest
	var ops []byte
	err := row.Scan(&st.TicketID, &st.SpecURL, &st.Spec, &st.BaseURL, &ops, &st.WriteEnabled, &st.Auth.Kind, &st.Auth.Name,
		&st.HasSecret, &st.RateLimit, &st.MaxRequests, &st.SuiteID, &st.CreatedAt)
	if err != nil {
		return st, notFound(err)
	}
	_ = json.Unmarshal(ops, &st.Operations)
	return st, nil
}

// SaveSwaggerTest stores a ticket's test. A non-nil secret replaces the
// credential (an empty one removes it); nil keeps it.
func (s *SwaggerTests) SaveSwaggerTest(ctx context.Context, st domain.SwaggerTest, cred *string) error {
	ops, err := json.Marshal(st.Operations)
	if err != nil {
		return err
	}
	var sealed []byte
	if cred != nil && *cred != "" {
		if sealed, err = s.box.Seal([]byte(*cred), swaggerAAD(st.TicketID)); err != nil {
			return err
		}
	}
	_, err = s.db.Exec(ctx, `INSERT INTO swagger_tests
		(ticket_id, spec_url, spec, base_url, operations, write_enabled, auth_kind, auth_name, auth_sealed, secret_v, rate_limit, max_requests, suite_id)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, 2, $10, $11, $12)
		ON CONFLICT (ticket_id) DO UPDATE SET spec_url = EXCLUDED.spec_url, spec = EXCLUDED.spec, base_url = EXCLUDED.base_url,
			operations = EXCLUDED.operations, write_enabled = EXCLUDED.write_enabled, auth_kind = EXCLUDED.auth_kind,
			auth_name = EXCLUDED.auth_name, rate_limit = EXCLUDED.rate_limit, max_requests = EXCLUDED.max_requests,
			suite_id = EXCLUDED.suite_id,
			auth_sealed = CASE WHEN $13 THEN EXCLUDED.auth_sealed ELSE swagger_tests.auth_sealed END`,
		st.TicketID, st.SpecURL, []byte(st.Spec), st.BaseURL, ops, st.WriteEnabled, string(st.Auth.Kind), st.Auth.Name, sealed,
		st.RateLimit, st.MaxRequests, st.SuiteID, cred != nil)
	return err
}

// SwaggerTest returns a ticket's test (the credential stays sealed).
func (s *SwaggerTests) SwaggerTest(ctx context.Context, ticketID int64) (domain.SwaggerTest, error) {
	return scanSwaggerTest(s.db.QueryRow(ctx, `SELECT `+swaggerCols+` FROM swagger_tests WHERE ticket_id = $1`, ticketID))
}

// SwaggerTestAuth opens a ticket's credential ("" when it has none). Only
// the orchestrator calls it, to hand the credential to agnts-api.
func (s *SwaggerTests) SwaggerTestAuth(ctx context.Context, ticketID int64) (string, error) {
	var sealed []byte
	if err := s.db.QueryRow(ctx, `SELECT auth_sealed FROM swagger_tests WHERE ticket_id = $1`, ticketID).Scan(&sealed); err != nil {
		return "", notFound(err)
	}
	if sealed == nil {
		return "", nil
	}
	b, err := s.box.Open(sealed, swaggerAAD(ticketID))
	if err != nil {
		return "", errors.New("the stored credential cannot be opened (the server key changed?): enter it again")
	}
	return string(b), nil
}

// SetSwaggerTestAuth replaces a ticket's credential.
func (s *SwaggerTests) SetSwaggerTestAuth(ctx context.Context, ticketID int64, cred string) error {
	var sealed []byte
	if cred != "" {
		var err error
		if sealed, err = s.box.Seal([]byte(cred), swaggerAAD(ticketID)); err != nil {
			return err
		}
	}
	tag, err := s.db.Exec(ctx, `UPDATE swagger_tests SET auth_sealed = $2, secret_v = 2 WHERE ticket_id = $1`, ticketID, sealed)
	if err == nil && tag.RowsAffected() == 0 {
		return domain.ErrNotFound
	}
	return err
}

// DeleteSwaggerTestAuth deletes a ticket's credential.
func (s *SwaggerTests) DeleteSwaggerTestAuth(ctx context.Context, ticketID int64) error {
	_, err := s.db.Exec(ctx, `UPDATE swagger_tests SET auth_sealed = NULL WHERE ticket_id = $1`, ticketID)
	return err
}

const swaggerRunCols = `run_id, ticket_id, results, passed, failed, skipped, blocked, log, plan, created_at`

func scanSwaggerRun(row pgx.Row, withLog bool) (domain.SwaggerRun, error) {
	var r domain.SwaggerRun
	var res, log, plan []byte
	err := row.Scan(&r.RunID, &r.TicketID, &res, &r.Counts.Passed, &r.Counts.Failed, &r.Counts.Skipped, &r.Counts.Blocked, &log, &plan, &r.CreatedAt)
	if err != nil {
		return r, notFound(err)
	}
	_ = json.Unmarshal(res, &r.Results)
	if withLog {
		_ = json.Unmarshal(log, &r.Log)
	}
	r.Plan = plan
	return r, nil
}

// SaveSwaggerResults stores a run's checked results and redacted log.
func (s *SwaggerTests) SaveSwaggerResults(ctx context.Context, r domain.SwaggerRun) error {
	res, err := json.Marshal(r.Results)
	if err != nil {
		return err
	}
	if r.Log == nil {
		r.Log = []domain.APIExchange{}
	}
	log, err := json.Marshal(domain.CapLog(r.Log, domain.MaxAPILogBytes))
	if err != nil {
		return err
	}
	var plan []byte
	if len(r.Plan) > 0 && json.Valid(r.Plan) {
		plan = r.Plan
	}
	c := r.Results.Counts()
	_, err = s.db.Exec(ctx, `INSERT INTO swagger_test_results (run_id, ticket_id, results, passed, failed, skipped, blocked, log, plan)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
		ON CONFLICT (run_id) DO UPDATE SET results = EXCLUDED.results, passed = EXCLUDED.passed, failed = EXCLUDED.failed,
			skipped = EXCLUDED.skipped, blocked = EXCLUDED.blocked, log = EXCLUDED.log, plan = EXCLUDED.plan`,
		r.RunID, r.TicketID, res, c.Passed, c.Failed, c.Skipped, c.Blocked, log, plan)
	return err
}

// SwaggerResults returns a ticket's latest results with their log.
func (s *SwaggerTests) SwaggerResults(ctx context.Context, ticketID int64) (domain.SwaggerRun, error) {
	return scanSwaggerRun(s.db.QueryRow(ctx, `SELECT `+swaggerRunCols+` FROM swagger_test_results
		WHERE ticket_id = $1 ORDER BY run_id DESC LIMIT 1`, ticketID), true)
}

// SwaggerResultsBefore returns a ticket's results from the run before
// runID, without the log (for comparing runs).
func (s *SwaggerTests) SwaggerResultsBefore(ctx context.Context, ticketID, runID int64) (domain.SwaggerRun, error) {
	return scanSwaggerRun(s.db.QueryRow(ctx, `SELECT `+swaggerRunCols+` FROM swagger_test_results
		WHERE ticket_id = $1 AND run_id < $2 ORDER BY run_id DESC LIMIT 1`, ticketID, runID), false)
}

// SuiteResultsBefore returns the latest results of a suite's tests from
// before runID, with the plan they sent (for reuse and comparison).
func (s *SwaggerTests) SuiteResultsBefore(ctx context.Context, suiteID, runID int64) (domain.SwaggerRun, error) {
	return scanSwaggerRun(s.db.QueryRow(ctx, `SELECT r.run_id, r.ticket_id, r.results, r.passed, r.failed, r.skipped, r.blocked, r.log, r.plan, r.created_at
		FROM swagger_test_results r JOIN swagger_tests t ON t.ticket_id = r.ticket_id
		WHERE t.suite_id = $1 AND r.run_id < $2 ORDER BY r.run_id DESC LIMIT 1`, suiteID, runID), false)
}
