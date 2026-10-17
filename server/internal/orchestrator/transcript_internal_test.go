package orchestrator

import (
	"bufio"
	"bytes"
	"compress/gzip"
	"context"
	"encoding/json"
	"errors"
	"io"
	"io/fs"
	"log/slog"
	"os"
	"path/filepath"
	"regexp"
	"strings"
	"sync"
	"testing"
	"time"
	"unicode/utf8"

	"agnts/internal/domain"
)

// decodeBody reads a stored body (one or more gzip members) as lines.
func decodeBody(t *testing.T, body []byte) []map[string]any {
	t.Helper()
	zr, err := gzip.NewReader(bytes.NewReader(body))
	if err != nil {
		t.Fatal(err)
	}
	var out []map[string]any
	sc := bufio.NewScanner(zr)
	sc.Buffer(nil, 64<<20)
	for sc.Scan() {
		var m map[string]any
		if err := json.Unmarshal(sc.Bytes(), &m); err != nil {
			t.Fatalf("line %q: %v", sc.Text(), err)
		}
		out = append(out, m)
	}
	if err := sc.Err(); err != nil {
		t.Fatal(err)
	}
	return out
}

func TestTranscriptWriterLines(t *testing.T) {
	sw := domain.NewRedactor(domain.AuthBearer, "swagger-token-123456")
	w := newTranscriptWriter(domain.RunHistorySettings{ToolOutputKB: 1, TextKB: 1, TranscriptMB: 8}, &sw)
	w.event(ClaudeEvent{Kind: ClaudeInit, Data: map[string]any{"session_id": "s1", "model": "opus"}})
	w.event(ClaudeEvent{Kind: ClaudeText, Text: "calling the API with swagger-token-123456"})
	w.event(ClaudeEvent{Kind: ClaudeTool, Tool: "Bash: go test", Data: map[string]any{"tool": "Bash", "id": "t1",
		"input": json.RawMessage(`{"command":"go test ./..."}`)}})
	big := strings.Repeat("a", 3000) + "THE ERROR AT THE END"
	w.event(ClaudeEvent{Kind: ClaudeToolResult, Data: map[string]any{"id": "t1", "is_error": true, "output": big}})
	w.event(ClaudeEvent{Kind: ClaudeToolResult, Data: map[string]any{"id": "t2", "is_error": false,
		"output": "GITHUB_TOKEN=ghp_" + strings.Repeat("Z9", 20)}})
	first, _ := w.take()
	w.note("stall: the same test failed 6 times")
	w.event(ClaudeEvent{Kind: ClaudeResultEv, Text: "done", Data: map[string]any{"subtype": "success", "is_error": false, "num_turns": 3, "total_cost_usd": 0.5}})
	second, counts := w.take()

	lines := decodeBody(t, append(first, second...)) // two gzip members read as one stream
	kinds := []string{}
	for _, l := range lines {
		kinds = append(kinds, l["k"].(string))
		if _, ok := l["t"]; !ok {
			t.Fatalf("line without time: %v", l)
		}
	}
	if strings.Join(kinds, ",") != "init,text,tool,tool_result,tool_result,note,result" {
		t.Fatalf("kinds %v", kinds)
	}
	if strings.Contains(lines[1]["text"].(string), "swagger-token") {
		t.Fatalf("the run's credential was kept: %v", lines[1])
	}
	if in := lines[2]["input"].(map[string]any); in["command"] != "go test ./..." {
		t.Fatalf("tool input %v", lines[2])
	}
	out := lines[3]["output"].(string)
	if len(out) > 1200 || !strings.HasSuffix(out, "THE ERROR AT THE END") || lines[3]["cut"].(float64) != float64(len(big)) {
		t.Fatalf("cut output (%d bytes): %q… cut=%v", len(out), out[:40], lines[3]["cut"])
	}
	if strings.Contains(lines[4]["output"].(string), "Z9Z9") {
		t.Fatalf("a token-shaped secret was kept: %v", lines[4])
	}
	if lines[6]["cost"].(float64) != 0.5 {
		t.Fatalf("result %v", lines[6])
	}
	if counts.ToolCalls != 1 || counts.ToolErrors != 1 || counts.Truncated || counts.RawBytes == 0 {
		t.Fatalf("counts %+v", counts)
	}
	if chunk, _ := w.take(); chunk != nil {
		t.Fatal("an empty take returned a chunk")
	}
}

