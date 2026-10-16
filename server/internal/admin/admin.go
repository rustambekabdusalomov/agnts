// Package admin holds the setup use cases behind the Integrations and
// Repositories pages: connecting providers and managing repositories.
package admin

import (
	"context"
	"crypto/rand"
	"encoding/hex"
	"errors"
	"fmt"
	"log/slog"
	"net/url"
	"slices"
	"strconv"
	"strings"

	"agnts/internal/domain"
	"agnts/internal/notify"
	"agnts/internal/orchestrator"
	"agnts/internal/store/postgres"
	"agnts/internal/toolchain"
	"agnts/internal/tracker/jira"
	"agnts/internal/tracker/plane"
	"agnts/internal/vcs"
	"agnts/internal/vcs/github"
	"agnts/internal/vcs/gitlab"
)

// ErrInvalid wraps input errors to show to the user.
var ErrInvalid = orchestrator.ErrInvalid

func invalid(format string, a ...any) error {
	return fmt.Errorf("%w: %s", ErrInvalid, fmt.Sprintf(format, a...))
}

// Providers agnts knows how to connect, in display order.
var Providers = []string{"jira", "plane", "github", "telegram", "gitlab", "openai"}

// settingKeys lists the non-secret settings each provider accepts.
var settingKeys = map[string][]string{
	"jira":     jira.SettingKeys,
	"plane":    plane.SettingKeys,
	"github":   {},
	"claude":   {},
	"telegram": {"chat_id"},
	"gitlab":   {"url"},
	"openai":   {}, // Codex runs
}

// Checker verifies a token with its provider and returns the account name.
type Checker func(ctx context.Context, token string, settings map[string]string) (string, error)

// Ingester picks up tickets (the orchestrator).
type Ingester interface {
	Ingest(ctx context.Context, in orchestrator.Incoming, origin domain.Origin) (bool, error)
	IngestDetail(ctx context.Context, in orchestrator.Incoming, origin domain.Origin) (orchestrator.IngestOutcome, error)
}

// JiraSync is what a Jira sync found.
type JiraSync struct {
	Found   int // open issues for agnts (assigned to you, when that is on)
	Created int // new tickets
	Updated int // tickets not started yet that took the issue's new text
	// Waiting counts started tickets whose issue changed: each asks you to
	// restart with the new version or keep the current one.
	Waiting int
}

// Integrations manages provider connections.
type Integrations struct {
	store  *postgres.Integrations
	events interface {
		AppendEvent(context.Context, domain.Event) error
	}
	checkers  map[string]Checker
	jira      *jira.Client
	plane     *plane.Client
	planeOf   plane.Projects // Plane projects linked to repositories
	ingest    Ingester
	publicURL string
	log       *slog.Logger

	telegramAPI string     // Bot API base; tests point it at a fake
	hooks       HookSource // the workspace's webhook URLs and secrets
}

// HookSource gives the webhook URLs and secrets of the workspace a context
// acts in: each workspace has its own.
type HookSource interface {
	// HookID is the id in the workspace's webhook URLs.
	HookID(ctx context.Context) (string, error)
	// Secret is the derived webhook secret for GitHub or GitLab; "" for
	// providers that bring their own.
	Secret(ctx context.Context, provider string) string
}

// SetPlane gives the service the Plane client and the linked projects,
// for Sync Plane and the state list.
func (s *Integrations) SetPlane(c *plane.Client, projects plane.Projects) {
	s.plane, s.planeOf = c, projects
}

// SetHooks sets where webhook URLs and the GitHub and GitLab secrets
// shown on their pages come from.
func (s *Integrations) SetHooks(h HookSource) { s.hooks = h }

// hookURL is the workspace's webhook URL for provider.
func (s *Integrations) hookURL(ctx context.Context, provider string) string {
	u := s.publicURL + "/webhooks/" + provider
	if s.hooks != nil {
		if id, err := s.hooks.HookID(ctx); err == nil && id != "" {
			u += "/" + id
		}
	}
	return u
}

// NewIntegrations returns the integrations service.
func NewIntegrations(store *postgres.Integrations, events interface {
	AppendEvent(context.Context, domain.Event) error
}, checkers map[string]Checker, jc *jira.Client, ing Ingester, publicURL string, log *slog.Logger) *Integrations {
	return &Integrations{store: store, events: events, checkers: checkers, jira: jc, ingest: ing, publicURL: strings.TrimRight(publicURL, "/"), log: log}
}

// SetTelegramAPI sets the Bot API base URL.
func (s *Integrations) SetTelegramAPI(api string) { s.telegramAPI = api }

// TelegramCheck verifies a bot token with getMe.
func TelegramCheck(api string) Checker {
	return func(ctx context.Context, token string, _ map[string]string) (string, error) {
		return notify.NewBot(api, token).GetMe(ctx)
	}
}

// View is an integration without secrets.
type View struct {
	Provider      string
	Connected     bool
	CheckedAt     *string
	Account       string
	TokenHint     string
	LastError     string
	Settings      map[string]string
	WebhookURL    string
	WebhookSecret string // GitHub and GitLab: derived, shown on the page
	// WebhookSecretSet is true when a Plane webhook secret is stored.
	WebhookSecretSet bool
	in               postgres.Integration
}

