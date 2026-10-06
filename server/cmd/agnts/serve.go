package main

import (
	"github.com/modelcontextprotocol/go-sdk/mcp"

	"context"
	"errors"
	"fmt"
	"io"
	"log/slog"
	"net/http"
	"net/url"
	"os"
	"path/filepath"
	"strings"
	"time"

	"agnts/internal/admin"
	"agnts/internal/config"
	"agnts/internal/docs"
	"agnts/internal/domain"
	"agnts/internal/httpapi"
	"agnts/internal/mcpserver"
	"agnts/internal/metrics"
	"agnts/internal/notify"
	"agnts/internal/oauth"
	"agnts/internal/orchestrator"
	"agnts/internal/runner"
	"agnts/internal/secret"
	"agnts/internal/store/postgres"
	"agnts/internal/tracker/jira"
	"agnts/internal/usage"
	"agnts/internal/vcs"
	"agnts/internal/vcs/github"
	"agnts/internal/vcs/gitlab"
	"agnts/internal/vcs/gitrepo"
)

func serve(ctx context.Context, cfg config.Config, log *slog.Logger, pool postgresPool) error {
	if cfg.AutoMigrate {
		if err := postgres.Migrate(ctx, pool, "up", log); err != nil {
			return err
		}
	}
	svc, err := newAuth(cfg, pool)
	if err != nil {
		return err
	}
	a, err := newAgent(cfg, pool, log)
	if err != nil {
		return err
	}

	mcpSrv := mcpserver.NewServer(mcpserver.Deps{
		Orch: a.orch, Store: a.store, Usage: a.usage, Settings: a.settings, Dashboard: a.dashboard, Repos: a.repos, Lessons: a.lessons,
		Analytics: func(ctx context.Context, days int) (any, error) { return a.dashboard.Analytics(ctx, days) },
	}, version)
	if cfg.MetricsAddr != "" {
		go func() {
			ms := &http.Server{Addr: cfg.MetricsAddr, Handler: metrics.Handler(pool, a.orch.Active), ReadHeaderTimeout: 5 * time.Second}
			log.Info("metrics listening", "addr", cfg.MetricsAddr)
			if err := ms.ListenAndServe(); err != nil {
				log.Error("metrics", "err", err)
			}
		}()
	}
	if cfg.InternalAddr != "" {
		go func() {
			is := &http.Server{Addr: cfg.InternalAddr, Handler: internalHandler(a.settings), ReadHeaderTimeout: 5 * time.Second}
			log.Info("internal listener", "addr", cfg.InternalAddr)
			if err := is.ListenAndServe(); err != nil {
				log.Error("internal listener", "err", err)
			}
		}()
	}
	mcpHandler := mcp.NewStreamableHTTPHandler(func(*http.Request) *mcp.Server { return mcpSrv },
		&mcp.StreamableHTTPOptions{SessionTimeout: 30 * time.Minute, Logger: log.With("component", "mcp")})
	go func() {
		t := time.NewTicker(time.Hour)
		defer t.Stop()
		for {
			a.oauth.Prune(ctx)
			select {
			case <-ctx.Done():
				return
			case <-t.C:
			}
		}
	}()

	broker := httpapi.NewBroker(a.store, log.With("component", "stream"))
	go broker.Run(ctx)
	go a.notifier.Run(ctx)
	go postgres.Listen(ctx, pool, "hiro_events", func() {
		broker.Notify()
		a.notifier.Wake()
	}, log.With("component", "listen"))

	var refresher *usage.Refresher
	if cfg.AgentEnabled {
		refresher = a.refresher
	}
	handler, err := httpapi.NewHandler(httpapi.Options{
		Auth:    svc,
		Tickets: a.orch,
		Admin: &httpapi.Admin{
			Settings: a.settings, Usage: a.usage, Refresher: refresher, Logs: a.store,
			Dashboard: a.dashboard, Integrations: a.adminInteg, Repos: a.repos, Docs: docs.New(cfg.DocsDir),
		},
		Broker:       broker,
		Devices:      a.store,
		Lessons:      a.lessons,
		Rules:        a.orch,
		OAuth:        a.oauth,
		MCP:          mcpHandler,
		DB:           pool,
		Log:          log,
		PublicURL:    cfg.PublicURL,
		CookieSecure: cfg.CookieSecure,
		WebDir:       cfg.WebDir,
		Version:      version,
		Commit:       commit,
		Webhooks: map[string]http.Handler{
			"jira":     jira.WebhookHandler(a.jiraConfig, a.orch, a.store, log.With("component", "jira")),
			"telegram": a.notifier.WebhookHandler(),
			"github":   vcs.GitHubWebhook(vcs.DeriveSecret(cfg.EncKey, "github"), a.orch, a.store, a.vcs.ForgetAll, log.With("component", "github")),
			"gitlab":   vcs.GitLabWebhook(vcs.DeriveSecret(cfg.EncKey, "gitlab"), a.orch, a.store, a.vcs.ForgetAll, log.With("component", "gitlab")),
		},
	})
	if err != nil {
		return err
	}
	srv := &http.Server{
		Addr:              cfg.Addr,
		Handler:           handler,
		ReadHeaderTimeout: 10 * time.Second,
		ReadTimeout:       30 * time.Second,
		IdleTimeout:       120 * time.Second,
		// No WriteTimeout: SSE streams are long-lived.
	}

	go purgeSessions(ctx, svc, log)

	workerDone := make(chan struct{})
	if cfg.AgentEnabled {
		if err := a.docker.Ping(ctx); err != nil {
			return fmt.Errorf("docker is not reachable at %s (set AGNTS_AGENT_ENABLED=false to run the API alone): %w", cfg.DockerSocket, err)
		}
		go func() {
			defer close(workerDone)
			if err := a.orch.Run(ctx); err != nil {
				log.Error("orchestrator stopped", "err", err)
			}
		}()
		go jira.Reconcile(ctx, a.jira, a.orch, cfg.JiraSyncEach, log.With("component", "jira"))
		go pruneDeliveries(ctx, a.store, log)
		if cfg.UsageRefresh > 0 {
			go a.refresher.IdleLoop(ctx, cfg.UsageRefresh, a.orch.Active)
		}
		go a.checkRepos(ctx)
	} else {
		close(workerDone)
		log.Warn("agent loop disabled (AGNTS_AGENT_ENABLED=false): tickets are stored but not worked on")
	}

	errc := make(chan error, 1)
	go func() {
		log.Info("listening", "addr", cfg.Addr, "public_url", cfg.PublicURL.String(), "version", version, "agent", cfg.AgentEnabled)
		errc <- srv.ListenAndServe()
	}()

	select {
	case err := <-errc:
		return err
	case <-ctx.Done():
	}
	log.Info("shutting down")
	shutdownCtx, cancel := context.WithTimeout(context.Background(), cfg.ShutdownGrace)
	defer cancel()
	err = srv.Shutdown(shutdownCtx)
	select {
	case <-workerDone:
	case <-shutdownCtx.Done():
		log.Warn("stages still running at shutdown; they resume on next start")
	}
	return err
}

