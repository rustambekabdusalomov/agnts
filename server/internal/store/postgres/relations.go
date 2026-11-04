package postgres

import (
	"context"
	"encoding/json"
	"errors"
	"slices"

	"github.com/jackc/pgx/v5"

	"agnts/internal/domain"
	"agnts/internal/orchestrator"
)

// releasesSQL is domain.Ticket.Releases for a tickets row aliased b: its
// change is on the default branch, or it will never be.
const releasesSQL = `(b.state = 'rejected' OR (b.state = 'done' AND (b.merged_at IS NOT NULL
	OR b.kind IN ('plan', 'analysis', 'bug') OR (b.after_approve = 'main' AND b.source = 'local'))))`

// inFlightSQL is true when ticket b has started changing code that is not
// on the default branch yet: a conflicting ticket waits for it.
const inFlightSQL = `(b.head_sha <> '' OR b.state IN ('testing', 'waiting_for_review', 'pushing')
	OR EXISTS (SELECT 1 FROM runs br WHERE br.ticket_id = b.id AND br.stage = 'code' AND br.finished_at IS NULL))`

// blockersSQL lists, for the tickets row aliased t, the tickets b that hold
// it back: an active dependency that has not landed, or an active conflict
// whose other side is changing the code right now. Columns: key, title,
// state, relation type.
// Keys are unique per workspace: every join by key also matches the
// workspace, since the queue reads all workspaces at once.
const blockersSQL = `SELECT b.key, b.title, b.state, r.type FROM ticket_relations r
		JOIN tickets b ON b.workspace_id = r.workspace_id AND b.key = r.other_key
		WHERE r.workspace_id = t.workspace_id AND r.ticket_key = t.key AND r.type = 'depends_on' AND r.status = 'active' AND NOT ` + releasesSQL + `
	UNION ALL
	SELECT b.key, b.title, b.state, r.type FROM ticket_relations r
		JOIN tickets b ON b.workspace_id = r.workspace_id AND b.key = CASE WHEN r.ticket_key = t.key THEN r.other_key ELSE r.ticket_key END
		WHERE r.workspace_id = t.workspace_id AND (r.ticket_key = t.key OR r.other_key = t.key) AND r.type = 'conflicts' AND r.status = 'active'
		  AND ` + inFlightSQL + ` AND NOT ` + releasesSQL

// waitsSQL is true when ticket t may not start coding. Only the first
// coding run waits: a ticket that has a commit already is never held back.
const waitsSQL = `(t.state = 'coding' AND t.head_sha = '' AND EXISTS (` + blockersSQL + `))`

// WaitsCondition is waitsSQL for other packages that query tickets t
// (metrics), so every count agrees with the queue.
const WaitsCondition = waitsSQL

// priorityRankSQL ranks Jira's priority names and the task form's, higher
// first; unknown ones count as medium.
const priorityRankSQL = `(CASE lower(t.priority) WHEN 'highest' THEN 5 WHEN 'blocker' THEN 5 WHEN 'critical' THEN 5
	WHEN 'high' THEN 4 WHEN 'medium' THEN 3 WHEN 'low' THEN 2 WHEN 'lowest' THEN 1 ELSE 3 END)`

// unblocksSQL counts the open tickets that wait for ticket t: among equal
// priorities, the one that frees the most work goes first.
const unblocksSQL = `(SELECT count(*) FROM ticket_relations r JOIN tickets d ON d.workspace_id = r.workspace_id AND d.key = r.ticket_key
	WHERE r.workspace_id = t.workspace_id AND r.other_key = t.key AND r.type = 'depends_on' AND r.status = 'active' AND d.state NOT IN ('done', 'rejected'))`

const relationCols = `id, ticket_key, other_key, type, source, status, confidence, reason, basis, files, COALESCE(found_by, ''), confirmed_at, decided_at, created_at`

func scanRelation(row pgx.Row) (domain.Relation, error) {
	var r domain.Relation
	var typ, src, st string
	var conf float32
	err := row.Scan(&r.ID, &r.TicketKey, &r.OtherKey, &typ, &src, &st, &conf, &r.Reason, &r.Basis, &r.Files, &r.FoundBy, &r.ConfirmedAt, &r.DecidedAt, &r.CreatedAt)
	r.Type, r.Source, r.Status, r.Confidence = domain.RelationType(typ), domain.RelationSource(src), domain.RelationStatus(st), float64(conf)
	return r, notFound(err)
}

