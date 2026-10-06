package postgres

import (
	"context"
	"encoding/json"
	"errors"
	"sync"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"agnts/internal/domain"
)

const settingsKey = "runtime"

// Settings stores the runtime settings as one JSON row, cached in memory.
type Settings struct {
	db       *pgxpool.Pool
	defaults domain.Settings

	mu    sync.Mutex
	cache *domain.Settings
}

// NewSettings returns the settings store; defaults apply until saved.
func NewSettings(db *pgxpool.Pool, defaults domain.Settings) *Settings {
	return &Settings{db: db, defaults: defaults}
}

// Get returns the current settings.
func (s *Settings) Get(ctx context.Context) (domain.Settings, error) {
	s.mu.Lock()
	defer s.mu.Unlock()
	if s.cache != nil {
		return clone(*s.cache), nil
	}
	out := clone(s.defaults)
	var raw []byte
	err := s.db.QueryRow(ctx, `SELECT value FROM settings WHERE key = $1`, settingsKey).Scan(&raw)
	if err != nil && !errors.Is(err, pgx.ErrNoRows) {
		return out, err
	}
	if err == nil {
		// Unmarshal over the defaults so fields added later get sane values.
		if err := json.Unmarshal(raw, &out); err != nil {
			return clone(s.defaults), err
		}
	}
	s.cache = &out
	return clone(out), nil
}

// Put validates and saves settings, writing a settings_changed event.
func (s *Settings) Put(ctx context.Context, v domain.Settings, origin domain.Origin) (domain.Settings, error) {
	if err := v.Validate(); err != nil {
		return v, err
	}
	raw, err := json.Marshal(v)
	if err != nil {
		return v, err
	}
	err = pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		if _, err := tx.Exec(ctx, `INSERT INTO settings (key, value) VALUES ($1, $2)
			ON CONFLICT (key) DO UPDATE SET value = $2, updated_at = now()`, settingsKey, raw); err != nil {
			return err
		}
		return insertEvent(ctx, tx, domain.Event{Type: domain.EventSettings, Origin: origin, Message: "settings saved"})
	})
	if err != nil {
		return v, err
	}
	s.mu.Lock()
	c := clone(v)
	s.cache = &c
	s.mu.Unlock()
	return v, nil
}

func clone(v domain.Settings) domain.Settings {
	v.Allow = append([]string{}, v.Allow...)
	v.Deny = append([]string{}, v.Deny...)
	v.EgressAllow = append([]string{}, v.EgressAllow...)
	return v
}
