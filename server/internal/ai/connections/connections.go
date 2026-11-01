// Package connections keeps the AI accounts calls run on and picks one for
// a call (ai.Accounts): the workspace's connection or a member's, per
// module (Muse, Claude; Codex runs on the workspace's OpenAI key). The
// owner of a workspace picks the mode: shared (the workspace's own
// connection) or per member (the connection of the ticket's member). When
// that account is at its limit or missing, a fallback switch lets runs
// continue on agnts's API key, paid with the workspace's credits.
package connections

import (
	"context"
	"errors"
	"fmt"
	"net/http"
	"slices"
	"strings"
	"time"

	"github.com/rustambekabdusalomov/agnts-muse/credential"

	"agnts/internal/ai"
	"agnts/internal/domain"
	"agnts/internal/orchestrator"
	"agnts/internal/store/postgres"
	"agnts/internal/usage"
)

// Connections is the store of Claude accounts.
type Connections interface {
	ByID(ctx context.Context, id int64) (postgres.ClaudeConnection, error)
	ForWorkspace(ctx context.Context, ws int64, provider string) (postgres.ClaudeConnection, error)
	ForUser(ctx context.Context, userID int64, provider string) (postgres.ClaudeConnection, error)
	Put(ctx context.Context, ws, userID int64, kind, token, account string) (postgres.ClaudeConnection, error)
	DeleteWorkspace(ctx context.Context, ws int64, provider string) error
	DeleteUser(ctx context.Context, userID int64, provider string) error
	SetPaused(ctx context.Context, id int64, until *time.Time) error
	MemberConnections(ctx context.Context, ws int64, provider string) (map[int64]*time.Time, error)
	Paused(ctx context.Context) ([]int64, error)
	UpdateToken(ctx context.Context, id int64, token string) error
}

// Usage says whether an account is at its limit.
type Usage interface {
	Paused(ctx context.Context, acct domain.ClaudeAccount, s domain.Settings) (bool, time.Time)
	Current(ctx context.Context, acct domain.ClaudeAccount, s domain.Settings) (usage.View, error)
}

// Users names members in messages.
type Users interface {
	ByID(ctx context.Context, id int64) (domain.User, error)
}

// Config is the platform's rules for Claude accounts.
type Config struct {
	// PlatformKey is agnts's Anthropic API key for runs on credits; ""
	// turns credits off.
	PlatformKey string
	// Subscriptions lets people connect Claude subscription tokens. A
	// hosted product turns it off until Anthropic approves that use: then
	// only API keys are accepted.
	Subscriptions bool
	// MinCredits is the balance a run on credits needs to start.
	MinCredits int64
	// APIBase is Anthropic's API, for checking keys (tests replace it).
	APIBase string
	// MuseKey is agnts's Meta Model API key for Muse runs on credits.
	MuseKey string
	// Free says whether a person has free credits left (an Admin gave
	// them); a Muse run then continues on credits even when the workspace
	// has not turned on continuing with credits. Free credits are Muse
	// ledger money: they never pay for Claude.
	Free func(ctx context.Context, userID int64) bool
	// CodexKey returns the OpenAI API key of the workspace ctx acts in,
	// for Codex runs (Integrations → OpenAI; "" when none); nil when Codex
	// is not set up.
	CodexKey func(ctx context.Context) (string, error)
}

// Service picks accounts and manages connections.
type Service struct {
	cfg      Config
	conns    Connections
	usage    Usage
	settings orchestrator.SettingsSource
	users    Users
	hc       *http.Client
}

var _ ai.Accounts = (*Service)(nil)

// New returns the service.
func New(cfg Config, conns Connections, usage Usage, settings orchestrator.SettingsSource, users Users) *Service {
	if cfg.APIBase == "" {
		cfg.APIBase = "https://api.anthropic.com"
	}
	if cfg.MinCredits <= 0 {
		cfg.MinCredits = 1
	}
	return &Service{cfg: cfg, conns: conns, usage: usage, settings: settings, users: users, hc: &http.Client{Timeout: 15 * time.Second}}
}

// CreditsEnabled reports whether runs of module provider can fall back to
// credits here: agnts has its own key for it. Codex never runs on credits.
func (s *Service) CreditsEnabled(provider string) bool {
	switch provider {
	case domain.ProviderMuse:
		return s.cfg.MuseKey != ""
	case domain.ProviderClaude:
		return s.cfg.PlatformKey != ""
	}
	return false
}

// AnyCredits reports whether any module can run on credits here.
func (s *Service) AnyCredits() bool {
	return s.CreditsEnabled(domain.ProviderMuse) || s.CreditsEnabled(domain.ProviderClaude)
}

// connProvider is the module whose connection a run of provider uses:
// Codex has none.
func connProvider(provider string) string {
	if provider == domain.ProviderMuse {
		return domain.ProviderMuse
	}
	return domain.ProviderClaude
}

