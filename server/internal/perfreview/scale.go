// Package perfreview scores delivered tickets for the owner's
// performance reviews: which commits a delivery counts, the facts of its
// diff, the score's bounds, who gets the points and what reverts and
// regressions take back. See plans/Performance review plan.md.
//
// Everything here is pure: the orchestrator reads the commits and diffs
// and asks the model; this package decides.
package perfreview

import "slices"

// Scale is the points a score may take.
var Scale = []int{1, 2, 3, 5, 8, 13}

// step is a score's index on the scale (the nearest step at or below it).
func step(points int) int {
	i := 0
	for j, p := range Scale {
		if points >= p {
			i = j
		}
	}
	return i
}

// up moves points n steps up the scale, capped at its top.
func up(points, n int) int {
	return Scale[min(step(points)+n, len(Scale)-1)]
}

// OnScale reports whether points is one of the scale's steps.
func OnScale(points int) bool { return slices.Contains(Scale, points) }

// FactsVersion names the facts-only formula and the clamp; it is part
// of a prompt version.
const FactsVersion = "f1"

// FactsScore is the deterministic score of a diff's facts: by changed
// lines, one step up for a risky area, one for three or more
// repositories, capped at 13. It is the score when the model is skipped
// and the base of the model's upper bound.
func FactsScore(f Facts) int {
	p := 8
	switch n := f.ChangedLines; {
	case n <= 50:
		p = 1
	case n <= 200:
		p = 2
	case n <= 500:
		p = 3
	case n <= 1500:
		p = 5
	}
	if f.Risky() {
		p = up(p, 1)
	}
	if f.Repositories >= 3 {
		p = up(p, 1)
	}
	return p
}

// Steps the model may go above the facts score.
const (
	clampSteps      = 1
	clampStepsRisky = 3
)

// Ceiling is the highest score the model may give a diff with these
// facts: one step above the facts score, three with a risky area.
func Ceiling(f Facts) int {
	n := clampSteps
	if f.Risky() {
		n = clampStepsRisky
	}
	return up(FactsScore(f), n)
}

// Clamp bounds the model's answer from above only: it may go as low as
// 1, never above Ceiling. clamped says the model wanted more. An answer
// off the scale is taken down to the step below it.
func Clamp(model int, f Facts) (points int, clamped bool) {
	p := Scale[step(max(model, 1))]
	if c := Ceiling(f); p > c {
		return c, true
	}
	return p, false
}
