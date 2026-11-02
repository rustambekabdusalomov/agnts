package domain

import "time"

// TranscriptPurpose is the call site a transcript comes from.
type TranscriptPurpose string

// Transcript purposes: a ticket's stages use the stage name (analyze,
// code, review, …); the rest are calls outside a ticket's stages.
const (
	PurposeAssistant     TranscriptPurpose = "assistant"
	PurposeBrief         TranscriptPurpose = "brief"
	PurposeDetect        TranscriptPurpose = "detect"
	PurposeDocument      TranscriptPurpose = "document"
	PurposeReflect       TranscriptPurpose = "reflect"
	PurposeRules         TranscriptPurpose = "rules"
	PurposeSecondOpinion TranscriptPurpose = "second_opinion"
	PurposeTranslate     TranscriptPurpose = "translate"
	// PurposeLogTriage explains a new log watcher finding.
	PurposeLogTriage TranscriptPurpose = "log_triage"
)

// Background reports whether the purpose is a call outside a ticket's
// stages, which never had a claude_calls row.
func (p TranscriptPurpose) Background() bool {
	switch p {
	case PurposeAssistant, PurposeBrief, PurposeDetect, PurposeDocument, PurposeReflect, PurposeRules, PurposeTranslate, PurposeLogTriage:
		return true
	}
	return false
}

// TranscriptStatus is how an invocation ended.
type TranscriptStatus string

// Transcript statuses. A stall is not one: the run goes on after agnts
// nudges Claude, so stalls are counted instead.
const (
	TranscriptRunning   TranscriptStatus = "running"
	TranscriptDone      TranscriptStatus = "done"
	TranscriptError     TranscriptStatus = "error"
	TranscriptTimeout   TranscriptStatus = "timeout"
	TranscriptCancelled TranscriptStatus = "cancelled"
	TranscriptOOM       TranscriptStatus = "oom"
)

// Valid reports whether s is a known status.
func (s TranscriptStatus) Valid() bool {
	switch s {
	case TranscriptRunning, TranscriptDone, TranscriptError, TranscriptTimeout, TranscriptCancelled, TranscriptOOM:
		return true
	}
	return false
}

// TranscriptStart is what is known when an invocation starts.
type TranscriptStart struct {
	// WorkspaceID is required: background loops run with a system scope,
	// where the database cannot infer it.
	WorkspaceID  int64
	RunID        *int64
	TicketKey    string
	Subject      string // what a background call is about: a repository, a rule, a language
	ConnectionID *int64 // the Claude account; nil for agnts's key or a legacy install
	ClaudeLabel  string
	Purpose      TranscriptPurpose
	ModelStage   string
	Engine       string // claude or codex
	Model        string
	Prompt       []byte // gzipped
}

// TranscriptCounts are the running totals of a transcript's body.
type TranscriptCounts struct {
	RawBytes   int
	ToolCalls  int
	ToolErrors int
	Truncated  bool
}

// TranscriptEnd is what is known when an invocation ends.
type TranscriptEnd struct {
	Status     TranscriptStatus
	ExitReason string
	SessionID  string
	Model      string
	Turns      int
	Stalls     int
	Usage      TokenUsage
	Counts     TranscriptCounts
}

// Transcript is one recorded invocation, without its prompt and body.
type Transcript struct {
	ID            int64
	WorkspaceID   int64
	WorkspaceSlug string
	WorkspaceName string
	RunID         *int64
	TicketKey     string
	Subject       string
	ConnectionID  *int64
	ClaudeLabel   string
	ClaudeUser    string // the member whose account it is, "" for a workspace's shared one
	Purpose       TranscriptPurpose
	ModelStage    string
	Engine        string
	Model         string
	SessionID     string
	StartedAt     time.Time
	FinishedAt    *time.Time
	Status        TranscriptStatus
	ExitReason    string
	Turns         int
	ToolCalls     int
	ToolErrors    int
	Stalls        int
	Usage         TokenUsage
	RawBytes      int
	StoredBytes   int
	Truncated     bool
}

// TranscriptFilter narrows the Admin list of transcripts.
type TranscriptFilter struct {
	WorkspaceID int64
	Purpose     string
	Status      TranscriptStatus
	Engine      string
	Model       string // substring
	TicketKey   string // prefix
	Stalled     bool
	From, To    time.Time
	MinCost     float64
	// Before pages: transcripts older than (BeforeAt, BeforeID).
	BeforeAt time.Time
	BeforeID int64
	Limit    int
}

// TranscriptSummary is the totals for a filter.
type TranscriptSummary struct {
	Count          int
	Errors         int // error, timeout, oom
	Stalled        int
	CostUSD        float64
	BackgroundCost float64
	InputTokens    int64
	OutputTokens   int64
	P50, P95       time.Duration
}

// RunHistorySettings are the server-wide limits of run history.
type RunHistorySettings struct {
	// RetentionDays deletes transcripts older than this; 0 keeps them.
	RetentionDays int `json:"retentionDays"`
	// ToolOutputKB caps one tool output (head and tail are kept).
	ToolOutputKB int `json:"toolOutputKB"`
	// TextKB caps one text block.
	TextKB int `json:"textKB"`
	// TranscriptMB caps one transcript's uncompressed body; past it only
	// tool calls and the result are kept, without content.
	TranscriptMB int `json:"transcriptMB"`
}

// DefaultRunHistory are the limits until an Admin changes them.
var DefaultRunHistory = RunHistorySettings{RetentionDays: 30, ToolOutputKB: 16, TextKB: 32, TranscriptMB: 8}

// Normalize fills unset limits with the defaults and clamps the rest.
func (s RunHistorySettings) Normalize() RunHistorySettings {
	clamp := func(v, def, lo, hi int) int {
		if v <= 0 {
			return def
		}
		return min(max(v, lo), hi)
	}
	s.RetentionDays = min(max(s.RetentionDays, 0), 3650)
	s.ToolOutputKB = clamp(s.ToolOutputKB, DefaultRunHistory.ToolOutputKB, 1, 1024)
	s.TextKB = clamp(s.TextKB, DefaultRunHistory.TextKB, 1, 1024)
	s.TranscriptMB = clamp(s.TranscriptMB, DefaultRunHistory.TranscriptMB, 1, 64)
	return s
}

// AdminAudit is one thing an Admin did that the audit log keeps.
type AdminAudit struct {
	ID          int64
	AdminID     *int64
	AdminName   string
	Action      string
	Target      string
	WorkspaceID *int64
	Workspace   string
	IP          string
	CreatedAt   time.Time
}

// Admin audit actions.
const (
	AuditTranscriptView     = "transcript.view"
	AuditTranscriptPrompt   = "transcript.prompt"
	AuditTranscriptDownload = "transcript.download"
	AuditRunHistorySettings = "run_history.settings"
)
