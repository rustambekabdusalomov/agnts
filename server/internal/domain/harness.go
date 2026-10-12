package domain

import (
	"errors"
	"fmt"
	"regexp"
	"slices"
	"strings"
	"time"
)

// Guard profiles: how strict agnts-guard, the hooks inside every run, is.
const (
	GuardMinimal  = "minimal"
	GuardStandard = "standard"
	GuardStrict   = "strict"
)

// GuardProfiles lists the profiles, least strict first.
var GuardProfiles = []string{GuardMinimal, GuardStandard, GuardStrict}

// GuardHooks are the hook ids a workspace may turn off (see package guard).
var GuardHooks = []string{"pre:secret", "pre:redflags", "pre:rules", "pre:fact-check", "pre:destructive", "post:edit-check", "stop:gate", "session:progress"}

// GuardSettings are the workspace's guard choices.
type GuardSettings struct {
	Profile  string   `json:"profile"`
	Disabled []string `json:"disabled"`
	// FactCheck: the share of strict-profile tickets (0 to 100) whose runs
	// must state facts before the first edit of each file. Tickets are
	// picked by key, so a ticket keeps its group.
	FactCheck int `json:"factCheck"`
}

// Validate checks a guard profile and hook ids.
func (g *GuardSettings) Validate() error {
	if g.Profile == "" {
		g.Profile = GuardStandard
	}
	var errs []error
	if !slices.Contains(GuardProfiles, g.Profile) {
		errs = append(errs, fmt.Errorf("guard profile must be one of %s", strings.Join(GuardProfiles, ", ")))
	}
	if g.Disabled == nil {
		g.Disabled = []string{}
	}
	for _, h := range g.Disabled {
		if !slices.Contains(GuardHooks, h) {
			errs = append(errs, fmt.Errorf("unknown guard hook %q", h))
		}
	}
	if g.FactCheck < 0 || g.FactCheck > 100 {
		errs = append(errs, errors.New("fact check share must be between 0 and 100"))
	}
	return errors.Join(errs...)
}

// RepoHarness is a repository's own guard and check settings. Empty fields
// follow the workspace.
type RepoHarness struct {
	// GuardProfile overrides the workspace's profile ("" inherits it).
	GuardProfile string `json:"guardProfile,omitempty"`
	// SecretAllow are path globs where example credentials are expected
	// (besides testdata/, fixtures/ and *.example).
	SecretAllow []string `json:"secretAllow,omitempty"`
	// EditChecks run on each file Claude edits; nil uses the ones agnts
	// detects from the toolchains.
	EditChecks []EditCheck `json:"editChecks,omitempty"`
	// EditChecksOff turns the per-file checks off for the repository.
	EditChecksOff bool `json:"editChecksOff,omitempty"`
	// Coverage measures how much of the changed code the tests run.
	Coverage CoverageConfig `json:"coverage,omitzero"`
	// Acceptance checks the ticket's acceptance criteria in the running
	// app after the preview (repositories with a preview command).
	Acceptance bool `json:"acceptance,omitempty"`
	// AgentConfig is what agnts found in the repository's agent
	// instructions and configuration; agnts sets it, people read it.
	AgentConfig *AgentConfigScan `json:"agentConfig,omitempty"`
}

// EditCheck is a quick check of one edited file (see guard.EditCheck).
type EditCheck struct {
	Name  string   `json:"name"`
	Globs []string `json:"globs"`
	Cmd   string   `json:"cmd"`
	Every int      `json:"every,omitempty"` // seconds between runs; 0: after every edit
}

// CoverageConfig is how a repository's coverage of changed lines is measured.
type CoverageConfig struct {
	Enabled bool `json:"enabled,omitempty"`
	// Command runs the tests with coverage and writes Report; "" uses the
	// one agnts derives from the toolchains.
	Command string `json:"command,omitempty"`
	// Report is the coverage file the command writes, relative to the
	// repository (a Go profile or lcov).
	Report string `json:"report,omitempty"`
	// Threshold, 0 to 100: below it, the review gets a coverage finding.
	Threshold int `json:"threshold,omitempty"`
}

// AgentConfigScan is the result of scanning a repository's agent files.
type AgentConfigScan struct {
	ScannedAt time.Time            `json:"scannedAt"`
	Findings  []AgentConfigFinding `json:"findings"`
}

// AgentConfigFinding is one thing the scan of agent files found.
type AgentConfigFinding struct {
	Path     string `json:"path"`
	Line     int    `json:"line,omitempty"`
	Kind     string `json:"kind"`
	Severity string `json:"severity"` // high, medium or info
	Text     string `json:"text"`
}

// Serious reports whether the scan found something people should read.
func (s *AgentConfigScan) Serious() []AgentConfigFinding {
	if s == nil {
		return nil
	}
	var out []AgentConfigFinding
	for _, f := range s.Findings {
		if f.Severity == "high" || f.Severity == "medium" {
			out = append(out, f)
		}
	}
	return out
}