// agent holds the components wired together.
type agent struct {
	store        *postgres.Agent
	lessons      *postgres.Lessons
	integrations *postgres.Integrations
	settings     *postgres.Settings
	usage        *usage.Tracker
	refresher    *usage.Refresher
	orch         *orchestrator.Orchestrator
	jira         *jira.Client
	docker       *runner.Docker
	repos        *admin.Repos
	dashboard    *admin.Dashboard
	adminInteg   *admin.Integrations
	notifier     *notify.Notifier
	oauth        *oauth.Server
	vcs          *vcs.Multi
}

func newAgent(cfg config.Config, pool postgresPool, log *slog.Logger) (*agent, error) {
	box, err := secret.NewBox(cfg.EncKey)
	if err != nil {
		return nil, err
	}
	a := &agent{
		store:        postgres.NewAgent(pool),
		lessons:      postgres.NewLessons(pool),
		integrations: postgres.NewIntegrations(pool, box),
		docker:       runner.NewDocker(cfg.DockerSocket),
	}
	a.settings = postgres.NewSettings(pool, defaultSettings(cfg))
	a.jira = jira.New(a.jiraConfig)
	a.usage = usage.New(postgres.NewUsage(pool), a.store, log.With("component", "usage"))

	tokenFor := func(provider string) func(ctx context.Context) (string, error) {
		return func(ctx context.Context) (string, error) { return a.integrations.Token(ctx, provider) }
	}
	rcfg := runner.DefaultConfig()
	rcfg.Network = cfg.RunNetwork
	rcfg.Proxy = cfg.RunProxy
	run := runner.New(a.docker, rcfg, tokenFor("claude"))
	a.refresher = usage.NewRefresher(a.usage, run, cfg.RunnerImage, log.With("component", "usage"))

	repos := gitrepo.New(filepath.Join(cfg.DataDir, "repos"),
		func(ctx context.Context, provider string) (string, error) { return a.integrations.Token(ctx, provider) },
		func(ctx context.Context) (gitrepo.Author, error) {
			s, err := a.settings.Get(ctx)
			if err != nil {
				return gitrepo.Author{}, err
			}
			if s.Git.AuthorName == "" || s.Git.AuthorEmail == "" {
				return gitrepo.Author{}, errors.New("set the commit author name and email in Settings so agnts can commit as you")
			}
			return gitrepo.Author{Name: s.Git.AuthorName, Email: s.Git.AuthorEmail}, nil
		})
	homes := gitrepo.NewHomes(filepath.Join(cfg.DataDir, "sessions"))
	if err := os.MkdirAll(cfg.DataDir, 0o750); err != nil {
		return nil, fmt.Errorf("data dir: %w", err)
	}

	gh := github.New(cfg.GitHubAPI, tokenFor("github"))
	gl := gitlab.New(a.gitlabConfig)
	a.vcs = vcs.NewMulti(map[string]vcs.Provider{"github": gh, "gitlab": gl})
	ocfg := orchestrator.DefaultConfig()
	ocfg.Image = cfg.RunnerImage
	previewEnvs := postgres.NewPreviewEnvs(pool, box)
	a.orch = orchestrator.New(ocfg, orchestrator.Deps{
		Store: a.store, Runner: run, Git: repos, Host: a.vcs, Tracker: a.jira, Homes: homes,
		Settings: a.settings, Usage: a.usage, Lessons: a.lessons, Rules: postgres.NewRules(pool),
		Translations: postgres.NewTranslations(pool),
		Shots:        gitrepo.NewShots(filepath.Join(cfg.DataDir, "previews")), PreviewEnvs: previewEnvs,
	}, log.With("component", "orchestrator"))

	a.repos = admin.NewRepos(a.store, gh, a.vcs, func(ctx context.Context) string {
		c, ok, err := a.gitlabConfig(ctx)
		if err != nil || !ok {
			return ""
		}
		u, err := url.Parse(c.URL)
		if err != nil {
			return ""
		}
		return u.Hostname()
	}, log.With("component", "repos"))
	a.repos.SetRemotes(map[string]admin.RemoteLister{"github": gh, "gitlab": gl})
	a.repos.SetLocal(repos)
	a.repos.SetPreviewEnvs(previewEnvs)
	a.dashboard = admin.NewDashboard(a.store, a.orch, a.repos, a.usage, a.settings, cfg.TimeZone)
	a.adminInteg = admin.NewIntegrations(a.integrations, a.store, map[string]admin.Checker{
		"jira":     admin.JiraCheck,
		"github":   admin.GitHubCheck(gh),
		"claude":   admin.ClaudeTokenCheck,
		"telegram": admin.TelegramCheck(cfg.TelegramAPI),
		"gitlab":   admin.GitLabCheck,
	}, a.jira, a.orch, cfg.PublicURL.String(), log.With("component", "integrations"))
	a.adminInteg.SetWebhookSecrets(map[string]string{
		"github": vcs.DeriveSecret(cfg.EncKey, "github"), "gitlab": vcs.DeriveSecret(cfg.EncKey, "gitlab"),
	})
	a.adminInteg.SetTelegramAPI(cfg.TelegramAPI)

	var fcm *notify.FCM
	if cfg.FCMCredentials != "" {
		if fcm, err = notify.LoadFCM(cfg.FCMCredentials); err != nil {
			return nil, fmt.Errorf("AGNTS_FCM_CREDENTIALS: %w", err)
		}
	} else {
		log.Info("push notifications off: set AGNTS_FCM_CREDENTIALS to a Firebase service account file to enable them")
	}
	a.oauth = oauth.New(pool, cfg.PublicURL.String(), cfg.MCPRedirectHosts, log.With("component", "oauth"))
	a.notifier = notify.New(a.store, a.orch, a.settings, fcm, a.telegramConfig, cfg.TelegramAPI, log.With("component", "notify"))
	return a, nil
}

