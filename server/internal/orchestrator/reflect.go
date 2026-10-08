package orchestrator

import (
	"archive/tar"
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"strings"
	"time"

	"agnts/internal/domain"
)

// ReflectPath is where a reflect run writes the rules it suggests.
const ReflectPath = "/agnts/out/reflect.json"

// Limits of a reflect run: it reads one piece of feedback and a diff.
const (
	reflectMaxTurns    = 30
	reflectTimeoutMin  = 15
	reflectMaxSuggest  = 2
	reflectMaxFeedback = 8000
)

// ReflectFile is what a reflect run must write to ReflectPath.
type ReflectFile struct {
	Suggestions []struct {
		Title string `json:"title"`
		Body  string `json:"body"`
		Scope string `json:"scope"` // repository or global
		Why   string `json:"why"`
	} `json:"suggestions"`
}

// queueReflection keeps what a person said about a ticket's work for a
// reflect run, when Settings allow it. Failures only log: the person's
// action has happened already.
func (o *Orchestrator) queueReflection(ctx context.Context, t domain.Ticket, source, feedback string, origin domain.Origin) {
	if o.reflections == nil || o.rules == nil || origin == domain.OriginSystem || strings.TrimSpace(feedback) == "" || t.ReplayOf != "" {
		return
	}
	s, err := o.settings.Get(ctx)
	if err != nil || !s.Reflect {
		return
	}
	if err := o.reflections.QueueReflection(ctx, domain.Reflection{TicketKey: t.Key, RepoID: t.RepoID, Source: source,
		Feedback: truncate(feedback, reflectMaxFeedback)}); err != nil {
		o.log.Warn("queue reflection", "ticket", t.Key, "err", err)
		return
	}
	o.Wake()
}

// reflect reads a claimed piece of feedback and suggests rules that would
// have avoided it. Suggestions never reach tickets until someone adopts
// them.
func (o *Orchestrator) reflect(ctx context.Context, r domain.Reflection) {
	log := o.log.With("ticket", r.TicketKey, "reflection", r.ID)
	saved, err := o.runReflect(ctx, r)
	if ctx.Err() != nil {
		log.Info("reflect interrupted") // RecoverReflections requeues it
		return
	}
	bg := context.WithoutCancel(ctx)
	var stop *stopError
	status, msg := domain.ReflectDone, ""
	switch {
	case errors.As(err, &stop):
		status = domain.ReflectPending // claimed again once usage allows
	case err != nil:
		status, msg = domain.ReflectFailed, err.Error()
		log.Warn("reflect failed", "err", err)
	}
	if ferr := o.reflections.FinishReflection(bg, r.ID, status, len(saved), msg); ferr != nil {
		log.Error("finish reflection", "err", ferr)
	}
	if len(saved) == 0 {
		return
	}
	titles := make([]string, len(saved))
	ids := make([]int64, len(saved))
	for i, x := range saved {
		titles[i], ids[i] = x.Title, x.ID
	}
	o.event(bg, domain.Event{TicketKey: r.TicketKey, Type: domain.EventRule, Step: "rules",
		Message: fmt.Sprintf("agnts learned from your feedback and suggests %d %s: %s", len(saved), plural(len(saved), "rule", "rules"), strings.Join(titles, ", ")),
		Data:    map[string]any{"suggested": len(saved), "ids": ids, "titles": titles}})
}

