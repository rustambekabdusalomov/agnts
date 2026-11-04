package domain

import (
	"slices"
	"strings"
	"testing"
	"time"
)

func sqliHit(id string, line int) SecHit {
	return SecHit{ID: id, Tool: ToolOpengrep, Source: SecFromCode, Rule: "agnts.go.sqli.formatted-query", Severity: SecMedium,
		Title: "SQL built with fmt.Sprintf", File: "handlers/orders.go", Line: line, CWE: "CWE-89", Category: "injection"}
}

func depHit(id string) SecHit {
	return SecHit{ID: id, Tool: ToolOSV, Source: SecFromDependency, Rule: "GHSA-35jh-r3h4-6jhm", Severity: SecHigh,
		Title: "lodash 4.17.20 has 4 known vulnerabilities", File: "package-lock.json", Ecosystem: "npm", Package: "lodash",
		Version: "4.17.20", FixedIn: "4.17.21", Category: "dependency"}
}

func symbolsOf(m map[string]string) func(string, int) string {
	return func(file string, _ int) string { return m[file] }
}

func allRan() SecRan {
	tools := map[string]SecToolRun{}
	for _, t := range SecTools {
		tools[t] = SecToolRun{Status: "ok"}
	}
	return SecRan{Tools: tools, Paths: []string{"."}, Agent: SecAgentDone}
}

func TestSecFingerprintStable(t *testing.T) {
	sym := symbolsOf(map[string]string{"handlers/orders.go": "Orders.Search"})
	a, _ := SecurityCandidates(1, SecScanResult{Hits: []SecHit{sqliHit("h1", 20)}, Symbol: sym})
	b, _ := SecurityCandidates(1, SecScanResult{Hits: []SecHit{sqliHit("h1", 31)}, Symbol: sym})
	if a[0].Fingerprint != b[0].Fingerprint {
		t.Fatal("a line shift changed the fingerprint")
	}
	// The agent words the same weakness differently: same finding.
	m := &SecurityManifest{Findings: []SecManifestFinding{{Title: "Orders search is injectable", CWE: "cwe-89",
		Location: SecLocation{File: "handlers/orders.go", Line: 22}, Severity: SecCritical}}}
	c, _ := SecurityCandidates(1, SecScanResult{Manifest: m, Symbol: sym})
	if c[0].Fingerprint != a[0].Fingerprint {
		t.Fatal("the agent's report of the same weakness got another identity than the tool's")
	}
	renamed, _ := SecurityCandidates(1, SecScanResult{Hits: []SecHit{sqliHit("h1", 20)},
		Symbol: symbolsOf(map[string]string{"handlers/orders.go": "Orders.Find"})})
	if renamed[0].Fingerprint == a[0].Fingerprint {
		t.Fatal("renaming the function kept the fingerprint")
	}
	other, _ := SecurityCandidates(2, SecScanResult{Hits: []SecHit{sqliHit("h1", 20)}, Symbol: sym})
	if other[0].Fingerprint == a[0].Fingerprint {
		t.Fatal("two repositories share a fingerprint")
	}
}

func TestSecurityCandidatesMergeAndTriage(t *testing.T) {
	taint := sqliHit("h2", 21)
	taint.Rule, taint.Severity = "agnts.go.sqli.request-into-query", SecHigh
	secret := SecHit{ID: "h3", Tool: ToolGitleaks, Source: SecFromSecret, Rule: "stripe-access-token", Severity: SecHigh,
		File: "docs/example.md", Line: 3, SecretHash: "abc", SecretMask: "sk_l****"}
	m := &SecurityManifest{
		Findings: []SecManifestFinding{{Hits: []string{"h1", "h2"}, Title: "SQL injection in /orders search", Severity: SecCritical,
			Confidence: SecConfirmed, Evidence: "q is concatenated", Fix: SecFix{Explanation: "use $1"}}},
		Rejected: []SecRejected{{Hit: "h3", Reason: "documentation example"}},
	}
	cands, rej := SecurityCandidates(1, SecScanResult{Hits: []SecHit{sqliHit("h1", 20), taint, secret, depHit("h4")}, Manifest: m,
		Symbol: symbolsOf(map[string]string{"handlers/orders.go": "Orders.Search"})})
	if len(rej) != 1 || rej[0].Rule != "stripe-access-token" || rej[0].File != "docs/example.md" {
		t.Fatalf("rejected = %+v", rej)
	}
	if len(cands) != 2 {
		t.Fatalf("want the injection and the untriaged dependency, got %d: %+v", len(cands), cands)
	}
	inj := cands[0]
	if inj.Severity != SecCritical || inj.Data.Confidence != SecConfirmed || len(inj.Data.Rules) != 2 || inj.Source != SecFromCode {
		t.Fatalf("injection = %+v", inj)
	}
	if cands[1].Source != SecFromDependency || cands[1].Data.Confidence != SecLikely {
		t.Fatalf("untriaged dependency = %+v", cands[1])
	}
}

