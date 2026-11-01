package domain

import (
	"errors"
	"fmt"
	"slices"
	"strings"
	"time"
)

// SourceLogs is a ticket agnts opened for something it found in a
// project's logs.
const SourceLogs TicketSource = "logs"

// LogKind is the kind of logging system a log source reads from.
type LogKind string

// Log source kinds. Push sources have no address: the user's log shipper
// sends to agnts.
const (
	LogLoki          LogKind = "loki"
	LogElasticsearch LogKind = "elasticsearch"
	LogOpenSearch    LogKind = "opensearch"
	LogGraylog       LogKind = "graylog"
	LogDatadog       LogKind = "datadog"
	LogCloudWatch    LogKind = "cloudwatch"
	LogSplunk        LogKind = "splunk"
	LogPush          LogKind = "push"
)

// LogKinds lists the kinds agnts can read.
var LogKinds = []LogKind{LogLoki, LogElasticsearch, LogOpenSearch, LogGraylog, LogDatadog, LogCloudWatch, LogSplunk, LogPush}

// Valid reports whether k is a known kind.
func (k LogKind) Valid() bool { return slices.Contains(LogKinds, k) }

// Pulls reports whether agnts reads from the source (it has an address),
// as opposed to the source pushing to agnts.
func (k LogKind) Pulls() bool { return k.Valid() && k != LogPush }

// Environments a log source may be in. Production-only detectors (debug
// mode) apply to production sources only.
var LogEnvironments = []string{"production", "staging", "development"}

// Poll interval bounds and default, in seconds.
const (
	LogPollDefault = 15
	LogPollMin     = 5
	LogPollMax     = 300
)

// LogSourceStatus is how reading a source goes.
type LogSourceStatus string

// Log source statuses.
const (
	LogSourceNew        LogSourceStatus = "new"         // never read yet
	LogSourceOK         LogSourceStatus = "ok"          // reading
	LogSourceBehind     LogSourceStatus = "behind"      // more logs than the caps allow
	LogSourceFailing    LogSourceStatus = "failing"     // errors; retried with backoff
	LogSourceAuthFailed LogSourceStatus = "auth_failed" // credentials rejected; stopped until saved again
)

// LogAuth are the credentials agnts reads a source with. Kind is "none",
// "basic", "bearer", "apikey" or "aws" (CloudWatch: the access key id as
// User, the secret as Password, a session token as Tenant). Datadog takes
// the API key as Token and the application key as Password. They are
// sealed at rest and never returned by the API.
type LogAuth struct {
	Kind     string `json:"kind"`
	User     string `json:"user,omitempty"`
	Password string `json:"password,omitempty"`
	Token    string `json:"token,omitempty"`
	// Tenant is Loki's X-Scope-OrgID.
	Tenant string `json:"tenant,omitempty"`
}

// LogAuthKinds lists the auth kinds.
var LogAuthKinds = []string{"none", "basic", "bearer", "apikey", "aws"}

// LogFields name where a source keeps the parts of an entry. Empty fields
// are detected (Test connection) or fall back to the usual names.
type LogFields struct {
	Message   string `json:"message,omitempty"`
	Timestamp string `json:"timestamp,omitempty"`
	Level     string `json:"level,omitempty"`
	Service   string `json:"service,omitempty"`
	Revision  string `json:"revision,omitempty"`
}

// LogScope narrows what a source reads: a Loki base selector, an
// Elasticsearch index pattern, Graylog streams.
type LogScope struct {
	Selector string   `json:"selector,omitempty"` // Loki: {env="prod"}
	Index    string   `json:"index,omitempty"`    // ES/OpenSearch: logs-*
	Streams  []string `json:"streams,omitempty"`  // Graylog stream ids
}

// LogCursor is where a source was last read up to. Its fields mean what
// the connector says; it is stored as it is.
type LogCursor struct {
	// Time is the newest entry's time read so far.
	Time time.Time `json:"time,omitempty"`
	// Seen are keys (hashes, ids) of the entries at Time already read, so
	// a poll starting at Time skips them.
	Seen []string `json:"seen,omitempty"`
	// After is the Elasticsearch search_after of the last hit.
	After []any `json:"after,omitempty"`
}

