package orchestrator

import (
	"bytes"
	"encoding/json"
	"fmt"
	"strings"
	"text/template"

	"hiro/internal/domain"
)

// Files Claude Code writes for hiro to read back. stream-json output has no
// structured result, so the contract is a file outside the repository.
const (
	AnalysisPath = "/hiro/out/analysis.json"
	SummaryPath  = "/hiro/out/summary.json"
	LessonsPath  = "/hiro/out/lessons.json"
	// ChangePath is where hiro puts the reviewed diff for the learn run.
	ChangePath = "/hiro/out/change.diff"
)

// Analysis is what the analyze stage must write to AnalysisPath.
type Analysis struct {
	Summary   string   `json:"summary"`
	Plan      []string `json:"plan"`
	Questions []struct {
		Text    string   `json:"text"`
		Options []string `json:"options"`
	} `json:"questions"`
}

// Summary is what a coding run should write to SummaryPath.
type Summary struct {
	Summary string   `json:"summary"`
	Notes   []string `json:"notes"`
}

var prompts = template.Must(template.New("").Funcs(template.FuncMap{
	"indent": func(s string) string { return "    " + strings.ReplaceAll(s, "\n", "\n    ") },
}).Parse(`
{{define "ticket"}}## Ticket {{.T.Key}}: {{.T.Title}}

{{if .T.Description}}{{.T.Description}}{{else}}(no description){{end}}
{{if .Repo.ClaudeMD}}
## Extra instructions for this repository

{{.Repo.ClaudeMD}}
{{end}}{{end}}

{{define "rules"}}## Rules

- Work only inside /workspace. Do not commit, push, or change git remotes; hiro does that after human review.
- Do not read or print secrets (.env files, credentials).
- Keep changes focused on the ticket. Follow the repository's existing style and CLAUDE.md.
{{end}}

{{define "analyze"}}You are hiro, a careful software engineer. Analyse the ticket below in the repository at /workspace. Do not change any files in /workspace.

{{template "ticket" .}}
{{template "rules" .}}
## What to produce

Investigate the code, then write a JSON file to {{.AnalysisPath}} with exactly this shape:

    {"summary": "one paragraph: what the ticket needs and where in the code",
     "plan": ["step 1", "step 2"],
     "questions": [{"text": "a question only the ticket author can answer", "options": ["option A", "option B"]}]}

{{if .NoQuestions}}Do not ask questions: use an empty "questions" list and make reasonable assumptions, noting them in the plan.{{else}}Ask questions only when the answer changes what you would build and you cannot find it in the code. Give two to four concrete options for each. Use an empty list when there is nothing to ask.{{end}}
{{end}}

{{define "code"}}You are hiro, a careful software engineer. Implement the ticket below in the repository at /workspace.

{{template "ticket" .}}
{{if .Plan}}## Plan from the analysis

{{range .Plan}}- {{.}}
{{end}}{{end}}{{if .Answers}}
## Answers from the ticket author

{{range .Answers}}- Q: {{.Text}}
  A: {{.Answer}}{{if .Note}} ({{.Note}}){{end}}
{{end}}{{end}}
{{template "rules" .}}- Run the project's build, lint and tests yourself before finishing{{if .Checks}}: {{.Checks}}{{end}}.

When you are done, write {{.SummaryPath}} as {"summary": "what you changed and why", "notes": ["anything the reviewer should check"]}.
{{end}}

{{define "feedback"}}The reviewer asked for changes to your work on {{.T.Key}}:

{{indent .Feedback}}

Make these changes in /workspace, run the checks again, and update {{.SummaryPath}}.
{{end}}

{{define "learn"}}You are hiro's teacher. hiro, an AI coding agent, just finished ticket {{.T.Key}} in the repository at /workspace, and the change was approved and pushed. The developers who own this repository did not write it, so they may not know the techniques it uses. Find what this change introduces that the repository had never done before, and teach it to them. Do not change any files in /workspace.

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
- {{.Slug}}: {{.Title}}{{end}}{{else}}Nothing yet: this is the first change hiro learns from.{{end}}

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

Give two or three quiz questions per lesson. Only link pages you are sure exist (official documentation first); leave "reading" empty rather than guess. Write plain text, not Markdown headings.
{{end}}

{{define "fix"}}hiro ran the project's checks after your changes and they failed:

{{indent .Output}}

Fix the cause (not the checks themselves), then update {{.SummaryPath}}.
{{end}}
`))

type promptData struct {
	T            domain.Ticket
	Repo         domain.Repository
	Plan         []string
	Answers      []domain.Question
	Checks       string
	Feedback     string
	Output       string
	AnalysisPath string
	SummaryPath  string
	NoQuestions  bool
	Files        []domain.FileChange
	Topics       []domain.LessonTopic
	MaxLessons   int
	LessonsPath  string
	ChangePath   string
}

func render(name string, d promptData) (string, error) {
	d.AnalysisPath, d.SummaryPath, d.LessonsPath, d.ChangePath = AnalysisPath, SummaryPath, LessonsPath, ChangePath
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
