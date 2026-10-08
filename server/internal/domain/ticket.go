package domain

import (
	"encoding/json"
	"fmt"
	"slices"
	"strings"
	"time"
)

// TicketSource says where a ticket came from.
type TicketSource string

// Ticket sources.
const (
	SourceJira  TicketSource = "jira"
	SourcePlane TicketSource = "plane"
	SourceLocal TicketSource = "local"
)

// TrackerSources are the sources that have an issue in a tracker.
var TrackerSources = []TicketSource{SourceJira, SourcePlane}

// Tracked reports whether tickets from s have a tracker issue.
func (s TicketSource) Tracked() bool { return slices.Contains(TrackerSources, s) }

// Name is the tracker's display name ("Jira", "Plane").
func (s TicketSource) Name() string {
	switch s {
	case SourceJira:
		return "Jira"
	case SourcePlane:
		return "Plane"
	}
	return string(s)
}

// RelationSource is the source of the relations this tracker's links
// make.
func (s TicketSource) RelationSource() RelationSource {
	if s == SourcePlane {
		return RelFromPlane
	}
	return RelFromJira
}

// Ticket is one unit of work agnts takes from intake to merge.
type Ticket struct {
	ID int64
	// WorkspaceID is the workspace the ticket belongs to; keys are unique
	// within it.
	WorkspaceID int64
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
	PreviewState string     // screenshots while waiting for review: PreviewNone, PreviewPending, ...
	// PreviewCompare has previews of this ticket capture the default
	// branch too (before shots). The reviewer decides per ticket.
	PreviewCompare bool
	// FeedbackShots are the screenshots the reviewer pointed at in
	// Feedback; the next coding run gets them next to the feedback.
	FeedbackShots []ShotRef
	// FeedbackFiles are attachments a retry note or review feedback
	// brought; the next coding run gets them next to the text.
	FeedbackFiles []int64
	Kind          TicketKind
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
	// MemberID is whose ticket it is: per-member Claude mode runs it on
	// that person's account. nil: the workspace's default member.
	MemberID *int64
	// CreatedBy is the person who created it, nil for webhooks and agnts.
	CreatedBy *int64
	// WaitReason says why a ticket that needs a worker is not running:
	// WaitBlocked, WaitSlots, WaitServer or WaitClaude ("" when it runs or
	// does not wait for one). QueuedAt is when it started waiting.
	WaitReason  WaitReason
	WaitMessage string // the reason in a sentence
	// SelfFixes counts the rounds agnts's own review sent findings back to
	// the coder since a person last asked for changes.
	SelfFixes int
	// QuietReview: the ticket reached review without being announced, as
	// agnts's own review may still send it back; announced when it ends.
	QuietReview bool
	// ReplayOf is the done ticket a replay re-runs ("" for other tickets);
	// BaseSHA is the commit the replay's branch is cut from. Replays are
	// for evaluation: never pushed, and never shown to other tickets.
	ReplayOf  string
	BaseSHA   string
	QueuedAt  *time.Time
	CreatedAt time.Time
	UpdatedAt time.Time
}

// WaitReason is why a ticket waits for a worker.
type WaitReason string

// Wait reasons, by who can fix them.
const (
	WaitNone    WaitReason = ""
	WaitBlocked WaitReason = "blocked" // relations or a hold: the team
	WaitSlots   WaitReason = "slots"   // the workspace's slots are in use: the workspace
	WaitServer  WaitReason = "server"  // the server has no memory left: the platform
	WaitClaude  WaitReason = "claude"  // the Claude account is at its limit: the workspace
)

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
	// Multiple allows choosing several options; the answer then lists
	// them, one per line (see JoinChoices).
	Multiple bool
	Answer   *string
	Note     string
}

// Answer is a reply to one question.
type Answer struct {
	QuestionID int64
	Answer     string
	Note       string
	// Attachments are pending uploads to link to the answer.
	Attachments []int64
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
	// StagePreview runs while a ticket waits for review, starts the app and
	// takes screenshots for the reviewer; it never changes the ticket's state.
	StagePreview Stage = "preview"
)

