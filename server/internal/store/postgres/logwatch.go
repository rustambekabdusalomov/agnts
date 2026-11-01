package postgres

import (
	"context"
	"crypto/rand"
	"encoding/json"
	"errors"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgconn"
	"github.com/jackc/pgx/v5/pgxpool"

	"agnts/internal/domain"
	"agnts/internal/secret"
)

// Logs stores log sources, their services and the findings. Credentials,
// samples and the secret-hash key are sealed.
type Logs struct {
	db  *pgxpool.Pool
	box *secret.Box
}

// NewLogs returns the log watcher's store.
func NewLogs(db *pgxpool.Pool, box *secret.Box) *Logs { return &Logs{db: db, box: box} }

var (
	logAuthAAD   = []byte("log_source_auth")
	logSampleAAD = []byte("log_finding_sample")
	logKeyAAD    = []byte("log_hmac_key")
)

// logSampleEvery is how often a hot finding's sample is replaced at most.
const logSampleEvery = 10 * time.Minute

func (s *Logs) seal(b, aad []byte) ([]byte, error) {
	if len(b) == 0 || s.box == nil {
		return nil, nil
	}
	return s.box.Seal(b, aad)
}

func (s *Logs) open(b, aad []byte) []byte {
	if len(b) == 0 || s.box == nil {
		return nil
	}
	out, err := s.box.Open(b, aad)
	if err != nil {
		return nil
	}
	return out
}

// ---------------------------------------------------------------------
// Sources

const logSourceCols = `id, workspace_id, name, kind, environment, address, auth, ca_pem, scope, fields, poll_seconds, enabled,
	cursor, status, last_error, last_read_at, gap_from, gap_to, dropped, network_id, push_token_hash IS NOT NULL, created_at`

func (s *Logs) scanSource(row pgx.Row, withAuth bool) (domain.LogSource, error) {
	var x domain.LogSource
	var kind, status string
	var auth, scope, fields, cursor []byte
	err := row.Scan(&x.ID, &x.WorkspaceID, &x.Name, &kind, &x.Environment, &x.Address, &auth, &x.CAPEM, &scope, &fields,
		&x.PollSeconds, &x.Enabled, &cursor, &status, &x.LastError, &x.LastReadAt, &x.GapFrom, &x.GapTo, &x.Dropped,
		&x.NetworkID, &x.HasPushToken, &x.CreatedAt)
	if err != nil {
		return x, notFound(err)
	}
	x.Kind, x.Status = domain.LogKind(kind), domain.LogSourceStatus(status)
	_ = json.Unmarshal(scope, &x.Scope)
	_ = json.Unmarshal(fields, &x.Fields)
	_ = json.Unmarshal(cursor, &x.Cursor)
	x.HasAuth = len(auth) > 0
	x.Auth = domain.LogAuth{Kind: "none"}
	if raw := s.open(auth, logAuthAAD); raw != nil {
		var a domain.LogAuth
		if json.Unmarshal(raw, &a) == nil {
			x.Auth.Kind = a.Kind
			x.HasAuth = a.Kind != "none"
			if withAuth {
				x.Auth = a
			} else {
				x.Auth.User, x.Auth.Tenant = a.User, a.Tenant // not secret; shown on the form
			}
		}
	}
	return x, nil
}

// LogSources lists the workspace's sources with their services, without
// credentials.
func (s *Logs) LogSources(ctx context.Context) ([]domain.LogSource, error) {
	rows, err := s.db.Query(ctx, `SELECT `+logSourceCols+` FROM log_sources ORDER BY name`)
	if err != nil {
		return nil, err
	}
	out := []domain.LogSource{}
	for rows.Next() {
		x, err := s.scanSource(rows, false)
		if err != nil {
			rows.Close()
			return nil, err
		}
		out = append(out, x)
	}
	rows.Close()
	if err := rows.Err(); err != nil {
		return nil, err
	}
	return out, s.attachServices(ctx, out)
}

// PullSources returns every enabled pulling source of every workspace,
// with credentials: what the readers run. ctx must be a system one.
func (s *Logs) PullSources(ctx context.Context) ([]domain.LogSource, error) {
	rows, err := s.db.Query(ctx, `SELECT `+logSourceCols+` FROM log_sources
		WHERE enabled AND kind <> 'push' AND status <> 'auth_failed' ORDER BY id`)
	if err != nil {
		return nil, err
	}
	var out []domain.LogSource
	for rows.Next() {
		x, err := s.scanSource(rows, true)
		if err != nil {
			rows.Close()
			return nil, err
		}
		out = append(out, x)
	}
	rows.Close()
	if err := rows.Err(); err != nil {
		return nil, err
	}
	return out, s.attachServices(ctx, out)
}

