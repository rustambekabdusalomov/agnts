package orchestrator

import (
	"bytes"
	"encoding/json"
	"fmt"
	"slices"
	"strings"
	"text/template"

	"agnts/internal/domain"
	"agnts/internal/toolchain"
)

// Files Claude Code writes for agnts to read back. stream-json output has no
// structured result, so the contract is a file outside the repository.
const (
	AnalysisPath = "/agnts/out/analysis.json"
	SummaryPath  = "/agnts/out/summary.json"
	LessonsPath  = "/agnts/out/lessons.json"
	RulePath     = "/agnts/out/rule.json"
	ReportPath   = "/agnts/out/report.md"
	ReviewPath   = "/agnts/out/review.json"
	// ChangePath is where agnts puts the reviewed diff for the learn and
	// review runs.
	ChangePath = "/agnts/out/change.diff"
)

// Analysis is what the analyze stage must write to AnalysisPath.
type Analysis struct {
	Summary string   `json:"summary"`
	Plan    []string `json:"plan"`
	// Kind is the kind of work the ticket asks for, in Claude's reading.
	Kind       domain.TicketKind `json:"kind"`
	KindReason string            `json:"kindReason"`
	// Complexity is simple or complex; it picks the review model on auto.
	Complexity string `json:"complexity"`
	Questions  []struct {
		Text    string   `json:"text"`
		Options []string `json:"options"`
		// Multiple: the options do not exclude each other; the author
		// may pick several.
		Multiple bool `json:"multiple"`
	} `json:"questions"`
	// FollowUps are prerequisites and parts to split off, when asked for.
	FollowUps []domain.FollowUp `json:"followUps,omitempty"`
	// Footprint is what the work is expected to change (tickets with a
	// repository). The queue compares footprints to keep colliding tickets
	// apart, and checks it against the real diff.
	Footprint *domain.Footprint `json:"footprint,omitempty"`
	// Relations say how this ticket depends on or collides with the other
	// open tickets the prompt listed.
	Relations []RelationClaim `json:"relations,omitempty"`
}

// Summary is what a coding run should write to SummaryPath.
type Summary struct {
	Summary string   `json:"summary"`
	Notes   []string `json:"notes"`
	// FollowUps are what the ticket still needs after this run, when asked for.
	FollowUps []domain.FollowUp `json:"followUps,omitempty"`
}

// kindWork describes each kind's work to Claude.
var kindWork = map[domain.TicketKind]string{
	domain.KindCode:     "implement a change in the code",
	domain.KindTest:     "write or fix automated tests",
	domain.KindPlan:     "write an implementation plan for a change, without making it",
	domain.KindAnalysis: "research a question (about the code, a design, the product or anything else) and report the findings",
	domain.KindBug:      "find the root cause of a bug and propose a fix, without making it",
}