// LogSource is a logging system agnts reads, or a push token it accepts.
type LogSource struct {
	ID          int64
	WorkspaceID int64
	Name        string
	Kind        LogKind
	Environment string
	Address     string
	// Auth is filled only where the credentials are needed (the reader);
	// HasAuth says whether any are saved.
	Auth        LogAuth
	HasAuth     bool
	CAPEM       string
	Scope       LogScope
	Fields      LogFields
	PollSeconds int
	Enabled     bool
	Cursor      LogCursor
	Status      LogSourceStatus
	LastError   string
	LastReadAt  *time.Time
	// Gap is the time range that could not be read after a long outage.
	GapFrom, GapTo *time.Time
	// Dropped counts entries over the caps since the source was saved.
	Dropped   int64
	NetworkID *int64
	// HasPushToken: a push source has a token (it is shown once).
	HasPushToken bool
	CreatedAt    time.Time
	Services     []LogService
}

// Normalize trims the source and checks it.
func (s *LogSource) Normalize() error {
	s.Name = strings.TrimSpace(s.Name)
	s.Address = strings.TrimRight(strings.TrimSpace(s.Address), "/")
	s.Environment = strings.TrimSpace(s.Environment)
	if s.Environment == "" {
		s.Environment = "production"
	}
	if s.PollSeconds == 0 {
		s.PollSeconds = LogPollDefault
	}
	if s.Auth.Kind == "" {
		s.Auth.Kind = "none"
	}
	var errs []error
	if s.Name == "" || len([]rune(s.Name)) > 80 {
		errs = append(errs, errors.New("name must be 1 to 80 characters"))
	}
	if !s.Kind.Valid() {
		errs = append(errs, fmt.Errorf("kind must be one of %s", joinKinds()))
	}
	if !slices.Contains(LogEnvironments, s.Environment) {
		errs = append(errs, fmt.Errorf("environment must be one of %s", strings.Join(LogEnvironments, ", ")))
	}
	if s.PollSeconds < LogPollMin || s.PollSeconds > LogPollMax {
		errs = append(errs, fmt.Errorf("poll interval must be between %d and %d seconds", LogPollMin, LogPollMax))
	}
	if !slices.Contains(LogAuthKinds, s.Auth.Kind) {
		errs = append(errs, fmt.Errorf("auth must be one of %s", strings.Join(LogAuthKinds, ", ")))
	}
	if s.Kind.Pulls() {
		if s.Address == "" {
			errs = append(errs, errors.New("address is required"))
		} else if !strings.HasPrefix(s.Address, "https://") && !strings.HasPrefix(s.Address, "http://") {
			errs = append(errs, errors.New("address must start with https:// or http://"))
		}
	} else {
		s.Address = ""
	}
	if s.CAPEM = strings.TrimSpace(s.CAPEM); s.CAPEM != "" && !strings.Contains(s.CAPEM, "BEGIN CERTIFICATE") {
		errs = append(errs, errors.New("CA certificate must be PEM"))
	}
	return errors.Join(errs...)
}

func joinKinds() string {
	out := make([]string, len(LogKinds))
	for i, k := range LogKinds {
		out[i] = string(k)
	}
	return strings.Join(out, ", ")
}

// LogService is one service of a source: what selects its entries and
// the repositories it runs on. No repositories: its findings are reported
// and never become tickets.
type LogService struct {
	ID       int64
	SourceID int64
	Name     string
	// Selector is the connector's filter: a LogQL matcher, an
	// Elasticsearch term value, a Graylog stream id or query.
	Selector string
	RepoIDs  []int64
	GroupID  *int64
	Enabled  bool
}

// Scope is the key findings of this service are grouped under:
// repos:<sorted ids>, or svc:<source>/<name> without repositories.
func (s LogService) Scope() string { return LogScopeKey(s.SourceID, s.Name, s.RepoIDs) }

// LogScopeKey is the grouping key of findings: the same bug through two
// sources of a service with the same repositories is one finding.
func LogScopeKey(sourceID int64, service string, repos []int64) string {
	if len(repos) == 0 {
		return fmt.Sprintf("svc:%d/%s", sourceID, service)
	}
	ids := slices.Clone(repos)
	slices.Sort(ids)
	ids = slices.Compact(ids)
	parts := make([]string, len(ids))
	for i, id := range ids {
		parts[i] = fmt.Sprint(id)
	}
	return "repos:" + strings.Join(parts, ",")
}

