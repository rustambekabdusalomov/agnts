package postgres

import (
	"context"
	"errors"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgconn"
	"github.com/jackc/pgx/v5/pgxpool"

	"agnts/internal/domain"
)

// Users is the users store.
type Users struct{ db *pgxpool.Pool }

// NewUsers returns a users store.
func NewUsers(db *pgxpool.Pool) *Users { return &Users{db: db} }

const userCols = `id, username, password_hash, totp_secret_enc, created_at, COALESCE(email, ''), display_name, email_verified_at,
	is_admin, last_workspace_id, avatar_version`

func scanUser(row interface{ Scan(...any) error }) (domain.User, error) {
	var u domain.User
	err := row.Scan(&u.ID, &u.Username, &u.PasswordHash, &u.TOTPSecretEnc, &u.CreatedAt, &u.Email, &u.DisplayName, &u.EmailVerifiedAt,
		&u.IsAdmin, &u.LastWorkspaceID, &u.AvatarVersion)
	return u, notFound(err)
}

// ByLogin returns the user whose username or email is login.
func (s *Users) ByLogin(ctx context.Context, login string) (domain.User, error) {
	return scanUser(s.db.QueryRow(ctx, `SELECT `+userCols+` FROM users WHERE username = $1 OR lower(email) = lower($1)
		ORDER BY (username = $1) DESC LIMIT 1`, login))
}

// ByEmail returns the user with this email address.
func (s *Users) ByEmail(ctx context.Context, email string) (domain.User, error) {
	return scanUser(s.db.QueryRow(ctx, `SELECT `+userCols+` FROM users WHERE lower(email) = lower($1)`, email))
}

// List returns every user, for the operator console.
func (s *Users) List(ctx context.Context) ([]domain.User, error) {
	rows, err := s.db.Query(ctx, `SELECT `+userCols+` FROM users ORDER BY id`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var out []domain.User
	for rows.Next() {
		u, err := scanUser(rows)
		if err != nil {
			return nil, err
		}
		out = append(out, u)
	}
	return out, rows.Err()
}

// SetAdmin grants or removes the system Admin role.
func (s *Users) SetAdmin(ctx context.Context, id int64, admin bool) error {
	tag, err := s.db.Exec(ctx, `UPDATE users SET is_admin = $2, updated_at = now() WHERE id = $1`, id, admin)
	if err == nil && tag.RowsAffected() == 0 {
		return domain.ErrNotFound
	}
	return err
}

// SetPassword replaces a user's password hash.
func (s *Users) SetPassword(ctx context.Context, id int64, hash string) error {
	_, err := s.db.Exec(ctx, `UPDATE users SET password_hash = $2, updated_at = now() WHERE id = $1`, id, hash)
	return err
}

// SetTOTP turns two-factor sign-in on (a sealed secret) or off (nil).
func (s *Users) SetTOTP(ctx context.Context, id int64, enc []byte, step int64) error {
	_, err := s.db.Exec(ctx, `UPDATE users SET totp_secret_enc = $2, totp_last_step = $3, updated_at = now() WHERE id = $1`, id, enc, step)
	return err
}

// SetProfile changes a user's display name and email; a new email is
// unverified until its link is opened.
func (s *Users) SetProfile(ctx context.Context, id int64, displayName, email string) (domain.User, error) {
	u, err := scanUser(s.db.QueryRow(ctx, `UPDATE users SET display_name = $2,
		email_verified_at = CASE WHEN lower(COALESCE(email, '')) = lower($3) THEN email_verified_at END,
		email = NULLIF($3, ''), updated_at = now() WHERE id = $1 RETURNING `+userCols, id, displayName, email))
	return u, uniqueUser(err)
}

// MarkEmailVerified records that the user opened a link sent to email
// (which must still be their address).
func (s *Users) MarkEmailVerified(ctx context.Context, id int64, email string) error {
	tag, err := s.db.Exec(ctx, `UPDATE users SET email_verified_at = now(), updated_at = now()
		WHERE id = $1 AND lower(email) = lower($2)`, id, email)
	if err == nil && tag.RowsAffected() == 0 {
		return domain.ErrNotFound
	}
	return err
}

// CreateToken stores a one-time link token (by hash).
func (s *Users) CreateToken(ctx context.Context, hash []byte, userID int64, purpose, email string, expires time.Time) error {
	_, err := s.db.Exec(ctx, `INSERT INTO user_tokens (token_hash, user_id, purpose, email, expires_at) VALUES ($1, $2, $3, $4, $5)`,
		hash, userID, purpose, email, expires)
	return err
}

// UseToken consumes a one-time link token and returns its user and the
// email it was sent to; ErrNotFound when it is unknown, used or expired.
func (s *Users) UseToken(ctx context.Context, hash []byte, purpose string) (int64, string, error) {
	var id int64
	var email string
	err := s.db.QueryRow(ctx, `UPDATE user_tokens SET used_at = now()
		WHERE token_hash = $1 AND purpose = $2 AND used_at IS NULL AND expires_at > now() RETURNING user_id, email`,
		hash, purpose).Scan(&id, &email)
	return id, email, notFound(err)
}

func uniqueUser(err error) error {
	var pgErr *pgconn.PgError
	if errors.As(err, &pgErr) && pgErr.Code == "23505" {
		return domain.ErrConflict
	}
	return err
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
		`INSERT INTO users (username, password_hash, totp_secret_enc, email, display_name, is_admin)
		 VALUES ($1, $2, $3, NULLIF($4, ''), $5, $6) RETURNING `+userCols,
		u.Username, u.PasswordHash, u.TOTPSecretEnc, u.Email, u.DisplayName, u.IsAdmin))
	var pgErr *pgconn.PgError
	if errors.As(err, &pgErr) && pgErr.Code == "23505" {
		return domain.User{}, domain.ErrConflict
	}
	return out, err
}

