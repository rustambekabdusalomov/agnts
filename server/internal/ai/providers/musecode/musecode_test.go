package musecode

import (
	"strings"
	"testing"

	muse "github.com/rustambekabdusalomov/agnts-muse"
	"github.com/rustambekabdusalomov/agnts-muse/budget"
	"github.com/rustambekabdusalomov/agnts-muse/meter"
	"github.com/rustambekabdusalomov/agnts-muse/model"
	"github.com/rustambekabdusalomov/agnts-muse/money"

	"agnts/internal/ai"
)

func TestMuseModel(t *testing.T) {
	for in, want := range map[string]model.ID{"muse:spark": model.Spark, "muse:wonder": model.Wonder,
		"muse:muse-spark-1.2": model.Spark12, "muse:muse-next-9": "muse-next-9"} {
		if got := museModel(in); got != want {
			t.Errorf("museModel(%q) = %q, want %q", in, got, want)
		}
	}
}

func TestMuseCredential(t *testing.T) {
	if c, err := museCredential(ai.Credential{Env: EnvKey, Token: "LLM_0123456789abcdefghij"}); err != nil || c.APIKey == "" {
		t.Fatalf("key: %+v, %v", c, err)
	}
	login := `{"schema_version":1,"providers":{"meta":{"mechanism":"oauth","storage":"file","access_token":"acc-0123456789"}}}`
	if c, err := museCredential(ai.Credential{Env: EnvLogin, Token: login}); err != nil || string(c.File) != login {
		t.Fatalf("login: %+v, %v", c, err)
	}
	if _, err := museCredential(ai.Credential{Env: "ANTHROPIC_API_KEY", Token: "sk-ant"}); err == nil || !strings.Contains(err.Error(), "not a Muse account") {
		t.Fatalf("claude credential: %v", err)
	}
	if _, err := museCredential(ai.Credential{}); err == nil {
		t.Fatal("empty credential accepted")
	}
}

func TestMuseEvents(t *testing.T) {
	var got []ai.Event
	on := func(e ai.Event) { got = append(got, e) }
	c := meter.Charge{Model: model.Spark, Cost: 3 * money.Cent, Total: 5 * money.Cent, Calls: 2}
	for _, e := range []muse.Event{
		{Kind: muse.EventStarted, SessionID: "s1", Model: model.Spark},
		{Kind: muse.EventToolStart, Tool: "bash", Args: `{"command":"go test"}`},
		{Kind: muse.EventToolEnd, Tool: "bash", Output: "FAIL", Failed: true},
		{Kind: muse.EventMessage, Text: "Fixed it."},
		{Kind: muse.EventUsage, Charge: &c, Held: 15 * money.Cent, Model: model.Spark},
		{Kind: muse.EventSteer},
		{Kind: muse.EventApproval, Approval: &muse.Approval{Tool: "bash", Command: "git push", Allow: false, Rule: "no-push", Reason: "no"}},
		{Kind: muse.EventApproval, Approval: &muse.Approval{Tool: "bash", Command: "ls", Allow: true}},
		{Kind: muse.EventSettled, Receipt: &budget.Receipt{Charged: 5 * money.Cent, Released: 10 * money.Cent}},
		{Kind: muse.EventContinue, Reason: "the turn ended without an answer; continuing (1 of 2)"},
		{Kind: muse.EventDelta, Text: "streamed"},
	} {
		museEvent(e, 0.5, on)
	}
	kinds := make([]string, len(got))
	for i, e := range got {
		kinds[i] = string(e.Kind)
	}
	want := "init tool tool_result text budget budget budget budget budget"
	if strings.Join(kinds, " ") != want {
		t.Fatalf("kinds = %v, want %s", kinds, want)
	}
	if got[0].Data["session_id"] != "s1" || got[1].Tool != "Bash" || got[1].Data["target"] != "go test" || got[2].Data["is_error"] != true {
		t.Fatalf("mapped = %+v", got[:3])
	}
	u := got[4]
	if u.Data["total_usd"] != 0.05 || u.Data["held_usd"] != 0.15 || u.Data["limit_usd"] != 0.5 || u.Data["level"] != "info" {
		t.Fatalf("usage = %+v", u.Data)
	}
	if got[5].Data["level"] != "warn" || !strings.Contains(got[6].Text, "no-push") {
		t.Fatalf("steer/approval = %+v %+v", got[5], got[6])
	}
	if c := got[8]; c.Data["kind"] != "continue" || !strings.Contains(c.Text, "without an answer") {
		t.Fatalf("continue = %+v", c)
	}
}

// A run someone follows in a chat: their messages and answers go into it,
// and what it waits on is in the ticket's log.
func TestMuseLiveEvents(t *testing.T) {
	var got []ai.Event
	on := func(e ai.Event) { got = append(got, e) }
	for _, e := range []muse.Event{
		{Kind: muse.EventSteer, Reason: "person", Text: "[Message from the person following this task] in seconds"},
		{Kind: muse.EventSteer, Reason: "steps"},
		{Kind: muse.EventApproval, Approval: &muse.Approval{Tool: "bash", Command: "npm install left-pad", Ask: true, Pending: true,
			Rule: "ask-new-dependency", Reason: "it adds a dependency to the project"}},
		{Kind: muse.EventApproval, Approval: &muse.Approval{Tool: "bash", Command: "npm install left-pad", Ask: true, Allow: true, Rule: "ask-new-dependency"}},
		{Kind: muse.EventApproval, Approval: &muse.Approval{Tool: "bash", Command: "pip install x", Ask: true, Rule: "ask-new-dependency"}},
	} {
		museEvent(e, 0, on)
	}
	var lines []string
	for _, e := range got {
		lines = append(lines, e.Data["kind"].(string)+"/"+e.Data["level"].(string)+": "+e.Text)
	}
	want := []string{
		"message/info: a message from the chat went to the running agent",
		"steer/warn: model calls running low: told Muse to wrap up",
		"ask/warn: waiting for the chat to allow npm install left-pad (it adds a dependency to the project)",
		"ask/info: the chat allowed npm install left-pad",
		"ask/warn: the chat did not allow pip install x",
	}
	if strings.Join(lines, "\n") != strings.Join(want, "\n") {
		t.Fatalf("events:\n%s", strings.Join(lines, "\n"))
	}
}