func (s *Integrations) view(ctx context.Context, in postgres.Integration) View {
	v := View{Provider: in.Provider, Connected: in.Connected, Account: in.Account, LastError: in.LastError, Settings: in.Settings, in: in}
	if in.CheckedAt != nil {
		t := in.CheckedAt.UTC().Format("2006-01-02T15:04:05Z07:00")
		v.CheckedAt = &t
	}
	tok := in.Token
	if in.Provider == "telegram" {
		if c, err := notify.ParseTelegram(in.Token, in.Settings); err == nil {
			tok = c.BotToken
		}
	}
	if in.Provider == "jira" {
		if c, _, err := jira.FromIntegration(in.Token, in.Settings, in.Connected); err == nil {
			tok = c.APIToken
		}
		v.WebhookURL = s.hookURL(ctx, "jira")
	}
	if in.Provider == "plane" {
		if c, _, err := plane.FromIntegration(in.Token, in.Settings, in.Connected); err == nil {
			tok, v.WebhookSecretSet = c.APIKey, c.WebhookSecret != ""
		}
		v.WebhookURL = s.hookURL(ctx, "plane")
	}
	if in.Provider == "telegram" {
		v.WebhookURL = s.hookURL(ctx, "telegram")
	}
	if (in.Provider == "github" || in.Provider == "gitlab") && in.Connected && s.hooks != nil {
		if sec := s.hooks.Secret(ctx, in.Provider); sec != "" {
			v.WebhookURL, v.WebhookSecret = s.hookURL(ctx, in.Provider), sec
		}
	}
	if len(tok) >= 4 && in.Connected {
		v.TokenHint = tok[len(tok)-4:]
	}
	if v.Settings == nil {
		v.Settings = map[string]string{}
	}
	return v
}

// List returns every provider, connected or not.
func (s *Integrations) List(ctx context.Context) ([]View, error) {
	stored, err := s.store.List(ctx)
	if err != nil {
		return nil, err
	}
	by := map[string]postgres.Integration{}
	for _, in := range stored {
		by[in.Provider] = in
	}
	out := make([]View, 0, len(Providers))
	for _, p := range Providers {
		in, ok := by[p]
		if !ok {
			in = postgres.Integration{Provider: p, Settings: map[string]string{}}
		}
		out = append(out, s.view(ctx, in))
	}
	return out, nil
}

func cleanSettings(provider string, in map[string]string) (map[string]string, error) {
	keys, ok := settingKeys[provider]
	if !ok {
		return nil, invalid("unknown provider %q", provider)
	}
	out := map[string]string{}
	for k, v := range in {
		if !slices.Contains(keys, k) {
			return nil, invalid("%s does not have a setting %q", provider, k)
		}
		out[k] = strings.TrimSpace(v)
	}
	return out, nil
}

// Connect checks a token with the provider, then stores it. For Jira it
// also creates the webhook secret, returned once. For Plane, webhookSecret
// is the secret Plane generated ("" keeps the stored one); other providers
// ignore it.
func (s *Integrations) Connect(ctx context.Context, provider, token string, settings map[string]string, webhookSecret string, origin domain.Origin) (View, string, error) {
	settings, err := cleanSettings(provider, settings)
	if err != nil {
		return View{}, "", err
	}
	if provider == "claude" {
		return View{}, "", invalid("Claude is connected per workspace now: Workspace settings → Claude")
	}
	check, ok := s.checkers[provider]
	if !ok {
		return View{}, "", invalid("%s cannot be connected in this version", provider)
	}
	token = strings.TrimSpace(token)
	account, err := check(ctx, token, settings)
	if err != nil {
		return View{}, "", invalid("%s rejected the credentials: %v", provider, err)
	}
	stored := token
	secret := ""
	if provider == "telegram" {
		if _, err := strconv.ParseInt(settings["chat_id"], 10, 64); err != nil {
			return View{}, "", invalid("chat id must be a number: send /start to your bot and it replies with yours")
		}
		b := make([]byte, 24)
		_, _ = rand.Read(b)
		hook := hex.EncodeToString(b)
		if err := notify.NewBot(s.telegramAPI, token).SetWebhook(ctx, s.hookURL(ctx, "telegram"), hook); err != nil {
			return View{}, "", invalid("could not register the Telegram webhook: %v", err)
		}
		stored = notify.TelegramToken(token, hook)
	}
	if provider == "jira" {
		// Keep the webhook secret across reconnects; create it on first connect.
		if prev, err := s.store.Get(ctx, "jira"); err == nil {
			if c, _, err := jira.FromIntegration(prev.Token, prev.Settings, true); err == nil {
				secret = c.WebhookSecret
			}
		}
		fresh := secret == ""
		if fresh {
			b := make([]byte, 24)
			_, _ = rand.Read(b)
			secret = hex.EncodeToString(b)
		}
		stored = jira.SecretsToken(token, secret)
		if settings["label"] == "" {
			settings["label"] = "agnts"
		}
		if !fresh {
			secret = "" // shown only when created
		}
	}
	if provider == "plane" {
		hook := strings.TrimSpace(webhookSecret)
		if prev, err := s.store.Get(ctx, "plane"); err == nil && hook == "" {
			if c, _, err := plane.FromIntegration(prev.Token, prev.Settings, true); err == nil {
				hook = c.WebhookSecret
			}
		}
		stored = plane.SecretsToken(token, hook)
		if settings["label"] == "" {
			settings["label"] = "agnts"
		}
	}
	if err := s.store.Put(ctx, postgres.Integration{Provider: provider, Token: stored, Settings: settings, Account: account}); err != nil {
		return View{}, "", err
	}
	s.changed(ctx, provider, origin, "connected as "+account)
	in, err := s.store.Get(ctx, provider)
	return s.view(ctx, in), secret, err
}

