package orchestrator

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"slices"
	"strings"

	"agnts/internal/domain"
)

// ErrInvalid wraps input errors the caller should show to the user.
var ErrInvalid = errors.New("invalid input")

func invalid(format string, a ...any) error {
	return fmt.Errorf("%w: %s", ErrInvalid, fmt.Sprintf(format, a...))
}

// Incoming is a ticket as reported by a tracker.
type Incoming struct {
	// Source is the tracker it came from; empty means Jira.
	Source      domain.TicketSource
	Key         string
	Project     string
	Title       string
	Description string
	Priority    string
	// Kind comes from a kind label; empty means agnts picks it.
	Kind domain.TicketKind
	// Repo is the repository a repo: label names; it wins over the one
	// linked to Project. Empty: the project's.
	Repo string
	// NoCreate refreshes a known ticket but never creates one (an issue no
	// longer assigned to you).
	NoCreate bool
	// LinksKnown is true when the tracker reported the issue's links, so
	// DependsOn and Dependents are complete (an empty list removes links).
	LinksKnown bool
	// DependsOn are the issues this one is blocked by; Dependents are the
	// issues it blocks.
	DependsOn  []string
	Dependents []string
}

// IngestOutcome is what Ingest did with an issue.
type IngestOutcome string

// Ingest outcomes.
const (
	IngestCreated   IngestOutcome = "created"   // a new ticket
	IngestUpdated   IngestOutcome = "updated"   // a ticket not started yet took the new text
	IngestAsked     IngestOutcome = "asked"     // a started ticket's issue changed: it asks you now
	IngestPending   IngestOutcome = "pending"   // that question still waits for you
	IngestUnchanged IngestOutcome = "unchanged" // nothing new, or nothing to do
)

// Ingest records a ticket from the tracker and reports whether it was
// created; IngestDetail says what else happened.
func (o *Orchestrator) Ingest(ctx context.Context, in Incoming, origin domain.Origin) (bool, error) {
	out, err := o.IngestDetail(ctx, in, origin)
	return out == IngestCreated, err
}

