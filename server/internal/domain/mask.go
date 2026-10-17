package domain

import (
	"net/url"
	"regexp"
	"slices"
	"strings"
)

// NewSecretRedactor returns a redactor for plain secrets (tokens, API keys,
// the values of an invocation's environment): each value as given and its
// URL-encoded forms. Values under 8 characters are left alone, since they
// would mask unrelated text.
func NewSecretRedactor(values ...string) Redactor {
	var r Redactor
	add := func(s string) {
		if len(s) >= 8 && !slices.Contains(r.forms, s) {
			r.forms = append(r.forms, s)
		}
	}
	for _, v := range values {
		v = strings.TrimSpace(v)
		add(v)
		add(url.QueryEscape(v))
		add(url.PathEscape(v))
	}
	slices.SortFunc(r.forms, func(a, b string) int { return len(b) - len(a) })
	return r
}

// Empty reports whether the redactor masks nothing.
func (r Redactor) Empty() bool { return len(r.forms) == 0 }

// maskShapes are what MaskCredentials masks besides credentialShapes: a
// whole private key block, and the value after Bearer or an
// Authorization header. The value classes stop at quotes and backslashes,
// so masking text inside JSON keeps it valid.
var (
	privateKeyBlock = regexp.MustCompile(`-----BEGIN ([A-Z]+ )?PRIVATE KEY( BLOCK)?-----[\s\S]*?-----END ([A-Z]+ )?PRIVATE KEY( BLOCK)?-----`)
	bearerValue     = regexp.MustCompile(`(?i)(\bbearer\s+)[A-Za-z0-9._~+/=-]{16,}`)
	authHeaderValue = regexp.MustCompile(`(?i)(\bauthorization["']?\s*[:=]\s*["']?(?:basic|token)\s+)[A-Za-z0-9._~+/=-]{8,}`)
	passwordURL     = regexp.MustCompile(`\b((?:postgres|postgresql|mysql|mongodb(?:\+srv)?|redis|amqp|https?)://[^:@/\s"'\\]+:)[^@/\s"'\\]{6,}@`)
)

// MaskCredentials masks what looks like a credential in s: the shapes
// LooksLikeSecret knows (GitHub, GitLab, Slack, Anthropic, OpenAI, AWS…),
// private key blocks, Bearer and Authorization values, and passwords in
// URLs. It is the safety net for secrets agnts does not know about, such
// as one Claude read out of a repository's .env.
func MaskCredentials(s string) string {
	s = privateKeyBlock.ReplaceAllString(s, "-----PRIVATE KEY "+Masked+"-----")
	s = passwordURL.ReplaceAllString(s, "${1}"+Masked+"@")
	s = bearerValue.ReplaceAllString(s, "${1}"+Masked)
	s = authHeaderValue.ReplaceAllString(s, "${1}"+Masked)
	for _, re := range credentialShapes {
		if src := re.String(); strings.HasPrefix(src, "-----BEGIN") || strings.Contains(src, "://") {
			continue // key blocks and URLs are handled above
		}
		s = re.ReplaceAllString(s, Masked)
	}
	return s
}
