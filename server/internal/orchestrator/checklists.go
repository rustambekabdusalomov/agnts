package orchestrator

import (
	"context"
	"embed"
	"encoding/json"
	"path"
	"slices"
	"strings"

	"agnts/internal/domain"
)

// reviewChecklists are per-language review checklists, adapted from ECC's
// reviewer agents (review/NOTICE).
//
//go:embed review/*.md
var reviewChecklists embed.FS

// ChecklistDir is where a review run finds its checklists.
const ChecklistDir = "/agnts/context/review"

// checklistsFor picks the checklists a change needs, from the files it
// touches and what their added lines use.
func checklistsFor(files []domain.FileChange) []string {
	var out []string
	add := func(names ...string) {
		for _, n := range names {
			if !slices.Contains(out, n) {
				out = append(out, n)
			}
		}
	}
	for _, f := range files {
		p := strings.ToLower(f.Path)
		switch path.Ext(p) {
		case ".go":
			add("go")
		case ".ts", ".mts", ".cts":
			add("typescript")
		case ".tsx":
			add("typescript", "react")
		case ".jsx":
			add("javascript", "react")
		case ".js", ".mjs", ".cjs":
			add("javascript")
		case ".vue":
			add("vue", "typescript")
		case ".py":
			add("python")
			if strings.Contains(f.Diff, "django") || strings.Contains(p, "/migrations/") || strings.HasSuffix(p, "models.py") || strings.HasSuffix(p, "views.py") {
				add("django")
			}
			if strings.Contains(f.Diff, "fastapi") || strings.Contains(f.Diff, "APIRouter") {
				add("fastapi")
			}
		case ".java":
			add("java")
			if strings.Contains(f.Diff, "springframework") || strings.Contains(f.Diff, "@Transactional") || strings.Contains(f.Diff, "@RestController") {
				add("spring")
			}
		case ".kt", ".kts":
			add("kotlin")
		case ".rs":
			add("rust")
		case ".swift":
			add("swift")
		case ".dart":
			add("flutter")
		case ".php":
			add("php")
			if strings.Contains(f.Diff, "Illuminate\\") || strings.Contains(p, "app/http/") {
				add("laravel")
			}
		case ".rb":
			add("ruby")
			if strings.Contains(f.Diff, "ActiveRecord") || strings.Contains(f.Diff, "Rails") || strings.HasPrefix(p, "app/") {
				add("rails")
			}
		case ".cs":
			add("csharp")
		}
		if isMigration(p) {
			add("sql-migrations")
		}
	}
	return out
}

// isMigration reports whether p is a database migration.
func isMigration(p string) bool {
	return strings.Contains(p, "migration") || strings.Contains(p, "/migrate/") || strings.HasSuffix(p, ".sql") && strings.Contains(p, "schema")
}

// copyChecklists puts the checklists a change needs into the run and
// returns their paths.
func (o *Orchestrator) copyChecklists(ctx context.Context, ws Workspace, files []domain.FileChange) []string {
	var out []string
	for _, name := range checklistsFor(files) {
		b, err := reviewChecklists.ReadFile("review/" + name + ".md")
		if err != nil {
			continue
		}
		p := ChecklistDir + "/" + name + ".md"
		if err := ws.WriteFile(ctx, p, b); err != nil {
			o.log.Warn("copy review checklist", "name", name, "err", err)
			continue
		}
		out = append(out, p)
	}
	return out
}

// deepReview reports whether a review gets the specialist passes.
func deepReview(s domain.Settings, model string) bool {
	switch s.DeepReview {
	case domain.DeepAlways:
		return true
	case domain.DeepAuto:
		// The same signal that picks the larger model: complex or large work.
		return domain.IsStrong(model)
	}
	return false
}

// adoptFindings marks the findings of t's latest review that the person
// put into their feedback, so Analytics can tell useful categories from
// noise. A finding counts as adopted when its suggestion or title appears
// in the feedback.
func (o *Orchestrator) adoptFindings(ctx context.Context, t domain.Ticket, feedback string) {
	r, err := o.store.LatestResult(ctx, t.ID, domain.StageReview)
	if err != nil || strings.TrimSpace(feedback) == "" {
		return
	}
	var rv domain.Review
	if json.Unmarshal(r.Summary, &rv) != nil || rv.Summary == "" || rv.Revision != t.Revision {
		return
	}
	fb := strings.ToLower(feedback)
	changed := false
	for i, f := range rv.Findings {
		for _, s := range []string{f.Suggestion, f.Title} {
			s = strings.ToLower(strings.TrimSpace(s))
			if len(s) >= 12 && strings.Contains(fb, s) && !rv.Findings[i].Adopted {
				rv.Findings[i].Adopted, changed = true, true
			}
		}
	}
	if !changed {
		return
	}
	r.Summary, _ = json.Marshal(rv)
	if err := o.store.SaveResult(ctx, r); err != nil {
		o.log.Warn("mark adopted findings", "ticket", t.Key, "err", err)
	}
}
