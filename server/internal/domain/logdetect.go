package domain

import (
	"crypto/hmac"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"
	"regexp"
	"slices"
	"strconv"
	"strings"
	"time"
)

// Limits of a framed log event.
const (
	LogEventMaxLines = 300
	LogEventMaxBytes = 64 << 10
	// logJoinGap is how far apart two entries of one stream may be and
	// still be lines of the same multi-line entry (a stack trace written
	// line by line).
	logJoinGap = 2 * time.Second
)

// LogEvent is one framed log event: an entry, or several entries of one
// stream joined because they are the lines of one stack trace. Lines are
// raw (not redacted).
type LogEvent struct {
	Time     time.Time
	Service  string
	Stream   string
	Level    string // normalized: "", debug, info, warn, error, fatal
	Revision string
	// Caller is the logger call site, when the entry says (JSON caller,
	// logger.caller, source).
	Caller string
	// Lines are the event's text: the message, the error, the stack.
	Lines []string
	// Raw are the entries as received (JSON included), for detectors that
	// look at every field (secrets).
	Raw []string
	// Access is set when the entry is an HTTP access log line.
	Access *LogAccess
	// Body is a logged response body, when the entry has one.
	Body string
}

// LogAccess is what an access log entry says about one request.
type LogAccess struct {
	Method string
	Path   string
	Status int
	IP     string
}

// ---------------------------------------------------------------------
// Parsing and framing

// jsonMessageKeys, in order, name the message of a JSON entry.
var (
	jsonMessageKeys  = []string{"msg", "message", "log", "_msg", "short_message", "full_message", "event"}
	jsonLevelKeys    = []string{"level", "severity", "lvl", "log.level", "levelname", "loglevel"}
	jsonErrorKeys    = []string{"error", "err", "error.message", "exception", "exc_info", "error_message"}
	jsonStackKeys    = []string{"stack", "stacktrace", "stack_trace", "error.stack", "error.stack_trace", "exception.stacktrace", "trace"}
	jsonCallerKeys   = []string{"caller", "logger.caller", "source", "src", "log.origin.file.name", "location"}
	jsonPathKeys     = []string{"path", "url", "uri", "request_uri", "http.request.path", "url.path", "request.path", "req.url"}
	jsonStatusKeys   = []string{"status", "status_code", "statusCode", "http.response.status_code", "response.status", "res.statusCode", "http_status"}
	jsonMethodKeys   = []string{"method", "http.request.method", "request.method", "req.method", "http_method"}
	jsonIPKeys       = []string{"ip", "remote_addr", "remote_ip", "client_ip", "client.ip", "source.ip", "req.remoteAddress", "x_forwarded_for"}
	jsonBodyKeys     = []string{"response.body", "resp_body", "response_body", "http.response.body.content", "res.body"}
	jsonRevisionKeys = []string{"revision", "version", "service.version", "commit", "git_sha", "build"}
)

// lookup reads a dotted key from a decoded JSON object, either nested
// ({"error":{"stack":..}}) or flat ({"error.stack":..}).
func lookup(m map[string]any, key string) (any, bool) {
	if v, ok := m[key]; ok {
		return v, true
	}
	head, rest, ok := strings.Cut(key, ".")
	if !ok {
		return nil, false
	}
	sub, ok := m[head].(map[string]any)
	if !ok {
		return nil, false
	}
	return lookup(sub, rest)
}

func lookupString(m map[string]any, keys []string, extra string) string {
	if extra != "" {
		keys = append([]string{extra}, keys...)
	}
	for _, k := range keys {
		v, ok := lookup(m, k)
		if !ok || v == nil {
			continue
		}
		switch x := v.(type) {
		case string:
			if x != "" {
				return x
			}
		case float64:
			return strconv.FormatFloat(x, 'f', -1, 64)
		case bool:
			return strconv.FormatBool(x)
		case map[string]any, []any:
			b, _ := json.Marshal(x)
			return string(b)
		}
	}
	return ""
}

// NormalizeLevel maps a level as loggers write it (a name, a syslog
// number, a pino number) to debug, info, warn, error or fatal; "" when
// unknown.
func NormalizeLevel(v string) string {
	v = strings.ToLower(strings.TrimSpace(v))
	if n, err := strconv.Atoi(v); err == nil {
		if n >= 10 { // pino / bunyan
			switch {
			case n >= 60:
				return "fatal"
			case n >= 50:
				return "error"
			case n >= 40:
				return "warn"
			case n >= 30:
				return "info"
			}
			return "debug"
		}
		switch { // syslog
		case n <= 2:
			return "fatal"
		case n == 3:
			return "error"
		case n == 4:
			return "warn"
		case n <= 6:
			return "info"
		}
		return "debug"
	}
	switch v {
	case "fatal", "panic", "crit", "critical", "emerg", "emergency", "alert", "dpanic":
		return "fatal"
	case "error", "err", "e", "severe":
		return "error"
	case "warn", "warning", "w":
		return "warn"
	case "info", "information", "notice", "i", "informational":
		return "info"
	case "debug", "trace", "d", "verbose", "fine", "finer", "finest":
		return "debug"
	}
	return ""
}

