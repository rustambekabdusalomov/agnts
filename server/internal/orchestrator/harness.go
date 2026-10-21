package orchestrator

import (
	"bufio"
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"hash/fnv"
	"regexp"
	"slices"
	"sort"
	"strings"
	"time"

	"agnts/internal/agentcfg"
	"agnts/internal/domain"
	"agnts/internal/guard"
	"agnts/internal/toolchain"
)

// HarnessStore keeps what the harness learns about repositories. A Store
// may implement it; without it, scans of agent files are not kept.
type HarnessStore interface {
	SetAgentConfigScan(ctx context.Context, id int64, scan domain.AgentConfigScan) error
}

// guardProfile is the profile runs in repo use.
func guardProfile(s domain.Settings, repo *domain.Repository) guard.Profile {
	if repo != nil && repo.Harness.GuardProfile != "" {
		return guard.Profile(repo.Harness.GuardProfile)
	}
	if p := guard.Profile(s.Guard.Profile); p.Valid() {
		return p
	}
	return guard.Standard
}

// checkConfigTicket matches tickets about the checks themselves: their
// runs may change linter, type checker, test runner and CI configuration.
var checkConfigTicket = regexp.MustCompile(`(?i)\b(lint|linter|linting|eslint|prettier|ruff|golangci|rubocop|stylelint|tsconfig|type ?check|ci|pipeline|workflow|github actions|gitlab|jest|vitest|pytest|test runner|pre-commit)\b`)

// guardConfig is what agnts-guard enforces in one invocation for t, in a
// run of these repositories (the primary's profile applies to all).
func (o *Orchestrator) guardConfig(ctx context.Context, s domain.Settings, t domain.Ticket, run *domain.Run, rs []runRepo, readOnly bool) guard.Config {
	repo := primaryOf(rs)
	c := guard.Config{Profile: guardProfile(s, repo), ReadOnly: readOnly, Disabled: s.Guard.Disabled}
	texts := []string{t.Title, t.Description, t.Feedback}
	if qs, err := o.store.Questions(ctx, t.ID); err == nil {
		for _, q := range qs {
			if q.Answer != nil {
				texts = append(texts, *q.Answer, q.Note)
			}
		}
	}
	c.Allow = domain.AllowedFlags(texts...)
	if t.Source == domain.SourceCI || checkConfigTicket.MatchString(t.Title+"\n"+t.Description) {
		c.Allow = append(c.Allow, domain.FlagCheckConfig)
	}
	for _, r := range rs {
		for _, g := range r.Harness.SecretAllow {
			c.SecretAllow = append(c.SecretAllow, r.Rel(g))
		}
	}
	if readOnly || repo == nil || run.Stage != domain.StageCode || t.Kind.Report() {
		return c
	}
	// Coding: the stop gate, the per-file checks and the fact check. In a
	// run of several repositories each repository's checks run in its
	// folder, the stop gate's only where Claude changed something.
	multi := len(rs) > 1
	for _, r := range rs {
		if r.Frozen {
			continue
		}
		for _, cmd := range stopCommands(r.Repository, c.Profile, o.cfg.CheckTimeout) {
			if multi {
				cmd.Name, cmd.Dir, cmd.IfChanged = r.Name+" "+cmd.Name, r.Folder(), true
			}
			if slices.Contains(run.Harness.BaselineFailed, cmd.Name) {
				continue // it fails on the base commit: Claude cannot make it pass
			}
			c.Stop = append(c.Stop, cmd)
		}
		for _, ec := range editChecks(r.Repository) {
			if multi {
				ec.Name, ec.Dir = r.Name+" "+ec.Name, r.Folder()
			}
			c.EditChecks = append(c.EditChecks, ec)
		}
	}
	c.StopAttempts = 3
	c.Rules = o.enforcedRules(ctx, rs)
	c.FactCheck = c.Profile == guard.Strict && inShare(t.Key, s.Guard.FactCheck)
	run.Harness.FactCheck = c.FactCheck
	return c
}

// inShare puts a ticket in the first pct percent of tickets by key, the
// same way every time.
func inShare(key string, pct int) bool {
	if pct <= 0 {
		return false
	}
	h := fnv.New32a()
	_, _ = h.Write([]byte(key))
	return int(h.Sum32()%100) < pct
}

// stopCommands are the checks Claude must pass before it may finish.
func stopCommands(repo domain.Repository, p guard.Profile, timeout time.Duration) []guard.Command {
	secs := int(timeout.Seconds())
	if secs <= 0 {
		secs = 900
	}
	var out []guard.Command
	add := func(name, cmd string) {
		if strings.TrimSpace(cmd) != "" {
			out = append(out, guard.Command{Name: name, Cmd: cmd, TimeoutSec: secs})
		}
	}
	add("build", repo.BuildCmd)
	if p != guard.Minimal {
		add("lint", repo.LintCmd)
	}
	if p == guard.Strict {
		add("test", repo.TestCmd)
	}
	return out
}