func (o *Orchestrator) runReflect(ctx context.Context, r domain.Reflection) ([]domain.Rule, error) {
	s, err := o.settings.Get(ctx)
	if err != nil {
		return nil, err
	}
	t, err := o.store.TicketByKey(ctx, r.TicketKey)
	if errors.Is(err, domain.ErrNotFound) {
		return nil, nil // deleted since: nothing to learn from
	}
	if err != nil {
		return nil, err
	}
	d := promptData{T: t, Feedback: r.Feedback, Source: r.Source, NoRepo: r.RepoID == nil}
	var repo *domain.Repository
	if r.RepoID != nil {
		x, err := o.store.RepositoryByID(ctx, *r.RepoID)
		if err != nil && !errors.Is(err, domain.ErrNotFound) {
			return nil, err
		}
		if err == nil {
			repo, d.Repo = &x, x
		}
	}
	d.NoRepo = repo == nil
	var tree io.Reader
	if repo != nil {
		if err := o.git.Prepare(ctx, *repo, repo.DefaultBranch); err != nil {
			return nil, fmt.Errorf("prepare repository: %w", err)
		}
		rc, err := o.git.Archive(ctx, *repo, repo.DefaultBranch)
		if err != nil {
			return nil, fmt.Errorf("archive repository: %w", err)
		}
		defer func() { _ = rc.Close() }()
		tree = rc
	} else {
		var empty bytes.Buffer
		_ = tar.NewWriter(&empty).Close()
		tree = &empty
	}
	known, err := o.rules.KnownRules(ctx, r.RepoID)
	if err != nil {
		return nil, err
	}
	d.Rules = known

	ws, err := o.runner.Open(ctx, WorkspaceSpec{TicketKey: fmt.Sprintf("reflect-%d", r.ID), Image: o.cfg.Image, Repo: tree})
	if err != nil {
		return nil, fmt.Errorf("start container: %w", err)
	}
	defer func() {
		if err := ws.Close(context.WithoutCancel(ctx)); err != nil {
			o.log.Warn("remove container", "reflection", r.ID, "err", err)
		}
	}()
	if res, err := o.store.LatestResult(ctx, t.ID, domain.StageCode); err == nil && len(res.Files) > 0 {
		if err := ws.WriteFile(ctx, ChangePath, changeDiff(res.Files)); err != nil {
			return nil, fmt.Errorf("copy the diff: %w", err)
		}
		d.Files = res.Files
		if len(d.Files) > learnMaxFiles {
			d.Files = d.Files[:learnMaxFiles]
		}
	} else if err == nil && res.Report != "" {
		if err := ws.WriteFile(ctx, ReportPath, []byte(res.Report)); err != nil {
			return nil, fmt.Errorf("copy the report: %w", err)
		}
		d.HasReport = true
	}
	d.Context = o.contextFiles(ctx, ws, domain.Ticket{}, repo) // no precedents: the feedback is about this ticket
	prompt, err := render("reflect", d)
	if err != nil {
		return nil, err
	}
	res, err := ws.Claude(ctx, ClaudeRequest{
		Prompt:   prompt,
		Model:    s.Models.Learn,
		MaxTurns: min(s.MaxTurns, reflectMaxTurns),
		Timeout:  time.Duration(min(s.TimeoutMin, reflectTimeoutMin)) * time.Minute,
		Settings: permissionSettings(s, true),
	}, func(e ClaudeEvent) {
		if e.Kind == ClaudeRateLimit {
			o.usage.Record(ctx, e.Data)
		}
	})
	if err != nil {
		return nil, err
	}
	if res.RateLimited {
		o.usage.RecordLimited(ctx)
		return nil, &stopError{"rate limited"}
	}
	if res.IsError {
		return nil, fmt.Errorf("claude ended with %s: %s", res.Subtype, truncate(res.Text, 500))
	}
	raw, err := ws.ReadFile(ctx, ReflectPath)
	if err != nil {
		return nil, fmt.Errorf("claude did not write %s: %w", ReflectPath, err)
	}
	var f ReflectFile
	if err := json.Unmarshal(raw, &f); err != nil {
		return nil, fmt.Errorf("reflect.json is not valid JSON: %w", err)
	}
	var saved []domain.Rule
	for _, x := range f.Suggestions {
		if len(saved) == reflectMaxSuggest {
			break
		}
		rule := domain.Rule{Title: x.Title, Body: x.Body, Enabled: true, Status: domain.RuleSuggested, Kind: domain.KindInstruction,
			SourceTicket: t.Key, Reason: truncate(strings.TrimSpace(x.Why), 1000)}
		if strings.EqualFold(strings.TrimSpace(x.Scope), "repository") && repo != nil {
			rule.RepoID = &repo.ID
		}
		if rule.Validate() != nil || duplicateRule(known, rule) {
			continue
		}
		created, err := o.rules.CreateRule(ctx, rule, func(x domain.Rule) domain.Event {
			ev := *ruleEvent(x, domain.OriginSystem, "", fmt.Sprintf("agnts suggests rule %q from feedback on %s", x.Title, t.Key))
			return ev
		})
		if err != nil {
			return saved, err
		}
		known = append(known, created)
		saved = append(saved, created)
	}
	return saved, nil
}

// duplicateRule reports whether a rule with the same title already exists
// where r would apply (any status, declined suggestions included).
func duplicateRule(known []domain.Rule, r domain.Rule) bool {
	for _, k := range known {
		if strings.EqualFold(strings.TrimSpace(k.Title), strings.TrimSpace(r.Title)) {
			return true
		}
	}
	return false
}