// Validate checks a repository's harness settings people can change.
func (h *RepoHarness) Validate() error {
	var errs []error
	if h.GuardProfile != "" && !slices.Contains(GuardProfiles, h.GuardProfile) {
		errs = append(errs, fmt.Errorf("guard profile must be empty or one of %s", strings.Join(GuardProfiles, ", ")))
	}
	h.SecretAllow = cleanList(h.SecretAllow)
	for i, c := range h.EditChecks {
		c.Name, c.Cmd = strings.TrimSpace(c.Name), strings.TrimSpace(c.Cmd)
		c.Globs = cleanList(c.Globs)
		if c.Name == "" || c.Cmd == "" || len(c.Globs) == 0 {
			errs = append(errs, fmt.Errorf("edit check %d needs a name, a command and at least one glob", i+1))
		}
		if c.Every < 0 || c.Every > 3600 {
			errs = append(errs, fmt.Errorf("edit check %q: run at most every 0 to 3600 seconds", c.Name))
		}
		h.EditChecks[i] = c
	}
	c := &h.Coverage
	c.Command, c.Report = strings.TrimSpace(c.Command), strings.TrimSpace(c.Report)
	if c.Threshold < 0 || c.Threshold > 100 {
		errs = append(errs, errors.New("coverage threshold must be between 0 and 100"))
	}
	if (c.Command == "") != (c.Report == "") {
		errs = append(errs, errors.New("a coverage command needs the report file it writes, and the other way round"))
	}
	if strings.Contains(c.Report, "..") || strings.HasPrefix(c.Report, "/") && !strings.HasPrefix(c.Report, "/agnts/out/") {
		errs = append(errs, errors.New("the coverage report must be a path inside the repository or under /agnts/out/"))
	}
	return errors.Join(errs...)
}

func cleanList(in []string) []string {
	var out []string
	for _, s := range in {
		if s = strings.TrimSpace(s); s != "" && !slices.Contains(out, s) {
			out = append(out, s)
		}
	}
	return out
}

// AllowPattern is "agnts: allow <kind>" in a ticket or an answer: a person
// lifting one of agnts-guard's red flag blocks for that ticket.
var AllowPattern = regexp.MustCompile(`(?im)\bagnts:\s*allow\s+([a-z_]+(?:\s*,\s*[a-z_]+)*)`)

// AllowedFlags returns the red flag kinds the texts lift.
func AllowedFlags(texts ...string) []string {
	var out []string
	for _, t := range texts {
		for _, m := range AllowPattern.FindAllStringSubmatch(t, -1) {
			for _, k := range strings.Split(m[1], ",") {
				if k = strings.TrimSpace(k); slices.Contains(FlagKinds, k) && !slices.Contains(out, k) {
					out = append(out, k)
				}
			}
		}
	}
	return out
}

// RunHarness is what agnts-guard and the server's harness checks recorded
// for a run.
type RunHarness struct {
	Guard *GuardSummary `json:"guard,omitempty"`
	// Stalls are the times the run looked stuck.
	Stalls []Stall `json:"stalls,omitempty"`
	// FactCheck: the run belonged to the fact check group (A/B).
	FactCheck bool `json:"factCheck,omitempty"`
	// Tool is the coding tool the run used: "" for Claude Code, "codex".
	Tool string `json:"tool,omitempty"`
	// Trouble is what went wrong along the way (failed checks, a stall),
	// condensed for a reflect run that may turn it into a tip.
	Trouble []string `json:"trouble,omitempty"`
}

// GuardSummary sums up a run's guard log.
type GuardSummary struct {
	Blocks       map[string]int `json:"blocks,omitempty"`   // by red flag kind or hook
	Feedback     map[string]int `json:"feedback,omitempty"` // by check name
	Warnings     int            `json:"warnings,omitempty"`
	StopFailures int            `json:"stopFailures,omitempty"`
	CheckMS      int64          `json:"checkMs,omitempty"` // time spent in edit checks and the stop gate
	Last         []GuardEntry   `json:"last,omitempty"`    // the latest decisions, for the ticket log
}

// GuardEntry is one guard decision.
type GuardEntry struct {
	At       time.Time `json:"at"`
	Event    string    `json:"event"`
	Hook     string    `json:"hook,omitempty"`
	Tool     string    `json:"tool,omitempty"`
	Decision string    `json:"decision"`
	Kind     string    `json:"kind,omitempty"`
	Path     string    `json:"path,omitempty"`
	MS       int64     `json:"ms,omitempty"`
	Msg      string    `json:"msg,omitempty"`
}

