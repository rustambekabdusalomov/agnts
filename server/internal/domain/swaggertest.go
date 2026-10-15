package domain

import (
	"encoding/base64"
	"encoding/json"
	"fmt"
	"net"
	"net/url"
	"regexp"
	"slices"
	"strings"
	"time"
)

// SwaggerTest is what a Swagger test ticket tests: the spec (OpenAPI 3,
// converted from Swagger 2.0), the base URL requests go to, the operations
// ticked in the form, and how the API is called.
type SwaggerTest struct {
	TicketID int64
	// SpecURL is where the spec came from ("" for an uploaded file).
	SpecURL string
	// Spec is the whole spec as OpenAPI 3 JSON; the run gets a trimmed
	// copy, the schema check uses this.
	Spec       json.RawMessage
	BaseURL    string
	Operations []string // "GET /api/v1/users/{id}"
	// WriteEnabled lets the test send POST, PUT, PATCH and DELETE; off,
	// only GET, HEAD and OPTIONS go out.
	WriteEnabled bool
	Auth         APIAuth
	// HasSecret: a sealed credential is stored (it is never read back
	// through the API, and is deleted when the ticket closes).
	HasSecret bool
	// RateLimit is requests per second (0: DefaultAPIRate); MaxRequests
	// caps a run (0: DefaultAPIMaxRequests).
	RateLimit   int
	MaxRequests int
	// SuiteID is the saved suite this test ran for, if any.
	SuiteID   *int64
	CreatedAt time.Time
}

// Swagger test limits.
const (
	DefaultAPIRate        = 5
	MaxAPIRate            = 20
	DefaultAPIMaxRequests = 300
	MaxAPIRequests        = 1000
	// MaxAPIOperations caps the operations one test covers.
	MaxAPIOperations = 500
	// MaxAPICases caps the cases a run reports.
	MaxAPICases = 500
	// MaxAuthFailures caps requests sent with no or a wrong credential in
	// one run: more looks like a login attack and may lock the account.
	MaxAuthFailures = 3
)

// APIAuthKind is how a Swagger test authenticates.
type APIAuthKind string

// Auth kinds.
const (
	AuthNone   APIAuthKind = "none"
	AuthBearer APIAuthKind = "bearer"
	AuthHeader APIAuthKind = "header" // an API key in a header (Name)
	AuthQuery  APIAuthKind = "query"  // an API key in a query parameter (Name)
	AuthBasic  APIAuthKind = "basic"  // value is "user:password"
)

// APIAuthKinds lists the auth kinds.
var APIAuthKinds = []APIAuthKind{AuthNone, AuthBearer, AuthHeader, AuthQuery, AuthBasic}

// APIAuth is the credential's kind and, for API keys, the header or
// query parameter name. The value is sealed apart and never in here.
type APIAuth struct {
	Kind APIAuthKind `json:"kind"`
	Name string      `json:"name,omitempty"`
}

var authName = regexp.MustCompile(`^[A-Za-z0-9!#$%&'*+.^_|~-]{1,100}$`)

// Validate checks the auth kind and name, and that a credential comes
// with every kind but none.
func (a APIAuth) Validate(value string) error {
	if !slices.Contains(APIAuthKinds, a.Kind) {
		return fmt.Errorf("unknown auth kind %q", a.Kind)
	}
	switch a.Kind {
	case AuthHeader, AuthQuery:
		if !authName.MatchString(a.Name) {
			return fmt.Errorf("the API key needs a %s name (letters, digits, - and _)", a.Kind)
		}
		if a.Kind == AuthHeader && slices.Contains([]string{"host", "content-length", "transfer-encoding", "connection"}, strings.ToLower(a.Name)) {
			return fmt.Errorf("%s cannot carry an API key", a.Name)
		}
	case AuthBasic:
		if value != "" && !strings.Contains(BasicCredentials(value), ":") {
			return fmt.Errorf("basic auth is user:password, or the encoded token from an Authorization: Basic header")
		}
	}
	if a.Kind != AuthNone && value == "" {
		return fmt.Errorf("a %s credential is required", a.Kind)
	}
	if len(value) > 8192 {
		return fmt.Errorf("the credential is too long")
	}
	if strings.ContainsAny(value, "\r\n") {
		return fmt.Errorf("the credential cannot contain line breaks")
	}
	return nil
}

