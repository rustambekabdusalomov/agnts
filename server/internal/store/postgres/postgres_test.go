package postgres

import (
	"context"
	"errors"
	"fmt"
	"io"
	"log/slog"
	"os"
	"testing"
	"time"

	"agnts/internal/domain"
)

// These tests need a disposable database:
//
//	AGNTS_TEST_DATABASE_URL=postgres://hiro:hiro@localhost:5442/hiro_test?sslmode=disable go test ./...
func testDB(t *testing.T) (*Users, *Sessions) {
	t.Helper()
	url := os.Getenv("AGNTS_TEST_DATABASE_URL")
	if url == "" {
		t.Skip("AGNTS_TEST_DATABASE_URL not set")
	}
	ctx := domain.System(context.Background())
	pool, err := Open(ctx, url)
	if err != nil {
		t.Fatal(err)
	}
	t.Cleanup(pool.Close)
	log := slog.New(slog.NewTextHandler(io.Discard, nil))
	// Down then up proves both directions of every migration work. Going
	// back past workspaces needs at most one workspace.
	if err := Migrate(ctx, pool, "up", log); err != nil {
		t.Fatal(err)
	}
	if _, err := pool.Exec(ctx, `TRUNCATE workspaces CASCADE`); err != nil {
		t.Fatal(err)
	}
	for {
		var v int64
		if err := pool.QueryRow(ctx, `SELECT COALESCE(MAX(version_id), 0) FROM goose_db_version WHERE is_applied`).Scan(&v); err != nil {
			t.Fatal(err)
		}
		if v == 0 {
			break
		}
		if err := Migrate(ctx, pool, "down", log); err != nil {
			t.Fatal(err)
		}
	}
	if err := Migrate(ctx, pool, "up", log); err != nil {
		t.Fatal(err)
	}
	if _, err := DetectTenantRole(ctx, pool); err != nil {
		t.Fatal(err)
	}
	return NewUsers(pool), NewSessions(pool)
}

var wsSeq int

// testWS returns a context acting in a fresh workspace of the test
// database, and the workspace's id.
func testWS(t *testing.T, users *Users) (context.Context, int64) {
	t.Helper()
	sys := domain.System(context.Background())
	wsSeq++
	owner, err := users.Create(sys, domain.User{Username: fmt.Sprintf("owner-%d-%s", wsSeq, t.Name()), PasswordHash: "h"})
	if err != nil {
		t.Fatal(err)
	}
	w, err := NewWorkspaces(users.db).Create(sys, NewWorkspace{Name: t.Name(), OwnerID: owner.ID})
	if err != nil {
		t.Fatal(err)
	}
	return domain.WithWorkspace(context.Background(), w.ID), w.ID
}

func TestUsersAndSessions(t *testing.T) {
	users, sessions := testDB(t)
	ctx := context.Background()

	u, err := users.Create(ctx, domain.User{Username: "rustam", PasswordHash: "h", TOTPSecretEnc: []byte{1, 2}})
	if err != nil {
		t.Fatal(err)
	}
	if _, err := users.Create(ctx, domain.User{Username: "rustam", PasswordHash: "h", TOTPSecretEnc: []byte{1}}); !errors.Is(err, domain.ErrConflict) {
		t.Fatalf("duplicate username: %v", err)
	}
	if _, err := users.ByUsername(ctx, "nobody"); !errors.Is(err, domain.ErrNotFound) {
		t.Fatalf("missing user: %v", err)
	}
	if ok, _ := users.AdvanceTOTPStep(ctx, u.ID, 10); !ok {
		t.Fatal("first step not accepted")
	}
	if ok, _ := users.AdvanceTOTPStep(ctx, u.ID, 10); ok {
		t.Fatal("same step accepted twice")
	}

	now := time.Now().UTC().Truncate(time.Microsecond)
	s := domain.Session{TokenHash: []byte("hash"), UserID: u.ID, Client: domain.ClientWeb, CreatedAt: now, ExpiresAt: now.Add(time.Hour)}
	if err := sessions.Create(ctx, s); err != nil {
		t.Fatal(err)
	}
	got, err := sessions.ByTokenHash(ctx, []byte("hash"))
	if err != nil || got.UserID != u.ID || got.Client != domain.ClientWeb {
		t.Fatalf("session: %+v %v", got, err)
	}
	if n, _ := sessions.DeleteExpired(ctx, now.Add(2*time.Hour)); n != 1 {
		t.Fatalf("expired sessions deleted: %d", n)
	}
}

