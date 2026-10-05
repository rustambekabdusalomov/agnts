// Package metrics serves Prometheus metrics computed from the database, so
// they survive restarts and need no instrumentation in the hot paths.
package metrics

import (
	"context"
	"fmt"
	"io"
	"net/http"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"
)

// Handler returns the /metrics handler.
func Handler(db *pgxpool.Pool, active func() int) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		ctx, cancel := context.WithTimeout(r.Context(), 5*time.Second)
		defer cancel()
		w.Header().Set("Content-Type", "text/plain; version=0.0.4")
		if err := write(ctx, w, db, active); err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
		}
	})
}

func write(ctx context.Context, w io.Writer, db *pgxpool.Pool, active func() int) error {
	p := func(format string, a ...any) { _, _ = fmt.Fprintf(w, format, a...) }

	p("# HELP hiro_active_runs Stages running right now.\n# TYPE hiro_active_runs gauge\nhiro_active_runs %d\n", active())

	rows, err := db.Query(ctx, `SELECT state, count(*) FROM tickets GROUP BY state`)
	if err != nil {
		return err
	}
	p("# HELP hiro_tickets Tickets by state.\n# TYPE hiro_tickets gauge\n")
	for rows.Next() {
		var st string
		var n int
		if err := rows.Scan(&st, &n); err != nil {
			rows.Close()
			return err
		}
		p("hiro_tickets{state=%q} %d\n", st, n)
	}
	rows.Close()

	var queue int
	if err := db.QueryRow(ctx, `SELECT count(*) FROM tickets t WHERE state IN ('new', 'coding', 'pushing') AND NOT held
		AND NOT EXISTS (SELECT 1 FROM runs r WHERE r.ticket_id = t.id AND r.finished_at IS NULL)`).Scan(&queue); err != nil {
		return err
	}
	p("# HELP hiro_queue_length Tickets waiting for a worker.\n# TYPE hiro_queue_length gauge\nhiro_queue_length %d\n", queue)

	rows, err = db.Query(ctx, `SELECT stage, exit_reason, count(*), COALESCE(sum(extract(epoch FROM finished_at - started_at)), 0)
		FROM runs WHERE finished_at IS NOT NULL GROUP BY stage, exit_reason`)
	if err != nil {
		return err
	}
	type key struct{ stage, exit string }
	counts := map[key]int{}
	durSum, durCount := map[string]float64{}, map[string]int{}
	for rows.Next() {
		var k key
		var n int
		var secs float64
		if err := rows.Scan(&k.stage, &k.exit, &n, &secs); err != nil {
			rows.Close()
			return err
		}
		counts[k] = n
		durSum[k.stage] += secs
		durCount[k.stage] += n
	}
	rows.Close()
	p("# HELP hiro_runs_total Finished runs by stage and how they ended.\n# TYPE hiro_runs_total counter\n")
	for k, n := range counts {
		p("hiro_runs_total{stage=%q,exit=%q} %d\n", k.stage, k.exit, n)
	}
	p("# HELP hiro_run_duration_seconds Run durations.\n# TYPE hiro_run_duration_seconds summary\n")
	for st, s := range durSum {
		p("hiro_run_duration_seconds_sum{stage=%q} %f\nhiro_run_duration_seconds_count{stage=%q} %d\n", st, s, st, durCount[st])
	}
	var errs int
	if err := db.QueryRow(ctx, `SELECT count(*) FROM events WHERE level = 'error'`).Scan(&errs); err != nil {
		return err
	}
	p("# HELP hiro_error_events_total Error events logged.\n# TYPE hiro_error_events_total counter\nhiro_error_events_total %d\n", errs)
	return nil
}
