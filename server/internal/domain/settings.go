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
	ModelLearn   = "learn" // lessons from finished tickets
)

// StageModels is the default model per stage.
type StageModels struct {
	Analyze string `json:"analyze"`
	Coding  string `json:"coding"`
	Retry   string `json:"retry"`
	Helper  string `json:"helper"`
	Learn   string `json:"learn"`
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
}

// Settings are the runtime settings edited on the Settings page.
type Settings struct {
	Models     StageModels    `json:"models"`
	MaxTurns   int            `json:"maxTurns"`
	TimeoutMin int            `json:"timeoutMin"`
	Allow      []string       `json:"allow"`
	Deny       []string       `json:"deny"`
	AskFirst   bool           `json:"askFirst"`
	AutoResume bool           `json:"autoResume"`
	AutoLearn  bool           `json:"autoLearn"` // learn run after every push
	PauseAbove int            `json:"pauseAbove"`
	Parallel   int            `json:"parallel"`
	Git        GitSettings    `json:"git"`
	Notify     NotifySettings `json:"notify"`
}

// DefaultSettings returns the settings used before any are saved.
func DefaultSettings() Settings {
	return Settings{
		Models:     StageModels{Analyze: "sonnet", Coding: "opus", Retry: "sonnet", Helper: "haiku", Learn: "sonnet"},
		MaxTurns:   150,
		TimeoutMin: 45,
		Allow:      []string{},
		Deny:       []string{},
		AskFirst:   true,
		AutoResume: true,
		AutoLearn:  true,
		PauseAbove: 90,
		Parallel:   1,
		Git:        GitSettings{CoAuthor: true, PRTitle: "{key}: {title}"},
		Notify:     NotifySettings{Push: true, Telegram: true, NeedsYou: true, Stopped: true, Done: true, Lessons: true},
	}
}

// Validate checks ranges and normalises lists.
func (s *Settings) Validate() error {
	var errs []error
	for name, m := range map[string]string{"analyze": s.Models.Analyze, "coding": s.Models.Coding, "retry": s.Models.Retry, "helper": s.Models.Helper, "learn": s.Models.Learn} {
		if !slices.Contains(Models, m) {
			errs = append(errs, fmt.Errorf("model for %s must be one of %s", name, strings.Join(Models, ", ")))
		}
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
	if s.Git.PRTitle == "" {
		s.Git.PRTitle = "{key}: {title}"
	}
	if s.Git.AuthorEmail != "" && !strings.Contains(s.Git.AuthorEmail, "@") {
		errs = append(errs, errors.New("git author email is not an email address"))
	}
	return errors.Join(errs...)
}

// ModelFor returns the model for a stage, honouring a ticket's override.
func (s Settings) ModelFor(t Ticket, stage string) string {
	if m := t.Models[stage]; slices.Contains(Models, m) {
		return m
	}
	return s.Models.For(stage)
}
