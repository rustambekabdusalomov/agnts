package toolchain

import (
	"path"
	"strings"

	"agnts/internal/domain"
)

// EditChecks returns the quick per-file checks agnts-guard runs after each
// edit, for a repository's toolchains: formatters and linters that check
// one file in seconds. A tool the run does not have is skipped quietly
// (the commands test for it first), so a guess here never costs Claude a
// turn. {file} is the edited file and {dir} its directory, both relative
// to /workspace and shell-quoted.
func EditChecks(tcs []domain.Toolchain) []domain.EditCheck {
	var out []domain.EditCheck
	seen := map[string]bool{}
	add := func(c domain.EditCheck) {
		if !seen[c.Name] {
			seen[c.Name] = true
			out = append(out, c)
		}
	}
	for _, tc := range tcs {
		globs := func(exts ...string) []string {
			var g []string
			for _, e := range exts {
				if tc.Dir == "" {
					g = append(g, "**/*"+e)
				} else {
					g = append(g, path.Join(tc.Dir, "**", "*"+e))
				}
			}
			return g
		}
		// in runs cmd from the toolchain's directory, where its config and
		// node_modules live; {file} is made absolute for it.
		in := func(cmd string) string {
			if tc.Dir == "" {
				return cmd
			}
			return "cd " + shellQuote(tc.Dir) + " && " + cmd
		}
		suffix := ""
		if tc.Dir != "" {
			suffix = " (" + tc.Dir + ")"
		}
		switch tc.Tool {
		case "go":
			add(domain.EditCheck{Name: "gofmt" + suffix, Globs: globs(".go"),
				Cmd: `f={file}; out=$(gofmt -l "$f" 2>&1) || { echo "$out"; exit 1; }; if [ -n "$out" ]; then echo "$f is not gofmt-formatted (gofmt -w $f fixes it):"; gofmt -d "$f" | head -40; exit 1; fi`})
			add(domain.EditCheck{Name: "go vet" + suffix, Globs: globs(".go"), Every: 30,
				Cmd: `cd {dir} && go vet . 2>&1 | grep -v '^#' ; exit ${PIPESTATUS[0]}`})
		case "node", "bun", "deno":
			add(domain.EditCheck{Name: "eslint" + suffix, Globs: globs(".js", ".jsx", ".ts", ".tsx", ".vue", ".mjs", ".cjs"),
				Cmd: in(`if [ -x node_modules/.bin/eslint ]; then node_modules/.bin/eslint --no-warn-ignored /workspace/{file}; fi`)})
			add(domain.EditCheck{Name: "prettier" + suffix, Globs: globs(".js", ".jsx", ".ts", ".tsx", ".vue", ".css", ".scss", ".json", ".md"),
				Cmd: in(`if [ -x node_modules/.bin/prettier ] && ls .prettierrc* prettier.config.* >/dev/null 2>&1; then node_modules/.bin/prettier --check --log-level warn /workspace/{file}; fi`)})
		case "python", "uv":
			add(domain.EditCheck{Name: "ruff" + suffix, Globs: globs(".py"),
				Cmd: in(`if command -v ruff >/dev/null; then ruff check --quiet /workspace/{file}; fi`)})
		case "rust":
			add(domain.EditCheck{Name: "rustfmt" + suffix, Globs: globs(".rs"),
				Cmd: `if command -v rustfmt >/dev/null; then rustfmt --check --edition 2021 {file}; fi`})
		case "ruby":
			add(domain.EditCheck{Name: "rubocop" + suffix, Globs: globs(".rb"),
				Cmd: in(`if [ -x bin/rubocop ]; then bin/rubocop --format quiet /workspace/{file}; fi`)})
		case "dart", "flutter":
			add(domain.EditCheck{Name: "dart format" + suffix, Globs: globs(".dart"),
				Cmd: `if command -v dart >/dev/null; then dart format --output=none --set-exit-if-changed {file}; fi`})
		}
	}
	return out
}

// CoverageReportDir is where derived coverage commands write their report
// (a volume of the run, which agnts can read back).
const CoverageReportDir = "/agnts/out/coverage"

// Coverage returns a command that runs a repository's tests with coverage
// and the report it writes, derived from its toolchains and test command;
// "" when agnts knows none. The report is a Go cover profile or lcov.
func Coverage(tcs []domain.Toolchain, testCmd string) (cmd, report string) {
	for _, tc := range tcs {
		cd := ""
		if tc.Dir != "" {
			cd = "cd " + shellQuote(tc.Dir) + " && "
		}
		switch tc.Tool {
		case "go":
			report = CoverageReportDir + "/go.out"
			return "mkdir -p " + CoverageReportDir + " && " + cd + "go test -coverprofile=" + report + " ./...", report
		case "node", "bun":
			report = CoverageReportDir + "/lcov.info"
			switch {
			case strings.Contains(testCmd, "vitest"):
				return cd + "npx vitest run --coverage.enabled --coverage.reporter=lcov --coverage.reportsDirectory=" + CoverageReportDir, report
			case strings.Contains(testCmd, "jest"):
				return cd + "npx jest --coverage --coverageReporters=lcov --coverageDirectory=" + CoverageReportDir, report
			}
		case "python", "uv":
			if strings.Contains(testCmd, "pytest") {
				report = CoverageReportDir + "/lcov.info"
				return "mkdir -p " + CoverageReportDir + " && " + cd + "python -m coverage run -m pytest && python -m coverage lcov -o " + report, report
			}
		case "rust":
			report = CoverageReportDir + "/lcov.info"
			return "mkdir -p " + CoverageReportDir + " && " + cd + "cargo llvm-cov --lcov --output-path " + report, report
		}
	}
	return "", ""
}