// Test checks the stored token again.
func (s *Integrations) Test(ctx context.Context, provider string) (View, error) {
	in, err := s.store.Get(ctx, provider)
	if err != nil {
		return View{}, err
	}
	check, ok := s.checkers[provider]
	if !ok || !in.Connected {
		return s.view(ctx, in), invalid("%s is not connected", provider)
	}
	token := in.Token
	switch provider {
	case "jira":
		c, _, err := jira.FromIntegration(in.Token, in.Settings, true)
		if err != nil {
			return View{}, err
		}
		token = c.APIToken
	case "plane":
		c, _, err := plane.FromIntegration(in.Token, in.Settings, true)
		if err != nil {
			return View{}, err
		}
		token = c.APIKey
	case "telegram":
		c, err := notify.ParseTelegram(in.Token, in.Settings)
		if err != nil {
			return View{}, err
		}
		token = c.BotToken
	}
	account, cerr := check(ctx, token, in.Settings)
	msg := ""
	if cerr != nil {
		msg = cerr.Error()
	}
	if err := s.store.SetCheck(ctx, provider, account, msg); err != nil {
		return View{}, err
	}
	in, err = s.store.Get(ctx, provider)
	return s.view(ctx, in), err
}

// Disconnect forgets a provider's token.
func (s *Integrations) Disconnect(ctx context.Context, provider string, origin domain.Origin) (View, error) {
	if _, ok := settingKeys[provider]; !ok {
		return View{}, invalid("unknown provider %q", provider)
	}
	if err := s.store.Disconnect(ctx, provider); err != nil {
		return View{}, err
	}
	s.changed(ctx, provider, origin, "disconnected")
	in, err := s.store.Get(ctx, provider)
	if errors.Is(err, domain.ErrNotFound) {
		return s.view(ctx, postgres.Integration{Provider: provider}), nil
	}
	return s.view(ctx, in), err
}

// Update replaces non-secret settings.
func (s *Integrations) Update(ctx context.Context, provider string, settings map[string]string, origin domain.Origin) (View, error) {
	settings, err := cleanSettings(provider, settings)
	if err != nil {
		return View{}, err
	}
	if provider == "jira" {
		if u, err := url.Parse(settings["site"]); settings["site"] != "" && (err != nil || u.Scheme != "https") {
			return View{}, invalid("site must be an https URL")
		}
	}
	if provider == "plane" {
		if err := validPlaneSettings(settings); err != nil {
			return View{}, err
		}
	}
	if err := s.store.UpdateSettings(ctx, provider, settings); err != nil {
		return View{}, err
	}
	s.changed(ctx, provider, origin, "settings changed")
	in, err := s.store.Get(ctx, provider)
	return s.view(ctx, in), err
}

// SyncJira picks up the open issues for agnts now and refreshes the
// tickets it has for them.
func (s *Integrations) SyncJira(ctx context.Context) (JiraSync, error) {
	var out JiraSync
	issues, err := s.jira.Search(ctx)
	if errors.Is(err, jira.ErrNotConnected) {
		return out, invalid("jira is not connected")
	}
	if err != nil {
		return out, err
	}
	out.Found = len(issues)
	for _, in := range issues {
		res, err := s.ingest.IngestDetail(ctx, in, domain.OriginWeb)
		if err != nil {
			return out, err
		}
		switch res {
		case orchestrator.IngestCreated:
			out.Created++
		case orchestrator.IngestUpdated:
			out.Updated++
		case orchestrator.IngestAsked, orchestrator.IngestPending:
			out.Waiting++
		}
	}
	return out, nil
}

// SyncPlane picks up labelled open work items in the linked Plane projects now.
func (s *Integrations) SyncPlane(ctx context.Context) (found, created int, err error) {
	if s.plane == nil {
		return 0, 0, invalid("plane is not available on this server")
	}
	found, created, err = plane.Sync(ctx, s.plane, s.planeOf, s.ingest, domain.OriginWeb)
	if errors.Is(err, plane.ErrNotConnected) {
		return 0, 0, invalid("plane is not connected")
	}
	return found, created, err
}

// SetPlaneWebhookSecret stores the secret Plane showed when the webhook
// was created; deliveries are accepted from then on.
func (s *Integrations) SetPlaneWebhookSecret(ctx context.Context, secret string, origin domain.Origin) (View, error) {
	secret = strings.TrimSpace(secret)
	if len(secret) < 8 {
		return View{}, invalid("paste the whole secret Plane showed for the webhook")
	}
	in, err := s.store.Get(ctx, "plane")
	if errors.Is(err, domain.ErrNotFound) || (err == nil && !in.Connected) {
		return View{}, invalid("connect Plane first")
	}
	if err != nil {
		return View{}, err
	}
	c, _, err := plane.FromIntegration(in.Token, in.Settings, true)
	if err != nil {
		return View{}, err
	}
	if err := s.store.Put(ctx, postgres.Integration{Provider: "plane", Token: plane.SecretsToken(c.APIKey, secret), Settings: in.Settings, Account: in.Account}); err != nil {
		return View{}, err
	}
	s.changed(ctx, "plane", origin, "webhook secret saved")
	in, err = s.store.Get(ctx, "plane")
	return s.view(ctx, in), err
}

// PlaneState is a state name in the linked Plane projects.
type PlaneState struct {
	Name     string
	Group    string
	Projects []string
}

