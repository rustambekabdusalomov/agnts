package domain

import (
	"strings"
	"testing"
)

func TestScanRedFlags(t *testing.T) {
	files := []FileChange{
		{Path: "refund/refund_test.go", Add: 3, Del: 4, Diff: strings.Join([]string{
			"diff --git a/refund/refund_test.go b/refund/refund_test.go",
			"--- a/refund/refund_test.go",
			"+++ b/refund/refund_test.go",
			"@@ -10,6 +10,5 @@ func TestRound(t *testing.T) {",
			" \tgot := Round(1.005)",
			"-\tif got != 1.01 {",
			"-\t\tt.Fatalf(\"got %v\", got)",
			"-\t}",
			"-\tassert.Equal(t, 2, Round(1.5))",
			"+\tt.Skip(\"flaky on CI\")",
			"+\t// TODO: put the check back",
			"+\t_ = got",
			" }",
		}, "\n")},
		{Path: "refund/refund.go", Add: 4, Del: 0, Diff: strings.Join([]string{
			"--- a/refund/refund.go",
			"+++ b/refund/refund.go",
			"@@ -1,2 +1,6 @@",
			" package refund",
			"+//nolint:gocyclo",
			"+func load() { if err != nil {} }",
			"+var todoList = \"TODO is a word here\"",
			"+func ok() {}",
		}, "\n")},
		{Path: "web/package.json", Add: 1, Diff: "@@ -5,3 +5,4 @@\n   \"dependencies\": {\n+    \"left-pad\": \"^1.3.0\",\n     \"vue\": \"^3.5.0\"\n"},
		{Path: "web/src/old.spec.ts", Add: 0, Del: 20, Diff: "diff --git a/web/src/old.spec.ts b/web/src/old.spec.ts\ndeleted file mode 100644\n--- a/web/src/old.spec.ts\n+++ /dev/null\n@@ -1,20 +0,0 @@\n-it('works', () => {})\n"},
		{Path: "README.md", Add: 1, Diff: "@@ -1 +1,2 @@\n # x\n+Install with npm.\n"},
	}
	got := ScanRedFlags(files)
	want := []struct {
		kind, path string
		line       int
	}{
		{FlagSkippedTest, "refund/refund_test.go", 11},
		{FlagTodo, "refund/refund_test.go", 12},
		{FlagRemovedAssert, "refund/refund_test.go", 0},
		{FlagSilencedLint, "refund/refund.go", 2},
		{FlagSwallowedError, "refund/refund.go", 3},
		{FlagNewDependency, "web/package.json", 6},
		{FlagDeletedTest, "web/src/old.spec.ts", 0},
	}
	if len(got) != len(want) {
		t.Fatalf("got %d flags: %+v", len(got), got)
	}
	for i, w := range want {
		if got[i].Kind != w.kind || got[i].Path != w.path || got[i].Line != w.line {
			t.Errorf("flag %d: got %+v, want %+v", i, got[i], w)
		}
	}
	if !strings.HasPrefix(got[2].Text, "2 fewer assertions") {
		t.Errorf("removed assertions text: %q", got[2].Text)
	}
	if len(ScanRedFlags(nil)) != 0 {
		t.Error("flags for no change")
	}
}

func TestIsTestFile(t *testing.T) {
	for p, want := range map[string]bool{
		"a/b_test.go": true, "src/x.spec.ts": true, "src/x.test.jsx": true, "tests/test_api.py": true, "pkg/api_test.py": true,
		"src/__tests__/x.js": true, "FooTest.java": true, "lib/x_spec.rb": true, "main.go": false, "testdata/in.json": false,
		"latest.go": false,
	} {
		if got := IsTestFile(p); got != want {
			t.Errorf("IsTestFile(%q) = %v", p, got)
		}
	}
}
