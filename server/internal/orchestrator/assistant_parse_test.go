package orchestrator_test

import (
	"encoding/json"
	"strings"
	"testing"

	"agnts/internal/domain"
	"agnts/internal/orchestrator"
)

func TestParseAssistantAnswer(t *testing.T) {
	for _, bad := range []string{``, `not json`, `{"answer":"  "}`, `{"speech":"hi"}`} {
		if _, err := orchestrator.ParseAssistantAnswer([]byte(bad)); err == nil {
			t.Errorf("%q parsed", bad)
		}
	}
	a, err := orchestrator.ParseAssistantAnswer([]byte(`{"answer":"## Waiting\n\n- **PAY-214**: review [it](https://x.y/PAY-214)\n- PAY-9: answer ` + "`two`" + ` questions\n\nThat is all. More text here! And more? Last one.",
		"links":[{"kind":"ticket","key":" pay-214 "},{"kind":"ticket","key":"PAY-214"},{"kind":"ci","id":3,"key":"x"},{"kind":"lesson","id":0},{"kind":"web","key":"x"}]}`))
	if err != nil {
		t.Fatal(err)
	}
	if a.Speech != "Waiting PAY-214: review it PAY-9: answer two questions That is all. More text here! And more?" {
		t.Errorf("speech = %q", a.Speech)
	}
	want := []domain.AssistantLink{{Kind: "ticket", Key: "PAY-214"}, {Kind: "ci", ID: 3}}
	if len(a.Links) != 2 || a.Links[0] != want[0] || a.Links[1] != want[1] {
		t.Errorf("links = %+v", a.Links)
	}
	a, _ = orchestrator.ParseAssistantAnswer([]byte(`{"answer":"x","speech":" Two tickets wait. "}`))
	if a.Speech != "Two tickets wait." {
		t.Errorf("given speech = %q", a.Speech)
	}
}

func TestSpeechOfDropsCode(t *testing.T) {
	got := orchestrator.SpeechOf("The test fails:\n\n```\npanic: nil map\n```\n\nSee https://ci.example.com/run/1 for the log.")
	if got != "The test fails: See for the log." {
		t.Errorf("speech = %q", got)
	}
}

func TestAssistantTopicsOf(t *testing.T) {
	cases := map[string][]orchestrator.AssistantTopic{
		"Why is main red?":                 {orchestrator.TopicCI},
		"Почему упала сборка?":             {orchestrator.TopicCI},
		"How much did we spend this week?": {orchestrator.TopicSpend},
		"Bu hafta qancha xarajat qildik?":  {orchestrator.TopicSpend},
		"Какие уроки новые?":               {orchestrator.TopicLessons},
		"Which repositories are archived?": {orchestrator.TopicRepos},
		"What waits on me?":                nil,
		"We need to decide on PAY-1":       nil, // "decide" is not "ci"
	}
	for q, want := range cases {
		got := orchestrator.AssistantTopicsOf(q, nil)
		if len(got) != len(want) {
			t.Errorf("%q: topics %v, want %v", q, got, want)
			continue
		}
		for _, w := range want {
			if !got[w] {
				t.Errorf("%q: topics %v, want %v", q, got, want)
			}
		}
	}
	// A follow-up takes its topic from the last exchange.
	h := []domain.AssistantMessage{{Role: domain.AssistantUser, Text: "Why is CI red?"}, {Role: domain.AssistantReply, Text: "A flaky test."}}
	if got := orchestrator.AssistantTopicsOf("and yesterday?", h); !got[orchestrator.TopicCI] {
		t.Errorf("follow-up topics = %v", got)
	}
}

func TestAssistantPermissionsDenyCommandsAndTheWeb(t *testing.T) {
	var s struct {
		Permissions struct{ Allow, Deny []string }
	}
	if err := json.Unmarshal([]byte(orchestrator.AssistantPermissions()), &s); err != nil {
		t.Fatal(err)
	}
	deny := strings.Join(s.Permissions.Deny, " ")
	for _, d := range []string{"Bash", "WebFetch", "WebSearch", "Write(//workspace/**)", "Edit(//agnts/context/**)"} {
		if !strings.Contains(deny, d) {
			t.Errorf("deny %v lacks %s", s.Permissions.Deny, d)
		}
	}
	allow := strings.Join(s.Permissions.Allow, " ")
	if !strings.Contains(allow, "Write(//agnts/out/**)") || strings.Contains(allow, "Bash") {
		t.Errorf("allow = %v", s.Permissions.Allow)
	}
}
