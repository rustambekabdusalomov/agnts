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

	"agnts/internal/ai"
	"agnts/internal/domain"
)

// Limits of a rule review: it reads a rule, not a ticket, so it gets a
// small budget.
const (
	ruleMaxTurns     = 30
	ruleTimeoutMin   = 10
	ruleMaxQuestions = 5
)

// RuleInput is a rule as the user writes it.
type RuleInput struct {
	Title   string
	Body    string
	RepoID  *int64 // nil: every repository
	Enabled bool
	Kind    domain.RuleKind // "" is an instruction
	// Enforce is set when EnforceSet: nil then removes the enforcement.
	Enforce    *domain.RuleEnforce
	EnforceSet bool
	// Delivery is prompt or skill; "" keeps the rule's.
	Delivery string
}

// harness validates the enforcement and delivery of a rule input.
func (in *RuleInput) harness() error {
	if in.Enforce != nil {
		if err := in.Enforce.Validate(); err != nil {
			return invalid("%s", err)
		}
	}
	if in.Delivery != "" && in.Delivery != domain.DeliverPrompt && in.Delivery != domain.DeliverSkill {
		return invalid("delivery must be prompt or skill")
	}
	return nil
}

func (in RuleInput) kind() (domain.RuleKind, error) {
	if in.Kind == "" {
		return domain.KindInstruction, nil
	}
	if !in.Kind.Valid() {
		return "", invalid("kind must be rule or context")
	}
	return in.Kind, nil
}

// RuleAnswer answers the rule question at Index (into Rule.Questions).
type RuleAnswer struct {
	Index  int
	Answer string
	Note   string
}

// RuleReview is what a rule review must write to RulePath.
type RuleReview struct {
	Interpretation string `json:"interpretation"`
	Clarified      string `json:"clarified"`
	// SkillDescription says when the rule applies, in one sentence: the
	// description of the rule's skill.
	SkillDescription string `json:"skillDescription"`
	Questions        []struct {
		Text    string   `json:"text"`
		Options []string `json:"options"`
	} `json:"questions"`
}

var errStale = errors.New("the rule changed during its review")

func (o *Orchestrator) rulesReady() error {
	if o.rules == nil {
		return invalid("rules are not available on this server")
	}
	return nil
}

func ruleEvent(r domain.Rule, origin domain.Origin, level domain.Level, msg string) *domain.Event {
	if level == "" {
		level = domain.LevelInfo
	}
	return &domain.Event{
		Type: domain.EventRule, Step: "rules", Origin: origin, Level: level, Message: msg,
		Data: map[string]any{"ruleId": r.ID, "status": string(r.Status), "title": r.Title},
	}
}

// ListRules returns every rule.
func (o *Orchestrator) ListRules(ctx context.Context) ([]domain.Rule, error) {
	if err := o.rulesReady(); err != nil {
		return nil, err
	}
	return o.rules.ListRules(ctx)
}

// Rule returns one rule.
func (o *Orchestrator) Rule(ctx context.Context, id int64) (domain.Rule, error) {
	if err := o.rulesReady(); err != nil {
		return domain.Rule{}, err
	}
	return o.rules.Rule(ctx, id)
}

func (o *Orchestrator) checkRuleRepo(ctx context.Context, id *int64) error {
	if id == nil {
		return nil
	}
	if _, err := o.store.RepositoryByID(ctx, *id); errors.Is(err, domain.ErrNotFound) {
		return invalid("no such repository")
	} else if err != nil {
		return err
	}
	return nil
}

// CreateRule saves a new rule and queues it for review. It applies to
// tickets once the review finds it clear.
func (o *Orchestrator) CreateRule(ctx context.Context, in RuleInput, origin domain.Origin) (domain.Rule, error) {
	if err := o.rulesReady(); err != nil {
		return domain.Rule{}, err
	}
	kind, err := in.kind()
	if err != nil {
		return domain.Rule{}, err
	}
	r := domain.Rule{Title: in.Title, Body: in.Body, RepoID: in.RepoID, Enabled: in.Enabled, Status: domain.RulePending, Kind: kind,
		Enforce: in.Enforce, Delivery: in.Delivery}
	if err := r.Validate(); err != nil {
		return r, invalid("%s", err)
	}
	if err := in.harness(); err != nil {
		return r, err
	}
	if err := o.checkRuleRepo(ctx, r.RepoID); err != nil {
		return r, err
	}
	r, err = o.rules.CreateRule(ctx, r, func(x domain.Rule) domain.Event {
		return *ruleEvent(x, origin, "", fmt.Sprintf("rule %q added; %s is reviewing it", x.Title, domain.ToolName(domain.AccessOf(ctx))))
	})
	if err == nil {
		o.Wake()
	}
	return r, err
}