// PlaneStates lists the states of the Plane projects linked to
// repositories, merged by name, for the status mapping.
func (s *Integrations) PlaneStates(ctx context.Context) ([]PlaneState, error) {
	if s.plane == nil {
		return nil, invalid("plane is not available on this server")
	}
	projects, err := s.planeOf(ctx)
	if err != nil {
		return nil, err
	}
	out := []PlaneState{}
	for _, p := range projects {
		sts, err := s.plane.ProjectStates(ctx, p)
		if errors.Is(err, plane.ErrNotConnected) {
			return nil, invalid("plane is not connected")
		}
		if err != nil {
			return nil, invalid("plane project %s: %v", p, err)
		}
		for _, st := range sts {
			i := slices.IndexFunc(out, func(x PlaneState) bool { return strings.EqualFold(x.Name, st.Name) })
			if i < 0 {
				out = append(out, PlaneState{Name: st.Name, Group: st.Group})
				i = len(out) - 1
			}
			if !slices.Contains(out[i].Projects, p) {
				out[i].Projects = append(out[i].Projects, p)
			}
		}
	}
	return out, nil
}

// validPlaneSettings checks the base URL and workspace slug.
func validPlaneSettings(settings map[string]string) error {
	if b := settings["base_url"]; b != "" {
		u, err := url.Parse(b)
		if err != nil || (u.Scheme != "https" && u.Scheme != "http") || u.Host == "" {
			return invalid("base URL must be an http(s) URL, such as https://api.plane.so or your Plane's address")
		}
	}
	for _, c := range settings["workspace"] {
		if (c < 'a' || c > 'z') && (c < '0' || c > '9') && c != '-' && c != '_' {
			return invalid("the workspace slug is the part after the host in Plane's URL, such as acme in app.plane.so/acme")
		}
	}
	return nil
}

// PlaneCheck verifies a Plane API key against the workspace in settings.
func PlaneCheck(ctx context.Context, token string, settings map[string]string) (string, error) {
	if err := validPlaneSettings(settings); err != nil {
		return "", err
	}
	if strings.TrimSpace(settings["workspace"]) == "" {
		return "", errors.New("the workspace slug is required")
	}
	c := plane.New(func(context.Context) (plane.Config, bool, error) {
		cfg, _, err := plane.FromIntegration(plane.SecretsToken(token, ""), settings, true)
		return cfg, true, err
	})
	return c.Me(ctx)
}

func (s *Integrations) changed(ctx context.Context, provider string, origin domain.Origin, msg string) {
	if err := s.events.AppendEvent(ctx, domain.Event{Type: domain.EventIntegration, Origin: origin, Message: provider + " " + msg}); err != nil {
		s.log.Warn("integration event", "err", err)
	}
}

// ClaudeTokenCheck accepts tokens from `claude setup-token`. They cannot be
// verified without a run, so this checks the format only.
func ClaudeTokenCheck(_ context.Context, token string, _ map[string]string) (string, error) {
	if !strings.HasPrefix(token, "sk-ant-") || len(token) < 40 {
		return "", errors.New("expected a token from `claude setup-token` (sk-ant-...)")
	}
	return "Claude subscription", nil
}

// GitHubCheck verifies a GitHub token.
func GitHubCheck(h *github.Host) Checker {
	return func(ctx context.Context, token string, _ map[string]string) (string, error) {
		return h.WithToken(token).User(ctx)
	}
}

// JiraCheck verifies Jira credentials against /myself.
func JiraCheck(ctx context.Context, token string, settings map[string]string) (string, error) {
	site := strings.TrimRight(settings["site"], "/")
	if u, err := url.Parse(site); err != nil || u.Scheme != "https" || u.Host == "" {
		return "", errors.New("site must be an https URL like https://your-team.atlassian.net")
	}
	if settings["email"] == "" {
		return "", errors.New("email is required")
	}
	c := jira.New(func(context.Context) (jira.Config, bool, error) {
		return jira.Config{Site: site, Email: settings["email"], APIToken: token}, true, nil
	})
	return c.Myself(ctx)
}

// Repos manages repositories.
type Repos struct {
	store      *postgres.Agent
	envs       PreviewEnvSetter
	builds     BuildEnvSetter
	detector   Detector
	deep       DeepDetector
	images     func(ctx context.Context, image string) error
	gh         *github.Host
	browser    vcs.Browser
	gitlabHost func(ctx context.Context) string // host of the connected GitLab, or ""
	remotes    map[string]RemoteLister
	local      LocalLister
	log        *slog.Logger
	// onArchive frees what an archived repository held on the server
	// (its package cache); nil does nothing.
	onArchive func(ctx context.Context, repo domain.Repository)
}

// OnArchive sets what frees an archived repository's server resources.
func (r *Repos) OnArchive(f func(ctx context.Context, repo domain.Repository)) { r.onArchive = f }

// PreviewEnvSetter stores a repository's sealed preview environment.
type PreviewEnvSetter interface {
	SetPreviewEnv(ctx context.Context, repoID int64, env string) error
}

// SetPreviewEnvs lets Save store preview environments.
func (r *Repos) SetPreviewEnvs(envs PreviewEnvSetter) { r.envs = envs }

// BuildEnvSetter stores a repository's sealed build environment.
type BuildEnvSetter interface {
	SetBuildEnv(ctx context.Context, repoID int64, env string) error
}

// SetBuildEnvs lets Save store build environments.
func (r *Repos) SetBuildEnvs(b BuildEnvSetter) { r.builds = b }

// Detector reads a repository's default branch and works out its
// toolchains and check commands.
type Detector interface {
	Detect(ctx context.Context, repo domain.Repository) (toolchain.Detection, error)
}

