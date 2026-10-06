package domain

import (
	"fmt"
	"testing"
)

func TestSuggestionsKeepOnlyWhatServesTheParent(t *testing.T) {
	fs := []FollowUp{
		{Type: "Prerequisite", Title: " Add expires_at column ", Serves: "the expiry check needs it", Kind: "code", Priority: "HIGH"},
		{Type: "idea", Title: "Rewrite in Rust", Serves: "faster"},                         // not a known type
		{Type: "gap", Title: "Docs for expiry", Serves: ""},                                // serves nothing said
		{Type: "unfinished", Title: "", Serves: "x"},                                       // no title
		{Type: "unfinished", Title: "add expires_at column", Serves: "repeat"},             // same title
		{Type: "unfinished", Title: "Test expiry", Serves: "untested", Kind: "weird"},      // kind falls back
		{Type: "split", Title: "Admin screen", Serves: "part of the ticket", Kind: "plan"}, // kept
	}
	got := Suggestions(fs, SuggestFromAnalyze)
	if len(got) != 3 {
		t.Fatalf("kept %d: %+v", len(got), got)
	}
	if s := got[0]; s.Type != "prerequisite" || s.Title != "Add expires_at column" || s.Priority != "high" || s.Status != SuggestionOpen || s.Source != SuggestFromAnalyze {
		t.Fatalf("first: %+v", s)
	}
	if s := got[1]; s.Kind != KindCode || s.Priority != "medium" {
		t.Fatalf("defaults: %+v", s)
	}
	if got[2].Kind != KindPlan {
		t.Fatalf("kind: %+v", got[2])
	}
}

func TestSuggestionsAreCapped(t *testing.T) {
	var fs []FollowUp
	for i := range 9 {
		fs = append(fs, FollowUp{Type: "gap", Title: fmt.Sprintf("Gap %d", i), Serves: "the report found it"})
	}
	if got := Suggestions(fs, SuggestFromWork); len(got) != MaxFollowUps {
		t.Fatalf("kept %d", len(got))
	}
}

func TestSuggestionReady(t *testing.T) {
	a := Suggestion{Source: SuggestFromAnalyze, Status: SuggestionOpen}
	w := Suggestion{Source: SuggestFromWork, Status: SuggestionOpen}
	if !a.Ready(StateCoding) || w.Ready(StateWaitingForReview) || !w.Ready(StateDone) {
		t.Fatal("readiness by source")
	}
	w.Status = SuggestionAccepted
	if w.Ready(StateDone) {
		t.Fatal("accepted suggestion is ready again")
	}
}

func TestFollowUpsOn(t *testing.T) {
	s := DefaultSettings()
	if s.SuggestFollowUps || s.FollowUpsOn(Ticket{}) {
		t.Fatal("follow-ups must be off by default")
	}
	on, off := true, false
	if !s.FollowUpsOn(Ticket{SuggestFollowUps: &on}) {
		t.Fatal("ticket override on")
	}
	s.SuggestFollowUps = true
	if s.FollowUpsOn(Ticket{SuggestFollowUps: &off}) || !s.FollowUpsOn(Ticket{}) {
		t.Fatal("ticket override off / inherit")
	}
}
