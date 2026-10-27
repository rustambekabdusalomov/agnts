package domain

import "testing"

func TestProviders(t *testing.T) {
	t.Cleanup(func() { SetProviders([]string{ProviderMuse}) })
	SetProviders([]string{" MUSE ", "bogus", "muse"})
	if got := EnabledProviders(); len(got) != 1 || got[0] != ProviderMuse {
		t.Fatalf("providers = %v", got)
	}
	s := DefaultSettings()
	if s.Models.Coding != MuseSpark || s.Models.Review != ModelAuto {
		t.Fatalf("muse defaults = %+v", s.Models)
	}
	if err := s.Validate(); err != nil {
		t.Fatal(err)
	}
	s.Models.Coding = "opus"
	if err := s.Validate(); err == nil {
		t.Fatal("a hidden provider's model was accepted")
	}
	// Settings saved before the switch keep working on Muse.
	old := Settings{Models: StageModels{Coding: "opus", Analyze: "sonnet"}}
	if old.ModelFor(Ticket{}, ModelCoding) != MuseWonder || old.ModelFor(Ticket{}, ModelAnalyze) != MuseSpark {
		t.Fatalf("mapped %q %q", old.ModelFor(Ticket{}, ModelCoding), old.ModelFor(Ticket{}, ModelAnalyze))
	}
	if StrongModel() != MuseWonder || LightModel() != MuseSpark || !IsStrong(MuseWonder) || IsStrong(MuseSpark) {
		t.Fatal("tiers")
	}

	SetProviders([]string{"claude", "codex"})
	if DefaultSettings().Models.Coding != "opus" || EffectiveModel("muse:spark") != "sonnet" || !AllowedModel("codex:gpt-5") || AllowedModel(MuseSpark) {
		t.Fatal("claude server")
	}
	if ProviderOf("muse:spark") != ProviderMuse || ProviderOf("codex:x") != ProviderCodex || ProviderOf("haiku") != ProviderClaude {
		t.Fatal("ProviderOf")
	}
}