// LogSource returns one source with its services; withAuth fills the
// credentials.
func (s *Logs) LogSource(ctx context.Context, id int64, withAuth bool) (domain.LogSource, error) {
	x, err := s.scanSource(s.db.QueryRow(ctx, `SELECT `+logSourceCols+` FROM log_sources WHERE id = $1`, id), withAuth)
	if err != nil {
		return x, err
	}
	one := []domain.LogSource{x}
	err = s.attachServices(ctx, one)
	return one[0], err
}

// LogSourceByPushToken finds the enabled push source with this token
// hash, in any workspace. ctx must be a system one.
func (s *Logs) LogSourceByPushToken(ctx context.Context, hash []byte) (domain.LogSource, error) {
	x, err := s.scanSource(s.db.QueryRow(ctx, `SELECT `+logSourceCols+` FROM log_sources
		WHERE push_token_hash = $1 AND kind = 'push' AND enabled`, hash), false)
	if err != nil {
		return x, err
	}
	one := []domain.LogSource{x}
	err = s.attachServices(ctx, one)
	return one[0], err
}

func (s *Logs) attachServices(ctx context.Context, srcs []domain.LogSource) error {
	if len(srcs) == 0 {
		return nil
	}
	ids := make([]int64, len(srcs))
	idx := map[int64]int{}
	for i, x := range srcs {
		ids[i] = x.ID
		idx[x.ID] = i
		srcs[i].Services = []domain.LogService{}
	}
	rows, err := s.db.Query(ctx, `SELECT v.id, v.source_id, v.name, v.selector, v.group_id, v.enabled,
		COALESCE((SELECT array_agg(r.repo_id ORDER BY r.position, r.repo_id) FROM log_service_repos r WHERE r.service_id = v.id), '{}')
		FROM log_services v WHERE v.source_id = ANY($1) ORDER BY v.name`, ids)
	if err != nil {
		return err
	}
	defer rows.Close()
	for rows.Next() {
		var v domain.LogService
		if err := rows.Scan(&v.ID, &v.SourceID, &v.Name, &v.Selector, &v.GroupID, &v.Enabled, &v.RepoIDs); err != nil {
			return err
		}
		i := idx[v.SourceID]
		srcs[i].Services = append(srcs[i].Services, v)
	}
	return rows.Err()
}

func jsonOf(v any) []byte {
	b, _ := json.Marshal(v)
	return b
}

// SaveLogSource creates (ID 0) or updates a source. keepAuth leaves the
// saved credentials as they are (the form sends none back).
func (s *Logs) SaveLogSource(ctx context.Context, x domain.LogSource, keepAuth bool) (domain.LogSource, error) {
	var sealed []byte
	if !keepAuth {
		var err error
		if sealed, err = s.seal(jsonOf(x.Auth), logAuthAAD); err != nil {
			return x, err
		}
	}
	if x.ID == 0 {
		err := s.db.QueryRow(ctx, `INSERT INTO log_sources (name, kind, environment, address, auth, ca_pem, scope, fields, poll_seconds, enabled)
			VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10) RETURNING id`,
			x.Name, string(x.Kind), x.Environment, x.Address, sealed, x.CAPEM, jsonOf(x.Scope), jsonOf(x.Fields), x.PollSeconds, x.Enabled).Scan(&x.ID)
		if err != nil {
			return x, conflict(err)
		}
		return s.LogSource(ctx, x.ID, false)
	}
	// Saving again starts reading again after an auth failure.
	tag, err := s.db.Exec(ctx, `UPDATE log_sources SET name = $2, environment = $3, address = $4,
		auth = CASE WHEN $11 THEN auth ELSE $5 END, ca_pem = $6, scope = $7, fields = $8, poll_seconds = $9, enabled = $10,
		status = CASE WHEN status = 'auth_failed' THEN 'new' ELSE status END, last_error = CASE WHEN status = 'auth_failed' THEN '' ELSE last_error END,
		updated_at = now() WHERE id = $1`,
		x.ID, x.Name, x.Environment, x.Address, sealed, x.CAPEM, jsonOf(x.Scope), jsonOf(x.Fields), x.PollSeconds, x.Enabled, keepAuth)
	if err != nil {
		return x, conflict(err)
	}
	if tag.RowsAffected() == 0 {
		return x, domain.ErrNotFound
	}
	return s.LogSource(ctx, x.ID, false)
}

