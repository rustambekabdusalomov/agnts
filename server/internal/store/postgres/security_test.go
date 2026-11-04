package postgres

import (
	"errors"
	"testing"
	"time"

	"agnts/internal/domain"
)

func TestSecurityStore(t *testing.T) {
	users, _ := testDB(t)
	ctx, _ := testWS(t, users)
	other, _ := testWS(t, users)
	s := NewAgent(users.db)
	sec := NewSecurity(users.db)

	repo, err := s.SaveRepository(ctx, domain.Repository{Name: "api", Kind: "side", Provider: "github", CloneURL: "https://github.com/a/api.git", DefaultBranch: "main"})
	if err != nil {
		t.Fatal(err)
	}

	// One manual scan at a time per repository; verify scans always queue.
	scan, busy, err := sec.CreateSecurityScan(ctx, domain.SecurityScan{RepoID: repo.ID, Trigger: domain.SecManual, Scope: domain.SecScope{FullHistory: true}})
	if err != nil || busy || scan.Status != domain.ScanPending || !scan.Scope.FullHistory || scan.RepoName != "api" {
		t.Fatalf("create: %+v %v %v", scan, busy, err)
	}
	again, busy, err := sec.CreateSecurityScan(ctx, domain.SecurityScan{RepoID: repo.ID, Trigger: domain.SecManual})
	if err != nil || !busy || again.ID != scan.ID {
		t.Fatalf("second manual scan: %+v %v %v", again, busy, err)
	}
	if ws, _ := sec.PendingSecurityWorkspaces(domain.System(ctx)); len(ws) != 1 {
		t.Fatalf("pending workspaces = %v", ws)
	}

	// The other workspace sees nothing of it.
	if _, err := sec.SecurityScan(other, scan.ID); !errors.Is(err, domain.ErrNotFound) {
		t.Fatalf("another workspace read the scan: %v", err)
	}
	if _, ok, _ := sec.ClaimSecurityScan(other); ok {
		t.Fatal("another workspace claimed the scan")
	}

	claimed, ok, err := sec.ClaimSecurityScan(ctx)
	if err != nil || !ok || claimed.ID != scan.ID || claimed.Status != domain.ScanRunning || claimed.StartedAt == nil {
		t.Fatalf("claim: %+v %v %v", claimed, ok, err)
	}

	// Finish: the reconcile decides; the store saves findings and the scan.
	hits := []domain.SecHit{
		{ID: "h1", Tool: domain.ToolOpengrep, Source: domain.SecFromCode, Rule: "agnts.go.sqli.formatted-query", Severity: domain.SecHigh,
			Title: "SQL built with fmt.Sprintf", File: "handlers/orders.go", Line: 20, CWE: "CWE-89", Category: "injection"},
		{ID: "h2", Tool: domain.ToolOSV, Source: domain.SecFromDependency, Rule: "GHSA-x", Severity: domain.SecMedium, Title: "lodash",
			File: "package-lock.json", Ecosystem: "npm", Package: "lodash", Version: "4.17.20", Category: "dependency"},
	}
	ran := domain.SecRan{Tools: map[string]domain.SecToolRun{}, Paths: []string{"."}, Agent: domain.SecAgentDone}
	for _, tool := range domain.SecTools {
		ran.Tools[tool] = domain.SecToolRun{Status: "ok"}
	}
	res := domain.SecScanResult{Hits: hits, Ran: ran}
	apply := func(res domain.SecScanResult, scanID int64) func([]domain.SecurityFinding) ([]domain.SecurityFinding, domain.SecCounts) {
		return func(existing []domain.SecurityFinding) ([]domain.SecurityFinding, domain.SecCounts) {
			cands, _ := domain.SecurityCandidates(repo.ID, res)
			for i := range cands {
				cands[i].RepoID = repo.ID
			}
			return domain.ReconcileSecurity(existing, cands, res, scanID, time.Now())
		}
	}
	claimed.Status, claimed.Ran, claimed.Commit, claimed.Provider = domain.ScanDone, ran, "abc123", "muse"
	claimed.Rejected = []domain.SecRejected{{Hit: "h9", Rule: "r", Reason: "example key"}}
	done, err := sec.FinishSecurityScan(ctx, claimed, apply(res, claimed.ID), func(x domain.SecurityScan) *domain.Event {
		return &domain.Event{Type: domain.EventSecurity, Message: "scan done", Data: map[string]any{"scan": x.ID}}
	})
	if err != nil {
		t.Fatal(err)
	}
	if done.Status != domain.ScanDone || done.Counts.New != 2 || done.Commit != "abc123" || done.Provider != "muse" || len(done.Rejected) != 1 ||
		done.FinishedAt == nil || done.Ran.Tool(domain.ToolOSV).Status != "ok" {
		t.Fatalf("done: %+v", done)
	}
	// A cancelled or recovered scan's result is dropped.
	if _, err := sec.FinishSecurityScan(ctx, claimed, nil, nil); !errors.Is(err, domain.ErrScanStale) {
		t.Fatalf("finish twice: %v", err)
	}

	fs, err := sec.SecurityFindings(ctx, domain.SecFindingFilter{RepoID: repo.ID, Active: true})
	if err != nil || len(fs) != 2 || fs[0].Severity != domain.SecHigh || fs[0].RepoName != "api" || fs[0].Data.Location.File != "handlers/orders.go" {
		t.Fatalf("findings: %+v %v", fs, err)
	}
	if fs, _ := sec.SecurityFindings(other, domain.SecFindingFilter{}); len(fs) != 0 {
		t.Fatalf("another workspace sees findings: %+v", fs)
	}

	// A fix ticket links two findings; the event comes with it.
	ids := []int64{fs[0].ID, fs[1].ID}
	upd, err := sec.UpdateSecurityFindings(ctx, ids, func(f *domain.SecurityFinding) error {
		f.Status, f.TicketKey = domain.SecFixing, "SEC-1"
		return nil
	}, nil)
	if err != nil || len(upd) != 2 {
		t.Fatalf("update: %v", err)
	}
	if byTicket, _ := sec.FindingsByTicket(ctx, "SEC-1"); len(byTicket) != 2 {
		t.Fatalf("by ticket = %d", len(byTicket))
	}
	if refs, _ := sec.FixingTickets(domain.System(ctx)); len(refs) != 1 || refs[0].Key != "SEC-1" {
		t.Fatalf("fixing tickets = %+v", refs)
	}
	if _, err := sec.UpdateSecurityFindings(other, ids, func(*domain.SecurityFinding) error { return nil }, nil); !errors.Is(err, domain.ErrNotFound) {
		t.Fatalf("another workspace updated findings: %v", err)
	}

	// A second scan sees the dependency gone: it closes; the injection
	// stays (still fixing) and the summary counts it.
	scan2, _, _ := sec.CreateSecurityScan(ctx, domain.SecurityScan{RepoID: repo.ID, Trigger: domain.SecManual})
	c2, _, _ := sec.ClaimSecurityScan(ctx)
	if c2.ID != scan2.ID {
		t.Fatalf("claimed %d, want %d", c2.ID, scan2.ID)
	}
	c2.Status, c2.Ran = domain.ScanDone, ran
	res2 := domain.SecScanResult{Hits: hits[:1], Ran: ran}
	done2, err := sec.FinishSecurityScan(ctx, c2, apply(res2, c2.ID), nil)
	if err != nil || done2.Counts.Fixed != 1 || done2.Counts.Seen != 1 || done2.Counts.New != 0 {
		t.Fatalf("second scan: %+v %v", done2.Counts, err)
	}
	if f, _ := sec.SecurityFinding(ctx, fs[0].ID); f.Status != domain.SecFixing || f.TicketKey != "SEC-1" {
		t.Fatalf("injection = %s %s", f.Status, f.TicketKey)
	}
	if f, _ := sec.SecurityFinding(ctx, fs[1].ID); f.Status != domain.SecFixed {
		t.Fatalf("dependency = %s", f.Status)
	}
	sum, err := sec.SecuritySummaries(ctx)
	if err != nil || len(sum) != 1 || sum[0].Open[domain.SecHigh] != 1 {
		t.Fatalf("summary: %+v %v", sum, err)
	}
	if last, err := sec.LastFullScan(ctx, repo.ID); err != nil || last.ID != scan2.ID {
		t.Fatalf("last full scan: %+v %v", last, err)
	}

	// Cancel and recover.
	s3, _, _ := sec.CreateSecurityScan(ctx, domain.SecurityScan{RepoID: repo.ID, Trigger: domain.SecManual})
	if c, err := sec.CancelSecurityScan(ctx, s3.ID); err != nil || c.Status != domain.ScanCancelled {
		t.Fatalf("cancel: %+v %v", c, err)
	}
	if _, err := sec.CancelSecurityScan(ctx, scan2.ID); !errors.Is(err, domain.ErrConflict) {
		t.Fatalf("cancel a finished scan: %v", err)
	}
	s4, _, _ := sec.CreateSecurityScan(ctx, domain.SecurityScan{RepoID: repo.ID, Trigger: domain.SecVerify, Scope: domain.SecScope{FindingIDs: ids}})
	if _, ok, _ := sec.ClaimSecurityScan(ctx); !ok {
		t.Fatal("claim verify scan")
	}
	if n, err := sec.RecoverSecurityScans(domain.System(ctx)); err != nil || n != 1 {
		t.Fatalf("recover = %d %v", n, err)
	}
	if x, _ := sec.SecurityScan(ctx, s4.ID); x.Status != domain.ScanPending || len(x.Scope.FindingIDs) != 2 {
		t.Fatalf("recovered: %+v", x)
	}
	list, _ := sec.SecurityScans(ctx, repo.ID, 10)
	if len(list) != 4 || list[0].ID != s4.ID {
		t.Fatalf("scans = %d", len(list))
	}
}