func TestManifestNormalize(t *testing.T) {
	m := SecurityManifest{
		Findings: []SecManifestFinding{
			{Title: "ok", Severity: "HIGH", Location: SecLocation{File: "/workspace/a.go"}},
			{Title: "escape", Location: SecLocation{File: "../../etc/passwd"}},
			{Title: "unknown hit", Hits: []string{"h99"}, Severity: "weird", Confidence: "sure"},
			{Title: "", Hits: nil},
		},
		Rejected: []SecRejected{{Hit: "h1", Reason: "fp"}, {Hit: "h99"}},
		Known:    []SecKnownCheck{{FindingID: 7, Status: "gone"}, {FindingID: 8, Status: "gone"}, {FindingID: 7, Status: "present"}, {FindingID: 9, Status: "maybe"}},
	}
	m.Normalize(map[string]bool{"h1": true}, map[int64]bool{7: true, 9: true})
	if len(m.Findings) != 2 {
		t.Fatalf("findings = %+v", m.Findings)
	}
	if m.Findings[0].Severity != SecHigh || m.Findings[0].Location.File != "a.go" {
		t.Fatalf("first = %+v", m.Findings[0])
	}
	if f := m.Findings[1]; len(f.Hits) != 0 || f.Severity != "" || f.Confidence != "" {
		t.Fatalf("second = %+v", f)
	}
	if len(m.Rejected) != 1 {
		t.Fatalf("rejected = %+v", m.Rejected)
	}
	if len(m.Known) != 2 || m.Known[0].Status != KnownGone || m.Known[1].Status != KnownUnchecked {
		t.Fatalf("known = %+v", m.Known)
	}
	many := SecurityManifest{}
	for range 250 {
		many.Findings = append(many.Findings, SecManifestFinding{Title: "x", Evidence: strings.Repeat("e", 20000)})
	}
	many.Normalize(nil, nil)
	if len(many.Findings) != SecMaxFindings || len(many.Findings[0].Evidence) > secMaxText+4 {
		t.Fatalf("caps: %d findings, evidence %d", len(many.Findings), len(many.Findings[0].Evidence))
	}
}

// stored runs a scan over nothing stored and returns the findings as the
// store would keep them.
func stored(t *testing.T, res SecScanResult) []SecurityFinding {
	t.Helper()
	cands, _ := SecurityCandidates(1, res)
	out, counts := ReconcileSecurity(nil, cands, res, 1, time.Now())
	if counts.New != len(out) {
		t.Fatalf("counts = %+v", counts)
	}
	for i := range out {
		out[i].ID = int64(i + 1)
	}
	return out
}

func rescan(existing []SecurityFinding, res SecScanResult) ([]SecurityFinding, SecCounts) {
	cands, _ := SecurityCandidates(1, res)
	return ReconcileSecurity(existing, cands, res, 2, time.Now())
}

func byFile(fs []SecurityFinding, file string) SecurityFinding {
	for _, f := range fs {
		if f.Data.Location.File == file {
			return f
		}
	}
	return SecurityFinding{}
}

