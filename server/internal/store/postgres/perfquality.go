package postgres

import (
	"context"
	"errors"
	"fmt"
	"strings"
	"time"

	"github.com/jackc/pgx/v5"

	"agnts/internal/domain"
)

// RecentDeliveries lists a repository's tickets delivered since, newest
// first: what a bug may be a regression of.
func (s *Agent) RecentDeliveries(ctx context.Context, repoID int64, since time.Time, limit int) ([]domain.Delivery, []string, error) {
	rows, err := s.db.Query(ctx, `SELECT d.ticket_id, t.key, d.delivery, d.delivered_at, t.title FROM ticket_deliveries d JOIN tickets t ON t.id = d.ticket_id
		WHERE d.delivered_at >= $2 AND EXISTS (SELECT 1 FROM ticket_commits c WHERE c.ticket_id = d.ticket_id AND c.repo_id = $1)
		ORDER BY d.delivered_at DESC LIMIT $3`, repoID, since, limit)
	if err != nil {
		return nil, nil, err
	}
	defer rows.Close()
	var out []domain.Delivery
	var titles []string
	for rows.Next() {
		var d domain.Delivery
		var title string
		if err := rows.Scan(&d.TicketID, &d.TicketKey, &d.Delivery, &d.DeliveredAt, &title); err != nil {
			return nil, nil, err
		}
		out, titles = append(out, d), append(titles, title)
	}
	return out, titles, rows.Err()
}

// ProposeRegression records that analysis of bug thinks it is a
// regression of origin. A regression the owner decided keeps its status.
func (s *Agent) ProposeRegression(ctx context.Context, bug, origin, reason string, confidence float64) error {
	_, err := s.db.Exec(ctx, `INSERT INTO ticket_relations (ticket_key, other_key, type, source, status, confidence, reason, found_by)
		VALUES ($1, $2, 'regression_of', 'agnts', 'proposed', $3, $4, $1)
		ON CONFLICT (workspace_id, ticket_key, other_key, type) DO UPDATE SET reason = EXCLUDED.reason, confidence = EXCLUDED.confidence
			WHERE ticket_relations.status = 'proposed'`, bug, origin, confidence, reason)
	return err
}

const regressionCols = `r.id, r.ticket_key, b.title, r.other_key, o.title, r.status, r.source, r.reason, r.decided_by, r.decided_at,
	(r.status = 'active' AND EXISTS (SELECT 1 FROM ticket_deliveries d WHERE d.ticket_id = o.id
		AND b.created_at >= d.delivered_at AND b.created_at < d.delivered_at + interval '90 days'))`

func scanRegression(row pgx.Row) (domain.Regression, error) {
	var g domain.Regression
	err := row.Scan(&g.ID, &g.Bug, &g.BugTitle, &g.Origin, &g.OriginTitle, &g.Status, &g.Source, &g.Reason, &g.DecidedBy, &g.DecidedAt, &g.Counts)
	return g, notFound(err)
}

