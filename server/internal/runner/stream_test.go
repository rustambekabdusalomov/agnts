package runner

import (
	"os"
	"testing"

	"hiro/internal/orchestrator"
)

func parseFile(t *testing.T, name string) (orchestrator.ClaudeResult, []orchestrator.ClaudeEvent, error) {
	t.Helper()
	f, err := os.Open("testdata/" + name)
	if err != nil {
		t.Fatal(err)
	}
	defer func() { _ = f.Close() }()
	var evs []orchestrator.ClaudeEvent
	res, err := ParseStream(f, func(e orchestrator.ClaudeEvent) { evs = append(evs, e) })
	return res, evs, err
}

func TestParseSuccess(t *testing.T) {
	res, evs, err := parseFile(t, "success.jsonl")
	if err != nil {
		t.Fatal(err)
	}
	if res.SessionID != "sess-1" || res.Turns != 4 || res.IsError || res.RateLimited || res.Text != "Done: fixed the nil check." {
		t.Fatalf("result: %+v", res)
	}
	var kinds []orchestrator.ClaudeEventKind
	for _, e := range evs {
		kinds = append(kinds, e.Kind)
	}
	want := []orchestrator.ClaudeEventKind{"init", "text", "tool", "tool", "rate_limit", "result"}
	if len(kinds) != len(want) {
		t.Fatalf("events %v, want %v", kinds, want)
	}
	for i := range want {
		if kinds[i] != want[i] {
			t.Fatalf("events %v, want %v", kinds, want)
		}
	}
	if evs[2].Tool != "Read: /workspace/main.go" || evs[3].Tool != "Bash: go test ./... echo done" {
		t.Fatalf("tool summaries: %q %q", evs[2].Tool, evs[3].Tool)
	}
}

func TestParseErrors(t *testing.T) {
	res, _, err := parseFile(t, "max_turns.jsonl")
	if err != nil || !res.IsError || res.Subtype != "error_max_turns" || res.RateLimited {
		t.Fatalf("max turns: %+v %v", res, err)
	}
	res, evs, err := parseFile(t, "rate_limited.jsonl")
	if err != nil || !res.RateLimited {
		t.Fatalf("usage limit text: %+v %v", res, err)
	}
	if evs[1].Kind != orchestrator.ClaudeText || evs[1].Text != "Starting." {
		t.Fatalf("top-level content not parsed: %+v", evs[1])
	}
	if res, _, err = parseFile(t, "rate_event_rejected.jsonl"); err != nil || !res.RateLimited {
		t.Fatalf("rejected rate_limit_event: %+v %v", res, err)
	}
	if _, _, err = parseFile(t, "truncated.jsonl"); err == nil {
		t.Fatal("stream without result should fail")
	}
}
