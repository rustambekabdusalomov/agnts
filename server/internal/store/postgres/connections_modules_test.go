package postgres_test

import (
	"context"
	"errors"
	"testing"

	"agnts/internal/domain"
	"agnts/internal/secret"
	"agnts/internal/store/postgres"
	"agnts/internal/store/postgres/pgtest"
)

// A person and a workspace each hold one account per module, side by side.
func TestConnectionsPerModule(t *testing.T) {
	pool := pgtest.Open(t)
	pgtest.Reset(t, pool)
	box, _ := secret.NewBox(make([]byte, 32))
	c := postgres.NewClaudeConnections(pool, box)
	ctx := context.Background()
	ann := pgtest.User(t, pool, "conn-ann")
	_, ws := pgtest.Workspace(t, pool, "conn-ws")

	if _, err := c.Put(ctx, 0, ann, postgres.ClaudeAPIKey, "sk-ant-api-ann", "Anthropic API key"); err != nil {
		t.Fatal(err)
	}
	if _, err := c.Put(ctx, 0, ann, postgres.MuseAPIKey, "LLM_ann", "Meta Model API key"); err != nil {
		t.Fatal(err)
	}
	cl, err := c.ForUser(ctx, ann, "claude")
	if err != nil || cl.Token != "sk-ant-api-ann" {
		t.Fatalf("claude = %+v, %v", cl, err)
	}
	mu, err := c.ForUser(ctx, ann, "muse")
	if err != nil || mu.Token != "LLM_ann" {
		t.Fatalf("muse = %+v, %v", mu, err)
	}
	// Replacing one module's account keeps the other's.
	if _, err := c.Put(ctx, 0, ann, postgres.MuseLogin, `{"login":1}`, "Meta account"); err != nil {
		t.Fatal(err)
	}
	if got, _ := c.ForUser(ctx, ann, "claude"); got.ID != cl.ID {
		t.Fatal("replacing the Muse account replaced the Claude one")
	}
	// Disconnecting one module keeps the other.
	if err := c.DeleteUser(ctx, ann, "muse"); err != nil {
		t.Fatal(err)
	}
	if _, err := c.ForUser(ctx, ann, "muse"); !errors.Is(err, domain.ErrNotFound) {
		t.Fatalf("muse after delete: %v", err)
	}
	if _, err := c.ForUser(ctx, ann, "claude"); err != nil {
		t.Fatalf("claude after deleting muse: %v", err)
	}

	// The workspace's shared accounts, likewise.
	wctx := domain.WithWorkspace(ctx, ws)
	if _, err := c.Put(wctx, ws, 0, postgres.ClaudeSubscription, "sk-ant-oat-ws", "Claude subscription"); err != nil {
		t.Fatal(err)
	}
	if _, err := c.Put(wctx, ws, 0, postgres.MuseAPIKey, "LLM_ws", "Meta Model API key"); err != nil {
		t.Fatal(err)
	}
	if got, err := c.ForWorkspace(wctx, ws, "muse"); err != nil || got.Token != "LLM_ws" {
		t.Fatalf("workspace muse = %+v, %v", got, err)
	}
	if got, err := c.ForWorkspace(wctx, ws, "claude"); err != nil || got.Token != "sk-ant-oat-ws" {
		t.Fatalf("workspace claude = %+v, %v", got, err)
	}
	pgtest.Exec(t, pool, `INSERT INTO memberships (workspace_id, user_id, role) VALUES ($1, $2, 'user') ON CONFLICT DO NOTHING`, ws, ann)
	if m, err := c.MemberConnections(wctx, ws, "claude"); err != nil || len(m) != 1 {
		t.Fatalf("members with claude = %v, %v", m, err)
	}
	if m, _ := c.MemberConnections(wctx, ws, "muse"); len(m) != 0 {
		t.Fatalf("members with muse = %v", m)
	}
}
