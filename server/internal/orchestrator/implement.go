package orchestrator

import (
	"context"
	"errors"
	"fmt"
	"slices"
	"strings"

	"agnts/internal/domain"
)

// ImplementInput makes a code task from an approved plan or bug report.
type ImplementInput struct {
	RepoID int64  // 0: the report's own repository
	Start  string // code (default: no questions, the report settled them) or queue
}

// Implement creates the code task that carries out a done plan or bug
// report. The task is local (agnts cannot file a Jira issue), linked back by
// ParentKey, and has the approved report in its description, so the
// analysis checks it against today's code and the coding prompt follows it.
// A report is implemented once.
func (o *Orchestrator) Implement(ctx context.Context, key string, in ImplementInput, origin domain.Origin) (domain.Ticket, error) {
	if in.Start == "" {
		in.Start = "code"
	}
	if in.Start != "code" && in.Start != "queue" {
		return domain.Ticket{}, invalid("start must be code or queue")
	}
	p, err := o.store.TicketByKey(ctx, key)
	if err != nil {
		return p, err
	}
	if !p.Kind.Spec().Implementable {
		return p, invalid("only a plan or a bug investigation can be implemented; %s is %s", key, p.Kind)
	}
	if p.State != domain.StateDone {
		return p, &domain.TransitionError{Key: key, From: p.State, To: domain.StateDone}
	}
	if c, err := o.store.ChildOf(ctx, key); err == nil {
		return c, invalid("%s is already implemented by %s", key, c.Key)
	} else if !errors.Is(err, domain.ErrNotFound) {
		return p, err
	}
	r, err := o.store.LatestResult(ctx, p.ID, domain.StageCode)
	if errors.Is(err, domain.ErrNotFound) || (err == nil && strings.TrimSpace(r.Report) == "") {
		return p, invalid("%s has no report to implement", key)
	}
	if err != nil {
		return p, err
	}

	repoID := in.RepoID
	if repoID == 0 && p.RepoID != nil {
		repoID = *p.RepoID
	}
	if repoID == 0 {
		return p, invalid("%s has no repository: pick the one to implement it in", key)
	}
	repo, err := o.store.RepositoryByID(ctx, repoID)
	if errors.Is(err, domain.ErrNotFound) {
		return p, invalid("no repository %d", repoID)
	}
	if err != nil {
		return p, err
	}
	if repo.ArchivedAt != nil {
		return p, invalid("%s is archived: restore it on the Repositories page first", repo.Name)
	}

	title, heading := "Implement: "+p.Title, "Approved plan"
	if p.Kind == domain.KindBug {
		title, heading = "Fix: "+p.Title, "Approved bug investigation"
	}
	desc := fmt.Sprintf("Carries out %s, approved in agnts. Follow it unless the code has changed in a way it did not foresee; say so in the notes when you depart from it.\n\n## %s (%s)\n\n%s",
		p.Key, heading, p.Key, strings.TrimSpace(r.Report))
	if d := strings.TrimSpace(p.Description); d != "" {
		desc += "\n\n## Original ticket " + p.Key + "\n\n" + d
	}
	priority := p.Priority
	if !slices.Contains([]string{"low", "medium", "high"}, priority) {
		priority = "medium"
	}
	t, err := o.createTask(ctx, domain.Ticket{
		Source: domain.SourceLocal, RepoID: &repo.ID, Title: truncate(title, 300), Description: desc, Priority: priority,
		State: domain.StateNew, ResumeState: domain.StateNew, AfterApprove: "pr", Held: in.Start == "queue",
		Kind: domain.KindCode, ParentKey: p.Key,
	}, TaskPrefix(repo), origin)
	if err != nil {
		return t, err
	}
	o.event(ctx, domain.Event{TicketKey: p.Key, Type: domain.EventTicketUpdated, Origin: origin,
		Message: "implementation task " + t.Key + " created", Data: map[string]any{"child": t.Key}})
	return t, nil
}