// RelationsOf returns every relation involving key.
func (s *Agent) RelationsOf(ctx context.Context, key string) ([]orchestrator.RelationRow, error) {
	rows, err := s.db.Query(ctx, `SELECT x.*, b.title, b.state, `+releasesSQL+`
		FROM (SELECT `+relationCols+` FROM ticket_relations WHERE (ticket_key = $1 OR other_key = $1) AND type <> 'regression_of') x
		JOIN tickets b ON b.key = CASE WHEN x.ticket_key = $1 THEN x.other_key ELSE x.ticket_key END
		ORDER BY x.id`, key)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := []orchestrator.RelationRow{}
	for rows.Next() {
		var r orchestrator.RelationRow
		var typ, src, st, other string
		var conf float32
		if err := rows.Scan(&r.ID, &r.TicketKey, &r.OtherKey, &typ, &src, &st, &conf, &r.Reason, &r.Basis, &r.Files, &r.FoundBy,
			&r.ConfirmedAt, &r.DecidedAt, &r.CreatedAt, &r.OtherTitle, &other, &r.OtherReleases); err != nil {
			return nil, err
		}
		r.Type, r.Source, r.Status, r.Confidence = domain.RelationType(typ), domain.RelationSource(src), domain.RelationStatus(st), float64(conf)
		r.OtherState = domain.TicketState(other)
		out = append(out, r)
	}
	return out, rows.Err()
}

// RelationByID returns one relation.
func (s *Agent) RelationByID(ctx context.Context, id int64) (domain.Relation, error) {
	return scanRelation(s.db.QueryRow(ctx, `SELECT `+relationCols+` FROM ticket_relations WHERE id = $1`, id))
}

// DependencyGraph returns the active depends_on edges.
func (s *Agent) DependencyGraph(ctx context.Context) (map[string][]string, error) {
	rows, err := s.db.Query(ctx, `SELECT ticket_key, other_key FROM ticket_relations WHERE type = 'depends_on' AND status = 'active'`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := map[string][]string{}
	for rows.Next() {
		var a, b string
		if err := rows.Scan(&a, &b); err != nil {
			return nil, err
		}
		out[a] = append(out[a], b)
	}
	return out, rows.Err()
}

// ReplaceFound swaps what foundBy's analysis found before for rs.
func (s *Agent) ReplaceFound(ctx context.Context, foundBy string, rs []domain.Relation, ev *domain.Event) ([]domain.Relation, error) {
	var out []domain.Relation
	err := pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		// A regression the owner confirmed or dismissed is theirs: analysing
		// the bug again neither deletes it nor brings it back.
		if _, err := tx.Exec(ctx, `DELETE FROM ticket_relations WHERE found_by = $1 AND source IN ('agnts', 'rule') AND status <> 'dismissed'
			AND NOT (type = 'regression_of' AND status = 'active')`,
			foundBy); err != nil {
			return err
		}
		for _, r := range rs {
			r.FoundBy = foundBy
			got, _, err := upsertRelation(ctx, tx, r)
			if err != nil {
				return err
			}
			out = append(out, got)
		}
		if ev != nil {
			return insertEvent(ctx, tx, *ev)
		}
		return nil
	})
	return out, err
}

// SyncTrackerRelations makes the relations of source (jira, plane)
// involving key exactly rs.
func (s *Agent) SyncTrackerRelations(ctx context.Context, source domain.RelationSource, key string, rs []domain.Relation) ([]domain.Relation, error) {
	var added []domain.Relation
	err := pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		keep := make([]int64, 0, len(rs))
		for _, r := range rs {
			var exists bool
			if err := tx.QueryRow(ctx, `SELECT count(*) = 2 FROM tickets WHERE key IN ($1, $2)`, r.TicketKey, r.OtherKey).Scan(&exists); err != nil {
				return err
			}
			if !exists {
				continue // the other issue is not an agnts ticket (yet)
			}
			got, changed, err := upsertRelation(ctx, tx, r)
			if err != nil {
				return err
			}
			keep = append(keep, got.ID)
			if changed {
				added = append(added, got)
			}
		}
		_, err := tx.Exec(ctx, `DELETE FROM ticket_relations WHERE source = $3 AND (ticket_key = $1 OR other_key = $1) AND NOT (id = ANY($2))`,
			key, keep, string(source))
		return err
	})
	return added, err
}

