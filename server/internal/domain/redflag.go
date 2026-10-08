package domain

import (
	"path"
	"regexp"
	"strconv"
	"strings"
)

// RedFlag kinds: patterns in a change that often mean an agent made the
// checks pass instead of making the code right.
const (
	FlagSkippedTest    = "skipped_test"      // a test skipped or focused
	FlagRemovedAssert  = "removed_assertion" // fewer assertions in a test file
	FlagDeletedTest    = "deleted_test"      // a test file deleted
	FlagSilencedLint   = "silenced_lint"     // a linter or type checker told to look away
	FlagSwallowedError = "swallowed_error"   // an error caught and dropped
	FlagTodo           = "todo"              // a TODO, FIXME or HACK left behind
	FlagNewDependency  = "new_dependency"    // a dependency added to a manifest
)

// RedFlag is one thing agnts's scan of a change flagged for the reviewer.
type RedFlag struct {
	Kind string `json:"kind"`
	Path string `json:"path"`
	Line int    `json:"line,omitempty"` // in the new file; 0 for the whole file
	Text string `json:"text"`           // the line, trimmed and capped
}

// MaxRedFlags caps what one change keeps.
const MaxRedFlags = 40

var (
	reSkip = regexp.MustCompile(`\bt\.Skip(Now|f)?\(|\b(it|describe|test|context)\.(skip|only)\(|\b(xit|xdescribe|xtest|fit|fdescribe)\(|` +
		`@pytest\.mark\.(skip|xfail)|@unittest\.skip|@(Disabled|Ignore)\b|\[(Ignore|Skip)\b|#\[ignore\]|\bskip\s*\(\s*["']|pending\(`)
	reLint = regexp.MustCompile(`eslint-disable|//\s*nolint|@ts-ignore|@ts-nocheck|#\s*type:\s*ignore|#\s*noqa|@SuppressWarnings|` +
		`#!?\[allow\(|#\s*pylint:\s*disable|//\s*@phpstan-ignore|#\s*rubocop:disable|//\s*swiftlint:disable|@phan-suppress`)
	reSwallow = regexp.MustCompile(`catch\s*(\([^)]*\))?\s*\{\s*\}|except[^:\n]*:\s*(pass|\.\.\.)\s*$|\bif\s+err\s*!=\s*nil\s*\{\s*\}|` +
		`^\s*_\s*=\s*err\s*$|rescue\s*(=>\s*\w+)?\s*;?\s*end\b|\.catch\(\s*\(\s*\w*\s*\)\s*=>\s*\{\s*\}\s*\)|catch\s*\(\s*\w*\s*\)\s*\{\s*\}`)
	reTodo   = regexp.MustCompile(`\b(TODO|FIXME|XXX|HACK)\b`)
	reAssert = regexp.MustCompile(`\bassert|\bexpect\s*\(|\brequire\.|\bt\.(Error|Fatal)|\bshould\b|\bverify\(|\bAssert\.|\bcheck\.|\.to(Be|Equal|Have|Match|Throw)`)
	reHunk   = regexp.MustCompile(`^@@ -\d+(?:,\d+)? \+(\d+)(?:,\d+)? @@`)
)

// manifestDep matches an added line that declares a dependency, per
// manifest file name.
var manifestDep = map[string]*regexp.Regexp{
	"package.json":     regexp.MustCompile(`^\s*"(@?[\w.-]+/)?[\w.-]+"\s*:\s*"(\^|~|>=|<|\d|\*|workspace:|npm:|git|https?:|file:|link:)`),
	"go.mod":           regexp.MustCompile(`^\s*(require\s+)?[\w.-]+\.[\w.-]+/\S+\s+v\d`),
	"requirements.txt": regexp.MustCompile(`^\s*[A-Za-z0-9_.\[\]-]+\s*(==|>=|<=|~=|!=|>|<|$)`),
	"pyproject.toml":   regexp.MustCompile(`^\s*"[A-Za-z0-9_.\[\]-]+\s*(==|>=|<=|~=|!=|>|<|\^)?[^"]*",?\s*$|^\s*[A-Za-z0-9_-]+\s*=\s*["{]`),
	"Cargo.toml":       regexp.MustCompile(`^\s*[A-Za-z0-9_-]+\s*=\s*("[\^~=<>]?\d|\{)`),
	"Gemfile":          regexp.MustCompile(`^\s*gem\s+["']`),
	"composer.json":    regexp.MustCompile(`^\s*"[\w.-]+/[\w.-]+"\s*:\s*"`),
	"pom.xml":          regexp.MustCompile(`<artifactId>`),
	"build.gradle":     regexp.MustCompile(`^\s*(implementation|api|compileOnly|runtimeOnly|testImplementation)\b`),
	"build.gradle.kts": regexp.MustCompile(`^\s*(implementation|api|compileOnly|runtimeOnly|testImplementation)\(`),
	"pubspec.yaml":     regexp.MustCompile(`^\s{2}[a-z0-9_]+:\s*(\^|\d|any|$)`),
}

