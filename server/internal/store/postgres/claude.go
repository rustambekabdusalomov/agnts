package postgres

import (
	"context"
	"errors"
	"strconv"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"agnts/internal/secret"
)

// ClaudeConnection is a Claude account agnts runs on: a workspace's shared
// one, or a person's own. Token is decrypted.
type ClaudeConnection struct {
	ID          int64
	WorkspaceID *int64
	UserID      *int64
	Kind        string // subscription or api_key
	Token       string
	Account     string
	LastError   string
	PausedUntil *time.Time
	CheckedAt   *time.Time
	UpdatedAt   time.Time
}

// Claude connection kinds.
const (
	ClaudeSubscription = "subscription"
	ClaudeAPIKey       = "api_key"
	// Muse Code accounts: a Meta Model API key, or a Meta sign-in (Muse
	// Code's credential file).
	MuseAPIKey = "muse_api_key"
	MuseLogin  = "muse_login"
)

// ClaudeConnections stores Claude accounts, sealed with the server key.
// The table has no row-level policy: personal connections serve every
// workspace their owner is in, so every query names the owner.
type ClaudeConnections struct {
	db  *pgxpool.Pool
	box *secret.Box
}

// NewClaudeConnections returns the store.
func NewClaudeConnections(db *pgxpool.Pool, box *secret.Box) *ClaudeConnections {
	return &ClaudeConnections{db: db, box: box}
}

func claudeAAD(c ClaudeConnection) []byte {
	if c.WorkspaceID != nil {
		return []byte("claude:workspace:" + strconv.FormatInt(*c.WorkspaceID, 10))
	}
	if c.UserID != nil {
		return []byte("claude:user:" + strconv.FormatInt(*c.UserID, 10))
	}
	return nil
}

const claudeCols = `id, workspace_id, user_id, kind, token_enc, account, last_error, paused_until, checked_at, updated_at`

func (s *ClaudeConnections) scan(row pgx.Row) (ClaudeConnection, error) {
	var c ClaudeConnection
	var enc []byte
	if err := row.Scan(&c.ID, &c.WorkspaceID, &c.UserID, &c.Kind, &enc, &c.Account, &c.LastError, &c.PausedUntil, &c.CheckedAt, &c.UpdatedAt); err != nil {
		return c, notFound(err)
	}
	pt, err := s.box.Open(enc, claudeAAD(c))
	if err != nil && c.WorkspaceID != nil {
		// Moved from the install's Claude integration: still sealed the old way.
		if pt, err = s.box.Open(enc, legacyAAD("claude")); err != nil {
			pt, err = s.box.Open(enc, integrationAAD(*c.WorkspaceID, "claude"))
		}
	}
	if err != nil {
		return c, err
	}
	c.Token = string(pt)
	return c, nil
}

// ByID returns a connection.
func (s *ClaudeConnections) ByID(ctx context.Context, id int64) (ClaudeConnection, error) {
	return s.scan(s.db.QueryRow(ctx, `SELECT `+claudeCols+` FROM claude_connections WHERE id = $1`, id))
}

// ForWorkspace returns a workspace's shared connection, or ErrNotFound.
func (s *ClaudeConnections) ForWorkspace(ctx context.Context, ws int64) (ClaudeConnection, error) {
	return s.scan(s.db.QueryRow(ctx, `SELECT `+claudeCols+` FROM claude_connections WHERE workspace_id = $1`, ws))
}

// ForUser returns a person's own connection, or ErrNotFound.
func (s *ClaudeConnections) ForUser(ctx context.Context, userID int64) (ClaudeConnection, error) {
	return s.scan(s.db.QueryRow(ctx, `SELECT `+claudeCols+` FROM claude_connections WHERE user_id = $1`, userID))
}

// Put saves the connection of a workspace (ws > 0) or a person (userID > 0),
// replacing the one there was.
func (s *ClaudeConnections) Put(ctx context.Context, ws, userID int64, kind, token, account string) (ClaudeConnection, error) {
	c := ClaudeConnection{Kind: kind}
	if ws > 0 {
		c.WorkspaceID = &ws
	} else if userID > 0 {
		c.UserID = &userID
	} else {
		return c, errors.New("a Claude connection needs a workspace or a person")
	}
	enc, err := s.box.Seal([]byte(token), claudeAAD(c))
	if err != nil {
		return c, err
	}
	err = pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		if c.WorkspaceID != nil {
			_, err = tx.Exec(ctx, `DELETE FROM claude_connections WHERE workspace_id = $1`, ws)
		} else {
			_, err = tx.Exec(ctx, `DELETE FROM claude_connections WHERE user_id = $1`, userID)
		}
		if err != nil {
			return err
		}
		return tx.QueryRow(ctx, `INSERT INTO claude_connections (workspace_id, user_id, kind, token_enc, account, checked_at)
			VALUES ($1, $2, $3, $4, $5, now()) RETURNING id, updated_at`, c.WorkspaceID, c.UserID, kind, enc, account).Scan(&c.ID, &c.UpdatedAt)
	})
	c.Token, c.Account = token, account
	return c, err
}

// DeleteWorkspace removes a workspace's shared connection.
func (s *ClaudeConnections) DeleteWorkspace(ctx context.Context, ws int64) error {
	_, err := s.db.Exec(ctx, `DELETE FROM claude_connections WHERE workspace_id = $1`, ws)
	return err
}

// DeleteUser removes a person's own connection.
func (s *ClaudeConnections) DeleteUser(ctx context.Context, userID int64) error {
	_, err := s.db.Exec(ctx, `DELETE FROM claude_connections WHERE user_id = $1`, userID)
	return err
}

// SetPaused records that an account is at its usage limit until t (nil:
// it is not).
func (s *ClaudeConnections) SetPaused(ctx context.Context, id int64, until *time.Time) error {
	_, err := s.db.Exec(ctx, `UPDATE claude_connections SET paused_until = $2 WHERE id = $1`, id, until)
	return err
}

// SetError records why the last run on an account failed to start ("" clears it).
func (s *ClaudeConnections) SetError(ctx context.Context, id int64, msg string) error {
	_, err := s.db.Exec(ctx, `UPDATE claude_connections SET last_error = $2, checked_at = now() WHERE id = $1`, id, msg)
	return err
}

// MemberConnections returns, for each member of workspace ws, whether they
// have their own connection and until when it is paused.
func (s *ClaudeConnections) MemberConnections(ctx context.Context, ws int64) (map[int64]*time.Time, error) {
	rows, err := s.db.Query(ctx, `SELECT c.user_id, c.paused_until FROM claude_connections c
		JOIN memberships m ON m.user_id = c.user_id WHERE m.workspace_id = $1`, ws)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := map[int64]*time.Time{}
	for rows.Next() {
		var id int64
		var until *time.Time
		if err := rows.Scan(&id, &until); err != nil {
			return nil, err
		}
		out[id] = until
	}
	return out, rows.Err()
}

// Paused returns the ids of the connections paused at their usage limit.
func (s *ClaudeConnections) Paused(ctx context.Context) ([]int64, error) {
	rows, err := s.db.Query(ctx, `SELECT id FROM claude_connections WHERE paused_until IS NOT NULL ORDER BY id`)
	if err != nil {
		return nil, err
	}
	return pgx.CollectRows(rows, pgx.RowTo[int64])
}
