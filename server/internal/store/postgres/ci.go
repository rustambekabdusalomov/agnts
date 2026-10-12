package postgres

import (
	"context"
	"encoding/json"
	"errors"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"agnts/internal/domain"
	"agnts/internal/secret"
)

// CI stores CI watches and failure groups. Log samples are sealed.
type CI struct {
	db  *pgxpool.Pool
	box *secret.Box
}

// NewCI returns the CI store.
func NewCI(db *pgxpool.Pool, box *secret.Box) *CI { return &CI{db: db, box: box} }

var sampleAAD = []byte("ci_failure_sample")

// CIWatch returns a repository's watch, or the default (not enabled) one.
func (s *CI) CIWatch(ctx context.Context, repoID int64) (domain.CIWatch, error) {
	var raw []byte
	err := s.db.QueryRow(ctx, `SELECT config FROM ci_watches WHERE repo_id = $1`, repoID).Scan(&raw)
	if errors.Is(err, pgx.ErrNoRows) {
		return domain.DefaultCIWatch(repoID), nil
	}
	if err != nil {
		return domain.CIWatch{}, err
	}
	return decodeWatch(repoID, raw)
}

func decodeWatch(repoID int64, raw []byte) (domain.CIWatch, error) {
	w := domain.DefaultCIWatch(repoID)
	if err := json.Unmarshal(raw, &w); err != nil {
		return w, err
	}
	w.RepoID = repoID
	return w, nil
}