// Delete removes a user; their sessions and tokens go with them. The
// documents they own go to each workspace's owner first, in the same
// transaction (documents.owner_id refuses the delete otherwise).
func (s *Users) Delete(ctx context.Context, id int64) error {
	return pgx.BeginFunc(domain.System(ctx), s.db, func(tx pgx.Tx) error {
		rows, err := tx.Query(ctx, `SELECT DISTINCT workspace_id FROM documents WHERE owner_id = $1`, id)
		if err != nil {
			return err
		}
		wss, err := pgx.CollectRows(rows, pgx.RowTo[int64])
		if err != nil {
			return err
		}
		for _, ws := range wss {
			if err := handOverDocuments(ctx, tx, ws, id); err != nil {
				return err
			}
		}
		tag, err := tx.Exec(ctx, `DELETE FROM users WHERE id = $1`, id)
		if err == nil && tag.RowsAffected() == 0 {
			return domain.ErrNotFound
		}
		return err
	})
}

// LastSignIns returns when each user last signed in: their newest session
// still on record (expired ones are purged).
func (s *Users) LastSignIns(ctx context.Context) (map[int64]time.Time, error) {
	rows, err := s.db.Query(ctx, `SELECT user_id, max(created_at) FROM sessions GROUP BY user_id`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := map[int64]time.Time{}
	for rows.Next() {
		var id int64
		var t time.Time
		if err := rows.Scan(&id, &t); err != nil {
			return nil, err
		}
		out[id] = t
	}
	return out, rows.Err()
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

// Usernames returns the usernames of people by id.
func (s *Agent) Usernames(ctx context.Context, ids []int64) (map[int64]string, error) {
	out := map[int64]string{}
	if len(ids) == 0 {
		return out, nil
	}
	rows, err := s.db.Query(ctx, `SELECT id, username FROM users WHERE id = ANY($1)`, ids)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	for rows.Next() {
		var id int64
		var name string
		if err := rows.Scan(&id, &name); err != nil {
			return nil, err
		}
		out[id] = name
	}
	return out, rows.Err()
}

// SetAvatar stores id's profile picture and returns the user, whose
// avatar version has moved on.
func (s *Users) SetAvatar(ctx context.Context, id int64, contentType string, data []byte) (domain.User, error) {
	var u domain.User
	err := pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		if _, err := tx.Exec(ctx, `INSERT INTO user_avatars (user_id, content_type, data) VALUES ($1, $2, $3)
			ON CONFLICT (user_id) DO UPDATE SET content_type = EXCLUDED.content_type, data = EXCLUDED.data, updated_at = now()`,
			id, contentType, data); err != nil {
			return err
		}
		var err error
		u, err = scanUser(tx.QueryRow(ctx, `UPDATE users SET avatar_version = avatar_version + 1 WHERE id = $1 RETURNING `+userCols, id))
		return err
	})
	return u, err
}

// DeleteAvatar removes id's profile picture.
func (s *Users) DeleteAvatar(ctx context.Context, id int64) (domain.User, error) {
	var u domain.User
	err := pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		if _, err := tx.Exec(ctx, `DELETE FROM user_avatars WHERE user_id = $1`, id); err != nil {
			return err
		}
		var err error
		u, err = scanUser(tx.QueryRow(ctx, `UPDATE users SET avatar_version = 0 WHERE id = $1 RETURNING `+userCols, id))
		return err
	})
	return u, err
}

// Avatar returns id's profile picture, or domain.ErrNotFound.
func (s *Users) Avatar(ctx context.Context, id int64) (string, []byte, error) {
	var ct string
	var data []byte
	err := s.db.QueryRow(ctx, `SELECT content_type, data FROM user_avatars WHERE user_id = $1`, id).Scan(&ct, &data)
	return ct, data, notFound(err)
}
