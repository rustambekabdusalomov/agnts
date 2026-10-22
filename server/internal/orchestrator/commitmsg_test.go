package orchestrator_test

import (
	"context"
	"errors"
	"strings"
	"testing"

	"agnts/internal/domain"
	"agnts/internal/orchestrator"
)

// BranchCommits and RewordCommit make fakeGit a CommitRewriter: the
// branch's one commit is the last one made, and a reworded one becomes
// "re-" plus its sha.
func (g *fakeGit) BranchCommits(context.Context, domain.Repository, string) ([]domain.BranchCommit, error) {
	g.mu.Lock()
	defer g.mu.Unlock()
	if g.commits == 0 {
		return nil, nil
	}
	sha, msg := "sha"+string(rune('0'+g.commits)), g.messages[len(g.messages)-1]
	if g.reworded != "" {
		sha, msg = "re-"+sha, g.reworded
	}
	return []domain.BranchCommit{{SHA: sha, Message: msg}}, nil
}

func (g *fakeGit) RewordCommits(_ context.Context, _ domain.Repository, _ string, messages map[string]string) (string, error) {
	g.mu.Lock()
	defer g.mu.Unlock()
	sha := "sha" + string(rune('0'+g.commits))
	message, ok := messages[sha]
	if !ok || len(messages) != 1 {
		return "", domain.ErrNotFound
	}
	g.reworded = message
	return "re-" + sha, nil
}

