package main

import (
	"context"
	"fmt"
	"io"
	"strings"
	"time"

	"agnts/internal/orchestrator"
	"agnts/internal/store/postgres"
)

// evalRelations replays every coded ticket and prints how well the queue
// predicted what each change touches and which changes collide.
func evalRelations(ctx context.Context, pool postgresPool, out io.Writer) error {
	ts, rs, err := postgres.NewAgent(pool).EvalData(ctx)
	if err != nil {
		return err
	}
	r := orchestrator.Evaluate(ts, rs, time.Now())
	p := func(format string, a ...any) { _, _ = fmt.Fprintf(out, format, a...) }
	ratio := func(a, b int) string {
		if b == 0 {
			return "n/a"
		}
		return fmt.Sprintf("%.0f%%", 100*float64(a)/float64(b))
	}

	p("Footprints: %d coded tickets had a prediction\n", r.Footprints)
	if r.Footprints > 0 {
		p("  precision %.0f%% (predicted files the change touched)\n  recall    %.0f%% (changed files the analysis predicted)\n", 100*r.Precision, 100*r.Recall)
	}
	p("\nConflicts: %d pairs of changes were open at the same time\n", r.Pairs)
	p("  predicted and collided   %d\n  predicted, no collision  %d\n  collided, not predicted  %d\n", r.TruePositive, r.FalsePositive, r.FalseNegative)
	p("  precision %s, recall %s\n", ratio(r.TruePositive, r.TruePositive+r.FalsePositive), ratio(r.TruePositive, r.TruePositive+r.FalseNegative))
	for _, m := range r.Missed {
		p("  missed: %s and %s (%s)\n", m.A, m.B, strings.Join(m.Files, ", "))
	}
	p("\nProposals: %d accepted, %d dismissed, %d waiting (acceptance %s)\n", r.Accepted, r.Rejected, r.Pending, ratio(r.Accepted, r.Accepted+r.Rejected))
	return nil
}
