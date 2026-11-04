package postgres

import (
	"context"
	"encoding/json"
	"time"

	"github.com/jackc/pgx/v5"

	"agnts/internal/domain"
	"agnts/internal/orchestrator"
	"agnts/internal/perfreview"
)

// regressionsSQL counts the confirmed regressions of delivery d's ticket
// t that count: a bug filed within 90 days after the delivery.
const regressionsSQL = `(SELECT count(*) FROM ticket_relations rr JOIN tickets bug ON bug.workspace_id = rr.workspace_id AND bug.key = rr.ticket_key
	WHERE rr.workspace_id = t.workspace_id AND rr.other_key = t.key AND rr.type = 'regression_of' AND rr.status = 'active'
	  AND bug.created_at >= d.delivered_at AND bug.created_at < d.delivered_at + interval '90 days')`

var _ orchestrator.PeriodCloser = (*Agent)(nil)

// DeliveryScores returns the scores under version of the workspace's
// deliveries in [from, to), with their authors and the regressions that
// count against them; author, when set, limits it to deliveries that
// author has a share of. Deliveries with no score yet come as unscored.
func (s *Agent) DeliveryScores(ctx context.Context, from, to time.Time, version, author string) ([]domain.TicketScore, error) {
	rows, err := s.db.Query(ctx, `SELECT d.ticket_id, t.key, t.title, d.delivery, d.delivered_at, $3::text,
			coalesce(x.status, 'unscored'), coalesce(x.points, 0), coalesce(x.from_facts_only, false), coalesce(x.clamped, false),
			coalesce(x.diff_source, ''), coalesce(x.rationale, ''), coalesce(x.factors, '{}'), coalesce(x.reverted_share, 0)::float8,
			coalesce(x.error, CASE WHEN x.ticket_id IS NULL THEN 'not scored yet' ELSE '' END), coalesce(x.model, ''), coalesce(x.scored_at, d.delivered_at),
			x.override_points, x.overridden_by, coalesce(x.override_reason, ''), x.overridden_at, `+regressionsSQL+`
		FROM ticket_deliveries d JOIN tickets t ON t.id = d.ticket_id
		LEFT JOIN ticket_scores x ON x.ticket_id = d.ticket_id AND x.delivery = d.delivery AND x.prompt_version = $3
		WHERE d.delivered_at >= $1 AND d.delivered_at < $2
		  AND ($4 = '' OR EXISTS (SELECT 1 FROM ticket_score_authors a WHERE a.ticket_id = d.ticket_id AND a.delivery = d.delivery AND a.author_key = $4))
		ORDER BY d.delivered_at, d.ticket_id, d.delivery`, from, to, version, author)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var out []domain.TicketScore
	for rows.Next() {
		var sc domain.TicketScore
		var factors []byte
		if err := rows.Scan(&sc.TicketID, &sc.TicketKey, &sc.Title, &sc.Delivery, &sc.DeliveredAt, &sc.PromptVersion, &sc.Status, &sc.Points,
			&sc.FromFactsOnly, &sc.Clamped, &sc.DiffSource, &sc.Rationale, &factors, &sc.RevertedShare, &sc.Error, &sc.Model, &sc.ScoredAt,
			&sc.OverridePoints, &sc.OverriddenBy, &sc.OverrideReason, &sc.OverriddenAt, &sc.Regressions); err != nil {
			return nil, err
		}
		_ = json.Unmarshal(factors, &sc.Factors)
		out = append(out, sc)
	}
	if err := rows.Err(); err != nil {
		return nil, err
	}
	if len(out) == 0 {
		return out, nil
	}
	ids := make([]int64, len(out))
	for i, sc := range out {
		ids[i] = sc.TicketID
	}
	arows, err := s.db.Query(ctx, `SELECT ticket_id, delivery, author_key, share::float8, days FROM ticket_score_authors
		WHERE ticket_id = ANY($1) ORDER BY share DESC, author_key`, ids)
	if err != nil {
		return nil, err
	}
	defer arows.Close()
	type dk struct {
		t int64
		d int
	}
	authors := map[dk][]domain.ScoreAuthor{}
	for arows.Next() {
		var k dk
		var a domain.ScoreAuthor
		if err := arows.Scan(&k.t, &k.d, &a.Key, &a.Share, &a.Days); err != nil {
			return nil, err
		}
		authors[k] = append(authors[k], a)
	}
	for i := range out {
		out[i].Authors = authors[dk{out[i].TicketID, out[i].Delivery}]
	}
	return out, arows.Err()
}

