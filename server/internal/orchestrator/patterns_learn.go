package orchestrator

import (
	"context"
	"fmt"
	"slices"
	"strings"
	"time"

	"agnts/internal/domain"
)

// suggestMergedPatterns turns the new patterns a merged ticket added into
// suggested rules: the first of a kind is the example the next one copies.
// Like every suggestion, it reaches runs only once a person adopts it.
func (o *Orchestrator) suggestMergedPatterns(ctx context.Context, t domain.Ticket, repoID int64, merged []domain.FileChange) {
	if o.rules == nil || t.ReplayOf != "" {
		return
	}
	a := o.latestAnalysis(ctx, t)
	if a == nil || !a.HasNewPattern() {
		return
	}
	known, err := o.rules.KnownRules(ctx, &repoID)
	if err != nil {
		o.log.Warn("suggest merged patterns", "ticket", t.Key, "err", err)
		return
	}
	shipped := func(p string) bool {
		return slices.ContainsFunc(merged, func(f domain.FileChange) bool { return f.Path == p || f.Where() == p })
	}
	now := time.Now()
	for _, p := range a.NewPatterns() {
		if !shipped(p.File) {
			continue // it did not merge as planned
		}
		what := cmpOr(p.Layer, p.Place, "this kind of code")
		r := domain.Rule{
			Title: truncate("Copy "+p.File+" for new "+what, 120),
			Body: fmt.Sprintf("%s is this repository's example of %s, merged in %s. New code of this kind follows it: where it lives, how it is wired, how it handles errors and logs, and how it is tested.%s",
				p.File, what, t.Key, placeNote(p.Place)),
			Enabled: true, Status: domain.RuleSuggested, Kind: domain.KindInstruction, Delivery: domain.DeliverSkill,
			RepoID: &repoID, SourceTicket: t.Key, Source: "pattern", Confidence: domain.ConfidenceFromFeedback, Evidence: 1, LastSeen: &now,
			Reason: truncate("The first "+what+" in the code base, merged in "+t.Key+": "+strings.TrimSpace(p.Why), 1000),
		}
		if r.Validate() != nil || sameTitle(known, r) != nil {
			continue
		}
		created, err := o.rules.CreateRule(ctx, r, func(x domain.Rule) domain.Event {
			return *ruleEvent(x, domain.OriginSystem, "", fmt.Sprintf("agnts suggests %q: %s added a new pattern that later work can copy", x.Title, t.Key))
		})
		if err != nil {
			o.log.Warn("suggest merged pattern", "ticket", t.Key, "err", err)
			continue
		}
		known = append(known, created)
	}
}

func placeNote(place string) string {
	if place = strings.TrimSpace(place); place == "" {
		return ""
	}
	return " It lives in " + strings.TrimSuffix(place, ".") + "."
}

func cmpOr(vs ...string) string {
	for _, v := range vs {
		if v = strings.TrimSpace(v); v != "" {
			return v
		}
	}
	return ""
}
