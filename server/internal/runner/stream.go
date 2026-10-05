// Package runner runs Claude Code in Docker containers and parses its output.
package runner

import (
	"bufio"
	"encoding/json"
	"fmt"
	"io"
	"regexp"
	"strings"
	"time"

	"hiro/internal/orchestrator"
)

// The stream-json format is only partly documented, and rate_limit_event not
// at all, so parsing is defensive: unknown lines are skipped, missing fields
// are zero, and nothing here can fail a run except an unreadable stream.

type streamLine struct {
	Type      string          `json:"type"`
	Subtype   string          `json:"subtype"`
	SessionID string          `json:"session_id"`
	Message   *streamMessage  `json:"message"`
	Content   []contentBlock  `json:"content"` // some versions put content at the top level
	Result    string          `json:"result"`
	IsError   bool            `json:"is_error"`
	NumTurns  int             `json:"num_turns"`
	Duration  int64           `json:"duration_ms"`
	CostUSD   float64         `json:"total_cost_usd"`
	Model     string          `json:"model"`
	Raw       json.RawMessage `json:"-"`
}

type streamMessage struct {
	Content []contentBlock `json:"content"`
}

type contentBlock struct {
	Type  string          `json:"type"`
	Text  string          `json:"text"`
	Name  string          `json:"name"`
	Input json.RawMessage `json:"input"`
}

var rateLimitText = regexp.MustCompile(`(?i)(usage limit|rate limit|limit reached|limit will reset|resets? at)`)

// ParseStream reads Claude Code's stream-json output, calls onEvent for each
// meaningful line, and returns the final result. It returns an error only
// if the stream ends without a result line.
func ParseStream(r io.Reader, onEvent func(orchestrator.ClaudeEvent)) (orchestrator.ClaudeResult, error) {
	var res orchestrator.ClaudeResult
	gotResult := false
	sc := bufio.NewScanner(r)
	sc.Buffer(make([]byte, 64*1024), 16*1024*1024) // tool results can be large

	for sc.Scan() {
		line := sc.Bytes()
		if len(line) == 0 || line[0] != '{' {
			continue // stray non-JSON output (warnings) is ignored
		}
		var l streamLine
		if err := json.Unmarshal(line, &l); err != nil {
			continue
		}
		if l.SessionID != "" {
			res.SessionID = l.SessionID
		}

		switch {
		case l.Type == "system" && l.Subtype == "init":
			emit(onEvent, orchestrator.ClaudeEvent{Kind: orchestrator.ClaudeInit, Data: map[string]any{"session_id": l.SessionID, "model": l.Model}})

		case l.Type == "assistant":
			blocks := l.Content
			if l.Message != nil {
				blocks = l.Message.Content
			}
			for _, b := range blocks {
				switch b.Type {
				case "text":
					if t := strings.TrimSpace(b.Text); t != "" {
						emit(onEvent, orchestrator.ClaudeEvent{Kind: orchestrator.ClaudeText, Text: t})
					}
				case "tool_use":
					emit(onEvent, orchestrator.ClaudeEvent{
						Kind: orchestrator.ClaudeTool, Tool: toolSummary(b.Name, b.Input),
						Data: map[string]any{"tool": b.Name},
					})
				}
			}

		case strings.Contains(l.Type, "rate_limit"):
			var data map[string]any
			_ = json.Unmarshal(line, &data)
			emit(onEvent, orchestrator.ClaudeEvent{Kind: orchestrator.ClaudeRateLimit, Data: data})
			if limitedStatus(data) {
				res.RateLimited = true
			}

		case l.Type == "result":
			gotResult = true
			res.Subtype = l.Subtype
			res.IsError = l.IsError || (l.Subtype != "" && l.Subtype != "success")
			res.Turns = l.NumTurns
			res.Text = l.Result
			res.CostUSD = l.CostUSD
			res.Duration = time.Duration(l.Duration) * time.Millisecond
			if res.IsError && rateLimitText.MatchString(l.Result) {
				res.RateLimited = true
			}
			emit(onEvent, orchestrator.ClaudeEvent{Kind: orchestrator.ClaudeResultEv, Text: l.Result, Data: map[string]any{
				"subtype": l.Subtype, "is_error": res.IsError, "num_turns": l.NumTurns,
				"duration_ms": l.Duration, "total_cost_usd": l.CostUSD,
			}})
		}
	}
	if err := sc.Err(); err != nil {
		return res, fmt.Errorf("read claude output: %w", err)
	}
	if !gotResult {
		return res, fmt.Errorf("claude exited without a result")
	}
	return res, nil
}

func emit(f func(orchestrator.ClaudeEvent), e orchestrator.ClaudeEvent) {
	if f != nil {
		f(e)
	}
}

// limitedStatus reports whether a rate-limit line says requests are being
// refused now (as opposed to an informational usage update).
func limitedStatus(data map[string]any) bool {
	var walk func(v any) bool
	walk = func(v any) bool {
		switch x := v.(type) {
		case map[string]any:
			for k, vv := range x {
				if s, ok := vv.(string); ok && (k == "status" || k == "state") {
					switch strings.ToLower(s) {
					case "rejected", "limited", "exceeded", "blocked":
						return true
					}
				}
				if walk(vv) {
					return true
				}
			}
		case []any:
			for _, vv := range x {
				if walk(vv) {
					return true
				}
			}
		}
		return false
	}
	return walk(data)
}

// toolSummary renders a tool call as one log line, e.g. "Bash: go test ./...".
func toolSummary(name string, input json.RawMessage) string {
	var in map[string]any
	_ = json.Unmarshal(input, &in)
	for _, k := range []string{"command", "file_path", "path", "pattern", "url", "description"} {
		if s, ok := in[k].(string); ok && s != "" {
			s = strings.ReplaceAll(s, "\n", " ")
			if len(s) > 200 {
				s = s[:200] + "…"
			}
			return name + ": " + s
		}
	}
	return name
}
