package billing

import (
	"context"
	"crypto/md5" //nolint:gosec // Click's signature
	"encoding/base64"
	"encoding/hex"
	"encoding/json"
	"errors"
	"io"
	"log/slog"
	"net/http/httptest"
	"net/url"
	"strconv"
	"strings"
	"testing"
	"time"

	"agnts/internal/domain"
	"agnts/internal/store/postgres"
	"agnts/internal/store/postgres/pgtest"
)

func setup(t *testing.T) (*Service, *postgres.Credits, int64, context.Context) {
	t.Helper()
	pool := pgtest.Open(t)
	pgtest.Reset(t, pool)
	ctx, ws := pgtest.Workspace(t, pool, "billing")
	pgtest.Exec(t, pool, `UPDATE workspaces SET credits_balance = 0, slots = 1, plan = 'base', trial_ends_at = NULL, suspended_at = NULL,
		paid_until = NULL, member_limit = 5 WHERE id = $1`, ws)
	credits := postgres.NewCredits(pool)
	s := New(Config{Enabled: true, WorkspaceUZS: 300000, SlotUZS: 190000, MemberUZS: 60000, CreditUZS: 175, IncludedMembers: 5, MaxSlots: 5,
		Markup: 1.4, RunCap: 2500, PublicURL: "https://agnts.example.com",
		Payme: PaymeConfig{MerchantID: "m1", Key: "paycom-key"},
		Click: ClickConfig{ServiceID: "11", MerchantID: "22", SecretKey: "click-secret"}},
		credits, postgres.NewWorkspaces(pool), postgres.NewAgent(pool), slog.New(slog.NewTextHandler(io.Discard, nil)))
	return s, credits, ws, ctx
}

func TestSettleAndWithin(t *testing.T) {
	s, credits, ws, ctx := setup(t)
	sys := domain.System(ctx)
	if _, err := credits.Add(sys, postgres.LedgerEntry{WorkspaceID: ws, Amount: 300, Reason: postgres.CreditGrant}); err != nil {
		t.Fatal(err)
	}
	store := postgres.NewAgent(pgtest.Open(t))
	tk, err := store.CreateTicket(ctx, domain.Ticket{Key: "C-1", Source: domain.SourceLocal, Title: "t", State: domain.StateNew, Priority: "medium",
		Kind: domain.KindPlan, AfterApprove: "pr"}, domain.Event{TicketKey: "C-1", Type: domain.EventTicketCreated})
	if err != nil {
		t.Fatal(err)
	}
	_, run, ok, err := store.ClaimTicket(ctx, tk.ID, "main")
	if err != nil || !ok {
		t.Fatal(err)
	}
	if err := store.RecordClaudeCall(ctx, domain.ClaudeCall{RunID: run.ID, ModelStage: domain.ModelAnalyze, Model: "opus",
		Usage: domain.TokenUsage{Input: 1, CostUSD: 1.234}}); err != nil {
		t.Fatal(err)
	}
	if ok, _ := s.Within(sys, ws, run.ID); !ok {
		t.Fatal("124 credits of 300 should be within")
	}
	if err := s.Settle(sys, ws, run.ID, "C-1"); err != nil {
		t.Fatal(err)
	}
	if err := s.Settle(sys, ws, run.ID, "C-1"); err != nil {
		t.Fatal(err)
	}
	if bal, _ := credits.Balance(sys, ws); bal != 300-124 {
		t.Fatalf("balance %d, want %d (charged once, rounded up)", bal, 300-124)
	}
	// More than the balance: the run must stop.
	if err := store.RecordClaudeCall(ctx, domain.ClaudeCall{RunID: run.ID, ModelStage: domain.ModelCoding, Model: "opus",
		Usage: domain.TokenUsage{Input: 1, CostUSD: 2}}); err != nil {
		t.Fatal(err)
	}
	if ok, why := s.Within(sys, ws, run.ID); ok || why == "" {
		t.Fatal("over the balance")
	}
}