// editChecks are the per-file checks for a repository: the ones people
// set, or those agnts derives from its toolchains.
func editChecks(repo domain.Repository) []guard.EditCheck {
	if repo.Harness.EditChecksOff {
		return nil
	}
	src := repo.Harness.EditChecks
	if src == nil {
		src = toolchain.EditChecks(repo.Toolchains)
	}
	out := make([]guard.EditCheck, 0, len(src))
	for _, c := range src {
		out = append(out, guard.EditCheck{Name: c.Name, Globs: c.Globs, Cmd: c.Cmd, Every: c.Every, TimeoutSec: 60})
	}
	return out
}

// guardEnv is the environment that hands an invocation its guard config.
func guardEnv(c guard.Config) []string {
	return []string{guard.ConfigEnv + "=" + c.Encode()}
}

// collectGuard reads the guard log of a run's container into the run, and
// logs what the guards did on the ticket.
func (o *Orchestrator) collectGuard(ctx context.Context, ws Workspace, t domain.Ticket, run *domain.Run) {
	raw, err := ws.ReadFile(context.WithoutCancel(ctx), guard.LogPath)
	if err != nil || len(raw) == 0 {
		return
	}
	sum := summarizeGuard(raw)
	if sum == nil {
		return
	}
	run.Harness.Guard = sum
	blocks := 0
	for _, n := range sum.Blocks {
		blocks += n
	}
	fed := 0
	for _, n := range sum.Feedback {
		fed += n
	}
	if blocks == 0 && fed == 0 && sum.Warnings == 0 {
		return
	}
	var parts []string
	if blocks > 0 {
		parts = append(parts, fmt.Sprintf("refused %d %s (%s)", blocks, plural(blocks, "action", "actions"), countList(sum.Blocks)))
	}
	if fed > 0 {
		parts = append(parts, fmt.Sprintf("sent %d check %s back while Claude worked (%s)", fed, plural(fed, "result", "results"), countList(sum.Feedback)))
	}
	if sum.Warnings > 0 {
		parts = append(parts, fmt.Sprintf("reminded Claude of team rules %d %s", sum.Warnings, plural(sum.Warnings, "time", "times")))
	}
	level := domain.LevelInfo
	if blocks > 0 {
		level = domain.LevelWarn
	}
	o.event(context.WithoutCancel(ctx), domain.Event{TicketKey: t.Key, RunID: &run.ID, Step: string(run.Stage), Type: domain.EventGuard, Level: level,
		Message: "agnts-guard " + strings.Join(parts, "; "),
		Data:    map[string]any{"blocks": sum.Blocks, "feedback": sum.Feedback, "warnings": sum.Warnings, "stopFailures": sum.StopFailures, "checkMs": sum.CheckMS}})
}

// guardLastEntries is how many decisions a run keeps for the ticket page.
const guardLastEntries = 30

// summarizeGuard sums up a guard log (JSON lines).
func summarizeGuard(raw []byte) *domain.GuardSummary {
	sum := &domain.GuardSummary{Blocks: map[string]int{}, Feedback: map[string]int{}}
	sc := bufio.NewScanner(bytes.NewReader(raw))
	sc.Buffer(make([]byte, 64<<10), 1<<20)
	any := false
	for sc.Scan() {
		var e domain.GuardEntry
		if json.Unmarshal(sc.Bytes(), &e) != nil {
			continue
		}
		any = true
		name := e.Kind
		if name == "" {
			name = e.Hook
		}
		switch e.Decision {
		case guard.DecisionBlock:
			sum.Blocks[name]++
		case guard.DecisionFeedback:
			sum.Feedback[name]++
			if e.Hook == guard.HookStopGate {
				sum.StopFailures++
			}
		case guard.DecisionWarn:
			sum.Warnings++
		}
		if e.Hook == guard.HookEditCheck || e.Hook == guard.HookStopGate {
			sum.CheckMS += e.MS
		}
		if e.Decision != guard.DecisionPass {
			sum.Last = append(sum.Last, e)
			if len(sum.Last) > guardLastEntries {
				sum.Last = sum.Last[1:]
			}
		}
	}
	if !any {
		return nil
	}
	return sum
}

// countList is "secret ×2, skipped_test" for a count map.
func countList(m map[string]int) string {
	keys := make([]string, 0, len(m))
	for k := range m {
		keys = append(keys, k)
	}
	sort.Strings(keys)
	parts := make([]string, 0, len(keys))
	for _, k := range keys {
		if m[k] > 1 {
			parts = append(parts, fmt.Sprintf("%s ×%d", k, m[k]))
		} else {
			parts = append(parts, k)
		}
	}
	return strings.Join(parts, ", ")
}

