package domain

import (
	"encoding/base64"
	"math"
	"net/url"
	"path"
	"regexp"
	"slices"
	"strings"
)

// credentialShapes match credentials with a recognisable shape. They follow
// the common gitleaks rules, rewritten for RE2.
var credentialShapes = []*regexp.Regexp{
	regexp.MustCompile(`\b(AKIA|ASIA)[0-9A-Z]{16}\b`),                                                       // AWS access key id
	regexp.MustCompile(`\bgh[pousr]_[A-Za-z0-9]{36,}\b`),                                                    // GitHub token
	regexp.MustCompile(`\bgithub_pat_[A-Za-z0-9_]{60,}`),                                                    // GitHub fine-grained token
	regexp.MustCompile(`\bglpat-[A-Za-z0-9_-]{20,}`),                                                        // GitLab token
	regexp.MustCompile(`\bxox[abprs]-[A-Za-z0-9-]{10,}`),                                                    // Slack token
	regexp.MustCompile(`\b[rs]k_live_[A-Za-z0-9]{20,}`),                                                     // Stripe live key
	regexp.MustCompile(`\bAIza[0-9A-Za-z_-]{35}\b`),                                                         // Google API key
	regexp.MustCompile(`\bsk-ant-[A-Za-z0-9_-]{20,}`),                                                       // Anthropic key
	regexp.MustCompile(`\bsk-(proj-)?[A-Za-z0-9_-]{32,}`),                                                   // OpenAI key
	regexp.MustCompile(`\b\d{8,10}:AA[A-Za-z0-9_-]{33}\b`),                                                  // Telegram bot token
	regexp.MustCompile(`-----BEGIN ([A-Z]+ )?PRIVATE KEY( BLOCK)?-----`),                                    // private key
	regexp.MustCompile(`\b(postgres|postgresql|mysql|mongodb(\+srv)?|redis|amqp)://[^:@/\s]+:[^@/\s]{6,}@`), // URL with a password
}

// secretAssign matches a credential-like name assigned a quoted literal.
var secretAssign = regexp.MustCompile(`(?i)(api[_-]?key|secret|token|passwd|password|private[_-]?key|access[_-]?key|client[_-]?secret|auth)["']?\s*[:=]\s*["']([^"'\s]{16,})["']`)

// placeholder words make an assigned value an example, not a secret.
var placeholder = regexp.MustCompile(`(?i)example|sample|dummy|placeholder|changeme|change[_-]me|your[_-]|xxxx|\*\*\*|<|\$\{|\{\{|test|fake|redacted|todo`)

// LooksLikeSecret reports whether a line holds what looks like a real
// credential.
func LooksLikeSecret(line string) bool {
	for _, re := range credentialShapes {
		if re.MatchString(line) {
			return true
		}
	}
	for _, m := range secretAssign.FindAllStringSubmatch(line, -1) {
		v := m[2]
		if placeholder.MatchString(v) {
			continue
		}
		if entropy(v) >= 3.5 {
			return true
		}
	}
	return false
}

// entropy is the Shannon entropy of s in bits per character.
func entropy(s string) float64 {
	if s == "" {
		return 0
	}
	counts := map[rune]int{}
	for _, r := range s {
		counts[r]++
	}
	n := float64(len([]rune(s)))
	h := 0.0
	for _, c := range counts {
		p := float64(c) / n
		h -= p * math.Log2(p)
	}
	return h
}

// SecretAllowed reports whether p is a place where example credentials are
// expected: test data, fixtures and example files, plus the extra globs a
// repository allows.
func SecretAllowed(p string, extra []string) bool {
	lower := strings.ToLower(p)
	for _, dir := range []string{"testdata/", "fixtures/", "__fixtures__/", "__mocks__/"} {
		if strings.HasPrefix(lower, dir) || strings.Contains(lower, "/"+dir) {
			return true
		}
	}
	base := path.Base(lower)
	for _, suf := range []string{".example", ".sample", ".template", ".dist"} {
		if strings.HasSuffix(base, suf) {
			return true
		}
	}
	for _, g := range extra {
		if ok, _ := path.Match(g, p); ok {
			return true
		}
		if strings.HasSuffix(g, "/**") && strings.HasPrefix(p, strings.TrimSuffix(g, "**")) {
			return true
		}
	}
	return false
}