// PendingScores counts the deliveries in [from, to) still waiting for a
// score under version (queued, scoring, or not queued yet).
func (s *Agent) PendingScores(ctx context.Context, from, to time.Time, version string) (int, error) {
	var n int
	err := s.db.QueryRow(ctx, `SELECT count(*) FROM ticket_deliveries d
		WHERE d.delivered_at >= $1 AND d.delivered_at < $2
		  AND NOT EXISTS (SELECT 1 FROM ticket_scores x WHERE x.ticket_id = d.ticket_id AND x.delivery = d.delivery AND x.prompt_version = $3)`,
		from, to, version).Scan(&n)
	return n, err
}

// CloseMonth writes the next closing of a month: totals per author as
// they are now. by is nil when it closes on its own.
func (s *Agent) CloseMonth(ctx context.Context, month time.Time, version string, totals []perfreview.Total, unscored int, by *int64) (domain.PeriodClosing, error) {
	var c domain.PeriodClosing
	err := pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		// One closing at a time per workspace and month.
		if _, err := tx.Exec(ctx, `SELECT pg_advisory_xact_lock(hashtext('period_close'), agnts_ws()::int)`); err != nil {
			return err
		}
		if err := tx.QueryRow(ctx, `INSERT INTO period_closings (month, closing, prompt_version, unscored, closed_by)
			VALUES ($1, coalesce((SELECT max(closing) FROM period_closings WHERE month = $1), 0) + 1, $2, $3, $4)
			RETURNING month, closing, prompt_version, unscored, closed_at, closed_by`, month, version, unscored, by).
			Scan(&c.Month, &c.Closing, &c.PromptVersion, &c.Unscored, &c.ClosedAt, &c.ClosedBy); err != nil {
			return err
		}
		for _, t := range totals {
			if _, err := tx.Exec(ctx, `INSERT INTO period_snapshots (month, closing, prompt_version, author_key, points, tickets, reverts, regressions, unscored, closed_by)
				VALUES ($1, $2, $3, $4, $5, $6, $7, $8, 0, $9)`, month, c.Closing, version, t.Key, t.Points, t.Tickets, t.Reverts, t.Regressions, by); err != nil {
				return err
			}
		}
		return nil
	})
	return c, err
}

// Closings lists a month's closings, newest first.
func (s *Agent) Closings(ctx context.Context, month time.Time) ([]domain.PeriodClosing, error) {
	rows, err := s.db.Query(ctx, `SELECT month, closing, prompt_version, unscored, closed_at, closed_by FROM period_closings
		WHERE month = $1 ORDER BY closing DESC`, month)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	return pgx.CollectRows(rows, func(r pgx.CollectableRow) (domain.PeriodClosing, error) {
		var c domain.PeriodClosing
		err := r.Scan(&c.Month, &c.Closing, &c.PromptVersion, &c.Unscored, &c.ClosedAt, &c.ClosedBy)
		return c, err
	})
}

// ClosedMonths returns the months that have a closing.
func (s *Agent) ClosedMonths(ctx context.Context) ([]time.Time, error) {
	rows, err := s.db.Query(ctx, `SELECT DISTINCT month FROM period_closings ORDER BY month`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	return pgx.CollectRows(rows, pgx.RowTo[time.Time])
}

// SnapshotTotals returns a closing's totals per author.
func (s *Agent) SnapshotTotals(ctx context.Context, month time.Time, closing int) ([]perfreview.Total, error) {
	rows, err := s.db.Query(ctx, `SELECT author_key, points::float8, tickets, reverts, regressions FROM period_snapshots
		WHERE month = $1 AND closing = $2 ORDER BY author_key`, month, closing)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	return pgx.CollectRows(rows, func(r pgx.CollectableRow) (perfreview.Total, error) {
		var t perfreview.Total
		err := r.Scan(&t.Key, &t.Points, &t.Tickets, &t.Reverts, &t.Regressions)
		return t, err
	})
}

// UserNames maps user ids to display names (else usernames).
func (s *Agent) UserNames(ctx context.Context, ids []int64) (map[int64]string, error) {
	out := map[int64]string{}
	if len(ids) == 0 {
		return out, nil
	}
	rows, err := s.db.Query(ctx, `SELECT id, coalesce(nullif(display_name, ''), username) FROM users WHERE id = ANY($1)`, ids)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	for rows.Next() {
		var id int64
		var name string
		if err := rows.Scan(&id, &name); err != nil {
			return nil, err
		}
		out[id] = name
	}
	return out, rows.Err()
}