func conflict(err error) error {
	var pgErr *pgconn.PgError
	if errors.As(err, &pgErr) && pgErr.Code == "23505" {
		return domain.ErrConflict
	}
	return err
}

// DeleteLogSource removes a source; its findings stay (their service is
// unset), so history is kept.
func (s *Logs) DeleteLogSource(ctx context.Context, id int64) error {
	tag, err := s.db.Exec(ctx, `DELETE FROM log_sources WHERE id = $1`, id)
	if err == nil && tag.RowsAffected() == 0 {
		err = domain.ErrNotFound
	}
	return err
}

// SetLogPushToken stores the hash of a push source's new token.
func (s *Logs) SetLogPushToken(ctx context.Context, id int64, hash []byte) error {
	tag, err := s.db.Exec(ctx, `UPDATE log_sources SET push_token_hash = $2, updated_at = now() WHERE id = $1 AND kind = 'push'`, id, hash)
	if err == nil && tag.RowsAffected() == 0 {
		err = domain.ErrNotFound
	}
	return err
}

// LogReadState is what one read of a source changes.
type LogReadState struct {
	Cursor    domain.LogCursor
	Status    domain.LogSourceStatus
	LastError string
	ReadAt    *time.Time
	Dropped   int64 // added
	NetworkID *int64
	GapFrom   *time.Time
	GapTo     *time.Time
}

// SaveLogRead stores a source's cursor and health after a read.
func (s *Logs) SaveLogRead(ctx context.Context, id int64, st LogReadState) error {
	_, err := s.db.Exec(ctx, `UPDATE log_sources SET cursor = $2, status = $3, last_error = $4,
		last_read_at = COALESCE($5, last_read_at), dropped = dropped + $6, network_id = COALESCE($7, network_id),
		gap_from = COALESCE($8, gap_from), gap_to = COALESCE($9, gap_to) WHERE id = $1`,
		id, jsonOf(st.Cursor), string(st.Status), st.LastError, st.ReadAt, st.Dropped, st.NetworkID, st.GapFrom, st.GapTo)
	return err
}

// SetLogServices replaces a source's services and their repositories,
// keeping the ids of services whose names stay.
func (s *Logs) SetLogServices(ctx context.Context, sourceID int64, svcs []domain.LogService) ([]domain.LogService, error) {
	err := pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		var ws int64
		if err := tx.QueryRow(ctx, `SELECT workspace_id FROM log_sources WHERE id = $1 FOR UPDATE`, sourceID).Scan(&ws); err != nil {
			return notFound(err)
		}
		names := make([]string, len(svcs))
		for i, v := range svcs {
			names[i] = v.Name
		}
		if _, err := tx.Exec(ctx, `DELETE FROM log_services WHERE source_id = $1 AND NOT (name = ANY($2))`, sourceID, names); err != nil {
			return err
		}
		for _, v := range svcs {
			var id int64
			err := tx.QueryRow(ctx, `INSERT INTO log_services (workspace_id, source_id, name, selector, group_id, enabled)
				VALUES ($1, $2, $3, $4, $5, $6)
				ON CONFLICT (source_id, name) DO UPDATE SET selector = EXCLUDED.selector, group_id = EXCLUDED.group_id, enabled = EXCLUDED.enabled
				RETURNING id`, ws, sourceID, v.Name, v.Selector, v.GroupID, v.Enabled).Scan(&id)
			if err != nil {
				return err
			}
			if _, err := tx.Exec(ctx, `DELETE FROM log_service_repos WHERE service_id = $1`, id); err != nil {
				return err
			}
			for pos, repo := range v.RepoIDs {
				if _, err := tx.Exec(ctx, `INSERT INTO log_service_repos (service_id, workspace_id, repo_id, position)
					SELECT $1, $2, id, $4 FROM repositories WHERE id = $3 ON CONFLICT DO NOTHING`, id, ws, repo, pos); err != nil {
					return err
				}
			}
		}
		return nil
	})
	if err != nil {
		return nil, err
	}
	x, err := s.LogSource(ctx, sourceID, false)
	return x.Services, err
}