func TestReconcileClosesOnlyWhatRan(t *testing.T) {
	sym := symbolsOf(map[string]string{"handlers/orders.go": "Orders.Search", "api/users.go": "Users.Get"})
	agent := &SecurityManifest{Findings: []SecManifestFinding{{Title: "IDOR on users", CWE: "CWE-639",
		Location: SecLocation{File: "api/users.go", Line: 10}, Severity: SecHigh}}}
	first := stored(t, SecScanResult{Hits: []SecHit{sqliHit("h1", 20), depHit("h2")}, Manifest: agent, Ran: allRan(), Symbol: sym})
	if len(first) != 3 {
		t.Fatalf("first scan stored %d", len(first))
	}
	idor := byFile(first, "api/users.go")

	cases := []struct {
		name  string
		ran   func(*SecRan)
		known []SecKnownCheck
		fixed []string // files of the findings that must close
	}{
		{name: "everything ran and saw nothing", known: []SecKnownCheck{{FindingID: idor.ID, Status: KnownGone}},
			fixed: []string{"handlers/orders.go", "package-lock.json", "api/users.go"}},
		{name: "opengrep timed out", ran: func(r *SecRan) { r.Tools[ToolOpengrep] = SecToolRun{Status: "timeout"} },
			known: []SecKnownCheck{{FindingID: idor.ID, Status: KnownGone}}, fixed: []string{"package-lock.json", "api/users.go"}},
		{name: "the file is excluded now", ran: func(r *SecRan) { r.Excluded = []string{"handlers/**"} },
			fixed: []string{"package-lock.json"}},
		{name: "the agent hit its limit", ran: func(r *SecRan) { r.Agent = SecAgentLimit },
			known: []SecKnownCheck{{FindingID: idor.ID, Status: KnownGone}}, fixed: []string{"handlers/orders.go", "package-lock.json"}},
		{name: "the agent could not check", known: []SecKnownCheck{{FindingID: idor.ID, Status: KnownUnchecked}},
			fixed: []string{"handlers/orders.go", "package-lock.json"}},
		{name: "the agent did not mention it", fixed: []string{"handlers/orders.go", "package-lock.json"}},
		{name: "osv had no database", ran: func(r *SecRan) { r.Tools[ToolOSV] = SecToolRun{Status: "skipped"} },
			fixed: []string{"handlers/orders.go"}},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			ran := allRan()
			if tc.ran != nil {
				tc.ran(&ran)
			}
			existing := append([]SecurityFinding(nil), first...)
			m := &SecurityManifest{Known: tc.known}
			out, counts := rescan(existing, SecScanResult{Manifest: m, Ran: ran, Symbol: sym})
			var got []string
			for _, f := range out {
				if f.Status == SecFixed {
					got = append(got, f.Data.Location.File)
				}
			}
			slices.Sort(got)
			slices.Sort(tc.fixed)
			if strings.Join(got, ",") != strings.Join(tc.fixed, ",") {
				t.Fatalf("fixed = %v, want %v", got, tc.fixed)
			}
			if counts.Fixed != len(tc.fixed) || counts.Unchecked != 3-len(tc.fixed) {
				t.Fatalf("counts = %+v", counts)
			}
		})
	}
}

