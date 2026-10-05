// Package mcpserver exposes hiro to Claude chat as an MCP server. Reads run
// directly; every write is two-step: the tool creates a pending action and
// returns what it would do, and nothing happens until confirm_action.
// Deploys, disconnecting integrations and settings are not exposed.
package mcpserver

import (
	"context"
	"crypto/rand"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"
	"strings"
	"time"

	"github.com/modelcontextprotocol/go-sdk/mcp"

	"hiro/internal/admin"
	"hiro/internal/domain"
	"hiro/internal/orchestrator"
	"hiro/internal/store/postgres"
	"hiro/internal/usage"
)

// ConfirmTTL is how long a pending write waits for confirm_action.
const ConfirmTTL = 10 * time.Minute

// Deps are the use cases the tools call: the same ones the REST API uses.
type Deps struct {
	Orch      *orchestrator.Orchestrator
	Store     *postgres.Agent
	Usage     *usage.Tracker
	Settings  orchestrator.SettingsSource
	Dashboard *admin.Dashboard
	Repos     *admin.Repos
	Lessons   *postgres.Lessons                                // nil disables the lesson tools
	Analytics func(ctx context.Context, days int) (any, error) // phase 5; nil returns weekly stats
}

type tools struct{ d Deps }

// NewServer builds the MCP server with hiro's tools.
func NewServer(d Deps, version string) *mcp.Server {
	s := mcp.NewServer(&mcp.Implementation{Name: "hiro", Title: "hiro", Version: version}, &mcp.ServerOptions{
		Instructions: "hiro is the user's coding agent. Use get_inbox first to see what needs the user. " +
			"Write tools never act directly: they return an action_id and a summary. Show the summary to the user, " +
			"and call confirm_action only after the user explicitly agrees. Never confirm on your own.",
	})
	t := &tools{d: d}
	ro := &mcp.ToolAnnotations{ReadOnlyHint: true}
	yes, no := true, false
	write := &mcp.ToolAnnotations{DestructiveHint: &no}
	destructive := &mcp.ToolAnnotations{DestructiveHint: &yes}

	mcp.AddTool(s, &mcp.Tool{Name: "get_inbox", Description: "Tickets waiting on the user (questions to answer, changes to review, stopped runs), oldest first, plus what is running.", Annotations: ro}, t.getInbox)
	mcp.AddTool(s, &mcp.Tool{Name: "list_tickets", Description: "List tickets. filter: needs, running, queue, done or all.", Annotations: ro}, t.listTickets)
	mcp.AddTool(s, &mcp.Tool{Name: "get_ticket", Description: "One ticket: description, hiro's analysis and plan, questions with ids, the latest result (summary, checks, changed files) and history.", Annotations: ro}, t.getTicket)
	mcp.AddTool(s, &mcp.Tool{Name: "get_run_log", Description: "The newest log lines of a ticket's runs (tool calls, checks, state changes).", Annotations: ro}, t.getRunLog)
	mcp.AddTool(s, &mcp.Tool{Name: "get_usage", Description: "Claude plan usage (session and weekly) and whether new runs are paused.", Annotations: ro}, t.getUsage)
	mcp.AddTool(s, &mcp.Tool{Name: "get_analytics", Description: "Statistics for the last N days (7, 30 or 90): tickets picked up, pushed, first-try approvals, turns, waiting time, stops.", Annotations: ro}, t.getAnalytics)
	mcp.AddTool(s, &mcp.Tool{Name: "list_repositories", Description: "Repositories hiro works on, with open ticket counts.", Annotations: ro}, t.listRepos)
	mcp.AddTool(s, &mcp.Tool{Name: "get_repository", Description: "One repository by name.", Annotations: ro}, t.getRepo)
	mcp.AddTool(s, &mcp.Tool{Name: "list_lessons", Description: "Lessons hiro wrote about techniques its pushed changes introduced to a repository for the first time (patterns, architecture, algorithms, libraries), newest first.", Annotations: ro}, t.listLessons)
	mcp.AddTool(s, &mcp.Tool{Name: "get_lesson", Description: "One lesson: explanation, why the change needed it, code references, quiz (with answers: ask the user first, then reveal) and further reading.", Annotations: ro}, t.getLesson)

	mcp.AddTool(s, &mcp.Tool{Name: "answer_questions", Description: "Prepare answers to a ticket's questions (all must be answered). Returns an action_id to confirm.", Annotations: write}, t.answerQuestions)
	mcp.AddTool(s, &mcp.Tool{Name: "start_run", Description: "Prepare starting a ticket that is held in the queue. Returns an action_id to confirm.", Annotations: write}, t.startRun)
	mcp.AddTool(s, &mcp.Tool{Name: "request_changes", Description: "Prepare sending a ticket under review back to coding with feedback. Returns an action_id to confirm.", Annotations: write}, t.requestChanges)
	mcp.AddTool(s, &mcp.Tool{Name: "retry_run", Description: "Prepare retrying a stopped or paused ticket. Returns an action_id to confirm.", Annotations: write}, t.retryRun)
	mcp.AddTool(s, &mcp.Tool{Name: "create_task", Description: "Prepare a new side-project task. Returns an action_id to confirm.", Annotations: write}, t.createTask)
	mcp.AddTool(s, &mcp.Tool{Name: "approve_ticket", Description: "Prepare approving reviewed changes: hiro will push and open the pull request. Returns an action_id; confirm only if the user explicitly approves.", Annotations: destructive}, t.approveTicket)
	mcp.AddTool(s, &mcp.Tool{Name: "reject_ticket", Description: "Prepare rejecting a ticket (stops all work on it). Returns an action_id; confirm only if the user explicitly agrees.", Annotations: destructive}, t.rejectTicket)
	mcp.AddTool(s, &mcp.Tool{Name: "confirm_action", Description: "Execute a prepared action after the user explicitly agreed to its summary. Actions expire after 10 minutes and run once.", Annotations: write}, t.confirmAction)
	return s
}