// LogKey returns the workspace's secret-hash key, making it the first
// time.
func (s *Logs) LogKey(ctx context.Context) ([]byte, error) {
	var sealed []byte
	err := s.db.QueryRow(ctx, `SELECT key FROM log_keys`).Scan(&sealed)
	if err == nil {
		if k := s.open(sealed, logKeyAAD); k != nil {
			return k, nil
		}
		if s.box == nil {
			return sealed, nil
		}
		return nil, errors.New("log key: cannot open (was AGNTS_ENC_KEY changed?)")
	}
	if !errors.Is(err, pgx.ErrNoRows) {
		return nil, err
	}
	key := make([]byte, 32)
	if _, err := rand.Read(key); err != nil {
		return nil, err
	}
	stored := key
	if s.box != nil {
		if stored, err = s.box.Seal(key, logKeyAAD); err != nil {
			return nil, err
		}
	}
	if _, err := s.db.Exec(ctx, `INSERT INTO log_keys (key) VALUES ($1) ON CONFLICT DO NOTHING`, stored); err != nil {
		return nil, err
	}
	return s.LogKey(ctx) // the stored one, if another reader made it first
}

// RotateLogKey replaces the workspace's secret-hash key. Findings of a
// secret seen before and after are then two findings.
func (s *Logs) RotateLogKey(ctx context.Context) error {
	if _, err := s.db.Exec(ctx, `DELETE FROM log_keys`); err != nil {
		return err
	}
	_, err := s.LogKey(ctx)
	return err
}

// ---------------------------------------------------------------------
// Findings

const logFindingCols = `f.id, f.workspace_id, f.scope, f.service_id, f.service, f.repo_ids,
	COALESCE((SELECT array_agg(r.name ORDER BY array_position(f.repo_ids, r.id)) FROM repositories r WHERE r.id = ANY(f.repo_ids)), '{}'),
	f.category, f.detector, f.class, f.severity, f.fingerprint, f.title, f.remediation, f.status, f.reason, f.count, f.hour_count,
	f.hour_start, f.first_seen_at, f.last_seen_at, f.revision, f.route, f.bursts, f.secret_mask, f.secret_hmac, f.sample_at, f.occurrences,
	f.reported_at, f.ticket_key, f.fixed_sha, f.fixed_at`

func scanFinding(row pgx.Row, extra ...any) (domain.LogFinding, error) {
	var f domain.LogFinding
	var cat, class, sev, status string
	var bursts, occ []byte
	dest := []any{&f.ID, &f.WorkspaceID, &f.Scope, &f.ServiceID, &f.Service, &f.RepoIDs, &f.RepoNames, &cat, &f.Detector, &class,
		&sev, &f.Fingerprint, &f.Title, &f.Remediation, &status, &f.Reason, &f.Count, &f.HourCount, &f.HourStart, &f.FirstSeenAt,
		&f.LastSeenAt, &f.Revision, &f.Route, &bursts, &f.SecretMask, &f.SecretHMAC, &f.SampleAt, &occ, &f.ReportedAt, &f.TicketKey,
		&f.FixedSHA, &f.FixedAt}
	if err := row.Scan(append(dest, extra...)...); err != nil {
		return f, notFound(err)
	}
	f.Category, f.Class, f.Severity, f.Status = domain.LogCategory(cat), domain.LogClass(class), domain.LogSeverity(sev), domain.LogStatus(status)
	_ = json.Unmarshal(bursts, &f.Bursts)
	_ = json.Unmarshal(occ, &f.Occurrences)
	return f, nil
}

// LogFinding returns one finding with its sample.
func (s *Logs) LogFinding(ctx context.Context, id int64) (domain.LogFinding, error) {
	var sealed []byte
	f, err := scanFinding(s.db.QueryRow(ctx, `SELECT `+logFindingCols+`, f.sample FROM log_findings f WHERE f.id = $1`, id), &sealed)
	if err != nil {
		return f, err
	}
	f.Sample = string(s.open(sealed, logSampleAAD))
	return f, nil
}

