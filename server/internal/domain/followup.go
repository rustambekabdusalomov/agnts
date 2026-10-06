package domain

import (
	"fmt"
	"slices"
	"strings"
	"time"
)

// Where a suggested follow-up came from.
const (
	SuggestFromAnalyze = "analyze" // the analysis: prerequisites and parts to split off
	SuggestFromWork    = "work"    // the code or report run: what it left undone or found
	SuggestFromReview  = "review"  // the code review: findings outside the change
	SuggestFromManual  = "manual"  // a person turned a review finding into one
)

// SuggestionTypes say how a follow-up serves its parent ticket. Anything
// else is out of scope: follow-ups exist to finish the parent, not to
// invent new work.
var SuggestionTypes = []string{"prerequisite", "split", "unfinished", "gap"}

// Suggestion statuses.
const (
	SuggestionOpen      = "open"
	SuggestionAccepted  = "accepted"
	SuggestionDismissed = "dismissed"
)

// ErrSuggestionDecided is returned when a suggestion that was already
// accepted or dismissed is decided again. It is a conflict.
var ErrSuggestionDecided = fmt.Errorf("%w: this suggestion was already decided", ErrConflict)

// MaxFollowUps caps what one run may suggest.
const MaxFollowUps = 5

// FollowUp is a suggested ticket as Claude writes it.
type FollowUp struct {
	Type        string `json:"type"`
	Title       string `json:"title"`
	Description string `json:"description"`
	Serves      string `json:"serves"`
	Kind        string `json:"kind"`
	Priority    string `json:"priority"`
}

// Suggestion is a follow-up ticket agnts suggests from a ticket. Nothing
// is created until someone accepts it.
type Suggestion struct {
	ID          int64
	TicketID    int64
	RunID       *int64
	Source      string
	Type        string
	Revision    int // the parent's revision when it was suggested
	Title       string
	Description string
	Serves      string // how it helps finish the parent
	Kind        TicketKind
	Priority    string
	Status      string
	ChildKey    string // the ticket made from it, once accepted
	DecidedAt   *time.Time
	CreatedAt   time.Time
}

// Suggestion builds a suggestion from what Claude wrote, cleaned. It
// reports false when the follow-up is out of scope: no title, no known
// type, or no word on how it serves the parent.
func (f FollowUp) Suggestion(source string) (Suggestion, bool) {
	s := Suggestion{
		Source: source, Status: SuggestionOpen,
		Type:        strings.ToLower(strings.TrimSpace(f.Type)),
		Title:       clip(strings.TrimSpace(f.Title), 300),
		Description: clip(strings.TrimSpace(f.Description), 6000),
		Serves:      clip(strings.TrimSpace(f.Serves), 1000),
		Kind:        TicketKind(strings.ToLower(strings.TrimSpace(f.Kind))),
		Priority:    strings.ToLower(strings.TrimSpace(f.Priority)),
	}
	if s.Title == "" || s.Serves == "" || !slices.Contains(SuggestionTypes, s.Type) {
		return s, false
	}
	if !s.Kind.Valid() {
		s.Kind = KindCode
	}
	if !slices.Contains([]string{"low", "medium", "high"}, s.Priority) {
		s.Priority = "medium"
	}
	return s, true
}

// Suggestions cleans a run's follow-ups: out-of-scope ones and repeats of
// a title are dropped, and at most MaxFollowUps are kept.
func Suggestions(fs []FollowUp, source string) []Suggestion {
	out := []Suggestion{}
	seen := map[string]bool{}
	for _, f := range fs {
		s, ok := f.Suggestion(source)
		key := strings.ToLower(s.Title)
		if !ok || seen[key] {
			continue
		}
		seen[key] = true
		if out = append(out, s); len(out) == MaxFollowUps {
			break
		}
	}
	return out
}

// Ready reports whether a ticket can be made from s while its parent is
// in state. What the analysis suggests (prerequisites, splits) can start
// at once; what the work or its review found builds on the work, so it
// waits until the parent is done.
func (s Suggestion) Ready(state TicketState) bool {
	if s.Status != SuggestionOpen {
		return false
	}
	if s.Source == SuggestFromAnalyze {
		return true
	}
	return state == StateDone
}