func TestPendingDevicesTelegram(t *testing.T) {
	users, _ := testDB(t)
	ctx, ws := testWS(t, users)
	_ = ws
	s := NewAgent(users.db)
	_, _ = s.db.Exec(domain.System(ctx), `TRUNCATE pending_actions, devices, telegram_messages`)

	exp := time.Now().Add(10 * time.Minute)
	if err := s.CreatePending(ctx, PendingAction{ID: "a1", Origin: domain.OriginMCP, Tool: "approve", TicketKey: "PAY-1",
		Args: map[string]any{"key": "PAY-1"}, Summary: "Approve PAY-1", ExpiresAt: exp}); err != nil {
		t.Fatal(err)
	}
	if _, err := s.ConfirmPending(ctx, "a1", domain.OriginTelegram); !errors.Is(err, ErrExpired) {
		t.Fatal("confirmed from a different origin")
	}
	a, err := s.ConfirmPending(ctx, "a1", domain.OriginMCP)
	if err != nil || a.Tool != "approve" || a.Args["key"] != "PAY-1" {
		t.Fatalf("confirm: %+v %v", a, err)
	}
	if _, err := s.ConfirmPending(ctx, "a1", domain.OriginMCP); !errors.Is(err, ErrExpired) {
		t.Fatal("confirmed twice")
	}
	_ = s.CreatePending(ctx, PendingAction{ID: "a2", Origin: domain.OriginMCP, Tool: "reject", ExpiresAt: time.Now().Add(-time.Second)})
	if _, err := s.ConfirmPending(ctx, "a2", domain.OriginMCP); !errors.Is(err, ErrExpired) {
		t.Fatal("expired action confirmed")
	}

	u, err := users.Create(ctx, domain.User{Username: "phone-owner", PasswordHash: "h", TOTPSecretEnc: []byte{1}})
	if err != nil {
		t.Fatal(err)
	}
	if err := s.RegisterDevice(ctx, Device{UserID: u.ID, Platform: "ios", FCMToken: "tok", AppVersion: "1"}); err != nil {
		t.Fatal(err)
	}
	if err := s.RegisterDevice(ctx, Device{UserID: u.ID, Platform: "ios", FCMToken: "tok", AppVersion: "2"}); err != nil {
		t.Fatal(err)
	}
	if ds, _ := s.Devices(ctx, ws); len(ds) != 0 {
		t.Fatalf("a non-member's device: %+v", ds)
	}
	if err := NewWorkspaces(users.db).AddMember(domain.System(ctx), ws, u.ID, domain.RoleUser); err != nil {
		t.Fatal(err)
	}
	ds, _ := s.Devices(ctx, ws)
	if len(ds) != 1 || ds[0].AppVersion != "2" {
		t.Fatalf("devices: %+v", ds)
	}

	// Pushes about a ticket go to its owner: the member, else the
	// workspace's owner for a ticket from a webhook.
	if _, err := s.CreateTicket(ctx, domain.Ticket{Key: "PAY-9", Source: domain.SourceLocal, Title: "x", Priority: "high",
		State: domain.StateNew, ResumeState: domain.StateNew, AfterApprove: "pr", Kind: domain.KindCode, MemberID: &u.ID},
		domain.Event{Type: domain.EventTicketCreated}); err != nil {
		t.Fatal(err)
	}
	if owner, ds, err := s.OwnerDevices(ctx, ws, "PAY-9"); err != nil || owner != u.ID || len(ds) != 1 {
		t.Fatalf("owner devices: %d %+v %v", owner, ds, err)
	}
	if _, err := s.CreateTicket(ctx, domain.Ticket{Key: "PAY-10", Source: domain.SourceJira, Title: "x", Priority: "high",
		State: domain.StateNew, ResumeState: domain.StateNew, AfterApprove: "pr", Kind: domain.KindCode},
		domain.Event{Type: domain.EventTicketCreated}); err != nil {
		t.Fatal(err)
	}
	if owner, ds, err := s.OwnerDevices(ctx, ws, "PAY-10"); err != nil || owner == 0 || owner == u.ID || len(ds) != 0 {
		t.Fatalf("webhook ticket: %d %+v %v", owner, ds, err)
	}
	if owner, ds, err := s.OwnerDevices(ctx, ws, "GONE-1"); err != nil || owner != 0 || ds != nil {
		t.Fatalf("missing ticket: %d %+v %v", owner, ds, err)
	}

	ref := int64(7)
	if err := s.SaveTelegramMessage(ctx, TelegramMessage{ChatID: 1, MessageID: 2, TicketKey: "PAY-1", Kind: "question", Ref: &ref}); err != nil {
		t.Fatal(err)
	}
	m, err := s.TelegramMessage(ctx, 1, 2)
	if err != nil || m.Kind != "question" || m.Ref == nil || *m.Ref != 7 {
		t.Fatalf("telegram message: %+v %v", m, err)
	}
	if c, _ := s.Cursor(ctx, "x"); c != -1 {
		t.Fatal("missing cursor should be -1")
	}
	_ = s.SetCursor(ctx, "x", 42)
	if c, _ := s.Cursor(ctx, "x"); c != 42 {
		t.Fatal("cursor round trip")
	}
}

