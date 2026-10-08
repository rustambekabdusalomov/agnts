package postgres

import (
	"context"
	"time"

	"agnts/internal/domain"
)

// DayStats is one day of the Analytics page.
type DayStats struct {
	Date      time.Time
	Picked    int
	Pushed    int
	Rejected  int
	Stopped   int
	AgntsMin  float64 // average minutes agnts worked per ticket active that day
	WaitMin   float64 // average minutes tickets waited on you
	Turns     float64 // average turns of coding runs that finished that day
	PeakUsage *float64
	Spend     domain.TokenUsage // Claude calls made that day
}

// Period sums a range of days.
type Period struct {
	Picked, Pushed, Rejected, Stopped int
	FirstTry, AfterChanges            int
	AgntsMin, WaitMin, Turns          float64
	ReviewMin, AnswerMin              float64
	Spend                             domain.TokenUsage // all Claude calls in the range
}

// ModelStats is one model's runs.
type ModelStats struct {
	Model         string
	Runs          int
	ReachedReview int
	AvgTurns      float64
}

// RepoStats is one repository's results.
type RepoStats struct {
	RepoID   int64
	Name     string
	Kind     string
	ClaudeMD string
	Tickets  int
	Done     int
	Finished int // done, rejected or failed
	AvgTurns float64
	AgntsMin float64
}

// QualityStats is how well the tickets whose first coding run used one
// prompt version went: the numbers each change to the agent is judged by.
type QualityStats struct {
	PromptVersion string // "" for runs from before versions were recorded
	Tickets       int    // first coding run in the period
	ReachedReview int    // got to a person's review at least once
	Done          int
	FirstTry      int // done without a person asking for changes
	Rejected      int
	ChangeRounds  float64 // average change requests by a person, over those that reached review
	FixAttempts   float64 // average failing checks sent back to Claude
	Serious       int     // reviewed with a blocker or major finding at least once
	FootprintHit  float64 // average share of changed files the analysis predicted (-1: none measured)
	RedFlags      int     // red flags found in their diffs
	SelfFixes     int     // findings sent back to the coder by agnts's own review
}

// Analytics is everything the Analytics page shows for one period.
type Analytics struct {
	Days    []DayStats
	Current Period
	Prev    Period
	Steps   map[string]float64 // state -> average minutes
	Stops   map[string]int     // reason -> count
	Models  []ModelStats
	Repos   []RepoStats
	Hours   [24]int
	Spend   []domain.StageUsage // by stage and model, costliest first
	Quality []QualityStats      // by prompt version, oldest first
}

// stateSpans is a CTE of how long each ticket stayed in each state.
const stateSpans = `spans AS (
	SELECT ticket_key, data->>'to' AS state, created_at AS entered,
	       lead(created_at) OVER (PARTITION BY ticket_key ORDER BY id) AS left_at
	FROM events WHERE type IN ('state_changed', 'answered', 'feedback') AND data ? 'to')`

var working = []string{"analyzing", "coding", "testing", "pushing"}
var waiting = []string{"waiting_for_answers", "waiting_for_review"}