// ---- outputs ----

// TicketBrief is a ticket in lists.
type TicketBrief struct {
	Key          string `json:"key"`
	Title        string `json:"title"`
	State        string `json:"state"`
	Source       string `json:"source"`
	Repository   string `json:"repository,omitempty"`
	InStateSince string `json:"in_state_since,omitempty"`
	StopReason   string `json:"stop_reason,omitempty"`
	PRURL        string `json:"pr_url,omitempty"`
}

func brief(r orchestrator.TicketRow) TicketBrief {
	b := TicketBrief{Key: r.Ticket.Key, Title: r.Ticket.Title, State: string(r.Ticket.State), Source: string(r.Ticket.Source),
		Repository: r.RepoName, PRURL: r.Ticket.PRURL}
	if !r.Info.Since.IsZero() {
		b.InStateSince = r.Info.Since.UTC().Format(time.RFC3339)
	}
	if r.Ticket.State == domain.StateFailed || r.Ticket.State == domain.StateRateLimited {
		b.StopReason = r.Info.Reason
	}
	return b
}

// Pending is what every write tool returns.
type Pending struct {
	ActionID  string `json:"action_id"`
	Summary   string `json:"summary"`
	ExpiresAt string `json:"expires_at"`
	Next      string `json:"next"`
}

// ---- reads ----

type noInput struct{}

// Inbox is get_inbox's output.
type Inbox struct {
	NeedsYou []TicketBrief `json:"needs_you"`
	Running  []TicketBrief `json:"running"`
	Queued   int           `json:"queued"`
}

func (t *tools) getInbox(ctx context.Context, _ *mcp.CallToolRequest, _ noInput) (*mcp.CallToolResult, Inbox, error) {
	d, err := t.d.Dashboard.Build(ctx)
	if err != nil {
		return nil, Inbox{}, err
	}
	out := Inbox{NeedsYou: []TicketBrief{}, Running: []TicketBrief{}, Queued: d.Counts["queued"]}
	needs, err := t.rows(ctx, filterStates["needs"], 50)
	if err != nil {
		return nil, out, err
	}
	for _, r := range needs {
		out.NeedsYou = append(out.NeedsYou, brief(r))
	}
	for _, l := range d.Live {
		out.Running = append(out.Running, brief(l.Row))
	}
	return nil, out, nil
}

var filterStates = map[string][]domain.TicketState{
	"needs":   {domain.StateWaitingForAnswers, domain.StateWaitingForReview, domain.StateFailed, domain.StateRateLimited},
	"running": {domain.StateAnalyzing, domain.StateCoding, domain.StateTesting, domain.StatePushing},
	"queue":   {domain.StateNew},
	"done":    {domain.StateDone, domain.StateRejected},
	"all":     nil,
}