var prompts = template.Must(template.New("").Funcs(template.FuncMap{
	"indent": func(s string) string { return "    " + strings.ReplaceAll(s, "\n", "\n    ") },
	// answer is a question's answer on one line: the chosen options of a
	// multiple-choice question are joined.
	"answer": func(q domain.Question) string {
		if q.Answer == nil {
			return ""
		}
		return strings.ReplaceAll(strings.TrimSpace(*q.Answer), "\n", "; ")
	},
	"work":  func(k domain.TicketKind) string { return kindWork[k] },
	"kinds": func() []domain.TicketKind { return domain.Kinds },
}).Parse(`
{{define "ticket"}}## Ticket {{.T.Key}}: {{.T.Title}}

{{if .T.Description}}{{.T.Description}}{{else}}(no description){{end}}
{{with .TicketFiles}}
The author attached these files to the ticket. Read each one (images and PDFs too) before you start:
{{range .}}
- {{.Path}} ({{.Name}}, {{.ContentType}}){{end}}
{{end}}{{if .Repo.ClaudeMD}}
## Extra instructions for this repository

{{.Repo.ClaudeMD}}
{{end}}{{template "team" .}}
{{template "lang"}}{{end}}

{{define "answers"}}{{if .Answers}}
## Answers from the ticket author

{{range .Answers}}- Q: {{.Text}}
  A: {{answer .}}{{if .Note}} ({{.Note}}){{end}}
{{with $.AnswerFiles .ID}}  Attached to this answer (read them): {{range $i, $f := .}}{{if $i}}, {{end}}{{$f.Path}}{{end}}
{{end}}{{end}}{{end}}{{end}}

{{define "feedbackfiles"}}{{with .FeedbackFiles}}
The author attached these files to help; read each one (images and PDFs too):
{{range .}}
- {{.Path}} ({{.Name}}){{end}}
{{end}}{{end}}

{{define "lang"}}## Language

Write everything a person reads (summaries, plans, questions and their options, notes, reports, review findings, follow-ups) in the language the ticket is written in. If the ticket mixes languages, use the one its description is mostly written in. Keep code, identifiers, file paths, commands and URLs as they are, and keep JSON keys and the fixed values listed for them (kinds, severities, verdicts and the like) exactly as given, in English. Code comments and commit text follow the repository's conventions.
{{end}}

{{define "team"}}{{if .Rules}}
## Team rules

The team wrote these rules for every ticket. Follow them. A repository rule is more specific than a global one and wins where the two disagree.
{{range .Rules}}
### {{if .RepoID}}Repository rule{{else}}Global rule{{end}}: {{.Title}}

{{.Text}}
{{end}}{{end}}{{end}}

{{define "rules"}}## Rules

- Work only inside /workspace. Do not commit, push, or change git remotes; agnts does that after human review.
- Do not read or print secrets (.env files, credentials).
- Keep changes focused on the ticket. Follow the repository's existing style and CLAUDE.md.
{{end}}

{{define "environment"}}{{if .Repo.Toolchains}}## Environment

Installed and on PATH: {{range $i, $t := .Repo.Toolchains}}{{if $i}}, {{end}}{{$t.Tool}} {{$t.Version}}{{if $t.Dir}} (for {{$t.Dir}}/){{end}}{{end}}. Their install directories are read-only: do not install other language versions, and do not use sudo or apt-get. Install the project's dependencies the usual way (npm ci, pip install, bundle install, cargo build, ...); package caches are kept between runs.{{range .Repo.Toolchains}}{{if eq .Tool "python"}} A Python virtualenv is active ($VIRTUAL_ENV, outside /workspace): install Python packages into it, and never create a virtualenv inside /workspace.{{end}}{{end}} If the work needs a tool that is not installed, say so in the notes instead of working around it.

{{end}}{{end}}

{{define "detect"}}You are agnts's build engineer. agnts runs AI coding agents on the repository at /workspace, in a Linux container, and needs to know which language toolchains to install and which commands build, lint and test the project. A file scan found:
{{if .Detected.Toolchains}}- toolchains: {{range $i, $t := .Detected.Toolchains}}{{if $i}}, {{end}}{{$t.Spec}}{{end}}{{else}}- no toolchains{{end}}
- build: {{if .Detected.Build}}{{.Detected.Build}}{{else}}(none){{end}}
- lint: {{if .Detected.Lint}}{{.Detected.Lint}}{{else}}(none){{end}}
- test: {{if .Detected.Test}}{{.Detected.Test}}{{else}}(none){{end}}

Fill the gaps. Read the README, CONTRIBUTING, the CI configuration (.github/workflows, .gitlab-ci.yml, .circleci, Jenkinsfile), Makefiles, Dockerfiles and build files: the CI file usually shows exactly how the project is built and tested. Do not run anything and do not change any files in /workspace.

Write {{.DetectPath}} as JSON:
{"toolchains": [{"tool": "python", "version": "3.12"}], "build": "...", "lint": "...", "test": "...", "notes": ["..."]}

- tool: a mise tool name (go, node, python, rust, java, dotnet, ruby, elixir, erlang, dart, zig, swift, deno, bun, uv, maven, gradle, cmake, ...). version: the one the project pins, or a prefix such as "20", or "latest". Leave out tools the scan already found, and anything the base image has (git, make, gcc, PHP, Composer).
- build, lint, test: one shell line each, run from the repository root, that install dependencies and then build, lint or test. Use "" when the project has none. Prefer what CI runs, without CI-only steps (caching, uploads, deploys, docker build). Each must finish on its own: no watch modes, servers or prompts.
- notes: anything a person must set up by hand (services such as a database the tests need, secrets, an SDK that cannot be installed this way). Keep each note to one sentence.
{{end}}

{{define "analyze"}}You are agnts, a careful software engineer. Analyse the ticket below {{if .NoRepo}}before working on it. It has no repository: /workspace is empty, so work from the ticket text{{else}}in the repository at /workspace{{end}}. Do not change any files in /workspace.

{{template "ticket" .}}
{{template "rules" .}}
## Kind of work

agnts works these kinds of tickets:
{{range kinds}}
- {{.}}: {{work .}}{{end}}

{{if .T.KindAuto}}Nobody chose a kind for this ticket. Pick the one it asks for; when it asks for a change to the code and nothing else fits, pick code.{{else}}The ticket was filed as {{.T.Kind}} ({{work .T.Kind}}). Keep that kind unless the ticket clearly asks for a different one; then name that kind, and agnts will tell the author.{{end}}{{if .NoRepo}} The code and test kinds need a repository; pick them only when the ticket really asks for a change to code.{{end}}

## What to produce

{{if .NoRepo}}Read the ticket{{else}}Investigate the code{{end}}, then write a JSON file to {{.AnalysisPath}} with exactly this shape:

    {"kind": "one of {{range $i, $k := kinds}}{{if $i}}, {{end}}{{$k}}{{end}}",
     "kindReason": "one sentence: why this kind",
     "complexity": "simple or complex",
     "summary": "one paragraph: what the ticket needs{{if not .NoRepo}} and where in the code{{end}}",
     "plan": ["step 1", "step 2"],{{if not .NoRepo}}
     "footprint": {"files": ["path/relative/to/the/repository/root.go"], "modules": ["package or feature"], "provides": ["what this adds that other work could use"], "consumes": ["what this needs that may not exist yet"], "migrations": false},{{end}}
     "questions": [{"text": "a question only the ticket author can answer", "options": ["option A", "option B"], "multiple": false}]}

For a report kind (plan, analysis, bug) the plan lists how you will do the work and what the report will cover.

{{if not .NoRepo}}The footprint is what the work will change. "files" lists the exact paths you expect to edit or add, as found in the code (not directories or patterns); "provides" names what the change adds that other work could build on (an endpoint, a table, a function, a config key); "consumes" names what it needs that does not exist yet; "migrations" is true when it adds or changes a database migration. agnts runs several tickets at a time and uses the footprint to keep tickets that change the same code apart, so be precise. For a report kind, which changes nothing, use empty lists.

{{end}}Rate the complexity "complex" when the work spans several modules or layers, changes data or schemas, touches concurrency, security, money or public APIs, or needs careful design; otherwise "simple".

{{if .NoQuestions}}Do not ask questions: use an empty "questions" list and make reasonable assumptions, noting them in the plan.{{else}}Ask questions only when the answer changes what you would build or conclude and you cannot find it{{if not .NoRepo}} in the code{{end}}. Give two to four concrete options for each. Set "multiple" to true when the options do not exclude each other and the author may pick several (which platforms to support, which fields to show); keep it false when only one can be right. Use an empty list when there is nothing to ask.{{end}}{{if .Rules}} Plan the work so it follows the team rules; if the ticket asks for something a rule forbids, {{if .NoQuestions}}follow the rule and say so in the plan{{else}}ask which one wins{{end}}.{{end}}
{{end}}

{{define "code"}}You are agnts, a careful software engineer. Implement the ticket below in the repository at /workspace.{{if eq .T.Kind "test"}} This ticket is about tests: add or fix automated tests that follow the project's existing test style, and change other code only when the ticket asks for it or a test cannot be written without it (say so in the notes).{{end}}

{{template "ticket" .}}
{{if .Plan}}## Plan from the analysis

{{range .Plan}}- {{.}}
{{end}}{{end}}{{template "answers" .}}
{{if .Landed}}## Merged since the analysis

This ticket waited for these tickets, and their changes are now merged into the default branch, so /workspace includes them:
{{range .Landed}}
- {{.Key}}: {{.Title}}{{end}}

The plan above was written before they landed. Check it against the current code, use what they added, and do not redo their work.

{{end}}{{template "environment" .}}{{template "rules" .}}- Run the project's build, lint and tests yourself before finishing{{if .Checks}}: {{.Checks}}{{end}}.
{{if .VisualCheck}}{{template "visualcheck" .}}{{end}}
When you are done, write {{.SummaryPath}} as {"summary": "what you changed and why", "notes": ["anything the reviewer should check"]}.
{{end}}

{{define "visualcheck"}}
## Looking at your change

This repository's app can run here. If your change alters what users see, check it in a browser before you finish:

1. ` + "`agnts-preview start`" + ` starts the app on http://localhost:{{.Repo.Preview.Port}} (log: /tmp/preview.log); it waits until the app answers.
2. ` + "`agnts-shot http://localhost:{{.Repo.Preview.Port}}/<route> --viewport desktop --out /tmp/shots/<name>.png`" + ` (and ` + "`--viewport phone`" + `) takes a screenshot; read the PNG to see it.
3. Fix what looks broken: overlapping or cut-off elements, layout that breaks at phone width, missing styles, console errors.
4. ` + "`agnts-preview stop`" + ` stops the app.

Spend at most about 10 turns on this, and skip it when the change has no visible effect.{{if .Repo.Preview.Login}} How to sign in: {{.Repo.Preview.Login}}{{end}} The variables in {{.PreviewEnvPath}} are secrets: never print or copy their values.
{{end}}

{{define "feedback"}}The reviewer asked for changes to your work on {{.T.Key}}:

{{indent .Feedback}}
{{template "feedbackfiles" .}}{{if .FeedbackShots}}
The reviewer pointed at these screenshots of the running app; read them to see what they mean:
{{range .FeedbackShots}}
- {{.}}{{end}}
{{end}}
Make these changes in /workspace, run the checks again, and update {{.SummaryPath}}.
{{end}}

{{define "learn"}}You are agnts's teacher. agnts, an AI coding agent, just finished ticket {{.T.Key}} in the repository at /workspace, and the change was approved and pushed. The developers who own this repository did not write it, so they may not know the techniques it uses. Find what this change introduces that the repository had never done before, and teach it to them. Do not change any files in /workspace.

## The change

Ticket {{.T.Key}}: {{.T.Title}}
{{if .T.Description}}
{{indent .T.Description}}
{{end}}
The full diff is in {{.ChangePath}}. /workspace is checked out at the result. Changed files:
{{range .Files}}
- {{.Path}} (+{{.Add}} −{{.Del}}){{end}}

## Already taught in this repository

{{if .Topics}}These concepts already have lessons. Never teach them again, even under a different name:
{{range .Topics}}
- {{.Slug}}: {{.Title}}{{end}}{{else}}Nothing yet: this is the first change agnts learns from.{{end}}

## What counts as new

A concept is worth a lesson only if all of these hold:

1. The change actually relies on it: a design pattern, an architectural boundary, an algorithm or data structure, a concurrency or transaction technique, a library or language feature, a testing approach, a security or performance technique.
2. The repository did not use it before this change. Check: search the code (grep, git grep, git log -S) and make sure every earlier use you find is only in lines this diff added. If the code base already did it somewhere else, it is not new.
3. It is not on the list above.
4. A developer who knows this code base would learn something real. Skip renames, ordinary CRUD, formatting, config tweaks, routine dependency bumps and language basics.

Most changes introduce nothing new. Writing no lessons is the right answer then. Write at most {{.MaxLessons}}, the most valuable first.

## What to produce

Write {{.LessonsPath}} with exactly this shape (an empty "lessons" list when nothing is new):

    {"lessons": [{
      "slug": "kebab-case-concept-name, about the concept not this ticket (e.g. transactional-outbox)",
      "title": "the concept's usual name",
      "category": "one of pattern, architecture, algorithm, library, language, testing, security, performance, tooling, other",
      "level": "beginner, intermediate or advanced",
      "summary": "one or two sentences: what it is",
      "explanation": "how it works, in plain text paragraphs separated by blank lines; a short code sample is fine",
      "whyHere": "why this change needed it, and the trade-offs against what the code did before",
      "refs": [{"path": "path/relative/to/workspace.go", "line": 42, "note": "what to look at here"}],
      "quiz": [{"question": "checks understanding, not trivia", "options": ["A", "B", "C"], "answer": 0, "explanation": "why that option is right"}],
      "reading": [{"title": "official docs or a well-known reference", "url": "https://..."}]
    }]}

Give two or three quiz questions per lesson. Only link pages you are sure exist (official documentation first); leave "reading" empty rather than guess. Write plain text, not Markdown headings. Write the lessons in the language ticket {{.T.Key}} is written in; keep slugs, categories, levels, code and names of technologies as they are.
{{end}}

{{define "rule"}}You are agnts, an AI agent that implements tickets in code. The team wrote the rule below for you to follow on every ticket {{if .RuleRepo}}in the repository {{.RuleRepo}}{{else}}in every repository{{end}}. Before you rely on it, make sure it is clear: two engineers reading it should make the same change. Do not change any files in /workspace.

## The rule

Title: {{.Rule.Title}}

{{indent .Rule.Body}}

## Where it applies

{{if .RuleRepo}}Every ticket in {{.RuleRepo}}, checked out at /workspace. Check the rule against the code: files, packages, libraries, commands and conventions it names should exist, and it should be possible to follow it here.{{else}}Every ticket in every repository. /workspace is empty: judge the rule on its own.{{end}}

## Other rules in effect

{{if .Rules}}{{range .Rules}}- {{if .RepoID}}[{{.RepoName}}]{{else}}[global]{{end}} {{.Title}}: {{.Text}}
{{end}}{{else}}None yet.
{{end}}
{{if .Answered}}## Questions already answered

{{range .Answered}}- Q: {{.Text}}
  A: {{.Answer}}{{if .Note}} ({{.Note}}){{end}}
{{end}}
{{end}}## What to look for

- Vague words with no measure ("small", "clean", "proper", "where needed", "if possible").
- Missing scope: which files, layers, languages or kinds of tickets it covers.
- Cases it does not say how to handle: exceptions, existing code that breaks it, what to do when it cannot be followed.
- Conflicts with another rule above{{if .RuleRepo}} or with how the code base works today{{end}}.
{{if .RuleRepo}}- Things it names that do not exist in the repository.
{{end}}
Do not ask about what the rule or the code already settles, about style you can infer, or about anything that would not change what you build.

## What to produce

Write {{.RulePath}} with exactly this shape:

    {"interpretation": "one paragraph: what you will do differently on every ticket because of this rule, in concrete terms",
     "clarified": "the rule rewritten as precise instructions to yourself, keeping the author's intent and everything the answers settled; plain text",
     "questions": [{"text": "a question only the author can answer", "options": ["option A", "option B"]}]}

{{if .NoQuestions}}Do not ask any more questions: use an empty "questions" list, resolve what is still open with the most reasonable reading, and state that reading in "clarified".{{else}}Ask at most five questions, each with two to four concrete options. Use an empty list when the rule is clear.{{end}} Write the interpretation, the clarified rule and the questions in the language the rule is written in.
{{end}}

{{define "translate"}}You are agnts's translator. {{.SourcePath}} holds texts from a software ticket's page as JSON: {"texts": [{"id": 0, "text": "..."}]}. Translate every text into {{.Language}}. /workspace is empty; do not create files there.

- Keep the meaning, tone and formatting: Markdown, line breaks, lists and tables stay as they are.
- Do not translate code, code blocks, inline code, identifiers, file paths, commands, URLs, ticket keys or branch names.
- Keep technical terms in the form {{.Language}}-speaking developers usually use.
- Copy a text already written in {{.Language}} unchanged.

Write {{.TranslationPath}} with exactly this shape, one item for every id in the input:

    {"texts": [{"id": 0, "text": "the translation"}]}
{{end}}

{{define "report"}}You are agnts, a careful software engineer. Your task: {{work .T.Kind}}, for the ticket below. {{if .NoRepo}}The ticket has no repository: /workspace is empty.{{else}}The repository is at /workspace.{{end}} Do not change any files in /workspace: the result is a report, not a change.

{{template "ticket" .}}
{{template "environment" .}}{{if .Plan}}## Plan from the analysis

{{range .Plan}}- {{.}}
{{end}}{{end}}{{template "answers" .}}
## Rules

- Do not change, commit or push anything in /workspace. Write only under /agnts/out; use /tmp for scratch files.
- Do not read or print secrets (.env files, credentials).
- Base every claim on what you checked.{{if not .NoRepo}} Cite code as path:line.{{end}} Say plainly what you could not verify.

## What to produce

Write the report in Markdown to {{.ReportPath}}. Start with a one-line title (# ...). Write for a developer who knows the product but not this ticket.
{{if eq .T.Kind "plan"}}
Sections: Goal; Current state{{if not .NoRepo}} (what exists today, with file references){{end}}; Approach, and the alternatives you rejected and why; Steps (numbered, each small enough for one pull request{{if not .NoRepo}}, naming the files it changes{{end}}); Risks and open questions; How to test it. Someone should be able to carry out the plan without asking you anything.
{{else if eq .T.Kind "bug"}}
Sections: Symptom; How to reproduce; Root cause, with the exact code path{{if not .NoRepo}} (path:line){{end}}; Why it happens; Proposed fix (concrete; a short diff sketch is welcome) and its risks; Other places with the same problem. You may run the code and its tests to confirm the cause, but leave /workspace as you found it.
{{else}}
Sections: Question (restated precisely); Short answer; Findings, each with its evidence; Options and trade-offs where there is a choice; Recommendation; Open questions.
{{end}}
Then write {{.SummaryPath}} as {"summary": "two or three sentences: the outcome", "notes": ["anything the reviewer should check"]}.
{{end}}

{{define "report-feedback"}}The reviewer asked for changes to your report on {{.T.Key}}:

{{indent .Feedback}}
{{template "feedbackfiles" .}}
Your last report is in {{.ReportPath}}. Rewrite it there in full with these changes, and update {{.SummaryPath}}. Do not change files in /workspace.
{{end}}

{{define "review"}}You are agnts's code reviewer. agnts, an AI agent, {{if .T.Kind.Report}}wrote a report for the ticket below ({{work .T.Kind}}){{else}}made a change for the ticket below{{end}}, and a developer is about to review it before {{if .T.Kind.Report}}accepting it{{else}}it is pushed{{end}}. Review it for them: find what they would want to know before deciding. Your review is advice shown next to the work; the developer decides. Do not change any files in /workspace.

{{template "ticket" .}}
{{if .Plan}}## Plan from the analysis

{{range .Plan}}- {{.}}
{{end}}{{end}}{{template "answers" .}}
## The work under review
{{if .WorkSummary}}
agnts's summary: {{.WorkSummary}}
{{end}}{{range .Notes}}- note: {{.}}
{{end}}{{if .T.Kind.Report}}
The report is in {{.ReportPath}}. {{if .NoRepo}}The ticket has no repository: /workspace is empty, so judge the report on its own.{{else}}/workspace is the repository the report is about, at its default branch: check the report's claims against the code.{{end}}
{{else}}
The full diff is in {{.ChangePath}}. /workspace is checked out at the change. Changed files:
{{range .Files}}
- {{.Path}} (+{{.Add}} −{{.Del}}){{end}}
{{if .CheckSteps}}
Checks agnts ran after the change:
{{range .CheckSteps}}
- {{.Name}}: ` + "`{{.Command}}`" + ` {{if eq .ExitCode 0}}passed{{else}}failed (exit {{.ExitCode}}){{end}}{{end}}
{{else}}
No build, lint or test commands are configured for this repository.
{{end}}{{end}}
## What to look for

{{if .T.Kind.Report}}- Accuracy: claims the code or the ticket contradicts, wrong paths or line references, wrong reasoning.
- Completeness: what the ticket asked that the report does not answer; risks or options it misses.
- Whether someone could act on it without asking anything.
{{else}}- Correctness: bugs, missed edge cases, error handling, races, broken callers of changed code. Read the surrounding code, not only the diff.
- Security: injection, secrets, missing authorization, unsafe input handling.
- Whether the change does what the ticket and the plan ask, and nothing unrelated.
- Tests: behaviour the change adds or alters with no test.
- Performance problems that matter at this code's scale.
- Maintainability: duplication of existing helpers, code that does not match the repository's style.
{{end}}{{if .Rules}}- Team rules: anything that breaks one of the rules above (category "rules").
{{end}}
Report only real problems, each with a concrete case of what goes wrong; you may run the code or its tests to confirm, but leave /workspace as you found it. Skip praise-free filler, style nits a linter would catch, and guesses you could not check. Finding nothing is a fine result.

## What to produce

Write {{.ReviewPath}} with exactly this shape:

    {"verdict": "looks_good, has_concerns or needs_changes",
     "summary": "two to four sentences: your overall read, for the developer",
     "findings": [{
       "severity": "blocker (must fix before {{if .T.Kind.Report}}accepting{{else}}pushing{{end}}), major, minor or nit",
       "category": "one of {{if .T.Kind.Report}}accuracy, completeness, {{end}}correctness, security, performance, tests, rules, maintainability, other",
       "file": "{{if .T.Kind.Report}}the code file a finding is about, relative to /workspace, or empty{{else}}path/relative/to/workspace{{end}}",
       "line": 42,
       "title": "the problem in one line",
       "detail": "why it is a problem: the case that goes wrong",
       "suggestion": "what to change; written so it can be sent back to agnts as review feedback"
     }],
     "strengths": ["at most three things done well, only if notable"]}

Order findings most severe first. Use an empty "findings" list when there is nothing to report.
{{end}}

{{define "preview"}}You are agnts's preview tester. agnts, an AI agent, made a change for the ticket below, and a developer is about to review it before it is pushed. Show them what the change looks like: open the pages it affects in a browser, take screenshots, and point out visual problems. Your screenshots are shown next to the diff; the developer decides. Do not change any files in /workspace.

{{template "ticket" .}}
## The change
{{if .WorkSummary}}
agnts's summary: {{.WorkSummary}}
{{end}}{{range .Notes}}- note: {{.}}
{{end}}
The full diff is in {{.ChangePath}}. /workspace is checked out at the change. Changed files:
{{range .Files}}
- {{.Path}} (+{{.Add}} −{{.Del}}){{end}}

## The running app

agnts started the app with ` + "`{{.Repo.Preview.Command}}`" + `; it answers on http://localhost:{{.Repo.Preview.Port}}. Its log is in /tmp/preview.log.{{if .Repo.Preview.Login}}

How to sign in: {{.Repo.Preview.Login}}{{end}}

The variables in {{.PreviewEnvPath}} are secrets: never print, copy or write their values; name them if you must.

Take screenshots with:

    agnts-shot <url> --viewport desktop|phone --out /agnts/out/shots/<id>.png [--full-page] [--wait <css selector>] [--click <css selector>]... [--fill '<css selector>=<text>']... [--wait-ms <ms>]

It opens the URL in a fresh page (cookies are kept between calls, so sign in once with --fill and --click), runs the fills and clicks in order, waits for the page to settle, saves the PNG and prints JSON with the page title, console errors and failed requests. Only localhost URLs work. Read each PNG to see it.

## What to capture

1. Read the diff and pick the routes and states that show this change: the pages it alters, and states such as an open dialog, a selected tab, a filled form, an empty list or an error. At most 8 routes and states.{{if .Repo.Preview.Routes}} Always include these routes as well:{{range .Repo.Preview.Routes}} {{.}}{{end}}.{{end}}
2. Capture each one at desktop and at phone width as "after" shots.{{if .T.PreviewCompare}}
3. Then run ` + "`agnts-preview base`" + `: it checks out the commit on the default branch this change started from and restarts the app (it may take a few minutes). Capture the same routes and states again as "before" shots, with the same ids ending in -before instead of -after. A route that does not exist there gets no before shot. If the base app does not start, say so in the summary and keep the after shots.{{end}}

Shot ids are lowercase letters, digits and hyphens, made of the page, the state, the viewport and the side, such as tickets-list-empty-phone-after. Give every shot a short human name ("Tickets list, empty") and the route you opened.

Then look at every after shot and report real visual problems: elements that overlap or are cut off, text that overflows, layout that breaks at phone width, missing styles or images, blank or error pages, and console errors the change causes. Do not report taste. Finding nothing is a fine result.

When a page cannot be reached (a login you cannot get past, a crash), capture what you see, say why in the summary, and use status "partial". Use "failed" only when no page works at all.

## What to produce

Write {{.PreviewPath}} with exactly this shape:

    {"status": "ok, partial or failed",
     "summary": "two or three sentences for the developer: what you captured and what stands out",
     "shots": [{"id": "tickets-list-phone-after", "file": "shots/tickets-list-phone-after.png", "name": "Tickets list", "route": "/tickets", "viewport": "desktop or phone", "side": "after or before", "note": "the state shown, if any", "consoleErrors": 0}],
     "issues": [{"severity": "high, medium or low", "description": "the problem and where on the page", "shotId": "the shot that shows it"}]}

List the shots in the order a reviewer should look at them, desktop before phone and after before before. Use an empty "issues" list when there is nothing to report.
{{end}}

{{define "relations"}}## Other open tickets in this repository

agnts works several tickets at a time, each on its own branch from {{.Repo.DefaultBranch}}, and merges them one by one. Decide how this ticket relates to each ticket below:
{{range .Related}}
- {{.Key}} ({{.State}}): {{.Title}}{{if .Summary}}
  Plan: {{.Summary}}{{end}}{{if .Files}}
  Changes: {{range $i, $f := .Files}}{{if $i}}, {{end}}{{$f}}{{end}}{{if .MoreFiles}} and {{.MoreFiles}} more{{end}}{{end}}{{if .Provides}}
  Adds: {{range $i, $x := .Provides}}{{if $i}}; {{end}}{{$x}}{{end}}{{end}}{{if .Consumes}}
  Needs: {{range $i, $x := .Consumes}}{{if $i}}; {{end}}{{$x}}{{end}}{{end}}{{end}}

Add a "relations" list to the JSON, one item per ticket that matters, and an empty list when none does:

    "relations": [{"key": "the other ticket's key", "type": "depends_on, blocks or conflicts", "confidence": 0.8, "reason": "one sentence a reviewer can check"}]

- depends_on: this ticket needs the other one's change to exist first: it uses what the other adds, or builds on top of it.
- blocks: the other ticket needs this ticket's change first.
- conflicts: neither needs the other, but both change the same code (the same functions, lines, schema or generated files), so working on them side by side ends in a merge conflict.
- Leave out tickets that only work in the same area. Check the code and the plans; do not judge from titles alone.
- confidence: 0.9 when the tickets or the code say so plainly, 0.6 when it is likely, lower when it is a guess. agnts follows confident relations at once and asks a person about the others. Write the reason in the ticket's language.
{{end}}

{{define "followups"}}## Follow-up tickets

agnts can suggest follow-up tickets; a person reads them and creates the ones they want. A follow-up exists only to get {{if .Chain}}the original goal of {{(index .Chain 0).Key}} ("{{(index .Chain 0).Title}}"){{else}}ticket {{.T.Key}}{{end}} fully done. Do not invent new work: no general refactoring, no unrelated improvements, no features nobody asked for.
{{if .Chain}}
{{.T.Key}} is itself a follow-up. The chain, root first:
{{range .Chain}}
- {{.Key}}: {{.Title}}{{end}}
- {{.T.Key}}: {{.T.Title}} (this ticket)

Stay on the root's goal.
{{end}}
Suggest a follow-up only when it is one of these:
{{range .FollowUpTypes}}
- {{.}}{{end}}

{{if .Known}}Never suggest what one of these already covers (open tickets, and follow-ups already suggested or declined):
{{range .Known}}
- {{.Key}}{{if .Key}}: {{end}}{{.Title}}{{end}}

{{end}}Most tickets need no follow-up; an empty list is the usual answer. Suggest at most {{.MaxFollowUps}}, the most important first. Add this list to the JSON you write to {{.FollowUpFile}}:

    "followUps": [{"type": "one of {{range $i, $t := .FollowUpTypeNames}}{{if $i}}, {{end}}{{$t}}{{end}}",
                   "title": "imperative, like a ticket title",
                   "description": "what to do and where{{if not .NoRepo}}, with path:line references{{end}}; enough to start without asking",
                   "serves": "one sentence: how it helps finish {{if .Chain}}{{(index .Chain 0).Key}}{{else}}{{.T.Key}}{{end}}",
                   "kind": "code, test, plan, analysis or bug",
                   "priority": "low, medium or high"}]
{{end}}

{{define "fix"}}agnts ran the project's checks after your changes and they failed:

{{indent .Output}}

Fix the cause (not the checks themselves), then update {{.SummaryPath}}.
{{end}}
`))