// Analytics computes the page for [now-days, now) in tz, with the previous
// period of the same length for comparison.
func (s *Agent) Analytics(ctx context.Context, days int, tz *time.Location) (Analytics, error) {
	now := time.Now().In(tz)
	end := time.Date(now.Year(), now.Month(), now.Day(), 0, 0, 0, 0, tz).AddDate(0, 0, 1)
	start := end.AddDate(0, 0, -days)
	prevStart := start.AddDate(0, 0, -days)
	a := Analytics{Steps: map[string]float64{}, Stops: map[string]int{}}

	var err error
	if a.Current, err = s.period(ctx, start, end); err != nil {
		return a, err
	}
	if a.Prev, err = s.period(ctx, prevStart, start); err != nil {
		return a, err
	}

	// Per day: outcomes from transitions, time from state spans, turns from runs.
	byDay := map[string]*DayStats{}
	for d := start; d.Before(end); d = d.AddDate(0, 0, 1) {
		ds := DayStats{Date: d}
		a.Days = append(a.Days, ds)
	}
	for i := range a.Days {
		byDay[a.Days[i].Date.Format("2006-01-02")] = &a.Days[i]
	}
	tzName := tz.String()
	rows, err := s.db.Query(ctx, `SELECT to_char(created_at AT TIME ZONE $3, 'YYYY-MM-DD'),
		count(*) FILTER (WHERE type = 'ticket_created'),
		count(*) FILTER (WHERE type = 'state_changed' AND data->>'to' = 'done'),
		count(*) FILTER (WHERE type = 'state_changed' AND data->>'to' = 'rejected'),
		count(*) FILTER (WHERE type = 'state_changed' AND data->>'to' IN ('failed', 'rate_limited'))
		FROM events WHERE created_at >= $1 AND created_at < $2 GROUP BY 1`, start, end, tzName)
	if err != nil {
		return a, err
	}
	for rows.Next() {
		var day string
		var p, pu, rj, st int
		if err := rows.Scan(&day, &p, &pu, &rj, &st); err != nil {
			rows.Close()
			return a, err
		}
		if d := byDay[day]; d != nil {
			d.Picked, d.Pushed, d.Rejected, d.Stopped = p, pu, rj, st
		}
	}
	rows.Close()

	rows, err = s.db.Query(ctx, `WITH `+stateSpans+`
		SELECT to_char(entered AT TIME ZONE $3, 'YYYY-MM-DD'),
		       COALESCE(sum(extract(epoch FROM left_at - entered)) FILTER (WHERE state = ANY($4)) / 60 / NULLIF(count(DISTINCT ticket_key), 0), 0),
		       COALESCE(sum(extract(epoch FROM left_at - entered)) FILTER (WHERE state = ANY($5)) / 60 / NULLIF(count(DISTINCT ticket_key), 0), 0)
		FROM spans WHERE left_at IS NOT NULL AND entered >= $1 AND entered < $2 GROUP BY 1`, start, end, tzName, working, waiting)
	if err != nil {
		return a, err
	}
	for rows.Next() {
		var day string
		var h, w float64
		if err := rows.Scan(&day, &h, &w); err != nil {
			rows.Close()
			return a, err
		}
		if d := byDay[day]; d != nil {
			d.AgntsMin, d.WaitMin = h, w
		}
	}
	rows.Close()

	rows, err = s.db.Query(ctx, `SELECT to_char(finished_at AT TIME ZONE $3, 'YYYY-MM-DD'), avg(turns)
		FROM runs WHERE stage = 'code' AND turns > 0 AND finished_at >= $1 AND finished_at < $2 GROUP BY 1`, start, end, tzName)
	if err != nil {
		return a, err
	}
	for rows.Next() {
		var day string
		var t float64
		if err := rows.Scan(&day, &t); err != nil {
			rows.Close()
			return a, err
		}
		if d := byDay[day]; d != nil {
			d.Turns = t
		}
	}
	rows.Close()

	rows, err = s.db.Query(ctx, `SELECT to_char(created_at AT TIME ZONE $3, 'YYYY-MM-DD'), max(five_hour)
		FROM usage_snapshots WHERE five_hour IS NOT NULL AND created_at >= $1 AND created_at < $2 GROUP BY 1`, start, end, tzName)
	if err != nil {
		return a, err
	}
	for rows.Next() {
		var day string
		var u float64
		if err := rows.Scan(&day, &u); err != nil {
			rows.Close()
			return a, err
		}
		if d := byDay[day]; d != nil {
			v := u
			d.PeakUsage = &v
		}
	}
	rows.Close()

	rows, err = s.db.Query(ctx, `SELECT to_char(created_at AT TIME ZONE $3, 'YYYY-MM-DD'),
		sum(input_tokens), sum(output_tokens), sum(cache_read_tokens), sum(cache_write_tokens), sum(cost_usd)::float8
		FROM claude_calls WHERE created_at >= $1 AND created_at < $2 GROUP BY 1`, start, end, tzName)
	if err != nil {
		return a, err
	}
	for rows.Next() {
		var day string
		var u domain.TokenUsage
		if err := rows.Scan(&day, &u.Input, &u.Output, &u.CacheRead, &u.CacheWrite, &u.CostUSD); err != nil {
			rows.Close()
			return a, err
		}
		if d := byDay[day]; d != nil {
			d.Spend = u
		}
	}
	rows.Close()

	// Spend by stage and model.
	rows, err = s.db.Query(ctx, `SELECT model_stage, model, count(*), sum(turns), bool_or(partial),
			sum(input_tokens), sum(output_tokens), sum(cache_read_tokens), sum(cache_write_tokens), sum(cost_usd)::float8
		FROM claude_calls WHERE created_at >= $1 AND created_at < $2
		GROUP BY model_stage, model ORDER BY sum(cost_usd) DESC, sum(input_tokens + output_tokens) DESC`, start, end)
	if err != nil {
		return a, err
	}
	for rows.Next() {
		var su domain.StageUsage
		u := &su.Usage
		if err := rows.Scan(&su.ModelStage, &su.Model, &su.Calls, &su.Turns, &su.Partial,
			&u.Input, &u.Output, &u.CacheRead, &u.CacheWrite, &u.CostUSD); err != nil {
			rows.Close()
			return a, err
		}
		a.Spend = append(a.Spend, su)
	}
	rows.Close()

	// Average minutes per state.
	rows, err = s.db.Query(ctx, `WITH `+stateSpans+`
		SELECT state, avg(extract(epoch FROM left_at - entered)) / 60 FROM spans
		WHERE left_at IS NOT NULL AND entered >= $1 AND entered < $2 AND state NOT IN ('done', 'rejected') GROUP BY state`, start, end)
	if err != nil {
		return a, err
	}
	for rows.Next() {
		var st string
		var m float64
		if err := rows.Scan(&st, &m); err != nil {
			rows.Close()
			return a, err
		}
		a.Steps[st] = m
	}
	rows.Close()

	// Why runs stopped, from how each run ended.
	rows, err = s.db.Query(ctx, `SELECT CASE
			WHEN exit_reason = 'checks_failed' THEN 'tests'
			WHEN exit_reason = 'rate_limited' THEN 'limit'
			WHEN exit_reason = 'stopped' THEN 'you'
			WHEN exit_reason = 'claude_error_max_turns' THEN 'turns'
			ELSE 'other' END, count(*)
		FROM runs WHERE finished_at >= $1 AND finished_at < $2 AND exit_reason NOT IN ('ok', 'interrupted', '') GROUP BY 1`, start, end)
	if err != nil {
		return a, err
	}
	for rows.Next() {
		var k string
		var n int
		if err := rows.Scan(&k, &n); err != nil {
			rows.Close()
			return a, err
		}
		a.Stops[k] = n
	}
	rows.Close()

	// Models: coding runs, and how many ended ready for review.
	rows, err = s.db.Query(ctx, `SELECT model, count(*), count(*) FILTER (WHERE exit_reason = 'ok'), COALESCE(avg(turns) FILTER (WHERE turns > 0), 0)
		FROM runs WHERE stage IN ('analyze', 'code') AND model <> '' AND started_at >= $1 AND started_at < $2
		GROUP BY model ORDER BY count(*) DESC`, start, end)
	if err != nil {
		return a, err
	}
	for rows.Next() {
		var m ModelStats
		if err := rows.Scan(&m.Model, &m.Runs, &m.ReachedReview, &m.AvgTurns); err != nil {
			rows.Close()
			return a, err
		}
		a.Models = append(a.Models, m)
	}
	rows.Close()

	// Repositories: tickets active in the period and how they ended.
	rows, err = s.db.Query(ctx, `WITH `+stateSpans+`,
		agnts AS (SELECT ticket_key, sum(extract(epoch FROM left_at - entered)) / 60 AS mins FROM spans
		         WHERE left_at IS NOT NULL AND state = ANY($3) AND entered >= $1 AND entered < $2 GROUP BY ticket_key)
		SELECT r.id, r.name, r.kind, r.claude_md_status, count(t.id),
		       count(t.id) FILTER (WHERE t.state = 'done'),
		       count(t.id) FILTER (WHERE t.state IN ('done', 'rejected', 'failed')),
		       COALESCE(avg(t.turns) FILTER (WHERE t.turns > 0), 0),
		       COALESCE(avg(h.mins), 0)
		FROM repositories r
		JOIN tickets t ON t.repo_id = r.id AND t.updated_at >= $1 AND t.updated_at < $2
		LEFT JOIN agnts h ON h.ticket_key = t.key
		GROUP BY r.id ORDER BY count(t.id) DESC`, start, end, working)
	if err != nil {
		return a, err
	}
	for rows.Next() {
		var r RepoStats
		if err := rows.Scan(&r.RepoID, &r.Name, &r.Kind, &r.ClaudeMD, &r.Tickets, &r.Done, &r.Finished, &r.AvgTurns, &r.AgntsMin); err != nil {
			rows.Close()
			return a, err
		}
		a.Repos = append(a.Repos, r)
	}
	rows.Close()

	if a.Quality, err = s.quality(ctx, start, end); err != nil {
		return a, err
	}

	// Activity by hour of day, agnts's own events only.
	rows, err = s.db.Query(ctx, `SELECT extract(hour FROM created_at AT TIME ZONE $3)::int, count(*) FROM events
		WHERE created_at >= $1 AND created_at < $2 AND origin = 'system' GROUP BY 1`, start, end, tzName)
	if err != nil {
		return a, err
	}
	for rows.Next() {
		var h, n int
		if err := rows.Scan(&h, &n); err != nil {
			rows.Close()
			return a, err
		}
		if h >= 0 && h < 24 {
			a.Hours[h] = n
		}
	}
	rows.Close()
	return a, rows.Err()
}

