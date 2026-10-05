package orchestrator

import (
	"context"
	"errors"
	"fmt"
	"slices"
	"strings"
	"time"

	"hiro/internal/domain"
)

// ErrInvalid wraps input errors the caller should show to the user.
var ErrInvalid = errors.New("invalid input")

func invalid(format string, a ...any) error {
	return fmt.Errorf("%w: %s", ErrInvalid, fmt.Sprintf(format, a...))
}

// Incoming is a ticket as reported by a tracker.
type Incoming struct {
	Key         string
	Project     string
	Title       string
	Description string
	Priority    string
}

// Ingest records a ticket from the tracker. New tickets are queued for
// analysis; known tickets get their text refreshed while hiro has not
// started coding them. It reports whether the ticket was created.
func (o *Orchestrator) Ingest(ctx context.Context, in Incoming, origin domain.Origin) (bool, error) {
	if in.Key == "" || in.Title == "" {
		return false, invalid("ticket key and title are required")
	}
	st, err := o.settings.Get(ctx)
	if err != nil {
		return false, err
	}
	t := domain.Ticket{
		Key: in.Key, Source: domain.SourceJira, Title: in.Title, Description: in.Description,
		Priority: strings.ToLower(in.Priority), State: domain.StateNew, ResumeState: domain.StateNew,
		AfterApprove: "pr", AskFirst: st.AskFirst,
	}
	if t.Priority == "" {
		t.Priority = "medium"
	}
	archived := false
	if repo, err := o.store.RepositoryByJiraProject(ctx, in.Project); err == nil {
		t.RepoID = &repo.ID
		archived = repo.ArchivedAt != nil
	} else if !errors.Is(err, domain.ErrNotFound) {
		return false, err
	}

	// An archived repository takes no new tickets; known ones still refresh.
	if !archived {
		_, err = o.store.CreateTicket(ctx, t, domain.Event{
			TicketKey: in.Key, Type: domain.EventTicketCreated, Origin: origin, Message: in.Title,
		})
		if err == nil {
			o.Wake()
			return true, nil
		}
		if !errors.Is(err, domain.ErrConflict) {
			return false, err
		}
	}

	// Known ticket: refresh text only before coding starts, so the
	// description Claude worked from matches what the reviewer sees.
	_, err = o.store.UpdateTicket(ctx, in.Key, &domain.Event{
		TicketKey: in.Key, Type: domain.EventTicketUpdated, Origin: origin, Message: "ticket text updated in Jira",
	}, func(x *domain.Ticket) {
		if x.State == domain.StateNew || x.State == domain.StateWaitingForAnswers {
			x.Title, x.Description = in.Title, in.Description
		}
		if x.RepoID == nil {
			x.RepoID = t.RepoID
		}
	})
	if archived && errors.Is(err, domain.ErrNotFound) {
		return false, nil
	}
	return false, err
}

// Answer saves answers to the ticket's questions and, once all are
// answered, starts coding.
func (o *Orchestrator) Answer(ctx context.Context, key string, answers []domain.Answer, origin domain.Origin) (domain.Ticket, error) {
	t, err := o.store.TicketByKey(ctx, key)
	if err != nil {
		return t, err
	}
	if t.State != domain.StateWaitingForAnswers {
		return t, &domain.TransitionError{Key: key, From: t.State, To: domain.StateCoding}
	}
	qs, err := o.store.Questions(ctx, t.ID)
	if err != nil {
		return t, err
	}
	byID := map[int64]domain.Answer{}
	for _, a := range answers {
		if strings.TrimSpace(a.Answer) == "" {
			return t, invalid("answer for question %d is empty", a.QuestionID)
		}
		byID[a.QuestionID] = a
	}
	for _, q := range qs {
		if _, ok := byID[q.ID]; !ok && q.Answer == nil {
			return t, invalid("question %d (%q) is not answered", q.Position, q.Text)
		}
	}
	for id := range byID {
		if !hasQuestion(qs, id) {
			return t, invalid("question %d does not belong to %s", id, key)
		}
	}
	if err := o.store.SaveAnswers(ctx, t.ID, answers); err != nil {
		return t, err
	}
	t, err = o.store.Transition(ctx, key, domain.StateCoding, domain.Event{
		TicketKey: key, Type: domain.EventAnswered, Origin: origin, Message: fmt.Sprintf("%d answers, starting to code", len(answers)),
	}, nil)
	if err == nil {
		o.Wake()
	}
	return t, err
}

