package orchestrator_test

import (
	"errors"
	"strings"
	"testing"

	"agnts/internal/domain"
	"agnts/internal/orchestrator"
)

// A group's branch and commit message formats replace each member's own
// in the group's tickets: every repository gets the same branch and
// commit style, whatever its own settings say.
func TestGroupNameFormats(t *testing.T) {
	h := newHarness(t)
	api, web, group := h.shop()
	repo, _ := h.store.RepositoryByID(h.ctx, api)
	repo.BranchTemplate, repo.CommitTemplate = "feature/{key}", "{key}: {title}"
	if _, err := h.store.SaveRepository(h.ctx, repo); err != nil {
		t.Fatal(err)
	}
	members := []orchestrator.GroupMemberInput{{RepoID: api, Role: "backend"}, {RepoID: web, Role: "web"}}
	for _, bad := range []orchestrator.GroupInput{
		{Name: "Shop", TaskPrefix: "SHOP", BranchTemplate: "no-key", Members: members},
		{Name: "Shop", TaskPrefix: "SHOP", CommitTemplate: "{key} only", Members: members},
	} {
		if _, err := h.o.SaveGroup(h.ctx, group, bad, domain.OriginWeb); !errors.Is(err, orchestrator.ErrInvalid) {
			t.Errorf("%+v: %v", bad, err)
		}
	}
	g, err := h.o.SaveGroup(h.ctx, group, orchestrator.GroupInput{Name: "Shop", TaskPrefix: "SHOP",
		BranchTemplate: " {number} ", CommitTemplate: "[{number}] {type}({scope}): {subject}", Members: members}, domain.OriginWeb)
	if err != nil || g.BranchTemplate != "{number}" || g.CommitTemplate != "[{number}] {type}({scope}): {subject}" {
		t.Fatalf("save: %+v %v", g.RepoGroup, err)
	}

	tk, err := h.o.CreateTask(h.ctx, orchestrator.TaskInput{GroupID: group, Kind: "code", Title: "Show refunds", Priority: "medium",
		AfterApprove: "pr", Start: "code"}, domain.OriginWeb)
	if err != nil {
		t.Fatal(err)
	}
	h.runner.scripts = []script{
		{result: ok("s1"), files: map[string]string{orchestrator.AnalysisPath: analysis(0)}},
		{result: ok("s1"), edit: "api:v1\nweb:v1", files: map[string]string{orchestrator.SummaryPath: `{"summary":"Refunds.","commit":{"type":"feat","scope":"refunds","subject":"show refunds"}}`}},
	}
	for _, f := range []string{"api", "web"} {
		h.runner.execs["cd '"+f+"' && {\ngit status --porcelain --untracked-files=all\n}"] = []orchestrator.ExecResult{
			{Output: " M main.go"}, {Output: " M main.go"}, {Output: " M main.go"}}
	}
	h.step() // analyze
	h.step() // code
	tk = h.expect(tk.Key, domain.StateWaitingForReview)
	for _, id := range []int64{api, web} {
		if r := repoRow(t, tk, id); r.Branch != tk.Key {
			t.Errorf("repository %d branch %q, want %q", id, r.Branch, tk.Key)
		}
	}
	want := "[" + tk.Key + "] feat(refunds): show refunds"
	if len(h.git.messages) != 2 || !strings.HasPrefix(h.git.messages[0], want) || !strings.HasPrefix(h.git.messages[1], want) {
		t.Fatalf("commit messages %q, want %q each", h.git.messages, want)
	}
}
