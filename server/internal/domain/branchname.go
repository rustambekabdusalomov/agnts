package domain

import (
	"fmt"
	"slices"
	"strings"
	"unicode"

	"golang.org/x/text/unicode/norm"
)

// DefaultBranchTemplate names agnts's branches when a repository sets no
// template: the branch prefix and the ticket key (agnts/PAY-42).
const DefaultBranchTemplate = "{prefix}{key}"

// BranchPlaceholders are the placeholders a branch template may use.
var BranchPlaceholders = []string{"prefix", "type", "key", "number", "slug", "user"}

// slugMax caps the {slug} part of a branch name, in bytes.
const slugMax = 40

// BranchVars are the values a branch template is filled with.
type BranchVars struct {
	Prefix string // the repository's branch prefix (agnts/)
	Type   string // the kind of work: feature, bugfix, test, ...
	Key    string // the ticket key (PAY-42)
	Number string // the ticket number (Ticket.Number)
	Title  string // the ticket title, slugged for {slug}
	User   string // whose ticket it is, a username; "" uses agnts
}

// BranchType is the {type} of a branch for work of kind k.
func (k TicketKind) BranchType() string {
	switch k {
	case KindCode, "":
		return "feature"
	case KindBug:
		return "bugfix"
	case KindSwaggerTest:
		return "swagger-test"
	}
	return string(k)
}

// ValidateBranchTemplate reports what is wrong with a branch template:
// an unknown placeholder, no {key} or {number} (which keep branches apart),
// or one that cannot make a valid git branch name. "" is valid and means
// DefaultBranchTemplate.
func ValidateBranchTemplate(tmpl string) error {
	if tmpl == "" {
		return nil
	}
	if err := checkPlaceholders(tmpl, BranchPlaceholders, "branch"); err != nil {
		return err
	}
	if !strings.Contains(tmpl, "{key}") && !strings.Contains(tmpl, "{number}") {
		return fmt.Errorf("branch template must contain {key} or {number}")
	}
	sample := BranchName(tmpl, BranchVars{Prefix: "agnts/", Type: "feature", Key: "PAY-1", Number: "PAY-1", Title: "Sample", User: "dev"})
	if !strings.Contains(sample, "PAY-1") {
		return fmt.Errorf("branch template does not make a valid branch name")
	}
	return nil
}

// checkPlaceholders reports braces that do not pair up and placeholders
// not in known.
func checkPlaceholders(tmpl string, known []string, what string) error {
	rest := tmpl
	for {
		i := strings.IndexAny(rest, "{}")
		if i < 0 {
			break
		}
		if rest[i] == '}' {
			return fmt.Errorf("unexpected } in %s template", what)
		}
		j := strings.IndexByte(rest[i:], '}')
		if j < 0 {
			return fmt.Errorf("unclosed { in %s template", what)
		}
		if name := rest[i+1 : i+j]; !slices.Contains(known, name) {
			return fmt.Errorf("unknown placeholder {%s} in %s template; use %s", name, what, placeholderList(known))
		}
		rest = rest[i+j+1:]
	}
	return nil
}

// BranchName fills a branch template (DefaultBranchTemplate when empty)
// and cleans the result into a valid git branch name.
func BranchName(tmpl string, v BranchVars) string {
	if tmpl == "" {
		tmpl = DefaultBranchTemplate
	}
	user := Slug(v.User, slugMax)
	if user == "" {
		user = "agnts"
	}
	r := strings.NewReplacer(
		"{prefix}", v.Prefix,
		"{type}", Slug(v.Type, slugMax),
		"{key}", v.Key,
		"{number}", v.Number,
		"{slug}", Slug(v.Title, slugMax),
		"{user}", user,
	)
	return cleanRef(r.Replace(tmpl))
}

// Slug makes s a lowercase ASCII slug of at most max bytes, words joined
// by hyphens and cut at a word boundary: "Add login page!" -> add-login-page.
// Accents are dropped and Cyrillic is transliterated.
func Slug(s string, max int) string {
	var b strings.Builder
	dash := false
	put := func(c rune) {
		switch {
		case unicode.Is(unicode.Mn, c), strings.ContainsRune("'‘’ʻʼьъ", c):
			// accents, the apostrophes of o‘ and g‘, and the soft and hard signs
		case c < unicode.MaxASCII && (unicode.IsLetter(c) || unicode.IsDigit(c)):
			b.WriteRune(c)
			dash = false
		default:
			if !dash && b.Len() > 0 {
				b.WriteByte('-')
				dash = true
			}
		}
	}
	for _, c := range strings.ToLower(s) {
		if t, ok := cyrillic[c]; ok {
			b.WriteString(t)
			dash = false
			continue
		}
		for _, d := range norm.NFD.String(string(c)) {
			put(d)
		}
	}
	out := strings.TrimRight(b.String(), "-")
	if len(out) > max {
		out = out[:max]
		if i := strings.LastIndexByte(out, '-'); i > 0 {
			out = out[:i]
		}
		out = strings.TrimRight(out, "-")
	}
	return out
}

// cleanRef turns s into a name git accepts for a branch (see git
// check-ref-format): characters git forbids become hyphens, and no part
// between slashes is empty, starts with a dot or ends with .lock.
func cleanRef(s string) string {
	var b strings.Builder
	for _, c := range s {
		switch {
		case c < unicode.MaxASCII && (unicode.IsLetter(c) || unicode.IsDigit(c)), c == '-', c == '_', c == '.', c == '/':
			b.WriteRune(c)
		default:
			b.WriteByte('-')
		}
	}
	parts := strings.Split(b.String(), "/")
	out := parts[:0]
	for _, p := range parts {
		for strings.Contains(p, "--") {
			p = strings.ReplaceAll(p, "--", "-")
		}
		for strings.Contains(p, "..") {
			p = strings.ReplaceAll(p, "..", ".")
		}
		p = strings.Trim(p, "-.")
		p = strings.TrimSuffix(p, ".lock")
		if p != "" {
			out = append(out, p)
		}
	}
	return strings.Join(out, "/")
}

func placeholderList(known []string) string {
	ps := make([]string, len(known))
	for i, p := range known {
		ps[i] = "{" + p + "}"
	}
	return strings.Join(ps, " ")
}

// cyrillic transliterates Russian and Uzbek Cyrillic letters to Latin.
var cyrillic = map[rune]string{
	'а': "a", 'б': "b", 'в': "v", 'г': "g", 'д': "d", 'е': "e", 'ё': "yo", 'ж': "zh", 'з': "z", 'и': "i",
	'й': "y", 'к': "k", 'л': "l", 'м': "m", 'н': "n", 'о': "o", 'п': "p", 'р': "r", 'с': "s", 'т': "t",
	'у': "u", 'ф': "f", 'х': "x", 'ц': "ts", 'ч': "ch", 'ш': "sh", 'щ': "sch", 'ы': "y", 'э': "e",
	'ю': "yu", 'я': "ya", 'ў': "o", 'қ': "q", 'ғ': "g", 'ҳ': "h",
}
