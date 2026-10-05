package domain

import (
	"errors"
	"strings"
	"time"
	"unicode/utf8"
)

// RuleStatus is where Claude's review of a rule stands.
type RuleStatus string

// Rule statuses. Only ready rules reach ticket prompts.
const (
	RulePending   RuleStatus = "pending"   // queued for review
	RuleAnalyzing RuleStatus = "analyzing" // Claude is reviewing it
	RuleQuestions RuleStatus = "questions" // waiting for the author's answers
	RuleReady     RuleStatus = "ready"     // clear; applied to tickets while enabled
	RuleFailed    RuleStatus = "failed"    // the review did not finish
)

// Limits of a rule's text and review.
const (
	RuleMaxTitle  = 200
	RuleMaxBody   = 10000
	RuleMaxRounds = 3 // question rounds before the review must settle
)

// Rule is an instruction the user wrote for hiro to follow on every ticket:
// in every repository when RepoID is nil, else in that repository only.
type Rule struct {
	ID       int64
	RepoID   *int64
	RepoName string // filled on reads
	Title    string
	Body     string
	Enabled  bool
	Status   RuleStatus
	// Interpretation is Claude's account of what the rule makes hiro do.
	Interpretation string
	// Clarified is the rule rewritten with what the answers settled; tickets
	// get it instead of Body when set.
	Clarified  string
	Questions  []RuleQuestion // every question asked, answered or not
	Rounds     int            // question rounds so far
	Revision   int            // bumped by edits and answers
	Error      string         // why the last review failed
	AnalyzedAt *time.Time
	CreatedAt  time.Time
	UpdatedAt  time.Time
}

// RuleQuestion is one question from a rule's review, with its answer once
// given.
type RuleQuestion struct {
	Text    string   `json:"text"`
	Options []string `json:"options"`
	Answer  string   `json:"answer,omitempty"`
	Note    string   `json:"note,omitempty"`
	Round   int      `json:"round"`
}

// Validate trims and checks the fields a user writes.
func (r *Rule) Validate() error {
	r.Title, r.Body = strings.TrimSpace(r.Title), strings.TrimSpace(r.Body)
	var errs []error
	if r.Title == "" {
		errs = append(errs, errors.New("a rule needs a title"))
	} else if utf8.RuneCountInString(r.Title) > RuleMaxTitle {
		errs = append(errs, errors.New("the title is longer than 200 characters"))
	}
	if r.Body == "" {
		errs = append(errs, errors.New("a rule needs its text"))
	} else if utf8.RuneCountInString(r.Body) > RuleMaxBody {
		errs = append(errs, errors.New("the rule is longer than 10000 characters"))
	}
	return errors.Join(errs...)
}

// Text is what tickets are given: the clarified rule, or else the rule as
// written with the answers given so far.
func (r Rule) Text() string {
	if r.Clarified != "" {
		return r.Clarified
	}
	qs := r.Answered()
	if len(qs) == 0 {
		return r.Body
	}
	var b strings.Builder
	b.WriteString(r.Body + "\n\nClarifications from the author:")
	for _, q := range qs {
		b.WriteString("\n- " + q.Text + " " + q.Answer)
		if q.Note != "" {
			b.WriteString(" (" + q.Note + ")")
		}
	}
	return b.String()
}

// Applies reports whether tickets follow the rule now.
func (r Rule) Applies() bool { return r.Enabled && r.Status == RuleReady }

// Open returns the questions still waiting for an answer.
func (r Rule) Open() []RuleQuestion {
	var out []RuleQuestion
	for _, q := range r.Questions {
		if q.Answer == "" {
			out = append(out, q)
		}
	}
	return out
}

// Answered returns the questions that have an answer.
func (r Rule) Answered() []RuleQuestion {
	var out []RuleQuestion
	for _, q := range r.Questions {
		if q.Answer != "" {
			out = append(out, q)
		}
	}
	return out
}

// Requeue sends the rule back for review after a change to what it says.
func (r *Rule) Requeue() {
	r.Status, r.Error = RulePending, ""
	r.Revision++
}
