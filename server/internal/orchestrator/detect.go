package orchestrator

import (
	"context"
	"encoding/json"
	"fmt"
	"strings"
	"time"

	"agnts/internal/domain"
	"agnts/internal/toolchain"
)

// DetectPath is where the detect run writes what it found.
const DetectPath = "/agnts/out/toolchains.json"

const (
	detectMaxTurns   = 25
	detectTimeoutMin = 5
)

type detectFile struct {
	Toolchains []domain.Toolchain `json:"toolchains"`
	Build      string             `json:"build"`
	Lint       string             `json:"lint"`
	Test       string             `json:"test"`
	Notes      []string           `json:"notes"`
}

// DetectDeep asks Claude to read a repository's README, CI and build
// files when the file scan (base) left gaps, and fills them: toolchains
// the scan missed are added, and empty commands take Claude's. What the
// scan found always wins. The repository's default branch is read.
func (o *Orchestrator) DetectDeep(ctx context.Context, repo domain.Repository, base toolchain.Detection) (toolchain.Detection, error) {
	s, err := o.settings.Get(ctx)
	if err != nil {
		return base, err
	}
	if paused, _ := o.usage.Paused(ctx, s); paused {
		return base, ErrPlanLimit
	}
	if err := o.git.Prepare(ctx, repo, repo.DefaultBranch); err != nil {
		return base, fmt.Errorf("prepare repository: %w", err)
	}
	rc, err := o.git.Archive(ctx, repo, repo.DefaultBranch)
	if err != nil {
		return base, fmt.Errorf("archive repository: %w", err)
	}
	defer func() { _ = rc.Close() }()
	prompt, err := render("detect", promptData{Repo: repo, Detected: base})
	if err != nil {
		return base, err
	}
	ws, err := o.runner.Open(ctx, WorkspaceSpec{TicketKey: "detect-" + repo.Name, Image: o.cfg.Image, Repo: rc})
	if err != nil {
		return base, fmt.Errorf("start container: %w", err)
	}
	defer func() {
		if err := ws.Close(context.WithoutCancel(ctx)); err != nil {
			o.log.Warn("remove container", "repo", repo.Name, "err", err)
		}
	}()
	res, err := ws.Claude(ctx, ClaudeRequest{
		Prompt:   prompt,
		Model:    s.Models.Helper,
		MaxTurns: min(s.MaxTurns, detectMaxTurns),
		Timeout:  time.Duration(min(s.TimeoutMin, detectTimeoutMin)) * time.Minute,
		Settings: permissionSettings(s, true),
	}, func(e ClaudeEvent) {
		if e.Kind == ClaudeRateLimit {
			o.usage.Record(ctx, e.Data)
		}
	})
	if err != nil {
		return base, err
	}
	if res.RateLimited {
		o.usage.RecordLimited(ctx)
		return base, ErrPlanLimit
	}
	if res.IsError {
		return base, fmt.Errorf("claude ended with %s: %s", res.Subtype, truncate(res.Text, 500))
	}
	raw, err := ws.ReadFile(ctx, DetectPath)
	if err != nil {
		return base, fmt.Errorf("claude did not write %s: %w", DetectPath, err)
	}
	var f detectFile
	if err := json.Unmarshal(raw, &f); err != nil {
		return base, fmt.Errorf("toolchains.json is not valid JSON: %w", err)
	}
	return mergeDetection(base, f), nil
}

// mergeDetection fills base's gaps with Claude's findings. Toolchains
// that fail validation are dropped with a note.
func mergeDetection(base toolchain.Detection, f detectFile) toolchain.Detection {
	out := base
	out.Toolchains = append([]domain.Toolchain(nil), base.Toolchains...)
	have := map[string]bool{}
	for _, t := range base.Toolchains {
		have[t.Tool] = true
	}
	for _, t := range f.Toolchains {
		t.Tool, t.Version = strings.ToLower(strings.TrimSpace(t.Tool)), strings.TrimSpace(t.Version)
		if t.Version == "" {
			t.Version = "latest"
		}
		t.Source = "claude"
		if err := t.Validate(); err != nil {
			out.Notes = append(out.Notes, "Claude suggested "+t.Spec()+", which was left out: "+err.Error())
			continue
		}
		if have[t.Tool] || len(out.Toolchains) >= domain.MaxToolchains {
			continue
		}
		have[t.Tool] = true
		out.Toolchains = append(out.Toolchains, t)
	}
	clean := func(s string) string {
		s = strings.TrimSpace(s)
		if len(s) > 500 || strings.ContainsAny(s, "\n\r") {
			return ""
		}
		return s
	}
	if out.Build == "" {
		out.Build = clean(f.Build)
	}
	if out.Lint == "" {
		out.Lint = clean(f.Lint)
	}
	if out.Test == "" {
		out.Test = clean(f.Test)
	}
	for _, n := range f.Notes {
		if n = strings.TrimSpace(n); n != "" && len(out.Notes) < 20 {
			out.Notes = append(out.Notes, truncate(n, 300))
		}
	}
	return out
}
