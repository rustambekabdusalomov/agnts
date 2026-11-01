package claudecode

import (
	"os"
	"testing"

	"agnts/internal/ai"
	"agnts/internal/domain"
)

func parseFile(t *testing.T, name string) (ai.Result, []ai.Event, error) {
	t.Helper()
	f, err := os.Open("testdata/" + name)
	if err != nil {
		t.Fatal(err)
	}
	defer func() { _ = f.Close() }()
	var evs []ai.Event
	res, err := ParseStream(f, func(e ai.Event) { evs = append(evs, e) })
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
	var kinds []ai.EventKind
	for _, e := range evs {
		kinds = append(kinds, e.Kind)
	}
	want := []ai.EventKind{"init", "text", "tool", "tool_result", "tool", "rate_limit", "result"}
	if len(kinds) != len(want) {
		t.Fatalf("events %v, want %v", kinds, want)
	}
	for i := range want {
		if kinds[i] != want[i] {
			t.Fatalf("events %v, want %v", kinds, want)
		}
	}
	if evs[2].Tool != "Read: /workspace/main.go" || evs[4].Tool != "Bash: go test ./... echo done" {
		t.Fatalf("tool summaries: %q %q", evs[2].Tool, evs[4].Tool)
	}
	if evs[3].Data["id"] != "t1" || evs[3].Data["is_error"] != false {
		t.Fatalf("tool result: %+v", evs[3].Data)
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
	if evs[1].Kind != ai.EventText || evs[1].Text != "Starting." {
		t.Fatalf("top-level content not parsed: %+v", evs[1])
	}
	if res, _, err = parseFile(t, "rate_event_rejected.jsonl"); err != nil || !res.RateLimited {
		t.Fatalf("rejected rate_limit_event: %+v %v", res, err)
	}
	if _, _, err = parseFile(t, "truncated.jsonl"); err == nil {
		t.Fatal("stream without result should fail")
	}
}

func TestParseUsage(t *testing.T) {
	res, _, err := parseFile(t, "usage.jsonl")
	if err != nil {
		t.Fatal(err)
	}
	// modelUsage wins over usage: the helper model's tokens count too.
	want := domain.TokenUsage{Input: 530, Output: 420, CacheRead: 9000, CacheWrite: 1200, CostUSD: 0.125}
	if res.Usage != want || res.Partial || res.Model != "claude-sonnet-5-5" {
		t.Fatalf("usage %+v partial=%v model=%q, want %+v", res.Usage, res.Partial, res.Model, want)
	}

	// Without modelUsage or usage, only the cost is known.
	res, _, _ = parseFile(t, "success.jsonl")
	if res.Usage != (domain.TokenUsage{CostUSD: 0.31}) || res.Partial {
		t.Fatalf("cost only: %+v", res.Usage)
	}
}

func TestParseUsageCutOff(t *testing.T) {
	res, _, err := parseFile(t, "usage_cut.jsonl")
	if err == nil {
		t.Fatal("stream without result should fail")
	}
	// msg_1 is counted once, with its last reading; no cost is known.
	want := domain.TokenUsage{Input: 15, Output: 100, CacheRead: 2300, CacheWrite: 200}
	if res.Usage != want || !res.Partial {
		t.Fatalf("usage %+v partial=%v, want %+v", res.Usage, res.Partial, want)
	}
	if res, _, _ = parseFile(t, "truncated.jsonl"); res.Partial {
		t.Fatal("a cut-off stream with no usage is not partial spend")
	}
}
