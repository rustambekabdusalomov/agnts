// Package actions holds agnts's two-step writes: Prepare checks what a
// caller asks for and says what it would do, and Execute does it once a
// person agreed. The MCP server and the assistant both use them, so a write
// is checked and summed up the same way wherever it is asked for.
package actions

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"strings"

	"agnts/internal/admin"
	"agnts/internal/domain"
	"agnts/internal/orchestrator"
	"agnts/internal/store/postgres"
)

// Deps are the use cases the actions call.
type Deps struct {
	Orch  *orchestrator.Orchestrator
	Store *postgres.Agent
	Repos *admin.Repos
}

// The write tools.
const (
	AnswerQuestions = "answer_questions"
	StartRun        = "start_run"
	RequestChanges  = "request_changes"
	RetryRun        = "retry_run"
	CreateTask      = "create_task"
	ImplementTicket = "implement_ticket"
	AcceptFollowUps = "accept_follow_ups"
	DismissFollowUp = "dismiss_follow_up"
	SetTicketKind   = "set_ticket_kind"
	ApproveTicket   = "approve_ticket"
	RejectTicket    = "reject_ticket"
)

// Destructive reports whether tool cannot be taken back (it pushes or stops
// work): callers ask once more before it.
func Destructive(tool string) bool { return domain.DestructiveAction(tool) }

// Prepared is a checked write: what to store until it is confirmed, and the
// summary to show the person.
type Prepared struct {
	Tool      string
	TicketKey string
	Summary   string
	Args      map[string]any
}

// Prepare checks a write given as its tool's name and JSON input.
func (d Deps) Prepare(ctx context.Context, tool string, args json.RawMessage) (Prepared, error) {
	if len(args) == 0 {
		args = json.RawMessage("{}")
	}
	switch tool {
	case AnswerQuestions:
		return prepareAs(ctx, args, d.AnswerQuestions)
	case StartRun:
		return prepareAs(ctx, args, d.StartRun)
	case RequestChanges:
		return prepareAs(ctx, args, d.RequestChanges)
	case RetryRun:
		return prepareAs(ctx, args, d.RetryRun)
	case CreateTask:
		return prepareAs(ctx, args, d.CreateTask)
	case ImplementTicket:
		return prepareAs(ctx, args, d.ImplementTicket)
	case AcceptFollowUps:
		return prepareAs(ctx, args, d.AcceptFollowUps)
	case DismissFollowUp:
		return prepareAs(ctx, args, d.DismissFollowUp)
	case SetTicketKind:
		return prepareAs(ctx, args, d.SetKind)
	case ApproveTicket:
		return prepareAs(ctx, args, d.ApproveTicket)
	case RejectTicket:
		return prepareAs(ctx, args, d.RejectTicket)
	}
	return Prepared{}, fmt.Errorf("unknown action %q", tool)
}

func prepareAs[In any](ctx context.Context, args json.RawMessage, f func(context.Context, In) (Prepared, error)) (Prepared, error) {
	var in In
	if err := json.Unmarshal(args, &in); err != nil {
		return Prepared{}, fmt.Errorf("the action's input is not valid: %w", err)
	}
	return f(ctx, in)
}

func prepared(tool, key, summary string, args map[string]any) (Prepared, error) {
	if args == nil {
		args = map[string]any{}
	}
	return Prepared{Tool: tool, TicketKey: key, Summary: summary, Args: args}, nil
}

func (d Deps) ticket(ctx context.Context, key string) (domain.Ticket, error) {
	tk, err := d.Store.TicketByKey(ctx, strings.TrimSpace(key))
	return tk, NotFound(err, key)
}

// NotFound turns a missing ticket into an error that names it.
func NotFound(err error, key string) error {
	if errors.Is(err, domain.ErrNotFound) {
		return fmt.Errorf("no ticket %q", key)
	}
	return err
}

