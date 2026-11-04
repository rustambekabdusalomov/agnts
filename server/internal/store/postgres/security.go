package postgres

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"strings"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"agnts/internal/domain"
)

// Security stores security scans and findings.
type Security struct{ db *pgxpool.Pool }

// NewSecurity returns the security store.
func NewSecurity(db *pgxpool.Pool) *Security { return &Security{db: db} }

const secScanCols = `s.id, s.workspace_id, s.repo_id, r.name, s.trigger, s.scope, s.ran, s.status, s.commit_sha, s.db_versions,
	s.counts, s.summary, s.rejected, s.error, s.provider, s.created_by, s.created_at, s.started_at, s.finished_at`

const secScanFrom = ` FROM security_scans s JOIN repositories r ON r.id = s.repo_id`

func scanScan(row pgx.Row) (domain.SecurityScan, error) {
	var s domain.SecurityScan
	var trigger, status string
	var scope, ran, dbv, counts, rejected []byte
	err := row.Scan(&s.ID, &s.WorkspaceID, &s.RepoID, &s.RepoName, &trigger, &scope, &ran, &status, &s.Commit, &dbv,
		&counts, &s.Summary, &rejected, &s.Error, &s.Provider, &s.CreatedBy, &s.CreatedAt, &s.StartedAt, &s.FinishedAt)
	if err != nil {
		return s, notFound(err)
	}
	s.Trigger, s.Status = domain.SecScanTrigger(trigger), domain.SecScanStatus(status)
	_ = json.Unmarshal(scope, &s.Scope)
	_ = json.Unmarshal(ran, &s.Ran)
	_ = json.Unmarshal(dbv, &s.DBVersions)
	_ = json.Unmarshal(counts, &s.Counts)
	_ = json.Unmarshal(rejected, &s.Rejected)
	return s, nil
}

func secJSON(v any) []byte {
	b, err := json.Marshal(v)
	if err != nil || string(b) == "null" {
		return []byte("{}")
	}
	return b
}

// CreateSecurityScan queues a scan. A repository with a manual or
// scheduled scan already queued or running gets that one back (busy
// true); verify scans always queue.
func (st *Security) CreateSecurityScan(ctx context.Context, s domain.SecurityScan) (out domain.SecurityScan, busy bool, err error) {
	err = pgx.BeginFunc(ctx, st.db, func(tx pgx.Tx) error {
		// One queue per repository: lock it while checking.
		var ws int64
		if err := tx.QueryRow(ctx, `SELECT workspace_id FROM repositories WHERE id = $1 FOR UPDATE`, s.RepoID).Scan(&ws); err != nil {
			return notFound(err)
		}
		if s.Trigger != domain.SecVerify {
			cur, err := scanScan(tx.QueryRow(ctx, `SELECT `+secScanCols+secScanFrom+` WHERE s.repo_id = $1 AND s.status IN ('pending', 'running')
				AND s.trigger <> 'verify' ORDER BY s.id LIMIT 1`, s.RepoID))
			if err == nil {
				out, busy = cur, true
				return nil
			}
			if !errors.Is(err, domain.ErrNotFound) {
				return err
			}
		}
		rejected, _ := json.Marshal(s.Rejected)
		if s.Rejected == nil {
			rejected = []byte("[]")
		}
		var id int64
		if err := tx.QueryRow(ctx, `INSERT INTO security_scans (workspace_id, repo_id, trigger, scope, created_by, rejected)
			VALUES ($1, $2, $3, $4, $5, $6) RETURNING id`, ws, s.RepoID, string(s.Trigger), secJSON(s.Scope), s.CreatedBy, rejected).Scan(&id); err != nil {
			return err
		}
		out, err = scanScan(tx.QueryRow(ctx, `SELECT `+secScanCols+secScanFrom+` WHERE s.id = $1`, id))
		return err
	})
	return out, busy, err
}

