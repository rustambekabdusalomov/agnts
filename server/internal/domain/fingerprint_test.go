package domain

import (
	"regexp"
	"strings"
	"testing"
)

const goFail1 = `2026-10-12T09:14:02.1234567Z ##[group]Run go test ./...
2026-10-12T09:14:10.0000000Z ok  	acme/api/auth	0.412s
2026-10-12T09:14:11.0000000Z --- FAIL: TestApplyCoupon (0.01s)
2026-10-12T09:14:11.0000000Z     billing_test.go:42: expected 90, got 100
2026-10-12T09:14:11.0000000Z FAIL
2026-10-12T09:14:11.0000000Z FAIL	acme/api/billing	0.233s
2026-10-12T09:14:11.0000000Z ##[error]Process completed with exit code 1.`

// The same failure on another commit: other times, durations and line.
const goFail2 = `2026-10-13T11:00:00.0000000Z ##[group]Run go test ./...
2026-10-13T11:00:05.0000000Z ok  	acme/api/auth	0.398s
2026-10-13T11:00:06.0000000Z --- FAIL: TestApplyCoupon (0.02s)
2026-10-13T11:00:06.0000000Z     billing_test.go:47: expected 90, got 100
2026-10-13T11:00:06.0000000Z FAIL
2026-10-13T11:00:06.0000000Z FAIL	acme/api/billing	0.301s
2026-10-13T11:00:06.0000000Z ##[error]Process completed with exit code 1.`

const goFailOther = `--- FAIL: TestRefund (0.01s)
    refund_test.go:12: refund not recorded
FAIL`

const pytestFail = `============================= test session starts ==============================
collected 12 items

tests/test_money.py ..F.

=================================== FAILURES ===================================
_______________________________ test_round_half _______________________________

    def test_round_half():
>       assert round_half(Decimal("2.5")) == 3
E       AssertionError: assert Decimal('2') == 3

tests/test_money.py:14: AssertionError
=========================== short test summary info ============================
FAILED tests/test_money.py::test_round_half - AssertionError: assert Decimal('2') == 3
========================= 1 failed, 11 passed in 0.31s =========================`

const jestFail = `PASS src/lib/date.test.ts
FAIL src/lib/money.test.ts
  ● formatMoney › rounds half up

    expect(received).toBe(expected) // Object.is equality

    Expected: "2.50"
    Received: "2.5"

      at Object.<anonymous> (src/lib/money.test.ts:8:31)

Tests:       1 failed, 14 passed, 15 total`

const tscFail = `> web@1.0.0 build
> vue-tsc --noEmit && vite build

src/pages/Cart.vue(12,8): error TS2307: Cannot find module '@/lib/money' or its corresponding type declarations.
 ELIFECYCLE  Command failed with exit code 2.`

func TestFingerprintStableAcrossRuns(t *testing.T) {
	a := Fingerprint("test", CleanLog(goFail1))
	b := Fingerprint("test", CleanLog(goFail2))
	if a != b {
		t.Fatalf("same failure, different fingerprints: %s %s", a, b)
	}
	if c := Fingerprint("test", CleanLog(goFailOther)); c == a {
		t.Fatal("different tests share a fingerprint")
	}
	if d := Fingerprint("lint", CleanLog(goFail1)); d == a {
		t.Fatal("the job should be part of the fingerprint")
	}
}

func TestFailingTests(t *testing.T) {
	for name, tc := range map[string]struct {
		log  string
		want string
	}{
		"go":     {goFail1, "TestApplyCoupon"},
		"pytest": {pytestFail, "tests/test_money.py::test_round_half"},
		"jest":   {jestFail, "src/lib/money.test.ts"},
	} {
		got := FailingTests(CleanLog(tc.log))
		if len(got) == 0 || got[0] != tc.want {
			t.Errorf("%s: failing tests %q, want first %q", name, got, tc.want)
		}
	}
}

