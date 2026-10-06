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

// Limits of the follow-up context put into a prompt.
const (
	followUpMaxChain = 10 // ancestors listed; also stops a cycle
	followUpMaxOpen  = 60 // open tickets listed so they are not suggested again
)

// followUpTypes is what each source may suggest, as told to Claude. Every
// type serves the parent ticket; nothing here invites new work.
var followUpTypes = map[string][]string{
	domain.SuggestFromAnalyze: {
		"prerequisite: work that must be done before this ticket can work, and that the ticket does not ask for",
		"split: a part of this ticket big enough to be its own ticket; leave it out of your plan and say so",
	},
	domain.SuggestFromWork: {
		"unfinished: something this ticket needs that you did not do here: a caller not updated, a missing test, a migration, configuration or docs the change relies on",
		"prerequisite: something outside this change that must be done before it works in production",
	},
	"report": {
		"gap: a concrete gap, risk or action item your report found that must be handled for the ticket's goal; one follow-up per gap, so nobody forgets it",
		"prerequisite: something that must be done before the ticket's goal can be reached",
	},
	domain.SuggestFromReview: {
		"unfinished: something the change needs but leaves out, too large or too separate to fix by requesting changes on this ticket",
		"gap: a concrete risk or missing piece around the change that must be handled for the ticket's goal",
	},
}

// followUpBlock renders the follow-up section of a prompt for stage (a
// source, or "report"), or "" when t has follow-ups off.
func (o *Orchestrator) followUpBlock(ctx context.Context, s domain.Settings, t domain.Ticket, d promptData, stage, file string) (string, error) {
	if !s.FollowUpsOn(t) {
		return "", nil
	}
	d.T, d.FollowUpFile, d.MaxFollowUps = t, file, domain.MaxFollowUps
	d.FollowUpTypes = followUpTypes[stage]
	d.FollowUpTypeNames = nil
	for _, x := range d.FollowUpTypes {
		d.FollowUpTypeNames = append(d.FollowUpTypeNames, x[:strings.Index(x, ":")])
	}

	// The chain, root first: every level serves the root's goal.
	d.Chain = nil
	seen := map[string]bool{t.Key: true}
	for key := t.FollowUpOf; key != "" && !seen[key] && len(d.Chain) < followUpMaxChain; {
		seen[key] = true
		p, err := o.store.TicketByKey(ctx, key)
		if errors.Is(err, domain.ErrNotFound) {
			break
		}
		if err != nil {
			return "", err
		}
		d.Chain = append([]TicketRef{{Key: p.Key, Title: p.Title}}, d.Chain...)
		key = p.FollowUpOf
	}

	open, err := o.store.OpenTicketRefs(ctx, t.RepoID, followUpMaxOpen)
	if err != nil {
		return "", err
	}
	d.Known = nil
	for _, r := range open {
		if r.Key != t.Key {
			d.Known = append(d.Known, r)
		}
	}
	ss, err := o.store.Suggestions(ctx, t.ID)
	if err != nil {
		return "", err
	}
	source := stage
	if stage == "report" {
		source = domain.SuggestFromWork
	}
	for _, x := range ss {
		switch {
		case x.Status == domain.SuggestionDismissed:
			d.Known = append(d.Known, TicketRef{Title: x.Title + " (declined)"})
		case x.Status == domain.SuggestionAccepted:
			d.Known = append(d.Known, TicketRef{Key: x.ChildKey, Title: x.Title})
		case x.Source != source:
			d.Known = append(d.Known, TicketRef{Title: x.Title}) // another stage's, still open
		}
	}
	// A follow-up's siblings: what its parent suggested besides it.
	if len(d.Chain) > 0 {
		p, err := o.store.TicketByKey(ctx, d.Chain[len(d.Chain)-1].Key)
		if err != nil {
			return "", err
		}
		ps, err := o.store.Suggestions(ctx, p.ID)
		if err != nil {
			return "", err
		}
		for _, x := range ps {
			if x.ChildKey == t.Key {
				continue
			}
			if x.Status == domain.SuggestionDismissed {
				d.Known = append(d.Known, TicketRef{Title: x.Title + " (declined)"})
			} else {
				d.Known = append(d.Known, TicketRef{Key: x.ChildKey, Title: x.Title})
			}
		}
	}
	return render("followups", d)
}