// UpdateRule edits a rule. A change to what it says or where it applies
// starts a new review; turning it on or off does not.
func (o *Orchestrator) UpdateRule(ctx context.Context, id int64, in RuleInput, origin domain.Origin) (domain.Rule, error) {
	if err := o.rulesReady(); err != nil {
		return domain.Rule{}, err
	}
	kind, err := in.kind()
	if err != nil {
		return domain.Rule{}, err
	}
	next := domain.Rule{Title: in.Title, Body: in.Body}
	if err := next.Validate(); err != nil {
		return next, invalid("%s", err)
	}
	if err := in.harness(); err != nil {
		return next, err
	}
	if err := o.checkRuleRepo(ctx, in.RepoID); err != nil {
		return next, err
	}
	var msg string
	r, err := o.rules.UpdateRule(ctx, id, func(x *domain.Rule) error {
		changed := x.Title != next.Title || x.Body != next.Body || !sameRepo(x.RepoID, in.RepoID) || x.Kind != kind
		switch {
		case changed:
			msg = fmt.Sprintf("rule %q edited; %s is reviewing it again", next.Title, domain.ToolName(domain.AccessOf(ctx)))
			if x.Status == domain.RuleSuggested {
				msg = fmt.Sprintf("suggested rule %q adopted with changes; %s is reviewing it", next.Title, domain.ToolName(domain.AccessOf(ctx)))
			}
			x.Title, x.Body, x.RepoID, x.Kind = next.Title, next.Body, in.RepoID, kind
			// The old answers and clarification were about the old text.
			x.Questions, x.Rounds, x.Interpretation, x.Clarified = nil, 0, "", ""
			x.Requeue()
		case x.Enabled != in.Enabled && in.Enabled:
			msg = fmt.Sprintf("rule %q turned on", x.Title)
		case x.Enabled != in.Enabled:
			msg = fmt.Sprintf("rule %q turned off", x.Title)
		}
		x.Enabled = in.Enabled
		if in.EnforceSet && !sameEnforce(x.Enforce, in.Enforce) {
			x.Enforce = in.Enforce
			if msg == "" {
				msg = fmt.Sprintf("rule %q: enforcement changed", x.Title)
				if in.Enforce == nil {
					msg = fmt.Sprintf("rule %q is no longer enforced", x.Title)
				}
			}
		}
		if in.Delivery != "" && in.Delivery != x.Delivery {
			x.Delivery = in.Delivery
			if msg == "" {
				msg = fmt.Sprintf("rule %q now reaches runs as a %s", x.Title, map[string]string{domain.DeliverSkill: "skill", domain.DeliverPrompt: "part of every prompt"}[in.Delivery])
			}
		}
		return nil
	}, func(x domain.Rule) *domain.Event {
		if msg == "" {
			return nil
		}
		return ruleEvent(x, origin, "", msg)
	})
	if err == nil && r.Status == domain.RulePending {
		o.Wake()
	}
	return r, err
}

func sameEnforce(a, b *domain.RuleEnforce) bool {
	if a == nil || b == nil {
		return a == b
	}
	return a.On == b.On && a.Pattern == b.Pattern && a.Action == b.Action && a.Message == b.Message && strings.Join(a.Paths, "\x00") == strings.Join(b.Paths, "\x00")
}

func sameRepo(a, b *int64) bool {
	return (a == nil && b == nil) || (a != nil && b != nil && *a == *b)
}

