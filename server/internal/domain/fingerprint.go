package domain

import (
	"crypto/sha256"
	"encoding/hex"
	"regexp"
	"slices"
	"strings"
)

// Limits of a log excerpt kept for a failure.
const (
	ExcerptTailLines = 300
	ExcerptMaxBytes  = 64 << 10
	errorBlockLines  = 60
)

// errorStarts find the first line of the first error block in CI output,
// most specific first. Each matches one line.
var errorStarts = []*regexp.Regexp{
	regexp.MustCompile(`^--- FAIL: `),                                     // go test
	regexp.MustCompile(`^panic: `),                                        // go runtime
	regexp.MustCompile(`^\S+\.go:\d+:\d+: `),                              // go build / vet
	regexp.MustCompile(`^(FAILED|ERROR) \S+::`),                           // pytest summary
	regexp.MustCompile(`^_{3,} \S.* _{3,}$`),                              // pytest failure header
	regexp.MustCompile(`^Traceback \(most recent call last\):`),           // python
	regexp.MustCompile(`^\s*● `),                                          // jest
	regexp.MustCompile(`^\s*FAIL\s+\S`),                                   // jest / vitest file
	regexp.MustCompile(`error TS\d+:`),                                    // tsc
	regexp.MustCompile(`^\S+\.(ts|tsx|js|jsx|vue)\s*$`),                   // eslint file header
	regexp.MustCompile(`^error(\[E\d+\])?: `),                             // rustc / cargo
	regexp.MustCompile(`^\[ERROR\] `),                                     // maven
	regexp.MustCompile(`^FAILURE: Build failed`),                          // gradle
	regexp.MustCompile(`^Exception in thread `),                           // java
	regexp.MustCompile(`^##\[error\]`),                                    // github actions
	regexp.MustCompile(`(?i)^(error|fatal)\b.*`),                          // generic
	regexp.MustCompile(`(?i)\b(npm ERR!|ERR_PNPM_|error Command failed)`), // node package managers
}

// logNoise is stripped from every line before anything else: timestamps
// GitHub and GitLab put in front, and ANSI colours.
var (
	ansi        = regexp.MustCompile(`\x1b\[[0-9;?]*[ -/]*[@-~]`)
	lineStamp   = regexp.MustCompile(`^\d{4}-\d\d-\d\dT\d\d:\d\d:\d\d(\.\d+)?Z ?`)
	gitlabStamp = regexp.MustCompile(`^section_(start|end):\d+:\S+\r?`)
)

// CleanLog removes timestamps, colours and carriage-return progress lines.
func CleanLog(raw string) []string {
	raw = ansi.ReplaceAllString(raw, "")
	lines := strings.Split(strings.ReplaceAll(raw, "\r\n", "\n"), "\n")
	out := make([]string, 0, len(lines))
	for _, l := range lines {
		if i := strings.LastIndexByte(l, '\r'); i >= 0 {
			l = l[i+1:] // progress bars redraw the line
		}
		l = lineStamp.ReplaceAllString(l, "")
		l = gitlabStamp.ReplaceAllString(l, "")
		out = append(out, strings.TrimRight(l, " \t"))
	}
	for len(out) > 0 && out[len(out)-1] == "" {
		out = out[:len(out)-1]
	}
	return out
}

// FirstErrorBlock returns the lines of the first error in a cleaned log:
// from the first line that starts an error to the next blank line after at
// least a few lines, capped. nil when nothing looks like an error.
func FirstErrorBlock(lines []string) []string {
	for _, re := range errorStarts {
		for i, l := range lines {
			if !re.MatchString(l) {
				continue
			}
			end := i + 1
			for end < len(lines) && end-i < errorBlockLines {
				if strings.TrimSpace(lines[end]) == "" && end-i >= 3 {
					break
				}
				end++
			}
			return lines[i:end]
		}
	}
	return nil
}

// Excerpt is what is kept of a failed job's log: the first error block,
// then the last lines, capped at ExcerptMaxBytes.
func Excerpt(lines []string) string {
	block := FirstErrorBlock(lines)
	tail := lines
	if len(tail) > ExcerptTailLines {
		tail = tail[len(tail)-ExcerptTailLines:]
	}
	var b strings.Builder
	if len(block) > 0 {
		b.WriteString("=== first error ===\n")
		b.WriteString(strings.Join(block, "\n"))
		b.WriteString("\n\n=== end of the log ===\n")
	}
	b.WriteString(strings.Join(tail, "\n"))
	s := b.String()
	if len(s) > ExcerptMaxBytes {
		// Keep the start (the error block) and the very end.
		half := ExcerptMaxBytes / 2
		s = s[:half] + "\n…\n" + s[len(s)-half:]
	}
	return s
}