// SetDetector enables toolchain detection.
func (r *Repos) SetDetector(d Detector) { r.detector = d }

// DeepDetector asks Claude to fill what the file scan could not find.
type DeepDetector interface {
	DetectDeep(ctx context.Context, repo domain.Repository, base toolchain.Detection) (toolchain.Detection, error)
}

// SetDeepDetector enables Claude-assisted detection.
func (r *Repos) SetDeepDetector(d DeepDetector) { r.deep = d }

// SetImageCheck sets how a custom runner image is checked on save.
func (r *Repos) SetImageCheck(f func(ctx context.Context, image string) error) { r.images = f }

// Detect clones (or fetches) a repository, saved or not, and returns what
// it needs without storing anything. With deep, Claude fills the gaps
// when the file scan found no commands or no toolchains; byClaude
// reports that it did.
func (r *Repos) Detect(ctx context.Context, x domain.Repository, deep bool) (det toolchain.Detection, byClaude bool, err error) {
	det, err = r.detectFiles(ctx, &x)
	if err != nil || !deep || r.deep == nil {
		return det, false, err
	}
	if len(det.Toolchains) > 0 && det.Build != "" && det.Test != "" {
		return det, false, nil // nothing for Claude to add
	}
	more, err := r.deep.DetectDeep(ctx, x, det)
	if errors.Is(err, orchestrator.ErrPlanLimit) {
		return det, false, invalid("the Claude plan limit is reached; try again later")
	}
	if err != nil {
		return det, false, invalid("Claude could not read the repository: %v", err)
	}
	return more, true, nil
}

func (r *Repos) detectFiles(ctx context.Context, x *domain.Repository) (toolchain.Detection, error) {
	if r.detector == nil {
		return toolchain.Detection{}, invalid("toolchain detection needs the agent loop (AGNTS_AGENT_ENABLED)")
	}
	if x.ID != 0 {
		cur, err := r.store.RepositoryByID(ctx, x.ID)
		if err != nil {
			return toolchain.Detection{}, err
		}
		if x.CloneURL != "" {
			cur.CloneURL = x.CloneURL
		}
		if x.DefaultBranch != "" {
			cur.DefaultBranch = x.DefaultBranch
		}
		*x = cur
	}
	if x.Name == "" {
		x.Name = "_detect-" + repoKeySlug(x.CloneURL)
	}
	if err := Validate(x, r.gitlabHost(ctx)); err != nil {
		return toolchain.Detection{}, err
	}
	det, err := r.detector.Detect(ctx, *x)
	if err != nil {
		return toolchain.Detection{}, invalid("could not read the repository: %v", err)
	}
	return det, nil
}

func repoKeySlug(cloneURL string) string {
	k := repoKey(cloneURL)
	if i := strings.Index(k, "://"); i >= 0 {
		k = k[i+3:]
	}
	return strings.Map(func(c rune) rune {
		if c >= 'a' && c <= 'z' || c >= '0' && c <= '9' || c == '-' {
			return c
		}
		return '-'
	}, k)
}

// detectAndStore runs detection for a newly saved repository so its
// toolchains (and, when none were given, check commands) are filled in
// before the first ticket.
func (r *Repos) detectAndStore(ctx context.Context, x domain.Repository) {
	if r.detector == nil {
		return
	}
	det, err := r.detector.Detect(ctx, x)
	if err != nil {
		r.log.Info("detect toolchains", "repo", x.Name, "err", err)
		return
	}
	if _, err := r.store.SetDetectedToolchains(ctx, x.ID, det.Toolchains, det.Notes, det.Build, det.Lint, det.Test); err != nil {
		r.log.Warn("store detected toolchains", "repo", x.Name, "err", err)
	}
}

// RemoteLister lists the repositories a git host's token can reach.
type RemoteLister interface {
	Repos(ctx context.Context) ([]vcs.RemoteRepo, error)
}

// LocalLister lists the branches in agnts's own clones of a repository.
type LocalLister interface {
	LocalBranches(repo domain.Repository) ([]vcs.LocalBranch, error)
}

// SetLocal sets where local branches are read from.
func (r *Repos) SetLocal(l LocalLister) { r.local = l }

// SetRemotes sets the git hosts the import picker lists from ("github", "gitlab").
func (r *Repos) SetRemotes(m map[string]RemoteLister) { r.remotes = m }

// NewRepos returns the repositories service.
func NewRepos(store *postgres.Agent, gh *github.Host, browser vcs.Browser, gitlabHost func(ctx context.Context) string, log *slog.Logger) *Repos {
	if gitlabHost == nil {
		gitlabHost = func(context.Context) string { return "" }
	}
	return &Repos{store: store, gh: gh, browser: browser, gitlabHost: gitlabHost, log: log}
}

// RepoView is a repository with its open ticket count and the groups it
// is in (id and name).
type RepoView struct {
	domain.Repository
	Open   int
	Groups []domain.RepoGroup
}

// List returns repositories with open ticket counts.
func (r *Repos) List(ctx context.Context) ([]RepoView, error) {
	repos, err := r.store.ListRepositories(ctx)
	if err != nil {
		return nil, err
	}
	open, err := r.store.OpenTicketCounts(ctx)
	if err != nil {
		return nil, err
	}
	groups, err := r.store.GroupsOfRepos(ctx)
	if err != nil {
		return nil, err
	}
	out := make([]RepoView, len(repos))
	for i, x := range repos {
		out[i] = RepoView{Repository: x, Open: open[x.ID], Groups: groups[x.ID]}
	}
	return out, nil
}