// SecurityScan returns a scan.
func (st *Security) SecurityScan(ctx context.Context, id int64) (domain.SecurityScan, error) {
	return scanScan(st.db.QueryRow(ctx, `SELECT `+secScanCols+secScanFrom+` WHERE s.id = $1`, id))
}

// SecurityScans returns a repository's scans, newest first.
func (st *Security) SecurityScans(ctx context.Context, repoID int64, limit int) ([]domain.SecurityScan, error) {
	if limit <= 0 || limit > 200 {
		limit = 50
	}
	rows, err := st.db.Query(ctx, `SELECT `+secScanCols+secScanFrom+` WHERE s.repo_id = $1 ORDER BY s.id DESC LIMIT $2`, repoID, limit)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var out []domain.SecurityScan
	for rows.Next() {
		s, err := scanScan(rows)
		if err != nil {
			return nil, err
		}
		out = append(out, s)
	}
	return out, rows.Err()
}

// LastFullScan returns a repository's last finished scan that was not a
// verify scan, or domain.ErrNotFound.
func (st *Security) LastFullScan(ctx context.Context, repoID int64) (domain.SecurityScan, error) {
	return scanScan(st.db.QueryRow(ctx, `SELECT `+secScanCols+secScanFrom+` WHERE s.repo_id = $1 AND s.status = 'done'
		AND s.trigger <> 'verify' ORDER BY s.id DESC LIMIT 1`, repoID))
}

// ClaimSecurityScan moves the oldest pending scan to running.
func (st *Security) ClaimSecurityScan(ctx context.Context) (domain.SecurityScan, bool, error) {
	var id int64
	err := st.db.QueryRow(ctx, `UPDATE security_scans SET status = 'running', started_at = now()
		WHERE id = (SELECT id FROM security_scans WHERE status = 'pending' ORDER BY created_at, id LIMIT 1 FOR UPDATE SKIP LOCKED)
		RETURNING id`).Scan(&id)
	if errors.Is(err, pgx.ErrNoRows) {
		return domain.SecurityScan{}, false, nil
	}
	if err != nil {
		return domain.SecurityScan{}, false, err
	}
	s, err := st.SecurityScan(ctx, id)
	return s, err == nil, err
}

// PendingSecurityWorkspaces returns the workspaces with scans waiting.
func (st *Security) PendingSecurityWorkspaces(ctx context.Context) ([]int64, error) {
	rows, err := st.db.Query(ctx, `SELECT DISTINCT workspace_id FROM security_scans WHERE status = 'pending' ORDER BY 1`)
	if err != nil {
		return nil, err
	}
	return pgx.CollectRows(rows, pgx.RowTo[int64])
}

// RecoverSecurityScans requeues scans a crash left running.
func (st *Security) RecoverSecurityScans(ctx context.Context) (int, error) {
	tag, err := st.db.Exec(ctx, `UPDATE security_scans SET status = 'pending', started_at = NULL WHERE status = 'running'`)
	return int(tag.RowsAffected()), err
}

// RequeueSecurityScan puts a running scan back in the queue (usage
// limits stopped it).
func (st *Security) RequeueSecurityScan(ctx context.Context, id int64) error {
	_, err := st.db.Exec(ctx, `UPDATE security_scans SET status = 'pending', started_at = NULL WHERE id = $1 AND status = 'running'`, id)
	return err
}

// CancelSecurityScan cancels a queued or running scan; a running one
// stops at its next step and saves nothing.
func (st *Security) CancelSecurityScan(ctx context.Context, id int64) (domain.SecurityScan, error) {
	tag, err := st.db.Exec(ctx, `UPDATE security_scans SET status = 'cancelled', finished_at = now()
		WHERE id = $1 AND status IN ('pending', 'running')`, id)
	if err != nil {
		return domain.SecurityScan{}, err
	}
	s, err := st.SecurityScan(ctx, id)
	if err == nil && tag.RowsAffected() == 0 && s.Status != domain.ScanCancelled {
		return s, fmt.Errorf("%w: the scan already finished", domain.ErrConflict)
	}
	return s, err
}

