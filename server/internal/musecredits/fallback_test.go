package musecredits_test

import (
	"testing"

	"github.com/rustambekabdusalomov/agnts-muse/budget"
	"github.com/rustambekabdusalomov/agnts-muse/money"

	"agnts/internal/domain"
	"agnts/internal/musecredits"
	"agnts/internal/orchestrator"
	"agnts/internal/store/postgres"
	"agnts/internal/store/postgres/pgtest"
)

// TestFallbackLimit follows a person's allowance on Baseten: the server's
// default of 20 credits a month applies until an Admin sets one, only
// spend on Baseten counts against it (not spend on Meta), the platform
// pays for it (not their credits, and billing leaves it out), and with
// none left their runs may not move there.
func TestFallbackLimit(t *testing.T) {
	pool := pgtest.Open(t)
	pgtest.Reset(t, pool)
	pgtest.Exec(t, pool, `DROP TABLE IF EXISTS muse_entries, muse_hold_legs, muse_holds, muse_accounts`)
	ctx, ws := pgtest.Workspace(t, pool, "muse-fallback")
	sys := domain.System(ctx)
	dev := pgtest.User(t, pool, "dev")
	admin := pgtest.User(t, pool, "admin")
	pgtest.Exec(t, pool, `UPDATE workspaces SET credits_balance = 0 WHERE id = $1`, ws)
	credits := postgres.NewCredits(pool)
	svc := musecredits.New(musecredits.Config{RunCap: 2500, Fallback: "baseten", FallbackUserLimit: 20}, pool, credits)
	if err := svc.Migrate(ctx); err != nil {
		t.Fatal(err)
	}
	if _, err := credits.Add(sys, postgres.LedgerEntry{WorkspaceID: ws, Amount: 1000, Reason: postgres.CreditGrant}); err != nil {
		t.Fatal(err)
	}
	rctx := domain.WithClaude(ctx, domain.ClaudeAccount{Credits: true, UserID: dev})
	l := svc.Ledger()
	// spend runs a hold the way muse.Failover does: on Meta under the
	// run's caps, on Baseten under its key + ":baseten" and the fallback's caps too.
	spend := func(run int64, onFallback bool, amount money.USD) {
		t.Helper()
		b, err := svc.Budget(rctx, orchestrator.ClaudeRequest{RunID: run, WorkspaceID: ws})
		if err != nil {
			t.Fatal(err)
		}
		req := budget.HoldRequest{Key: b.Key, Payers: b.Payers, Caps: b.Caps, Amount: amount}
		if onFallback {
			req = budget.HoldRequest{Key: b.Key + ":baseten", Payers: b.FallbackPayers, Caps: b.FallbackCaps, Amount: amount}
		}
		h, err := l.Hold(ctx, req)
		if err != nil {
			t.Fatal(err)
		}
		if _, err := l.Commit(ctx, h.ID, amount); err != nil {
			t.Fatal(err)
		}
	}

	b, err := svc.Budget(rctx, orchestrator.ClaudeRequest{RunID: 9201, WorkspaceID: ws})
	if err != nil || b.FallbackLimit != 20*money.Cent || len(b.FallbackCaps) != 1 || len(b.Caps) != 0 {
		t.Fatalf("budget = %+v, %v; want the default 20¢ on Baseten only", b, err)
	}
	spend(9201, false, 50*money.Cent) // on Meta: not counted
	spend(9202, true, 15*money.Cent)  // on Baseten
	u, err := svc.Usage(ctx, dev)
	if err != nil || u.Fallback == nil || u.Fallback.MonthUsed != 15 || u.Fallback.MonthLimit != 20 || !u.Fallback.Default || u.MonthUsed != 50 {
		t.Fatalf("usage = %+v / %+v, %v; want 15 on Baseten and only the 50 on Meta as their credits", u, u.Fallback, err)
	}
	// Billing charges the workspace nothing for Baseten.
	if paid, err := svc.FreeChargedUSD(ctx, 9202); err != nil || paid != 0.15 {
		t.Fatalf("not billed for run 9202 = %v, %v; want the whole 15¢", paid, err)
	}
	if b, _ = svc.Budget(rctx, orchestrator.ClaudeRequest{RunID: 9203, WorkspaceID: ws}); b.FallbackLimit != 5*money.Cent {
		t.Fatalf("fallback limit = %v, want 5¢ left", b.FallbackLimit)
	}
	spend(9203, true, 5*money.Cent)
	if b, _ = svc.Budget(rctx, orchestrator.ClaudeRequest{RunID: 9204, WorkspaceID: ws}); b.FallbackLimit != -1 || b.Limit <= 0 {
		t.Fatalf("budget = %+v; want Meta still allowed and Baseten not", b)
	}
	if svc.FallbackAvailable(ctx, dev) {
		t.Fatal("FallbackAvailable with the allowance spent")
	}

	// An Admin raises this person's limit, then removes it; null is the default again.
	limit := int64(50)
	if u, err = svc.SetFallbackLimit(ctx, dev, &limit, admin); err != nil || u.Fallback.MonthLimit != 50 || u.Fallback.Default {
		t.Fatalf("set = %+v, %v", u.Fallback, err)
	}
	if b, _ = svc.Budget(rctx, orchestrator.ClaudeRequest{RunID: 9205, WorkspaceID: ws}); b.FallbackLimit != 30*money.Cent {
		t.Fatalf("raised fallback limit = %v, want 30¢", b.FallbackLimit)
	}
	none := int64(0)
	if _, err = svc.SetFallbackLimit(ctx, dev, &none, admin); err != nil {
		t.Fatal(err)
	}
	if b, _ = svc.Budget(rctx, orchestrator.ClaudeRequest{RunID: 9206, WorkspaceID: ws}); b.FallbackLimit != 0 || len(b.FallbackCaps) != 0 {
		t.Fatalf("unlimited = %+v", b)
	}
	if u, _ = svc.SetFallbackLimit(ctx, dev, nil, admin); !u.Fallback.Default || u.Fallback.MonthLimit != 20 {
		t.Fatalf("back to default = %+v", u.Fallback)
	}
	bad := int64(-1)
	if _, err := svc.SetFallbackLimit(ctx, dev, &bad, admin); err == nil {
		t.Fatal("negative limit accepted")
	}
}

