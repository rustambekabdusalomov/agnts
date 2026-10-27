// Package claude decides which Claude account each run uses. The owner of a
// workspace picks the mode: shared (the workspace's own connection) or per
// member (the connection of the ticket's member). When that account is at
// its limit or missing, a fallback switch lets runs continue on agnts's API
// key, paid with the workspace's credits.
package claude

import (
	"context"
	"errors"
	"fmt"
	"net/http"
	"strings"
	"time"

	"github.com/rustambekabdusalomov/agnts-muse/credential"

	"agnts/internal/domain"
	"agnts/internal/orchestrator"
	"agnts/internal/store/postgres"
	"agnts/internal/usage"
)

// Connections is the store of Claude accounts.
type Connections interface {
	ByID(ctx context.Context, id int64) (postgres.ClaudeConnection, error)
	ForWorkspace(ctx context.Context, ws int64) (postgres.ClaudeConnection, error)
	ForUser(ctx context.Context, userID int64) (postgres.ClaudeConnection, error)
	Put(ctx context.Context, ws, userID int64, kind, token, account string) (postgres.ClaudeConnection, error)
	DeleteWorkspace(ctx context.Context, ws int64) error
	DeleteUser(ctx context.Context, userID int64) error
	SetPaused(ctx context.Context, id int64, until *time.Time) error
	MemberConnections(ctx context.Context, ws int64) (map[int64]*time.Time, error)
	Paused(ctx context.Context) ([]int64, error)
	UpdateToken(ctx context.Context, id int64, token string) error
}