// LogEntry is one entry as a connector or a push returns it. Message is
// raw: it may be JSON, and may hold several lines.
type LogEntry struct {
	Time     time.Time
	Service  string
	Stream   string // what keeps entries of one producer together (labels, container)
	Level    string // from the backend's field, when it has one
	Revision string
	Message  string
	// Key identifies the entry for the cursor's de-duplication.
	Key string
}

// LogCategory is what kind of problem a finding is.
type LogCategory string

// Categories.
const (
	LogErrors   LogCategory = "error"
	LogSecurity LogCategory = "security"
)

// LogClass is what the cause is.
type LogClass string

// Classes. Ticket-able ones can be fixed in code.
const (
	LogClassCode       LogClass = "code"
	LogClassConfig     LogClass = "config"
	LogClassInfra      LogClass = "infra"
	LogClassDependency LogClass = "dependency"
	LogClassLeak       LogClass = "leak"
	LogClassExposure   LogClass = "exposure"
	LogClassWeakness   LogClass = "weakness"
	LogClassAttack     LogClass = "attack"
	LogClassNoise      LogClass = "noise"
)

// Ticketable reports whether a finding of this class may become a ticket
// on its own (attack findings only after they repeat: see the policy).
func (c LogClass) Ticketable() bool {
	switch c {
	case LogClassCode, LogClassDependency, LogClassLeak, LogClassExposure, LogClassWeakness:
		return true
	}
	return false
}

// LogSeverity is how bad a finding is.
type LogSeverity string

// Severities, lowest first.
const (
	LogLow      LogSeverity = "low"
	LogMedium   LogSeverity = "medium"
	LogHigh     LogSeverity = "high"
	LogCritical LogSeverity = "critical"
)

// LogSeverities lists them, lowest first.
var LogSeverities = []LogSeverity{LogLow, LogMedium, LogHigh, LogCritical}

// Rank is the severity's position, -1 for an unknown one.
func (s LogSeverity) Rank() int { return slices.Index(LogSeverities, s) }

// AtLeast reports whether s is min or worse.
func (s LogSeverity) AtLeast(min LogSeverity) bool { return s.Rank() >= min.Rank() }

// LogStatus is where a finding is in its life.
type LogStatus string

// Finding statuses: the CI set plus reported.
const (
	LogOpen       LogStatus = "open"       // seen, nothing done yet (below threshold, or off)
	LogReported   LogStatus = "reported"   // shown and notified
	LogFixing     LogStatus = "fixing"     // a ticket is working on it
	LogFixed      LogStatus = "fixed"      // the fix merged; waiting to see it gone
	LogResolved   LogStatus = "resolved"   // gone after the fix
	LogMuted      LogStatus = "muted"      // someone said to ignore it
	LogRegression LogStatus = "regression" // back on a revision that has the fix, or after the fix merged
)

// LogStatuses lists them.
var LogStatuses = []LogStatus{LogOpen, LogReported, LogFixing, LogFixed, LogResolved, LogMuted, LogRegression}

// Valid reports whether s is a known status.
func (s LogStatus) Valid() bool { return slices.Contains(LogStatuses, s) }

// Active reports whether a finding with this status still needs
// attention.
func (s LogStatus) Active() bool {
	return s == LogOpen || s == LogReported || s == LogFixing || s == LogRegression
}

// LogOccurrence is one batch of sightings of a finding.
type LogOccurrence struct {
	At       time.Time `json:"at"`
	SourceID int64     `json:"sourceId"`
	Service  string    `json:"service"`
	Revision string    `json:"revision,omitempty"`
	Count    int       `json:"count"`
}

// MaxLogOccurrences is how many occurrences a finding keeps.
const MaxLogOccurrences = 20