func (t *tools) rows(ctx context.Context, states []domain.TicketState, limit int) ([]orchestrator.TicketRow, error) {
	ts, err := t.d.Orch.List(ctx, orchestrator.TicketFilter{States: states, Limit: limit})
	if err != nil {
		return nil, err
	}
	return t.d.Orch.Rows(ctx, ts)
}

// ListInput filters list_tickets.
type ListInput struct {
	Filter string `json:"filter,omitempty" jsonschema:"needs, running, queue, done or all (default all)"`
	Limit  int    `json:"limit,omitempty" jsonschema:"at most this many, default 30"`
}

// TicketList is list_tickets's output.
type TicketList struct {
	Tickets []TicketBrief `json:"tickets"`
}

func (t *tools) listTickets(ctx context.Context, _ *mcp.CallToolRequest, in ListInput) (*mcp.CallToolResult, TicketList, error) {
	if in.Filter == "" {
		in.Filter = "all"
	}
	states, ok := filterStates[in.Filter]
	if !ok {
		return nil, TicketList{}, fmt.Errorf("filter must be needs, running, queue, done or all")
	}
	if in.Limit <= 0 || in.Limit > 100 {
		in.Limit = 30
	}
	rows, err := t.rows(ctx, states, in.Limit)
	if err != nil {
		return nil, TicketList{}, err
	}
	out := TicketList{Tickets: []TicketBrief{}}
	for _, r := range rows {
		out.Tickets = append(out.Tickets, brief(r))
	}
	return nil, out, nil
}

// KeyInput names a ticket.
type KeyInput struct {
	Key string `json:"key" jsonschema:"ticket or task key, e.g. PAY-214"`
}

// QuestionOut is a question in get_ticket.
type QuestionOut struct {
	ID      int64    `json:"id"`
	Text    string   `json:"text"`
	Options []string `json:"options"`
	Answer  string   `json:"answer,omitempty"`
}

// FileOut is a changed file.
type FileOut struct {
	Path string `json:"path"`
	Add  int    `json:"add"`
	Del  int    `json:"del"`
}

// TicketOut is get_ticket's output.
type TicketOut struct {
	TicketBrief
	Description  string        `json:"description"`
	Branch       string        `json:"branch,omitempty"`
	Revision     int           `json:"revision"`
	Analysis     string        `json:"analysis,omitempty"`
	Plan         []string      `json:"plan,omitempty"`
	Questions    []QuestionOut `json:"questions,omitempty"`
	Summary      string        `json:"summary,omitempty"`
	Notes        []string      `json:"notes,omitempty"`
	Checks       []string      `json:"checks,omitempty"`
	ChangedFiles []FileOut     `json:"changed_files,omitempty"`
	History      []string      `json:"history,omitempty"`
}

func (t *tools) getTicket(ctx context.Context, _ *mcp.CallToolRequest, in KeyInput) (*mcp.CallToolResult, TicketOut, error) {
	v, err := t.d.Orch.View(ctx, strings.TrimSpace(in.Key))
	if err != nil {
		return nil, TicketOut{}, notFound(err, in.Key)
	}
	out := TicketOut{
		TicketBrief: brief(orchestrator.TicketRow{Ticket: v.Ticket, Info: v.Info, RepoName: v.RepoName}),
		Description: v.Ticket.Description, Branch: v.Ticket.Branch, Revision: v.Ticket.Revision,
	}
	if v.Analysis != nil {
		out.Analysis, out.Plan = v.Analysis.Summary, v.Analysis.Plan
	}
	for _, q := range v.Questions {
		qo := QuestionOut{ID: q.ID, Text: q.Text, Options: q.Options}
		if q.Answer != nil {
			qo.Answer = *q.Answer
		}
		out.Questions = append(out.Questions, qo)
	}
	if r := v.Result; r != nil {
		var sum orchestrator.Summary
		if json.Unmarshal(r.Summary, &sum) == nil {
			out.Summary, out.Notes = sum.Summary, sum.Notes
		}
		var steps []orchestrator.CheckStep
		_ = json.Unmarshal(r.Tests, &steps)
		for _, s := range steps {
			status := "passed"
			if s.ExitCode != 0 {
				status = fmt.Sprintf("failed (exit %d)", s.ExitCode)
			}
			out.Checks = append(out.Checks, s.Command+": "+status)
		}
		for _, f := range r.Files {
			out.ChangedFiles = append(out.ChangedFiles, FileOut{Path: f.Path, Add: f.Add, Del: f.Del})
		}
	}
	for i, h := range v.History {
		if i < len(v.History)-10 {
			continue
		}
		out.History = append(out.History, fmt.Sprintf("%s %s: %s", h.At.UTC().Format(time.RFC3339), h.State, h.Message))
	}
	return nil, out, nil
}

