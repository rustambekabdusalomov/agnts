package domain

import (
	"errors"
	"fmt"
	"slices"
	"strings"
	"time"
	"unicode"
)

// CommitPlaceholders are the placeholders a commit template may use.
var CommitPlaceholders = []string{"number", "key", "type", "scope", "subject", "title"}

// CommitTypes are the Conventional Commits types a commit may have.
var CommitTypes = []string{"feat", "fix", "chore", "refactor", "docs", "test", "perf", "build", "ci", "style", "revert"}

// Caps on what the agent writes for a commit.
const (
	commitScopeMax   = 30
	commitSubjectMax = 100
)

// CommitInfo is what the coding agent says about its change, for the
// commit message: chore(deps): protos v1.63.0, drop local replace.
type CommitInfo struct {
	Type    string `json:"type"`
	Scope   string `json:"scope"`
	Subject string `json:"subject"`
}

// CommitVars are the values a commit template is filled with.
type CommitVars struct {
	Number string // the ticket number (Ticket.Number)
	Key    string
	Title  string     // the ticket title
	Kind   TicketKind // gives the type when the agent gave none
	Info   CommitInfo // the agent's; any part may be empty
}

// CommitType is the commit type of work of kind k.
func (k TicketKind) CommitType() string {
	switch k {
	case KindCode, "":
		return "feat"
	case KindBug:
		return "fix"
	case KindTest:
		return "test"
	}
	return "chore"
}

// ValidateCommitTemplate reports what is wrong with a commit template:
// an unknown placeholder, or no {subject} or {title} to say what changed.
// "" is valid and keeps the default message (KEY: Title).
func ValidateCommitTemplate(tmpl string) error {
	if tmpl == "" {
		return nil
	}
	if err := checkPlaceholders(tmpl, CommitPlaceholders, "commit"); err != nil {
		return err
	}
	if !strings.Contains(tmpl, "{subject}") && !strings.Contains(tmpl, "{title}") {
		return fmt.Errorf("commit template must contain {subject} or {title}")
	}
	if strings.ContainsAny(tmpl, "\r\n") {
		return fmt.Errorf("commit template must be one line")
	}
	return nil
}

// CommitLine fills a commit template into the commit's first line. The
// agent's type, scope and subject are cleaned; a type outside CommitTypes
// gives way to the kind's, a missing subject to the ticket title, and an
// empty scope takes its parentheses with it: [PAY-42] feat: Add login.
func CommitLine(tmpl string, v CommitVars) string {
	typ := strings.ToLower(strings.TrimSpace(v.Info.Type))
	if !slices.Contains(CommitTypes, typ) {
		typ = v.Kind.CommitType()
	}
	scope := commitScope(v.Info.Scope)
	subject := oneLine(v.Info.Subject, commitSubjectMax)
	if subject == "" {
		subject = oneLine(v.Title, commitSubjectMax)
	}
	if scope == "" {
		tmpl = strings.ReplaceAll(tmpl, "({scope})", "")
	}
	r := strings.NewReplacer(
		"{number}", v.Number,
		"{key}", v.Key,
		"{type}", typ,
		"{scope}", scope,
		"{subject}", subject,
		"{title}", oneLine(v.Title, commitSubjectMax),
	)
	return strings.Join(strings.Fields(r.Replace(tmpl)), " ")
}

// commitScope keeps a scope to lowercase letters, digits and - _ / .
func commitScope(s string) string {
	var b strings.Builder
	for _, c := range strings.ToLower(strings.TrimSpace(s)) {
		if c < unicode.MaxASCII && (unicode.IsLetter(c) || unicode.IsDigit(c) || strings.ContainsRune("-_/.", c)) {
			b.WriteRune(c)
		}
	}
	out := b.String()
	if len(out) > commitScopeMax {
		out = out[:commitScopeMax]
	}
	return strings.Trim(out, "-_/.")
}

// oneLine is the first line of s, trimmed, without a trailing period and
// cut to max bytes at a word.
func oneLine(s string, max int) string {
	s, _, _ = strings.Cut(strings.TrimSpace(s), "\n")
	s = strings.TrimRight(strings.TrimSpace(s), ".")
	if len(s) > max {
		cut := s[:max]
		if i := strings.LastIndexByte(cut, ' '); i > 0 {
			cut = cut[:i]
		}
		s = strings.TrimRight(cut, " ,;:")
	}
	return s
}

// BranchCommit is one of the commits agnts made on a ticket's branch and
// has not pushed yet, whose message can still be changed.
type BranchCommit struct {
	SHA     string
	Message string
	When    time.Time // when it was made (its author time)
}

// RunCommit is what a coding run of a ticket said its commit is (the
// summary's commit, empty when it gave none) and when its result was
// saved: agnts commits just before it saves the result.
type RunCommit struct {
	At   time.Time
	Info CommitInfo
}

// MaxCommitMessage caps a commit message a person writes.
const MaxCommitMessage = 10000

// CleanCommitMessage is a person's commit message as it is stored: line
// endings made \n, trailing spaces of each line and blank lines at either
// end dropped. An empty result, or one over MaxCommitMessage bytes, is an
// error.
func CleanCommitMessage(msg string) (string, error) {
	lines := strings.Split(strings.ReplaceAll(msg, "\r\n", "\n"), "\n")
	for i, l := range lines {
		lines[i] = strings.TrimRight(l, " \t\r")
	}
	out := strings.Trim(strings.Join(lines, "\n"), "\n")
	switch {
	case strings.TrimSpace(out) == "":
		return "", errors.New("the commit message is empty")
	case len(out) > MaxCommitMessage:
		return "", fmt.Errorf("the commit message is longer than %d characters", MaxCommitMessage)
	}
	return out, nil
}