// RemoteView is a repository offered for import, and whether agnts has it.
type RemoteView struct {
	vcs.RemoteRepo
	Added bool
}

// Remote lists the repositories the connected provider's token can reach,
// marking the ones already added.
func (r *Repos) Remote(ctx context.Context, provider string) ([]RemoteView, error) {
	l, ok := r.remotes[provider]
	if !ok {
		return nil, invalid("repositories can be imported from GitHub or GitLab only")
	}
	list, err := l.Repos(ctx)
	if errors.Is(err, vcs.ErrNotConnected) {
		return nil, invalid("%s is not connected: connect it on the Integrations page first", provider)
	}
	if err != nil {
		return nil, err
	}
	have, err := r.store.ListRepositories(ctx)
	if err != nil {
		return nil, err
	}
	known := make(map[string]bool, len(have))
	for _, x := range have {
		known[repoKey(x.CloneURL)] = true
	}
	out := make([]RemoteView, len(list))
	for i, x := range list {
		out[i] = RemoteView{RemoteRepo: x, Added: known[repoKey(x.CloneURL)]}
	}
	return out, nil
}

// repoKey compares clone URLs regardless of case, ".git" and a trailing slash.
func repoKey(cloneURL string) string {
	return strings.TrimSuffix(strings.TrimRight(strings.ToLower(strings.TrimSpace(cloneURL)), "/"), ".git")
}

// Get returns one repository.
func (r *Repos) Get(ctx context.Context, id int64) (RepoView, error) {
	x, err := r.store.RepositoryByID(ctx, id)
	if err != nil {
		return RepoView{}, err
	}
	open, err := r.store.OpenTicketCounts(ctx)
	if err != nil {
		return RepoView{}, err
	}
	groups, err := r.store.GroupsOfRepos(ctx)
	return RepoView{Repository: x, Open: open[id], Groups: groups[id]}, err
}

// Validate checks and normalises a repository from the form. gitlabHost is
// the connected GitLab instance's host, or "" when GitLab is not connected.
func Validate(x *domain.Repository, gitlabHost string) error {
	x.Name = strings.TrimSpace(x.Name)
	x.CloneURL = strings.TrimSpace(x.CloneURL)
	if x.Name == "" {
		return invalid("name is required")
	}
	if u, err := url.Parse(x.CloneURL); err != nil || u.Scheme != "https" {
		return invalid("clone URL must be https (agnts authenticates with a token, not SSH keys)")
	}
	u, _ := url.Parse(x.CloneURL)
	switch {
	case strings.EqualFold(u.Hostname(), "github.com"):
		if _, _, err := github.OwnerRepo(x.CloneURL); err != nil {
			return invalid("%v", err)
		}
		x.Provider = "github"
	case gitlabHost != "" && strings.EqualFold(u.Hostname(), gitlabHost):
		x.Provider = "gitlab"
		x.DeployWorkflow = ""
	default:
		return invalid("the clone URL must be on github.com or on your connected GitLab")
	}
	if x.DefaultBranch == "" {
		x.DefaultBranch = "main"
	}
	if x.BranchPrefix == "" {
		x.BranchPrefix = "agnts/"
	}
	x.BranchTemplate = strings.TrimSpace(x.BranchTemplate)
	if x.BranchTemplate == domain.DefaultBranchTemplate {
		x.BranchTemplate = ""
	}
	if err := domain.ValidateBranchTemplate(x.BranchTemplate); err != nil {
		return invalid("%v", err)
	}
	x.CommitTemplate = strings.TrimSpace(x.CommitTemplate)
	if err := domain.ValidateCommitTemplate(x.CommitTemplate); err != nil {
		return invalid("%v", err)
	}
	x.TaskPrefix = strings.ToUpper(strings.TrimSpace(x.TaskPrefix))
	for _, c := range x.TaskPrefix {
		if c < 'A' || c > 'Z' {
			return invalid("task prefix may only contain letters")
		}
	}
	x.JiraProject = strings.ToUpper(strings.TrimSpace(x.JiraProject))
	for _, c := range x.JiraProject {
		if (c < 'A' || c > 'Z') && (c < '0' || c > '9') && c != '_' {
			return invalid("jira project key may only contain letters, digits and _")
		}
	}
	// Side tasks and Jira tickets share one key space (KEY-1), so the two
	// prefixes must differ.
	if x.JiraProject != "" && orchestrator.TaskPrefix(*x) == x.JiraProject {
		return invalid("the task prefix must differ from the Jira project key: both would number tickets %s-1, %s-2, …", x.JiraProject, x.JiraProject)
	}
	x.PlaneProject = strings.ToUpper(strings.TrimSpace(x.PlaneProject))
	for _, c := range x.PlaneProject {
		if (c < 'A' || c > 'Z') && (c < '0' || c > '9') {
			return invalid("plane project identifier may only contain letters and digits")
		}
	}
	if len(x.PlaneProject) > 12 {
		return invalid("plane project identifiers are at most 12 characters")
	}
	if x.PlaneProject != "" && orchestrator.TaskPrefix(*x) == x.PlaneProject {
		return invalid("the task prefix must differ from the Plane project identifier: both would number tickets %s-1, %s-2, …", x.PlaneProject, x.PlaneProject)
	}
	if x.PlaneProject != "" && x.PlaneProject == x.JiraProject {
		return invalid("the Jira project key and the Plane project identifier must differ: both would number tickets %s-1, %s-2, …", x.PlaneProject, x.PlaneProject)
	}
	x.Kind = RepoKind(x.JiraProject, x.PlaneProject)
	if err := validateRun(x); err != nil {
		return err
	}
	return validatePreview(&x.Preview)
}

