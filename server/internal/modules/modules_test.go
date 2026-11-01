package modules_test

import (
	"context"
	"errors"
	"slices"
	"testing"

	"agnts/internal/domain"
	"agnts/internal/modules"
	"agnts/internal/store/postgres/pgtest"
)

func TestModules(t *testing.T) {
	pool := pgtest.Open(t)
	pgtest.Reset(t, pool)
	pgtest.Exec(t, pool, `DELETE FROM system_settings WHERE key = 'modules'`)
	pgtest.Exec(t, pool, `UPDATE users SET modules = NULL, modules_set_by = NULL, modules_set_at = NULL`)
	ctx := context.Background()
	domain.SetProviders([]string{domain.ProviderMuse, domain.ProviderClaude, domain.ProviderCodex})
	t.Cleanup(func() { domain.SetProviders([]string{domain.ProviderMuse}) })

	// The first start writes what the server offered before: everything it
	// can run, for everyone.
	s := modules.New(pool)
	if err := s.Ensure(ctx); err != nil {
		t.Fatal(err)
	}
	cfg, err := s.Config(ctx)
	if err != nil || !slices.Equal(cfg.Enabled, domain.Ceiling()) || !slices.Equal(cfg.Default, domain.Ceiling()) {
		t.Fatalf("first config = %+v, %v", cfg, err)
	}
	// Ensure never overwrites the Admin's choice.
	if _, err := s.SetConfig(ctx, domain.ModulesConfig{Enabled: domain.Ceiling(), Default: []string{domain.ProviderClaude, domain.ProviderCodex}}); err != nil {
		t.Fatal(err)
	}
	if err := modules.New(pool).Ensure(ctx); err != nil {
		t.Fatal(err)
	}
	if cfg, _ := modules.New(pool).Config(ctx); !slices.Equal(cfg.Default, []string{domain.ProviderClaude, domain.ProviderCodex}) {
		t.Fatalf("Ensure overwrote the default: %+v", cfg)
	}
	if got := domain.DefaultAccess(); !slices.Equal(got.Modules, []string{domain.ProviderClaude, domain.ProviderCodex}) {
		t.Fatalf("default access = %v", got.Modules)
	}

	// A judge is set to Muse only; the Admin who did it is recorded.
	admin := pgtest.User(t, pool, "modules-admin")
	judge := pgtest.User(t, pool, "modules-judge")
	other := pgtest.User(t, pool, "modules-other")
	um, err := s.SetUser(ctx, judge, []string{domain.ProviderMuse}, admin)
	if err != nil || !slices.Equal(um.Effective, []string{domain.ProviderMuse}) || um.SetBy == nil || *um.SetBy != admin || um.SetAt == nil {
		t.Fatalf("set judge = %+v, %v", um, err)
	}
	if a, _ := s.For(ctx, judge); !slices.Equal(a.Modules, []string{domain.ProviderMuse}) {
		t.Fatalf("judge access = %v", a.Modules)
	}
	if a, _ := s.For(ctx, other); !slices.Equal(a.Modules, []string{domain.ProviderClaude, domain.ProviderCodex}) {
		t.Fatalf("other access = %v", a.Modules)
	}
	// Refused: Codex first, a module not enabled, an unknown person.
	var inv *modules.InvalidError
	if _, err := s.SetUser(ctx, other, []string{domain.ProviderCodex}, admin); !errors.As(err, &inv) {
		t.Fatalf("codex first: %v", err)
	}
	if _, err := s.SetUser(ctx, 999999, nil, admin); !errors.Is(err, domain.ErrNotFound) {
		t.Fatalf("unknown person: %v", err)
	}
	if _, err := s.SetConfig(ctx, domain.ModulesConfig{Enabled: []string{"gemini"}}); !errors.As(err, &inv) {
		t.Fatalf("unknown module: %v", err)
	}

	// A person orders what they were given; the Admin's list still decides
	// what that is.
	if um, err := s.SetOrder(ctx, other, []string{domain.ProviderCodex}); !errors.As(err, &inv) {
		t.Fatalf("codex first: %+v, %v", um, err)
	}
	if um, err := s.SetOrder(ctx, other, []string{domain.ProviderMuse}); !errors.As(err, &inv) {
		t.Fatalf("a module not given: %+v, %v", um, err)
	}
	if _, err := s.SetConfig(ctx, domain.ModulesConfig{Enabled: domain.Ceiling(), Default: []string{domain.ProviderClaude, domain.ProviderCodex, domain.ProviderMuse}}); err != nil {
		t.Fatal(err)
	}
	if um, err := s.SetOrder(ctx, other, []string{domain.ProviderMuse, domain.ProviderClaude}); err != nil ||
		!slices.Equal(um.Effective, []string{domain.ProviderMuse, domain.ProviderClaude, domain.ProviderCodex}) {
		t.Fatalf("order = %+v, %v", um, err)
	}
	if a, _ := s.For(ctx, other); a.Primary() != domain.ProviderMuse {
		t.Fatalf("ordered access = %v", a.Modules)
	}
	if um, err := s.SetOrder(ctx, other, nil); err != nil || um.Order != nil || um.Effective[0] != domain.ProviderClaude {
		t.Fatalf("reset order = %+v, %v", um, err)
	}

	// Disabling Muse server-wide leaves the judge with nothing, at once.
	if _, err := s.SetConfig(ctx, domain.ModulesConfig{Enabled: []string{domain.ProviderClaude, domain.ProviderCodex}, Default: []string{domain.ProviderClaude}}); err != nil {
		t.Fatal(err)
	}
	if a, _ := s.For(ctx, judge); !a.None() {
		t.Fatalf("judge access after disabling muse = %v", a.Modules)
	}
	// Following the default again.
	if um, err := s.SetUser(ctx, judge, nil, admin); err != nil || um.Own != nil || !slices.Equal(um.Effective, []string{domain.ProviderClaude}) {
		t.Fatalf("follow default = %+v, %v", um, err)
	}
}
