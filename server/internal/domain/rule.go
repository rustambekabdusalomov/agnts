package domain

import (
	"errors"
	"fmt"
	"regexp"
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
	// RuleSuggested: agnts proposed it from what people told it; tickets
	// never get it until someone adopts it (a review, or as written).
	RuleSuggested RuleStatus = "suggested"
	// RuleDismissed: a suggestion someone declined, kept so it is not
	// suggested again; never shown in the list.
	RuleDismissed RuleStatus = "dismissed"
)

// RuleKind tells instructions from business knowledge.
type RuleKind string

// Rule kinds.
const (
	// KindInstruction is something agnts must do: it reaches prompts as a
	// team rule.
	KindInstruction RuleKind = "rule"
	// KindContext is business knowledge (a glossary, invariants, roles):
	// runs get every context note in /agnts/context/business.md.
	KindContext RuleKind = "context"
	// KindTip is a practical lesson about running a repository's work
	// ("the tests need the database: run make dev-db first"), learned from
	// runs; runs get tips as skills.
	KindTip RuleKind = "tip"
)

// Valid reports whether k is a known kind.
func (k RuleKind) Valid() bool { return k == KindInstruction || k == KindContext || k == KindTip }

// Rule deliveries: how a rule reaches a run.
const (
	DeliverPrompt = "prompt" // in every prompt
	DeliverSkill  = "skill"  // a skill Claude loads when its description matches the work
)

// LessonTags are the kinds of lesson a learned rule can be, for counting
// which kinds agnts keeps getting wrong.
var LessonTags = []string{"reuse", "layer", "tests", "style", "logic", "other"}

// CleanLessonTag returns tag when it is one of LessonTags, else "".
func CleanLessonTag(tag string) string {
	tag = strings.ToLower(strings.TrimSpace(tag))
	for _, t := range LessonTags {
		if t == tag {
			return tag
		}
	}
	return ""
}

// RuleEnforce makes a rule something agnts-guard checks, not only asks
// for: On "file" checks edits of files matching Paths (and, with a
// Pattern, only added lines matching it), "bash" checks commands against
// Pattern, "diff" checks the finished change (on the server only).
type RuleEnforce struct {
	On      string   `json:"on"`
	Paths   []string `json:"paths,omitempty"`
	Pattern string   `json:"pattern,omitempty"`
	Action  string   `json:"action"` // block or warn
	Message string   `json:"message,omitempty"`
}

// Validate checks an enforcement and compiles its pattern.
func (e *RuleEnforce) Validate() error {
	e.Pattern, e.Message = strings.TrimSpace(e.Pattern), strings.TrimSpace(e.Message)
	var paths []string
	for _, p := range e.Paths {
		if p = strings.TrimSpace(p); p != "" {
			paths = append(paths, p)
		}
	}
	e.Paths = paths
	var errs []error
	switch e.On {
	case "file", "diff":
		if len(e.Paths) == 0 && e.Pattern == "" {
			errs = append(errs, errors.New("a file or diff rule needs paths, a pattern, or both"))
		}
	case "bash":
		if e.Pattern == "" {
			errs = append(errs, errors.New("a command rule needs a pattern"))
		}
	default:
		errs = append(errs, errors.New("enforce on must be file, bash or diff"))
	}
	if e.Action != "block" && e.Action != "warn" {
		errs = append(errs, errors.New("enforce action must be block or warn"))
	}
	if e.Pattern != "" {
		if _, err := regexp.Compile(e.Pattern); err != nil {
			errs = append(errs, fmt.Errorf("the pattern is not a valid regular expression: %w", err))
		}
	}
	if len(e.Paths) > 20 || len(e.Pattern) > 500 || len(e.Message) > 1000 {
		errs = append(errs, errors.New("an enforcement takes at most 20 paths, a 500-character pattern and a 1000-character message"))
	}
	return errors.Join(errs...)
}

// Limits of a rule's text and review.
const (
	RuleMaxTitle  = 200
	RuleMaxBody   = 10000
	RuleMaxRounds = 3 // question rounds before the review must settle
)

// Rule is an instruction the user wrote for agnts to follow on every ticket:
// in every repository when RepoID is nil, else in that repository only.
type Rule struct {
	ID          int64
	WorkspaceID int64
	RepoID      *int64
	RepoName    string // filled on reads
	Title       string
	Body        string
	Enabled     bool
	Status      RuleStatus
	// Interpretation is Claude's account of what the rule makes agnts do.
	Interpretation string
	// Clarified is the rule rewritten with what the answers settled; tickets
	// get it instead of Body when set.
	Clarified string
	Questions []RuleQuestion // every question asked, answered or not
	Rounds    int            // question rounds so far
	Revision  int            // bumped by edits and answers
	Error     string         // why the last review failed
	Kind      RuleKind
	// SourceTicket and Reason say where a suggested rule came from: the
	// ticket whose feedback taught it, and which feedback.
	SourceTicket string
	Reason       string
	// Enforce, when set, has agnts-guard check the rule while Claude works.
	Enforce *RuleEnforce
	// Delivery is DeliverPrompt or DeliverSkill.
	Delivery string
	// SkillDescription says when the rule applies, for a skill.
	SkillDescription string
	// Source says where a rule came from: "" (a person), "reflect"
	// (feedback), "run" (a run's trouble), "pack:go" (a starter pack).
	Source string
	// Confidence (0.3 to 0.9) and Evidence (how many times it was seen)
	// are what a learned suggestion has earned; LastSeen is when it was
	// last seen again.
	Confidence float64
	Evidence   int
	LastSeen   *time.Time
	AnalyzedAt *time.Time
	CreatedAt  time.Time
	UpdatedAt  time.Time
	// Tag is what kind of lesson a learned rule is (LessonTags); "" for
	// rules people wrote.
	Tag string
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