func TestRenewSuspendsAndPaymentResumes(t *testing.T) {
	s, credits, ws, ctx := setup(t)
	sys := domain.System(ctx)
	fee := s.MonthlyCredits(1, 1)
	if fee != (300000+174)/175 {
		t.Fatalf("fee %d", fee)
	}
	if err := s.Renew(sys); err != nil {
		t.Fatal(err)
	}
	w, _ := postgres.NewWorkspaces(pgtest.Open(t)).ByID(sys, ws)
	if w.SuspendedAt == nil {
		t.Fatal("unpaid workspace not suspended")
	}

	// Buying credits through Payme pays the month and lifts the suspension.
	pageURL, id, err := s.Checkout(sys, ws, 0, 350000, "payme")
	if err != nil {
		t.Fatal(err)
	}
	enc := strings.TrimPrefix(pageURL, "https://checkout.paycom.uz/")
	raw, _ := base64.StdEncoding.DecodeString(enc)
	if !strings.Contains(string(raw), "ac.payment_id="+strconv.FormatInt(id, 10)) || !strings.Contains(string(raw), "a=35000000") {
		t.Fatalf("checkout params %q", raw)
	}
	h := s.PaymeHandler()
	rpc := func(method string, params map[string]any, key string) map[string]any {
		t.Helper()
		b, _ := json.Marshal(map[string]any{"method": method, "params": params, "id": 1})
		req := httptest.NewRequest("POST", "/webhooks/payme", strings.NewReader(string(b)))
		req.SetBasicAuth("Paycom", key)
		rec := httptest.NewRecorder()
		h.ServeHTTP(rec, req)
		var out map[string]any
		_ = json.Unmarshal(rec.Body.Bytes(), &out)
		return out
	}
	errCode := func(out map[string]any) int {
		e, _ := out["error"].(map[string]any)
		c, _ := e["code"].(float64)
		return int(c)
	}
	acct := map[string]any{"payment_id": strconv.FormatInt(id, 10)}
	if c := errCode(rpc("CheckPerformTransaction", map[string]any{"amount": 35000000, "account": acct}, "wrong")); c != paymeAuth {
		t.Fatalf("bad auth: %d", c)
	}
	if c := errCode(rpc("CheckPerformTransaction", map[string]any{"amount": 100, "account": acct}, "paycom-key")); c != paymeWrongAmount {
		t.Fatalf("wrong amount: %d", c)
	}
	if out := rpc("CheckPerformTransaction", map[string]any{"amount": 35000000, "account": acct}, "paycom-key"); out["result"] == nil {
		t.Fatalf("check: %v", out)
	}
	now := time.Now().UnixMilli()
	if out := rpc("CreateTransaction", map[string]any{"id": "pm-1", "time": now, "amount": 35000000, "account": acct}, "paycom-key"); out["result"] == nil {
		t.Fatalf("create: %v", out)
	}
	if c := errCode(rpc("CreateTransaction", map[string]any{"id": "pm-2", "time": now, "amount": 35000000, "account": acct}, "paycom-key")); c != paymeOrderBusy {
		t.Fatalf("second transaction: %d", c)
	}
	out := rpc("PerformTransaction", map[string]any{"id": "pm-1"}, "paycom-key")
	res, _ := out["result"].(map[string]any)
	if res["state"] != float64(paymePerformed) {
		t.Fatalf("perform: %v", out)
	}
	rpc("PerformTransaction", map[string]any{"id": "pm-1"}, "paycom-key") // again: no second payment
	bal, _ := credits.Balance(sys, ws)
	if want := 350000/175 - fee; bal != want {
		t.Fatalf("balance %d, want %d (credits bought less the month's fee)", bal, want)
	}
	w, _ = postgres.NewWorkspaces(pgtest.Open(t)).ByID(sys, ws)
	if w.SuspendedAt != nil {
		t.Fatal("still suspended after paying")
	}
	if out := rpc("CheckTransaction", map[string]any{"id": "pm-1"}, "paycom-key"); out["result"].(map[string]any)["state"] != float64(paymePerformed) {
		t.Fatalf("check transaction: %v", out)
	}
	stmt := rpc("GetStatement", map[string]any{"from": now - 1000, "to": now + 1000}, "paycom-key")
	if txs := stmt["result"].(map[string]any)["transactions"].([]any); len(txs) != 1 {
		t.Fatalf("statement: %v", stmt)
	}
}

func TestClick(t *testing.T) {
	s, credits, ws, ctx := setup(t)
	sys := domain.System(ctx)
	_, id, err := s.Checkout(sys, ws, 0, 17500, "click")
	if err != nil {
		t.Fatal(err)
	}
	h := s.ClickHandler()
	send := func(action, prepareID string, signed bool, errCode string) map[string]any {
		t.Helper()
		f := url.Values{"click_trans_id": {"777"}, "service_id": {"11"}, "click_paydoc_id": {"1"}, "merchant_trans_id": {strconv.FormatInt(id, 10)},
			"amount": {"17500"}, "action": {action}, "error": {errCode}, "sign_time": {"2026-10-08 12:00:00"}}
		if prepareID != "" {
			f.Set("merchant_prepare_id", prepareID)
		}
		str := "777" + "11" + "click-secret" + f.Get("merchant_trans_id") + prepareID + "17500" + action + f.Get("sign_time")
		sum := md5.Sum([]byte(str)) //nolint:gosec // Click's signature
		f.Set("sign_string", hex.EncodeToString(sum[:]))
		if !signed {
			f.Set("sign_string", "bad")
		}
		req := httptest.NewRequest("POST", "/webhooks/click", strings.NewReader(f.Encode()))
		req.Header.Set("Content-Type", "application/x-www-form-urlencoded")
		rec := httptest.NewRecorder()
		h.ServeHTTP(rec, req)
		var out map[string]any
		_ = json.Unmarshal(rec.Body.Bytes(), &out)
		return out
	}
	if out := send("0", "", false, "0"); out["error"] != float64(clickSignFailed) {
		t.Fatalf("bad sign: %v", out)
	}
	out := send("0", "", true, "0")
	if out["error"] != float64(clickOK) {
		t.Fatalf("prepare: %v", out)
	}
	prep := strconv.FormatInt(int64(out["merchant_prepare_id"].(float64)), 10)
	if out := send("1", prep, true, "0"); out["error"] != float64(clickOK) {
		t.Fatalf("complete: %v", out)
	}
	if out := send("1", prep, true, "0"); out["error"] != float64(clickAlreadyPaid) {
		t.Fatalf("complete again: %v", out)
	}
	if bal, _ := credits.Balance(sys, ws); bal < 100 {
		// 100 credits bought; the month's fee may have been taken from them.
		t.Logf("balance %d", bal)
	}
	p, _ := credits.PaymentByID(sys, id)
	if p.State != postgres.PaymentPaid {
		t.Fatalf("payment %+v", p)
	}
}

