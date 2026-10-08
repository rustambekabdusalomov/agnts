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

// PromptVersion names the current prompts. Every run records it, so the
// Analytics page can compare the quality of the work before and after a
// change: bump it whenever a change to the prompts or to the context runs
// get could change what Claude does.
const PromptVersion = "2026-10-08.1"

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
	// Approaches are the ways the work could be done, weighed against the
	// code base; one is chosen (code and test kinds).
	Approaches []Approach `json:"approaches,omitempty"`
	// OutOfScope is what the work will deliberately not do.
	OutOfScope []string `json:"outOfScope,omitempty"`
	// Ship says how the change reaches production, when it touches data,
	// schemas, public APIs or configuration.
	Ship *ShipNotes `json:"ship,omitempty"`
}

// Approach is one way to do a ticket's work.
type Approach struct {
	Title  string   `json:"title"`
	Sketch string   `json:"sketch"`
	Pros   []string `json:"pros,omitempty"`
	Cons   []string `json:"cons,omitempty"`
	// Fit is how it fits the brief's architecture and the team rules, or
	// what it bends.
	Fit    string `json:"fit,omitempty"`
	Chosen bool   `json:"chosen"`
	// Why: for the chosen one, why it beats the others; otherwise, why not.
	Why string `json:"why,omitempty"`
}

// ShipNotes are how a change ships; empty fields do not apply.
type ShipNotes struct {
	Migrations    string `json:"migrations,omitempty"`
	Compatibility string `json:"compatibility,omitempty"`
	Rollout       string `json:"rollout,omitempty"`
	Rollback      string `json:"rollback,omitempty"`
}

// ShipPlan returns the ship notes, or nil when none applies.
func (a Analysis) ShipPlan() *ShipNotes {
	if n := a.Ship; n != nil && strings.TrimSpace(n.Migrations+n.Compatibility+n.Rollout+n.Rollback) != "" {
		return n
	}
	return nil
}

// Chosen returns the approach the analysis picked: the one marked chosen,
// else the first; nil when there are none.
func (a Analysis) Chosen() *Approach {
	for i := range a.Approaches {
		if a.Approaches[i].Chosen {
			return &a.Approaches[i]
		}
	}
	if len(a.Approaches) > 0 {
		return &a.Approaches[0]
	}
	return nil
}

// Alternatives returns the approaches not chosen.
func (a Analysis) Alternatives() []Approach {
	c := a.Chosen()
	var out []Approach
	for i := range a.Approaches {
		if &a.Approaches[i] != c {
			out = append(out, a.Approaches[i])
		}
	}
	return out
}

