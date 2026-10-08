package orchestrator_test

import (
	"encoding/json"
	"errors"
	"io"
	"log/slog"
	"os"
	"strings"
	"testing"

	"agnts/internal/domain"
	"agnts/internal/orchestrator"
	"agnts/internal/store/postgres"
)

// newReflectHarness has the rules and reflection stores.
func newReflectHarness(t *testing.T) (*harness, *postgres.Reflections) {
	t.Helper()
	h := newRulesHarness(t)
	pool, err := postgres.Open(h.ctx, os.Getenv("AGNTS_TEST_DATABASE_URL"))
	if err != nil {
		t.Fatal(err)
	}
	t.Cleanup(pool.Close)
	if _, err := pool.Exec(domain.System(h.ctx), `TRUNCATE reflections RESTART IDENTITY`); err != nil {
		t.Fatal(err)
	}
	refl := postgres.NewReflections(pool)
	cfg := orchestrator.DefaultConfig()
	cfg.FixAttempts = 1
	h.o = orchestrator.New(cfg, orchestrator.Deps{
		Store: h.store, Runner: h.runner, Git: h.git, Host: h.host, Trackers: map[domain.TicketSource]orchestrator.Tracker{domain.SourceJira: h.tracker}, Homes: &memHomes{},
		Settings: h.settings, Usage: h.usage, Rules: postgres.NewRules(pool), Reflections: refl,
	}, slog.New(slog.NewTextHandler(io.Discard, nil)))
	return h, refl
}

func reflectJSON(s ...map[string]any) string {
	if s == nil {
		s = []map[string]any{}
	}
	b, _ := json.Marshal(map[string]any{"suggestions": s})
	return string(b)
}