// validateRun checks a repository's toolchains, runner image and memory.
func validateRun(x *domain.Repository) error {
	tcs, err := domain.ValidateToolchains(x.Toolchains)
	if err != nil {
		return invalid("toolchains: %v", err)
	}
	x.Toolchains = tcs
	x.RunnerImage = strings.TrimSpace(x.RunnerImage)
	if x.RunnerImage != "" && !domain.ValidImage(x.RunnerImage) {
		return invalid("%q is not a Docker image name", x.RunnerImage)
	}
	if x.MemoryMB != 0 && (x.MemoryMB < 512 || x.MemoryMB > 65536) {
		return invalid("memory must be between 512 and 65536 MB (0 uses the server default)")
	}
	return nil
}

// validatePreview cleans a repository's preview settings. An empty command
// turns previews off and needs nothing else.
func validatePreview(p *domain.PreviewConfig) error {
	p.Command, p.Login = strings.TrimSpace(p.Command), strings.TrimSpace(p.Login)
	p.ReadyPath = strings.TrimSpace(p.ReadyPath)
	if p.ReadyPath == "" {
		p.ReadyPath = "/"
	}
	if !strings.HasPrefix(p.ReadyPath, "/") {
		return invalid("the preview ready path must start with /")
	}
	if p.Command != "" && (p.Port < 1 || p.Port > 65535) {
		return invalid("the preview needs the port the app listens on (1-65535)")
	}
	if p.Port < 0 || p.Port > 65535 {
		return invalid("the preview port must be between 1 and 65535")
	}
	clean := func(in []string, what string, check func(string) bool) ([]string, error) {
		out := []string{}
		for _, v := range in {
			if v = strings.TrimSpace(v); v == "" || slices.Contains(out, v) {
				continue
			}
			if !check(v) {
				return nil, invalid("%q is not a valid %s", v, what)
			}
			out = append(out, v)
		}
		return out, nil
	}
	var err error
	if p.Routes, err = clean(p.Routes, "preview route (it must start with /)", func(v string) bool {
		return strings.HasPrefix(v, "/") && !strings.ContainsAny(v, " \t\n")
	}); err != nil {
		return err
	}
	p.UIPaths, err = clean(p.UIPaths, "UI path (a glob relative to the repository root, such as src/**/*.vue)", func(v string) bool {
		return !strings.HasPrefix(v, "/") && !strings.Contains(v, "..")
	})
	return err
}

// RepoKind is "jira" for a repository linked to a Jira project, "plane"
// for one linked only to a Plane project, and "side" otherwise. Every
// repository takes side-project tasks; the kind only says whether tracker
// tickets arrive too.
func RepoKind(jiraProject, planeProject string) string {
	switch {
	case jiraProject != "":
		return "jira"
	case planeProject != "":
		return "plane"
	}
	return "side"
}

// checkKeySpace refuses a repository whose Plane project would number
// tickets like another repository's Jira project or task prefix, or the
// other way round. Jira projects among themselves are kept apart by a
// unique index, as are Plane projects.
func (r *Repos) checkKeySpace(ctx context.Context, x domain.Repository) error {
	others, err := r.store.ListRepositories(ctx)
	if err != nil {
		return err
	}
	for _, o := range others {
		if o.ID == x.ID || (x.ID == 0 && o.Name == x.Name) {
			continue
		}
		clash := ""
		switch {
		case x.PlaneProject != "" && (x.PlaneProject == o.JiraProject || x.PlaneProject == orchestrator.TaskPrefix(o)):
			clash = x.PlaneProject
		case o.PlaneProject != "" && (o.PlaneProject == x.JiraProject || o.PlaneProject == orchestrator.TaskPrefix(x)):
			clash = o.PlaneProject
		}
		if clash != "" {
			return invalid("%s already numbers tickets %s-1, %s-2, …: pick another Plane project, Jira project or task prefix", o.Name, clash, clash)
		}
	}
	return nil
}

// Save creates (id 0) or updates a repository, then checks for CLAUDE.md
// in the background. keepPreview keeps an existing repository's preview
// settings (the client did not send them); env, when not nil, replaces the
// preview environment ("" clears it).
func (r *Repos) Save(ctx context.Context, x domain.Repository, keepPreview bool, env *string) (RepoView, error) {
	return r.SaveRun(ctx, x, SaveOptions{KeepPreview: keepPreview, PreviewEnv: env, KeepRun: true})
}

// SaveOptions says which parts of a repository the client left out (and
// so are kept) and which secrets it replaces.
type SaveOptions struct {
	KeepPreview bool    // keep the stored preview settings
	PreviewEnv  *string // replaces the preview environment; nil keeps it
	// KeepRun keeps the stored toolchains, runner image and memory (a
	// client that does not know about them).
	KeepRun  bool
	BuildEnv *string // replaces the build environment; nil keeps it
	// KeepPlane keeps the stored Plane project (a client that does not
	// know about Plane).
	KeepPlane bool
}

