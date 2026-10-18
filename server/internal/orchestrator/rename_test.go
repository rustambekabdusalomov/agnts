package orchestrator_test

import (
	"context"
	"errors"
	"fmt"
	"slices"
	"strings"
	"testing"

	"agnts/internal/domain"
	"agnts/internal/orchestrator"
)

// RenameBranch makes fakeGit a BranchRenamer; "taken" is a name the git
// host already has.
func (g *fakeGit) RenameBranch(_ context.Context, _ domain.Repository, from, to string) error {
	g.mu.Lock()
	defer g.mu.Unlock()
	if to == "taken" {
		return domain.ErrConflict
	}
	if to == "slow" {
		return fmt.Errorf("%w: fetch: i/o", context.DeadlineExceeded)
	}
	g.renamed = append(g.renamed, from+"->"+to)
	return nil
}

func TestRenameBranchBeforePush(t *testing.T) {
	h := newHarness(t)
	before := h.reviewed("PAY-50")
	v, err := h.o.View(h.ctx, "PAY-50")
	if err != nil || len(v.RenameBranch) != 1 {
		t.Fatalf("view offers rename for %v: %v", v.RenameBranch, err)
	}
	for _, bad := range []string{"", "has space", "a..b"} {
		if _, err := h.o.RenameBranch(h.ctx, "PAY-50", 0, bad, domain.OriginWeb); !errors.Is(err, orchestrator.ErrInvalid) {
			t.Errorf("rename to %q: %v", bad, err)
		}
	}
	if _, err := h.o.RenameBranch(h.ctx, "PAY-50", 0, "taken", domain.OriginWeb); !errors.Is(err, domain.ErrConflict) {
		t.Fatalf("taken name: %v", err)
	}
	if _, err := h.o.RenameBranch(h.ctx, "PAY-50", 0, "slow", domain.OriginWeb); !errors.Is(err, orchestrator.ErrInvalid) ||
		!strings.Contains(err.Error(), "could not reach") || !strings.Contains(err.Error(), "Private networks") {
		t.Fatalf("a silent git host: %v", err)
	}
	tk, err := h.o.RenameBranch(h.ctx, "PAY-50", 0, " feature/PAY-50-login ", domain.OriginWeb)
	if err != nil || tk.Branch != "feature/PAY-50-login" || tk.HeadSHA != before.HeadSHA || tk.State != domain.StateWaitingForReview {
		t.Fatalf("rename: %+v %v", tk, err)
	}
	if want := before.Branch + "->feature/PAY-50-login"; !slices.Contains(h.git.renamed, want) {
		t.Fatalf("renamed %v, want %s", h.git.renamed, want)
	}
	if r, _ := tk.Primary(); r.Branch != "feature/PAY-50-login" {
		t.Fatalf("repository row keeps %q", r.Branch)
	}

	if _, err := h.o.Approve(h.ctx, "PAY-50", nil, false, domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	h.step() // push
	tk = h.expect("PAY-50", domain.StateDone)
	if !slices.Contains(h.git.pushed, "feature/PAY-50-login") || h.host.last.Branch != "feature/PAY-50-login" {
		t.Fatalf("pushed %v, pull request from %q", h.git.pushed, h.host.last.Branch)
	}
	if _, err := h.o.RenameBranch(h.ctx, "PAY-50", 0, "feature/other", domain.OriginWeb); !errors.Is(err, orchestrator.ErrInvalid) {
		t.Fatalf("rename after push: %v", err)
	}
	if v, _ := h.o.View(h.ctx, "PAY-50"); len(v.RenameBranch) != 0 {
		t.Fatalf("pushed ticket offers rename: %v", v.RenameBranch)
	}
}
