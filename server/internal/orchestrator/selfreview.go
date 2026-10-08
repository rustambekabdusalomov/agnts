package orchestrator

import (
	"context"
	"errors"
	"fmt"
	"strings"

	"agnts/internal/domain"
)

// maxSelfFixes is how many rounds agnts's own review may send a change
// back before a person sees it, per change request by a person.
const maxSelfFixes = 1

// selfReviewDue reports whether agnts's own review of t's next result may
// still send it back to the coder: the ticket then reaches review quietly.
func selfReviewDue(s domain.Settings, t domain.Ticket) bool {
	return s.SelfReview && s.AutoReview && !t.Kind.Report() && t.SelfFixes < maxSelfFixes
}

// seriousFindings are the blocker and major findings of a review.
func seriousFindings(rv domain.Review) []domain.Finding {
	var out []domain.Finding
	for _, f := range rv.Findings {
		if f.Severity == "blocker" || f.Severity == "major" {
			out = append(out, f)
		}
	}
	return out
}

// selfFixFeedback is what the coder reads when agnts's review sends the
// change back.
func selfFixFeedback(fs []domain.Finding) string {
	var b strings.Builder
	b.WriteString("agnts's code review found these problems before a person looked at the change. Fix each one, ")
	b.WriteString("or, if one is not a real problem, leave the code and explain why in the notes:\n")
	for i, f := range fs {
		fmt.Fprintf(&b, "\n%d. [%s, %s] %s", i+1, f.Severity, f.Category, f.Title)
		if f.File != "" {
			fmt.Fprintf(&b, " (%s", f.File)
			if f.Line > 0 {
				fmt.Fprintf(&b, ":%d", f.Line)
			}
			b.WriteString(")")
		}
		if f.Detail != "" {
			b.WriteString("\n   " + strings.ReplaceAll(f.Detail, "\n", "\n   "))
		}
		if f.Suggestion != "" {
			b.WriteString("\n   Suggestion: " + strings.ReplaceAll(f.Suggestion, "\n", "\n   "))
		}
	}
	return b.String()
}

// afterReview acts on a finished review of a ticket that reached review
// quietly: serious findings go back to the coder once; otherwise the
// ticket is announced to the people who review it.
func (o *Orchestrator) afterReview(ctx context.Context, s domain.Settings, t domain.Ticket, run *domain.Run, rv domain.Review) error {
	fs := seriousFindings(rv)
	if len(fs) == 0 || !selfReviewDue(s, t) {
		o.announceQuiet(ctx, t.Key, run, "agnts's code review: "+strings.ReplaceAll(rv.Verdict, "_", " "))
		return nil
	}
	cur, err := o.store.TicketByKey(ctx, t.Key)
	if err != nil {
		return err
	}
	if cur.State != domain.StateWaitingForReview || cur.Revision != t.Revision {
		return nil // a person acted on it meanwhile
	}
	msg := fmt.Sprintf("agnts's code review found %d serious %s; sent back to fix before your review", len(fs), plural(len(fs), "problem", "problems"))
	_, err = o.store.Transition(ctx, t.Key, domain.StateCoding, domain.Event{
		TicketKey: t.Key, RunID: &run.ID, Type: domain.EventFeedback, Origin: domain.OriginSystem, Step: string(domain.StageReview),
		Message: msg, Data: map[string]any{"self": true, "findings": len(fs)},
	}, func(x *domain.Ticket) {
		x.Revision++
		x.Feedback = selfFixFeedback(fs)
		x.FeedbackShots, x.FeedbackFiles = nil, nil
		x.SelfFixes++
		x.QuietReview = false
		if x.PreviewState == domain.PreviewPending {
			x.PreviewState = domain.PreviewNone // it would show the old revision
		}
	})
	var te *domain.TransitionError
	if errors.As(err, &te) {
		return nil // moved on meanwhile
	}
	if err == nil {
		o.Wake()
	}
	return err
}

// announceQuiet announces a ticket that reached review quietly, once: the
// people who review it learn it waits for them.
func (o *Orchestrator) announceQuiet(ctx context.Context, key string, run *domain.Run, why string) {
	announce := false
	_, err := o.store.UpdateTicket(ctx, key, nil, func(x *domain.Ticket) {
		announce = x.QuietReview && x.State == domain.StateWaitingForReview
		x.QuietReview = false
	})
	if err != nil {
		o.log.Warn("announce review", "ticket", key, "err", err)
		return
	}
	if !announce {
		return
	}
	ev := domain.Event{TicketKey: key, Type: domain.EventReadyForReview, Step: string(domain.StageReview),
		Message: "ready for your review (" + why + ")", Data: map[string]any{"to": string(domain.StateWaitingForReview)}}
	if run != nil {
		ev.RunID = &run.ID
	}
	o.event(ctx, ev)
}