type promptData struct {
	T               domain.Ticket
	Repo            domain.Repository
	Plan            []string
	Answers         []domain.Question
	Checks          string
	Feedback        string
	Output          string
	AnalysisPath    string
	SummaryPath     string
	NoQuestions     bool
	Files           []domain.FileChange
	Topics          []domain.LessonTopic
	MaxLessons      int
	LessonsPath     string
	ChangePath      string
	Rules           []domain.Rule // team rules in effect
	Rule            domain.Rule   // the rule under review
	RuleRepo        string        // its repository; empty for a global rule
	Answered        []domain.RuleQuestion
	RulePath        string
	ReportPath      string
	NoRepo          bool // the ticket has no repository: /workspace is empty
	ReviewPath      string
	PreviewPath     string
	PreviewEnvPath  string
	VisualCheck     bool           // the coding prompt explains how to look at the app
	FeedbackShots   []string       // screenshots the reviewer's feedback points at
	Attached        []AttachedFile // files people attached, copied into the run
	Language        string         // translate: the target language's English name
	SourcePath      string
	TranslationPath string
	DetectPath      string
	Detected        toolchain.Detection // detect: what the file scan found
	WorkSummary     string              // what the work run said it did (review)
	Notes           []string            // its notes for the reviewer
	CheckSteps      []CheckStep         // its checks

	// Follow-up suggestions (the "followups" block).
	Chain             []TicketRef // ancestors of a follow-up ticket, root first
	Known             []TicketRef // what not to suggest again
	FollowUpTypes     []string    // the kinds of follow-up this stage may suggest, explained
	FollowUpTypeNames []string
	FollowUpFile      string
	MaxFollowUps      int

	// Relations to other tickets (the "relations" block).
	Related []RelatedTicket // other open tickets the analysis compares with
	Landed  []TicketRef     // tickets this one waited for, merged since its analysis
}

