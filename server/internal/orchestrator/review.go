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

// Limits of the review stage: it runs beside the human review, so it gets
// a smaller budget than coding.
const (
	reviewMaxTurns   = 40
	reviewTimeoutMin = 20
	reviewMaxFiles   = 200 // listed in the prompt, which goes through argv
)

// With the review model on auto, any of these makes a ticket complex enough
// for the larger model.
const (
	complexFiles     = 10    // changed files
	complexLines     = 400   // added plus deleted lines
	complexReport    = 20000 // bytes of report
	complexRevisions = 2     // rounds of requested changes
)

// Complexity ratings the analysis gives a ticket.
const (
	ComplexitySimple  = "simple"
	ComplexityComplex = "complex"
)

// reviewModel picks the review model: a choice for the ticket wins, then
// one set in Settings; on auto, the larger model reviews complex tickets.
// It returns the model and why it was picked.
func reviewModel(s domain.Settings, t domain.Ticket, a *Analysis, res domain.Result) (string, string) {
	if m := t.Models[domain.ModelReview]; slices.Contains(domain.Models, m) {
		return m, "chosen for this ticket"
	}
	if m := s.Models.Review; slices.Contains(domain.Models, m) {
		return m, "set in Settings"
	}
	lines := 0
	for _, f := range res.Files {
		lines += f.Add + f.Del
	}
	switch {
	case a != nil && a.Complexity == ComplexityComplex:
		return "opus", "the analysis rated this ticket complex"
	case len(res.Files) >= complexFiles || lines >= complexLines:
		return "opus", fmt.Sprintf("a large change (%d %s, %d lines)", len(res.Files), plural(len(res.Files), "file", "files"), lines)
	case len(res.Report) >= complexReport:
		return "opus", "a long report"
	case t.Revision >= complexRevisions:
		return "opus", fmt.Sprintf("changes were requested %d times", t.Revision)
	}
	return "sonnet", "a simple ticket"
}

// parseReview reads review.json and cleans it.
func parseReview(b []byte) (domain.Review, error) {
	var r domain.Review
	if err := json.Unmarshal(b, &r); err != nil {
		return r, fmt.Errorf("review.json is not valid JSON: %w", err)
	}
	if !r.Normalize() {
		return r, errors.New("review.json has no summary")
	}
	return r, nil
}

// reviewState is the review state a ticket gets as it reaches review.
func reviewState(s domain.Settings) string {
	if s.AutoReview {
		return domain.ReviewPending
	}
	return domain.ReviewNone
}

// dropReview forgets a queued or running review of a ticket leaving
// review; it reports whether a review run may be running.
func dropReview(x *domain.Ticket) bool {
	running := x.ReviewState == domain.ReviewRunning
	if running || x.ReviewState == domain.ReviewPending {
		x.ReviewState = domain.ReviewNone
	}
	return running
}

// Review queues a code review of a ticket waiting for review (again, if
// one already ran).
func (o *Orchestrator) Review(ctx context.Context, key string, origin domain.Origin) (domain.Ticket, error) {
	t, err := o.store.TicketByKey(ctx, key)
	if err != nil {
		return t, err
	}
	if t.State != domain.StateWaitingForReview {
		return t, invalid("agnts reviews a ticket while it waits for your review")
	}
	if t.ReviewState == domain.ReviewPending || t.ReviewState == domain.ReviewRunning {
		return t, nil
	}
	t, err = o.store.UpdateTicket(ctx, key, &domain.Event{
		TicketKey: key, Type: domain.EventTicketUpdated, Origin: origin, Step: string(domain.StageReview), Message: "queued for code review",
	}, func(x *domain.Ticket) {
		if x.State == domain.StateWaitingForReview {
			x.ReviewState = domain.ReviewPending
		}
	})
	if err == nil {
		o.Wake()
	}
	return t, err
}