// AnswerOne answers a single question (Telegram asks them one by one) and
// starts coding once every question has an answer. It reports whether
// coding started.
func (o *Orchestrator) AnswerOne(ctx context.Context, key string, a domain.Answer, origin domain.Origin) (bool, error) {
	t, err := o.store.TicketByKey(ctx, key)
	if err != nil {
		return false, err
	}
	if t.State != domain.StateWaitingForAnswers {
		return false, &domain.TransitionError{Key: key, From: t.State, To: domain.StateCoding}
	}
	qs, err := o.store.Questions(ctx, t.ID)
	if err != nil {
		return false, err
	}
	if !hasQuestion(qs, a.QuestionID) {
		return false, invalid("question %d does not belong to %s", a.QuestionID, key)
	}
	if strings.TrimSpace(a.Answer) == "" {
		return false, invalid("the answer is empty")
	}
	if err := o.store.SaveAnswers(ctx, t.ID, []domain.Answer{a}); err != nil {
		return false, err
	}
	for _, q := range qs {
		if q.ID != a.QuestionID && q.Answer == nil {
			o.event(ctx, domain.Event{TicketKey: key, Type: domain.EventAnswered, Origin: origin, Message: "answered: " + truncate(a.Answer, 200)})
			return false, nil
		}
	}
	_, err = o.store.Transition(ctx, key, domain.StateCoding, domain.Event{
		TicketKey: key, Type: domain.EventAnswered, Origin: origin, Message: "all questions answered, starting to code",
	}, nil)
	if err != nil {
		return false, err
	}
	o.Wake()
	return true, nil
}

func hasQuestion(qs []domain.Question, id int64) bool {
	for _, q := range qs {
		if q.ID == id {
			return true
		}
	}
	return false
}

// MaxAssignees caps how many people a pull request can be assigned to.
const MaxAssignees = 10

// Approve lets hiro push the reviewed branch and open the pull request,
// assigned to the given git host usernames (none keeps it unassigned).
func (o *Orchestrator) Approve(ctx context.Context, key string, assignees []string, origin domain.Origin) (domain.Ticket, error) {
	clean := make([]string, 0, len(assignees))
	for _, a := range assignees {
		a = strings.TrimSpace(a)
		if a == "" || slices.Contains(clean, a) {
			continue
		}
		if len(a) > 100 || strings.ContainsAny(a, " \t\n/") {
			return domain.Ticket{}, invalid("%q is not a username", a)
		}
		clean = append(clean, a)
	}
	if len(clean) > MaxAssignees {
		return domain.Ticket{}, invalid("a pull request can have at most %d assignees", MaxAssignees)
	}
	msg := "approved"
	if len(clean) > 0 {
		msg += ", assigned to " + strings.Join(clean, ", ")
	}
	t, err := o.store.Transition(ctx, key, domain.StatePushing, domain.Event{
		TicketKey: key, Type: domain.EventStateChanged, Origin: origin, Message: msg,
	}, func(x *domain.Ticket) { x.Assignees = clean })
	if err == nil {
		o.Wake()
	}
	return t, err
}

// RequestChanges sends the ticket back to coding with reviewer feedback.
func (o *Orchestrator) RequestChanges(ctx context.Context, key, feedback string, origin domain.Origin) (domain.Ticket, error) {
	feedback = strings.TrimSpace(feedback)
	if feedback == "" {
		return domain.Ticket{}, invalid("feedback is required")
	}
	t, err := o.store.Transition(ctx, key, domain.StateCoding, domain.Event{
		TicketKey: key, Type: domain.EventFeedback, Origin: origin, Message: feedback,
	}, func(x *domain.Ticket) {
		x.Revision++
		x.Feedback = feedback
	})
	if err == nil {
		o.Wake()
	}
	return t, err
}

