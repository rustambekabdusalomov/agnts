package claude

import (
	"context"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
	"time"

	"agnts/internal/domain"
	"agnts/internal/store/postgres"
	"agnts/internal/usage"
)

type connKey struct {
	owner    int64
	provider string
}

type fakeConns struct {
	ws    map[connKey]postgres.ClaudeConnection
	users map[connKey]postgres.ClaudeConnection
	byID  map[int64]postgres.ClaudeConnection
}

func newConns() *fakeConns {
	return &fakeConns{ws: map[connKey]postgres.ClaudeConnection{}, users: map[connKey]postgres.ClaudeConnection{}, byID: map[int64]postgres.ClaudeConnection{}}
}

func (f *fakeConns) add(ws, user int64, id int64, kind string) {
	c := postgres.ClaudeConnection{ID: id, Kind: kind, Token: "sk-ant-token-" + kind}
	if ws > 0 {
		c.WorkspaceID = &ws
		f.ws[connKey{ws, postgres.ProviderOfKind(kind)}] = c
	} else {
		c.UserID = &user
		f.users[connKey{user, postgres.ProviderOfKind(kind)}] = c
	}
	f.byID[id] = c
}

func (f *fakeConns) ByID(_ context.Context, id int64) (postgres.ClaudeConnection, error) {
	if c, ok := f.byID[id]; ok {
		return c, nil
	}
	return postgres.ClaudeConnection{}, domain.ErrNotFound
}
func (f *fakeConns) ForWorkspace(_ context.Context, ws int64, p string) (postgres.ClaudeConnection, error) {
	if c, ok := f.ws[connKey{ws, p}]; ok {
		return c, nil
	}
	return postgres.ClaudeConnection{}, domain.ErrNotFound
}
func (f *fakeConns) ForUser(_ context.Context, u int64, p string) (postgres.ClaudeConnection, error) {
	if c, ok := f.users[connKey{u, p}]; ok {
		return c, nil
	}
	return postgres.ClaudeConnection{}, domain.ErrNotFound
}
func (f *fakeConns) Put(_ context.Context, ws, u int64, kind, token, account string) (postgres.ClaudeConnection, error) {
	id := int64(len(f.byID) + 1)
	f.add(ws, u, id, kind)
	return f.byID[id], nil
}
func (f *fakeConns) DeleteWorkspace(context.Context, int64, string) error { return nil }
func (f *fakeConns) DeleteUser(context.Context, int64, string) error      { return nil }
func (f *fakeConns) SetPaused(context.Context, int64, *time.Time) error   { return nil }
func (f *fakeConns) MemberConnections(context.Context, int64, string) (map[int64]*time.Time, error) {
	return nil, nil
}
func (f *fakeConns) Paused(context.Context) ([]int64, error) { return nil, nil }
func (f *fakeConns) UpdateToken(_ context.Context, id int64, token string) error {
	c := f.byID[id]
	c.Token = token
	f.byID[id] = c
	return nil
}

// fakeUsage pauses the connections in paused.
type fakeUsage struct{ paused map[int64]bool }

func (f fakeUsage) Paused(ctx context.Context, _ domain.Settings) (bool, time.Time) {
	a, _ := domain.ClaudeOf(ctx)
	if f.paused[a.ConnectionID] {
		return true, time.Date(2026, 10, 8, 14, 0, 0, 0, time.UTC)
	}
	return false, time.Time{}
}
func (f fakeUsage) Current(context.Context, domain.Settings) (usage.View, error) {
	return usage.View{}, nil
}

type fakeSettings struct{}

func (fakeSettings) Get(context.Context) (domain.Settings, error) {
	return domain.DefaultSettings(), nil
}

type fakeUsers struct{}

func (fakeUsers) ByID(_ context.Context, id int64) (domain.User, error) {
	return domain.User{ID: id, Username: map[int64]string{1: "owner", 2: "ann", 3: "bob"}[id]}, nil
}

func TestPickShared(t *testing.T) {
	ctx := context.Background()
	conns := newConns()
	u := fakeUsage{paused: map[int64]bool{}}
	s := New(Config{Subscriptions: true, PlatformKey: "sk-ant-api-platform"}, conns, u, fakeSettings{}, fakeUsers{})
	w := domain.Workspace{ID: 7, OwnerID: 1, ClaudeMode: domain.ClaudeShared}

	if _, ok, why, _ := s.Pick(ctx, w, nil, domain.ProviderClaude); ok || !strings.Contains(why, "Workspace settings") {
		t.Fatalf("no connection: ok=%v %q", ok, why)
	}
	conns.add(7, 0, 10, postgres.ClaudeSubscription)
	a, ok, _, _ := s.Pick(ctx, w, nil, domain.ProviderClaude)
	if !ok || a.ConnectionID != 10 || a.Credits {
		t.Fatalf("shared: %+v %v", a, ok)
	}
	// Every member's ticket runs on the shared account.
	if a, _, _, _ := s.Pick(ctx, w, ptr(2), domain.ProviderClaude); a.ConnectionID != 10 {
		t.Fatalf("member's ticket in shared mode: %+v", a)
	}
	// At its limit: the ticket waits, unless the fallback uses credits.
	u.paused[10] = true
	if _, ok, why, until := s.Pick(ctx, w, nil, domain.ProviderClaude); ok || !strings.Contains(why, "limit") || until.IsZero() {
		t.Fatalf("paused: ok=%v %q %v", ok, why, until)
	}
	w.ClaudeFallback = true
	if _, ok, why, _ := s.Pick(ctx, w, nil, domain.ProviderClaude); ok || !strings.Contains(why, "no credits") {
		t.Fatalf("fallback without credits: ok=%v %q", ok, why)
	}
	w.CreditsBalance = 100
	if a, ok, _, _ := s.Pick(ctx, w, nil, domain.ProviderClaude); !ok || !a.Credits {
		t.Fatalf("fallback: %+v %v", a, ok)
	}
	// The credits run gets agnts's key.
	cred, err := s.CredentialFor(domain.WithClaude(ctx, domain.ClaudeAccount{Credits: true}))
	if err != nil || cred.Env != "ANTHROPIC_API_KEY" || cred.Token != "sk-ant-api-platform" {
		t.Fatalf("credits credential %+v %v", cred, err)
	}
}