func TestReconcileLifecycle(t *testing.T) {
	sym := symbolsOf(map[string]string{"handlers/orders.go": "Orders.Search"})
	first := stored(t, SecScanResult{Hits: []SecHit{sqliHit("h1", 20)}, Ran: allRan(), Symbol: sym})

	// Unchanged rescans, worded differently: nothing new, nothing fixed.
	for i := range 3 {
		m := &SecurityManifest{Findings: []SecManifestFinding{{Hits: []string{"h1"}, Title: strings.Repeat("SQL injection ", i+1)}}}
		out, counts := rescan(first, SecScanResult{Hits: []SecHit{sqliHit("h1", 20+i)}, Manifest: m, Ran: allRan(), Symbol: sym})
		if counts.New != 0 || counts.Fixed != 0 || counts.Seen != 1 || len(out) != 1 {
			t.Fatalf("rescan %d: %+v", i, counts)
		}
	}

	// Fixed, then back: reopened and worth a notification.
	fixed, _ := rescan(append([]SecurityFinding(nil), first...), SecScanResult{Ran: allRan(), Symbol: sym})
	if fixed[0].Status != SecFixed {
		t.Fatalf("status = %s", fixed[0].Status)
	}
	back, counts := rescan(fixed, SecScanResult{Hits: []SecHit{sqliHit("h1", 20)}, Ran: allRan(), Symbol: sym})
	if back[0].Status != SecReopened || counts.Reopened != 1 || counts.Notify != 0 {
		t.Fatalf("reopened: %s %+v", back[0].Status, counts) // medium does not notify
	}

	// Dismissed stays dismissed while the tool sees it, and is never closed.
	dis := append([]SecurityFinding(nil), first...)
	dis[0].Status = SecDismissed
	out, _ := rescan(dis, SecScanResult{Hits: []SecHit{sqliHit("h1", 20)}, Ran: allRan(), Symbol: sym})
	if out[0].Status != SecDismissed {
		t.Fatalf("dismissed became %s", out[0].Status)
	}
	if out, _ := rescan(dis, SecScanResult{Ran: allRan(), Symbol: sym}); len(out) != 0 {
		t.Fatalf("a dismissed finding changed: %+v", out)
	}

	// A rejected hit keeps its finding: the tool still sees it.
	m := &SecurityManifest{Rejected: []SecRejected{{Hit: "h1", Reason: "fp"}}}
	m.Normalize(map[string]bool{"h1": true}, nil)
	out, counts = rescan(append([]SecurityFinding(nil), first...), SecScanResult{Hits: []SecHit{sqliHit("h1", 20)}, Manifest: m, Ran: allRan(), Symbol: sym})
	if len(out) != 1 || out[0].Status != SecOpen || counts.Fixed != 0 {
		t.Fatalf("rejected hit: %+v %+v", out, counts)
	}
}

func TestReconcileVerifyScope(t *testing.T) {
	sym := symbolsOf(map[string]string{"handlers/orders.go": "Orders.Search"})
	first := stored(t, SecScanResult{Hits: []SecHit{sqliHit("h1", 20), depHit("h2")}, Ran: allRan(), Symbol: sym})
	inj := byFile(first, "handlers/orders.go")
	for i := range first {
		first[i].Status = SecVerifying
	}
	// Only the injection is verified: the dependency is left alone even
	// though osv no longer reports it, and a new hit is not recorded.
	newHit := sqliHit("h9", 5)
	newHit.File = "other.go"
	out, counts := rescan(first, SecScanResult{Hits: []SecHit{newHit}, Ran: allRan(), Symbol: sym, Scope: SecScope{FindingIDs: []int64{inj.ID}}})
	if len(out) != 1 || out[0].ID != inj.ID || out[0].Status != SecFixed || counts.New != 0 {
		t.Fatalf("verify: %+v %+v", out, counts)
	}
	// Still there after the fix merged: back to open, ticket kept.
	first[0].TicketKey = "SEC-1"
	out, _ = rescan(first, SecScanResult{Hits: []SecHit{sqliHit("h1", 20)}, Ran: allRan(), Symbol: sym, Scope: SecScope{FindingIDs: []int64{inj.ID}}})
	if out[0].Status != SecOpen || out[0].TicketKey != "SEC-1" {
		t.Fatalf("still there: %+v", out[0])
	}
}

