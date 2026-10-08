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

	"agnts/internal/domain"
	"agnts/internal/store/postgres"
)

// Handler returns the /metrics handler.
func Handler(db *pgxpool.Pool, active func() int) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// Metrics count every workspace.
		ctx, cancel := context.WithTimeout(domain.System(r.Context()), 5*time.Second)
		defer cancel()
		w.Header().Set("Content-Type", "text/plain; version=0.0.4")
		if err := write(ctx, w, db, active); err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
		}
	})
}

func write(ctx context.Context, w io.Writer, db *pgxpool.Pool, active func() int) error {
	p := func(format string, a ...any) { _, _ = fmt.Fprintf(w, format, a...) }

	p("# HELP agnts_active_runs Stages running right now.\n# TYPE agnts_active_runs gauge\nagnts_active_runs %d\n", active())

	rows, err := db.Query(ctx, `SELECT state, count(*) FROM tickets GROUP BY state`)
	if err != nil {
		return err
	}
	p("# HELP agnts_tickets Tickets by state.\n# TYPE agnts_tickets gauge\n")
	for rows.Next() {
		var st string
		var n int
		if err := rows.Scan(&st, &n); err != nil {
			rows.Close()
			return err
		}
		p("agnts_tickets{state=%q} %d\n", st, n)
	}
	rows.Close()

	var queue, waiting int
	if err := db.QueryRow(ctx, `SELECT count(*) FILTER (WHERE NOT `+postgres.WaitsCondition+`), count(*) FILTER (WHERE `+postgres.WaitsCondition+`)
		FROM tickets t WHERE state IN ('new', 'coding', 'pushing') AND NOT held
		AND NOT EXISTS (SELECT 1 FROM runs r WHERE r.ticket_id = t.id AND r.finished_at IS NULL)`).Scan(&queue, &waiting); err != nil {
		return err
	}
	p("# HELP agnts_queue_length Tickets waiting for a worker.\n# TYPE agnts_queue_length gauge\nagnts_queue_length %d\n", queue)
	p("# HELP agnts_tickets_waiting Tickets whose coding waits for another ticket to merge.\n# TYPE agnts_tickets_waiting gauge\nagnts_tickets_waiting %d\n", waiting)
	if err := writeRelations(ctx, p, db); err != nil {
		return err
	}

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
	p("# HELP agnts_runs_total Finished runs by stage and how they ended.\n# TYPE agnts_runs_total counter\n")
	for k, n := range counts {
		p("agnts_runs_total{stage=%q,exit=%q} %d\n", k.stage, k.exit, n)
	}
	p("# HELP agnts_run_duration_seconds Run durations.\n# TYPE agnts_run_duration_seconds summary\n")
	for st, s := range durSum {
		p("agnts_run_duration_seconds_sum{stage=%q} %f\nagnts_run_duration_seconds_count{stage=%q} %d\n", st, s, st, durCount[st])
	}
	var errs int
	if err := db.QueryRow(ctx, `SELECT count(*) FROM events WHERE level = 'error'`).Scan(&errs); err != nil {
		return err
	}
	p("# HELP agnts_error_events_total Error events logged.\n# TYPE agnts_error_events_total counter\nagnts_error_events_total %d\n", errs)
	return nil
}

// writeRelations reports the ordering constraints and how well agnts
// predicts them: footprint precision and recall against the real diffs,
// and finished changes that collided, by whether the collision was
// predicted (active, proposed, dismissed) or not (none).
func writeRelations(ctx context.Context, p func(string, ...any), db *pgxpool.Pool) error {
	rows, err := db.Query(ctx, `SELECT type, source, status, count(*), count(confirmed_at) FROM ticket_relations GROUP BY type, source, status`)
	if err != nil {
		return err
	}
	p("# HELP agnts_relations Ordering constraints between tickets.\n# TYPE agnts_relations gauge\n")
	confirmed := map[string]int{}
	for rows.Next() {
		var typ, src, st string
		var n, c int
		if err := rows.Scan(&typ, &src, &st, &n, &c); err != nil {
			rows.Close()
			return err
		}
		p("agnts_relations{type=%q,source=%q,status=%q} %d\n", typ, src, st, n)
		confirmed[src] += c
	}
	rows.Close()
	p("# HELP agnts_relations_confirmed Relations the finished changes proved real, by who predicted them.\n# TYPE agnts_relations_confirmed gauge\n")
	for src, n := range confirmed {
		p("agnts_relations_confirmed{source=%q} %d\n", src, n)
	}

	var n int
	var precision, recall float64
	if err := db.QueryRow(ctx, `SELECT count(*), COALESCE(sum((data->>'precision')::float8), 0), COALESCE(sum((data->>'recall')::float8), 0)
		FROM events WHERE type = 'footprint_checked'`).Scan(&n, &precision, &recall); err != nil {
		return err
	}
	p("# HELP agnts_footprint_precision Share of predicted files the change really touched.\n# TYPE agnts_footprint_precision summary\n")
	p("agnts_footprint_precision_sum %f\nagnts_footprint_precision_count %d\n", precision, n)
	p("# HELP agnts_footprint_recall Share of changed files the analysis predicted.\n# TYPE agnts_footprint_recall summary\n")
	p("agnts_footprint_recall_sum %f\nagnts_footprint_recall_count %d\n", recall, n)

	rows, err = db.Query(ctx, `SELECT data->>'predicted', count(*) FROM events
		WHERE type = 'collision_found' AND data ? 'predicted' AND run_id IS NOT NULL GROUP BY 1`)
	if err != nil {
		return err
	}
	p("# HELP agnts_collisions_total Finished changes that touch the same lines as another unmerged change.\n# TYPE agnts_collisions_total counter\n")
	for rows.Next() {
		var pred string
		var c int
		if err := rows.Scan(&pred, &c); err != nil {
			rows.Close()
			return err
		}
		p("agnts_collisions_total{predicted=%q} %d\n", pred, c)
	}
	rows.Close()
	return rows.Err()
}
