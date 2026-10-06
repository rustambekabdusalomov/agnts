package postgres

import (
	"context"
	"encoding/json"
	"errors"
	"time"

	"github.com/jackc/pgx/v5"

	"agnts/internal/domain"
)

// Device is a phone registered for push notifications.
type Device struct {
	ID         int64
	UserID     int64
	Platform   string
	FCMToken   string
	AppVersion string
	LastSeen   time.Time
}

// RegisterDevice adds or refreshes a device token.
func (s *Agent) RegisterDevice(ctx context.Context, d Device) error {
	_, err := s.db.Exec(ctx, `INSERT INTO devices (user_id, platform, fcm_token, app_version)
		VALUES ($1, $2, $3, $4)
		ON CONFLICT (fcm_token) DO UPDATE SET user_id = $1, platform = $2, app_version = $4, last_seen = now()`,
		d.UserID, d.Platform, d.FCMToken, d.AppVersion)
	return err
}

// DeleteDevice forgets a token (sign-out, or FCM says it is gone).
func (s *Agent) DeleteDevice(ctx context.Context, token string) error {
	_, err := s.db.Exec(ctx, `DELETE FROM devices WHERE fcm_token = $1`, token)
	return err
}

// Devices returns every registered device.
func (s *Agent) Devices(ctx context.Context) ([]Device, error) {
	rows, err := s.db.Query(ctx, `SELECT id, user_id, platform, fcm_token, app_version, last_seen FROM devices ORDER BY id`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var out []Device
	for rows.Next() {
		var d Device
		if err := rows.Scan(&d.ID, &d.UserID, &d.Platform, &d.FCMToken, &d.AppVersion, &d.LastSeen); err != nil {
			return nil, err
		}
		out = append(out, d)
	}
	return out, rows.Err()
}

// PendingAction is a write waiting for confirmation (MCP and Telegram).
type PendingAction struct {
	ID        string
	Origin    domain.Origin
	Tool      string
	TicketKey string
	Args      map[string]any
	Summary   string
	ExpiresAt time.Time
}

// CreatePending stores a pending action.
func (s *Agent) CreatePending(ctx context.Context, a PendingAction) error {
	args, _ := json.Marshal(a.Args)
	_, err := s.db.Exec(ctx, `INSERT INTO pending_actions (id, origin, tool, ticket_key, args, summary, expires_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7)`, a.ID, string(a.Origin), a.Tool, a.TicketKey, args, a.Summary, a.ExpiresAt)
	return err
}

// ErrExpired is returned for unknown, used or expired confirmations.
var ErrExpired = errors.New("this confirmation is unknown, already used or expired")

// ConfirmPending marks an action confirmed exactly once and returns it.
func (s *Agent) ConfirmPending(ctx context.Context, id string, origin domain.Origin) (PendingAction, error) {
	var a PendingAction
	var args []byte
	var o string
	err := s.db.QueryRow(ctx, `UPDATE pending_actions SET confirmed_at = now()
		WHERE id = $1 AND origin = $2 AND confirmed_at IS NULL AND expires_at > now()
		RETURNING id, origin, tool, ticket_key, args, summary, expires_at`, id, string(origin)).
		Scan(&a.ID, &o, &a.Tool, &a.TicketKey, &args, &a.Summary, &a.ExpiresAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return a, ErrExpired
	}
	if err != nil {
		return a, err
	}
	a.Origin = domain.Origin(o)
	_ = json.Unmarshal(args, &a.Args)
	return a, nil
}

// CancelPending drops an unconfirmed action.
func (s *Agent) CancelPending(ctx context.Context, id string) error {
	_, err := s.db.Exec(ctx, `DELETE FROM pending_actions WHERE id = $1 AND confirmed_at IS NULL`, id)
	return err
}

// PrunePending removes actions that expired a day ago or more.
func (s *Agent) PrunePending(ctx context.Context) error {
	_, err := s.db.Exec(ctx, `DELETE FROM pending_actions WHERE expires_at < now() - interval '1 day'`)
	return err
}

// TelegramMessage maps a sent message to its ticket.
type TelegramMessage struct {
	ChatID    int64
	MessageID int64
	TicketKey string
	Kind      string
	Ref       *int64
}

// SaveTelegramMessage records a sent message.
func (s *Agent) SaveTelegramMessage(ctx context.Context, m TelegramMessage) error {
	_, err := s.db.Exec(ctx, `INSERT INTO telegram_messages (chat_id, message_id, ticket_key, kind, ref)
		VALUES ($1, $2, $3, $4, $5) ON CONFLICT DO NOTHING`, m.ChatID, m.MessageID, m.TicketKey, m.Kind, m.Ref)
	return err
}

// TelegramMessage returns what a sent message was about.
func (s *Agent) TelegramMessage(ctx context.Context, chatID, messageID int64) (TelegramMessage, error) {
	m := TelegramMessage{ChatID: chatID, MessageID: messageID}
	err := s.db.QueryRow(ctx, `SELECT ticket_key, kind, ref FROM telegram_messages WHERE chat_id = $1 AND message_id = $2`,
		chatID, messageID).Scan(&m.TicketKey, &m.Kind, &m.Ref)
	return m, notFound(err)
}

// Cursor reads a named position in the event log (e.g. the notifier's).
func (s *Agent) Cursor(ctx context.Context, name string) (int64, error) {
	var v int64
	err := s.db.QueryRow(ctx, `SELECT (value #>> '{}')::bigint FROM settings WHERE key = $1`, "cursor:"+name).Scan(&v)
	if errors.Is(err, pgx.ErrNoRows) {
		return -1, nil
	}
	return v, err
}

// SetCursor saves a named position in the event log.
func (s *Agent) SetCursor(ctx context.Context, name string, id int64) error {
	_, err := s.db.Exec(ctx, `INSERT INTO settings (key, value) VALUES ($1, to_jsonb($2::bigint))
		ON CONFLICT (key) DO UPDATE SET value = to_jsonb($2::bigint), updated_at = now()`, "cursor:"+name, id)
	return err
}
