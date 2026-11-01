// Package modules keeps which coding modules (Muse Code, Claude Code,
// Codex) each person may use. The platform Admin chooses the modules the
// server offers and the ones a person gets by default, within what the
// server can run (AGNTS_PROVIDERS, the ceiling), and may set a person's
// own list instead.
package modules

import (
	"context"
	"encoding/json"
	"errors"
	"slices"
	"sync"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"agnts/internal/domain"
)

const configKey = "modules"

// cacheFor is how long the Admin's choice and a person's access are
// reused: the scheduler asks every tick, and a change made on another
// server shows within it.
const cacheFor = 15 * time.Second

// UserModules is a person's modules as the Admin cabinet shows them.
type UserModules struct {
	// Own is the list an Admin set; nil follows the default.
	Own []string
	// Effective is what the person may use now, in their order.
	Effective []string
	// Order is the order the person put their modules in; nil keeps the
	// Admin's.
	Order []string
	SetBy *int64
	SetAt *time.Time
}

// Service reads and changes module access.
type Service struct {
	db  *pgxpool.Pool
	now func() time.Time

	mu    sync.Mutex
	cfg   *domain.ModulesConfig
	cfgAt time.Time
	users map[int64]cached
}

type cached struct {
	a  domain.Access
	at time.Time
}

// New returns the service.
func New(db *pgxpool.Pool) *Service {
	return &Service{db: db, now: time.Now, users: map[int64]cached{}}
}

// Ensure writes the Admin's general choice when it is missing, from what
// the server offered before modules were chosen per person: every module
// it can run, for everyone. It then makes it the default access.
func (s *Service) Ensure(ctx context.Context) error {
	ceiling := domain.Ceiling()
	b, err := json.Marshal(domain.ModulesConfig{Enabled: ceiling, Default: ceiling})
	if err != nil {
		return err
	}
	if _, err := s.db.Exec(domain.System(ctx), `INSERT INTO system_settings (key, value) VALUES ($1, $2) ON CONFLICT (key) DO NOTHING`,
		configKey, b); err != nil {
		return err
	}
	_, err = s.Config(ctx)
	return err
}

// Config returns the Admin's general choice.
func (s *Service) Config(ctx context.Context) (domain.ModulesConfig, error) {
	s.mu.Lock()
	if s.cfg != nil && s.now().Sub(s.cfgAt) < cacheFor {
		c := clone(*s.cfg)
		s.mu.Unlock()
		return c, nil
	}
	s.mu.Unlock()
	var raw []byte
	err := s.db.QueryRow(domain.System(ctx), `SELECT value FROM system_settings WHERE key = $1`, configKey).Scan(&raw)
	// Separate slices: Unmarshal reuses a slice's array, and one shared
	// by both fields would mix them up.
	cfg := domain.ModulesConfig{Enabled: domain.Ceiling(), Default: domain.Ceiling()}
	switch {
	case errors.Is(err, pgx.ErrNoRows):
	case err != nil:
		return cfg, err
	default:
		var saved domain.ModulesConfig
		if err := json.Unmarshal(raw, &saved); err != nil {
			return cfg, err
		}
		cfg = saved
	}
	s.remember(cfg)
	return clone(cfg), nil
}

// SetConfig changes the Admin's general choice.
func (s *Service) SetConfig(ctx context.Context, cfg domain.ModulesConfig) (domain.ModulesConfig, error) {
	if cfg.Default == nil {
		cfg.Default = []string{}
	}
	if err := cfg.Validate(domain.Ceiling()); err != nil {
		return cfg, &InvalidError{err.Error()}
	}
	b, err := json.Marshal(cfg)
	if err != nil {
		return cfg, err
	}
	if _, err := s.db.Exec(domain.System(ctx), `INSERT INTO system_settings (key, value) VALUES ($1, $2)
		ON CONFLICT (key) DO UPDATE SET value = $2, updated_at = now()`, configKey, b); err != nil {
		return cfg, err
	}
	s.remember(cfg)
	return clone(cfg), nil
}

// remember caches cfg, drops every person's cached access when it changed,
// and makes cfg's default the default access.
func (s *Service) remember(cfg domain.ModulesConfig) {
	c := clone(cfg)
	s.mu.Lock()
	if s.cfg == nil || !slices.Equal(s.cfg.Enabled, c.Enabled) || !slices.Equal(s.cfg.Default, c.Default) {
		s.users = map[int64]cached{}
	}
	s.cfg, s.cfgAt = &c, s.now()
	s.mu.Unlock()
	domain.SetDefaultAccess(domain.ResolveAccess(domain.Ceiling(), c, nil))
}