func TestFirstErrorBlockAndTitle(t *testing.T) {
	lines := CleanLog(goFail1)
	if got := FailureTitle(lines); got != "TestApplyCoupon: billing_test.go:42: expected 90, got 100" {
		t.Errorf("go title %q", got)
	}
	if got := FailureTitle(CleanLog(tscFail)); !strings.Contains(got, "error TS2307: Cannot find module '@/lib/money'") {
		t.Errorf("tsc title %q", got)
	}
	if b := FirstErrorBlock(CleanLog(pytestFail)); len(b) == 0 || !strings.HasPrefix(b[0], "FAILED tests/test_money.py") {
		t.Errorf("pytest block %q", b)
	}
	if ex := Excerpt(lines); !strings.Contains(ex, "=== first error ===\n--- FAIL: TestApplyCoupon") {
		t.Errorf("excerpt does not start with the error block:\n%s", ex)
	}
}

func TestCleanLog(t *testing.T) {
	got := CleanLog("2026-10-12T09:14:11.0000000Z \x1b[31mred\x1b[0m\nprogress 10%\rprogress 100%\n\n")
	if len(got) != 2 || got[0] != "red" || got[1] != "progress 100%" {
		t.Fatalf("CleanLog = %q", got)
	}
}

func TestExcerptCap(t *testing.T) {
	lines := make([]string, 5000)
	for i := range lines {
		lines[i] = strings.Repeat("x", 200)
	}
	if n := len(Excerpt(lines)); n > ExcerptMaxBytes+10 {
		t.Fatalf("excerpt is %d bytes", n)
	}
}

func TestRedact(t *testing.T) {
	in := strings.Join([]string{
		"Authorization: Bearer abcdefghijklmnopqrstuvwxyz012345",
		"connecting to postgres://app:s3cr3t@db:5432/app",
		"token ghp_abcdefghijklmnopqrstuvwxyz0123456789",
		"API_KEY=sk-livelivelivelivelivelive1234",
		"sent to dev@example.com",
		"jwt eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMjM0NTY3ODkwIn0.dozjgNryP4J3jVmNHl0w5N_XgL0n3I9PlFUP0THsR8U",
	}, "\n")
	out := Redact(in)
	for _, secret := range []string{"abcdefghijklmnopqrstuvwxyz012345", "s3cr3t", "ghp_abc", "sk-live", "dev@example.com", "eyJzdWIi"} {
		if strings.Contains(out, secret) {
			t.Errorf("%q survived redaction:\n%s", secret, out)
		}
	}
	if !strings.Contains(out, "postgres://[user]:[password]@db:5432/app") {
		t.Errorf("URL credentials not replaced in place:\n%s", out)
	}
}

func TestInfraMatch(t *testing.T) {
	runnerLost := "Run make test\nThe runner has received a shutdown signal. This can happen when the runner service is stopped.\n##[error]The operation was canceled."
	if l, ok := InfraMatch(CleanLog(runnerLost), nil); !ok || l == "" {
		t.Errorf("runner lost not infra: %q %v", l, ok)
	}
	if _, ok := InfraMatch(CleanLog(goFail1), nil); ok {
		t.Error("a failing test is not infra")
	}
	extra := []*regexp.Regexp{regexp.MustCompile(`(?i)license server unreachable`)}
	if _, ok := InfraMatch(CleanLog("error: License server unreachable"), extra); !ok {
		t.Error("extra pattern not used")
	}
}

func TestCIWatch(t *testing.T) {
	w := DefaultCIWatch(1)
	w.Branches = []string{" release/* ", "release/*", ""}
	if err := w.Normalize(); err != nil {
		t.Fatal(err)
	}
	if len(w.Branches) != 1 {
		t.Fatalf("branches %q", w.Branches)
	}
	if !w.WatchesBranch("main", "main") || !w.WatchesBranch("release/1.2", "main") || w.WatchesBranch("feature/x", "main") {
		t.Error("WatchesBranch")
	}
	if !w.Ignores("Deploy to production") || w.Ignores("test") {
		t.Error("Ignores")
	}
	w.PRs = "push"
	if w.Normalize() == nil {
		t.Error("bad PR mode accepted")
	}
}

func TestCISettingsValidate(t *testing.T) {
	c := DefaultCISettings()
	c.InfraPatterns = []string{"ok", "(", " ok "}
	if err := c.Validate(); err == nil {
		t.Fatal("bad regexp accepted")
	}
	c.InfraPatterns = []string{"ok", " ok "}
	if err := c.Validate(); err != nil || len(c.InfraPatterns) != 1 {
		t.Fatalf("validate: %v %q", err, c.InfraPatterns)
	}
}