// KeyInput names a ticket.
type KeyInput struct {
	Key string `json:"key" jsonschema:"ticket or task key, e.g. PAY-214"`
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

// AnswerQuestions prepares answering a ticket's questions.
func (d Deps) AnswerQuestions(ctx context.Context, in AnswersInput) (Prepared, error) {
	tk, err := d.ticket(ctx, in.Key)
	if err != nil {
		return Prepared{}, err
	}
	if tk.State != domain.StateWaitingForAnswers {
		return Prepared{}, fmt.Errorf("%s is not waiting for answers (it is %s)", tk.Key, tk.State)
	}
	qs, err := d.Store.Questions(ctx, tk.ID)
	if err != nil {
		return Prepared{}, err
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
			return Prepared{}, fmt.Errorf("question %d is not on %s", a.QuestionID, tk.Key)
		}
		lines = append(lines, fmt.Sprintf("- %s → %s", q, a.Answer))
		args = append(args, map[string]any{"question_id": a.QuestionID, "answer": a.Answer, "note": a.Note})
	}
	return prepared(AnswerQuestions, tk.Key, fmt.Sprintf("Answer %d question(s) on %s and start coding:\n%s", len(in.Answers), tk.Key, strings.Join(lines, "\n")),
		map[string]any{"answers": args})
}

// StartRun prepares starting a queued ticket.
func (d Deps) StartRun(ctx context.Context, in KeyInput) (Prepared, error) {
	tk, err := d.ticket(ctx, in.Key)
	if err != nil {
		return Prepared{}, err
	}
	return prepared(StartRun, tk.Key, fmt.Sprintf("Start %s (%s) now.", tk.Key, tk.Title), nil)
}

// FeedbackInput requests changes.
type FeedbackInput struct {
	Key      string `json:"key"`
	Feedback string `json:"feedback"`
}

// RequestChanges prepares sending a ticket back to coding.
func (d Deps) RequestChanges(ctx context.Context, in FeedbackInput) (Prepared, error) {
	tk, err := d.ticket(ctx, in.Key)
	if err != nil {
		return Prepared{}, err
	}
	if strings.TrimSpace(in.Feedback) == "" {
		return Prepared{}, errors.New("feedback is required")
	}
	return prepared(RequestChanges, tk.Key, fmt.Sprintf("Send %s back to coding with this feedback:\n%s", tk.Key, in.Feedback),
		map[string]any{"feedback": in.Feedback})
}

// RetryRun prepares retrying a stopped ticket.
func (d Deps) RetryRun(ctx context.Context, in KeyInput) (Prepared, error) {
	tk, err := d.ticket(ctx, in.Key)
	if err != nil {
		return Prepared{}, err
	}
	return prepared(RetryRun, tk.Key, fmt.Sprintf("Retry %s (%s) from where it stopped.", tk.Key, tk.Title), nil)
}

// TaskInput creates a task.
type TaskInput struct {
	Kind         string   `json:"kind,omitempty" jsonschema:"auto, code, test, plan, analysis or bug (default auto)"`
	Repository   string   `json:"repository,omitempty" jsonschema:"repository name; omit for a plan, analysis or bug task without one"`
	Repositories []string `json:"repositories,omitempty" jsonschema:"several repository names instead of repository: the task changes them together; the first is the primary"`
	Group        string   `json:"group,omitempty" jsonschema:"a repository group's name instead of repository: the task works in its repositories"`
	Title        string   `json:"title"`
	Description  string   `json:"description,omitempty"`
	Priority     string   `json:"priority,omitempty" jsonschema:"low, medium or high (default medium)"`
	AfterApprove string   `json:"after_approve,omitempty" jsonschema:"pr or main (default pr)"`
	Start        string   `json:"start,omitempty" jsonschema:"ask, code or queue (default ask)"`
}

