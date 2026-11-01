package httpapi

import (
	"context"
	"encoding/json"
	"net/http"
	"strings"
	"sync"
	"testing"

	"agnts/internal/domain"
	"agnts/internal/modules"
)

// fakeModules keeps module access in memory, with the domain's rules.
type fakeModules struct {
	mu    sync.Mutex
	cfg   domain.ModulesConfig
	own   map[int64][]string
	order map[int64][]string
}

func newFakeModules() *fakeModules {
	all := []string{domain.ProviderMuse, domain.ProviderClaude, domain.ProviderCodex}
	return &fakeModules{cfg: domain.ModulesConfig{Enabled: all, Default: []string{domain.ProviderClaude, domain.ProviderCodex}},
		own: map[int64][]string{}, order: map[int64][]string{}}
}

func (f *fakeModules) Config(context.Context) (domain.ModulesConfig, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	return f.cfg, nil
}

func (f *fakeModules) SetConfig(_ context.Context, c domain.ModulesConfig) (domain.ModulesConfig, error) {
	if err := c.Validate(domain.Ceiling()); err != nil {
		return c, &modules.InvalidError{Msg: err.Error()}
	}
	f.mu.Lock()
	defer f.mu.Unlock()
	f.cfg = c
	return c, nil
}

func (f *fakeModules) For(_ context.Context, user int64) (domain.Access, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	own, ok := f.own[user]
	if !ok {
		own = nil
	}
	return domain.ResolveAccess(domain.Ceiling(), f.cfg, own).Ordered(f.order[user]), nil
}

func (f *fakeModules) User(ctx context.Context, user int64) (modules.UserModules, error) {
	a, _ := f.For(ctx, user)
	f.mu.Lock()
	defer f.mu.Unlock()
	return modules.UserModules{Own: f.own[user], Effective: a.Modules, Order: f.order[user]}, nil
}

func (f *fakeModules) SetOrder(ctx context.Context, user int64, order []string) (modules.UserModules, error) {
	f.mu.Lock()
	base := domain.ResolveAccess(domain.Ceiling(), f.cfg, f.own[user])
	f.mu.Unlock()
	if order != nil {
		if err := domain.ValidateOrder(base, order); err != nil {
			return modules.UserModules{}, &modules.InvalidError{Msg: err.Error()}
		}
	}
	f.mu.Lock()
	f.order[user] = order
	f.mu.Unlock()
	return f.User(ctx, user)
}

func (f *fakeModules) SetUser(ctx context.Context, user int64, own []string, _ int64) (modules.UserModules, error) {
	if own != nil {
		if err := domain.ValidateModuleList(own, f.cfg.Enabled); err != nil {
			return modules.UserModules{}, &modules.InvalidError{Msg: err.Error()}
		}
	}
	f.mu.Lock()
	if own == nil {
		delete(f.own, user)
	} else {
		f.own[user] = own
	}
	f.mu.Unlock()
	return f.User(ctx, user)
}

func TestModulesRoutesAreAdminOnly(t *testing.T) {
	ops, err := operations()
	if err != nil {
		t.Fatal(err)
	}
	for _, op := range []string{"GET /api/platform/settings/modules", "PUT /api/platform/settings/modules", "PUT /api/platform/users/{id}/modules"} {
		if o, ok := ops[op]; !ok || o.scope != "admin" {
			t.Errorf("%s: %+v (in spec %v)", op, o, ok)
		}
	}
	h := newHarness(t, pinger{})
	if rec := h.do("PUT", "/api/platform/users/1/modules", `{"modules":["muse"]}`, nil); rec.Code != http.StatusUnauthorized {
		t.Fatalf("signed out: %d", rec.Code)
	}
}

