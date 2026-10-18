package domain

import (
	"strings"
	"testing"
)

func TestCommitLine(t *testing.T) {
	const tmpl = "[{number}] {type}({scope}): {subject}"
	v := CommitVars{Number: "AMANAT-2288", Key: "VIS-3", Title: "Update protos", Kind: KindCode,
		Info: CommitInfo{Type: "Chore", Scope: "deps", Subject: "protos v1.63.0, drop local replace."}}
	for _, c := range []struct {
		name string
		tmpl string
		info CommitInfo
		want string
	}{
		{"agent's", tmpl, v.Info, "[AMANAT-2288] chore(deps): protos v1.63.0, drop local replace"},
		{"no scope", tmpl, CommitInfo{Type: "fix", Subject: "handle expired token"}, "[AMANAT-2288] fix: handle expired token"},
		{"nothing from the agent", tmpl, CommitInfo{}, "[AMANAT-2288] feat: Update protos"},
		{"made-up type", tmpl, CommitInfo{Type: "feature", Scope: "Auth Flow!", Subject: "x\ny"}, "[AMANAT-2288] feat(authflow): x"},
		{"key and title", "{key}: {title}", v.Info, "VIS-3: Update protos"},
	} {
		v := v
		v.Info = c.info
		if got := CommitLine(c.tmpl, v); got != c.want {
			t.Errorf("%s: %q, want %q", c.name, got, c.want)
		}
	}
}

func TestValidateCommitTemplate(t *testing.T) {
	for _, ok := range []string{"", "[{number}] {type}({scope}): {subject}", "{key}: {title}"} {
		if err := ValidateCommitTemplate(ok); err != nil {
			t.Errorf("%q: %v", ok, err)
		}
	}
	for _, bad := range []string{"[{number}] {type}", "{key}: {summary}", "{subject}\n\nbody"} {
		if err := ValidateCommitTemplate(bad); err == nil {
			t.Errorf("%q: want an error", bad)
		}
	}
}

func TestTicketNumber(t *testing.T) {
	if n := (Ticket{Key: "VIS-1"}).Number(); n != "VIS-1" {
		t.Errorf("fallback %q", n)
	}
	if n := (Ticket{Key: "VIS-1", TicketNumber: "AMANAT-2288"}).Number(); n != "AMANAT-2288" {
		t.Errorf("number %q", n)
	}
	for n, want := range map[string]bool{"AMANAT-2288": true, "1234": true, "v1.2_x": true, "": false, "-1": false, "A 1": false, "A/1": false} {
		if ValidTicketNumber(n) != want {
			t.Errorf("ValidTicketNumber(%q) != %v", n, want)
		}
	}
}

func TestCleanCommitMessage(t *testing.T) {
	for in, want := range map[string]string{
		"feat: x":                      "feat: x",
		"\n\nfeat: x  \r\n\r\nbody \n": "feat: x\n\nbody",
		"a\n\n\nb":                     "a\n\n\nb",
	} {
		if got, err := CleanCommitMessage(in); err != nil || got != want {
			t.Errorf("CleanCommitMessage(%q) = %q, %v; want %q", in, got, err, want)
		}
	}
	for _, bad := range []string{"", " \n \t\n", strings.Repeat("x", MaxCommitMessage+1)} {
		if _, err := CleanCommitMessage(bad); err == nil {
			t.Errorf("CleanCommitMessage(%.20q) took it", bad)
		}
	}
}
