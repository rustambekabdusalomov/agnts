package mcpserver_test

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"log/slog"
	"strings"
	"testing"
	"time"

	"github.com/modelcontextprotocol/go-sdk/mcp"

	"agnts/internal/admin"
	"agnts/internal/domain"
	"agnts/internal/mcpserver"
	"agnts/internal/orchestrator"
	"agnts/internal/secret"
	"agnts/internal/store/postgres"
	"agnts/internal/store/postgres/pgtest"
	"agnts/internal/usage"
	"agnts/internal/vcs/github"
)

// testCtx acts in the workspace the test's MCP session acts in.
var testCtx context.Context

func setup(t *testing.T) (*mcp.ClientSession, *postgres.Agent) {
	t.Helper()
	d := testDeps(t)
	srv := mcpserver.NewServer(d, "test")
	st, ct := mcp.NewInMemoryTransports()
	if _, err := srv.Connect(testCtx, st, nil); err != nil {
		t.Fatal(err)
	}
	cs, err := mcp.NewClient(&mcp.Implementation{Name: "test"}, nil).Connect(testCtx, ct, nil)
	if err != nil {
		t.Fatal(err)
	}
	t.Cleanup(func() { _ = cs.Close() })
	return cs, d.Store
}

// testDeps sets up a workspace with repository api and ticket PAY-1
// waiting for review, and the use cases over it.
func testDeps(t *testing.T) mcpserver.Deps {
	t.Helper()
	pool := pgtest.Open(t)
	pgtest.Reset(t, pool)
	ctx, _ := pgtest.Workspace(t, pool, "mcp")
	testCtx = ctx
	log := slog.New(slog.NewTextHandler(io.Discard, nil))
	store := postgres.NewAgent(pool)
	settings := postgres.NewSettings(pool, domain.DefaultSettings())
	ut := usage.New(postgres.NewUsage(pool), store, log)
	box, err := secret.NewBox(bytes.Repeat([]byte{5}, 32))
	if err != nil {
		t.Fatal(err)
	}
	testSwagger, testPool = postgres.NewSwaggerTests(pool, box), pool
	orch := orchestrator.New(orchestrator.DefaultConfig(), orchestrator.Deps{Store: store, Settings: settings, Usage: ut, SwaggerTests: testSwagger}, log)
	gh := github.New("http://127.0.0.1:1", func(context.Context) (string, error) { return "", nil })
	repos := admin.NewRepos(store, gh, gh, nil, log)
	dash := admin.NewDashboard(store, orch, repos, ut, settings, time.UTC)

	repo, err := store.SaveRepository(ctx, domain.Repository{Name: "api", Kind: "jira", Provider: "github",
		CloneURL: "https://github.com/acme/api.git", DefaultBranch: "main", JiraProject: "PAY"})
	if err != nil {
		t.Fatal(err)
	}
	if _, err := store.CreateTicket(ctx, domain.Ticket{Key: "PAY-1", Source: domain.SourceJira, RepoID: &repo.ID, Title: "Fix rounding",
		State: domain.StateNew, ResumeState: domain.StateNew, AfterApprove: "pr"}, domain.Event{Type: domain.EventTicketCreated}); err != nil {
		t.Fatal(err)
	}
	for _, st := range []domain.TicketState{domain.StateAnalyzing, domain.StateCoding, domain.StateTesting, domain.StateWaitingForReview} {
		if _, err := store.Transition(ctx, "PAY-1", st, domain.Event{TicketKey: "PAY-1", Type: domain.EventStateChanged}, func(x *domain.Ticket) {
			x.Branch = "agnts/PAY-1"
		}); err != nil {
			t.Fatal(err)
		}
	}

	return mcpserver.Deps{Orch: orch, Store: store, Usage: ut, Settings: settings, Dashboard: dash, Repos: repos}
}

func call(t *testing.T, cs *mcp.ClientSession, name string, args map[string]any) (map[string]any, bool) {
	t.Helper()
	res, err := cs.CallTool(context.Background(), &mcp.CallToolParams{Name: name, Arguments: args})
	if err != nil {
		t.Fatalf("%s: %v", name, err)
	}
	var out map[string]any
	if b, err := json.Marshal(res.StructuredContent); err == nil {
		_ = json.Unmarshal(b, &out)
	}
	if res.IsError {
		var msg strings.Builder
		for _, c := range res.Content {
			if tc, ok := c.(*mcp.TextContent); ok {
				msg.WriteString(tc.Text)
			}
		}
		return map[string]any{"error": msg.String()}, true
	}
	return out, false
}

