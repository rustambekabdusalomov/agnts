package mcpserver_test

import (
	"context"
	"encoding/json"
	"strings"
	"testing"

	"agnts/internal/domain"
	"agnts/internal/mcpserver"
	"agnts/internal/orchestrator"
)

func names(files []orchestrator.AssistantFile) string {
	var n []string
	for _, f := range files {
		n = append(n, f.Name)
	}
	return strings.Join(n, ",")
}

func TestSnapshotHasTheReadToolsData(t *testing.T) {
	d := testDeps(t)
	s := mcpserver.NewSnapshotter(d)

	// A question about nothing in particular gets everything this
	// workspace has (no CI watching or lessons here), and the named ticket.
	files, err := s.Snapshot(testCtx, orchestrator.AssistantQuestion{Question: "What changed in PAY-1?", Keys: []string{"PAY-1", "NOPE-9"}})
	if err != nil {
		t.Fatal(err)
	}
	if got := names(files); got != "me.json,inbox.json,tickets.json,ticket-PAY-1.json,usage.json,analytics.json,repositories.json,groups.json,missing.json" {
		t.Fatalf("files = %s", got)
	}
	byName := map[string]string{}
	for _, f := range files {
		byName[f.Name] = f.Content
	}
	var inbox struct {
		NeedsYou []struct{ Key, State string } `json:"needs_you"`
	}
	if err := json.Unmarshal([]byte(byName["inbox.json"]), &inbox); err != nil || len(inbox.NeedsYou) != 1 || inbox.NeedsYou[0].Key != "PAY-1" {
		t.Fatalf("inbox = %s %v", byName["inbox.json"], err)
	}
	if !strings.Contains(byName["tickets.json"], `"needs_you": [`) || !strings.Contains(byName["ticket-PAY-1.json"], `"branch": "agnts/PAY-1"`) {
		t.Fatalf("tickets = %s\nticket = %s", byName["tickets.json"], byName["ticket-PAY-1.json"])
	}
	if !strings.Contains(byName["missing.json"], "no ticket NOPE-9") {
		t.Fatalf("missing = %s", byName["missing.json"])
	}
	if !strings.Contains(byName["me.json"], `"can_act": true`) || !strings.Contains(byName["groups.json"], `"groups": []`) {
		t.Fatalf("me = %s\ngroups = %s", byName["me.json"], byName["groups.json"])
	}
	if strings.Contains(byName["repositories.json"], "github.com/acme") {
		t.Fatalf("clone URLs left in: %s", byName["repositories.json"])
	}

	// A question about spend leaves the rest out.
	files, err = s.Snapshot(testCtx, orchestrator.AssistantQuestion{Question: "spend?", Topics: map[orchestrator.AssistantTopic]bool{orchestrator.TopicSpend: true}})
	if err != nil {
		t.Fatal(err)
	}
	if got := names(files); got != "me.json,inbox.json,tickets.json,usage.json,analytics.json" {
		t.Fatalf("spend files = %s", got)
	}
}

func TestSnapshotSaysWhoAsks(t *testing.T) {
	d := testDeps(t)
	d.Role = func(context.Context, int64, int64) (domain.WorkspaceRole, error) { return domain.RoleViewer, nil }
	ctx := domain.WithActor(testCtx, domain.Actor{UserID: 1, Username: "viewer"})
	// A question that creates work gets the repositories and groups.
	files, err := mcpserver.NewSnapshotter(d).Snapshot(ctx, orchestrator.AssistantQuestion{Question: "create a task",
		Topics: map[orchestrator.AssistantTopic]bool{orchestrator.TopicAct: true}})
	if err != nil {
		t.Fatal(err)
	}
	if got := names(files); got != "me.json,inbox.json,tickets.json,repositories.json,groups.json" {
		t.Fatalf("files = %s", got)
	}
	if files[0].Content != "{\n \"role\": \"viewer\",\n \"can_act\": false\n}" {
		t.Fatalf("me.json = %s", files[0].Content)
	}
}