// UpsertRelation stores r or merges it into the pair's relation.
func (s *Agent) UpsertRelation(ctx context.Context, r domain.Relation, ev *domain.Event) (domain.Relation, error) {
	var out domain.Relation
	err := pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		var err error
		if out, _, err = upsertRelation(ctx, tx, r); err != nil {
			return err
		}
		if ev != nil {
			return insertEvent(ctx, tx, *ev)
		}
		return nil
	})
	return out, err
}

// authority ranks the sources that predict: what a person or Jira says
// outranks what agnts read from the tickets or their footprints.
var authority = map[domain.RelationSource]int{
	domain.RelFromAgnts: 1, domain.RelFromRule: 2, domain.RelFromJira: 3, domain.RelFromPlane: 3, domain.RelFromUser: 4,
}

// upsertRelation inserts r, or merges it into the existing relation of the
// pair: active beats proposed, the more authoritative source supplies the
// reason, and a dismissed relation stays dismissed unless a person adds it
// again. changed is false when nothing was written.
func upsertRelation(ctx context.Context, tx pgx.Tx, r domain.Relation) (domain.Relation, bool, error) {
	r = r.Normalize()
	if r.Files == nil {
		r.Files = []string{}
	}
	if r.Status == "" {
		r.Status = domain.RelActive
	}
	git := r.Source == domain.RelFromGit
	old, err := scanRelation(tx.QueryRow(ctx, `SELECT `+relationCols+` FROM ticket_relations
		WHERE ticket_key = $1 AND other_key = $2 AND type = $3 FOR UPDATE`, r.TicketKey, r.OtherKey, string(r.Type)))
	if errors.Is(err, domain.ErrNotFound) {
		out, err := scanRelation(tx.QueryRow(ctx, `INSERT INTO ticket_relations
			(ticket_key, other_key, type, source, status, confidence, reason, basis, files, found_by, confirmed_at)
			VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, NULLIF($10, ''), CASE WHEN $11 THEN now() END) RETURNING `+relationCols,
			r.TicketKey, r.OtherKey, string(r.Type), string(r.Source), string(r.Status), r.Confidence, r.Reason, r.Basis, r.Files, r.FoundBy, git))
		return out, err == nil, err
	}
	if err != nil {
		return old, false, err
	}
	if git {
		// The finished changes prove a predicted conflict: keep who
		// predicted it, note the proof and the files. A proposal is now a
		// fact; a dismissal stays, as the person chose to run them anyway.
		status := old.Status
		if status == domain.RelProposed {
			status = domain.RelActive
		}
		out, err := scanRelation(tx.QueryRow(ctx, `UPDATE ticket_relations SET status = $2, files = $3, confirmed_at = coalesce(confirmed_at, now())
			WHERE id = $1 RETURNING `+relationCols, old.ID, string(status), mergeStrings(old.Files, r.Files)))
		return out, err == nil, err
	}
	if old.Status == domain.RelDismissed && r.Source != domain.RelFromUser {
		return old, false, nil
	}
	m := old
	if old.Status == domain.RelDismissed || (r.Status == domain.RelActive && old.Status == domain.RelProposed) {
		m.Status = r.Status
	}
	if authority[r.Source] >= authority[old.Source] {
		m.Source = r.Source
		if r.Reason != "" {
			m.Reason = r.Reason
		}
		if r.Basis != "" {
			m.Basis = r.Basis
		}
		if r.FoundBy != "" || (r.Source != domain.RelFromAgnts && r.Source != domain.RelFromRule) {
			m.FoundBy = r.FoundBy
		}
	}
	m.Confidence = max(old.Confidence, r.Confidence)
	if len(r.Files) > 0 {
		m.Files = mergeStrings(old.Files, r.Files)
	}
	if relationEqual(m, old) {
		return old, false, nil
	}
	out, err := scanRelation(tx.QueryRow(ctx, `UPDATE ticket_relations SET source = $2, status = $3, confidence = $4, reason = $5,
		basis = $6, files = $7, found_by = NULLIF($8, ''),
		decided_at = CASE WHEN $3 <> status AND $9 THEN now() ELSE decided_at END
		WHERE id = $1 RETURNING `+relationCols,
		old.ID, string(m.Source), string(m.Status), m.Confidence, m.Reason, m.Basis, m.Files, m.FoundBy, r.Source == domain.RelFromUser))
	return out, err == nil, err
}