func TestToolsAndAnnotations(t *testing.T) {
	cs, _ := setup(t)
	list, err := cs.ListTools(context.Background(), nil)
	if err != nil {
		t.Fatal(err)
	}
	byName := map[string]*mcp.Tool{}
	for _, tl := range list.Tools {
		byName[tl.Name] = tl
	}
	for _, n := range []string{"get_inbox", "list_tickets", "get_ticket", "get_run_log", "get_usage", "get_analytics", "list_repositories", "get_repository", "list_ticket_commits"} {
		if tl := byName[n]; tl == nil || tl.Annotations == nil || !tl.Annotations.ReadOnlyHint {
			t.Errorf("%s should exist and be read-only", n)
		}
	}
	for _, n := range []string{"approve_ticket", "reject_ticket"} {
		if tl := byName[n]; tl == nil || tl.Annotations == nil || tl.Annotations.DestructiveHint == nil || !*tl.Annotations.DestructiveHint {
			t.Errorf("%s should be marked destructive", n)
		}
	}
	for _, n := range []string{"answer_questions", "start_run", "request_changes", "retry_run", "create_task", "set_ticket_kind", "implement_ticket", "accept_follow_ups", "dismiss_follow_up", "confirm_action"} {
		if byName[n] == nil {
			t.Errorf("missing tool %s", n)
		}
	}
	for n := range byName {
		if strings.Contains(n, "deploy") || strings.Contains(n, "disconnect") || strings.Contains(n, "setting") {
			t.Errorf("tool %s must not be exposed", n)
		}
	}
}

func TestTwoStepApprove(t *testing.T) {
	cs, store := setup(t)
	ctx := testCtx

	inbox, _ := call(t, cs, "get_inbox", nil)
	if needs, _ := inbox["needs_you"].([]any); len(needs) != 1 {
		t.Fatalf("inbox: %v", inbox)
	}

	out, isErr := call(t, cs, "approve_ticket", map[string]any{"key": "PAY-1"})
	if isErr {
		t.Fatalf("approve_ticket: %v", out)
	}
	id, _ := out["action_id"].(string)
	if id == "" || !strings.Contains(out["summary"].(string), "agnts/PAY-1") {
		t.Fatalf("pending: %v", out)
	}
	if tk, _ := store.TicketByKey(ctx, "PAY-1"); tk.State != domain.StateWaitingForReview {
		t.Fatalf("approve_ticket acted before confirmation: %s", tk.State)
	}

	if out, isErr = call(t, cs, "confirm_action", map[string]any{"action_id": id}); isErr {
		t.Fatalf("confirm: %v", out)
	}
	if tk, _ := store.TicketByKey(ctx, "PAY-1"); tk.State != domain.StatePushing {
		t.Fatalf("not approved after confirm: %s", tk.State)
	}
	if _, isErr = call(t, cs, "confirm_action", map[string]any{"action_id": id}); !isErr {
		t.Fatal("confirmed twice")
	}

	evs, _ := store.ListEvents(ctx, postgres.LogFilter{Type: "user"})
	found := false
	for _, e := range evs {
		if e.Origin == domain.OriginMCP {
			found = true
		}
	}
	if !found {
		t.Fatal("approval not audited with origin mcp")
	}

	if out, isErr = call(t, cs, "approve_ticket", map[string]any{"key": "NOPE-9"}); !isErr {
		t.Fatalf("unknown ticket accepted: %v", out)
	}
	if out, isErr = call(t, cs, "request_changes", map[string]any{"key": "PAY-1", "feedback": "  "}); !isErr {
		t.Fatalf("empty feedback accepted: %v", out)
	}
}

