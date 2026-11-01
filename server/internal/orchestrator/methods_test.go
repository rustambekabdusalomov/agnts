package orchestrator_test

import (
	"slices"
	"strings"
	"testing"
	"time"

	"agnts/internal/ai"
	"agnts/internal/domain"
	"agnts/internal/orchestrator"
	"agnts/internal/skillpacks"
)

func TestMethodSkills(t *testing.T) {
	h := newHarness(t)
	grep := "git ls-files | grep -E -q -e '" + skillpacks.MigrationFiles + "'"
	methods := func() []string {
		var out []string
		for p := range h.runner.written {
			if rest, ok := strings.CutPrefix(p, orchestrator.SkillsDir+"/"+skillpacks.Prefix); ok && strings.HasSuffix(rest, "/SKILL.md") {
				out = append(out, strings.TrimSuffix(rest, "/SKILL.md"))
			}
		}
		slices.Sort(out)
		return out
	}
	// code takes a ticket through analysis and coding; it returns the
	// analysis and coding prompts.
	code := func(key string) (string, string) {
		h.runner.written = nil
		h.ingest(key)
		h.runner.scripts = []script{
			{result: ok("s-" + key), files: map[string]string{orchestrator.AnalysisPath: analysis(0)}},
			{result: ok("s-" + key), edit: "fix"},
		}
		h.step()
		h.step()
		h.expect(key, domain.StateWaitingForReview)
		n := len(h.runner.prompts)
		return h.runner.prompts[n-2], h.runner.prompts[n-1]
	}

	// Off by default.
	if _, p := code("PAY-70"); len(methods()) != 0 || strings.Contains(p, skillpacks.Prefix) {
		t.Fatalf("method skills while off: %v\n%s", methods(), p)
	}

	// On, in a repository without migrations.
	h.settings.s.MethodSkills = true
	h.runner.execs[grep] = []orchestrator.ExecResult{{ExitCode: 1}}
	an, p := code("PAY-71")
	if got := strings.Join(methods(), ","); got != "follow-existing-pattern,house-style,reuse-first" {
		t.Fatalf("method skills: %s", got)
	}
	if !strings.Contains(p, "agnts-method-house-style") || !strings.Contains(p, "not team rules") || strings.Contains(an, skillpacks.Prefix) {
		t.Fatalf("prompts:\nanalysis:\n%s\ncoding:\n%s", an, p)
	}

	// With migrations; Claude loads one.
	h.runner.stream = func(on func(ai.Event)) {
		on(ai.Event{Kind: ai.EventTool, Tool: "Skill: agnts-method-migrations", Data: map[string]any{"tool": "Skill", "id": "k1"}})
	}
	code("PAY-72")
	if got := strings.Join(methods(), ","); got != "follow-existing-pattern,house-style,migrations,reuse-first" {
		t.Fatalf("method skills: %s", got)
	}

	a, err := h.store.Analytics(h.ctx, 30, time.UTC)
	if err != nil {
		t.Fatal(err)
	}
	stats := map[string][2]int{}
	for _, x := range a.Skills {
		stats[strings.TrimPrefix(x.Skill, skillpacks.Prefix)] = [2]int{x.Tickets, x.Loaded}
	}
	want := map[string][2]int{"": {1, 0}, "follow-existing-pattern": {2, 0}, "house-style": {2, 0}, "reuse-first": {2, 0}, "migrations": {1, 1}}
	for k, v := range want {
		if stats[k] != v {
			t.Errorf("skill %q: tickets and loaded %v, want %v", k, stats[k], v)
		}
	}
	versions := map[string]int{}
	for _, q := range a.Quality {
		versions[q.PromptVersion] = q.Tickets
	}
	if versions[orchestrator.PromptVersion] != 1 || versions[orchestrator.PromptVersion+orchestrator.MethodsSuffix] != 2 {
		t.Fatalf("prompt versions: %v", versions)
	}
}
