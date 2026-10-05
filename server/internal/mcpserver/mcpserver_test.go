package mcpserver_test

import (
	"context"
	"encoding/json"
	"io"
	"log/slog"
	"os"
	"strings"
	"testing"
	"time"

	"github.com/modelcontextprotocol/go-sdk/mcp"

	"hiro/internal/admin"
	"hiro/internal/domain"
	"hiro/internal/mcpserver"
	"hiro/internal/orchestrator"
	"hiro/internal/store/postgres"
	"hiro/internal/usage"
	"hiro/internal/vcs/github"
)

func setup(t *testing.T) (*mcp.ClientSession, *postgres.Agent) {
	t.Helper()
	url := os.Getenv("HIRO_TEST_DATABASE_URL")
	if url == "" {
		t.Skip("HIRO_TEST_DATABASE_URL not set")
	}
	ctx := context.Background()
	pool, err := postgres.Open(ctx, url)
	if err != nil {
		t.Fatal(err)
	}
	t.Cleanup(pool.Close)
	log := slog.New(slog.NewTextHandler(io.Discard, nil))
	if err := postgres.Migrate(ctx, pool, "up", log); err != nil {
		t.Fatal(err)
	}
	if _, err := pool.Exec(ctx, `TRUNCATE tickets, runs, results, questions, events, repositories, pending_actions RESTART IDENTITY CASCADE`); err != nil {
		t.Fatal(err)
	}
	store := postgres.NewAgent(pool)
	settings := postgres.NewSettings(pool, domain.DefaultSettings())
	ut := usage.New(postgres.NewUsage(pool), store, log)
	orch := orchestrator.New(orchestrator.DefaultConfig(), orchestrator.Deps{Store: store, Settings: settings, Usage: ut}, log)
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
			x.Branch = "hiro/PAY-1"
		}); err != nil {
			t.Fatal(err)
		}
	}

	srv := mcpserver.NewServer(mcpserver.Deps{Orch: orch, Store: store, Usage: ut, Settings: settings, Dashboard: dash, Repos: repos}, "test")
	st, ct := mcp.NewInMemoryTransports()
	if _, err := srv.Connect(ctx, st, nil); err != nil {
		t.Fatal(err)
	}
	cs, err := mcp.NewClient(&mcp.Implementation{Name: "test"}, nil).Connect(ctx, ct, nil)
	if err != nil {
		t.Fatal(err)
	}
	t.Cleanup(func() { _ = cs.Close() })
	return cs, store
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
	for _, n := range []string{"get_inbox", "list_tickets", "get_ticket", "get_run_log", "get_usage", "get_analytics", "list_repositories", "get_repository"} {
		if tl := byName[n]; tl == nil || tl.Annotations == nil || !tl.Annotations.ReadOnlyHint {
			t.Errorf("%s should exist and be read-only", n)
		}
	}
	for _, n := range []string{"approve_ticket", "reject_ticket"} {
		if tl := byName[n]; tl == nil || tl.Annotations == nil || tl.Annotations.DestructiveHint == nil || !*tl.Annotations.DestructiveHint {
			t.Errorf("%s should be marked destructive", n)
		}
	}
	for _, n := range []string{"answer_questions", "start_run", "request_changes", "retry_run", "create_task", "set_ticket_kind", "implement_ticket", "confirm_action"} {
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
	ctx := context.Background()

	inbox, _ := call(t, cs, "get_inbox", nil)
	if needs, _ := inbox["needs_you"].([]any); len(needs) != 1 {
		t.Fatalf("inbox: %v", inbox)
	}

	out, isErr := call(t, cs, "approve_ticket", map[string]any{"key": "PAY-1"})
	if isErr {
		t.Fatalf("approve_ticket: %v", out)
	}
	id, _ := out["action_id"].(string)
	if id == "" || !strings.Contains(out["summary"].(string), "hiro/PAY-1") {
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
	ctx := context.Background()

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
	ctx := context.Background()
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