// FinishSecurityScan saves a scan's result in one transaction: it locks
// the scan (which must still be running) and the repository's findings,
// lets apply decide what changes (domain.ReconcileSecurity), saves the
// findings and the scan, and appends the event ev builds (nil for none).
// apply is nil for a scan that failed: only the scan is saved.
func (st *Security) FinishSecurityScan(ctx context.Context, s domain.SecurityScan,
	apply func(existing []domain.SecurityFinding) ([]domain.SecurityFinding, domain.SecCounts),
	ev func(domain.SecurityScan) *domain.Event) (domain.SecurityScan, error) {
	var out domain.SecurityScan
	err := pgx.BeginFunc(ctx, st.db, func(tx pgx.Tx) error {
		var status string
		if err := tx.QueryRow(ctx, `SELECT status FROM security_scans WHERE id = $1 FOR UPDATE`, s.ID).Scan(&status); err != nil {
			return notFound(err)
		}
		if status != string(domain.ScanRunning) {
			return domain.ErrScanStale
		}
		if apply != nil {
			existing, err := findingsTx(ctx, tx, domain.SecFindingFilter{RepoID: s.RepoID}, true)
			if err != nil {
				return err
			}
			save, counts := apply(existing)
			s.Counts = counts
			for _, f := range save {
				if err := saveFinding(ctx, tx, s.WorkspaceID, f); err != nil {
					return err
				}
			}
		}
		rejected, _ := json.Marshal(s.Rejected)
		if s.Rejected == nil {
			rejected = []byte("[]")
		}
		if _, err := tx.Exec(ctx, `UPDATE security_scans SET status = $2, ran = $3, commit_sha = $4, db_versions = $5, counts = $6,
			summary = $7, rejected = $8, error = $9, provider = $10, finished_at = now() WHERE id = $1`,
			s.ID, string(s.Status), secJSON(s.Ran), s.Commit, secJSON(s.DBVersions), secJSON(s.Counts), s.Summary, rejected,
			s.Error, s.Provider); err != nil {
			return err
		}
		var err error
		if out, err = scanScan(tx.QueryRow(ctx, `SELECT `+secScanCols+secScanFrom+` WHERE s.id = $1`, s.ID)); err != nil {
			return err
		}
		if ev != nil {
			if e := ev(out); e != nil {
				return insertEvent(ctx, tx, *e)
			}
		}
		return nil
	})
	return out, err
}

func saveFinding(ctx context.Context, tx pgx.Tx, ws int64, f domain.SecurityFinding) error {
	data, err := json.Marshal(f.Data)
	if err != nil {
		return err
	}
	if f.ID == 0 {
		_, err = tx.Exec(ctx, `INSERT INTO security_findings (workspace_id, repo_id, fingerprint, severity, category, source, symbol, data,
			status, first_seen, last_seen, last_checked, last_scan_id)
			VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13)
			ON CONFLICT (repo_id, fingerprint) DO UPDATE SET last_seen = EXCLUDED.last_seen, last_checked = EXCLUDED.last_checked,
				last_scan_id = EXCLUDED.last_scan_id, updated_at = now()`,
			ws, f.RepoID, f.Fingerprint, string(f.Severity), f.Category, string(f.Source), f.Symbol, data, string(f.Status),
			f.FirstSeen, f.LastSeen, f.LastChecked, f.LastScanID)
		return err
	}
	_, err = tx.Exec(ctx, `UPDATE security_findings SET severity = $2, category = $3, source = $4, symbol = $5, data = $6, status = $7,
		ticket_key = $8, last_seen = $9, last_checked = $10, last_scan_id = $11, updated_at = now() WHERE id = $1`,
		f.ID, string(f.Severity), f.Category, string(f.Source), f.Symbol, data, string(f.Status), f.TicketKey, f.LastSeen,
		f.LastChecked, f.LastScanID)
	return err
}