// LogInput asks for a ticket's log.
type LogInput struct {
	Key   string `json:"key"`
	Lines int    `json:"lines,omitempty" jsonschema:"how many of the newest lines, default 50"`
}

// LogOut is get_run_log's output.
type LogOut struct {
	Lines []string `json:"lines"`
}

func (t *tools) getRunLog(ctx context.Context, _ *mcp.CallToolRequest, in LogInput) (*mcp.CallToolResult, LogOut, error) {
	if in.Lines <= 0 || in.Lines > 300 {
		in.Lines = 50
	}
	if _, err := t.d.Store.TicketByKey(ctx, in.Key); err != nil {
		return nil, LogOut{}, notFound(err, in.Key)
	}
	evs, err := t.d.Orch.Events(ctx, orchestrator.EventFilter{TicketKey: in.Key, Limit: 1000})
	if err != nil {
		return nil, LogOut{}, err
	}
	if len(evs) > in.Lines {
		evs = evs[len(evs)-in.Lines:]
	}
	out := LogOut{Lines: []string{}}
	for _, e := range evs {
		msg := e.Message
		if len(msg) > 300 {
			msg = msg[:300] + "…"
		}
		out.Lines = append(out.Lines, fmt.Sprintf("%s [%s] %s", e.CreatedAt.UTC().Format("15:04:05"), e.Type, msg))
	}
	return nil, out, nil
}

// UsageOut is get_usage's output.
type UsageOut struct {
	SessionPercent  *int   `json:"session_percent,omitempty"`
	SessionResetsAt string `json:"session_resets_at,omitempty"`
	WeeklyPercent   *int   `json:"weekly_percent,omitempty"`
	Status          string `json:"status"`
	Paused          bool   `json:"new_runs_paused"`
	PauseAbove      int    `json:"pause_above_percent"`
}

func (t *tools) getUsage(ctx context.Context, _ *mcp.CallToolRequest, _ noInput) (*mcp.CallToolResult, UsageOut, error) {
	s, err := t.d.Settings.Get(ctx)
	if err != nil {
		return nil, UsageOut{}, err
	}
	v, err := t.d.Usage.Current(ctx, s)
	if err != nil {
		return nil, UsageOut{}, err
	}
	pct := func(f *float64) *int {
		if f == nil {
			return nil
		}
		p := int(*f*100 + 0.5)
		return &p
	}
	out := UsageOut{SessionPercent: pct(v.FiveHour), WeeklyPercent: pct(v.SevenDay), Status: v.Status, Paused: v.Paused, PauseAbove: v.PauseAbove}
	if v.FiveHourResets != nil {
		out.SessionResetsAt = v.FiveHourResets.UTC().Format(time.RFC3339)
	}
	return nil, out, nil
}

// DaysInput picks an analytics period.
type DaysInput struct {
	Days int `json:"days,omitempty" jsonschema:"7, 30 or 90 (default 7)"`
}

// AnalyticsOut wraps get_analytics's output.
type AnalyticsOut struct {
	Days int `json:"days"`
	Data any `json:"data"`
}

func (t *tools) getAnalytics(ctx context.Context, _ *mcp.CallToolRequest, in DaysInput) (*mcp.CallToolResult, AnalyticsOut, error) {
	if in.Days != 30 && in.Days != 90 {
		in.Days = 7
	}
	if t.d.Analytics != nil {
		data, err := t.d.Analytics(ctx, in.Days)
		return nil, AnalyticsOut{Days: in.Days, Data: data}, err
	}
	w, err := t.d.Store.Week(ctx, time.Now().Add(-7*24*time.Hour))
	return nil, AnalyticsOut{Days: 7, Data: w}, err
}

