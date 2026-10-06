// Package orchestrator owns the ticket state machine: it claims work, drives
// each stage through the runner, and applies the human decisions (answers,
// approve, request changes, reject, retry). It depends only on the
// interfaces in this file; adapters implement them.
package orchestrator

import (
	"context"
	"io"
	"time"

	"agnts/internal/domain"
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
	// RecordClaudeCall stores the token spend of one Claude invocation.
	RecordClaudeCall(ctx context.Context, c domain.ClaudeCall) error
	// TicketUsage returns a ticket's spend by model stage and model.
	TicketUsage(ctx context.Context, ticketID int64) ([]domain.StageUsage, error)
	// SpendByKeys returns each ticket's total spend; tickets without any
	// are absent.
	SpendByKeys(ctx context.Context, keys []string) (map[string]domain.TokenUsage, error)
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
	// NextTaskNumber reserves a task number in repoID, or among tasks
	// without a repository when it is nil.
	NextTaskNumber(ctx context.Context, repoID *int64) (int, error)
	DeleteTicket(ctx context.Context, key string, ev domain.Event) error
	// StateSince returns when each ticket entered its current state and,
	// for failed or paused ones, the reason.
	StateSince(ctx context.Context, keys []string) (map[string]StateInfo, error)
	History(ctx context.Context, key string) ([]HistoryItem, error)
	TicketByPR(ctx context.Context, url, branch string) (domain.Ticket, error)
	// ChildOf returns the ticket that implements parentKey, or ErrNotFound.
	ChildOf(ctx context.Context, parentKey string) (domain.Ticket, error)

	// ReplaceSuggestions swaps the open suggestions source made for a
	// ticket for ss, and appends ev (nil for none), in one transaction.
	ReplaceSuggestions(ctx context.Context, ticketID int64, source string, ss []domain.Suggestion, ev *domain.Event) error
	AddSuggestion(ctx context.Context, s domain.Suggestion, ev domain.Event) (domain.Suggestion, error)
	Suggestions(ctx context.Context, ticketID int64) ([]domain.Suggestion, error)
	OpenSuggestionCounts(ctx context.Context, keys []string) (map[string]int, error)
	// DismissSuggestion and CreateFollowUp decide an open suggestion of a
	// ticket; one already decided gives domain.ErrSuggestionDecided.
	DismissSuggestion(ctx context.Context, ticketID, id int64, ev domain.Event) (domain.Suggestion, error)
	// CreateFollowUp creates t from the suggestion and marks it accepted.
	CreateFollowUp(ctx context.Context, ticketID, id int64, t domain.Ticket, ev domain.Event) (domain.Ticket, error)
	// FollowUpsOf returns the tickets made from parentKey's suggestions.
	FollowUpsOf(ctx context.Context, parentKey string) ([]domain.Ticket, error)
	// OpenTicketRefs returns the newest unfinished tickets in repoID (nil:
	// tasks without a repository).
	OpenTicketRefs(ctx context.Context, repoID *int64, limit int) ([]TicketRef, error)

	RelationStore
}

// TicketRef names a ticket.
type TicketRef struct {
	Key   string
	Title string
}

// RelationStore keeps the ordering constraints between tickets. The queue
// (ClaimNext) reads the active ones directly.
type RelationStore interface {
	// RelationsOf returns every relation involving key, any status, with
	// the other ticket's title and state, oldest first.
	RelationsOf(ctx context.Context, key string) ([]RelationRow, error)
	// RelationByID returns one relation, or ErrNotFound.
	RelationByID(ctx context.Context, id int64) (domain.Relation, error)
	// DependencyGraph returns the active depends_on edges: key -> the keys
	// it waits for. Cycle checks use it.
	DependencyGraph(ctx context.Context) (map[string][]string, error)
	// ReplaceFound swaps the agnts and rule relations foundBy's analysis
	// found before (dismissed ones stay) for rs, merging each into a
	// relation the pair may already have, and appends ev when not nil. It
	// returns the relations as stored.
	ReplaceFound(ctx context.Context, foundBy string, rs []domain.Relation, ev *domain.Event) ([]domain.Relation, error)
	// SyncJiraRelations makes the jira relations involving key exactly rs
	// (only between tickets agnts has); it reports what it added.
	SyncJiraRelations(ctx context.Context, key string, rs []domain.Relation) ([]domain.Relation, error)
	// UpsertRelation stores r, or merges it into the pair's relation: the
	// stronger status and source win, and only a person revives a
	// dismissed one. ev is appended when not nil.
	UpsertRelation(ctx context.Context, r domain.Relation, ev *domain.Event) (domain.Relation, error)
	// DecideRelation sets a relation's status (active or dismissed) and
	// appends ev. ErrNotFound when it does not involve key.
	DecideRelation(ctx context.Context, key string, id int64, status domain.RelationStatus, ev domain.Event) (domain.Relation, error)
	// Blockers returns, per key, the tickets holding its first coding run
	// back right now. Keys that are not held back are absent.
	Blockers(ctx context.Context, keys []string) (map[string][]domain.Blocker, error)
	// RelationCandidates returns the tickets in repoID that work on except
	// could depend on or collide with: open ones, and done ones whose
	// change is not merged yet. Each comes with its newest analysis.
	RelationCandidates(ctx context.Context, repoID int64, except string, limit int) ([]Candidate, error)
	// InFlightResults returns the newest code result of each ticket in
	// repoID, other than except, whose change is committed but not merged.
	InFlightResults(ctx context.Context, repoID int64, except string) ([]InFlight, error)
}