func relationEqual(a, b domain.Relation) bool {
	return a.Source == b.Source && a.Status == b.Status && a.Confidence == b.Confidence && a.Reason == b.Reason &&
		a.Basis == b.Basis && a.FoundBy == b.FoundBy && slices.Equal(a.Files, b.Files)
}

func mergeStrings(a, b []string) []string {
	out := slices.Clone(a)
	for _, x := range b {
		if !slices.Contains(out, x) {
			out = append(out, x)
		}
	}
	slices.Sort(out)
	return out
}

// DecideRelation sets a relation's status.
func (s *Agent) DecideRelation(ctx context.Context, key string, id int64, status domain.RelationStatus, ev domain.Event) (domain.Relation, error) {
	var out domain.Relation
	err := pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		var err error
		out, err = scanRelation(tx.QueryRow(ctx, `UPDATE ticket_relations SET status = $3, decided_at = now()
			WHERE id = $1 AND (ticket_key = $2 OR other_key = $2) RETURNING `+relationCols, id, key, string(status)))
		if err != nil {
			return err
		}
		return insertEvent(ctx, tx, ev)
	})
	return out, err
}

// Blockers returns what holds each ticket's first coding run back now. A
// ticket whose run already started is not waiting, whatever was added since.
func (s *Agent) Blockers(ctx context.Context, keys []string) (map[string][]domain.Blocker, error) {
	out := map[string][]domain.Blocker{}
	if len(keys) == 0 {
		return out, nil
	}
	rows, err := s.db.Query(ctx, `SELECT t.key, x.key, x.title, x.state, x.type FROM tickets t
		CROSS JOIN LATERAL (`+blockersSQL+`) x (key, title, state, type)
		WHERE t.key = ANY($1) AND t.state = 'coding' AND t.head_sha = ''
		  AND NOT EXISTS (SELECT 1 FROM runs tr WHERE tr.ticket_id = t.id AND tr.finished_at IS NULL)
		ORDER BY t.key, x.key`, keys)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	for rows.Next() {
		var key, state, typ string
		var b domain.Blocker
		if err := rows.Scan(&key, &b.Key, &b.Title, &state, &typ); err != nil {
			return nil, err
		}
		b.State, b.Type = domain.TicketState(state), domain.RelationType(typ)
		if !slices.ContainsFunc(out[key], func(x domain.Blocker) bool { return x.Key == b.Key }) {
			out[key] = append(out[key], b)
		}
	}
	return out, rows.Err()
}

// touchesSQL is true for a ticket (t) that works in repository $1, as its
// primary repository or another of its repositories.
const touchesSQL = `(t.repo_id = $1 OR EXISTS (SELECT 1 FROM ticket_repos tr WHERE tr.ticket_id = t.id AND tr.repo_id = $1))`

// RelationCandidates returns the tickets work on except could relate to:
// those working in the repository, whichever of their repositories it is.
func (s *Agent) RelationCandidates(ctx context.Context, repoID int64, except string, limit int) ([]orchestrator.Candidate, error) {
	rows, err := s.db.Query(ctx, `SELECT `+ticketCols+`, a.summary FROM tickets t
		LEFT JOIN LATERAL (SELECT res.summary FROM results res JOIN runs ON runs.id = res.run_id
			WHERE runs.ticket_id = t.id AND runs.stage = 'analyze' ORDER BY res.created_at DESC LIMIT 1) a ON true
		WHERE `+touchesSQL+` AND t.key <> $2 AND t.replay_of = '' AND (t.state NOT IN ('done', 'rejected')
			OR (t.state = 'done' AND t.merged_at IS NULL AND t.kind IN ('code', 'test') AND NOT (t.after_approve = 'main' AND t.source = 'local')))
		ORDER BY t.updated_at DESC LIMIT $3`, repoID, except, limit)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := []orchestrator.Candidate{}
	for rows.Next() {
		var c orchestrator.Candidate
		var analysis []byte
		t, err := scanTicket(scanAppend{rows, &analysis})
		if err != nil {
			return nil, err
		}
		c.Ticket, c.Analysis = t, analysis
		out = append(out, c)
	}
	return out, rows.Err()
}

