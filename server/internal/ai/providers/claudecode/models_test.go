package claudecode

import (
	"slices"
	"testing"
)

func TestModelIDs(t *testing.T) {
	m := New(nil).models
	for name, want := range map[string]string{"opus": "claude-opus-5-5", "sonnet": "claude-sonnet-5-5", "haiku": "claude-haiku-5-5",
		"claude-opus-4-7": "claude-opus-4-7", "": ""} {
		if got := modelID(m, name); got != want {
			t.Errorf("modelID(%q) = %q, want %q", name, got, want)
		}
	}
	// Claude Code's own short names follow, so sub-agents use the same models.
	env := modelEnv(m)
	for _, want := range []string{"ANTHROPIC_DEFAULT_OPUS_MODEL=claude-opus-5-5", "ANTHROPIC_DEFAULT_SONNET_MODEL=claude-sonnet-5-5",
		"ANTHROPIC_DEFAULT_HAIKU_MODEL=claude-haiku-5-5"} {
		if !slices.Contains(env, want) {
			t.Errorf("modelEnv lacks %s: %v", want, env)
		}
	}
	// An emptied mapping passes the short name through and sets nothing.
	m = New(map[string]string{"haiku": ""}).models
	if modelID(m, "haiku") != "haiku" || len(modelEnv(m)) != 2 {
		t.Fatalf("emptied: %q %v", modelID(m, "haiku"), modelEnv(m))
	}
	// Each provider gets its own copy of the defaults.
	if DefaultModels["haiku"] != "claude-haiku-5-5" {
		t.Fatal("DefaultModels changed through a config")
	}
}

func TestCatalog(t *testing.T) {
	c := New(nil).Catalog()
	if c.Model("strong") != "opus" || c.Model("light") != "sonnet" || c.TierOf("opus") != "strong" || c.TierOf("haiku") != "light" {
		t.Fatal("tiers")
	}
	if !c.Valid("sonnet") || c.Valid("gpt-5") {
		t.Fatal("valid")
	}
}