// IsEnvFile reports whether p is a dotenv file that may hold real values
// (.env, .env.local), not an example of one (.env.example).
func IsEnvFile(p string) bool {
	base := path.Base(p)
	if base != ".env" && !strings.HasPrefix(base, ".env.") {
		return false
	}
	for _, suf := range []string{".example", ".sample", ".template", ".dist", ".defaults"} {
		if strings.HasSuffix(base, suf) {
			return false
		}
	}
	return true
}

// Masked replaces a redacted credential.
const Masked = "•••"

// Redactor removes one credential, in every form it travels in, from text
// agnts stores or shows.
type Redactor struct {
	forms []string
}

// NewRedactor returns a redactor for a credential of kind auth: the exact
// value, the value without a "Bearer " prefix, its URL-encoded form (query
// keys) and, for basic auth, base64 of user:password. Values under 4
// characters are not redacted as text (they would mask unrelated words);
// the headers that carry them still are.
func NewRedactor(kind APIAuthKind, value string) Redactor {
	var r Redactor
	add := func(s string) {
		if len(s) >= 4 && !slices.Contains(r.forms, s) {
			r.forms = append(r.forms, s)
		}
	}
	value = strings.TrimSpace(value)
	values := []string{value}
	if v, ok := strings.CutPrefix(value, "Bearer "); ok {
		values = append(values, v)
	}
	for _, v := range values {
		add(v)
		add(url.QueryEscape(v))
		add(url.PathEscape(v))
	}
	if kind == AuthBasic {
		value = BasicCredentials(value) // an encoded token is masked as given above, and as user:password here
		add(value)
		add(base64.StdEncoding.EncodeToString([]byte(value)))
		add(base64.RawStdEncoding.EncodeToString([]byte(value)))
		if _, pass, ok := strings.Cut(value, ":"); ok {
			add(pass)
		}
	}
	// Longest first, so a form inside another is not replaced first.
	slices.SortFunc(r.forms, func(a, b string) int { return len(b) - len(a) })
	return r
}

// String returns s with every form of the credential masked.
func (r Redactor) String(s string) string {
	for _, f := range r.forms {
		s = strings.ReplaceAll(s, f, Masked)
	}
	return s
}

// Bytes is String for JSON and other text kept as bytes.
func (r Redactor) Bytes(b []byte) []byte {
	if len(r.forms) == 0 {
		return b
	}
	return []byte(r.String(string(b)))
}

// sensitiveHeaders are always masked in logged requests and responses.
var sensitiveHeaders = []string{"authorization", "proxy-authorization", "cookie", "set-cookie", "x-api-key", "x-auth-token"}

// Headers masks the headers that carry credentials (and extra, the
// configured API key header), and the credential anywhere else.
func (r Redactor) Headers(h map[string]string, extra string) map[string]string {
	if h == nil {
		return nil
	}
	out := make(map[string]string, len(h))
	for k, v := range h {
		lk := strings.ToLower(k)
		if slices.Contains(sensitiveHeaders, lk) || (extra != "" && lk == strings.ToLower(extra)) {
			out[k] = Masked
			continue
		}
		out[k] = r.String(v)
	}
	return out
}

// Exchange redacts one logged request and response.
func (r Redactor) Exchange(e APIExchange, apiKeyHeader string) APIExchange {
	e.URL = r.String(e.URL)
	e.ReqHeaders = r.Headers(e.ReqHeaders, apiKeyHeader)
	e.RespHeaders = r.Headers(e.RespHeaders, apiKeyHeader)
	e.ReqBody = r.String(e.ReqBody)
	e.RespBody = r.String(e.RespBody)
	e.Error = r.String(e.Error)
	return e
}
