package orchestrator

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"path"
	"slices"
	"strings"

	"agnts/internal/domain"
)

// AcceptancePath is where the acceptance check writes its verdicts.
const AcceptancePath = "/agnts/out/acceptance.json"

// Acceptance check limits: it runs after the preview, in its container.
const (
	acceptMaxTurns   = 40
	acceptTimeoutMin = 20
	acceptMaxShots   = 12
)

// acceptanceCriteria are the criteria of t's analysis agnts can check in
// the running app, when the repository asks for the check.
func (o *Orchestrator) acceptanceCriteria(ctx context.Context, t domain.Ticket, repo domain.Repository) []AcceptanceCriterion {
	if !repo.Harness.Acceptance || !repo.Preview.Enabled() {
		return nil
	}
	a := o.latestAnalysis(ctx, t)
	if a == nil {
		return nil
	}
	var out []AcceptanceCriterion
	for _, c := range a.Acceptance {
		if (c.Check == "ui" || c.Check == "api") && strings.TrimSpace(c.Criterion) != "" {
			out = append(out, c)
		}
	}
	return out
}

// checkAcceptance has Claude check each criterion in the running app with
// agnts-act, and copies the screenshots it took out of the run.
func (o *Orchestrator) checkAcceptance(ctx context.Context, s domain.Settings, ws Workspace, t domain.Ticket, run *domain.Run, repo domain.Repository,
	criteria []AcceptanceCriterion) (*domain.Acceptance, []domain.Shot, error) {
	prompt, err := render("accept", promptData{T: t, Repo: repo, Criteria: criteria})
	if err != nil {
		return nil, nil, err
	}
	as := s
	as.MaxTurns = min(s.MaxTurns, acceptMaxTurns)
	as.TimeoutMin = min(s.TimeoutMin, acceptTimeoutMin)
	if _, err := o.claude(ctx, as, ws, &t, run, domain.ModelPreview, prompt, ""); err != nil {
		return nil, nil, err
	}
	raw, err := ws.ReadFile(ctx, AcceptancePath)
	if err != nil {
		return nil, nil, fmt.Errorf("claude did not write %s: %w", AcceptancePath, err)
	}
	var got struct {
		domain.Acceptance
		Shots []struct {
			ID   string `json:"id"`
			File string `json:"file"`
			Name string `json:"name"`
		} `json:"shots"`
	}
	if err := json.Unmarshal(raw, &got); err != nil {
		return nil, nil, fmt.Errorf("acceptance.json is not valid JSON: %w", err)
	}
	acc := normalizeAcceptance(got.Acceptance, criteria)
	var shots []domain.Shot
	for _, c := range acc.Criteria {
		for _, id := range c.Shots {
			if len(shots) == acceptMaxShots || !shotID(id) || slices.ContainsFunc(shots, func(x domain.Shot) bool { return x.ID == "acc-"+id }) {
				continue
			}
			b, err := ws.ReadFile(ctx, path.Join(previewOutDir, "shots", id+".png"))
			if err != nil {
				continue
			}
			w, h, ok := pngSize(b)
			if !ok || len(b) > previewMaxShotBytes {
				continue
			}
			if err := o.shots.Save(t.WorkspaceID, t.Key, run.ID, "acc-"+id, b); err != nil {
				return &acc, shots, fmt.Errorf("save screenshot %s: %w", id, err)
			}
			shots = append(shots, domain.Shot{ID: "acc-" + id, Name: "Acceptance " + c.ID + ": " + truncate(c.Criterion, 80), Viewport: "desktop",
				Side: "after", Note: c.Verdict, Width: w, Height: h})
		}
	}
	for i, c := range acc.Criteria {
		var kept []string
		for _, id := range c.Shots {
			if slices.ContainsFunc(shots, func(x domain.Shot) bool { return x.ID == "acc-"+id }) {
				kept = append(kept, "acc-"+id)
			}
		}
		acc.Criteria[i].Shots = kept
	}
	return &acc, shots, nil
}

// shotID reports whether id is a safe screenshot id.
func shotID(id string) bool {
	if id == "" || len(id) > 80 {
		return false
	}
	for _, c := range id {
		if (c < 'a' || c > 'z') && (c < '0' || c > '9') && c != '-' {
			return false
		}
	}
	return true
}