// TestFallbackPlatformCap keeps all runs together inside the host's
// credit: the platform's fallback account holds what is left of it.
func TestFallbackPlatformCap(t *testing.T) {
	pool := pgtest.Open(t)
	pgtest.Reset(t, pool)
	pgtest.Exec(t, pool, `DROP TABLE IF EXISTS muse_entries, muse_hold_legs, muse_holds, muse_accounts`)
	ctx, ws := pgtest.Workspace(t, pool, "muse-fallback-cap")
	sys := domain.System(ctx)
	dev := pgtest.User(t, pool, "dev")
	pgtest.Exec(t, pool, `UPDATE workspaces SET credits_balance = 0 WHERE id = $1`, ws)
	credits := postgres.NewCredits(pool)
	svc := musecredits.New(musecredits.Config{RunCap: 2500, Fallback: "baseten", FallbackCapUSD: 0.10}, pool, credits)
	if err := svc.Migrate(ctx); err != nil {
		t.Fatal(err)
	}
	if _, err := credits.Add(sys, postgres.LedgerEntry{WorkspaceID: ws, Amount: 1000, Reason: postgres.CreditGrant}); err != nil {
		t.Fatal(err)
	}
	rctx := domain.WithClaude(ctx, domain.ClaudeAccount{Credits: true, UserID: dev})
	b, err := svc.Budget(rctx, orchestrator.ClaudeRequest{RunID: 9301, WorkspaceID: ws})
	if err != nil || b.FallbackLimit != 10*money.Cent || len(b.FallbackPayers) != 1 || len(b.FallbackCaps) != 0 {
		t.Fatalf("budget = %+v, %v", b, err)
	}
	l := svc.Ledger()
	h, err := l.Hold(ctx, budget.HoldRequest{Key: b.Key + ":baseten", Payers: b.FallbackPayers, Amount: 10 * money.Cent})
	if err != nil {
		t.Fatal(err)
	}
	if _, err := l.Extend(ctx, h.ID, money.Cent); err == nil {
		t.Fatal("a hold went past the server's fallback cap")
	}
	if _, err := l.Commit(ctx, h.ID, 10*money.Cent); err != nil {
		t.Fatal(err)
	}
	if b, _ = svc.Budget(rctx, orchestrator.ClaudeRequest{RunID: 9302, WorkspaceID: ws}); b.FallbackLimit != -1 {
		t.Fatalf("fallback limit = %v after the cap was spent", b.FallbackLimit)
	}
	if svc.FallbackAvailable(ctx, dev) {
		t.Fatal("FallbackAvailable with the server's cap spent")
	}
}

// TestPreferFallbackNeedsNoCredits lets a person whose own account is at
// its limit start on Baseten with no credits at all: it costs them nothing.
func TestPreferFallbackNeedsNoCredits(t *testing.T) {
	pool := pgtest.Open(t)
	pgtest.Reset(t, pool)
	pgtest.Exec(t, pool, `DROP TABLE IF EXISTS muse_entries, muse_hold_legs, muse_holds, muse_accounts`)
	ctx, ws := pgtest.Workspace(t, pool, "muse-fallback-first")
	dev := pgtest.User(t, pool, "dev")
	pgtest.Exec(t, pool, `UPDATE workspaces SET credits_balance = 0 WHERE id = $1`, ws)
	svc := musecredits.New(musecredits.Config{RunCap: 2500, Fallback: "baseten", FallbackUserLimit: 500}, pool, postgres.NewCredits(pool))
	if err := svc.Migrate(ctx); err != nil {
		t.Fatal(err)
	}
	req := orchestrator.ClaudeRequest{RunID: 9401, WorkspaceID: ws}
	if _, err := svc.Budget(domain.WithClaude(ctx, domain.ClaudeAccount{Credits: true, UserID: dev}), req); err == nil {
		t.Fatal("a run on credits started with no credits")
	}
	if !svc.FallbackAvailable(ctx, dev) {
		t.Fatal("no fallback room for a person with a fresh allowance")
	}
	b, err := svc.Budget(domain.WithClaude(ctx, domain.ClaudeAccount{Credits: true, UserID: dev, PreferFallback: true}), req)
	if err != nil || b.FallbackLimit != 5*money.Dollar || len(b.FallbackPayers) != 1 {
		t.Fatalf("budget = %+v, %v; want $5 on Baseten, paid by the platform", b, err)
	}
}
