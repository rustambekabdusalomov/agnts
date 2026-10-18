package toolchain

import (
	"strings"
	"testing"
)

const privateGoMod = `module gitlab.iman.uz/iman-invest/gateway

go 1.22

require (
	github.com/stretchr/testify v1.9.0
	gitlab.iman.uz/core-service/grpc_contracts v1.0.0
	gitlab.iman.uz/iman-invest/protos v1.63.0 // indirect
)

require gitlab.iman.uz/iman-invest/protos v1.63.0
`

func TestHostOf(t *testing.T) {
	for in, want := range map[string]string{
		"https://gitlab.iman.uz/iman-invest/gateway.git":   "gitlab.iman.uz",
		"https://oauth2:x@GitLab.Corp.local:8443/a/b.git":  "gitlab.corp.local",
		"git@gitlab.iman.uz:iman-invest/gateway.git":       "gitlab.iman.uz",
		"ssh://git@gitlab.iman.uz/iman-invest/gateway.git": "gitlab.iman.uz",
		"": "",
	} {
		if got := HostOf(in); got != want {
			t.Errorf("HostOf(%q) = %q, want %q", in, got, want)
		}
	}
}

func TestPrivateNotes(t *testing.T) {
	files := tree(map[string]string{"go.mod": privateGoMod, "web/package.json": `{}`, "web/.npmrc": "@corp:registry=https://npm.corp.local/\nregistry=https://registry.npmjs.org/\n"})
	notes := strings.Join(DetectFor(files, Repo{GitHosts: []string{"gitlab.iman.uz"}}).Notes, "\n")
	for _, w := range []string{
		"private modules from gitlab.iman.uz (gitlab.iman.uz/core-service/grpc_contracts, gitlab.iman.uz/iman-invest/protos)",
		"GOPRIVATE=gitlab.iman.uz", "GIT_CONFIG_KEY_0=url.https://oauth2:<TOKEN>@gitlab.iman.uz/.insteadOf",
		".npmrc uses the registry npm.corp.local", "//npm.corp.local/:_authToken=${NPM_TOKEN}",
	} {
		if !strings.Contains(notes, w) {
			t.Errorf("notes lack %q:\n%s", w, notes)
		}
	}
	if strings.Contains(notes, "github.com/stretchr") || strings.Contains(notes, "registry.npmjs.org") {
		t.Errorf("public dependencies noted:\n%s", notes)
	}

	// Set up already: nothing to say.
	set := DetectFor(files, Repo{GitHosts: []string{"gitlab.iman.uz"}, EnvNames: []string{"GOPRIVATE", "GIT_CONFIG_COUNT", "NPM_TOKEN"}})
	for _, n := range set.Notes {
		if strings.Contains(n, "gitlab.iman.uz") || strings.Contains(n, "npm.corp.local") {
			t.Errorf("noted with the build environment set: %s", n)
		}
	}
	// Modules on a public host, or no host known: no note.
	for _, r := range []Repo{{GitHosts: []string{"github.com"}}, {}} {
		for _, n := range DetectFor(tree(map[string]string{"go.mod": privateGoMod}), r).Notes {
			if strings.Contains(n, "private modules") {
				t.Errorf("%v: %s", r, n)
			}
		}
	}
}
