package orchestrator_test

import (
	"errors"
	"strings"
	"testing"

	"agnts/internal/domain"
	"agnts/internal/orchestrator"
)

// A red check on agnts's pull request sends the ticket back to coding with
// the failure; the fix is reviewed, approved and pushed to the same pull
// request; the rounds are capped.
func TestCIFeedbackRound(t *testing.T) {
	h := newHarness(t)
	h.ingest("PAY-30")
	h.runner.scripts = []script{
		{result: ok("s30"), files: map[string]string{orchestrator.AnalysisPath: analysis(0)}},
		{result: ok("s30"), edit: "v1"},
		{result: ok("s30"), edit: "v2"},
	}
	h.step() // analyze
	h.step() // code
	h.expect("PAY-30", domain.StateWaitingForReview)

	// Not pushed yet: CI cannot be about it.
	if _, res, err := h.o.CIFeedback(h.ctx, "PAY-30", "CI failed", "https://ci/1", 2); err != nil || res != orchestrator.CIFeedbackSkipped {
		t.Fatalf("before push: %v %v", res, err)
	}
	if _, err := h.o.Approve(h.ctx, "PAY-30", nil, false, domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	h.step() // push
	before := h.expect("PAY-30", domain.StateDone)
	opened := h.host.opened

	tk, res, err := h.o.CIFeedback(h.ctx, "PAY-30", "CI failed on the pull request (CI, commit abc): https://ci/1\n\n--- FAIL: TestRefund", "https://ci/1", 1)
	if err != nil || res != orchestrator.CIFeedbackSent || tk.State != domain.StateCoding || tk.CIFixes != 1 || tk.Revision != before.Revision+1 {
		t.Fatalf("feedback: %+v %v %v", tk, res, err)
	}
	h.step() // code the fix
	h.expect("PAY-30", domain.StateWaitingForReview)
	if p := h.runner.prompts[len(h.runner.prompts)-1]; !strings.Contains(p, "--- FAIL: TestRefund") {
		t.Fatalf("coding prompt lacks the CI failure:\n%s", p)
	}
	if _, err := h.o.Approve(h.ctx, "PAY-30", nil, false, domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	h.step() // push again
	tk = h.expect("PAY-30", domain.StateDone)
	if h.host.opened != opened || tk.PRNumber == nil || *tk.PRNumber != 7 || len(h.git.pushed) != 2 {
		t.Fatalf("second push opened a new PR or did not push: opened %d→%d, %+v, pushed %v", opened, h.host.opened, tk, h.git.pushed)
	}

	// The cap: one round was allowed.
	if _, res, err := h.o.CIFeedback(h.ctx, "PAY-30", "CI failed again", "https://ci/2", 1); err != nil || res != orchestrator.CIFeedbackCapped {
		t.Fatalf("capped: %v %v", res, err)
	}
	h.expect("PAY-30", domain.StateDone)
}

func TestCreateCITicket(t *testing.T) {
	h := newHarness(t)
	repos, err := h.store.ListRepositories(h.ctx)
	if err != nil || len(repos) == 0 {
		t.Fatal(err)
	}
	tk, err := h.o.CreateCITicket(h.ctx, orchestrator.CITicketInput{RepoID: repos[0].ID, Title: "Fix CI on main: TestRefund",
		Description: "CI fails on main.", Priority: "highest", Log: "=== first error ===\n--- FAIL: TestRefund"}, domain.OriginWebhook)
	if err != nil {
		t.Fatal(err)
	}
	if !strings.HasPrefix(tk.Key, "CI-") || tk.Source != domain.SourceCI || tk.Kind != domain.KindCode || !tk.KindAuto || tk.AskFirst || tk.AfterApprove != "pr" {
		t.Fatalf("ticket %+v", tk)
	}
	v, err := h.o.View(h.ctx, tk.Key)
	if err != nil || len(v.Attachments) != 1 || v.Attachments[0].Name != "ci-log.txt" {
		t.Fatalf("attachments: %+v %v", v.Attachments, err)
	}
	if _, err := h.o.CreateCITicket(h.ctx, orchestrator.CITicketInput{RepoID: 999999, Title: "x"}, domain.OriginWebhook); !errors.Is(err, domain.ErrNotFound) {
		t.Fatalf("missing repository: %v", err)
	}
}
