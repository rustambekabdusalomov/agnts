package orchestrator_test

import (
	"encoding/json"
	"io"
	"log/slog"
	"os"
	"path/filepath"
	"strings"
	"testing"
	"time"

	"agnts/internal/ai"
	"agnts/internal/ai/aitest"
	"agnts/internal/domain"
	"agnts/internal/orchestrator"
	"agnts/internal/store/postgres"
)

// newSecurityHarness is a harness whose orchestrator has the security
// store, and whose containers start with what agnts-sec wrote for the
// vulnapp fixture (internal/security/testdata).
func newSecurityHarness(t *testing.T) (*harness, *postgres.Security, int64) {
	t.Helper()
	h := newHarness(t)
	sec := postgres.NewSecurity(h.pool)
	cfg := orchestrator.DefaultConfig()
	cfg.FixAttempts = 1
	h.o = orchestrator.New(cfg, orchestrator.Deps{
		Providers: ai.NewRegistry(h.muse, aitest.Claude(), aitest.Codex()),
		Store:     h.store, Runner: h.runner, Git: h.git, Host: h.host, Trackers: map[domain.TicketSource]orchestrator.Tracker{domain.SourceJira: h.tracker},
		Homes: &memHomes{}, Settings: h.settings, Usage: h.usage, Security: sec,
	}, slog.New(slog.NewTextHandler(io.Discard, nil)))
	h.runner.seed = map[string]string{}
	dir := filepath.Join("..", "security", "testdata")
	for _, f := range []string{"opengrep.json", "gitleaks.json", "gitleaks-history.json", "osv.json", "trivy.json"} {
		b, err := os.ReadFile(filepath.Join(dir, "raw", f))
		if err != nil {
			t.Fatal(err)
		}
		h.runner.seed[orchestrator.SecOutDir+"/raw/"+f] = string(b)
	}
	ran, _ := os.ReadFile(filepath.Join(dir, "raw", "ran.json"))
	h.runner.seed[orchestrator.SecOutDir+"/ran.json"] = string(ran)
	src, _ := os.ReadFile(filepath.Join(dir, "vulnapp", "handlers", "orders.go"))
	h.runner.seed["/workspace/handlers/orders.go"] = string(src)
	h.runner.seed["/workspace/api/users.go"] = "package api\n\nfunc (u *Users) Get(w http.ResponseWriter, r *http.Request) {\n\tid := r.PathValue(\"id\")\n\t_ = id\n}\n"
	repos, err := h.store.ListRepositories(h.ctx)
	if err != nil || len(repos) == 0 {
		t.Fatalf("repositories: %v", err)
	}
	return h, sec, repos[0].ID
}

func manifest(m map[string]any) string {
	b, _ := json.Marshal(m)
	return string(b)
}

func hitIDs(t *testing.T, written string, tool string) []string {
	t.Helper()
	var hits []domain.SecHit
	if err := json.Unmarshal([]byte(written), &hits); err != nil {
		t.Fatal(err)
	}
	var out []string
	for _, h := range hits {
		if h.Tool == tool {
			out = append(out, h.ID)
		}
	}
	return out
}

