// Package orchestrator owns the ticket state machine: it claims work, drives
// each stage through the runner, and applies the human decisions (answers,
// approve, request changes, reject, retry). It depends only on the
// interfaces in this file; adapters implement them.
package orchestrator

import (
	"context"
	"io"
	"time"

	"hiro/internal/domain"
)

// Store is the persistence the orchestrator needs. Every state change goes
// through Transition, which writes the new state and its event in one
// transaction.
type Store interface {
	TicketByKey(ctx context.Context, key string) (domain.Ticket, error)
	ListTickets(ctx context.Context, f TicketFilter) ([]domain.Ticket, error)
	// CreateTicket inserts a ticket in state new, or returns ErrConflict if
	// the key exists.
	CreateTicket(ctx context.Context, t domain.Ticket, ev domain.Event) (domain.Ticket, error)
	// UpdateTicket applies mut to the locked ticket row without a state change.
	UpdateTicket(ctx context.Context, key string, ev *domain.Event, mut func(*domain.Ticket)) (domain.Ticket, error)
	// Transition moves a ticket to state to, failing with a
	// *domain.TransitionError if that is not allowed from its current state.
	// mut, if not nil, may change other fields in the same transaction.
	Transition(ctx context.Context, key string, to domain.TicketState, ev domain.Event, mut func(*domain.Ticket)) (domain.Ticket, error)

	// ClaimNext picks the oldest ticket that needs a worker (state new,
	// coding or pushing, with no unfinished run), starts a run for it and,
	// for new tickets, moves them to analyzing. Only when none is waiting
	// does it claim a done ticket with a pending learn run. ok is false when
	// idle.
	ClaimNext(ctx context.Context) (t domain.Ticket, r domain.Run, ok bool, err error)
	FinishRun(ctx context.Context, r domain.Run) error
	LastSessionID(ctx context.Context, ticketID int64) (string, error)
	// RecoverInterrupted closes runs left unfinished by a crash and moves
	// their tickets back to a claimable state.
	RecoverInterrupted(ctx context.Context) (int, error)

	ReplaceQuestions(ctx context.Context, ticketID int64, qs []domain.Question) error
	Questions(ctx context.Context, ticketID int64) ([]domain.Question, error)
	SaveAnswers(ctx context.Context, ticketID int64, as []domain.Answer) error

	SaveResult(ctx context.Context, r domain.Result) error
	// LatestResult returns the newest result of a stage, or ErrNotFound.
	LatestResult(ctx context.Context, ticketID int64, stage domain.Stage) (domain.Result, error)

	AppendEvent(ctx context.Context, ev domain.Event) error
	Events(ctx context.Context, f EventFilter) ([]domain.Event, error)

	RepositoryByID(ctx context.Context, id int64) (domain.Repository, error)
	RepositoryByJiraProject(ctx context.Context, project string) (domain.Repository, error)
	NextTaskNumber(ctx context.Context, repoID int64) (int, error)
	DeleteTicket(ctx context.Context, key string, ev domain.Event) error
	// StateSince returns when each ticket entered its current state and,
	// for failed or paused ones, the reason.
	StateSince(ctx context.Context, keys []string) (map[string]StateInfo, error)
	History(ctx context.Context, key string) ([]HistoryItem, error)
	TicketByPR(ctx context.Context, url, branch string) (domain.Ticket, error)
}

// Lessons is the knowledge base the learn stage reads and adds to.
type Lessons interface {
	// LessonTopics returns the concepts already taught for a repository.
	LessonTopics(ctx context.Context, repoID int64) ([]domain.LessonTopic, error)
	// SaveLessons finishes a ticket's learn run in one transaction: it
	// stores the new lessons (skipping slugs the repository already has),
	// marks the ticket's learn state done, and appends the event ev builds
	// from the lessons stored. It returns those stored.
	SaveLessons(ctx context.Context, ticketKey string, ls []domain.Lesson, ev func(saved []domain.Lesson) domain.Event) ([]domain.Lesson, error)
}

// StateInfo is when a ticket entered its state, and why it stopped.
type StateInfo struct {
	Since  time.Time
	Reason string
}

// HistoryItem is one state change of a ticket.
type HistoryItem struct {
	At      time.Time
	State   domain.TicketState
	Message string
	Origin  domain.Origin
}

// TicketFilter narrows ListTickets.
type TicketFilter struct {
	States []domain.TicketState
	Limit  int
}

// EventFilter narrows Events. AfterID gives events newer than a cursor.
type EventFilter struct {
	TicketKey string
	AfterID   int64
	Limit     int
}

// Runner starts isolated workspaces (one container per run).
type Runner interface {
	Open(ctx context.Context, spec WorkspaceSpec) (Workspace, error)
}

// WorkspaceSpec describes a new workspace.
type WorkspaceSpec struct {
	TicketKey string
	Image     string
	// Repo is a tar of the checked-out repository, unpacked at /workspace.
	Repo io.Reader
	// ClaudeHome is a tar of Claude Code's config dir from an earlier run of
	// this ticket (session transcripts for --resume), or nil.
	ClaudeHome []byte
}

