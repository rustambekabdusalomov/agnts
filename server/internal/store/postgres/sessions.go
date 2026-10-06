package postgres

import (
	"context"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"

	"agnts/internal/domain"
)

// Sessions is the sessions store.
type Sessions struct{ db *pgxpool.Pool }

// NewSessions returns a sessions store.
func NewSessions(db *pgxpool.Pool) *Sessions { return &Sessions{db: db} }

// Create inserts a session.
func (s *Sessions) Create(ctx context.Context, x domain.Session) error {
	_, err := s.db.Exec(ctx,
		`INSERT INTO sessions (token_hash, user_id, client, user_agent, ip, created_at, expires_at)
		 VALUES ($1, $2, $3, $4, $5, $6, $7)`,
		x.TokenHash, x.UserID, string(x.Client), x.UserAgent, x.IP, x.CreatedAt, x.ExpiresAt)
	return err
}

// ByTokenHash returns the session with the given token hash.
func (s *Sessions) ByTokenHash(ctx context.Context, hash []byte) (domain.Session, error) {
	var x domain.Session
	var client string
	err := s.db.QueryRow(ctx,
		`SELECT token_hash, user_id, client, user_agent, ip, created_at, expires_at
		 FROM sessions WHERE token_hash = $1`, hash).
		Scan(&x.TokenHash, &x.UserID, &client, &x.UserAgent, &x.IP, &x.CreatedAt, &x.ExpiresAt)
	x.Client = domain.Client(client)
	return x, notFound(err)
}

// Delete removes a session.
func (s *Sessions) Delete(ctx context.Context, hash []byte) error {
	_, err := s.db.Exec(ctx, `DELETE FROM sessions WHERE token_hash = $1`, hash)
	return err
}

// DeleteExpired removes sessions that expired before now.
func (s *Sessions) DeleteExpired(ctx context.Context, now time.Time) (int64, error) {
	tag, err := s.db.Exec(ctx, `DELETE FROM sessions WHERE expires_at <= $1`, now)
	return tag.RowsAffected(), err
}
