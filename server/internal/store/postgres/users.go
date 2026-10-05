package postgres

import (
	"context"
	"errors"

	"github.com/jackc/pgx/v5/pgconn"
	"github.com/jackc/pgx/v5/pgxpool"

	"hiro/internal/domain"
)

// Users is the users store.
type Users struct{ db *pgxpool.Pool }

// NewUsers returns a users store.
func NewUsers(db *pgxpool.Pool) *Users { return &Users{db: db} }

const userCols = `id, username, password_hash, totp_secret_enc, created_at`

func scanUser(row interface{ Scan(...any) error }) (domain.User, error) {
	var u domain.User
	err := row.Scan(&u.ID, &u.Username, &u.PasswordHash, &u.TOTPSecretEnc, &u.CreatedAt)
	return u, notFound(err)
}

// ByUsername returns the user with username.
func (s *Users) ByUsername(ctx context.Context, username string) (domain.User, error) {
	return scanUser(s.db.QueryRow(ctx, `SELECT `+userCols+` FROM users WHERE username = $1`, username))
}

// ByID returns the user with id.
func (s *Users) ByID(ctx context.Context, id int64) (domain.User, error) {
	return scanUser(s.db.QueryRow(ctx, `SELECT `+userCols+` FROM users WHERE id = $1`, id))
}

// Count returns the number of users.
func (s *Users) Count(ctx context.Context) (int, error) {
	var n int
	err := s.db.QueryRow(ctx, `SELECT count(*) FROM users`).Scan(&n)
	return n, err
}

// Create inserts a user.
func (s *Users) Create(ctx context.Context, u domain.User) (domain.User, error) {
	out, err := scanUser(s.db.QueryRow(ctx,
		`INSERT INTO users (username, password_hash, totp_secret_enc) VALUES ($1, $2, $3) RETURNING `+userCols,
		u.Username, u.PasswordHash, u.TOTPSecretEnc))
	var pgErr *pgconn.PgError
	if errors.As(err, &pgErr) && pgErr.Code == "23505" {
		return domain.User{}, domain.ErrConflict
	}
	return out, err
}

// AdvanceTOTPStep records step as used if it is later than the last one.
func (s *Users) AdvanceTOTPStep(ctx context.Context, userID, step int64) (bool, error) {
	tag, err := s.db.Exec(ctx,
		`UPDATE users SET totp_last_step = $2, updated_at = now() WHERE id = $1 AND totp_last_step < $2`,
		userID, step)
	if err != nil {
		return false, err
	}
	return tag.RowsAffected() == 1, nil
}