func TestReportKinds(t *testing.T) {
	cs, store := setup(t)
	ctx := testCtx

	// A plan ticket under review.
	if _, err := store.CreateTicket(ctx, domain.Ticket{Key: "PAY-2", Source: domain.SourceJira, Title: "Plan expiry", Kind: domain.KindPlan,
		State: domain.StateNew, ResumeState: domain.StateNew, AfterApprove: "pr"}, domain.Event{Type: domain.EventTicketCreated}); err != nil {
		t.Fatal(err)
	}
	for _, st := range []domain.TicketState{domain.StateAnalyzing, domain.StateCoding, domain.StateWaitingForReview} {
		if _, err := store.Transition(ctx, "PAY-2", st, domain.Event{TicketKey: "PAY-2", Type: domain.EventStateChanged}, nil); err != nil {
			t.Fatal(err)
		}
	}
	got, _ := call(t, cs, "get_ticket", map[string]any{"key": "PAY-2"})
	if got["kind"] != "plan" {
		t.Fatalf("get_ticket kind: %v", got)
	}

	if out, isErr := call(t, cs, "approve_ticket", map[string]any{"key": "PAY-1", "post_report": true}); !isErr {
		t.Fatalf("post_report accepted for a change: %v", out)
	}
	out, isErr := call(t, cs, "approve_ticket", map[string]any{"key": "PAY-2", "post_report": true})
	if isErr || !strings.Contains(out["summary"].(string), "Jira issue") {
		t.Fatalf("approve report: %v", out)
	}
	if out, isErr = call(t, cs, "confirm_action", map[string]any{"action_id": out["action_id"]}); isErr {
		t.Fatalf("confirm: %v", out)
	}
	if tk, _ := store.TicketByKey(ctx, "PAY-2"); tk.State != domain.StatePushing || !tk.PostReport {
		t.Fatalf("approved report: state=%s post=%v", tk.State, tk.PostReport)
	}

	// Tasks without a repository: reports yes, code no.
	if out, isErr = call(t, cs, "create_task", map[string]any{"kind": "code", "title": "x"}); !isErr {
		t.Fatalf("code task without a repository: %v", out)
	}
	out, isErr = call(t, cs, "create_task", map[string]any{"kind": "analysis", "title": "Why is checkout slow?"})
	if isErr || !strings.Contains(out["summary"].(string), "analysis task without a repository") {
		t.Fatalf("analysis task: %v", out)
	}
	if out, isErr = call(t, cs, "confirm_action", map[string]any{"action_id": out["action_id"]}); isErr {
		t.Fatalf("confirm task: %v", out)
	}
	key := out["ticket"].(map[string]any)["key"].(string)
	tk, err := store.TicketByKey(ctx, key)
	if err != nil || tk.Kind != domain.KindAnalysis || tk.RepoID != nil {
		t.Fatalf("task: %+v %v", tk, err)
	}

	// Changing the kind takes a confirmation too.
	out, isErr = call(t, cs, "set_ticket_kind", map[string]any{"key": key, "kind": "bug"})
	if isErr {
		t.Fatalf("set_ticket_kind: %v", out)
	}
	if tk, _ := store.TicketByKey(ctx, key); tk.Kind != domain.KindAnalysis {
		t.Fatal("kind changed before confirmation")
	}
	if out, isErr = call(t, cs, "confirm_action", map[string]any{"action_id": out["action_id"]}); isErr {
		t.Fatalf("confirm kind: %v", out)
	}
	if tk, _ := store.TicketByKey(ctx, key); tk.Kind != domain.KindBug || tk.KindAuto {
		t.Fatalf("kind after confirm: %s auto=%v", tk.Kind, tk.KindAuto)
	}
	if out, isErr = call(t, cs, "set_ticket_kind", map[string]any{"key": key, "kind": "deploy"}); !isErr {
		t.Fatalf("unknown kind accepted: %v", out)
	}
}

