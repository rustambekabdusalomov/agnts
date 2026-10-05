package postgres

import (
	"context"
	"errors"
	"io"
	"log/slog"
	"os"
	"testing"
	"time"

	"hiro/internal/domain"
)

// These tests need a disposable database:
//
//	HIRO_TEST_DATABASE_URL=postgres://hiro:hiro@localhost:5442/hiro_test?sslmode=disable go test ./...
func testDB(t *testing.T) (*Users, *Sessions) {
	t.Helper()
	url := os.Getenv("HIRO_TEST_DATABASE_URL")
	if url == "" {
		t.Skip("HIRO_TEST_DATABASE_URL not set")
	}
	ctx := context.Background()
	pool, err := Open(ctx, url)
	if err != nil {
		t.Fatal(err)
	}
	t.Cleanup(pool.Close)
	log := slog.New(slog.NewTextHandler(io.Discard, nil))
	// Down then up proves both directions of every migration work.
	if err := Migrate(ctx, pool, "up", log); err != nil {
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
	return NewUsers(pool), NewSessions(pool)
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
	ctx := context.Background()
	s := NewAgent(users.db)
	_, _ = s.db.Exec(ctx, `TRUNCATE pending_actions, devices, telegram_messages`)

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
	ds, _ := s.Devices(ctx)
	if len(ds) != 1 || ds[0].AppVersion != "2" {
		t.Fatalf("devices: %+v", ds)
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
	ctx := context.Background()
	s := NewAgent(users.db)
	_, _ = s.db.Exec(ctx, `TRUNCATE tickets, runs, events, repositories, usage_snapshots RESTART IDENTITY CASCADE`)

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
	if _, err := s.db.Exec(ctx, `INSERT INTO usage_snapshots (five_hour, created_at) VALUES (0.3, $1), (0.7, $2)`, at(10), at(70)); err != nil {
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
	// hiro working (analyze 10 + coding 30 + pushing 1 = 41 min for PAY-1, 10 for PAY-2) averages ~25.5.
	if c.HiroMin < 25 || c.HiroMin > 26 || c.WaitMin < 17 || c.WaitMin > 18 {
		t.Fatalf("time: hiro %.1f wait %.1f", c.HiroMin, c.WaitMin)
	}
}
