package runner

import (
	"strings"
	"testing"

	muse "github.com/rustambekabdusalomov/agnts-muse"
	"github.com/rustambekabdusalomov/agnts-muse/budget"
	"github.com/rustambekabdusalomov/agnts-muse/meter"
	"github.com/rustambekabdusalomov/agnts-muse/model"
	"github.com/rustambekabdusalomov/agnts-muse/money"

	"agnts/internal/orchestrator"
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
	if c, err := museCredential(Credential{Env: MuseKeyEnv, Token: "LLM_0123456789abcdefghij"}); err != nil || c.APIKey == "" {
		t.Fatalf("key: %+v, %v", c, err)
	}
	login := `{"schema_version":1,"providers":{"meta":{"mechanism":"oauth","storage":"file","access_token":"acc-0123456789"}}}`
	if c, err := museCredential(Credential{Env: MuseLoginEnv, Token: login}); err != nil || c.Token == nil {
		t.Fatalf("login: %+v, %v", c, err)
	}
	if _, err := museCredential(Credential{Env: "ANTHROPIC_API_KEY", Token: "sk-ant"}); err == nil || !strings.Contains(err.Error(), "not a Muse account") {
		t.Fatalf("claude credential: %v", err)
	}
	if _, err := museCredential(Credential{}); err == nil {
		t.Fatal("empty credential accepted")
	}
}

func TestMuseEvents(t *testing.T) {
	var got []orchestrator.ClaudeEvent
	on := func(e orchestrator.ClaudeEvent) { got = append(got, e) }
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
		{Kind: muse.EventDelta, Text: "streamed"},
	} {
		museEvent(e, 0.5, on)
	}
	kinds := make([]string, len(got))
	for i, e := range got {
		kinds[i] = string(e.Kind)
	}
	want := "init tool tool_result text budget budget budget budget"
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
}
