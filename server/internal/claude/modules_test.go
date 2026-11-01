package claude

import (
	"context"
	"strings"
	"testing"

	"agnts/internal/domain"
	"agnts/internal/store/postgres"
)

// A person or a workspace holds one account per module, and each run picks
// the one for its module.
func TestPickPerModule(t *testing.T) {
	ctx := context.Background()
	conns := newConns()
	conns.add(7, 0, 30, postgres.ClaudeAPIKey)
	conns.add(7, 0, 31, postgres.MuseLogin)
	s := New(Config{}, conns, fakeUsage{paused: map[int64]bool{}}, fakeSettings{}, fakeUsers{})
	w := domain.Workspace{ID: 7, OwnerID: 1, ClaudeMode: domain.ClaudeShared}
	if a, ok, _, _ := s.Pick(ctx, w, nil, domain.ProviderClaude); !ok || a.ConnectionID != 30 || a.Provider != domain.ProviderClaude {
		t.Fatalf("claude: %+v %v", a, ok)
	}
	if a, ok, _, _ := s.Pick(ctx, w, nil, domain.ProviderMuse); !ok || a.ConnectionID != 31 || a.Provider != domain.ProviderMuse {
		t.Fatalf("muse: %+v %v", a, ok)
	}
	// Each credential comes from the account of the call's module.
	run := domain.WithAccounts(ctx, domain.ProviderClaude, map[string]domain.ClaudeAccount{
		domain.ProviderClaude: {ConnectionID: 30, Provider: domain.ProviderClaude},
		domain.ProviderMuse:   {ConnectionID: 31, Provider: domain.ProviderMuse},
	})
	if c, _ := s.CredentialFor(run); c.Env != "ANTHROPIC_API_KEY" {
		t.Fatalf("claude call: %+v", c)
	}
	if c, _ := s.CredentialFor(domain.UseProvider(run, domain.ProviderMuse)); c.Env != EnvMuseLogin {
		t.Fatalf("muse call: %+v", c)
	}
}

// Free credits are Muse ledger money: a person with free credits left and
// no Claude account still cannot run Claude on them.
func TestFreeCreditsNeverFundClaude(t *testing.T) {
	ctx := context.Background()
	s := New(Config{PlatformKey: "sk-ant-api-platform", MuseKey: "LLM_platformkey0123456789",
		Free: func(context.Context, int64) bool { return true }}, newConns(), fakeUsage{}, fakeSettings{}, fakeUsers{})
	w := domain.Workspace{ID: 7, OwnerID: 1, ClaudeMode: domain.ClaudePerMember}
	ann := int64(2)
	if a, ok, why, _ := s.Pick(ctx, w, &ann, domain.ProviderClaude); ok || a.Credits {
		t.Fatalf("free credits paid for claude: %+v %q", a, why)
	}
	if a, ok, _, _ := s.Pick(ctx, w, &ann, domain.ProviderMuse); !ok || !a.Credits || a.Label != "free credits" {
		t.Fatalf("muse on free credits: %+v %v", a, ok)
	}
	// Workspace credits still pay for Claude when the workspace allows it.
	w.ClaudeFallback, w.CreditsBalance = true, 500
	if a, ok, _, _ := s.Pick(ctx, w, &ann, domain.ProviderClaude); !ok || !a.Credits || a.Label != "workspace credits" {
		t.Fatalf("claude on workspace credits: %+v %v", a, ok)
	}
}

// A Codex stage needs only the workspace's OpenAI key, no Claude account.
func TestPickCodex(t *testing.T) {
	ctx := context.Background()
	ready := false
	s := New(Config{CodexKey: func(context.Context) (string, error) {
		if ready {
			return "sk-openai", nil
		}
		return "", nil
	}}, newConns(), fakeUsage{}, fakeSettings{}, fakeUsers{})
	w := domain.Workspace{ID: 7, OwnerID: 1, ClaudeMode: domain.ClaudePerMember}
	if _, ok, why, _ := s.Pick(ctx, w, nil, domain.ProviderCodex); ok || !strings.Contains(why, "OpenAI") {
		t.Fatalf("no key: ok=%v %q", ok, why)
	}
	ready = true
	a, ok, _, _ := s.Pick(ctx, w, nil, domain.ProviderCodex)
	if !ok || a.Credits || a.ConnectionID != 0 || a.Provider != domain.ProviderCodex {
		t.Fatalf("codex: %+v %v", a, ok)
	}
	if s.CreditsEnabled(domain.ProviderCodex) {
		t.Fatal("codex never runs on credits")
	}
}