// defaultSettings applies AGNTS_* environment values until settings are saved.
func defaultSettings(cfg config.Config) domain.Settings {
	s := domain.DefaultSettings()
	if cfg.ModelAnalyze != "" {
		s.Models.Analyze = cfg.ModelAnalyze
	}
	if cfg.ModelCode != "" {
		s.Models.Coding = cfg.ModelCode
	}
	s.Parallel = min(max(cfg.Parallel, 1), 3)
	s.Git.AuthorName, s.Git.AuthorEmail = cfg.GitName, cfg.GitEmail
	return s
}

// jiraConfig loads the Jira connection; the secrets live in the encrypted token.
func (a *agent) jiraConfig(ctx context.Context) (jira.Config, bool, error) {
	in, err := a.integrations.Get(ctx, "jira")
	if errors.Is(err, domain.ErrNotFound) {
		return jira.Config{}, false, nil
	}
	if err != nil {
		return jira.Config{}, false, err
	}
	return jira.FromIntegration(in.Token, in.Settings, in.Connected)
}

// gitlabConfig loads the GitLab connection.
func (a *agent) gitlabConfig(ctx context.Context) (gitlab.Config, bool, error) {
	in, err := a.integrations.Get(ctx, "gitlab")
	if errors.Is(err, domain.ErrNotFound) {
		return gitlab.Config{}, false, nil
	}
	if err != nil {
		return gitlab.Config{}, false, err
	}
	u := in.Settings["url"]
	if u == "" {
		u = "https://gitlab.com"
	}
	return gitlab.Config{URL: u, Token: in.Token}, in.Connected, nil
}