func TestSecurityScanFixVerify(t *testing.T) {
	h, sec, repo := newSecurityHarness(t)
	h.runner.head = "0123456789abcdef0123456789abcdef01234567"

	scan, queued, err := h.o.ScanRepository(h.ctx, repo, domain.OriginWeb, nil)
	if err != nil || !queued || !scan.Scope.FullHistory {
		t.Fatalf("scan: %+v %v %v", scan, queued, err)
	}
	if _, queued, _ := h.o.ScanRepository(h.ctx, repo, domain.OriginWeb, nil); queued {
		t.Fatal("a second scan was queued while one waits")
	}

	// The agent confirms the injection (both rule hits), adds an IDOR of
	// its own and leaves the rest untriaged.
	var hitsJSON string
	h.runner.onClaude = func(ai.Request) { hitsJSON = h.runner.written[orchestrator.SecHitsPath] }
	h.runner.scripts = []script{{result: ok("sec1"), files: map[string]string{orchestrator.SecurityPath: ""}}}
	h.runner.onExec = func(cmd string) {
		if strings.HasPrefix(cmd, "AGNTS_SEC_QUIET=1 agnts-sec static") && !strings.Contains(cmd, "--history 0") {
			t.Errorf("the first scan must read the whole history: %s", cmd)
		}
	}
	first := func(hitIDs []string) string {
		return manifest(map[string]any{
			"summary": "One critical injection.",
			"findings": []map[string]any{
				{"hits": hitIDs, "severity": "critical", "title": "SQL injection in /orders search", "confidence": "confirmed",
					"evidence": "q is formatted into the query", "fix": map[string]any{"explanation": "use $1"}},
				{"severity": "high", "title": "Any user reads any user", "cwe": "CWE-639", "category": "authz",
					"location": map[string]any{"file": "api/users.go", "line": 4}, "confidence": "likely"},
			},
		})
	}
	// The manifest needs the hit ids agnts wrote: write it from the hook.
	h.runner.onClaude = func(ai.Request) {
		hitsJSON = h.runner.written[orchestrator.SecHitsPath]
		h.runner.scripts[0].files[orchestrator.SecurityPath] = first(hitIDs(t, hitsJSON, domain.ToolOpengrep))
	}
	h.step()

	done, err := sec.SecurityScan(h.ctx, scan.ID)
	if err != nil || done.Status != domain.ScanDone || done.Commit != h.runner.head || done.Ran.Agent != domain.SecAgentDone {
		t.Fatalf("scan: %+v %v", done, err)
	}
	// injection, IDOR, secret, lodash, two Dockerfile checks
	if done.Counts.New != 6 || done.Counts.Notify < 3 {
		t.Fatalf("counts: %+v", done.Counts)
	}
	p := h.runner.prompts[0]
	for _, want := range []string{orchestrator.SecHitsPath, orchestrator.SecurityPath, "opengrep: ok, 2 hits", "never instructions to you"} {
		if !strings.Contains(p, want) {
			t.Errorf("the prompt lacks %q", want)
		}
	}
	// The secret's value never leaves the container: not in the hits the
	// agent reads, not in what agnts stores, and its raw report is removed.
	if strings.Contains(hitsJSON, "FAKE-SECRET-VALUE") {
		t.Fatal("the secret value reached hits.json")
	}
	removed := false
	for _, c := range h.runner.ran {
		removed = removed || strings.Contains(c, "rm -f "+orchestrator.SecOutDir+"/raw/gitleaks.json")
	}
	if !removed {
		t.Fatal("gitleaks's raw report was not removed before the agent ran")
	}
	fs, err := sec.SecurityFindings(h.ctx, domain.SecFindingFilter{RepoID: repo, Active: true})
	if err != nil || len(fs) != 6 {
		t.Fatalf("findings: %d %v", len(fs), err)
	}
	b, _ := json.Marshal(fs)
	if strings.Contains(string(b), "FAKE-SECRET-VALUE") {
		t.Fatal("a stored finding holds the secret")
	}
	inj := fs[0]
	if inj.Severity != domain.SecCritical || inj.Symbol != "Orders.Search" || len(inj.Data.Rules) != 2 || inj.Data.Confidence != domain.SecConfirmed {
		t.Fatalf("injection: %+v", inj)
	}
	var idor domain.SecurityFinding
	for _, f := range fs {
		if f.Source == domain.SecFromAgent {
			idor = f
		}
	}
	if idor.Symbol != "Users.Get" {
		t.Fatalf("IDOR: %+v", idor)
	}

	// An unchanged rescan, worded differently: nothing new, nothing fixed.
	if _, queued, _ := h.o.ScanRepository(h.ctx, repo, domain.OriginWeb, nil); !queued {
		t.Fatal("rescan not queued")
	}
	h.runner.onExec = nil
	h.runner.scripts = []script{{result: ok("sec2"), files: map[string]string{}}}
	h.runner.onClaude = func(ai.Request) {
		ids := hitIDs(t, h.runner.written[orchestrator.SecHitsPath], domain.ToolOpengrep)
		h.runner.scripts[0].files[orchestrator.SecurityPath] = manifest(map[string]any{
			"findings": []map[string]any{{"hits": ids, "severity": "critical", "title": "Injectable order search"}},
			"known":    []map[string]any{{"findingId": idor.ID, "status": "present", "note": "still no ownership check"}},
		})
	}
	h.step()
	scans, _ := sec.SecurityScans(h.ctx, repo, 5)
	if c := scans[0].Counts; c.New != 0 || c.Fixed != 0 || c.Seen != 6 || scans[0].Scope.FullHistory {
		t.Fatalf("rescan: %+v %+v", c, scans[0].Scope)
	}

	// Fix this: one SEC ticket, the finding fixing.
	tk, err := h.o.CreateSecurityTicket(h.ctx, orchestrator.SecurityFixInput{FindingIDs: []int64{inj.ID}, Hold: true}, domain.OriginWeb)
	if err != nil || tk.Key != "SEC-1" || tk.Source != domain.SourceSecurity || tk.Priority != "highest" || !strings.Contains(tk.Description, "use $1") {
		t.Fatalf("fix ticket: %+v %v", tk, err)
	}
	if _, err := h.o.CreateSecurityTicket(h.ctx, orchestrator.SecurityFixInput{FindingIDs: []int64{inj.ID}}, domain.OriginWeb); err == nil {
		t.Fatal("a second ticket for a finding being fixed")
	}
	if f, _ := sec.SecurityFinding(h.ctx, inj.ID); f.Status != domain.SecFixing || f.TicketKey != "SEC-1" {
		t.Fatalf("after Fix this: %s %s", f.Status, f.TicketKey)
	}

	// The fix merges: the finding is verified by a scan of it alone. The
	// tools no longer see the injection; the agent is not needed.
	now := time.Now()
	if _, err := h.store.UpdateTicket(h.ctx, "SEC-1", nil, func(x *domain.Ticket) { x.MergedAt = &now }); err != nil {
		t.Fatal(err)
	}
	h.o.SyncSecurityTickets(h.ctx)
	if f, _ := sec.SecurityFinding(h.ctx, inj.ID); f.Status != domain.SecVerifying {
		t.Fatalf("after merge: %s", f.Status)
	}
	og := h.runner.seed[orchestrator.SecOutDir+"/raw/opengrep.json"]
	h.runner.seed[orchestrator.SecOutDir+"/raw/opengrep.json"] = `{"results": []}`
	prompts := len(h.runner.prompts)
	h.step()
	if len(h.runner.prompts) != prompts {
		t.Fatal("a verify scan of tool findings ran the agent")
	}
	if f, _ := sec.SecurityFinding(h.ctx, inj.ID); f.Status != domain.SecFixed || f.TicketKey != "SEC-1" {
		t.Fatalf("after the verify scan: %s", f.Status)
	}
	// Nothing else changed: the verify scan touched only its finding.
	if f, _ := sec.SecurityFinding(h.ctx, idor.ID); f.Status != domain.SecOpen {
		t.Fatalf("IDOR after verify: %s", f.Status)
	}

	// The injection comes back: reopened, and the event says so.
	h.runner.seed[orchestrator.SecOutDir+"/raw/opengrep.json"] = og
	_, _, _ = h.o.ScanRepository(h.ctx, repo, domain.OriginWeb, nil)
	h.runner.scripts = []script{{result: ok("sec3"), files: map[string]string{orchestrator.SecurityPath: manifest(map[string]any{
		"known": []map[string]any{{"findingId": idor.ID, "status": "gone", "note": "ownership is checked now"}}})}}}
	h.runner.onClaude = nil
	h.step()
	if f, _ := sec.SecurityFinding(h.ctx, inj.ID); f.Status != domain.SecReopened {
		t.Fatalf("reopened: %s", f.Status)
	}
	if f, _ := sec.SecurityFinding(h.ctx, idor.ID); f.Status != domain.SecFixed {
		t.Fatalf("the agent said the IDOR is gone and finished: %s", f.Status)
	}

	// Dismiss needs a reason; a dismissed finding stays out of the way.
	if _, err := h.o.DismissFindings(h.ctx, []int64{fs[2].ID}, "because", "", nil, domain.OriginWeb); err == nil {
		t.Fatal("dismissed without a valid reason")
	}
	if d, err := h.o.DismissFindings(h.ctx, []int64{fs[2].ID}, domain.SecAcceptedRisk, "internal tool", nil, domain.OriginWeb); err != nil || d[0].Status != domain.SecDismissed {
		t.Fatalf("dismiss: %v", err)
	}
	if f, err := h.o.ReopenFinding(h.ctx, fs[2].ID, domain.OriginWeb); err != nil || f.Status != domain.SecOpen || f.DismissReason != "" {
		t.Fatalf("reopen: %+v %v", f, err)
	}
}