func TestPickPerMember(t *testing.T) {
	ctx := context.Background()
	conns := newConns()
	conns.add(0, 2, 20, postgres.ClaudeAPIKey) // ann
	conns.add(0, 1, 21, postgres.ClaudeSubscription)
	s := New(Config{Subscriptions: true}, conns, fakeUsage{paused: map[int64]bool{20: true}}, fakeSettings{}, fakeUsers{})
	w := domain.Workspace{ID: 7, OwnerID: 1, ClaudeMode: domain.ClaudePerMember}

	// Ann's account is at its limit: her tickets wait, the owner's run.
	if _, ok, why, _ := s.Pick(ctx, w, ptr(2), domain.ProviderClaude); ok || !strings.Contains(why, "limit") {
		t.Fatalf("ann's ticket: ok=%v %q", ok, why)
	}
	if a, ok, _, _ := s.Pick(ctx, w, ptr(1), domain.ProviderClaude); !ok || a.ConnectionID != 21 {
		t.Fatalf("owner's ticket: %+v", a)
	}
	// Bob has none.
	if _, ok, why, _ := s.Pick(ctx, w, ptr(3), domain.ProviderClaude); ok || !strings.Contains(why, "bob has not connected") {
		t.Fatalf("bob: ok=%v %q", ok, why)
	}
	// A ticket without a person goes to the default member, else the owner.
	if a, _, _, _ := s.Pick(ctx, w, nil, domain.ProviderClaude); a.ConnectionID != 21 {
		t.Fatalf("no member: %+v", a)
	}
	w.DefaultMemberID = ptr(2)
	if _, ok, _, _ := s.Pick(ctx, w, nil, domain.ProviderClaude); ok {
		t.Fatal("default member ann is paused")
	}
	// Ann's API key runs as an API key.
	cred, _ := s.CredentialFor(domain.WithClaude(ctx, domain.ClaudeAccount{ConnectionID: 20}))
	if cred.Env != "ANTHROPIC_API_KEY" {
		t.Fatalf("api key credential %+v", cred)
	}
	cred, _ = s.CredentialFor(domain.WithClaude(ctx, domain.ClaudeAccount{ConnectionID: 21}))
	if cred.Env != "CLAUDE_CODE_OAUTH_TOKEN" {
		t.Fatalf("subscription credential %+v", cred)
	}
}

func TestSubscriptionsOff(t *testing.T) {
	ctx := context.Background()
	conns := newConns()
	conns.add(7, 0, 10, postgres.ClaudeSubscription)
	s := New(Config{Subscriptions: false}, conns, fakeUsage{}, fakeSettings{}, fakeUsers{})
	if _, ok, why, _ := s.Pick(ctx, domain.Workspace{ID: 7, ClaudeMode: domain.ClaudeShared}, nil, domain.ProviderClaude); ok || !strings.Contains(why, "API keys only") {
		t.Fatalf("subscription on a cloud server: ok=%v %q", ok, why)
	}
	if _, err := s.Check(ctx, postgres.ClaudeSubscription, "sk-ant-oat01-"+strings.Repeat("x", 40)); err == nil {
		t.Fatal("subscription token accepted")
	}
}

func TestCheckAPIKey(t *testing.T) {
	api := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.Header.Get("x-api-key") != "sk-ant-api03-good"+strings.Repeat("x", 30) {
			w.WriteHeader(http.StatusUnauthorized)
			return
		}
		_, _ = w.Write([]byte(`{"data":[]}`))
	}))
	defer api.Close()
	s := New(Config{APIBase: api.URL}, newConns(), fakeUsage{}, fakeSettings{}, fakeUsers{})
	ctx := context.Background()
	if _, err := s.Check(ctx, postgres.ClaudeAPIKey, "sk-ant-api03-good"+strings.Repeat("x", 30)); err != nil {
		t.Fatal(err)
	}
	if _, err := s.Check(ctx, postgres.ClaudeAPIKey, "sk-ant-api03-bad"+strings.Repeat("x", 30)); err == nil {
		t.Fatal("a rejected key passed")
	}
	if _, err := s.Check(ctx, postgres.ClaudeAPIKey, "nope"); err == nil {
		t.Fatal("not a key")
	}
}

func ptr(v int64) *int64 { return &v }
