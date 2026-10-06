// Package postgres implements agnts's stores on PostgreSQL.
package postgres

import (
	"context"
	"errors"
	"fmt"
	"log/slog"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/jackc/pgx/v5/stdlib"
	"github.com/pressly/goose/v3"

	"agnts/internal/domain"
	"agnts/migrations"
)

// Open connects to PostgreSQL and checks the connection.
func Open(ctx context.Context, url string) (*pgxpool.Pool, error) {
	pool, err := pgxpool.New(ctx, url)
	if err != nil {
		return nil, fmt.Errorf("postgres: connect: %w", err)
	}
	if err := pool.Ping(ctx); err != nil {
		pool.Close()
		return nil, fmt.Errorf("postgres: ping: %w", err)
	}
	return pool, nil
}

// MigrateCommand is a goose command: up, down, status, or version.
type MigrateCommand string

// Migrate runs a migration command against the database.
func Migrate(ctx context.Context, pool *pgxpool.Pool, cmd MigrateCommand, log *slog.Logger) error {
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
