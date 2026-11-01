package connections

import (
	"context"
	"strings"
	"testing"

	"agnts/internal/ai"
	"agnts/internal/domain"
	"agnts/internal/store/postgres"
)

// withMuse makes Muse the primary tool for one test.
func withMuse(t *testing.T) {
	t.Helper()
	domain.SetProviders([]string{domain.ProviderMuse})
	t.Cleanup(func() { domain.SetProviders([]string{domain.ProviderClaude, domain.ProviderCodex}) })
}

func TestPickMuse(t *testing.T) {
	withMuse(t)
	ctx := context.Background()
	conns := newConns()
	free := map[int64]bool{}
	s := New(Config{MuseKey: "LLM_platformkey0123456789", Free: func(_ context.Context, u int64) bool { return free[u] }},
		conns, fakeUsage{paused: map[int64]bool{}}, fakeSettings{}, fakeUsers{})
	w := domain.Workspace{ID: 7, OwnerID: 1, ClaudeMode: domain.ClaudeShared}

	// A Claude connection does not count for a Muse run.
	conns.add(7, 0, 10, postgres.ClaudeSubscription)
	if _, ok, why, _ := s.Pick(ctx, w, nil, domain.ProviderMuse, ai.PickOpts{Credits: true}); ok || !strings.Contains(why, "Muse account") {
		t.Fatalf("claude connection on muse: ok=%v %q", ok, why)
	}
	conns.add(7, 0, 11, postgres.MuseLogin)
	if a, ok, _, _ := s.Pick(ctx, w, nil, domain.ProviderMuse, ai.PickOpts{Credits: true}); !ok || a.ConnectionID != 11 || a.Credits {
		t.Fatalf("muse connection: %+v %v", a, ok)
	}

	// Without a connection, free credits are used even with continuing on
	// credits off; they belong to the ticket's member.
	conns = newConns()
	s.conns = conns
	ann := int64(2)
	free[ann] = true
	a, ok, _, _ := s.Pick(ctx, w, &ann, domain.ProviderMuse, ai.PickOpts{Credits: true})
	if !ok || !a.Credits || a.UserID != ann || a.Label != "free credits" {
		t.Fatalf("free credits: %+v %v", a, ok)
	}
	// Someone without free credits needs the workspace's credits on.
	bob := int64(3)
	if _, ok, why, _ := s.Pick(ctx, w, &bob, domain.ProviderMuse, ai.PickOpts{Credits: true}); ok || !strings.Contains(why, "continuing with credits") {
		t.Fatalf("no free credits: ok=%v %q", ok, why)
	}
	w.ClaudeFallback, w.CreditsBalance = true, 500
	if a, ok, _, _ := s.Pick(ctx, w, &bob, domain.ProviderMuse, ai.PickOpts{Credits: true}); !ok || !a.Credits || a.UserID != bob || a.Label != "workspace credits" {
		t.Fatalf("workspace credits: %+v %v", a, ok)
	}
}

func TestMuseCredentials(t *testing.T) {
	withMuse(t)
	conns := newConns()
	s := New(Config{MuseKey: "LLM_platformkey0123456789"}, conns, fakeUsage{}, fakeSettings{}, fakeUsers{})
	if c, err := s.Credential(context.Background(), domain.ClaudeAccount{Credits: true, Provider: domain.ProviderMuse}); err != nil || c.Env != EnvMuseKey || c.Token != "LLM_platformkey0123456789" {
		t.Fatalf("credits credential = %+v, %v", c, err)
	}
	conns.add(7, 0, 12, postgres.MuseAPIKey)
	conns.add(0, 2, 13, postgres.MuseLogin)
	for id, env := range map[int64]string{12: EnvMuseKey, 13: EnvMuseLogin} {
		c, err := s.Credential(context.Background(), domain.ClaudeAccount{ConnectionID: id})
		if err != nil || c.Env != env {
			t.Errorf("connection %d: %+v, %v", id, c, err)
		}
	}
	if !s.CreditsEnabled(domain.ProviderMuse) || s.CreditsEnabled(domain.ProviderClaude) {
		t.Fatal("a Meta key enables credits for Muse only")
	}
}

func TestCheckMuseKinds(t *testing.T) {
	s := New(Config{}, newConns(), fakeUsage{}, fakeSettings{}, fakeUsers{})
	if label, err := s.Check(context.Background(), postgres.MuseAPIKey, "LLM_0123456789abcdefghij"); err != nil || label != "Meta Model API key" {
		t.Fatalf("api key: %q, %v", label, err)
	}
	if _, err := s.Check(context.Background(), postgres.MuseAPIKey, "sk-ant-api-xyz"); err == nil {
		t.Fatal("an Anthropic key is not a Meta key")
	}
	login := `{"schema_version":1,"providers":{"meta":{"mechanism":"oauth","storage":"file","access_token":"acc-123456789"}}}`
	if label, err := s.Check(context.Background(), postgres.MuseLogin, login); err != nil || label != "Meta account" {
		t.Fatalf("login: %q, %v", label, err)
	}
	if _, err := s.Check(context.Background(), postgres.MuseLogin, "{}"); err == nil {
		t.Fatal("an empty sign-in is refused")
	}
}
