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
		Tag   string `json:"tag"` // reuse, layer, tests, style, logic or other
	} `json:"suggestions"`
	// Reinforces are suggestions already made that this feedback shows
	// again.
	Reinforces []struct {
		ID       int64  `json:"id"`
		Evidence string `json:"evidence"`
	} `json:"reinforces"`
}

// queueReflection keeps what a person said about a ticket's work for a
// reflect run, when Settings allow it. Failures only log: the person's
// action has happened already.
func (o *Orchestrator) queueReflection(ctx context.Context, t domain.Ticket, source, feedback string, origin domain.Origin) {
	// A review's feedback is about how to review, not about agnts's code:
	// it goes to the reviewer's profile instead (noteReviewer).
	if o.reflections == nil || o.rules == nil || origin == domain.OriginSystem || strings.TrimSpace(feedback) == "" || t.ReplayOf != "" ||
		t.Kind == domain.KindReview {
		return
	}
	s, err := o.settings.Get(ctx)
	if err != nil || !s.Reflect {
		return
	}
	if err := o.reflections.QueueReflection(ctx, domain.Reflection{TicketKey: t.Key, RepoID: t.RepoID, RepoIDs: multiIDs(t), Source: source,
		Feedback: truncate(feedback, reflectMaxFeedback)}); err != nil {
		o.log.Warn("queue reflection", "ticket", t.Key, "err", err)
		return
	}
	o.Wake()
}

// maxTrouble is how many troubles a run keeps for its lesson.
const maxTrouble = 5

// noteTrouble records something that went wrong in a run, for a reflect
// run that may turn it into a tip.
func noteTrouble(run *domain.Run, what string) {
	if len(run.Harness.Trouble) < maxTrouble {
		run.Harness.Trouble = append(run.Harness.Trouble, what)
	}
}