var (
	textLevelKV  = regexp.MustCompile(`(?i)\b(?:level|lvl|severity)\s*[=:]\s*"?([a-z]+)`)
	textLevelTag = regexp.MustCompile(`\b(FATAL|PANIC|CRITICAL|ERROR|ERR|WARNING|WARN|INFO|DEBUG|TRACE)\b`)
	// Common/combined log format: ip - - [time] "GET /path HTTP/1.1" 500 123
	accessLine = regexp.MustCompile(`^(\S+) \S+ \S+ \[[^\]]+\] "([A-Z]+) (\S+)[^"]*" (\d{3}) `)
)

// textLevel finds the level of a plain text line: logfmt level=error, or
// an upper-case tag ([ERROR], " ERROR ") near the start.
func textLevel(line string) string {
	if m := textLevelKV.FindStringSubmatch(line); m != nil {
		if l := NormalizeLevel(m[1]); l != "" {
			return l
		}
	}
	head := line
	if len(head) > 100 {
		head = head[:100]
	}
	if m := textLevelTag.FindStringSubmatch(head); m != nil {
		return NormalizeLevel(m[1])
	}
	return ""
}

// ParseLogEntry turns an entry into a one-entry event: JSON is decoded
// into message, error, stack and fields; plain text keeps its lines. f
// names the source's own fields.
func ParseLogEntry(e LogEntry, f LogFields) LogEvent {
	ev := LogEvent{Time: e.Time, Service: e.Service, Stream: e.Stream, Revision: e.Revision, Raw: []string{e.Message}}
	if ev.Stream == "" {
		ev.Stream = e.Service
	}
	msg := strings.TrimRight(e.Message, "\n")
	trimmed := strings.TrimSpace(msg)
	var m map[string]any
	if strings.HasPrefix(trimmed, "{") && json.Unmarshal([]byte(trimmed), &m) == nil {
		text := lookupString(m, jsonMessageKeys, f.Message)
		ev.Level = NormalizeLevel(lookupString(m, jsonLevelKeys, f.Level))
		ev.Caller = lookupString(m, jsonCallerKeys, "")
		if ev.Revision == "" {
			ev.Revision = lookupString(m, jsonRevisionKeys, f.Revision)
		}
		if text != "" {
			ev.Lines = append(ev.Lines, splitLines(text)...)
		}
		if er := lookupString(m, jsonErrorKeys, ""); er != "" && er != text {
			ev.Lines = append(ev.Lines, splitLines(er)...)
		}
		if st := lookupString(m, jsonStackKeys, ""); st != "" {
			ev.Lines = append(ev.Lines, splitLines(st)...)
		}
		if len(ev.Lines) == 0 {
			ev.Lines = []string{trimmed}
		}
		// A shipper's wrapper ({"log": "ERROR ..."}) carries a text line:
		// read its level and access fields as for plain text.
		if ev.Level == "" && text != "" {
			ev.Level = textLevel(ev.Lines[0])
		}
		if a := accessLine.FindStringSubmatch(ev.Lines[0]); a != nil {
			st, _ := strconv.Atoi(a[4])
			ev.Access = &LogAccess{IP: a[1], Method: a[2], Path: a[3], Status: st}
		}
		if p := lookupString(m, jsonPathKeys, ""); p != "" {
			if st, err := strconv.Atoi(lookupString(m, jsonStatusKeys, "")); err == nil && st >= 100 && st < 600 {
				ev.Access = &LogAccess{Method: strings.ToUpper(lookupString(m, jsonMethodKeys, "")), Path: p, Status: st, IP: lookupString(m, jsonIPKeys, "")}
			}
		}
		ev.Body = lookupString(m, jsonBodyKeys, "")
	} else {
		ev.Lines = splitLines(msg)
		if len(ev.Lines) > 0 {
			ev.Level = textLevel(ev.Lines[0])
			if a := accessLine.FindStringSubmatch(ev.Lines[0]); a != nil {
				st, _ := strconv.Atoi(a[4])
				ev.Access = &LogAccess{IP: a[1], Method: a[2], Path: a[3], Status: st}
			}
		}
	}
	if l := NormalizeLevel(e.Level); l != "" && ev.Level == "" {
		ev.Level = l
	}
	if ev.Access != nil {
		if i := strings.IndexAny(ev.Access.Path, "?#"); i >= 0 {
			ev.Access.Path = ev.Access.Path[:i]
		}
	}
	return ev
}

func splitLines(s string) []string {
	s = strings.ReplaceAll(s, "\r\n", "\n")
	lines := strings.Split(strings.TrimRight(s, "\n"), "\n")
	for i, l := range lines {
		lines[i] = strings.TrimRight(ansi.ReplaceAllString(l, ""), " \t\r")
	}
	return lines
}

// continuation matches a line that carries on the multi-line entry before
// it: indented frames, goroutine headers, "Caused by", Go function lines,
// the exception line that ends a Python traceback.
var continuation = regexp.MustCompile(`^(?:\s+\S|goroutine \d+ \[|Caused by: |\.\.\. \d+ more|created by |[\w./*()\[\]{}-]+\(.*\)$|[\w.]+(?:Error|Exception|Exit|Interrupt)\b|During handling of the above exception|The above exception was|Traceback \(most recent call last\)|\[signal |exit status \d+)`)