func TestTranscriptWriterCap(t *testing.T) {
	w := newTranscriptWriter(domain.RunHistorySettings{ToolOutputKB: 1024, TextKB: 1024, TranscriptMB: 1}, nil)
	for i := 0; i < 3; i++ {
		w.event(ClaudeEvent{Kind: ClaudeText, Text: strings.Repeat("x", 600<<10)})
	}
	w.event(ClaudeEvent{Kind: ClaudeTool, Tool: "Read: a.go", Data: map[string]any{"tool": "Read", "id": "t9",
		"input": json.RawMessage(`{"file_path":"a.go"}`)}})
	w.event(ClaudeEvent{Kind: ClaudeResultEv, Text: "done", Data: map[string]any{"subtype": "success"}})
	body, counts := w.take()
	lines := decodeBody(t, body)
	if !counts.Truncated || len(lines) != 4 { // two texts fit, the third is past the cap; tool and result are kept
		t.Fatalf("truncated=%v, %d lines", counts.Truncated, len(lines))
	}
	if lines[2]["k"] != "tool" || lines[2]["input"] != nil || lines[3]["k"] != "result" {
		t.Fatalf("past the cap: %v / %v", lines[2], lines[3])
	}
}

func TestTranscriptWriterDue(t *testing.T) {
	w := newTranscriptWriter(domain.DefaultRunHistory, nil)
	now := time.Now()
	if w.due(now.Add(2 * time.Minute)) {
		t.Fatal("due with nothing written")
	}
	w.note("x")
	if w.due(now) || !w.due(now.Add(flushEvery+time.Second)) {
		t.Fatal("time flush")
	}
	w.event(ClaudeEvent{Kind: ClaudeText, Text: strings.Repeat("y", 30<<10)})
	for i := 0; i < 10; i++ {
		w.event(ClaudeEvent{Kind: ClaudeText, Text: strings.Repeat("y", 30<<10)})
	}
	if !w.due(now) {
		t.Fatal("size flush")
	}
}

func TestCutMiddleKeepsUTF8(t *testing.T) {
	s := strings.Repeat("ё", 2000) // two bytes each
	got, n := cutMiddle(s, 1001)
	if n != len(s) || !utf8.ValidString(got) {
		t.Fatalf("cut %d, valid %v", n, utf8.ValidString(got))
	}
	if same, n := cutMiddle("short", 10); same != "short" || n != 0 {
		t.Fatal("a short text was cut")
	}
}

func TestTranscriptEnd(t *testing.T) {
	ctx := context.Background()
	cancelled, cancel := context.WithCancel(ctx)
	cancel()
	for _, tc := range []struct {
		ctx  context.Context
		res  ClaudeResult
		err  error
		want domain.TranscriptStatus
	}{
		{ctx, ClaudeResult{Subtype: "success"}, nil, domain.TranscriptDone},
		{ctx, ClaudeResult{Subtype: "error_max_turns", IsError: true}, nil, domain.TranscriptError},
		{ctx, ClaudeResult{RateLimited: true}, nil, domain.TranscriptError},
		{ctx, ClaudeResult{}, errors.New("claude timed out after 30m0s"), domain.TranscriptTimeout},
		{ctx, ClaudeResult{}, &OOMError{LimitMB: 4096}, domain.TranscriptOOM},
		{cancelled, ClaudeResult{}, context.Canceled, domain.TranscriptCancelled},
		{ctx, ClaudeResult{}, errors.New("docker exec failed"), domain.TranscriptError},
	} {
		if got := transcriptEnd(tc.ctx, tc.res, tc.err); got.Status != tc.want {
			t.Errorf("%+v %v: %s, want %s", tc.res, tc.err, got.Status, tc.want)
		}
	}
}

// memRecorder keeps transcripts in memory; fail makes every write fail.
type memRecorder struct {
	mu     sync.Mutex
	starts []domain.TranscriptStart
	bodies map[int64][]byte
	ends   map[int64]domain.TranscriptEnd
	fail   bool
}

func (m *memRecorder) StartTranscript(_ context.Context, s domain.TranscriptStart) (int64, error) {
	m.mu.Lock()
	defer m.mu.Unlock()
	if m.fail {
		return 0, errors.New("database down")
	}
	m.starts = append(m.starts, s)
	return int64(len(m.starts)), nil
}

func (m *memRecorder) AppendTranscript(_ context.Context, id int64, chunk []byte, _ domain.TranscriptCounts) error {
	m.mu.Lock()
	defer m.mu.Unlock()
	m.bodies[id] = append(m.bodies[id], chunk...)
	return nil
}

func (m *memRecorder) FinishTranscript(_ context.Context, id int64, chunk []byte, e domain.TranscriptEnd) error {
	m.mu.Lock()
	defer m.mu.Unlock()
	m.bodies[id] = append(m.bodies[id], chunk...)
	m.ends[id] = e
	return nil
}

func (m *memRecorder) RecoverTranscripts(context.Context) (int, error) { return 0, nil }

func (m *memRecorder) RunHistorySettings(context.Context) (domain.RunHistorySettings, error) {
	return domain.DefaultRunHistory, nil
}

// scriptedWS is a Workspace whose Claude streams fixed events.
type scriptedWS struct {
	Workspace
	events []ClaudeEvent
	res    ClaudeResult
	err    error
}

