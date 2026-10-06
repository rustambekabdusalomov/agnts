package orchestrator_test

import (
	"encoding/json"
	"errors"
	"strings"
	"testing"

	"agnts/internal/domain"
	"agnts/internal/orchestrator"
)

func analysisOfKind(kind string) string {
	b, _ := json.Marshal(map[string]any{
		"kind": kind, "kindReason": "the ticket asks for it", "summary": "Auth tokens never expire.",
		"plan": []string{"Read the token code", "Write it up"}, "questions": []any{},
	})
	return string(b)
}

func reportScript(session, report string) script {
	return script{result: ok(session), files: map[string]string{
		orchestrator.ReportPath:  report,
		orchestrator.SummaryPath: `{"summary":"Expire tokens after a day.","notes":[]}`,
	}}
}

func kindEvents(t *testing.T, h *harness, key string) []domain.Event {
	t.Helper()
	evs, err := h.store.Events(h.ctx, orchestrator.EventFilter{TicketKey: key})
	if err != nil {
		t.Fatal(err)
	}
	var out []domain.Event
	for _, e := range evs {
		if e.Type == domain.EventKind {
			out = append(out, e)
		}
	}
	return out
}

func TestReportTaskWithoutRepository(t *testing.T) {
	h := newHarness(t)
	if _, err := h.o.CreateTask(h.ctx, orchestrator.TaskInput{Kind: "code", Title: "x", Priority: "low", AfterApprove: "pr", Start: "code"}, domain.OriginWeb); !errors.Is(err, orchestrator.ErrInvalid) {
		t.Fatalf("code task without a repository: %v", err)
	}
	tk, err := h.o.CreateTask(h.ctx, orchestrator.TaskInput{Kind: "plan", Title: "Plan token expiry", Priority: "medium", AfterApprove: "pr", Start: "code"}, domain.OriginWeb)
	if err != nil {
		t.Fatal(err)
	}
	key := tk.Key
	if !strings.HasPrefix(tk.Key, "TASK-") || tk.RepoID != nil || tk.Kind != domain.KindPlan || tk.KindAuto {
		t.Fatalf("task: %+v", tk)
	}

	var settings []string
	h.runner.onClaude = func(r orchestrator.ClaudeRequest) { settings = append(settings, r.Settings) }
	h.runner.scripts = []script{
		{result: ok("p1"), files: map[string]string{orchestrator.AnalysisPath: analysisOfKind("plan")}},
		reportScript("p1", "# Token expiry plan\n\n1. Add an expiry."),
		reportScript("p2", "# Token expiry plan\n\n1. Add an expiry of one day."),
	}
	h.step() // analyze, on an empty workspace
	h.expect(key, domain.StateCoding)
	if !strings.Contains(h.runner.prompts[0], "It has no repository") {
		t.Fatalf("analyze prompt does not say the workspace is empty:\n%s", h.runner.prompts[0])
	}
	h.step() // write the report
	tk = h.expect(key, domain.StateWaitingForReview)
	if h.git.commits != 0 || tk.Branch != "" {
		t.Fatalf("a report committed: commits=%d branch=%q", h.git.commits, tk.Branch)
	}
	if !strings.Contains(settings[1], "Edit(//workspace/**)") {
		t.Fatalf("report run may edit /workspace: %s", settings[1])
	}
	if h.runner.resumes[1] != "p1" {
		t.Fatalf("report run did not resume the analysis: %q", h.runner.resumes[1])
	}
	v, err := h.o.View(h.ctx, key)
	if err != nil || v.Result == nil || !strings.HasPrefix(v.Result.Report, "# Token expiry plan") || len(v.Result.Files) != 0 {
		t.Fatalf("view: %+v %v", v.Result, err)
	}

	if _, err := h.o.RequestChanges(h.ctx, key, "Say how long a token lives.", domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	h.step()
	h.expect(key, domain.StateWaitingForReview)
	last := h.runner.prompts[len(h.runner.prompts)-1]
	if !strings.Contains(last, "how long a token lives") || !strings.Contains(last, orchestrator.ReportPath) {
		t.Fatalf("feedback prompt: %s", last)
	}
	if v, _ := h.o.View(h.ctx, key); !strings.Contains(v.Result.Report, "one day") {
		t.Fatalf("revised report not stored: %q", v.Result.Report)
	}

	// No tracker issue: asking to post only warns.
	if _, err := h.o.Approve(h.ctx, key, []string{"alice"}, true, domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	h.step()
	tk = h.expect(key, domain.StateDone)
	if len(tk.Assignees) != 0 || h.git.pushed != nil || h.host.opened != 0 || len(h.tracker.comments) != 0 {
		t.Fatalf("report delivery touched git or the tracker: %+v pushed=%v prs=%d comments=%v", tk, h.git.pushed, h.host.opened, h.tracker.comments)
	}
	if tk.LearnState != "" && tk.LearnState != domain.LearnNone {
		t.Fatalf("learn queued for a report: %q", tk.LearnState)
	}
}

func TestReportPostedToJiraOnlyWhenAsked(t *testing.T) {
	h := newHarness(t)
	for i, key := range []string{"PAY-40", "PAY-41"} {
		if _, err := h.o.Ingest(h.ctx, orchestrator.Incoming{Key: key, Project: "PAY", Title: "Why do refunds fail?", Kind: domain.KindBug}, domain.OriginWebhook); err != nil {
			t.Fatal(err)
		}
		h.runner.scripts = []script{
			{result: ok("b"), files: map[string]string{orchestrator.AnalysisPath: analysisOfKind("bug")}},
			reportScript("b", []string{"# Refunds fail\n\nRoot cause: refund.go:42.", "# Refunds fail again"}[i]),
		}
		h.step()
		h.step()
	}
	h.expect("PAY-40", domain.StateWaitingForReview)
	h.expect("PAY-41", domain.StateWaitingForReview)
	if !strings.Contains(h.runner.prompts[1], "root cause of a bug") {
		t.Fatalf("bug report prompt:\n%s", h.runner.prompts[1])
	}
	h.tracker.comments = nil

	if _, err := h.o.Approve(h.ctx, "PAY-40", nil, true, domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	if _, err := h.o.Approve(h.ctx, "PAY-41", nil, false, domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	h.step()
	h.step()
	h.expect("PAY-40", domain.StateDone)
	h.expect("PAY-41", domain.StateDone)
	if len(h.tracker.comments) != 1 || !strings.Contains(h.tracker.comments[0], "refund.go:42") {
		t.Fatalf("comments: %q", h.tracker.comments)
	}
	if h.git.pushed != nil || h.host.opened != 0 {
		t.Fatal("a report was pushed")
	}
}

func TestAnalysisPicksKind(t *testing.T) {
	h := newHarness(t)
	h.ingest("PAY-50") // bare label: agnts picks the kind
	if tk := h.state("PAY-50"); tk.Kind != domain.KindCode || !tk.KindAuto {
		t.Fatalf("new ticket: kind=%s auto=%v", tk.Kind, tk.KindAuto)
	}
	h.runner.scripts = []script{
		{result: ok("a1"), files: map[string]string{orchestrator.AnalysisPath: analysisOfKind("analysis")}},
		reportScript("a1", "# Findings"),
	}
	h.step()
	tk := h.expect("PAY-50", domain.StateCoding)
	if tk.Kind != domain.KindAnalysis || !tk.KindAuto || tk.Branch != "" {
		t.Fatalf("picked: kind=%s auto=%v branch=%q", tk.Kind, tk.KindAuto, tk.Branch)
	}
	if evs := kindEvents(t, h, "PAY-50"); len(evs) != 1 || evs[0].Level != domain.LevelInfo || !strings.Contains(evs[0].Message, "picked analysis") {
		t.Fatalf("kind events: %+v", evs)
	}
	h.step()
	h.expect("PAY-50", domain.StateWaitingForReview)
	if h.git.commits != 0 {
		t.Fatal("an analysis committed")
	}
}

func TestChosenKindIsKept(t *testing.T) {
	h := newHarness(t)
	if _, err := h.o.Ingest(h.ctx, orchestrator.Incoming{Key: "PAY-51", Project: "PAY", Title: "Fix rounding", Kind: domain.KindCode}, domain.OriginWebhook); err != nil {
		t.Fatal(err)
	}
	h.runner.scripts = []script{{result: ok("c1"), files: map[string]string{orchestrator.AnalysisPath: analysisOfKind("plan")}}}
	h.step()
	tk := h.expect("PAY-51", domain.StateCoding)
	if tk.Kind != domain.KindCode || tk.KindAuto || tk.Branch == "" {
		t.Fatalf("chosen kind changed: %+v", tk)
	}
	evs := kindEvents(t, h, "PAY-51")
	if len(evs) != 1 || evs[0].Level != domain.LevelWarn || !strings.Contains(evs[0].Message, "reads like plan work") {
		t.Fatalf("kind events: %+v", evs)
	}
}

func TestNoRepositoryForPickedCode(t *testing.T) {
	h := newHarness(t)
	if _, err := h.o.Ingest(h.ctx, orchestrator.Incoming{Key: "OPS-2", Project: "OPS", Title: "Add a button"}, domain.OriginWebhook); err != nil {
		t.Fatal(err)
	}
	h.runner.scripts = []script{{result: ok("n1"), files: map[string]string{orchestrator.AnalysisPath: analysisOfKind("code")}}}
	h.step()
	tk := h.expect("OPS-2", domain.StateFailed)
	info, err := h.store.StateSince(h.ctx, []string{"OPS-2"})
	if err != nil || !strings.Contains(info["OPS-2"].Reason, "needs a repository") || tk.ResumeState != domain.StateNew {
		t.Fatalf("failure: %+v %v resume=%s", info, err, tk.ResumeState)
	}

	// Choosing a report kind lets it run without one.
	if _, err := h.o.SetKind(h.ctx, "OPS-2", "code", domain.OriginWeb); !errors.Is(err, orchestrator.ErrInvalid) {
		t.Fatalf("code without a repository: %v", err)
	}
	tk, err = h.o.SetKind(h.ctx, "OPS-2", "analysis", domain.OriginWeb)
	if err != nil || tk.Kind != domain.KindAnalysis || tk.KindAuto {
		t.Fatalf("set kind: %+v %v", tk, err)
	}
}

func TestSetKind(t *testing.T) {
	h := newHarness(t)
	h.ingest("PAY-52")
	if _, err := h.o.SetKind(h.ctx, "PAY-52", "deploy", domain.OriginWeb); !errors.Is(err, orchestrator.ErrInvalid) {
		t.Fatalf("unknown kind: %v", err)
	}
	tk, err := h.o.SetKind(h.ctx, "PAY-52", "test", domain.OriginWeb)
	if err != nil || tk.Kind != domain.KindTest || tk.KindAuto {
		t.Fatalf("set test: %+v %v", tk, err)
	}
	h.runner.scripts = []script{
		{result: ok("t1"), files: map[string]string{orchestrator.AnalysisPath: analysisOfKind("test")}},
		{result: ok("t1"), edit: "test"},
	}
	h.step()
	h.step()
	h.expect("PAY-52", domain.StateWaitingForReview)
	if !strings.Contains(h.runner.prompts[1], "This ticket is about tests") {
		t.Fatalf("test prompt:\n%s", h.runner.prompts[1])
	}
	if _, err := h.o.SetKind(h.ctx, "PAY-52", "plan", domain.OriginWeb); !errors.Is(err, domain.ErrConflict) {
		t.Fatalf("kind changed under review: %v", err)
	}
}

func TestImplementPlan(t *testing.T) {
	h := newHarness(t)
	if _, err := h.o.Ingest(h.ctx, orchestrator.Incoming{Key: "PAY-60", Project: "PAY", Title: "Token expiry", Description: "Tokens never expire.", Kind: domain.KindPlan}, domain.OriginWebhook); err != nil {
		t.Fatal(err)
	}
	h.runner.scripts = []script{
		{result: ok("p"), files: map[string]string{orchestrator.AnalysisPath: analysisOfKind("plan")}},
		reportScript("p", "# Token expiry plan\n\n1. Add expires_at to tokens."),
	}
	h.step()
	h.step()
	if _, err := h.o.Implement(h.ctx, "PAY-60", orchestrator.ImplementInput{}, domain.OriginWeb); !errors.Is(err, domain.ErrConflict) {
		t.Fatalf("implemented before approval: %v", err)
	}
	if _, err := h.o.Approve(h.ctx, "PAY-60", nil, false, domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	h.step()
	h.expect("PAY-60", domain.StateDone)

	if _, err := h.o.Implement(h.ctx, "PAY-60", orchestrator.ImplementInput{Start: "ask"}, domain.OriginWeb); !errors.Is(err, orchestrator.ErrInvalid) {
		t.Fatalf("bad start: %v", err)
	}
	c, err := h.o.Implement(h.ctx, "PAY-60", orchestrator.ImplementInput{}, domain.OriginMobile)
	if err != nil {
		t.Fatal(err)
	}
	if c.ParentKey != "PAY-60" || c.Kind != domain.KindCode || c.KindAuto || c.AskFirst || c.Source != domain.SourceLocal ||
		c.RepoID == nil || c.Title != "Implement: Token expiry" || !strings.Contains(c.Description, "Add expires_at") ||
		!strings.Contains(c.Description, "Tokens never expire.") {
		t.Fatalf("child: %+v", c)
	}
	if _, err := h.o.Implement(h.ctx, "PAY-60", orchestrator.ImplementInput{}, domain.OriginWeb); !errors.Is(err, orchestrator.ErrInvalid) {
		t.Fatalf("implemented twice: %v", err)
	}
	v, err := h.o.View(h.ctx, "PAY-60")
	if err != nil || v.ChildKey != c.Key {
		t.Fatalf("parent view: child=%q %v", v.ChildKey, err)
	}

	// The child is an ordinary code ticket: its analysis sees the plan.
	h.runner.scripts = []script{{result: ok("c"), files: map[string]string{orchestrator.AnalysisPath: analysisOfKind("code")}}}
	h.step()
	h.expect(c.Key, domain.StateCoding)
	if last := h.runner.prompts[len(h.runner.prompts)-1]; !strings.Contains(last, "Add expires_at") {
		t.Fatalf("child analysis prompt lacks the plan:\n%s", last)
	}
}

func TestImplementNeedsAPlanWithARepository(t *testing.T) {
	h := newHarness(t)
	tk, err := h.o.CreateTask(h.ctx, orchestrator.TaskInput{Kind: "analysis", Title: "Why slow?", Priority: "low", AfterApprove: "pr", Start: "queue"}, domain.OriginWeb)
	if err != nil {
		t.Fatal(err)
	}
	if _, err := h.o.Implement(h.ctx, tk.Key, orchestrator.ImplementInput{}, domain.OriginWeb); !errors.Is(err, orchestrator.ErrInvalid) {
		t.Fatalf("analysis implemented: %v", err)
	}
	bug, err := h.o.CreateTask(h.ctx, orchestrator.TaskInput{Kind: "bug", Title: "Refunds fail", Priority: "high", AfterApprove: "pr", Start: "code"}, domain.OriginWeb)
	if err != nil {
		t.Fatal(err)
	}
	h.runner.scripts = []script{
		{result: ok("b"), files: map[string]string{orchestrator.AnalysisPath: analysisOfKind("bug")}},
		reportScript("b", "# Refunds fail\n\nRoot cause: rounding."),
	}
	h.step()
	h.step()
	if _, err := h.o.Approve(h.ctx, bug.Key, nil, false, domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	h.step()
	if _, err := h.o.Implement(h.ctx, bug.Key, orchestrator.ImplementInput{}, domain.OriginWeb); err == nil || !strings.Contains(err.Error(), "pick the one") {
		t.Fatalf("no repository: %v", err)
	}
	repo, err := h.store.RepositoryByJiraProject(h.ctx, "PAY")
	if err != nil {
		t.Fatal(err)
	}
	c, err := h.o.Implement(h.ctx, bug.Key, orchestrator.ImplementInput{RepoID: repo.ID, Start: "queue"}, domain.OriginWeb)
	if err != nil || !c.Held || c.Title != "Fix: Refunds fail" || *c.RepoID != repo.ID {
		t.Fatalf("fix task: %+v %v", c, err)
	}
}