// Secrets in logs. CI masks the secrets it knows; these catch what it
// does not (derived values, tokens printed by tools).
var secretPatterns = []struct {
	re   *regexp.Regexp
	with string
}{
	{regexp.MustCompile(`-----BEGIN [A-Z ]*PRIVATE KEY-----[\s\S]*?-----END [A-Z ]*PRIVATE KEY-----`), "[private key]"},
	{regexp.MustCompile(`(?i)\b(bearer|token|basic)\s+[A-Za-z0-9._~+/=-]{16,}`), "$1 [redacted]"},
	{regexp.MustCompile(`\beyJ[A-Za-z0-9_-]{8,}\.[A-Za-z0-9_-]{8,}\.[A-Za-z0-9_-]{8,}`), "[jwt]"},
	{regexp.MustCompile(`\b(AKIA|ASIA)[A-Z0-9]{16}\b`), "[aws key]"},
	{regexp.MustCompile(`\bgh[pousr]_[A-Za-z0-9]{30,}\b`), "[github token]"},
	{regexp.MustCompile(`\bglpat-[A-Za-z0-9_-]{20,}\b`), "[gitlab token]"},
	{regexp.MustCompile(`\bxox[abprs]-[A-Za-z0-9-]{10,}\b`), "[slack token]"},
	{regexp.MustCompile(`\bAIza[0-9A-Za-z_-]{35}\b`), "[google key]"},
	{regexp.MustCompile(`\bsk-[A-Za-z0-9_-]{20,}\b`), "[api key]"},
	{regexp.MustCompile(`([a-z][a-z0-9+.-]*://)[^\s:/@]+:[^\s@/]+@`), "$1[user]:[password]@"},
	{regexp.MustCompile(`(?i)\b((?:api[_-]?key|secret|password|passwd|access[_-]?key|private[_-]?key|client[_-]?secret)\s*[:=]\s*)["']?[^\s"']{6,}`), "$1[redacted]"},
	{regexp.MustCompile(`\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}\b`), "[email]"},
}

// Redact replaces secrets and email addresses in a log.
func Redact(s string) string {
	for _, p := range secretPatterns {
		s = p.re.ReplaceAllString(s, p.with)
	}
	return s
}

// Built-in infra patterns: the runner, the network or the CI service failed,
// not the code. They are matched against the cleaned log.
var infraPatterns = []*regexp.Regexp{
	regexp.MustCompile(`(?i)the runner has received a shutdown signal`),
	regexp.MustCompile(`(?i)lost communication with the server`),
	regexp.MustCompile(`(?i)the operation was canceled`),
	regexp.MustCompile(`(?i)no space left on device`),
	regexp.MustCompile(`(?i)runner system failure`),
	regexp.MustCompile(`(?i)job's log exceeded limit`),
	regexp.MustCompile(`(?i)there was an error while downloading the artifacts`),
	regexp.MustCompile(`(?i)(toomanyrequests|rate limit exceeded|429 too many requests)`),
	regexp.MustCompile(`(?i)(503 service unavailable|502 bad gateway|504 gateway time-?out)`),
	regexp.MustCompile(`(?i)(temporary failure in name resolution|could not resolve host|getaddrinfo (enotfound|eai_again))`),
	regexp.MustCompile(`(?i)(etimedout|econnreset|connection reset by peer|tls handshake timeout)`),
	regexp.MustCompile(`(?i)error pulling image|failed to pull image|manifest unknown`),
	regexp.MustCompile(`(?i)input required and not supplied`),
	regexp.MustCompile(`(?i)(secret|variable) .*(is not set|not defined|empty)`),
	regexp.MustCompile(`(?i)oom-?killed|exit code 137`),
}

// InfraMatch returns the first line of the log that matches an infra
// pattern (built in, or extra), and whether one did. Only the error block
// and the last lines are searched, so a test that prints "ECONNRESET" in
// passing does not count.
func InfraMatch(lines []string, extra []*regexp.Regexp) (string, bool) {
	search := FirstErrorBlock(lines)
	tail := lines
	if len(tail) > 40 {
		tail = tail[len(tail)-40:]
	}
	search = append(append([]string{}, search...), tail...)
	all := append(append([]*regexp.Regexp{}, infraPatterns...), extra...)
	for _, l := range search {
		for _, re := range all {
			if re.MatchString(l) {
				return strings.TrimSpace(l), true
			}
		}
	}
	return "", false
}