// errorStart matches the first line of an error in application logs.
var errorStart = []*regexp.Regexp{
	regexp.MustCompile(`^panic: `),
	regexp.MustCompile(`^fatal error: `),
	regexp.MustCompile(`^Traceback \(most recent call last\):`),
	regexp.MustCompile(`^Exception in thread `),
	regexp.MustCompile(`(?i)\b(?:uncaught|unhandled)(?: promise)?(?: exception| rejection|PromiseRejection)`),
	regexp.MustCompile(`^(?:[a-z][\w$]*\.)+[A-Z][\w$]*(?:Error|Exception)\b`),                   // java.lang.NullPointerException
	regexp.MustCompile(`^(?:[A-Z][\w$]*\.)*[A-Z][\w$]*(?:Error|Exception)(?:\s*\[[^\]]*\])?: `), // TypeError: x, ValueError: x
}

// LogErrorStart reports whether a line starts a multi-line error (a Go
// panic, a Python traceback, a Java exception): readers fetch the lines
// after it, which a keyword filter would drop.
func LogErrorStart(line string) bool {
	i, _ := startsError([]string{line})
	return i >= 0
}

func startsError(lines []string) (int, *regexp.Regexp) {
	for i, l := range lines {
		for _, re := range errorStart {
			if re.MatchString(l) {
				return i, re
			}
		}
	}
	return -1, nil
}

// FrameLogs parses entries and joins the lines of one multi-line entry
// that arrived as separate entries (a Go panic or a Python traceback
// written line by line), per stream, in time order. f names the source's
// fields.
func FrameLogs(entries []LogEntry, f LogFields) []LogEvent {
	var out []LogEvent
	open := map[string]int{} // stream → index in out of the event still taking lines
	blank := map[string]int{}
	for _, e := range entries {
		ev := ParseLogEntry(e, f)
		if i, ok := open[ev.Stream]; ok {
			cur := &out[i]
			gap := ev.Time.Sub(cur.Time)
			joins := gap >= 0 && gap <= logJoinGap+time.Duration(len(cur.Lines))*time.Millisecond &&
				len(ev.Lines) == 1 && ev.Access == nil && len(cur.Lines) < LogEventMaxLines
			if joins {
				l := ev.Lines[0]
				switch {
				case strings.TrimSpace(l) == "" && blank[ev.Stream] < 2:
					blank[ev.Stream]++
					cur.Lines = append(cur.Lines, l)
					cur.Raw = append(cur.Raw, ev.Raw...)
					continue
				case continuation.MatchString(l):
					blank[ev.Stream] = 0
					cur.Lines = append(cur.Lines, l)
					cur.Raw = append(cur.Raw, ev.Raw...)
					if cur.Level == "" && ev.Level != "" {
						cur.Level = ev.Level
					}
					continue
				}
			}
			delete(open, ev.Stream)
		}
		out = append(out, ev)
		if idx, _ := startsError(ev.Lines); idx >= 0 || ev.Level == "error" || ev.Level == "fatal" {
			open[ev.Stream] = len(out) - 1
			blank[ev.Stream] = 0
		}
	}
	for i := range out {
		capLines(&out[i])
	}
	return out
}

func capLines(ev *LogEvent) {
	for len(ev.Lines) > 0 && strings.TrimSpace(ev.Lines[len(ev.Lines)-1]) == "" {
		ev.Lines = ev.Lines[:len(ev.Lines)-1]
	}
	if len(ev.Lines) > LogEventMaxLines {
		ev.Lines = ev.Lines[:LogEventMaxLines]
	}
	size := 0
	for i, l := range ev.Lines {
		size += len(l) + 1
		if size > LogEventMaxBytes {
			ev.Lines = ev.Lines[:i]
			break
		}
	}
}

// ---------------------------------------------------------------------
// Prefilter and the backends' filter terms

// logLiterals are the lower-case substrings at least one of which is in
// every entry a built-in detector can match (besides the level and access
// lines). The connectors turn them into the backend's own filter, so the
// two never disagree.
var logLiterals = []string{
	"panic", "fatal", "error", "exception", "traceback", "uncaught", "unhandled", "critical",
	"bearer", "basic ", "password", "passwd", "pwd", "secret", "api_key", "apikey", "api-key", "token",
	"private key", "eyj", "akia", "asia", "ghp_", "gho_", "ghs_", "ghu_", "ghr_", "github_pat_", "glpat-",
	"xox", "sk_live_", "rk_live_", "aiza", "sk-", ":aa",
	"debug", "development server", "debugger",
	"/.env", "/.git", "/wp-", "phpmyadmin", "xmlrpc", "/.aws", "/actuator", "/server-status",
	"login", "signin", "sign_in", "authentication", "credentials",
}

// accessHit matches access log lines worth a look: 5xx, 401, 403, in the
// common log format, logfmt and JSON.
var accessHit = regexp.MustCompile(`HTTP/[0-9.]+" (?:5\d\d|40[13]) |"(?:status|status_code|statusCode)"\s*:\s*"?(?:5\d\d|40[13])\b|\bstatus=(?:5\d\d|40[13])\b`)

// urlCredentials matches user:password@ in a URL, which has no keyword
// for the literals to catch.
var urlCredentials = regexp.MustCompile(`://[^\s:/@"']+:[^\s@/"']+@`)

// LogFilterTerms are the literals the backends filter on (see
// LogFilterRegex for Loki's form).
func LogFilterTerms() []string { return slices.Clone(logLiterals) }

