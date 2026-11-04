package orchestrator_test

import (
	"fmt"
	"testing"

	"agnts/internal/domain"
	"agnts/internal/orchestrator"
)

// LOG, SEC and CI keys are shared by every repository of a workspace. A
// repository's own counter would run into the keys the others took and,
// five behind, give up: "no free task key with prefix SEC".
func TestSharedPrefixNumbersAcrossRepositories(t *testing.T) {
	h := newHarness(t)
	repos, err := h.store.ListRepositories(h.ctx)
	if err != nil || len(repos) == 0 {
		t.Fatalf("repositories: %v", err)
	}
	a := repos[0]
	b := a
	b.ID, b.Name, b.TaskPrefix, b.JiraProject, b.PlaneProject = 0, "second-repo", "SECOND", "", ""
	if b, err = h.store.SaveRepository(h.ctx, b); err != nil {
		t.Fatal(err)
	}
	open := func(repo domain.Repository) string {
		t.Helper()
		tk, err := h.o.CreateLogTicket(h.ctx, orchestrator.LogTicketInput{RepoIDs: []int64{repo.ID}, Title: "panic in " + repo.Name},
			domain.OriginWeb)
		if err != nil {
			t.Fatalf("log ticket on %s: %v", repo.Name, err)
		}
		return tk.Key
	}
	for i := 1; i <= 6; i++ {
		if got, want := open(a), fmt.Sprintf("LOG-%d", i); got != want {
			t.Fatalf("ticket %d on %s: %s, want %s", i, a.Name, got, want)
		}
	}
	if got := open(b); got != "LOG-7" {
		t.Errorf("first ticket on %s: %s, want LOG-7", b.Name, got)
	}
	if got := open(a); got != "LOG-8" {
		t.Errorf("next ticket on %s: %s, want LOG-8", a.Name, got)
	}
	// The repositories' own keys are still numbered per repository.
	tk, err := h.o.CreateTask(h.ctx, orchestrator.TaskInput{RepoID: b.ID, Title: "a task", Priority: "medium", AfterApprove: "pr", Start: "queue"}, domain.OriginWeb)
	if err != nil {
		t.Fatal(err)
	}
	if tk.Key != "SECOND-1" {
		t.Errorf("own task on %s: %s, want SECOND-1", b.Name, tk.Key)
	}
}