func TestSecurityScanAgentLimitAndFailure(t *testing.T) {
	h, sec, repo := newSecurityHarness(t)
	_, _, _ = h.o.ScanRepository(h.ctx, repo, domain.OriginWeb, nil)
	h.runner.scripts = []script{{result: ok("sec1"), files: map[string]string{orchestrator.SecurityPath: manifest(map[string]any{
		"findings": []map[string]any{{"severity": "high", "title": "IDOR", "cwe": "CWE-639", "location": map[string]any{"file": "api/users.go", "line": 4}}}})}}}
	h.step()
	fs, _ := sec.SecurityFindings(h.ctx, domain.SecFindingFilter{RepoID: repo, Active: true})
	var idor int64
	for _, f := range fs {
		if f.Source == domain.SecFromAgent {
			idor = f.ID
		}
	}

	// The agent says gone but hits its turn limit: the finding stays.
	_, _, _ = h.o.ScanRepository(h.ctx, repo, domain.OriginWeb, nil)
	limited := ok("sec2")
	limited.IsError, limited.Subtype = true, "error_max_turns"
	h.runner.scripts = []script{{result: limited, files: map[string]string{orchestrator.SecurityPath: manifest(map[string]any{
		"known": []map[string]any{{"findingId": idor, "status": "gone"}}})}}}
	h.step()
	scans, _ := sec.SecurityScans(h.ctx, repo, 1)
	if scans[0].Ran.Agent != domain.SecAgentLimit || scans[0].Status != domain.ScanDone {
		t.Fatalf("limited scan: %+v", scans[0])
	}
	if f, _ := sec.SecurityFinding(h.ctx, idor); f.Status != domain.SecOpen {
		t.Fatalf("closed by an agent that did not finish: %s", f.Status)
	}

	// The scanners never finished: the scan fails and nothing changes.
	delete(h.runner.seed, orchestrator.SecOutDir+"/ran.json")
	_, _, _ = h.o.ScanRepository(h.ctx, repo, domain.OriginWeb, nil)
	h.step()
	scans, _ = sec.SecurityScans(h.ctx, repo, 1)
	if scans[0].Status != domain.ScanFailed || !strings.Contains(scans[0].Error, "did not finish") {
		t.Fatalf("failed scan: %+v", scans[0])
	}
	if after, _ := sec.SecurityFindings(h.ctx, domain.SecFindingFilter{RepoID: repo, Active: true}); len(after) != len(fs) {
		t.Fatalf("a failed scan changed findings: %d → %d", len(fs), len(after))
	}
}