func TestAnalytics(t *testing.T) {
	users, _ := testDB(t)
	ctx, ws := testWS(t, users)
	_ = ws
	s := NewAgent(users.db)
	_, _ = s.db.Exec(domain.System(ctx), `TRUNCATE tickets, runs, events, repositories, usage_snapshots RESTART IDENTITY CASCADE`)

	repo, err := s.SaveRepository(ctx, domain.Repository{Name: "api", Kind: "jira", Provider: "github", CloneURL: "https://github.com/a/api.git", DefaultBranch: "main"})
	if err != nil {
		t.Fatal(err)
	}
	base := time.Now().UTC().Add(-3 * time.Hour)
	at := func(m int) time.Time { return base.Add(time.Duration(m) * time.Minute) }
	ev := func(key, typ, to string, m int, origin string) {
		data := `{}`
		if to != "" {
			data = `{"to":"` + to + `"}`
		}
		if _, err := s.db.Exec(ctx, `INSERT INTO events (ticket_key, type, origin, data, created_at) VALUES ($1, $2, $3, $4::jsonb, $5)`,
			key, typ, origin, data, at(m)); err != nil {
			t.Fatal(err)
		}
	}
	// PAY-1: analysed 10 min, waited 20 min for answers, coded 30, reviewed 15, pushed: first try.
	for _, k := range []string{"PAY-1", "PAY-2"} {
		if _, err := s.db.Exec(ctx, `INSERT INTO tickets (key, source, repo_id, title, state, revision, turns, updated_at)
			VALUES ($1, 'jira', $2, 't', $3, 0, 12, now())`, k, repo.ID, map[string]string{"PAY-1": "done", "PAY-2": "failed"}[k]); err != nil {
			t.Fatal(err)
		}
	}
	ev("PAY-1", "ticket_created", "", 0, "webhook")
	ev("PAY-1", "state_changed", "analyzing", 0, "system")
	ev("PAY-1", "state_changed", "waiting_for_answers", 10, "system")
	ev("PAY-1", "answered", "coding", 30, "web")
	ev("PAY-1", "state_changed", "waiting_for_review", 60, "system")
	ev("PAY-1", "state_changed", "pushing", 75, "web")
	ev("PAY-1", "state_changed", "done", 76, "system")
	ev("PAY-2", "ticket_created", "", 5, "webhook")
	ev("PAY-2", "state_changed", "analyzing", 5, "system")
	ev("PAY-2", "state_changed", "failed", 15, "system")
	if _, err := s.db.Exec(ctx, `INSERT INTO runs (ticket_id, stage, model, started_at, finished_at, turns, exit_reason) VALUES
		((SELECT id FROM tickets WHERE key='PAY-1'), 'code', 'opus', $1, $2, 12, 'ok'),
		((SELECT id FROM tickets WHERE key='PAY-2'), 'analyze', 'sonnet', $1, $2, 3, 'checks_failed')`, at(30), at(60)); err != nil {
		t.Fatal(err)
	}
	// PAY-1's coding used prompts v1 and needed one fix; agnts's review found
	// a major problem and sent it back; the analysis predicted half the files.
	if _, err := s.db.Exec(ctx, `UPDATE runs SET prompt_version = 'v1', fix_attempts = 1 WHERE stage = 'code'`); err != nil {
		t.Fatal(err)
	}
	for _, q := range []string{
		`INSERT INTO events (ticket_key, type, origin, data, created_at) VALUES ('PAY-1', 'review_done', 'system', '{"counts":{"major":1,"minor":2}}', $1)`,
		`INSERT INTO events (ticket_key, type, origin, data, created_at) VALUES ('PAY-1', 'feedback', 'system', '{}', $1)`,
		`INSERT INTO events (ticket_key, type, origin, data, created_at) VALUES ('PAY-1', 'footprint_checked', 'system', '{"recall":0.5}', $1)`,
		`INSERT INTO events (ticket_key, type, origin, data, created_at) VALUES ('PAY-1', 'red_flags', 'system', '{"count":2}', $1)`,
	} {
		if _, err := s.db.Exec(ctx, q, at(61)); err != nil {
			t.Fatal(err)
		}
	}
	if _, err := s.db.Exec(ctx, `INSERT INTO usage_snapshots (five_hour, created_at) VALUES (0.3, $1), (0.7, $2)`, at(10), at(70)); err != nil {
		t.Fatal(err)
	}
	// Two coding calls on opus, one analysis call on sonnet.
	if _, err := s.db.Exec(ctx, `INSERT INTO claude_calls (run_id, ticket_id, model_stage, model, input_tokens, output_tokens, cache_read_tokens, cost_usd, created_at)
		SELECT id, ticket_id, CASE stage WHEN 'code' THEN 'coding' ELSE stage END, model, 1000, 200, 5000, CASE model WHEN 'opus' THEN 1.5 ELSE 0.25 END, $1
		FROM runs, generate_series(1, CASE stage WHEN 'code' THEN 2 ELSE 1 END)`, at(40)); err != nil {
		t.Fatal(err)
	}

	a, err := s.Analytics(ctx, 7, time.UTC)
	if err != nil {
		t.Fatal(err)
	}
	c := a.Current
	if c.Picked != 2 || c.Pushed != 1 || c.Stopped != 1 || c.FirstTry != 1 {
		t.Fatalf("period: %+v", c)
	}
	if len(a.Days) != 7 {
		t.Fatalf("days: %d", len(a.Days))
	}
	if a.Steps["waiting_for_answers"] < 19.9 || a.Steps["waiting_for_answers"] > 20.1 || a.Steps["coding"] < 29.9 {
		t.Fatalf("steps: %v", a.Steps)
	}
	if a.Stops["tests"] != 1 {
		t.Fatalf("stops: %v", a.Stops)
	}
	if len(a.Models) != 2 || len(a.Repos) != 1 || a.Repos[0].Done != 1 || a.Repos[0].Finished != 2 {
		t.Fatalf("models %+v repos %+v", a.Models, a.Repos)
	}
	var peak float64
	for _, d := range a.Days {
		if d.PeakUsage != nil && *d.PeakUsage > peak {
			peak = *d.PeakUsage
		}
	}
	if peak < 0.69 {
		t.Fatalf("peak usage %v", peak)
	}
	// agnts working (analyze 10 + coding 30 + pushing 1 = 41 min for PAY-1, 10 for PAY-2) averages ~25.5.
	if c.AgntsMin < 25 || c.AgntsMin > 26 || c.WaitMin < 17 || c.WaitMin > 18 {
		t.Fatalf("time: agnts %.1f wait %.1f", c.AgntsMin, c.WaitMin)
	}
	if c.Spend.Input != 3000 || c.Spend.Output != 600 || c.Spend.CacheRead != 15000 || c.Spend.CostUSD < 3.24 || c.Spend.CostUSD > 3.26 {
		t.Fatalf("period spend: %+v", c.Spend)
	}
	if a.Prev.Spend.Input != 0 {
		t.Fatalf("previous spend: %+v", a.Prev.Spend)
	}
	var dayIn int64
	for _, d := range a.Days {
		dayIn += d.Spend.Input
	}
	if dayIn != 3000 {
		t.Fatalf("daily spend input %d", dayIn)
	}
	if len(a.Spend) != 2 || a.Spend[0].ModelStage != "coding" || a.Spend[0].Calls != 2 || a.Spend[1].Model != "sonnet" {
		t.Fatalf("spend by stage: %+v", a.Spend)
	}
	// Only PAY-1 had a coding run: done first time (agnts's own feedback
	// does not count against it).
	want := QualityStats{PromptVersion: "v1", Tickets: 1, ReachedReview: 1, Done: 1, FirstTry: 1, FixAttempts: 1,
		Serious: 1, FootprintHit: 0.5, RedFlags: 2, SelfFixes: 1, Tokens: 12400}
	if len(a.Quality) != 1 || a.Quality[0] != want {
		t.Fatalf("quality: %+v", a.Quality)
	}

	// The harness: agnts-guard refused two edits, the stop gate caught a
	// failure (but the checks still needed a fix, so no save), the run
	// stalled once, the fix was proven, one of two findings was adopted,
	// and the ticket was in the fact check group.
	for _, q := range []string{
		`UPDATE runs SET harness = '{"guard":{"blocks":{"secret":1,"skipped_test":1},"stopFailures":1},"stalls":[{"reason":"no_edits"}],"factCheck":true}' WHERE stage = 'code'`,
		`INSERT INTO results (run_id, harness) SELECT id, '{"proof":{"status":"proven"}}' FROM runs WHERE stage = 'code'`,
		`INSERT INTO runs (ticket_id, stage, model, started_at, finished_at, turns, exit_reason) VALUES ((SELECT id FROM tickets WHERE key='PAY-1'), 'review', 'opus', now(), now(), 3, 'ok')`,
		`INSERT INTO results (run_id, summary) SELECT id, '{"findings":[{"title":"a","adopted":true},{"title":"b"}]}' FROM runs WHERE stage = 'review'`,
	} {
		if _, err := s.db.Exec(ctx, q); err != nil {
			t.Fatalf("%s: %v", q, err)
		}
	}
	a, err = s.Analytics(ctx, 7, time.UTC)
	if err != nil {
		t.Fatal(err)
	}
	q := a.Quality[0]
	if q.GuardBlocks != 2 || q.StopSaves != 0 || q.Stalls != 1 || q.ProofDue != 1 || q.Proven != 1 || q.Findings != 2 || q.Adopted != 1 ||
		q.FactCheck != 1 || q.FactCheckFirst != 1 {
		t.Fatalf("harness quality: %+v", q)
	}
}

