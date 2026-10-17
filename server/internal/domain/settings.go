package domain

import (
	"errors"
	"fmt"
	"regexp"
	"slices"
	"strings"
)

// Models are the model aliases Claude Code accepts.
var Models = []string{"haiku", "sonnet", "opus"}

// codexModel matches a Codex CLI model: "codex:" and the model's name.
var codexModel = regexp.MustCompile(`^codex:[a-z0-9][a-z0-9._-]{0,63}$`)

// ValidModel reports whether m is a Claude model alias or a Codex model.
func ValidModel(m string) bool { return slices.Contains(Models, m) || codexModel.MatchString(m) }

// IsCodex reports whether m runs on Codex CLI.
func IsCodex(m string) bool { return strings.HasPrefix(m, "codex:") }

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

// When the code review runs its specialist passes.
const (
	DeepOff    = "off"
	DeepAuto   = "auto" // large or complex work, the same as the review model's auto
	DeepAlways = "always"
)

// What agnts does when a run looks stuck.
const (
	StallsOff = "off" // nothing
	StallsLog = "log" // note it on the ticket
	StallsAct = "act" // note it, and tell Claude to step back (once per run)
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
	// Progress announces an agent finishing a step (analysis, code), on
	// the phone only.
	Progress bool `json:"progress"`
	Lessons  bool `json:"lessons"`
	Review   bool `json:"review"`  // a code review found something
	Preview  bool `json:"preview"` // screenshots are ready
	// PreviewPhotos sends phone-width screenshots to Telegram with the
	// preview message.
	PreviewPhotos bool `json:"previewPhotos"`
	// FollowUps announces suggested follow-up tickets.
	FollowUps bool `json:"followUps"`
	// CI announces a watched branch going red.
	CI bool `json:"ci"`
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
	// AutoBrief surveys a repository that has no brief when its first
	// ticket is analysed, and again after every BriefRefreshMerges merges.
	AutoBrief bool `json:"autoBrief"`
	// SelfReview sends the blocker and major findings of agnts's own code
	// review back to the coder once per revision, before a person reviews.
	SelfReview bool `json:"selfReview"`
	// Reflect has agnts learn from change requests and rejections: it may
	// suggest rules, which apply only once someone adopts them.
	Reflect bool `json:"reflect"`
	// EgressAllow are hosts run containers may reach besides the built-in
	// list (a staging API for previews); ".domain" matches subdomains.
	EgressAllow []string `json:"egressAllow"`
	// SuggestFollowUps has the runs suggest follow-up tickets. Off by
	// default: it makes every prompt and answer a little longer.
	SuggestFollowUps bool `json:"suggestFollowUps"`
	// PullReviews: agnts reviews the pull requests waiting for you.
	PullReviews PullReviewSettings `json:"pullReviews"`
	// PRComments: how agnts takes part in pull request conversations.
	PRComments PRCommentSettings `json:"prComments"`
	// CI: agnts watches CI pipelines and fixes what fails.
	CI CISettings `json:"ci"`
	// Guard: how strict agnts-guard, the hooks inside every run, is.
	Guard GuardSettings `json:"guard"`
	// SecondOpinion is the model ("codex:<model>", or a Claude model) that
	// critiques the chosen approach of complex tickets; "" turns it off.
	SecondOpinion string `json:"secondOpinion"`
	// LearnFromRuns has agnts read runs that had trouble (failed checks,
	// a stall) and suggest tips for the repository.
	LearnFromRuns bool `json:"learnFromRuns"`
	// DeepReview runs specialist passes (security, silent failures, tests,
	// types and data) in the code review: DeepOff, DeepAuto (large or
	// complex work) or DeepAlways.
	DeepReview string `json:"deepReview"`
	// ProveFixes asks bug-fix tickets for a test that fails before the
	// change and passes after it, and checks it.
	ProveFixes bool `json:"proveFixes"`
	// MethodSkills gives coding runs agnts's method skills (package
	// skillpacks): how to add one more of something, follow the house
	// style, reuse before writing, change a schema safely.
	MethodSkills bool `json:"methodSkills"`
	// Stalls: what agnts does when a run looks stuck (StallsOff, StallsLog
	// or StallsAct).
	Stalls string `json:"stalls"`
	// MaxTicketRepos caps how many repositories one ticket (and one
	// repository group) may have; 0 means DefaultMaxTicketRepos.
	MaxTicketRepos int            `json:"maxTicketRepos"`
	PauseAbove     int            `json:"pauseAbove"`
	Parallel       int            `json:"parallel"`
	Git            GitSettings    `json:"git"`
	Notify         NotifySettings `json:"notify"`
}

