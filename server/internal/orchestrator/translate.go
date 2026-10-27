package orchestrator

import (
	"archive/tar"
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"strings"
	"time"

	"agnts/internal/domain"
)

// Files of a translation run.
const (
	SourcePath      = "/agnts/out/source.json"
	TranslationPath = "/agnts/out/translation.json"
)

const (
	translateMaxTurns   = 20
	translateTimeoutMin = 10
)

// ErrPlanLimit means Claude cannot be asked now: the plan limit is reached.
var ErrPlanLimit = errors.New("the Claude plan limit is reached; try again after it resets")

// TranslatedText is a text of the ticket page and its translation.
type TranslatedText struct {
	Source string
	Text   string
}

type translationFile struct {
	Texts []struct {
		ID   int    `json:"id"`
		Text string `json:"text"`
	} `json:"texts"`
}

// Translate returns the texts of a ticket's page translated into lang.
// Texts already translated come from the store; the rest are translated by
// Claude in one run and stored, so each text is translated once.
func (o *Orchestrator) Translate(ctx context.Context, key, lang string) ([]TranslatedText, error) {
	if _, ok := domain.Languages[lang]; !ok {
		return nil, invalid("unknown language %q", lang)
	}
	v, err := o.View(ctx, key)
	if err != nil {
		return nil, err
	}
	texts := ticketTexts(v)
	got, err := o.translateTexts(ctx, translateSubject{ticket: key, name: key}, lang, texts)
	if err != nil {
		return nil, err
	}
	out := make([]TranslatedText, 0, len(texts))
	for _, s := range texts {
		if t, ok := got[s]; ok {
			out = append(out, TranslatedText{Source: s, Text: t})
		}
	}
	return out, nil
}

// TranslateTexts returns texts that are not a ticket's (a document's)
// translated into lang, by source text, the same way: the store answers
// what is translated already, Claude the rest. subject names what they
// are of, as "document-12"; one run per subject and language at a time.
func (o *Orchestrator) TranslateTexts(ctx context.Context, subject, lang string, texts []string) (map[string]string, error) {
	if _, ok := domain.Languages[lang]; !ok {
		return nil, invalid("unknown language %q", lang)
	}
	return o.translateTexts(ctx, translateSubject{name: subject}, lang, texts)
}

// translateSubject is what texts are of: a ticket (its key in both), or
// another subject by name.
type translateSubject struct{ ticket, name string }

func (o *Orchestrator) translateTexts(ctx context.Context, sub translateSubject, lang string, texts []string) (map[string]string, error) {
	if o.trans == nil {
		return nil, invalid("translation is not available")
	}
	got, err := o.translated(ctx, lang, texts)
	if err != nil {
		return nil, err
	}
	var missing []string
	for _, s := range texts {
		if _, ok := got[s]; !ok {
			missing = append(missing, s)
		}
	}
	if len(missing) == 0 {
		return got, nil
	}
	// One run per subject and language at a time: a second request waits
	// for the first. The run outlives a client that gives up, so its work
	// is stored all the same.
	_, err, _ = o.translating.Do(runKey(domain.WorkspaceOf(ctx), sub.name)+"\x00"+lang, func() (any, error) {
		return nil, o.translateMissing(context.WithoutCancel(ctx), sub, lang, missing)
	})
	if err != nil {
		return nil, err
	}
	return o.translated(ctx, lang, texts)
}

// translated returns the stored translations of texts, by source text.
func (o *Orchestrator) translated(ctx context.Context, lang string, texts []string) (map[string]string, error) {
	hashes := make([]string, len(texts))
	for i, s := range texts {
		hashes[i] = domain.TextHash(s)
	}
	byHash, err := o.trans.Translated(ctx, lang, hashes)
	if err != nil {
		return nil, err
	}
	out := make(map[string]string, len(byHash))
	for i, s := range texts {
		if t, ok := byHash[hashes[i]]; ok {
			out[s] = t
		}
	}
	return out, nil
}

// ticketTexts lists the distinct texts a person reads on a ticket's page:
// the ticket itself and everything agnts wrote about it.
func ticketTexts(v TicketView) []string {
	var out []string
	seen := map[string]bool{}
	add := func(ss ...string) {
		for _, s := range ss {
			if strings.TrimSpace(s) != "" && !seen[s] {
				seen[s] = true
				out = append(out, s)
			}
		}
	}
	add(v.Ticket.Title, v.Ticket.Description)
	if a := v.Analysis; a != nil {
		add(a.Summary)
		add(a.Plan...)
		for _, x := range a.Approaches {
			add(x.Title, x.Sketch, x.Fit, x.Why)
			add(x.Pros...)
			add(x.Cons...)
		}
		add(a.OutOfScope...)
		for _, p := range a.Patterns {
			add(p.Layer, p.Why, p.Place)
		}
		for _, r := range a.Reuse {
			add(r.For)
		}
		for _, x := range a.TestPlan {
			add(x.What)
		}
		add(a.EdgeCases...)
		if a.Repro != nil {
			add(a.Repro.Why)
		}
		if n := a.ShipPlan(); n != nil {
			add(n.Migrations, n.Compatibility, n.Rollout, n.Rollback)
		}
	}
	for _, q := range v.Questions {
		add(q.Text)
		add(q.Options...)
	}
	if v.Result != nil {
		var sum Summary
		_ = json.Unmarshal(v.Result.Summary, &sum)
		add(sum.Summary, v.Result.Report)
		add(sum.Notes...)
		add(sum.Deviations...)
	}
	if v.Review != nil {
		add(v.Review.Summary)
		add(v.Review.Strengths...)
		for _, f := range v.Review.Findings {
			add(f.Title, f.Detail, f.Suggestion)
		}
	}
	for _, s := range v.FollowUps.Suggestions {
		add(s.Title, s.Description, s.Serves)
	}
	return out
}