// RepoOut is a repository.
type RepoOut struct {
	Name          string `json:"name"`
	Kind          string `json:"kind"`
	CloneURL      string `json:"clone_url"`
	DefaultBranch string `json:"default_branch"`
	JiraProject   string `json:"jira_project,omitempty"`
	TestCommand   string `json:"test_command,omitempty"`
	OpenTickets   int    `json:"open_tickets"`
	ClaudeMD      string `json:"claude_md"`
	Archived      bool   `json:"archived,omitempty"` // takes no new tickets or tasks
}

func repoOut(r admin.RepoView) RepoOut {
	return RepoOut{Name: r.Name, Kind: r.Kind, CloneURL: r.CloneURL, DefaultBranch: r.DefaultBranch, JiraProject: r.JiraProject,
		TestCommand: r.TestCmd, OpenTickets: r.Open, ClaudeMD: r.ClaudeMDState, Archived: r.ArchivedAt != nil}
}

// RepoList is list_repositories's output.
type RepoList struct {
	Repositories []RepoOut `json:"repositories"`
}

func (t *tools) listRepos(ctx context.Context, _ *mcp.CallToolRequest, _ noInput) (*mcp.CallToolResult, RepoList, error) {
	list, err := t.d.Repos.List(ctx)
	if err != nil {
		return nil, RepoList{}, err
	}
	out := RepoList{Repositories: []RepoOut{}}
	for _, r := range list {
		out.Repositories = append(out.Repositories, repoOut(r))
	}
	return nil, out, nil
}

// NameInput names a repository.
type NameInput struct {
	Name string `json:"name"`
}

func (t *tools) getRepo(ctx context.Context, _ *mcp.CallToolRequest, in NameInput) (*mcp.CallToolResult, RepoOut, error) {
	list, err := t.d.Repos.List(ctx)
	if err != nil {
		return nil, RepoOut{}, err
	}
	for _, r := range list {
		if strings.EqualFold(r.Name, strings.TrimSpace(in.Name)) {
			return nil, repoOut(r), nil
		}
	}
	return nil, RepoOut{}, fmt.Errorf("no repository named %q", in.Name)
}

// ---- writes (two-step) ----

func (t *tools) prepare(ctx context.Context, tool, key, summary string, args map[string]any) (*mcp.CallToolResult, Pending, error) {
	b := make([]byte, 8)
	_, _ = rand.Read(b)
	id := hex.EncodeToString(b)
	exp := time.Now().Add(ConfirmTTL)
	if args == nil {
		args = map[string]any{}
	}
	if err := t.d.Store.CreatePending(ctx, postgres.PendingAction{ID: id, Origin: domain.OriginMCP, Tool: tool, TicketKey: key,
		Args: args, Summary: summary, ExpiresAt: exp}); err != nil {
		return nil, Pending{}, err
	}
	return nil, Pending{ActionID: id, Summary: summary, ExpiresAt: exp.UTC().Format(time.RFC3339),
		Next: "Show this summary to the user. Call confirm_action with this action_id only after they explicitly agree."}, nil
}

func (t *tools) ticket(ctx context.Context, key string) (domain.Ticket, error) {
	tk, err := t.d.Store.TicketByKey(ctx, strings.TrimSpace(key))
	return tk, notFound(err, key)
}

// AnswerInput is one answer.
type AnswerInput struct {
	QuestionID int64  `json:"question_id"`
	Answer     string `json:"answer"`
	Note       string `json:"note,omitempty"`
}

// AnswersInput answers a ticket's questions.
type AnswersInput struct {
	Key     string        `json:"key"`
	Answers []AnswerInput `json:"answers"`
}

func (t *tools) answerQuestions(ctx context.Context, _ *mcp.CallToolRequest, in AnswersInput) (*mcp.CallToolResult, Pending, error) {
	tk, err := t.ticket(ctx, in.Key)
	if err != nil {
		return nil, Pending{}, err
	}
	if tk.State != domain.StateWaitingForAnswers {
		return nil, Pending{}, fmt.Errorf("%s is not waiting for answers (it is %s)", tk.Key, tk.State)
	}
	qs, err := t.d.Store.Questions(ctx, tk.ID)
	if err != nil {
		return nil, Pending{}, err
	}
	text := map[int64]string{}
	for _, q := range qs {
		text[q.ID] = q.Text
	}
	var lines []string
	args := []any{}
	for _, a := range in.Answers {
		q, ok := text[a.QuestionID]
		if !ok {
			return nil, Pending{}, fmt.Errorf("question %d is not on %s", a.QuestionID, tk.Key)
		}
		lines = append(lines, fmt.Sprintf("- %s → %s", q, a.Answer))
		args = append(args, map[string]any{"question_id": a.QuestionID, "answer": a.Answer, "note": a.Note})
	}
	return t.prepare(ctx, "answer_questions", tk.Key, fmt.Sprintf("Answer %d question(s) on %s and start coding:\n%s", len(in.Answers), tk.Key, strings.Join(lines, "\n")),
		map[string]any{"answers": args})
}

