package orchestrator_test

import (
	"encoding/json"
	"strings"
	"testing"

	"agnts/internal/domain"
	"agnts/internal/orchestrator"
)

func reinforceJSON(id int64, evidence string) string {
	b, _ := json.Marshal(map[string]any{"suggestions": []any{}, "reinforces": []any{map[string]any{"id": id, "evidence": evidence}}})
	return string(b)
}

func TestLessonsGainConfidenceAndArePromoted(t *testing.T) {
	h, refl := newReflectHarness(t)
	api, _ := h.store.RepositoryByName(h.ctx, "api")
	web, err := h.store.SaveRepository(h.ctx, domain.Repository{Name: "web", Kind: "side", Provider: "github", CloneURL: "https://github.com/acme/web.git", DefaultBranch: "main", TaskPrefix: "WEB"})
	if err != nil {
		t.Fatal(err)
	}
	h.toReview("PAY-70", analysis(0))
	if _, err := h.o.RequestChanges(h.ctx, "PAY-70", "No SQL in handlers.", nil, nil, domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	h.runner.scripts = []script{
		{result: ok("s"), edit: "fix 2"},
		{result: ok("x1"), files: map[string]string{orchestrator.ReflectPath: reflectJSON(
			map[string]any{"title": "SQL lives in the store", "body": "Handlers never run SQL.", "scope": "repository", "why": "SQL moved out of a handler."})}},
	}
	h.step() // code
	h.step() // reflect
	var sug domain.Rule
	all, _ := h.o.ListRules(h.ctx)
	for _, r := range all {
		if r.Title == "SQL lives in the store" {
			sug = r
		}
	}
	if sug.ID == 0 || sug.Confidence != domain.ConfidenceFromFeedback || sug.Evidence != 1 || sug.Source != "reflect" || sug.Watching() || *sug.RepoID != api.ID {
		t.Fatalf("suggestion: %+v", sug)
	}

	// The same lesson from feedback in the web repository: it gains
	// confidence, and agnts proposes it for every repository.
	if err := refl.QueueReflection(h.ctx, domain.Reflection{TicketKey: "PAY-70", RepoID: &web.ID, Source: domain.ReflectChanges, Feedback: "Again: keep SQL out of the handlers."}); err != nil {
		t.Fatal(err)
	}
	h.runner.scripts = []script{{result: ok("x2"), files: map[string]string{orchestrator.ReflectPath: reinforceJSON(sug.ID, "The reviewer moved a query out of a page handler.")}}}
	h.step()
	if p := h.runner.prompts[len(h.runner.prompts)-1]; !strings.Contains(p, "Suggested in other repositories") || !strings.Contains(p, "[api, suggested, id ") {
		t.Fatalf("reflect prompt does not show other repositories' suggestions:\n%s", p)
	}
	up := h.rule(sug.ID)
	if up.Evidence != 2 || up.Confidence < 0.64 || up.Confidence > 0.66 || up.LastSeen == nil {
		t.Fatalf("reinforced: %+v", up)
	}
	var global *domain.Rule
	all, _ = h.o.ListRules(h.ctx)
	for i, r := range all {
		if r.RepoID == nil && r.Title == "SQL lives in the store" {
			global = &all[i]
		}
	}
	if global == nil || global.Status != domain.RuleSuggested || global.Source != "promoted" || !strings.Contains(global.Reason, "api") || !strings.Contains(global.Reason, "web") {
		t.Fatalf("promoted: %+v", global)
	}
}

func TestRunTroubleBecomesAWatchedTip(t *testing.T) {
	h, refl := newReflectHarness(t)
	var models []string
	h.runner.onClaude = func(r orchestrator.ClaudeRequest) { models = append(models, r.Model) }
	h.ingest("PAY-71")
	h.runner.scripts = []script{
		{result: ok("s1"), files: map[string]string{orchestrator.AnalysisPath: analysis(0)}},
		{result: ok("s1"), edit: "v1"},
		{result: ok("s1"), edit: "v2"},
	}
	h.runner.execs["go test ./..."] = []orchestrator.ExecResult{{ExitCode: 1, Output: "dial tcp 127.0.0.1:5432: connect: connection refused"}, {ExitCode: 0}}
	h.step()
	h.step()
	h.expect("PAY-71", domain.StateWaitingForReview)
	rs, _ := refl.Reflections(h.ctx, "PAY-71")
	if len(rs) != 1 || rs[0].Source != domain.ReflectRun || !strings.Contains(rs[0].Feedback, "connection refused") {
		t.Fatalf("queued: %+v", rs)
	}
	h.runner.scripts = []script{{result: ok("x"), files: map[string]string{orchestrator.ReflectPath: reflectJSON(
		map[string]any{"title": "Tests need PostgreSQL", "body": "Run make dev-db before go test ./...", "scope": "repository", "why": "The tests could not reach the database."})}}}
	h.step()
	if models[len(models)-1] != "haiku" {
		t.Fatalf("run lessons use %s", models[len(models)-1])
	}
	if p := h.runner.prompts[len(h.runner.prompts)-1]; !strings.Contains(p, "ran into trouble") || !strings.Contains(p, "connection refused") {
		t.Fatalf("prompt:\n%s", p)
	}
	all, _ := h.o.ListRules(h.ctx)
	var tip domain.Rule
	for _, r := range all {
		if r.Title == "Tests need PostgreSQL" {
			tip = r
		}
	}
	if tip.Kind != domain.KindTip || tip.Delivery != domain.DeliverSkill || !tip.Watching() || tip.Source != "run" || tip.RepoID == nil {
		t.Fatalf("tip: %+v", tip)
	}

	// Off: no lesson is queued.
	h.settings.s.LearnFromRuns = false
	h.ingest("PAY-72")
	h.runner.scripts = []script{
		{result: ok("s2"), files: map[string]string{orchestrator.AnalysisPath: analysis(0)}},
		{result: ok("s2"), edit: "v1"},
		{result: ok("s2"), edit: "v2"},
	}
	h.runner.execs["go test ./..."] = []orchestrator.ExecResult{{ExitCode: 1, Output: "FAIL"}, {ExitCode: 0}}
	h.step()
	h.step()
	if rs, _ := refl.Reflections(h.ctx, "PAY-72"); len(rs) != 0 {
		t.Fatalf("queued with learning off: %+v", rs)
	}
}
