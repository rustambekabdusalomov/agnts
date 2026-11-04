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

// The security check of a change (plans/Security plan.md, the side
// stage): while a ticket waits for review, agnts runs its scanners on
// the files the change touched and keeps what they report on the lines
// it added. The agent judges those hits, and only when there are any.
// The result is advice for the reviewer, kept on the ticket (not as
// repository findings): it never blocks Approve.

// Limits of the security check: smaller than a repository scan's, as
// only the change's hits are judged.
const (
	securitySideMaxTurns   = 20
	securitySideTimeoutMin = 15
	// securitySideMaxPaths caps the files one check scans; a larger
	// change is checked on its first files.
	securitySideMaxPaths = 300
)

// securityState is the security check state a code change gets as it
// reaches review: pending when checks are on and the change touches a
// file the scanners would look at.
func (o *Orchestrator) securityState(s domain.Settings, rs []runRepo, primary *int64, files []domain.FileChange) string {
	if o.security == nil || !s.Security.AutoCheck {
		return domain.SecCheckNone
	}
	if paths, _ := securityTargets(rs, primary, files); len(paths) == 0 {
		return domain.SecCheckNone
	}
	return domain.SecCheckPending
}

// securityTargets are the paths of a change to scan, from /workspace,
// and the exclusions that apply: agnts's defaults and each repository's
// own (prefixed with its folder in a ticket of several repositories).
// Files in excluded paths and in repositories whose pull request is
// closed are left out.
func securityTargets(rs []runRepo, primary *int64, files []domain.FileChange) ([]string, []string) {
	exclude := slices.Clone(domain.SecDefaultExclude)
	var paths []string
	for _, r := range rs {
		own := r.Harness.Security.Exclude
		for _, p := range own {
			if r.Folder() != "" {
				p = r.Folder() + "/" + p
			}
			exclude = append(exclude, p)
		}
		if r.Frozen {
			continue
		}
		for _, f := range domain.FilesIn(files, r.ID, primary) {
			if domain.SecExcluded(f.Path, domain.SecDefaultExclude) || domain.SecExcluded(f.Path, own) {
				continue
			}
			paths = append(paths, f.Where())
		}
	}
	slices.Sort(paths)
	return slices.Compact(paths), exclude
}

// dropSecurity forgets a queued or running security check of a ticket
// leaving review; it reports whether one may be running.
func dropSecurity(x *domain.Ticket) bool {
	running := x.SecurityState == domain.SecCheckRunning
	if running || x.SecurityState == domain.SecCheckPending {
		x.SecurityState = domain.SecCheckNone
	}
	return running
}

// CheckSecurity queues the security check of a ticket waiting for review
// (again, if one already ran).
func (o *Orchestrator) CheckSecurity(ctx context.Context, key string, origin domain.Origin) (domain.Ticket, error) {
	t, err := o.store.TicketByKey(ctx, key)
	if err != nil {
		return t, err
	}
	if err := o.securityReady(); err != nil {
		return t, err
	}
	if t.State != domain.StateWaitingForReview {
		return t, invalid("agnts checks a change for security issues while it waits for your review")
	}
	if t.Kind.Report() || t.Kind == domain.KindReview {
		return t, invalid("%s has no change of agnts's to check", t.Key)
	}
	t, err = o.store.UpdateTicket(ctx, key, &domain.Event{
		TicketKey: key, Type: domain.EventTicketUpdated, Origin: origin, Step: string(domain.StageSecurity), Message: "queued for a security check",
	}, func(x *domain.Ticket) {
		if x.State == domain.StateWaitingForReview && x.SecurityState != domain.SecCheckRunning {
			x.SecurityState = domain.SecCheckPending
		}
	})
	if err == nil {
		o.Wake()
	}
	return t, err
}