// LogFilterRegex is one case-insensitive RE2 expression that matches
// every entry the detectors may want: the literals, the access lines, and
// the extra patterns. Loki applies it with |~.
func LogFilterRegex(extra []string) string {
	parts := make([]string, 0, len(logLiterals)+len(extra)+1)
	for _, l := range logLiterals {
		parts = append(parts, regexp.QuoteMeta(l))
	}
	parts = append(parts, accessHit.String(), urlCredentials.String())
	parts = append(parts, extra...)
	return "(?i)(" + strings.Join(parts, "|") + ")"
}

// PassesLogPrefilter reports whether an event may hold a finding: an
// error level, an access line, or one of the literals. Most entries are
// dropped here without running a detector.
func PassesLogPrefilter(ev LogEvent, extra []*regexp.Regexp) bool {
	if ev.Level == "error" || ev.Level == "fatal" || ev.Access != nil {
		return true
	}
	for _, raw := range ev.Raw {
		low := strings.ToLower(raw)
		for _, l := range logLiterals {
			if strings.Contains(low, l) {
				return true
			}
		}
		if accessHit.MatchString(raw) || urlCredentials.MatchString(raw) {
			return true
		}
		for _, re := range extra {
			if re.MatchString(raw) {
				return true
			}
		}
	}
	return false
}

// ---------------------------------------------------------------------
// Redaction and normalization

// moreSecrets are redacted on top of Redact's patterns.
var moreSecrets = []struct {
	re   *regexp.Regexp
	with string
}{
	{regexp.MustCompile(`\bgithub_pat_[A-Za-z0-9_]{20,}`), "[github token]"},
	{regexp.MustCompile(`\b[rs]k_live_[A-Za-z0-9]{16,}`), "[stripe key]"},
	{regexp.MustCompile(`\b\d{8,10}:AA[A-Za-z0-9_-]{30,}\b`), "[telegram token]"},
	{regexp.MustCompile(`(?i)("(?:password|passwd|pwd|secret|api[_-]?key|apikey|access[_-]?token|refresh[_-]?token|client[_-]?secret|authorization|cookie|set-cookie)"\s*:\s*")[^"]{3,}"`), `$1[redacted]"`},
	{regexp.MustCompile(`\b(?:\d[ -]?){12,18}\d\b`), "[number]"},
}

// RedactLog hides secrets, emails and long numbers (card-like) in a log
// line. values are secrets found in it that are hidden wherever they are.
func RedactLog(s string, values ...string) string {
	for _, v := range values {
		if len(v) >= 6 {
			s = strings.ReplaceAll(s, v, "[redacted]")
		}
	}
	s = Redact(s)
	for _, p := range moreSecrets {
		s = p.re.ReplaceAllString(s, p.with)
	}
	return s
}

var (
	normQuoted = regexp.MustCompile(`"[^"]{0,200}"|'[^']{0,200}'`)
	normIP     = regexp.MustCompile(`\b\d{1,3}(?:\.\d{1,3}){3}(?::\d+)?\b`)
	logPrefix  = regexp.MustCompile(`^(?:\[?\d{4}[-/]\d\d[-/]\d\d[T ]\d\d:\d\d:\d\d[^\s\]]*\]?\s*)?(?:\[?(?:FATAL|PANIC|CRITICAL|ERROR|ERR|WARNING|WARN|INFO|DEBUG)\]?:?\s+)?`)
)

// NormalizeLogLine is NormalizeLine plus what varies between two
// occurrences of the same log error: quoted values and IP addresses.
func NormalizeLogLine(l string) string {
	l = normQuoted.ReplaceAllString(l, `"<s>"`)
	l = normIP.ReplaceAllString(l, "<ip>")
	return NormalizeLine(l)
}

// ---------------------------------------------------------------------
// Detectors

// LogHit is one thing a detector found in an event. Lines and Title are
// redacted; secret values never leave DetectLog (only their mask and
// keyed hash).
type LogHit struct {
	Category    LogCategory
	Detector    string
	Class       LogClass
	Severity    LogSeverity
	Title       string
	Fingerprint string
	Lines       []string
	Route       string
	SecretKind  string
	SecretMask  string
	SecretHMAC  string
	// Remediation is a short, rule-written fix.
	Remediation string
}

// LogRules are what DetectLog checks besides the built-in detectors.
type LogRules struct {
	// Key is the workspace's secret-hash key.
	Key []byte
	// Production: the source is a production one (debug mode counts).
	Production bool
	Patterns   []CompiledLogPattern
}

// CompiledLogPattern is a LogPattern ready to match.
type CompiledLogPattern struct {
	LogPattern
	Re *regexp.Regexp
}

func compileLogPattern(p string) (*regexp.Regexp, error) {
	if p == "" {
		return nil, errors.New("empty")
	}
	if len(p) > 500 {
		return nil, errors.New("longer than 500 characters")
	}
	return regexp.Compile("(?i)" + p)
}

// CompileLogPatterns compiles a workspace's patterns, skipping invalid
// ones (Validate refuses them on save).
func CompileLogPatterns(ps []LogPattern) []CompiledLogPattern {
	out := make([]CompiledLogPattern, 0, len(ps))
	for _, p := range ps {
		if re, err := compileLogPattern(p.Pattern); err == nil {
			out = append(out, CompiledLogPattern{LogPattern: p, Re: re})
		}
	}
	return out
}

func fingerprint(parts ...string) string {
	h := sha256.New()
	for _, p := range parts {
		h.Write([]byte(p))
		h.Write([]byte{0})
	}
	return hex.EncodeToString(h.Sum(nil))[:32]
}

