package domain

import (
	"errors"
	"slices"
	"strings"
	"time"
)

// PerfReviewSettings are a workspace's performance review choices (see
// plans/Performance review plan.md).
type PerfReviewSettings struct {
	// Enabled shows the Developers tab and scores delivered tickets. Off
	// by default: automated scoring of people needs the workspace to
	// check its obligations first.
	Enabled bool `json:"enabled"`
	// NotDone are the Jira resolutions that close an issue without the
	// work being done; such an issue never delivers its ticket.
	NotDone []string `json:"notDone"`
	// TimeZone is the IANA zone months and commit days are counted in;
	// "" is UTC.
	TimeZone string `json:"timeZone"`
}

// Location is the zone months and days are counted in (UTC when unset
// or unknown).
func (p PerfReviewSettings) Location() *time.Location {
	if p.TimeZone == "" {
		return time.UTC
	}
	if l, err := time.LoadLocation(p.TimeZone); err == nil {
		return l
	}
	return time.UTC
}

// ErrPerfInvalid is a performance review request that cannot be done.
var ErrPerfInvalid = errors.New("invalid performance review request")

// DefaultNotDoneResolutions are Jira's usual resolutions for work that
// was not done.
var DefaultNotDoneResolutions = []string{"Won't Do", "Won't Fix", "Duplicate", "Cannot Reproduce", "Declined", "Incomplete"}

// NotDoneResolutions returns the list in force: the default when unset.
func (p PerfReviewSettings) NotDoneResolutions() []string {
	if p.NotDone == nil {
		return DefaultNotDoneResolutions
	}
	return p.NotDone
}

// TrackerResolution is how a tracker reports an issue's end.
type TrackerResolution struct {
	// Closed: Jira's status category Done, Plane's completed or cancelled
	// state group.
	Closed bool
	// Resolution names how: Jira's resolution ("" when it has none),
	// Plane's state group.
	Resolution string
	// At is when it was resolved, when the tracker says; else now.
	At *time.Time
}

// DoneIn reports whether the issue is resolved as done: closed, and not
// with one of the not-done resolutions (Plane: completed, not cancelled).
func (r TrackerResolution) DoneIn(source TicketSource, notDone []string) bool {
	if !r.Closed {
		return false
	}
	if source == SourcePlane {
		return r.Resolution == "completed"
	}
	return !slices.ContainsFunc(notDone, func(n string) bool { return strings.EqualFold(strings.TrimSpace(n), strings.TrimSpace(r.Resolution)) })
}

// PurposeScore scores a delivered ticket for performance reviews.
const PurposeScore TranscriptPurpose = "score"

// Score run statuses.
const (
	ScoreQueued  = "queued"
	ScoreScoring = "scoring"
	ScoreDone    = "done"
	ScoreFailed  = "failed"
)

// ScoreMaxAttempts is how many times a delivery is tried: once and two
// retries. After that it shows as unscored.
const ScoreMaxAttempts = 3

// ScoreRun is one attempt at scoring a delivery.
type ScoreRun struct {
	ID            int64
	WorkspaceID   int64
	TicketID      int64
	TicketKey     string
	Delivery      int
	PromptVersion string
	Status        string
	Attempts      int
	Error         string
	CreatedAt     time.Time
}

// Delivery is one delivery of a ticket.
type Delivery struct {
	TicketID      int64
	TicketKey     string
	Delivery      int
	DeliveredAt   time.Time
	UndeliveredAt *time.Time
	// PreviousAt is when the delivery before it was made; nil for the
	// first. A delivery counts the commits that reached a default branch
	// after it.
	PreviousAt *time.Time
}

// Score statuses.
const (
	ScoreScored   = "scored"
	ScoreUnscored = "unscored"
)

// TicketScore is a delivery's score under one prompt version.
type TicketScore struct {
	TicketID       int64
	TicketKey      string
	Title          string
	Delivery       int
	DeliveredAt    time.Time
	PromptVersion  string
	Status         string
	Points         int
	FromFactsOnly  bool
	Clamped        bool
	DiffSource     string
	Rationale      string
	Factors        map[string]any
	RevertedShare  float64
	Error          string
	Model          string
	ScoredAt       time.Time
	OverridePoints *int
	OverriddenBy   *int64
	OverrideReason string
	OverriddenAt   *time.Time
	Authors        []ScoreAuthor
	// Regressions are the confirmed regressions of the delivery's ticket
	// that count (filed within 90 days of the delivery).
	Regressions int
}

// Effective is the score in force: the owner's override, else the score.
func (s TicketScore) Effective() int {
	if s.OverridePoints != nil {
		return *s.OverridePoints
	}
	return s.Points
}

// ScoreAuthor is one author's share of a delivery.
type ScoreAuthor struct {
	Key   string
	Share float64
	Days  int
}

// PromptVersionRow is a workspace's scoring version.
type PromptVersionRow struct {
	Version     string
	Model       string
	Anchors     []byte // JSON
	CurrentFrom time.Time
}

// ScoreResult is how a score run ended.
type ScoreResult struct {
	Status string // ScoreDone, ScoreFailed, or ScoreQueued to try again
	Error  string
	Score  *TicketScore // the score to store, when done or finally failed
}

// PeriodClosing is one closing of a month: its totals were written then.
type PeriodClosing struct {
	Month         time.Time
	Closing       int
	PromptVersion string
	Unscored      int
	ClosedAt      time.Time
	ClosedBy      *int64 // nil: closed on its own
}

// DeliveryEarners are the earners a delivery's score recorded (JSON of
// perfreview.Earner).
type DeliveryEarners struct {
	TicketID int64
	Delivery int
	Earners  []byte
}

// UnmappedAuthor is a git identity that earned shares but is no member's.
type UnmappedAuthor struct {
	Key        string
	Identity   string // the login or email
	Deliveries int
}

// GitIdentity gives a git login or email to a workspace member.
type GitIdentity struct {
	UserID      int64
	Provider    string
	Login       string
	Email       string
	AutoMatched bool
}

// Regression is a regression_of relation: the bug ticket and the ticket
// whose delivered work it is a regression of.
type Regression struct {
	ID          int64
	Bug         string
	BugTitle    string
	Origin      string
	OriginTitle string
	Status      string // proposed, active, dismissed
	Source      string
	Reason      string
	DecidedBy   *int64
	DecidedAt   *time.Time
	// Counts: confirmed, and the bug was filed within 90 days of the
	// origin's delivery.
	Counts bool
}
