package domain

import (
	"cmp"
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

// ValidModel reports whether m names a model of any provider: a Claude
// alias, codex:<model> or muse:<model>.
func ValidModel(m string) bool {
	return slices.Contains(Models, m) || codexModel.MatchString(m) || museModel.MatchString(m)
}

// AllowedModel reports whether a person with access a may pick m: a valid
// model of a module they may use.
func AllowedModel(a Access, m string) bool { return ValidModel(m) && a.Allows(ProviderOf(m)) }

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
	// ModelRecheck re-checks a complex ticket's analysis; it is the
	// coding model, so nobody picks it on its own.
	ModelRecheck = "recheck"
)

// How hard Claude Code thinks (its --effort); "" leaves its default.
const (
	EffortLow    = "low"
	EffortMedium = "medium"
	EffortHigh   = "high"
)

// Efforts are the effort levels a setting may name.
var Efforts = []string{"", EffortLow, EffortMedium, EffortHigh}

// EffortSettings is how hard runs think, by stage. Complex raises the
// coding and review of tickets their analysis rated complex, and the
// re-check of that analysis (RecheckComplex).
type EffortSettings struct {
	Analyze string `json:"analyze"`
	Coding  string `json:"coding"`
	Review  string `json:"review"`
	Complex string `json:"complex"`
}

// For returns the effort of a model stage, for a complex ticket or not.
func (e EffortSettings) For(stage string, complex bool) string {
	var v string
	switch stage {
	case ModelAnalyze:
		v = e.Analyze
	case ModelCoding, ModelRetry:
		v = e.Coding
	case ModelReview:
		v = e.Review
	case ModelRecheck:
		return cmp.Or(e.Complex, e.Analyze)
	default:
		return ""
	}
	if complex && e.Complex != "" && stage != ModelAnalyze {
		return e.Complex
	}
	return v
}

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
	// Access is the person the settings were read for (For); zero for
	// settings as stored. It is never saved.
	Access Access `json:"-"`

	Models   StageModels `json:"models"`
	MaxTurns int         `json:"maxTurns"`
	// RunBudget is the most one run on credits may spend, in credits
	// (1 credit = $0.01); 0 leaves the server's cap per run.
	RunBudget  int64    `json:"runBudget"`
	TimeoutMin int      `json:"timeoutMin"`
	Allow      []string `json:"allow"`
	Deny       []string `json:"deny"`
	AskFirst   bool     `json:"askFirst"`
	AutoResume bool     `json:"autoResume"`
	// SwitchModules lets a call whose module cannot run (no usable
	// account, its limit reached, not enabled for the person) run on the
	// person's next module, on the model of the same tier. Off: it waits
	// for its own module.
	SwitchModules bool `json:"switchModules"`
	AutoLearn     bool `json:"autoLearn"`  // learn run after every push
	AutoReview    bool `json:"autoReview"` // code review of every result
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
	// PublicDocuments lets documents have public links. Turning it off
	// makes every public link of the workspace stop working, without
	// changing the documents.
	PublicDocuments bool `json:"publicDocuments"`
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
	// Effort is how hard runs think (Claude Code's --effort).
	Effort EffortSettings `json:"effort"`
	// RecheckComplex has the coding model re-check the analysis of a ticket
	// the analysis model rated complex, before any code is written.
	RecheckComplex bool `json:"recheckComplex"`
	// BaselineChecks runs the checks on the commit a ticket starts from
	// before its first coding run: failures there are not the ticket's.
	BaselineChecks bool `json:"baselineChecks"`
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
	// Meetings: recording, retention and limits of the workspace's calls.
	Meetings MeetingSettings `json:"meetings"`
}

// MeetingSettings are a workspace's rules for meetings.
type MeetingSettings struct {
	// AllowRecording lets hosts record calls as video.
	AllowRecording bool `json:"allowRecording"`
	// RetentionDays is how long recordings, notes audio and transcripts
	// are kept, 0 for ever.
	RetentionDays int `json:"retentionDays"`
	// KeepAudio keeps the audio of notes after it is transcribed.
	KeepAudio bool `json:"keepAudio"`
	// MaxParticipants caps the people in one call.
	MaxParticipants int `json:"maxParticipants"`
}

