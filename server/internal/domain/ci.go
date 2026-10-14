package domain

import (
	"errors"
	"fmt"
	"path"
	"regexp"
	"slices"
	"strings"
	"time"
)

// SourceCI is a ticket agnts opened for a failing CI pipeline.
const SourceCI TicketSource = "ci"

// CIStatus is where a CI failure group is in its life.
type CIStatus string

// CI failure statuses.
const (
	CIOpen       CIStatus = "open"       // confirmed failure, no ticket yet
	CIFixing     CIStatus = "fixing"     // a ticket is working on it
	CIFixed      CIStatus = "fixed"      // the fix was merged; waiting for a green run
	CIResolved   CIStatus = "resolved"   // the branch is green again
	CIFlaky      CIStatus = "flaky"      // passed when re-run
	CIInfra      CIStatus = "infra"      // the runner or the network, not the code
	CIMuted      CIStatus = "muted"      // someone said to ignore it
	CIRegression CIStatus = "regression" // failed again on a commit that has the fix
	CITriage     CIStatus = "triage"     // waiting for the re-run of a new failure
)

// CIStatuses lists the valid statuses.
var CIStatuses = []CIStatus{CIOpen, CIFixing, CIFixed, CIResolved, CIFlaky, CIInfra, CIMuted, CIRegression, CITriage}

// Valid reports whether s is a known status.
func (s CIStatus) Valid() bool { return slices.Contains(CIStatuses, s) }

// Active reports whether a group with this status still needs attention:
// a new occurrence counts against it rather than starting a new one.
func (s CIStatus) Active() bool {
	return s == CIOpen || s == CIFixing || s == CIRegression || s == CITriage
}

// CI failure classes: what triage or the analysis decided the cause is.
const (
	CIClassCode       = "code"
	CIClassTest       = "test"
	CIClassConfig     = "config"
	CIClassDependency = "dependency"
	CIClassInfra      = "infra"
	CIClassFlaky      = "flaky"
	CIClassUnknown    = ""
)

// CIRun is a finished CI run (a GitHub Actions workflow run or a GitLab
// pipeline) as a webhook or the poller reports it.
type CIRun struct {
	Provider   string // github or gitlab
	Repo       string // owner/name or group/project, as the host names it
	RunID      int64
	Attempt    int    // GitHub run_attempt; 1 for the first
	Workflow   string // workflow file (GitHub) or "pipeline" (GitLab)
	Name       string // the workflow's display name
	Branch     string
	SHA        string
	Event      string // push, pull_request, schedule, ...
	Conclusion string // success, failure, cancelled, skipped
	URL        string
	// PRNumbers are the pull requests the run belongs to, when the host
	// says (GitHub: same-repository PRs only).
	PRNumbers []int
	// Fork: the run's head is in another repository. Never fed to Claude.
	Fork     bool
	Author   string
	Message  string
	Finished time.Time
}

// Failed reports whether the run failed (not cancelled or skipped).
func (r CIRun) Failed() bool {
	return r.Conclusion == "failure" || r.Conclusion == "failed" || r.Conclusion == "timed_out"
}

// Passed reports whether the run succeeded.
func (r CIRun) Passed() bool { return r.Conclusion == "success" }

// CIJob is one job of a run.
type CIJob struct {
	ID           int64
	Name         string
	Stage        string // GitLab stage; "" on GitHub
	Conclusion   string
	FailedStep   string
	AllowFailure bool
	URL          string
	Annotations  []string // file:line: message, when the host has them
}

// QualifiedName is the job's name with its stage, as shown and matched.
func (j CIJob) QualifiedName() string {
	if j.Stage != "" {
		return j.Stage + ": " + j.Name
	}
	return j.Name
}

// CIOccurrence is one failing run of a group.
type CIOccurrence struct {
	RunID int64     `json:"runId"`
	URL   string    `json:"url"`
	SHA   string    `json:"sha"`
	Job   string    `json:"job"`
	At    time.Time `json:"at"`
	Flaky bool      `json:"flaky,omitempty"`
}

// MaxCIOccurrences is how many occurrences a group keeps.
const MaxCIOccurrences = 20

// CIFailure is a group of CI failures with the same fingerprint on one
// branch of one repository.
type CIFailure struct {
	ID          int64
	WorkspaceID int64
	RepoID      int64
	RepoName    string // filled by reads
	Branch      string
	Workflow    string
	Job         string
	Fingerprint string
	Class       string
	Title       string
	Status      CIStatus
	Count       int
	FlakyCount  int
	FirstSeenAt time.Time
	LastSeenAt  time.Time
	FirstSHA    string
	LastSHA     string
	// Sample is the redacted log excerpt of the newest occurrence; it is
	// only filled by single reads.
	Sample      string
	Occurrences []CIOccurrence
	TicketKey   string
	FixedSHA    string
	FixedAt     *time.Time
	// PRNumber is the other person's pull request the failure is on (comment
	// mode), 0 on watched branches.
	PRNumber  int
	CommentID string // the diagnosis comment, updated in place
}

// LastRun returns the newest occurrence, if any.
func (f CIFailure) LastRun() (CIOccurrence, bool) {
	if len(f.Occurrences) == 0 {
		return CIOccurrence{}, false
	}
	return f.Occurrences[len(f.Occurrences)-1], true
}

// CanReopenForCI reports whether a red check on t's pull request may send
// it back to coding: it was pushed with a pull request that is still open,
// and it is not a replay or a review of someone else's pull request.
func CanReopenForCI(t Ticket) bool {
	return t.State == StateDone && t.AnyPR() && t.MergedAt == nil && t.ReplayOf == "" &&
		t.Source != SourceGit && (t.Kind == KindCode || t.Kind == KindTest)
}