// Stall is a moment a run looked stuck.
type Stall struct {
	At     time.Time `json:"at"`
	Turn   int       `json:"turn"`
	Reason string    `json:"reason"` // repeated_failure, no_edits, rereading
	Detail string    `json:"detail"`
	Acted  bool      `json:"acted"` // agnts stepped in
}

// ResultHarness is what the harness checks found in a result.
type ResultHarness struct {
	// SecondOpinion is another model's critique of the chosen approach
	// (analysis results of complex tickets).
	SecondOpinion *SecondOpinion `json:"secondOpinion,omitempty"`
	Proof         *Proof         `json:"proof,omitempty"`
	Coverage      *Coverage      `json:"coverage,omitempty"`
	Acceptance    *Acceptance    `json:"acceptance,omitempty"`
}

// Proof statuses.
const (
	ProofProven        = "proven"         // the test fails before the change and passes after it
	ProofNotReproduced = "not_reproduced" // the test passes before the change too: it does not catch the bug
	ProofStillFailing  = "still_failing"  // the test fails after the change
	ProofInconclusive  = "inconclusive"   // the test could not run before the change (it needs the new code, or the environment)
	ProofNoTest        = "no_test"        // no automated test is possible; Why says why
	ProofError         = "error"          // agnts could not run the proof
)

// Proof is the evidence that a bug fix fixes the bug: tests that fail on
// the code before the change and pass after it.
type Proof struct {
	Status string      `json:"status"`
	Base   string      `json:"base,omitempty"` // the commit the change started from
	Tests  []ProofTest `json:"tests,omitempty"`
	Why    string      `json:"why,omitempty"` // no_test: why there is none; error: what went wrong
}

// ProofTest is one reproducing test, run before and after the change.
type ProofTest struct {
	File    string    `json:"file"`
	Name    string    `json:"name"`
	Command string    `json:"command"`
	Before  ProofRun  `json:"before"`
	After   ProofRun  `json:"after"`
	Status  string    `json:"status"`
	At      time.Time `json:"at"`
}

// ProofRun is one run of a reproducing test.
type ProofRun struct {
	Exit   int    `json:"exit"`
	Output string `json:"output"` // the tail
	MS     int64  `json:"ms"`
}

// Coverage is how much of a change's added lines the tests ran.
type Coverage struct {
	Covered   int            `json:"covered"`
	Total     int            `json:"total"`
	Percent   float64        `json:"percent"`
	Threshold int            `json:"threshold,omitempty"`
	Files     []FileCoverage `json:"files,omitempty"`
	Error     string         `json:"error,omitempty"`
}

// FileCoverage is one changed file's coverage of added lines.
type FileCoverage struct {
	Path      string      `json:"path"`
	Covered   int         `json:"covered"`
	Total     int         `json:"total"`
	Uncovered []LineRange `json:"uncovered,omitempty"`
}

// LineRange is a range of lines, both ends included.
type LineRange struct {
	From int `json:"from"`
	To   int `json:"to"`
}

// Acceptance is the check of a ticket's acceptance criteria in the running app.
type Acceptance struct {
	Status   string                `json:"status"` // ok, partial, failed
	Summary  string                `json:"summary"`
	Criteria []AcceptanceCriterion `json:"criteria"`
}

// AcceptanceCriterion is one criterion and its verdict.
type AcceptanceCriterion struct {
	ID        string   `json:"id"`
	Criterion string   `json:"criterion"`
	Verdict   string   `json:"verdict"` // pass, fail or unknown
	Evidence  string   `json:"evidence,omitempty"`
	Steps     []string `json:"steps,omitempty"`
	Shots     []string `json:"shots,omitempty"` // screenshot ids
}

// Learning thresholds: what a learned suggestion's confidence means.
const (
	ConfidenceFromFeedback = 0.5  // a suggestion from a person's feedback starts here
	ConfidenceFromRun      = 0.3  // a tip from a run's trouble starts here
	ConfidenceStep         = 0.15 // added each time the lesson is seen again
	ConfidenceMax          = 0.9
	// ConfidenceShown: below it a suggestion is only watched: listed apart,
	// never announced.
	ConfidenceShown = 0.5
	// SuggestionExpiryDays: a learned suggestion not seen again for this
	// long is dismissed.
	SuggestionExpiryDays = 60
)

// Watching reports whether a learned suggestion has too little evidence
// to be shown as a suggestion yet.
func (r Rule) Watching() bool {
	return r.Status == RuleSuggested && r.Confidence > 0 && r.Confidence < ConfidenceShown
}

// SecondOpinion is another model's read of the approach an analysis chose.
type SecondOpinion struct {
	Model    string   `json:"model"`
	Agrees   bool     `json:"agrees"`
	Summary  string   `json:"summary"`
	Concerns []string `json:"concerns,omitempty"`
	// Alternative is the approach it would take instead, when it disagrees.
	Alternative string `json:"alternative,omitempty"`
	Error       string `json:"error,omitempty"`
}
