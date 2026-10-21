package orchestrator

import (
	"context"
	"fmt"
	"slices"
	"strings"
	"sync"

	"agnts/internal/domain"
)

// Checks that already fail on the commit a ticket starts from are not the
// ticket's: agnts runs the checks there before the first coding run, tells
// the coder which fail already, keeps them out of the stop gate, and does
// not spend fix attempts (or fail the ticket) on them.

// baselineDue reports whether t's coding run first checks its base commit:
// the first coding run of code work with checks on.
func baselineDue(s domain.Settings, t domain.Ticket) bool {
	return s.BaselineChecks && !t.SkipChecks && t.HeadSHA == "" && !t.Kind.Report() && t.Kind != domain.KindReview
}

// baselineKey names one check on one commit of a repository.
type baselineKey struct {
	repo     int64
	sha, cmd string
}

// baselines caches check results by commit: tickets started from the same
// commit share them.
type baselines struct {
	mu sync.Mutex
	m  map[baselineKey]CheckStep
}

func (b *baselines) get(k baselineKey) (CheckStep, bool) {
	b.mu.Lock()
	defer b.mu.Unlock()
	s, ok := b.m[k]
	return s, ok
}

func (b *baselines) put(k baselineKey, s CheckStep) {
	b.mu.Lock()
	defer b.mu.Unlock()
	if b.m == nil {
		b.m = map[baselineKey]CheckStep{}
	}
	if len(b.m) > 2000 {
		clear(b.m) // a long-running server: keep it bounded
	}
	b.m[k] = s
}

// baselineChecks runs the repositories' checks on the commit the work
// starts from and returns the ones that fail, named as runChecks names
// them. Like runChecks it stops a repository at its first failure.
func (o *Orchestrator) baselineChecks(ctx context.Context, ws Workspace, t domain.Ticket, rs []runRepo, run *domain.Run) []CheckStep {
	var failed []CheckStep
	multi := len(rs) > 1
	for _, r := range rs {
		if r.Frozen {
			continue
		}
		head, err := ws.Exec(ctx, r.Cmd("git rev-parse HEAD"), o.cfg.CheckTimeout)
		sha := strings.TrimSpace(head.Output)
		if err != nil || head.ExitCode != 0 || len(sha) < 7 {
			continue
		}
		for _, c := range []struct{ name, cmd string }{
			{"build", r.BuildCmd}, {"lint", r.LintCmd}, {"test", r.TestCmd},
		} {
			if strings.TrimSpace(c.cmd) == "" {
				continue
			}
			name := c.name
			if multi {
				name = r.Name + " " + c.name
			}
			k := baselineKey{repo: r.ID, sha: sha, cmd: c.cmd}
			step, ok := o.baselines.get(k)
			if !ok {
				res, err := ws.Exec(ctx, r.Cmd(c.cmd), o.cfg.CheckTimeout)
				if err != nil || ctx.Err() != nil {
					break // could not run: no baseline for it
				}
				step = CheckStep{Name: name, Command: c.cmd, ExitCode: res.ExitCode, DurationMS: res.Duration.Milliseconds(), TimedOut: res.TimedOut}
				if res.ExitCode != 0 || res.TimedOut {
					step.Output = tail(res.Output, 8000)
				}
				o.baselines.put(k, step)
			}
			step.Name = name
			if step.ExitCode == 0 && !step.TimedOut {
				continue
			}
			failed = append(failed, step)
			o.event(ctx, domain.Event{TicketKey: t.Key, RunID: &run.ID, Step: "baseline", Type: domain.EventBaseline, Level: domain.LevelWarn,
				Message: fmt.Sprintf("%s already fails on the commit the work starts from (%.7s, exit %d): not this ticket's to fix", name, sha, step.ExitCode),
				Data:    map[string]any{"name": name, "command": c.cmd, "exit_code": step.ExitCode, "sha": sha, "output": tail(step.Output, 2000)}})
			break
		}
	}
	for _, f := range failed {
		run.Harness.BaselineFailed = append(run.Harness.BaselineFailed, f.Name)
	}
	return failed
}

// preexisting reports whether the check that failed in rep also failed,
// the same way, on the base commit.
func preexisting(rep checkReport, failed []string) (CheckStep, bool) {
	if len(rep.Steps) == 0 || len(failed) == 0 {
		return CheckStep{}, false
	}
	last := rep.Steps[len(rep.Steps)-1]
	if last.ExitCode == 0 && !last.TimedOut {
		return CheckStep{}, false
	}
	return last, slices.Contains(failed, last.Name)
}