// IsTestFile reports whether a path looks like a test.
func IsTestFile(p string) bool {
	base := path.Base(p)
	lower := strings.ToLower(p)
	switch {
	case strings.HasSuffix(base, "_test.go"), strings.Contains(base, ".test."), strings.Contains(base, ".spec."),
		strings.HasPrefix(base, "test_") && strings.HasSuffix(base, ".py"), strings.HasSuffix(base, "_test.py"),
		strings.HasSuffix(base, "Test.java"), strings.HasSuffix(base, "Tests.cs"), strings.HasSuffix(base, "_spec.rb"),
		strings.HasSuffix(base, "Test.kt"), strings.HasSuffix(base, "_test.dart"):
		return true
	}
	return strings.Contains(lower, "/__tests__/") || strings.HasPrefix(lower, "__tests__/")
}

func isManifest(p string) (*regexp.Regexp, bool) {
	base := path.Base(p)
	if strings.HasPrefix(base, "requirements") && strings.HasSuffix(base, ".txt") {
		base = "requirements.txt"
	}
	re, ok := manifestDep[base]
	return re, ok
}

// ScanRedFlags looks through a change's per-file unified diffs for the
// patterns that often mean the checks were made to pass the wrong way.
// It flags added lines only (and net-removed assertions), so code the
// change merely moved past is not blamed on it.
func ScanRedFlags(files []FileChange) []RedFlag {
	out := []RedFlag{}
	add := func(f RedFlag) bool {
		if len(out) >= MaxRedFlags {
			return false
		}
		f.Text = clip(strings.TrimSpace(f.Text), 200)
		out = append(out, f)
		return true
	}
	for _, f := range files {
		test := IsTestFile(f.Path)
		manifest, isMan := isManifest(f.Path)
		if test && f.Add == 0 && f.Del > 0 && deletedFile(f.Diff) {
			if !add(RedFlag{Kind: FlagDeletedTest, Path: f.Path, Text: "test file deleted"}) {
				return out
			}
			continue
		}
		line, addedAsserts, removedAsserts, firstRemoved := 0, 0, 0, ""
		for _, l := range strings.Split(f.Diff, "\n") {
			if m := reHunk.FindStringSubmatch(l); m != nil {
				line, _ = strconv.Atoi(m[1])
				continue
			}
			switch {
			case strings.HasPrefix(l, "+++"), strings.HasPrefix(l, "---"):
				continue
			case strings.HasPrefix(l, "+"):
				text := l[1:]
				kind := ""
				switch {
				case reSkip.MatchString(text) && (test || strings.Contains(text, "Skip")):
					kind = FlagSkippedTest
				case reLint.MatchString(text):
					kind = FlagSilencedLint
				case reSwallow.MatchString(text):
					kind = FlagSwallowedError
				case reTodo.MatchString(text) && isComment(text):
					kind = FlagTodo
				case isMan && manifest.MatchString(text):
					kind = FlagNewDependency
				}
				if kind != "" && !add(RedFlag{Kind: kind, Path: f.Path, Line: line, Text: text}) {
					return out
				}
				if test && reAssert.MatchString(text) {
					addedAsserts++
				}
				line++
			case strings.HasPrefix(l, "-"):
				if test && reAssert.MatchString(l[1:]) {
					removedAsserts++
					if firstRemoved == "" {
						firstRemoved = l[1:]
					}
				}
			case strings.HasPrefix(l, " "):
				line++
			}
		}
		if removedAsserts > addedAsserts {
			n := removedAsserts - addedAsserts
			text := strconv.Itoa(n) + " fewer assertion"
			if n > 1 {
				text += "s"
			}
			if !add(RedFlag{Kind: FlagRemovedAssert, Path: f.Path, Text: text + ", e.g. " + strings.TrimSpace(firstRemoved)}) {
				return out
			}
		}
	}
	return out
}

func deletedFile(diff string) bool {
	return strings.Contains(diff, "deleted file mode") || strings.Contains(diff, "+++ /dev/null")
}

// isComment reports whether a line holds a comment, so a TODO in a string
// or an identifier is not flagged.
func isComment(s string) bool {
	for _, c := range []string{"//", "#", "/*", "*", "<!--", "--", ";"} {
		if i := strings.Index(s, c); i >= 0 {
			if j := reTodo.FindStringIndex(s); j != nil && j[0] > i {
				return true
			}
		}
	}
	return false
}
