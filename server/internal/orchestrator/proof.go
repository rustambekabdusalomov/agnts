package orchestrator

import (
	"context"
	"encoding/json"
	"fmt"
	"path"
	"strings"
	"time"

	"agnts/internal/domain"
)

// The base worktree lives in /tmp, outside /workspace, so it is never part
// of the exported change.
const (
	proofDir      = "/tmp/agnts-base"
	proofMaxTests = 5
)

// proveDue reports whether the coding run of t must prove its fix.
func proveDue(s domain.Settings, t domain.Ticket, a *Analysis) bool {
	return s.ProveFixes && a != nil && a.Defect && !t.Kind.Report() && t.Kind != domain.KindReview
}

// proveFix runs the reproducing tests the summary lists on the code the
// change started from (they must fail) and on the change (they must pass).
func (o *Orchestrator) proveFix(ctx context.Context, ws Workspace, t domain.Ticket, run *domain.Run, repo domain.Repository) domain.Proof {
	var sum Summary
	if raw, err := ws.ReadFile(ctx, SummaryPath); err == nil {
		_ = json.Unmarshal(raw, &sum)
	}
	if len(sum.Repro) == 0 {
		why := strings.TrimSpace(sum.ReproWhy)
		if why == "" {
			why = "the summary lists no reproducing test"
		}
		return domain.Proof{Status: domain.ProofNoTest, Why: why}
	}
	base, err := o.proofBase(ctx, ws, t, repo)
	if err != nil {
		return domain.Proof{Status: domain.ProofError, Why: err.Error()}
	}
	p := domain.Proof{Base: base}
	setup := fmt.Sprintf("rm -rf %[1]s; git worktree prune; git worktree add --detach %[1]s %[2]s", proofDir, base)
	if r, err := ws.Exec(ctx, setup, 5*time.Minute); err != nil || r.ExitCode != 0 {
		return domain.Proof{Status: domain.ProofError, Base: base, Why: "could not check out the code before the change: " + tail(r.Output+errText(err), 500)}
	}
	defer func() {
		_, _ = ws.Exec(context.WithoutCancel(ctx), fmt.Sprintf("git worktree remove --force %s; git worktree prune", proofDir), time.Minute)
	}()
	for i, rt := range sum.Repro {
		if i == proofMaxTests {
			break
		}
		p.Tests = append(p.Tests, o.proveOne(ctx, ws, rt))
	}
	p.Status = proofStatus(p.Tests)
	return p
}

func errText(err error) string {
	if err == nil {
		return ""
	}
	return err.Error()
}

// proofBase is the commit the change started from.
func (o *Orchestrator) proofBase(ctx context.Context, ws Workspace, t domain.Ticket, repo domain.Repository) (string, error) {
	b := shellArg(repo.DefaultBranch)
	cmd := "git merge-base HEAD " + b + " 2>/dev/null || git merge-base HEAD origin/" + strings.Trim(b, "'") + " 2>/dev/null"
	if t.BaseSHA != "" {
		cmd += " || echo " + shellArg(t.BaseSHA)
	}
	cmd += " || git rev-parse HEAD"
	r, err := ws.Exec(ctx, cmd, time.Minute)
	if err != nil {
		return "", err
	}
	base := strings.TrimSpace(r.Output)
	if i := strings.LastIndex(base, "\n"); i >= 0 {
		base = strings.TrimSpace(base[i+1:])
	}
	if r.ExitCode != 0 || len(base) < 7 || strings.ContainsAny(base, " \t") {
		return "", fmt.Errorf("could not find the commit the change started from: %s", tail(r.Output, 300))
	}
	return base, nil
}

func shellArg(s string) string { return "'" + strings.ReplaceAll(s, "'", `'\''`) + "'" }

