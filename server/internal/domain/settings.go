package domain

import (
	"errors"
	"fmt"
	"slices"
	"strings"
)

// Models are the model aliases Claude Code accepts.
var Models = []string{"haiku", "sonnet", "opus"}

// Model stages a user can pick a model for.
const (
	ModelAnalyze = "analyze"
	ModelCoding  = "coding"
	ModelRetry   = "retry" // fix attempts and requested changes
	ModelHelper  = "helper"
	ModelLearn   = "learn"   // lessons from finished tickets
	ModelReview  = "review"  // code review while a ticket waits for review
	ModelPreview = "preview" // screenshots while a ticket waits for review
)

// ModelAuto lets agnts pick the review model from how complex the ticket is.
const ModelAuto = "auto"

// StageModels is the default model per stage.
type StageModels struct {
	Analyze string `json:"analyze"`
	Coding  string `json:"coding"`
	Retry   string `json:"retry"`
	Helper  string `json:"helper"`
	Learn   string `json:"learn"`
	Review  string `json:"review"` // a model or ModelAuto
	Preview string `json:"preview"`
}

// For returns the model for a stage name.
func (m StageModels) For(stage string) string {
	switch stage {
	case ModelAnalyze:
		return m.Analyze
	case ModelRetry:
		return m.Retry
	case ModelHelper:
		return m.Helper
	case ModelLearn:
		return m.Learn
	case ModelReview:
		return m.Review
	case ModelPreview:
		return m.Preview
	default:
		return m.Coding
	}
}

// GitSettings controls commits and pull requests.
type GitSettings struct {
	AuthorName  string `json:"authorName"`
	AuthorEmail string `json:"authorEmail"`
	CoAuthor    bool   `json:"coAuthor"`
	PRTitle     string `json:"prTitle"`
	Draft       bool   `json:"draft"`
}

// NotifySettings says which events reach the phone and Telegram.
type NotifySettings struct {
	Push     bool `json:"push"`
	Telegram bool `json:"telegram"`
	NeedsYou bool `json:"needsYou"`
	Stopped  bool `json:"stopped"`
	Done     bool `json:"done"`
	Lessons  bool `json:"lessons"`
	Review   bool `json:"review"`  // a code review found something
	Preview  bool `json:"preview"` // screenshots are ready
	// PreviewPhotos sends phone-width screenshots to Telegram with the
	// preview message.
	PreviewPhotos bool `json:"previewPhotos"`
	// FollowUps announces suggested follow-up tickets.
	FollowUps bool `json:"followUps"`
}

// Settings are the runtime settings edited on the Settings page.
type Settings struct {
	Models     StageModels `json:"models"`
	MaxTurns   int         `json:"maxTurns"`
	TimeoutMin int         `json:"timeoutMin"`
	Allow      []string    `json:"allow"`
	Deny       []string    `json:"deny"`
	AskFirst   bool        `json:"askFirst"`
	AutoResume bool        `json:"autoResume"`
	AutoLearn  bool        `json:"autoLearn"`  // learn run after every push
	AutoReview bool        `json:"autoReview"` // code review of every result
	// AutoPreview takes screenshots of every UI change in a repository
	// with a preview command.
	AutoPreview bool `json:"autoPreview"`
	// VisualCheck lets coding runs start the app and look at the pages they
	// changed, in repositories with a preview command.
	VisualCheck bool `json:"visualCheck"`
	// EgressAllow are hosts run containers may reach besides the built-in
	// list (a staging API for previews); ".domain" matches subdomains.
	EgressAllow []string `json:"egressAllow"`
	// SuggestFollowUps has the runs suggest follow-up tickets. Off by
	// default: it makes every prompt and answer a little longer.
	SuggestFollowUps bool           `json:"suggestFollowUps"`
	PauseAbove       int            `json:"pauseAbove"`
	Parallel         int            `json:"parallel"`
	Git              GitSettings    `json:"git"`
	Notify           NotifySettings `json:"notify"`
}