// SubscriptionsAllowed reports whether subscription tokens are accepted.
func (s *Service) SubscriptionsAllowed() bool { return s.cfg.Subscriptions }

// Pick implements ai.Accounts: the account a call of member in w uses on
// module provider. Muse uses the Muse connection, then free credits, then
// workspace credits; Claude its connection, then workspace credits; Codex
// the workspace's OpenAI key. credits false leaves agnts's key out.
func (s *Service) Pick(ctx context.Context, w domain.Workspace, member *int64, provider string, opts ai.PickOpts) (domain.ClaudeAccount, bool, string, time.Time) {
	credits := opts.Credits
	payer := w.RunPerson(member)
	tool := domain.ModuleName(provider)
	if provider == domain.ProviderCodex {
		if !s.codexReady(ctx) {
			return domain.ClaudeAccount{}, false, "Codex runs need an OpenAI API key: connect OpenAI under Integrations", time.Time{}
		}
		return domain.ClaudeAccount{Label: "the workspace's OpenAI key", UserID: payer, Provider: provider}, true, "", time.Time{}
	}
	var conn postgres.ClaudeConnection
	var err error
	var who string
	if w.ClaudeMode == domain.ClaudePerMember {
		conn, err = s.conns.ForUser(ctx, payer, provider)
		who = s.name(ctx, payer)
	} else {
		conn, err = s.conns.ForWorkspace(ctx, w.ID, provider)
		who = "the workspace"
	}
	why, until := "", time.Time{}
	switch {
	case errors.Is(err, domain.ErrNotFound):
		if w.ClaudeMode == domain.ClaudePerMember {
			why = who + " has not connected a " + tool + " account (Profile → " + tool + ")"
		} else {
			why = "no " + tool + " account is connected (Workspace settings → AI accounts)"
		}
	case err != nil:
		why = "could not read the " + tool + " account: " + err.Error()
	case conn.Kind == postgres.ClaudeSubscription && !s.cfg.Subscriptions:
		why = "this server accepts Anthropic API keys only; connect one instead of a subscription token"
	case slices.Contains(opts.Skip, conn.ID):
		why = tool + " refused " + label(conn, who)
	default:
		acct := domain.ClaudeAccount{ConnectionID: conn.ID, Label: label(conn, who), Provider: provider}
		st, serr := s.settings.Get(ctx)
		if serr != nil {
			st = domain.DefaultSettings()
		}
		paused, at := s.usage.Paused(ctx, acct, st)
		if !paused {
			return acct, true, "", time.Time{}
		}
		why, until = tool+" limit reached on "+acct.Label, at
		if !at.IsZero() {
			why += "; resumes at " + at.Format("15:04")
		}
	}
	if !credits {
		return domain.ClaudeAccount{}, false, why, until
	}
	if provider == domain.ProviderMuse && s.CreditsEnabled(provider) && s.cfg.Free != nil && s.cfg.Free(ctx, payer) {
		return domain.ClaudeAccount{Credits: true, Label: "free credits", UserID: payer, Provider: provider}, true, "", time.Time{}
	}
	if w.ClaudeFallback && s.CreditsEnabled(provider) {
		if w.CreditsBalance >= s.cfg.MinCredits {
			return domain.ClaudeAccount{Credits: true, Label: "workspace credits", UserID: payer, Provider: provider}, true, "", time.Time{}
		}
		why += "; the workspace has no credits left to continue on"
	} else if s.CreditsEnabled(provider) {
		why += "; or turn on continuing with credits"
	}
	return domain.ClaudeAccount{}, false, why, until
}

func label(c postgres.ClaudeConnection, who string) string {
	if c.Account != "" {
		return c.Account
	}
	if who == "the workspace" {
		return "the workspace's account"
	}
	return who + "'s account"
}

func (s *Service) name(ctx context.Context, id int64) string {
	if s.users == nil {
		return "the member"
	}
	u, err := s.users.ByID(ctx, id)
	if err != nil {
		return "the member"
	}
	if u.DisplayName != "" {
		return u.DisplayName
	}
	return u.Username
}

// codexReady reports whether the workspace ctx acts in has an OpenAI key.
func (s *Service) codexReady(ctx context.Context) bool {
	if s.cfg.CodexKey == nil {
		return false
	}
	key, err := s.cfg.CodexKey(ctx)
	return err == nil && key != ""
}

