package postgres

import (
	"context"
	"encoding/json"
	"time"

	"github.com/jackc/pgx/v5"

	"agnts/internal/domain"
	"agnts/internal/orchestrator"
)

// StateSince returns, per ticket, when it entered its current state and,
// for failed or paused tickets, the message of that transition.
func (s *Agent) StateSince(ctx context.Context, keys []string) (map[string]orchestrator.StateInfo, error) {
	out := map[string]orchestrator.StateInfo{}
	if len(keys) == 0 {
		return out, nil
	}
	rows, err := s.db.Query(ctx, `SELECT DISTINCT ON (t.key) t.key, e.created_at, e.message
		FROM tickets t JOIN events e ON e.ticket_key = t.key AND e.workspace_id = t.workspace_id
			AND e.type = 'state_changed' AND e.data->>'to' = t.state
		WHERE t.key = ANY($1) ORDER BY t.key, e.id DESC`, keys)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	for rows.Next() {
		var k string
		var si orchestrator.StateInfo
		if err := rows.Scan(&k, &si.Since, &si.Reason); err != nil {
			return nil, err
		}
		out[k] = si
	}
	return out, rows.Err()
}

// History returns a ticket's state changes, oldest first.
func (s *Agent) History(ctx context.Context, key string) ([]orchestrator.HistoryItem, error) {
	rows, err := s.db.Query(ctx, `SELECT e.created_at, e.data->>'to', e.message, e.origin, COALESCE(u.username, '') FROM `+eventFrom+`
		WHERE e.ticket_key = $1 AND e.type IN ('state_changed', 'answered', 'feedback') AND e.data ? 'to' ORDER BY e.id`, key)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var out []orchestrator.HistoryItem
	for rows.Next() {
		var h orchestrator.HistoryItem
		var st, origin string
		if err := rows.Scan(&h.At, &st, &h.Message, &origin, &h.User); err != nil {
			return nil, err
		}
		h.State, h.Origin = domain.TicketState(st), domain.Origin(origin)
		out = append(out, h)
	}
	return out, rows.Err()
}

// LogFilter narrows the global log.
type LogFilter struct {
	Type   string // all, state, tool, command, user, limit, problems
	Key    string
	Errors bool
	Before int64
	Limit  int
}

// typeCondition maps the Logs page tabs to event rows.
var typeCondition = map[string]string{
	"state":    `e.type = 'state_changed'`,
	"tool":     `e.type IN ('claude_tool', 'claude_text')`,
	"command":  `e.type IN ('check', 'pushed', 'pr_opened', 'tracker_comment')`,
	"user":     `e.origin IN ('web', 'mobile', 'mcp', 'telegram')`,
	"limit":    `e.type IN ('rate_limit', 'usage_updated')`,
	"problems": `e.level IN ('warn', 'error')`,
}

// ListEvents returns events newest first.
func (s *Agent) ListEvents(ctx context.Context, f LogFilter) ([]domain.Event, error) {
	limit := f.Limit
	if limit <= 0 || limit > 500 {
		limit = 100
	}
	cond := "true"
	if c, ok := typeCondition[f.Type]; ok {
		cond = c
	}
	q := `SELECT ` + eventCols + ` FROM ` + eventFrom + ` WHERE ` + cond + `
		  AND ($1 = '' OR e.ticket_key ILIKE $1 || '%')
		  AND (NOT $2 OR e.level = 'error')
		  AND ($3 = 0 OR e.id < $3)
		ORDER BY e.id DESC LIMIT $4`
	rows, err := s.db.Query(ctx, q, f.Key, f.Errors, f.Before, limit)
	if err != nil {
		return nil, err
	}
	return scanEvents(rows)
}

// eventCols and eventFrom select events with the name of the person
// behind each.
const (
	eventCols = `e.id, COALESCE(e.ticket_key, ''), e.run_id, e.step, e.type, e.level, e.origin, e.message, e.data, e.duration_ms, e.created_at,
	COALESCE(e.workspace_id, 0), COALESCE(e.user_id, 0), COALESCE(u.username, '')`
	eventFrom = `events e LEFT JOIN users u ON u.id = e.user_id`
)

func scanEvent(row pgx.Row) (domain.Event, error) {
	var e domain.Event
	var level, origin string
	var data []byte
	if err := row.Scan(&e.ID, &e.TicketKey, &e.RunID, &e.Step, &e.Type, &level, &origin, &e.Message, &data, &e.DurationMS, &e.CreatedAt,
		&e.WorkspaceID, &e.UserID, &e.Username); err != nil {
		return e, notFound(err)
	}
	e.Level, e.Origin = domain.Level(level), domain.Origin(origin)
	_ = json.Unmarshal(data, &e.Data)
	return e, nil
}