// Summary is what a coding run should write to SummaryPath.
type Summary struct {
	Summary string   `json:"summary"`
	Notes   []string `json:"notes"`
	// FollowUps are what the ticket still needs after this run, when asked for.
	FollowUps []domain.FollowUp `json:"followUps,omitempty"`
	// Deviations are where the work departed from the chosen approach or
	// the plan, and why.
	Deviations []string `json:"deviations,omitempty"`
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
{{end}}{{template "context" .}}{{template "team" .}}
{{template "lang"}}{{end}}

{{define "context"}}{{with .Context}}
## Team knowledge

Read these files before you start. People on the team approved them; they say how this code base works:
{{range .}}
- {{.Path}}: {{.What}}{{end}}

Follow them: put code where they say it belongs, copy the files they point to, keep to the dependency rules and conventions. When the ticket needs something they do not cover, or the code contradicts them, trust the code and say so in your notes.
{{end}}{{end}}

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

{{define "survey"}}You are agnts's architect. agnts runs AI coding agents on tickets in the repository {{.Repo.Name}}, checked out at /workspace on its default branch, {{.Repo.DefaultBranch}}. Before an agent touches a ticket it reads a brief of the repository, so that it builds what a senior engineer on this team would: in the right place, the way the code base already does it. Write that brief. Do not change any files in /workspace.
{{if .Brief.Ready}}
## The current brief

/agnts/context/brief.md is the brief the team approved{{if .Brief.BodySHA}}, written at commit {{.Brief.BodySHA}}{{end}}. People may have edited it: keep what they wrote unless the code now contradicts it. Update it rather than starting over:{{if .Brief.BodySHA}} run ` + "`git log --stat {{.Brief.BodySHA}}..HEAD`" + ` to see what changed since, and{{end}} check every statement against the code as it is now. Remove what no longer holds; add what is new.
{{end}}{{if .Rules}}
## Team rules

The team wrote these rules; they stay separate from the brief, so do not repeat them, but do not contradict them either:
{{range .Rules}}
- {{.Title}}{{end}}
{{end}}
## How to survey

Read the README, CONTRIBUTING, CLAUDE.md or AGENTS.md, the build and CI files, then the code itself: the entry points, the package or module layout, the imports between them, a few typical features end to end, and the tests. Use git log to see how the team usually makes changes. Every statement in the brief must be something you checked in the code; cite paths. When the code is inconsistent, say which way is the current one (usually the newer code).

## What to write

Write {{.BriefOutPath}} in Markdown, at most about 2000 words, with exactly these sections:

# {{.Repo.Name}}

## Purpose
What the product does and for whom, the main domain concepts and their names in the code. Three to six sentences.

## Architecture
The layers or modules and what each owns; which may depend on which (and which must not); where business rules live, where I/O lives; how requests or jobs flow through the code. Name the directories.

## Module map
A list: path → what it is responsible for. The important directories only.

## Recipes
For each common kind of change (for example: a new API endpoint, a new database table or migration, a new page or screen, a new background job, a new setting, a new integration), the steps and files to touch, in order, including generated code and how to regenerate it. Only kinds this repository has.

## Files to copy
For each recipe, the one existing file that is the best example to copy, with why.

## Conventions
Error handling, naming, logging, configuration, dependency injection, transactions, translations, comments, commit style: what the code consistently does.

## Testing
Where tests live, their style (table tests, fixtures, mocks or real services), how to run one test, what needs a database or other services.

## Pitfalls
What a newcomer would get wrong: generated files not to edit by hand, invariants the code relies on, surprising coupling, slow or flaky parts, things that look unused but are not.

Write facts, not advice anyone could give ("write clean code"). Write in English; keep identifiers, paths and commands as they are.
{{end}}

{{define "design"}}## Design

For code and test work, think like a senior engineer on this team before you plan. In "approaches", give two or three genuinely different ways to do it when the work is complex, and one when it is simple; mark exactly one "chosen" and make the plan carry it out. Weigh them on how the code base already does similar things{{if .Context}} (the brief's recipes and files to copy){{end}}, how much code each touches and how easy it is to undo, what breaks if it is wrong, compatibility with existing callers, data and clients, and the risk of running it in production. Prefer the plain option that matches the existing code; add a new abstraction, layer or dependency only when the existing ones cannot do the job, and say why. Do not pad the list with approaches nobody would pick.

"outOfScope" names what you will deliberately leave alone: refactors, clean-ups and features next to the ticket that it does not ask for. Keep it short, and empty when nothing tempting is nearby.

Fill "ship" only when the change touches persisted data, a schema or migration, a public or cross-service API, configuration or environment variables: how the migration runs and whether the old code still works with the new schema (migrations), what happens to existing callers, clients and data (compatibility), what to deploy first (rollout), and how to undo it (rollback). Use "" for what does not apply, and leave "ship" out when nothing does.

For a report kind (plan, analysis, bug), leave "approaches", "outOfScope" and "ship" out.{{if not .NoQuestions}} When the work is complex and you give two or more approaches a reasonable person could prefer, add a question asking which one to take, with their titles as the options, the chosen one first.{{end}}

{{end}}

{{define "approach"}}{{with .Design}}{{with .Chosen}}## Approach

Take this approach, chosen in the analysis{{if $.Answers}} (unless the author's answers below pick another: then follow theirs){{end}}:

**{{.Title}}**: {{.Sketch}}{{if .Why}}
Why: {{.Why}}{{end}}
{{end}}{{with .Alternatives}}
Rejected:
{{range .}}
- {{.Title}}{{if .Why}}: {{.Why}}{{end}}{{end}}
{{end}}{{with .OutOfScope}}
## Out of scope

Do not do these, even where they look easy; mention them in the notes if they matter:
{{range .}}
- {{.}}{{end}}
{{end}}{{with .ShipPlan}}
## Shipping

The change must ship safely:{{with .Migrations}}
- Migrations: {{.}}{{end}}{{with .Compatibility}}
- Compatibility: {{.}}{{end}}{{with .Rollout}}
- Rollout: {{.}}{{end}}{{with .Rollback}}
- Rollback: {{.}}{{end}}
{{end}}
{{end}}{{end}}

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
     "approaches": [{"title": "a short name", "sketch": "what changes where, in two or three sentences", "pros": ["..."], "cons": ["..."], "fit": "how it fits the brief and the team rules, or what it bends", "chosen": true, "why": "why this one beats the others; for the others, why not"}],
     "outOfScope": ["what this ticket will deliberately not do"],
     "ship": {"migrations": "", "compatibility": "", "rollout": "", "rollback": ""},
     "footprint": {"files": ["path/relative/to/the/repository/root.go"], "modules": ["package or feature"], "provides": ["what this adds that other work could use"], "consumes": ["what this needs that may not exist yet"], "migrations": false},{{end}}
     "questions": [{"text": "a question only the ticket author can answer", "options": ["option A", "option B"], "multiple": false}]}

For a report kind (plan, analysis, bug) the plan lists how you will do the work and what the report will cover.

{{if not .NoRepo}}The footprint is what the work will change. "files" lists the exact paths you expect to edit or add, as found in the code (not directories or patterns); "provides" names what the change adds that other work could build on (an endpoint, a table, a function, a config key); "consumes" names what it needs that does not exist yet; "migrations" is true when it adds or changes a database migration. agnts runs several tickets at a time and uses the footprint to keep tickets that change the same code apart, so be precise. For a report kind, which changes nothing, use empty lists.

{{template "design" .}}{{end}}Rate the complexity "complex" when the work spans several modules or layers, changes data or schemas, touches concurrency, security, money or public APIs, or needs careful design; otherwise "simple".

{{if .NoQuestions}}Do not ask questions: use an empty "questions" list and make reasonable assumptions, noting them in the plan.{{else}}Ask questions only when the answer changes what you would build or conclude and you cannot find it{{if not .NoRepo}} in the code{{end}}. Give two to four concrete options for each. Set "multiple" to true when the options do not exclude each other and the author may pick several (which platforms to support, which fields to show); keep it false when only one can be right. Use an empty list when there is nothing to ask.{{end}}{{if .Rules}} Plan the work so it follows the team rules; if the ticket asks for something a rule forbids, {{if .NoQuestions}}follow the rule and say so in the plan{{else}}ask which one wins{{end}}.{{end}}
{{end}}

{{define "code"}}You are agnts, a careful software engineer. Implement the ticket below in the repository at /workspace.{{if eq .T.Kind "test"}} This ticket is about tests: add or fix automated tests that follow the project's existing test style, and change other code only when the ticket asks for it or a test cannot be written without it (say so in the notes).{{end}}

{{template "ticket" .}}
{{if .Plan}}## Plan from the analysis

{{range .Plan}}- {{.}}
{{end}}{{end}}{{template "approach" .}}{{template "answers" .}}
{{if .Landed}}## Merged since the analysis

This ticket waited for these tickets, and their changes are now merged into the default branch, so /workspace includes them:
{{range .Landed}}
- {{.Key}}: {{.Title}}{{end}}

The plan above was written before they landed. Check it against the current code, use what they added, and do not redo their work.

{{end}}{{template "environment" .}}{{template "rules" .}}- Run the project's build, lint and tests yourself before finishing{{if .Checks}}: {{.Checks}}{{end}}.
{{if .VisualCheck}}{{template "visualcheck" .}}{{end}}
When you are done, write {{.SummaryPath}} as {"summary": "what you changed and why", "notes": ["anything the reviewer should check"], "deviations": ["where you departed from the approach or the plan, and why"]}. Leave "deviations" empty when you followed them.
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

{{define "rule"}}You are agnts, an AI agent that implements tickets in code. {{if eq .Rule.Kind "context"}}The team wrote the business context note below: knowledge about the product and its domain (terms, invariants, roles, rules of the business) that you read before every ticket {{if .RuleRepo}}in the repository {{.RuleRepo}}{{else}}in every repository{{end}}. Before you rely on it, make sure it is clear: two engineers reading it should understand the same thing, and every term and invariant should be precise enough to check code against{{else}}The team wrote the rule below for you to follow on every ticket {{if .RuleRepo}}in the repository {{.RuleRepo}}{{else}}in every repository{{end}}. Before you rely on it, make sure it is clear: two engineers reading it should make the same change{{end}}. Do not change any files in /workspace.

## The {{if eq .Rule.Kind "context"}}note{{else}}rule{{end}}

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

    {"interpretation": "one paragraph: {{if eq .Rule.Kind "context"}}what you understand from this note, and how it will shape the work on tickets{{else}}what you will do differently on every ticket because of this rule{{end}}, in concrete terms",
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
{{end}}{{end}}{{with .Design}}{{with .Chosen}}
## Decisions from the analysis

Chosen approach: **{{.Title}}**: {{.Sketch}}
{{end}}{{with .OutOfScope}}Out of scope: {{range $i, $x := .}}{{if $i}}; {{end}}{{$x}}{{end}}
{{end}}{{with .ShipPlan}}How it must ship:{{with .Migrations}} migrations: {{.}};{{end}}{{with .Compatibility}} compatibility: {{.}};{{end}}{{with .Rollout}} rollout: {{.}};{{end}}{{with .Rollback}} rollback: {{.}}{{end}}
{{end}}{{end}}{{template "answers" .}}
## The work under review
{{if .WorkSummary}}
agnts's summary: {{.WorkSummary}}
{{end}}{{range .Notes}}- note: {{.}}
{{end}}{{range .Deviations}}- departed from the plan: {{.}}
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
{{end}}{{with .Unexpected}}
Changed, but not among the files the analysis expected to change: {{range $i, $f := .}}{{if $i}}, {{end}}{{$f}}{{end}}.
{{end}}{{with .RedFlags}}
agnts's scan flagged these lines. It only matches patterns: check each one and report the real problems.
{{range .}}
- {{.Path}}{{if .Line}}:{{.Line}}{{end}} [{{.Kind}}] {{.Text}}{{end}}
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
- Architecture: code in the wrong layer or module, dependencies that point the wrong way, a new pattern or abstraction where the code base{{if .Context}} (see the brief){{end}} already has one (category "architecture").
- Scope: changes the ticket and the chosen approach do not need, work listed as out of scope, departures from the plan the summary does not explain, and a missing migration, compatibility or rollback step when the change touches data, schemas, APIs or configuration (category "scope").
- Checks made to pass the wrong way: tests skipped, weakened or deleted, assertions removed, linters silenced, errors swallowed. Each is a blocker unless the summary gives a good reason (category "tests").
{{end}}{{if .Rules}}- Team rules: anything that breaks one of the rules above (category "rules").
{{end}}
Report only real problems, each with a concrete case of what goes wrong; you may run the code or its tests to confirm, but leave /workspace as you found it. Skip praise-free filler, style nits a linter would catch, and guesses you could not check. Finding nothing is a fine result.

## What to produce

Write {{.ReviewPath}} with exactly this shape:

    {"verdict": "looks_good, has_concerns or needs_changes",
     "summary": "two to four sentences: your overall read, for the developer",
     "findings": [{
       "severity": "blocker (must fix before {{if .T.Kind.Report}}accepting{{else}}pushing{{end}}), major, minor or nit",
       "category": "one of {{if .T.Kind.Report}}accuracy, completeness, {{end}}correctness, security, performance, tests, rules, {{if not .T.Kind.Report}}architecture, scope, {{end}}maintainability, other",
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

{{define "reflect"}}You are agnts's coach. agnts, an AI agent, worked on ticket {{.T.Key}}{{if not .NoRepo}} in the repository {{.Repo.Name}}{{end}}, and a person {{if eq .Source "rejected"}}rejected the work{{else}}reviewing it asked for changes{{end}}. Find out whether what they said teaches agnts something it should do on every future ticket, not just this one. Do not change any files in /workspace.

## What they said

{{indent .Feedback}}

## The ticket

{{.T.Key}}: {{.T.Title}}
{{if .T.Description}}
{{indent .T.Description}}
{{end}}{{if .Files}}
The change they reviewed is in {{.ChangePath}}. Changed files:
{{range .Files}}
- {{.Path}} (+{{.Add}} −{{.Del}}){{end}}
{{else if .HasReport}}
The report they reviewed is in {{.ReportPath}}.
{{end}}{{if not .NoRepo}}
/workspace is the repository at its default branch, {{.Repo.DefaultBranch}}: look at how the code base does things before you generalise.
{{end}}{{template "context" .}}
## Rules that already exist

{{if .Rules}}Never suggest anything one of these already covers, even in other words. Suggestions the team declined are marked; do not suggest them again.
{{range .Rules}}
- [{{if .RepoID}}{{.RepoName}}{{else}}global{{end}}{{if eq .Status "dismissed"}}, declined{{else if eq .Status "suggested"}}, suggested{{end}}] {{.Title}}: {{.Text}}{{end}}{{else}}None yet.{{end}}

## What counts

A suggestion must be a convention of this code base or team that the feedback reveals and agnts did not follow: where code belongs, a library or helper to use or avoid, how tests are written, naming, error handling, a business rule, how changes ship. Leave out:

- feedback about this ticket only: a bug, a missed requirement, a typo, a wrong value;
- taste with no rule behind it;
- anything an existing rule covers.

Most feedback teaches no general rule: an empty list is the usual answer. Suggest at most {{.MaxSuggest}}.

## What to produce

Write {{.ReflectPath}} with exactly this shape:

    {"suggestions": [{"title": "a short name for the rule", "body": "the rule as an instruction to agnts, precise enough that two engineers would make the same change: name the files, packages, libraries or commands it is about", "scope": "repository or global", "why": "one sentence: which part of the feedback shows it"}]}

Use "repository" unless the rule clearly holds for every repository. Write the title, body and why in the language the feedback is written in.
{{end}}

{{define "checkpoint"}}Checkpoint: you have used about a third of your turns. Before you go on, check that you are still building what was planned.

Files changed so far:{{range .Changed}}
- {{.}}{{else}} none yet.{{end}}
{{with .Outside}}
These are not among the files the analysis expected to change: {{range $i, $f := .}}{{if $i}}, {{end}}{{$f}}{{end}}. Make sure each one is needed.
{{end}}{{with .Design}}{{with .Chosen}}
The chosen approach: **{{.Title}}**: {{.Sketch}}
{{end}}{{with .OutOfScope}}Out of scope: {{range $i, $x := .}}{{if $i}}; {{end}}{{$x}}{{end}}
{{end}}{{end}}
If you are drifting (a workaround instead of a fix, a new abstraction or dependency nobody asked for, changes the ticket does not need, tests skipped or weakened so they pass), stop: undo what does not belong (git checkout -- <file>, or delete files you added) and get back to the plan. If the plan itself turned out to be wrong, change course and say why under "deviations" in {{.SummaryPath}}. Then finish the work as instructed.
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
	Context         []ContextFile       // team knowledge copied into /agnts/context
	Design          *Analysis           // the analysis, for its approach, scope and ship notes
	Brief           domain.RepoBrief    // survey: the brief so far
	BriefOutPath    string
	WorkSummary     string           // what the work run said it did (review)
	Notes           []string         // its notes for the reviewer
	Deviations      []string         // where it departed from the approach or plan
	RedFlags        []domain.RedFlag // what the scan of the change flagged (review)
	Unexpected      []string         // changed files the analysis did not predict (review)
	Source          string           // reflect: changes or rejected
	HasReport       bool             // reflect: the work was a report, in ReportPath
	MaxSuggest      int
	ReflectPath     string
	Changed         []string    // checkpoint: files changed so far
	Outside         []string    // checkpoint: of those, the ones the analysis did not predict
	CheckSteps      []CheckStep // its checks

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
	d.DetectPath, d.BriefOutPath, d.ReflectPath, d.MaxSuggest = DetectPath, BriefOutPath, ReflectPath, reflectMaxSuggest
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
	a.normalizeDesign()
	return a, nil
}
