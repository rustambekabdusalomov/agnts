package actions_test

import (
	"context"
	"encoding/json"
	"io"
	"log/slog"
	"strings"
	"testing"

	"agnts/internal/actions"
	"agnts/internal/admin"
	"agnts/internal/domain"
	"agnts/internal/orchestrator"
	"agnts/internal/store/postgres"
	"agnts/internal/store/postgres/pgtest"
	"agnts/internal/usage"
	"agnts/internal/vcs/github"
)

// setup makes a workspace with repository api and ticket PAY-1 waiting for
// review.
func setup(t *testing.T) (context.Context, actions.Deps) {
	t.Helper()
	pool := pgtest.Open(t)
	pgtest.Reset(t, pool)
	ctx, _ := pgtest.Workspace(t, pool, "actions")
	log := slog.New(slog.NewTextHandler(io.Discard, nil))
	store := postgres.NewAgent(pool)
	settings := postgres.NewSettings(pool, domain.DefaultSettings())
	ut := usage.New(postgres.NewUsage(pool), store, log)
	orch := orchestrator.New(orchestrator.DefaultConfig(), orchestrator.Deps{Store: store, Settings: settings, Usage: ut}, log)
	gh := github.New("http://127.0.0.1:1", func(context.Context) (string, error) { return "", nil })
	repos := admin.NewRepos(store, gh, gh, nil, log)

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
	return ctx, actions.Deps{Orch: orch, Store: store, Repos: repos}
}

func TestPrepare(t *testing.T) {
	ctx, d := setup(t)
	cases := []struct {
		name, tool, args string
		summary, err     string // what the summary or the error contains
	}{
		{"unknown tool", "deploy", `{}`, "", "unknown action"},
		{"bad input", actions.ApproveTicket, `{"key": 5}`, "", "not valid"},
		{"no ticket", actions.StartRun, `{"key": "PAY-404"}`, "", `no ticket "PAY-404"`},
		{"approve", actions.ApproveTicket, `{"key": "PAY-1"}`, "push agnts/PAY-1 and open a pull request", ""},
		{"post report on a change", actions.ApproveTicket, `{"key": "PAY-1", "post_report": true}`, "", "not a report"},
		{"answers when not asked", actions.AnswerQuestions, `{"key": "PAY-1", "answers": []}`, "", "not waiting for answers"},
		{"feedback required", actions.RequestChanges, `{"key": "PAY-1", "feedback": " "}`, "", "feedback is required"},
		{"code task needs a repository", actions.CreateTask, `{"kind": "code", "title": "x"}`, "", "needs a repository"},
		{"unknown repository", actions.CreateTask, `{"kind": "code", "title": "x", "repository": "web"}`, "", `no repository named "web"`},
		{"task", actions.CreateTask, `{"kind": "code", "title": "Add retries", "repository": "API"}`, `Create a code task in api: "Add retries"`, ""},
		{"no input", actions.RetryRun, ``, "", `no ticket ""`},
	}
	for _, c := range cases {
		t.Run(c.name, func(t *testing.T) {
			p, err := d.Prepare(ctx, c.tool, json.RawMessage(c.args))
			if c.err != "" {
				if err == nil || !strings.Contains(err.Error(), c.err) {
					t.Fatalf("err = %v, want %q", err, c.err)
				}
				return
			}
			if err != nil {
				t.Fatal(err)
			}
			if p.Tool != c.tool || !strings.Contains(p.Summary, c.summary) {
				t.Fatalf("got %s %q, want %s %q", p.Tool, p.Summary, c.tool, c.summary)
			}
		})
	}
}

func TestPrepareArgsRoundTrip(t *testing.T) {
	ctx, d := setup(t)
	p, err := d.Prepare(ctx, actions.CreateTask, json.RawMessage(`{"kind": "code", "title": "Add retries", "repository": "api"}`))
	if err != nil {
		t.Fatal(err)
	}
	if p.TicketKey != "" || p.Args["priority"] != "medium" || p.Args["start"] != "ask" || p.Args["after_approve"] != "pr" {
		t.Fatalf("defaults not filled: %+v", p)
	}
	if ids, _ := p.Args["repo_ids"].([]int64); len(ids) != 1 {
		t.Fatalf("repo_ids = %v", p.Args["repo_ids"])
	}
}

func TestExecute(t *testing.T) {
	ctx, d := setup(t)
	p, err := d.Prepare(ctx, actions.RejectTicket, json.RawMessage(`{"key": "PAY-1", "reason": "not needed"}`))
	if err != nil {
		t.Fatal(err)
	}
	// Execute reads arguments as they come back from the database: JSON.
	var args map[string]any
	b, _ := json.Marshal(p.Args)
	_ = json.Unmarshal(b, &args)
	a := postgres.PendingAction{Tool: p.Tool, TicketKey: p.TicketKey, Summary: p.Summary, Args: args}
	res, err := d.Execute(ctx, a, domain.OriginMCP)
	if err != nil {
		t.Fatal(err)
	}
	if res.Done != p.Summary || res.Ticket == nil || res.Ticket.State != domain.StateRejected {
		t.Fatalf("result = %+v", res)
	}
	if _, err := d.Execute(ctx, postgres.PendingAction{Tool: "deploy"}, domain.OriginMCP); err == nil || !strings.Contains(err.Error(), "unknown action") {
		t.Fatalf("unknown tool: %v", err)
	}
}

func TestDestructive(t *testing.T) {
	for tool, want := range map[string]bool{actions.ApproveTicket: true, actions.RejectTicket: true, actions.StartRun: false, actions.CreateTask: false} {
		if actions.Destructive(tool) != want {
			t.Errorf("Destructive(%s) = %v", tool, !want)
		}
	}
}
