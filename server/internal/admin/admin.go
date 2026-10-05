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

	"hiro/internal/domain"
	"hiro/internal/notify"
	"hiro/internal/orchestrator"
	"hiro/internal/store/postgres"
	"hiro/internal/tracker/jira"
	"hiro/internal/vcs"
	"hiro/internal/vcs/github"
	"hiro/internal/vcs/gitlab"
)

// ErrInvalid wraps input errors to show to the user.
var ErrInvalid = orchestrator.ErrInvalid

func invalid(format string, a ...any) error {
	return fmt.Errorf("%w: %s", ErrInvalid, fmt.Sprintf(format, a...))
}

// Providers hiro knows how to connect, in display order.
var Providers = []string{"jira", "github", "claude", "telegram", "gitlab"}

// settingKeys lists the non-secret settings each provider accepts.
var settingKeys = map[string][]string{
	"jira":     jira.SettingKeys,
	"github":   {},
	"claude":   {},
	"telegram": {"chat_id"},
	"gitlab":   {"url"},
}

// Checker verifies a token with its provider and returns the account name.
type Checker func(ctx context.Context, token string, settings map[string]string) (string, error)

// Ingester picks up tickets (the orchestrator).
type Ingester interface {
	Ingest(ctx context.Context, in orchestrator.Incoming, origin domain.Origin) (bool, error)
}

// Integrations manages provider connections.
type Integrations struct {
	store  *postgres.Integrations
	events interface {
		AppendEvent(context.Context, domain.Event) error
	}
	checkers  map[string]Checker
	jira      *jira.Client
	ingest    Ingester
	publicURL string
	log       *slog.Logger

	telegramAPI    string            // Bot API base; tests point it at a fake
	webhookSecrets map[string]string // provider -> derived webhook secret
}

// SetWebhookSecrets sets the GitHub and GitLab webhook secrets shown on their pages.
func (s *Integrations) SetWebhookSecrets(m map[string]string) { s.webhookSecrets = m }

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
	in            postgres.Integration
}

func (s *Integrations) view(in postgres.Integration) View {
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
		v.WebhookURL = s.publicURL + "/webhooks/jira"
	}
	if in.Provider == "telegram" {
		v.WebhookURL = s.publicURL + "/webhooks/telegram"
	}
	if sec, ok := s.webhookSecrets[in.Provider]; ok && in.Connected {
		v.WebhookURL, v.WebhookSecret = s.publicURL+"/webhooks/"+in.Provider, sec
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
		out = append(out, s.view(in))
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
// also creates the webhook secret, returned once.
func (s *Integrations) Connect(ctx context.Context, provider, token string, settings map[string]string, origin domain.Origin) (View, string, error) {
	settings, err := cleanSettings(provider, settings)
	if err != nil {
		return View{}, "", err
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
		if err := notify.NewBot(s.telegramAPI, token).SetWebhook(ctx, s.publicURL+"/webhooks/telegram", hook); err != nil {
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
			settings["label"] = "hiro"
		}
		if !fresh {
			secret = "" // shown only when created
		}
	}
	if err := s.store.Put(ctx, postgres.Integration{Provider: provider, Token: stored, Settings: settings, Account: account}); err != nil {
		return View{}, "", err
	}
	s.changed(ctx, provider, origin, "connected as "+account)
	in, err := s.store.Get(ctx, provider)
	return s.view(in), secret, err
}

// Test checks the stored token again.
func (s *Integrations) Test(ctx context.Context, provider string) (View, error) {
	in, err := s.store.Get(ctx, provider)
	if err != nil {
		return View{}, err
	}
	check, ok := s.checkers[provider]
	if !ok || !in.Connected {
		return s.view(in), invalid("%s is not connected", provider)
	}
	token := in.Token
	switch provider {
	case "jira":
		c, _, err := jira.FromIntegration(in.Token, in.Settings, true)
		if err != nil {
			return View{}, err
		}
		token = c.APIToken
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
	return s.view(in), err
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
		return s.view(postgres.Integration{Provider: provider}), nil
	}
	return s.view(in), err
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
	if err := s.store.UpdateSettings(ctx, provider, settings); err != nil {
		return View{}, err
	}
	s.changed(ctx, provider, origin, "settings changed")
	in, err := s.store.Get(ctx, provider)
	return s.view(in), err
}

// SyncJira picks up labelled open issues now.
func (s *Integrations) SyncJira(ctx context.Context) (found, created int, err error) {
	issues, err := s.jira.Search(ctx)
	if errors.Is(err, jira.ErrNotConnected) {
		return 0, 0, invalid("jira is not connected")
	}
	if err != nil {
		return 0, 0, err
	}
	for _, in := range issues {
		ok, err := s.ingest.Ingest(ctx, in, domain.OriginWeb)
		if err != nil {
			return len(issues), created, err
		}
		if ok {
			created++
		}
	}
	return len(issues), created, nil
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
	gh         *github.Host
	browser    vcs.Browser
	gitlabHost func(ctx context.Context) string // host of the connected GitLab, or ""
	remotes    map[string]RemoteLister
	local      LocalLister
	log        *slog.Logger
}

// RemoteLister lists the repositories a git host's token can reach.
type RemoteLister interface {
	Repos(ctx context.Context) ([]vcs.RemoteRepo, error)
}

// LocalLister lists the branches in hiro's own clones of a repository.
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

// RepoView is a repository with its open ticket count.
type RepoView struct {
	domain.Repository
	Open int
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
	out := make([]RepoView, len(repos))
	for i, x := range repos {
		out[i] = RepoView{Repository: x, Open: open[x.ID]}
	}
	return out, nil
}

// RemoteView is a repository offered for import, and whether hiro has it.
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
	return RepoView{Repository: x, Open: open[id]}, err
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
		return invalid("clone URL must be https (hiro authenticates with a token, not SSH keys)")
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
		x.BranchPrefix = "hiro/"
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
	x.Kind = RepoKind(x.JiraProject)
	return nil
}

// RepoKind is "jira" for a repository linked to a Jira project and "side"
// otherwise. Every repository takes side-project tasks; the kind only says
// whether Jira tickets arrive too.
func RepoKind(jiraProject string) string {
	if jiraProject != "" {
		return "jira"
	}
	return "side"
}

// Save creates (id 0) or updates a repository, then checks for CLAUDE.md
// in the background.
func (r *Repos) Save(ctx context.Context, x domain.Repository) (RepoView, error) {
	if err := Validate(&x, r.gitlabHost(ctx)); err != nil {
		return RepoView{}, err
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
	go r.CheckClaudeMD(context.WithoutCancel(ctx), saved)
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