// DefaultSettings returns the settings used before any are saved.
func DefaultSettings() Settings {
	return Settings{
		Models:      StageModels{Analyze: "sonnet", Coding: "opus", Retry: "sonnet", Helper: "haiku", Learn: "sonnet", Review: ModelAuto, Preview: "sonnet"},
		MaxTurns:    150,
		TimeoutMin:  45,
		Allow:       []string{},
		Deny:        []string{},
		AskFirst:    true,
		AutoResume:  true,
		AutoLearn:   true,
		AutoReview:  true,
		AutoPreview: true,
		VisualCheck: true,
		EgressAllow: []string{},
		PauseAbove:  90,
		Parallel:    1,
		Git:         GitSettings{CoAuthor: true, PRTitle: "{key}: {title}"},
		Notify:      NotifySettings{Push: true, Telegram: true, NeedsYou: true, Stopped: true, Done: true, Lessons: true, Review: true, Preview: true, PreviewPhotos: true, FollowUps: true},
	}
}

// Validate checks ranges and normalises lists.
func (s *Settings) Validate() error {
	var errs []error
	for name, m := range map[string]string{"analyze": s.Models.Analyze, "coding": s.Models.Coding, "retry": s.Models.Retry, "helper": s.Models.Helper, "learn": s.Models.Learn, "preview": s.Models.Preview} {
		if !slices.Contains(Models, m) {
			errs = append(errs, fmt.Errorf("model for %s must be one of %s", name, strings.Join(Models, ", ")))
		}
	}
	if s.Models.Review != ModelAuto && !slices.Contains(Models, s.Models.Review) {
		errs = append(errs, fmt.Errorf("model for review must be %s or one of %s", ModelAuto, strings.Join(Models, ", ")))
	}
	check := func(name string, v, lo, hi int) {
		if v < lo || v > hi {
			errs = append(errs, fmt.Errorf("%s must be between %d and %d", name, lo, hi))
		}
	}
	check("maxTurns", s.MaxTurns, 20, 200)
	check("timeoutMin", s.TimeoutMin, 10, 120)
	check("pauseAbove", s.PauseAbove, 50, 100)
	check("parallel", s.Parallel, 1, 3)
	clean := func(in []string) []string {
		out := []string{}
		for _, c := range in {
			if c = strings.TrimSpace(c); c != "" && !slices.Contains(out, c) {
				out = append(out, c)
			}
		}
		return out
	}
	s.Allow, s.Deny = clean(s.Allow), clean(s.Deny)
	s.EgressAllow = clean(s.EgressAllow)
	for i, h := range s.EgressAllow {
		h = strings.ToLower(strings.TrimPrefix(h, "*"))
		s.EgressAllow[i] = h
		if !validHost(h) {
			errs = append(errs, fmt.Errorf("allowed host %q is not a host name (use example.com or .example.com)", h))
		}
	}
	if s.Git.PRTitle == "" {
		s.Git.PRTitle = "{key}: {title}"
	}
	if s.Git.AuthorEmail != "" && !strings.Contains(s.Git.AuthorEmail, "@") {
		errs = append(errs, errors.New("git author email is not an email address"))
	}
	return errors.Join(errs...)
}

// FollowUpsOn reports whether runs of t suggest follow-up tickets: the
// ticket's own choice wins over the setting.
func (s Settings) FollowUpsOn(t Ticket) bool {
	if t.SuggestFollowUps != nil {
		return *t.SuggestFollowUps
	}
	return s.SuggestFollowUps
}

// ModelFor returns the model for a stage, honouring a ticket's override.
func (s Settings) ModelFor(t Ticket, stage string) string {
	if m := t.Models[stage]; slices.Contains(Models, m) {
		return m
	}
	return s.Models.For(stage)
}

// validHost reports whether h is a host name, optionally with a leading
// dot for its subdomains. IP addresses and ports are not allowed.
func validHost(h string) bool {
	h = strings.TrimPrefix(h, ".")
	if h == "" || len(h) > 253 || !strings.Contains(h, ".") {
		return false
	}
	for _, label := range strings.Split(h, ".") {
		if label == "" || len(label) > 63 || strings.HasPrefix(label, "-") || strings.HasSuffix(label, "-") {
			return false
		}
		for _, c := range label {
			if (c < 'a' || c > 'z') && (c < '0' || c > '9') && c != '-' {
				return false
			}
		}
	}
	last := h[strings.LastIndex(h, ".")+1:]
	return strings.ContainsFunc(last, func(c rune) bool { return c >= 'a' && c <= 'z' })
}
