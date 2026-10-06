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
	if o.trans == nil {
		return nil, invalid("translation is not available")
	}
	v, err := o.View(ctx, key)
	if err != nil {
		return nil, err
	}
	texts := ticketTexts(v)
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
	if len(missing) > 0 {
		// One run per ticket and language at a time: a second request waits
		// for the first. The run outlives a client that gives up, so its
		// work is stored all the same.
		_, err, _ := o.translating.Do(key+"\x00"+lang, func() (any, error) {
			return nil, o.translateMissing(context.WithoutCancel(ctx), key, lang, missing)
		})
		if err != nil {
			return nil, err
		}
		if got, err = o.translated(ctx, lang, texts); err != nil {
			return nil, err
		}
	}
	out := make([]TranslatedText, 0, len(texts))
	for _, s := range texts {
		if t, ok := got[s]; ok {
			out = append(out, TranslatedText{Source: s, Text: t})
		}
	}
	return out, nil
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
	if v.Analysis != nil {
		add(v.Analysis.Summary)
		add(v.Analysis.Plan...)
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

// translateMissing has Claude translate texts into lang in an empty
// workspace and stores the translations.
func (o *Orchestrator) translateMissing(ctx context.Context, key, lang string, texts []string) error {
	s, err := o.settings.Get(ctx)
	if err != nil {
		return err
	}
	if paused, _ := o.usage.Paused(ctx, s); paused {
		return ErrPlanLimit
	}
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
		return err
	}
	prompt, err := render("translate", promptData{Language: domain.Languages[lang]})
	if err != nil {
		return err
	}

	var empty bytes.Buffer
	_ = tar.NewWriter(&empty).Close()
	ws, err := o.runner.Open(ctx, WorkspaceSpec{TicketKey: key + "-translate", Image: o.cfg.Image, Repo: &empty})
	if err != nil {
		return fmt.Errorf("start container: %w", err)
	}
	defer func() {
		if err := ws.Close(context.WithoutCancel(ctx)); err != nil {
			o.log.Warn("remove container", "ticket", key, "err", err)
		}
	}()
	if err := ws.WriteFile(ctx, SourcePath, src); err != nil {
		return fmt.Errorf("write texts: %w", err)
	}
	res, err := ws.Claude(ctx, ClaudeRequest{
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
		return err
	}
	if res.RateLimited {
		o.usage.RecordLimited(ctx)
		return ErrPlanLimit
	}
	if res.IsError {
		return fmt.Errorf("claude ended with %s: %s", res.Subtype, truncate(res.Text, 500))
	}
	raw, err := ws.ReadFile(ctx, TranslationPath)
	if err != nil {
		return fmt.Errorf("claude did not write %s: %w", TranslationPath, err)
	}
	var tf translationFile
	if err := json.Unmarshal(raw, &tf); err != nil {
		return fmt.Errorf("translation.json is not valid JSON: %w", err)
	}
	byHash := map[string]string{}
	for _, x := range tf.Texts {
		if x.ID >= 0 && x.ID < len(texts) && strings.TrimSpace(x.Text) != "" {
			byHash[domain.TextHash(texts[x.ID])] = x.Text
		}
	}
	if len(byHash) == 0 {
		return errors.New("claude translated nothing")
	}
	o.log.Info("ticket translated", "ticket", key, "lang", lang, "texts", len(byHash), "of", len(texts))
	return o.trans.SaveTranslations(ctx, lang, byHash)
}