// CanReopenForCIIn reports whether red CI on the ticket's pull request in
// repository repoID may send the ticket back to coding: that pull request
// is open (not merged, not closed) and the ticket may reopen at all.
func CanReopenForCIIn(t Ticket, repoID int64) bool {
	r, ok := t.RepoState(repoID)
	return ok && CanReopenForCI(t) && r.PRNumber != nil && r.MergedAt == nil && r.ClosedAt == nil && r.State != RepoDropped
}

// CIFilter selects failure groups.
type CIFilter struct {
	RepoID   int64
	Branch   string
	Workflow string
	Statuses []CIStatus
	Limit    int
}

// CIPRMode is what agnts does with failures on other people's pull requests.
type CIPRMode string

// PR modes.
const (
	CIPROff     CIPRMode = "off"
	CIPRComment CIPRMode = "comment"
)

// CIWatch is one repository's CI watching.
type CIWatch struct {
	RepoID  int64 `json:"-"`
	Enabled bool  `json:"enabled"`
	// Branches are globs of watched branches; empty means the default
	// branch only.
	Branches []string `json:"branches"`
	// Ignore are globs of workflow or job names never watched.
	Ignore []string `json:"ignore"`
	PRs    CIPRMode `json:"prs"`
	// AutoFix overrides Settings.CI.AutoFix for this repository when set.
	AutoFix *bool `json:"autoFix,omitempty"`
	// Polled is set by the poller: the newest run it has seen.
	LastPolledRun int64 `json:"lastPolledRun,omitempty"`
}

// DefaultCIIgnore are the jobs a new watch ignores: deploys rarely fail
// for a reason a code change fixes.
var DefaultCIIgnore = []string{"*deploy*", "*release*", "*publish*"}

// DefaultCIWatch returns the watch a repository has before anyone set one.
func DefaultCIWatch(repoID int64) CIWatch {
	return CIWatch{RepoID: repoID, Branches: []string{}, Ignore: slices.Clone(DefaultCIIgnore), PRs: CIPROff}
}

// Normalize cleans lists and checks values.
func (w *CIWatch) Normalize() error {
	clean := func(in []string) []string {
		out := []string{}
		for _, s := range in {
			if s = strings.TrimSpace(s); s != "" && !slices.Contains(out, s) {
				out = append(out, s)
			}
		}
		return out
	}
	w.Branches, w.Ignore = clean(w.Branches), clean(w.Ignore)
	if w.PRs == "" {
		w.PRs = CIPROff
	}
	var errs []error
	if w.PRs != CIPROff && w.PRs != CIPRComment {
		errs = append(errs, fmt.Errorf("prs must be %s or %s", CIPROff, CIPRComment))
	}
	for _, g := range append(slices.Clone(w.Branches), w.Ignore...) {
		if _, err := path.Match(g, ""); err != nil {
			errs = append(errs, fmt.Errorf("%q is not a valid pattern", g))
		}
	}
	return errors.Join(errs...)
}

// WatchesBranch reports whether failures on branch are watched.
func (w CIWatch) WatchesBranch(branch, defaultBranch string) bool {
	if branch == defaultBranch {
		return true
	}
	for _, g := range w.Branches {
		if ok, _ := path.Match(g, branch); ok {
			return true
		}
	}
	return false
}

// Ignores reports whether a workflow or job name is ignored.
func (w CIWatch) Ignores(names ...string) bool {
	for _, n := range names {
		n = strings.ToLower(n)
		for _, g := range w.Ignore {
			if ok, _ := path.Match(strings.ToLower(g), n); ok {
				return true
			}
		}
	}
	return false
}

// CISettings are the workspace's CI watching settings.
type CISettings struct {
	// AutoFix creates a ticket for every confirmed code failure; off, the
	// failure waits for Fix it.
	AutoFix bool `json:"autoFix"`
	// MaxAutoPerDay caps automatic tickets a day (manual Fix it is not capped).
	MaxAutoPerDay int `json:"maxAutoPerDay"`
	// RetryFlaky re-runs the failed jobs of a new failure once before
	// believing it.
	RetryFlaky bool `json:"retryFlaky"`
	// FeedbackRounds caps how many times a red check sends one of agnts's
	// own pull requests back to coding.
	FeedbackRounds int `json:"feedbackRounds"`
	// InfraPatterns are extra regular expressions that mark a log as infra.
	InfraPatterns []string `json:"infraPatterns"`
}

// DefaultCISettings returns the defaults.
func DefaultCISettings() CISettings {
	return CISettings{AutoFix: false, MaxAutoPerDay: 5, RetryFlaky: true, FeedbackRounds: 2, InfraPatterns: []string{}}
}

// Validate checks ranges and compiles the patterns.
func (c *CISettings) Validate() error {
	var errs []error
	if c.MaxAutoPerDay < 0 || c.MaxAutoPerDay > 50 {
		errs = append(errs, errors.New("ci.maxAutoPerDay must be between 0 and 50"))
	}
	if c.FeedbackRounds < 0 || c.FeedbackRounds > 5 {
		errs = append(errs, errors.New("ci.feedbackRounds must be between 0 and 5"))
	}
	out := []string{}
	for _, p := range c.InfraPatterns {
		if p = strings.TrimSpace(p); p == "" || slices.Contains(out, p) {
			continue
		}
		if _, err := regexp.Compile(p); err != nil {
			errs = append(errs, fmt.Errorf("infra pattern %q: %w", p, err))
		}
		out = append(out, p)
	}
	c.InfraPatterns = out
	return errors.Join(errs...)
}
