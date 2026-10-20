package mcpserver_test

import (
	"testing"
	"time"

	"agnts/internal/domain"
)

func TestLinkedCommits(t *testing.T) {
	cs, store := setup(t)
	tk, err := store.TicketByKey(testCtx, "PAY-1")
	if err != nil {
		t.Fatal(err)
	}
	// No links: get_ticket leaves them out.
	if out, isErr := call(t, cs, "get_ticket", map[string]any{"key": "PAY-1"}); isErr || out["linked_commits"] != nil {
		t.Fatalf("no links: %v", out)
	}
	var links []domain.CommitLink
	for i, sha := range []string{"a1", "a2", "a3", "a4", "a5", "a6", "a7", "a8", "a9", "b1", "b2", "b3"} {
		links = append(links, domain.CommitLink{TicketID: tk.ID, RepoID: *tk.RepoID, SHA: sha, Branch: "feature/PAY-1", Subject: "PAY-1: step " + sha,
			Author: "Alice", CommittedAt: time.Date(2026, 10, 1, i, 0, 0, 0, time.UTC), MatchedOn: []string{"branch"}, Token: "pay-1"})
	}
	if _, err := store.UpsertCommitLinks(testCtx, links); err != nil {
		t.Fatal(err)
	}

	out, isErr := call(t, cs, "get_ticket", map[string]any{"key": "PAY-1"})
	commits, _ := out["linked_commits"].([]any)
	if isErr || len(commits) != 10 || out["linked_commits_total"] != float64(12) || commits[0].(map[string]any)["sha"] != "b3" {
		t.Fatalf("get_ticket: %v", out)
	}
	out, isErr = call(t, cs, "list_ticket_commits", map[string]any{"key": "PAY-1", "limit": 5, "offset": 10})
	commits, _ = out["commits"].([]any)
	if isErr || len(commits) != 2 || out["total"] != float64(12) {
		t.Fatalf("list: %v", out)
	}
	c := commits[1].(map[string]any)
	if c["sha"] != "a1" || c["repository"] != "api" || c["branch"] != "feature/PAY-1" || c["subject"] != "PAY-1: step a1" {
		t.Fatalf("commit: %v", c)
	}
	if _, isErr := call(t, cs, "list_ticket_commits", map[string]any{"key": "NOPE-1"}); !isErr {
		t.Fatal("an unknown ticket")
	}
}