func TestClaudeCalls(t *testing.T) {
	users, _ := testDB(t)
	ctx, ws := testWS(t, users)
	_ = ws
	s := NewAgent(users.db)
	if _, err := s.db.Exec(ctx, `INSERT INTO tickets (key, source, title, state, revision, turns, updated_at)
		VALUES ('PAY-1', 'jira', 't', 'coding', 0, 0, now())`); err != nil {
		t.Fatal(err)
	}
	var runID, ticketID int64
	if err := s.db.QueryRow(ctx, `INSERT INTO runs (ticket_id, stage, model) SELECT id, 'code', 'opus' FROM tickets WHERE key = 'PAY-1'
		RETURNING id, ticket_id`).Scan(&runID, &ticketID); err != nil {
		t.Fatal(err)
	}
	for _, c := range []domain.ClaudeCall{
		{ModelStage: domain.ModelCoding, Model: "opus", Turns: 4, Usage: domain.TokenUsage{Input: 10, Output: 5, CacheRead: 100, CacheWrite: 20, CostUSD: 0.5}},
		{ModelStage: domain.ModelRetry, Model: "opus", Turns: 2, Usage: domain.TokenUsage{Input: 1, Output: 1, CostUSD: 0.25}},
		{ModelStage: domain.ModelRetry, Model: "sonnet", Turns: 1, Usage: domain.TokenUsage{Input: 2}, Partial: true},
		{ModelStage: domain.ModelRetry, Model: "opus", Turns: 3, Usage: domain.TokenUsage{Input: 3, Output: 3, CostUSD: 0.125}},
	} {
		c.RunID = runID
		if err := s.RecordClaudeCall(ctx, c); err != nil {
			t.Fatal(err)
		}
	}
	if err := s.RecordClaudeCall(ctx, domain.ClaudeCall{RunID: runID + 100, ModelStage: domain.ModelCoding}); !errors.Is(err, domain.ErrNotFound) {
		t.Fatalf("unknown run: %v", err)
	}

	got, err := s.TicketUsage(ctx, ticketID)
	if err != nil {
		t.Fatal(err)
	}
	want := []domain.StageUsage{
		{ModelStage: domain.ModelCoding, Model: "opus", Calls: 1, Turns: 4, Usage: domain.TokenUsage{Input: 10, Output: 5, CacheRead: 100, CacheWrite: 20, CostUSD: 0.5}},
		{ModelStage: domain.ModelRetry, Model: "opus", Calls: 2, Turns: 5, Usage: domain.TokenUsage{Input: 4, Output: 4, CostUSD: 0.375}},
		{ModelStage: domain.ModelRetry, Model: "sonnet", Calls: 1, Turns: 1, Partial: true, Usage: domain.TokenUsage{Input: 2}},
	}
	if len(got) != len(want) {
		t.Fatalf("usage %+v, want %+v", got, want)
	}
	for i := range want {
		if got[i] != want[i] {
			t.Fatalf("row %d: %+v, want %+v", i, got[i], want[i])
		}
	}
	if got, err := s.TicketUsage(ctx, ticketID+100); err != nil || len(got) != 0 {
		t.Fatalf("no calls: %+v %v", got, err)
	}
}