// DefaultMeetingSettings are the settings before any are saved.
func DefaultMeetingSettings() MeetingSettings {
	return MeetingSettings{AllowRecording: true, RetentionDays: 90, MaxParticipants: 50}
}

// Validate checks the ranges.
func (m MeetingSettings) Validate() error {
	switch {
	case m.RetentionDays < 0 || m.RetentionDays > 3650:
		return errors.New("meeting retention must be between 0 and 3650 days")
	case m.MaxParticipants < 2 || m.MaxParticipants > 100:
		return errors.New("people in one call must be between 2 and 100")
	}
	return nil
}

// defaultModels are a's default module's models per stage. On Muse,
// every stage starts on Spark: the review's auto choice and a stuck
// session's escalation move hard work to Wonder.
func defaultModels(a Access) StageModels {
	if a.Primary() == ProviderMuse {
		return StageModels{Analyze: MuseSpark, Coding: MuseSpark, Retry: MuseSpark, Helper: MuseSpark, Learn: MuseSpark, Review: ModelAuto, Preview: MuseSpark}
	}
	return StageModels{Analyze: "sonnet", Coding: "opus", Retry: "sonnet", Helper: "haiku", Learn: "sonnet", Review: ModelAuto, Preview: "sonnet"}
}

// DefaultSettings returns the settings used before any are saved.
func DefaultSettings() Settings {
	return Settings{
		Models:          defaultModels(DefaultAccess()),
		MaxTurns:        150,
		TimeoutMin:      45,
		Allow:           []string{},
		Deny:            []string{},
		AskFirst:        true,
		AutoResume:      true,
		SwitchModules:   true,
		AutoLearn:       true,
		AutoReview:      true,
		AutoPreview:     true,
		VisualCheck:     true,
		AutoBrief:       true,
		PublicDocuments: true,
		SelfReview:      true,
		Reflect:         true,
		EgressAllow:     []string{},
		PullReviews:     DefaultPullReviewSettings(),
		PRComments:      DefaultPRCommentSettings(),
		CI:              DefaultCISettings(),
		Guard:           GuardSettings{Profile: GuardStandard, Disabled: []string{}, FactCheck: 50},
		Stalls:          StallsLog,
		ProveFixes:      true,
		DeepReview:      DeepAuto,
		LearnFromRuns:   true,
		Effort:          EffortSettings{Complex: EffortHigh},
		RecheckComplex:  true,
		BaselineChecks:  true,
		PauseAbove:      90,
		Parallel:        1,

		MaxTicketRepos: DefaultMaxTicketRepos,
		Git:            GitSettings{CoAuthor: true, PRTitle: "{key}: {title}"},
		Notify:         NotifySettings{Push: true, Telegram: true, NeedsYou: true, Stopped: true, Done: true, Progress: true, Lessons: true, Review: true, Preview: true, PreviewPhotos: true, FollowUps: true, CI: true},
		Meetings:       DefaultMeetingSettings(),
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
	// Which modules a person may pick from is CheckModels: here any model
	// agnts can run is valid, so settings saved by someone with other
	// modules stay valid.
	for name, m := range map[string]string{"analyze": s.Models.Analyze, "coding": s.Models.Coding, "retry": s.Models.Retry, "helper": s.Models.Helper, "learn": s.Models.Learn, "preview": s.Models.Preview} {
		if !ValidModel(m) {
			errs = append(errs, fmt.Errorf("model for %s must be one of %s, muse:<model> or codex:<model>", name, strings.Join(Models, ", ")))
		}
	}
	if s.Models.Review != ModelAuto && !ValidModel(s.Models.Review) {
		errs = append(errs, fmt.Errorf("model for review must be %s, one of %s, muse:<model> or codex:<model>", ModelAuto, strings.Join(Models, ", ")))
	}
	check := func(name string, v, lo, hi int) {
		if v < lo || v > hi {
			errs = append(errs, fmt.Errorf("%s must be between %d and %d", name, lo, hi))
		}
	}
	check("maxTurns", s.MaxTurns, 20, 200)
	if s.RunBudget < 0 || s.RunBudget > 1_000_000 {
		errs = append(errs, fmt.Errorf("budget per run must be between 0 and 1000000 credits"))
	}
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
	for name, v := range map[string]string{"analyze": s.Effort.Analyze, "coding": s.Effort.Coding, "review": s.Effort.Review, "complex": s.Effort.Complex} {
		if !slices.Contains(Efforts, v) {
			errs = append(errs, fmt.Errorf("effort for %s must be empty, %s, %s or %s", name, EffortLow, EffortMedium, EffortHigh))
		}
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
	if err := s.Meetings.Validate(); err != nil {
		errs = append(errs, err)
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

// ModelFor returns the model for a stage, honouring a ticket's override,
// mapped to the modules of the person the settings were read for.
func (s Settings) ModelFor(t Ticket, stage string) string {
	if m := t.Models[stage]; ValidModel(m) {
		return EffectiveModel(s.Access, m)
	}
	return EffectiveModel(s.Access, s.Models.For(stage))
}

// For returns the settings as they apply to runs of a person with access
// a: models of modules they may not use map to their own (EffectiveModel).
// A workspace that never saved its settings has the defaults of the
// default access when the server started, mapped the same way.
func (s Settings) For(a Access) Settings {
	s.Access = Access{Modules: slices.Clone(a.Modules)}
	s.Models = s.Models.EffectiveModels(a)
	s.SecondOpinion = EffectiveModel(a, s.SecondOpinion)
	return s
}

// Modules returns the modules runs of these settings may use for a ticket
// with model overrides models (nil: none): every stage's, the second
// opinion's, and the default module's, which the review's auto choice and
// helpers use. Settings must be For a person.
func (s Settings) Modules(models map[string]string) []string {
	out := []string{}
	add := func(m string) {
		if m == "" || m == ModelAuto {
			return
		}
		if p := ProviderOf(m); !slices.Contains(out, p) {
			out = append(out, p)
		}
	}
	if p := s.Access.Primary(); p != "" {
		out = append(out, p)
	}
	for _, stage := range []string{ModelAnalyze, ModelCoding, ModelRetry, ModelHelper, ModelLearn, ModelReview, ModelPreview} {
		add(s.ModelFor(Ticket{Models: models}, stage))
	}
	add(s.SecondOpinion)
	return out
}

// CheckModels checks the models a person with access a changed from prev:
// each must be of a module they may use. Models they left alone are kept
// even when they cannot use them (someone else chose them).
func (s Settings) CheckModels(a Access, prev Settings) error {
	var errs []error
	allowed := strings.Join(AvailableModels(a), ", ")
	if a.Allows(ProviderCodex) {
		allowed += ", codex:<model>"
	}
	check := func(name, m, was string, auto bool) {
		if m == was || (auto && m == ModelAuto) || AllowedModel(a, m) {
			return
		}
		errs = append(errs, fmt.Errorf("model for %s must be one of %s: %s is not enabled for you", name, allowed, ModuleName(ProviderOf(m))))
	}
	check("analyze", s.Models.Analyze, prev.Models.Analyze, false)
	check("coding", s.Models.Coding, prev.Models.Coding, false)
	check("retry", s.Models.Retry, prev.Models.Retry, false)
	check("helper", s.Models.Helper, prev.Models.Helper, false)
	check("learn", s.Models.Learn, prev.Models.Learn, false)
	check("review", s.Models.Review, prev.Models.Review, true)
	check("preview", s.Models.Preview, prev.Models.Preview, false)
	if s.SecondOpinion != "" {
		check("second opinion", s.SecondOpinion, prev.SecondOpinion, false)
	}
	return errors.Join(errs...)
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