// Usage says whether an account is at its limit (the account is in ctx).
type Usage interface {
	Paused(ctx context.Context, s domain.Settings) (bool, time.Time)
	Current(ctx context.Context, s domain.Settings) (usage.View, error)
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
	// MuseKey is agnts's Meta Model API key for Muse runs on credits;
	// it, not PlatformKey, enables credits when Muse is the primary tool.
	MuseKey string
	// Free says whether a person has free credits left (an Admin gave
	// them); a run then continues on credits even when the workspace has
	// not turned on continuing with credits.
	Free func(ctx context.Context, userID int64) bool
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

var _ orchestrator.ClaudeAccounts = (*Service)(nil)

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

// CreditsEnabled reports whether runs can fall back to credits here: agnts
// has its own key for the primary coding tool.
func (s *Service) CreditsEnabled() bool {
	if muse() {
		return s.cfg.MuseKey != ""
	}
	return s.cfg.PlatformKey != ""
}

// muse reports whether Muse Code is the primary tool: then accounts are
// Meta ones and Claude connections are not used.
func muse() bool { return domain.PrimaryProvider() == domain.ProviderMuse }

// isMuseKind reports whether a connection is a Muse account.
func isMuseKind(kind string) bool { return kind == postgres.MuseAPIKey || kind == postgres.MuseLogin }

// toolName names the primary tool in messages.
func toolName() string {
	if muse() {
		return "Muse"
	}
	return "Claude"
}

// SubscriptionsAllowed reports whether subscription tokens are accepted.
func (s *Service) SubscriptionsAllowed() bool { return s.cfg.Subscriptions }

// whose returns the member whose account a ticket of member uses in
// per-member mode: the member, else the workspace's default member, else
// its owner.
func whose(w domain.Workspace, member *int64) int64 {
	switch {
	case member != nil && *member > 0:
		return *member
	case w.DefaultMemberID != nil:
		return *w.DefaultMemberID
	default:
		return w.OwnerID
	}
}

// Pick implements orchestrator.ClaudeAccounts.
func (s *Service) Pick(ctx context.Context, w domain.Workspace, member *int64) (domain.ClaudeAccount, bool, string, time.Time) {
	var conn postgres.ClaudeConnection
	var err error
	var who string
	if w.ClaudeMode == domain.ClaudePerMember {
		uid := whose(w, member)
		conn, err = s.conns.ForUser(ctx, uid)
		who = s.name(ctx, uid)
	} else {
		conn, err = s.conns.ForWorkspace(ctx, w.ID)
		who = "the workspace"
	}
	why, until := "", time.Time{}
	if err == nil && isMuseKind(conn.Kind) != muse() {
		err = domain.ErrNotFound // a connection for a tool this server does not run
	}
	switch {
	case errors.Is(err, domain.ErrNotFound):
		if w.ClaudeMode == domain.ClaudePerMember {
			why = who + " has not connected a " + toolName() + " account (Profile → " + toolName() + ")"
		} else {
			why = "no " + toolName() + " account is connected (Workspace settings → " + toolName() + ")"
		}
	case err != nil:
		why = "could not read the " + toolName() + " account: " + err.Error()
	case conn.Kind == postgres.ClaudeSubscription && !s.cfg.Subscriptions:
		why = "this server accepts Anthropic API keys only; connect one instead of a subscription token"
	default:
		acct := domain.ClaudeAccount{ConnectionID: conn.ID, Label: label(conn, who)}
		st, serr := s.settings.Get(ctx)
		if serr != nil {
			st = domain.DefaultSettings()
		}
		paused, at := s.usage.Paused(domain.WithClaude(ctx, acct), st)
		if !paused {
			return acct, true, "", time.Time{}
		}
		why, until = toolName()+" limit reached on "+acct.Label, at
		if !at.IsZero() {
			why += "; resumes at " + at.Format("15:04")
		}
	}
	payer := whose(w, member)
	if s.CreditsEnabled() && s.cfg.Free != nil && s.cfg.Free(ctx, payer) {
		return domain.ClaudeAccount{Credits: true, Label: "free credits", UserID: payer}, true, "", time.Time{}
	}
	if w.ClaudeFallback && s.CreditsEnabled() {
		if w.CreditsBalance >= s.cfg.MinCredits {
			return domain.ClaudeAccount{Credits: true, Label: "workspace credits", UserID: payer}, true, "", time.Time{}
		}
		why += "; the workspace has no credits left to continue on"
	} else if s.CreditsEnabled() {
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

// Credential is what a run container needs to reach Claude.
type Credential struct {
	// Env is the variable Claude Code reads it from:
	// CLAUDE_CODE_OAUTH_TOKEN for a subscription, ANTHROPIC_API_KEY for a key.
	Env   string
	Token string
}

// CredentialFor returns the credential of the account ctx runs on. Without
// an account in ctx it uses the workspace's shared connection (translation
// and usage refresh runs outside the scheduler).
func (s *Service) CredentialFor(ctx context.Context) (Credential, error) {
	a, ok := domain.ClaudeOf(ctx)
	if ok && a.Credits {
		if !s.CreditsEnabled() {
			return Credential{}, errors.New("credits are not available on this server")
		}
		if muse() {
			return Credential{Env: EnvMuseKey, Token: s.cfg.MuseKey}, nil
		}
		return Credential{Env: "ANTHROPIC_API_KEY", Token: s.cfg.PlatformKey}, nil
	}
	var c postgres.ClaudeConnection
	var err error
	switch {
	case ok && a.ConnectionID > 0:
		c, err = s.conns.ByID(ctx, a.ConnectionID)
	default:
		ws, werr := domain.MustWorkspace(ctx)
		if werr != nil {
			return Credential{}, werr
		}
		c, err = s.conns.ForWorkspace(ctx, ws)
		if errors.Is(err, domain.ErrNotFound) {
			if actor, ok := domain.ActorOf(ctx); ok {
				c, err = s.conns.ForUser(ctx, actor.UserID)
			}
		}
	}
	if errors.Is(err, domain.ErrNotFound) {
		return Credential{}, fmt.Errorf("%s is not connected: connect an account in Workspace settings → %s", strings.ToLower(toolName()), toolName())
	}
	if err != nil {
		return Credential{}, err
	}
	switch c.Kind {
	case postgres.MuseAPIKey:
		return Credential{Env: EnvMuseKey, Token: c.Token}, nil
	case postgres.MuseLogin:
		return Credential{Env: EnvMuseLogin, Token: c.Token}, nil
	}
	if c.Kind == postgres.ClaudeAPIKey {
		return Credential{Env: "ANTHROPIC_API_KEY", Token: c.Token}, nil
	}
	return Credential{Env: "CLAUDE_CODE_OAUTH_TOKEN", Token: c.Token}, nil
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

// WorkspaceConnection returns a workspace's shared connection.
func (s *Service) WorkspaceConnection(ctx context.Context, ws int64) (postgres.ClaudeConnection, error) {
	return s.conns.ForWorkspace(ctx, ws)
}

// UserConnection returns a person's own connection.
func (s *Service) UserConnection(ctx context.Context, userID int64) (postgres.ClaudeConnection, error) {
	return s.conns.ForUser(ctx, userID)
}

// DeleteWorkspaceConnection disconnects a workspace's shared account.
func (s *Service) DeleteWorkspaceConnection(ctx context.Context, ws int64) error {
	return s.conns.DeleteWorkspace(ctx, ws)
}

// DeleteUserConnection disconnects a person's own account.
func (s *Service) DeleteUserConnection(ctx context.Context, userID int64) error {
	return s.conns.DeleteUser(ctx, userID)
}

// MemberConnections returns which members of a workspace have their own
// account, and until when each is paused.
func (s *Service) MemberConnections(ctx context.Context, ws int64) (map[int64]*time.Time, error) {
	return s.conns.MemberConnections(ctx, ws)
}

// UsageOf returns an account's latest usage reading.
func (s *Service) UsageOf(ctx context.Context, c postgres.ClaudeConnection) (usage.View, error) {
	st, err := s.settings.Get(ctx)
	if err != nil {
		st = domain.DefaultSettings()
	}
	return s.usage.Current(domain.WithClaude(ctx, domain.ClaudeAccount{ConnectionID: c.ID}), st)
}

// AccountFor returns the account the person in ctx sees usage for in
// workspace w: the shared one, or their own in per-member mode.
func (s *Service) AccountFor(ctx context.Context, w domain.Workspace, userID int64) (domain.ClaudeAccount, bool) {
	var c postgres.ClaudeConnection
	var err error
	if w.ClaudeMode == domain.ClaudePerMember {
		c, err = s.conns.ForUser(ctx, userID)
	} else {
		c, err = s.conns.ForWorkspace(ctx, w.ID)
	}
	if err != nil {
		return domain.ClaudeAccount{}, false
	}
	return domain.ClaudeAccount{ConnectionID: c.ID, Label: c.Account}, true
}

// PausedAccounts returns the accounts paused at their usage limit.
func (s *Service) PausedAccounts(ctx context.Context) []domain.ClaudeAccount {
	ids, err := s.conns.Paused(ctx)
	if err != nil {
		return nil
	}
	out := make([]domain.ClaudeAccount, 0, len(ids))
	for _, id := range ids {
		out = append(out, domain.ClaudeAccount{ConnectionID: id})
	}
	return out
}

// Resolve returns the account the person acting in ctx would run on in
// its workspace (for usage pages).
func (s *Service) Resolve(ctx context.Context, ws domain.Workspace) (domain.ClaudeAccount, bool) {
	uid := ws.OwnerID
	if a, ok := domain.ActorOf(ctx); ok {
		uid = a.UserID
	}
	return s.AccountFor(ctx, ws, uid)
}

// KeepMuseLogin saves the Muse login a run ended with, when Muse refreshed
// it during the run, so the connection does not expire. Runs on credits
// and on API keys have nothing to keep.
func (s *Service) KeepMuseLogin(ctx context.Context, file []byte) error {
	a, ok := domain.ClaudeOf(ctx)
	if !ok || a.Credits || a.ConnectionID == 0 {
		return nil
	}
	if _, err := credential.LoginFile(file, ""); err != nil {
		return err
	}
	return s.conns.UpdateToken(ctx, a.ConnectionID, string(file))
}