func TestImplementTicket(t *testing.T) {
	cs, store := setup(t)
	ctx := testCtx
	if _, err := store.CreateTicket(ctx, domain.Ticket{Key: "PAY-3", Source: domain.SourceJira, Title: "Plan expiry", Kind: domain.KindPlan,
		State: domain.StateNew, ResumeState: domain.StateNew, AfterApprove: "pr"}, domain.Event{Type: domain.EventTicketCreated}); err != nil {
		t.Fatal(err)
	}
	move := func(states ...domain.TicketState) {
		t.Helper()
		for _, st := range states {
			if _, err := store.Transition(ctx, "PAY-3", st, domain.Event{TicketKey: "PAY-3", Type: domain.EventStateChanged}, nil); err != nil {
				t.Fatal(err)
			}
		}
	}
	move(domain.StateAnalyzing, domain.StateCoding)
	if out, isErr := call(t, cs, "implement_ticket", map[string]any{"key": "PAY-3", "repository": "api"}); !isErr {
		t.Fatalf("implemented before done: %v", out)
	}
	_, run, ok, err := store.ClaimNext(ctx)
	if err != nil || !ok {
		t.Fatalf("claim: %v %v", ok, err)
	}
	if err := store.SaveResult(ctx, domain.Result{RunID: run.ID, Report: "# Plan\n\n1. Expire tokens."}); err != nil {
		t.Fatal(err)
	}
	now := time.Now()
	run.FinishedAt = &now
	if err := store.FinishRun(ctx, run); err != nil {
		t.Fatal(err)
	}
	move(domain.StateWaitingForReview, domain.StatePushing, domain.StateDone)

	if out, isErr := call(t, cs, "implement_ticket", map[string]any{"key": "PAY-3"}); !isErr {
		t.Fatalf("no repository accepted: %v", out)
	}
	out, isErr := call(t, cs, "implement_ticket", map[string]any{"key": "PAY-3", "repository": "api", "queue": true})
	if isErr || !strings.Contains(out["summary"].(string), "keep it in the queue") {
		t.Fatalf("implement_ticket: %v", out)
	}
	if out, isErr = call(t, cs, "confirm_action", map[string]any{"action_id": out["action_id"]}); isErr {
		t.Fatalf("confirm: %v", out)
	}
	key := out["ticket"].(map[string]any)["key"].(string)
	child, err := store.TicketByKey(ctx, key)
	if err != nil || child.ParentKey != "PAY-3" || !child.Held || child.Kind != domain.KindCode {
		t.Fatalf("child: %+v %v", child, err)
	}
	got, _ := call(t, cs, "get_ticket", map[string]any{"key": "PAY-3"})
	if got["implemented_by"] != key {
		t.Fatalf("get_ticket: %v", got)
	}
}

func TestFollowUpTools(t *testing.T) {
	cs, store := setup(t)
	ctx := testCtx
	tk, err := store.TicketByKey(ctx, "PAY-1")
	if err != nil {
		t.Fatal(err)
	}
	ss := []domain.Suggestion{
		{Source: domain.SuggestFromAnalyze, Type: "prerequisite", Title: "Add refund_cents", Serves: "needed first", Kind: domain.KindCode, Priority: "high"},
		{Source: domain.SuggestFromAnalyze, Type: "split", Title: "Admin screen", Serves: "part of it", Kind: domain.KindCode, Priority: "low"},
		{Source: domain.SuggestFromWork, Type: "unfinished", Title: "Test negatives", Serves: "untested", Kind: domain.KindTest, Priority: "medium"},
	}
	if err := store.ReplaceSuggestions(ctx, tk.ID, domain.SuggestFromAnalyze, ss[:2], nil); err != nil {
		t.Fatal(err)
	}
	if err := store.ReplaceSuggestions(ctx, tk.ID, domain.SuggestFromWork, ss[2:], nil); err != nil {
		t.Fatal(err)
	}
	got, _ := call(t, cs, "get_ticket", map[string]any{"key": "PAY-1"})
	fus, _ := got["follow_ups"].([]any)
	if len(fus) != 3 {
		t.Fatalf("follow_ups: %v", got["follow_ups"])
	}
	ids := make([]float64, 3)
	for i, f := range fus {
		ids[i] = f.(map[string]any)["id"].(float64)
	}
	if fus[2].(map[string]any)["ready"] != false || fus[0].(map[string]any)["ready"] != true {
		t.Fatalf("readiness: %v", fus)
	}

	if out, isErr := call(t, cs, "accept_follow_ups", map[string]any{"key": "PAY-1", "items": []any{map[string]any{"id": ids[2]}}}); !isErr {
		t.Fatalf("work follow-up accepted before done: %v", out)
	}
	out, isErr := call(t, cs, "accept_follow_ups", map[string]any{"key": "PAY-1", "items": []any{map[string]any{"id": ids[0], "kind": "test"}}})
	if isErr || !strings.Contains(out["summary"].(string), `"Add refund_cents" (test) as a local task`) {
		t.Fatalf("accept_follow_ups: %v", out)
	}
	if out, isErr = call(t, cs, "confirm_action", map[string]any{"action_id": out["action_id"]}); isErr {
		t.Fatalf("confirm: %v", out)
	}
	created, _ := out["created"].([]any)
	if len(created) != 1 {
		t.Fatalf("created: %v", out)
	}
	child, err := store.TicketByKey(ctx, created[0].(map[string]any)["key"].(string))
	if err != nil || child.FollowUpOf != "PAY-1" || !child.Held || child.Kind != domain.KindTest {
		t.Fatalf("child: %+v %v", child, err)
	}

	out, isErr = call(t, cs, "dismiss_follow_up", map[string]any{"key": "PAY-1", "id": ids[1]})
	if isErr {
		t.Fatalf("dismiss: %v", out)
	}
	if out, isErr = call(t, cs, "confirm_action", map[string]any{"action_id": out["action_id"]}); isErr {
		t.Fatalf("confirm dismiss: %v", out)
	}
	if out, isErr = call(t, cs, "dismiss_follow_up", map[string]any{"key": "PAY-1", "id": ids[1]}); !isErr {
		t.Fatalf("dismissed twice: %v", out)
	}
}