// Reject stops work on a ticket for good, cancelling a running stage.
func (o *Orchestrator) Reject(ctx context.Context, key, reason string, origin domain.Origin) (domain.Ticket, error) {
	msg := "rejected"
	if r := strings.TrimSpace(reason); r != "" {
		msg += ": " + r
	}
	t, err := o.store.Transition(ctx, key, domain.StateRejected, domain.Event{
		TicketKey: key, Type: domain.EventStateChanged, Origin: origin, Message: msg,
	}, nil)
	if err != nil {
		return t, err
	}
	o.cancelRun(key)
	o.trackerMove(context.WithoutCancel(ctx), t, TrackerRejected)
	return t, nil
}

func (o *Orchestrator) cancelRun(key string) bool {
	o.mu.Lock()
	cancel := o.cancels[key]
	o.mu.Unlock()
	if cancel != nil {
		cancel()
	}
	return cancel != nil
}

// Stop ends the running stage; the ticket goes to failed and can be retried.
func (o *Orchestrator) Stop(ctx context.Context, key string, origin domain.Origin) (domain.Ticket, error) {
	t, err := o.store.TicketByKey(ctx, key)
	if err != nil {
		return t, err
	}
	resume := map[domain.TicketState]domain.TicketState{
		domain.StateAnalyzing: domain.StateNew, domain.StateCoding: domain.StateCoding, domain.StateTesting: domain.StateCoding,
	}[t.State]
	if resume == "" {
		return t, &domain.TransitionError{Key: key, From: t.State, To: domain.StateFailed}
	}
	t, err = o.store.Transition(ctx, key, domain.StateFailed, domain.Event{
		TicketKey: key, Type: domain.EventStateChanged, Origin: origin, Level: domain.LevelWarn, Message: "stopped by you",
	}, func(x *domain.Ticket) { x.ResumeState = resume })
	if err != nil {
		return t, err
	}
	o.cancelRun(key)
	return t, nil
}

// Start releases a held ticket into the queue.
func (o *Orchestrator) Start(ctx context.Context, key string, origin domain.Origin) (domain.Ticket, error) {
	t, err := o.store.TicketByKey(ctx, key)
	if err != nil {
		return t, err
	}
	if t.State != domain.StateNew || !t.Held {
		return t, &domain.TransitionError{Key: key, From: t.State, To: domain.StateAnalyzing}
	}
	t, err = o.store.UpdateTicket(ctx, key, &domain.Event{
		TicketKey: key, Type: domain.EventTicketUpdated, Origin: origin, Message: "started",
	}, func(x *domain.Ticket) { x.Held = false })
	if err == nil {
		o.Wake()
	}
	return t, err
}

// SetModels overrides models for one ticket; an empty value means default.
func (o *Orchestrator) SetModels(ctx context.Context, key string, models map[string]string, origin domain.Origin) (domain.Ticket, error) {
	clean := map[string]string{}
	for stage, m := range models {
		if stage != domain.ModelAnalyze && stage != domain.ModelCoding && stage != domain.ModelRetry {
			return domain.Ticket{}, invalid("unknown stage %q", stage)
		}
		if m == "" || m == "default" {
			continue
		}
		if !slices.Contains(domain.Models, m) {
			return domain.Ticket{}, invalid("unknown model %q", m)
		}
		clean[stage] = m
	}
	return o.store.UpdateTicket(ctx, key, &domain.Event{
		TicketKey: key, Type: domain.EventTicketUpdated, Origin: origin, Message: "models changed",
		Data: map[string]any{"models": clean},
	}, func(x *domain.Ticket) { x.Models = clean })
}