func TestReflectSuggestsRulesFromFeedback(t *testing.T) {
	h, refl := newReflectHarness(t)
	existing := h.addRule("Tests", "Write tests for new code.", nil)
	h.runner.scripts = []script{{result: ok("r0"), files: map[string]string{orchestrator.RulePath: reviewJSON("Write a test for every change.")}}}
	h.step() // the rule's review
	h.toReview("PAY-1", analysis(0))

	if _, err := h.o.RequestChanges(h.ctx, "PAY-1", "Don't put SQL in handlers; we always go through the store package.", nil, nil, domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	rs, _ := refl.Reflections(h.ctx, "PAY-1")
	if len(rs) != 1 || rs[0].Source != domain.ReflectChanges || rs[0].Status != domain.ReflectPending || rs[0].RepoID == nil {
		t.Fatalf("queued reflections: %+v", rs)
	}

	h.runner.scripts = []script{
		{result: ok("s-PAY-1"), edit: "fix 2"}, // coding the change request goes first
		{result: ok("x1"), files: map[string]string{orchestrator.ReflectPath: reflectJSON(
			map[string]any{"title": "Database access goes through store", "body": "Never query the database from httpapi handlers; add a method to internal/store.", "scope": "repository", "why": "The reviewer moved SQL out of the handler."},
			map[string]any{"title": "tests", "body": "Duplicate of an existing rule.", "scope": "global"},
			map[string]any{"title": "Errors", "body": "Wrap errors with %w.", "scope": "global"},
			map[string]any{"title": "Fourth", "body": "Over the limit."},
		)}},
	}
	h.step() // code
	h.step() // reflect
	p := h.runner.prompts[len(h.runner.prompts)-1]
	for _, want := range []string{"asked for changes", "Don't put SQL in handlers", orchestrator.ChangePath, "[global] Tests: Write a test for every change.", orchestrator.ReflectPath, "at most 2"} {
		if !strings.Contains(p, want) {
			t.Fatalf("reflect prompt lacks %q:\n%s", want, p)
		}
	}
	rs, _ = refl.Reflections(h.ctx, "PAY-1")
	if rs[0].Status != domain.ReflectDone || rs[0].Suggested != 2 {
		t.Fatalf("reflection after the run: %+v", rs[0])
	}
	all, _ := h.o.ListRules(h.ctx)
	var sug domain.Rule
	titles := []string{}
	for _, r := range all {
		titles = append(titles, r.Title)
		if r.Status == domain.RuleSuggested && r.RepoID != nil {
			sug = r
		}
	}
	if strings.Join(titles, ",") != "Tests,Errors,Database access goes through store" {
		t.Fatalf("rules after reflecting: %q", titles)
	}
	if sug.ID == 0 || sug.SourceTicket != "PAY-1" || sug.RepoID == nil || sug.Reason != "The reviewer moved SQL out of the handler." || !sug.Enabled {
		t.Fatalf("suggested rule: %+v (all %d)", sug, len(all))
	}
	evs := h.events("PAY-1", domain.EventRule)
	if len(evs) == 0 || !strings.Contains(evs[len(evs)-1].Message, "suggests 2 rules: Database access goes through store, Errors") {
		t.Fatalf("ticket event: %+v", evs)
	}

	// A suggestion never reaches tickets until adopted.
	h.ingest("PAY-2")
	h.runner.scripts = []script{{result: ok("s2"), files: map[string]string{orchestrator.AnalysisPath: analysis(0)}}}
	h.step()
	if strings.Contains(h.runner.prompts[len(h.runner.prompts)-1], "Database access goes through store") {
		t.Fatal("a suggested rule reached a ticket")
	}
	// Dismissing hides it and keeps it from being suggested again.
	if err := h.o.DeleteRule(h.ctx, sug.ID, domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	if r := h.rule(sug.ID); r.Status != domain.RuleDismissed {
		t.Fatalf("after dismiss: %s", r.Status)
	}
	all, _ = h.o.ListRules(h.ctx)
	if len(all) != 2 || all[0].ID != existing.ID || all[1].Title != "Errors" {
		t.Fatalf("list after dismiss: %+v", all)
	}

	// Rejecting with a reason reflects too; agnts's own feedback never does.
	if _, err := h.o.Reject(h.ctx, "PAY-2", "We never build admin pages in jQuery.", domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	h.runner.scripts = []script{{result: ok("x2"), files: map[string]string{orchestrator.ReflectPath: reflectJSON(
		map[string]any{"title": "database access goes through STORE", "body": "Same as the dismissed one."},
	)}}}
	h.step()
	p = h.runner.prompts[len(h.runner.prompts)-1]
	if !strings.Contains(p, "rejected the work") || !strings.Contains(p, ", declined] Database access goes through store") {
		t.Fatalf("second reflect prompt:\n%s", p)
	}
	all, _ = h.o.ListRules(h.ctx)
	if len(all) != 2 {
		t.Fatalf("a declined suggestion came back: %+v", all)
	}
	h.idle()
}

func TestAdoptSuggestedRule(t *testing.T) {
	h, _ := newReflectHarness(t)
	h.toReview("PAY-1", analysis(0))
	if _, err := h.o.RequestChanges(h.ctx, "PAY-1", "Use the money package for amounts.", nil, nil, domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	h.runner.scripts = []script{
		{result: ok("s-PAY-1"), edit: "fix 2"},
		{result: ok("x1"), files: map[string]string{orchestrator.ReflectPath: reflectJSON(
			map[string]any{"title": "Money", "body": "Represent amounts with internal/money.Amount.", "scope": "global", "why": "w"},
			map[string]any{"title": "Errors", "body": "Wrap errors with %w.", "scope": "global", "why": "w"},
		)}},
	}
	h.step()
	h.step()
	all, _ := h.o.ListRules(h.ctx)
	if len(all) != 2 || all[0].RepoID != nil {
		t.Fatalf("suggestions: %+v", all)
	}
	// Adopt one through a review, the other as written.
	if r, err := h.o.ReviewRule(h.ctx, all[0].ID, domain.OriginWeb); err != nil || r.Status != domain.RulePending {
		t.Fatalf("adopt with a review: %+v %v", r, err)
	}
	if r, err := h.o.AcceptRule(h.ctx, all[1].ID, domain.OriginWeb); err != nil || r.Status != domain.RuleReady || !r.Applies() {
		t.Fatalf("adopt as written: %+v %v", r, err)
	}
	if _, err := h.o.AcceptRule(h.ctx, all[1].ID, domain.OriginWeb); !errors.Is(err, orchestrator.ErrInvalid) {
		t.Fatalf("accepting a ready rule: %v", err)
	}
}
