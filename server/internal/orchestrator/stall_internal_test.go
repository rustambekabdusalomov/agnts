package orchestrator

import (
	"fmt"
	"testing"

	"agnts/internal/ai"
	"agnts/internal/domain"
)

func tool(name, target, id string) ai.Event {
	return ai.Event{Kind: ai.EventTool, Tool: name + ": " + target, Data: map[string]any{"tool": name, "id": id}}
}

func result(id string, failed bool) ai.Event {
	return ai.Event{Kind: ai.EventToolResult, Data: map[string]any{"id": id, "is_error": failed}}
}

func TestStallDetector(t *testing.T) {
	t.Run("the same command failing", func(t *testing.T) {
		d := newStallDetector(true)
		var got []*domain.Stall
		for i := range 4 {
			id := fmt.Sprint("b", i)
			got = append(got, d.observe(tool("Bash", "go  test ./pay/...", id)), d.observe(result(id, true)))
		}
		var stalls []*domain.Stall
		for _, s := range got {
			if s != nil {
				stalls = append(stalls, s)
			}
		}
		if len(stalls) != 1 || stalls[0].Reason != StallRepeatedFailure || stalls[0].Detail != "`go test ./pay/...` failed 3 times in a row" {
			t.Fatalf("stalls: %+v", stalls)
		}
	})
	t.Run("a pass resets the streak", func(t *testing.T) {
		d := newStallDetector(true)
		seq := []bool{true, true, false, true, true}
		for i, failed := range seq {
			id := fmt.Sprint("b", i)
			d.observe(tool("Bash", "make test", id))
			if s := d.observe(result(id, failed)); s != nil {
				t.Fatalf("stall after %d: %+v", i, s)
			}
		}
	})
	t.Run("rereading one file", func(t *testing.T) {
		d := newStallDetector(true)
		var last *domain.Stall
		for i := range 4 {
			last = d.observe(tool("Read", "/workspace/pay.go", fmt.Sprint("r", i)))
		}
		if last == nil || last.Reason != StallRereading {
			t.Fatalf("got %+v", last)
		}
		d.observe(tool("Edit", "/workspace/pay.go", "e1"))
		for i := range 3 {
			if s := d.observe(tool("Read", "/workspace/pay.go", fmt.Sprint("x", i))); s != nil {
				t.Fatalf("an edit did not reset the reads: %+v", s)
			}
		}
	})
	t.Run("no edits for a long time", func(t *testing.T) {
		d := newStallDetector(true)
		d.observe(tool("Edit", "/workspace/a.go", "e"))
		var fired []*domain.Stall
		for i := range stallSinceEdit + 5 {
			if s := d.observe(tool("Grep", fmt.Sprint("pattern", i), fmt.Sprint("g", i))); s != nil {
				fired = append(fired, s)
			}
		}
		if len(fired) != 1 || fired[0].Reason != StallNoEdits {
			t.Fatalf("fired: %+v", fired)
		}
		// Analysis runs do not edit: never a no-edits stall there.
		a := newStallDetector(false)
		for i := range stallBeforeEdit + 5 {
			if s := a.observe(tool("Grep", fmt.Sprint("p", i), fmt.Sprint("g", i))); s != nil {
				t.Fatalf("analysis stall: %+v", s)
			}
		}
	})
}
