package orchestrator_test

import (
	"bytes"
	"compress/gzip"
	"context"
	"io"
	"strings"
	"testing"

	"agnts/internal/ai"
	"agnts/internal/domain"
	"agnts/internal/orchestrator"
	"agnts/internal/store/postgres"
)

// A ticket's stages each leave a transcript, linked to the run and to the
// spend rows, and the run's output reaches it (masked).
func TestStagesAreRecorded(t *testing.T) {
	h := newHarness(t)
	rec := postgres.NewTranscripts(h.pool)
	h.o.SetRecorder(rec)
	h.ingest("PAY-40")
	spend := func(session string, cost float64) ai.Result {
		r := ok(session)
		r.Usage = domain.TokenUsage{Input: 100, Output: 10, CostUSD: cost}
		return r
	}
	h.runner.stream = func(on func(ai.Event)) {
		on(ai.Event{Kind: ai.EventToolResult, Data: map[string]any{"id": "t1", "is_error": true,
			"output": "FAIL with token glpat-abcdefghijklmnopqrstuvwxyz"}})
	}
	h.runner.scripts = []script{
		{result: spend("s40", 0.01), files: map[string]string{orchestrator.AnalysisPath: analysis(0)}},
		{result: spend("s40", 0.02), edit: "v1"},
		{result: spend("s40", 0.03), edit: "v2"},
	}
	h.runner.execs["go test ./..."] = []orchestrator.ExecResult{{ExitCode: 1, Output: "--- FAIL"}, {ExitCode: 0}}
	h.step() // analyze
	h.step() // code, then one fix attempt
	h.expect("PAY-40", domain.StateWaitingForReview)

	sys := domain.System(context.Background())
	list, err := rec.ListTranscripts(sys, domain.TranscriptFilter{TicketKey: "PAY-40"})
	if err != nil || len(list) != 3 {
		t.Fatalf("transcripts %+v %v", list, err)
	}
	analyze, coding, retry := list[2], list[1], list[0] // newest first
	if analyze.Purpose != "analyze" || coding.Purpose != "code" || retry.Purpose != "code" ||
		coding.ModelStage != domain.ModelCoding || retry.ModelStage != domain.ModelRetry {
		t.Fatalf("purposes %s/%s %s/%s %s/%s", analyze.Purpose, analyze.ModelStage, coding.Purpose, coding.ModelStage, retry.Purpose, retry.ModelStage)
	}
	for _, x := range list {
		if x.Status != domain.TranscriptDone || x.RunID == nil || x.ToolCalls != 1 || x.ToolErrors != 1 || x.Usage.CostUSD == 0 || x.WorkspaceSlug != "orch" {
			t.Fatalf("transcript %+v", x)
		}
	}
	if *coding.RunID != *retry.RunID || *analyze.RunID == *coding.RunID {
		t.Fatal("run links")
	}
	var linked int
	if err := h.pool.QueryRow(sys, `SELECT count(*) FROM claude_calls WHERE transcript_id IS NOT NULL`).Scan(&linked); err != nil || linked != 3 {
		t.Fatalf("spend rows linked: %d %v", linked, err)
	}
	body, err := rec.TranscriptBody(sys, coding.ID)
	if err != nil || len(body) == 0 {
		t.Fatalf("body: %v", err)
	}
	if text := gunzip(t, body); !contains(text, "FAIL with token") || contains(text, "glpat-abcdefghij") {
		t.Fatalf("body %s", text)
	}
	// The ticket log keeps Claude's stream without tool input and output.
	evs, _ := h.store.Events(h.ctx, orchestrator.EventFilter{TicketKey: "PAY-40"})
	for _, e := range evs {
		if !strings.HasPrefix(e.Type, "claude") {
			continue
		}
		_, in := e.Data["input"]
		if _, out := e.Data["output"]; in || out {
			t.Fatalf("event %s kept tool output", e.Type)
		}
	}
}

func gunzip(t *testing.T, b []byte) string {
	t.Helper()
	zr, err := gzip.NewReader(bytes.NewReader(b))
	if err != nil {
		t.Fatal(err)
	}
	out, err := io.ReadAll(zr)
	if err != nil {
		t.Fatal(err)
	}
	return string(out)
}

func contains(s, sub string) bool { return strings.Contains(s, sub) }
