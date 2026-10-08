// Package pgtest sets up the test database (AGNTS_TEST_DATABASE_URL) for
// tests: migrated, and with users and workspaces to act in.
package pgtest

import (
	"context"
	"io"
	"log/slog"
	"os"
	"testing"

	"github.com/jackc/pgx/v5/pgxpool"

	"agnts/internal/domain"
	"agnts/internal/store/postgres"
)

// Open connects to the test database and migrates it, or skips the test
// when AGNTS_TEST_DATABASE_URL is not set.
func Open(t *testing.T) *pgxpool.Pool {
	t.Helper()
	dsn := os.Getenv("AGNTS_TEST_DATABASE_URL")
	if dsn == "" {
		t.Skip("AGNTS_TEST_DATABASE_URL not set")
	}
	ctx := context.Background()
	pool, err := postgres.Open(ctx, dsn)
	if err != nil {
		t.Fatal(err)
	}
	t.Cleanup(pool.Close)
	if err := postgres.Migrate(ctx, pool, "up", slog.New(slog.NewTextHandler(io.Discard, nil))); err != nil {
		t.Fatal(err)
	}
	if _, err := postgres.DetectTenantRole(ctx, pool); err != nil {
		t.Fatal(err)
	}
	return pool
}

// Exec runs SQL as the system (every workspace's rows), failing the test
// on error.
func Exec(t *testing.T, pool *pgxpool.Pool, sql string, args ...any) {
	t.Helper()
	if _, err := pool.Exec(domain.System(context.Background()), sql, args...); err != nil {
		t.Fatalf("%s: %v", sql, err)
	}
}

// User returns the id of a user with this username, creating it.
func User(t *testing.T, pool *pgxpool.Pool, username string) int64 {
	t.Helper()
	var id int64
	err := pool.QueryRow(domain.System(context.Background()), `INSERT INTO users (username, password_hash, totp_secret_enc)
		VALUES ($1, 'h', NULL) ON CONFLICT (username) DO UPDATE SET username = EXCLUDED.username RETURNING id`, username).Scan(&id)
	if err != nil {
		t.Fatal(err)
	}
	return id
}

// Workspace returns a context acting in a workspace with this slug,
// creating it (owned by a user named after it) when needed, and its id.
func Workspace(t *testing.T, pool *pgxpool.Pool, slug string) (context.Context, int64) {
	t.Helper()
	owner := User(t, pool, slug+"-owner")
	var id int64
	err := pool.QueryRow(domain.System(context.Background()), `INSERT INTO workspaces (slug, name, owner_id, slots)
		VALUES ($1, $1, $2, 1) ON CONFLICT (slug) DO UPDATE SET deleted_at = NULL, suspended_at = NULL RETURNING id`, slug, owner).Scan(&id)
	if err != nil {
		t.Fatal(err)
	}
	Exec(t, pool, `INSERT INTO memberships (workspace_id, user_id, role) VALUES ($1, $2, 'owner') ON CONFLICT DO NOTHING`, id, owner)
	return domain.WithWorkspace(context.Background(), id), id
}

// Reset empties the tables tests write to, in every workspace.
func Reset(t *testing.T, pool *pgxpool.Pool) {
	t.Helper()
	Exec(t, pool, `TRUNCATE tickets, runs, results, questions, events, repositories, webhook_deliveries, translations,
		rules, lessons, ticket_relations, ticket_suggestions, claude_calls, attachments, integrations, settings,
		pending_actions, telegram_messages, credit_ledger, payments, claude_connections, usage_snapshots RESTART IDENTITY CASCADE`)
}