// BasicCredentials reads a basic auth value as user:password: given as
// is, or as the encoded token from an "Authorization: Basic …" header
// (with or without the "Basic " prefix).
func BasicCredentials(value string) string {
	v := strings.TrimSpace(value)
	if strings.Contains(v, ":") && !strings.HasPrefix(strings.ToLower(v), "basic ") {
		return v
	}
	if len(v) > 6 && strings.EqualFold(v[:6], "basic ") {
		v = strings.TrimSpace(v[6:])
	}
	for _, enc := range []*base64.Encoding{base64.StdEncoding, base64.RawStdEncoding, base64.URLEncoding, base64.RawURLEncoding} {
		if b, err := enc.DecodeString(v); err == nil && strings.Contains(string(b), ":") {
			return string(b)
		}
	}
	return value
}

// ParseBaseURL checks a base URL: http or https, a host name or bare IP,
// any port, no credentials, query or fragment.
func ParseBaseURL(raw string) (*url.URL, error) {
	u, err := url.Parse(strings.TrimSpace(raw))
	if err != nil {
		return nil, fmt.Errorf("base URL: %w", err)
	}
	if u.Scheme != "http" && u.Scheme != "https" {
		return nil, fmt.Errorf("the base URL must start with http:// or https://")
	}
	if u.Hostname() == "" {
		return nil, fmt.Errorf("the base URL has no host")
	}
	if u.User != nil || u.RawQuery != "" || u.Fragment != "" {
		return nil, fmt.Errorf("the base URL cannot carry credentials, a query or a fragment")
	}
	if p := u.Port(); p != "" {
		var n int
		if _, err := fmt.Sscanf(p, "%d", &n); err != nil || n < 1 || n > 65535 {
			return nil, fmt.Errorf("the base URL has a bad port")
		}
	}
	u.Path = strings.TrimSuffix(u.Path, "/")
	return u, nil
}

// HostPort returns a URL's host and port, the scheme's default port when
// it names none.
func HostPort(u *url.URL) (string, int) {
	host := strings.ToLower(u.Hostname())
	p := u.Port()
	if p == "" {
		if u.Scheme == "http" {
			return host, 80
		}
		return host, 443
	}
	var n int
	_, _ = fmt.Sscanf(p, "%d", &n)
	return host, n
}

// Operation is "METHOD /path" of a spec operation.
type Operation struct {
	Method string
	Path   string
}

func (o Operation) String() string { return o.Method + " " + o.Path }

// ParseOperation reads "GET /users/{id}".
func ParseOperation(s string) (Operation, bool) {
	m, p, ok := strings.Cut(strings.TrimSpace(s), " ")
	m = strings.ToUpper(m)
	if !ok || !slices.Contains(HTTPMethods, m) || !strings.HasPrefix(p, "/") {
		return Operation{}, false
	}
	return Operation{Method: m, Path: strings.TrimSpace(p)}, true
}

// HTTPMethods are the methods an OpenAPI path item has.
var HTTPMethods = []string{"GET", "PUT", "POST", "DELETE", "OPTIONS", "HEAD", "PATCH", "TRACE"}

// ReadOnlyMethod reports whether a read-only test may send method.
func ReadOnlyMethod(m string) bool {
	m = strings.ToUpper(m)
	return m == "GET" || m == "HEAD" || m == "OPTIONS"
}

// sideEffectWords in a GET's path or operation id suggest it changes
// something; the form leaves such operations unticked.
var sideEffectWords = regexp.MustCompile(`(?i)(^|[^a-z])(logout|log-out|signout|export|send|notify|email|reset|sync|trigger|run|delete|remove|purge|refresh|approve|cancel|confirm|activate|deactivate)([^a-z]|$)`)

// SideEffect reports why an operation probably changes something although
// its method is safe ("" when it looks harmless).
func SideEffect(path, operationID string) string {
	for _, s := range []string{path, camelWords(operationID)} {
		if m := sideEffectWords.FindStringSubmatch(s); m != nil {
			return strings.ToLower(m[2])
		}
	}
	return ""
}

// camelWords splits sendEmail into "send Email".
func camelWords(s string) string {
	var b strings.Builder
	for i, r := range s {
		if i > 0 && r >= 'A' && r <= 'Z' {
			b.WriteByte(' ')
		}
		b.WriteRune(r)
	}
	return b.String()
}

