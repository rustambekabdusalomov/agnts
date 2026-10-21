package orchestrator_test

import (
	"strings"
	"testing"

	"agnts/internal/domain"
	"agnts/internal/orchestrator"
)

// When a pull request merges, agnts compares its last version with what
// merged: it logs how much people changed and learns from the edits. A
// later revert is logged once and learned from too.
func TestLearnFromMergeAndRevert(t *testing.T) {
	host := newConvHost()
	h, refl := newReflectHarnessWith(t, func(d *orchestrator.Deps) {
		d.Git, d.Host = &pullGit{fakeGit: d.Git.(*fakeGit), host: host.reviewHost}, host
		d.PullReviews, d.PRPosts, d.ReviewDrafts = d.Store.(orchestrator.PullReviews), d.Store.(orchestrator.PRPosts), d.Store.(orchestrator.ReviewDrafts)
	})
	h.git.files = []domain.FileChange{{Path: "refund.go", Add: 3, Diff: "@@ -1 +1,4 @@\n+func refund(amount float64) float64 {\n+\treturn math.Round(amount*100) / 100\n+}\n x"}}
	h.ingest("PAY-40")
	h.runner.scripts = []script{
		{result: ok("s40"), files: map[string]string{orchestrator.AnalysisPath: analysis(0)}},
		{result: ok("s40"), edit: "v1"},
	}
	h.step() // analyze
	h.step() // code
	if _, err := h.o.Approve(h.ctx, "PAY-40", nil, false, domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	h.step() // push: pull request #7

	// The reviewer swapped the hand-written rounding for the money package.
	host.files = []domain.FileChange{{Path: "refund.go", Add: 3, Diff: "@@ -1 +1,4 @@\n+func refund(amount money.Cents) money.Cents {\n+\treturn money.Round(amount)\n+}\n x"}}
	if ok, err := h.o.MarkMerged(h.ctx, domain.PRRef{URL: "https://github.com/acme/api/pull/7"}, domain.OriginWebhook); err != nil || !ok {
		t.Fatalf("merge: %v %v", ok, err)
	}
	evs := h.events("PAY-40", domain.EventPeopleEdits)
	if len(evs) != 1 || evs[0].Data["added"] != float64(2) || evs[0].Data["removed"] != float64(2) || evs[0].Data["share"] != float64(1) {
		t.Fatalf("people edits event: %+v", evs)
	}
	rs, _ := refl.Reflections(h.ctx, "PAY-40")
	if len(rs) != 1 || rs[0].Source != domain.ReflectMerged || !strings.Contains(rs[0].Feedback, "+ return money.Round(amount)") ||
		!strings.Contains(rs[0].Feedback, "- return math.Round(amount*100) / 100") {
		t.Fatalf("reflections: %+v", rs)
	}

	// The reflect run reads what people changed.
	h.runner.scripts = []script{{result: ok("r1"), files: map[string]string{orchestrator.ReflectPath: reflectJSON(map[string]any{
		"title": "Money goes through the money package", "body": "Use money.Cents and money.Round for amounts.", "scope": "repository",
		"why": "The reviewer replaced math.Round", "tag": "reuse"})}}}
	h.step()
	if p := h.runner.prompts[len(h.runner.prompts)-1]; !strings.Contains(p, "people changed agnts's work before they merged it") ||
		!strings.Contains(p, "## What they changed") || !strings.Contains(p, `"tag": "reuse, layer, tests, style, logic or other"`) {
		t.Fatalf("reflect prompt:\n%s", p)
	}
	rules, _ := h.o.ListRules(h.ctx)
	var learned *domain.Rule
	for i := range rules {
		if rules[i].Title == "Money goes through the money package" {
			learned = &rules[i]
		}
	}
	if learned == nil || learned.Tag != "reuse" || learned.Source != domain.ReflectMerged || learned.Status != domain.RuleSuggested {
		t.Fatalf("learned rule: %+v", learned)
	}

	// A revert, delivered twice, is logged and learned from once.
	l := domain.CommitLink{TicketKey: "PAY-40", RepoName: "api", SHA: "deadbeef", Subject: `Revert "PAY-40: Fix refund rounding (#7)"`, Author: "bob"}
	h.o.Reverted(h.ctx, l)
	h.o.Reverted(h.ctx, l)
	if evs := h.events("PAY-40", domain.EventReverted); len(evs) != 1 || !strings.Contains(evs[0].Message, "people reverted this work") {
		t.Fatalf("revert events: %+v", evs)
	}
	rs, _ = refl.Reflections(h.ctx, "PAY-40")
	if len(rs) != 2 || rs[1].Source != domain.ReflectReverted || !strings.Contains(rs[1].Feedback, "bob reverted it") {
		t.Fatalf("reflections after the revert: %+v", rs)
	}
}