func (w scriptedWS) Claude(_ context.Context, _ ClaudeRequest, on func(ClaudeEvent)) (ClaudeResult, error) {
	for _, e := range w.events {
		if on != nil {
			on(e)
		}
	}
	return w.res, w.err
}

func TestCallClaudeRecords(t *testing.T) {
	rec := &memRecorder{bodies: map[int64][]byte{}, ends: map[int64]domain.TranscriptEnd{}}
	o := &Orchestrator{recorder: rec, log: slog.New(slog.NewTextHandler(io.Discard, nil))}
	ctx := domain.WithClaude(domain.System(context.Background()), domain.ClaudeAccount{ConnectionID: 7, Label: "team"})
	run := &domain.Run{ID: 42, Stage: domain.StageCode}
	ws := scriptedWS{events: []ClaudeEvent{
		{Kind: ClaudeTool, Tool: "Bash: go test", Data: map[string]any{"tool": "Bash", "id": "t1"}},
		{Kind: ClaudeToolResult, Data: map[string]any{"id": "t1", "is_error": true, "output": "FAIL"}},
	}, res: ClaudeResult{Subtype: "success", Turns: 3, Usage: domain.TokenUsage{Input: 10, CostUSD: 0.2}}}
	seen := 0
	res, err := o.callClaude(ctx, ws, transcriptMeta{Purpose: "code", WorkspaceID: 5, Run: run, TicketKey: "PAY-1", ModelStage: "coding"},
		ClaudeRequest{Prompt: "fix it", Model: "opus"}, func(ClaudeEvent) {
			seen++
			run.Harness.Stalls = append(run.Harness.Stalls, domain.Stall{Reason: "loop"}) // a stall during the call
		})
	if err != nil || res.TranscriptID != 1 || seen != 2 {
		t.Fatalf("res %+v err %v seen %d", res, err, seen)
	}
	s := rec.starts[0]
	if s.WorkspaceID != 5 || *s.RunID != 42 || s.TicketKey != "PAY-1" || s.Purpose != "code" || s.Engine != "claude" ||
		*s.ConnectionID != 7 || s.ClaudeLabel != "team" || len(s.Prompt) == 0 {
		t.Fatalf("start %+v", s)
	}
	end := rec.ends[1]
	if end.Status != domain.TranscriptDone || end.Turns != 3 || end.Stalls != 2 || end.Counts.ToolErrors != 1 || end.Usage.CostUSD != 0.2 {
		t.Fatalf("end %+v", end)
	}
	if n := len(decodeBody(t, rec.bodies[1])); n != 2 {
		t.Fatalf("%d lines", n)
	}
	if _, ok := o.transcripts.Load(int64(42)); ok {
		t.Fatal("the run's writer was left registered")
	}

	// Without a workspace nothing is recorded, and the call still runs.
	o2 := &Orchestrator{recorder: rec, log: o.log}
	if _, err := o2.callClaude(domain.System(context.Background()), ws, transcriptMeta{Purpose: domain.PurposeDetect}, ClaudeRequest{}, nil); err != nil || len(rec.starts) != 1 {
		t.Fatalf("no workspace: %v, %d starts", err, len(rec.starts))
	}
	// A failing recorder never fails the run.
	rec.fail = true
	ws.err = errors.New("claude ended badly")
	if _, err := o.callClaude(ctx, ws, transcriptMeta{Purpose: domain.PurposeBrief, WorkspaceID: 5}, ClaudeRequest{}, nil); err == nil || err.Error() != "claude ended badly" {
		t.Fatalf("failing recorder: %v", err)
	}
}

// Every Claude Code or Codex invocation goes through callClaude, so it is
// recorded. The usage refresh is the one exception: a one-turn probe in a
// throwaway container, with no workspace.
func TestEveryClaudeCallIsRecorded(t *testing.T) {
	call := regexp.MustCompile(`\.Claude\(ctx`)
	allowed := map[string]bool{
		filepath.Join("orchestrator", "transcript.go"): true, // callClaude itself
		filepath.Join("usage", "usage.go"):             true, // the usage refresh probe
	}
	root := ".."
	err := filepath.WalkDir(root, func(p string, d fs.DirEntry, err error) error {
		if err != nil || d.IsDir() || !strings.HasSuffix(p, ".go") || strings.HasSuffix(p, "_test.go") {
			return err
		}
		b, err := os.ReadFile(p)
		if err != nil {
			return err
		}
		rel, _ := filepath.Rel(root, p)
		for i, line := range strings.Split(string(b), "\n") {
			if call.MatchString(line) && !strings.Contains(line, "o.callClaude(") && !allowed[rel] {
				t.Errorf("%s:%d calls Claude without recording it; use o.callClaude: %s", rel, i+1, strings.TrimSpace(line))
			}
		}
		return nil
	})
	if err != nil {
		t.Fatal(err)
	}
}