// Validate checks a test before it is stored. ops are the spec's
// operations (nil skips that check).
func (st SwaggerTest) Validate(ops []Operation) error {
	if _, err := ParseBaseURL(st.BaseURL); err != nil {
		return err
	}
	if len(st.Operations) > MaxAPIOperations {
		return fmt.Errorf("at most %d endpoints per test", MaxAPIOperations)
	}
	known := map[string]bool{}
	for _, o := range ops {
		known[o.String()] = true
	}
	for _, s := range st.Operations {
		o, ok := ParseOperation(s)
		if !ok {
			return fmt.Errorf("bad endpoint %q", s)
		}
		if ops != nil && !known[o.String()] {
			return fmt.Errorf("%s is not in the spec", o)
		}
	}
	if st.RateLimit < 0 || st.RateLimit > MaxAPIRate {
		return fmt.Errorf("the rate limit is 1 to %d requests a second", MaxAPIRate)
	}
	if st.MaxRequests < 0 || st.MaxRequests > MaxAPIRequests {
		return fmt.Errorf("at most %d requests per run", MaxAPIRequests)
	}
	return nil
}

// ByInstructions reports a test with no endpoints ticked: the ticket's text
// says which endpoints to test, and the run sees the whole spec.
func (st SwaggerTest) ByInstructions() bool { return len(st.Operations) == 0 }

// Rate is the requests per second a run may send.
func (st SwaggerTest) Rate() int {
	if st.RateLimit > 0 {
		return st.RateLimit
	}
	return DefaultAPIRate
}

// Budget is the requests a run may send.
func (st SwaggerTest) Budget() int {
	if st.MaxRequests > 0 {
		return st.MaxRequests
	}
	return DefaultAPIMaxRequests
}

// APIVerdict is a case's outcome.
type APIVerdict string

// Verdicts.
const (
	VerdictPass    APIVerdict = "pass"
	VerdictFail    APIVerdict = "fail"
	VerdictSkipped APIVerdict = "skipped" // not run, by choice (write requests off, no data, caps)
	VerdictBlocked APIVerdict = "blocked" // could not run (token expired, an earlier request failed)
)

// Who found a case's verdict.
const (
	CaseByClaude = "claude"
	CaseBySchema = "schema" // agnts's own check of a response against the spec
)

// APICase is one test case and its verdict.
type APICase struct {
	ID        string     `json:"id"`
	Operation string     `json:"operation"`
	Case      string     `json:"case"`
	Expected  string     `json:"expected,omitempty"`
	Verdict   APIVerdict `json:"verdict"`
	Reason    string     `json:"reason,omitempty"`
	Requests  []string   `json:"requests,omitempty"`
	// Source is who reached the verdict: Claude, or agnts's schema check.
	Source string `json:"source,omitempty"`
}

// SwaggerResults is what a run reports: results.json, checked.
type SwaggerResults struct {
	Status  string    `json:"status"`
	Summary string    `json:"summary"`
	Cases   []APICase `json:"cases"`
	// Notes are what agnts dropped or added while checking.
	Notes []string `json:"notes,omitempty"`
}

var caseID = regexp.MustCompile(`^[a-z0-9-]{1,64}$`)

// Normalize checks results Claude wrote: at most MaxAPICases cases, valid
// ids (unique), operations the test covers, known verdicts, and a pass or
// fail only with logged requests behind it (no evidence, no verdict).
// Skipped and blocked cases need no requests.
func (r *SwaggerResults) Normalize(ops []string, logged map[string]bool) {
	allowed := map[string]bool{}
	for _, s := range ops {
		if o, ok := ParseOperation(s); ok {
			allowed[o.String()] = true
		}
	}
	seen := map[string]bool{}
	out := make([]APICase, 0, min(len(r.Cases), MaxAPICases))
	dropped := map[string]int{}
	for _, c := range r.Cases {
		c.ID = strings.ToLower(strings.TrimSpace(c.ID))
		switch {
		case !caseID.MatchString(c.ID) || seen[c.ID]:
			dropped["a bad or repeated case id"]++
			continue
		case !slices.Contains([]APIVerdict{VerdictPass, VerdictFail, VerdictSkipped, VerdictBlocked}, c.Verdict):
			dropped["an unknown verdict"]++
			continue
		}
		op, ok := ParseOperation(c.Operation)
		if !ok || !allowed[op.String()] {
			dropped["an endpoint the test does not cover"]++
			continue
		}
		c.Operation = op.String()
		if c.Verdict == VerdictPass || c.Verdict == VerdictFail {
			if len(c.Requests) == 0 || slices.ContainsFunc(c.Requests, func(id string) bool { return !logged[id] }) {
				dropped["no logged request behind the verdict"]++
				continue
			}
		}
		if len(out) >= MaxAPICases {
			dropped[fmt.Sprintf("over %d cases", MaxAPICases)]++
			continue
		}
		seen[c.ID] = true
		c.Case = clipText(c.Case, 200)
		c.Expected = clipText(c.Expected, 300)
		c.Reason = clipText(c.Reason, 1000)
		if c.Source == "" {
			c.Source = CaseByClaude
		}
		out = append(out, c)
	}
	r.Cases = out
	keys := make([]string, 0, len(dropped))
	for k := range dropped {
		keys = append(keys, k)
	}
	slices.Sort(keys)
	for _, k := range keys {
		r.Notes = append(r.Notes, fmt.Sprintf("dropped %d case(s): %s", dropped[k], k))
	}
	r.Summary = clipText(r.Summary, 1000)
}

