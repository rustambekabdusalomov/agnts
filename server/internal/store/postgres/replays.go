package postgres

import (
	"context"

	"github.com/jackc/pgx/v5"

	"agnts/internal/domain"
	"agnts/internal/orchestrator"
)

var _ orchestrator.ReplayStore = (*Agent)(nil)

// ReplayRows returns the newest replays with what the eval report compares:
// their latest change, checks and review, turns and cost, and the same for
// the ticket each re-ran.
func (s *Agent) ReplayRows(ctx context.Context, limit int) ([]orchestrator.ReplayRow, error) {
	rows, err := s.db.Query(ctx, `SELECT r.key, r.replay_of, r.title, r.state, r.turns, r.created_at,
			COALESCE((SELECT prompt_version FROM runs WHERE ticket_id = r.id AND stage = 'code' ORDER BY started_at, id LIMIT 1), ''),
			COALESCE((SELECT model FROM runs WHERE ticket_id = r.id AND stage = 'code' ORDER BY started_at, id LIMIT 1), ''),
			rc.files, rc.tests,
			COALESCE((SELECT res.summary->>'verdict' FROM results res JOIN runs ON runs.id = res.run_id
				WHERE runs.ticket_id = r.id AND runs.stage = 'review' ORDER BY res.created_at DESC LIMIT 1), ''),
			COALESCE((SELECT sum(cost_usd) FROM claude_calls WHERE ticket_id = r.id), 0)::float8,
			COALESCE(o.turns, 0), oc.files,
			COALESCE((SELECT sum(cost_usd) FROM claude_calls WHERE ticket_id = o.id), 0)::float8,
			COALESCE((SELECT jsonb_agg(f) FROM merged_changes mc, jsonb_array_elements(mc.files) f WHERE mc.ticket_id = o.id), '[]'),
			COALESCE(o.benchmark, false)
		FROM tickets r
		LEFT JOIN tickets o ON o.workspace_id = r.workspace_id AND o.key = r.replay_of
		LEFT JOIN LATERAL (SELECT res.files, res.tests FROM results res JOIN runs ON runs.id = res.run_id
			WHERE runs.ticket_id = r.id AND runs.stage = 'code' ORDER BY res.created_at DESC LIMIT 1) rc ON true
		LEFT JOIN LATERAL (SELECT res.files FROM results res JOIN runs ON runs.id = res.run_id
			WHERE runs.ticket_id = o.id AND runs.stage = 'code' ORDER BY res.created_at DESC LIMIT 1) oc ON true
		WHERE r.replay_of <> ''
		ORDER BY r.created_at DESC LIMIT $1`, limit)
	if err != nil {
		return nil, err
	}
	return pgx.CollectRows(rows, func(row pgx.CollectableRow) (orchestrator.ReplayRow, error) {
		var x orchestrator.ReplayRow
		var state string
		err := row.Scan(&x.Key, &x.Original, &x.Title, &state, &x.Turns, &x.CreatedAt, &x.PromptVersion, &x.Model, &x.Files, &x.Tests,
			&x.Verdict, &x.CostUSD, &x.OriginalTurns, &x.OriginalFiles, &x.OriginalCostUSD, &x.MergedFiles, &x.Benchmark)
		x.State = domain.TicketState(state)
		return x, err
	})
}
