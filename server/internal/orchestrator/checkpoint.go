package orchestrator

import (
	"context"
	"fmt"
	"slices"
	"strings"
	"time"

	"agnts/internal/ai"
	"agnts/internal/domain"
)

// checkpointMinTurns is the smallest turn limit a coding run gets a drift
// checkpoint at: below it, a third of the turns is too few to judge.
const checkpointMinTurns = 45

// codeWithCheckpoint runs the coding invocation. A first run that has a
// plan to drift from stops at a third of its turns: agnts lists what it
// changed so far, compares that with the plan, and resumes the session
// with a checkpoint prompt that asks Claude to get back on course before
// it finishes.
func (o *Orchestrator) codeWithCheckpoint(ctx context.Context, s domain.Settings, ws Workspace, t *domain.Ticket, run *domain.Run, rs []runRepo, modelStage, prompt, session string, design *Analysis) (ai.Result, error) {
	// The same budget claudeTurns gives the run: tickets in several
	// repositories get more turns.
	total := int(float64(s.MaxTurns) * domain.TurnScale(len(t.Repos)))
	at := 0
	// Muse is told to wrap up before its call cap (agnts-muse's SteerAt), so
	// a checkpoint cap would end its run instead of pausing it.
	if design != nil && (design.Chosen() != nil || design.Footprint != nil) && total >= checkpointMinTurns &&
		!domain.IsMuse(s.ModelFor(*t, modelStage)) {
		at = total / 3
	}
	res, err := o.claudeTurns(ctx, s, ws, t, run, modelStage, prompt, session, at)
	if err != nil || at == 0 || !res.IsError || res.Subtype != "error_max_turns" {
		return res, err
	}
	changed := changedFiles(ctx, ws, rs)
	var outside []string
	if design.Footprint != nil {
		if pred := design.Footprint.Clean().Files; len(pred) > 0 {
			for _, f := range changed {
				if !slices.Contains(pred, f) {
					outside = append(outside, f)
				}
			}
		}
	}
	msg := fmt.Sprintf("checkpoint after %d turns: %d %s changed", res.Turns, len(changed), plural(len(changed), "file", "files"))
	if len(outside) > 0 {
		msg += fmt.Sprintf(", %d outside the plan", len(outside))
	}
	o.event(ctx, domain.Event{TicketKey: t.Key, RunID: &run.ID, Step: string(run.Stage), Type: domain.EventCheckpoint, Message: msg,
		Data: map[string]any{"turns": res.Turns, "changed": len(changed), "outside": outside}})
	cp, err := render("checkpoint", promptData{Design: design, Changed: changed, Outside: outside})
	if err != nil {
		return res, err
	}
	return o.claudeTurns(ctx, s, ws, t, run, modelStage, cp, res.SessionID, max(total-res.Turns, 10))
}

// changedFiles lists the files changed in the run's repositories so far,
// at most 100, as paths from /workspace.
func changedFiles(ctx context.Context, ws Workspace, rs []runRepo) []string {
	if len(rs) == 0 {
		return changedIn(ctx, ws, runRepo{})
	}
	var out []string
	for _, r := range rs {
		for _, p := range changedIn(ctx, ws, r) {
			if len(out) < 100 {
				out = append(out, r.Rel(p))
			}
		}
	}
	return out
}

// changedIn lists the files changed in one repository of a run so far, at
// most 100, relative to it.
func changedIn(ctx context.Context, ws Workspace, r runRepo) []string {
	res, err := ws.Exec(ctx, r.Cmd("git status --porcelain --untracked-files=all"), time.Minute)
	if err != nil || res.ExitCode != 0 {
		return nil
	}
	var out []string
	for _, l := range strings.Split(res.Output, "\n") {
		if len(l) < 4 {
			continue
		}
		p := strings.TrimSpace(l[3:])
		if i := strings.Index(p, " -> "); i >= 0 {
			p = p[i+4:] // a rename: the new name
		}
		if p = strings.Trim(p, `"`); p != "" && len(out) < 100 {
			out = append(out, p)
		}
	}
	return out
}