func clipText(s string, n int) string {
	s = strings.TrimSpace(s)
	if len(s) <= n {
		return s
	}
	return strings.ToValidUTF8(s[:n], "") + "…"
}

// APICounts are cases per verdict.
type APICounts struct {
	Passed, Failed, Skipped, Blocked int
}

// Total is every case.
func (c APICounts) Total() int { return c.Passed + c.Failed + c.Skipped + c.Blocked }

// Counts counts the cases per verdict.
func (r SwaggerResults) Counts() APICounts {
	var c APICounts
	for _, x := range r.Cases {
		switch x.Verdict {
		case VerdictPass:
			c.Passed++
		case VerdictFail:
			c.Failed++
		case VerdictSkipped:
			c.Skipped++
		case VerdictBlocked:
			c.Blocked++
		}
	}
	return c
}

// AllBlocked reports a run where no case could run: a failed run (an
// expired token, an unreachable API), not an API full of bugs.
func (r SwaggerResults) AllBlocked() bool {
	c := r.Counts()
	return c.Blocked > 0 && c.Blocked == c.Total()
}

// SummaryLine is "37 passed, 3 failed" (and skipped and blocked when any).
func (c APICounts) SummaryLine() string {
	parts := []string{fmt.Sprintf("%d passed", c.Passed), fmt.Sprintf("%d failed", c.Failed)}
	if c.Skipped > 0 {
		parts = append(parts, fmt.Sprintf("%d skipped", c.Skipped))
	}
	if c.Blocked > 0 {
		parts = append(parts, fmt.Sprintf("%d blocked", c.Blocked))
	}
	return strings.Join(parts, ", ")
}

// APIExchange is one logged request and its response (log.jsonl).
type APIExchange struct {
	ID          string            `json:"id"`
	Case        string            `json:"case,omitempty"`
	Auth        string            `json:"auth,omitempty"` // default, none or wrong
	Method      string            `json:"method"`
	URL         string            `json:"url"`
	ReqHeaders  map[string]string `json:"requestHeaders,omitempty"`
	ReqBody     string            `json:"requestBody,omitempty"`
	Status      int               `json:"status"`
	RespHeaders map[string]string `json:"responseHeaders,omitempty"`
	RespBody    string            `json:"responseBody,omitempty"`
	Truncated   bool              `json:"truncated,omitempty"`
	MS          int64             `json:"ms"`
	Error       string            `json:"error,omitempty"`
	At          time.Time         `json:"at"`
}

// SwaggerRun is a run's checked results and its request log.
type SwaggerRun struct {
	RunID     int64
	TicketID  int64
	Results   SwaggerResults
	Log       []APIExchange
	Counts    APICounts
	Plan      json.RawMessage // the plan the run sent, reused by suites
	CreatedAt time.Time
}

// MaxAPILogBytes caps a run's stored log.
const MaxAPILogBytes = 2 << 20

