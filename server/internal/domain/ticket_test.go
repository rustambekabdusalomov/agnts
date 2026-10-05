package domain

import (
	"errors"
	"testing"
)

var allStates = []TicketState{
	StateNew, StateAnalyzing, StateWaitingForAnswers, StateCoding, StateTesting,
	StateWaitingForReview, StatePushing, StateDone, StateRejected, StateFailed, StateRateLimited,
}

// The full matrix: every pair is either explicitly allowed or forbidden.
func TestTransitionMatrix(t *testing.T) {
	allowed := map[[2]TicketState]bool{}
	for _, p := range [][2]TicketState{
		{StateNew, StateAnalyzing}, {StateNew, StateRejected},
		{StateAnalyzing, StateWaitingForAnswers}, {StateAnalyzing, StateCoding}, {StateAnalyzing, StateFailed},
		{StateAnalyzing, StateRateLimited}, {StateAnalyzing, StateNew}, {StateAnalyzing, StateRejected},
		{StateWaitingForAnswers, StateCoding}, {StateWaitingForAnswers, StateRejected},
		{StateCoding, StateTesting}, {StateCoding, StateFailed}, {StateCoding, StateRateLimited}, {StateCoding, StateRejected},
		{StateTesting, StateWaitingForReview}, {StateTesting, StateCoding}, {StateTesting, StateFailed}, {StateTesting, StateRejected},
		{StateWaitingForReview, StatePushing}, {StateWaitingForReview, StateCoding}, {StateWaitingForReview, StateRejected},
		{StatePushing, StateDone}, {StatePushing, StateFailed},
		{StateFailed, StateNew}, {StateFailed, StateCoding}, {StateFailed, StatePushing}, {StateFailed, StateRejected},
		{StateRateLimited, StateNew}, {StateRateLimited, StateCoding}, {StateRateLimited, StateRejected},
	} {
		allowed[p] = true
	}
	for _, from := range allStates {
		for _, to := range allStates {
			if got := CanTransition(from, to); got != allowed[[2]TicketState{from, to}] {
				t.Errorf("%s -> %s: got %v", from, to, got)
			}
		}
	}
}

func TestNoPushWithoutReview(t *testing.T) {
	for _, from := range allStates {
		if CanTransition(from, StatePushing) && from != StateWaitingForReview && from != StateFailed {
			t.Errorf("%s can reach pushing without review", from)
		}
	}
}

func TestTerminalStates(t *testing.T) {
	for _, s := range allStates {
		if s.Terminal() != (len(transitions[s]) == 0) {
			t.Errorf("%s: Terminal()=%v but has %d exits", s, s.Terminal(), len(transitions[s]))
		}
		if !s.Valid() {
			t.Errorf("%s not valid", s)
		}
	}
	if TicketState("bogus").Valid() {
		t.Error("unknown state is valid")
	}
}

func TestTransitionErrorIsConflict(t *testing.T) {
	var err error = &TransitionError{Key: "A-1", From: StateDone, To: StateCoding}
	if !errors.Is(err, ErrConflict) {
		t.Fatal("TransitionError should match ErrConflict")
	}
}