// LogFinding is a group of log entries with the same fingerprint, for one
// set of repositories (or one service without any).
type LogFinding struct {
	ID          int64
	WorkspaceID int64
	Scope       string
	ServiceID   *int64
	Service     string
	RepoIDs     []int64
	RepoNames   []string // filled by reads
	Category    LogCategory
	Detector    string
	Class       LogClass
	Severity    LogSeverity
	Fingerprint string
	Title       string
	Remediation string
	Status      LogStatus
	Count       int64
	HourCount   int
	HourStart   time.Time
	FirstSeenAt time.Time
	LastSeenAt  time.Time
	Revision    string
	Route       string
	Bursts      []time.Time
	SecretMask  string
	// SecretHMAC is the keyed hash of a leaked secret; never shown.
	SecretHMAC string
	// Sample is the redacted excerpt; filled by single reads only.
	Sample      string
	SampleAt    *time.Time
	Occurrences []LogOccurrence
	ReportedAt  *time.Time
	TicketKey   string
	FixedSHA    string
	FixedAt     *time.Time
	// Reason says why a finding that could have been a ticket is only
	// reported ("no repository selected", "budget reached").
	Reason string
}

// LogFindingFilter selects findings for a list.
type LogFindingFilter struct {
	Category LogCategory
	Status   LogStatus
	Severity LogSeverity
	RepoID   int64
	SourceID int64
	// Active: only findings that still need attention.
	Active bool
	Limit  int
}

// LogMode is what agnts does with a finding of a category.
type LogMode string

// Modes.
const (
	LogModeOff    LogMode = "off"
	LogModeReport LogMode = "report"
	LogModeTicket LogMode = "ticket"
)

// LogPattern is a custom detector: a regular expression that marks an
// entry as a finding of its category.
type LogPattern struct {
	Name     string      `json:"name"`
	Pattern  string      `json:"pattern"`
	Category LogCategory `json:"category"`
	Severity LogSeverity `json:"severity"`
}

// LogOverride changes the modes for one repository or one service
// (Service is "<source name>/<service name>").
type LogOverride struct {
	RepoID   int64   `json:"repoId,omitempty"`
	Service  string  `json:"service,omitempty"`
	Errors   LogMode `json:"errors,omitempty"`
	Security LogMode `json:"security,omitempty"`
}

// LogWatchSettings: how agnts watches project logs and what it does with
// what it finds. Workspace-level, like CISettings.
type LogWatchSettings struct {
	// Errors and Security say what to do with a finding of that category:
	// "off" records it only, "report" shows and notifies, "ticket" also
	// opens a ticket (for classes that can be fixed in code, on services
	// with repositories). Both default to "report": automatic tickets are
	// off until someone turns them on.
	Errors   LogMode `json:"errors"`
	Security LogMode `json:"security"`
	// AlwaysNotifyLeaks notifies leak findings of high severity or above
	// even when Security is "off": a secret leaking into logs is a live
	// incident.
	AlwaysNotifyLeaks bool `json:"alwaysNotifyLeaks"`
	// MinSeverity is the lowest severity that is reported or ticketed.
	MinSeverity LogSeverity `json:"minSeverity"`
	// Threshold is how many occurrences within the hour a finding needs
	// before it acts; panics and leaks act on the first one.
	Threshold int `json:"threshold"`
	// MaxAutoPerDay caps automatic tickets a day (Fix it is not capped).
	MaxAutoPerDay int `json:"maxAutoPerDay"`
	// AttackTicketAfter: an attack finding on one route becomes
	// ticket-able as a hardening ticket after this many bursts within 7
	// days; 0 never.
	AttackTicketAfter int `json:"attackTicketAfter"`
	// ResolveAfterDays: a fixed finding with no revision to check is
	// resolved after this many quiet days.
	ResolveAfterDays int `json:"resolveAfterDays"`
	// Digest sends one daily summary instead of a message per finding.
	Digest bool `json:"digest"`
	// TriagePerDay caps model triage calls; 0 turns triage off.
	TriagePerDay int `json:"triagePerDay"`
	// Patterns are extra detectors.
	Patterns []LogPattern `json:"patterns"`
	// Overrides change the modes for one repository or service.
	Overrides []LogOverride `json:"overrides"`
}

// DefaultLogWatchSettings returns the defaults: report everything worth
// reporting, open no tickets.
func DefaultLogWatchSettings() LogWatchSettings {
	return LogWatchSettings{
		Errors: LogModeReport, Security: LogModeReport, AlwaysNotifyLeaks: true, MinSeverity: LogMedium,
		Threshold: 3, MaxAutoPerDay: 5, AttackTicketAfter: 3, ResolveAfterDays: 3,
		Patterns: []LogPattern{}, Overrides: []LogOverride{},
	}
}

