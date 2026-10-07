package orchestrator_test

import (
	"encoding/json"
	"errors"
	"strings"
	"testing"

	"agnts/internal/domain"
	"agnts/internal/orchestrator"
)

// analysisWith is analysis(0) with follow-ups added.
func analysisWith(fs ...map[string]any) string {
	var a map[string]any
	_ = json.Unmarshal([]byte(analysis(0)), &a)
	a["followUps"] = fs
	b, _ := json.Marshal(a)
	return string(b)
}

func summaryWith(fs ...map[string]any) string {
	b, _ := json.Marshal(map[string]any{"summary": "Rounded refunds.", "notes": []string{}, "followUps": fs})
	return string(b)
}

func followUp(typ, title string) map[string]any {
	return map[string]any{"type": typ, "title": title, "description": "Do " + title + ".", "serves": "PAY-1 needs it", "kind": "code", "priority": "high"}
}

func suggestions(t *testing.T, h *harness, key string) []domain.Suggestion {
	t.Helper()
	f, err := h.o.ListFollowUps(h.ctx, key)
	if err != nil {
		t.Fatal(err)
	}
	return f.Suggestions
}

func lastPrompt(h *harness) string { return h.runner.prompts[len(h.runner.prompts)-1] }

func TestFollowUpsOffByDefault(t *testing.T) {
	h := newHarness(t)
	h.ingest("PAY-1")
	h.runner.scripts = []script{
		{result: ok("s"), files: map[string]string{orchestrator.AnalysisPath: analysisWith(followUp("prerequisite", "Add a column"))}},
		{result: ok("s"), edit: "fix", files: map[string]string{orchestrator.SummaryPath: summaryWith(followUp("unfinished", "Test it"))}},
	}
	h.step()
	if strings.Contains(lastPrompt(h), "Follow-up tickets") {
		t.Fatal("follow-ups asked for while off")
	}
	h.step()
	h.expect("PAY-1", domain.StateWaitingForReview)
	if strings.Contains(lastPrompt(h), "Follow-up tickets") {
		t.Fatal("follow-ups asked for while off")
	}
	if ss := suggestions(t, h, "PAY-1"); len(ss) != 0 {
		t.Fatalf("suggestions stored while off: %+v", ss)
	}

	// Turned on for this ticket only.
	on := true
	tk, err := h.o.SetFollowUps(h.ctx, "PAY-1", &on, domain.OriginWeb)
	if err != nil || tk.SuggestFollowUps == nil || !*tk.SuggestFollowUps {
		t.Fatalf("set follow-ups: %+v %v", tk.SuggestFollowUps, err)
	}
	if v, _ := h.o.View(h.ctx, "PAY-1"); !v.FollowUpsOn {
		t.Fatal("view: follow-ups should be on for the ticket")
	}
}

