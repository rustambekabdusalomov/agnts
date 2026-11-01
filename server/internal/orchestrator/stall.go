package orchestrator

import (
	"context"
	"encoding/json"
	"fmt"
	"strings"
	"time"

	"agnts/internal/ai"
	"agnts/internal/domain"
	"agnts/internal/guard"
)

// What counts as stuck.
const (
	stallFailures     = 3  // the same command failing in a row
	stallRereads      = 4  // reads of one file with no edit in between
	stallSinceEdit    = 20 // tool calls since the last edit, once something was edited
	stallBeforeEdit   = 45 // tool calls before the first edit
	stallMaxPerRun    = 5  // stalls recorded per run (a run that loops would flood the log)
	stallNoticeHeader = "agnts noticed that you seem to be stuck"
)

// Stall reasons.
const (
	StallRepeatedFailure = "repeated_failure"
	StallNoEdits         = "no_edits"
	StallRereading       = "rereading"
)

// stallDetector watches one invocation's stream for signs that the work
// is going in circles.
type stallDetector struct {
	coding   bool // only coding runs are expected to edit
	calls    int
	edited   bool
	lastEdit int
	pending  map[string]string // tool call id -> its summary
	streak   string            // the command failing in a row
	failures int
	reads    map[string]int
	fired    map[string]bool
}

func newStallDetector(coding bool) *stallDetector {
	return &stallDetector{coding: coding, pending: map[string]string{}, reads: map[string]int{}, fired: map[string]bool{}}
}

func isEditTool(name string) bool {
	switch name {
	case "Edit", "Write", "MultiEdit", "NotebookEdit":
		return true
	}
	return false
}

// observe takes one stream event and returns a stall when this event
// shows one (each kind of stall on the same target only once).
func (d *stallDetector) observe(e ai.Event) *domain.Stall {
	switch e.Kind {
	case ai.EventTool:
		d.calls++
		name, _ := e.Data["tool"].(string)
		if id, _ := e.Data["id"].(string); id != "" {
			d.pending[id] = e.Tool
		}
		target := ""
		if _, t, ok := strings.Cut(e.Tool, ": "); ok {
			target = t
		}
		switch {
		case isEditTool(name):
			d.edited, d.lastEdit = true, d.calls
			clear(d.reads)
		case name == "Read" && target != "":
			d.reads[target]++
			if d.reads[target] >= stallRereads {
				return d.fire(StallRereading, target, fmt.Sprintf("you have read %s %d times without changing it", target, d.reads[target]))
			}
		}
		if d.coding && d.edited && d.calls-d.lastEdit >= stallSinceEdit {
			return d.fire(StallNoEdits, fmt.Sprint(d.lastEdit), fmt.Sprintf("%d tool calls since your last edit, and nothing changed", d.calls-d.lastEdit))
		}
		if d.coding && !d.edited && d.calls >= stallBeforeEdit {
			return d.fire(StallNoEdits, "start", fmt.Sprintf("%d tool calls and no edit yet", d.calls))
		}
	case ai.EventToolResult:
		id, _ := e.Data["id"].(string)
		summary, ok := d.pending[id]
		delete(d.pending, id)
		if !ok || !strings.HasPrefix(summary, "Bash: ") {
			return nil
		}
		cmd := strings.Join(strings.Fields(strings.TrimPrefix(summary, "Bash: ")), " ")
		if failed, _ := e.Data["is_error"].(bool); !failed {
			if cmd == d.streak {
				d.streak, d.failures = "", 0
			}
			return nil
		}
		if cmd != d.streak {
			d.streak, d.failures = cmd, 0
		}
		d.failures++
		if d.failures >= stallFailures {
			return d.fire(StallRepeatedFailure, cmd, fmt.Sprintf("`%s` failed %d times in a row", cmd, d.failures))
		}
	}
	return nil
}

func (d *stallDetector) fire(reason, key, detail string) *domain.Stall {
	if d.fired[reason+"\x00"+key] {
		return nil
	}
	d.fired[reason+"\x00"+key] = true
	return &domain.Stall{At: time.Now(), Turn: d.calls, Reason: reason, Detail: detail}
}

// stallNotice is what agnts-guard tells Claude when agnts steps in.
func stallNotice(st domain.Stall) string {
	return stallNoticeHeader + ": " + st.Detail + ".\n\n" +
		"Stop and think before your next step: what is actually wrong, and why did the last attempts not fix it? " +
		"Try a different approach rather than the same thing again. If the ticket cannot be done as planned, finish now: " +
		"say why in the \"deviations\" of your summary and in " + guard.ProgressPath + ", instead of working around it."
}

// onStall records a stall on the run and, when the workspace asked agnts
// to act, has agnts-guard tell Claude at its next tool call. agnts acts at
// most once per run.
func (o *Orchestrator) onStall(ctx context.Context, s domain.Settings, ws Workspace, t domain.Ticket, run *domain.Run, st domain.Stall) {
	if len(run.Harness.Stalls) >= stallMaxPerRun {
		return
	}
	acted := false
	for _, x := range run.Harness.Stalls {
		acted = acted || x.Acted
	}
	if s.Stalls == domain.StallsAct && !acted && run.Stage == domain.StageCode {
		n := guard.Notice{ID: fmt.Sprintf("stall-%d-%d", run.ID, len(run.Harness.Stalls)), Message: stallNotice(st)}
		b, _ := json.Marshal(n)
		if err := ws.WriteFile(ctx, guard.NoticePath, b); err == nil {
			st.Acted = true
		} else {
			o.log.Warn("write stall notice", "ticket", t.Key, "err", err)
		}
	}
	run.Harness.Stalls = append(run.Harness.Stalls, st)
	noteTrouble(run, "the run looked stuck: "+st.Detail)
	msg := "looks stuck: " + st.Detail
	if st.Acted {
		msg += "; agnts asked " + domain.ToolName(domain.AccessOf(ctx)) + " to step back"
	}
	o.noteTranscript(run.ID, "stall: "+st.Detail)
	o.event(ctx, domain.Event{TicketKey: t.Key, RunID: &run.ID, Step: string(run.Stage), Type: domain.EventStall, Level: domain.LevelWarn,
		Message: msg, Data: map[string]any{"reason": st.Reason, "turn": st.Turn, "acted": st.Acted}})
}