// proveOne runs one reproducing test before and after the change.
func (o *Orchestrator) proveOne(ctx context.Context, ws Workspace, rt ReproTest) domain.ProofTest {
	pt := domain.ProofTest{File: rt.File, Name: rt.Name, Command: rt.Command, At: time.Now()}
	file := path.Clean(strings.TrimPrefix(rt.File, "/workspace/"))
	if rt.Command == "" || file == "." || strings.HasPrefix(file, "..") || strings.HasPrefix(file, "/") {
		pt.Status = domain.ProofError
		pt.Before.Output = "the test needs a file inside the repository and a command"
		return pt
	}
	// The test file goes into the old code; dependencies installed in the
	// workspace (node_modules, a .venv) are linked so the old code can run.
	var links []string
	for d := path.Dir(file); ; d = path.Dir(d) {
		for _, dep := range []string{"node_modules", ".venv", "venv", "vendor/bundle"} {
			src, dst := path.Join("/workspace", d, dep), path.Join(proofDir, d, dep)
			links = append(links, fmt.Sprintf("if [ -e %s ] && [ ! -e %s ]; then mkdir -p %s && ln -s %s %s; fi",
				shellArg(src), shellArg(dst), shellArg(path.Dir(dst)), shellArg(src), shellArg(dst)))
		}
		if d == "." || d == "/" {
			break
		}
	}
	prep := fmt.Sprintf("mkdir -p %s && cp %s %s && %s", shellArg(path.Join(proofDir, path.Dir(file))),
		shellArg(path.Join("/workspace", file)), shellArg(path.Join(proofDir, file)), strings.Join(links, " && "))
	if r, err := ws.Exec(ctx, prep, time.Minute); err != nil || r.ExitCode != 0 {
		pt.Status = domain.ProofError
		pt.Before.Output = "could not copy the test into the code before the change: " + tail(r.Output+errText(err), 500)
		return pt
	}
	run := func(dir string) domain.ProofRun {
		r, err := ws.Exec(ctx, "cd "+shellArg(dir)+" && "+rt.Command, o.cfg.CheckTimeout)
		out := r.Output
		if err != nil {
			out += "\n" + err.Error()
		}
		exit := r.ExitCode
		if r.TimedOut {
			exit = 124
		}
		return domain.ProofRun{Exit: exit, Output: tail(out, 3000), MS: r.Duration.Milliseconds()}
	}
	pt.Before = run(proofDir)
	pt.After = run("/workspace")
	pt.Status = proofTestStatus(pt)
	return pt
}

// proofTestStatus judges one test's two runs.
func proofTestStatus(pt domain.ProofTest) string {
	switch {
	case pt.After.Exit != 0:
		return domain.ProofStillFailing
	case pt.Before.Exit == 0:
		return domain.ProofNotReproduced
	case pt.Before.Exit == 127 || pt.Before.Exit == 124:
		return domain.ProofInconclusive
	case !failureNames(pt.Before.Output, pt.Name):
		// It failed, but not visibly in this test: the old code may not
		// even compile with it (the test uses what the fix adds).
		return domain.ProofInconclusive
	}
	return domain.ProofProven
}

// failureNames reports whether a test run's output names the test, so a
// failure can be pinned on it rather than on the build.
func failureNames(out, name string) bool {
	name = strings.TrimSpace(name)
	if name == "" {
		return false
	}
	lower := strings.ToLower(out)
	if strings.Contains(lower, strings.ToLower(name)) {
		return true
	}
	// Go subtests and pytest node ids: the last part is enough.
	for _, sep := range []string{"/", "::", "."} {
		if i := strings.LastIndex(name, sep); i >= 0 && len(name)-i > 4 && strings.Contains(lower, strings.ToLower(name[i+len(sep):])) {
			return true
		}
	}
	return false
}

// proofStatus sums up the tests: the worst outcome wins.
func proofStatus(ts []domain.ProofTest) string {
	if len(ts) == 0 {
		return domain.ProofNoTest
	}
	order := []string{domain.ProofStillFailing, domain.ProofNotReproduced, domain.ProofError, domain.ProofInconclusive}
	for _, s := range order {
		for _, t := range ts {
			if t.Status == s {
				return s
			}
		}
	}
	return domain.ProofProven
}

// proofEvent logs a proof on the ticket.
func proofEvent(key string, run *domain.Run, p domain.Proof) domain.Event {
	msg, level := "", domain.LevelInfo
	switch p.Status {
	case domain.ProofProven:
		msg = fmt.Sprintf("fix proven: %d reproducing %s fail before the change and pass after it", len(p.Tests), plural(len(p.Tests), "test", "tests"))
	case domain.ProofNotReproduced:
		msg, level = "the reproducing test passes before the change too: it does not show the bug", domain.LevelWarn
	case domain.ProofStillFailing:
		msg, level = "the reproducing test still fails with the change", domain.LevelWarn
	case domain.ProofInconclusive:
		msg = "the reproducing test could not run on the code before the change (it may need what the fix adds)"
	case domain.ProofNoTest:
		msg = "no reproducing test: " + p.Why
	default:
		msg, level = "could not check the fix: "+p.Why, domain.LevelWarn
	}
	return domain.Event{TicketKey: key, RunID: &run.ID, Step: string(run.Stage), Type: domain.EventProof, Level: level, Message: msg,
		Data: map[string]any{"status": p.Status, "tests": len(p.Tests), "base": p.Base}}
}