// normalizeAcceptance keeps one verdict per criterion the analysis listed
// (unknown when Claude skipped one) and settles the overall status.
func normalizeAcceptance(got domain.Acceptance, criteria []AcceptanceCriterion) domain.Acceptance {
	out := domain.Acceptance{Summary: truncate(strings.TrimSpace(got.Summary), 2000)}
	pass, fail := 0, 0
	for _, c := range criteria {
		v := domain.AcceptanceCriterion{ID: c.ID, Criterion: c.Criterion, Verdict: "unknown"}
		for _, g := range got.Criteria {
			if g.ID != c.ID {
				continue
			}
			if slices.Contains([]string{"pass", "fail", "unknown"}, g.Verdict) {
				v.Verdict = g.Verdict
			}
			v.Evidence = truncate(strings.TrimSpace(g.Evidence), 1500)
			for _, st := range g.Steps {
				if len(v.Steps) < 20 {
					v.Steps = append(v.Steps, truncate(st, 300))
				}
			}
			v.Shots = g.Shots
		}
		switch v.Verdict {
		case "pass":
			pass++
		case "fail":
			fail++
		}
		out.Criteria = append(out.Criteria, v)
	}
	switch {
	case fail > 0:
		out.Status = "failed"
	case pass == len(criteria) && pass > 0:
		out.Status = "ok"
	default:
		out.Status = "partial"
	}
	return out
}

// failedCriteria are the criteria the check found not met.
func failedCriteria(a *domain.Acceptance) []domain.AcceptanceCriterion {
	if a == nil {
		return nil
	}
	var out []domain.AcceptanceCriterion
	for _, c := range a.Criteria {
		if c.Verdict == "fail" {
			out = append(out, c)
		}
	}
	return out
}

// acceptanceFeedback is what the coder reads when the acceptance check
// sends a change back.
func acceptanceFeedback(fs []domain.AcceptanceCriterion) string {
	var b strings.Builder
	b.WriteString("agnts checked the ticket's acceptance criteria in the running app before a person looked at the change, and these are not met. Fix each one, or, if a check was wrong, leave the code and explain why in the notes:\n")
	for i, c := range fs {
		fmt.Fprintf(&b, "\n%d. %s", i+1, c.Criterion)
		if c.Evidence != "" {
			b.WriteString("\n   What happened: " + strings.ReplaceAll(c.Evidence, "\n", "\n   "))
		}
		if len(c.Steps) > 0 {
			b.WriteString("\n   Steps: " + strings.Join(c.Steps, " → "))
		}
	}
	return b.String()
}

// afterAcceptance sends a change whose criteria failed back to the coder,
// once, while agnts is still checking it before a person does.
func (o *Orchestrator) afterAcceptance(ctx context.Context, t domain.Ticket, run *domain.Run, acc *domain.Acceptance) error {
	fs := failedCriteria(acc)
	if len(fs) == 0 {
		return nil
	}
	cur, err := o.store.TicketByKey(ctx, t.Key)
	if err != nil {
		return err
	}
	if cur.State != domain.StateWaitingForReview || !cur.QuietReview || cur.SelfFixes >= maxSelfFixes || cur.Revision != t.Revision {
		return nil // a person may be looking already, or agnts sent it back once
	}
	msg := fmt.Sprintf("the acceptance check found %d %s not met; sent back to fix before your review", len(fs), plural(len(fs), "criterion", "criteria"))
	_, err = o.store.Transition(ctx, t.Key, domain.StateCoding, domain.Event{
		TicketKey: t.Key, RunID: &run.ID, Type: domain.EventFeedback, Origin: domain.OriginSystem, Step: string(domain.StagePreview),
		Message: msg, Data: map[string]any{"self": true, "acceptance": len(fs)},
	}, func(x *domain.Ticket) {
		x.Revision++
		x.Feedback = acceptanceFeedback(fs)
		x.FeedbackShots, x.FeedbackFiles = nil, nil
		x.SelfFixes++
		x.QuietReview = false
		x.ReviewState = domain.ReviewNone
	})
	var te *domain.TransitionError
	if errors.As(err, &te) {
		return nil
	}
	if err == nil {
		o.Wake()
	}
	return err
}
