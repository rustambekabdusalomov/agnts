package ai

import "testing"

func TestParseModel(t *testing.T) {
	for _, c := range []struct {
		in   string
		ref  ModelRef
		tier Tier
	}{
		{"opus", ModelRef{Claude, "opus"}, ""},
		{"muse:spark", ModelRef{Muse, "spark"}, ""},
		{"codex:gpt-5", ModelRef{Codex, "gpt-5"}, ""},
		{"auto", ModelRef{}, Auto},
		{"tier:strong", ModelRef{}, Strong},
		{"", ModelRef{}, ""},
	} {
		ref, tier := ParseModel(c.in)
		if ref != c.ref || tier != c.tier {
			t.Errorf("%q: got %+v %q, want %+v %q", c.in, ref, tier, c.ref, c.tier)
		}
		if c.tier == "" && ref.String() != c.in {
			t.Errorf("%q: String() = %q", c.in, ref.String())
		}
	}
}

func TestCaps(t *testing.T) {
	c := Caps{CapResume, CapEffort}
	if !c.Has(CapResume) || !c.Has(CapResume, CapEffort) || c.Has(CapAudio) {
		t.Fatal(c)
	}
}
