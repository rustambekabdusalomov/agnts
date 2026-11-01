package httpapi

import (
	"testing"

	"agnts/internal/ai"
	"agnts/internal/ai/aitest"
	"agnts/internal/domain"
)

// Each module of the catalog has its own models and its light and strong
// one; Codex lists the models named for its tiers.
func TestCatalogModules(t *testing.T) {
	s := &Server{opt: Options{Providers: aitest.Providers()}}
	all := domain.Access{Modules: []string{domain.ProviderClaude, domain.ProviderMuse, domain.ProviderCodex}}
	byModule := map[string][]string{}
	for _, m := range s.models(all) {
		byModule[m.Provider] = append(byModule[m.Provider], m.ID)
	}
	if len(byModule["claude"]) != 3 || len(byModule["muse"]) != 2 || len(byModule["codex"]) != 2 || byModule["codex"][1] != "codex:gpt-5" {
		t.Fatalf("models: %v", byModule)
	}
	for p, want := range map[string][2]string{"claude": {"sonnet", "opus"}, "muse": {"muse:spark", "muse:wonder"}, "codex": {"codex:gpt-5-mini", "codex:gpt-5"}} {
		if l, st := s.tierModels(p); l != want[0] || st != want[1] {
			t.Errorf("%s: %s %s", p, l, st)
		}
	}
	// Codex without models of its own has none to list.
	bare := &Server{opt: Options{Providers: ai.NewRegistry(aitest.Claude())}}
	if l, st := bare.tierModels("codex"); l != "" || st != "" {
		t.Fatalf("bare codex: %q %q", l, st)
	}
}