func truncTitle(s string) string {
	s = strings.TrimSpace(s)
	if r := []rune(s); len(r) > 160 {
		s = string(r[:159]) + "…"
	}
	return s
}

// DetectLog runs every detector on one framed event.
func DetectLog(ev LogEvent, r LogRules) []LogHit {
	var hits []LogHit
	secrets := detectSecrets(ev, r.Key)
	values := make([]string, 0, len(secrets))
	for _, s := range secrets {
		values = append(values, s.value)
	}
	red := make([]string, len(ev.Lines))
	for i, l := range ev.Lines {
		red[i] = RedactLog(l, values...)
	}
	if h, ok := detectError(ev, red); ok {
		hits = append(hits, h)
	}
	for _, s := range secrets {
		hits = append(hits, s.hit(ev, red, values))
	}
	hits = append(hits, detectPersonalData(ev, red)...)
	if h, ok := detectExposure(ev, red, values); ok {
		hits = append(hits, h)
	}
	if r.Production {
		if h, ok := detectDebugMode(ev, red); ok {
			hits = append(hits, h)
		}
	}
	if h, ok := detectInjection(ev, red); ok {
		hits = append(hits, h)
	}
	for _, p := range r.Patterns {
		for _, raw := range ev.Raw {
			if !p.Re.MatchString(raw) {
				continue
			}
			class := LogClassCode
			if p.Category == LogSecurity {
				class = LogClassWeakness
			}
			hits = append(hits, LogHit{Category: p.Category, Detector: "pattern:" + p.Name, Class: class, Severity: p.Severity,
				Title: truncTitle(p.Name + ": " + RedactLog(firstNonEmpty(ev.Lines), values...)), Lines: red,
				Fingerprint: fingerprint("pattern", p.Name, templateOf(red))})
			break
		}
	}
	return hits
}

func firstNonEmpty(lines []string) string {
	for _, l := range lines {
		if strings.TrimSpace(l) != "" {
			return l
		}
	}
	return ""
}

// templateOf is the normalized first line: what stays the same between
// two occurrences of one message.
func templateOf(red []string) string {
	l := logPrefix.ReplaceAllString(strings.TrimSpace(firstNonEmpty(red)), "")
	l = NormalizeLogLine(l)
	if len(l) > 300 {
		l = l[:300]
	}
	return l
}

// frameLine matches a stack frame; stdFrame one in the language's own
// library or a dependency, which says little about where the bug is.
var (
	frameLine = regexp.MustCompile(`^(?:\s+at |\s+File "|[\w./*()\[\]{}-]+\(.*\)$|\s+[\w.$]+\(.*\)$)`)
	stdFrame  = regexp.MustCompile(`runtime/|^runtime\.|/usr/local/go/|/usr/lib/go|^net/http\.|^sync\.|site-packages|dist-packages|/lib/python\d|node_modules|node:internal|\(internal/|at java\.|at javax\.|at sun\.|at jdk\.|java\.base/|at org\.springframework|at kotlin\.|at (?:async )?Promise|<anonymous>`)
)

func appFrames(lines []string, n int) []string {
	var out []string
	for _, l := range lines {
		if !frameLine.MatchString(l) || stdFrame.MatchString(l) {
			continue
		}
		out = append(out, NormalizeLogLine(l))
		if len(out) == n {
			break
		}
	}
	return out
}

var (
	pyException   = regexp.MustCompile(`^[\w.]+(?:Error|Exception|Exit|Interrupt|Warning)\b`)
	javaInThread  = regexp.MustCompile(`^Exception in thread "[^"]*" `)
	goFatalPrefix = regexp.MustCompile(`^(panic|fatal error): `)
)

// errorTitle picks the line that names the error.
func errorTitle(red []string, start int, re *regexp.Regexp) string {
	if start >= 0 {
		l := red[start]
		switch {
		case strings.HasPrefix(l, "Traceback"):
			// Python names the exception at the end.
			for i := len(red) - 1; i > start; i-- {
				if pyException.MatchString(red[i]) {
					return red[i]
				}
			}
		case javaInThread.MatchString(l):
			return javaInThread.ReplaceAllString(l, "")
		}
		if re != nil && start > 0 && !goFatalPrefix.MatchString(l) {
			// "ERROR handler failed" then "TypeError: x": the message
			// before is usually the better title.
			if p := logPrefix.ReplaceAllString(strings.TrimSpace(red[0]), ""); p != "" && !frameLine.MatchString(red[0]) {
				return p + " — " + strings.TrimSpace(l)
			}
		}
		return l
	}
	return logPrefix.ReplaceAllString(strings.TrimSpace(firstNonEmpty(red)), "")
}