// CreateTask prepares a new task.
func (d Deps) CreateTask(ctx context.Context, in TaskInput) (Prepared, error) {
	if in.Kind == "" {
		in.Kind = "auto"
	}
	kind := domain.TicketKind(in.Kind)
	if in.Kind != "auto" && !kind.Valid() {
		return Prepared{}, fmt.Errorf("kind must be auto, code, test, plan, analysis or bug")
	}
	pick, err := d.pickRepos(ctx, in.Repository, in.Repositories, in.Group)
	if err != nil {
		return Prepared{}, err
	}
	where := pick.where
	if pick.empty() && in.Kind != "auto" && kind.Spec().NeedsRepo {
		return Prepared{}, fmt.Errorf("a %s task needs a repository", kind)
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
	after := ", after approval: " + in.AfterApprove
	if in.Kind != "auto" && kind.Report() {
		after = ""
	}
	return prepared(CreateTask, "", fmt.Sprintf("Create a %s task %s: %q (priority %s%s, start: %s).",
		in.Kind, where, in.Title, in.Priority, after, in.Start), map[string]any{
		"repo_ids": pick.ids, "group_id": pick.group, "kind": in.Kind, "title": in.Title, "description": in.Description, "priority": in.Priority,
		"after_approve": in.AfterApprove, "start": in.Start,
	})
}

// repoPick is the repositories a write names: their ids (or a group's),
// and how to say where in the summary.
type repoPick struct {
	ids   []int64
	group int64
	where string
}

func (p repoPick) empty() bool { return len(p.ids) == 0 && p.group == 0 }

// pickRepos resolves a repository name, several, or a group name.
func (d Deps) pickRepos(ctx context.Context, one string, several []string, group string) (repoPick, error) {
	out := repoPick{where: "without a repository"}
	names := several
	if strings.TrimSpace(one) != "" {
		names = append([]string{one}, names...)
	}
	if strings.TrimSpace(group) != "" {
		if len(names) > 0 {
			return out, errors.New("give repositories or a group, not both")
		}
		g, err := d.Store.GroupByName(ctx, strings.TrimSpace(group))
		if err != nil {
			return out, fmt.Errorf("no repository group named %q", group)
		}
		var ns []string
		for _, m := range g.Members {
			ns = append(ns, m.RepoName)
		}
		out.group, out.where = g.ID, "in the group "+g.Name+" ("+strings.Join(ns, ", ")+")"
		return out, nil
	}
	if len(names) == 0 {
		return out, nil
	}
	list, err := d.Repos.List(ctx)
	if err != nil {
		return out, err
	}
	var found []string
	for _, n := range names {
		n = strings.TrimSpace(n)
		var id int64
		for _, r := range list {
			if strings.EqualFold(r.Name, n) {
				id, n = r.ID, r.Name
			}
		}
		if id == 0 {
			return out, fmt.Errorf("no repository named %q", n)
		}
		out.ids = append(out.ids, id)
		found = append(found, n)
	}
	out.where = "in " + strings.Join(found, " and ")
	return out, nil
}

// ImplementInput makes the code task for a report.
type ImplementInput struct {
	Key          string   `json:"key" jsonschema:"the done plan or bug investigation"`
	Repository   string   `json:"repository,omitempty" jsonschema:"repository to implement it in; defaults to the report's repositories"`
	Repositories []string `json:"repositories,omitempty" jsonschema:"several repositories instead of repository"`
	Group        string   `json:"group,omitempty" jsonschema:"a repository group instead of repository"`
	Queue        bool     `json:"queue,omitempty" jsonschema:"keep the task in the queue instead of starting it"`
}

// ImplementTicket prepares the code task that carries out a done report.
func (d Deps) ImplementTicket(ctx context.Context, in ImplementInput) (Prepared, error) {
	tk, err := d.ticket(ctx, in.Key)
	if err != nil {
		return Prepared{}, err
	}
	if !tk.Kind.Spec().Implementable {
		return Prepared{}, fmt.Errorf("only a plan or a bug investigation can be implemented; %s is %s", tk.Key, tk.Kind)
	}
	if tk.State != domain.StateDone {
		return Prepared{}, fmt.Errorf("%s is not done yet (it is %s): approve the report first", tk.Key, tk.State)
	}
	pick, err := d.pickRepos(ctx, in.Repository, in.Repositories, in.Group)
	if err != nil {
		return Prepared{}, err
	}
	where := strings.TrimPrefix(pick.where, "in ")
	if pick.empty() {
		where = "its repositories"
		if tk.RepoID == nil {
			return Prepared{}, fmt.Errorf("%s has no repository: name the one to implement it in", tk.Key)
		}
	}
	start, when := "code", "start it now"
	if in.Queue {
		start, when = "queue", "keep it in the queue"
	}
	return prepared(ImplementTicket, tk.Key, fmt.Sprintf("Create a code task in %s that carries out the %s on %s (%s), and %s.", where, tk.Kind, tk.Key, tk.Title, when),
		map[string]any{"repo_ids": pick.ids, "group_id": pick.group, "start": start})
}

// FollowUpChoice is one suggestion to create.
type FollowUpChoice struct {
	ID     int64  `json:"id"`
	Target string `json:"target,omitempty" jsonschema:"local (an agnts task, default), jira (a new Jira issue) or plane (a new Plane work item); ask the user"`
	Title  string `json:"title,omitempty" jsonschema:"a new title, if the user wants one"`
	Kind   string `json:"kind,omitempty" jsonschema:"code, test, plan, analysis or bug, if the user wants another kind"`
}

// AcceptFollowUpsInput creates tickets from suggestions.
type AcceptFollowUpsInput struct {
	Key   string           `json:"key" jsonschema:"the ticket that suggested them"`
	Items []FollowUpChoice `json:"items"`
}

// AcceptFollowUps prepares creating tickets from a ticket's suggestions.
func (d Deps) AcceptFollowUps(ctx context.Context, in AcceptFollowUpsInput) (Prepared, error) {
	tk, err := d.ticket(ctx, in.Key)
	if err != nil {
		return Prepared{}, err
	}
	if len(in.Items) == 0 {
		return Prepared{}, errors.New("pick at least one follow-up")
	}
	f, err := d.Orch.ListFollowUps(ctx, tk.Key)
	if err != nil {
		return Prepared{}, err
	}
	var lines []string
	items := make([]any, 0, len(in.Items))
	for _, c := range in.Items {
		var x *domain.Suggestion
		for i := range f.Suggestions {
			if f.Suggestions[i].ID == c.ID {
				x = &f.Suggestions[i]
			}
		}
		if x == nil {
			return Prepared{}, fmt.Errorf("%s has no follow-up %d", tk.Key, c.ID)
		}
		if !x.Ready(tk.State) {
			return Prepared{}, fmt.Errorf("follow-up %d (%s) cannot be created now: it is %s, or it waits until %s is done", c.ID, x.Title, x.Status, tk.Key)
		}
		if c.Target == "" {
			c.Target = orchestrator.TargetLocal
		}
		if c.Target != orchestrator.TargetLocal && c.Target != orchestrator.TargetJira && c.Target != orchestrator.TargetPlane {
			return Prepared{}, errors.New("target must be local, jira or plane")
		}
		if c.Kind != "" && !domain.TicketKind(c.Kind).Selectable() {
			return Prepared{}, fmt.Errorf("kind must be code, test, plan, analysis or bug")
		}
		title, kind := x.Title, string(x.Kind)
		if c.Title != "" {
			title = c.Title
		}
		if c.Kind != "" {
			kind = c.Kind
		}
		where := "a local task"
		switch c.Target {
		case orchestrator.TargetJira:
			where = "a new Jira issue"
		case orchestrator.TargetPlane:
			where = "a new Plane work item"
		}
		lines = append(lines, fmt.Sprintf("%q (%s) as %s", title, kind, where))
		items = append(items, map[string]any{"id": c.ID, "target": c.Target, "title": c.Title, "kind": c.Kind})
	}
	return prepared(AcceptFollowUps, tk.Key, fmt.Sprintf("Create %d follow-up %s of %s, queued until started: %s.",
		len(lines), plural(len(lines), "ticket", "tickets"), tk.Key, strings.Join(lines, "; ")), map[string]any{"items": items})
}

// DismissInput declines a suggestion.
type DismissInput struct {
	Key string `json:"key"`
	ID  int64  `json:"id" jsonschema:"the follow-up's id from get_ticket"`
}

// DismissFollowUp prepares declining a suggestion.
func (d Deps) DismissFollowUp(ctx context.Context, in DismissInput) (Prepared, error) {
	tk, err := d.ticket(ctx, in.Key)
	if err != nil {
		return Prepared{}, err
	}
	f, err := d.Orch.ListFollowUps(ctx, tk.Key)
	if err != nil {
		return Prepared{}, err
	}
	for _, x := range f.Suggestions {
		if x.ID == in.ID {
			if x.Status != domain.SuggestionOpen {
				return Prepared{}, fmt.Errorf("follow-up %d is already %s", in.ID, x.Status)
			}
			return prepared(DismissFollowUp, tk.Key, fmt.Sprintf("Dismiss the follow-up %q suggested by %s.", x.Title, tk.Key),
				map[string]any{"id": in.ID})
		}
	}
	return Prepared{}, fmt.Errorf("%s has no follow-up %d", tk.Key, in.ID)
}

func plural(n int, one, many string) string {
	if n == 1 {
		return one
	}
	return many
}

// KindInput changes a ticket's kind.
type KindInput struct {
	Key  string `json:"key"`
	Kind string `json:"kind" jsonschema:"auto, code, test, plan, analysis or bug"`
}

// SetKind prepares changing what a ticket produces.
func (d Deps) SetKind(ctx context.Context, in KindInput) (Prepared, error) {
	tk, err := d.ticket(ctx, in.Key)
	if err != nil {
		return Prepared{}, err
	}
	if in.Kind != "auto" && !domain.TicketKind(in.Kind).Selectable() {
		return Prepared{}, fmt.Errorf("kind must be auto, code, test, plan, analysis or bug")
	}
	what := "make " + tk.Key + " a " + in.Kind + " ticket"
	if in.Kind == "auto" {
		what = "let agnts pick the kind of " + tk.Key + " while reading it"
	}
	return prepared(SetTicketKind, tk.Key, fmt.Sprintf("Change %s (%s, now %s): %s.", tk.Key, tk.Title, tk.Kind, what),
		map[string]any{"kind": in.Kind})
}

// ApproveInput approves a ticket under review.
type ApproveInput struct {
	Key        string `json:"key"`
	PostReport bool   `json:"post_report,omitempty" jsonschema:"for a report on a Jira or Plane ticket: also post it as a comment on the issue; only when the user asks"`
}

// ApproveTicket prepares approving reviewed work.
func (d Deps) ApproveTicket(ctx context.Context, in ApproveInput) (Prepared, error) {
	tk, err := d.ticket(ctx, in.Key)
	if err != nil {
		return Prepared{}, err
	}
	if tk.State != domain.StateWaitingForReview {
		return Prepared{}, fmt.Errorf("%s is not waiting for review (it is %s)", tk.Key, tk.State)
	}
	if tk.Kind.Report() {
		if in.PostReport && !tk.Source.Tracked() {
			return Prepared{}, fmt.Errorf("%s has no tracker issue to post the report to", tk.Key)
		}
		what := "close it and keep the report in agnts"
		if in.PostReport {
			what = "close it, keep the report in agnts and post it as a comment on the " + tk.Source.Name() + " issue"
		}
		return prepared(ApproveTicket, tk.Key, fmt.Sprintf("Approve the %s report on %s (%s): agnts will %s.", tk.Kind, tk.Key, tk.Title, what),
			map[string]any{"post_report": in.PostReport})
	}
	if in.PostReport {
		return Prepared{}, fmt.Errorf("%s is a change, not a report: post_report does not apply", tk.Key)
	}
	what := fmt.Sprintf("push %s and open a pull request", tk.Branch)
	if tk.Source == domain.SourceLocal && tk.AfterApprove == "main" {
		what = "push the changes straight to the default branch"
	}
	return prepared(ApproveTicket, tk.Key, fmt.Sprintf("Approve %s (%s): agnts will %s.", tk.Key, tk.Title, what), nil)
}

// RejectInput rejects a ticket.
type RejectInput struct {
	Key    string `json:"key"`
	Reason string `json:"reason,omitempty"`
}

// RejectTicket prepares rejecting a ticket.
func (d Deps) RejectTicket(ctx context.Context, in RejectInput) (Prepared, error) {
	tk, err := d.ticket(ctx, in.Key)
	if err != nil {
		return Prepared{}, err
	}
	return prepared(RejectTicket, tk.Key, fmt.Sprintf("Reject %s (%s) and stop all work on it.", tk.Key, tk.Title),
		map[string]any{"reason": in.Reason})
}

// Result is what a confirmed action did.
type Result struct {
	Done    string          // the action's summary
	Ticket  *domain.Ticket  // the ticket it changed or made, if any
	Created []domain.Ticket // accept_follow_ups: the tickets made
	Errors  []string        // accept_follow_ups: the follow-ups that could not be made
}

// Execute does a confirmed action, as origin.
func (d Deps) Execute(ctx context.Context, a postgres.PendingAction, origin domain.Origin) (Result, error) {
	o := d.Orch
	var tk domain.Ticket
	var err error
	switch a.Tool {
	case AnswerQuestions:
		var as []domain.Answer
		list, _ := a.Args["answers"].([]any)
		for _, x := range list {
			m, _ := x.(map[string]any)
			id, _ := m["question_id"].(float64)
			ans, _ := m["answer"].(string)
			note, _ := m["note"].(string)
			as = append(as, domain.Answer{QuestionID: int64(id), Answer: ans, Note: note})
		}
		tk, err = o.Answer(ctx, a.TicketKey, as, origin)
	case StartRun:
		tk, err = o.Start(ctx, a.TicketKey, origin)
	case RequestChanges:
		fb, _ := a.Args["feedback"].(string)
		tk, err = o.RequestChanges(ctx, a.TicketKey, fb, nil, nil, origin)
	case RetryRun:
		tk, err = o.Retry(ctx, a.TicketKey, origin)
	case ApproveTicket:
		post, _ := a.Args["post_report"].(bool)
		tk, err = o.Approve(ctx, a.TicketKey, nil, post, origin)
	case ImplementTicket:
		id, _ := a.Args["repo_id"].(float64) // actions prepared before several repositories
		gid, _ := a.Args["group_id"].(float64)
		start, _ := a.Args["start"].(string)
		tk, err = o.Implement(ctx, a.TicketKey, orchestrator.ImplementInput{RepoID: int64(id), RepoIDs: idsArg(a.Args["repo_ids"]),
			GroupID: int64(gid), Start: start}, origin)
	case SetTicketKind:
		kind, _ := a.Args["kind"].(string)
		tk, err = o.SetKind(ctx, a.TicketKey, kind, origin)
	case RejectTicket:
		reason, _ := a.Args["reason"].(string)
		tk, err = o.Reject(ctx, a.TicketKey, reason, origin)
	case AcceptFollowUps:
		return d.acceptFollowUps(ctx, a, origin)
	case DismissFollowUp:
		id, _ := a.Args["id"].(float64)
		if _, err := o.DismissSuggestion(ctx, a.TicketKey, int64(id), origin); err != nil {
			return Result{}, err
		}
		return Result{Done: a.Summary}, nil
	case CreateTask:
		id, _ := a.Args["repo_id"].(float64) // actions prepared before several repositories
		gid, _ := a.Args["group_id"].(float64)
		str := func(k string) string { s, _ := a.Args[k].(string); return s }
		tk, err = o.CreateTask(ctx, orchestrator.TaskInput{RepoID: int64(id), RepoIDs: idsArg(a.Args["repo_ids"]), GroupID: int64(gid),
			Kind: str("kind"), Title: str("title"), Description: str("description"),
			Priority: str("priority"), AfterApprove: str("after_approve"), Start: str("start")}, origin)
	default:
		return Result{}, fmt.Errorf("unknown action %q", a.Tool)
	}
	if err != nil {
		var te *domain.TransitionError
		if errors.As(err, &te) {
			return Result{}, fmt.Errorf("not possible now: %s is %s", te.Key, te.From)
		}
		return Result{}, err
	}
	return Result{Done: a.Summary, Ticket: &tk}, nil
}

func (d Deps) acceptFollowUps(ctx context.Context, a postgres.PendingAction, origin domain.Origin) (Result, error) {
	var in []orchestrator.AcceptInput
	list, _ := a.Args["items"].([]any)
	for _, x := range list {
		m, _ := x.(map[string]any)
		id, _ := m["id"].(float64)
		str := func(k string) string { s, _ := m[k].(string); return s }
		in = append(in, orchestrator.AcceptInput{ID: int64(id), Target: str("target"), Title: str("title"), Kind: str("kind")})
	}
	res, err := d.Orch.AcceptSuggestions(ctx, a.TicketKey, in, origin)
	if err != nil {
		return Result{}, err
	}
	out := Result{Done: a.Summary}
	for _, r := range res {
		if r.Err != nil {
			out.Errors = append(out.Errors, fmt.Sprintf("follow-up %d: %v", r.ID, r.Err))
			continue
		}
		out.Created = append(out.Created, *r.Ticket)
	}
	return out, nil
}

// idsArg reads a list of ids from a pending action's arguments.
func idsArg(v any) []int64 {
	list, _ := v.([]any)
	var out []int64
	for _, x := range list {
		if f, ok := x.(float64); ok {
			out = append(out, int64(f))
		}
	}
	return out
}
