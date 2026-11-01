package musecredits_test

import (
	"context"
	"io"
	"log/slog"
	"strconv"
	"testing"

	"github.com/rustambekabdusalomov/agnts-muse/budget"
	"github.com/rustambekabdusalomov/agnts-muse/money"

	"agnts/internal/billing"
	"agnts/internal/domain"
	"agnts/internal/musecredits"
	"agnts/internal/orchestrator"
	"agnts/internal/store/postgres"
	"agnts/internal/store/postgres/pgtest"
)

// TestRunPaysFreeCreditsFirst follows the money of one Muse run on
// agnts's key: an Admin gives a judge 20 free credits, the workspace has
// 500 bought ones, the run holds and spends 27¢ live, and billing charges
// the workspace only the 7¢ the free credits did not cover.
func TestRunPaysFreeCreditsFirst(t *testing.T) {
	pool := pgtest.Open(t)
	pgtest.Reset(t, pool)
	pgtest.Exec(t, pool, `DROP TABLE IF EXISTS muse_entries, muse_hold_legs, muse_holds, muse_accounts`)
	ctx, ws := pgtest.Workspace(t, pool, "muse-money")
	sys := domain.System(ctx)
	judge := pgtest.User(t, pool, "judge")
	admin := pgtest.User(t, pool, "admin")
	pgtest.Exec(t, pool, `UPDATE users SET free_credits_limit = 0 WHERE id = $1`, judge)
	pgtest.Exec(t, pool, `UPDATE workspaces SET credits_balance = 0 WHERE id = $1`, ws)

	credits := postgres.NewCredits(pool)
	svc := musecredits.New(musecredits.Config{RunCap: 2500, GlobalCapUSD: 100}, pool, credits)
	if err := svc.Migrate(ctx); err != nil {
		t.Fatal(err)
	}
	f, err := svc.SetFree(ctx, judge, 20, admin)
	if err != nil || f.Limit != 20 || f.Remaining != 20 || f.Used != 0 || f.SetBy == nil || *f.SetBy != admin {
		t.Fatalf("set free = %+v, %v", f, err)
	}
	if _, err := credits.Add(sys, postgres.LedgerEntry{WorkspaceID: ws, Amount: 500, Reason: postgres.CreditGrant}); err != nil {
		t.Fatal(err)
	}

	store := postgres.NewAgent(pool)
	tk, err := store.CreateTicket(ctx, domain.Ticket{Key: "M-1", Source: domain.SourceLocal, Title: "t", State: domain.StateNew, Priority: "medium",
		Kind: domain.KindPlan, AfterApprove: "pr"}, domain.Event{TicketKey: "M-1", Type: domain.EventTicketCreated})
	if err != nil {
		t.Fatal(err)
	}
	_, run, ok, err := store.ClaimTicket(ctx, tk.ID, "main")
	if err != nil || !ok {
		t.Fatal(err)
	}

	// The run's budget: the judge's free credits, then the wallet, under
	// the platform's monthly cap and the run cap; its limit is what the
	// payers have ($0.20 + $5.00), below the $25 cap.
	rctx := domain.WithClaude(ctx, domain.ClaudeAccount{Credits: true, UserID: judge})
	b, err := svc.Budget(rctx, orchestrator.ClaudeRequest{RunID: run.ID, WorkspaceID: ws})
	if err != nil || b == nil {
		t.Fatalf("budget = %+v, %v", b, err)
	}
	if len(b.Payers) != 2 || b.Payers[0] != budget.AccountID("user:"+itoa(judge)+":free") || len(b.Caps) != 1 || b.Limit != 520*money.Cent {
		t.Fatalf("budget = %+v", b)
	}
	// What agnts-muse does during the run: hold, extend, commit.
	l := svc.Ledger()
	h, err := l.Hold(ctx, budget.HoldRequest{Key: b.Key, Payers: b.Payers, Caps: b.Caps, Amount: 20 * money.Cent})
	if err != nil {
		t.Fatal(err)
	}
	if h, err = l.Extend(ctx, h.ID, 10*money.Cent); err != nil {
		t.Fatal(err)
	}
	r, err := l.Commit(ctx, h.ID, 27*money.Cent)
	if err != nil || r.Charged != 27*money.Cent || r.Legs[0].Charged != 20*money.Cent || r.Legs[1].Charged != 7*money.Cent {
		t.Fatalf("receipt = %+v, %v", r, err)
	}
	if usd, err := svc.FreeChargedUSD(ctx, run.ID); err != nil || usd != 0.20 {
		t.Fatalf("free charged = %v, %v", usd, err)
	}
	if f, _ := svc.Free(ctx, judge); f.Used != 20 || f.Remaining != 0 {
		t.Fatalf("free after the run = %+v", f)
	}

	// A second run before billing settled the first must not see the 7¢
	// again: the wallet copy counts unsettled spend.
	b2, err := svc.Budget(rctx, orchestrator.ClaudeRequest{RunID: run.ID, WorkspaceID: ws})
	if err != nil {
		t.Fatal(err)
	}
	h2, err := l.Hold(ctx, budget.HoldRequest{Key: b2.Key, Payers: b2.Payers, Caps: b2.Caps, Amount: 493 * money.Cent})
	if err != nil {
		t.Fatalf("the wallet should have exactly $4.93 left: %v", err)
	}
	if err := l.Release(ctx, h2.ID); err != nil {
		t.Fatal(err)
	}

	// Billing charges the wallet the paid part only.
	if err := store.RecordClaudeCall(ctx, domain.ClaudeCall{RunID: run.ID, ModelStage: domain.ModelCoding, Model: "muse:muse-spark-1.3",
		Usage: domain.TokenUsage{Input: 1, CostUSD: 0.27}, OnCredits: true}); err != nil {
		t.Fatal(err)
	}
	bill := billing.New(billing.Config{Enabled: true, RunCap: 2500, Markup: 1.4}, credits, postgres.NewWorkspaces(pool), store,
		slog.New(slog.NewTextHandler(io.Discard, nil)))
	bill.SetFree(svc.FreeChargedUSD)
	if err := bill.Settle(sys, ws, run.ID, "M-1"); err != nil {
		t.Fatal(err)
	}
	if bal, _ := credits.Balance(sys, ws); bal != 493 {
		t.Fatalf("wallet = %d credits, want 493 (500 - 7)", bal)
	}
	// After settling, the copy still matches the wallet.
	if _, err := svc.Budget(rctx, orchestrator.ClaudeRequest{RunID: run.ID + 1, WorkspaceID: ws}); err != nil {
		t.Fatal(err)
	}
	var total int64
	if err := pool.QueryRow(sys, `SELECT total FROM muse_accounts WHERE id = $1`, "ws:"+itoa(ws)+":wallet").Scan(&total); err != nil || total != 4_930_000 {
		t.Fatalf("wallet copy = %d µ$, %v; want 4930000", total, err)
	}
}

