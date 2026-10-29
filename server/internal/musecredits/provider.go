package musecredits

import (
	"context"
	"errors"
	"fmt"
	"sync"
	"time"

	"github.com/jackc/pgx/v5"
	muse "github.com/rustambekabdusalomov/agnts-muse"

	"agnts/internal/domain"
)

// providerModeKey is where the Admin's choice of provider is kept
// (system_settings).
const providerModeKey = "muse_provider_mode"

// ProviderMode is which provider runs on agnts's Muse key use, and who
// chose it.
type ProviderMode struct {
	Mode  muse.Mode
	SetBy int64 // 0 until an Admin chose
	SetAt time.Time
}

// modeCache keeps the last mode read, for when the database cannot be.
type modeCache struct {
	mu   sync.Mutex
	mode muse.Mode
}

// ProviderMode reads the Admin's choice; muse.ModeAuto until one is made.
func (s *Service) ProviderMode(ctx context.Context) (ProviderMode, error) {
	var m struct {
		Mode  string `json:"mode"`
		SetBy int64  `json:"setBy"`
	}
	var at time.Time
	err := s.db.QueryRow(domain.System(ctx), `SELECT value, updated_at FROM system_settings WHERE key = $1`, providerModeKey).Scan(&m, &at)
	if errors.Is(err, pgx.ErrNoRows) {
		return ProviderMode{Mode: muse.ModeAuto}, nil
	}
	if err != nil {
		return ProviderMode{}, err
	}
	mode, err := muse.ParseMode(m.Mode)
	if err != nil {
		return ProviderMode{}, err
	}
	return ProviderMode{Mode: mode, SetBy: m.SetBy, SetAt: at}, nil
}

// SetProviderMode saves an Admin's choice. It applies from the next run.
func (s *Service) SetProviderMode(ctx context.Context, mode muse.Mode, by int64) (ProviderMode, error) {
	if mode == "" {
		return ProviderMode{}, fmt.Errorf("%w: no mode", muse.ErrInvalid)
	}
	if _, err := muse.ParseMode(string(mode)); err != nil {
		return ProviderMode{}, err
	}
	_, err := s.db.Exec(domain.System(ctx), `INSERT INTO system_settings (key, value) VALUES ($1, jsonb_build_object('mode', $2::text, 'setBy', $3::bigint))
		ON CONFLICT (key) DO UPDATE SET value = EXCLUDED.value, updated_at = now()`, providerModeKey, string(mode), by)
	if err != nil {
		return ProviderMode{}, err
	}
	s.modes.mu.Lock()
	s.modes.mode = mode
	s.modes.mu.Unlock()
	return s.ProviderMode(ctx)
}

// Mode is muse.Failover's Mode: the Admin's choice as of now. When the
// database cannot be read it keeps the last choice it saw (auto at first),
// so a database hiccup does not move runs between providers.
func (s *Service) Mode() muse.Mode {
	ctx, cancel := context.WithTimeout(context.Background(), 2*time.Second)
	defer cancel()
	m, err := s.ProviderMode(ctx)
	s.modes.mu.Lock()
	defer s.modes.mu.Unlock()
	if err == nil {
		s.modes.mode = m.Mode
	}
	if s.modes.mode == "" {
		return muse.ModeAuto
	}
	return s.modes.mode
}

// ProviderStatus is where runs on agnts's key go now.
type ProviderStatus struct {
	ProviderMode
	// Fallback and FallbackModel are the fallback provider ("" without one).
	Fallback, FallbackModel string
	// OutUntil is when agnts's Meta account is tried again after it ran
	// out (zero when it is not out), and OutReason why it is out.
	OutUntil  time.Time
	OutReason string
}
