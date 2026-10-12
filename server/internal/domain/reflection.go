package domain

import "time"

// Reflection sources: what a person said that agnts may learn from.
const (
	ReflectChanges  = "changes"  // a person asked for changes
	ReflectRejected = "rejected" // a person rejected the work, with a reason
	ReflectRun      = "run"      // a run had trouble (failed checks, a stall): a tip may help next time
)

// Reflection statuses.
const (
	ReflectPending = "pending"
	ReflectRunning = "running"
	ReflectDone    = "done"
	ReflectFailed  = "failed"
)

// Reflection is feedback waiting for agnts to learn from: a reflect run
// reads it and may suggest rules that would have avoided it.
type Reflection struct {
	ID          int64
	WorkspaceID int64
	TicketKey   string
	RepoID      *int64
	Source      string
	Feedback    string
	Status      string
	Suggested   int // rules suggested
	Error       string
	CreatedAt   time.Time
}
