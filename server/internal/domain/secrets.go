package domain

import (
	"math"
	"path"
	"regexp"
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
