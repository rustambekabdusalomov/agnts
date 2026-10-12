package orchestrator

import (
	"context"
	"fmt"
	"path"
	"strings"

	"agnts/internal/coverage"
	"agnts/internal/domain"
	"agnts/internal/toolchain"
)

// measureCoverage runs the repository's tests with coverage and measures
// the lines the change adds. It never fails the run: what it could not do
// is in Coverage.Error.
func (o *Orchestrator) measureCoverage(ctx context.Context, ws Workspace, t domain.Ticket, run *domain.Run, repo domain.Repository, files []domain.FileChange) *domain.Coverage {
	cfg := repo.Harness.Coverage
	if !cfg.Enabled {
		return nil
	}
	cmd, report := cfg.Command, cfg.Report
	if cmd == "" {
		cmd, report = toolchain.Coverage(repo.Toolchains, repo.TestCmd)
	}
	if cmd == "" {
		return &domain.Coverage{Threshold: cfg.Threshold, Error: "agnts knows no coverage command for this repository's toolchains; set one under Repositories → Checks"}
	}
	if !path.IsAbs(report) {
		report = path.Join("/workspace", report)
	}
	r, err := ws.Exec(ctx, cmd, o.cfg.CheckTimeout)
	if err != nil || r.ExitCode != 0 {
		msg := fmt.Sprintf("the coverage run failed (exit %d): %s", r.ExitCode, tail(r.Output, 600))
		if err != nil {
			msg = "the coverage run failed: " + err.Error()
		}
		return &domain.Coverage{Threshold: cfg.Threshold, Error: msg}
	}
	raw, err := ws.ReadFile(ctx, report)
	if err != nil {
		return &domain.Coverage{Threshold: cfg.Threshold, Error: "the coverage run wrote no report at " + report}
	}
	lines, err := coverage.Parse(raw, "/workspace", o.goModules(ctx, ws, repo))
	if err != nil {
		return &domain.Coverage{Threshold: cfg.Threshold, Error: err.Error()}
	}
	c := coverage.Measure(files, lines, cfg.Threshold)
	msg := fmt.Sprintf("changed lines covered by tests: %.1f%% (%d of %d)", c.Percent, c.Covered, c.Total)
	level := domain.LevelInfo
	if c.Total == 0 {
		msg = "no changed line is code the coverage report measures"
	} else if cfg.Threshold > 0 && c.Percent < float64(cfg.Threshold) {
		msg += fmt.Sprintf(", below the repository's %d%%", cfg.Threshold)
		level = domain.LevelWarn
	}
	o.event(ctx, domain.Event{TicketKey: t.Key, RunID: &run.ID, Step: "checks", Type: domain.EventCoverage, Level: level, Message: msg,
		Data: map[string]any{"percent": c.Percent, "covered": c.Covered, "total": c.Total, "threshold": cfg.Threshold}})
	return &c
}

// goModules maps the Go modules of a repository to their directories,
// from the go.mod files next to its Go toolchains.
func (o *Orchestrator) goModules(ctx context.Context, ws Workspace, repo domain.Repository) map[string]string {
	out := map[string]string{}
	dirs := []string{""}
	for _, tc := range repo.Toolchains {
		if tc.Tool == "go" && tc.Dir != "" {
			dirs = append(dirs, tc.Dir)
		}
	}
	for _, d := range dirs {
		b, err := ws.ReadFile(ctx, path.Join("/workspace", d, "go.mod"))
		if err != nil {
			continue
		}
		for _, l := range strings.Split(string(b), "\n") {
			if m, ok := strings.CutPrefix(strings.TrimSpace(l), "module "); ok {
				out[strings.Trim(strings.TrimSpace(m), `"`)] = d
				break
			}
		}
	}
	return out
}

// coverageFinding is the review finding for a change below the threshold.
func coverageFinding(c *domain.Coverage) *domain.Finding {
	if c == nil || c.Threshold <= 0 || c.Total == 0 || c.Percent >= float64(c.Threshold) {
		return nil
	}
	var b strings.Builder
	for i, f := range c.Files {
		if i == 8 {
			break
		}
		if len(f.Uncovered) == 0 {
			continue
		}
		var rs []string
		for _, r := range f.Uncovered {
			if r.From == r.To {
				rs = append(rs, fmt.Sprint(r.From))
			} else {
				rs = append(rs, fmt.Sprintf("%d-%d", r.From, r.To))
			}
		}
		fmt.Fprintf(&b, "\n- %s: lines %s", f.Path, strings.Join(rs, ", "))
	}
	first := ""
	line := 0
	for _, f := range c.Files {
		if len(f.Uncovered) > 0 {
			first, line = f.Path, f.Uncovered[0].From
			break
		}
	}
	return &domain.Finding{Severity: "minor", Category: "tests", File: first, Line: line, Confidence: 1,
		Title:      fmt.Sprintf("Tests cover %.1f%% of the changed lines, below the repository's %d%%", c.Percent, c.Threshold),
		Detail:     "These added lines never ran in the tests:" + b.String(),
		Suggestion: "Add tests that exercise the uncovered changed lines listed in the review."}
}