// securityCheck runs the scanners on the change under review, has the
// agent judge what they report on its added lines, and stores the result
// for the reviewer. It never changes the ticket's state.
func (o *Orchestrator) securityCheck(ctx context.Context, s domain.Settings, t domain.Ticket, run *domain.Run) error {
	if err := o.securityReady(); err != nil {
		return err
	}
	res, err := o.store.LatestResult(ctx, t.ID, domain.StageCode)
	if err != nil {
		return fmt.Errorf("load the change to check: %w", err)
	}
	rs, err := o.reposFor(ctx, t)
	if err != nil {
		return err
	}
	paths, exclude := securityTargets(rs, t.RepoID, res.Files)
	check := domain.SecurityCheck{Revision: t.Revision, Files: len(paths), Issues: []domain.SecCheckIssue{}}
	if len(paths) == 0 {
		check.Agent = domain.SecAgentSkipped
		check.Summary = "The change touches no file the scanners look at."
		return o.saveSecurityCheck(ctx, t, run, check)
	}
	if len(paths) > securitySideMaxPaths {
		paths = paths[:securitySideMaxPaths]
	}

	ws, err := o.openWorkspace(ctx, t, rs, run)
	if err != nil {
		return err
	}
	defer o.closeWorkspace(ctx, t, ws)
	if err := ws.WriteFile(ctx, SecExcludePath, []byte(strings.Join(exclude, "\n")+"\n")); err != nil {
		return fmt.Errorf("write exclusions: %w", err)
	}
	var args strings.Builder
	args.WriteString("--history -1") // the change's commits are its files: no history scan
	for _, p := range paths {
		args.WriteString(" --path " + shellQuote(p))
	}
	o.event(ctx, domain.Event{TicketKey: t.Key, RunID: &run.ID, Step: string(domain.StageSecurity), Type: domain.EventClaudeText,
		Message: fmt.Sprintf("running the security scanners on %d changed %s", len(paths), plural(len(paths), "file", "files"))})
	all, ran, err := o.secSweep(ctx, ws, args.String(), exclude)
	if err != nil {
		return err
	}
	hits := domain.SecChangeHits(all, res.Files)
	check.Tools = ran.Tools
	for tool, r := range check.Tools {
		r.Hits = 0
		for _, h := range hits {
			if h.Tool == tool {
				r.Hits++
			}
		}
		check.Tools[tool] = r
	}
	if len(hits) == 0 {
		check.Agent = domain.SecAgentSkipped
		check.Summary = "The scanners found nothing in the lines this change adds."
		if failed := secFailedTools(ran); failed != "" {
			check.Summary += " " + failed + " did not finish, so this is not the whole picture."
		}
		return o.saveSecurityCheck(ctx, t, run, check)
	}

	// The agent judges the hits; the hits stand as the tools reported them
	// when it cannot.
	m, agent, err := o.judgeSecurityHits(ctx, s, ws, &t, run, rs, res, hits, ran)
	if err != nil {
		return err
	}
	check.Agent = agent
	check.Issues, check.Rejected = domain.SecCheckIssues(hits, m)
	if check.Issues == nil {
		check.Issues = []domain.SecCheckIssue{}
	}
	switch {
	case m != nil && m.Summary != "":
		check.Summary = m.Summary
	case len(check.Issues) == 0:
		check.Summary = "The scanners' hits on this change are not real issues."
	default:
		check.Summary = fmt.Sprintf("The scanners report %d %s in the lines this change adds.", len(check.Issues), plural(len(check.Issues), "issue", "issues"))
	}
	return o.saveSecurityCheck(ctx, t, run, check)
}

// judgeSecurityHits has the agent triage a change's hits. It returns the
// manifest (nil when the agent wrote none), how the agent's run ended,
// and an error only when the check cannot go on (rate limited, stopped).
func (o *Orchestrator) judgeSecurityHits(ctx context.Context, s domain.Settings, ws Workspace, t *domain.Ticket, run *domain.Run,
	rs []runRepo, res domain.Result, hits []domain.SecHit, ran domain.SecRan) (*domain.SecurityManifest, string, error) {
	hb, _ := json.MarshalIndent(hits, "", "  ")
	if err := ws.WriteFile(ctx, SecHitsPath, hb); err != nil {
		return nil, "", fmt.Errorf("write hits: %w", err)
	}
	if err := ws.WriteFile(ctx, ChangePath, changeDiff(res.Files)); err != nil {
		return nil, "", fmt.Errorf("copy the change into the workspace: %w", err)
	}
	turns := min(s.MaxTurns, securitySideMaxTurns)
	if turns <= 0 {
		turns = securitySideMaxTurns
	}
	d := promptData{T: *t, Repo: rs[0].Repository, Security: &securityPrompt{Hits: len(hits), HitsPath: SecHitsPath, OutPath: SecurityPath,
		ChangePath: ChangePath, MaxTurns: turns, MaxFinding: len(hits)}}
	for _, tool := range domain.SecTools {
		if r, ok := ran.Tools[tool]; ok {
			d.Security.Tools = append(d.Security.Tools, fmt.Sprintf("%s: %s", tool, r.Status))
		}
	}
	var err error
	if d.Rules, err = o.teamRules(ctx, t.RepoIDs()); err != nil {
		return nil, "", err
	}
	prompt, err := render("security-side", d)
	if err != nil {
		return nil, "", err
	}
	ps := s
	ps.MaxTurns = turns
	ps.TimeoutMin = min(max(s.TimeoutMin, 1), securitySideTimeoutMin)
	result, err := o.claude(ctx, ps, ws, t, run, domain.ModelSecurity, prompt, "")
	var stop *stopError
	agent := domain.SecAgentDone
	switch {
	case errors.As(err, &stop):
		// Rate limited: claimed again once usage allows.
		o.setSecurityState(context.WithoutCancel(ctx), *t, domain.SecCheckPending)
		return nil, "", err
	case err != nil && ctx.Err() != nil:
		return nil, "", ctx.Err()
	case err != nil && strings.Contains(err.Error(), "timed out"):
		agent = domain.SecAgentLimit
	case err != nil:
		agent = domain.SecAgentFailed
		o.event(ctx, domain.Event{TicketKey: t.Key, RunID: &run.ID, Step: string(domain.StageSecurity), Type: domain.EventError, Level: domain.LevelWarn,
			Message: "the agent could not judge the scanners' hits (" + truncate(err.Error(), 200) + "); they are shown as the tools reported them"})
	case result.IsError && result.Subtype == "error_max_turns":
		agent = domain.SecAgentLimit
	case result.IsError:
		agent = domain.SecAgentFailed
	}
	b, err := ws.ReadFile(ctx, SecurityPath)
	if err != nil {
		if agent == domain.SecAgentDone {
			agent = domain.SecAgentFailed
		}
		return nil, agent, nil
	}
	m, err := domain.ParseSecurityManifest(b)
	if err != nil {
		o.event(ctx, domain.Event{TicketKey: t.Key, RunID: &run.ID, Step: string(domain.StageSecurity), Type: domain.EventError, Level: domain.LevelWarn,
			Message: "the agent's security.json was not valid (" + truncate(err.Error(), 200) + "); the hits are shown as the tools reported them"})
		return nil, domain.SecAgentFailed, nil
	}
	ids := map[string]bool{}
	for _, h := range hits {
		ids[h.ID] = true
	}
	m.Normalize(ids, nil)
	m.Known = nil // a change's check has no known findings
	return &m, agent, nil
}

