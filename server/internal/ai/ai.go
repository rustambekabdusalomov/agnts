// Package ai is the one way agnts's features reach an AI provider: Muse
// Code (Meta), Claude Code (Anthropic) and Codex (OpenAI). Features say
// what they need (the person, the purpose, a model or a tier); the
// gateway decides which provider runs it, on which account, and how it is
// paid for, then runs it through the provider.
//
// This package is a leaf: it imports domain and nothing from the
// features, the runner or the stores, which import it.
package ai

import (
	"errors"
	"fmt"
	"time"

	"agnts/internal/domain"
)

// Request is one invocation of a coding agent.
type Request struct {
	Prompt   string
	Model    string
	MaxTurns int
	Resume   string // session id to continue, or empty
	Timeout  time.Duration
	Settings string // JSON for Claude Code's --settings (permission rules)
	// Env is extra KEY=value environment for the agent; its hooks inherit
	// it (agnts-guard reads its config from there).
	Env []string
	// ReadOnly: the run must not change /workspace (Codex runs enforce it
	// with their sandbox; Claude Code with the permission rules; Muse with
	// its guard).
	ReadOnly bool
	// Effort is how hard the agent thinks; "" leaves its default.
	// Providers without CapEffort ignore it.
	Effort string
	// RunID and WorkspaceID say whose invocation this is (0: not a
	// ticket run); Muse runs on credits budget by them.
	RunID       int64
	WorkspaceID int64
	// Budget is the workspace's most a run on credits may spend, in
	// credits (0: the server's cap).
	Budget int64
	// Steer brings messages from the people following the run in a chat
	// into its running turn; Ask asks them about a tool call the guard
	// leaves to a person (installing a dependency) and gives their
	// answer. Providers with CapSteer and CapAsk take them; others ignore
	// them.
	Steer <-chan string
	Ask   func(ToolQuestion) <-chan bool
}

// ToolQuestion is a tool call a run asks the people following it about.
type ToolQuestion struct {
	Tool, Command, Path string
	Reason              string // why a rule asks
}

// EventKind classifies an agent's stream.
type EventKind string

// Event kinds. Every provider maps its stream onto them, so the ticket
// log, transcripts and stall detection read every provider the same way.
const (
	EventInit EventKind = "init"
	EventText EventKind = "text"
	EventTool EventKind = "tool"
	// EventToolResult: a tool call finished (Data: id, is_error, and
	// output: the text it returned).
	EventToolResult EventKind = "tool_result"
	EventRateLimit  EventKind = "rate_limit"
	// EventBudget: a Muse run's spend or budget decision (Text: what
	// happened; Data: cost_usd, total_usd, held_usd, limit_usd, level).
	EventBudget EventKind = "budget"
	EventResult EventKind = "result"
	// EventRetry: the gateway ran the call again elsewhere after it failed
	// early (Text: what and why; Data: from, to, why).
	EventRetry EventKind = "retry"
)

// Event is one parsed step of an agent's stream.
type Event struct {
	Kind EventKind
	Text string
	Tool string
	Data map[string]any
}

// Result summarises a finished invocation.
type Result struct {
	SessionID   string
	Turns       int
	Subtype     string
	IsError     bool
	RateLimited bool
	Text        string
	Duration    time.Duration
	// Model is the model the agent reported, which may differ from the
	// one requested (an alias, or a fallback).
	Model string
	// Usage is the invocation's token spend. Partial means the stream had
	// no result line (killed or timed out) and Usage was summed from the
	// assistant messages seen, without a cost.
	Usage   domain.TokenUsage
	Partial bool
	// TranscriptID is the run history transcript the invocation was
	// recorded in (0: not recorded).
	TranscriptID int64
	// Provider and Account are where the gateway ran it.
	Provider string
	Account  Account
}

// Credential is how an agent reaches its provider: Env names what it is
// (the variable it goes in, e.g. ANTHROPIC_API_KEY, or MUSE_LOGIN for a
// Meta sign-in file), Token the secret.
type Credential struct {
	Env   string
	Token string
	// Account is the account it belongs to: Muse budgets runs on credits
	// by it, and keeps a refreshed sign-in for it.
	Account Account
}

// Account is the account a call runs on: a connection (the workspace's
// or a member's), agnts's key paid with credits, or for Codex the
// workspace's OpenAI key.
type Account = domain.ClaudeAccount

// OOMError is returned for a process the kernel killed for using more
// memory than its container's limit.
type OOMError struct{ LimitMB int64 }

func (e *OOMError) Error() string {
	return fmt.Sprintf("ran out of memory at %s: raise the repository's memory (Repository → Advanced) and retry", gbOf(e.LimitMB))
}

func gbOf(mb int64) string {
	if mb%1024 == 0 {
		return fmt.Sprintf("%d GB", mb/1024)
	}
	return fmt.Sprintf("%.1f GB", float64(mb)/1024)
}

// ErrNoSpeech says a recording had no words in it.
var ErrNoSpeech = errors.New("no words were heard in the recording; try again closer to the microphone")