// Workspace is a running container with the repository and Claude Code.
type Workspace interface {
	ID() string
	// Claude runs one `claude -p` invocation, calling onEvent for each
	// parsed line of its stream.
	Claude(ctx context.Context, req ClaudeRequest, onEvent func(ClaudeEvent)) (ClaudeResult, error)
	// Exec runs a shell command in /workspace (used for checks).
	Exec(ctx context.Context, cmd string, timeout time.Duration) (ExecResult, error)
	// ReadFile returns a file from the container, or domain.ErrNotFound.
	ReadFile(ctx context.Context, path string) ([]byte, error)
	// WriteFile puts a file into the container, readable by the agent.
	WriteFile(ctx context.Context, path string, data []byte) error
	// ExportRepo returns a tar of /workspace.
	ExportRepo(ctx context.Context) (io.ReadCloser, error)
	// ExportClaudeHome returns a tar of Claude Code's config dir.
	ExportClaudeHome(ctx context.Context) ([]byte, error)
	Close(ctx context.Context) error
}

// ClaudeRequest is one Claude Code invocation.
type ClaudeRequest struct {
	Prompt   string
	Model    string
	MaxTurns int
	Resume   string // session id to continue, or empty
	Timeout  time.Duration
	Settings string // JSON for --settings (permission rules from Settings)
}

// ClaudeEventKind classifies stream lines.
type ClaudeEventKind string

// Claude event kinds.
const (
	ClaudeInit      ClaudeEventKind = "init"
	ClaudeText      ClaudeEventKind = "text"
	ClaudeTool      ClaudeEventKind = "tool"
	ClaudeRateLimit ClaudeEventKind = "rate_limit"
	ClaudeResultEv  ClaudeEventKind = "result"
)

// ClaudeEvent is one parsed line of Claude Code's stream-json output.
type ClaudeEvent struct {
	Kind ClaudeEventKind
	Text string
	Tool string
	Data map[string]any
}

// ClaudeResult summarises a finished invocation.
type ClaudeResult struct {
	SessionID   string
	Turns       int
	Subtype     string
	IsError     bool
	RateLimited bool
	Text        string
	CostUSD     float64
	Duration    time.Duration
}

// ExecResult is the outcome of Workspace.Exec.
type ExecResult struct {
	ExitCode int
	Output   string // combined stdout and stderr, truncated
	Duration time.Duration
	TimedOut bool
}

// Git manages the server-side clones. Push credentials stay here and never
// enter a workspace.
type Git interface {
	// Prepare makes sure a clone of repo exists with branch checked out:
	// the existing branch if there is one, otherwise new from the default.
	Prepare(ctx context.Context, repo domain.Repository, branch string) error
	// Archive returns a tar of the checkout (including .git).
	Archive(ctx context.Context, repo domain.Repository, branch string) (io.ReadCloser, error)
	// Commit replaces the checkout's files with the tar's and commits all
	// changes. It returns the new head and the branch's full diff against
	// the default branch (what a reviewer sees), empty when they are equal.
	Commit(ctx context.Context, repo domain.Repository, branch string, tree io.Reader, message string) (sha string, files []domain.FileChange, err error)
	Push(ctx context.Context, repo domain.Repository, branch string) error
	// PushTo fast-forwards target (the default branch) to branch's head.
	PushTo(ctx context.Context, repo domain.Repository, branch, target string) error
}

// PR is a pull request to open.
type PR struct {
	Branch string
	Title  string
	Body   string
	Draft  bool
}

// Assigner assigns an open pull request to git host users. Hosts that
// cannot do it simply do not implement it.
type Assigner interface {
	Assign(ctx context.Context, repo domain.Repository, number int, usernames []string) error
}

// Host opens pull requests on GitHub (GitLab in phase 5).
type Host interface {
	OpenPR(ctx context.Context, repo domain.Repository, pr PR) (number int, url string, err error)
}

// CommentKind lets the tracker apply the user's comment preferences.
type CommentKind string

// Comment kinds.
const (
	CommentQuestions CommentKind = "questions"
	CommentPlan      CommentKind = "plan"
	CommentPR        CommentKind = "pr"
	CommentSummary   CommentKind = "summary"
	CommentStatus    CommentKind = "status"
)

// Tracker posts back to the issue tracker. Failures are logged, never fatal.
type Tracker interface {
	// Comment posts text unless the user turned that kind off; it reports
	// whether a comment was posted.
	Comment(ctx context.Context, key string, kind CommentKind, text string) (bool, error)
	// MoveTo transitions the issue to the named status, if configured.
	MoveTo(ctx context.Context, key string, status TrackerStatus) error
}

// TrackerStatus is a hiro milestone mapped to a tracker status in settings.
type TrackerStatus string

// Tracker milestones.
const (
	TrackerStarted  TrackerStatus = "started"
	TrackerInReview TrackerStatus = "in_review"
	TrackerRejected TrackerStatus = "rejected"
	TrackerMerged   TrackerStatus = "merged"
)

// Homes stores each ticket's Claude Code config dir between runs.
type Homes interface {
	Load(ticketKey string) ([]byte, error) // nil, nil when there is none
	Save(ticketKey string, tar []byte) error
}
