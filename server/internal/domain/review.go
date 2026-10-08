package domain

import (
	"slices"
	"strings"
	"time"
)

// Review states of a ticket: where the code review of its latest result
// stands. The review is advice for the human reviewer and never gates
// approval.
const (
	ReviewNone    = ""
	ReviewPending = "pending"
	ReviewRunning = "running"
	ReviewDone    = "done"
	ReviewFailed  = "failed"
)

// Review verdicts, from best to worst.
const (
	VerdictLooksGood    = "looks_good"
	VerdictHasConcerns  = "has_concerns"
	VerdictNeedsChanges = "needs_changes"
)

// FindingSeverities, most severe first.
var FindingSeverities = []string{"blocker", "major", "minor", "nit"}

// FindingCategories say what a finding is about.
var FindingCategories = []string{
	"correctness", "security", "performance", "tests", "rules", "architecture", "scope", "maintainability", "accuracy", "completeness", "other",
}

// MaxFindings caps what one review keeps, most severe first.
const MaxFindings = 30

// Review is what the review run wrote about a ticket's result. It is
// stored as the review run's result, so it also carries the revision it
// reviewed: a review of an older revision is stale.
type Review struct {
	Revision    int       `json:"revision"`
	Model       string    `json:"model"`
	ModelReason string    `json:"modelReason"`
	Verdict     string    `json:"verdict"`
	Summary     string    `json:"summary"`
	Findings    []Finding `json:"findings"`
	Strengths   []string  `json:"strengths"`
	// FollowUps are what the reviewer found outside this change that the
	// ticket still needs; they are stored as suggestions, not kept here.
	FollowUps []FollowUp `json:"followUps,omitempty"`
	CreatedAt time.Time  `json:"-"`
}

// Finding is one problem the review found.
type Finding struct {
	Severity   string `json:"severity"`
	Category   string `json:"category"`
	File       string `json:"file,omitempty"`
	Line       int    `json:"line,omitempty"`
	Title      string `json:"title"`
	Detail     string `json:"detail,omitempty"`
	Suggestion string `json:"suggestion,omitempty"`
}

// Normalize cleans a review written by Claude: it trims and caps every
// field, drops findings without a title or with an unsafe path, sorts the
// rest most severe first, and settles the verdict. It reports false when
// there is no summary.
func (r *Review) Normalize() bool {
	r.Summary = clip(strings.TrimSpace(r.Summary), 3000)
	if r.Summary == "" {
		return false
	}
	fs := []Finding{}
	for _, f := range r.Findings {
		f.Title = clip(strings.TrimSpace(f.Title), 200)
		if f.Title == "" {
			continue
		}
		if f.Severity = strings.ToLower(strings.TrimSpace(f.Severity)); !slices.Contains(FindingSeverities, f.Severity) {
			f.Severity = "minor"
		}
		if f.Category = strings.ToLower(strings.TrimSpace(f.Category)); !slices.Contains(FindingCategories, f.Category) {
			f.Category = "other"
		}
		f.File = strings.TrimPrefix(strings.TrimSpace(f.File), "/workspace/")
		if strings.HasPrefix(f.File, "/") || slices.Contains(strings.Split(f.File, "/"), "..") {
			f.File = ""
		}
		f.File, f.Line = clip(f.File, 300), max(f.Line, 0)
		if f.File == "" {
			f.Line = 0
		}
		f.Detail = clip(strings.TrimSpace(f.Detail), 3000)
		f.Suggestion = clip(strings.TrimSpace(f.Suggestion), 3000)
		fs = append(fs, f)
	}
	slices.SortStableFunc(fs, func(a, b Finding) int {
		return slices.Index(FindingSeverities, a.Severity) - slices.Index(FindingSeverities, b.Severity)
	})
	if len(fs) > MaxFindings {
		fs = fs[:MaxFindings]
	}
	r.Findings = fs

	st := []string{}
	for _, s := range r.Strengths {
		if s = clip(strings.TrimSpace(s), 500); s != "" && len(st) < 5 {
			st = append(st, s)
		}
	}
	r.Strengths = st

	// The verdict never says less than the findings do.
	worst := r.Worst()
	switch {
	case worst == "blocker":
		r.Verdict = VerdictNeedsChanges
	case r.Verdict == VerdictNeedsChanges:
	case worst == "major":
		r.Verdict = VerdictHasConcerns
	case r.Verdict != VerdictHasConcerns:
		r.Verdict = VerdictLooksGood
	}
	return true
}

// Worst returns the most severe finding's severity, or "" with none.
func (r Review) Worst() string {
	if len(r.Findings) == 0 {
		return ""
	}
	return r.Findings[0].Severity
}

// Counts returns how many findings each severity has.
func (r Review) Counts() map[string]int {
	out := map[string]int{}
	for _, f := range r.Findings {
		out[f.Severity]++
	}
	return out
}