func detectError(ev LogEvent, red []string) (LogHit, bool) {
	start, re := startsError(ev.Lines)
	level := ev.Level
	if start < 0 && level != "error" && level != "fatal" {
		return LogHit{}, false
	}
	det, sev := "error", LogMedium
	switch {
	case start >= 0 && goFatalPrefix.MatchString(ev.Lines[start]), level == "fatal":
		det, sev = "panic", LogHigh
	case start >= 0 && strings.Contains(strings.ToLower(ev.Lines[start]), "uncaught"),
		start >= 0 && strings.Contains(strings.ToLower(ev.Lines[start]), "unhandled"):
		det, sev = "exception", LogHigh
	case start >= 0, len(appFrames(ev.Lines, 1)) > 0:
		det = "exception"
	}
	title := truncTitle(errorTitle(red, start, re))
	if title == "" {
		return LogHit{}, false
	}
	frames := appFrames(ev.Lines, 5)
	key := NormalizeLogLine(logPrefix.ReplaceAllString(title, ""))
	h := LogHit{Category: LogErrors, Detector: det, Class: LogClassCode, Severity: sev, Title: title, Lines: red,
		Fingerprint: fingerprint(append([]string{"error", det, key}, frames...)...)}
	if infra, ok := InfraMatch(ev.Lines, nil); ok {
		_ = infra
		h.Class = LogClassInfra
		h.Remediation = "This looks like the network, a dependency service or the machine, not the code: check the service it calls and its resources."
	}
	return h, true
}

// secretRule finds one kind of secret; group is the submatch with the
// value (0: the whole match).
type secretRule struct {
	kind  string
	re    *regexp.Regexp
	group int
}

var secretRules = []secretRule{
	{"JWT", regexp.MustCompile(`\beyJ[A-Za-z0-9_-]{8,}\.[A-Za-z0-9_-]{8,}\.[A-Za-z0-9_-]{8,}`), 0},
	{"bearer token", regexp.MustCompile(`(?i)\bbearer\s+([A-Za-z0-9._~+/=-]{16,})`), 1},
	{"basic auth credentials", regexp.MustCompile(`(?i)\bbasic\s+([A-Za-z0-9+/]{16,}={0,2})`), 1},
	{"AWS access key", regexp.MustCompile(`\b(?:AKIA|ASIA)[A-Z0-9]{16}\b`), 0},
	{"GitHub token", regexp.MustCompile(`\bgh[pousr]_[A-Za-z0-9]{30,}\b|\bgithub_pat_[A-Za-z0-9_]{60,}`), 0},
	{"GitLab token", regexp.MustCompile(`\bglpat-[A-Za-z0-9_-]{20,}`), 0},
	{"Slack token", regexp.MustCompile(`\bxox[abprs]-[A-Za-z0-9-]{10,}`), 0},
	{"Stripe key", regexp.MustCompile(`\b[rs]k_live_[A-Za-z0-9]{20,}`), 0},
	{"Google API key", regexp.MustCompile(`\bAIza[0-9A-Za-z_-]{35}\b`), 0},
	{"API key", regexp.MustCompile(`\bsk-(?:ant-|proj-)?[A-Za-z0-9_-]{20,}`), 0},
	{"Telegram bot token", regexp.MustCompile(`\b\d{8,10}:AA[A-Za-z0-9_-]{33}\b`), 0},
	{"private key", regexp.MustCompile(`-----BEGIN [A-Z ]*PRIVATE KEY-----[A-Za-z0-9+/=\s\\n]{16,}`), 0},
	{"password in a URL", regexp.MustCompile(`\b[a-z][a-z0-9+.-]*://[^\s:/@"']+:([^\s@/"']{3,})@`), 1},
	{"password", regexp.MustCompile(`(?i)["']?\b(?:password|passwd|pwd)\b["']?\s*[:=]\s*["']?([^\s"',;&}\]]{6,})`), 1},
	{"secret", regexp.MustCompile(`(?i)["']?\b(?:secret|api[_-]?key|apikey|access[_-]?token|refresh[_-]?token|client[_-]?secret|private[_-]?key)\b["']?\s*[:=]\s*["']?([^\s"',;&}\]]{12,})`), 1},
}

// notSecret are values that look like an assignment but hold nothing.
var notSecret = regexp.MustCompile(`(?i)^(?:\[[a-z ]+\]|\*+|x+|null|nil|none|undefined|true|false|empty|hidden|masked|redacted|\$\{.*|%s|%v|\{\{.*|<.*>)$`)

type foundSecret struct {
	kind, value, mask, hmac string
}

func maskSecret(v string) string {
	r := []rune(v)
	if strings.HasPrefix(v, "-----BEGIN") {
		return "-----BEGIN…"
	}
	if len(r) < 10 {
		return string(r[:1]) + "…"
	}
	return string(r[:4]) + "…" + string(r[len(r)-2:])
}

func detectSecrets(ev LogEvent, key []byte) []foundSecret {
	var out []foundSecret
	seen := map[string]bool{}
	kinds := map[string]bool{}
	for _, raw := range ev.Raw {
		for _, rule := range secretRules {
			for _, m := range rule.re.FindAllStringSubmatch(raw, 4) {
				v := m[rule.group]
				if v == "" || seen[v] {
					continue
				}
				if rule.group > 0 && (notSecret.MatchString(v) || placeholder.MatchString(v)) {
					continue
				}
				if (rule.kind == "password" || rule.kind == "secret") && !strongEnough(v) {
					continue
				}
				// A JWT inside "Bearer eyJ…" is one secret.
				dup := false
				for s := range seen {
					if strings.Contains(s, v) || strings.Contains(v, s) {
						dup = true
					}
				}
				seen[v] = true
				if dup || kinds[rule.kind] {
					continue
				}
				kinds[rule.kind] = true
				mac := hmac.New(sha256.New, key)
				mac.Write([]byte(v))
				out = append(out, foundSecret{kind: rule.kind, value: v, mask: maskSecret(v), hmac: hex.EncodeToString(mac.Sum(nil))})
			}
		}
	}
	return out
}