// AnswerRule records answers to a rule's open questions and reviews it
// again with them. Every open question needs an answer.
func (o *Orchestrator) AnswerRule(ctx context.Context, id int64, answers []RuleAnswer, origin domain.Origin) (domain.Rule, error) {
	if err := o.rulesReady(); err != nil {
		return domain.Rule{}, err
	}
	r, err := o.rules.UpdateRule(ctx, id, func(x *domain.Rule) error {
		if x.Status != domain.RuleQuestions {
			return invalid("this rule has no open questions")
		}
		for _, a := range answers {
			if a.Index < 0 || a.Index >= len(x.Questions) || x.Questions[a.Index].Answer != "" {
				return invalid("question %d is not open", a.Index)
			}
			ans := strings.TrimSpace(a.Answer)
			if ans == "" {
				continue
			}
			x.Questions[a.Index].Answer, x.Questions[a.Index].Note = ans, strings.TrimSpace(a.Note)
		}
		if n := len(x.Open()); n > 0 {
			return invalid("%d %s still without an answer", n, plural(n, "question", "questions"))
		}
		x.Requeue()
		return nil
	}, func(x domain.Rule) *domain.Event {
		return ruleEvent(x, origin, "", fmt.Sprintf("answered the questions on rule %q; %s is reviewing it again", x.Title, domain.ToolName(domain.AccessOf(ctx))))
	})
	if err == nil {
		o.Wake()
	}
	return r, err
}

// AcceptRule applies a rule as written, skipping open questions or a
// failed review. Answers already given still go to tickets with it.
func (o *Orchestrator) AcceptRule(ctx context.Context, id int64, origin domain.Origin) (domain.Rule, error) {
	if err := o.rulesReady(); err != nil {
		return domain.Rule{}, err
	}
	return o.rules.UpdateRule(ctx, id, func(x *domain.Rule) error {
		if x.Status != domain.RuleQuestions && x.Status != domain.RuleFailed && x.Status != domain.RuleSuggested {
			return invalid("only a suggested rule, or one with open questions or a failed review, can be accepted as written")
		}
		x.Questions = x.Answered()
		x.Status, x.Error, x.Clarified, x.Interpretation = domain.RuleReady, "", "", ""
		return nil
	}, func(x domain.Rule) *domain.Event {
		return ruleEvent(x, origin, "", fmt.Sprintf("rule %q accepted as written", x.Title))
	})
}

// dismissRule declines a suggested rule. It is kept, hidden, so agnts does
// not suggest it again.
func (o *Orchestrator) dismissRule(ctx context.Context, id int64, origin domain.Origin) error {
	_, err := o.rules.UpdateRule(ctx, id, func(x *domain.Rule) error {
		x.Status, x.Enabled = domain.RuleDismissed, false
		return nil
	}, func(x domain.Rule) *domain.Event {
		return ruleEvent(x, origin, "", fmt.Sprintf("suggested rule %q dismissed", x.Title))
	})
	return err
}

// ReviewRule queues a rule for another review, keeping its answers.
func (o *Orchestrator) ReviewRule(ctx context.Context, id int64, origin domain.Origin) (domain.Rule, error) {
	if err := o.rulesReady(); err != nil {
		return domain.Rule{}, err
	}
	adopted := false
	r, err := o.rules.UpdateRule(ctx, id, func(x *domain.Rule) error {
		if x.Status == domain.RulePending || x.Status == domain.RuleAnalyzing {
			return invalid("this rule is already being reviewed")
		}
		adopted = x.Status == domain.RuleSuggested
		x.Questions = x.Answered()
		x.Requeue()
		return nil
	}, func(x domain.Rule) *domain.Event {
		if adopted {
			return ruleEvent(x, origin, "", fmt.Sprintf("suggested rule %q adopted; %s is reviewing it", x.Title, domain.ToolName(domain.AccessOf(ctx))))
		}
		return ruleEvent(x, origin, "", fmt.Sprintf("rule %q queued for another review", x.Title))
	})
	if err == nil {
		o.Wake()
	}
	return r, err
}

// DeleteRule removes a rule. Tickets started after this no longer get it.
func (o *Orchestrator) DeleteRule(ctx context.Context, id int64, origin domain.Origin) error {
	if err := o.rulesReady(); err != nil {
		return err
	}
	r, err := o.rules.Rule(ctx, id)
	if err != nil {
		return err
	}
	if r.Status == domain.RuleSuggested {
		return o.dismissRule(ctx, id, origin)
	}
	return o.rules.DeleteRule(ctx, id, *ruleEvent(r, origin, "", fmt.Sprintf("rule %q deleted", r.Title)))
}