func TestAnalysisFollowUpsAcceptedAtOnce(t *testing.T) {
	h := newHarness(t)
	h.settings.s.SuggestFollowUps = true
	h.ingest("PAY-1")
	h.runner.scripts = []script{{result: ok("s"), files: map[string]string{orchestrator.AnalysisPath: analysisWith(
		followUp("prerequisite", "Add refund_cents column"),
		followUp("split", "Admin refund screen"),
		map[string]any{"type": "idea", "title": "Rewrite payments", "serves": "faster"},
		map[string]any{"type": "gap", "title": "No serves"},
	)}}}
	h.step()
	h.expect("PAY-1", domain.StateCoding)
	p := lastPrompt(h)
	if !strings.Contains(p, "## Follow-up tickets") || !strings.Contains(p, "prerequisite: work that must be done") ||
		!strings.Contains(p, "Do not invent new work") || !strings.Contains(p, orchestrator.AnalysisPath) {
		t.Fatalf("analysis prompt:\n%s", p)
	}

	ss := suggestions(t, h, "PAY-1")
	if len(ss) != 2 || ss[0].Source != domain.SuggestFromAnalyze || ss[0].Type != "prerequisite" || ss[1].Type != "split" {
		t.Fatalf("suggestions: %+v", ss)
	}
	evs, _ := h.store.Events(h.ctx, orchestrator.EventFilter{TicketKey: "PAY-1"})
	if !slicesContainsFunc(evs, func(e domain.Event) bool {
		return e.Type == domain.EventFollowUps && strings.HasPrefix(e.Message, "2 follow-ups suggested")
	}) {
		t.Fatal("no follow_ups_suggested event")
	}

	// Analysis suggestions can be created while the parent is still worked on.
	res, err := h.o.AcceptSuggestions(h.ctx, "PAY-1", []orchestrator.AcceptInput{
		{ID: ss[0].ID, Title: "Add refund_cents"},
		{ID: 9999},
		{ID: ss[1].ID, Target: "fax"},
	}, domain.OriginWeb)
	if err != nil || len(res) != 3 {
		t.Fatalf("accept: %+v %v", res, err)
	}
	c := res[0].Ticket
	if res[0].Err != nil || c == nil {
		t.Fatalf("first: %v", res[0].Err)
	}
	if !c.Held || c.FollowUpOf != "PAY-1" || c.Source != domain.SourceLocal || c.Title != "Add refund_cents" || c.Kind != domain.KindCode ||
		c.KindAuto || c.Priority != "high" || c.RepoID == nil || !strings.Contains(c.Description, "## Follow-up of PAY-1") ||
		!strings.Contains(c.Description, "PAY-1 needs it") {
		t.Fatalf("follow-up ticket: %+v", c)
	}
	if !errors.Is(res[1].Err, domain.ErrNotFound) || !errors.Is(res[2].Err, orchestrator.ErrInvalid) {
		t.Fatalf("bad items: %v / %v", res[1].Err, res[2].Err)
	}

	// Held: nothing starts, so no tokens are spent.
	if ok, err := h.o.RunOnce(h.ctx); err != nil {
		t.Fatal(err)
	} else if ok && h.state(c.Key).State != domain.StateNew {
		t.Fatal("a follow-up started on its own")
	}

	again, _ := h.o.AcceptSuggestions(h.ctx, "PAY-1", []orchestrator.AcceptInput{{ID: ss[0].ID}}, domain.OriginWeb)
	if !errors.Is(again[0].Err, domain.ErrSuggestionDecided) {
		t.Fatalf("accepted twice: %+v", again[0])
	}
	if _, err := h.o.DismissSuggestion(h.ctx, "PAY-1", ss[1].ID, domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	if _, err := h.o.DismissSuggestion(h.ctx, "PAY-1", ss[1].ID, domain.OriginWeb); !errors.Is(err, domain.ErrConflict) {
		t.Fatalf("dismissed twice: %v", err)
	}

	v, err := h.o.View(h.ctx, "PAY-1")
	if err != nil || len(v.FollowUps.Children) != 1 || v.FollowUps.Children[0].Key != c.Key {
		t.Fatalf("view children: %+v %v", v.FollowUps.Children, err)
	}
	rows, _ := h.o.Rows(h.ctx, []domain.Ticket{v.Ticket})
	if rows[0].OpenSuggestions != 0 {
		t.Fatalf("open suggestions: %d", rows[0].OpenSuggestions)
	}

	// The follow-up's own analysis stays on the root goal and is told
	// what not to suggest again.
	if _, err := h.o.Start(h.ctx, c.Key, domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	h.runner.scripts = []script{{result: ok("c"), files: map[string]string{orchestrator.AnalysisPath: analysis(0)}}}
	h.step()
	p = lastPrompt(h)
	if !strings.Contains(p, "is itself a follow-up") || !strings.Contains(p, "- PAY-1: Fix refund rounding") ||
		!strings.Contains(p, `the original goal of PAY-1`) || !strings.Contains(p, "Stay on the root's goal") ||
		!strings.Contains(p, "- Admin refund screen (declined)") || !strings.Contains(p, `"type": "one of prerequisite, split"`) {
		t.Fatalf("follow-up analysis prompt lacks the chain:\n%s", p)
	}
}

func TestWorkFollowUpsWaitForDone(t *testing.T) {
	h := newHarness(t)
	h.settings.s.SuggestFollowUps = true
	h.ingest("PAY-1")
	h.runner.scripts = []script{
		{result: ok("s"), files: map[string]string{orchestrator.AnalysisPath: analysis(0)}},
		{result: ok("s"), edit: "v1", files: map[string]string{orchestrator.SummaryPath: summaryWith(
			followUp("unfinished", "Update the CSV export"), followUp("unfinished", "Test negative refunds"))}},
	}
	h.step()
	h.step()
	h.expect("PAY-1", domain.StateWaitingForReview)
	if p := lastPrompt(h); !strings.Contains(p, "unfinished: something this ticket needs") || !strings.Contains(p, orchestrator.SummaryPath) {
		t.Fatalf("code prompt:\n%s", p)
	}
	ss := suggestions(t, h, "PAY-1")
	if len(ss) != 2 || ss[0].Source != domain.SuggestFromWork {
		t.Fatalf("suggestions: %+v", ss)
	}
	res, _ := h.o.AcceptSuggestions(h.ctx, "PAY-1", []orchestrator.AcceptInput{{ID: ss[0].ID}}, domain.OriginWeb)
	if !errors.Is(res[0].Err, orchestrator.ErrInvalid) {
		t.Fatalf("accepted before done: %+v", res[0])
	}
	if _, err := h.o.DismissSuggestion(h.ctx, "PAY-1", ss[1].ID, domain.OriginWeb); err != nil {
		t.Fatal(err)
	}

	// Changes requested: the rerun replaces open work suggestions; the
	// dismissed one stays and the prompt says not to suggest it again.
	if _, err := h.o.RequestChanges(h.ctx, "PAY-1", "Also log refunds.", nil, nil, domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	h.runner.scripts = []script{{result: ok("s2"), edit: "v2", files: map[string]string{orchestrator.SummaryPath: summaryWith(followUp("prerequisite", "Enable refund logs in prod"))}}}
	h.step()
	h.expect("PAY-1", domain.StateWaitingForReview)
	if p := lastPrompt(h); !strings.Contains(p, "Test negative refunds (declined)") {
		t.Fatalf("feedback prompt does not list the declined follow-up:\n%s", p)
	}
	ss = suggestions(t, h, "PAY-1")
	if len(ss) != 2 || ss[0].Status != domain.SuggestionDismissed || ss[1].Title != "Enable refund logs in prod" || ss[1].Revision != 1 {
		t.Fatalf("after rerun: %+v", ss)
	}

	if _, err := h.o.Approve(h.ctx, "PAY-1", nil, false, domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	h.step()
	h.expect("PAY-1", domain.StateDone)
	res, _ = h.o.AcceptSuggestions(h.ctx, "PAY-1", []orchestrator.AcceptInput{{ID: ss[1].ID, Kind: "plan", Priority: "low"}}, domain.OriginMobile)
	if res[0].Err != nil || res[0].Ticket.Kind != domain.KindPlan || res[0].Ticket.Priority != "low" {
		t.Fatalf("accept after done: %+v", res[0])
	}
}

func TestFollowUpToJira(t *testing.T) {
	h := newHarness(t)
	h.settings.s.SuggestFollowUps = true
	h.ingest("PAY-1")
	h.runner.scripts = []script{{result: ok("s"), files: map[string]string{orchestrator.AnalysisPath: analysisWith(
		followUp("prerequisite", "Add refund_cents column"), followUp("split", "Admin screen"))}}}
	h.step()
	ss := suggestions(t, h, "PAY-1")

	var heldWhenLabelled bool
	h.tracker.onLabel = func(key string) {
		tk, err := h.store.TicketByKey(h.ctx, key)
		heldWhenLabelled = err == nil && tk.Held
	}
	res, err := h.o.AcceptSuggestions(h.ctx, "PAY-1", []orchestrator.AcceptInput{{ID: ss[0].ID, Target: orchestrator.TargetJira}}, domain.OriginWeb)
	if err != nil || res[0].Err != nil {
		t.Fatalf("accept to Jira: %+v %v", res, err)
	}
	c := res[0].Ticket
	if c.Key != "PAY-100" || c.Source != domain.SourceJira || !c.Held || c.FollowUpOf != "PAY-1" {
		t.Fatalf("jira follow-up: %+v", c)
	}
	if !heldWhenLabelled {
		t.Fatal("the issue was labelled before agnts kept it as a held ticket")
	}
	want := []string{"create PAY-100", "label PAY-100 code", "link PAY-100 PAY-1"}
	if strings.Join(h.tracker.calls, "|") != strings.Join(want, "|") {
		t.Fatalf("issue calls: %v", h.tracker.calls)
	}
	if in := h.tracker.issues[0]; in.Project != "PAY" || in.Priority != "high" || !strings.Contains(in.Description, "Follow-up of PAY-1") {
		t.Fatalf("issue: %+v", in)
	}

	// The webhook for the labelled issue finds the ticket and leaves it held.
	if created, err := h.o.Ingest(h.ctx, orchestrator.Incoming{Key: "PAY-100", Project: "PAY", Title: c.Title, Description: c.Description}, domain.OriginWebhook); err != nil || created {
		t.Fatalf("ingest: %v %v", created, err)
	}
	if !h.state("PAY-100").Held {
		t.Fatal("the webhook started the follow-up")
	}

	// A failed Jira call leaves the suggestion open.
	h.tracker.issueErr = errors.New("jira down")
	res, _ = h.o.AcceptSuggestions(h.ctx, "PAY-1", []orchestrator.AcceptInput{{ID: ss[1].ID, Target: orchestrator.TargetJira}}, domain.OriginWeb)
	if res[0].Err == nil {
		t.Fatal("expected a Jira error")
	}
	if ss = suggestions(t, h, "PAY-1"); ss[1].Status != domain.SuggestionOpen {
		t.Fatalf("suggestion after a failed Jira call: %+v", ss[1])
	}
}

func TestReviewFollowUpsAndFindings(t *testing.T) {
	h, _ := newReviewHarness(t)
	h.settings.s.SuggestFollowUps = true
	h.toReview("PAY-1", withComplexity("simple"))
	var rv map[string]any
	_ = json.Unmarshal([]byte(codeReviewJSON("has_concerns",
		map[string]any{"severity": "major", "category": "correctness", "file": "refund.go", "line": 9, "title": "Caller truncates", "detail": "caller.go floors it", "suggestion": "Round there too."},
	)), &rv)
	rv["followUps"] = []any{followUp("gap", "Reconcile old refunds")}
	b, _ := json.Marshal(rv)
	h.runner.scripts = []script{reviewScript("r", string(b))}
	h.step()
	if p := lastPrompt(h); !strings.Contains(p, "gap: a concrete risk") || !strings.Contains(p, orchestrator.ReviewPath) {
		t.Fatalf("review prompt:\n%s", p)
	}
	ss := suggestions(t, h, "PAY-1")
	if len(ss) != 1 || ss[0].Source != domain.SuggestFromReview {
		t.Fatalf("review suggestions: %+v", ss)
	}
	v, _ := h.o.View(h.ctx, "PAY-1")
	if v.Review == nil || len(v.Review.FollowUps) != 0 {
		t.Fatal("follow-ups should live as suggestions, not in the stored review")
	}

	x, err := h.o.SuggestFromFinding(h.ctx, "PAY-1", 0, domain.OriginWeb)
	if err != nil {
		t.Fatal(err)
	}
	if x.Source != domain.SuggestFromManual || x.Title != "Caller truncates" || x.Priority != "high" ||
		!strings.Contains(x.Description, "refund.go:9") || !strings.Contains(x.Description, "Round there too.") {
		t.Fatalf("from finding: %+v", x)
	}
	if _, err := h.o.SuggestFromFinding(h.ctx, "PAY-1", 5, domain.OriginWeb); !errors.Is(err, orchestrator.ErrInvalid) {
		t.Fatalf("bad finding index: %v", err)
	}
}

func slicesContainsFunc[T any](s []T, f func(T) bool) bool {
	for _, x := range s {
		if f(x) {
			return true
		}
	}
	return false
}

// A follow-up of a Jira ticket can go to Plane: the project comes from the
// repository's Plane project, and the issues are not linked across trackers.
func TestFollowUpToPlane(t *testing.T) {
	h := newHarness(t)
	h.settings.s.SuggestFollowUps = true
	h.ingest("PAY-1")
	h.runner.scripts = []script{{result: ok("s"), files: map[string]string{orchestrator.AnalysisPath: analysisWith(
		followUp("prerequisite", "Add refund_cents column"))}}}
	h.step()
	ss := suggestions(t, h, "PAY-1")

	accept := func() orchestrator.AcceptResult {
		res, err := h.o.AcceptSuggestions(h.ctx, "PAY-1", []orchestrator.AcceptInput{{ID: ss[0].ID, Target: orchestrator.TargetPlane}}, domain.OriginWeb)
		if err != nil {
			t.Fatal(err)
		}
		return res[0]
	}
	if r := accept(); r.Err == nil || !strings.Contains(r.Err.Error(), "no Plane project") {
		t.Fatalf("accept without a Plane project: %+v", r)
	}
	repo, err := h.store.RepositoryByTrackerProject(h.ctx, domain.SourceJira, "PAY")
	if err != nil {
		t.Fatal(err)
	}
	repo.PlaneProject = "API"
	if _, err := h.store.UpdateRepository(h.ctx, repo); err != nil {
		t.Fatal(err)
	}
	r := accept()
	if r.Err != nil || r.Ticket.Key != "API-100" || r.Ticket.Source != domain.SourcePlane || !r.Ticket.Held {
		t.Fatalf("plane follow-up: %+v", r)
	}
	if want := "create API-100|label API-100 code"; strings.Join(h.plane.calls, "|") != want {
		t.Fatalf("plane calls: %v", h.plane.calls)
	}
	if len(h.tracker.calls) != 0 {
		t.Fatalf("jira calls: %v", h.tracker.calls)
	}
}
