package orchestrator_test

import (
	"context"
	"errors"
	"slices"
	"strings"
	"testing"

	"agnts/internal/domain"
	"agnts/internal/orchestrator"
)

// RestoreBranch makes fakeGit a BranchRestorer.
func (g *fakeGit) RestoreBranch(_ context.Context, _ domain.Repository, branch, sha string) error {
	g.mu.Lock()
	defer g.mu.Unlock()
	if g.branchesGone {
		return domain.ErrNotFound
	}
	g.restored = append(g.restored, branch+"@"+sha)
	return nil
}

// reviewed takes a new ticket to review and returns it there.
func (h *harness) reviewed(key string) domain.Ticket {
	h.t.Helper()
	h.toReview(key, analysis(0))
	return h.state(key)
}

func (h *harness) reject(key string) {
	h.t.Helper()
	if _, err := h.o.Reject(h.ctx, key, "not now", domain.OriginWeb); err != nil {
		h.t.Fatal(err)
	}
	h.expect(key, domain.StateRejected)
}

func TestContinueAtReviewRestoresBranch(t *testing.T) {
	h := newHarness(t)
	before := h.reviewed("PAY-40")
	if _, err := h.o.Continue(h.ctx, "PAY-40", "", nil, domain.OriginWeb); !errors.Is(err, domain.ErrConflict) {
		t.Fatalf("continue an open ticket: %v", err)
	}
	h.reject("PAY-40")
	v, err := h.o.View(h.ctx, "PAY-40")
	if err != nil || v.ContinueTo != domain.StateWaitingForReview || !v.CanStartOver {
		t.Fatalf("view: to=%q startOver=%v %v", v.ContinueTo, v.CanStartOver, err)
	}

	tk, err := h.o.Continue(h.ctx, "PAY-40", "  ", nil, domain.OriginMobile)
	if err != nil || tk.State != domain.StateWaitingForReview || tk.Revision != before.Revision || tk.HeadSHA != before.HeadSHA {
		t.Fatalf("continue: %+v %v", tk, err)
	}
	if want := before.Branch + "@" + before.HeadSHA; !slices.Contains(h.git.restored, want) {
		t.Fatalf("restored %v, want %s", h.git.restored, want)
	}
	if m := h.tracker.moves; len(m) == 0 || m[len(m)-1] != orchestrator.TrackerInReview {
		t.Fatalf("tracker moves %v", m)
	}
	if v, _ := h.o.View(h.ctx, "PAY-40"); v.ContinueTo != "" {
		t.Fatalf("an open ticket offers continue: %q", v.ContinueTo)
	}
	h.idle() // review waits for a person
}

func TestContinueAtReviewWithNoteCodes(t *testing.T) {
	h := newHarness(t)
	before := h.reviewed("PAY-41")
	h.reject("PAY-41")
	tk, err := h.o.Continue(h.ctx, "PAY-41", "Keep the old API too.", nil, domain.OriginWeb)
	if err != nil || tk.State != domain.StateCoding || tk.Revision != before.Revision+1 || tk.Feedback != "Keep the old API too." {
		t.Fatalf("continue: %+v %v", tk, err)
	}
	if m := h.tracker.moves; m[len(m)-1] != orchestrator.TrackerStarted {
		t.Fatalf("tracker moves %v", m)
	}
	h.runner.scripts = []script{{result: ok("s-PAY-41"), edit: "v2"}}
	h.step()
	tk = h.expect("PAY-41", domain.StateWaitingForReview)
	if last := h.runner.prompts[len(h.runner.prompts)-1]; !strings.Contains(last, "Keep the old API too.") {
		t.Fatalf("coding prompt lacks the note:\n%s", last)
	}
	if tk.Feedback != "" {
		t.Fatal("note not cleared after the run")
	}
}

