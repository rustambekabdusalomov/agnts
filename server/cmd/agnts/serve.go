package main

import (
	"github.com/modelcontextprotocol/go-sdk/mcp"

	"context"
	"errors"
	"fmt"
	"io"
	"log/slog"
	"maps"
	"net/http"
	"net/url"
	"os"
	"path/filepath"
	"strconv"
	"strings"
	"text/tabwriter"
	"time"

	"agnts/internal/accounts"
	"agnts/internal/admin"
	"agnts/internal/billing"
	"agnts/internal/claude"
	"agnts/internal/config"
	"agnts/internal/docs"
	"agnts/internal/domain"
	"agnts/internal/google"
	"agnts/internal/httpapi"
	"agnts/internal/mail"
	"agnts/internal/mcpserver"
	"agnts/internal/metrics"
	"agnts/internal/notify"
	"agnts/internal/oauth"
	"agnts/internal/orchestrator"
	"agnts/internal/runner"
	"agnts/internal/secret"
	"agnts/internal/store/postgres"
	"agnts/internal/toolchain"
	"agnts/internal/tracker/jira"
	"agnts/internal/tracker/plane"
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
	if ok, err := postgres.DetectTenantRole(ctx, pool); err != nil {
		return fmt.Errorf("check the agnts_tenant role: %w", err)
	} else if !ok {
		log.Warn("the agnts_tenant role is missing: workspace isolation relies on the database login role not being a superuser (run the migrations as a role that can create roles)")
	}
	// Background work reads every workspace and scopes itself per item.
	sys := domain.System(ctx)
	svc, err := newAuth(cfg, pool)
	if err != nil {
		return err
	}
	if cfg.PasswordSignIn == "admins" {
		svc.PasswordsForAdminsOnly()
		if cfg.GoogleClientID == "" {
			log.Warn("only Admins sign in with a password (AGNTS_PASSWORD_SIGNIN=admins) and Google sign-in is off (AGNTS_GOOGLE_CLIENT_ID): nobody else can sign in")
		}
	}
	a, err := newAgent(cfg, pool, log)
	if err != nil {
		return err
	}
	if err := a.adoptLegacy(sys); err != nil {
		log.Warn("move files from before workspaces", "err", err)
	}
	mailer, err := mail.New(cfg.SMTPURL, cfg.MailFrom, log.With("component", "mail"))
	if err != nil {
		return err
	}
	if !mailer.Enabled() {
		log.Info("email off: set AGNTS_SMTP_URL to send verification, invite and password reset emails (they are logged meanwhile)")
	}
	acc := accounts.New(accounts.Config{
		PublicURL: cfg.PublicURL.String(), Open: cfg.Signup == "open", Cloud: cfg.Cloud, TrialDays: cfg.TrialDays,
		IncludedMembers: cfg.IncludedMembers, DefaultSlots: cfg.Parallel,
	}, svc, a.users, a.workspaces, a.store, mailer, a.files(), log.With("component", "accounts"))

	mcpSrv := mcpserver.NewServer(mcpserver.Deps{
		Orch: a.orch, Store: a.store, Usage: a.usage, Settings: a.settings, Dashboard: a.dashboard, Repos: a.repos, Lessons: a.lessons,
		Analytics: func(ctx context.Context, days int) (any, error) { return a.dashboard.Analytics(ctx, days) },
		Role:      a.workspaces.Role,
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
			is := &http.Server{Addr: cfg.InternalAddr, Handler: internalHandler(a.egressAllow), ReadHeaderTimeout: 5 * time.Second}
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
			a.oauth.Prune(sys)
			select {
			case <-ctx.Done():
				return
			case <-t.C:
			}
		}
	}()

	broker := httpapi.NewBroker(a.store, log.With("component", "stream"))
	go broker.Run(sys)
	go a.notifier.Run(sys)
	go postgres.Listen(sys, pool, "hiro_events", func() {
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
		Briefs:       a.orch,
		Reviews:      a.orch,
		OAuth:        a.oauth,
		MCP:          mcpHandler,
		DB:           pool,
		Log:          log,
		PublicURL:    cfg.PublicURL,
		CookieSecure: cfg.CookieSecure,
		WebDir:       cfg.WebDir,
		Version:      version,
		Commit:       commit,
		Workspaces:   a.workspaces,
		Users:        a.users,
		Accounts:     acc,
		Claude:       a.claude,
		Queue:        a.orch,
		Billing:      a.billing,
		EventLog:     a.store,
		Cloud:        cfg.Cloud,
		Google:       googleSignIn(cfg, acc),
		Feedback:     postgres.NewFeedbacks(pool),
		SiteURL:      cfg.SiteURL,
		Payments: map[string]http.Handler{
			"payme": a.billing.PaymeHandler(),
			"click": a.billing.ClickHandler(),
		},
		Webhooks: map[string]http.Handler{
			"jira":     jira.WebhookHandler(a.jiraConfig, a.jira.AccountID, a.orch, a.store, log.With("component", "jira")),
			"plane":    plane.WebhookHandler(a.planeConfig, a.plane, a.orch, a.store, log.With("component", "plane")),
			"telegram": a.notifier.WebhookHandler(),
			"github":   vcs.GitHubWebhook(hookSecret(cfg.EncKey, "github"), a.orch, a.store, a.vcs.ForgetAll, log.With("component", "github")),
			"gitlab":   vcs.GitLabWebhook(hookSecret(cfg.EncKey, "gitlab"), a.orch, a.store, a.vcs.ForgetAll, log.With("component", "gitlab")),
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

	go purgeSessions(sys, svc, log)
	go every(sys, 24*time.Hour, func(ctx context.Context) {
		if err := acc.PurgeDeleted(ctx); err != nil {
			log.Warn("purge deleted workspaces", "err", err)
		}
	})
	go every(sys, time.Hour, func(ctx context.Context) {
		if err := a.billing.Renew(ctx); err != nil {
			log.Warn("renew plans", "err", err)
		}
	})

	workerDone := make(chan struct{})
	if cfg.AgentEnabled {
		if err := a.docker.Ping(ctx); err != nil {
			return fmt.Errorf("docker is not reachable at %s (set AGNTS_AGENT_ENABLED=false to run the API alone): %w", cfg.DockerSocket, err)
		}
		a.sizeBudget(ctx, cfg, log)
		go func() {
			defer close(workerDone)
			if err := a.orch.Run(sys); err != nil {
				log.Error("orchestrator stopped", "err", err)
			}
		}()
		go jira.Reconcile(sys, a.jira, a.orch, cfg.JiraSyncEach, a.forEachWorkspace, log.With("component", "jira"))
		go plane.Reconcile(sys, a.plane, a.planeProjects, a.orch, cfg.PlaneSyncEach, a.forEachWorkspace, log.With("component", "plane"))
		go pruneDeliveries(sys, a.store, log)
		if cfg.UsageRefresh > 0 {
			go a.refresher.IdleLoop(sys, cfg.UsageRefresh, a.orch.Active, a.claude.PausedAccounts)
		}
		go a.checkRepos(sys)
		if cfg.CacheMaxBytes > 0 || cfg.CacheIdleDays > 0 {
			go sweepCaches(sys, a.runner, cfg.CacheMaxBytes, time.Duration(cfg.CacheIdleDays)*24*time.Hour, log.With("component", "runner"))
		}
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
	plane        *plane.Client
	docker       *runner.Docker
	runner       *runner.Runner
	repos        *admin.Repos
	dashboard    *admin.Dashboard
	adminInteg   *admin.Integrations
	notifier     *notify.Notifier
	oauth        *oauth.Server
	vcs          *vcs.Multi
	workspaces   *postgres.Workspaces
	git          *gitrepo.Repos
	homes        *gitrepo.Homes
	shots        *gitrepo.Shots
	users        *postgres.Users
	claude       *claude.Service
	billing      *billing.Service
	budget       *orchestrator.MemoryBudget
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
		workspaces:   postgres.NewWorkspaces(pool),
		users:        postgres.NewUsers(pool),
	}
	a.settings = postgres.NewSettings(pool, defaultSettings(cfg))
	a.jira = jira.New(a.jiraConfig)
	a.plane = plane.New(a.planeConfig)
	a.usage = usage.New(postgres.NewUsage(pool), a.store, log.With("component", "usage"))
	conns := postgres.NewClaudeConnections(pool, box)
	a.claude = claude.New(claude.Config{PlatformKey: cfg.AnthropicAPIKey, Subscriptions: !cfg.Cloud},
		conns, a.usage, a.settings, a.users)
	a.usage.OnPaused(a.claude.Paused)
	a.usage.SetResolver(func(ctx context.Context) (domain.ClaudeAccount, bool) {
		ws, err := domain.MustWorkspace(ctx)
		if err != nil {
			return domain.ClaudeAccount{}, false
		}
		w, err := a.workspaces.ByID(ctx, ws)
		if err != nil {
			return domain.ClaudeAccount{}, false
		}
		return a.claude.Resolve(ctx, w)
	})
	a.billing = billing.New(billing.Config{
		Enabled: cfg.Cloud, WorkspaceUZS: cfg.PriceWorkspaceUZS, SlotUZS: cfg.PriceSlotUZS, MemberUZS: cfg.PriceMemberUZS,
		CreditUZS: cfg.PriceCreditUZS, IncludedMembers: cfg.IncludedMembers, MaxSlots: cfg.MaxSlots, Markup: cfg.CreditMarkup,
		WorkspaceUSD: cfg.PriceWorkspaceUSD, SlotUSD: cfg.PriceSlotUSD, MemberUSD: cfg.PriceMemberUSD, CreditUSD: cfg.PriceCreditUSD,
		RunCap: cfg.RunCreditCap, PublicURL: cfg.PublicURL.String(),
		Payme: billing.PaymeConfig{MerchantID: cfg.PaymeMerchantID, Key: cfg.PaymeKey},
		Click: billing.ClickConfig{ServiceID: cfg.ClickServiceID, MerchantID: cfg.ClickMerchantID, SecretKey: cfg.ClickSecretKey},
	}, postgres.NewCredits(pool), a.workspaces, a.store, log.With("component", "billing"))

	tokenFor := func(provider string) func(ctx context.Context) (string, error) {
		return func(ctx context.Context) (string, error) { return a.integrations.Token(ctx, provider) }
	}
	rcfg := runner.DefaultConfig()
	rcfg.Network = cfg.RunNetwork
	rcfg.Proxy = cfg.RunProxy
	rcfg.ToolchainVolume = cfg.ToolchainVolume
	rcfg.MemoryMB, rcfg.MaxMemoryMB = int64(cfg.RunMemoryMB), int64(cfg.RunMemoryMaxMB)
	rcfg.Runtime, rcfg.NetworkPerRun, rcfg.ProxyContainer = cfg.RunRuntime, cfg.RunNetworkPerRun, cfg.EgressContainer
	rcfg.StampDir = filepath.Join(cfg.DataDir, "cache-stamps")
	maps.Copy(rcfg.Models, cfg.ClaudeModels)
	run := runner.New(a.docker, rcfg, func(ctx context.Context) (runner.Credential, error) {
		c, err := a.claude.CredentialFor(ctx)
		return runner.Credential{Env: c.Env, Token: c.Token}, err
	})
	a.budget = &orchestrator.MemoryBudget{
		BudgetMB: cfg.RunMemoryBudgetMB, DefaultMB: int64(cfg.RunMemoryMB), MaxMB: int64(cfg.RunMemoryMaxMB),
		MinFreeDiskMB: cfg.MinFreeDiskMB, Available: runner.AvailableMemoryMB,
		DiskFree: func() (int64, bool) { return runner.DiskFreeMB(cfg.DataDir) },
	}
	a.runner = run
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
	a.git, a.homes = repos, homes
	a.shots = gitrepo.NewShots(filepath.Join(cfg.DataDir, "previews"))
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
		Store: a.store, Runner: run, Git: repos, Host: a.vcs, Homes: homes,
		Trackers: map[domain.TicketSource]orchestrator.Tracker{domain.SourceJira: a.jira, domain.SourcePlane: a.plane},
		Settings: a.settings, Usage: a.usage, Lessons: a.lessons, Rules: postgres.NewRules(pool), Briefs: postgres.NewBriefs(pool),
		Reflections:  postgres.NewReflections(pool),
		PullReviews:  a.store,
		Translations: postgres.NewTranslations(pool),
		Shots:        a.shots, PreviewEnvs: previewEnvs,
		BuildEnvs: previewEnvs, Workspaces: a.workspaces,
		Accounts: a.claude, Capacity: a.budget, Credits: a.billing,
	}, log.With("component", "orchestrator"))
	a.billing.OnChange(a.orch.ForgetWorkspace)

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
	a.repos.SetBuildEnvs(previewEnvs)
	a.repos.SetImageCheck(run.ImageOK)
	a.repos.OnArchive(func(ctx context.Context, r domain.Repository) {
		if err := run.RemoveCache(ctx, "repo-"+strconv.FormatInt(r.ID, 10)); err != nil {
			log.Warn("remove an archived repository's package cache", "repo", r.ID, "err", err)
		}
	})
	if cfg.AgentEnabled {
		a.repos.SetDetector(repoDetector{repos})
		a.repos.SetDeepDetector(a.orch)
	}
	a.dashboard = admin.NewDashboard(a.store, a.orch, a.repos, a.usage, a.settings, cfg.TimeZone)
	a.adminInteg = admin.NewIntegrations(a.integrations, a.store, map[string]admin.Checker{
		"jira":     admin.JiraCheck,
		"plane":    admin.PlaneCheck,
		"github":   admin.GitHubCheck(gh),
		"claude":   admin.ClaudeTokenCheck,
		"telegram": admin.TelegramCheck(cfg.TelegramAPI),
		"gitlab":   admin.GitLabCheck,
	}, a.jira, a.orch, cfg.PublicURL.String(), log.With("component", "integrations"))
	a.adminInteg.SetHooks(hooks{ws: a.workspaces, encKey: cfg.EncKey})
	a.adminInteg.SetTelegramAPI(cfg.TelegramAPI)
	a.adminInteg.SetPlane(a.plane, a.planeProjects)

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

// planeConfig loads the Plane connection; the secrets live in the encrypted token.
func (a *agent) planeConfig(ctx context.Context) (plane.Config, bool, error) {
	in, err := a.integrations.Get(ctx, "plane")
	if errors.Is(err, domain.ErrNotFound) {
		return plane.Config{}, false, nil
	}
	if err != nil {
		return plane.Config{}, false, err
	}
	return plane.FromIntegration(in.Token, in.Settings, in.Connected)
}

// planeProjects lists the Plane projects linked to repositories that take
// new work, for the reconcile and the state list.
func (a *agent) planeProjects(ctx context.Context) ([]string, error) {
	repos, err := a.store.ListRepositories(ctx)
	if err != nil {
		return nil, err
	}
	var out []string
	for _, r := range repos {
		if r.PlaneProject != "" && r.ArchivedAt == nil {
			out = append(out, r.PlaneProject)
		}
	}
	return out, nil
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
		a.forEachWorkspace(ctx, func(ctx context.Context) {
			if repos, err := a.store.ListRepositories(ctx); err == nil {
				for _, r := range repos {
					a.repos.CheckClaudeMD(ctx, r)
				}
			}
		})
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

// sizeBudget sets the run memory budget from the Docker host when it was
// not configured: its memory less 2.5 GB for agnts, the database and the
// system.
func (a *agent) sizeBudget(ctx context.Context, cfg config.Config, log *slog.Logger) {
	if cfg.RunMemoryBudgetMB > 0 {
		log.Info("run memory budget", "mb", cfg.RunMemoryBudgetMB)
		return
	}
	total, err := a.docker.Info(ctx)
	if err != nil || total <= 0 {
		log.Warn("could not read the Docker host's memory; runs are limited by slots alone", "err", err)
		return
	}
	a.budget.BudgetMB = max(total-2560, int64(cfg.RunMemoryMB))
	log.Info("run memory budget", "mb", a.budget.BudgetMB, "host_mb", total)
}

// files removes what a workspace kept on disk and in Docker.
func (a *agent) files() accounts.Files { return workspaceFiles{a} }

type workspaceFiles struct{ a *agent }

func (f workspaceFiles) RemoveWorkspace(ctx context.Context, ws int64) error {
	var errs []error
	if repos, err := f.a.store.ListRepositories(domain.WithWorkspace(ctx, ws)); err == nil && f.a.runner != nil {
		for _, r := range repos {
			errs = append(errs, f.a.runner.RemoveCache(ctx, "repo-"+strconv.FormatInt(r.ID, 10)))
		}
	}
	errs = append(errs, f.a.git.RemoveWorkspace(ws), f.a.homes.Delete(ws), f.a.shots.Delete(ws))
	return errors.Join(errs...)
}

// egressAllow is every workspace's allowed hosts: run containers share
// the egress proxy.
func (a *agent) egressAllow(ctx context.Context) ([]string, error) {
	seen := map[string]bool{}
	var out []string
	var firstErr error
	a.forEachWorkspace(domain.System(ctx), func(ctx context.Context) {
		s, err := a.settings.Get(ctx)
		if err != nil {
			if firstErr == nil {
				firstErr = err
			}
			return
		}
		for _, h := range s.EgressAllow {
			if !seen[h] {
				seen[h] = true
				out = append(out, h)
			}
		}
	})
	return out, firstErr
}

// every runs fn now and then every interval until ctx ends.
func every(ctx context.Context, interval time.Duration, fn func(context.Context)) {
	t := time.NewTicker(interval)
	defer t.Stop()
	for {
		fn(ctx)
		select {
		case <-ctx.Done():
			return
		case <-t.C:
		}
	}
}

// forEachWorkspace calls fn with a context acting in each active workspace.
func (a *agent) forEachWorkspace(ctx context.Context, fn func(context.Context)) {
	ids, err := a.workspaces.Active(domain.System(ctx))
	if err != nil {
		if ctx.Err() == nil {
			slog.Warn("list workspaces", "err", err)
		}
		return
	}
	for _, id := range ids {
		if ctx.Err() != nil {
			return
		}
		fn(domain.WithWorkspace(ctx, id))
	}
}

// adoptLegacy moves what was kept on disk before workspaces (repository
// mirrors, Claude session homes, screenshots) into the workspace the
// install was migrated into.
func (a *agent) adoptLegacy(ctx context.Context) error {
	w, err := a.workspaces.Default(ctx)
	if errors.Is(err, domain.ErrNotFound) {
		return nil
	}
	if err != nil {
		return err
	}
	repos, err := a.store.ListRepositories(domain.WithWorkspace(ctx, w.ID))
	if err != nil {
		return err
	}
	return errors.Join(a.git.AdoptLegacy(repos), a.homes.AdoptLegacy(w.ID), a.shots.AdoptLegacy(w.ID))
}

// hooks gives the admin pages each workspace's webhook URLs and secrets.
type hooks struct {
	ws     *postgres.Workspaces
	encKey []byte
}

func (h hooks) HookID(ctx context.Context) (string, error) {
	id, err := domain.MustWorkspace(ctx)
	if err != nil {
		return "", err
	}
	w, err := h.ws.ByID(ctx, id)
	return w.HookID, err
}

func (h hooks) Secret(ctx context.Context, provider string) string {
	id, err := h.HookID(ctx)
	if err != nil {
		return ""
	}
	return vcs.HookSecret(h.encKey, provider, id)
}

// hookSecret checks deliveries against the secret of the workspace they
// were sent to (the old secret on the URLs from before workspaces).
func hookSecret(encKey []byte, provider string) vcs.SecretSource {
	return func(ctx context.Context) string { return vcs.HookSecret(encKey, provider, domain.HookOf(ctx)) }
}

func jiraSync(ctx context.Context, cfg config.Config, pool postgresPool, log *slog.Logger) error {
	a, err := newAgent(cfg, pool, log)
	if err != nil {
		return err
	}
	res, err := a.adminInteg.SyncJira(ctx)
	if err != nil {
		return err
	}
	fmt.Printf("%d labelled open issues, %d new, %d updated, %d changed after work started (restart or keep them in agnts)\n",
		res.Found, res.Created, res.Updated, res.Waiting)
	return nil
}

func planeSync(ctx context.Context, cfg config.Config, pool postgresPool, log *slog.Logger) error {
	a, err := newAgent(cfg, pool, log)
	if err != nil {
		return err
	}
	found, created, err := a.adminInteg.SyncPlane(ctx)
	if err != nil {
		return err
	}
	fmt.Printf("%d labelled open work items, %d new\n", found, created)
	return nil
}

// internalHandler serves what other containers of the stack need from
// agnts and must not be public: the egress proxy reads the hosts allowed in
// Settings from /egress/allow. Caddy only routes the main listener.
func internalHandler(allow func(ctx context.Context) ([]string, error)) http.Handler {
	mux := http.NewServeMux()
	mux.HandleFunc("GET /egress/allow", func(w http.ResponseWriter, r *http.Request) {
		hosts, err := allow(r.Context())
		if err != nil && len(hosts) == 0 {
			http.Error(w, "settings unavailable", http.StatusServiceUnavailable)
			return
		}
		w.Header().Set("Content-Type", "text/plain; charset=utf-8")
		_, _ = io.WriteString(w, strings.Join(hosts, "\n"))
	})
	return mux
}

// repoDetector reads a repository's default branch for toolchain detection.
type repoDetector struct{ git *gitrepo.Repos }

func (d repoDetector) Detect(ctx context.Context, repo domain.Repository) (toolchain.Detection, error) {
	if err := d.git.Prepare(ctx, repo, repo.DefaultBranch); err != nil {
		return toolchain.Detection{}, err
	}
	tree, err := d.git.Tree(ctx, repo, repo.DefaultBranch)
	if err != nil {
		return toolchain.Detection{}, err
	}
	return toolchain.Detect(tree), nil
}

// sweepCaches empties repository package caches that grew over max or
// that no run used for idle, every six hours (measuring volume sizes is
// slow on a busy host).
func sweepCaches(ctx context.Context, r *runner.Runner, limit int64, idle time.Duration, log *slog.Logger) {
	t := time.NewTicker(6 * time.Hour)
	defer t.Stop()
	for {
		if limit > 0 {
			removed, err := r.SweepCaches(ctx, limit)
			if err != nil {
				log.Warn("sweep package caches", "err", err)
			} else if len(removed) > 0 {
				log.Info("package caches over the limit emptied", "volumes", removed)
			}
		}
		if idle > 0 {
			removed, err := r.SweepIdleCaches(ctx, idle)
			if err != nil {
				log.Warn("sweep idle package caches", "err", err)
			} else if len(removed) > 0 {
				log.Info("package caches nobody used for a while emptied", "volumes", removed)
			}
		}
		select {
		case <-ctx.Done():
			return
		case <-t.C:
		}
	}
}

// evalReplay queues replays of done tickets; the running server works them.
func evalReplay(ctx context.Context, cfg config.Config, pool postgresPool, log *slog.Logger, keys []string, out io.Writer) error {
	a, err := newAgent(cfg, pool, log)
	if err != nil {
		return err
	}
	var errs []error
	for _, k := range keys {
		t, err := a.orch.Replay(ctx, strings.ToUpper(strings.TrimSpace(k)), domain.OriginSystem)
		if err != nil {
			errs = append(errs, fmt.Errorf("%s: %w", k, err))
			continue
		}
		_, _ = fmt.Fprintf(out, "%s replays %s from commit %.7s\n", t.Key, t.ReplayOf, t.BaseSHA)
	}
	return errors.Join(errs...)
}

// evalReport prints how the replays compare with the tickets they re-ran.
func evalReport(ctx context.Context, cfg config.Config, pool postgresPool, log *slog.Logger, out io.Writer) error {
	a, err := newAgent(cfg, pool, log)
	if err != nil {
		return err
	}
	rep, err := a.orch.ReplayReport(ctx)
	if err != nil {
		return err
	}
	if len(rep.Replays) == 0 {
		_, _ = fmt.Fprintln(out, "No replays yet: run `agnts eval replay KEY...` first.")
		return nil
	}
	tw := tabwriter.NewWriter(out, 0, 0, 2, ' ', 0)
	_, _ = fmt.Fprintln(tw, "PROMPTS\tREPLAYS\tCHECKS PASS\tLOOKS GOOD\tFILE OVERLAP\tRECALL\tTURNS (ORIG)\tCOST (ORIG)")
	for _, v := range rep.Versions {
		_, _ = fmt.Fprintf(tw, "%s\t%d\t%d\t%d/%d\t%.0f%%\t%.0f%%\t%.0f (%.0f)\t$%.2f ($%.2f)\n", orDash(v.PromptVersion), v.Replays, v.ChecksPassed,
			v.LooksGood, v.Reviewed, v.AvgOverlap*100, v.AvgRecall*100, v.AvgTurns, v.OriginalTurns, v.AvgCostUSD, v.OriginalCostUSD)
	}
	_ = tw.Flush()
	_, _ = fmt.Fprintln(out)
	tw = tabwriter.NewWriter(out, 0, 0, 2, ' ', 0)
	_, _ = fmt.Fprintln(tw, "REPLAY\tOF\tSTATE\tPROMPTS\tCHECKS\tOVERLAP\tREVIEW")
	for _, x := range rep.Replays {
		checks := "-"
		if x.HasChange {
			checks = map[bool]string{true: "pass", false: "fail"}[x.ChecksPassed]
		}
		_, _ = fmt.Fprintf(tw, "%s\t%s\t%s\t%s\t%s\t%.0f%%\t%s\n", x.Key, x.Original, x.State, orDash(x.PromptVersion), checks, x.Overlap*100, orDash(x.Verdict))
	}
	return tw.Flush()
}

func orDash(s string) string {
	if s == "" {
		return "-"
	}
	return s
}

// googleSignIn is "Continue with Google" when a client id is configured.
func googleSignIn(cfg config.Config, acc *accounts.Service) *httpapi.GoogleSignIn {
	if cfg.GoogleClientID == "" {
		return nil
	}
	return &httpapi.GoogleSignIn{Verifier: google.New(cfg.GoogleClientID, cfg.GoogleAppClientIDs...), Accounts: acc, ClientID: cfg.GoogleClientID, SiteURL: cfg.SiteURL}
}