// teamRules returns the rules tickets in these repositories follow (none:
// global only).
func (o *Orchestrator) teamRules(ctx context.Context, repoIDs []int64) ([]domain.Rule, error) {
	if o.rules == nil {
		return nil, nil
	}
	rules, err := o.activeRules(ctx, repoIDs)
	if err != nil {
		return nil, fmt.Errorf("load team rules: %w", err)
	}
	out := rules[:0:0]
	for _, r := range rules {
		if r.Kind == domain.KindInstruction && r.Delivery != domain.DeliverSkill {
			out = append(out, r)
		}
	}
	return out, nil
}

// businessNotes returns the business context notes runs in these
// repositories read (none: global ones only).
func (o *Orchestrator) businessNotes(ctx context.Context, repoIDs []int64) ([]domain.Rule, error) {
	if o.rules == nil {
		return nil, nil
	}
	rules, err := o.activeRules(ctx, repoIDs)
	if err != nil {
		return nil, fmt.Errorf("load business context: %w", err)
	}
	var out []domain.Rule
	for _, r := range rules {
		if r.Kind == domain.KindContext && r.Delivery != domain.DeliverSkill {
			out = append(out, r)
		}
	}
	return out, nil
}

// rulesEvent records which rules a ticket was given.
func rulesEvent(key string, run *domain.Run, rules []domain.Rule) domain.Event {
	ids, titles := make([]int64, len(rules)), make([]string, len(rules))
	for i, r := range rules {
		ids[i], titles[i] = r.ID, r.Title
	}
	return domain.Event{
		TicketKey: key, RunID: &run.ID, Step: string(run.Stage), Type: domain.EventRule,
		Message: fmt.Sprintf("following %d team %s: %s", len(rules), plural(len(rules), "rule", "rules"), strings.Join(titles, ", ")),
		Data:    map[string]any{"ids": ids, "titles": titles},
	}
}

// reviewRule has Claude check a claimed rule for ambiguity and conflicts,
// then stores the outcome: questions for the author, or a clear rule.
func (o *Orchestrator) reviewRule(ctx context.Context, r domain.Rule) {
	log := o.log.With("rule", r.ID)
	log.Info("rule review started")
	review, err := o.runRuleReview(ctx, r)
	if ctx.Err() != nil {
		// Shutting down: RecoverRules requeues it on the next start.
		log.Info("rule review interrupted")
		return
	}
	var stop *stopError
	limited := errors.As(err, &stop)
	var msg string
	level := domain.LevelInfo
	_, uerr := o.rules.UpdateRule(ctx, r.ID, func(x *domain.Rule) error {
		if x.Revision != r.Revision || x.Status != domain.RuleAnalyzing {
			return errStale
		}
		switch {
		case limited:
			// Claimed again once plan usage allows.
			x.Status = domain.RulePending
		case err != nil:
			x.Status, x.Error = domain.RuleFailed, err.Error()
			level, msg = domain.LevelWarn, fmt.Sprintf("could not review rule %q: %v", x.Title, err)
		default:
			msg = applyReview(x, review)
		}
		return nil
	}, func(x domain.Rule) *domain.Event {
		if msg == "" {
			return nil
		}
		return ruleEvent(x, domain.OriginSystem, level, msg)
	})
	switch {
	case errors.Is(uerr, errStale), errors.Is(uerr, domain.ErrNotFound):
		log.Info("rule changed or was deleted during its review; result dropped")
	case uerr != nil:
		log.Error("save rule review", "err", uerr)
	case err != nil:
		log.Warn("rule review failed", "err", err)
	default:
		log.Info("rule review finished")
	}
}

// applyReview stores a finished review and returns its log line.
func applyReview(x *domain.Rule, rv RuleReview) string {
	now := time.Now()
	x.AnalyzedAt, x.Error = &now, ""
	x.Interpretation = strings.TrimSpace(rv.Interpretation)
	var qs []domain.RuleQuestion
	if x.Rounds < domain.RuleMaxRounds {
		for _, q := range rv.Questions {
			if text := strings.TrimSpace(q.Text); text != "" && len(qs) < ruleMaxQuestions {
				qs = append(qs, domain.RuleQuestion{Text: text, Options: cleanOptions(q.Options), Round: x.Rounds + 1})
			}
		}
	}
	if len(qs) > 0 {
		x.Rounds++
		x.Questions = append(x.Answered(), qs...)
		x.Status, x.Clarified = domain.RuleQuestions, ""
		return fmt.Sprintf("rule %q: %d %s before it applies", x.Title, len(qs), plural(len(qs), "question", "questions"))
	}
	x.Status, x.Clarified = domain.RuleReady, strings.TrimSpace(rv.Clarified)
	if d := strings.TrimSpace(rv.SkillDescription); d != "" {
		x.SkillDescription = truncate(d, 500)
	}
	return fmt.Sprintf("rule %q is clear and applies to new tickets", x.Title)
}