// LogFindingByTicket returns the finding a ticket fixes, or ErrNotFound.
func (s *Logs) LogFindingByTicket(ctx context.Context, key string) (domain.LogFinding, error) {
	var sealed []byte
	f, err := scanFinding(s.db.QueryRow(ctx, `SELECT `+logFindingCols+`, f.sample FROM log_findings f
		WHERE f.ticket_key = $1 ORDER BY f.id DESC LIMIT 1`, key), &sealed)
	if err != nil {
		return f, err
	}
	f.Sample = string(s.open(sealed, logSampleAAD))
	return f, nil
}

// ListLogFindings returns findings, newest sighting first, without
// samples.
func (s *Logs) ListLogFindings(ctx context.Context, q domain.LogFindingFilter) ([]domain.LogFinding, error) {
	if q.Limit <= 0 || q.Limit > 500 {
		q.Limit = 200
	}
	rows, err := s.db.Query(ctx, `SELECT `+logFindingCols+` FROM log_findings f
		WHERE ($1 = '' OR f.category = $1) AND ($2 = '' OR f.status = $2) AND ($3 = '' OR f.severity = $3)
		AND ($4 = 0 OR $4 = ANY(f.repo_ids))
		AND ($5 = 0 OR f.service_id IN (SELECT id FROM log_services WHERE source_id = $5) OR f.occurrences @> jsonb_build_array(jsonb_build_object('sourceId', $5::bigint)))
		AND (NOT $6 OR f.status IN ('open', 'reported', 'fixing', 'regression'))
		ORDER BY f.last_seen_at DESC LIMIT $7`,
		string(q.Category), string(q.Status), string(q.Severity), q.RepoID, q.SourceID, q.Active, q.Limit)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := []domain.LogFinding{}
	for rows.Next() {
		f, err := scanFinding(rows)
		if err != nil {
			return nil, err
		}
		out = append(out, f)
	}
	return out, rows.Err()
}

// UpsertLogFinding finds the finding of key (scope, fingerprint) in the
// workspace ctx acts in, locks it and applies mut, or creates it from key
// and applies mut with isNew. sample replaces the stored one when the
// finding is new, its status changed, or the stored one is older than ten
// minutes, so a hot error doesn't re-seal its sample on every batch.
func (s *Logs) UpsertLogFinding(ctx context.Context, key domain.LogFinding, sample string, mut func(f *domain.LogFinding, isNew bool) error) (domain.LogFinding, error) {
	var out domain.LogFinding
	err := pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		now := time.Now()
		first := key.FirstSeenAt
		if first.IsZero() {
			first = now
		}
		var newID int64
		err := tx.QueryRow(ctx, `INSERT INTO log_findings (scope, service_id, service, repo_ids, category, detector, class, severity,
			fingerprint, title, first_seen_at, last_seen_at, hour_start)
			VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $11, $11)
			ON CONFLICT (workspace_id, scope, fingerprint) DO NOTHING RETURNING id`,
			key.Scope, key.ServiceID, key.Service, nonNilIDs(key.RepoIDs), string(key.Category), key.Detector, string(key.Class),
			string(key.Severity), key.Fingerprint, key.Title, first).Scan(&newID)
		if err != nil && !errors.Is(err, pgx.ErrNoRows) {
			return err
		}
		isNew := newID != 0
		f, err := scanFinding(tx.QueryRow(ctx, `SELECT `+logFindingCols+` FROM log_findings f
			WHERE f.scope = $1 AND f.fingerprint = $2 FOR UPDATE OF f`, key.Scope, key.Fingerprint))
		if err != nil {
			return err
		}
		prev := f.Status
		if err := mut(&f, isNew); err != nil {
			return err
		}
		var sealed []byte
		if sample != "" && (isNew || f.Status != prev || f.SampleAt == nil || now.Sub(*f.SampleAt) > logSampleEvery) {
			if sealed, err = s.seal([]byte(sample), logSampleAAD); err != nil {
				return err
			}
			if sealed != nil {
				f.SampleAt = &now
			}
		}
		if err := writeFinding(ctx, tx, f, sealed); err != nil {
			return err
		}
		out = f
		return nil
	})
	return out, err
}

// UpdateLogFinding locks one finding and applies mut; mut's error aborts.
func (s *Logs) UpdateLogFinding(ctx context.Context, id int64, mut func(f *domain.LogFinding) error) (domain.LogFinding, error) {
	var out domain.LogFinding
	err := pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		f, err := scanFinding(tx.QueryRow(ctx, `SELECT `+logFindingCols+` FROM log_findings f WHERE f.id = $1 FOR UPDATE OF f`, id))
		if err != nil {
			return err
		}
		if err := mut(&f); err != nil {
			return err
		}
		if err := writeFinding(ctx, tx, f, nil); err != nil {
			return err
		}
		out = f
		return nil
	})
	return out, err
}