func TestTopTicketSpend(t *testing.T) {
	users, _ := testDB(t)
	ctx, ws := testWS(t, users)
	_ = ws
	s := NewAgent(users.db)
	repo, err := s.SaveRepository(ctx, domain.Repository{Name: "api", Kind: "jira", Provider: "github", CloneURL: "https://github.com/a/api.git", DefaultBranch: "main"})
	if err != nil {
		t.Fatal(err)
	}
	runs := map[string]int64{}
	for _, k := range []string{"PAY-1", "PAY-2", "PAY-3", "PAY-4"} {
		var run int64
		if err := s.db.QueryRow(ctx, `WITH tk AS (INSERT INTO tickets (key, source, repo_id, title, kind, state, revision, turns, updated_at)
				VALUES ($1, 'jira', $2, 'title '||$1, 'code', 'done', 0, 0, now()) RETURNING id)
			INSERT INTO runs (ticket_id, stage, model) SELECT id, 'code', 'opus' FROM tk RETURNING id`, k, repo.ID).Scan(&run); err != nil {
			t.Fatal(err)
		}
		runs[k] = run
	}
	call := func(key, stage string, in, out int64, cost float64, ago time.Duration) {
		t.Helper()
		if _, err := s.db.Exec(ctx, `INSERT INTO claude_calls (run_id, ticket_id, model_stage, model, input_tokens, output_tokens, cache_read_tokens, cost_usd, created_at)
			SELECT id, ticket_id, $2, 'opus', $3, $4, 10, $5, now() - $6::interval FROM runs WHERE id = $1`,
			runs[key], stage, in, out, cost, ago.String()); err != nil {
			t.Fatal(err)
		}
	}
	call("PAY-1", "analyze", 100, 10, 0.25, time.Hour)
	call("PAY-1", "coding", 200, 20, 1.5, time.Hour)
	call("PAY-1", "retry", 50, 5, 0.5, time.Hour)
	call("PAY-2", "coding", 500, 50, 0.75, time.Hour)
	call("PAY-3", "retry", 900, 90, 0, time.Hour) // cut off: no cost, ranks by tokens
	call("PAY-4", "coding", 9000, 900, 9, 48*time.Hour)

	total, got, err := s.TopTicketSpend(ctx, time.Now().Add(-24*time.Hour), 10)
	if err != nil {
		t.Fatal(err)
	}
	if want := (domain.TokenUsage{Input: 1750, Output: 175, CacheRead: 50, CostUSD: 3}); total != want {
		t.Fatalf("total %+v, want %+v", total, want)
	}
	if len(got) != 3 {
		t.Fatalf("tickets %+v", got)
	}
	if got[0].Key != "PAY-1" || got[0].Calls != 3 || got[0].TopStage != "coding" || got[0].Usage.CostUSD != 2.25 ||
		got[0].Usage.Input != 350 || got[0].RepoName != "api" || got[0].Title != "title PAY-1" || got[0].State != domain.StateDone {
		t.Fatalf("first: %+v", got[0])
	}
	if got[1].Key != "PAY-2" || got[2].Key != "PAY-3" || got[2].TopStage != "retry" {
		t.Fatalf("order: %s %s %+v", got[1].Key, got[2].Key, got[2])
	}

	_, got, err = s.TopTicketSpend(ctx, time.Now().Add(-72*time.Hour), 1)
	if err != nil || len(got) != 1 || got[0].Key != "PAY-4" {
		t.Fatalf("wider period, limit 1: %+v %v", got, err)
	}
}