const secFindingCols = `f.id, f.workspace_id, f.repo_id, r.name, f.fingerprint, f.severity, f.category, f.source, f.symbol, f.data,
	f.status, f.dismiss_reason, f.dismiss_note, f.dismissed_by, f.ticket_key, f.first_seen, f.last_seen, f.last_checked,
	f.last_scan_id, f.updated_at`

const secFindingFrom = ` FROM security_findings f JOIN repositories r ON r.id = f.repo_id`

func scanSecFinding(row pgx.Row) (domain.SecurityFinding, error) {
	var f domain.SecurityFinding
	var sev, source, status string
	var data []byte
	err := row.Scan(&f.ID, &f.WorkspaceID, &f.RepoID, &f.RepoName, &f.Fingerprint, &sev, &f.Category, &source, &f.Symbol, &data,
		&status, &f.DismissReason, &f.DismissNote, &f.DismissedBy, &f.TicketKey, &f.FirstSeen, &f.LastSeen, &f.LastChecked,
		&f.LastScanID, &f.UpdatedAt)
	if err != nil {
		return f, notFound(err)
	}
	f.Severity, f.Source, f.Status = domain.SecSeverity(sev), domain.SecSource(source), domain.SecStatus(status)
	_ = json.Unmarshal(data, &f.Data)
	return f, nil
}

type secQuerier interface {
	Query(ctx context.Context, sql string, args ...any) (pgx.Rows, error)
}

