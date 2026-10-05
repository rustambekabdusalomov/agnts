package orchestrator_test

import (
	"encoding/json"
	"errors"
	"io"
	"log/slog"
	"os"
	"strings"
	"testing"

	"hiro/internal/domain"
	"hiro/internal/orchestrator"
	"hiro/internal/store/postgres"
)

// newRulesHarness is a harness whose orchestrator has the rules store.
func newRulesHarness(t *testing.T) *harness {
	t.Helper()
	h := newHarness(t)
	pool, err := postgres.Open(h.ctx, os.Getenv("HIRO_TEST_DATABASE_URL"))
	if err != nil {
		t.Fatal(err)
	}
	t.Cleanup(pool.Close)
	if _, err := pool.Exec(h.ctx, `TRUNCATE rules RESTART IDENTITY`); err != nil {
		t.Fatal(err)
	}
	cfg := orchestrator.DefaultConfig()
	cfg.FixAttempts = 1
	h.o = orchestrator.New(cfg, orchestrator.Deps{
		Store: h.store, Runner: h.runner, Git: h.git, Host: h.host, Tracker: h.tracker, Homes: &memHomes{},
		Settings: h.settings, Usage: h.usage, Rules: postgres.NewRules(pool),
	}, slog.New(slog.NewTextHandler(io.Discard, nil)))
	return h
}

func reviewJSON(clarified string, questions ...string) string {
	qs := []any{}
	for _, q := range questions {
		qs = append(qs, map[string]any{"text": q, "options": []string{"yes", "no", " "}})
	}
	b, _ := json.Marshal(map[string]any{"interpretation": "Every new endpoint gets a test.", "clarified": clarified, "questions": qs})
	return string(b)
}

func (h *harness) rule(id int64) domain.Rule {
	h.t.Helper()
	r, err := h.o.Rule(h.ctx, id)
	if err != nil {
		h.t.Fatal(err)
	}
	return r
}

func (h *harness) addRule(title, body string, repoID *int64) domain.Rule {
	h.t.Helper()
	r, err := h.o.CreateRule(h.ctx, orchestrator.RuleInput{Title: title, Body: body, RepoID: repoID, Enabled: true}, domain.OriginWeb)
	if err != nil {
		h.t.Fatal(err)
	}
	return r
}

func repoID(id int64) *int64 { return &id }