// SetRepo links a ticket to another repository. It is allowed while no
// stage runs and nothing was pushed: on a new ticket, or a failed or
// rate-limited one. Analysis and the branch belong to the old repository,
// so a stopped ticket starts over from analysis on Retry.
func (o *Orchestrator) SetRepo(ctx context.Context, key string, repoID int64, origin domain.Origin) (domain.Ticket, error) {
	repo, err := o.store.RepositoryByID(ctx, repoID)
	if errors.Is(err, domain.ErrNotFound) {
		return domain.Ticket{}, invalid("no repository %d", repoID)
	}
	if err != nil {
		return domain.Ticket{}, err
	}
	if repo.ArchivedAt != nil {
		return domain.Ticket{}, invalid("%s is archived: restore it on the Repositories page first", repo.Name)
	}
	var bad error
	t, err := o.store.UpdateTicket(ctx, key, &domain.Event{
		TicketKey: key, Type: domain.EventTicketUpdated, Origin: origin, Message: "repository set to " + repo.Name,
		Data: map[string]any{"repoId": repo.ID},
	}, func(x *domain.Ticket) {
		stopped := x.State == domain.StateFailed || x.State == domain.StateRateLimited
		if (x.State != domain.StateNew && !stopped) || x.PRURL != "" || x.ResumeState == domain.StatePushing {
			bad = &domain.TransitionError{Key: key, From: x.State, To: x.State}
			return
		}
		x.RepoID = &repo.ID
		if stopped {
			x.ResumeState = domain.StateNew
			x.Branch, x.HeadSHA, x.Feedback = "", "", ""
		}
	})
	if bad != nil {
		return t, bad
	}
	return t, err
}

// TaskInput creates or edits a side-project task.
type TaskInput struct {
	RepoID       int64
	Title        string
	Description  string
	Priority     string
	AfterApprove string // pr or main
	Start        string // ask, code or queue
}

// CreateTask adds a side-project task. Its key comes from the
// repository's task prefix (VIS-1, VIS-2, ...).
func (o *Orchestrator) CreateTask(ctx context.Context, in TaskInput, origin domain.Origin) (domain.Ticket, error) {
	if strings.TrimSpace(in.Title) == "" {
		return domain.Ticket{}, invalid("title is required")
	}
	if !slices.Contains([]string{"low", "medium", "high"}, in.Priority) {
		return domain.Ticket{}, invalid("priority must be low, medium or high")
	}
	if in.AfterApprove != "pr" && in.AfterApprove != "main" {
		return domain.Ticket{}, invalid("afterApprove must be pr or main")
	}
	if !slices.Contains([]string{"ask", "code", "queue"}, in.Start) {
		return domain.Ticket{}, invalid("start must be ask, code or queue")
	}
	repo, err := o.store.RepositoryByID(ctx, in.RepoID)
	if errors.Is(err, domain.ErrNotFound) {
		return domain.Ticket{}, invalid("no repository %d", in.RepoID)
	}
	if err != nil {
		return domain.Ticket{}, err
	}
	if repo.ArchivedAt != nil {
		return domain.Ticket{}, invalid("%s is archived: restore it on the Repositories page to add tasks", repo.Name)
	}
	st, err := o.settings.Get(ctx)
	if err != nil {
		return domain.Ticket{}, err
	}
	n, err := o.store.NextTaskNumber(ctx, repo.ID)
	if err != nil {
		return domain.Ticket{}, err
	}
	t, err := o.store.CreateTicket(ctx, domain.Ticket{
		Key: fmt.Sprintf("%s-%d", TaskPrefix(repo), n), Source: domain.SourceLocal, RepoID: &repo.ID,
		Title: strings.TrimSpace(in.Title), Description: strings.TrimSpace(in.Description), Priority: in.Priority,
		State: domain.StateNew, ResumeState: domain.StateNew, AfterApprove: in.AfterApprove,
		Held: in.Start == "queue", AskFirst: in.Start == "ask" || (in.Start == "queue" && st.AskFirst),
	}, domain.Event{Type: domain.EventTicketCreated, Origin: origin, Message: strings.TrimSpace(in.Title)})
	if err == nil && !t.Held {
		o.Wake()
	}
	return t, err
}