func (t *tools) startRun(ctx context.Context, _ *mcp.CallToolRequest, in KeyInput) (*mcp.CallToolResult, Pending, error) {
	tk, err := t.ticket(ctx, in.Key)
	if err != nil {
		return nil, Pending{}, err
	}
	return t.prepare(ctx, "start_run", tk.Key, fmt.Sprintf("Start %s (%s) now.", tk.Key, tk.Title), nil)
}

// FeedbackInput requests changes.
type FeedbackInput struct {
	Key      string `json:"key"`
	Feedback string `json:"feedback"`
}

func (t *tools) requestChanges(ctx context.Context, _ *mcp.CallToolRequest, in FeedbackInput) (*mcp.CallToolResult, Pending, error) {
	tk, err := t.ticket(ctx, in.Key)
	if err != nil {
		return nil, Pending{}, err
	}
	if strings.TrimSpace(in.Feedback) == "" {
		return nil, Pending{}, errors.New("feedback is required")
	}
	return t.prepare(ctx, "request_changes", tk.Key, fmt.Sprintf("Send %s back to coding with this feedback:\n%s", tk.Key, in.Feedback),
		map[string]any{"feedback": in.Feedback})
}

func (t *tools) retryRun(ctx context.Context, _ *mcp.CallToolRequest, in KeyInput) (*mcp.CallToolResult, Pending, error) {
	tk, err := t.ticket(ctx, in.Key)
	if err != nil {
		return nil, Pending{}, err
	}
	return t.prepare(ctx, "retry_run", tk.Key, fmt.Sprintf("Retry %s (%s) from where it stopped.", tk.Key, tk.Title), nil)
}

// TaskInput creates a task.
type TaskInput struct {
	Repository   string `json:"repository" jsonschema:"side-project repository name"`
	Title        string `json:"title"`
	Description  string `json:"description,omitempty"`
	Priority     string `json:"priority,omitempty" jsonschema:"low, medium or high (default medium)"`
	AfterApprove string `json:"after_approve,omitempty" jsonschema:"pr or main (default pr)"`
	Start        string `json:"start,omitempty" jsonschema:"ask, code or queue (default ask)"`
}

func (t *tools) createTask(ctx context.Context, _ *mcp.CallToolRequest, in TaskInput) (*mcp.CallToolResult, Pending, error) {
	list, err := t.d.Repos.List(ctx)
	if err != nil {
		return nil, Pending{}, err
	}
	var repo *admin.RepoView
	for i := range list {
		if strings.EqualFold(list[i].Name, strings.TrimSpace(in.Repository)) {
			repo = &list[i]
		}
	}
	if repo == nil {
		return nil, Pending{}, fmt.Errorf("no repository named %q", in.Repository)
	}
	if in.Priority == "" {
		in.Priority = "medium"
	}
	if in.AfterApprove == "" {
		in.AfterApprove = "pr"
	}
	if in.Start == "" {
		in.Start = "ask"
	}
	return t.prepare(ctx, "create_task", "", fmt.Sprintf("Create task in %s: %q (priority %s, after approval: %s, start: %s).",
		repo.Name, in.Title, in.Priority, in.AfterApprove, in.Start), map[string]any{
		"repo_id": repo.ID, "title": in.Title, "description": in.Description, "priority": in.Priority,
		"after_approve": in.AfterApprove, "start": in.Start,
	})
}