// withFollowUps appends the follow-up block to a prompt.
func (o *Orchestrator) withFollowUps(ctx context.Context, s domain.Settings, t domain.Ticket, d promptData, stage, file, prompt string) (string, error) {
	block, err := o.followUpBlock(ctx, s, t, d, stage, file)
	if err != nil || block == "" {
		return prompt, err
	}
	return prompt + "\n" + block, nil
}

// saveFollowUps stores what a run suggested, replacing the open
// suggestions the same source made before. With follow-ups off nothing is
// touched. Suggestions are advice: a failure is logged, never fatal.
func (o *Orchestrator) saveFollowUps(ctx context.Context, s domain.Settings, t domain.Ticket, run *domain.Run, source string, fs []domain.FollowUp) {
	if !s.FollowUpsOn(t) {
		return
	}
	ss := domain.Suggestions(fs, source)
	titles := make([]string, len(ss))
	for i := range ss {
		ss[i].RunID, ss[i].Revision = &run.ID, t.Revision
		titles[i] = ss[i].Title
	}
	var ev *domain.Event
	if len(ss) > 0 {
		ev = &domain.Event{
			TicketKey: t.Key, RunID: &run.ID, Step: string(run.Stage), Type: domain.EventFollowUps,
			Message: fmt.Sprintf("%d %s suggested: %s", len(ss), plural(len(ss), "follow-up", "follow-ups"), strings.Join(titles, "; ")),
			Data:    map[string]any{"count": len(ss), "source": source, "titles": titles},
		}
	}
	if err := o.store.ReplaceSuggestions(ctx, t.ID, source, ss, ev); err != nil {
		o.log.Error("save follow-up suggestions", "ticket", t.Key, "err", err)
	}
}

// summaryFollowUps reads the follow-ups from a run's summary.json.
func summaryFollowUps(b []byte) []domain.FollowUp {
	var sum Summary
	_ = json.Unmarshal(b, &sum)
	return sum.FollowUps
}

// SetFollowUps turns follow-up suggestions on or off for one ticket; nil
// follows the setting again.
func (o *Orchestrator) SetFollowUps(ctx context.Context, key string, on *bool, origin domain.Origin) (domain.Ticket, error) {
	msg := "follow-up suggestions follow the settings"
	if on != nil && *on {
		msg = "follow-up suggestions turned on"
	} else if on != nil {
		msg = "follow-up suggestions turned off"
	}
	return o.store.UpdateTicket(ctx, key, &domain.Event{TicketKey: key, Type: domain.EventTicketUpdated, Origin: origin, Message: msg},
		func(x *domain.Ticket) { x.SuggestFollowUps = on })
}

// FollowUps is a ticket's suggestions and the tickets made from them.
type FollowUps struct {
	Suggestions []domain.Suggestion
	Children    []domain.Ticket
}

// ListFollowUps returns a ticket's suggestions and follow-up tickets.
func (o *Orchestrator) ListFollowUps(ctx context.Context, key string) (FollowUps, error) {
	t, err := o.store.TicketByKey(ctx, key)
	if err != nil {
		return FollowUps{}, err
	}
	return o.followUps(ctx, t)
}

func (o *Orchestrator) followUps(ctx context.Context, t domain.Ticket) (FollowUps, error) {
	var f FollowUps
	var err error
	if f.Suggestions, err = o.store.Suggestions(ctx, t.ID); err != nil {
		return f, err
	}
	f.Children, err = o.store.FollowUpsOf(ctx, t.Key)
	return f, err
}

