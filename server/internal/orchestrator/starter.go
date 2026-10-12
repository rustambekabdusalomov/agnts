package orchestrator

import (
	"context"
	"fmt"
	"strings"

	"agnts/internal/domain"
	"agnts/internal/rulepacks"
)

// StarterOffer is a starter pack that fits a repository.
type StarterOffer struct {
	Pack  string // id: go, typescript, ...
	Name  string
	Rules int
	// Offered: its rules were already added to the repository's suggestions
	// (adopted, dismissed or still open).
	Offered bool
}

// StarterPacks lists the starter packs that fit a repository's
// toolchains.
func (o *Orchestrator) StarterPacks(ctx context.Context, repoID int64) ([]StarterOffer, error) {
	if err := o.rulesReady(); err != nil {
		return nil, err
	}
	repo, err := o.store.RepositoryByID(ctx, repoID)
	if err != nil {
		return nil, err
	}
	known, err := o.rules.KnownRules(ctx, &repoID)
	if err != nil {
		return nil, err
	}
	var out []StarterOffer
	for _, id := range rulepacks.For(repo.Toolchains) {
		p, err := rulepacks.Get(id)
		if err != nil {
			continue
		}
		offer := StarterOffer{Pack: id, Name: p.Name, Rules: len(p.Rules)}
		for _, r := range known {
			if r.Source == rulepacks.Source(id) && r.RepoID != nil && *r.RepoID == repoID {
				offer.Offered = true
				break
			}
		}
		out = append(out, offer)
	}
	return out, nil
}

// OfferStarterRules adds a starter pack's rules to a repository as
// suggestions: they apply only once someone adopts them, through the
// usual rule review. Rules whose title the repository already has are
// skipped. It returns the suggestions added.
func (o *Orchestrator) OfferStarterRules(ctx context.Context, repoID int64, pack string, origin domain.Origin) ([]domain.Rule, error) {
	if err := o.rulesReady(); err != nil {
		return nil, err
	}
	p, err := rulepacks.Get(pack)
	if err != nil {
		return nil, invalid("%s", err)
	}
	repo, err := o.store.RepositoryByID(ctx, repoID)
	if err != nil {
		return nil, err
	}
	known, err := o.rules.KnownRules(ctx, &repoID)
	if err != nil {
		return nil, err
	}
	have := map[string]bool{}
	for _, r := range known {
		have[strings.ToLower(r.Title)] = true
	}
	var out []domain.Rule
	for _, sr := range p.Rules {
		if have[strings.ToLower(sr.Title)] {
			continue
		}
		r := domain.Rule{Title: sr.Title, Body: sr.Body, RepoID: &repoID, Enabled: true, Status: domain.RuleSuggested,
			Kind: domain.KindInstruction, Enforce: sr.Enforce, Source: rulepacks.Source(pack),
			Reason: fmt.Sprintf("A starter rule for %s code, from agnts's %s pack. Adopt it if your team works this way.", p.Name, p.Name)}
		if err := r.Validate(); err != nil {
			continue
		}
		saved, err := o.rules.CreateRule(ctx, r, func(x domain.Rule) domain.Event {
			return *ruleEvent(x, origin, "", fmt.Sprintf("starter rule %q suggested for %s", x.Title, repo.Name))
		})
		if err != nil {
			return out, err
		}
		out = append(out, saved)
	}
	return out, nil
}