func TestSlotsAndGrants(t *testing.T) {
	s, credits, ws, ctx := setup(t)
	sys := domain.System(ctx)
	if _, err := s.SetSlots(sys, ws, 9, 0); err == nil {
		t.Fatal("over the max slots")
	}
	// Paid this month: a slot more costs the rest of the month now.
	pgtest.Exec(t, pgtest.Open(t), `UPDATE workspaces SET paid_until = now() + interval '30 days' WHERE id = $1`, ws)
	var be *Error
	if _, err := s.SetSlots(sys, ws, 2, 0); !errors.As(err, &be) || !be.Payment {
		t.Fatalf("no credits for a slot: %v", err)
	}
	if _, err := s.Grant(sys, ws, 5000, "test", 0); err != nil {
		t.Fatal(err)
	}
	v, err := s.SetSlots(sys, ws, 2, 0)
	if err != nil || v.Slots != 2 || v.Balance >= 5000 {
		t.Fatalf("slots %+v %v", v, err)
	}
	if v.MonthlyUZS != 300000+190000 {
		t.Fatalf("monthly %d", v.MonthlyUZS)
	}
	if bal, _ := credits.Balance(sys, ws); bal != v.Balance {
		t.Fatalf("balance %d vs view %d", bal, v.Balance)
	}
}

func TestSelfHostedSlotsAreFree(t *testing.T) {
	_, credits, ws, ctx := setup(t)
	sys := domain.System(ctx)
	s := New(Config{MaxSlots: 5}, credits, postgres.NewWorkspaces(pgtest.Open(t)), postgres.NewAgent(pgtest.Open(t)),
		slog.New(slog.NewTextHandler(io.Discard, nil)))
	v, err := s.SetSlots(sys, ws, 4, 0)
	if err != nil || v.Slots != 4 || v.Balance != 0 {
		t.Fatalf("slots %+v %v", v, err)
	}
	if _, err := s.SetSlots(sys, ws, 6, 0); err == nil {
		t.Fatal("over the max slots")
	}
}

func TestMonthlyUSD(t *testing.T) {
	s := &Service{cfg: Config{WorkspaceUSD: 10, SlotUSD: 15, MemberUSD: 5, IncludedMembers: 5}}
	for _, c := range []struct {
		slots, members int
		want           float64
	}{
		{1, 1, 10},          // the plan alone
		{3, 5, 40},          // two extra slots
		{1, 7, 20},          // two members above the five included
		{2, 6, 10 + 15 + 5}, // both
	} {
		if got := s.MonthlyUSD(c.slots, c.members); got != c.want {
			t.Errorf("%d slots, %d members: $%v, want $%v", c.slots, c.members, got, c.want)
		}
	}
}

// TestFreeCreditsOweNothing: a run its member's free credits paid in full
// owes the workspace nothing, so an empty workspace balance must not stop
// it (it did: 0 owed >= 0 balance read as "ran out of credits").
func TestFreeCreditsOweNothing(t *testing.T) {
	s, _, ws, ctx := setup(t)
	sys := domain.System(ctx)
	store := postgres.NewAgent(pgtest.Open(t))
	tk, err := store.CreateTicket(ctx, domain.Ticket{Key: "F-1", Source: domain.SourceLocal, Title: "t", State: domain.StateNew, Priority: "medium",
		Kind: domain.KindPlan, AfterApprove: "pr"}, domain.Event{TicketKey: "F-1", Type: domain.EventTicketCreated})
	if err != nil {
		t.Fatal(err)
	}
	_, run, ok, err := store.ClaimTicket(ctx, tk.ID, "main")
	if err != nil || !ok {
		t.Fatal(err)
	}
	if err := store.RecordClaudeCall(ctx, domain.ClaudeCall{RunID: run.ID, ModelStage: domain.ModelAnalyze, Model: "muse:muse-spark-1.3",
		Usage: domain.TokenUsage{Input: 1, CostUSD: 0.36}}); err != nil {
		t.Fatal(err)
	}
	s.SetFree(func(context.Context, int64) (float64, error) { return 0.36, nil })
	if ok, why := s.Within(sys, ws, run.ID); !ok {
		t.Fatalf("a run free credits paid in full was stopped: %s", why)
	}
}