func scanEvents(rows pgx.Rows) ([]domain.Event, error) {
	defer rows.Close()
	var out []domain.Event
	for rows.Next() {
		e, err := scanEvent(rows)
		if err != nil {
			return nil, err
		}
		out = append(out, e)
	}
	return out, rows.Err()
}

// ExportEvents streams the last 90 days of events to fn, oldest first.
func (s *Agent) ExportEvents(ctx context.Context, fn func(domain.Event) error) error {
	rows, err := s.db.Query(ctx, `SELECT `+eventCols+` FROM `+eventFrom+` WHERE e.created_at > now() - interval '90 days' ORDER BY e.id`)
	if err != nil {
		return err
	}
	defer rows.Close()
	for rows.Next() {
		e, err := scanEvent(rows)
		if err != nil {
			return err
		}
		if err := fn(e); err != nil {
			return err
		}
	}
	return rows.Err()
}

// StepDuration is the average time tickets spend in one state.
type StepDuration struct {
	State domain.TicketState
	Avg   time.Duration
	Count int
}

// Summary is the Logs page's statistics.
type Summary struct {
	RunsStarted   int
	ReachedReview int
	AvgTurns      int
	Stops         int
	Errors        int
	Steps         []StepDuration
}

// EventSummary computes run statistics over the last 30 days.
func (s *Agent) EventSummary(ctx context.Context) (Summary, error) {
	var sum Summary
	err := s.db.QueryRow(ctx, `SELECT
		count(*) FILTER (WHERE type = 'state_changed' AND data->>'to' = 'coding'),
		count(*) FILTER (WHERE type = 'state_changed' AND data->>'to' = 'waiting_for_review'),
		count(*) FILTER (WHERE type = 'state_changed' AND data->>'to' IN ('failed', 'rate_limited')),
		count(*) FILTER (WHERE level = 'error')
		FROM events WHERE created_at > now() - interval '30 days'`).Scan(&sum.RunsStarted, &sum.ReachedReview, &sum.Stops, &sum.Errors)
	if err != nil {
		return sum, err
	}
	if err := s.db.QueryRow(ctx, `SELECT COALESCE(round(avg(turns)), 0)::int FROM tickets WHERE turns > 0`).Scan(&sum.AvgTurns); err != nil {
		return sum, err
	}
	// Time in a state = from entering it to the ticket's next state change.
	rows, err := s.db.Query(ctx, `WITH t AS (
		SELECT ticket_key, data->>'to' AS state, created_at,
		       lead(created_at) OVER (PARTITION BY ticket_key ORDER BY id) AS left_at
		FROM events WHERE type IN ('state_changed', 'answered', 'feedback') AND data ? 'to'
		  AND created_at > now() - interval '30 days')
		SELECT state, (extract(epoch FROM avg(left_at - created_at)) * 1000)::bigint, count(*)
		FROM t WHERE left_at IS NOT NULL AND state NOT IN ('done', 'rejected') GROUP BY state`)
	if err != nil {
		return sum, err
	}
	defer rows.Close()
	for rows.Next() {
		var st string
		var ms int64
		var n int
		if err := rows.Scan(&st, &ms, &n); err != nil {
			return sum, err
		}
		sum.Steps = append(sum.Steps, StepDuration{State: domain.TicketState(st), Avg: time.Duration(ms) * time.Millisecond, Count: n})
	}
	return sum, rows.Err()
}

// HourBucket counts today's events by kind.
type HourBucket struct{ Hour, Agnts, You, Problems int }

// TodayByHour buckets today's events (server time zone) by hour.
func (s *Agent) TodayByHour(ctx context.Context, tz *time.Location) ([]HourBucket, error) {
	now := time.Now().In(tz)
	start := time.Date(now.Year(), now.Month(), now.Day(), 0, 0, 0, 0, tz)
	rows, err := s.db.Query(ctx, `SELECT created_at, origin, level FROM events WHERE created_at >= $1`, start)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := make([]HourBucket, 24)
	for i := range out {
		out[i].Hour = i
	}
	for rows.Next() {
		var at time.Time
		var origin, level string
		if err := rows.Scan(&at, &origin, &level); err != nil {
			return nil, err
		}
		b := &out[at.In(tz).Hour()]
		switch {
		case level == "warn" || level == "error":
			b.Problems++
		case origin == "web" || origin == "mobile" || origin == "mcp" || origin == "telegram":
			b.You++
		default:
			b.Agnts++
		}
	}
	return out, rows.Err()
}

// WeekStats summarises one 7-day window.
type WeekStats struct {
	Picked, Pushed, FirstTryPct, AvgTurns, AvgWaitMin, Stopped int
}