func TestReconcileLooseMatchAndHistory(t *testing.T) {
	sym := symbolsOf(map[string]string{"api/users.go": "Users.Get"})
	agent := func(line int) *SecurityManifest {
		return &SecurityManifest{Findings: []SecManifestFinding{{Title: "IDOR", CWE: "CWE-639", Location: SecLocation{File: "api/users.go", Line: line}}}}
	}
	first := stored(t, SecScanResult{Manifest: agent(10), Ran: allRan(), Symbol: sym})
	// The model's line moved into another function: still the same finding.
	moved := symbolsOf(map[string]string{"api/users.go": "Users.List"})
	out, counts := rescan(first, SecScanResult{Manifest: agent(40), Ran: allRan(), Symbol: moved})
	if counts.New != 0 || counts.Seen != 1 || !strings.Contains(out[0].Data.Note, "api/users.go:40") {
		t.Fatalf("loose match: %+v %+v", counts, out)
	}

	hist := SecHit{ID: "h1", Tool: ToolGitleaks, Source: SecFromHistory, Rule: "stripe-access-token", Severity: SecHigh, SecretHash: "x", Commit: "abc"}
	h := stored(t, SecScanResult{Hits: []SecHit{hist}, Ran: allRan()})
	if out, counts := rescan(h, SecScanResult{Ran: allRan()}); len(out) != 0 || counts.Unchecked != 1 {
		t.Fatalf("a history secret closed by itself: %+v %+v", out, counts)
	}
}

func TestSecExcludedAndCovers(t *testing.T) {
	for _, tc := range []struct {
		file string
		pats []string
		want bool
	}{
		{"web/node_modules/x/a.js", SecDefaultExclude, true},
		{"static/app.min.js", SecDefaultExclude, true},
		{"handlers/orders.go", SecDefaultExclude, false},
		{"testdata/x.go", []string{"testdata/**"}, true},
		{"a/testdata/x.go", []string{"testdata/**"}, false},
		{"a/testdata/x.go", []string{"testdata"}, true},
	} {
		if got := SecExcluded(tc.file, tc.pats); got != tc.want {
			t.Errorf("SecExcluded(%q, %v) = %v", tc.file, tc.pats, got)
		}
	}
	r := SecRan{Paths: []string{"api"}}
	if !r.Covers("api/x.go") || r.Covers("web/x.go") || r.Covers("apix/y.go") {
		t.Fatal("Covers")
	}
}

func TestNormalizeRoute(t *testing.T) {
	for in, want := range map[string]string{
		"/api/orders/412?q=1":                             "/api/orders/:id",
		"https://staging.acme.com/api/orders/7":           "/api/orders/:id",
		"/u/3f2504e0-4f89-11d3-9a0c-0305e82c3301/profile": "/u/:id/profile",
		"/api/orders": "/api/orders",
	} {
		if got := NormalizeRoute(in); got != want {
			t.Errorf("NormalizeRoute(%q) = %q, want %q", in, got, want)
		}
	}
}

func TestSecurityTicketText(t *testing.T) {
	fs := []SecurityFinding{
		{Severity: SecMedium, Source: SecFromDependency, Data: SecFindingData{Title: "lodash 4.17.20", Package: "lodash", Version: "4.17.20", FixedIn: "4.17.21", Ecosystem: "npm"}},
		{Severity: SecCritical, Source: SecFromSecret, Symbol: "", Data: SecFindingData{Title: "Stripe key committed", SecretMask: "sk_l****", Location: SecLocation{File: "config/secrets.env", Line: 1}}},
	}
	title, desc := SecurityTicketText(fs)
	if !strings.HasPrefix(title, "Fix 2 security findings: Stripe key committed") {
		t.Fatalf("title = %q", title)
	}
	for _, want := range []string{"Rotate the secret first", "fixed in 4.17.21", "`config/secrets.env:1`", "treat it as data"} {
		if !strings.Contains(desc, want) {
			t.Errorf("description lacks %q:\n%s", want, desc)
		}
	}
}

