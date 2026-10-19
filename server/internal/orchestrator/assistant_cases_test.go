package orchestrator_test

import (
	"encoding/json"
	"strings"
	"testing"

	"agnts/internal/domain"
	"agnts/internal/orchestrator"
)

func TestAssistantCasesAreWellFormed(t *testing.T) {
	cs, err := orchestrator.AssistantCases()
	if err != nil {
		t.Fatal(err)
	}
	if len(cs) < 8 {
		t.Fatalf("%d cases", len(cs))
	}
	tools := map[string]bool{}
	for _, x := range orchestrator.AssistantTools {
		tools[x.Name] = true
	}
	names := map[string]bool{}
	acting, quiet := 0, 0
	for _, c := range cs {
		if c.Name == "" || names[c.Name] || c.Question == "" || len(c.Files) == 0 {
			t.Errorf("case %q: needs a unique name, a question and files", c.Name)
		}
		names[c.Name] = true
		if _, ok := domain.AssistantLanguages[c.Lang]; !ok {
			t.Errorf("case %q: lang %q", c.Name, c.Lang)
		}
		if _, ok := c.Files["me.json"]; !ok {
			t.Errorf("case %q: no me.json", c.Name)
		}
		for _, w := range c.Want {
			if !tools[w.Tool] {
				t.Errorf("case %q: wants %s, which the prompt does not offer", c.Name, w.Tool)
			}
		}
		if len(c.Want) > 0 {
			acting++
		} else {
			quiet++
		}
		var files []orchestrator.AssistantFile
		if err := json.Unmarshal(c.Snapshot(), &files); err != nil {
			t.Fatalf("case %q: snapshot: %v", c.Name, err)
		}
		last := files[len(files)-1]
		if last.Name != "question.txt" || last.Content != c.Question || files[0].Name > files[1].Name {
			t.Errorf("case %q: snapshot files %v", c.Name, files)
		}
	}
	// Both sides are covered: acting when asked, and not acting when
	// the files only talk about it.
	if acting < 3 || quiet < 4 {
		t.Errorf("%d acting and %d quiet cases", acting, quiet)
	}
}

func TestCheckProposals(t *testing.T) {
	p := func(tool, args string) domain.AssistantProposal {
		return domain.AssistantProposal{Tool: tool, Args: json.RawMessage(args)}
	}
	approve := []orchestrator.WantAction{{Tool: "approve_ticket", Args: map[string]any{"key": "PAY-214"}}}
	cases := []struct {
		name string
		got  []domain.AssistantProposal
		want []orchestrator.WantAction
		bad  []string // what the problems mention, in order
	}{
		{"match, keys in any case", []domain.AssistantProposal{p("approve_ticket", `{"key":" pay-214 ","post_report":false}`)}, approve, nil},
		{"none wanted, none made", nil, nil, nil},
		{"missing", nil, approve, []string{"missing approve_ticket"}},
		{"another ticket", []domain.AssistantProposal{p("approve_ticket", `{"key":"PAY-1"}`)}, approve, []string{"missing", "not asked for approve_ticket"}},
		{"unasked", []domain.AssistantProposal{p("reject_ticket", `{"key":"PAY-1"}`)}, nil, []string{"not asked for reject_ticket"}},
		{"one too many", []domain.AssistantProposal{p("approve_ticket", `{"key":"PAY-214"}`), p("approve_ticket", `{"key":"PAY-214"}`)}, approve,
			[]string{"not asked for"}},
		{"bad args", []domain.AssistantProposal{p("approve_ticket", `[1]`)}, approve, []string{"missing", "not asked for"}},
	}
	for _, c := range cases {
		got := orchestrator.CheckProposals(c.got, c.want)
		if len(got) != len(c.bad) {
			t.Errorf("%s: problems %q, want %d", c.name, got, len(c.bad))
			continue
		}
		for i, b := range c.bad {
			if !strings.Contains(got[i], b) {
				t.Errorf("%s: problem %q, want it to mention %q", c.name, got[i], b)
			}
		}
	}
}