// Credential implements ai.Accounts: acct's secret. Codex runs on the
// workspace's OpenAI key; a run on credits on agnts's key for its module.
func (s *Service) Credential(ctx context.Context, acct domain.ClaudeAccount) (ai.Credential, error) {
	switch {
	case acct.Provider == domain.ProviderCodex:
		if s.cfg.CodexKey == nil {
			return ai.Credential{}, errors.New("codex is not available on this server")
		}
		key, err := s.cfg.CodexKey(ctx)
		if err != nil {
			return ai.Credential{}, fmt.Errorf("openai key: %w", err)
		}
		return ai.Credential{Env: "OPENAI_API_KEY", Token: key}, nil
	case acct.Credits:
		provider := connProvider(acct.Provider)
		if !s.CreditsEnabled(provider) {
			return ai.Credential{}, errors.New("credits are not available on this server")
		}
		if provider == domain.ProviderMuse {
			return ai.Credential{Env: EnvMuseKey, Token: s.cfg.MuseKey}, nil
		}
		return ai.Credential{Env: "ANTHROPIC_API_KEY", Token: s.cfg.PlatformKey}, nil
	case acct.ConnectionID <= 0:
		return ai.Credential{}, fmt.Errorf("%s is not connected: connect an account in Workspace settings → AI accounts", strings.ToLower(domain.ModuleName(acct.Provider)))
	}
	c, err := s.conns.ByID(ctx, acct.ConnectionID)
	if errors.Is(err, domain.ErrNotFound) {
		return ai.Credential{}, fmt.Errorf("the %s account was disconnected", strings.ToLower(domain.ModuleName(acct.Provider)))
	}
	if err != nil {
		return ai.Credential{}, err
	}
	switch c.Kind {
	case postgres.MuseAPIKey:
		return ai.Credential{Env: EnvMuseKey, Token: c.Token}, nil
	case postgres.MuseLogin:
		return ai.Credential{Env: EnvMuseLogin, Token: c.Token}, nil
	case postgres.ClaudeAPIKey:
		return ai.Credential{Env: "ANTHROPIC_API_KEY", Token: c.Token}, nil
	}
	return ai.Credential{Env: "CLAUDE_CODE_OAUTH_TOKEN", Token: c.Token}, nil
}

// Environment names of Muse credentials (the runner reads them).
const (
	EnvMuseKey   = "META_API_KEY"
	EnvMuseLogin = "MUSE_LOGIN"
)

// Check validates a token before it is saved and returns the account
// label to show. API keys are tried against Anthropic's API; subscription
// tokens can only be checked for their shape.
func (s *Service) Check(ctx context.Context, kind, token string) (string, error) {
	token = strings.TrimSpace(token)
	switch kind {
	case postgres.ClaudeSubscription:
		if !s.cfg.Subscriptions {
			return "", errors.New("this server accepts Anthropic API keys only")
		}
		if !strings.HasPrefix(token, "sk-ant-") || len(token) < 40 {
			return "", errors.New("expected a token from `claude setup-token` (sk-ant-oat...)")
		}
		return "Claude subscription", nil
	case postgres.ClaudeAPIKey:
		if !strings.HasPrefix(token, "sk-ant-api") || len(token) < 40 {
			return "", errors.New("expected an Anthropic API key (sk-ant-api...)")
		}
		req, err := http.NewRequestWithContext(ctx, http.MethodGet, strings.TrimRight(s.cfg.APIBase, "/")+"/v1/models?limit=1", nil)
		if err != nil {
			return "", err
		}
		req.Header.Set("x-api-key", token)
		req.Header.Set("anthropic-version", "2023-06-01")
		resp, err := s.hc.Do(req)
		if err != nil {
			return "", fmt.Errorf("could not reach Anthropic to check the key: %w", err)
		}
		_ = resp.Body.Close()
		if resp.StatusCode == http.StatusUnauthorized || resp.StatusCode == http.StatusForbidden {
			return "", errors.New("anthropic rejected this API key")
		}
		if resp.StatusCode >= 300 {
			return "", fmt.Errorf("anthropic answered %s while checking the key", resp.Status)
		}
		return "Anthropic API key", nil
	case postgres.MuseAPIKey:
		if _, err := credential.APIKey(token); err != nil {
			return "", errors.New("expected a Meta Model API key (LLM_...)")
		}
		return "Meta Model API key", nil
	case postgres.MuseLogin:
		if _, err := credential.LoginFile([]byte(token), ""); err != nil {
			return "", errors.New("the Meta sign-in did not return a usable login; sign in again")
		}
		return "Meta account", nil
	}
	return "", fmt.Errorf("unknown kind %q (want subscription, api_key, muse_api_key or muse_login)", kind)
}

// SetWorkspace connects a workspace's shared account.
func (s *Service) SetWorkspace(ctx context.Context, ws int64, kind, token string) (postgres.ClaudeConnection, error) {
	account, err := s.Check(ctx, kind, token)
	if err != nil {
		return postgres.ClaudeConnection{}, &InvalidError{err.Error()}
	}
	return s.conns.Put(ctx, ws, 0, kind, strings.TrimSpace(token), account)
}

