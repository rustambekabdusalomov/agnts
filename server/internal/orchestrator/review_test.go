package orchestrator_test

import (
	"encoding/json"
	"errors"
	"fmt"
	"strings"
	"testing"

	"agnts/internal/domain"
	"agnts/internal/orchestrator"
)

func codeReviewJSON(verdict string, findings ...map[string]any) string {
	if findings == nil {
		findings = []map[string]any{}
	}
	b, _ := json.Marshal(map[string]any{"verdict": verdict, "summary": "Rounding is fixed; one caller is missed.", "findings": findings})
	return string(b)
}

func reviewScript(session, review string) script {
	return script{result: ok(session), files: map[string]string{orchestrator.ReviewPath: review}}
}

// newReviewHarness has auto review on and records each run's model.
func newReviewHarness(t *testing.T) (*harness, *[]string) {
	t.Helper()
	h := newHarness(t)
	h.settings.s.AutoReview = true
	var models []string
	h.runner.onClaude = func(r orchestrator.ClaudeRequest) { models = append(models, r.Model) }
	return h, &models
}

// toReview runs a ticket to waiting_for_review with one coding script.
func (h *harness) toReview(key, analysisJSON string) {
	h.t.Helper()
	h.ingest(key)
	h.runner.scripts = append(h.runner.scripts,
		script{result: ok("s-" + key), files: map[string]string{orchestrator.AnalysisPath: analysisJSON}},
		script{result: ok("s-" + key), edit: "fix " + key},
	)
	h.step() // analyze
	h.step() // code
	h.expect(key, domain.StateWaitingForReview)
}

func withComplexity(c string) string {
	var a map[string]any
	_ = json.Unmarshal([]byte(analysis(0)), &a)
	a["complexity"] = c
	b, _ := json.Marshal(a)
	return string(b)
}

