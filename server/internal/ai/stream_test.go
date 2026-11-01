package ai

import "testing"

func TestToolSummaryNamesTheSkill(t *testing.T) {
	for in, want := range map[string]string{
		`{"skill":"agnts-method-house-style"}`:   "Skill: agnts-method-house-style",
		`{"command":"agnts-method-reuse-first"}`: "Skill: agnts-method-reuse-first", // older Claude Code versions
		`{}`:                                     "Skill",
	} {
		if got := ToolSummary("Skill", []byte(in)); got != want {
			t.Errorf("%s: %q, want %q", in, got, want)
		}
	}
}