// secFailedTools names the scanners that did not finish, or "".
func secFailedTools(ran domain.SecRan) string {
	var out []string
	for _, tool := range domain.SecTools {
		if r, ok := ran.Tools[tool]; ok && r.Status != "ok" {
			out = append(out, tool)
		}
	}
	return strings.Join(out, ", ")
}

// saveSecurityCheck stores a finished check and marks the ticket's check
// done if it is still on that revision.
func (o *Orchestrator) saveSecurityCheck(ctx context.Context, t domain.Ticket, run *domain.Run, check domain.SecurityCheck) error {
	b, _ := json.Marshal(check)
	if err := o.store.SaveResult(ctx, domain.Result{RunID: run.ID, Summary: b}); err != nil {
		return err
	}
	msg := "security check: nothing found in the change"
	worst := ""
	if n := len(check.Issues); n > 0 {
		worst = string(check.Issues[0].Severity)
		msg = fmt.Sprintf("security check: %d %s, the worst %s", n, plural(n, "issue", "issues"), worst)
	}
	ev := domain.Event{TicketKey: t.Key, RunID: &run.ID, Step: string(domain.StageSecurity), Type: domain.EventSecurityCheck, Message: msg,
		Data: map[string]any{"issues": len(check.Issues), "worst": worst, "revision": check.Revision, "runId": run.ID}}
	_, err := o.store.UpdateTicket(ctx, t.Key, &ev, func(x *domain.Ticket) {
		if x.SecurityState == domain.SecCheckRunning && x.Revision == t.Revision {
			x.SecurityState = domain.SecCheckDone
		}
	})
	return err
}

// setSecurityState moves a running check of t's revision to state.
func (o *Orchestrator) setSecurityState(ctx context.Context, t domain.Ticket, state string) {
	if _, err := o.store.UpdateTicket(ctx, t.Key, nil, func(x *domain.Ticket) {
		if x.SecurityState == domain.SecCheckRunning && x.Revision == t.Revision {
			x.SecurityState = state
		}
	}); err != nil {
		o.log.Error("set security check state", "ticket", t.Key, "err", err)
	}
}

// securityCheckFailed records a failed check. The ticket stays in review.
func (o *Orchestrator) securityCheckFailed(ctx context.Context, t domain.Ticket, run domain.Run, cause error) {
	if _, err := o.store.UpdateTicket(ctx, t.Key, &domain.Event{
		TicketKey: t.Key, RunID: &run.ID, Type: domain.EventError, Level: domain.LevelWarn, Step: string(domain.StageSecurity),
		Message: "the security check failed: " + cause.Error(),
	}, func(x *domain.Ticket) {
		if x.SecurityState == domain.SecCheckRunning && x.Revision == t.Revision {
			x.SecurityState = domain.SecCheckFailed
		}
	}); err != nil {
		o.log.Error("mark security check failed", "ticket", t.Key, "err", err)
	}
}

// latestSecurityCheck returns the newest security check of a ticket, or
// nil.
func (o *Orchestrator) latestSecurityCheck(ctx context.Context, ticketID int64) (*domain.SecurityCheck, error) {
	r, err := o.store.LatestResult(ctx, ticketID, domain.StageSecurity)
	if errors.Is(err, domain.ErrNotFound) {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}
	var c domain.SecurityCheck
	if json.Unmarshal(r.Summary, &c) != nil || c.Summary == "" {
		return nil, nil
	}
	c.RunID, c.CreatedAt = r.RunID, r.CreatedAt
	if c.Issues == nil {
		c.Issues = []domain.SecCheckIssue{}
	}
	return &c, nil
}
