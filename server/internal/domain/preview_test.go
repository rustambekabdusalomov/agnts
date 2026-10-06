package domain

import (
	"strings"
	"testing"
)

func TestPreviewNormalize(t *testing.T) {
	p := Preview{Summary: "  ok  ", Status: "weird", Shots: []Shot{
		{ID: "Home-Phone-After", File: "shots/home.png", Viewport: "PHONE", Side: ""},
		{ID: "home-phone-after", File: "shots/dup.png", Viewport: "phone"},
		{ID: "bad id", Viewport: "phone"},
		{ID: "tv", Viewport: "tv"},
		{ID: "esc", File: "shots/../../x.png", Viewport: "desktop"},
		{ID: "deep", File: "shots/a/b.png", Viewport: "desktop"},
	}, Issues: []PreviewIssue{
		{Severity: "low", Description: "a", ShotID: "home-phone-after"},
		{Severity: "", Description: "b", ShotID: "esc"},
		{Severity: "high", Description: " "},
		{Severity: "HIGH", Description: "c"},
	}}
	if !p.Normalize() {
		t.Fatal("rejected")
	}
	if p.Summary != "ok" || p.Status != PreviewPartial {
		t.Fatalf("summary/status: %q %q", p.Summary, p.Status)
	}
	if len(p.Shots) != 1 || p.Shots[0].ID != "home-phone-after" || p.Shots[0].Viewport != "phone" || p.Shots[0].Side != "after" || p.Shots[0].Name != "home-phone-after" {
		t.Fatalf("shots: %+v", p.Shots)
	}
	if len(p.Issues) != 3 || p.Issues[0].Severity != "high" || p.Issues[1].Severity != "medium" || p.Issues[1].ShotID != "" || p.Issues[2].ShotID != "home-phone-after" {
		t.Fatalf("issues: %+v", p.Issues)
	}
	if (&Preview{Summary: " "}).Normalize() {
		t.Fatal("empty summary accepted")
	}
}

func TestMatchUIPaths(t *testing.T) {
	files := []string{"server/main.go", "apps/admin/src/pages/TicketPage.vue"}
	cases := []struct {
		globs []string
		want  bool
	}{
		{nil, true},
		{[]string{"apps/admin/src/**/*.vue"}, true},
		{[]string{"**/*.{tsx,vue}"}, true},
		{[]string{"apps/admin/**"}, true},
		{[]string{"src/**/*.vue"}, false},
		{[]string{"**/*.css"}, false},
		{[]string{"server/*.go"}, true},
	}
	for _, c := range cases {
		if got := MatchUIPaths(files, c.globs); got != c.want {
			t.Errorf("%v: %v, want %v", c.globs, got, c.want)
		}
	}
	if MatchUIPaths(nil, nil) {
		t.Error("no files matched")
	}
}

func TestParseEnv(t *testing.T) {
	names, err := ParseEnv("# staging\nVITE_API_URL=https://x\n\nexport TOKEN = a=b\nVITE_API_URL=again\n")
	if err != nil || strings.Join(names, ",") != "VITE_API_URL,TOKEN" {
		t.Fatalf("%v %v", names, err)
	}
	for _, bad := range []string{"NOVALUE", "1X=2", "a b=c", strings.Repeat("A=1\n", MaxPreviewEnv)} {
		if _, err := ParseEnv(bad); err == nil {
			t.Errorf("%.20q accepted", bad)
		}
	}
}

func TestEgressAllowValidation(t *testing.T) {
	s := DefaultSettings()
	s.EgressAllow = []string{" staging.acme.com ", "*.acme.dev", "staging.acme.com"}
	if err := s.Validate(); err != nil || strings.Join(s.EgressAllow, ",") != "staging.acme.com,.acme.dev" {
		t.Fatalf("%v %v", s.EgressAllow, err)
	}
	for _, bad := range []string{"10.0.0.1", "localhost", "acme.com:8080", "agnts", "https://acme.com"} {
		s.EgressAllow = []string{bad}
		if err := s.Validate(); err == nil {
			t.Errorf("%q accepted", bad)
		}
	}
}
