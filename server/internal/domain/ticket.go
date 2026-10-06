package domain

import (
	"encoding/json"
	"fmt"
	"slices"
	"time"
)

// TicketSource says where a ticket came from.
type TicketSource string

// Ticket sources.
const (
	SourceJira  TicketSource = "jira"
	SourceLocal TicketSource = "local"
)

// Ticket is one unit of work agnts takes from intake to merge.
type Ticket struct {
	ID          int64
	Key         string
	Source      TicketSource
	RepoID      *int64
	Title       string
	Description string
	Priority    string
	State       TicketState
	// ResumeState is where Retry sends a failed or rate-limited ticket.
	ResumeState  TicketState
	Revision     int
	Turns        int
	Models       map[string]string // stage -> model override
	AfterApprove string            // "pr" or "main"
	Branch       string
	HeadSHA      string
	PRNumber     *int
	PRURL        string
	Feedback     string     // review feedback not yet handled by a coding run
	MergedAt     *time.Time // when the pull request was merged (from webhooks)
	Assignees    []string   // git host usernames the pull request is assigned to
	Held         bool       // kept in the queue until someone starts it
	AskFirst     bool       // analysis may ask questions before coding
	LearnState   string     // learn run after push: LearnNone, LearnPending, LearnDone, LearnFailed
	ReviewState  string     // code review while waiting for review: ReviewNone, ReviewPending, ...
	Kind         TicketKind
	// KindAuto is true while agnts picks the kind: the analysis may change
	// it. A kind someone chose (label, form, hand edit) is never changed.
	KindAuto bool
	// PostReport posts an approved report to the tracker issue.
	PostReport bool
	// ParentKey is the plan or bug report this ticket implements, or "".
	ParentKey string
	// FollowUpOf is the ticket that suggested this one as a follow-up, or "".
	FollowUpOf string
	// SuggestFollowUps turns follow-up suggestions on or off for this
	// ticket; nil follows Settings.
	SuggestFollowUps *bool
	CreatedAt        time.Time
	UpdatedAt        time.Time
}

// transitions lists every allowed state change. Anything else is a bug.
var transitions = map[TicketState][]TicketState{
	StateNew:               {StateAnalyzing, StateRejected},
	StateAnalyzing:         {StateWaitingForAnswers, StateCoding, StateFailed, StateRateLimited, StateNew, StateRejected},
	StateWaitingForAnswers: {StateCoding, StateRejected},
	// A report skips testing: coding goes straight to review.
	StateCoding:           {StateTesting, StateWaitingForReview, StateFailed, StateRateLimited, StateRejected},
	StateTesting:          {StateWaitingForReview, StateCoding, StateFailed, StateRejected},
	StateWaitingForReview: {StatePushing, StateCoding, StateRejected},
	StatePushing:          {StateDone, StateFailed},
	StateFailed:           {StateNew, StateCoding, StatePushing, StateRejected},
	StateRateLimited:      {StateNew, StateCoding, StateRejected},
	StateDone:             {},
	StateRejected:         {},
}

// CanTransition reports whether a ticket may move from one state to another.
func CanTransition(from, to TicketState) bool {
	return slices.Contains(transitions[from], to)
}

// Valid reports whether s is a known state.
func (s TicketState) Valid() bool {
	_, ok := transitions[s]
	return ok
}

// Terminal reports whether no further work happens on a ticket in state s.
func (s TicketState) Terminal() bool { return s == StateDone || s == StateRejected }

// TransitionError is returned when a requested change is not allowed from
// the ticket's current state (for example approving a ticket twice).
type TransitionError struct {
	Key  string
	From TicketState
	To   TicketState
}

func (e *TransitionError) Error() string {
	return fmt.Sprintf("ticket %s: cannot go from %s to %s", e.Key, e.From, e.To)
}

// Is makes errors.Is(err, ErrConflict) true for transition errors.
func (e *TransitionError) Is(target error) bool { return target == ErrConflict }

// Question is something agnts asks before coding.
type Question struct {
	ID       int64
	TicketID int64
	Position int
	Text     string
	Options  []string
	Answer   *string
	Note     string
}

// Answer is a reply to one question.
type Answer struct {
	QuestionID int64
	Answer     string
	Note       string
}

// Stage is the kind of work a run does.
type Stage string

// Run stages.
const (
	StageAnalyze Stage = "analyze"
	StageCode    Stage = "code"
	StagePush    Stage = "push"
	// StageLearn runs on a done ticket and writes lessons; it never changes
	// the ticket's state.
	StageLearn Stage = "learn"
	// StageReview runs while a ticket waits for review and writes a code
	// review for the human reviewer; it never changes the ticket's state.
	StageReview Stage = "review"
)

// Side reports whether runs of stage s work beside the ticket (learn,
// review) instead of moving it through its states.
func (s Stage) Side() bool { return s == StageLearn || s == StageReview }

// Run is one container session (or the push step) for a ticket.
type Run struct {
	ID          int64
	TicketID    int64
	Stage       Stage
	Model       string
	SessionID   string
	ContainerID string
	StartedAt   time.Time
	FinishedAt  *time.Time
	Turns       int
	ExitReason  string
}