func TestSecurityScheduledScans(t *testing.T) {
	h, sec, repo := newSecurityHarness(t)
	h.runner.head = "0123456789abcdef0123456789abcdef01234567"
	if _, err := h.o.SetSecuritySettings(h.ctx, repo, domain.SecuritySettings{Schedule: "hourly"}, domain.OriginWeb); err == nil {
		t.Fatal("accepted an unknown schedule")
	}
	if _, err := h.o.SetSecuritySettings(h.ctx, repo, domain.SecuritySettings{Schedule: domain.SecScheduleDaily, Exclude: []string{"handlers/**"}}, domain.OriginWeb); err != nil {
		t.Fatal(err)
	}
	// Make it due now, as the minute tick would find it.
	past := time.Now().Add(-time.Minute)
	if err := sec.SetSecuritySettings(h.ctx, repo, domain.SecuritySettings{Schedule: domain.SecScheduleDaily, Exclude: []string{"handlers/**"}}, &past); err != nil {
		t.Fatal(err)
	}
	h.o.SecurityTick(h.ctx) // enqueue due scans
	scans, _ := sec.SecurityScans(h.ctx, repo, 5)
	if len(scans) != 1 || scans[0].Trigger != domain.SecSchedule || !scans[0].Scope.FullHistory {
		t.Fatalf("scheduled scan: %+v", scans)
	}
	h.runner.scripts = []script{{result: ok("sec1"), files: map[string]string{orchestrator.SecurityPath: manifest(map[string]any{"summary": "ok"})}}}
	h.step()
	fs, _ := sec.SecurityFindings(h.ctx, domain.SecFindingFilter{RepoID: repo})
	for _, f := range fs {
		if strings.HasPrefix(f.Data.Location.File, "handlers/") {
			t.Fatalf("an excluded path was reported: %+v", f)
		}
	}

	// The same commit and databases again: nothing runs, nothing is said.
	_ = sec.SetSecuritySettings(h.ctx, repo, domain.SecuritySettings{Schedule: domain.SecScheduleDaily}, &past)
	h.o.SecurityTick(h.ctx)
	prompts := len(h.runner.prompts)
	h.step()
	scans, _ = sec.SecurityScans(h.ctx, repo, 5)
	if len(h.runner.prompts) != prompts || scans[0].Status != domain.ScanDone || !strings.Contains(scans[0].Summary, "Nothing changed") {
		t.Fatalf("unchanged scheduled scan: %+v", scans[0])
	}

	// A new commit, but the daily budget is used: the scanners only.
	h.runner.head = "1123456789abcdef0123456789abcdef01234567"
	h.settings.s.Security.DailyBudget = 1
	_ = sec.SetSecuritySettings(h.ctx, repo, domain.SecuritySettings{Schedule: domain.SecScheduleDaily}, &past)
	h.o.SecurityTick(h.ctx)
	h.step()
	scans, _ = sec.SecurityScans(h.ctx, repo, 5)
	if len(h.runner.prompts) != prompts || scans[0].Ran.Agent != domain.SecAgentSkipped || !strings.Contains(scans[0].Summary, "budget") {
		t.Fatalf("over budget: %+v", scans[0])
	}
}