// Where an accepted follow-up is filed.
const (
	TargetLocal = "local" // an agnts task
	TargetJira  = "jira"  // a new Jira issue
)

// AcceptInput is one suggestion to turn into a ticket, with the person's
// edits; empty fields keep what was suggested.
type AcceptInput struct {
	ID          int64
	Target      string // TargetLocal (default) or TargetJira
	Title       string
	Description string
	Kind        string
	Priority    string
	RepoID      int64 // 0: the parent's repository
}

// AcceptResult is what accepting one suggestion did.
type AcceptResult struct {
	ID     int64
	Ticket *domain.Ticket
	Err    error
}

// AcceptSuggestions creates a ticket from each chosen suggestion. Every
// ticket is queued (held): nothing runs, and no tokens are spent, until
// someone starts it. Each suggestion is handled on its own, so one bad
// choice does not undo the others.
func (o *Orchestrator) AcceptSuggestions(ctx context.Context, key string, in []AcceptInput, origin domain.Origin) ([]AcceptResult, error) {
	if len(in) == 0 {
		return nil, invalid("pick at least one suggestion")
	}
	p, err := o.store.TicketByKey(ctx, key)
	if err != nil {
		return nil, err
	}
	ss, err := o.store.Suggestions(ctx, p.ID)
	if err != nil {
		return nil, err
	}
	st, err := o.settings.Get(ctx)
	if err != nil {
		return nil, err
	}
	out := make([]AcceptResult, 0, len(in))
	for _, a := range in {
		r := AcceptResult{ID: a.ID}
		i := slices.IndexFunc(ss, func(x domain.Suggestion) bool { return x.ID == a.ID })
		if i < 0 {
			r.Err = fmt.Errorf("suggestion %d of %s: %w", a.ID, key, domain.ErrNotFound)
		} else {
			var t domain.Ticket
			if t, r.Err = o.accept(ctx, st, p, ss[i], a, origin); r.Err == nil {
				r.Ticket = &t
			}
		}
		out = append(out, r)
	}
	return out, nil
}

