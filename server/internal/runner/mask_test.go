package runner

import (
	"encoding/json"
	"strings"
	"testing"

	"agnts/internal/domain"
	"agnts/internal/orchestrator"
)

// A tool call that prints the environment must not hand the Claude token,
// or the values agnts put in the environment, to anything above the runner.
func TestMaskEventsHidesEnvironmentSecrets(t *testing.T) {
	const token = "sk-ant-oat01-SECRETSECRETSECRET"
	env := []string{"AGNTS_GUARD=eyJjb25maWciOiJ2YWx1ZSJ9", "SHORT=abc"}
	stream := `{"type":"system","subtype":"init","session_id":"s1","model":"opus"}
{"type":"assistant","message":{"id":"m1","content":[{"type":"tool_use","id":"t1","name":"Bash","input":{"command":"env | grep TOKEN; echo ` + token + `"}}]}}
{"type":"user","message":{"content":[{"type":"tool_result","tool_use_id":"t1","content":"CLAUDE_CODE_OAUTH_TOKEN=` + token + `\nAGNTS_GUARD=eyJjb25maWciOiJ2YWx1ZSJ9\nSHORT=abc"}]}}
{"type":"assistant","message":{"id":"m2","content":[{"type":"text","text":"I found ` + token + `"}]}}
{"type":"result","subtype":"success","num_turns":1,"result":"done"}
`
	var evs []orchestrator.ClaudeEvent
	on := maskEvents(domain.NewSecretRedactor(append([]string{token}, envValues(env)...)...), func(e orchestrator.ClaudeEvent) { evs = append(evs, e) })
	if _, err := ParseStream(strings.NewReader(stream), on); err != nil {
		t.Fatal(err)
	}
	all, _ := json.Marshal(evs)
	if strings.Contains(string(all), "SECRETSECRET") || strings.Contains(string(all), "eyJjb25maWciOiJ2YWx1ZSJ9") {
		t.Fatalf("a secret reached the handler: %s", all)
	}
	if !strings.Contains(string(all), "SHORT=abc") || !strings.Contains(string(all), domain.Masked) {
		t.Fatalf("masking went too far or not at all: %s", all)
	}
}

func TestParseToolResultOutput(t *testing.T) {
	stream := `{"type":"assistant","message":{"id":"m1","content":[{"type":"tool_use","id":"t1","name":"Bash","input":{"command":"go test ./..."}}]}}
{"type":"user","message":{"content":[{"type":"tool_result","tool_use_id":"t1","is_error":true,"content":"--- FAIL: TestRefund"}]}}
{"type":"user","message":{"content":[{"type":"tool_result","tool_use_id":"t2","content":[{"type":"text","text":"line one"},{"type":"image"},{"type":"text","text":"line two"}]}]}}
{"type":"result","subtype":"success","num_turns":1,"result":"done"}
`
	var evs []orchestrator.ClaudeEvent
	if _, err := ParseStream(strings.NewReader(stream), func(e orchestrator.ClaudeEvent) { evs = append(evs, e) }); err != nil {
		t.Fatal(err)
	}
	if in, _ := evs[0].Data["input"].(json.RawMessage); !strings.Contains(string(in), "go test") {
		t.Fatalf("tool input: %+v", evs[0].Data)
	}
	if evs[1].Data["output"] != "--- FAIL: TestRefund" || evs[1].Data["is_error"] != true {
		t.Fatalf("string result: %+v", evs[1].Data)
	}
	if evs[2].Data["output"] != "line one\n[image]\nline two" {
		t.Fatalf("parts result: %q", evs[2].Data["output"])
	}
}

func TestParseCodexCommandOutput(t *testing.T) {
	stream := `{"type":"thread.started","thread_id":"th"}
{"type":"item.started","item":{"id":"i1","type":"command_execution","command":"go test ./pay","status":"in_progress"}}
{"type":"item.completed","item":{"id":"i1","type":"command_execution","command":"go test ./pay","aggregated_output":"FAIL pay 0.01s","exit_code":1,"status":"failed"}}
{"type":"item.completed","item":{"id":"i2","type":"file_change","changes":[{"path":"/workspace/pay/refund.go","kind":"update"}],"status":"completed"}}
{"type":"turn.completed","usage":{"input_tokens":10,"cached_input_tokens":0,"output_tokens":2}}
`
	var evs []orchestrator.ClaudeEvent
	if _, err := ParseCodexStream(strings.NewReader(stream), func(e orchestrator.ClaudeEvent) { evs = append(evs, e) }); err != nil {
		t.Fatal(err)
	}
	if evs[2].Data["output"] != "FAIL pay 0.01s" || evs[2].Data["exit_code"] != 1 || evs[2].Data["is_error"] != true {
		t.Fatalf("command result: %+v", evs[2].Data)
	}
	if in, _ := evs[3].Data["input"].(json.RawMessage); !strings.Contains(string(in), `"kind":"update"`) {
		t.Fatalf("file change input: %+v", evs[3].Data)
	}
}
