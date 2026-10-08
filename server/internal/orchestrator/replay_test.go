package orchestrator_test

import (
	"errors"
	"strings"
	"testing"

	"agnts/internal/domain"
	"agnts/internal/orchestrator"
)

func TestReplayAndReport(t *testing.T) {
	h := newHarness(t)
	h.ingest("PAY-1")
	h.runner.scripts = []script{
		{result: ok("s1"), files: map[string]string{orchestrator.AnalysisPath: analysis(1)}},
		{result: ok("s1"), edit: "fix"},
	}
	h.step()
	if _, err := h.o.Answer(h.ctx, "PAY-1", h.answers("PAY-1"), domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	if _, err := h.o.Replay(h.ctx, "PAY-1", domain.OriginWeb); !errors.Is(err, orchestrator.ErrInvalid) {
		t.Fatalf("replaying an unfinished ticket: %v", err)
	}
	h.step()
	if _, err := h.o.Approve(h.ctx, "PAY-1", nil, false, domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	h.step()
	orig := h.expect("PAY-1", domain.StateDone)

	r, err := h.o.Replay(h.ctx, "PAY-1", domain.OriginWeb)
	if err != nil {
		t.Fatal(err)
	}
	if r.ReplayOf != "PAY-1" || r.BaseSHA != "base-of-"+orig.HeadSHA || r.AskFirst || r.Source != domain.SourceLocal ||
		!strings.HasPrefix(r.Title, "Replay of PAY-1: ") || !strings.Contains(r.Description, "Which rounding mode?\n  half up") {
		t.Fatalf("replay ticket: %+v", r)
	}
	if _, err := h.o.Replay(h.ctx, r.Key, domain.OriginWeb); !errors.Is(err, orchestrator.ErrInvalid) {
		t.Fatalf("replaying a replay: %v", err)
	}

	h.runner.scripts = []script{
		{result: ok("s2"), files: map[string]string{orchestrator.AnalysisPath: analysis(0)}},
		{result: ok("s2"), edit: "fix again"},
	}
	h.step() // analyze the replay
	if strings.Contains(h.runner.prompts[len(h.runner.prompts)-1], orchestrator.PrecedentsPath) {
		t.Fatal("the replay was shown the ticket it re-runs as a precedent")
	}
	h.step() // code the replay
	h.expect(r.Key, domain.StateWaitingForReview)
	if len(h.git.preparedAt) == 0 || h.git.preparedAt[0] != "agnts/"+r.Key+"@base-of-"+orig.HeadSHA {
		t.Fatalf("replay branch: %q", h.git.preparedAt)
	}
	if _, err := h.o.Approve(h.ctx, r.Key, nil, false, domain.OriginWeb); !errors.Is(err, orchestrator.ErrInvalid) {
		t.Fatalf("approving a replay: %v", err)
	}

	rep, err := h.o.ReplayReport(h.ctx)
	if err != nil {
		t.Fatal(err)
	}
	if len(rep.Replays) != 1 || len(rep.Versions) != 1 {
		t.Fatalf("report: %+v", rep)
	}
	x, v := rep.Replays[0], rep.Versions[0]
	if x.Original != "PAY-1" || !x.ChecksPassed || x.Overlap != 1 || x.Recall != 1 || x.PromptVersion != orchestrator.PromptVersion || x.OriginalTurns == 0 {
		t.Fatalf("replay result: %+v", x)
	}
	if v.Replays != 1 || v.ChecksPassed != 1 || v.AvgOverlap != 1 {
		t.Fatalf("version: %+v", v)
	}
}
