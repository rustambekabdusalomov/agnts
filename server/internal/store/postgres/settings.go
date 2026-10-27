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

// Settings stores each workspace's runtime settings as one JSON row,
// cached in memory.
type Settings struct {
	db       *pgxpool.Pool
	defaults domain.Settings

	mu    sync.Mutex
	cache map[int64]*domain.Settings // by workspace
}

// NewSettings returns the settings store; defaults apply until saved.
func NewSettings(db *pgxpool.Pool, defaults domain.Settings) *Settings {
	return &Settings{db: db, defaults: defaults, cache: map[int64]*domain.Settings{}}
}

// Get returns the settings of the workspace ctx acts in.
func (s *Settings) Get(ctx context.Context) (domain.Settings, error) {
	ws, err := domain.MustWorkspace(ctx)
	if err != nil {
		return clone(s.defaults), err
	}
	s.mu.Lock()
	defer s.mu.Unlock()
	if c := s.cache[ws]; c != nil {
		return clone(*c), nil
	}
	out := clone(s.defaults)
	var raw []byte
	err = s.db.QueryRow(ctx, `SELECT value FROM settings WHERE workspace_id = $1 AND key = $2`, ws, settingsKey).Scan(&raw)
	if err != nil && !errors.Is(err, pgx.ErrNoRows) {
		return out, err
	}
	if err == nil {
		// Unmarshal over the defaults so fields added later get sane values.
		if err := json.Unmarshal(raw, &out); err != nil {
			return clone(s.defaults), err
		}
	}
	// Models saved for a tool this server does not offer read as its own.
	out.Models = out.Models.EffectiveModels()
	if out.SecondOpinion != "" && !domain.ProviderEnabled(domain.ProviderOf(out.SecondOpinion)) {
		out.SecondOpinion = ""
	}
	s.cache[ws] = &out
	return clone(out), nil
}

// Forget drops a workspace's cached settings (it was deleted, or changed
// elsewhere).
func (s *Settings) Forget(ws int64) {
	s.mu.Lock()
	delete(s.cache, ws)
	s.mu.Unlock()
}

// Put validates and saves settings, writing a settings_changed event.
func (s *Settings) Put(ctx context.Context, v domain.Settings, origin domain.Origin) (domain.Settings, error) {
	ws, err := domain.MustWorkspace(ctx)
	if err != nil {
		return v, err
	}
	if err := v.Validate(); err != nil {
		return v, err
	}
	raw, err := json.Marshal(v)
	if err != nil {
		return v, err
	}
	err = pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		if _, err := tx.Exec(ctx, `INSERT INTO settings (workspace_id, key, value) VALUES ($1, $2, $3)
			ON CONFLICT (workspace_id, key) DO UPDATE SET value = $3, updated_at = now()`, ws, settingsKey, raw); err != nil {
			return err
		}
		return insertEvent(ctx, tx, domain.Event{Type: domain.EventSettings, Origin: origin, Message: "settings saved"})
	})
	if err != nil {
		return v, err
	}
	s.mu.Lock()
	c := clone(v)
	s.cache[ws] = &c
	s.mu.Unlock()
	return v, nil
}

func clone(v domain.Settings) domain.Settings {
	v.Allow = append([]string{}, v.Allow...)
	v.Deny = append([]string{}, v.Deny...)
	v.EgressAllow = append([]string{}, v.EgressAllow...)
	v.CI.InfraPatterns = append([]string{}, v.CI.InfraPatterns...)
	v.Guard.Disabled = append([]string{}, v.Guard.Disabled...)
	return v
}
