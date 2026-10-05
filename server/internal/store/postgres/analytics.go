package postgres

import (
	"context"
	"time"
)

// DayStats is one day of the Analytics page.
type DayStats struct {
	Date      time.Time
	Picked    int
	Pushed    int
	Rejected  int
	Stopped   int
	HiroMin   float64 // average minutes hiro worked per ticket active that day
	WaitMin   float64 // average minutes tickets waited on you
	Turns     float64 // average turns of coding runs that finished that day
	PeakUsage *float64
}

// Period sums a range of days.
type Period struct {
	Picked, Pushed, Rejected, Stopped int
	FirstTry, AfterChanges            int
	HiroMin, WaitMin, Turns           float64
	ReviewMin, AnswerMin              float64
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
	HiroMin  float64
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
			d.HiroMin, d.WaitMin = h, w
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
		hiro AS (SELECT ticket_key, sum(extract(epoch FROM left_at - entered)) / 60 AS mins FROM spans
		         WHERE left_at IS NOT NULL AND state = ANY($3) AND entered >= $1 AND entered < $2 GROUP BY ticket_key)
		SELECT r.id, r.name, r.kind, r.claude_md_status, count(t.id),
		       count(t.id) FILTER (WHERE t.state = 'done'),
		       count(t.id) FILTER (WHERE t.state IN ('done', 'rejected', 'failed')),
		       COALESCE(avg(t.turns) FILTER (WHERE t.turns > 0), 0),
		       COALESCE(avg(h.mins), 0)
		FROM repositories r
		JOIN tickets t ON t.repo_id = r.id AND t.updated_at >= $1 AND t.updated_at < $2
		LEFT JOIN hiro h ON h.ticket_key = t.key
		GROUP BY r.id ORDER BY count(t.id) DESC`, start, end, working)
	if err != nil {
		return a, err
	}
	for rows.Next() {
		var r RepoStats
		if err := rows.Scan(&r.RepoID, &r.Name, &r.Kind, &r.ClaudeMD, &r.Tickets, &r.Done, &r.Finished, &r.AvgTurns, &r.HiroMin); err != nil {
			rows.Close()
			return a, err
		}
		a.Repos = append(a.Repos, r)
	}
	rows.Close()

	// Activity by hour of day, hiro's own events only.
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
			sum(extract(epoch FROM left_at - entered)) FILTER (WHERE state = ANY($3)) AS hiro,
			sum(extract(epoch FROM left_at - entered)) FILTER (WHERE state = ANY($4)) AS wait,
			sum(extract(epoch FROM left_at - entered)) FILTER (WHERE state = 'waiting_for_review') AS review,
			sum(extract(epoch FROM left_at - entered)) FILTER (WHERE state = 'waiting_for_answers') AS answer
			FROM spans WHERE left_at IS NOT NULL AND entered >= $1 AND entered < $2 GROUP BY ticket_key)
		SELECT COALESCE(avg(COALESCE(hiro, 0)), 0) / 60, COALESCE(avg(COALESCE(wait, 0)), 0) / 60, COALESCE(avg(review), 0) / 60, COALESCE(avg(answer), 0) / 60 FROM per`,
		from, to, working, waiting).Scan(&p.HiroMin, &p.WaitMin, &p.ReviewMin, &p.AnswerMin)
	if err != nil {
		return p, err
	}
	err = s.db.QueryRow(ctx, `SELECT COALESCE(avg(t), 0) FROM (
		SELECT ticket_id, sum(turns) AS t FROM runs WHERE turns > 0 AND started_at >= $1 AND started_at < $2 GROUP BY ticket_id) x`,
		from, to).Scan(&p.Turns)
	return p, err
}