// A task in several repositories, or a group's, from MCP; the ticket shows
// each repository's state.
func TestMultiRepoTools(t *testing.T) {
	cs, store := setup(t)
	ctx := testCtx
	api, err := store.RepositoryByName(ctx, "api")
	if err != nil {
		t.Fatal(err)
	}
	web, err := store.SaveRepository(ctx, domain.Repository{Name: "web", Kind: "side", Provider: "github", CloneURL: "https://github.com/acme/web.git", DefaultBranch: "main"})
	if err != nil {
		t.Fatal(err)
	}
	if _, err := store.SaveGroup(ctx, domain.RepoGroup{Name: "Shop", TaskPrefix: "SHOP",
		Members: []domain.GroupMember{{RepoID: api.ID, Role: "backend"}, {RepoID: web.ID}}}); err != nil {
		t.Fatal(err)
	}
	out, isErr := call(t, cs, "list_repository_groups", nil)
	gs, _ := out["groups"].([]any)
	if isErr || len(gs) != 1 || !strings.Contains(fmt.Sprint(gs[0]), "api (backend)") {
		t.Fatalf("groups: %v", out)
	}
	out, isErr = call(t, cs, "create_task", map[string]any{"kind": "code", "title": "Refunds page", "group": "shop"})
	if isErr || !strings.Contains(out["summary"].(string), "in the group Shop (api, web)") {
		t.Fatalf("task in a group: %v", out)
	}
	if out, isErr = call(t, cs, "confirm_action", map[string]any{"action_id": out["action_id"]}); isErr {
		t.Fatalf("confirm: %v", out)
	}
	key := out["ticket"].(map[string]any)["key"].(string)
	tk, err := store.TicketByKey(ctx, key)
	if err != nil || key != "SHOP-1" || len(tk.Repos) != 2 || tk.GroupName != "Shop" {
		t.Fatalf("task: %s %+v %v", key, tk.Repos, err)
	}
	got, _ := call(t, cs, "get_ticket", map[string]any{"key": key})
	if states, _ := got["repository_states"].([]any); len(states) != 2 || got["group"] != "Shop" {
		t.Fatalf("get_ticket: %v", got)
	}
	out, isErr = call(t, cs, "create_task", map[string]any{"kind": "code", "title": "Both", "repositories": []string{"web", "api"}})
	if isErr || !strings.Contains(out["summary"].(string), "in web and api") {
		t.Fatalf("task in two repositories: %v", out)
	}
	if out, isErr = call(t, cs, "create_task", map[string]any{"title": "x", "repository": "api", "group": "Shop"}); !isErr {
		t.Fatalf("repositories and a group at once: %v", out)
	}
}