// CapLog keeps the newest exchanges' bodies until the log fits max bytes,
// emptying the bodies of older ones (their status and headers stay).
func CapLog(log []APIExchange, maxBytes int) []APIExchange {
	size := func() int {
		b, _ := json.Marshal(log)
		return len(b)
	}
	for i := 0; i < len(log) && size() > maxBytes; i++ {
		if log[i].RespBody != "" || log[i].ReqBody != "" {
			log[i].RespBody, log[i].ReqBody, log[i].Truncated = "", "", true
		}
	}
	for size() > maxBytes && len(log) > 0 {
		log = log[1:]
	}
	return log
}

// IsPublicIP reports whether ip is an address on the internet: not
// loopback, private (RFC 1918), CGNAT, link-local, unique-local IPv6,
// multicast, unspecified or documentation/benchmark space.
func IsPublicIP(ip net.IP) bool {
	if ip == nil || ip.IsLoopback() || ip.IsPrivate() || ip.IsLinkLocalUnicast() || ip.IsLinkLocalMulticast() ||
		ip.IsInterfaceLocalMulticast() || ip.IsMulticast() || ip.IsUnspecified() {
		return false
	}
	for _, n := range nonPublic {
		if n.Contains(ip) {
			return false
		}
	}
	return true
}

var nonPublic = func() []*net.IPNet {
	var out []*net.IPNet
	for _, c := range []string{
		"0.0.0.0/8", "100.64.0.0/10", "192.0.0.0/24", "198.18.0.0/15", "240.0.0.0/4", "255.255.255.255/32",
		"64:ff9b::/96", "100::/64", "fc00::/7", "fe80::/10",
	} {
		_, n, _ := net.ParseCIDR(c)
		out = append(out, n)
	}
	return out
}()

// SwaggerSuite is a saved Swagger test that runs again on a schedule or
// after a deploy: each run is a new Swagger test ticket, compared with the
// suite's last run, reusing its plan.
type SwaggerSuite struct {
	ID           int64
	Name         string
	SpecURL      string
	Spec         json.RawMessage
	BaseURL      string
	Operations   []string
	WriteEnabled bool
	Auth         APIAuth
	HasSecret    bool
	RateLimit    int
	MaxRequests  int
	RepoID       *int64
	Notes        string
	Schedule     SuiteSchedule
	// Hour is the UTC hour daily and weekly runs start at (0-23); weekly
	// runs are on Mondays.
	Hour    int
	Enabled bool
	// HookSet: a deploy hook URL exists (its token is shown once).
	HookSet       bool
	LastRunAt     *time.Time
	NextRunAt     *time.Time
	LastTicketKey string
	CreatedAt     time.Time
}

// SuiteSchedule is how often a suite runs by itself.
type SuiteSchedule string

// Schedules.
const (
	ScheduleOff    SuiteSchedule = "off" // only by hand or the deploy hook
	ScheduleHourly SuiteSchedule = "hourly"
	ScheduleDaily  SuiteSchedule = "daily"
	ScheduleWeekly SuiteSchedule = "weekly"
)

// Valid reports whether s is a known schedule.
func (s SuiteSchedule) Valid() bool {
	return s == ScheduleOff || s == ScheduleHourly || s == ScheduleDaily || s == ScheduleWeekly
}

// NextRun is when a suite on schedule s runs next after now (nil when
// off): hourly on the hour, daily at hour (UTC), weekly on Monday at hour.
func (s SuiteSchedule) NextRun(now time.Time, hour int) *time.Time {
	now = now.UTC()
	var t time.Time
	switch s {
	case ScheduleHourly:
		t = now.Truncate(time.Hour).Add(time.Hour)
	case ScheduleDaily:
		t = time.Date(now.Year(), now.Month(), now.Day(), hour, 0, 0, 0, time.UTC)
		if !t.After(now) {
			t = t.AddDate(0, 0, 1)
		}
	case ScheduleWeekly:
		t = time.Date(now.Year(), now.Month(), now.Day(), hour, 0, 0, 0, time.UTC)
		for t.Weekday() != time.Monday || !t.After(now) {
			t = t.AddDate(0, 0, 1)
		}
	default:
		return nil
	}
	return &t
}

// Test returns the Swagger test a suite run makes.
func (s SwaggerSuite) Test() SwaggerTest {
	id := s.ID
	return SwaggerTest{SpecURL: s.SpecURL, Spec: s.Spec, BaseURL: s.BaseURL, Operations: s.Operations, WriteEnabled: s.WriteEnabled,
		Auth: s.Auth, RateLimit: s.RateLimit, MaxRequests: s.MaxRequests, SuiteID: &id}
}
