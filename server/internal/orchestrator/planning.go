package orchestrator

import (
	"context"
	"encoding/json"
	"fmt"
	"slices"
	"strings"
	"time"

	"agnts/internal/domain"
)

// Before any code is written, agnts makes the analysis worth following:
// the coding model re-checks the analysis of a complex ticket, and every
// file the analysis says to copy or reuse must exist.

// recheckDue reports whether the coding model re-checks analysis a of t:
// a complex code or test ticket analysed by another model of the same
// module, as the re-check resumes the analysis's session and a module
// cannot resume another's.
func recheckDue(s domain.Settings, t domain.Ticket, a Analysis) bool {
	analyze, recheck := s.ModelFor(t, domain.ModelAnalyze), s.ModelFor(t, domain.ModelRecheck)
	return s.RecheckComplex && a.Complexity == ComplexityComplex && !t.Kind.Report() && t.Kind != domain.KindReview &&
		analyze != recheck && domain.ProviderOf(analyze) == domain.ProviderOf(recheck)
}

// recheckTurns caps the re-check and the fix of the analysis's paths.
const recheckTurns = 30

// refineAnalysis re-checks a complex analysis with the coding model, then
// makes sure the files it says to copy or reuse exist: an analysis naming
// missing files is asked once to fix them, and what is still missing is
// dropped. It returns the analysis to keep and its raw JSON.
func (o *Orchestrator) refineAnalysis(ctx context.Context, s domain.Settings, ws Workspace, t *domain.Ticket, run *domain.Run, raw []byte, a Analysis) ([]byte, Analysis, error) {
	stage := domain.ModelAnalyze
	if recheckDue(s, *t, a) && run.SessionID != "" {
		p, err := render("recheck", promptData{T: *t, AnalysisPath: AnalysisPath})
		if err != nil {
			return raw, a, err
		}
		before := a
		if _, err := o.claudeTurns(ctx, s, ws, t, run, domain.ModelRecheck, p, run.SessionID, recheckTurns); err != nil {
			return raw, a, err
		}
		if r2, b, ok := o.readAnalysis(ctx, ws); ok {
			raw, a, stage = r2, b, domain.ModelRecheck
		}
		o.event(ctx, domain.Event{TicketKey: t.Key, RunID: &run.ID, Step: string(run.Stage), Type: domain.EventAnalysisChecked,
			Message: recheckMessage(s.ModelFor(*t, domain.ModelRecheck), before, a),
			Data:    map[string]any{"model": s.ModelFor(*t, domain.ModelRecheck), "complexity": a.Complexity}})
	}
	missing := o.missingPaths(ctx, ws, a)
	if len(missing) == 0 || run.SessionID == "" {
		return raw, a, nil
	}
	p, err := render("fixpaths", promptData{T: *t, AnalysisPath: AnalysisPath, Missing: missing})
	if err != nil {
		return raw, a, err
	}
	if _, err := o.claudeTurns(ctx, s, ws, t, run, stage, p, run.SessionID, recheckTurns); err != nil {
		return raw, a, err
	}
	if r2, b, ok := o.readAnalysis(ctx, ws); ok {
		raw, a = r2, b
	}
	still := o.missingPaths(ctx, ws, a)
	msg := fmt.Sprintf("the analysis named %d %s that do not exist; it fixed them", len(missing), plural(len(missing), "file", "files"))
	if len(still) > 0 {
		a = dropPaths(a, still)
		raw = mustJSON(a)
		msg = fmt.Sprintf("the analysis named %d %s that do not exist; %d still missing, dropped: %s", len(missing),
			plural(len(missing), "file", "files"), len(still), strings.Join(still, ", "))
	}
	o.event(ctx, domain.Event{TicketKey: t.Key, RunID: &run.ID, Step: string(run.Stage), Type: domain.EventAnalysisChecked, Level: domain.LevelWarn,
		Message: msg, Data: map[string]any{"missing": missing, "dropped": still}})
	return raw, a, nil
}

// readAnalysis reads and parses the analysis Claude wrote.
func (o *Orchestrator) readAnalysis(ctx context.Context, ws Workspace) ([]byte, Analysis, bool) {
	raw, err := ws.ReadFile(ctx, AnalysisPath)
	if err != nil {
		return nil, Analysis{}, false
	}
	a, err := parseAnalysis(raw)
	return raw, a, err == nil
}

func recheckMessage(model string, before, after Analysis) string {
	var changed []string
	if before.Chosen() != nil && after.Chosen() != nil && before.Chosen().Title != after.Chosen().Title {
		changed = append(changed, "the approach")
	}
	if !slices.Equal(before.Plan, after.Plan) {
		changed = append(changed, "the plan")
	}
	if before.Footprint != nil && after.Footprint != nil && !slices.Equal(before.Footprint.Clean().Files, after.Footprint.Clean().Files) {
		changed = append(changed, "the files")
	}
	if len(changed) == 0 {
		return fmt.Sprintf("%s re-checked the analysis of this complex ticket and kept it", model)
	}
	return fmt.Sprintf("%s re-checked the analysis of this complex ticket and changed %s", model, strings.Join(changed, ", "))
}

// analysisPaths are the existing files the analysis says the change must
// copy or reuse, as paths from /workspace.
func analysisPaths(a Analysis) []string {
	var out []string
	add := func(p string) {
		if p != "" && !slices.Contains(out, p) {
			out = append(out, p)
		}
	}
	for _, p := range a.Patterns {
		add(p.Like)
	}
	for _, r := range a.Reuse {
		add(r.Where)
	}
	return out
}

// missingPaths returns the files of analysisPaths that are not in the
// workspace. A failed check reports none: it never blocks the work.
func (o *Orchestrator) missingPaths(ctx context.Context, ws Workspace, a Analysis) []string {
	return missingFiles(ctx, ws, analysisPaths(a))
}

// missingFiles returns the paths (from /workspace) that do not exist; none
// when the check cannot run.
func missingFiles(ctx context.Context, ws Workspace, ps []string) []string {
	if len(ps) == 0 {
		return nil
	}
	q := make([]string, len(ps))
	for i, p := range ps {
		q[i] = shellQuote(p)
	}
	res, err := ws.Exec(ctx, `for f in `+strings.Join(q, " ")+`; do [ -e "$f" ] || printf '%s\n' "$f"; done`, 30*time.Second)
	if err != nil || res.ExitCode != 0 {
		return nil
	}
	var out []string
	for _, l := range strings.Split(res.Output, "\n") {
		if l = strings.TrimSpace(l); l != "" && slices.Contains(ps, l) {
			out = append(out, l)
		}
	}
	return out
}

// dropPaths removes the patterns and helpers that name missing files.
func dropPaths(a Analysis, missing []string) Analysis {
	a.Patterns = slices.DeleteFunc(slices.Clone(a.Patterns), func(p Pattern) bool { return slices.Contains(missing, p.Like) })
	a.Reuse = slices.DeleteFunc(slices.Clone(a.Reuse), func(r Reuse) bool { return slices.Contains(missing, r.Where) })
	return a
}

// mustJSON marshals v, which is always marshalable.
func mustJSON(v any) []byte {
	b, _ := json.Marshal(v)
	return b
}