// period sums one range.
func (s *Agent) period(ctx context.Context, from, to time.Time) (Period, error) {
	var p Period
	err := s.db.QueryRow(ctx, `SELECT
		count(*) FILTER (WHERE type = 'ticket_created'),
		count(*) FILTER (WHERE type = 'state_changed' AND data->>'to' = 'done'),
		count(*) FILTER (WHERE type = 'state_changed' AND data->>'to' = 'rejected'),
		count(*) FILTER (WHERE type = 'state_changed' AND data->>'to' IN ('failed', 'rate_limited'))
		FROM events WHERE created_at >= $1 AND created_at < $2`, from, to).Scan(&p.Picked, &p.Pushed, &p.Rejected, &p.Stopped)
	if err != nil {
		return p, err
	}
	err = s.db.QueryRow(ctx, `SELECT count(*) FILTER (WHERE revision = 0), count(*) FILTER (WHERE revision > 0)
		FROM tickets WHERE state = 'done' AND updated_at >= $1 AND updated_at < $2`, from, to).Scan(&p.FirstTry, &p.AfterChanges)
	if err != nil {
		return p, err
	}
	err = s.db.QueryRow(ctx, `WITH `+stateSpans+`,
		per AS (SELECT ticket_key,
			sum(extract(epoch FROM left_at - entered)) FILTER (WHERE state = ANY($3)) AS agnts,
			sum(extract(epoch FROM left_at - entered)) FILTER (WHERE state = ANY($4)) AS wait,
			sum(extract(epoch FROM left_at - entered)) FILTER (WHERE state = 'waiting_for_review') AS review,
			sum(extract(epoch FROM left_at - entered)) FILTER (WHERE state = 'waiting_for_answers') AS answer
			FROM spans WHERE left_at IS NOT NULL AND entered >= $1 AND entered < $2 GROUP BY ticket_key)
		SELECT COALESCE(avg(COALESCE(agnts, 0)), 0) / 60, COALESCE(avg(COALESCE(wait, 0)), 0) / 60, COALESCE(avg(review), 0) / 60, COALESCE(avg(answer), 0) / 60 FROM per`,
		from, to, working, waiting).Scan(&p.AgntsMin, &p.WaitMin, &p.ReviewMin, &p.AnswerMin)
	if err != nil {
		return p, err
	}
	err = s.db.QueryRow(ctx, `SELECT COALESCE(avg(t), 0) FROM (
		SELECT ticket_id, sum(turns) AS t FROM runs WHERE turns > 0 AND started_at >= $1 AND started_at < $2 GROUP BY ticket_id) x`,
		from, to).Scan(&p.Turns)
	if err != nil {
		return p, err
	}
	err = s.db.QueryRow(ctx, `SELECT COALESCE(sum(input_tokens), 0), COALESCE(sum(output_tokens), 0),
		COALESCE(sum(cache_read_tokens), 0), COALESCE(sum(cache_write_tokens), 0), COALESCE(sum(cost_usd), 0)::float8
		FROM claude_calls WHERE created_at >= $1 AND created_at < $2`, from, to).
		Scan(&p.Spend.Input, &p.Spend.Output, &p.Spend.CacheRead, &p.Spend.CacheWrite, &p.Spend.CostUSD)
	return p, err
}

