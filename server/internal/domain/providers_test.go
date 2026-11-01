package domain

import (
	"slices"
	"strings"
	"testing"
)

var (
	museOnly    = Access{Modules: []string{ProviderMuse}}
	claudeCodex = Access{Modules: []string{ProviderClaude, ProviderCodex}}
)

func TestProviders(t *testing.T) {
	t.Cleanup(func() { SetProviders([]string{ProviderMuse}) })
	SetProviders([]string{" MUSE ", "bogus", "muse"})
	if got := Ceiling(); len(got) != 1 || got[0] != ProviderMuse {
		t.Fatalf("ceiling = %v", got)
	}
	if got := DefaultAccess(); !slices.Equal(got.Modules, []string{ProviderMuse}) {
		t.Fatalf("SetProviders made the default %v", got)
	}
	s := DefaultSettings()
	if s.Models.Coding != MuseSpark || s.Models.Review != ModelAuto {
		t.Fatalf("muse defaults = %+v", s.Models)
	}
	if err := s.Validate(); err != nil {
		t.Fatal(err)
	}
	if StrongModel(museOnly) != MuseWonder || LightModel(museOnly) != MuseSpark || !IsStrong(MuseWonder) || IsStrong(MuseSpark) {
		t.Fatal("muse tiers")
	}
	if StrongModel(claudeCodex) != "opus" || LightModel(claudeCodex) != "sonnet" {
		t.Fatal("claude tiers")
	}
	if ProviderOf("muse:spark") != ProviderMuse || ProviderOf("codex:x") != ProviderCodex || ProviderOf("haiku") != ProviderClaude {
		t.Fatal("ProviderOf")
	}
	if got := AvailableModels(claudeCodex); !slices.Equal(got, Models) {
		t.Fatalf("available = %v", got)
	}
}

func TestEffectiveModel(t *testing.T) {
	cases := []struct {
		a        Access
		in, want string
	}{
		// Claude keeps the tier.
		{claudeCodex, MuseWonder, "opus"},
		{claudeCodex, "muse:muse-wonder-1.0", "opus"},
		{claudeCodex, MuseSpark, "sonnet"},
		{claudeCodex, "codex:gpt-5", "codex:gpt-5"}, // allowed: kept
		// Muse is always Spark: Wonder for every run is three times dearer.
		{museOnly, "opus", MuseSpark},
		{museOnly, "sonnet", MuseSpark},
		{museOnly, "haiku", MuseSpark},
		{museOnly, "codex:gpt-5", MuseSpark},
		{museOnly, MuseWonder, MuseWonder},
		// Codex without its own default maps to the default's light model.
		{Access{Modules: []string{ProviderClaude}}, "codex:gpt-5", "sonnet"},
		// Nothing to map: auto, empty, and a person with no modules.
		{museOnly, ModelAuto, ModelAuto},
		{museOnly, "", ""},
		{Access{}, "opus", "opus"},
	}
	for _, c := range cases {
		if got := EffectiveModel(c.a, c.in); got != c.want {
			t.Errorf("EffectiveModel(%v, %q) = %q, want %q", c.a.Modules, c.in, got, c.want)
		}
	}
	if !AllowedModel(claudeCodex, "codex:gpt-5") || AllowedModel(claudeCodex, MuseSpark) || AllowedModel(museOnly, "opus") || AllowedModel(museOnly, "bogus") {
		t.Fatal("AllowedModel")
	}
}

