package orchestrator

import (
	"context"
	"fmt"
	"strings"

	"hiro/internal/domain"
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
}

// runChecks runs build, lint and test in order, stopping at the first failure.
func (o *Orchestrator) runChecks(ctx context.Context, ws Workspace, t domain.Ticket, repo domain.Repository, run *domain.Run) checkReport {
	rep := checkReport{OK: true}
	for _, c := range []struct{ name, cmd string }{
		{"build", repo.BuildCmd}, {"lint", repo.LintCmd}, {"test", repo.TestCmd},
	} {
		if strings.TrimSpace(c.cmd) == "" {
			continue
		}
		res, err := ws.Exec(ctx, c.cmd, o.cfg.CheckTimeout)
		step := CheckStep{Name: c.name, Command: c.cmd, ExitCode: res.ExitCode, DurationMS: res.Duration.Milliseconds(), TimedOut: res.TimedOut}
		ok := err == nil && res.ExitCode == 0 && !res.TimedOut
		if c.name == "lint" {
			rep.LintOutput = tail(res.Output, 4000)
		}
		level, msg := domain.LevelInfo, fmt.Sprintf("%s passed", c.name)
		if !ok {
			step.Output = tail(res.Output, 8000)
			level, msg = domain.LevelWarn, fmt.Sprintf("%s failed (exit %d)", c.name, res.ExitCode)
			if res.TimedOut {
				msg = fmt.Sprintf("%s timed out after %s", c.name, o.cfg.CheckTimeout)
			}
			if err != nil {
				msg = fmt.Sprintf("%s could not run: %v", c.name, err)
				step.Output = err.Error()
			}
		}
		d := res.Duration.Milliseconds()
		o.event(ctx, domain.Event{
			TicketKey: t.Key, RunID: &run.ID, Step: "checks", Type: domain.EventCheck, Level: level, Message: msg,
			DurationMS: &d, Data: map[string]any{"name": c.name, "command": c.cmd, "exit_code": res.ExitCode, "output": step.Output},
		})
		rep.Steps = append(rep.Steps, step)
		if !ok {
			rep.OK = false
			rep.FailOutput = fmt.Sprintf("$ %s\n%s", c.cmd, step.Output)
			return rep
		}
	}
	return rep
}

// tail keeps the end of s, where build and test failures usually are.
func tail(s string, n int) string {
	if len(s) <= n {
		return s
	}
	return "…" + s[len(s)-n:]
}
