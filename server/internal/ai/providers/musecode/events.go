package musecode

import (
	"encoding/json"
	"fmt"
	"strings"

	muse "github.com/rustambekabdusalomov/agnts-muse"

	"agnts/internal/ai"
)

// museEvent maps agnts-muse's events onto Claude Code's, which the ticket
// log, transcripts and stall detection read.
func museEvent(e muse.Event, limit float64, on func(ai.Event)) {
	budget := func(kind, text, level string, data map[string]any) {
		if data == nil {
			data = map[string]any{}
		}
		data["kind"], data["level"] = kind, level
		on(ai.Event{Kind: ai.EventBudget, Text: text, Data: data})
	}
	switch e.Kind {
	case muse.EventStarted:
		on(ai.Event{Kind: ai.EventInit, Data: map[string]any{
			"session_id": e.SessionID, "model": ai.MusePrefix + string(e.Model)}})
	case muse.EventMessage:
		on(ai.Event{Kind: ai.EventText, Text: e.Text})
	case muse.EventToolStart:
		data := map[string]any{"input": e.Args}
		if t := toolTarget(e.Args); t != "" {
			data["target"] = t
		}
		on(ai.Event{Kind: ai.EventTool, Tool: museTool(e.Tool), Data: data})
	case muse.EventToolEnd:
		on(ai.Event{Kind: ai.EventToolResult, Tool: museTool(e.Tool), Data: map[string]any{"is_error": e.Failed, "output": e.Output}})
	case muse.EventUsage:
		c := e.Charge
		text := fmt.Sprintf("model call %d on %s: %s (total %s)", c.Calls, e.Model, c.Cost, c.Total)
		budget("usage", text, "info", map[string]any{"cost_usd": c.Cost.Float(), "total_usd": c.Total.Float(), "held_usd": e.Held.Float(),
			"limit_usd": limit, "calls": c.Calls, "model": string(e.Model),
			"input_tokens": c.Usage.Input, "cached_tokens": c.Usage.Cached, "output_tokens": c.Usage.Output})
	case muse.EventSteer:
		switch e.Reason {
		case "person":
			budget("message", "a message from the chat went to the running agent", "info", nil)
		case "approval":
			budget("approval", "told the agent the chat's answer", "info", nil)
		case "steps":
			budget("steer", "model calls running low: told Muse to wrap up", "warn", nil)
		default:
			budget("steer", "budget running low: told Muse to wrap up", "warn", nil)
		}
	case muse.EventEscalate:
		budget("escalate", "moved to "+string(e.Model)+": "+e.Reason, "info", map[string]any{"model": string(e.Model)})
	case muse.EventContinue:
		budget("continue", e.Reason, "warn", nil)
	case muse.EventInterrupt:
		budget("stop", "stopped: "+e.Reason, "warn", nil)
	case muse.EventApproval:
		a := e.Approval
		what := ""
		if a != nil {
			what = firstNonEmpty(a.Command, a.Path, a.Tool)
		}
		switch {
		case a == nil:
		case a.Pending:
			budget("ask", fmt.Sprintf("waiting for the chat to allow %s (%s)", what, a.Reason), "warn", map[string]any{"rule": a.Rule})
		case a.Ask && a.Allow:
			budget("ask", "the chat allowed "+what, "info", map[string]any{"rule": a.Rule})
		case a.Ask:
			budget("ask", "the chat did not allow "+what, "warn", map[string]any{"rule": a.Rule})
		case !a.Allow:
			budget("guard", fmt.Sprintf("guard refused %s (%s): %s", what, a.Rule, a.Reason), "warn", map[string]any{"rule": a.Rule})
		}
	case muse.EventSettled:
		if r := e.Receipt; r != nil {
			budget("settled", fmt.Sprintf("charged %s, released %s", r.Charged, r.Released), "info",
				map[string]any{"charged_usd": r.Charged.Float(), "released_usd": r.Released.Float(), "unbilled_usd": r.Unbilled.Float()})
		}
	}
}

// toolTarget is the short subject of a tool call for the ticket log: the
// file read or edited, the pattern searched, the command run. The full
// input stays in the run history only.
func toolTarget(args string) string {
	var in map[string]any
	if json.Unmarshal([]byte(args), &in) != nil {
		return ""
	}
	for _, k := range []string{"path", "file_path", "pattern", "query", "command", "url"} {
		if v, ok := in[k].(string); ok && strings.TrimSpace(v) != "" {
			v = strings.Join(strings.Fields(v), " ")
			if len(v) > 120 {
				v = v[:117] + "..."
			}
			return v
		}
	}
	return ""
}

// museTool names Muse's tools the way the ticket log and stall detection
// know Claude Code's.
func museTool(t string) string {
	switch t {
	case "bash", "shell":
		return "Bash"
	case "read_file":
		return "Read"
	case "edit_file", "apply_patch":
		return "Edit"
	case "write_file":
		return "Write"
	case "grep", "search":
		return "Grep"
	}
	return t
}

func firstNonEmpty(s ...string) string {
	for _, v := range s {
		if v != "" {
			return v
		}
	}
	return ""
}