func TestResolveAccess(t *testing.T) {
	ceiling := []string{ProviderMuse, ProviderClaude, ProviderCodex}
	cfg := ModulesConfig{Enabled: []string{ProviderMuse, ProviderClaude, ProviderCodex}, Default: []string{ProviderClaude, ProviderCodex}}
	cases := []struct {
		name     string
		ceiling  []string
		cfg      ModulesConfig
		override []string
		want     []string
	}{
		{"default", ceiling, cfg, nil, []string{ProviderClaude, ProviderCodex}},
		{"judge", ceiling, cfg, []string{ProviderMuse}, []string{ProviderMuse}},
		{"none", ceiling, cfg, []string{}, []string{}},
		{"disabled later", ceiling, ModulesConfig{Enabled: []string{ProviderClaude}, Default: cfg.Default}, []string{ProviderMuse, ProviderClaude}, []string{ProviderClaude}},
		{"over the ceiling", []string{ProviderMuse}, cfg, nil, []string{}},
		{"order kept", ceiling, cfg, []string{ProviderCodex, ProviderMuse}, []string{ProviderCodex, ProviderMuse}},
	}
	for _, c := range cases {
		if got := ResolveAccess(c.ceiling, c.cfg, c.override); !slices.Equal(got.Modules, c.want) {
			t.Errorf("%s: %v, want %v", c.name, got.Modules, c.want)
		}
	}
}

func TestModulesConfigValidate(t *testing.T) {
	ceiling := []string{ProviderMuse, ProviderClaude, ProviderCodex}
	ok := []ModulesConfig{
		{Enabled: []string{ProviderMuse}, Default: []string{ProviderMuse}},
		{Enabled: ceiling, Default: []string{ProviderClaude, ProviderCodex}},
		{Enabled: ceiling, Default: []string{}}, // new people get nothing
	}
	for _, c := range ok {
		if err := c.Validate(ceiling); err != nil {
			t.Errorf("%+v: %v", c, err)
		}
	}
	bad := map[string]ModulesConfig{
		"default":     {Enabled: ceiling, Default: []string{ProviderCodex, ProviderClaude}},
		"enable":      {Enabled: []string{}},
		"cannot run":  {Enabled: []string{ProviderClaude}, Default: []string{ProviderClaude}},
		"unknown":     {Enabled: []string{"gemini"}},
		"twice":       {Enabled: []string{ProviderMuse, ProviderMuse}},
		"not enabled": {Enabled: []string{ProviderMuse}, Default: []string{ProviderClaude}},
	}
	for want, c := range bad {
		ceil := ceiling
		if want == "cannot run" {
			ceil = []string{ProviderMuse}
		}
		err := c.Validate(ceil)
		if err == nil || !strings.Contains(err.Error(), want) {
			t.Errorf("%+v: err = %v, want it to mention %q", c, err, want)
		}
	}
}

func TestSettingsFor(t *testing.T) {
	saved := Settings{Models: StageModels{Analyze: "sonnet", Coding: "opus", Retry: "sonnet", Helper: "haiku", Learn: "sonnet", Review: ModelAuto, Preview: "sonnet"},
		SecondOpinion: "codex:gpt-5"}
	// A judge runs a Claude workspace's settings on Muse; nothing stored
	// changes.
	j := saved.For(museOnly)
	if j.Models.Coding != MuseSpark || j.Models.Review != ModelAuto || j.SecondOpinion != MuseSpark {
		t.Fatalf("judge = %+v / %q", j.Models, j.SecondOpinion)
	}
	if saved.Models.Coding != "opus" {
		t.Fatal("For changed the stored settings")
	}
	if got := j.ModelFor(Ticket{Models: map[string]string{ModelCoding: "opus"}}, ModelCoding); got != MuseSpark {
		t.Fatalf("a ticket's override = %q", got)
	}
	// A Claude person keeps them.
	if c := saved.For(claudeCodex); c.Models.Coding != "opus" || c.SecondOpinion != "codex:gpt-5" {
		t.Fatalf("claude = %+v", c.Models)
	}
	// The modules a run needs: the default one first, then each stage's.
	if got := saved.For(claudeCodex).Modules(nil); !slices.Equal(got, []string{ProviderClaude, ProviderCodex}) {
		t.Fatalf("modules = %v", got)
	}
	if got := saved.For(museOnly).Modules(nil); !slices.Equal(got, []string{ProviderMuse}) {
		t.Fatalf("judge modules = %v", got)
	}
	mixed := Settings{Models: StageModels{Analyze: "sonnet", Coding: "codex:gpt-5", Retry: "sonnet", Helper: "haiku", Learn: "sonnet", Review: ModelAuto, Preview: "sonnet"}}
	if got := mixed.For(claudeCodex).Modules(map[string]string{}); !slices.Equal(got, []string{ProviderClaude, ProviderCodex}) {
		t.Fatalf("mixed modules = %v", got)
	}
}

