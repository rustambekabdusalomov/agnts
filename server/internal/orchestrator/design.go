package orchestrator

import (
	"strings"

	"agnts/internal/domain"
)

// Limits of the design part of an analysis.
const (
	maxApproaches = 4
	maxOutOfScope = 10
)

// normalizeDesign cleans the approaches, scope and ship notes Claude wrote:
// it trims every text, drops approaches without a title, keeps exactly one
// chosen (the first marked, else the first) and caps the lists.
func (a *Analysis) normalizeDesign() {
	var aps []Approach
	chosen := false
	for _, x := range a.Approaches {
		x.Title, x.Sketch = strings.TrimSpace(x.Title), strings.TrimSpace(x.Sketch)
		x.Fit, x.Why = strings.TrimSpace(x.Fit), strings.TrimSpace(x.Why)
		x.Pros, x.Cons = cleanList(x.Pros, 6), cleanList(x.Cons, 6)
		if x.Title == "" {
			continue
		}
		x.Chosen = x.Chosen && !chosen
		chosen = chosen || x.Chosen
		if aps = append(aps, x); len(aps) == maxApproaches {
			break
		}
	}
	if !chosen && len(aps) > 0 {
		aps[0].Chosen = true
	}
	a.Approaches = aps
	a.OutOfScope = cleanList(a.OutOfScope, maxOutOfScope)
	if n := a.Ship; n != nil {
		n.Migrations, n.Compatibility = strings.TrimSpace(n.Migrations), strings.TrimSpace(n.Compatibility)
		n.Rollout, n.Rollback = strings.TrimSpace(n.Rollout), strings.TrimSpace(n.Rollback)
		if a.ShipPlan() == nil {
			a.Ship = nil
		}
	}
}

func cleanList(in []string, max int) []string {
	var out []string
	for _, s := range in {
		if s = strings.TrimSpace(s); s != "" && len(out) < max {
			out = append(out, s)
		}
	}
	return out
}

// approachQuestion is the question that lets the author pick the approach
// of complex code work with real alternatives, unless the analysis already
// asked it. The chosen approach is the first option.
func approachQuestion(t domain.Ticket, a Analysis, asked []domain.Question) (domain.Question, bool) {
	if t.Kind.Report() || a.Complexity != ComplexityComplex || len(a.Approaches) < 2 {
		return domain.Question{}, false
	}
	titles := map[string]bool{}
	for _, x := range a.Approaches {
		titles[strings.ToLower(x.Title)] = true
	}
	for _, q := range asked {
		hits := 0
		for _, o := range q.Options {
			if titles[strings.ToLower(strings.TrimSpace(o))] {
				hits++
			}
		}
		if hits >= 2 {
			return domain.Question{}, false
		}
	}
	opts := []string{a.Chosen().Title}
	for _, x := range a.Alternatives() {
		opts = append(opts, x.Title)
	}
	return domain.Question{TicketID: t.ID, Text: "Which approach should agnts take? The first one is its recommendation.", Options: opts}, true
}