// Regressions lists the workspace's regressions, proposed first.
func (s *Agent) Regressions(ctx context.Context) ([]domain.Regression, error) {
	rows, err := s.db.Query(ctx, `SELECT `+regressionCols+` FROM ticket_relations r
		JOIN tickets b ON b.workspace_id = r.workspace_id AND b.key = r.ticket_key
		JOIN tickets o ON o.workspace_id = r.workspace_id AND o.key = r.other_key
		WHERE r.type = 'regression_of'
		ORDER BY CASE r.status WHEN 'proposed' THEN 0 WHEN 'active' THEN 1 ELSE 2 END, r.created_at DESC LIMIT 500`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var out []domain.Regression
	for rows.Next() {
		g, err := scanRegression(rows)
		if err != nil {
			return nil, err
		}
		out = append(out, g)
	}
	return out, rows.Err()
}

// DecideRegression confirms (active) or dismisses a regression of bug.
func (s *Agent) DecideRegression(ctx context.Context, bug string, id int64, status domain.RelationStatus, by int64) (domain.Regression, error) {
	tag, err := s.db.Exec(ctx, `UPDATE ticket_relations SET status = $3, decided_at = now(), decided_by = $4
		WHERE id = $1 AND ticket_key = $2 AND type = 'regression_of'`, id, bug, string(status), by)
	if err != nil {
		return domain.Regression{}, err
	}
	if tag.RowsAffected() == 0 {
		return domain.Regression{}, domain.ErrNotFound
	}
	return s.regression(ctx, id)
}

// SetRegression records, for the owner, that bug is a regression of
// origin: confirmed at once.
func (s *Agent) SetRegression(ctx context.Context, bug, origin, reason string, by int64) (domain.Regression, error) {
	if strings.EqualFold(bug, origin) {
		return domain.Regression{}, fmt.Errorf("%w: a ticket cannot be a regression of itself", domain.ErrPerfInvalid)
	}
	var id int64
	err := s.db.QueryRow(ctx, `INSERT INTO ticket_relations (ticket_key, other_key, type, source, status, confidence, reason, decided_at, decided_by)
		VALUES ($1, $2, 'regression_of', 'user', 'active', 1, $3, now(), $4)
		ON CONFLICT (workspace_id, ticket_key, other_key, type) DO UPDATE SET status = 'active', source = 'user', reason = EXCLUDED.reason,
			decided_at = now(), decided_by = EXCLUDED.decided_by
		RETURNING id`, bug, origin, reason, by).Scan(&id)
	var fk interface{ SQLState() string }
	if errors.As(err, &fk) && fk.SQLState() == "23503" {
		return domain.Regression{}, domain.ErrNotFound
	}
	if err != nil {
		return domain.Regression{}, err
	}
	return s.regression(ctx, id)
}

func (s *Agent) regression(ctx context.Context, id int64) (domain.Regression, error) {
	return scanRegression(s.db.QueryRow(ctx, `SELECT `+regressionCols+` FROM ticket_relations r
		JOIN tickets b ON b.workspace_id = r.workspace_id AND b.key = r.ticket_key
		JOIN tickets o ON o.workspace_id = r.workspace_id AND o.key = r.other_key
		WHERE r.id = $1`, id))
}

// SetScoreOverride sets (points) or clears (nil) the owner's override of
// a delivery's score, under every version it was scored with.
func (s *Agent) SetScoreOverride(ctx context.Context, ticketID int64, delivery int, points *int, reason string, by int64) error {
	tag, err := s.db.Exec(ctx, `UPDATE ticket_scores SET override_points = $3, override_reason = $4,
			overridden_by = CASE WHEN $3::int IS NULL THEN NULL ELSE $5::bigint END, overridden_at = CASE WHEN $3::int IS NULL THEN NULL ELSE now() END
		WHERE ticket_id = $1 AND delivery = $2`, ticketID, delivery, points, reason, by)
	if err != nil {
		return err
	}
	if tag.RowsAffected() == 0 {
		return domain.ErrNotFound
	}
	return nil
}

// RevertsOf returns the commits on a repository's default branch that
// revert one of shas, or revert such a revert (a re-land): sha → what it
// reverts.
func (s *Agent) RevertsOf(ctx context.Context, repoID int64, shas []string) (map[string]string, error) {
	out := map[string]string{}
	if len(shas) == 0 {
		return out, nil
	}
	rows, err := s.db.Query(ctx, `WITH RECURSIVE chain(sha, reverts) AS (
			SELECT DISTINCT sha, reverts FROM ticket_commits WHERE repo_id = $1 AND reverts <> '' AND on_default_at IS NOT NULL
			  AND EXISTS (SELECT 1 FROM unnest($2::text[]) x WHERE x LIKE reverts || '%')
			UNION
			SELECT DISTINCT c.sha, c.reverts FROM ticket_commits c JOIN chain ON chain.sha LIKE c.reverts || '%'
			WHERE c.repo_id = $1 AND c.reverts <> '' AND c.on_default_at IS NOT NULL)
		SELECT sha, reverts FROM chain`, repoID, lowerAll(shas))
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	for rows.Next() {
		var sha, of string
		if err := rows.Scan(&sha, &of); err != nil {
			return nil, err
		}
		out[sha] = of
	}
	return out, rows.Err()
}

// SetRevertedShare records the part of a delivery's scored lines that
// reverts undid.
func (s *Agent) SetRevertedShare(ctx context.Context, ticketID int64, delivery int, share float64) error {
	_, err := s.db.Exec(ctx, `UPDATE ticket_scores SET reverted_share = $3 WHERE ticket_id = $1 AND delivery = $2`, ticketID, delivery, min(max(share, 0), 1))
	return err
}

// ScoredDeliveriesOf lists a ticket's deliveries that have a score.
func (s *Agent) ScoredDeliveriesOf(ctx context.Context, ticketID int64) ([]int, error) {
	rows, err := s.db.Query(ctx, `SELECT DISTINCT delivery FROM ticket_scores WHERE ticket_id = $1 AND status = 'scored' ORDER BY delivery`, ticketID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	return pgx.CollectRows(rows, pgx.RowTo[int])
}
