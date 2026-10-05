package admin

import (
	"strings"
	"testing"

	"hiro/internal/domain"
)

func TestValidateDerivesKind(t *testing.T) {
	cases := []struct {
		name, jira, prefix, wantKind, wantErr string
	}{
		{name: "side only", wantKind: "side"},
		{name: "jira and tasks", jira: " kan ", prefix: "mka", wantKind: "jira"},
		{name: "same prefix as jira key", jira: "MKA", prefix: "mka", wantErr: "task prefix must differ"},
		{name: "derived prefix clashes", jira: "MKAC", wantErr: "task prefix must differ"}, // name "mkacademy" → MKAC
		{name: "bad jira key", jira: "KA-N", wantErr: "jira project key"},
	}
	for _, c := range cases {
		t.Run(c.name, func(t *testing.T) {
			x := domain.Repository{Name: "mkacademy", Kind: "side", CloneURL: "https://github.com/me/mkacademy.git",
				JiraProject: c.jira, TaskPrefix: c.prefix}
			err := Validate(&x, "")
			if c.wantErr != "" {
				if err == nil || !strings.Contains(err.Error(), c.wantErr) {
					t.Fatalf("err = %v, want %q", err, c.wantErr)
				}
				return
			}
			if err != nil {
				t.Fatal(err)
			}
			if x.Kind != c.wantKind {
				t.Fatalf("kind = %q, want %q", x.Kind, c.wantKind)
			}
			if c.jira != "" && x.JiraProject != "KAN" {
				t.Fatalf("jira project = %q, want KAN", x.JiraProject)
			}
		})
	}
}