// TokenUsage is what one or more Claude invocations used. CostUSD is what
// Claude Code reports the same work would cost on the API; on a plan it is
// an estimate, not a charge.
type TokenUsage struct {
	Input      int64
	Output     int64
	CacheRead  int64
	CacheWrite int64
	CostUSD    float64
}

// Total is every token counted, cache included.
func (u TokenUsage) Total() int64 { return u.Input + u.Output + u.CacheRead + u.CacheWrite }

// IsZero reports whether nothing was used.
func (u TokenUsage) IsZero() bool { return u.Total() == 0 && u.CostUSD == 0 }

// Add adds o to u.
func (u *TokenUsage) Add(o TokenUsage) {
	u.Input += o.Input
	u.Output += o.Output
	u.CacheRead += o.CacheRead
	u.CacheWrite += o.CacheWrite
	u.CostUSD += o.CostUSD
}

// ClaudeCall is one Claude Code invocation within a run. ModelStage is
// the Model* constant it ran as (a code run has coding and retry calls).
// Partial is true when the stream ended without a result, so the tokens
// were summed from the messages seen and the cost is unknown.
type ClaudeCall struct {
	ID         int64
	RunID      int64
	TicketID   int64
	ModelStage string
	Model      string
	Usage      TokenUsage
	Turns      int
	Duration   time.Duration
	Partial    bool
	CreatedAt  time.Time
}

// StageUsage is a ticket's spend for one model stage and model, in the
// order the stage first ran.
type StageUsage struct {
	ModelStage string
	Model      string
	Calls      int
	Turns      int
	Partial    bool // at least one call was partial
	Usage      TokenUsage
}

// FileChange is one changed file in a result.
type FileChange struct {
	Path string `json:"path"`
	Add  int    `json:"add"`
	Del  int    `json:"del"`
	Diff string `json:"diff"`
}

// Result is what a coding run produced, shown on the review page.
type Result struct {
	ID        int64
	RunID     int64
	Summary   json.RawMessage
	Tests     json.RawMessage
	Lint      string
	Files     []FileChange
	Report    string // Markdown, for report kinds
	CreatedAt time.Time
}

// Origin says who or what caused an event (audit).
type Origin string

// Event origins.
const (
	OriginSystem   Origin = "system"
	OriginWeb      Origin = "web"
	OriginMobile   Origin = "mobile"
	OriginMCP      Origin = "mcp"
	OriginTelegram Origin = "telegram"
	OriginWebhook  Origin = "webhook"
)

// Level is an event's severity.
type Level string

// Event levels.
const (
	LevelDebug Level = "debug"
	LevelInfo  Level = "info"
	LevelWarn  Level = "warn"
	LevelError Level = "error"
)

// Event is one row of the append-only log.
type Event struct {
	ID         int64
	TicketKey  string
	RunID      *int64
	Step       string
	Type       string
	Level      Level
	Origin     Origin
	Message    string
	Data       map[string]any
	DurationMS *int64
	CreatedAt  time.Time
}

// Event types.
const (
	EventStateChanged   = "state_changed"
	EventTicketCreated  = "ticket_created"
	EventTicketUpdated  = "ticket_updated"
	EventClaudeText     = "claude_text"
	EventClaudeTool     = "claude_tool"
	EventClaudeResult   = "claude_result"
	EventRateLimit      = "rate_limit"
	EventCheck          = "check"
	EventAnswered       = "answered"
	EventFeedback       = "feedback"
	EventPushed         = "pushed"
	EventPROpened       = "pr_opened"
	EventTrackerComment = "tracker_comment"
	EventError          = "error"
	EventUsageUpdated   = "usage_updated"
	EventTaskChanged    = "task_changed"
	EventSettings       = "settings_changed"
	EventIntegration    = "integration_changed"
	EventMerged         = "pr_merged"
	EventPipeline       = "pipeline"
	EventDeploy         = "deploy"
	EventRepoArchived   = "repo_archived"
	EventLessons        = "lessons_found"
	EventRule           = "rule_changed"
	EventKind           = "kind_changed"
	EventReview         = "review_done"
	EventFollowUps      = "follow_ups_suggested"
)

// Repository is a codebase agnts works on.
type Repository struct {
	ID             int64
	Name           string
	Kind           string // "jira" or "side"
	Provider       string // "github" or "gitlab"
	CloneURL       string
	DefaultBranch  string
	Stack          string
	BuildCmd       string
	LintCmd        string
	TestCmd        string
	BranchPrefix   string
	ClaudeMD       string // extra instructions added to every prompt
	JiraProject    string
	TaskPrefix     string     // side-project task keys: PREFIX-1, PREFIX-2
	DeployWorkflow string     // GitHub workflow file triggered by Deploy
	ClaudeMDState  string     // CLAUDE.md in the repository: found, missing, unknown
	ArchivedAt     *time.Time // archived: kept for history, takes no new work
}
