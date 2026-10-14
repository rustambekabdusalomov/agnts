package orchestrator

import (
	"context"
	"errors"
	"fmt"
	"strings"

	"agnts/internal/domain"
)

// CIPrefix is the key prefix of tickets opened for failing CI.
const CIPrefix = "CI"

// Reopener sends a done ticket with an open pull request back to coding.
// The store implements it; it is not part of Store so fakes need not.
type Reopener interface {
	ReopenForCI(ctx context.Context, key string, ev domain.Event, mut func(*domain.Ticket)) (domain.Ticket, error)
}

// CIHook hears about tickets CI watching cares about.
type CIHook interface {
	// TicketMerged is called after a ticket's pull request is merged.
	TicketMerged(ctx context.Context, t domain.Ticket)
}

// SetCIHook sets the hook (nil for none). Call it before Run.
func (o *Orchestrator) SetCIHook(h CIHook) { o.ciHook = h }

// CIFeedbackResult says what a red check on a ticket's pull request did.
type CIFeedbackResult string

// CI feedback results.
const (
	CIFeedbackSent    CIFeedbackResult = "sent"    // the ticket went back to coding
	CIFeedbackCapped  CIFeedbackResult = "capped"  // it already had its rounds
	CIFeedbackSkipped CIFeedbackResult = "skipped" // not a ticket that can be reopened
)

// CIFeedback sends failing CI on a ticket's open pull request in repoID
// back to coding with the failures as feedback, at most rounds times per
// pull request. The fix goes through checks and review again and is pushed
// to the same pull request after approval, like any change.
func (o *Orchestrator) CIFeedback(ctx context.Context, key string, repoID int64, feedback, runURL string, rounds int) (domain.Ticket, CIFeedbackResult, error) {
	t, err := o.store.TicketByKey(ctx, key)
	if err != nil {
		return t, CIFeedbackSkipped, err
	}
	if !domain.CanReopenForCIIn(t, repoID) {
		return t, CIFeedbackSkipped, nil
	}
	r, _ := t.RepoState(repoID)
	where := ""
	if t.Multi() {
		where = r.RepoName + ": "
		feedback = fmt.Sprintf("This CI failure is in the repository %s (%s/).\n\n%s", r.RepoName, r.Folder, feedback)
	}
	if r.CIFixes >= rounds {
		o.event(ctx, domain.Event{TicketKey: key, Type: domain.EventCIFailure, Origin: domain.OriginWebhook, Level: domain.LevelWarn,
			Message: fmt.Sprintf("%sCI still fails on the pull request after %d automatic fix rounds; look at it by hand", where, r.CIFixes),
			Data:    map[string]any{"url": runURL, "capped": true, "repoId": repoID}})
		return t, CIFeedbackCapped, nil
	}
	ro, ok := o.store.(Reopener)
	if !ok {
		return t, CIFeedbackSkipped, errors.New("the store cannot reopen tickets")
	}
	ev := domain.Event{TicketKey: key, Type: domain.EventFeedback, Origin: domain.OriginWebhook,
		Message: where + "CI failed on the pull request: " + firstLineOf(feedback), Data: map[string]any{"ci": true, "url": runURL, "repoId": repoID}}
	reviewing := false
	out, err := ro.ReopenForCI(ctx, key, ev, func(x *domain.Ticket) {
		x.Revision++
		x.Feedback = feedback
		x.FeedbackShots, x.FeedbackFiles = nil, nil
		x.UpdateRepo(repoID, func(r *domain.TicketRepo) { r.CIFixes++ })
		x.SelfFixes, x.QuietReview = 0, false
		reviewing = dropSideRuns(x)
	})
	if err != nil {
		return out, CIFeedbackSkipped, err
	}
	if reviewing {
		o.cancelRun(ctx, key)
	}
	o.Wake()
	return out, CIFeedbackSent, nil
}

func firstLineOf(s string) string {
	s, _, _ = strings.Cut(strings.TrimSpace(s), "\n")
	if r := []rune(s); len(r) > 200 {
		s = string(r[:199]) + "…"
	}
	return s
}

// CITicketInput is a CI failure to turn into a ticket.
type CITicketInput struct {
	RepoID      int64
	Title       string
	Description string
	Priority    string
	// Log is the redacted log excerpt, attached as ci-log.txt so the run
	// can read all of it while the prompt stays short.
	Log string
}

// CreateCITicket opens a code ticket (the analysis may switch it to a bug
// report) for a CI failure. It never asks questions first: nobody waits
// for them at 3 a.m.; open questions go into the report.
func (o *Orchestrator) CreateCITicket(ctx context.Context, in CITicketInput, origin domain.Origin) (domain.Ticket, error) {
	repo, err := o.store.RepositoryByID(ctx, in.RepoID)
	if err != nil {
		return domain.Ticket{}, err
	}
	if repo.ArchivedAt != nil {
		return domain.Ticket{}, invalid("%s is archived", repo.Name)
	}
	if in.Priority == "" {
		in.Priority = "high"
	}
	var files []int64
	if strings.TrimSpace(in.Log) != "" {
		a, err := o.Upload(ctx, "ci-log.txt", []byte(in.Log))
		if err != nil {
			o.log.Warn("ci log attachment", "err", err)
		} else {
			files = []int64{a.ID}
		}
	}
	title := strings.TrimSpace(in.Title)
	if r := []rune(title); len(r) > 200 {
		title = string(r[:199]) + "…"
	}
	return o.createTask(ctx, domain.Ticket{
		Source: domain.SourceCI, RepoID: &repo.ID, Title: title, Description: strings.TrimSpace(in.Description),
		Priority: in.Priority, State: domain.StateNew, ResumeState: domain.StateNew, AfterApprove: "pr",
		AskFirst: false, Kind: domain.KindCode, KindAuto: true,
	}, CIPrefix, files, origin)
}