// EnabledCIWatches returns the enabled watches of the workspace.
func (s *CI) EnabledCIWatches(ctx context.Context) ([]domain.CIWatch, error) {
	rows, err := s.db.Query(ctx, `SELECT w.repo_id, w.config FROM ci_watches w JOIN repositories r ON r.id = w.repo_id
		WHERE (w.config->>'enabled')::boolean AND r.archived_at IS NULL ORDER BY w.repo_id`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var out []domain.CIWatch
	for rows.Next() {
		var id int64
		var raw []byte
		if err := rows.Scan(&id, &raw); err != nil {
			return nil, err
		}
		w, err := decodeWatch(id, raw)
		if err != nil {
			return nil, err
		}
		out = append(out, w)
	}
	return out, rows.Err()
}

// SaveCIWatch stores a repository's watch in the repository's workspace.
func (s *CI) SaveCIWatch(ctx context.Context, w domain.CIWatch) (domain.CIWatch, error) {
	raw, err := json.Marshal(w)
	if err != nil {
		return w, err
	}
	tag, err := s.db.Exec(ctx, `INSERT INTO ci_watches (repo_id, workspace_id, config)
		SELECT id, workspace_id, $2 FROM repositories WHERE id = $1
		ON CONFLICT (repo_id) DO UPDATE SET config = EXCLUDED.config, updated_at = now()`, w.RepoID, raw)
	if err != nil {
		return w, err
	}
	if tag.RowsAffected() == 0 {
		return w, domain.ErrNotFound
	}
	return w, nil
}

const ciCols = `f.id, f.workspace_id, f.repo_id, r.name, f.branch, f.workflow, f.job, f.fingerprint, f.class, f.title, f.status,
	f.count, f.flaky_count, f.first_seen_at, f.last_seen_at, f.first_sha, f.last_sha, f.occurrences, f.ticket_key,
	f.fixed_sha, f.fixed_at, f.pr_number, f.comment_id`

const ciFrom = ` FROM ci_failures f JOIN repositories r ON r.id = f.repo_id`

func scanCI(row pgx.Row, extra ...any) (domain.CIFailure, error) {
	var f domain.CIFailure
	var status string
	var occ []byte
	dest := []any{&f.ID, &f.WorkspaceID, &f.RepoID, &f.RepoName, &f.Branch, &f.Workflow, &f.Job, &f.Fingerprint, &f.Class, &f.Title,
		&status, &f.Count, &f.FlakyCount, &f.FirstSeenAt, &f.LastSeenAt, &f.FirstSHA, &f.LastSHA, &occ, &f.TicketKey,
		&f.FixedSHA, &f.FixedAt, &f.PRNumber, &f.CommentID}
	if err := row.Scan(append(dest, extra...)...); err != nil {
		return f, notFound(err)
	}
	f.Status = domain.CIStatus(status)
	if len(occ) > 0 {
		_ = json.Unmarshal(occ, &f.Occurrences)
	}
	return f, nil
}

func (s *CI) openSample(sealed []byte) string {
	if len(sealed) == 0 || s.box == nil {
		return ""
	}
	b, err := s.box.Open(sealed, sampleAAD)
	if err != nil {
		return ""
	}
	return string(b)
}

func (s *CI) sealSample(sample string) ([]byte, error) {
	if sample == "" || s.box == nil {
		return nil, nil
	}
	return s.box.Seal([]byte(sample), sampleAAD)
}

// CIFailure returns one group with its log sample.
func (s *CI) CIFailure(ctx context.Context, id int64) (domain.CIFailure, error) {
	var sealed []byte
	f, err := scanCI(s.db.QueryRow(ctx, `SELECT `+ciCols+`, f.sample`+ciFrom+` WHERE f.id = $1`, id), &sealed)
	if err != nil {
		return f, err
	}
	f.Sample = s.openSample(sealed)
	return f, nil
}

// CIFailureByTicket returns the group a ticket fixes, or ErrNotFound.
func (s *CI) CIFailureByTicket(ctx context.Context, key string) (domain.CIFailure, error) {
	var sealed []byte
	f, err := scanCI(s.db.QueryRow(ctx, `SELECT `+ciCols+`, f.sample`+ciFrom+` WHERE f.ticket_key = $1 ORDER BY f.id DESC LIMIT 1`, key), &sealed)
	if err != nil {
		return f, err
	}
	f.Sample = s.openSample(sealed)
	return f, nil
}

// ListCIFailures returns groups, newest occurrence first, without samples.
func (s *CI) ListCIFailures(ctx context.Context, f domain.CIFilter) ([]domain.CIFailure, error) {
	statuses := make([]string, len(f.Statuses))
	for i, st := range f.Statuses {
		statuses[i] = string(st)
	}
	if f.Limit <= 0 || f.Limit > 500 {
		f.Limit = 200
	}
	rows, err := s.db.Query(ctx, `SELECT `+ciCols+ciFrom+`
		WHERE ($1 = 0 OR f.repo_id = $1) AND ($2 = '' OR f.branch = $2) AND ($3 = '' OR f.workflow = $3)
		AND (cardinality($4::text[]) = 0 OR f.status = ANY($4))
		ORDER BY f.last_seen_at DESC LIMIT $5`, f.RepoID, f.Branch, f.Workflow, statuses, f.Limit)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := []domain.CIFailure{}
	for rows.Next() {
		x, err := scanCI(rows)
		if err != nil {
			return nil, err
		}
		out = append(out, x)
	}
	return out, rows.Err()
}

// UpsertCIFailure finds the group of key (repo, branch, workflow,
// fingerprint), locks it and applies mut, or creates it from key and
// applies mut with isNew. sample, when not empty, replaces the stored one.
func (s *CI) UpsertCIFailure(ctx context.Context, key domain.CIFailure, sample string, mut func(f *domain.CIFailure, isNew bool) error) (domain.CIFailure, error) {
	sealed, err := s.sealSample(sample)
	if err != nil {
		return key, err
	}
	var out domain.CIFailure
	err = pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		// Insert first, so two first sightings at once (matrix jobs) do not
		// both insert; then lock the row either way. The repository's own
		// workspace, so the poller's context works too.
		now := time.Now()
		first, last := key.FirstSeenAt, key.LastSeenAt
		if first.IsZero() {
			first = now
		}
		if last.IsZero() {
			last = now
		}
		var newID int64
		err := tx.QueryRow(ctx, `INSERT INTO ci_failures (workspace_id, repo_id, branch, workflow, fingerprint, job, title, pr_number, first_seen_at, last_seen_at)
			SELECT workspace_id, id, $2, $3, $4, $5, $6, $7, $8, $9 FROM repositories WHERE id = $1
			ON CONFLICT (repo_id, branch, workflow, fingerprint) DO NOTHING RETURNING id`,
			key.RepoID, key.Branch, key.Workflow, key.Fingerprint, key.Job, key.Title, key.PRNumber, first, last).Scan(&newID)
		if err != nil && !errors.Is(err, pgx.ErrNoRows) {
			return err
		}
		isNew := newID != 0
		f, err := scanCI(tx.QueryRow(ctx, `SELECT `+ciCols+ciFrom+`
			WHERE f.repo_id = $1 AND f.branch = $2 AND f.workflow = $3 AND f.fingerprint = $4 FOR UPDATE OF f`,
			key.RepoID, key.Branch, key.Workflow, key.Fingerprint))
		if err != nil {
			return err // ErrNotFound: no such repository
		}
		if err := mut(&f, isNew); err != nil {
			return err
		}
		if err := writeCI(ctx, tx, f, sealed); err != nil {
			return err
		}
		out = f
		return nil
	})
	return out, err
}