// strongEnough: a plain lower-case word after "password:" is usually a
// message ("password: incorrect"), not a password.
var plainWord = regexp.MustCompile(`^[a-z]+$`)

func strongEnough(v string) bool { return !plainWord.MatchString(v) }

func (s foundSecret) hit(ev LogEvent, red, values []string) LogHit {
	site := strings.TrimSpace(ev.Caller)
	if site == "" {
		if f := appFrames(ev.Lines, 1); len(f) > 0 {
			site = f[0]
		}
	}
	key := site
	if key == "" {
		key = templateOf(red)
	} else {
		key = NormalizeLogLine(key)
	}
	title := s.kind + " written to the log"
	if ev.Caller != "" {
		title += " (" + ev.Caller + ")"
	}
	return LogHit{Category: LogSecurity, Detector: "secret", Class: LogClassLeak, Severity: LogHigh, Title: truncTitle(title),
		Lines: red, SecretKind: s.kind, SecretMask: s.mask, SecretHMAC: s.hmac,
		Fingerprint: fingerprint("security", "secret", s.kind, key),
		Remediation: "Stop logging this value at its call site (mask it or drop the field), then rotate every " + s.kind + " written since it started."}
}

var (
	logEmail = regexp.MustCompile(`\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}\b`)
	cardRe   = regexp.MustCompile(`\b(?:\d[ -]?){12,18}\d\b`)
)

func luhn(s string) bool {
	sum, alt, n := 0, false, 0
	for i := len(s) - 1; i >= 0; i-- {
		c := s[i]
		if c < '0' || c > '9' {
			continue
		}
		d := int(c - '0')
		if alt {
			if d *= 2; d > 9 {
				d -= 9
			}
		}
		sum += d
		alt = !alt
		n++
	}
	return n >= 13 && n <= 19 && sum%10 == 0
}

// detectPersonalData finds card numbers and email addresses. It sees only
// the entries agnts reads (filtered for errors and security), so it is
// best effort: it catches personal data in error logs and request dumps.
func detectPersonalData(ev LogEvent, red []string) []LogHit {
	var hits []LogHit
	card, email := false, false
	for _, raw := range ev.Raw {
		for _, m := range cardRe.FindAllString(raw, 4) {
			if luhn(m) {
				card = true
			}
		}
		if logEmail.MatchString(raw) {
			email = true
		}
	}
	tpl := templateOf(red)
	if card {
		hits = append(hits, LogHit{Category: LogSecurity, Detector: "personal_data", Class: LogClassLeak, Severity: LogHigh,
			Title: "card number written to the log", Lines: red, SecretKind: "card number",
			Fingerprint: fingerprint("security", "personal_data", "card", tpl),
			Remediation: "Never log card numbers: drop the field or keep only the last four digits."})
	}
	if email {
		hits = append(hits, LogHit{Category: LogSecurity, Detector: "personal_data", Class: LogClassLeak, Severity: LogLow,
			Title: "email address written to the log", Lines: red, SecretKind: "email",
			Fingerprint: fingerprint("security", "personal_data", "email", tpl),
			Remediation: "Log a user id instead of the email address, or mask it."})
	}
	return hits
}

var (
	sqlError    = regexp.MustCompile(`(?i)SQLSTATE|\bpq: |syntax error at or near|You have an error in your SQL syntax|\bORA-\d{5}|sqlite3?\.OperationalError|SqlException|PSQLException|unterminated quoted string`)
	traceInBody = regexp.MustCompile(`goroutine \d+ \[|Traceback \(most recent call last\)|\n\s+at [\w.$<>]+\(|Exception in thread|\.go:\d+|\.py", line \d+`)
)

func detectExposure(ev LogEvent, red, values []string) (LogHit, bool) {
	if ev.Body == "" {
		return LogHit{}, false
	}
	what := ""
	switch {
	case sqlError.MatchString(ev.Body):
		what = "SQL error"
	case traceInBody.MatchString(ev.Body):
		what = "stack trace"
	default:
		return LogHit{}, false
	}
	route := ""
	if ev.Access != nil {
		route = ev.Access.Method + " " + ev.Access.Path
	}
	return LogHit{Category: LogSecurity, Detector: "exposure", Class: LogClassExposure, Severity: LogMedium,
		Title: truncTitle(what + " sent to the client" + suffix(route)), Lines: append(red, "response body: "+RedactLog(ev.Body, values...)),
		Route: route, Fingerprint: fingerprint("security", "exposure", what, NormalizeLogLine(route)),
		Remediation: "Return a generic error to the client and log the details on the server only."}, true
}

func suffix(route string) string {
	if route == "" {
		return ""
	}
	return " on " + route
}

var debugMode = []struct {
	re   *regexp.Regexp
	what string
}{
	{regexp.MustCompile(`\[GIN-debug\]|GIN_MODE=debug|Running in "debug" mode`), "Gin runs in debug mode"},
	{regexp.MustCompile(`Debugger is active!|Debug mode: on`), "the Flask/Werkzeug debugger is on"},
	{regexp.MustCompile(`WARNING: This is a development server`), "a development server serves traffic"},
	{regexp.MustCompile(`(?i)\bAPP_DEBUG\s*=\s*true\b`), "Laravel runs with APP_DEBUG"},
	{regexp.MustCompile(`DEBUG\s*=\s*True`), "Django runs with DEBUG = True"},
}