// RelationRow is a relation with the ticket on its other side.
type RelationRow struct {
	domain.Relation
	OtherTitle string
	OtherState domain.TicketState
	// OtherReleases reports whether the other ticket no longer holds work
	// back (merged, or rejected).
	OtherReleases bool
}

// Candidate is a ticket a new analysis compares itself with.
type Candidate struct {
	Ticket   domain.Ticket
	Analysis []byte // the newest analysis.json, or nil
}

// InFlight is a committed change not merged yet.
type InFlight struct {
	Ticket domain.Ticket
	Files  []domain.FileChange
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

// Translations stores translated texts, keyed by domain.TextHash of the
// source text and the language.
type Translations interface {
	// Translated returns the translations into lang of the texts with these
	// hashes, by hash; texts never translated are absent.
	Translated(ctx context.Context, lang string, hashes []string) (map[string]string, error)
	SaveTranslations(ctx context.Context, lang string, byHash map[string]string) error
}

// Rules are the instructions the user wrote for every ticket, and the queue
// of rules waiting for Claude's review.
type Rules interface {
	Rule(ctx context.Context, id int64) (domain.Rule, error)
	ListRules(ctx context.Context) ([]domain.Rule, error)
	// ActiveRules returns the enabled, reviewed rules for tickets in repoID
	// (global ones first); nil gives the global rules only.
	ActiveRules(ctx context.Context, repoID *int64) ([]domain.Rule, error)
	CreateRule(ctx context.Context, r domain.Rule, ev func(domain.Rule) domain.Event) (domain.Rule, error)
	// UpdateRule applies mut to the locked rule and appends the event ev
	// returns (nil for none) in the same transaction.
	UpdateRule(ctx context.Context, id int64, mut func(*domain.Rule) error, ev func(domain.Rule) *domain.Event) (domain.Rule, error)
	DeleteRule(ctx context.Context, id int64, ev domain.Event) error
	// ClaimRule moves the oldest pending rule to analyzing; ok is false
	// when none is waiting.
	ClaimRule(ctx context.Context) (r domain.Rule, ok bool, err error)
	// RecoverRules requeues reviews a crash left running.
	RecoverRules(ctx context.Context) (int, error)
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
	Duration    time.Duration
	// Model is the model Claude Code reported at start, which may differ
	// from the one requested (an alias, or a fallback).
	Model string
	// Usage is the invocation's token spend. Partial means the stream had
	// no result line (killed or timed out) and Usage was summed from the
	// assistant messages seen, without a cost.
	Usage   domain.TokenUsage
	Partial bool
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
	CommentReport    CommentKind = "report" // an approved report, posted on request
)

// Tracker posts back to the issue tracker. Failures are logged, never fatal.
type Tracker interface {
	// Comment posts text unless the user turned that kind off; it reports
	// whether a comment was posted.
	Comment(ctx context.Context, key string, kind CommentKind, text string) (bool, error)
	// MoveTo transitions the issue to the named status, if configured.
	MoveTo(ctx context.Context, key string, status TrackerStatus) error
}

// IssueCreator files new issues in the tracker. A tracker may implement
// it; follow-ups can then be filed there instead of as local tasks.
type IssueCreator interface {
	// CreateIssue files an issue without agnts's labels and returns its key.
	CreateIssue(ctx context.Context, in NewIssue) (string, error)
	// LabelIssue adds agnts's labels for kind, which hand the issue to agnts.
	LabelIssue(ctx context.Context, key string, kind domain.TicketKind) error
	// LinkIssues links key to other as related issues.
	LinkIssues(ctx context.Context, key, other string) error
}

// NewIssue is an issue to file.
type NewIssue struct {
	Project     string
	Title       string
	Description string // plain text
	Priority    string // low, medium or high
}

// TrackerStatus is a agnts milestone mapped to a tracker status in settings.
type TrackerStatus string

// Tracker milestones.
const (
	TrackerStarted  TrackerStatus = "started"
	TrackerInReview TrackerStatus = "in_review"
	TrackerRejected TrackerStatus = "rejected"
	TrackerMerged   TrackerStatus = "merged"
)

// Shots stores preview screenshots by ticket and run.
type Shots interface {
	Save(ticketKey string, runID int64, id string, png []byte) error
	Open(ticketKey string, runID int64, id string) (io.ReadCloser, error)
	// Prune deletes a ticket's screenshots except those of the runs in
	// keep; an empty keep deletes them all.
	Prune(ticketKey string, keep []int64) error
	// Tickets lists the ticket keys that have screenshots.
	Tickets() ([]string, error)
}

// PreviewEnvs returns a repository's preview environment (KEY=value
// lines), "" when none is set.
type PreviewEnvs interface {
	PreviewEnv(ctx context.Context, repoID int64) (string, error)
}

// Homes stores each ticket's Claude Code config dir between runs.
type Homes interface {
	Load(ticketKey string) ([]byte, error) // nil, nil when there is none
	Save(ticketKey string, tar []byte) error
}