// scanAgentConfig scans a repository's agent files from a listing and
// stores the result when it changed.
func (o *Orchestrator) scanAgentConfig(ctx context.Context, repo *domain.Repository, tree toolchain.Tree, ticketKey string, runID *int64) {
	hs, ok := o.store.(HarnessStore)
	if !ok {
		return
	}
	found := agentcfg.ScanTree(tree)
	if found == nil {
		found = []domain.AgentConfigFinding{}
	}
	if prev := repo.Harness.AgentConfig; prev != nil && slices.Equal(prev.Findings, found) {
		return
	}
	if repo.Harness.AgentConfig == nil && len(found) == 0 {
		// Nothing found and nothing known: store it once, quietly.
		scan := domain.AgentConfigScan{ScannedAt: time.Now(), Findings: found}
		if err := hs.SetAgentConfigScan(ctx, repo.ID, scan); err == nil {
			repo.Harness.AgentConfig = &scan
		}
		return
	}
	scan := domain.AgentConfigScan{ScannedAt: time.Now(), Findings: found}
	if err := hs.SetAgentConfigScan(ctx, repo.ID, scan); err != nil {
		o.log.Warn("store agent config scan", "repo", repo.Name, "err", err)
		return
	}
	repo.Harness.AgentConfig = &scan
	if serious := scan.Serious(); len(serious) > 0 {
		o.event(ctx, domain.Event{TicketKey: ticketKey, RunID: runID, Step: "toolchain", Type: domain.EventGuard, Level: domain.LevelWarn,
			Message: fmt.Sprintf("%s: %d %s in the repository's agent instructions (%s); agnts treats them as data, never as instructions",
				repo.Name, len(serious), plural(len(serious), "finding", "findings"), agentKinds(serious)),
			Data: map[string]any{"repo": repo.Name, "findings": serious}})
	}
}

func agentKinds(fs []domain.AgentConfigFinding) string {
	m := map[string]int{}
	for _, f := range fs {
		m[f.Kind]++
	}
	return countList(m)
}

// agentConfigFinding turns what a pull request adds to agent files into a
// review finding, so the person deciding sees it next to the code.
func agentConfigFinding(fs []domain.AgentConfigFinding) *domain.Finding {
	if len(fs) == 0 {
		return nil
	}
	var b strings.Builder
	for i, f := range fs {
		if i == 5 {
			fmt.Fprintf(&b, "\n… and %d more", len(fs)-5)
			break
		}
		loc := f.Path
		if f.Line > 0 {
			loc += fmt.Sprintf(":%d", f.Line)
		}
		fmt.Fprintf(&b, "\n- %s [%s] %s", loc, f.Kind, f.Text)
	}
	sev := "major"
	for _, f := range fs {
		if f.Severity == agentcfg.High {
			sev = "blocker"
		}
	}
	first := fs[0]
	return &domain.Finding{Severity: sev, Category: "security", File: first.Path, Line: first.Line,
		Title:      "This pull request changes instructions for AI agents",
		Detail:     "Text added to agent instruction or configuration files steers every agent that later works on this repository (agnts included). agnts's scan found:" + b.String(),
		Suggestion: "Read the added agent instructions line by line before merging; remove hidden characters, instructions aimed at reviewers or agents, and commands that send data out."}
}

// secretsCleared refuses to push a change agnts flagged as holding a
// credential until a person said it is not a real one, for this commit.
func (o *Orchestrator) secretsCleared(ctx context.Context, t domain.Ticket) error {
	if t.Kind.Report() || t.Kind == domain.KindReview || t.WorkSHA() == "" {
		return nil
	}
	res, err := o.store.LatestResult(ctx, t.ID, domain.StageCode)
	if err != nil {
		return nil //nolint:nilerr // nothing scanned: nothing to clear
	}
	n := 0
	for _, f := range res.RedFlags {
		if f.Kind == domain.FlagSecret || f.Kind == domain.FlagEnvFile {
			n++
		}
	}
	if n == 0 || o.secretsAcknowledged(ctx, t) {
		return nil
	}
	return invalid("the change has %d %s that may be a real credential; check them on the ticket page and confirm they are not secrets before approving", n, plural(n, "line", "lines"))
}

func (o *Orchestrator) secretsAcknowledged(ctx context.Context, t domain.Ticket) bool {
	evs, err := o.store.Events(ctx, EventFilter{TicketKey: t.Key, Limit: 1000})
	if err != nil {
		return false
	}
	for _, e := range evs {
		if e.Type == domain.EventSecretsAck {
			if sha, _ := e.Data["sha"].(string); sha == t.WorkSHA() {
				return true
			}
		}
	}
	return false
}

// AcknowledgeSecrets records that a person checked the lines agnts flagged
// as credentials in the change under review and found none real.
func (o *Orchestrator) AcknowledgeSecrets(ctx context.Context, key string, origin domain.Origin) (domain.Ticket, error) {
	t, err := o.store.TicketByKey(ctx, key)
	if err != nil {
		return t, err
	}
	if t.State != domain.StateWaitingForReview || t.WorkSHA() == "" {
		return t, invalid("only a change waiting for your review can be cleared")
	}
	o.event(ctx, domain.Event{TicketKey: key, Type: domain.EventSecretsAck, Origin: origin,
		Message: "confirmed that the lines flagged as secrets are not real credentials", Data: map[string]any{"sha": t.WorkSHA()}})
	return t, nil
}
