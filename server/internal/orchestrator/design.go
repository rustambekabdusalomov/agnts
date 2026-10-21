package orchestrator

import (
	"slices"
	"strings"

	"agnts/internal/domain"
)

// Limits of the design part of an analysis.
const (
	maxApproaches = 4
	maxOutOfScope = 10
	maxPatterns   = 20
	maxReuse      = 15
	maxTestPlan   = 15
	maxEdgeCases  = 12
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
	a.Patterns, a.Reuse = cleanPatterns(a.Patterns), cleanReuse(a.Reuse)
	a.EdgeCases = cleanList(a.EdgeCases, maxEdgeCases)
	var tp []TestPlanItem
	for _, x := range a.TestPlan {
		x.File, x.What = domain.CleanPath(x.File), strings.TrimSpace(x.What)
		if x.What != "" && len(tp) < maxTestPlan {
			tp = append(tp, x)
		}
	}
	a.TestPlan = tp
	if r := a.Repro; r != nil {
		r.Command, r.Why = strings.TrimSpace(r.Command), strings.TrimSpace(r.Why)
		r.Output = clipTail(strings.TrimSpace(r.Output), 3000)
		if r.Command == "" && r.Why == "" {
			a.Repro = nil
		}
	}
	if n := a.Ship; n != nil {
		n.Migrations, n.Compatibility = strings.TrimSpace(n.Migrations), strings.TrimSpace(n.Compatibility)
		n.Rollout, n.Rollback = strings.TrimSpace(n.Rollout), strings.TrimSpace(n.Rollback)
		if a.ShipPlan() == nil {
			a.Ship = nil
		}
	}
}

// cleanPatterns normalizes the paths and kinds, and drops patterns without
// a file, without a file to follow (unless new), and duplicates of a file.
func cleanPatterns(in []Pattern) []Pattern {
	var out []Pattern
	seen := map[string]bool{}
	for _, x := range in {
		x.File, x.Like, x.Layer = domain.CleanPath(x.File), domain.CleanPath(x.Like), strings.TrimSpace(x.Layer)
		x.Why, x.Place = strings.TrimSpace(x.Why), strings.TrimSpace(x.Place)
		switch x.Kind = strings.ToLower(strings.TrimSpace(x.Kind)); x.Kind {
		case PatternAdapt, PatternNew:
		default:
			x.Kind = PatternCopy
		}
		x.Precedent = x.Precedent && x.Kind == PatternNew
		if x.File == "" || (x.Like == "" && x.Kind != PatternNew) || seen[x.File] || len(out) == maxPatterns {
			continue
		}
		seen[x.File] = true
		out = append(out, x)
	}
	return out
}

// cleanReuse drops helpers without a name or a file.
func cleanReuse(in []Reuse) []Reuse {
	var out []Reuse
	for _, x := range in {
		x.Name, x.Where, x.For = strings.TrimSpace(x.Name), domain.CleanPath(x.Where), strings.TrimSpace(x.For)
		if x.Name == "" || x.Where == "" || len(out) == maxReuse {
			continue
		}
		out = append(out, x)
	}
	return out
}

// clipTail keeps the last n bytes of s.
func clipTail(s string, n int) string {
	if len(s) <= n {
		return s
	}
	return "…" + s[len(s)-n:]
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

// precedentQuestions ask the author about each new pattern other code
// will copy, unless the analysis already asked about its file.
func precedentQuestions(t domain.Ticket, a Analysis, asked []domain.Question) []domain.Question {
	if t.Kind.Report() {
		return nil
	}
	var out []domain.Question
	for _, p := range a.Patterns {
		if !p.Precedent || slices.ContainsFunc(asked, func(q domain.Question) bool { return strings.Contains(q.Text, p.File) }) {
			continue
		}
		text := "agnts will add " + p.File + " as something new the code base will copy"
		if p.Place != "" {
			text += ", in " + p.Place
		}
		if p.Why != "" {
			text += " (" + strings.TrimSuffix(p.Why, ".") + ")"
		}
		out = append(out, domain.Question{TicketID: t.ID, Text: text + ". Should it?",
			Options: []string{"Yes, as planned", "No: follow existing code instead (say which in a note)"}})
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