// IngestDetail records a ticket from the tracker. New tickets are queued
// for analysis. A known ticket agnts has not started takes the new text;
// one it started keeps working from the text it started with, and a newer
// version waits on it for you to restart with it or keep the current one.
func (o *Orchestrator) IngestDetail(ctx context.Context, in Incoming, origin domain.Origin) (IngestOutcome, error) {
	if in.Key == "" || in.Title == "" {
		return IngestUnchanged, invalid("ticket key and title are required")
	}
	if in.Source == "" {
		in.Source = domain.SourceJira
	}
	if !in.Source.Tracked() {
		return IngestUnchanged, invalid("%s is not a tracker", in.Source)
	}
	st, err := o.settings.Get(ctx)
	if err != nil {
		return IngestUnchanged, err
	}
	t := domain.Ticket{
		Key: in.Key, Source: in.Source, Title: in.Title, Description: in.Description,
		Priority: strings.ToLower(in.Priority), State: domain.StateNew, ResumeState: domain.StateNew,
		AfterApprove: "pr", AskFirst: st.AskFirst, Kind: in.Kind, KindAuto: in.Kind == "",
	}
	if t.KindAuto {
		t.Kind = domain.KindCode
	}
	if t.Priority == "" {
		t.Priority = "medium"
	}
	archived, labelled, warn := false, false, ""
	if in.Repo != "" {
		repo, err := o.store.RepositoryByName(ctx, in.Repo)
		switch {
		case err == nil:
			t.RepoID, labelled = &repo.ID, true
			archived = repo.ArchivedAt != nil
		case errors.Is(err, domain.ErrNotFound):
			warn = fmt.Sprintf("the label %s%s names no repository in agnts; using the one linked to %s, if any", domain.RepoLabelPrefix, in.Repo, in.Project)
		default:
			return IngestUnchanged, err
		}
	}
	if !labelled {
		if repo, err := o.store.RepositoryByTrackerProject(ctx, in.Source, in.Project); err == nil {
			t.RepoID = &repo.ID
			archived = repo.ArchivedAt != nil
		} else if !errors.Is(err, domain.ErrNotFound) {
			return IngestUnchanged, err
		}
	}
	defer func() {
		if warn != "" {
			o.event(ctx, domain.Event{TicketKey: in.Key, Type: domain.EventTicketUpdated, Origin: origin, Level: domain.LevelWarn, Message: warn})
		}
	}()

	// An archived repository takes no new tickets; known ones still refresh.
	if !archived && !in.NoCreate {
		_, err = o.store.CreateTicket(ctx, t, domain.Event{
			TicketKey: in.Key, Type: domain.EventTicketCreated, Origin: origin, Message: in.Title,
		})
		if err == nil {
			o.syncTrackerRelations(ctx, in, origin)
			o.Wake()
			return IngestCreated, nil
		}
		if !errors.Is(err, domain.ErrConflict) {
			return IngestUnchanged, err
		}
	}

	// Known ticket: before work starts it takes the new text; after, the
	// description Claude worked from stays what the reviewer sees, and the
	// new version waits for a person's choice.
	fresh := domain.NewTrackerUpdate(in.Title, in.Description)
	out := IngestUnchanged
	cur, err := o.store.UpdateTicket(ctx, in.Key, nil, func(x *domain.Ticket) {
		if !x.State.Terminal() && in.Priority != "" && x.Priority != t.Priority {
			x.Priority = t.Priority // only orders the queue: taken at any time
		}
		switch {
		case x.State.Terminal():
		case x.State == domain.StateNew:
			if fresh.Differs(*x) {
				x.Title, x.Description, out = fresh.Title, fresh.Description, IngestUpdated
			}
			x.Update = nil
		case !fresh.Differs(*x):
			x.Update = nil // changed back to what agnts works from
		case fresh.Hash == x.Kept:
		case x.Update != nil && x.Update.Hash == fresh.Hash:
			out = IngestPending
		default:
			x.Update, out = &fresh, IngestAsked
		}
		if x.State == domain.StateNew && in.Kind != "" && (x.Kind != in.Kind || x.KindAuto) {
			x.Kind, x.KindAuto = in.Kind, false // a kind label added before work started
			if out == IngestUnchanged {
				out = IngestUpdated
			}
		}
		switch {
		case labelled && x.State == domain.StateNew && x.PRURL == "" && (x.RepoID == nil || *x.RepoID != *t.RepoID):
			// A repo: label added or changed before work started.
			x.RepoID = t.RepoID
			if out == IngestUnchanged {
				out = IngestUpdated
			}
		case x.RepoID == nil && t.RepoID != nil:
			x.RepoID = t.RepoID
		default:
			warn = "" // the ticket keeps its repository; nothing to warn about
		}
	})
	if errors.Is(err, domain.ErrNotFound) && (archived || in.NoCreate) {
		warn = "" // no ticket to warn on
		return IngestUnchanged, nil
	}
	if err != nil {
		return IngestUnchanged, err
	}
	switch out {
	case IngestUpdated:
		o.event(ctx, domain.Event{TicketKey: in.Key, Type: domain.EventTicketUpdated, Origin: origin, Message: "ticket text updated in " + in.Source.Name()})
	case IngestAsked:
		o.event(ctx, domain.Event{TicketKey: in.Key, Type: domain.EventTrackerChanged, Origin: origin, Level: domain.LevelWarn,
			Message: fmt.Sprintf("%s changed in %s after agnts started (%s): restart with the new version, or keep working on the current one",
				in.Key, in.Source.Name(), cur.State),
			Data: map[string]any{"title": fresh.Title, "state": string(cur.State)}})
	}
	o.syncTrackerRelations(ctx, in, origin)
	return out, nil
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
	for i, a := range answers {
		if strings.TrimSpace(a.Answer) == "" {
			return t, invalid("answer for question %d is empty", a.QuestionID)
		}
		if answers[i].Attachments, err = o.checkUploads(ctx, a.Attachments); err != nil {
			return t, err
		}
		byID[a.QuestionID] = answers[i]
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

// Approve lets agnts push the reviewed branch and open the pull request,
// assigned to the given git host usernames (none keeps it unassigned). For
// a report it finishes the ticket, posting the report to the tracker issue
// when postReport is set.
func (o *Orchestrator) Approve(ctx context.Context, key string, assignees []string, postReport bool, origin domain.Origin) (domain.Ticket, error) {
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
	cur, err := o.store.TicketByKey(ctx, key)
	if err != nil {
		return cur, err
	}
	if cur.ReplayOf != "" {
		return cur, invalid("%s replays %s to evaluate agnts: it is never pushed. Reject it when you are done", cur.Key, cur.ReplayOf)
	}
	if err := o.secretsCleared(ctx, cur); err != nil {
		return cur, err
	}
	msg := "approved"
	switch {
	case cur.Kind == domain.KindReview:
		clean, postReport = nil, false
		msg = "accepted: merging the pull request"
	case cur.Kind.Report():
		clean = nil // there is no pull request to assign
		if postReport {
			msg += ", posting the report to the issue"
		}
	case len(clean) > 0:
		msg += ", assigned to " + strings.Join(clean, ", ")
	}
	reviewing := false
	t, err := o.store.Transition(ctx, key, domain.StatePushing, domain.Event{
		TicketKey: key, Type: domain.EventStateChanged, Origin: origin, Message: msg,
	}, func(x *domain.Ticket) {
		x.Assignees = clean
		x.PostReport = postReport && x.Kind.Report()
		reviewing = dropSideRuns(x)
	})
	if err == nil {
		if reviewing {
			o.cancelRun(ctx, key) // the push waits for the run to end
		}
		o.Wake()
	}
	return t, err
}

// dropSideRuns forgets the code review and preview of a ticket leaving
// review; it reports whether one of them may be running.
func dropSideRuns(x *domain.Ticket) bool {
	r := dropReview(x)
	p := dropPreview(x)
	return r || p
}

// RequestChanges sends the ticket back to coding with reviewer feedback.
// shots are preview screenshots the feedback points at, files uploads
// that go with it; the coding run gets both next to it.
func (o *Orchestrator) RequestChanges(ctx context.Context, key, feedback string, shots []domain.ShotRef, files []int64, origin domain.Origin) (domain.Ticket, error) {
	feedback = strings.TrimSpace(feedback)
	if feedback == "" {
		return domain.Ticket{}, invalid("feedback is required")
	}
	shots, err := o.checkShotRefs(domain.WorkspaceOf(ctx), key, shots)
	if err != nil {
		return domain.Ticket{}, err
	}
	if files, err = o.checkUploads(ctx, files); err != nil {
		return domain.Ticket{}, err
	}
	cur, err := o.store.TicketByKey(ctx, key)
	if err != nil {
		return cur, err
	}
	if !domain.CanTransition(cur.State, domain.StateCoding) {
		return cur, &domain.TransitionError{Key: key, From: cur.State, To: domain.StateCoding}
	}
	ev := domain.Event{TicketKey: key, Type: domain.EventFeedback, Origin: origin, Message: feedback}
	if len(files) > 0 {
		ev.Data = map[string]any{"attachments": files}
	}
	// Link first: once the ticket moves, a run may pick it up.
	if err := o.store.LinkAttachments(ctx, files, cur.ID, nil, domain.AttachFeedback); err != nil {
		return cur, err
	}
	reviewing := false
	t, err := o.store.Transition(ctx, key, domain.StateCoding, ev, func(x *domain.Ticket) {
		x.Revision++
		x.Feedback = feedback
		x.FeedbackShots = shots
		x.FeedbackFiles = files
		x.SelfFixes, x.QuietReview = 0, false // agnts's review gets a round on the new change
		reviewing = dropSideRuns(x)
	})
	if err == nil {
		if reviewing {
			o.cancelRun(ctx, key) // coding waits for the run to end
		}
		o.queueReflection(ctx, t, domain.ReflectChanges, feedback, origin)
		o.noteReviewer(ctx, t, domain.NoteRereview, feedback, origin)
		o.adoptFindings(ctx, cur, feedback) // the revision that was reviewed
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
	}, func(x *domain.Ticket) { dropSideRuns(x) })
	if err != nil {
		return t, err
	}
	o.cancelRun(ctx, key)
	o.trackerMove(context.WithoutCancel(ctx), t, TrackerRejected)
	o.queueReflection(context.WithoutCancel(ctx), t, domain.ReflectRejected, reason, origin)
	o.noteReviewer(ctx, t, domain.NoteDismissed, reason, origin)
	if t.PRNumber == nil || t.Kind == domain.KindReview {
		o.dropBranch(ctx, t) // never pushed (a review's branch is a copy): nothing else needs it
	}
	o.Wake() // tickets waiting for it may start
	return t, nil
}

// RestartWithUpdate starts a ticket over from the newer version of its
// issue that arrived after agnts started: the work so far (analysis,
// answers, commits, reviews) is dropped and the ticket is analysed again.
// Anything pushed already cannot be restarted.
func (o *Orchestrator) RestartWithUpdate(ctx context.Context, key string, origin domain.Origin) (domain.Ticket, error) {
	cur, err := o.store.TicketByKey(ctx, key)
	if err != nil {
		return cur, err
	}
	if cur.Update == nil {
		return cur, invalid("%s has no newer version from the tracker", key)
	}
	if cur.PRURL != "" || cur.State == domain.StatePushing || cur.ResumeState == domain.StatePushing {
		return cur, invalid("%s is pushed already: reject it and let agnts take the issue again, or keep the current version", key)
	}
	u := *cur.Update
	t, err := o.store.Transition(ctx, key, domain.StateNew, domain.Event{
		TicketKey: key, Type: domain.EventStateChanged, Origin: origin,
		Message: "restarted with the newer version from " + cur.Source.Name(),
	}, func(x *domain.Ticket) {
		x.Title, x.Description = u.Title, u.Description
		x.Update, x.Kept = nil, ""
		x.Revision++ // reviews of the old work are stale
		x.HeadSHA, x.Feedback, x.FeedbackShots, x.FeedbackFiles = "", "", nil, nil
		x.ResumeState, x.SelfFixes, x.QuietReview = domain.StateNew, 0, false
		dropSideRuns(x)
	})
	if err != nil {
		return t, err
	}
	o.cancelRun(ctx, key)
	o.dropBranch(ctx, cur) // the old commits: the new analysis cuts a fresh branch
	if err := o.store.ReplaceQuestions(context.WithoutCancel(ctx), cur.ID, nil); err != nil {
		o.log.Warn("drop the old questions", "ticket", key, "err", err)
	}
	o.Wake()
	return t, nil
}

// KeepCurrentVersion keeps working from the text agnts started with and
// stops asking about this newer version of the issue (a later change asks
// again).
func (o *Orchestrator) KeepCurrentVersion(ctx context.Context, key string, origin domain.Origin) (domain.Ticket, error) {
	cur, err := o.store.TicketByKey(ctx, key)
	if err != nil {
		return cur, err
	}
	if cur.Update == nil {
		return cur, invalid("%s has no newer version from the tracker", key)
	}
	return o.store.UpdateTicket(ctx, key, &domain.Event{
		TicketKey: key, Type: domain.EventTicketUpdated, Origin: origin, Message: "kept working on the version agnts started with",
	}, func(x *domain.Ticket) {
		if x.Update != nil {
			x.Kept, x.Update = x.Update.Hash, nil
		}
	})
}

func (o *Orchestrator) cancelRun(ctx context.Context, key string) bool {
	o.mu.Lock()
	cancel := o.cancels[runKey(domain.WorkspaceOf(ctx), key)]
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
	o.cancelRun(ctx, key)
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
		if stage != domain.ModelAnalyze && stage != domain.ModelCoding && stage != domain.ModelRetry && stage != domain.ModelReview && stage != domain.ModelPreview {
			return domain.Ticket{}, invalid("unknown stage %q", stage)
		}
		if m == "" || m == "default" {
			continue
		}
		if !domain.ValidModel(m) {
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
		if (x.State != domain.StateNew && !stopped) || x.PRURL != "" || x.ResumeState == domain.StatePushing || x.Kind == domain.KindReview {
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
	RepoID       int64  // 0: no repository (report kinds, or agnts picks)
	Kind         string // a domain.TicketKind, or "" / "auto" for agnts to pick
	Title        string
	Description  string
	Priority     string
	AfterApprove string // pr or main
	Start        string // ask, code or queue
	// FollowUps turns follow-up suggestions on or off for the task; nil
	// follows the setting. CreateTask only.
	FollowUps *bool
	// Attachments are the files attached to the description: uploads to
	// link, and on edit the task's files to keep. nil keeps them as they are.
	Attachments *[]int64
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
	kind, auto, err := parseKind(in.Kind)
	if err != nil {
		return domain.Ticket{}, err
	}
	var repoID *int64
	prefix := NoRepoTaskPrefix
	if in.RepoID != 0 {
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
		repoID, prefix = &repo.ID, TaskPrefix(repo)
	} else if !auto && kind.Spec().NeedsRepo {
		return domain.Ticket{}, invalid("a %s task needs a repository", kind)
	}
	var files []int64
	if in.Attachments != nil {
		if files, err = o.checkUploads(ctx, *in.Attachments); err != nil {
			return domain.Ticket{}, err
		}
	}
	st, err := o.settings.Get(ctx)
	if err != nil {
		return domain.Ticket{}, err
	}
	return o.createTask(ctx, domain.Ticket{
		Source: domain.SourceLocal, RepoID: repoID,
		Title: strings.TrimSpace(in.Title), Description: strings.TrimSpace(in.Description), Priority: in.Priority,
		State: domain.StateNew, ResumeState: domain.StateNew, AfterApprove: in.AfterApprove,
		Held: in.Start == "queue", AskFirst: in.Start == "ask" || (in.Start == "queue" && st.AskFirst),
		Kind: kind, KindAuto: auto, SuggestFollowUps: in.FollowUps,
	}, prefix, files, origin)
}

// createTask stores a local task under the next free key with prefix
// (numbered per repository, or among tasks without one), attaches files
// (checked uploads) and wakes the loop.
func (o *Orchestrator) createTask(ctx context.Context, t domain.Ticket, prefix string, files []int64, origin domain.Origin) (domain.Ticket, error) {
	// A key can be taken by a ticket from elsewhere with the same prefix;
	// skip to the next number.
	for range 5 {
		n, err := o.store.NextTaskNumber(ctx, t.RepoID)
		if err != nil {
			return domain.Ticket{}, err
		}
		t.Key = fmt.Sprintf("%s-%d", prefix, n)
		out, err := o.store.CreateTicket(ctx, t, domain.Event{Type: domain.EventTicketCreated, Origin: origin, Message: t.Title})
		if errors.Is(err, domain.ErrConflict) {
			continue
		}
		if err == nil {
			// Before the wake, so the analysis sees the files.
			if lerr := o.store.LinkAttachments(ctx, files, out.ID, nil, domain.AttachTicket); lerr != nil {
				o.log.Warn("attach files", "ticket", out.Key, "err", lerr)
			}
			if !out.Held {
				o.Wake()
			}
		}
		return out, err
	}
	return domain.Ticket{}, fmt.Errorf("no free task key with prefix %s", prefix)
}

// NoRepoTaskPrefix is the key prefix of tasks without a repository.
const NoRepoTaskPrefix = "TASK"

// parseKind reads a kind from input: "" or "auto" lets agnts pick (it
// starts as code until the analysis says otherwise).
func parseKind(s string) (domain.TicketKind, bool, error) {
	if s == "" || s == "auto" {
		return domain.KindCode, true, nil
	}
	k := domain.TicketKind(s)
	if !k.Selectable() {
		return "", false, invalid("unknown kind %q", s)
	}
	return k, false, nil
}

// SetKind changes what a ticket produces. It is allowed before work starts,
// while agnts waits for answers, and on a stopped ticket that pushed
// nothing. The chosen kind is final: the analysis no longer changes it.
func (o *Orchestrator) SetKind(ctx context.Context, key, kind string, origin domain.Origin) (domain.Ticket, error) {
	k, auto, err := parseKind(kind)
	if err != nil {
		return domain.Ticket{}, err
	}
	var bad error
	t, err := o.store.UpdateTicket(ctx, key, &domain.Event{
		TicketKey: key, Type: domain.EventKind, Origin: origin, Message: "kind set to " + kind,
		Data: map[string]any{"to": kind},
	}, func(x *domain.Ticket) {
		switch x.State {
		case domain.StateNew, domain.StateWaitingForAnswers, domain.StateFailed, domain.StateRateLimited:
		default:
			bad = &domain.TransitionError{Key: key, From: x.State, To: x.State}
			return
		}
		if x.PRURL != "" || x.ResumeState == domain.StatePushing || x.Kind == domain.KindReview {
			bad = &domain.TransitionError{Key: key, From: x.State, To: x.State}
			return
		}
		if !auto && k.Spec().NeedsRepo && x.RepoID == nil {
			bad = invalid("%s work needs a repository: link one first", k)
			return
		}
		if k.Report() != x.Kind.Report() {
			// A change and a report share no work past the analysis.
			x.Branch, x.HeadSHA, x.Feedback = "", "", ""
		}
		x.Kind, x.KindAuto = k, auto
	})
	if bad != nil {
		return t, bad
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
	if in.Attachments != nil {
		if len(*in.Attachments) > domain.MaxAttachments {
			return domain.Ticket{}, invalid("attach at most %d files", domain.MaxAttachments)
		}
	}
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
		if in.Kind != "" {
			k, auto, err := parseKind(in.Kind)
			if err != nil {
				bad = err
				return
			}
			if !auto && k.Spec().NeedsRepo && x.RepoID == nil {
				bad = invalid("a %s task needs a repository", k)
				return
			}
			x.Kind, x.KindAuto = k, auto
		}
	})
	if bad != nil {
		return t, bad
	}
	if err == nil && in.Attachments != nil {
		err = o.setTaskFiles(ctx, t, *in.Attachments)
	}
	return t, err
}

// DeleteTask removes a task that has not started yet.
func (o *Orchestrator) DeleteTask(ctx context.Context, key string, origin domain.Origin) error {
	t, err := o.store.TicketByKey(ctx, key)
	if err != nil {
		return err
	}
	if t.Source != domain.SourceLocal || t.State != domain.StateNew || (!t.Held && o.cancelRunning(ctx, key)) {
		return &domain.TransitionError{Key: key, From: t.State, To: domain.StateRejected}
	}
	return o.store.DeleteTicket(ctx, key, domain.Event{TicketKey: key, Type: domain.EventTaskChanged, Origin: origin, Message: "task deleted"})
}

func (o *Orchestrator) cancelRunning(ctx context.Context, key string) bool {
	o.mu.Lock()
	defer o.mu.Unlock()
	_, ok := o.cancels[runKey(domain.WorkspaceOf(ctx), key)]
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
	return o.RetryWithNote(ctx, key, "", nil, origin)
}

// RetryWithNote is Retry with a note on how to get past the failure, and
// files (uploads) that help. The next coding run gets them and the error
// the way it gets requested changes, so the ticket must resume at a stage
// that runs Claude.
func (o *Orchestrator) RetryWithNote(ctx context.Context, key, note string, files []int64, origin domain.Origin) (domain.Ticket, error) {
	note = strings.TrimSpace(note)
	files, err := o.checkUploads(ctx, files)
	if err != nil {
		return domain.Ticket{}, err
	}
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
	if (note != "" || len(files) > 0) && to == domain.StatePushing {
		return t, invalid("this ticket resumes at pushing, which does not run Claude; retry without a note or files")
	}
	feedback := ""
	if note != "" || len(files) > 0 {
		info, err := o.store.StateSince(ctx, []string{key})
		if err != nil {
			return t, err
		}
		if note == "" {
			note = "See the attached files."
		}
		feedback = retryFeedback(info[key].Reason, note)
	}
	msg := "retry"
	if note != "" {
		msg += ": " + note
	}
	ev := domain.Event{TicketKey: key, Type: domain.EventStateChanged, Origin: origin, Message: msg}
	if len(files) > 0 {
		ev.Data = map[string]any{"attachments": files}
	}
	// Link first: once the ticket moves, a run may pick it up.
	if err := o.store.LinkAttachments(ctx, files, t.ID, nil, domain.AttachRetry); err != nil {
		return t, err
	}
	t, err = o.store.Transition(ctx, key, to, ev, func(x *domain.Ticket) {
		if feedback == "" {
			return
		}
		if x.Feedback != "" {
			x.Feedback += "\n\n" + feedback
		} else {
			x.Feedback = feedback
		}
		x.FeedbackFiles = append(x.FeedbackFiles, files...)
	})
	if err == nil {
		o.Wake()
	}
	return t, err
}

// retryFeedback is what the next coding run reads for a retry note: the
// error the last run stopped with, then the note.
func retryFeedback(reason, note string) string {
	if reason = strings.TrimSpace(reason); reason == "" {
		return note
	}
	return "The last run stopped with this error:\n\n" + truncate(reason, 4000) + "\n\nHow to get past it:\n\n" + note
}

// TicketView is everything the ticket page shows.
type TicketView struct {
	Ticket   domain.Ticket
	Info     StateInfo
	RepoName string
	// Member and CreatedBy are usernames ("" for none).
	Member, CreatedBy string
	Questions         []domain.Question
	Analysis          *Analysis
	// SecondOpinion is another model's read of the analysis's approach.
	SecondOpinion *domain.SecondOpinion
	Result        *domain.Result
	ChildKey      string          // the code task that implements this report, if any
	Review        *domain.Review  // newest code review; stale when its revision is older
	Preview       *domain.Preview // newest preview; stale when its revision is older
	// CanPreview reports whether the ticket's repository has a preview
	// command (and the server can store screenshots).
	CanPreview bool
	History    []HistoryItem
	Settings   domain.Settings
	Spend      domain.TokenUsage   // all Claude runs; zero when none was recorded
	Stages     []domain.StageUsage // Spend by model stage and model
	// FollowUps are the suggested follow-up tickets and those made from them.
	FollowUps FollowUps
	// FollowUpsOn reports whether this ticket's runs suggest follow-ups.
	FollowUpsOn bool
	// Relations are its ordering constraints and what holds it back now.
	Relations Relations
	// Attachments are the files attached to the task, answers and retries.
	Attachments []domain.Attachment
}

// TicketRow is a ticket for lists, with when it entered its state.
type TicketRow struct {
	Ticket   domain.Ticket
	Info     StateInfo
	RepoName string
	Spend    domain.TokenUsage // zero when no Claude run was recorded
	// OpenSuggestions counts follow-ups waiting for someone to decide.
	OpenSuggestions int
	// Blockers hold its first coding run back right now.
	Blockers []domain.Blocker
	// Member and CreatedBy are the usernames of the ticket's member and
	// creator ("" for none).
	Member, CreatedBy string
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
	spend, err := o.store.SpendByKeys(ctx, keys)
	if err != nil {
		return nil, err
	}
	open, err := o.store.OpenSuggestionCounts(ctx, keys)
	if err != nil {
		return nil, err
	}
	blockers, err := o.store.Blockers(ctx, keys)
	if err != nil {
		return nil, err
	}
	var people []int64
	for _, t := range ts {
		if t.MemberID != nil {
			people = append(people, *t.MemberID)
		}
		if t.CreatedBy != nil {
			people = append(people, *t.CreatedBy)
		}
	}
	who, err := o.store.Usernames(ctx, people)
	if err != nil {
		return nil, err
	}
	names := map[int64]string{}
	out := make([]TicketRow, len(ts))
	for i, t := range ts {
		out[i] = TicketRow{Ticket: t, Info: info[t.Key], Spend: spend[t.Key], OpenSuggestions: open[t.Key], Blockers: blockers[t.Key]}
		if t.MemberID != nil {
			out[i].Member = who[*t.MemberID]
		}
		if t.CreatedBy != nil {
			out[i].CreatedBy = who[*t.CreatedBy]
		}
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
	v.Info, v.RepoName, v.Spend = rows[0].Info, rows[0].RepoName, rows[0].Spend
	v.Member, v.CreatedBy = rows[0].Member, rows[0].CreatedBy
	if v.Stages, err = o.store.TicketUsage(ctx, t.ID); err != nil {
		return v, err
	}
	if v.Settings, err = o.settings.Get(ctx); err != nil {
		return v, err
	}
	if v.History, err = o.store.History(ctx, key); err != nil {
		return v, err
	}
	if v.Questions, err = o.store.Questions(ctx, t.ID); err != nil {
		return v, err
	}
	if v.Attachments, err = o.store.TicketAttachments(ctx, t.ID); err != nil {
		return v, err
	}
	if r, err := o.store.LatestResult(ctx, t.ID, domain.StageAnalyze); err == nil {
		if a, err := parseAnalysis(r.Summary); err == nil {
			v.Analysis = &a
		}
		v.SecondOpinion = r.Harness.SecondOpinion
	} else if !errors.Is(err, domain.ErrNotFound) {
		return v, err
	}
	if r, err := o.store.LatestResult(ctx, t.ID, domain.StageCode); err == nil {
		v.Result = &r
	} else if !errors.Is(err, domain.ErrNotFound) {
		return v, err
	}
	if t.Kind.Spec().Implementable {
		if c, err := o.store.ChildOf(ctx, t.Key); err == nil {
			v.ChildKey = c.Key
		} else if !errors.Is(err, domain.ErrNotFound) {
			return v, err
		}
	}
	if v.Review, err = o.latestReview(ctx, t.ID); err != nil {
		return v, err
	}
	if t.Kind == domain.KindReview && v.Result != nil {
		// A pull request review is the work itself: the result holds it.
		var rv domain.Review
		if json.Unmarshal(v.Result.Summary, &rv) == nil && rv.Summary != "" {
			rv.CreatedAt = v.Result.CreatedAt
			v.Review = &rv
		}
	}
	if v.Preview, err = o.latestPreview(ctx, t.ID); err != nil {
		return v, err
	}
	if o.shots != nil && t.RepoID != nil && !t.Kind.Report() {
		if repo, err := o.store.RepositoryByID(ctx, *t.RepoID); err == nil {
			v.CanPreview = repo.Preview.Enabled()
		}
	}
	if v.FollowUps, err = o.followUps(ctx, t); err != nil {
		return v, err
	}
	v.FollowUpsOn = v.Settings.FollowUpsOn(t)
	if v.Relations, err = o.relations(ctx, t.Key); err != nil {
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
		return false, nil // not one of agnts's
	}
	if err != nil {
		return false, err
	}
	if t.MergedAt != nil {
		return false, nil
	}
	if prURL != "" {
		t.PRURL = prURL
	}
	if _, err := o.markMerged(ctx, t, origin, "pull request merged"); err != nil {
		return false, err
	}
	return true, nil
}

// MarkPRClosed records that a ticket's pull request was closed without a
// merge (closed true) or reopened (false), from a git host webhook. Only
// analytics read it; the ticket stays done.
func (o *Orchestrator) MarkPRClosed(ctx context.Context, prURL, branch string, closed bool, origin domain.Origin) (bool, error) {
	t, err := o.store.TicketByPR(ctx, prURL, branch)
	if errors.Is(err, domain.ErrNotFound) {
		return false, nil // not one of agnts's
	}
	if err != nil {
		return false, err
	}
	if t.MergedAt != nil {
		return false, nil
	}
	msg := "pull request closed without merging"
	if !closed {
		msg = "pull request reopened"
	}
	return true, o.setPRClosed(ctx, t, closed, origin, msg)
}

func (o *Orchestrator) setPRClosed(ctx context.Context, t domain.Ticket, closed bool, origin domain.Origin, msg string) error {
	changed, err := o.store.SetPRClosed(ctx, t.Key, closed)
	if err != nil || !changed {
		return err
	}
	o.event(ctx, domain.Event{TicketKey: t.Key, Type: domain.EventPRClosed, Origin: origin, Message: msg,
		Data: map[string]any{"url": t.PRURL, "closed": closed}})
	return nil
}

// SetMember makes userID the ticket's member: in per-member Claude mode its
// runs use that person's account. The caller checks userID is a member.
func (o *Orchestrator) SetMember(ctx context.Context, key string, userID int64, name string, origin domain.Origin) (domain.Ticket, error) {
	msg := "assigned to " + name
	if a, ok := domain.ActorOf(ctx); ok && a.UserID == userID {
		msg = name + " took the ticket over"
	}
	return o.store.UpdateTicket(ctx, key, &domain.Event{TicketKey: key, Type: domain.EventTicketUpdated, Origin: origin, Message: msg,
		Data: map[string]any{"member": userID}}, func(t *domain.Ticket) { t.MemberID = &userID })
}