// InFlightResults returns committed, unmerged changes in a repository.
func (s *Agent) InFlightResults(ctx context.Context, repoID int64, except string) ([]orchestrator.InFlight, error) {
	rows, err := s.db.Query(ctx, `SELECT `+ticketCols+`, c.files FROM tickets t
		JOIN LATERAL (SELECT res.files FROM results res JOIN runs ON runs.id = res.run_id
			WHERE runs.ticket_id = t.id AND runs.stage = 'code' ORDER BY res.created_at DESC LIMIT 1) c ON true
		WHERE EXISTS (SELECT 1 FROM ticket_repos tr WHERE tr.ticket_id = t.id AND tr.repo_id = $1 AND tr.head_sha <> ''
				AND tr.merged_at IS NULL AND tr.closed_at IS NULL AND tr.state <> 'unchanged')
		  AND t.key <> $2 AND t.replay_of = '' AND t.kind IN ('code', 'test')
		  AND t.state NOT IN ('rejected') AND t.merged_at IS NULL AND NOT (t.state = 'done' AND t.after_approve = 'main' AND t.source = 'local')
		ORDER BY t.updated_at DESC LIMIT 50`, repoID, except)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var out []orchestrator.InFlight
	for rows.Next() {
		var files []byte
		t, err := scanTicket(scanAppend{rows, &files})
		if err != nil {
			return nil, err
		}
		f := orchestrator.InFlight{Ticket: t}
		_ = json.Unmarshal(files, &f.Files)
		out = append(out, f)
	}
	return out, rows.Err()
}

// scanAppend scans a ticket row with extra trailing columns.
type scanAppend struct {
	row   pgx.Row
	extra any
}

func (s scanAppend) Scan(dest ...any) error { return s.row.Scan(append(dest, s.extra)...) }

// EvalData returns every coded change ticket (with its predicted files,
// first and newest change) and every relation, for the relations eval.
func (s *Agent) EvalData(ctx context.Context) ([]orchestrator.EvalTicket, []domain.Relation, error) {
	rows, err := s.db.Query(ctx, `SELECT t.key, t.repo_id, a.summary, f.files, l.files, f.created_at,
			CASE WHEN t.merged_at IS NOT NULL THEN t.merged_at
			     WHEN t.state = 'rejected' OR (t.state = 'done' AND t.after_approve = 'main' AND t.source = 'local') THEN t.updated_at END
		FROM tickets t
		JOIN LATERAL (SELECT res.files, res.created_at FROM results res JOIN runs ON runs.id = res.run_id
			WHERE runs.ticket_id = t.id AND runs.stage = 'code' ORDER BY res.created_at LIMIT 1) f ON true
		JOIN LATERAL (SELECT res.files FROM results res JOIN runs ON runs.id = res.run_id
			WHERE runs.ticket_id = t.id AND runs.stage = 'code' ORDER BY res.created_at DESC LIMIT 1) l ON true
		LEFT JOIN LATERAL (SELECT res.summary FROM results res JOIN runs ON runs.id = res.run_id
			WHERE runs.ticket_id = t.id AND runs.stage = 'analyze' ORDER BY res.created_at DESC LIMIT 1) a ON true
		WHERE t.repo_id IS NOT NULL AND t.kind IN ('code', 'test')
		ORDER BY f.created_at`)
	if err != nil {
		return nil, nil, err
	}
	defer rows.Close()
	var ts []orchestrator.EvalTicket
	for rows.Next() {
		var t orchestrator.EvalTicket
		var analysis, first, latest []byte
		if err := rows.Scan(&t.Key, &t.RepoID, &analysis, &first, &latest, &t.CodedAt, &t.EndedAt); err != nil {
			return nil, nil, err
		}
		t.Predicted = orchestrator.PredictedFiles(analysis)
		_ = json.Unmarshal(first, &t.FirstFiles)
		_ = json.Unmarshal(latest, &t.Files)
		ts = append(ts, t)
	}
	if err := rows.Err(); err != nil {
		return nil, nil, err
	}
	rrows, err := s.db.Query(ctx, `SELECT `+relationCols+` FROM ticket_relations ORDER BY id`)
	if err != nil {
		return nil, nil, err
	}
	defer rrows.Close()
	var rs []domain.Relation
	for rrows.Next() {
		r, err := scanRelation(rrows)
		if err != nil {
			return nil, nil, err
		}
		rs = append(rs, r)
	}
	return ts, rs, rrows.Err()
}