// Default returns the access of a person no Admin set modules for.
func (s *Service) Default(ctx context.Context) (domain.Access, error) {
	cfg, err := s.Config(ctx)
	if err != nil {
		return domain.DefaultAccess(), err
	}
	return domain.ResolveAccess(domain.Ceiling(), cfg, nil), nil
}

// For returns what person user may use. A person who does not exist (0,
// or deleted) gets the default.
func (s *Service) For(ctx context.Context, user int64) (domain.Access, error) {
	s.mu.Lock()
	if c, ok := s.users[user]; ok && s.now().Sub(c.at) < cacheFor {
		s.mu.Unlock()
		return domain.Access{Modules: slices.Clone(c.a.Modules)}, nil
	}
	s.mu.Unlock()
	cfg, err := s.Config(ctx)
	if err != nil {
		return domain.DefaultAccess(), err
	}
	own, order, err := s.own(ctx, user)
	if err != nil {
		return domain.ResolveAccess(domain.Ceiling(), cfg, nil), err
	}
	a := domain.ResolveAccess(domain.Ceiling(), cfg, own).Ordered(order)
	s.mu.Lock()
	s.users[user] = cached{a: a, at: s.now()}
	s.mu.Unlock()
	return domain.Access{Modules: slices.Clone(a.Modules)}, nil
}

// own returns the list an Admin set for user and the order they put their
// modules in, each nil when none.
func (s *Service) own(ctx context.Context, user int64) (own, order []string, err error) {
	if user <= 0 {
		return nil, nil, nil
	}
	err = s.db.QueryRow(domain.System(ctx), `SELECT modules, module_order FROM users WHERE id = $1`, user).Scan(&own, &order)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, nil, nil
	}
	return own, order, err
}

// User returns a person's modules for the Admin cabinet.
func (s *Service) User(ctx context.Context, user int64) (UserModules, error) {
	var out UserModules
	err := s.db.QueryRow(domain.System(ctx), `SELECT modules, modules_set_by, modules_set_at, module_order FROM users WHERE id = $1`, user).
		Scan(&out.Own, &out.SetBy, &out.SetAt, &out.Order)
	if errors.Is(err, pgx.ErrNoRows) {
		return out, domain.ErrNotFound
	}
	if err != nil {
		return out, err
	}
	cfg, err := s.Config(ctx)
	if err != nil {
		return out, err
	}
	out.Effective = domain.ResolveAccess(domain.Ceiling(), cfg, out.Own).Ordered(out.Order).Modules
	return out, nil
}

// SetOrder sets the order a person puts their modules in (nil: the
// Admin's order). It only orders what they may use.
func (s *Service) SetOrder(ctx context.Context, user int64, order []string) (UserModules, error) {
	if order != nil {
		cfg, err := s.Config(ctx)
		if err != nil {
			return UserModules{}, err
		}
		own, _, err := s.own(ctx, user)
		if err != nil {
			return UserModules{}, err
		}
		if err := domain.ValidateOrder(domain.ResolveAccess(domain.Ceiling(), cfg, own), order); err != nil {
			return UserModules{}, &InvalidError{err.Error()}
		}
	}
	tag, err := s.db.Exec(domain.System(ctx), `UPDATE users SET module_order = $2 WHERE id = $1`, user, order)
	if err != nil {
		return UserModules{}, err
	}
	if tag.RowsAffected() == 0 {
		return UserModules{}, domain.ErrNotFound
	}
	s.mu.Lock()
	delete(s.users, user)
	s.mu.Unlock()
	return s.User(ctx, user)
}

// SetUser sets a person's own modules (nil: follow the default), recording
// which Admin set them.
func (s *Service) SetUser(ctx context.Context, user int64, own []string, by int64) (UserModules, error) {
	cfg, err := s.Config(ctx)
	if err != nil {
		return UserModules{}, err
	}
	if own != nil {
		if err := domain.ValidateModuleList(own, cfg.Enabled); err != nil {
			return UserModules{}, &InvalidError{err.Error()}
		}
	}
	tag, err := s.db.Exec(domain.System(ctx), `UPDATE users SET modules = $2, modules_set_by = $3, modules_set_at = now() WHERE id = $1`,
		user, own, by)
	if err != nil {
		return UserModules{}, err
	}
	if tag.RowsAffected() == 0 {
		return UserModules{}, domain.ErrNotFound
	}
	s.mu.Lock()
	delete(s.users, user)
	s.mu.Unlock()
	return s.User(ctx, user)
}

// InvalidError is a choice the Admin can fix.
type InvalidError struct{ Msg string }

func (e *InvalidError) Error() string { return e.Msg }

func clone(c domain.ModulesConfig) domain.ModulesConfig {
	return domain.ModulesConfig{Enabled: slices.Clone(c.Enabled), Default: slices.Clone(c.Default)}
}