func TestRuleQuestionsThenAppliedToTickets(t *testing.T) {
	h := newRulesHarness(t)
	r := h.addRule("Tests", "Write tests for new code.", nil)
	if r.Status != domain.RulePending {
		t.Fatalf("new rule status: %s", r.Status)
	}

	h.runner.scripts = []script{{result: ok("r1"), files: map[string]string{orchestrator.RulePath: reviewJSON("", "Unit tests only, or integration too?")}}}
	h.step() // review
	r = h.rule(r.ID)
	if r.Status != domain.RuleQuestions || r.Rounds != 1 || len(r.Open()) != 1 {
		t.Fatalf("after review: status=%s rounds=%d open=%d", r.Status, r.Rounds, len(r.Open()))
	}
	if got := r.Questions[0].Options; len(got) != 2 {
		t.Fatalf("blank options kept: %q", got)
	}
	if p := h.runner.prompts[0]; !strings.Contains(p, "Write tests for new code.") || !strings.Contains(p, "in every repository") {
		t.Fatalf("review prompt:\n%s", p)
	}

	// Tickets ignore a rule with open questions.
	h.ingest("PAY-1")
	h.runner.scripts = []script{{result: ok("s1"), files: map[string]string{orchestrator.AnalysisPath: analysis(1)}}}
	h.step()
	if strings.Contains(h.runner.prompts[1], "Team rules") {
		t.Fatal("a rule with open questions reached a ticket")
	}

	if _, err := h.o.AnswerRule(h.ctx, r.ID, []orchestrator.RuleAnswer{{Index: 0, Answer: ""}}, domain.OriginWeb); !errors.Is(err, orchestrator.ErrInvalid) {
		t.Fatalf("blank answer: %v", err)
	}
	if _, err := h.o.AnswerRule(h.ctx, r.ID, []orchestrator.RuleAnswer{{Index: 0, Answer: "Both", Note: "integration for HTTP"}}, domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	h.runner.scripts = []script{{result: ok("r2"), files: map[string]string{orchestrator.RulePath: reviewJSON("Add unit tests and, for HTTP handlers, an integration test.")}}}
	h.step() // second review
	if p := h.runner.prompts[2]; !strings.Contains(p, "A: Both (integration for HTTP)") {
		t.Fatalf("answers missing from the second review:\n%s", p)
	}
	r = h.rule(r.ID)
	if r.Status != domain.RuleReady || r.Text() != "Add unit tests and, for HTTP handlers, an integration test." || r.AnalyzedAt == nil {
		t.Fatalf("after answers: %+v", r)
	}

	h.ingest("PAY-2")
	h.runner.scripts = []script{{result: ok("s2"), files: map[string]string{orchestrator.AnalysisPath: analysis(0)}}}
	h.step()
	p := h.runner.prompts[3]
	if !strings.Contains(p, "## Team rules") || !strings.Contains(p, "Global rule: Tests") || !strings.Contains(p, "for HTTP handlers, an integration test") {
		t.Fatalf("ticket prompt without the rule:\n%s", p)
	}
	evs, _ := h.store.Events(h.ctx, orchestrator.EventFilter{TicketKey: "PAY-2"})
	found := false
	for _, e := range evs {
		found = found || (e.Type == domain.EventRule && strings.Contains(e.Message, "following 1 team rule: Tests"))
	}
	if !found {
		t.Fatal("no event says which rules the ticket followed")
	}

	// The coding run gets the rule too.
	h.runner.scripts = []script{{result: ok("s2"), edit: "fix"}}
	h.step()
	if !strings.Contains(h.runner.prompts[4], "Global rule: Tests") {
		t.Fatalf("coding prompt without the rule:\n%s", h.runner.prompts[4])
	}
}

func TestRuleScopeAndEnabled(t *testing.T) {
	h := newRulesHarness(t)
	other, err := h.store.SaveRepository(h.ctx, domain.Repository{
		Name: "web", Kind: "side", Provider: "github", CloneURL: "https://github.com/acme/web.git", DefaultBranch: "main",
	})
	if err != nil {
		t.Fatal(err)
	}
	h.addRule("Money", "Use decimal for amounts.", repoID(1))
	h.addRule("Styles", "Use CSS modules.", &other.ID)
	off := h.addRule("Off", "Never applies.", nil)
	clear := script{result: ok("r"), files: map[string]string{orchestrator.RulePath: reviewJSON("")}}
	h.runner.scripts = []script{clear, clear, clear}
	h.step()
	h.step()
	h.step()
	if p := h.runner.prompts[0]; !strings.Contains(p, "in the repository api") || !strings.Contains(p, "checked out at /workspace") {
		t.Fatalf("repository rule review prompt:\n%s", p)
	}
	if _, err := h.o.UpdateRule(h.ctx, off.ID, orchestrator.RuleInput{Title: off.Title, Body: off.Body, Enabled: false}, domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	if r := h.rule(off.ID); r.Status != domain.RuleReady || r.Enabled {
		t.Fatalf("turning a rule off must not requeue it: %+v", r)
	}

	h.ingest("PAY-1")
	h.runner.scripts = []script{{result: ok("s1"), files: map[string]string{orchestrator.AnalysisPath: analysis(0)}}}
	h.step()
	p := h.runner.prompts[3]
	if !strings.Contains(p, "Repository rule: Money") || strings.Contains(p, "Styles") || strings.Contains(p, "Never applies") {
		t.Fatalf("wrong rules in the ticket prompt:\n%s", p)
	}
}

func TestRuleEditDuringReviewDropsResult(t *testing.T) {
	h := newRulesHarness(t)
	r := h.addRule("Logs", "Log errors.", nil)
	h.runner.onClaude = func(orchestrator.ClaudeRequest) {
		h.runner.onClaude = nil
		if _, err := h.o.UpdateRule(h.ctx, r.ID, orchestrator.RuleInput{Title: "Logs", Body: "Log errors with slog.", Enabled: true}, domain.OriginWeb); err != nil {
			t.Error(err)
		}
	}
	h.runner.scripts = []script{{result: ok("r1"), files: map[string]string{orchestrator.RulePath: reviewJSON("old")}}}
	h.step()
	got := h.rule(r.ID)
	if got.Status != domain.RulePending || got.Clarified != "" || got.Body != "Log errors with slog." {
		t.Fatalf("a review of the old text was applied: %+v", got)
	}
	h.runner.scripts = []script{{result: ok("r2"), files: map[string]string{orchestrator.RulePath: reviewJSON("new")}}}
	h.step()
	if got := h.rule(r.ID); got.Status != domain.RuleReady || got.Clarified != "new" {
		t.Fatalf("the edited rule was not reviewed: %+v", got)
	}
}

func TestRuleFailureAcceptAndReview(t *testing.T) {
	h := newRulesHarness(t)
	r := h.addRule("Docs", "Document public functions.", nil)
	h.runner.scripts = []script{{result: ok("r1")}} // writes no rule.json
	h.step()
	if got := h.rule(r.ID); got.Status != domain.RuleFailed || !strings.Contains(got.Error, "did not write") {
		t.Fatalf("missing rule.json: %+v", got)
	}
	if _, err := h.o.ReviewRule(h.ctx, r.ID, domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	if _, err := h.o.ReviewRule(h.ctx, r.ID, domain.OriginWeb); !errors.Is(err, orchestrator.ErrInvalid) {
		t.Fatalf("second review while queued: %v", err)
	}
	h.runner.scripts = []script{{result: ok("r2"), files: map[string]string{orchestrator.RulePath: reviewJSON("", "Which languages?")}}}
	h.step()
	got, err := h.o.AcceptRule(h.ctx, r.ID, domain.OriginWeb)
	if err != nil {
		t.Fatal(err)
	}
	if got.Status != domain.RuleReady || len(got.Questions) != 0 || got.Text() != "Document public functions." {
		t.Fatalf("accepted as written: %+v", got)
	}
	if _, err := h.o.AcceptRule(h.ctx, r.ID, domain.OriginWeb); !errors.Is(err, orchestrator.ErrInvalid) {
		t.Fatalf("accepting a ready rule: %v", err)
	}
}

func TestRuleRateLimitedRequeues(t *testing.T) {
	h := newRulesHarness(t)
	r := h.addRule("Small", "Keep functions under 50 lines.", nil)
	h.runner.scripts = []script{{result: orchestrator.ClaudeResult{RateLimited: true}}}
	h.step()
	if got := h.rule(r.ID); got.Status != domain.RulePending {
		t.Fatalf("rate limited review: %s", got.Status)
	}
	if !h.usage.paused {
		t.Fatal("the plan limit was not recorded")
	}
}

func TestRuleQuestionRoundsEnd(t *testing.T) {
	h := newRulesHarness(t)
	r := h.addRule("Naming", "Use good names.", nil)
	for round := 1; round <= domain.RuleMaxRounds; round++ {
		h.runner.scripts = []script{{result: ok("r"), files: map[string]string{orchestrator.RulePath: reviewJSON("", "What is good?")}}}
		h.step()
		got := h.rule(r.ID)
		if got.Status != domain.RuleQuestions || got.Rounds != round {
			t.Fatalf("round %d: %+v", round, got)
		}
		open := got.Open()
		idx := len(got.Questions) - len(open)
		if _, err := h.o.AnswerRule(h.ctx, r.ID, []orchestrator.RuleAnswer{{Index: idx, Answer: "descriptive"}}, domain.OriginWeb); err != nil {
			t.Fatal(err)
		}
	}
	h.runner.scripts = []script{{result: ok("r"), files: map[string]string{orchestrator.RulePath: reviewJSON("Use descriptive names.", "Still unsure?")}}}
	h.step()
	if p := h.runner.prompts[len(h.runner.prompts)-1]; !strings.Contains(p, "Do not ask any more questions") {
		t.Fatalf("last round still allows questions:\n%s", p)
	}
	if got := h.rule(r.ID); got.Status != domain.RuleReady || len(got.Questions) != domain.RuleMaxRounds {
		t.Fatalf("after the last round: %+v", got)
	}
}