// SetUser connects a person's own account.
func (s *Service) SetUser(ctx context.Context, userID int64, kind, token string) (postgres.ClaudeConnection, error) {
	account, err := s.Check(ctx, kind, token)
	if err != nil {
		return postgres.ClaudeConnection{}, &InvalidError{err.Error()}
	}
	return s.conns.Put(ctx, 0, userID, kind, strings.TrimSpace(token), account)
}

// InvalidError is a token the person can fix.
type InvalidError struct{ Msg string }

func (e *InvalidError) Error() string { return e.Msg }

// Paused records an account reaching (until set) or leaving its limit.
func (s *Service) Paused(ctx context.Context, conn int64, until *time.Time) {
	_ = s.conns.SetPaused(ctx, conn, until)
}

// WorkspaceConnection returns a workspace's shared connection for module
// provider (muse or claude).
func (s *Service) WorkspaceConnection(ctx context.Context, ws int64, provider string) (postgres.ClaudeConnection, error) {
	return s.conns.ForWorkspace(ctx, ws, connProvider(provider))
}

// UserConnection returns a person's own connection for module provider.
func (s *Service) UserConnection(ctx context.Context, userID int64, provider string) (postgres.ClaudeConnection, error) {
	return s.conns.ForUser(ctx, userID, connProvider(provider))
}

// DeleteWorkspaceConnection disconnects a workspace's shared account for
// module provider.
func (s *Service) DeleteWorkspaceConnection(ctx context.Context, ws int64, provider string) error {
	return s.conns.DeleteWorkspace(ctx, ws, connProvider(provider))
}

// DeleteUserConnection disconnects a person's own account for module
// provider.
func (s *Service) DeleteUserConnection(ctx context.Context, userID int64, provider string) error {
	return s.conns.DeleteUser(ctx, userID, connProvider(provider))
}

// MemberConnections returns which members of a workspace have their own
// account for module provider, and until when each is paused.
func (s *Service) MemberConnections(ctx context.Context, ws int64, provider string) (map[int64]*time.Time, error) {
	return s.conns.MemberConnections(ctx, ws, connProvider(provider))
}

// UsageOf returns an account's latest usage reading.
func (s *Service) UsageOf(ctx context.Context, c postgres.ClaudeConnection) (usage.View, error) {
	st, err := s.settings.Get(ctx)
	if err != nil {
		st = domain.DefaultSettings()
	}
	return s.usage.Current(ctx, domain.ClaudeAccount{ConnectionID: c.ID, Provider: postgres.ProviderOfKind(c.Kind)}, st)
}

// AccountFor returns the account the person in ctx sees usage for in
// workspace w on module provider: the shared one, or their own in
// per-member mode.
func (s *Service) AccountFor(ctx context.Context, w domain.Workspace, userID int64, provider string) (domain.ClaudeAccount, bool) {
	var c postgres.ClaudeConnection
	var err error
	if w.ClaudeMode == domain.ClaudePerMember {
		c, err = s.conns.ForUser(ctx, userID, connProvider(provider))
	} else {
		c, err = s.conns.ForWorkspace(ctx, w.ID, connProvider(provider))
	}
	if err != nil {
		return domain.ClaudeAccount{}, false
	}
	return domain.ClaudeAccount{ConnectionID: c.ID, Label: c.Account, Provider: connProvider(provider)}, true
}

// PausedAccounts returns the accounts paused at their usage limit.
func (s *Service) PausedAccounts(ctx context.Context) []domain.ClaudeAccount {
	ids, err := s.conns.Paused(ctx)
	if err != nil {
		return nil
	}
	out := make([]domain.ClaudeAccount, 0, len(ids))
	for _, id := range ids {
		a := domain.ClaudeAccount{ConnectionID: id}
		if c, err := s.conns.ByID(ctx, id); err == nil {
			a.Provider, a.Label = postgres.ProviderOfKind(c.Kind), c.Account
		}
		out = append(out, a)
	}
	return out
}

// Resolve returns the account the person acting in ctx would run on in
// its workspace (for usage pages).
func (s *Service) Resolve(ctx context.Context, ws domain.Workspace, provider string) (domain.ClaudeAccount, bool) {
	uid := ws.OwnerID
	if a, ok := domain.ActorOf(ctx); ok {
		uid = a.UserID
	}
	return s.AccountFor(ctx, ws, uid, provider)
}

// KeepMuseLogin saves the Muse login a run on acct ended with, when Muse
// refreshed it during the run, so the connection does not expire. Runs on
// credits and on API keys have nothing to keep.
func (s *Service) KeepMuseLogin(ctx context.Context, acct domain.ClaudeAccount, file []byte) error {
	if acct.Credits || acct.ConnectionID == 0 {
		return nil
	}
	if _, err := credential.LoginFile(file, ""); err != nil {
		return err
	}
	return s.conns.UpdateToken(ctx, acct.ConnectionID, string(file))
}
