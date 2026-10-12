package domain

import (
	"slices"
	"strings"
	"testing"
)

func TestNewRedFlagKinds(t *testing.T) {
	files := []FileChange{
		{Path: "pay/client.go", Add: 2, Diff: "@@ -1 +1,3 @@\n package pay\n+var key = \"AKIAIOSFODNN7ABCDEFG\"\n+var dsn = \"postgres://app:s3cretPassw0rd@db:5432/pay\"\n"},
		{Path: "pay/testdata/creds.go", Add: 1, Diff: "@@ -0,0 +1 @@\n+var key = \"AKIAIOSFODNN7ABCDEFG\"\n"},
		{Path: ".env", Add: 1, Diff: "diff --git a/.env b/.env\nnew file mode 100644\n@@ -0,0 +1 @@\n+API_KEY=abc\n"},
		{Path: ".env.example", Add: 1, Diff: "@@ -0,0 +1 @@\n+API_KEY=\n"},
		{Path: ".golangci.yml", Add: 1, Del: 1, Diff: "@@ -1 +1 @@\n-  - errcheck\n+  # - errcheck\n"},
		{Path: "web/src/App.vue", Add: 1, Diff: "@@ -1 +1,2 @@\n <script setup>\n+console.log('here', user)\n"},
		{Path: "scripts/release.mjs", Add: 1, Diff: "@@ -1 +1,2 @@\n x\n+console.log('released')\n"},
	}
	got := ScanRedFlags(files)
	kinds := map[string][]string{}
	for _, f := range got {
		kinds[f.Kind] = append(kinds[f.Kind], f.Path)
		if f.Kind == FlagSecret && (strings.Contains(f.Text, "IOSFODNN7ABCDEFG") || strings.Contains(f.Text, "s3cretPassw0rd")) {
			t.Errorf("secret shown in full: %q", f.Text)
		}
	}
	if !slices.Equal(kinds[FlagSecret], []string{"pay/client.go", "pay/client.go"}) {
		t.Errorf("secrets: %v", kinds[FlagSecret])
	}
	if !slices.Equal(kinds[FlagEnvFile], []string{".env"}) || !slices.Equal(kinds[FlagCheckConfig], []string{".golangci.yml"}) ||
		!slices.Equal(kinds[FlagDebug], []string{"web/src/App.vue"}) {
		t.Errorf("kinds: %v", kinds)
	}
	// A repository may allow example credentials in more places.
	if got := ScanRedFlags(files[:1], "pay/*.go"); len(got) != 0 {
		t.Errorf("allowed path still flagged: %+v", got)
	}
}

func TestAllowedFlags(t *testing.T) {
	got := AllowedFlags("Remove the legacy suite.\nagnts: allow deleted_test, skipped_test", "AGNTS: Allow check_config", "agnts: allow everything")
	if !slices.Equal(got, []string{FlagDeletedTest, FlagSkippedTest, FlagCheckConfig}) {
		t.Fatalf("got %v", got)
	}
}

func TestHarnessValidation(t *testing.T) {
	h := RepoHarness{GuardProfile: "loose", Coverage: CoverageConfig{Command: "go test -coverprofile=c.out ./...", Threshold: 120}}
	err := h.Validate()
	for _, want := range []string{"guard profile", "threshold", "report file"} {
		if err == nil || !strings.Contains(err.Error(), want) {
			t.Errorf("error %v lacks %q", err, want)
		}
	}
	g := GuardSettings{Disabled: []string{"pre:nope"}}
	if err := g.Validate(); err == nil || g.Profile != GuardStandard {
		t.Errorf("guard: %v %+v", err, g)
	}
}