// queueRunLesson queues a reflect run on a coding run that had trouble,
// when the workspace learns from runs.
func (o *Orchestrator) queueRunLesson(ctx context.Context, t domain.Ticket, run domain.Run) {
	if o.reflections == nil || o.rules == nil || t.RepoID == nil || t.ReplayOf != "" {
		return
	}
	s, err := o.settings.Get(ctx)
	if err != nil || !s.LearnFromRuns {
		return
	}
	trouble := fmt.Sprintf("Ticket %s: %s\n\n%s", t.Key, t.Title, strings.Join(run.Harness.Trouble, "\n\n"))
	if err := o.reflections.QueueReflection(ctx, domain.Reflection{TicketKey: t.Key, RepoID: t.RepoID, RepoIDs: multiIDs(t), Source: domain.ReflectRun,
		Feedback: truncate(trouble, 6000)}); err != nil {
		o.log.Warn("queue a lesson from a run", "ticket", t.Key, "err", err)
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
	note := fmt.Sprintf("agnts learned from your feedback and suggests %d %s: %s", len(saved), plural(len(saved), "rule", "rules"), strings.Join(titles, ", "))
	if r.Source == domain.ReflectRun {
		note = fmt.Sprintf("agnts noted %d possible %s from this run's trouble and watches for %s again: %s", len(saved), plural(len(saved), "tip", "tips"),
			plural(len(saved), "it", "them"), strings.Join(titles, ", "))
	}
	o.event(bg, domain.Event{TicketKey: r.TicketKey, Type: domain.EventRule, Step: "rules", Message: note,
		Data: map[string]any{"suggested": len(saved), "ids": ids, "titles": titles, "source": r.Source}})
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
	// Suggestions made in other repositories: the same lesson seen there
	// too is worth a rule for the whole workspace.
	var others []domain.Rule
	if repo != nil {
		all, err := o.rules.ListRules(ctx)
		if err != nil {
			return nil, err
		}
		for _, x := range all {
			if x.Status == domain.RuleSuggested && x.RepoID != nil && *x.RepoID != repo.ID {
				others = append(others, x)
			}
		}
	}
	d.Others = others
	if r.Source == domain.ReflectRun {
		d.Trouble = r.Feedback
	}

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
	var rs []runRepo
	if repo != nil {
		rs = soloRepo(*repo)
	}
	d.Context = o.contextFiles(ctx, ws, domain.Ticket{}, rs) // no precedents: the feedback is about this ticket
	prompt, err := render("reflect", d)
	if err != nil {
		return nil, err
	}
	model := s.Models.Learn
	if r.Source == domain.ReflectRun {
		model = s.Models.Helper // a run's trouble is small and plain: the cheap model reads it
	}
	res, err := o.callClaude(ctx, ws, transcriptMeta{Purpose: domain.PurposeReflect, WorkspaceID: r.WorkspaceID,
		TicketKey: r.TicketKey, Subject: r.Source}, ClaudeRequest{
		Prompt:   prompt,
		Model:    model,
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
		return nil, fmt.Errorf("%s ended with %s: %s", domain.AgentName(res.Model), res.Subtype, truncate(res.Text, 500))
	}
	raw, err := ws.ReadFile(ctx, ReflectPath)
	if err != nil {
		return nil, fmt.Errorf("%s did not write %s: %w", domain.AgentName(res.Model), ReflectPath, err)
	}
	var f ReflectFile
	if err := json.Unmarshal(raw, &f); err != nil {
		return nil, fmt.Errorf("reflect.json is not valid JSON: %w", err)
	}
	return o.saveLessons(ctx, t, r, repo, known, others, f)
}

// saveLessons stores what a reflect run found: new suggestions, with the
// confidence their source earns, and lessons seen again, which gain
// confidence. A suggestion from another repository seen again here is
// proposed for the whole workspace. It returns the new suggestions.
func (o *Orchestrator) saveLessons(ctx context.Context, t domain.Ticket, r domain.Reflection, repo *domain.Repository,
	known, others []domain.Rule, f ReflectFile) ([]domain.Rule, error) {
	fromRun := r.Source == domain.ReflectRun
	now := time.Now()
	byID := map[int64]domain.Rule{}
	for _, x := range append(append([]domain.Rule{}, known...), others...) {
		byID[x.ID] = x
	}
	var saved []domain.Rule
	reinforce := func(id int64, evidence string) error {
		x, ok := byID[id]
		if !ok || x.Status != domain.RuleSuggested {
			return nil
		}
		up, err := o.rules.UpdateRule(ctx, id, func(y *domain.Rule) error {
			if y.Status != domain.RuleSuggested {
				return errStale
			}
			y.Evidence++
			y.Confidence = min(domain.ConfidenceMax, max(y.Confidence, domain.ConfidenceFromRun)+domain.ConfidenceStep)
			y.LastSeen = &now
			return nil
		}, func(y domain.Rule) *domain.Event {
			return ruleEvent(y, domain.OriginSystem, "", fmt.Sprintf("agnts saw the lesson %q again on %s (seen %d %s, confidence %.0f%%)",
				y.Title, t.Key, y.Evidence+1, plural(y.Evidence+1, "time", "times"), y.Confidence*100))
		})
		if errors.Is(err, errStale) {
			return nil
		}
		if err != nil {
			return err
		}
		byID[id] = up
		if repo != nil && up.RepoID != nil && *up.RepoID != repo.ID {
			return o.promote(ctx, up, repo, evidence, known)
		}
		return nil
	}
	for _, x := range f.Reinforces {
		if err := reinforce(x.ID, strings.TrimSpace(x.Evidence)); err != nil {
			return saved, err
		}
	}
	for _, x := range f.Suggestions {
		if len(saved) == reflectMaxSuggest {
			break
		}
		rule := domain.Rule{Title: x.Title, Body: x.Body, Enabled: true, Status: domain.RuleSuggested, Kind: domain.KindInstruction,
			SourceTicket: t.Key, Reason: truncate(strings.TrimSpace(x.Why), 1000),
			Source: "reflect", Confidence: domain.ConfidenceFromFeedback, Evidence: 1, LastSeen: &now, Tag: domain.CleanLessonTag(x.Tag)}
		if r.Source == domain.ReflectMerged || r.Source == domain.ReflectReverted {
			rule.Source = r.Source
		}
		if fromRun {
			rule.Kind, rule.Delivery, rule.Source, rule.Confidence = domain.KindTip, domain.DeliverSkill, "run", domain.ConfidenceFromRun
		}
		if (strings.EqualFold(strings.TrimSpace(x.Scope), "repository") || fromRun) && repo != nil {
			rule.RepoID = &repo.ID
		}
		if rule.Validate() != nil {
			continue
		}
		if dup := sameTitle(known, rule); dup != nil {
			// The same lesson under the same name: it is seen again.
			if err := reinforce(dup.ID, rule.Reason); err != nil {
				return saved, err
			}
			continue
		}
		created, err := o.rules.CreateRule(ctx, rule, func(x domain.Rule) domain.Event {
			msg := fmt.Sprintf("agnts suggests rule %q from feedback on %s", x.Title, t.Key)
			if fromRun {
				msg = fmt.Sprintf("agnts is watching a possible tip from %s's run: %q", t.Key, x.Title)
			}
			return *ruleEvent(x, domain.OriginSystem, "", msg)
		})
		if err != nil {
			return saved, err
		}
		known = append(known, created)
		saved = append(saved, created)
	}
	return saved, nil
}

// promote proposes a lesson seen in two repositories as a rule for the
// whole workspace, unless one with its title exists.
func (o *Orchestrator) promote(ctx context.Context, x domain.Rule, here *domain.Repository, evidence string, known []domain.Rule) error {
	global := domain.Rule{Title: x.Title, Body: x.Body, Enabled: true, Status: domain.RuleSuggested, Kind: x.Kind, Delivery: x.Delivery,
		Source: "promoted", Confidence: max(x.Confidence, domain.ConfidenceShown), Evidence: x.Evidence + 1, LastSeen: x.LastSeen,
		SourceTicket: x.SourceTicket,
		Reason:       truncate(fmt.Sprintf("Seen in %s and again in %s: %s", x.RepoName, here.Name, evidence), 1000)}
	if sameTitle(known, global) != nil {
		return nil
	}
	all, err := o.rules.ListRules(ctx)
	if err != nil {
		return err
	}
	for _, k := range all {
		if k.RepoID == nil && strings.EqualFold(strings.TrimSpace(k.Title), strings.TrimSpace(x.Title)) {
			return nil
		}
	}
	_, err = o.rules.CreateRule(ctx, global, func(g domain.Rule) domain.Event {
		return *ruleEvent(g, domain.OriginSystem, "", fmt.Sprintf("agnts suggests %q for every repository: seen in %s and %s", g.Title, x.RepoName, here.Name))
	})
	return err
}

// sameTitle returns the known rule with r's title, or nil.
func sameTitle(known []domain.Rule, r domain.Rule) *domain.Rule {
	for i := range known {
		if strings.EqualFold(strings.TrimSpace(known[i].Title), strings.TrimSpace(r.Title)) {
			return &known[i]
		}
	}
	return nil
}

// expireSuggestions removes learned suggestions nobody adopted and agnts
// did not see again for SuggestionExpiryDays, so the list holds what
// still matters. Deleted (not dismissed): the lesson may come back.
func (o *Orchestrator) expireSuggestions(ctx context.Context) {
	if o.rules == nil {
		return
	}
	o.forEachWorkspace(ctx, func(wctx context.Context) {
		rules, err := o.rules.ListRules(wctx)
		if err != nil {
			o.log.Warn("list rules to expire", "err", err)
			return
		}
		cutoff := time.Now().AddDate(0, 0, -domain.SuggestionExpiryDays)
		for _, r := range rules {
			if r.Status != domain.RuleSuggested || (r.Source != "reflect" && r.Source != "run" && r.Source != "promoted") {
				continue
			}
			seen := r.CreatedAt
			if r.LastSeen != nil {
				seen = *r.LastSeen
			}
			if seen.After(cutoff) {
				continue
			}
			ev := *ruleEvent(r, domain.OriginSystem, "", fmt.Sprintf("suggestion %q expired: not seen again in %d days", r.Title, domain.SuggestionExpiryDays))
			if err := o.rules.DeleteRule(wctx, r.ID, ev); err != nil && !errors.Is(err, domain.ErrNotFound) {
				o.log.Warn("expire suggestion", "rule", r.ID, "err", err)
			}
		}
	})
}

// multiIDs are a ticket's repositories when it has several, else nil.
func multiIDs(t domain.Ticket) []int64 {
	if !t.Multi() {
		return nil
	}
	return t.RepoIDs()
}
