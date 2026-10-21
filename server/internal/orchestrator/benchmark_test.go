package orchestrator_test

import (
	"errors"
	"testing"

	"agnts/internal/domain"
	"agnts/internal/orchestrator"
)

// A merged ticket's pull request is recorded as it merged; a person puts
// the ticket in the benchmark, which replays it with another model and
// scores the replay against the merge, next to agnts's original change.
func TestBenchmarkAgainstTheMerge(t *testing.T) {
	h := newHarness(t)
	host := newConvHost()
	convOrchestrator(h, host)
	h.git.files = []domain.FileChange{{Path: "refund.go", Add: 2, Diff: "@@ -1 +1,3 @@\n+func refund() int {\n+\treturn round(amount)\n }"}}
	h.ingest("PAY-1")
	h.runner.scripts = []script{
		{result: ok("s1"), files: map[string]string{orchestrator.AnalysisPath: analysis(0)}},
		{result: ok("s1"), edit: "fix"},
	}
	h.step() // analyze
	h.step() // code
	if _, err := h.o.Approve(h.ctx, "PAY-1", nil, false, domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	h.step() // push: pull request #7
	if _, err := h.o.SetBenchmark(h.ctx, "PAY-1", true, domain.OriginWeb); !errors.Is(err, orchestrator.ErrInvalid) {
		t.Fatalf("an unmerged ticket went into the benchmark: %v", err)
	}

	// A reviewer changed agnts's work before merging: one line kept, one
	// replaced, one added.
	host.files = []domain.FileChange{{Path: "refund.go", Add: 3, Diff: "@@ -1 +1,4 @@\n+func refund() int {\n+\treturn money.Round(amount)\n+\t// cents\n }"}}
	if ok, err := h.o.MarkMerged(h.ctx, domain.PRRef{URL: "https://github.com/acme/api/pull/7"}, domain.OriginWebhook); err != nil || !ok {
		t.Fatalf("merge: %v %v", ok, err)
	}
	orig := h.state("PAY-1")
	ms, err := h.store.MergedChanges(h.ctx, orig.ID)
	if err != nil || len(ms) != 1 || ms[0].Number != 7 || ms[0].HeadSHA != orig.HeadSHA || len(ms[0].Files) != 1 {
		t.Fatalf("merged change: %+v %v", ms, err)
	}

	if tk, err := h.o.SetBenchmark(h.ctx, "PAY-1", true, domain.OriginWeb); err != nil || !tk.Benchmark {
		t.Fatalf("add to benchmark: %+v %v", tk.Benchmark, err)
	}
	if _, err := h.o.RunBenchmark(h.ctx, map[string]string{"coding": "gpt"}, domain.OriginWeb); !errors.Is(err, orchestrator.ErrInvalid) {
		t.Fatalf("an unknown model: %v", err)
	}
	runs, err := h.o.RunBenchmark(h.ctx, map[string]string{"coding": "opus"}, domain.OriginWeb)
	if err != nil || len(runs) != 1 || runs[0].Replay == nil || runs[0].Replay.Models["coding"] != "opus" {
		t.Fatalf("benchmark run: %+v %v", runs, err)
	}

	// The replay writes what the reviewer merged, but for the comment.
	h.git.files = []domain.FileChange{{Path: "refund.go", Add: 2, Diff: "@@ -1 +1,3 @@\n+func refund() int {\n+\treturn money.Round(amount)\n }"}}
	h.runner.scripts = []script{
		{result: ok("s2"), files: map[string]string{orchestrator.AnalysisPath: analysis(0)}},
		{result: ok("s2"), edit: "fix again"},
	}
	h.step() // analyze the replay
	h.step() // code it
	rep, err := h.o.ReplayReport(h.ctx)
	if err != nil {
		t.Fatal(err)
	}
	if len(rep.Replays) != 1 || len(rep.Benchmark) != 1 || len(rep.Versions) != 1 {
		t.Fatalf("report: %+v", rep)
	}
	x, v := rep.Replays[0], rep.Benchmark[0]
	// The merge adds 3 meaningful lines: the replay has 2 of them, agnts's
	// original only the first.
	if x.Against != "merged" || !x.Benchmark || x.Model != "opus" || x.Recall != 1 || !near(x.LineRecall, 2.0/3) || !near(x.OriginalLineRecall, 1.0/3) {
		t.Fatalf("replay result: %+v", x)
	}
	if v.Model != "opus" || v.Merged != 1 || !near(v.AvgLineRecall, 2.0/3) || !near(v.OriginalLineRecall, 1.0/3) {
		t.Fatalf("benchmark version: %+v", v)
	}

	if tk, err := h.o.SetBenchmark(h.ctx, "PAY-1", false, domain.OriginWeb); err != nil || tk.Benchmark {
		t.Fatalf("take out of benchmark: %v", err)
	}
	if _, err := h.o.RunBenchmark(h.ctx, nil, domain.OriginWeb); !errors.Is(err, orchestrator.ErrInvalid) {
		t.Fatalf("running an empty benchmark: %v", err)
	}
}

func near(a, b float64) bool { return a-b < 1e-9 && b-a < 1e-9 }
