package runner

import (
	"os"
	"slices"
	"strings"
	"testing"

	"agnts/internal/orchestrator"
)

func TestParseCodexStream(t *testing.T) {
	f, err := os.Open("testdata/codex.jsonl")
	if err != nil {
		t.Fatal(err)
	}
	defer func() { _ = f.Close() }()
	var evs []orchestrator.ClaudeEvent
	res, err := ParseCodexStream(f, func(e orchestrator.ClaudeEvent) { evs = append(evs, e) })
	if err != nil {
		t.Fatal(err)
	}
	if res.SessionID != "0199a213-81c0-7800-8aa1-bbab2a035a53" || res.Turns != 1 || res.IsError || res.Subtype != "success" ||
		res.Text != "Rounded half up in pay/refund.go." || res.Usage.CacheRead != 24448 || res.Usage.Input != 315 || res.Usage.Output != 122 {
		t.Fatalf("result: %+v", res)
	}
	var kinds []orchestrator.ClaudeEventKind
	for _, e := range evs {
		kinds = append(kinds, e.Kind)
	}
	want := []orchestrator.ClaudeEventKind{"init", "tool", "tool_result", "tool", "text", "result"}
	if !slices.Equal(kinds, want) {
		t.Fatalf("events %v, want %v", kinds, want)
	}
	if evs[1].Tool != "Bash: bash -lc 'go test ./pay'" || evs[2].Data["is_error"] != true || evs[3].Tool != "Edit: /workspace/pay/refund.go" {
		t.Fatalf("events: %+v", evs)
	}
}

func TestCodexFailureAndArgs(t *testing.T) {
	res, err := ParseCodexStream(strings.NewReader(`{"type":"thread.started","thread_id":"t1"}
{"type":"turn.failed","error":{"message":"You exceeded your current quota; usage limit reached"}}
`), nil)
	if err != nil || !res.IsError || !res.RateLimited {
		t.Fatalf("failed turn: %+v %v", res, err)
	}
	if _, err := ParseCodexStream(strings.NewReader(`{"type":"thread.started","thread_id":"t1"}`), nil); err == nil {
		t.Fatal("a stream without a finished turn parsed")
	}
	argv := codexArgv(orchestrator.ClaudeRequest{Prompt: "review", ReadOnly: true, Resume: "t1"}, "gpt-5-codex")
	if got := strings.Join(argv, " "); got != "codex exec --json --skip-git-repo-check --sandbox read-only --model gpt-5-codex resume t1 review" {
		t.Fatalf("argv: %s", got)
	}
}