// Side reports whether runs of stage s work beside the ticket (learn,
// review) instead of moving it through its states.
func (s Stage) Side() bool { return s == StageLearn || s == StageReview || s == StagePreview }

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
	// PromptVersion is the version of agnts's prompts the run used.
	PromptVersion string
	// FixAttempts counts failing checks sent back to Claude (coding runs).
	FixAttempts int
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
	ID      int64
	RunID   int64
	Summary json.RawMessage
	Tests   json.RawMessage
	Lint    string
	Files   []FileChange
	Report  string // Markdown, for report kinds
	// RedFlags are what agnts's scan of the change flagged.
	RedFlags  []RedFlag
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
	ID int64
	// WorkspaceID is the workspace the event belongs to, 0 for server-wide
	// events. Set by the store from the context.
	WorkspaceID int64
	// UserID and Username name the person behind the event (from the
	// context's actor); 0 and "" for agnts itself.
	UserID     int64
	Username   string
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
	EventPreview        = "preview_done"
	EventFollowUps      = "follow_ups_suggested"
	// EventQueued: why a ticket waits for a worker changed (wait_reason).
	EventQueued = "queued"
	// EventWorkspace: members, invites or workspace settings changed.
	EventWorkspace = "workspace_changed"
	// EventCredits: credits were bought, granted, spent or refunded.
	EventCredits = "credits_changed"
	// EventRelations: ordering constraints were found, added or decided.
	EventRelations = "relations_changed"
	// EventCollision: a finished change touches the same lines as another
	// unmerged one, or as what landed on the default branch since. Its data
	// says whether the relation was predicted before (for the eval).
	EventCollision = "collision_found"
	// EventFootprint: the predicted footprint checked against the real diff.
	EventFootprint = "footprint_checked"
	// EventBrief: a repository brief was queued, surveyed, approved or edited.
	EventBrief = "brief_changed"
	// EventReadyForReview announces a ticket that reached review quietly,
	// once agnts's own review let it through (data "to" is its state).
	EventReadyForReview = "review_ready"
	// EventRedFlags: agnts's scan of a change flagged lines for the reviewer.
	EventRedFlags = "red_flags"
	// EventCheckpoint: the drift checkpoint partway through a coding run.
	EventCheckpoint = "checkpoint"
	// EventToolchain: toolchains were detected for a repository, or
	// installed into the shared toolchain volume before a run.
	EventToolchain = "toolchain"
)

// Repository is a codebase agnts works on.
type Repository struct {
	ID             int64
	WorkspaceID    int64
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
	PlaneProject   string     // Plane project identifier whose work items go here
	TaskPrefix     string     // side-project task keys: PREFIX-1, PREFIX-2
	DeployWorkflow string     // GitHub workflow file triggered by Deploy
	ClaudeMDState  string     // CLAUDE.md in the repository: found, missing, unknown
	ArchivedAt     *time.Time // archived: kept for history, takes no new work
	Preview        PreviewConfig
	// Toolchains are installed into the run container (detected from the
	// repository unless ToolchainsOverride says a person set them).
	Toolchains           []Toolchain
	ToolchainsOverride   bool
	ToolchainsDetectedAt *time.Time
	ToolchainNotes       []string // what detection could not handle
	// RunnerImage replaces the server's runner image for this repository
	// (an image built FROM agnts-runner); "" uses the default.
	RunnerImage string
	// MemoryMB raises or lowers the run container's memory; 0 uses the
	// server default. Capped by the server limit.
	MemoryMB int
	// BuildEnv is KEY=value lines (registry tokens and the like) given to
	// every run container. Sealed at rest, never returned; BuildEnvNames
	// describes it.
	BuildEnvSet   bool
	BuildEnvNames []string
}

// TrackerProject is the project in tracker src whose issues come to r,
// or "" when r is not linked to one.
func (r Repository) TrackerProject(src TicketSource) string {
	switch src {
	case SourceJira:
		return r.JiraProject
	case SourcePlane:
		return r.PlaneProject
	}
	return ""
}

// PreviewConfig is how agnts starts a repository's app to take
// screenshots. An empty Command turns previews off for the repository.
type PreviewConfig struct {
	Command   string   // e.g. "npm ci && npm run dev -- --port 4173"
	Port      int      // where the app listens on localhost
	ReadyPath string   // polled until it answers; "/" by default
	Routes    []string // always captured, besides what Claude picks
	UIPaths   []string // globs: a change touching one gets a preview
	Login     string   // free text for Claude: how to get past a login
	// Env is KEY=value lines given to the app. It is sealed at rest and
	// never returned by the API; EnvSet and EnvNames describe it.
	Env      string
	EnvSet   bool
	EnvNames []string
}

// Enabled reports whether the repository can be previewed.
func (c PreviewConfig) Enabled() bool { return strings.TrimSpace(c.Command) != "" && c.Port > 0 }
