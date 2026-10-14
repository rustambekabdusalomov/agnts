package orchestrator

import (
	"context"
	"encoding/json"
	"fmt"
	"strings"
	"time"

	"agnts/internal/domain"
)

// SecondOpinionPath is where the second opinion run writes its read.
const SecondOpinionPath = "/agnts/out/second-opinion.json"

// secondOpinionDue reports whether another model reads the approach of t.
func secondOpinionDue(s domain.Settings, t domain.Ticket, a Analysis) bool {
	return s.SecondOpinion != "" && a.Complexity == ComplexityComplex && a.Chosen() != nil && !t.Kind.Report() && t.Kind != domain.KindReview
}

// secondOpinion has the second opinion model read the analysis and the
// code, in the analysis run's container, and say whether it agrees with
// the chosen approach. It is advice for the people deciding; nothing waits
// on it, and a failure is only recorded.
func (o *Orchestrator) secondOpinion(ctx context.Context, s domain.Settings, ws Workspace, t domain.Ticket, run *domain.Run, a Analysis, repos []RepoView) *domain.SecondOpinion {
	out := &domain.SecondOpinion{Model: s.SecondOpinion}
	prompt, err := render("secondopinion", promptData{T: t, Design: &a, Repos: repos})
	if err != nil {
		out.Error = err.Error()
		return out
	}
	res, err := ws.Claude(ctx, ClaudeRequest{
		Prompt: prompt, Model: s.SecondOpinion, MaxTurns: min(s.MaxTurns, 30), ReadOnly: true,
		Timeout:  time.Duration(min(s.TimeoutMin, 15)) * time.Minute,
		Settings: permissionSettings(s, true),
	}, func(e ClaudeEvent) {
		if e.Kind == ClaudeRateLimit {
			o.usage.Record(ctx, e.Data)
		}
	})
	o.recordSpend(ctx, run, "second_opinion", s.SecondOpinion, res)
	switch {
	case err != nil:
		out.Error = err.Error()
		return out
	case res.IsError:
		out.Error = fmt.Sprintf("ended with %s: %s", res.Subtype, truncate(res.Text, 300))
		return out
	}
	raw, err := ws.ReadFile(ctx, SecondOpinionPath)
	if err != nil {
		out.Error = "it wrote no second-opinion.json"
		return out
	}
	var got domain.SecondOpinion
	if err := json.Unmarshal(raw, &got); err != nil {
		out.Error = "second-opinion.json is not valid JSON"
		return out
	}
	out.Agrees, out.Summary, out.Alternative = got.Agrees, truncate(strings.TrimSpace(got.Summary), 2000), truncate(strings.TrimSpace(got.Alternative), 2000)
	for _, c := range got.Concerns {
		if c = strings.TrimSpace(c); c != "" && len(out.Concerns) < 8 {
			out.Concerns = append(out.Concerns, truncate(c, 500))
		}
	}
	return out
}

// secondOpinionEvent logs a second opinion on the ticket.
func secondOpinionEvent(key string, run *domain.Run, so *domain.SecondOpinion) domain.Event {
	msg, level := "", domain.LevelInfo
	switch {
	case so.Error != "":
		msg, level = "no second opinion: "+so.Error, domain.LevelWarn
	case so.Agrees:
		msg = fmt.Sprintf("second opinion (%s): agrees with the approach", so.Model)
	default:
		msg, level = fmt.Sprintf("second opinion (%s): has concerns about the approach", so.Model), domain.LevelWarn
	}
	return domain.Event{TicketKey: key, RunID: &run.ID, Step: string(run.Stage), Type: domain.EventSecondOpinion, Level: level, Message: msg,
		Data: map[string]any{"model": so.Model, "agrees": so.Agrees, "concerns": len(so.Concerns)}}
}