// UpdateCIFailure locks one group and applies mut; mut's error aborts.
func (s *CI) UpdateCIFailure(ctx context.Context, id int64, mut func(f *domain.CIFailure) error) (domain.CIFailure, error) {
	var out domain.CIFailure
	err := pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		f, err := scanCI(tx.QueryRow(ctx, `SELECT `+ciCols+ciFrom+` WHERE f.id = $1 FOR UPDATE OF f`, id))
		if err != nil {
			return err
		}
		if err := mut(&f); err != nil {
			return err
		}
		if err := writeCI(ctx, tx, f, nil); err != nil {
			return err
		}
		out = f
		return nil
	})
	return out, err
}

func writeCI(ctx context.Context, tx pgx.Tx, f domain.CIFailure, sealed []byte) error {
	if len(f.Occurrences) > domain.MaxCIOccurrences {
		f.Occurrences = f.Occurrences[len(f.Occurrences)-domain.MaxCIOccurrences:]
	}
	occ, err := json.Marshal(f.Occurrences)
	if err != nil {
		return err
	}
	if f.Occurrences == nil {
		occ = []byte("[]")
	}
	_, err = tx.Exec(ctx, `UPDATE ci_failures SET job = $2, class = $3, title = $4, status = $5, count = $6, flaky_count = $7,
		last_seen_at = $8, first_sha = $9, last_sha = $10, occurrences = $11, ticket_key = $12, fixed_sha = $13, pr_number = $14,
		comment_id = $15, sample = COALESCE($16, sample), fixed_at = $17, updated_at = now() WHERE id = $1`,
		f.ID, f.Job, f.Class, f.Title, string(f.Status), f.Count, f.FlakyCount, f.LastSeenAt, f.FirstSHA, f.LastSHA, occ,
		f.TicketKey, f.FixedSHA, f.PRNumber, f.CommentID, sealed, f.FixedAt)
	return err
}

// AutoCITickets counts the CI tickets agnts opened by itself since t (not
// the ones a person asked for with Fix it).
func (s *CI) AutoCITickets(ctx context.Context, since time.Time) (int, error) {
	var n int
	err := s.db.QueryRow(ctx, `SELECT count(*) FROM tickets WHERE source = 'ci' AND created_by IS NULL AND created_at >= $1`, since).Scan(&n)
	return n, err
}

// PruneCISamples drops the log samples of groups that are over: resolved
// or muted for 30 days, flaky or infra without a new occurrence for 14.
func (s *CI) PruneCISamples(ctx context.Context) (int64, error) {
	tag, err := s.db.Exec(ctx, `UPDATE ci_failures SET sample = NULL WHERE sample IS NOT NULL AND (
		(status IN ('resolved', 'muted') AND updated_at < now() - interval '30 days') OR
		(status IN ('flaky', 'infra') AND last_seen_at < now() - interval '14 days'))`)
	return tag.RowsAffected(), err
}
