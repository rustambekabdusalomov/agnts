package ai

import (
	"encoding/json"
	"regexp"
	"strings"
)

// RateLimitText matches an error result that says a usage limit was hit.
var RateLimitText = regexp.MustCompile(`(?i)(usage limit|rate limit|limit reached|limit will reset|resets? at)`)

// Emit calls f with e, when there is an f.
func Emit(f func(Event), e Event) {
	if f != nil {
		f(e)
	}
}

// ToolSummary renders a tool call as one log line, e.g. "Bash: go test ./...".
func ToolSummary(name string, input json.RawMessage) string {
	var in map[string]any
	_ = json.Unmarshal(input, &in)
	for _, k := range []string{"command", "skill", "file_path", "path", "pattern", "url", "description"} {
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