func TestEditCommitMessageBeforePush(t *testing.T) {
	h := newHarness(t)
	before := h.reviewed("PAY-60")
	v, err := h.o.View(h.ctx, "PAY-60")
	cs := v.Commits[*before.RepoID]
	if err != nil || len(cs) != 1 || cs[0].SHA != before.HeadSHA || !strings.HasPrefix(cs[0].Message, "PAY-60: ") {
		t.Fatalf("view commits %+v: %v", v.Commits, err)
	}
	for _, bad := range []string{"", " \n\n "} {
		if _, err := h.o.EditCommitMessage(h.ctx, "PAY-60", 0, before.HeadSHA, bad, domain.OriginWeb); !errors.Is(err, orchestrator.ErrInvalid) {
			t.Errorf("message %q: %v", bad, err)
		}
	}
	if _, err := h.o.EditCommitMessage(h.ctx, "PAY-60", 0, "nope123", "feat: x", domain.OriginWeb); !errors.Is(err, orchestrator.ErrInvalid) {
		t.Fatalf("unknown commit: %v", err)
	}
	tk, err := h.o.EditCommitMessage(h.ctx, "PAY-60", 0, before.HeadSHA, "feat(auth): add login  \r\n\r\nPAY-60\n\n", domain.OriginWeb)
	if err != nil || tk.HeadSHA != "re-"+before.HeadSHA || tk.State != domain.StateWaitingForReview {
		t.Fatalf("edit: %+v %v", tk, err)
	}
	if h.git.reworded != "feat(auth): add login\n\nPAY-60" {
		t.Fatalf("stored message %q", h.git.reworded)
	}
	evs, _ := h.store.Events(h.ctx, orchestrator.EventFilter{TicketKey: "PAY-60"})
	if !slicesContainsMsg(evs, "commit message changed: feat(auth): add login") {
		t.Fatal("no event for the change")
	}

	if _, err := h.o.Approve(h.ctx, "PAY-60", nil, false, domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	h.step() // push
	h.expect("PAY-60", domain.StateDone)
	if _, err := h.o.EditCommitMessage(h.ctx, "PAY-60", 0, "re-"+before.HeadSHA, "feat: other", domain.OriginWeb); !errors.Is(err, orchestrator.ErrInvalid) {
		t.Fatalf("edit after push: %v", err)
	}
	if v, _ := h.o.View(h.ctx, "PAY-60"); len(v.Commits) != 0 {
		t.Fatalf("pushed ticket offers commits: %v", v.Commits)
	}
}

func slicesContainsMsg(evs []domain.Event, msg string) bool {
	for _, e := range evs {
		if e.Message == msg {
			return true
		}
	}
	return false
}

// Commits made before the repository had a commit format: re-applying it
// shows the new messages first, then writes them, with the ticket number
// given for {number}.
func TestReapplyCommitFormat(t *testing.T) {
	h := newHarness(t)
	before := h.reviewed("PAY-70")
	if _, _, err := h.o.ReapplyCommitFormat(h.ctx, "PAY-70", nil, true, nil, domain.OriginWeb); !errors.Is(err, orchestrator.ErrInvalid) {
		t.Fatalf("no format anywhere: %v", err)
	}
	repo, _ := h.store.RepositoryByID(h.ctx, *before.RepoID)
	repo.CommitTemplate = "[{number}] {type}({scope}): {subject}"
	if _, err := h.store.SaveRepository(h.ctx, repo); err != nil {
		t.Fatal(err)
	}
	if _, _, err := h.o.ReapplyCommitFormat(h.ctx, "PAY-70", ptr("no spaces allowed"), true, nil, domain.OriginWeb); !errors.Is(err, orchestrator.ErrInvalid) {
		t.Fatalf("a bad number: %v", err)
	}

	changes, tk, err := h.o.ReapplyCommitFormat(h.ctx, "PAY-70", ptr("AMANAT-2677"), true, nil, domain.OriginWeb)
	want := "[AMANAT-2677] feat: " + before.Title + "\n\nCo-authored-by: agnts <agnts@users.noreply.github.com>"
	if err != nil || len(changes) != 1 || changes[0].SHA != before.HeadSHA || !strings.HasPrefix(changes[0].From, "PAY-70: ") || changes[0].To != want ||
		!changes[0].Suggested { // agnts's own message: worth changing unasked
		t.Fatalf("preview: %+v %v", changes, err)
	}
	if tk.TicketNumber != "PAY-70" || h.git.reworded != "" { // still its key, the number it was created with
		t.Fatal("the preview changed something")
	}

	changes, tk, err = h.o.ReapplyCommitFormat(h.ctx, "PAY-70", ptr("AMANAT-2677"), false, nil, domain.OriginWeb)
	if err != nil || len(changes) != 1 || h.git.reworded != want || tk.TicketNumber != "AMANAT-2677" || tk.HeadSHA != "re-"+before.HeadSHA {
		t.Fatalf("apply: %+v %+v %v (reworded %q)", changes, tk, err, h.git.reworded)
	}
	// Applied already: nothing more to change.
	if changes, _, err := h.o.ReapplyCommitFormat(h.ctx, "PAY-70", nil, true, nil, domain.OriginWeb); err != nil || len(changes) != 0 {
		t.Fatalf("again: %+v %v", changes, err)
	}
}

// A message a person wrote is not suggested for re-applying, and only the
// commits picked from the preview change.
func TestReapplyCommitFormatPicked(t *testing.T) {
	h := newHarness(t)
	before := h.reviewed("PAY-71")
	repo, _ := h.store.RepositoryByID(h.ctx, *before.RepoID)
	repo.CommitTemplate = "[{number}] {type}({scope}): {subject}"
	if _, err := h.store.SaveRepository(h.ctx, repo); err != nil {
		t.Fatal(err)
	}
	tk, err := h.o.EditCommitMessage(h.ctx, "PAY-71", 0, before.HeadSHA, "feat(refunds): my own words", domain.OriginWeb)
	if err != nil {
		t.Fatal(err)
	}
	changes, _, err := h.o.ReapplyCommitFormat(h.ctx, "PAY-71", nil, true, nil, domain.OriginWeb)
	if err != nil || len(changes) != 1 || changes[0].Suggested {
		t.Fatalf("a hand-written message: %+v %v", changes, err)
	}
	if _, _, err := h.o.ReapplyCommitFormat(h.ctx, "PAY-71", nil, false, []string{"nope"}, domain.OriginWeb); !errors.Is(err, orchestrator.ErrInvalid) {
		t.Fatalf("a commit not in the preview: %v", err)
	}
	if _, after, err := h.o.ReapplyCommitFormat(h.ctx, "PAY-71", nil, false, []string{}, domain.OriginWeb); err != nil || after.HeadSHA != tk.HeadSHA || h.git.reworded != "feat(refunds): my own words" {
		t.Fatalf("none picked changed something: %+v %v %q", after, err, h.git.reworded)
	}
}

func ptr[T any](v T) *T { return &v }