func TestOwnAccountRunsHaveNoBudget(t *testing.T) {
	svc := musecredits.New(musecredits.Config{}, nil, nil)
	ctx := domain.WithClaude(context.Background(), domain.ClaudeAccount{ConnectionID: 5})
	if b, err := svc.Budget(ctx, orchestrator.ClaudeRequest{RunID: 1, WorkspaceID: 1}); b != nil || err != nil {
		t.Fatalf("own account: %+v, %v", b, err)
	}
	ctx = domain.WithClaude(context.Background(), domain.ClaudeAccount{Credits: true})
	if b, err := svc.Budget(ctx, orchestrator.ClaudeRequest{}); b != nil || err != nil {
		t.Fatalf("outside a run: %+v, %v", b, err)
	}
}

func TestLoweringFreeCreditsKeepsWhatWasSpent(t *testing.T) {
	pool := pgtest.Open(t)
	pgtest.Reset(t, pool)
	ctx := context.Background()
	u := pgtest.User(t, pool, "trial")
	svc := musecredits.New(musecredits.Config{}, pool, nil)
	if err := svc.Migrate(ctx); err != nil {
		t.Fatal(err)
	}
	pgtest.Exec(t, pool, `DELETE FROM muse_entries WHERE account_id = $1`, "user:"+itoa(u)+":free")
	pgtest.Exec(t, pool, `UPDATE muse_accounts SET total = 0, held = 0 WHERE id = $1`, "user:"+itoa(u)+":free")
	if _, err := svc.SetFree(ctx, u, 100, u); err != nil {
		t.Fatal(err)
	}
	f, err := svc.SetFree(ctx, u, 30, u)
	if err != nil || f.Limit != 30 || f.Remaining != 30 {
		t.Fatalf("lowered = %+v, %v", f, err)
	}
	if _, err := svc.SetFree(ctx, u, -1, u); err == nil {
		t.Fatal("negative limit accepted")
	}
}

func itoa(n int64) string { return strconv.FormatInt(n, 10) }

