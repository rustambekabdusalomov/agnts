package orchestrator

import (
	"context"
	"errors"
	"fmt"
	"regexp"
	"strings"

	"agnts/internal/domain"
)

// CheckStep is one check command's outcome, stored with the result.
type CheckStep struct {
	Name       string `json:"name"`
	Command    string `json:"command"`
	ExitCode   int    `json:"exit_code"`
	DurationMS int64  `json:"duration_ms"`
	TimedOut   bool   `json:"timed_out,omitempty"`
	Output     string `json:"output,omitempty"` // tail, kept only on failure
}

type checkReport struct {
	OK         bool
	Steps      []CheckStep
	FailOutput string // what Claude gets to fix
	LintOutput string
	// Unfixable is set when a check failed for a reason Claude cannot fix
	// in the code (a command missing from the container, the container
	// out of memory, a private host it cannot reach or log in to); it says
	// what the person should change instead.
	Unfixable string
	Reason    string // run exit reason for Unfixable
	// Preexisting names the failing check when it failed the same way on
	// the commit the work started from.
	Preexisting string
}

// notFoundRe matches bash's own message for a command of the check line
// itself that is not installed (not one a script it calls is missing).
var notFoundRe = regexp.MustCompile(`(?m)^bash: (?:line \d+: )?([^:\s]+): command not found`)

// unfixable explains a check failure that is not a code problem.
func unfixable(repo domain.Repository, exit int, output string) (msg, reason string) {
	switch exit {
	case 127:
		m := notFoundRe.FindStringSubmatch(output)
		if m == nil {
			return "", ""
		}
		return fmt.Sprintf("`%s` is not installed in the run container. Add the toolchain that provides it under Repositories → %s → Toolchains (installed: %s), or fix the check command.",
			m[1], repo.Name, toolchainList(repo.Toolchains)), "toolchain_missing"
	case 137:
		return fmt.Sprintf("the check was killed (exit 137), most likely because the container ran out of memory. Raise the memory under Repositories → %s → Advanced, or make the check use less (fewer parallel jobs).",
			repo.Name), "out_of_memory"
	}
	return diagnose(repo, output)
}

// runChecks runs build, lint and test in order, stopping at the first
// failure. In a ticket of several repositories it runs each touched
// repository's checks in its folder, one repository after another.
func (o *Orchestrator) runChecks(ctx context.Context, ws Workspace, t domain.Ticket, rs []runRepo, run *domain.Run) checkReport {
	rep := checkReport{OK: true}
	multi := len(rs) > 1
	for _, r := range rs {
		if multi && (r.Frozen || !touched(ctx, ws, r)) {
			continue
		}
		if !o.runRepoChecks(ctx, ws, t, r, multi, run, &rep) {
			return rep
		}
	}
	return rep
}

// touched reports whether the work changed a repository of a run of
// several: files changed in the run, or commits of earlier runs.
func touched(ctx context.Context, ws Workspace, r runRepo) bool {
	return r.Row.Files > 0 || len(changedIn(ctx, ws, r)) > 0
}

// runRepoChecks runs one repository's checks into rep; false when one
// failed.
func (o *Orchestrator) runRepoChecks(ctx context.Context, ws Workspace, t domain.Ticket, r runRepo, multi bool, run *domain.Run, rep *checkReport) bool {
	repo := r.Repository
	for _, c := range []struct{ name, cmd string }{
		{"build", repo.BuildCmd}, {"lint", repo.LintCmd}, {"test", repo.TestCmd},
	} {
		if strings.TrimSpace(c.cmd) == "" {
			continue
		}
		name := c.name
		if multi {
			name = r.Name + " " + c.name
		}
		res, err := ws.Exec(ctx, r.Cmd(c.cmd), o.cfg.CheckTimeout)
		step := CheckStep{Name: name, Command: c.cmd, ExitCode: res.ExitCode, DurationMS: res.Duration.Milliseconds(), TimedOut: res.TimedOut}
		ok := err == nil && res.ExitCode == 0 && !res.TimedOut
		if c.name == "lint" {
			if multi && rep.LintOutput != "" {
				rep.LintOutput += "\n"
			}
			out := tail(res.Output, 4000)
			if multi {
				out = "# " + r.Name + "\n" + out
			}
			rep.LintOutput += out
		}
		level, msg := domain.LevelInfo, fmt.Sprintf("%s passed", name)
		if !ok {
			step.Output = tail(res.Output, 8000)
			level, msg = domain.LevelWarn, fmt.Sprintf("%s failed (exit %d)", name, res.ExitCode)
			if res.TimedOut {
				msg = fmt.Sprintf("%s timed out after %s", name, o.cfg.CheckTimeout)
			}
			if err != nil {
				msg = fmt.Sprintf("%s could not run: %v", name, err)
				step.Output = err.Error()
			}
		}
		d := res.Duration.Milliseconds()
		data := map[string]any{"name": name, "command": c.cmd, "exit_code": res.ExitCode, "output": step.Output}
		if multi {
			data["repoId"], data["repo"] = r.ID, r.Name
		}
		o.event(ctx, domain.Event{
			TicketKey: t.Key, RunID: &run.ID, Step: "checks", Type: domain.EventCheck, Level: level, Message: msg,
			DurationMS: &d, Data: data,
		})
		rep.Steps = append(rep.Steps, step)
		if !ok {
			rep.OK = false
			rep.FailOutput = fmt.Sprintf("$ %s\n%s", c.cmd, step.Output)
			if multi {
				rep.FailOutput = fmt.Sprintf("In %s/ (%s):\n$ %s\n%s", r.Folder(), r.Name, c.cmd, step.Output)
			}
			var oom *OOMError
			switch {
			case errors.As(err, &oom):
				rep.Unfixable, rep.Reason = "the "+c.name+" "+oom.Error(), "out_of_memory"
			case err == nil && !res.TimedOut:
				rep.Unfixable, rep.Reason = unfixable(repo, res.ExitCode, res.Output)
			}
			return false
		}
	}
	return true
}

// tail keeps the end of s, where build and test failures usually are.
func tail(s string, n int) string {
	if len(s) <= n {
		return s
	}
	return "…" + s[len(s)-n:]
}