func (t *tools) approveTicket(ctx context.Context, _ *mcp.CallToolRequest, in KeyInput) (*mcp.CallToolResult, Pending, error) {
	tk, err := t.ticket(ctx, in.Key)
	if err != nil {
		return nil, Pending{}, err
	}
	if tk.State != domain.StateWaitingForReview {
		return nil, Pending{}, fmt.Errorf("%s is not waiting for review (it is %s)", tk.Key, tk.State)
	}
	what := fmt.Sprintf("push %s and open a pull request", tk.Branch)
	if tk.Source == domain.SourceLocal && tk.AfterApprove == "main" {
		what = "push the changes straight to the default branch"
	}
	return t.prepare(ctx, "approve_ticket", tk.Key, fmt.Sprintf("Approve %s (%s): hiro will %s.", tk.Key, tk.Title, what), nil)
}

// RejectInput rejects a ticket.
type RejectInput struct {
	Key    string `json:"key"`
	Reason string `json:"reason,omitempty"`
}

func (t *tools) rejectTicket(ctx context.Context, _ *mcp.CallToolRequest, in RejectInput) (*mcp.CallToolResult, Pending, error) {
	tk, err := t.ticket(ctx, in.Key)
	if err != nil {
		return nil, Pending{}, err
	}
	return t.prepare(ctx, "reject_ticket", tk.Key, fmt.Sprintf("Reject %s (%s) and stop all work on it.", tk.Key, tk.Title),
		map[string]any{"reason": in.Reason})
}

// ConfirmInput confirms a prepared action.
type ConfirmInput struct {
	ActionID string `json:"action_id"`
}

// Done is confirm_action's output.
type Done struct {
	Done   string       `json:"done"`
	Ticket *TicketBrief `json:"ticket,omitempty"`
}

func (t *tools) confirmAction(ctx context.Context, _ *mcp.CallToolRequest, in ConfirmInput) (*mcp.CallToolResult, Done, error) {
	a, err := t.d.Store.ConfirmPending(ctx, strings.TrimSpace(in.ActionID), domain.OriginMCP)
	if err != nil {
		return nil, Done{}, err
	}
	o := t.d.Orch
	var tk domain.Ticket
	switch a.Tool {
	case "answer_questions":
		var as []domain.Answer
		list, _ := a.Args["answers"].([]any)
		for _, x := range list {
			m, _ := x.(map[string]any)
			id, _ := m["question_id"].(float64)
			ans, _ := m["answer"].(string)
			note, _ := m["note"].(string)
			as = append(as, domain.Answer{QuestionID: int64(id), Answer: ans, Note: note})
		}
		tk, err = o.Answer(ctx, a.TicketKey, as, domain.OriginMCP)
	case "start_run":
		tk, err = o.Start(ctx, a.TicketKey, domain.OriginMCP)
	case "request_changes":
		fb, _ := a.Args["feedback"].(string)
		tk, err = o.RequestChanges(ctx, a.TicketKey, fb, domain.OriginMCP)
	case "retry_run":
		tk, err = o.Retry(ctx, a.TicketKey, domain.OriginMCP)
	case "approve_ticket":
		tk, err = o.Approve(ctx, a.TicketKey, nil, domain.OriginMCP)
	case "reject_ticket":
		reason, _ := a.Args["reason"].(string)
		tk, err = o.Reject(ctx, a.TicketKey, reason, domain.OriginMCP)
	case "create_task":
		id, _ := a.Args["repo_id"].(float64)
		str := func(k string) string { s, _ := a.Args[k].(string); return s }
		tk, err = o.CreateTask(ctx, orchestrator.TaskInput{RepoID: int64(id), Title: str("title"), Description: str("description"),
			Priority: str("priority"), AfterApprove: str("after_approve"), Start: str("start")}, domain.OriginMCP)
	default:
		return nil, Done{}, fmt.Errorf("unknown action %q", a.Tool)
	}
	if err != nil {
		var te *domain.TransitionError
		if errors.As(err, &te) {
			return nil, Done{}, fmt.Errorf("not possible now: %s is %s", te.Key, te.From)
		}
		return nil, Done{}, err
	}
	rows, err := o.Rows(ctx, []domain.Ticket{tk})
	out := Done{Done: a.Summary}
	if err == nil && len(rows) == 1 {
		b := brief(rows[0])
		out.Ticket = &b
	}
	return nil, out, nil
}

func notFound(err error, key string) error {
	if errors.Is(err, domain.ErrNotFound) {
		return fmt.Errorf("no ticket %q", key)
	}
	return err
}
