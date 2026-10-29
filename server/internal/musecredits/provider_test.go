package musecredits_test

import (
	"errors"
	"testing"

	muse "github.com/rustambekabdusalomov/agnts-muse"

	"agnts/internal/musecredits"
	"agnts/internal/store/postgres"
	"agnts/internal/store/postgres/pgtest"
)

// TestProviderMode keeps an Admin's choice of where runs on agnts's key
// go: auto until one is made, then what they chose, read by every run.
func TestProviderMode(t *testing.T) {
	pool := pgtest.Open(t)
	pgtest.Reset(t, pool)
	pgtest.Exec(t, pool, `DELETE FROM system_settings WHERE key = 'muse_provider_mode'`)
	ctx, _ := pgtest.Workspace(t, pool, "muse-provider")
	admin := pgtest.User(t, pool, "admin")
	svc := musecredits.New(musecredits.Config{}, pool, postgres.NewCredits(pool))

	if m, err := svc.ProviderMode(ctx); err != nil || m.Mode != muse.ModeAuto || m.SetBy != 0 {
		t.Fatalf("default = %+v, %v", m, err)
	}
	m, err := svc.SetProviderMode(ctx, muse.ModeFallback, admin)
	if err != nil || m.Mode != muse.ModeFallback || m.SetBy != admin || m.SetAt.IsZero() {
		t.Fatalf("set = %+v, %v", m, err)
	}
	if got := svc.Mode(); got != muse.ModeFallback {
		t.Fatalf("Mode() = %q", got)
	}
	if _, err := svc.SetProviderMode(ctx, "both", admin); !errors.Is(err, muse.ErrInvalid) {
		t.Fatalf("invalid mode err = %v", err)
	}
	if m, _ := svc.ProviderMode(ctx); m.Mode != muse.ModeFallback {
		t.Fatalf("an invalid mode replaced the choice: %+v", m)
	}
}