func TestReviewBesideHumanReview(t *testing.T) {
	h, models := newReviewHarness(t)
	h.toReview("PAY-1", withComplexity("simple"))
	if tk := h.state("PAY-1"); tk.ReviewState != domain.ReviewPending {
		t.Fatalf("review state after coding: %q", tk.ReviewState)
	}

	h.runner.scripts = []script{reviewScript("r1", codeReviewJSON("looks_good",
		map[string]any{"severity": "minor", "category": "tests", "file": "/workspace/refund.go", "line": 12, "title": "No test for negatives"},
		map[string]any{"severity": "BLOCKER", "category": "weird", "file": "../etc/passwd", "line": 3, "title": "Caller still truncates", "suggestion": "Round in caller.go too."},
		map[string]any{"severity": "major", "title": "  "},
	))}
	h.step() // review
	tk := h.expect("PAY-1", domain.StateWaitingForReview)
	if tk.ReviewState != domain.ReviewDone {
		t.Fatalf("review state: %q", tk.ReviewState)
	}
	h.idle()

	prompt := h.runner.prompts[len(h.runner.prompts)-1]
	if !strings.Contains(prompt, orchestrator.ChangePath) || !strings.Contains(prompt, "main.go (+3 −1)") ||
		!strings.Contains(prompt, orchestrator.ReviewPath) || !strings.Contains(prompt, "test: `go test ./...` passed") {
		t.Fatalf("review prompt:\n%s", prompt)
	}
	if m := (*models)[len(*models)-1]; m != "sonnet" {
		t.Fatalf("simple ticket reviewed with %s", m)
	}

	v, err := h.o.View(h.ctx, "PAY-1")
	if err != nil || v.Review == nil {
		t.Fatalf("view: %+v %v", v.Review, err)
	}
	rv := v.Review
	if rv.Verdict != domain.VerdictNeedsChanges || len(rv.Findings) != 2 || rv.Revision != 0 || rv.Model != "sonnet" {
		t.Fatalf("review not normalised: %+v", rv)
	}
	if f := rv.Findings[0]; f.Severity != "blocker" || f.Category != "other" || f.File != "" || f.Line != 0 {
		t.Fatalf("first finding: %+v", f)
	}
	if f := rv.Findings[1]; f.File != "refund.go" || f.Line != 12 {
		t.Fatalf("second finding: %+v", f)
	}
	evs, _ := h.store.Events(h.ctx, orchestrator.EventFilter{TicketKey: "PAY-1"})
	found := false
	for _, e := range evs {
		if e.Type == domain.EventReview && e.Message == "code review: needs changes (1 blocker, 1 minor)" {
			found = true
		}
	}
	if !found {
		t.Fatal("no review_done event")
	}

	// Changes requested from the review: coding resumes the coding
	// session, not the review's, and the next revision is reviewed again.
	if _, err := h.o.RequestChanges(h.ctx, "PAY-1", rv.Findings[0].Suggestion, nil, nil, domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	h.runner.scripts = []script{{result: ok("s2"), edit: "v2"}}
	h.step()
	tk = h.expect("PAY-1", domain.StateWaitingForReview)
	if r := h.runner.resumes[len(h.runner.resumes)-1]; r != "s-PAY-1" {
		t.Fatalf("feedback run resumed %q", r)
	}
	if tk.ReviewState != domain.ReviewPending {
		t.Fatalf("revision 1 not queued for review: %q", tk.ReviewState)
	}
	if v, _ := h.o.View(h.ctx, "PAY-1"); v.Review == nil || v.Review.Revision == tk.Revision {
		t.Fatal("old review should be kept and marked by its revision")
	}
}

func TestApproveDropsQueuedReview(t *testing.T) {
	h, _ := newReviewHarness(t)
	h.toReview("PAY-2", analysis(0))
	tk, err := h.o.Approve(h.ctx, "PAY-2", nil, false, domain.OriginWeb)
	if err != nil || tk.ReviewState != domain.ReviewNone {
		t.Fatalf("approve: %q %v", tk.ReviewState, err)
	}
	h.step() // push, not review
	h.expect("PAY-2", domain.StateDone)
	h.idle()
	if _, err := h.o.Review(h.ctx, "PAY-2", domain.OriginWeb); !errors.Is(err, orchestrator.ErrInvalid) {
		t.Fatalf("review of a done ticket: %v", err)
	}
}

func TestReviewModelFollowsComplexity(t *testing.T) {
	h, models := newReviewHarness(t)
	h.toReview("PAY-3", withComplexity("complex"))
	h.runner.scripts = []script{reviewScript("r3", codeReviewJSON("looks_good"))}
	h.step()
	if m := (*models)[len(*models)-1]; m != "opus" {
		t.Fatalf("complex ticket reviewed with %s", m)
	}
	if v, _ := h.o.View(h.ctx, "PAY-3"); v.Review == nil || v.Review.ModelReason != "the analysis rated this ticket complex" || v.Review.Verdict != domain.VerdictLooksGood {
		t.Fatalf("review: %+v", v.Review)
	}

	// A large change is complex too.
	h.git.files = make([]domain.FileChange, 12)
	for i := range h.git.files {
		h.git.files[i] = domain.FileChange{Path: fmt.Sprintf("f%d.go", i), Add: 10, Diff: "+x\n"}
	}
	h.toReview("PAY-4", withComplexity("simple"))
	h.runner.scripts = []script{reviewScript("r4", codeReviewJSON("looks_good"))}
	h.step()
	if m := (*models)[len(*models)-1]; m != "opus" {
		t.Fatalf("large change reviewed with %s", m)
	}

	// A model set in Settings or for the ticket wins over auto.
	h.git.files = nil
	h.settings.s.Models.Review = "haiku"
	h.toReview("PAY-5", withComplexity("complex"))
	h.runner.scripts = []script{reviewScript("r5", codeReviewJSON("looks_good"))}
	h.step()
	if m := (*models)[len(*models)-1]; m != "haiku" {
		t.Fatalf("settings model ignored: %s", m)
	}
	if _, err := h.o.SetModels(h.ctx, "PAY-5", map[string]string{"review": "opus"}, domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	if _, err := h.o.Review(h.ctx, "PAY-5", domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	h.runner.scripts = []script{reviewScript("r6", codeReviewJSON("looks_good"))}
	h.step()
	if m := (*models)[len(*models)-1]; m != "opus" {
		t.Fatalf("ticket model ignored: %s", m)
	}
}

func TestReviewFailureAndRateLimit(t *testing.T) {
	h, _ := newReviewHarness(t)
	h.toReview("PAY-6", analysis(0))

	h.runner.scripts = []script{{result: orchestrator.ClaudeResult{RateLimited: true}}}
	h.step()
	if tk := h.expect("PAY-6", domain.StateWaitingForReview); tk.ReviewState != domain.ReviewPending {
		t.Fatalf("rate-limited review state: %q", tk.ReviewState)
	}

	h.runner.scripts = []script{{result: ok("r7")}} // writes no review.json
	h.step()
	if tk := h.expect("PAY-6", domain.StateWaitingForReview); tk.ReviewState != domain.ReviewFailed {
		t.Fatalf("failed review state: %q", tk.ReviewState)
	}
	h.idle()

	if _, err := h.o.Review(h.ctx, "PAY-6", domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	h.runner.scripts = []script{reviewScript("r8", codeReviewJSON("has_concerns"))}
	h.step()
	if tk := h.expect("PAY-6", domain.StateWaitingForReview); tk.ReviewState != domain.ReviewDone {
		t.Fatalf("review state after retry: %q", tk.ReviewState)
	}
}

func TestReportIsReviewed(t *testing.T) {
	h, _ := newReviewHarness(t)
	tk, err := h.o.CreateTask(h.ctx, orchestrator.TaskInput{Kind: "plan", Title: "Plan token expiry", Priority: "medium", AfterApprove: "pr", Start: "code"}, domain.OriginWeb)
	if err != nil {
		t.Fatal(err)
	}
	var settings []string
	h.runner.onClaude = func(r orchestrator.ClaudeRequest) { settings = append(settings, r.Settings) }
	h.runner.scripts = []script{
		{result: ok("p1"), files: map[string]string{orchestrator.AnalysisPath: analysisOfKind("plan")}},
		reportScript("p1", "# Token expiry plan\n\n1. Add an expiry."),
		reviewScript("r1", codeReviewJSON("has_concerns", map[string]any{"severity": "major", "category": "completeness", "title": "No rollout plan"})),
	}
	h.step()
	h.step()
	if got := h.expect(tk.Key, domain.StateWaitingForReview); got.ReviewState != domain.ReviewPending {
		t.Fatalf("report review state: %q", got.ReviewState)
	}
	h.step()
	prompt := h.runner.prompts[len(h.runner.prompts)-1]
	if !strings.Contains(prompt, "wrote a report") || !strings.Contains(prompt, orchestrator.ReportPath) || !strings.Contains(prompt, "/workspace is empty") {
		t.Fatalf("report review prompt:\n%s", prompt)
	}
	if !strings.Contains(settings[len(settings)-1], "Edit(//workspace/**)") {
		t.Fatalf("review run may edit /workspace: %s", settings[len(settings)-1])
	}
	if v, _ := h.o.View(h.ctx, tk.Key); v.Review == nil || v.Review.Findings[0].Category != "completeness" {
		t.Fatalf("report review: %+v", v.Review)
	}
}