// The model catalog and /auth/me follow the viewer's modules, and an Admin
// changes them.
func TestModulesPerViewer(t *testing.T) {
	domain.SetProviders([]string{domain.ProviderMuse, domain.ProviderClaude, domain.ProviderCodex})
	t.Cleanup(func() { domain.SetProviders([]string{domain.ProviderMuse}) })
	h := newHarness(t, pinger{})
	cookie := h.signIn(t)

	catalog := func() (providers []string, primary string, models []string) {
		t.Helper()
		rec := h.do("GET", "/api/models", "", cookie)
		if rec.Code != http.StatusOK {
			t.Fatalf("models: %d %s", rec.Code, rec.Body)
		}
		var c struct {
			Providers []string `json:"providers"`
			Primary   string   `json:"primary"`
			Models    []struct {
				ID string `json:"id"`
			} `json:"models"`
		}
		if err := json.Unmarshal(rec.Body.Bytes(), &c); err != nil {
			t.Fatal(err)
		}
		for _, m := range c.Models {
			models = append(models, m.ID)
		}
		return c.Providers, c.Primary, models
	}
	p, primary, ms := catalog()
	if strings.Join(p, ",") != "claude,codex" || primary != "claude" || strings.Join(ms, ",") != "haiku,sonnet,opus" {
		t.Fatalf("default viewer: %v %s %v", p, primary, ms)
	}

	// The Admin makes them a judge: Muse only.
	if rec := h.do("PUT", "/api/platform/users/1/modules", `{"modules":["muse"]}`, cookie); rec.Code != http.StatusOK ||
		!strings.Contains(rec.Body.String(), `"effective":["muse"]`) {
		t.Fatalf("set modules: %d %s", rec.Code, rec.Body)
	}
	p, primary, ms = catalog()
	if strings.Join(p, ",") != "muse" || primary != "muse" || strings.Join(ms, ",") != "muse:spark,muse:wonder" {
		t.Fatalf("judge: %v %s %v", p, primary, ms)
	}
	if rec := h.do("GET", "/api/auth/me", "", cookie); !strings.Contains(rec.Body.String(), `"modules":["muse"]`) {
		t.Fatalf("me: %s", rec.Body)
	}
	// Codex cannot be anyone's default module.
	if rec := h.do("PUT", "/api/platform/users/1/modules", `{"modules":["codex","claude"]}`, cookie); rec.Code != http.StatusBadRequest {
		t.Fatalf("codex first: %d %s", rec.Code, rec.Body)
	}
	if rec := h.do("PUT", "/api/platform/settings/modules", `{"enabled":["claude","codex"],"default":["codex"]}`, cookie); rec.Code != http.StatusBadRequest {
		t.Fatalf("codex default: %d %s", rec.Code, rec.Body)
	}
	// Back to the default; the general settings show what the server can run.
	if rec := h.do("PUT", "/api/platform/users/1/modules", `{"modules":null}`, cookie); rec.Code != http.StatusOK {
		t.Fatalf("follow default: %d %s", rec.Code, rec.Body)
	}
	rec := h.do("GET", "/api/platform/settings/modules", "", cookie)
	if rec.Code != http.StatusOK || !strings.Contains(rec.Body.String(), `"available":["muse","claude","codex"]`) {
		t.Fatalf("settings: %d %s", rec.Code, rec.Body)
	}
}

// People put the modules they may use in their own order; the catalog
// follows it.
func TestMyModuleOrder(t *testing.T) {
	domain.SetProviders([]string{domain.ProviderMuse, domain.ProviderClaude, domain.ProviderCodex})
	t.Cleanup(func() { domain.SetProviders([]string{domain.ProviderMuse}) })
	h := newHarness(t, pinger{})
	cookie := h.signIn(t)
	h.modules.cfg.Default = []string{domain.ProviderClaude, domain.ProviderCodex, domain.ProviderMuse}

	if rec := h.do("PUT", "/api/account/modules", `{"order":["muse","claude"]}`, cookie); rec.Code != http.StatusOK ||
		!strings.Contains(rec.Body.String(), `"effective":["muse","claude","codex"]`) {
		t.Fatalf("set order: %d %s", rec.Code, rec.Body)
	}
	if rec := h.do("GET", "/api/models", "", cookie); !strings.Contains(rec.Body.String(), `"primary":"muse"`) {
		t.Fatalf("catalog after ordering: %s", rec.Body)
	}
	if rec := h.do("GET", "/api/account/modules", "", cookie); !strings.Contains(rec.Body.String(), `"order":["muse","claude"]`) {
		t.Fatalf("my modules: %s", rec.Body)
	}
	// Codex first, or a module the Admin did not give, is refused.
	if rec := h.do("PUT", "/api/account/modules", `{"order":["codex"]}`, cookie); rec.Code != http.StatusBadRequest {
		t.Fatalf("codex first: %d", rec.Code)
	}
	h.modules.own[1] = []string{domain.ProviderClaude}
	if rec := h.do("PUT", "/api/account/modules", `{"order":["muse"]}`, cookie); rec.Code != http.StatusBadRequest {
		t.Fatalf("a module not given: %d", rec.Code)
	}
	// Back to the Admin's order.
	delete(h.modules.own, 1)
	if rec := h.do("PUT", "/api/account/modules", `{"order":null}`, cookie); rec.Code != http.StatusOK ||
		!strings.Contains(rec.Body.String(), `"effective":["claude","codex","muse"]`) {
		t.Fatalf("reset: %d %s", rec.Code, rec.Body)
	}
}