// review reads the result waiting for review (a diff, or a report) and
// writes findings for the reviewer. It never changes the ticket's state.
func (o *Orchestrator) review(ctx context.Context, s domain.Settings, t domain.Ticket, run *domain.Run) error {
	res, err := o.store.LatestResult(ctx, t.ID, domain.StageCode)
	if err != nil {
		return fmt.Errorf("load the result to review: %w", err)
	}
	report := t.Kind.Report()
	if report && strings.TrimSpace(res.Report) == "" {
		return errors.New("no report to review")
	}
	if !report && len(res.Files) == 0 {
		return errors.New("no change to review")
	}
	repo, err := o.optionalRepo(ctx, t)
	if err != nil {
		return err
	}

	d := promptData{T: t, NoRepo: repo == nil}
	var a *Analysis
	if r, err := o.store.LatestResult(ctx, t.ID, domain.StageAnalyze); err == nil {
		if x, err := parseAnalysis(r.Summary); err == nil {
			a, d.Plan = &x, x.Plan
		}
	}
	if d.Answers, err = o.store.Questions(ctx, t.ID); err != nil {
		return err
	}
	if d.Rules, err = o.teamRules(ctx, t.RepoID); err != nil {
		return err
	}
	var sum Summary
	_ = json.Unmarshal(res.Summary, &sum)
	d.WorkSummary, d.Notes = sum.Summary, sum.Notes
	_ = json.Unmarshal(res.Tests, &d.CheckSteps)
	d.Files = res.Files
	if len(d.Files) > reviewMaxFiles {
		d.Files = d.Files[:reviewMaxFiles]
	}

	branch := ""
	if repo != nil {
		d.Repo, branch = *repo, repo.DefaultBranch
		if !report {
			branch = t.Branch // the reviewed commit
		}
	}
	ws, err := o.openWorkspace(ctx, t, repo, branch, run)
	if err != nil {
		return err
	}
	defer o.closeWorkspace(ctx, t, ws)
	if report {
		err = ws.WriteFile(ctx, ReportPath, []byte(res.Report))
	} else {
		err = ws.WriteFile(ctx, ChangePath, changeDiff(res.Files))
	}
	if err != nil {
		return fmt.Errorf("copy the work into the workspace: %w", err)
	}

	model, why := reviewModel(s, t, a, res)
	o.event(ctx, domain.Event{TicketKey: t.Key, RunID: &run.ID, Step: string(domain.StageReview), Type: domain.EventClaudeText,
		Message: fmt.Sprintf("reviewing with %s: %s", model, why), Data: map[string]any{"model": model, "reason": why}})
	prompt, err := render("review", d)
	if err == nil {
		prompt, err = o.withFollowUps(ctx, s, t, d, domain.SuggestFromReview, ReviewPath, prompt)
	}
	if err != nil {
		return err
	}
	rs := s
	rs.Models.Review = model
	rs.MaxTurns = min(s.MaxTurns, reviewMaxTurns)
	rs.TimeoutMin = min(s.TimeoutMin, reviewTimeoutMin)
	if _, err := o.claude(ctx, rs, ws, &t, run, domain.ModelReview, prompt, ""); err != nil {
		var stop *stopError
		if errors.As(err, &stop) {
			// Rate limited: claimed again once usage allows.
			o.setReviewState(context.WithoutCancel(ctx), t, domain.ReviewPending)
		}
		return err
	}
	raw, err := ws.ReadFile(ctx, ReviewPath)
	if err != nil {
		return fmt.Errorf("claude did not write %s: %w", ReviewPath, err)
	}
	rv, err := parseReview(raw)
	if err != nil {
		return err
	}
	rv.Revision, rv.Model, rv.ModelReason = t.Revision, model, why
	o.saveFollowUps(ctx, s, t, run, domain.SuggestFromReview, rv.FollowUps)
	rv.FollowUps = nil // kept as suggestions
	b, _ := json.Marshal(rv)
	if err := o.store.SaveResult(ctx, domain.Result{RunID: run.ID, Summary: b}); err != nil {
		return err
	}
	ev := reviewEvent(t.Key, run, rv)
	_, err = o.store.UpdateTicket(ctx, t.Key, &ev, func(x *domain.Ticket) {
		if x.ReviewState == domain.ReviewRunning && x.Revision == t.Revision {
			x.ReviewState = domain.ReviewDone
		}
	})
	return err
}

// reviewEvent is the log line for a finished review; the notifier
// announces it.
func reviewEvent(key string, run *domain.Run, rv domain.Review) domain.Event {
	counts := rv.Counts()
	var parts []string
	for _, sev := range domain.FindingSeverities {
		if n := counts[sev]; n > 0 {
			parts = append(parts, fmt.Sprintf("%d %s", n, sev))
		}
	}
	msg := "code review: " + strings.ReplaceAll(rv.Verdict, "_", " ")
	if len(parts) > 0 {
		msg += " (" + strings.Join(parts, ", ") + ")"
	}
	return domain.Event{
		TicketKey: key, RunID: &run.ID, Step: string(domain.StageReview), Type: domain.EventReview, Message: msg,
		Data: map[string]any{"verdict": rv.Verdict, "findings": len(rv.Findings), "counts": counts, "worst": rv.Worst(),
			"revision": rv.Revision, "model": rv.Model},
	}
}

// setReviewState moves a running review of t's revision to state.
func (o *Orchestrator) setReviewState(ctx context.Context, t domain.Ticket, state string) {
	if _, err := o.store.UpdateTicket(ctx, t.Key, nil, func(x *domain.Ticket) {
		if x.ReviewState == domain.ReviewRunning && x.Revision == t.Revision {
			x.ReviewState = state
		}
	}); err != nil {
		o.log.Error("set review state", "ticket", t.Key, "err", err)
	}
}

// reviewFailed records a failed review run. The ticket stays in review.
func (o *Orchestrator) reviewFailed(ctx context.Context, t domain.Ticket, run domain.Run, cause error) {
	if _, err := o.store.UpdateTicket(ctx, t.Key, &domain.Event{
		TicketKey: t.Key, RunID: &run.ID, Type: domain.EventError, Level: domain.LevelWarn, Step: string(domain.StageReview),
		Message: "the code review failed: " + cause.Error(),
	}, func(x *domain.Ticket) {
		if x.ReviewState == domain.ReviewRunning && x.Revision == t.Revision {
			x.ReviewState = domain.ReviewFailed
		}
	}); err != nil {
		o.log.Error("mark review failed", "ticket", t.Key, "err", err)
	}
}

// latestReview returns the newest review of a ticket, or nil.
func (o *Orchestrator) latestReview(ctx context.Context, ticketID int64) (*domain.Review, error) {
	r, err := o.store.LatestResult(ctx, ticketID, domain.StageReview)
	if errors.Is(err, domain.ErrNotFound) {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}
	var rv domain.Review
	if json.Unmarshal(r.Summary, &rv) != nil || rv.Summary == "" {
		return nil, nil
	}
	rv.CreatedAt = r.CreatedAt
	return &rv, nil
}