func (o *Orchestrator) accept(ctx context.Context, st domain.Settings, p domain.Ticket, x domain.Suggestion, a AcceptInput, origin domain.Origin) (domain.Ticket, error) {
	if x.Status != domain.SuggestionOpen {
		return domain.Ticket{}, domain.ErrSuggestionDecided
	}
	if !x.Ready(p.State) {
		return domain.Ticket{}, invalid("this follow-up builds on %s's work: create it once %s is done", p.Key, p.Key)
	}
	if a.Target == "" {
		a.Target = TargetLocal
	}
	if a.Target != TargetLocal && a.Target != TargetJira {
		return domain.Ticket{}, invalid("target must be local or jira")
	}
	kind := x.Kind
	if a.Kind != "" {
		if kind = domain.TicketKind(a.Kind); !kind.Valid() {
			return domain.Ticket{}, invalid("unknown kind %q", a.Kind)
		}
	}
	priority := x.Priority
	if a.Priority != "" {
		if !slices.Contains([]string{"low", "medium", "high"}, a.Priority) {
			return domain.Ticket{}, invalid("priority must be low, medium or high")
		}
		priority = a.Priority
	}
	title, desc := x.Title, x.Description
	if s := strings.TrimSpace(a.Title); s != "" {
		title = s
	}
	if s := strings.TrimSpace(a.Description); s != "" {
		desc = s
	}
	desc = followUpDescription(p, x, desc)

	var repo *domain.Repository
	repoID := a.RepoID
	if repoID == 0 && p.RepoID != nil {
		repoID = *p.RepoID
	}
	if repoID != 0 {
		r, err := o.store.RepositoryByID(ctx, repoID)
		if errors.Is(err, domain.ErrNotFound) {
			return domain.Ticket{}, invalid("no repository %d", repoID)
		}
		if err != nil {
			return domain.Ticket{}, err
		}
		if r.ArchivedAt != nil {
			return domain.Ticket{}, invalid("%s is archived: restore it on the Repositories page first", r.Name)
		}
		repo = &r
	} else if kind.Spec().NeedsRepo {
		return domain.Ticket{}, invalid("a %s ticket needs a repository: pick one", kind)
	}

	t := domain.Ticket{
		Source: domain.SourceLocal, Title: truncate(title, 300), Description: desc, Priority: priority,
		State: domain.StateNew, ResumeState: domain.StateNew, AfterApprove: "pr", Held: true, AskFirst: st.AskFirst,
		Kind: kind, FollowUpOf: p.Key,
	}
	if repo != nil {
		t.RepoID = &repo.ID
	}
	ev := domain.Event{TicketKey: p.Key, Type: domain.EventTicketUpdated, Origin: origin, Data: map[string]any{"suggestion": x.ID}}

	if a.Target == TargetJira {
		return o.acceptToJira(ctx, p, repo, t, x, ev)
	}
	prefix := NoRepoTaskPrefix
	if repo != nil {
		prefix = TaskPrefix(*repo)
	}
	for range 5 {
		n, err := o.store.NextTaskNumber(ctx, t.RepoID)
		if err != nil {
			return domain.Ticket{}, err
		}
		t.Key = fmt.Sprintf("%s-%d", prefix, n)
		ev.Message, ev.Data["child"] = "follow-up "+t.Key+" created: "+t.Title, t.Key
		out, err := o.store.CreateFollowUp(ctx, p.ID, x.ID, t, ev)
		if errors.Is(err, domain.ErrConflict) && !errors.Is(err, domain.ErrSuggestionDecided) {
			continue // the key is taken by a ticket from elsewhere
		}
		return out, err
	}
	return domain.Ticket{}, fmt.Errorf("no free task key with prefix %s", prefix)
}

// acceptToJira files the follow-up as a Jira issue, then keeps it as a
// queued ticket under the issue's key. The issue gets agnts's labels only
// after the ticket exists: a webhook for a labelled issue would otherwise
// race in and start it.
func (o *Orchestrator) acceptToJira(ctx context.Context, p domain.Ticket, repo *domain.Repository, t domain.Ticket, x domain.Suggestion, ev domain.Event) (domain.Ticket, error) {
	ic, ok := o.tracker.(IssueCreator)
	if o.tracker == nil || !ok {
		return domain.Ticket{}, invalid("Jira is not connected: create it as a local task, or connect Jira on the Integrations page")
	}
	project := ""
	if p.Source == domain.SourceJira {
		if i := strings.LastIndex(p.Key, "-"); i > 0 {
			project = p.Key[:i]
		}
	}
	if repo != nil && repo.JiraProject != "" && (project == "" || (p.RepoID != nil && *p.RepoID != repo.ID)) {
		project = repo.JiraProject
	}
	if project == "" {
		return domain.Ticket{}, invalid("no Jira project for this follow-up: link the repository to a Jira project, or create it as a local task")
	}
	key, err := ic.CreateIssue(ctx, NewIssue{Project: project, Title: t.Title, Description: t.Description, Priority: t.Priority})
	if err != nil {
		return domain.Ticket{}, fmt.Errorf("create the Jira issue: %w", err)
	}
	t.Key, t.Source = key, domain.SourceJira
	ev.Message, ev.Data["child"] = "follow-up "+key+" filed in Jira: "+t.Title, key
	out, err := o.store.CreateFollowUp(ctx, p.ID, x.ID, t, ev)
	if err != nil {
		o.event(ctx, domain.Event{TicketKey: p.Key, Type: domain.EventError, Level: domain.LevelWarn,
			Message: fmt.Sprintf("Jira issue %s was created but agnts could not keep it: %v", key, err)})
		return out, err
	}
	if err := ic.LabelIssue(ctx, key, t.Kind); err != nil {
		o.event(ctx, domain.Event{TicketKey: key, Type: domain.EventTrackerComment, Level: domain.LevelWarn,
			Message: "could not label the Jira issue for agnts: " + err.Error()})
	}
	if p.Source == domain.SourceJira {
		if err := ic.LinkIssues(ctx, key, p.Key); err != nil {
			o.event(ctx, domain.Event{TicketKey: key, Type: domain.EventTrackerComment, Level: domain.LevelWarn,
				Message: "could not link the Jira issue to " + p.Key + ": " + err.Error()})
		}
	}
	return out, nil
}

