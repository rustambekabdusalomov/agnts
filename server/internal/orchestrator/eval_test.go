package orchestrator_test

import (
	"testing"
	"time"

	"agnts/internal/domain"
	"agnts/internal/orchestrator"
)

func TestEvaluate(t *testing.T) {
	edit := func(path string, line int) domain.FileChange {
		d := "--- a/" + path + "\n+++ b/" + path + "\n@@ -1,99 +1,99 @@\n"
		for i := 1; i < line; i++ {
			d += " x\n"
		}
		return domain.FileChange{Path: path, Diff: d + "-old\n+new\n"}
	}
	t0 := time.Date(2026, 10, 1, 9, 0, 0, 0, time.UTC)
	at := func(h int) time.Time { return t0.Add(time.Duration(h) * time.Hour) }
	merged := func(h int) *time.Time { x := at(h); return &x }
	ts := []orchestrator.EvalTicket{
		// A and B collide in main.go, and a rule predicted it.
		{Key: "PAY-1", RepoID: 1, Predicted: []string{"main.go", "a.go"}, FirstFiles: []domain.FileChange{edit("main.go", 3)},
			Files: []domain.FileChange{edit("main.go", 3)}, CodedAt: at(0), EndedAt: merged(5)},
		{Key: "PAY-2", RepoID: 1, Predicted: []string{"main.go"}, FirstFiles: []domain.FileChange{edit("main.go", 4)},
			Files: []domain.FileChange{edit("main.go", 4)}, CodedAt: at(1)},
		// C collides with B in x.go; nobody predicted it.
		{Key: "PAY-3", RepoID: 1, FirstFiles: []domain.FileChange{edit("x.go", 9)}, Files: []domain.FileChange{edit("x.go", 9), edit("main.go", 60)}, CodedAt: at(2)},
		// D was coded after A merged: no pair with A.
		{Key: "PAY-4", RepoID: 1, Files: []domain.FileChange{edit("main.go", 3)}, CodedAt: at(6), EndedAt: merged(7)},
		// E is in another repository.
		{Key: "WEB-1", RepoID: 2, Files: []domain.FileChange{edit("main.go", 3)}, CodedAt: at(1)},
	}
	ts[1].Files = append(ts[1].Files, edit("x.go", 10))
	decided := at(3)
	rs := []domain.Relation{
		{TicketKey: "PAY-1", OtherKey: "PAY-2", Type: domain.RelConflicts, Source: domain.RelFromRule, Status: domain.RelActive},
		{TicketKey: "PAY-3", OtherKey: "PAY-4", Type: domain.RelDependsOn, Source: domain.RelFromAgnts, Status: domain.RelDismissed, DecidedAt: &decided},
		{TicketKey: "PAY-2", OtherKey: "PAY-3", Type: domain.RelConflicts, Source: domain.RelFromGit, Status: domain.RelActive},
	}
	r := orchestrator.Evaluate(ts, rs, at(10))
	if r.Footprints != 2 || r.Precision != 0.75 || r.Recall != 1 {
		t.Fatalf("footprints: %+v", r)
	}
	// Pairs: 1-2, 1-3, 2-3, 2-4, 3-4 (1-4 never overlapped; WEB-1 is elsewhere).
	if r.Pairs != 5 || r.TruePositive != 1 || r.FalseNegative != 2 || r.FalsePositive != 1 {
		t.Fatalf("pairs: %+v", r)
	}
	if r.Missed[0].A != "PAY-2" || r.Missed[0].B != "PAY-3" || r.Missed[0].Files[0] != "x.go" || r.Rejected != 1 {
		t.Fatalf("missed: %+v", r)
	}
}
