package orchestrator

import (
	"archive/tar"
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"time"

	"agnts/internal/ai"
	"agnts/internal/domain"
)

// LogTriagePath is where a triage run writes its answer.
const LogTriagePath = "/agnts/out/triage.json"

const (
	logTriageMaxTurns   = 6
	logTriageTimeoutMin = 3
)

// LogTriage is a model's take on a log finding.
type LogTriage struct {
	Class       string `json:"class"`
	Severity    string `json:"severity"`
	Title       string `json:"title"`
	Remediation string `json:"remediation"`
}

// TriageLogFinding asks the light model what a new log finding is, in an
// empty workspace. It goes through the AI gateway like every call: the
// workspace's default person's modules and funding, recorded in the run
// history.
func (o *Orchestrator) TriageLogFinding(ctx context.Context, f domain.LogFinding, sample string) (LogTriage, error) {
	s, err := o.settings.Get(ctx)
	if err != nil {
		return LogTriage{}, err
	}
	meta := transcriptMeta{Purpose: domain.PurposeLogTriage, WorkspaceID: domain.WorkspaceOf(ctx), Subject: f.Service}
	if err := o.hold(ctx, meta, domain.TierLight); err != nil {
		return LogTriage{}, err
	}
	prompt, err := render("logtriage", promptData{})
	if err != nil {
		return LogTriage{}, err
	}
	in, err := json.Marshal(map[string]any{"category": f.Category, "detector": f.Detector, "class": f.Class, "severity": f.Severity,
		"title": f.Title, "service": f.Service, "count": f.Count, "excerpt": sample})
	if err != nil {
		return LogTriage{}, err
	}
	var empty bytes.Buffer
	_ = tar.NewWriter(&empty).Close()
	ws, err := o.runner.Open(ctx, WorkspaceSpec{TicketKey: fmt.Sprintf("log-triage-%d", f.ID), Image: o.cfg.Image, Repo: &empty})
	if err != nil {
		return LogTriage{}, fmt.Errorf("start container: %w", err)
	}
	defer func() {
		if err := ws.Close(context.WithoutCancel(ctx)); err != nil {
			o.log.Warn("remove container", "finding", f.ID, "err", err)
		}
	}()
	if err := ws.WriteFile(ctx, SourcePath, in); err != nil {
		return LogTriage{}, fmt.Errorf("write finding: %w", err)
	}
	res, err := o.callClaude(ctx, ws, meta, ai.Request{
		Prompt:   prompt,
		Model:    domain.TierLight,
		MaxTurns: min(s.MaxTurns, logTriageMaxTurns),
		Timeout:  time.Duration(min(s.TimeoutMin, logTriageTimeoutMin)) * time.Minute,
		Settings: permissionSettings(s, true),
	}, nil)
	if err != nil {
		return LogTriage{}, err
	}
	if res.RateLimited {
		return LogTriage{}, ErrPlanLimit
	}
	if res.IsError {
		return LogTriage{}, fmt.Errorf("%s ended with %s: %s", domain.AgentName(res.Model), res.Subtype, truncate(res.Text, 500))
	}
	raw, err := ws.ReadFile(ctx, LogTriagePath)
	if err != nil {
		return LogTriage{}, fmt.Errorf("%s did not write %s: %w", domain.AgentName(res.Model), LogTriagePath, err)
	}
	var out LogTriage
	if err := json.Unmarshal(raw, &out); err != nil {
		return LogTriage{}, errors.New("triage.json is not valid JSON")
	}
	return out, nil
}