// TaskPrefix is a repository's task key prefix, derived from its name
// when not set.
func TaskPrefix(r domain.Repository) string {
	if p := strings.ToUpper(strings.TrimSpace(r.TaskPrefix)); p != "" {
		return p
	}
	var b strings.Builder
	for _, c := range strings.ToUpper(r.Name) {
		if c >= 'A' && c <= 'Z' && b.Len() < 4 {
			b.WriteRune(c)
		}
	}
	if b.Len() == 0 {
		return "TASK"
	}
	return b.String()
}

// UpdateTask edits a task that has not started yet.
func (o *Orchestrator) UpdateTask(ctx context.Context, key string, in TaskInput, origin domain.Origin) (domain.Ticket, error) {
	var bad error
	t, err := o.store.UpdateTicket(ctx, key, &domain.Event{
		TicketKey: key, Type: domain.EventTaskChanged, Origin: origin, Message: "task edited",
	}, func(x *domain.Ticket) {
		if x.Source != domain.SourceLocal || x.State != domain.StateNew {
			bad = &domain.TransitionError{Key: key, From: x.State, To: domain.StateNew}
			return
		}
		if v := strings.TrimSpace(in.Title); v != "" {
			x.Title = v
		}
		if in.Description != "" {
			x.Description = strings.TrimSpace(in.Description)
		}
		if slices.Contains([]string{"low", "medium", "high"}, in.Priority) {
			x.Priority = in.Priority
		}
		if in.AfterApprove == "pr" || in.AfterApprove == "main" {
			x.AfterApprove = in.AfterApprove
		}
	})
	if bad != nil {
		return t, bad
	}
	return t, err
}

// DeleteTask removes a task that has not started yet.
func (o *Orchestrator) DeleteTask(ctx context.Context, key string, origin domain.Origin) error {
	t, err := o.store.TicketByKey(ctx, key)
	if err != nil {
		return err
	}
	if t.Source != domain.SourceLocal || t.State != domain.StateNew || (!t.Held && o.cancelRunning(key)) {
		return &domain.TransitionError{Key: key, From: t.State, To: domain.StateRejected}
	}
	return o.store.DeleteTicket(ctx, key, domain.Event{TicketKey: key, Type: domain.EventTaskChanged, Origin: origin, Message: "task deleted"})
}

func (o *Orchestrator) cancelRunning(key string) bool {
	o.mu.Lock()
	defer o.mu.Unlock()
	_, ok := o.cancels[key]
	return ok
}

// AutoResume sends rate-limited tickets back to work once usage allows it.
func (o *Orchestrator) AutoResume(ctx context.Context, s domain.Settings) {
	if !s.AutoResume || ctx.Err() != nil {
		return
	}
	if paused, _ := o.usage.Paused(ctx, s); paused {
		return
	}
	ts, err := o.store.ListTickets(ctx, TicketFilter{States: []domain.TicketState{domain.StateRateLimited}})
	if err != nil {
		o.log.Warn("auto-resume", "err", err)
		return
	}
	for _, t := range ts {
		if _, err := o.Retry(ctx, t.Key, domain.OriginSystem); err != nil {
			o.log.Warn("auto-resume", "ticket", t.Key, "err", err)
		}
	}
}

// Retry resumes a failed or rate-limited ticket where it stopped.
func (o *Orchestrator) Retry(ctx context.Context, key string, origin domain.Origin) (domain.Ticket, error) {
	t, err := o.store.TicketByKey(ctx, key)
	if err != nil {
		return t, err
	}
	if t.State != domain.StateFailed && t.State != domain.StateRateLimited {
		return t, &domain.TransitionError{Key: key, From: t.State, To: t.ResumeState}
	}
	to := t.ResumeState
	if !to.Valid() {
		to = domain.StateNew
	}
	t, err = o.store.Transition(ctx, key, to, domain.Event{
		TicketKey: key, Type: domain.EventStateChanged, Origin: origin, Message: "retry",
	}, nil)
	if err == nil {
		o.Wake()
	}
	return t, err
}