// SaveRun is Save with control over the run settings.
func (r *Repos) SaveRun(ctx context.Context, x domain.Repository, o SaveOptions) (RepoView, error) {
	keepPreview, env := o.KeepPreview, o.PreviewEnv
	if x.ID != 0 && (keepPreview || o.KeepRun || o.KeepPlane) {
		cur, err := r.store.RepositoryByID(ctx, x.ID)
		if err != nil {
			return RepoView{}, err
		}
		if keepPreview {
			x.Preview = cur.Preview
		}
		if o.KeepRun {
			x.Toolchains, x.ToolchainsOverride, x.RunnerImage, x.MemoryMB = cur.Toolchains, cur.ToolchainsOverride, cur.RunnerImage, cur.MemoryMB
		}
		if o.KeepPlane {
			x.PlaneProject = cur.PlaneProject
		}
	}
	if err := Validate(&x, r.gitlabHost(ctx)); err != nil {
		return RepoView{}, err
	}
	if err := r.checkKeySpace(ctx, x); err != nil {
		return RepoView{}, err
	}
	if x.RunnerImage != "" && r.images != nil {
		if err := r.images(ctx, x.RunnerImage); errors.Is(err, domain.ErrNotFound) {
			return RepoView{}, invalid("image %s is not on this server: build it there first (see deploy/runner/README.md)", x.RunnerImage)
		} else if err != nil {
			return RepoView{}, invalid("runner image: %v", err)
		}
	}
	if o.BuildEnv != nil {
		if r.builds == nil {
			return RepoView{}, invalid("build environments are not available on this server")
		}
		if _, err := domain.ParseEnv(*o.BuildEnv); err != nil {
			return RepoView{}, invalid("build environment: %v", err)
		}
	}
	if env != nil {
		if r.envs == nil {
			return RepoView{}, invalid("preview environments are not available on this server")
		}
		if _, err := domain.ParseEnv(*env); err != nil {
			return RepoView{}, invalid("preview environment: %v", err)
		}
	}
	var saved domain.Repository
	var err error
	if x.ID == 0 {
		saved, err = r.store.SaveRepository(ctx, x)
	} else {
		saved, err = r.store.UpdateRepository(ctx, x)
	}
	if err != nil {
		return RepoView{}, err
	}
	if env != nil {
		if err := r.envs.SetPreviewEnv(ctx, saved.ID, *env); err != nil {
			return RepoView{}, err
		}
	}
	if o.BuildEnv != nil {
		if err := r.builds.SetBuildEnv(ctx, saved.ID, *o.BuildEnv); err != nil {
			return RepoView{}, err
		}
	}
	go r.CheckClaudeMD(context.WithoutCancel(ctx), saved)
	if x.ID == 0 && len(saved.Toolchains) == 0 && !saved.ToolchainsOverride {
		go r.detectAndStore(context.WithoutCancel(ctx), saved)
	}
	return r.Get(ctx, saved.ID)
}

// SetArchived archives a repository (it keeps its history but takes no new
// tickets or tasks) or restores it.
func (r *Repos) SetArchived(ctx context.Context, id int64, archived bool, origin domain.Origin) (RepoView, error) {
	x, err := r.store.SetRepositoryArchived(ctx, id, archived)
	if err != nil {
		return RepoView{}, err
	}
	msg := x.Name + " restored from the archive"
	if archived {
		msg = x.Name + " archived"
		if r.onArchive != nil {
			r.onArchive(context.WithoutCancel(ctx), x)
		}
	}
	if err := r.store.AppendEvent(ctx, domain.Event{Type: domain.EventRepoArchived, Origin: origin, Message: msg,
		Data: map[string]any{"repo": x.Name, "archived": archived}}); err != nil {
		r.log.Warn("repository archive event", "err", err)
	}
	return r.Get(ctx, id)
}

// CheckClaudeMD records whether the repository has a CLAUDE.md.
func (r *Repos) CheckClaudeMD(ctx context.Context, x domain.Repository) {
	if x.Provider != "github" {
		return // GitLab: shown as unknown
	}
	ok, err := r.gh.HasFile(ctx, x, "CLAUDE.md")
	state := "missing"
	switch {
	case err != nil:
		r.log.Debug("check CLAUDE.md", "repo", x.Name, "err", err)
		state = "unknown"
	case ok:
		state = "found"
	}
	if err := r.store.SetClaudeMDState(ctx, x.ID, state); err != nil {
		r.log.Warn("save CLAUDE.md state", "err", err)
	}
}

// GitLabCheck verifies a GitLab token against the instance in settings.
func GitLabCheck(ctx context.Context, token string, settings map[string]string) (string, error) {
	u := strings.TrimRight(settings["url"], "/")
	if u == "" {
		u = "https://gitlab.com"
		settings["url"] = u
	}
	if p, err := url.Parse(u); err != nil || p.Scheme != "https" || p.Host == "" {
		return "", errors.New("the GitLab URL must be https")
	}
	return gitlab.WithConfig(gitlab.Config{URL: u, Token: token}).User(ctx)
}

// SetHarness saves the guard and check settings people chose for a
// repository.
func (r *Repos) SetHarness(ctx context.Context, id int64, h domain.RepoHarness, origin domain.Origin) (RepoView, error) {
	if err := h.Validate(); err != nil {
		return RepoView{}, invalid("%s", err)
	}
	x, err := r.store.SetRepoHarness(ctx, id, h)
	if err != nil {
		return RepoView{}, err
	}
	if err := r.store.AppendEvent(ctx, domain.Event{Type: domain.EventRepoHarness, Origin: origin, Message: x.Name + ": guard and check settings changed",
		Data: map[string]any{"repo": x.Name, "guardProfile": h.GuardProfile, "coverage": h.Coverage.Enabled, "acceptance": h.Acceptance}}); err != nil {
		r.log.Warn("repository harness event", "err", err)
	}
	return r.Get(ctx, id)
}