func detectDebugMode(ev LogEvent, red []string) (LogHit, bool) {
	for _, raw := range ev.Raw {
		for _, d := range debugMode {
			if d.re.MatchString(raw) {
				return LogHit{Category: LogSecurity, Detector: "debug_mode", Class: LogClassConfig, Severity: LogMedium,
					Title: truncTitle(d.what + " in production"), Lines: red, Fingerprint: fingerprint("security", "debug_mode", d.what),
					Remediation: "Turn debug mode off in the production configuration: debug pages show code, settings and sometimes secrets."}, true
			}
		}
	}
	return LogHit{}, false
}

// injectionInput is what an injection probe looks like.
var injectionInput = regexp.MustCompile(`(?i)'\s*or\s+'?\d|'\s*or\s+'[^']*'\s*=\s*'|union\s+(all\s+)?select|;\s*drop\s+table|'\s*--|sleep\(\d+\)|<script\b|\.\./\.\./`)

// detectInjection is best effort: it fires only when the app logs the
// input next to the SQL error, and the input looks like a probe.
func detectInjection(ev LogEvent, red []string) (LogHit, bool) {
	text := strings.Join(ev.Raw, "\n")
	if !sqlError.MatchString(text) || !injectionInput.MatchString(text) {
		return LogHit{}, false
	}
	route := ""
	if ev.Access != nil {
		route = ev.Access.Method + " " + ev.Access.Path
	}
	return LogHit{Category: LogSecurity, Detector: "injection", Class: LogClassWeakness, Severity: LogHigh,
		Title: truncTitle("input that looks like SQL injection reached the database" + suffix(route)), Lines: red, Route: route,
		Fingerprint: fingerprint("security", "injection", NormalizeLogLine(route), templateOf(red)),
		Remediation: "Use parameterized queries (placeholders) for every value from the request on this path."}, true
}

// ---------------------------------------------------------------------
// Access signals for the rate detectors (counted by the use case)

// LogSignal is what an access event counts towards.
type LogSignal string

// Signals.
const (
	SignalNone        LogSignal = ""
	SignalServerError LogSignal = "server_error" // 5xx
	SignalFailedLogin LogSignal = "failed_login"
	SignalProbe       LogSignal = "probe" // a scanner's path, not found
)

var (
	loginPath   = regexp.MustCompile(`(?i)login|signin|sign_in|sign-in|/auth|/token|/session|/oauth|/password`)
	failedLogin = regexp.MustCompile(`(?i)(failed|invalid|incorrect|wrong|bad)\s+(login|password|credentials|username or password)|authentication failed|login failed|invalid_grant`)
	probePath   = regexp.MustCompile(`(?i)^/(?:\.env|\.git/|\.aws/|\.ssh/|\.DS_Store|wp-admin|wp-login\.php|xmlrpc\.php|phpmyadmin|pma/|admin\.php|config\.(?:json|php|yml)|server-status|actuator|\.htaccess|\.svn/|backup\.(?:sql|zip|tar)|db\.sql|cgi-bin/)`)
	routeIDs    = regexp.MustCompile(`/(?:\d+|[0-9a-fA-F-]{16,}|[0-9a-fA-F]{24})(?:/|$)`)
)

// RouteOf normalizes a request path into a route: ids become :id.
func RouteOf(method, path string) string {
	for {
		p := routeIDs.ReplaceAllStringFunc(path, func(s string) string {
			if strings.HasSuffix(s, "/") {
				return "/:id/"
			}
			return "/:id"
		})
		if p == path {
			break
		}
		path = p
	}
	if method == "" {
		return path
	}
	return method + " " + path
}

// SignalOf says what an event counts towards, and the route.
func SignalOf(ev LogEvent) (LogSignal, string) {
	text := strings.Join(ev.Lines, "\n")
	if ev.Access == nil {
		if failedLogin.MatchString(text) {
			return SignalFailedLogin, "login"
		}
		return SignalNone, ""
	}
	a := ev.Access
	route := RouteOf(a.Method, a.Path)
	switch {
	case probePath.MatchString(a.Path) && a.Status >= 400:
		return SignalProbe, "probes"
	case (a.Status == 401 || a.Status == 403) && loginPath.MatchString(a.Path), failedLogin.MatchString(text):
		return SignalFailedLogin, route
	case a.Status >= 500:
		return SignalServerError, route
	}
	return SignalNone, ""
}

// ProbeExposed: a scanner's path was answered with a success, so whatever
// it looks for (.env, .git) is served. That is an exposure at once.
func ProbeExposed(ev LogEvent) (LogHit, bool) {
	a := ev.Access
	if a == nil || a.Status < 200 || a.Status >= 300 || !probePath.MatchString(a.Path) {
		return LogHit{}, false
	}
	return LogHit{Category: LogSecurity, Detector: "probe_exposed", Class: LogClassExposure, Severity: LogHigh,
		Title: truncTitle(fmt.Sprintf("%s is served to anyone (a scanner got %d)", a.Path, a.Status)), Route: a.Path,
		Lines: []string{RedactLog(firstNonEmpty(ev.Lines))}, Fingerprint: fingerprint("security", "probe_exposed", strings.ToLower(a.Path)),
		Remediation: "Stop serving this path: remove the file from the web root or deny it in the server or proxy configuration, and rotate anything it held."}, true
}