func validMode(m LogMode) bool { return m == LogModeOff || m == LogModeReport || m == LogModeTicket }

// Validate checks ranges and the patterns.
func (l *LogWatchSettings) Validate() error {
	var errs []error
	if l.Errors == "" {
		l.Errors = LogModeReport
	}
	if l.Security == "" {
		l.Security = LogModeReport
	}
	if l.MinSeverity == "" {
		l.MinSeverity = LogMedium
	}
	if !validMode(l.Errors) || !validMode(l.Security) {
		errs = append(errs, errors.New("logWatch modes must be off, report or ticket"))
	}
	if l.MinSeverity.Rank() < 0 {
		errs = append(errs, errors.New("logWatch.minSeverity must be low, medium, high or critical"))
	}
	if l.Threshold < 1 || l.Threshold > 1000 {
		errs = append(errs, errors.New("logWatch.threshold must be between 1 and 1000"))
	}
	if l.MaxAutoPerDay < 0 || l.MaxAutoPerDay > 50 {
		errs = append(errs, errors.New("logWatch.maxAutoPerDay must be between 0 and 50"))
	}
	if l.AttackTicketAfter < 0 || l.AttackTicketAfter > 50 {
		errs = append(errs, errors.New("logWatch.attackTicketAfter must be between 0 and 50"))
	}
	if l.ResolveAfterDays < 1 || l.ResolveAfterDays > 30 {
		errs = append(errs, errors.New("logWatch.resolveAfterDays must be between 1 and 30"))
	}
	if l.TriagePerDay < 0 || l.TriagePerDay > 500 {
		errs = append(errs, errors.New("logWatch.triagePerDay must be between 0 and 500"))
	}
	if l.Patterns == nil {
		l.Patterns = []LogPattern{}
	}
	if len(l.Patterns) > 50 {
		errs = append(errs, errors.New("logWatch allows at most 50 patterns"))
	}
	for i := range l.Patterns {
		p := &l.Patterns[i]
		p.Name, p.Pattern = strings.TrimSpace(p.Name), strings.TrimSpace(p.Pattern)
		if p.Severity == "" {
			p.Severity = LogMedium
		}
		if p.Category == "" {
			p.Category = LogErrors
		}
		if _, err := compileLogPattern(p.Pattern); err != nil {
			errs = append(errs, fmt.Errorf("log pattern %q: %w", p.Name, err))
		}
		if p.Category != LogErrors && p.Category != LogSecurity {
			errs = append(errs, fmt.Errorf("log pattern %q: category must be error or security", p.Name))
		}
		if p.Severity.Rank() < 0 {
			errs = append(errs, fmt.Errorf("log pattern %q: severity must be low, medium, high or critical", p.Name))
		}
	}
	if l.Overrides == nil {
		l.Overrides = []LogOverride{}
	}
	for _, o := range l.Overrides {
		if (o.RepoID == 0) == (o.Service == "") {
			errs = append(errs, errors.New("a log override names either a repository or a service"))
		}
		if (o.Errors != "" && !validMode(o.Errors)) || (o.Security != "" && !validMode(o.Security)) {
			errs = append(errs, errors.New("log override modes must be off, report or ticket"))
		}
	}
	return errors.Join(errs...)
}

// ModeFor is the mode for a finding of category c on a service (named
// "<source>/<service>") with repositories repos, after overrides: the
// service's override wins over a repository's, which wins over the
// workspace's.
func (l LogWatchSettings) ModeFor(c LogCategory, service string, repos []int64) LogMode {
	pick := func(o LogOverride) LogMode {
		if c == LogSecurity {
			return o.Security
		}
		return o.Errors
	}
	for _, o := range l.Overrides {
		if o.Service != "" && o.Service == service {
			if m := pick(o); m != "" {
				return m
			}
		}
	}
	for _, o := range l.Overrides {
		if o.RepoID != 0 && slices.Contains(repos, o.RepoID) {
			if m := pick(o); m != "" {
				return m
			}
		}
	}
	if c == LogSecurity {
		return l.Security
	}
	return l.Errors
}

// Clone copies the slices.
func (l LogWatchSettings) Clone() LogWatchSettings {
	l.Patterns = append([]LogPattern{}, l.Patterns...)
	l.Overrides = append([]LogOverride{}, l.Overrides...)
	return l
}