func cleanOptions(in []string) []string {
	out := []string{}
	for _, o := range in {
		if o = strings.TrimSpace(o); o != "" && len(out) < 4 {
			out = append(out, o)
		}
	}
	return out
}

func (o *Orchestrator) runRuleReview(ctx context.Context, r domain.Rule) (RuleReview, error) {
	var rv RuleReview
	s, err := o.settings.Get(ctx)
	if err != nil {
		return rv, err
	}
	d := promptData{Rule: r, Answered: r.Answered(), NoQuestions: r.Rounds >= domain.RuleMaxRounds}
	var tree io.Reader
	if r.RepoID != nil {
		repo, err := o.store.RepositoryByID(ctx, *r.RepoID)
		if err != nil {
			return rv, err
		}
		d.RuleRepo = repo.Name
		if err := o.git.Prepare(ctx, repo, repo.DefaultBranch); err != nil {
			return rv, fmt.Errorf("prepare repository: %w", err)
		}
		rc, err := o.git.Archive(ctx, repo, repo.DefaultBranch)
		if err != nil {
			return rv, fmt.Errorf("archive repository: %w", err)
		}
		defer func() { _ = rc.Close() }()
		tree = rc
	} else {
		var empty bytes.Buffer
		_ = tar.NewWriter(&empty).Close()
		tree = &empty
	}
	others, err := o.rules.ActiveRules(ctx, r.RepoID)
	if err != nil {
		return rv, err
	}
	for _, x := range others {
		if x.ID != r.ID {
			d.Rules = append(d.Rules, x)
		}
	}
	prompt, err := render("rule", d)
	if err != nil {
		return rv, err
	}

	ws, err := o.runner.Open(ctx, WorkspaceSpec{TicketKey: fmt.Sprintf("rule-%d", r.ID), Image: o.cfg.Image, Repo: tree})
	if err != nil {
		return rv, fmt.Errorf("start container: %w", err)
	}
	defer func() {
		if err := ws.Close(context.WithoutCancel(ctx)); err != nil {
			o.log.Warn("remove container", "rule", r.ID, "err", err)
		}
	}()
	res, err := o.callClaude(ctx, ws, transcriptMeta{Purpose: domain.PurposeRules, WorkspaceID: r.WorkspaceID,
		Subject: fmt.Sprintf("rule %d: %s", r.ID, truncate(r.Title, 80))}, ai.Request{
		Prompt:   prompt,
		Model:    s.Models.Analyze,
		MaxTurns: min(s.MaxTurns, ruleMaxTurns),
		Timeout:  time.Duration(min(s.TimeoutMin, ruleTimeoutMin)) * time.Minute,
		Settings: permissionSettings(s, false),
	}, nil)
	if err != nil {
		return rv, err
	}
	if res.RateLimited {
		return rv, &stopError{"rate limited"}
	}
	if res.IsError {
		if res.Subtype == "error_max_turns" {
			return rv, fmt.Errorf("stopped at the turn limit (%d); shorten the rule or split it", min(s.MaxTurns, ruleMaxTurns))
		}
		return rv, fmt.Errorf("%s ended with %s: %s", domain.AgentName(res.Model), res.Subtype, truncate(res.Text, 500))
	}
	raw, err := ws.ReadFile(ctx, RulePath)
	if err != nil {
		return rv, fmt.Errorf("%s did not write %s: %w", domain.AgentName(res.Model), RulePath, err)
	}
	return parseRuleReview(raw)
}

func parseRuleReview(b []byte) (RuleReview, error) {
	var rv RuleReview
	if err := json.Unmarshal(b, &rv); err != nil {
		return rv, fmt.Errorf("rule.json is not valid JSON: %w", err)
	}
	if strings.TrimSpace(rv.Interpretation) == "" {
		return rv, errors.New("rule.json has no interpretation")
	}
	return rv, nil
}
