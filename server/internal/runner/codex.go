package runner

import (
	"bufio"
	"encoding/json"
	"fmt"
	"io"
	"strings"

	"agnts/internal/domain"
	"agnts/internal/orchestrator"
)

// Codex CLI (codex exec --json) is agnts's second coding tool. Its stream
// is JSON lines of thread, turn and item events; ParseCodexStream maps them
// to the events and result the orchestrator already reads for Claude Code,
// so stall detection, the ticket log and spend work the same way.
//
// What Codex runs lack next to Claude Code (see docs and Harness plan.md):
// no hooks, so agnts-guard's in-run checks do not apply (the server's
// checks after the run still do), and no permission rules (the container
// and its egress proxy are the boundary).

// CodexPrefix marks a model as a Codex model in agnts's settings:
// "codex:<model>".
const CodexPrefix = orchestrator.CodexPrefix

type codexLine struct {
	Type     string     `json:"type"`
	ThreadID string     `json:"thread_id"`
	Item     *codexItem `json:"item"`
	Usage    *struct {
		Input       int64 `json:"input_tokens"`
		CachedInput int64 `json:"cached_input_tokens"`
		Output      int64 `json:"output_tokens"`
	} `json:"usage"`
	Error   *struct{ Message string } `json:"error"`
	Message string                    `json:"message"`
}

type codexItem struct {
	ID       string `json:"id"`
	Type     string `json:"type"`
	Text     string `json:"text"`
	Command  string `json:"command"`
	ExitCode *int   `json:"exit_code"`
	Status   string `json:"status"`
	Changes  []struct {
		Path string `json:"path"`
		Kind string `json:"kind"`
	} `json:"changes"`
}

// ParseCodexStream reads codex exec --json output.
func ParseCodexStream(r io.Reader, onEvent func(orchestrator.ClaudeEvent)) (orchestrator.ClaudeResult, error) {
	var res orchestrator.ClaudeResult
	sc := bufio.NewScanner(r)
	sc.Buffer(make([]byte, 64*1024), 16*1024*1024)
	ended := false
	for sc.Scan() {
		line := sc.Bytes()
		if len(line) == 0 || line[0] != '{' {
			continue
		}
		var l codexLine
		if json.Unmarshal(line, &l) != nil {
			continue
		}
		switch l.Type {
		case "thread.started":
			res.SessionID = l.ThreadID
			emit(onEvent, orchestrator.ClaudeEvent{Kind: orchestrator.ClaudeInit, Data: map[string]any{"session_id": l.ThreadID, "model": "codex"}})
		case "turn.completed":
			ended = true
			res.Turns++
			if u := l.Usage; u != nil {
				res.Usage.Add(domain.TokenUsage{Input: u.Input - u.CachedInput, CacheRead: u.CachedInput, Output: u.Output})
			}
		case "turn.failed", "error":
			ended = true
			msg := l.Message
			if l.Error != nil && l.Error.Message != "" {
				msg = l.Error.Message
			}
			res.IsError, res.Subtype, res.Text = true, "error_during_execution", msg
			if rateLimitText.MatchString(msg) {
				res.RateLimited = true
			}
		case "item.started", "item.completed":
			codexItemEvent(l, &res, onEvent)
		}
	}
	if err := sc.Err(); err != nil {
		return res, fmt.Errorf("read codex output: %w", err)
	}
	if !ended {
		res.Partial = !res.Usage.IsZero()
		return res, fmt.Errorf("codex exited without finishing a turn")
	}
	if !res.IsError {
		res.Subtype = "success"
	}
	emit(onEvent, orchestrator.ClaudeEvent{Kind: orchestrator.ClaudeResultEv, Text: res.Text, Data: map[string]any{
		"subtype": res.Subtype, "is_error": res.IsError, "num_turns": res.Turns}})
	return res, nil
}

func codexItemEvent(l codexLine, res *orchestrator.ClaudeResult, onEvent func(orchestrator.ClaudeEvent)) {
	it := l.Item
	if it == nil {
		return
	}
	started := l.Type == "item.started"
	switch it.Type {
	case "agent_message":
		if !started && strings.TrimSpace(it.Text) != "" {
			res.Text = it.Text
			emit(onEvent, orchestrator.ClaudeEvent{Kind: orchestrator.ClaudeText, Text: strings.TrimSpace(it.Text)})
		}
	case "command_execution":
		if started {
			emit(onEvent, orchestrator.ClaudeEvent{Kind: orchestrator.ClaudeTool, Tool: toolSummary("Bash", mustJSON(map[string]string{"command": it.Command})),
				Data: map[string]any{"tool": "Bash", "id": it.ID}})
			return
		}
		failed := it.Status == "failed" || it.ExitCode != nil && *it.ExitCode != 0
		emit(onEvent, orchestrator.ClaudeEvent{Kind: orchestrator.ClaudeToolResult, Data: map[string]any{"id": it.ID, "is_error": failed}})
	case "file_change":
		if started {
			return
		}
		for _, c := range it.Changes {
			emit(onEvent, orchestrator.ClaudeEvent{Kind: orchestrator.ClaudeTool, Tool: "Edit: " + c.Path,
				Data: map[string]any{"tool": "Edit", "id": it.ID + ":" + c.Path}})
		}
	}
}

func mustJSON(v any) json.RawMessage {
	b, _ := json.Marshal(v)
	return b
}

// codexArgv is the codex exec command line for a request.
func codexArgv(req orchestrator.ClaudeRequest, model string) []string {
	sandbox := "danger-full-access" // the run container is the sandbox
	if req.ReadOnly {
		sandbox = "read-only"
	}
	argv := []string{"codex", "exec", "--json", "--skip-git-repo-check", "--sandbox", sandbox}
	if model != "" {
		argv = append(argv, "--model", model)
	}
	if req.Resume != "" {
		return append(argv, "resume", req.Resume, req.Prompt)
	}
	return append(argv, req.Prompt)
}