func TestContinueAtAnswersRefusesNote(t *testing.T) {
	h := newHarness(t)
	h.ingest("PAY-42")
	h.runner.scripts = []script{{result: ok("s"), files: map[string]string{orchestrator.AnalysisPath: analysis(1)}}}
	h.step()
	h.expect("PAY-42", domain.StateWaitingForAnswers)
	h.reject("PAY-42")
	if _, err := h.o.Continue(h.ctx, "PAY-42", "hurry", nil, domain.OriginWeb); !errors.Is(err, orchestrator.ErrInvalid) {
		t.Fatalf("note at answers: %v", err)
	}
	if _, err := h.o.Continue(h.ctx, "PAY-42", "", nil, domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	h.expect("PAY-42", domain.StateWaitingForAnswers)
	if qs, _ := h.store.Questions(h.ctx, h.state("PAY-42").ID); len(qs) != 1 {
		t.Fatalf("questions kept: %d", len(qs))
	}
}

func TestContinueFailedShowsTheErrorAgain(t *testing.T) {
	h := newHarness(t)
	h.ingest("PAY-43")
	h.runner.scripts = []script{
		{result: ok("s"), files: map[string]string{orchestrator.AnalysisPath: analysis(0)}},
		{result: ok("s"), edit: "v1"},
	}
	h.runner.execs["go test ./..."] = []orchestrator.ExecResult{{ExitCode: 1, Output: "boom"}, {ExitCode: 1, Output: "boom"}}
	h.step()
	h.step()
	failed := h.expect("PAY-43", domain.StateFailed)
	info, _ := h.store.StateSince(h.ctx, []string{"PAY-43"})
	reason := info["PAY-43"].Reason
	h.reject("PAY-43")
	tk, err := h.o.Continue(h.ctx, "PAY-43", "", nil, domain.OriginWeb)
	if err != nil || tk.State != domain.StateFailed || tk.ResumeState != failed.ResumeState {
		t.Fatalf("continue: %+v %v", tk, err)
	}
	if info, _ = h.store.StateSince(h.ctx, []string{"PAY-43"}); info["PAY-43"].Reason != reason {
		t.Fatalf("reason %q, want %q", info["PAY-43"].Reason, reason)
	}
	if _, err := h.o.Retry(h.ctx, "PAY-43", domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
}

func TestContinueWithLostCommitsStartsOver(t *testing.T) {
	h := newHarness(t)
	h.reviewed("PAY-44")
	h.reject("PAY-44")
	h.git.branchesGone = true
	tk, err := h.o.Continue(h.ctx, "PAY-44", "", nil, domain.OriginWeb)
	if err != nil || tk.State != domain.StateNew || tk.HeadSHA != "" || tk.Branch != "" {
		t.Fatalf("continue: %+v %v", tk, err)
	}
	evs, _ := h.store.Events(h.ctx, orchestrator.EventFilter{TicketKey: "PAY-44"})
	if !slices.ContainsFunc(evs, func(e domain.Event) bool { return strings.Contains(e.Message, "commits are gone") }) {
		t.Fatal("no warning about the lost commits")
	}
}

func TestStartOver(t *testing.T) {
	h := newHarness(t)
	if _, err := h.o.StartOver(h.ctx, "PAY-45", domain.OriginWeb); !errors.Is(err, domain.ErrNotFound) {
		t.Fatalf("unknown ticket: %v", err)
	}
	before := h.reviewed("PAY-45")
	h.reject("PAY-45")
	tk, err := h.o.StartOver(h.ctx, "PAY-45", domain.OriginWeb)
	if err != nil || tk.State != domain.StateNew || tk.HeadSHA != "" || tk.Branch != "" || tk.Revision != before.Revision+1 {
		t.Fatalf("start over: %+v %v", tk, err)
	}
	if m := h.tracker.moves; m[len(m)-1] != orchestrator.TrackerStarted {
		t.Fatalf("tracker moves %v", m)
	}
	h.runner.scripts = []script{{result: ok("s2"), files: map[string]string{orchestrator.AnalysisPath: analysis(0)}}}
	h.step()
	h.expect("PAY-45", domain.StateCoding)
}