func TestSecuritySettingsStore(t *testing.T) {
	users, _ := testDB(t)
	ctx, _ := testWS(t, users)
	s := NewAgent(users.db)
	sec := NewSecurity(users.db)
	repo, err := s.SaveRepository(ctx, domain.Repository{Name: "api", Kind: "side", Provider: "github", CloneURL: "https://github.com/a/api.git", DefaultBranch: "main"})
	if err != nil {
		t.Fatal(err)
	}
	set := domain.SecuritySettings{Schedule: domain.SecScheduleDaily, Exclude: []string{"testdata/**"}, MinNotify: domain.SecMedium}
	past := time.Now().Add(-time.Minute)
	if err := sec.SetSecuritySettings(ctx, repo.ID, set, &past); err != nil {
		t.Fatal(err)
	}
	// Saving the guardrails keeps the security settings.
	if _, err := s.SetRepoHarness(ctx, repo.ID, domain.RepoHarness{GuardProfile: "strict"}); err != nil {
		t.Fatal(err)
	}
	got, err := sec.SecuritySettings(ctx, repo.ID)
	if err != nil || got.Schedule != "daily" || len(got.Exclude) != 1 || got.MinNotify != domain.SecMedium {
		t.Fatalf("after a guardrails save: %+v %v", got, err)
	}
	if r, _ := s.RepositoryByID(ctx, repo.ID); r.Harness.GuardProfile != "strict" || r.Harness.Security.Schedule != "daily" {
		t.Fatalf("harness = %+v", r.Harness)
	}
	// Due once; the next time moves on, so it is not due again.
	due, err := sec.DueSecurityScans(domain.System(ctx), time.Now())
	if err != nil || len(due) != 1 || due[0].RepoID != repo.ID || due[0].Settings.Schedule != "daily" {
		t.Fatalf("due: %+v %v", due, err)
	}
	if again, _ := sec.DueSecurityScans(domain.System(ctx), time.Now()); len(again) != 0 {
		t.Fatalf("due twice: %+v", again)
	}
	if err := sec.SetSecuritySettings(ctx, 999999, set, nil); !errors.Is(err, domain.ErrNotFound) {
		t.Fatalf("missing repository: %v", err)
	}
	if n, err := sec.AgentScansSince(ctx, time.Now().Add(-time.Hour)); err != nil || n != 0 {
		t.Fatalf("agent scans = %d %v", n, err)
	}
}
