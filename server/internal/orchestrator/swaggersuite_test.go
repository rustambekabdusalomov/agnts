package orchestrator_test

import (
	"errors"
	"strings"
	"testing"
	"time"

	"agnts/internal/apiclient"
	"agnts/internal/domain"
	"agnts/internal/orchestrator"
)

// A result where a case that passed before (users-list) now fails.
const worseResults = `{"status":"done","summary":"3 cases","cases":[
 {"id":"users-list","operation":"GET /users","case":"happy path","verdict":"fail","reason":"id is a string","requests":["r-001"]},
 {"id":"users-get","operation":"GET /users/{id}","case":"known id","verdict":"pass","requests":["r-002"]},
 {"id":"users-unknown","operation":"GET /users/{id}","case":"unknown id","expected":"404","verdict":"fail","reason":"500","requests":["r-003"]}]}`

func TestSwaggerSuites(t *testing.T) {
	h := newSwaggerHarness(t)
	first := h.create(false)
	h.runner.scripts = []script{{result: ok("s1"), files: swaggerFiles(goodResults)}}
	h.step()
	h.expect(first.Key, domain.StateWaitingForReview)

	su, err := h.o.SaveSuiteFromTicket(h.ctx, orchestrator.SuiteInput{FromTicket: first.Key, Name: "Users API", Schedule: domain.ScheduleDaily, Hour: 6, Enabled: true})
	if err != nil || !su.HasSecret || su.NextRunAt == nil || len(su.Operations) != 3 {
		t.Fatalf("save suite: %+v %v", su, err)
	}
	if st, _ := h.tests.SwaggerTest(h.ctx, first.ID); st.SuiteID == nil || *st.SuiteID != su.ID {
		t.Error("the ticket's test is not the suite's first run")
	}

	// A suite run: a new ticket that reuses the last plan and leads with
	// what is new since the last run.
	run, err := h.o.RunSuite(h.ctx, su.ID, domain.OriginWeb)
	if err != nil || run.Key == first.Key || run.State != domain.StateCoding || run.Held {
		t.Fatalf("run suite: %+v %v", run, err)
	}
	if v, _ := h.tests.SwaggerTestAuth(h.ctx, run.ID); v != swaggerToken {
		t.Errorf("the run's token = %q", v)
	}
	if _, err := h.o.RunSuite(h.ctx, su.ID, domain.OriginWeb); !errors.Is(err, orchestrator.ErrSuiteBusy) {
		t.Errorf("a second run while the first is going: %v", err)
	}
	h.runner.scripts = []script{{result: ok("s2"), files: swaggerFiles(worseResults)}}
	h.step()
	h.expect(run.Key, domain.StateWaitingForReview)
	prompt := h.runner.prompts[len(h.runner.prompts)-1]
	if !strings.Contains(prompt, "already holds the plan of this suite's last run") || !strings.Contains(h.runner.written[apiclient.PlanPath], "users-list") {
		t.Errorf("the last plan was not reused:\n%s", prompt)
	}
	evs, _ := h.store.Events(h.ctx, orchestrator.EventFilter{TicketKey: run.Key})
	found := false
	for _, e := range evs {
		found = found || (e.Type == domain.EventSwaggerResults && strings.Contains(e.Message, "1 new since") && strings.Contains(e.Message, "GET /users · happy path"))
	}
	if !found {
		t.Error("the results event does not lead with the new failure")
	}
	if v, _ := h.o.SwaggerResultsOf(h.ctx, run.Key); v.Previous == nil || strings.Join(v.NewFailures, ",") != "GET /users · happy path" {
		t.Errorf("the results page does not compare with the suite's last run: %+v", v.NewFailures)
	}

	// The deploy hook runs the suite; an unknown token does nothing.
	tok, err := h.o.RotateSuiteHook(h.ctx, su.ID)
	if err != nil || !strings.HasPrefix(tok, orchestrator.SuiteHookPrefix) {
		t.Fatal(tok, err)
	}
	byHook, err := h.o.RunSuiteByHook(h.ctx, tok)
	if err != nil || byHook.Kind != domain.KindSwaggerTest {
		t.Fatalf("by hook: %+v %v", byHook, err)
	}
	if _, err := h.o.RunSuiteByHook(h.ctx, orchestrator.SuiteHookPrefix+"nope"); !errors.Is(err, domain.ErrNotFound) {
		t.Errorf("an unknown hook: %v", err)
	}

	// A due scheduled run while the last one is still going is skipped,
	// and the schedule moves on.
	if _, err := h.pool.Exec(h.ctx, `UPDATE swagger_suites SET next_run_at = now() - interval '1 minute' WHERE id = $1`, su.ID); err != nil {
		t.Fatal(err)
	}
	h.o.RunDueSuites(h.ctx)
	got, _ := h.o.Suite(h.ctx, su.ID)
	if got.LastTicketKey != byHook.Key || got.NextRunAt == nil || !got.NextRunAt.After(time.Now()) {
		t.Errorf("after a skipped scheduled run: %+v", got)
	}
}