// DefaultSettings returns the settings used before any are saved.
func DefaultSettings() Settings {
	return Settings{
		Models:        StageModels{Analyze: "sonnet", Coding: "opus", Retry: "sonnet", Helper: "haiku", Learn: "sonnet", Review: ModelAuto, Preview: "sonnet"},
		MaxTurns:      150,
		TimeoutMin:    45,
		Allow:         []string{},
		Deny:          []string{},
		AskFirst:      true,
		AutoResume:    true,
		AutoLearn:     true,
		AutoReview:    true,
		AutoPreview:   true,
		VisualCheck:   true,
		AutoBrief:     true,
		SelfReview:    true,
		Reflect:       true,
		EgressAllow:   []string{},
		PullReviews:   DefaultPullReviewSettings(),
		PRComments:    DefaultPRCommentSettings(),
		CI:            DefaultCISettings(),
		Guard:         GuardSettings{Profile: GuardStandard, Disabled: []string{}, FactCheck: 50},
		Stalls:        StallsLog,
		ProveFixes:    true,
		DeepReview:    DeepAuto,
		LearnFromRuns: true,
		PauseAbove:    90,
		Parallel:      1,

		MaxTicketRepos: DefaultMaxTicketRepos,
		Git:            GitSettings{CoAuthor: true, PRTitle: "{key}: {title}"},
		Notify:         NotifySettings{Push: true, Telegram: true, NeedsYou: true, Stopped: true, Done: true, Progress: true, Lessons: true, Review: true, Preview: true, PreviewPhotos: true, FollowUps: true, CI: true},
	}
}

// TicketRepoLimit is how many repositories a ticket may have.
func (s Settings) TicketRepoLimit() int {
	if s.MaxTicketRepos <= 0 {
		return DefaultMaxTicketRepos
	}
	return s.MaxTicketRepos
}

// TurnScale is how much more room (turns) a ticket in n repositories gets:
// half as much again for two or three, twice as much for more.
func TurnScale(n int) float64 {
	switch {
	case n <= 1:
		return 1
	case n <= 3:
		return 1.5
	}
	return 2
}

// Validate checks ranges and normalises lists.
func (s *Settings) Validate() error {
	var errs []error
	if s.MaxTicketRepos < 0 || s.MaxTicketRepos > 20 {
		errs = append(errs, fmt.Errorf("a ticket may have 1 to 20 repositories"))
	}
	for name, m := range map[string]string{"analyze": s.Models.Analyze, "coding": s.Models.Coding, "retry": s.Models.Retry, "helper": s.Models.Helper, "learn": s.Models.Learn, "preview": s.Models.Preview} {
		if !ValidModel(m) {
			errs = append(errs, fmt.Errorf("model for %s must be one of %s, or codex:<model>", name, strings.Join(Models, ", ")))
		}
	}
	if s.Models.Review != ModelAuto && !ValidModel(s.Models.Review) {
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
	if s.PullReviews.MergeMethod == "" {
		s.PullReviews.MergeMethod = "merge"
	}
	if !slices.Contains(MergeMethods, s.PullReviews.MergeMethod) {
		errs = append(errs, fmt.Errorf("merge method must be one of %s", strings.Join(MergeMethods, ", ")))
	}
	if err := s.CI.Validate(); err != nil {
		errs = append(errs, err)
	}
	if err := s.Guard.Validate(); err != nil {
		errs = append(errs, err)
	}
	if s.SecondOpinion != "" && !ValidModel(s.SecondOpinion) {
		errs = append(errs, fmt.Errorf("second opinion must be empty, one of %s, or codex:<model>", strings.Join(Models, ", ")))
	}
	if s.DeepReview == "" {
		s.DeepReview = DeepAuto
	}
	if !slices.Contains([]string{DeepOff, DeepAuto, DeepAlways}, s.DeepReview) {
		errs = append(errs, fmt.Errorf("deep review must be %s, %s or %s", DeepOff, DeepAuto, DeepAlways))
	}
	if s.Stalls == "" {
		s.Stalls = StallsLog
	}
	if !slices.Contains([]string{StallsOff, StallsLog, StallsAct}, s.Stalls) {
		errs = append(errs, fmt.Errorf("stalls must be %s, %s or %s", StallsOff, StallsLog, StallsAct))
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
	if m := t.Models[stage]; ValidModel(m) {
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