func TestCheckModels(t *testing.T) {
	prev := Settings{Models: StageModels{Analyze: MuseSpark, Coding: MuseSpark, Retry: MuseSpark, Helper: MuseSpark, Learn: MuseSpark, Review: ModelAuto, Preview: MuseSpark}}
	// A Claude person saves something else: the stored Muse models stay.
	if err := prev.CheckModels(claudeCodex, prev); err != nil {
		t.Fatalf("unchanged models refused: %v", err)
	}
	next := prev
	next.Models.Coding = "opus"
	next.SecondOpinion = "codex:gpt-5"
	if err := next.CheckModels(claudeCodex, prev); err != nil {
		t.Fatal(err)
	}
	next.Models.Analyze = MuseWonder
	err := next.CheckModels(claudeCodex, prev)
	if err == nil || !strings.Contains(err.Error(), "analyze") || !strings.Contains(err.Error(), "Muse is not enabled") {
		t.Fatalf("err = %v", err)
	}
	// Validate itself accepts any model agnts can run.
	if err := next.Validate(); err != nil && strings.Contains(err.Error(), "model for") {
		t.Fatal(err)
	}
}

func TestRunPerson(t *testing.T) {
	w := Workspace{OwnerID: 1}
	m := int64(5)
	if w.RunPerson(&m) != 5 || w.RunPerson(nil) != 1 {
		t.Fatal("RunPerson")
	}
	d := int64(3)
	w.DefaultMemberID = &d
	if w.RunPerson(nil) != 3 {
		t.Fatal("RunPerson default member")
	}
}

func TestOrdered(t *testing.T) {
	all := Access{Modules: []string{ProviderClaude, ProviderCodex, ProviderMuse}}
	cases := []struct {
		order []string
		want  []string
	}{
		{nil, []string{ProviderClaude, ProviderCodex, ProviderMuse}},
		{[]string{ProviderMuse}, []string{ProviderMuse, ProviderClaude, ProviderCodex}},
		{[]string{ProviderMuse, ProviderCodex, ProviderClaude}, []string{ProviderMuse, ProviderCodex, ProviderClaude}},
		// A module the Admin took away is skipped; one added later goes last.
		{[]string{"gemini", ProviderClaude}, []string{ProviderClaude, ProviderCodex, ProviderMuse}},
		// Codex never ends up first, even when a stale order puts it there.
		{[]string{ProviderCodex, ProviderMuse}, []string{ProviderMuse, ProviderCodex, ProviderClaude}},
	}
	for _, c := range cases {
		if got := all.Ordered(c.order).Modules; !slices.Equal(got, c.want) {
			t.Errorf("Ordered(%v) = %v, want %v", c.order, got, c.want)
		}
	}
	if got := museOnly.Ordered([]string{ProviderClaude}).Modules; !slices.Equal(got, []string{ProviderMuse}) {
		t.Fatalf("an order cannot add a module: %v", got)
	}
	if err := ValidateOrder(all, []string{ProviderMuse, ProviderClaude}); err != nil {
		t.Fatal(err)
	}
	for _, bad := range [][]string{{ProviderCodex, ProviderClaude}, {ProviderMuse, ProviderMuse}, {"gemini"}} {
		if ValidateOrder(all, bad) == nil {
			t.Errorf("%v accepted", bad)
		}
	}
	if ValidateOrder(claudeCodex, []string{ProviderMuse}) == nil {
		t.Error("a module the person may not use was accepted")
	}
}