// TicketFiles are the files attached to the ticket's description.
func (d promptData) TicketFiles() []AttachedFile {
	return d.attached(func(f AttachedFile) bool { return f.Purpose == domain.AttachTicket })
}

// AnswerFiles are the files attached to the answer to question qid.
func (d promptData) AnswerFiles(qid int64) []AttachedFile {
	return d.attached(func(f AttachedFile) bool { return f.QuestionID != nil && *f.QuestionID == qid })
}

// FeedbackFiles are the files a retry note brought, not yet seen by a run.
func (d promptData) FeedbackFiles() []AttachedFile {
	return d.attached(func(f AttachedFile) bool { return slices.Contains(d.T.FeedbackFiles, f.ID) })
}

func (d promptData) attached(keep func(AttachedFile) bool) []AttachedFile {
	var out []AttachedFile
	for _, f := range d.Attached {
		if keep(f) {
			out = append(out, f)
		}
	}
	return out
}

func render(name string, d promptData) (string, error) {
	d.AnalysisPath, d.SummaryPath, d.LessonsPath, d.ChangePath, d.RulePath = AnalysisPath, SummaryPath, LessonsPath, ChangePath, RulePath
	d.ReportPath, d.ReviewPath = ReportPath, ReviewPath
	d.PreviewPath, d.PreviewEnvPath = PreviewPath, PreviewEnvPath
	d.SourcePath, d.TranslationPath = SourcePath, TranslationPath
	d.DetectPath = DetectPath
	var b bytes.Buffer
	if err := prompts.ExecuteTemplate(&b, name, d); err != nil {
		return "", fmt.Errorf("prompt %s: %w", name, err)
	}
	return strings.TrimSpace(b.String()) + "\n", nil
}

func checksLine(r domain.Repository) string {
	var parts []string
	for _, c := range []string{r.BuildCmd, r.LintCmd, r.TestCmd} {
		if c != "" {
			parts = append(parts, "`"+c+"`")
		}
	}
	return strings.Join(parts, ", ")
}

func parseAnalysis(b []byte) (Analysis, error) {
	var a Analysis
	if err := json.Unmarshal(b, &a); err != nil {
		return a, fmt.Errorf("analysis.json is not valid JSON: %w", err)
	}
	if strings.TrimSpace(a.Summary) == "" {
		return a, fmt.Errorf("analysis.json has no summary")
	}
	return a, nil
}