// telegramConfig loads the Telegram connection.
func (a *agent) telegramConfig(ctx context.Context) (notify.TelegramConfig, bool, error) {
	in, err := a.integrations.Get(ctx, "telegram")
	if errors.Is(err, domain.ErrNotFound) {
		return notify.TelegramConfig{}, false, nil
	}
	if err != nil || !in.Connected {
		return notify.TelegramConfig{}, false, err
	}
	c, err := notify.ParseTelegram(in.Token, in.Settings)
	return c, err == nil, err
}

// checkRepos refreshes each repository's CLAUDE.md state once a day.
func (a *agent) checkRepos(ctx context.Context) {
	t := time.NewTicker(24 * time.Hour)
	defer t.Stop()
	for {
		if repos, err := a.store.ListRepositories(ctx); err == nil {
			for _, r := range repos {
				a.repos.CheckClaudeMD(ctx, r)
			}
		}
		select {
		case <-ctx.Done():
			return
		case <-t.C:
		}
	}
}

func pruneDeliveries(ctx context.Context, s *postgres.Agent, log *slog.Logger) {
	t := time.NewTicker(6 * time.Hour)
	defer t.Stop()
	for {
		if err := s.PruneDeliveries(ctx, 7*24*time.Hour); err != nil && ctx.Err() == nil {
			log.Warn("prune webhook deliveries", "err", err)
		}
		select {
		case <-ctx.Done():
			return
		case <-t.C:
		}
	}
}

func jiraSync(ctx context.Context, cfg config.Config, pool postgresPool, log *slog.Logger) error {
	a, err := newAgent(cfg, pool, log)
	if err != nil {
		return err
	}
	found, created, err := a.adminInteg.SyncJira(ctx)
	if err != nil {
		return err
	}
	fmt.Printf("%d labelled open issues, %d new\n", found, created)
	return nil
}

// internalHandler serves what other containers of the stack need from
// agnts and must not be public: the egress proxy reads the hosts allowed in
// Settings from /egress/allow. Caddy only routes the main listener.
func internalHandler(settings interface {
	Get(ctx context.Context) (domain.Settings, error)
}) http.Handler {
	mux := http.NewServeMux()
	mux.HandleFunc("GET /egress/allow", func(w http.ResponseWriter, r *http.Request) {
		s, err := settings.Get(r.Context())
		if err != nil {
			http.Error(w, "settings unavailable", http.StatusServiceUnavailable)
			return
		}
		w.Header().Set("Content-Type", "text/plain; charset=utf-8")
		_, _ = io.WriteString(w, strings.Join(s.EgressAllow, "\n"))
	})
	return mux
}