// followUpDescription is the new ticket's description: the work, then why
// it exists, so its own analysis stays on the parent's goal.
func followUpDescription(p domain.Ticket, x domain.Suggestion, desc string) string {
	var b strings.Builder
	if desc != "" {
		b.WriteString(desc + "\n\n")
	}
	fmt.Fprintf(&b, "## Follow-up of %s: %s\n\n%s", p.Key, p.Title, x.Serves)
	return b.String()
}

// DismissSuggestion declines a suggestion; later runs are told not to
// suggest it again.
func (o *Orchestrator) DismissSuggestion(ctx context.Context, key string, id int64, origin domain.Origin) (domain.Suggestion, error) {
	p, err := o.store.TicketByKey(ctx, key)
	if err != nil {
		return domain.Suggestion{}, err
	}
	return o.store.DismissSuggestion(ctx, p.ID, id, domain.Event{
		TicketKey: key, Type: domain.EventTicketUpdated, Origin: origin, Message: "follow-up suggestion dismissed",
		Data: map[string]any{"suggestion": id},
	})
}

// SuggestFromFinding turns a finding of the ticket's newest code review
// into a suggestion, without asking Claude.
func (o *Orchestrator) SuggestFromFinding(ctx context.Context, key string, index int, origin domain.Origin) (domain.Suggestion, error) {
	t, err := o.store.TicketByKey(ctx, key)
	if err != nil {
		return domain.Suggestion{}, err
	}
	rv, err := o.latestReview(ctx, t.ID)
	if err != nil {
		return domain.Suggestion{}, err
	}
	if rv == nil {
		return domain.Suggestion{}, invalid("%s has no code review", key)
	}
	if index < 0 || index >= len(rv.Findings) {
		return domain.Suggestion{}, invalid("the review has no finding %d", index)
	}
	f := rv.Findings[index]
	var b strings.Builder
	if f.Detail != "" {
		b.WriteString(f.Detail + "\n\n")
	}
	if f.File != "" {
		ref := f.File
		if f.Line > 0 {
			ref = fmt.Sprintf("%s:%d", f.File, f.Line)
		}
		b.WriteString("Where: " + ref + "\n\n")
	}
	if f.Suggestion != "" {
		b.WriteString("Suggested fix: " + f.Suggestion)
	}
	priority := map[string]string{"blocker": "high", "major": "high", "minor": "medium", "nit": "low"}[f.Severity]
	x, ok := domain.FollowUp{
		Type: "unfinished", Title: f.Title, Description: strings.TrimSpace(b.String()), Kind: string(domain.KindCode), Priority: priority,
		Serves: fmt.Sprintf("The code review of %s found it (%s, %s).", key, f.Severity, f.Category),
	}.Suggestion(domain.SuggestFromManual)
	if !ok {
		return x, invalid("this finding cannot become a follow-up")
	}
	x.TicketID, x.Revision = t.ID, rv.Revision
	return o.store.AddSuggestion(ctx, x, domain.Event{
		TicketKey: key, Type: domain.EventTicketUpdated, Origin: origin, Message: "follow-up suggested from a review finding: " + x.Title,
		Data: map[string]any{"finding": index},
	})
}
