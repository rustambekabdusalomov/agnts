package postgres

import (
	"context"
	"fmt"
	"time"

	"agnts/internal/domain"
)

// RecordClaudeCall stores the token spend of one Claude invocation. The
// ticket is taken from the run.
func (s *Agent) RecordClaudeCall(ctx context.Context, c domain.ClaudeCall) error {
	u := c.Usage
	var transcript *int64
	if c.TranscriptID > 0 {
		transcript = &c.TranscriptID
	}
	tag, err := s.db.Exec(ctx, `INSERT INTO claude_calls (run_id, ticket_id, model_stage, model,
			input_tokens, output_tokens, cache_read_tokens, cache_write_tokens, cost_usd, turns, duration_ms, partial, transcript_id)
		SELECT id, ticket_id, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12 FROM runs WHERE id = $1`,
		c.RunID, c.ModelStage, c.Model, u.Input, u.Output, u.CacheRead, u.CacheWrite, u.CostUSD,
		c.Turns, c.Duration.Milliseconds(), c.Partial, transcript)
	if err != nil {
		return err
	}
	if tag.RowsAffected() == 0 {
		return fmt.Errorf("record claude call: run %d: %w", c.RunID, domain.ErrNotFound)
	}
	return nil
}

// TicketUsage returns a ticket's spend by model stage and model, in the
// order each first ran. It is empty for tickets with no recorded calls.
func (s *Agent) TicketUsage(ctx context.Context, ticketID int64) ([]domain.StageUsage, error) {
	rows, err := s.db.Query(ctx, `SELECT model_stage, model, count(*), sum(turns), bool_or(partial),
			sum(input_tokens), sum(output_tokens), sum(cache_read_tokens), sum(cache_write_tokens), sum(cost_usd)::float8
		FROM claude_calls WHERE ticket_id = $1
		GROUP BY model_stage, model ORDER BY min(created_at), min(id)`, ticketID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := []domain.StageUsage{}
	for rows.Next() {
		var su domain.StageUsage
		u := &su.Usage
		if err := rows.Scan(&su.ModelStage, &su.Model, &su.Calls, &su.Turns, &su.Partial,
			&u.Input, &u.Output, &u.CacheRead, &u.CacheWrite, &u.CostUSD); err != nil {
			return nil, err
		}
		out = append(out, su)
	}
	return out, rows.Err()
}

// SpendByKeys returns the total spend of each ticket in keys. Tickets
// without recorded calls are absent.
func (s *Agent) SpendByKeys(ctx context.Context, keys []string) (map[string]domain.TokenUsage, error) {
	out := map[string]domain.TokenUsage{}
	if len(keys) == 0 {
		return out, nil
	}
	rows, err := s.db.Query(ctx, `SELECT t.key, sum(c.input_tokens), sum(c.output_tokens),
			sum(c.cache_read_tokens), sum(c.cache_write_tokens), sum(c.cost_usd)::float8
		FROM tickets t JOIN claude_calls c ON c.ticket_id = t.id
		WHERE t.key = ANY($1) GROUP BY t.key`, keys)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	for rows.Next() {
		var k string
		var u domain.TokenUsage
		if err := rows.Scan(&k, &u.Input, &u.Output, &u.CacheRead, &u.CacheWrite, &u.CostUSD); err != nil {
			return nil, err
		}
		out[k] = u
	}
	return out, rows.Err()
}

// TicketSpend is one ticket's spend within a period.
type TicketSpend struct {
	Key      string
	Title    string
	Kind     domain.TicketKind
	State    domain.TicketState
	RepoName string
	Calls    int
	TopStage string // the model stage that cost the most
	Usage    domain.TokenUsage
}

// TopTicketSpend returns the total spend of calls made since, and the
// limit tickets that spent most then: by cost, then by input and output
// tokens (cut-off runs have no cost).
func (s *Agent) TopTicketSpend(ctx context.Context, since time.Time, limit int) (domain.TokenUsage, []TicketSpend, error) {
	var total domain.TokenUsage
	if err := s.db.QueryRow(ctx, `SELECT COALESCE(sum(input_tokens), 0), COALESCE(sum(output_tokens), 0),
			COALESCE(sum(cache_read_tokens), 0), COALESCE(sum(cache_write_tokens), 0), COALESCE(sum(cost_usd), 0)::float8
		FROM claude_calls WHERE created_at >= $1`, since).
		Scan(&total.Input, &total.Output, &total.CacheRead, &total.CacheWrite, &total.CostUSD); err != nil {
		return total, nil, err
	}
	rows, err := s.db.Query(ctx, `WITH c AS (SELECT * FROM claude_calls WHERE created_at >= $1),
		per AS (
			SELECT ticket_id, count(*) AS calls, sum(input_tokens) AS i, sum(output_tokens) AS o,
				sum(cache_read_tokens) AS cr, sum(cache_write_tokens) AS cw, sum(cost_usd) AS cost
			FROM c GROUP BY ticket_id
		),
		top AS (
			SELECT DISTINCT ON (ticket_id) ticket_id, model_stage FROM (
				SELECT ticket_id, model_stage, sum(cost_usd) AS cost, sum(input_tokens + output_tokens) AS io
				FROM c GROUP BY ticket_id, model_stage
			) x ORDER BY ticket_id, cost DESC, io DESC, model_stage
		)
		SELECT t.key, t.title, t.kind, t.state, COALESCE(r.name, ''), per.calls, top.model_stage,
			per.i, per.o, per.cr, per.cw, per.cost::float8
		FROM per
		JOIN tickets t ON t.id = per.ticket_id
		JOIN top ON top.ticket_id = per.ticket_id
		LEFT JOIN repositories r ON r.id = t.repo_id
		ORDER BY per.cost DESC, per.i + per.o DESC, t.key
		LIMIT $2`, since, limit)
	if err != nil {
		return total, nil, err
	}
	defer rows.Close()
	out := []TicketSpend{}
	for rows.Next() {
		var ts TicketSpend
		var kind, state string
		u := &ts.Usage
		if err := rows.Scan(&ts.Key, &ts.Title, &kind, &state, &ts.RepoName, &ts.Calls, &ts.TopStage,
			&u.Input, &u.Output, &u.CacheRead, &u.CacheWrite, &u.CostUSD); err != nil {
			return total, nil, err
		}
		ts.Kind, ts.State = domain.TicketKind(kind), domain.TicketState(state)
		out = append(out, ts)
	}
	return total, out, rows.Err()
}
