package domain

import (
	"fmt"
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
	FlagSecret         = "secret"            // what looks like a real credential
	FlagEnvFile        = "env_file"          // a dotenv file with real values added
	FlagDebug          = "debug_leftover"    // console.log, debugger, breakpoint() and the like
	FlagCheckConfig    = "check_config"      // the configuration of a linter, type checker, test runner or CI changed
	FlagRuleViolation  = "rule_violation"    // a team rule agnts enforces was broken
)

// FlagKinds lists every red flag kind, in the order the UI shows them.
var FlagKinds = []string{FlagSecret, FlagEnvFile, FlagSkippedTest, FlagRemovedAssert, FlagDeletedTest, FlagSilencedLint,
	FlagCheckConfig, FlagSwallowedError, FlagRuleViolation, FlagDebug, FlagTodo, FlagNewDependency}

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
	// reDebug matches debugging left in code: it never belongs in a change.
	reDebug = regexp.MustCompile(`\bconsole\.(log|debug|trace)\(|^\s*debugger;?\s*$|\bbreakpoint\(\)|\bpdb\.set_trace\(|\bbinding\.pry\b|\bbyebug\b|\bdbg!\(|\bvar_dump\(|\bdd\(|\bspew\.Dump\(`)
)

// checkConfigNames are the files that configure a linter, type checker,
// formatter, test runner or CI: changing one can make checks pass without
// fixing the code.
var checkConfigNames = map[string]bool{
	".golangci.yml": true, ".golangci.yaml": true, ".golangci.toml": true, ".eslintrc": true, ".eslintignore": true,
	".prettierrc": true, ".prettierignore": true, ".stylelintrc": true, "ruff.toml": true, ".ruff.toml": true, "mypy.ini": true,
	".flake8": true, "setup.cfg": true, "tox.ini": true, ".pylintrc": true, ".rubocop.yml": true, "phpstan.neon": true,
	"phpstan.neon.dist": true, ".swiftlint.yml": true, "clippy.toml": true, "rustfmt.toml": true, "detekt.yml": true,
	".pre-commit-config.yaml": true, ".gitlab-ci.yml": true, "Jenkinsfile": true, "biome.json": true, "deno.json": true,
	"jest.config.js": true, "jest.config.ts": true, "vitest.config.ts": true, "vitest.config.js": true, "pytest.ini": true,
	"karma.conf.js": true, "analysis_options.yaml": true, ".editorconfig": false,
}

// IsCheckConfig reports whether p configures the checks: a linter, type
// checker, formatter, test runner or CI pipeline.
func IsCheckConfig(p string) bool {
	base := path.Base(p)
	if checkConfigNames[base] {
		return true
	}
	switch {
	case strings.HasPrefix(base, ".eslintrc"), strings.HasPrefix(base, "eslint.config."), strings.HasPrefix(base, ".prettierrc"),
		strings.HasPrefix(base, "prettier.config."), strings.HasPrefix(base, "tsconfig") && strings.HasSuffix(base, ".json"),
		strings.HasPrefix(base, "jest.config."), strings.HasPrefix(base, "vitest.config."), strings.HasPrefix(base, ".stylelintrc"):
		return true
	}
	return strings.HasPrefix(p, ".github/workflows/") || strings.HasPrefix(p, ".circleci/") || strings.Contains(p, "/.github/workflows/")
}

// LineFlag returns the red flag kind of a line added to the file at p, or
// "" when the line looks fine. The scan of a change and agnts-guard, which
// checks edits as Claude makes them, share it.
func LineFlag(p, text string) string {
	test := IsTestFile(p)
	switch {
	case LooksLikeSecret(text):
		return FlagSecret
	case reSkip.MatchString(text) && (test || strings.Contains(text, "Skip")):
		return FlagSkippedTest
	case reLint.MatchString(text):
		return FlagSilencedLint
	case reSwallow.MatchString(text):
		return FlagSwallowedError
	case reTodo.MatchString(text) && isComment(text):
		return FlagTodo
	case !test && reDebug.MatchString(text) && debugChecked(p):
		return FlagDebug
	}
	if re, ok := isManifest(p); ok && re.MatchString(text) {
		return FlagNewDependency
	}
	return ""
}

// debugChecked reports whether debug output in p is a leftover: scripts,
// command-line tools and docs print on purpose.
func debugChecked(p string) bool {
	lower := strings.ToLower(p)
	for _, dir := range []string{"scripts/", "script/", "bin/", "cmd/", "tools/", "examples/", "docs/", "cli/"} {
		if strings.HasPrefix(lower, dir) || strings.Contains(lower, "/"+dir) {
			return false
		}
	}
	switch path.Ext(lower) {
	case ".md", ".mdx", ".txt", ".sh", ".mjs", ".cjs":
		return false
	}
	return true
}

// CountAsserts counts the assertion lines in text.
func CountAsserts(text string) int {
	n := 0
	for _, l := range strings.Split(text, "\n") {
		if reAssert.MatchString(l) {
			n++
		}
	}
	return n
}

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
//
// secretAllow are extra path globs where example credentials are expected.
func ScanRedFlags(files []FileChange, secretAllow ...string) []RedFlag {
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
		secretOK := SecretAllowed(f.Path, secretAllow)
		if test && f.Add == 0 && f.Del > 0 && deletedFile(f.Diff) {
			if !add(RedFlag{Kind: FlagDeletedTest, Path: f.Path, Text: "test file deleted"}) {
				return out
			}
			continue
		}
		if IsEnvFile(f.Path) && !deletedFile(f.Diff) && f.Add > 0 && !secretOK {
			if !add(RedFlag{Kind: FlagEnvFile, Path: f.Path, Text: "a dotenv file is part of the change"}) {
				return out
			}
			continue
		}
		if IsCheckConfig(f.Path) && (f.Add > 0 || f.Del > 0) {
			if !add(RedFlag{Kind: FlagCheckConfig, Path: f.Path, Text: fmt.Sprintf("check configuration changed (+%d −%d)", f.Add, f.Del)}) {
				return out
			}
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
				kind := LineFlag(f.Path, text)
				if kind == FlagSecret {
					if secretOK {
						kind = ""
					} else {
						text = MaskSecret(text)
					}
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

// MaskSecret hides most of each credential in a line, so a flagged secret
// is never stored or shown in full.
func MaskSecret(line string) string {
	mask := func(v string) string {
		if len(v) <= 8 {
			return "****"
		}
		return v[:4] + strings.Repeat("*", min(len(v)-4, 12))
	}
	for _, re := range credentialShapes {
		line = re.ReplaceAllStringFunc(line, mask)
	}
	return secretAssign.ReplaceAllStringFunc(line, func(m string) string {
		sub := secretAssign.FindStringSubmatch(m)
		return strings.Replace(m, sub[2], mask(sub[2]), 1)
	})
}