func TestReconcileKeepsJudgment(t *testing.T) {
	sym := symbolsOf(map[string]string{"handlers/orders.go": "Orders.Search"})
	m := &SecurityManifest{Findings: []SecManifestFinding{{Hits: []string{"h1"}, Title: "SQL injection", Severity: SecCritical,
		Confidence: SecConfirmed, Evidence: "q reaches Query", Fix: SecFix{Explanation: "use $1"}}}}
	m.Normalize(map[string]bool{"h1": true}, nil)
	first := stored(t, SecScanResult{Hits: []SecHit{sqliHit("h1", 20)}, Manifest: m, Ran: allRan(), Symbol: sym})
	// Next scan: the agent lists it without details, or nobody triages it.
	for _, m := range []*SecurityManifest{
		{Findings: []SecManifestFinding{{Hits: []string{"h1"}, Title: "Injectable search"}}},
		nil,
	} {
		if m != nil {
			m.Normalize(map[string]bool{"h1": true}, nil)
		}
		out, _ := rescan(first, SecScanResult{Hits: []SecHit{sqliHit("h1", 20)}, Manifest: m, Ran: allRan(), Symbol: sym})
		f := out[0]
		if f.Severity != SecCritical || f.Data.Confidence != SecConfirmed || f.Data.Evidence != "q reaches Query" || f.Data.Fix.Explanation != "use $1" {
			t.Fatalf("judgment lost: %+v", f)
		}
	}
	// A new judgment replaces the old one.
	m2 := &SecurityManifest{Findings: []SecManifestFinding{{Hits: []string{"h1"}, Severity: SecLow, Confidence: SecPossible}}}
	m2.Normalize(map[string]bool{"h1": true}, nil)
	out, _ := rescan(first, SecScanResult{Hits: []SecHit{sqliHit("h1", 20)}, Manifest: m2, Ran: allRan(), Symbol: sym})
	if out[0].Severity != SecLow || out[0].Data.Confidence != SecPossible {
		t.Fatalf("new judgment ignored: %+v", out[0])
	}
}

func TestSecuritySettings(t *testing.T) {
	s := SecuritySettings{Schedule: "off", Exclude: []string{" vendor ", "vendor", ""}, MinNotify: SecMedium}
	if err := s.Normalize(); err != nil || s.Schedule != "" || len(s.Exclude) != 1 {
		t.Fatalf("normalize: %+v %v", s, err)
	}
	for _, bad := range []SecuritySettings{{Schedule: "hourly"}, {MinNotify: "urgent"}, {Exclude: []string{"../etc"}}, {Exclude: []string{"/abs"}}} {
		if err := bad.Normalize(); err == nil {
			t.Errorf("accepted %+v", bad)
		}
	}
	if (SecuritySettings{}).NotifyAt() != SecHigh || s.NotifyAt() != SecMedium {
		t.Fatal("NotifyAt")
	}
	now := time.Date(2026, 11, 4, 10, 0, 0, 0, time.UTC)
	if (SecuritySettings{}).NextScan(1, now) != nil {
		t.Fatal("off has a next scan")
	}
	d := SecuritySettings{Schedule: SecScheduleDaily}.NextScan(5, now)
	if d == nil || !d.Equal(time.Date(2026, 11, 5, 3, 5, 0, 0, time.UTC)) {
		t.Fatalf("daily = %v", d)
	}
	early := time.Date(2026, 11, 4, 1, 0, 0, 0, time.UTC)
	if d := (SecuritySettings{Schedule: SecScheduleDaily}).NextScan(5, early); !d.Equal(time.Date(2026, 11, 4, 3, 5, 0, 0, time.UTC)) {
		t.Fatalf("daily before 3am = %v", d)
	}
	if w := (SecuritySettings{Schedule: SecScheduleWeekly}).NextScan(5, now); !w.Equal(time.Date(2026, 11, 11, 3, 5, 0, 0, time.UTC)) {
		t.Fatalf("weekly = %v", w)
	}
}

func TestReconcileMinNotify(t *testing.T) {
	hit := sqliHit("h1", 20) // medium
	res := SecScanResult{Hits: []SecHit{hit}, Ran: allRan()}
	cands, _ := SecurityCandidates(1, res)
	if _, c := ReconcileSecurity(nil, cands, res, 1, time.Now()); c.Notify != 0 {
		t.Fatalf("medium notified at the default (high): %+v", c)
	}
	res.MinNotify = SecMedium
	if _, c := ReconcileSecurity(nil, cands, res, 1, time.Now()); c.Notify != 1 {
		t.Fatalf("medium did not notify at medium: %+v", c)
	}
}