func TestWorkspaceBudgetPerRun(t *testing.T) {
	pool := pgtest.Open(t)
	pgtest.Reset(t, pool)
	ctx, ws := pgtest.Workspace(t, pool, "muse-budget")
	pgtest.Exec(t, pool, `UPDATE workspaces SET credits_balance = 0 WHERE id = $1`, ws)
	credits := postgres.NewCredits(pool)
	svc := musecredits.New(musecredits.Config{RunCap: 2500}, pool, credits)
	if err := svc.Migrate(ctx); err != nil {
		t.Fatal(err)
	}
	rctx := domain.WithClaude(ctx, domain.ClaudeAccount{Credits: true})
	if _, err := svc.Budget(rctx, orchestrator.ClaudeRequest{RunID: 9001, WorkspaceID: ws}); err == nil {
		t.Fatal("a run without any credits must not start")
	}
	if _, err := credits.Add(domain.System(ctx), postgres.LedgerEntry{WorkspaceID: ws, Amount: 1000, Reason: postgres.CreditGrant}); err != nil {
		t.Fatal(err)
	}
	b, err := svc.Budget(rctx, orchestrator.ClaudeRequest{RunID: 9001, WorkspaceID: ws, Budget: 50})
	if err != nil || b.Limit != 50*money.Cent {
		t.Fatalf("budget 50 credits: %+v, %v", b, err)
	}
	if b, _ = svc.Budget(rctx, orchestrator.ClaudeRequest{RunID: 9001, WorkspaceID: ws}); b.Limit != 10*money.Dollar {
		t.Fatalf("no setting: limit %v, want the $10 the wallet has", b.Limit)
	}
}

// TestMonthlyLimitStopsSpend: an Admin limits a person to 30 credits a
// month; a run may hold only what is left of it, whatever pays, and once
// it is spent no new run starts until the Admin raises it.
func TestMonthlyLimitStopsSpend(t *testing.T) {
	pool := pgtest.Open(t)
	pgtest.Reset(t, pool)
	pgtest.Exec(t, pool, `DROP TABLE IF EXISTS muse_entries, muse_hold_legs, muse_holds, muse_accounts`)
	ctx, ws := pgtest.Workspace(t, pool, "muse-limit")
	sys := domain.System(ctx)
	dev := pgtest.User(t, pool, "dev")
	admin := pgtest.User(t, pool, "admin")
	pgtest.Exec(t, pool, `UPDATE workspaces SET credits_balance = 0 WHERE id = $1`, ws)
	credits := postgres.NewCredits(pool)
	svc := musecredits.New(musecredits.Config{RunCap: 2500}, pool, credits)
	if err := svc.Migrate(ctx); err != nil {
		t.Fatal(err)
	}
	if _, err := credits.Add(sys, postgres.LedgerEntry{WorkspaceID: ws, Amount: 1000, Reason: postgres.CreditGrant}); err != nil {
		t.Fatal(err)
	}
	u, err := svc.SetLimit(ctx, dev, 30, admin)
	if err != nil || u.MonthLimit != 30 || u.MonthUsed != 0 || u.SetBy == nil || *u.SetBy != admin {
		t.Fatalf("set limit = %+v, %v", u, err)
	}

	rctx := domain.WithClaude(ctx, domain.ClaudeAccount{Credits: true, UserID: dev})
	b, err := svc.Budget(rctx, orchestrator.ClaudeRequest{RunID: 9101, WorkspaceID: ws})
	if err != nil || b.Limit != 30*money.Cent || len(b.Caps) != 1 {
		t.Fatalf("budget = %+v, %v; want a 30¢ limit under the person's cap", b, err)
	}
	l := svc.Ledger()
	h, err := l.Hold(ctx, budget.HoldRequest{Key: b.Key, Payers: b.Payers, Caps: b.Caps, Amount: 30 * money.Cent})
	if err != nil {
		t.Fatal(err)
	}
	if _, err := l.Extend(ctx, h.ID, money.Cent); err == nil {
		t.Fatal("a hold went past the monthly limit")
	}
	if _, err := l.Commit(ctx, h.ID, 30*money.Cent); err != nil {
		t.Fatal(err)
	}
	if u, _ = svc.Usage(ctx, dev); u.MonthUsed != 30 || u.TotalUsed != 30 {
		t.Fatalf("usage = %+v, want 30 used", u)
	}
	if _, err := svc.Budget(rctx, orchestrator.ClaudeRequest{RunID: 9102, WorkspaceID: ws}); err == nil {
		t.Fatal("a run started past the monthly limit")
	}
	// Raising the limit gives the difference; spend this month still counts.
	if _, err := svc.SetLimit(ctx, dev, 50, admin); err != nil {
		t.Fatal(err)
	}
	if b, err = svc.Budget(rctx, orchestrator.ClaudeRequest{RunID: 9102, WorkspaceID: ws}); err != nil || b.Limit != 20*money.Cent {
		t.Fatalf("raised budget = %+v, %v; want 20¢ left", b, err)
	}
	// No limit: only the wallet bounds the run.
	if _, err := svc.SetLimit(ctx, dev, 0, admin); err != nil {
		t.Fatal(err)
	}
	if b, err = svc.Budget(rctx, orchestrator.ClaudeRequest{RunID: 9103, WorkspaceID: ws}); err != nil || len(b.Caps) != 0 {
		t.Fatalf("unlimited budget = %+v, %v", b, err)
	}
	if _, err := svc.SetLimit(ctx, dev, -5, admin); err == nil {
		t.Fatal("negative limit accepted")
	}
}
