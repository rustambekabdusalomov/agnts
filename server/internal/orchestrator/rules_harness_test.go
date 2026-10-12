package orchestrator_test

import (
	"encoding/json"
	"strings"
	"testing"

	"agnts/internal/domain"
	"agnts/internal/orchestrator"
)

func ruleReview(desc string) script {
	b, _ := json.Marshal(map[string]any{"interpretation": "x", "clarified": "", "questions": []any{}, "skillDescription": desc})
	return script{result: ok("rule"), files: map[string]string{orchestrator.RulePath: string(b)}}
}

func TestEnforcedRulesAndSkills(t *testing.T) {
	h := newRulesHarness(t)
	repo, err := h.store.RepositoryByName(h.ctx, "api")
	if err != nil {
		t.Fatal(err)
	}
	cfgs := guardConfigs(h)
	migrations, err := h.o.CreateRule(h.ctx, orchestrator.RuleInput{Title: "Applied migrations are never edited", Body: "Add a new migration instead.",
		RepoID: &repo.ID, Enabled: true, EnforceSet: true,
		Enforce: &domain.RuleEnforce{On: "file", Paths: []string{"server/migrations/0000*.sql"}, Action: "block", Message: "add a new migration"}}, domain.OriginWeb)
	if err != nil {
		t.Fatal(err)
	}
	if _, err := h.o.CreateRule(h.ctx, orchestrator.RuleInput{Title: "Bad pattern", Body: "x", Enabled: true, EnforceSet: true,
		Enforce: &domain.RuleEnforce{On: "bash", Pattern: "(", Action: "block"}}, domain.OriginWeb); err == nil {
		t.Fatal("an invalid pattern was accepted")
	}
	queries, err := h.o.CreateRule(h.ctx, orchestrator.RuleInput{Title: "SQL lives in internal/store", Body: "Handlers never run SQL; call a store method.",
		RepoID: &repo.ID, Enabled: true, Delivery: domain.DeliverSkill}, domain.OriginWeb)
	if err != nil {
		t.Fatal(err)
	}
	h.runner.scripts = []script{ruleReview("Use when editing migrations."), ruleReview("Use when adding or changing database queries.")}
	h.step()
	h.step()
	if r := h.rule(queries.ID); r.Status != domain.RuleReady || r.SkillDescription != "Use when adding or changing database queries." || r.Delivery != domain.DeliverSkill {
		t.Fatalf("skill rule: %+v", r)
	}

	h.git.files = []domain.FileChange{{Path: "server/migrations/00001_init.sql", Add: 1, Del: 1, Diff: "@@ -3 +3 @@\n-a\n+b\n"}}
	h.ingest("PAY-60")
	h.runner.scripts = []script{
		{result: ok("s1"), files: map[string]string{orchestrator.AnalysisPath: analysis(0)}},
		{result: ok("s1"), edit: "fix"},
	}
	h.step()
	h.step()
	h.expect("PAY-60", domain.StateWaitingForReview)
	an := h.runner.prompts[len(h.runner.prompts)-2]
	if strings.Contains(an, "SQL lives in internal/store") || !strings.Contains(an, orchestrator.SkillsDir) || !strings.Contains(an, "Applied migrations are never edited") {
		t.Fatalf("analysis prompt:\n%s", an)
	}
	skill := ""
	for p, body := range h.runner.written {
		if strings.HasPrefix(p, orchestrator.SkillsDir+"/agnts-sql-lives-in-internal-store-") && strings.HasSuffix(p, "/SKILL.md") {
			skill = body
		}
	}
	if !strings.Contains(skill, "description: Use when adding or changing database queries.") || !strings.Contains(skill, "call a store method") {
		t.Fatalf("skill:\n%s\nwritten: %v", skill, keys(h.runner.written))
	}
	code := (*cfgs)[len(*cfgs)-1]
	if len(code.Rules) != 1 || code.Rules[0].ID != migrations.ID || code.Rules[0].Message != "add a new migration" {
		t.Fatalf("guard rules: %+v", code.Rules)
	}
	v, _ := h.o.View(h.ctx, "PAY-60")
	found := false
	for _, f := range v.Result.RedFlags {
		found = found || f.Kind == domain.FlagRuleViolation && f.Path == "server/migrations/00001_init.sql"
	}
	if !found {
		t.Fatalf("no rule violation flagged: %+v", v.Result.RedFlags)
	}

	// Try on history: the change is done once approved and pushed.
	if _, err := h.o.Approve(h.ctx, "PAY-60", nil, false, domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	h.step()
	h.expect("PAY-60", domain.StateDone)
	res, err := h.o.TryEnforce(h.ctx, domain.RuleEnforce{On: "diff", Paths: []string{"server/migrations/*.sql"}, Action: "warn"}, &repo.ID)
	if err != nil || res.Checked != 1 || len(res.Tickets) != 1 || res.Tickets[0] != "PAY-60" {
		t.Fatalf("try: %+v %v", res, err)
	}
	res, _ = h.o.TryEnforce(h.ctx, domain.RuleEnforce{On: "file", Pattern: `DROP TABLE`, Action: "block"}, nil)
	if len(res.Hits) != 0 {
		t.Fatalf("false hit: %+v", res)
	}
}

func keys(m map[string]string) []string {
	var out []string
	for k := range m {
		out = append(out, k)
	}
	return out
}

func TestStarterPacks(t *testing.T) {
	h := newRulesHarness(t)
	repo, _ := h.store.RepositoryByName(h.ctx, "api")
	repo.Toolchains, repo.ToolchainsOverride = []domain.Toolchain{{Tool: "go", Version: "1.26"}, {Tool: "node", Version: "22", Dir: "web"}}, true
	if _, err := h.store.UpdateRepository(h.ctx, repo); err != nil {
		t.Fatal(err)
	}
	offers, err := h.o.StarterPacks(h.ctx, repo.ID)
	if err != nil || len(offers) != 2 || offers[0].Pack != "go" || offers[0].Offered || offers[0].Rules < 4 {
		t.Fatalf("offers: %+v %v", offers, err)
	}
	added, err := h.o.OfferStarterRules(h.ctx, repo.ID, "go", domain.OriginWeb)
	if err != nil || len(added) != offers[0].Rules {
		t.Fatalf("added %d: %v", len(added), err)
	}
	for _, r := range added {
		if r.Status != domain.RuleSuggested || r.Source != "pack:go" || r.RepoID == nil || *r.RepoID != repo.ID || r.Applies() {
			t.Fatalf("starter rule: %+v", r)
		}
	}
	again, _ := h.o.OfferStarterRules(h.ctx, repo.ID, "go", domain.OriginWeb)
	offers, _ = h.o.StarterPacks(h.ctx, repo.ID)
	if len(again) != 0 || !offers[0].Offered {
		t.Fatalf("offered twice: %d %+v", len(again), offers)
	}
	if _, err := h.o.OfferStarterRules(h.ctx, repo.ID, "cobol", domain.OriginWeb); err == nil {
		t.Fatal("unknown pack accepted")
	}
}
