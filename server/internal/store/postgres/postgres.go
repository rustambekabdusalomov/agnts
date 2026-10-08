// Package postgres implements agnts's stores on PostgreSQL.
package postgres

import (
	"context"
	"errors"
	"fmt"
	"log/slog"
	"strconv"
	"sync/atomic"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/jackc/pgx/v5/stdlib"
	"github.com/pressly/goose/v3"

	"agnts/internal/domain"
	"agnts/migrations"
)

// Open connects to PostgreSQL and checks the connection. Every connection
// taken from the pool is scoped to the workspace of the context that takes
// it (see scopeConn), which the row-level security policies enforce.
func Open(ctx context.Context, url string) (*pgxpool.Pool, error) {
	cfg, err := pgxpool.ParseConfig(url)
	if err != nil {
		return nil, fmt.Errorf("postgres: config: %w", err)
	}
	cfg.PrepareConn = scopeConn
	pool, err := pgxpool.NewWithConfig(ctx, cfg)
	if err != nil {
		return nil, fmt.Errorf("postgres: connect: %w", err)
	}
	if err := pool.Ping(domain.System(ctx)); err != nil {
		pool.Close()
		return nil, fmt.Errorf("postgres: ping: %w", err)
	}
	return pool, nil
}

// tenantRole is set once the agnts_tenant role is known to exist; scoped
// connections then switch to it so the policies hold even for a superuser
// login role.
var tenantRole atomic.Bool

// DetectTenantRole checks for the agnts_tenant role (created by the
// workspaces migration) and reports whether scoped connections use it.
func DetectTenantRole(ctx context.Context, pool *pgxpool.Pool) (bool, error) {
	var ok bool
	err := pool.QueryRow(domain.System(ctx), `SELECT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'agnts_tenant')
		AND pg_has_role(current_user, 'agnts_tenant', 'MEMBER')`).Scan(&ok)
	if err != nil {
		return false, err
	}
	tenantRole.Store(ok)
	return ok, nil
}

const scopeData = "agnts.scope"

// scopeConn sets app.workspace_id (and the role) for the context taking the
// connection: a workspace id, "all" for system work, or "" (no workspace's
// rows) otherwise. The setting is only sent when it changes.
func scopeConn(ctx context.Context, conn *pgx.Conn) (bool, error) {
	sc := domain.ScopeOf(ctx)
	ws, role := "", "none"
	switch {
	case sc.WorkspaceID > 0:
		ws = strconv.FormatInt(sc.WorkspaceID, 10)
		if tenantRole.Load() {
			role = "agnts_tenant"
		}
	case sc.All:
		ws = "all"
	default:
		if tenantRole.Load() {
			role = "agnts_tenant"
		}
	}
	want := ws + "/" + role
	data := conn.PgConn().CustomData()
	if cur, ok := data[scopeData].(string); ok && cur == want {
		return true, nil
	}
	if _, err := conn.Exec(ctx, `SELECT set_config('app.workspace_id', $1, false), set_config('role', $2, false)`, ws, role); err != nil {
		delete(data, scopeData)
		return false, err
	}
	data[scopeData] = want
	return true, nil
}

// MigrateCommand is a goose command: up, down, status, or version.
type MigrateCommand string

// Migrate runs a migration command against the database.
func Migrate(ctx context.Context, pool *pgxpool.Pool, cmd MigrateCommand, log *slog.Logger) error {
	ctx = domain.System(ctx)
	db := stdlib.OpenDBFromPool(pool)
	defer func() { _ = db.Close() }()

	p, err := goose.NewProvider(goose.DialectPostgres, db, migrations.FS)
	if err != nil {
		return fmt.Errorf("migrate: %w", err)
	}
	switch cmd {
	case "up":
		res, err := p.Up(ctx)
		for _, r := range res {
			log.Info("migration applied", "version", r.Source.Version, "file", r.Source.Path, "duration", r.Duration)
		}
		return err
	case "down":
		r, err := p.Down(ctx)
		if r != nil {
			log.Info("migration rolled back", "version", r.Source.Version, "file", r.Source.Path)
		}
		return err
	case "status":
		st, err := p.Status(ctx)
		if err != nil {
			return err
		}
		for _, s := range st {
			log.Info("migration", "version", s.Source.Version, "file", s.Source.Path, "state", s.State, "applied_at", s.AppliedAt)
		}
		return nil
	case "version":
		v, err := p.GetDBVersion(ctx)
		if err != nil {
			return err
		}
		log.Info("database version", "version", v)
		return nil
	default:
		return fmt.Errorf("migrate: unknown command %q (want up, down, status, version)", cmd)
	}
}

func notFound(err error) error {
	if errors.Is(err, pgx.ErrNoRows) {
		return domain.ErrNotFound
	}
	return err
}