// Normalizers: what changes between two runs of the same failure.
var (
	normHex       = regexp.MustCompile(`0x[0-9a-fA-F]+`)
	normUUID      = regexp.MustCompile(`[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}`)
	normSHA       = regexp.MustCompile(`\b[0-9a-f]{12,64}\b`)
	normTime      = regexp.MustCompile(`\d{4}-\d\d-\d\d[T ]\d\d:\d\d:\d\d(\.\d+)?(Z|[+-]\d\d:?\d\d)?`)
	normDuration  = regexp.MustCompile(`\b\d+(\.\d+)?\s?(ns|µs|us|ms|s|m|h|sec|secs|seconds|minutes)\b`)
	normLine      = regexp.MustCompile(`(\.[A-Za-z]{1,5}):\d+(:\d+)?`)
	normTmp       = regexp.MustCompile(`(/tmp|/var/folders|/private/var|/home/runner/work/_temp|C:\\Users\\[^\\]+\\AppData\\Local\\Temp)[^\s:'"]*`)
	normPort      = regexp.MustCompile(`(127\.0\.0\.1|localhost|0\.0\.0\.0|\[::1?\]):\d+`)
	normGoroutine = regexp.MustCompile(`goroutine \d+`)
	normNumber    = regexp.MustCompile(`\b\d+\b`)
	normSpace     = regexp.MustCompile(`\s+`)
	failingTest   = regexp.MustCompile(`^(?:--- FAIL: (\S+)|(?:FAILED|ERROR) (\S+::\S+)|\s*● (.+?)(?: ›.*)?$|\s*FAIL\s+(\S+))`)
)

// NormalizeLine strips what differs between two runs of the same failure:
// addresses, ids, hashes, times, durations, line numbers, temp paths,
// ports and other numbers.
func NormalizeLine(l string) string {
	l = normTime.ReplaceAllString(l, "<time>")
	l = normUUID.ReplaceAllString(l, "<uuid>")
	l = normHex.ReplaceAllString(l, "<hex>")
	l = normSHA.ReplaceAllString(l, "<sha>")
	l = normTmp.ReplaceAllString(l, "<tmp>")
	l = normPort.ReplaceAllString(l, "$1:<port>")
	l = normLine.ReplaceAllString(l, "$1")
	l = normDuration.ReplaceAllString(l, "<dur>")
	l = normGoroutine.ReplaceAllString(l, "goroutine")
	l = normNumber.ReplaceAllString(l, "<n>")
	return strings.TrimSpace(normSpace.ReplaceAllString(l, " "))
}

// FailingTests returns the names of the failing tests a log mentions, in
// order, without duplicates.
func FailingTests(lines []string) []string {
	var out []string
	for _, l := range lines {
		m := failingTest.FindStringSubmatch(l)
		if m == nil {
			continue
		}
		for _, name := range m[1:] {
			if name = strings.TrimSpace(name); name != "" && !slices.Contains(out, name) {
				out = append(out, name)
				break
			}
		}
	}
	return out
}

// Fingerprint identifies a failure across runs: the failing tests when the
// log names them, else the normalized first error block. The job is part
// of it (the same message in lint and in test are two problems), the
// commit and the matrix values are not.
func Fingerprint(job string, lines []string) string {
	h := sha256.New()
	h.Write([]byte(NormalizeLine(job)))
	h.Write([]byte{0})
	if tests := FailingTests(lines); len(tests) > 0 {
		for _, t := range tests {
			h.Write([]byte(NormalizeLine(t)))
			h.Write([]byte{0})
		}
	} else {
		block := FirstErrorBlock(lines)
		if len(block) > 8 {
			block = block[:8]
		}
		if len(block) == 0 && len(lines) > 0 {
			block = lines[max(0, len(lines)-3):]
		}
		for _, l := range block {
			if n := NormalizeLine(l); n != "" {
				h.Write([]byte(n))
				h.Write([]byte{0})
			}
		}
	}
	return hex.EncodeToString(h.Sum(nil))[:32]
}

// FailureTitle is a one-line title for a failure: the first failing test
// with its message, or the first error line.
func FailureTitle(lines []string) string {
	block := FirstErrorBlock(lines)
	title := ""
	if len(block) > 0 {
		title = strings.TrimSpace(block[0])
		// "--- FAIL: TestX (0.01s)" says less than the assertion under it.
		if strings.HasPrefix(title, "--- FAIL: ") && len(block) > 1 {
			name := strings.Fields(strings.TrimPrefix(title, "--- FAIL: "))[0]
			for _, l := range block[1:] {
				if l = strings.TrimSpace(l); l != "" && !strings.HasPrefix(l, "---") {
					title = name + ": " + l
					break
				}
			}
		}
	} else if len(lines) > 0 {
		title = strings.TrimSpace(lines[len(lines)-1])
	}
	title = strings.TrimPrefix(title, "##[error]")
	if r := []rune(title); len(r) > 160 {
		title = string(r[:159]) + "…"
	}
	if title == "" {
		title = "the job failed with no error in its log"
	}
	return title
}
