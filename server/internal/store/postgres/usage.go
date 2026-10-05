package postgres

import (
	"context"
	"encoding/json"
	"errors"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

// UsageSnapshot is one reading of the plan limits.
type UsageSnapshot struct {
	FiveHour       *float64
	FiveHourResets *time.Time
	SevenDay       *float64
	SevenDayResets *time.Time
	Status         string
	Raw            map[string]any
	CreatedAt      time.Time
}

// Usage stores plan usage snapshots.
type Usage struct{ db *pgxpool.Pool }

// NewUsage returns the usage store.
func NewUsage(db *pgxpool.Pool) *Usage { return &Usage{db: db} }

// Insert saves a snapshot.
func (u *Usage) Insert(ctx context.Context, s UsageSnapshot) error {
	raw, _ := json.Marshal(s.Raw)
	if s.Raw == nil {
		raw = []byte("{}")
	}
	_, err := u.db.Exec(ctx, `INSERT INTO usage_snapshots (five_hour, resets_at, seven_day, seven_day_resets_at, status, raw)
		VALUES ($1, $2, $3, $4, $5, $6)`, s.FiveHour, s.FiveHourResets, s.SevenDay, s.SevenDayResets, s.Status, raw)
	return err
}

// Latest returns the newest snapshot, or ok=false when there is none.
func (u *Usage) Latest(ctx context.Context) (UsageSnapshot, bool, error) {
	var s UsageSnapshot
	var raw []byte
	var five, seven *float32
	err := u.db.QueryRow(ctx, `SELECT five_hour, resets_at, seven_day, seven_day_resets_at, status, raw, created_at
		FROM usage_snapshots ORDER BY id DESC LIMIT 1`).Scan(&five, &s.FiveHourResets, &seven, &s.SevenDayResets, &s.Status, &raw, &s.CreatedAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return s, false, nil
	}
	if err != nil {
		return s, false, err
	}
	if five != nil {
		v := float64(*five)
		s.FiveHour = &v
	}
	if seven != nil {
		v := float64(*seven)
		s.SevenDay = &v
	}
	_ = json.Unmarshal(raw, &s.Raw)
	return s, true, nil
}

// Prune keeps 30 days of snapshots.
func (u *Usage) Prune(ctx context.Context) error {
	_, err := u.db.Exec(ctx, `DELETE FROM usage_snapshots WHERE created_at < now() - interval '30 days'`)
	return err
}