func findingsTx(ctx context.Context, q secQuerier, flt domain.SecFindingFilter, lock bool) ([]domain.SecurityFinding, error) {
	var where []string
	var args []any
	arg := func(v any) string {
		args = append(args, v)
		return fmt.Sprintf("$%d", len(args))
	}
	if flt.RepoID != 0 {
		where = append(where, "f.repo_id = "+arg(flt.RepoID))
	}
	if flt.Status != "" {
		where = append(where, "f.status = "+arg(string(flt.Status)))
	}
	if flt.Severity != "" {
		where = append(where, "f.severity = "+arg(string(flt.Severity)))
	}
	if flt.Active {
		where = append(where, "f.status IN ('open', 'fixing', 'verifying', 'reopened')")
	}
	if len(flt.IDs) > 0 {
		where = append(where, "f.id = ANY("+arg(flt.IDs)+")")
	}
	sql := `SELECT ` + secFindingCols + secFindingFrom
	if len(where) > 0 {
		sql += " WHERE " + strings.Join(where, " AND ")
	}
	sql += " ORDER BY f.id"
	if flt.Limit > 0 {
		sql += " LIMIT " + arg(flt.Limit)
	}
	if lock {
		sql += " FOR UPDATE OF f"
	}
	rows, err := q.Query(ctx, sql, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var out []domain.SecurityFinding
	for rows.Next() {
		f, err := scanSecFinding(rows)
		if err != nil {
			return nil, err
		}
		out = append(out, f)
	}
	return out, rows.Err()
}

// SecurityFindings lists findings, worst first.
func (st *Security) SecurityFindings(ctx context.Context, flt domain.SecFindingFilter) ([]domain.SecurityFinding, error) {
	if flt.Limit <= 0 || flt.Limit > 2000 {
		flt.Limit = 1000
	}
	fs, err := findingsTx(ctx, st.db, flt, false)
	domain.SortFindings(fs)
	return fs, err
}

// SecurityFinding returns a finding.
func (st *Security) SecurityFinding(ctx context.Context, id int64) (domain.SecurityFinding, error) {
	return scanSecFinding(st.db.QueryRow(ctx, `SELECT `+secFindingCols+secFindingFrom+` WHERE f.id = $1`, id))
}

// FindingsByTicket returns the findings a fix ticket works on.
func (st *Security) FindingsByTicket(ctx context.Context, key string) ([]domain.SecurityFinding, error) {
	rows, err := st.db.Query(ctx, `SELECT `+secFindingCols+secFindingFrom+` WHERE f.ticket_key = $1 ORDER BY f.id`, key)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var out []domain.SecurityFinding
	for rows.Next() {
		f, err := scanSecFinding(rows)
		if err != nil {
			return nil, err
		}
		out = append(out, f)
	}
	return out, rows.Err()
}

// FixingTickets returns the ticket keys of findings being fixed, across
// every workspace the context sees.
func (st *Security) FixingTickets(ctx context.Context) ([]domain.TicketRef, error) {
	rows, err := st.db.Query(ctx, `SELECT DISTINCT workspace_id, ticket_key FROM security_findings
		WHERE status = 'fixing' AND ticket_key <> '' ORDER BY 1, 2`)
	if err != nil {
		return nil, err
	}
	return pgx.CollectRows(rows, func(r pgx.CollectableRow) (domain.TicketRef, error) {
		var t domain.TicketRef
		err := r.Scan(&t.WorkspaceID, &t.Key)
		return t, err
	})
}

// UpdateSecurityFindings applies mut to each locked finding of ids (in
// one repository's or several) and saves them with the event ev builds
// (nil for none), in one transaction. mut's error aborts it.
func (st *Security) UpdateSecurityFindings(ctx context.Context, ids []int64, mut func(*domain.SecurityFinding) error,
	ev func([]domain.SecurityFinding) *domain.Event) ([]domain.SecurityFinding, error) {
	var out []domain.SecurityFinding
	err := pgx.BeginFunc(ctx, st.db, func(tx pgx.Tx) error {
		fs, err := findingsTx(ctx, tx, domain.SecFindingFilter{IDs: ids}, true)
		if err != nil {
			return err
		}
		if len(fs) != len(ids) {
			return domain.ErrNotFound
		}
		for i := range fs {
			if err := mut(&fs[i]); err != nil {
				return err
			}
			data, _ := json.Marshal(fs[i].Data)
			f := fs[i]
			if _, err := tx.Exec(ctx, `UPDATE security_findings SET status = $2, dismiss_reason = $3, dismiss_note = $4, dismissed_by = $5,
				ticket_key = $6, data = $7, updated_at = now() WHERE id = $1`,
				f.ID, string(f.Status), f.DismissReason, f.DismissNote, f.DismissedBy, f.TicketKey, data); err != nil {
				return err
			}
		}
		out = fs
		if ev != nil {
			if e := ev(fs); e != nil {
				return insertEvent(ctx, tx, *e)
			}
		}
		return nil
	})
	return out, err
}

// SecuritySummary is one repository's active findings by severity and
// its last scan.
type SecuritySummary struct {
	RepoID     int64
	RepoName   string
	Open       map[domain.SecSeverity]int
	LastScanID *int64
}

// SecuritySummaries returns every repository that is not archived, with
// its active findings and last scan (nil when never scanned).
func (st *Security) SecuritySummaries(ctx context.Context) ([]SecuritySummary, error) {
	rows, err := st.db.Query(ctx, `SELECT r.id, r.name,
			(SELECT max(s.id) FROM security_scans s WHERE s.repo_id = r.id),
			count(f.id) FILTER (WHERE f.severity = 'critical'), count(f.id) FILTER (WHERE f.severity = 'high'),
			count(f.id) FILTER (WHERE f.severity = 'medium'), count(f.id) FILTER (WHERE f.severity = 'low'),
			count(f.id) FILTER (WHERE f.severity = 'info')
		FROM repositories r
		LEFT JOIN security_findings f ON f.repo_id = r.id AND f.status IN ('open', 'fixing', 'verifying', 'reopened')
		WHERE r.archived_at IS NULL
		GROUP BY r.id, r.name ORDER BY r.name`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var out []SecuritySummary
	for rows.Next() {
		var x SecuritySummary
		var c, h, m, l, i int
		if err := rows.Scan(&x.RepoID, &x.RepoName, &x.LastScanID, &c, &h, &m, &l, &i); err != nil {
			return nil, err
		}
		x.Open = map[domain.SecSeverity]int{domain.SecCritical: c, domain.SecHigh: h, domain.SecMedium: m, domain.SecLow: l, domain.SecInfo: i}
		out = append(out, x)
	}
	return out, rows.Err()
}