// quality groups the tickets whose first coding run started in [from, to)
// by that run's prompt version.
func (s *Agent) quality(ctx context.Context, from, to time.Time) ([]QualityStats, error) {
	rows, err := s.db.Query(ctx, `WITH first_code AS (
			SELECT DISTINCT ON (ticket_id) ticket_id, prompt_version, started_at
			FROM runs WHERE stage = 'code' ORDER BY ticket_id, started_at, id),
		cohort AS (
			SELECT f.ticket_id, f.prompt_version, f.started_at, t.key, t.state
			FROM first_code f JOIN tickets t ON t.id = f.ticket_id
			WHERE f.started_at >= $1 AND f.started_at < $2 AND t.replay_of = ''),
		per AS (
			SELECT c.prompt_version, c.started_at, c.state,
				EXISTS (SELECT 1 FROM events e WHERE e.ticket_key = c.key AND e.type = 'state_changed'
					AND e.data->>'to' = 'waiting_for_review') AS reached,
				(SELECT count(*) FROM events e WHERE e.ticket_key = c.key AND e.type = 'feedback' AND e.origin <> 'system') AS rounds,
				(SELECT count(*) FROM events e WHERE e.ticket_key = c.key AND e.type = 'feedback' AND e.origin = 'system') AS self_fixes,
				(SELECT COALESCE(sum(r.fix_attempts), 0) FROM runs r WHERE r.ticket_id = c.ticket_id AND r.stage = 'code') AS fixes,
				EXISTS (SELECT 1 FROM events e WHERE e.ticket_key = c.key AND e.type = 'review_done'
					AND (COALESCE((e.data->'counts'->>'blocker')::int, 0) + COALESCE((e.data->'counts'->>'major')::int, 0)) > 0) AS serious,
				(SELECT (e.data->>'recall')::float8 FROM events e WHERE e.ticket_key = c.key AND e.type = 'footprint_checked'
					ORDER BY e.id LIMIT 1) AS recall,
				(SELECT COALESCE(sum((e.data->>'count')::int), 0) FROM events e WHERE e.ticket_key = c.key AND e.type = 'red_flags') AS flags
			FROM cohort c)
		SELECT prompt_version, count(*),
			count(*) FILTER (WHERE reached),
			count(*) FILTER (WHERE state = 'done'),
			count(*) FILTER (WHERE state = 'done' AND rounds = 0),
			count(*) FILTER (WHERE state = 'rejected'),
			COALESCE(avg(rounds) FILTER (WHERE reached), 0)::float8,
			COALESCE(avg(fixes), 0)::float8,
			count(*) FILTER (WHERE serious),
			COALESCE(avg(recall), -1)::float8,
			COALESCE(sum(flags), 0)::int,
			COALESCE(sum(self_fixes), 0)::int
		FROM per GROUP BY prompt_version ORDER BY min(started_at)`, from, to)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := []QualityStats{}
	for rows.Next() {
		var q QualityStats
		if err := rows.Scan(&q.PromptVersion, &q.Tickets, &q.ReachedReview, &q.Done, &q.FirstTry, &q.Rejected,
			&q.ChangeRounds, &q.FixAttempts, &q.Serious, &q.FootprintHit, &q.RedFlags, &q.SelfFixes); err != nil {
			return nil, err
		}
		out = append(out, q)
	}
	return out, rows.Err()
}