// TicketView is everything the ticket page shows.
type TicketView struct {
	Ticket    domain.Ticket
	Info      StateInfo
	RepoName  string
	Questions []domain.Question
	Analysis  *Analysis
	Result    *domain.Result
	History   []HistoryItem
	Settings  domain.Settings
}

// TicketRow is a ticket for lists, with when it entered its state.
type TicketRow struct {
	Ticket   domain.Ticket
	Info     StateInfo
	RepoName string
}

// Rows decorates tickets for lists.
func (o *Orchestrator) Rows(ctx context.Context, ts []domain.Ticket) ([]TicketRow, error) {
	keys := make([]string, len(ts))
	for i, t := range ts {
		keys[i] = t.Key
	}
	info, err := o.store.StateSince(ctx, keys)
	if err != nil {
		return nil, err
	}
	names := map[int64]string{}
	out := make([]TicketRow, len(ts))
	for i, t := range ts {
		out[i] = TicketRow{Ticket: t, Info: info[t.Key]}
		if t.RepoID != nil {
			if n, ok := names[*t.RepoID]; ok {
				out[i].RepoName = n
			} else if r, err := o.store.RepositoryByID(ctx, *t.RepoID); err == nil {
				names[*t.RepoID] = r.Name
				out[i].RepoName = r.Name
			}
		}
	}
	return out, nil
}

// View loads a ticket with its questions, analysis and latest result.
func (o *Orchestrator) View(ctx context.Context, key string) (TicketView, error) {
	t, err := o.store.TicketByKey(ctx, key)
	if err != nil {
		return TicketView{}, err
	}
	v := TicketView{Ticket: t}
	rows, err := o.Rows(ctx, []domain.Ticket{t})
	if err != nil {
		return v, err
	}
	v.Info, v.RepoName = rows[0].Info, rows[0].RepoName
	if v.Settings, err = o.settings.Get(ctx); err != nil {
		return v, err
	}
	if v.History, err = o.store.History(ctx, key); err != nil {
		return v, err
	}
	if v.Questions, err = o.store.Questions(ctx, t.ID); err != nil {
		return v, err
	}
	if r, err := o.store.LatestResult(ctx, t.ID, domain.StageAnalyze); err == nil {
		if a, err := parseAnalysis(r.Summary); err == nil {
			v.Analysis = &a
		}
	} else if !errors.Is(err, domain.ErrNotFound) {
		return v, err
	}
	if r, err := o.store.LatestResult(ctx, t.ID, domain.StageCode); err == nil {
		v.Result = &r
	} else if !errors.Is(err, domain.ErrNotFound) {
		return v, err
	}
	return v, nil
}

// List returns tickets, newest activity first.
func (o *Orchestrator) List(ctx context.Context, f TicketFilter) ([]domain.Ticket, error) {
	return o.store.ListTickets(ctx, f)
}

// Events returns a ticket's events after a cursor (for the live log).
func (o *Orchestrator) Events(ctx context.Context, f EventFilter) ([]domain.Event, error) {
	return o.store.Events(ctx, f)
}

// MarkMerged records that a ticket's pull request was merged (from a git
// host webhook) and moves the tracker issue to the "merged" status.
func (o *Orchestrator) MarkMerged(ctx context.Context, prURL, branch string, origin domain.Origin) (bool, error) {
	t, err := o.store.TicketByPR(ctx, prURL, branch)
	if errors.Is(err, domain.ErrNotFound) {
		return false, nil // not one of hiro's
	}
	if err != nil {
		return false, err
	}
	if t.MergedAt != nil {
		return false, nil
	}
	now := time.Now()
	if _, err := o.store.UpdateTicket(ctx, t.Key, &domain.Event{
		TicketKey: t.Key, Type: domain.EventMerged, Origin: origin, Message: "pull request merged", Data: map[string]any{"url": prURL},
	}, func(x *domain.Ticket) { x.MergedAt = &now }); err != nil {
		return false, err
	}
	o.trackerComment(ctx, t, CommentStatus, "The pull request was merged.")
	o.trackerMove(ctx, t, TrackerMerged)
	return true, nil
}