// Week computes stats for [from, from+7d).
func (s *Agent) Week(ctx context.Context, from time.Time) (WeekStats, error) {
	to := from.Add(7 * 24 * time.Hour)
	var w WeekStats
	var firstTry int
	err := s.db.QueryRow(ctx, `SELECT
		count(*) FILTER (WHERE type = 'ticket_created' OR (type = 'state_changed' AND data->>'to' = 'analyzing' AND data->>'from' = 'new')),
		count(*) FILTER (WHERE type = 'state_changed' AND data->>'to' = 'done'),
		count(*) FILTER (WHERE type = 'state_changed' AND data->>'to' IN ('failed', 'rate_limited'))
		FROM events WHERE created_at >= $1 AND created_at < $2`, from, to).Scan(&w.Picked, &w.Pushed, &w.Stopped)
	if err != nil {
		return w, err
	}
	// Tickets pushed this week whose approval came without requested changes.
	if err := s.db.QueryRow(ctx, `SELECT count(*) FROM tickets t
		WHERE t.state = 'done' AND t.revision = 0 AND t.updated_at >= $1 AND t.updated_at < $2`, from, to).Scan(&firstTry); err != nil {
		return w, err
	}
	if w.Pushed > 0 {
		w.FirstTryPct = firstTry * 100 / w.Pushed
	}
	if err := s.db.QueryRow(ctx, `SELECT COALESCE(round(avg(turns)), 0)::int FROM runs
		WHERE turns > 0 AND started_at >= $1 AND started_at < $2`, from, to).Scan(&w.AvgTurns); err != nil {
		return w, err
	}
	err = s.db.QueryRow(ctx, `WITH t AS (
		SELECT data->>'to' AS state, created_at, lead(created_at) OVER (PARTITION BY ticket_key ORDER BY id) AS left_at
		FROM events WHERE type IN ('state_changed', 'answered', 'feedback') AND data ? 'to')
		SELECT COALESCE(round(extract(epoch FROM avg(left_at - created_at)) / 60), 0)::int FROM t
		WHERE state IN ('waiting_for_answers', 'waiting_for_review') AND left_at IS NOT NULL
		  AND created_at >= $1 AND created_at < $2`, from, to).Scan(&w.AvgWaitMin)
	return w, err
}

// RecentEvents returns the newest n events that matter to a person.
func (s *Agent) RecentEvents(ctx context.Context, n int) ([]domain.Event, error) {
	rows, err := s.db.Query(ctx, `SELECT `+eventCols+` FROM `+eventFrom+`
		WHERE e.type NOT IN ('claude_text', 'claude_tool', 'rate_limit') ORDER BY e.id DESC LIMIT $1`, n)
	if err != nil {
		return nil, err
	}
	return scanEvents(rows)
}

// LastMessages returns the newest Claude text or tool line per ticket.
func (s *Agent) LastMessages(ctx context.Context, keys []string) (map[string]string, error) {
	out := map[string]string{}
	if len(keys) == 0 {
		return out, nil
	}
	rows, err := s.db.Query(ctx, `SELECT DISTINCT ON (ticket_key) ticket_key, message FROM events
		WHERE ticket_key = ANY($1) AND type IN ('claude_text', 'claude_tool', 'check') ORDER BY ticket_key, id DESC`, keys)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	for rows.Next() {
		var k, m string
		if err := rows.Scan(&k, &m); err != nil {
			return nil, err
		}
		out[k] = m
	}
	return out, rows.Err()
}

// ActiveRuns returns unfinished runs by ticket id.
func (s *Agent) ActiveRuns(ctx context.Context) (map[int64]domain.Run, error) {
	rows, err := s.db.Query(ctx, `SELECT `+runCols+` FROM runs WHERE finished_at IS NULL`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := map[int64]domain.Run{}
	for rows.Next() {
		r, err := scanRun(rows)
		if err != nil {
			return nil, err
		}
		out[r.TicketID] = r
	}
	return out, rows.Err()
}

// ToolCallsByRun counts tool calls of running runs, a live stand-in for
// turns (the exact count arrives when the run finishes).
func (s *Agent) ToolCallsByRun(ctx context.Context, runIDs []int64) (map[int64]int, error) {
	out := map[int64]int{}
	if len(runIDs) == 0 {
		return out, nil
	}
	rows, err := s.db.Query(ctx, `SELECT run_id, count(*) FROM events WHERE run_id = ANY($1) AND type = 'claude_tool' GROUP BY run_id`, runIDs)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	for rows.Next() {
		var id int64
		var n int
		if err := rows.Scan(&id, &n); err != nil {
			return nil, err
		}
		out[id] = n
	}
	return out, rows.Err()
}
