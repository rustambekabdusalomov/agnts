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
// In a run of several repositories each test runs in the repository its
// file is in.
func (o *Orchestrator) proveFix(ctx context.Context, ws Workspace, t domain.Ticket, run *domain.Run, rs []runRepo) domain.Proof {
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
	type job struct {
		r  runRepo
		rt ReproTest
	}
	var jobs []job
	for i, rt := range sum.Repro {
		if i == proofMaxTests {
			break
		}
		r, rel, ok := repoOfPath(rs, rt.File)
		if !ok {
			return domain.Proof{Status: domain.ProofError, Why: fmt.Sprintf("the test file %s is in none of the repositories: start its path with the repository's folder", rt.File)}
		}
		rt.File = rel
		jobs = append(jobs, job{r, rt})
	}
	var p domain.Proof
	started := map[int64]string{}
	for _, j := range jobs {
		wt := proofDir
		if j.r.Folder() != "" {
			wt = proofDir + "/" + j.r.Folder()
		}
		if _, ok := started[j.r.ID]; !ok {
			base, err := o.proofBase(ctx, ws, t, j.r)
			if err != nil {
				return domain.Proof{Status: domain.ProofError, Why: j.r.Label(len(rs) > 1) + err.Error()}
			}
			if p.Base == "" {
				p.Base = base
			}
			setup := j.r.Cmd(fmt.Sprintf("rm -rf %[1]s; git worktree prune; git worktree add --detach %[1]s %[2]s", wt, base))
			if r, err := ws.Exec(ctx, setup, 5*time.Minute); err != nil || r.ExitCode != 0 {
				return domain.Proof{Status: domain.ProofError, Base: base, Why: "could not check out the code before the change: " + tail(r.Output+errText(err), 500)}
			}
			started[j.r.ID] = wt
			defer func(r runRepo, wt string) {
				_, _ = ws.Exec(context.WithoutCancel(ctx), r.Cmd(fmt.Sprintf("git worktree remove --force %s; git worktree prune", wt)), time.Minute)
			}(j.r, wt)
		}
		pt := o.proveOne(ctx, ws, j.r.Dir(), wt, j.rt)
		if len(rs) > 1 {
			pt.File = j.r.Rel(pt.File)
		}
		p.Tests = append(p.Tests, pt)
	}
	p.Status = proofStatus(p.Tests)
	return p
}

// repoOfPath finds the run's repository a path is in (relative to
// /workspace, or absolute under it), and the path in that repository.
func repoOfPath(rs []runRepo, p string) (runRepo, string, bool) {
	p = strings.TrimPrefix(path.Clean("/"+strings.TrimPrefix(p, "/workspace/")), "/")
	if len(rs) == 1 {
		return rs[0], p, true
	}
	for _, r := range rs {
		if rest, ok := strings.CutPrefix(p, r.Folder()+"/"); ok {
			return r, rest, true
		}
	}
	return runRepo{}, "", false
}

func errText(err error) string {
	if err == nil {
		return ""
	}
	return err.Error()
}

// proofBase is the commit the change started from, in repository r.
func (o *Orchestrator) proofBase(ctx context.Context, ws Workspace, t domain.Ticket, r runRepo) (string, error) {
	b := shellArg(r.DefaultBranch)
	cmd := "git merge-base HEAD " + b + " 2>/dev/null || git merge-base HEAD origin/" + strings.Trim(b, "'") + " 2>/dev/null"
	if r.Row.BaseSHA != "" {
		cmd += " || echo " + shellArg(r.Row.BaseSHA)
	}
	cmd += " || git rev-parse HEAD"
	res, err := ws.Exec(ctx, r.Cmd(cmd), time.Minute)
	if err != nil {
		return "", err
	}
	base := strings.TrimSpace(res.Output)
	if i := strings.LastIndex(base, "\n"); i >= 0 {
		base = strings.TrimSpace(base[i+1:])
	}
	if res.ExitCode != 0 || len(base) < 7 || strings.ContainsAny(base, " \t") {
		return "", fmt.Errorf("could not find the commit the change started from: %s", tail(res.Output, 300))
	}
	return base, nil
}

func shellArg(s string) string { return "'" + strings.ReplaceAll(s, "'", `'\''`) + "'" }

// proveOne runs one reproducing test before the change (in the worktree
// wt) and after it (in the repository's directory dir).
func (o *Orchestrator) proveOne(ctx context.Context, ws Workspace, dir, wt string, rt ReproTest) domain.ProofTest {
	pt := domain.ProofTest{File: rt.File, Name: rt.Name, Command: rt.Command, At: time.Now()}
	file := path.Clean(strings.TrimPrefix(rt.File, dir+"/"))
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
			src, dst := path.Join(dir, d, dep), path.Join(wt, d, dep)
			links = append(links, fmt.Sprintf("if [ -e %s ] && [ ! -e %s ]; then mkdir -p %s && ln -s %s %s; fi",
				shellArg(src), shellArg(dst), shellArg(path.Dir(dst)), shellArg(src), shellArg(dst)))
		}
		if d == "." || d == "/" {
			break
		}
	}
	prep := fmt.Sprintf("mkdir -p %s && cp %s %s && %s", shellArg(path.Join(wt, path.Dir(file))),
		shellArg(path.Join(dir, file)), shellArg(path.Join(wt, file)), strings.Join(links, " && "))
	if r, err := ws.Exec(ctx, prep, time.Minute); err != nil || r.ExitCode != 0 {
		pt.Status = domain.ProofError
		pt.Before.Output = "could not copy the test into the code before the change: " + tail(r.Output+errText(err), 500)
		return pt
	}
	run := func(d string) domain.ProofRun {
		r, err := ws.Exec(ctx, "cd "+shellArg(d)+" && "+rt.Command, o.cfg.CheckTimeout)
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
	pt.Before = run(wt)
	pt.After = run(dir)
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
