package orchestrator

import (
	"slices"
	"time"

	"agnts/internal/domain"
)

// EvalTicket is one coded ticket, as the relations eval replays it.
type EvalTicket struct {
	Key    string
	RepoID int64
	// Predicted are the files the newest analysis expected to change.
	Predicted []string
	// FirstFiles is the first change (what the analysis predicted);
	// Files is the newest (what the pull request merges).
	FirstFiles []domain.FileChange
	Files      []domain.FileChange
	CodedAt    time.Time  // when the first change was made
	EndedAt    *time.Time // merged, or rejected; nil while it is open
}

// EvalReport scores how well the queue's predictions matched what really
// happened. Pairs are the tickets of one repository whose changes were
// open at the same time; a collision is a pair whose final diffs touch the
// same lines; a prediction is any relation agnts, a rule, Jira or a person
// set on the pair before the diffs proved anything.
type EvalReport struct {
	Footprints         int     // tickets with a predicted footprint and a change
	Precision, Recall  float64 // footprint averages
	Pairs              int
	TruePositive       int // predicted and collided
	FalsePositive      int // predicted, no collision
	FalseNegative      int // collided, not predicted
	Missed             []EvalPair
	Accepted, Rejected int // proposals people accepted or dismissed
	Pending            int // proposals waiting
}

// EvalPair is a collision nobody predicted.
type EvalPair struct {
	A, B  string
	Files []string
}

// Evaluate replays coded tickets against the relations stored for them.
func Evaluate(ts []EvalTicket, rs []domain.Relation, now time.Time) EvalReport {
	var rep EvalReport
	var psum, rsum float64
	for _, t := range ts {
		if len(t.Predicted) == 0 || len(t.FirstFiles) == 0 {
			continue
		}
		hit := 0
		for _, f := range t.FirstFiles {
			if slices.Contains(t.Predicted, f.Path) {
				hit++
			}
		}
		rep.Footprints++
		psum += float64(hit) / float64(len(t.Predicted))
		rsum += float64(hit) / float64(len(t.FirstFiles))
	}
	if rep.Footprints > 0 {
		rep.Precision, rep.Recall = psum/float64(rep.Footprints), rsum/float64(rep.Footprints)
	}

	predicted := map[[2]string]bool{}
	for _, r := range rs {
		if r.Source != domain.RelFromGit {
			predicted[pairKey(r.TicketKey, r.OtherKey)] = true
		}
		switch {
		case r.Status == domain.RelProposed:
			rep.Pending++
		case r.Source != domain.RelFromAgnts || r.DecidedAt == nil:
		case r.Status == domain.RelActive:
			rep.Accepted++
		case r.Status == domain.RelDismissed:
			rep.Rejected++
		}
	}
	end := func(t EvalTicket) time.Time {
		if t.EndedAt != nil {
			return *t.EndedAt
		}
		return now
	}
	for i, a := range ts {
		for _, b := range ts[i+1:] {
			if a.RepoID != b.RepoID || !a.CodedAt.Before(end(b)) || !b.CodedAt.Before(end(a)) {
				continue // one landed before the other was coded: no chance to collide
			}
			rep.Pairs++
			var lines []string
			for _, c := range domain.DiffConflicts(a.Files, b.Files) {
				if c.Lines {
					lines = append(lines, c.Path)
				}
			}
			pred := predicted[pairKey(a.Key, b.Key)]
			switch {
			case pred && len(lines) > 0:
				rep.TruePositive++
			case pred:
				rep.FalsePositive++
			case len(lines) > 0:
				rep.FalseNegative++
				rep.Missed = append(rep.Missed, EvalPair{A: a.Key, B: b.Key, Files: lines})
			}
		}
	}
	return rep
}

func pairKey(a, b string) [2]string {
	if b < a {
		a, b = b, a
	}
	return [2]string{a, b}
}

// PredictedFiles returns the files an analysis.json expected to change.
func PredictedFiles(analysis []byte) []string {
	a, err := parseAnalysis(analysis)
	if err != nil || a.Footprint == nil {
		return nil
	}
	return a.Footprint.Clean().Files
}