// translateBatch bounds the text one Claude call translates; more is
// translated in several calls, one after another.
const translateBatch = 40 << 10

// translateBatches cuts texts into runs of at most translateBatch bytes
// (a longer text goes alone).
func translateBatches(texts []string) [][]string {
	var out [][]string
	size := 0
	for _, t := range texts {
		if n := len(out); n == 0 || size+len(t) > translateBatch && len(out[n-1]) > 0 {
			out, size = append(out, nil), 0
		}
		out[len(out)-1] = append(out[len(out)-1], t)
		size += len(t)
	}
	return out
}

// translateMissing has Claude translate texts into lang in an empty
// workspace, in batches, and stores the translations of each batch as it
// is done.
func (o *Orchestrator) translateMissing(ctx context.Context, sub translateSubject, lang string, texts []string) error {
	s, err := o.settings.Get(ctx)
	if err != nil {
		return err
	}
	if paused, _ := o.usage.Paused(ctx, s); paused {
		return ErrPlanLimit
	}
	prompt, err := render("translate", promptData{Language: domain.Languages[lang]})
	if err != nil {
		return err
	}

	var empty bytes.Buffer
	_ = tar.NewWriter(&empty).Close()
	ws, err := o.runner.Open(ctx, WorkspaceSpec{TicketKey: sub.name + "-translate", Image: o.cfg.Image, Repo: &empty})
	if err != nil {
		return fmt.Errorf("start container: %w", err)
	}
	defer func() {
		if err := ws.Close(context.WithoutCancel(ctx)); err != nil {
			o.log.Warn("remove container", "subject", sub.name, "err", err)
		}
	}()
	done := 0
	for _, batch := range translateBatches(texts) {
		n, err := o.translateBatch(ctx, ws, s, sub, lang, prompt, batch)
		if err != nil {
			return err
		}
		done += n
	}
	if done == 0 {
		return errors.New("claude translated nothing")
	}
	o.log.Info("texts translated", "subject", sub.name, "lang", lang, "texts", done, "of", len(texts))
	return nil
}

// translateBatch has Claude translate one batch in ws and stores it,
// returning how many texts it translated.
func (o *Orchestrator) translateBatch(ctx context.Context, ws Workspace, s domain.Settings, sub translateSubject, lang, prompt string, texts []string) (int, error) {
	type item struct {
		ID   int    `json:"id"`
		Text string `json:"text"`
	}
	in := struct {
		Texts []item `json:"texts"`
	}{Texts: make([]item, len(texts))}
	for i, t := range texts {
		in.Texts[i] = item{ID: i, Text: t}
	}
	src, err := json.Marshal(in)
	if err != nil {
		return 0, err
	}
	if err := ws.WriteFile(ctx, SourcePath, src); err != nil {
		return 0, fmt.Errorf("write texts: %w", err)
	}
	// An earlier batch's answer must not pass for this one's.
	if err := ws.WriteFile(ctx, TranslationPath, nil); err != nil {
		return 0, fmt.Errorf("clear translation: %w", err)
	}
	res, err := o.callClaude(ctx, ws, transcriptMeta{Purpose: domain.PurposeTranslate, TicketKey: sub.ticket, Subject: subjectOf(sub, lang)}, ClaudeRequest{
		Prompt:   prompt,
		Model:    s.Models.Helper,
		MaxTurns: min(s.MaxTurns, translateMaxTurns),
		Timeout:  time.Duration(min(s.TimeoutMin, translateTimeoutMin)) * time.Minute,
		Settings: permissionSettings(s, true),
	}, func(e ClaudeEvent) {
		if e.Kind == ClaudeRateLimit {
			o.usage.Record(ctx, e.Data)
		}
	})
	if err != nil {
		return 0, err
	}
	if res.RateLimited {
		o.usage.RecordLimited(ctx)
		return 0, ErrPlanLimit
	}
	if res.IsError {
		return 0, fmt.Errorf("claude ended with %s: %s", res.Subtype, truncate(res.Text, 500))
	}
	raw, err := ws.ReadFile(ctx, TranslationPath)
	if err == nil && len(bytes.TrimSpace(raw)) == 0 {
		err = errors.New("empty")
	}
	if err != nil {
		return 0, fmt.Errorf("claude did not write %s: %w", TranslationPath, err)
	}
	var tf translationFile
	if err := json.Unmarshal(raw, &tf); err != nil {
		return 0, fmt.Errorf("translation.json is not valid JSON: %w", err)
	}
	byHash := map[string]string{}
	for _, x := range tf.Texts {
		if x.ID >= 0 && x.ID < len(texts) && strings.TrimSpace(x.Text) != "" {
			byHash[domain.TextHash(texts[x.ID])] = x.Text
		}
	}
	if len(byHash) == 0 {
		return 0, nil
	}
	return len(byHash), o.trans.SaveTranslations(ctx, lang, byHash)
}

// subjectOf is a translation call's subject in the run history: the
// language for a ticket (its key is on the call), else what it is of too.
func subjectOf(sub translateSubject, lang string) string {
	if sub.ticket != "" {
		return lang
	}
	return sub.name + " " + lang
}