func writeFinding(ctx context.Context, tx pgx.Tx, f domain.LogFinding, sealed []byte) error {
	if len(f.Occurrences) > domain.MaxLogOccurrences {
		f.Occurrences = f.Occurrences[len(f.Occurrences)-domain.MaxLogOccurrences:]
	}
	if f.Occurrences == nil {
		f.Occurrences = []domain.LogOccurrence{}
	}
	if f.Bursts == nil {
		f.Bursts = []time.Time{}
	}
	_, err := tx.Exec(ctx, `UPDATE log_findings SET service_id = $2, service = $3, repo_ids = $4, class = $5, severity = $6, title = $7,
		remediation = $8, status = $9, reason = $10, count = $11, hour_count = $12, hour_start = $13, last_seen_at = $14, revision = $15,
		route = $16, bursts = $17, secret_mask = $18, sample = COALESCE($19, sample), sample_at = $20, occurrences = $21,
		reported_at = $22, ticket_key = $23, fixed_sha = $24, fixed_at = $25, secret_hmac = $26, updated_at = now() WHERE id = $1`,
		f.ID, f.ServiceID, f.Service, nonNilIDs(f.RepoIDs), string(f.Class), string(f.Severity), f.Title, f.Remediation, string(f.Status),
		f.Reason, f.Count, f.HourCount, f.HourStart, f.LastSeenAt, f.Revision, f.Route, jsonOf(f.Bursts), f.SecretMask, sealed,
		f.SampleAt, jsonOf(f.Occurrences), f.ReportedAt, f.TicketKey, f.FixedSHA, f.FixedAt, f.SecretHMAC)
	return err
}

// MergeLogScope moves the findings of one scope into another (a service
// got repositories, or other ones): a finding already in the new scope
// takes the old one's counts and keeps the older first sighting.
func (s *Logs) MergeLogScope(ctx context.Context, from, to string, repos []int64) error {
	if from == to {
		return nil
	}
	return pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		if _, err := tx.Exec(ctx, `UPDATE log_findings t SET count = t.count + f.count,
			first_seen_at = LEAST(t.first_seen_at, f.first_seen_at), last_seen_at = GREATEST(t.last_seen_at, f.last_seen_at)
			FROM log_findings f WHERE f.scope = $1 AND t.scope = $2 AND t.fingerprint = f.fingerprint`, from, to); err != nil {
			return err
		}
		if _, err := tx.Exec(ctx, `DELETE FROM log_findings f WHERE f.scope = $1
			AND EXISTS (SELECT 1 FROM log_findings t WHERE t.scope = $2 AND t.fingerprint = f.fingerprint)`, from, to); err != nil {
			return err
		}
		_, err := tx.Exec(ctx, `UPDATE log_findings SET scope = $2, repo_ids = $3, updated_at = now() WHERE scope = $1`, from, to, nonNilIDs(repos))
		return err
	})
}

// AutoLogTickets counts the log tickets agnts opened by itself since t
// (not the ones a person asked for with Fix it).
func (s *Logs) AutoLogTickets(ctx context.Context, since time.Time) (int, error) {
	var n int
	err := s.db.QueryRow(ctx, `SELECT count(*) FROM tickets WHERE source = 'logs' AND created_by IS NULL AND created_at >= $1`, since).Scan(&n)
	return n, err
}

// FixedLogFindings returns the workspace's fixed findings, for the sweep.
func (s *Logs) FixedLogFindings(ctx context.Context) ([]domain.LogFinding, error) {
	return s.ListLogFindings(ctx, domain.LogFindingFilter{Status: domain.LogFixed, Limit: 500})
}

// PruneLogSamples drops the samples of findings that are over: resolved
// or muted for 30 days.
func (s *Logs) PruneLogSamples(ctx context.Context) (int64, error) {
	tag, err := s.db.Exec(ctx, `UPDATE log_findings SET sample = NULL, sample_at = NULL WHERE sample IS NOT NULL
		AND status IN ('resolved', 'muted') AND updated_at < now() - interval '30 days'`)
	return tag.RowsAffected(), err
}
