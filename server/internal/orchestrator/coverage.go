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

// measureCoverage runs the repositories' tests with coverage and measures
// the lines the change adds. It never fails the run: what it could not do
// is in Coverage.Error. In a ticket of several repositories each changed
// repository with coverage on is measured, and the results are added up.
// None for a ticket whose checks are skipped: coverage runs the tests.
func (o *Orchestrator) measureCoverage(ctx context.Context, ws Workspace, t domain.Ticket, run *domain.Run, rs []runRepo, files []domain.FileChange) *domain.Coverage {
	if t.SkipChecks {
		return nil
	}
	if len(rs) == 1 {
		return o.measureRepoCoverage(ctx, ws, t, run, rs[0], files, false)
	}
	var sum *domain.Coverage
	var errs []string
	for _, r := range rs {
		fs := domain.FilesIn(files, r.ID, t.RepoID)
		if len(fs) == 0 || r.Frozen {
			continue
		}
		c := o.measureRepoCoverage(ctx, ws, t, run, r, fs, true)
		if c == nil {
			continue
		}
		if sum == nil {
			sum = &domain.Coverage{Threshold: c.Threshold}
		}
		if c.Error != "" {
			errs = append(errs, r.Name+": "+c.Error)
			continue
		}
		sum.Covered += c.Covered
		sum.Total += c.Total
		sum.Threshold = max(sum.Threshold, c.Threshold)
		for _, f := range c.Files {
			f.Path = r.Rel(f.Path)
			sum.Files = append(sum.Files, f)
		}
	}
	if sum == nil {
		return nil
	}
	if sum.Total > 0 {
		sum.Percent = float64(sum.Covered) * 100 / float64(sum.Total)
	}
	sum.Error = strings.Join(errs, "; ")
	return sum
}

// measureRepoCoverage measures one repository's coverage of the lines its
// change adds (files, paths relative to it).
func (o *Orchestrator) measureRepoCoverage(ctx context.Context, ws Workspace, t domain.Ticket, run *domain.Run, r runRepo, files []domain.FileChange, multi bool) *domain.Coverage {
	repo := r.Repository
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
		report = path.Join(r.Dir(), report)
	}
	res, err := ws.Exec(ctx, r.Cmd(cmd), o.cfg.CheckTimeout)
	if err != nil || res.ExitCode != 0 {
		msg := fmt.Sprintf("the coverage run failed (exit %d): %s", res.ExitCode, tail(res.Output, 600))
		if err != nil {
			msg = "the coverage run failed: " + err.Error()
		}
		return &domain.Coverage{Threshold: cfg.Threshold, Error: msg}
	}
	raw, err := ws.ReadFile(ctx, report)
	if err != nil {
		return &domain.Coverage{Threshold: cfg.Threshold, Error: "the coverage run wrote no report at " + report}
	}
	lines, err := coverage.Parse(raw, r.Dir(), o.goModules(ctx, ws, r))
	if err != nil {
		return &domain.Coverage{Threshold: cfg.Threshold, Error: err.Error()}
	}
	c := coverage.Measure(files, lines, cfg.Threshold)
	msg := fmt.Sprintf("%schanged lines covered by tests: %.1f%% (%d of %d)", r.Label(multi), c.Percent, c.Covered, c.Total)
	level := domain.LevelInfo
	if c.Total == 0 {
		msg = r.Label(multi) + "no changed line is code the coverage report measures"
	} else if cfg.Threshold > 0 && c.Percent < float64(cfg.Threshold) {
		msg += fmt.Sprintf(", below the repository's %d%%", cfg.Threshold)
		level = domain.LevelWarn
	}
	o.event(ctx, domain.Event{TicketKey: t.Key, RunID: &run.ID, Step: "checks", Type: domain.EventCoverage, Level: level, Message: msg,
		Data: map[string]any{"percent": c.Percent, "covered": c.Covered, "total": c.Total, "threshold": cfg.Threshold, "repoId": r.ID}})
	return &c
}

// goModules maps the Go modules of a repository to their directories,
// from the go.mod files next to its Go toolchains.
func (o *Orchestrator) goModules(ctx context.Context, ws Workspace, r runRepo) map[string]string {
	repo := r.Repository
	out := map[string]string{}
	dirs := []string{""}
	for _, tc := range repo.Toolchains {
		if tc.Tool == "go" && tc.Dir != "" {
			dirs = append(dirs, tc.Dir)
		}
	}
	for _, d := range dirs {
		b, err := ws.ReadFile(ctx, path.Join(r.Dir(), d, "go.mod"))
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
