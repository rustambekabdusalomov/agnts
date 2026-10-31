package main

import (
	muse "github.com/rustambekabdusalomov/agnts-muse"
	"github.com/rustambekabdusalomov/agnts-muse/model"

	gitclient "github.com/go-git/go-git/v5/plumbing/transport/client"
	githttp "github.com/go-git/go-git/v5/plumbing/transport/http"
	"github.com/modelcontextprotocol/go-sdk/mcp"

	"cmp"
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
	"agnts/internal/actions"
	"agnts/internal/admin"
	"agnts/internal/billing"
	"agnts/internal/ciwatch"
	"agnts/internal/claude"
	"agnts/internal/commitlink"
	"agnts/internal/config"
	"agnts/internal/docs"
	"agnts/internal/documents"
	"agnts/internal/domain"
	"agnts/internal/egress"
	"agnts/internal/google"
	"agnts/internal/httpapi"
	"agnts/internal/livekit"
	"agnts/internal/mail"
	"agnts/internal/mcpserver"
	"agnts/internal/meetings"
	"agnts/internal/metrics"
	"agnts/internal/modules"
	"agnts/internal/musecredits"
	"agnts/internal/netroute"
	"agnts/internal/network"
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

	mcpSrv := mcpserver.NewServer(a.mcpDeps(), version)
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
			is := &http.Server{Addr: cfg.InternalAddr, Handler: internalHandler(a.egressAllow, a.network), ReadHeaderTimeout: 5 * time.Second}
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
	a.orch.SetAssistantEvents(broker)
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
	// Documents: generations and PDFs need the worker's containers; without
	// them people still write, share and download Markdown.
	docDeps := documents.Deps{Store: a.docStore, Workspaces: a.workspaces, Tickets: a.store, Settings: a.settings,
		Notifier: broker, Log: log.With("component", "documents")}
	if cfg.AgentEnabled {
		docDeps.Generator, docDeps.PDF, docDeps.Translator = a.orch, a.orch, a.orch
	}
	docSvc := documents.New(docDeps)
	a.orch.SetDocumentWatcher(docSvc)
	meetSvc := newMeetings(cfg, a, docSvc, broker, mailer, log.With("component", "meetings"))
	a.meet = meetSvc
	docSvc.SetMeetingWatcher(meetSvc.NotesChanged)
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
		Pulls:        a.orch,
		Drafts:       a.orch,
		CI:           a.ci,
		CommitLinks:  a.store,
		Assistant:    a.orch,
		Code:         a.orch,
		Swagger:      a.orch,
		Suites:       a.orch,
		Documents:    docSvc,
		Meetings:     meetSvc,
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
		Muse:         museAPI{a.museCredits, a.museDevice},
		Modules:      a.modules,
		EventLog:     a.store,
		Cloud:        cfg.Cloud,
		Google:       googleSignIn(cfg, acc),
		Feedback:     postgres.NewFeedbacks(pool),
		RunHistory:   a.transcripts,
		SiteURL:      cfg.SiteURL,
		Network:      a.network,
		Payments: map[string]http.Handler{
			"payme": a.billing.PaymeHandler(),
			"click": a.billing.ClickHandler(),
		},
		Webhooks: map[string]http.Handler{
			"jira":     jira.WebhookHandler(a.jiraConfig, a.jira.AccountID, a.orch, a.store, log.With("component", "jira")),
			"plane":    plane.WebhookHandler(a.planeConfig, a.plane, a.orch, a.store, log.With("component", "plane")),
			"telegram": a.notifier.WebhookHandler(),
			"github":   vcs.GitHubWebhook(hookSecret(cfg.EncKey, "github"), gitHooks{a.orch, a.ci, a.links}, a.store, a.vcs.ForgetAll, log.With("component", "github")),
			"gitlab":   vcs.GitLabWebhook(hookSecret(cfg.EncKey, "gitlab"), gitHooks{a.orch, a.ci, a.links}, a.store, a.vcs.ForgetAll, log.With("component", "gitlab")),
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
	go every(sys, 24*time.Hour, func(ctx context.Context) { pruneRunHistory(ctx, a.transcripts, log) })
	go every(sys, 24*time.Hour, func(ctx context.Context) {
		if err := acc.PurgeDeleted(ctx); err != nil {
			log.Warn("purge deleted workspaces", "err", err)
		}
	})
	go every(sys, 24*time.Hour, func(ctx context.Context) {
		if n, err := docSvc.Purge(ctx); err != nil {
			log.Warn("purge deleted documents", "err", err)
		} else if n > 0 {
			log.Info("purged deleted documents", "count", n)
		}
	})
	go every(sys, time.Hour, func(ctx context.Context) {
		if err := a.billing.Renew(ctx); err != nil {
			log.Warn("renew plans", "err", err)
		}
	})
	go every(sys, time.Minute, func(ctx context.Context) {
		if n, err := a.museCredits.Reap(ctx); err != nil {
			log.Warn("release expired muse holds", "err", err)
		} else if n > 0 {
			log.Info("released expired muse holds", "count", n)
		}
	})

	if meetSvc.Ready() {
		go every(sys, time.Minute, meetSvc.Sweep)
		go every(sys, time.Minute, meetSvc.Remind)
		go every(sys, 24*time.Hour, func(ctx context.Context) { a.forEachWorkspace(ctx, meetSvc.Retention) })
		if cfg.AgentEnabled {
			go meetSvc.RunNotes(sys) // hearing the audio needs the worker's containers
		}
	}

	go a.network.Run(sys)
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
		go every(sys, time.Minute, a.orch.RunDueSuites) // scheduled Swagger test suites
		go jira.Reconcile(sys, a.jira, a.orch, cfg.JiraSyncEach, a.forEachWorkspace, log.With("component", "jira"))
		go plane.Reconcile(sys, a.plane, a.planeProjects, a.orch, cfg.PlaneSyncEach, a.forEachWorkspace, log.With("component", "plane"))
		if !a.network.Enabled() {
			a.network.SetWhoIs(a.runner.WhoIs) // grants (Swagger tests) without a gateway
		}
		if a.network.Enabled() {
			a.network.SetRuns(a.docker, a.runner.WhoIs)
			// A tracker reached through a VPN cannot send webhooks to agnts:
			// read it more often (agnts-link relays them, so a tracker
			// reached through a connector is skipped).
			jiraSite := func(ctx context.Context) string {
				c, ok, err := a.jiraConfig(ctx)
				if err != nil || !ok {
					return ""
				}
				return c.Site
			}
			planeURL := func(ctx context.Context) string {
				c, ok, err := a.planeConfig(ctx)
				if err != nil || !ok {
					return ""
				}
				return c.BaseURL
			}
			go jira.Reconcile(sys, a.jira, a.orch, cfg.PrivatePollEvery, a.network.PolledBy(jiraSite), log.With("component", "jira", "private", true))
			go plane.Reconcile(sys, a.plane, a.planeProjects, a.orch, max(cfg.PrivatePollEvery, 5*time.Minute), a.network.PolledBy(planeURL),
				log.With("component", "plane", "private", true))
		}
		go pruneDeliveries(sys, a.store, log)
		// CI watching: poll repositories without webhooks, follow CI tickets.
		go every(sys, 5*time.Minute, func(ctx context.Context) { a.forEachWorkspace(ctx, a.ci.Tick) })
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
	transcripts  *postgres.Transcripts
	lessons      *postgres.Lessons
	integrations *postgres.Integrations
	settings     *postgres.Settings
	modules      *modules.Service
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
	progress     *gitrepo.Progress
	shots        *gitrepo.Shots
	users        *postgres.Users
	claude       *claude.Service
	billing      *billing.Service
	museCredits  *musecredits.Service
	museDevice   *musecredits.Logins
	budget       *orchestrator.MemoryBudget
	network      *network.Service
	ci           *ciwatch.Service
	links        *commitlink.Service
	assistant    *postgres.Assistant
	docStore     *postgres.Documents
	meetStore    *postgres.Meetings
	meet         *meetings.Service // set once the server is built
}

// mcpDeps are the use cases the MCP tools call, and the assistant's
// snapshot reads.
func (a *agent) mcpDeps() mcpserver.Deps {
	return mcpserver.Deps{
		Orch: a.orch, Store: a.store, Usage: a.usage, Settings: a.settings, Dashboard: a.dashboard, Repos: a.repos, Lessons: a.lessons, CI: a.ci,
		Analytics: func(ctx context.Context, days int) (any, error) { return a.dashboard.Analytics(ctx, days) },
		Role:      a.workspaces.Role,
		Meetings:  func() *meetings.Service { return a.meet },
	}
}

func newAgent(cfg config.Config, pool postgresPool, log *slog.Logger) (*agent, error) {
	box, err := secret.NewBox(cfg.EncKey)
	if err != nil {
		return nil, err
	}
	domain.SetProviders(cfg.Providers)
	a := &agent{
		store:        postgres.NewAgent(pool),
		lessons:      postgres.NewLessons(pool),
		integrations: postgres.NewIntegrations(pool, box),
		docker:       runner.NewDocker(cfg.DockerSocket),
		workspaces:   postgres.NewWorkspaces(pool),
		users:        postgres.NewUsers(pool),
	}
	a.modules = modules.New(pool)
	if err := a.modules.Ensure(context.Background()); err != nil {
		return nil, fmt.Errorf("modules: %w", err)
	}
	a.settings = postgres.NewSettings(pool, defaultSettings(cfg))
	// Private networks: the server's own calls (GitLab, Jira and Plane
	// APIs, git) to a host on a workspace's routes go through the gateway.
	router := netroute.New(cfg.Gateway, cfg.GatewaySecret)
	netroute.Install(router)
	routed := githttp.NewClient(&http.Client{Transport: netroute.Transport})
	gitclient.InstallProtocol("https", routed)
	gitclient.InstallProtocol("http", routed)
	a.network = network.New(network.Config{
		Gateway: cfg.Gateway, GatewaySecret: cfg.GatewaySecret, LinkURL: cfg.LinkURL, Reserved: reservedHosts(cfg),
		OVPNImage: cfg.OVPNImage, OVPNNetwork: cfg.OVPNNetwork, Polled: cfg.PrivatePollEvery,
		MaxNetworks: cfg.PrivateNetworksMax, MaxOVPN: cfg.OVPNMax,
	}, postgres.NewPrivateNetworks(pool), box, router, a.store, log.With("component", "network"))
	a.jira = jira.New(a.jiraConfig)
	a.plane = plane.New(a.planeConfig)
	a.usage = usage.New(postgres.NewUsage(pool), a.store, log.With("component", "usage"))
	conns := postgres.NewClaudeConnections(pool, box)
	credits := postgres.NewCredits(pool)
	a.museCredits = musecredits.New(musecredits.Config{RunCap: cfg.RunCreditCap, GlobalCapUSD: cfg.MuseGlobalCapUSD}, pool, credits)
	if err := a.museCredits.Migrate(context.Background()); err != nil {
		return nil, fmt.Errorf("muse ledger: %w", err)
	}
	a.claude = claude.New(claude.Config{PlatformKey: cfg.AnthropicAPIKey, Subscriptions: !cfg.Cloud, MuseKey: cfg.MusePlatformKey,
		Free: func(ctx context.Context, user int64) bool { return a.museCredits.FreeAvailable(ctx, user) > 0 },
		CodexReady: func(ctx context.Context) bool {
			key, err := a.integrations.Token(ctx, "openai")
			return err == nil && key != ""
		}},
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
		p := domain.CurrentProvider(ctx)
		if p == "" {
			p = domain.AccessOf(ctx).Primary()
		}
		return a.claude.Resolve(ctx, w, p)
	})
	a.billing = billing.New(billing.Config{
		Enabled: cfg.Cloud, WorkspaceUZS: cfg.PriceWorkspaceUZS, SlotUZS: cfg.PriceSlotUZS, MemberUZS: cfg.PriceMemberUZS,
		CreditUZS: cfg.PriceCreditUZS, IncludedMembers: cfg.IncludedMembers, MaxSlots: cfg.MaxSlots, Markup: cfg.CreditMarkup,
		WorkspaceUSD: cfg.PriceWorkspaceUSD, SlotUSD: cfg.PriceSlotUSD, MemberUSD: cfg.PriceMemberUSD, CreditUSD: cfg.PriceCreditUSD,
		RunCap: cfg.RunCreditCap, PublicURL: cfg.PublicURL.String(),
		Payme: billing.PaymeConfig{MerchantID: cfg.PaymeMerchantID, Key: cfg.PaymeKey},
		Click: billing.ClickConfig{ServiceID: cfg.ClickServiceID, MerchantID: cfg.ClickMerchantID, SecretKey: cfg.ClickSecretKey},
	}, credits, a.workspaces, a.store, log.With("component", "billing"))
	a.billing.SetFree(a.museCredits.FreeChargedUSD)

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
	if b, err := os.ReadFile(cfg.GuardBinary); err == nil {
		rcfg.GuardBinary = b
	} else {
		log.Warn("agnts-guard is missing: runs work without the in-run guards (the checks after each run still apply)", "path", cfg.GuardBinary, "err", err)
	}
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
	run.SetCA(a.network.CA)
	run.SetCodexKey(func(ctx context.Context) (string, error) { return a.integrations.Token(ctx, "openai") })
	catalog, err := model.Default.WithPrices(cfg.MusePrices)
	if err != nil {
		return nil, fmt.Errorf("AGNTS_MUSE_PRICES: %w", err)
	}
	a.museDevice = musecredits.NewLogins(func(ctx context.Context) (string, string, time.Time, <-chan musecredits.SignInResult, error) {
		p, res, err := run.MuseLogin(ctx, cfg.RunnerImage)
		if err != nil {
			return "", "", time.Time{}, nil, err
		}
		out := make(chan musecredits.SignInResult, 1)
		go func() {
			r := <-res
			out <- musecredits.SignInResult{File: r.File, Err: r.Err}
		}()
		return p.URL, p.Code, p.ExpiresAt, out, nil
	}, a.claude, log.With("component", "muse-login"))
	run.SetMuseLoginKeeper(a.claude.KeepMuseLogin)
	// Runs are in their own container behind the egress proxy, and Muse's
	// own shell sandbox cannot start there (bwrap needs user namespaces the
	// container does not allow): with it on, the first try of every shell
	// command fails. A turn that ends without any answer (the model's last
	// step was reasoning only) is continued twice.
	run.SetMuse(muse.New(muse.Config{Binary: cfg.MuseBinary, Catalog: catalog, Ledger: a.museCredits.Ledger(),
		Observer: muse.SlogObserver{Logger: log.With("component", "muse")}, ServeArgs: []string{"--disable-sandbox"}, Continues: 2}), a.museCredits)
	a.refresher = usage.NewRefresher(a.usage, run, cfg.RunnerImage, log.With("component", "usage"))

	repos := gitrepo.New(filepath.Join(cfg.DataDir, "repos"),
		func(ctx context.Context, provider string) (string, error) { return a.integrations.Token(ctx, provider) },
		a.commitAuthor)
	homes := gitrepo.NewHomes(filepath.Join(cfg.DataDir, "sessions"))
	a.git, a.homes = repos, homes
	a.progress = gitrepo.NewProgress(filepath.Join(cfg.DataDir, "progress"))
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
	a.docStore = postgres.NewDocuments(pool)
	a.orch = orchestrator.New(ocfg, orchestrator.Deps{
		Store: a.store, Runner: run, Git: repos, Host: a.vcs, Homes: homes, Progress: a.progress,
		Trackers: map[domain.TicketSource]orchestrator.Tracker{domain.SourceJira: a.jira, domain.SourcePlane: a.plane},
		Settings: a.settings, Access: a.modules, Usage: a.usage, Lessons: a.lessons, Rules: postgres.NewRules(pool), Briefs: postgres.NewBriefs(pool),
		Reflections:  postgres.NewReflections(pool),
		PullReviews:  a.store,
		PRPosts:      a.store,
		ReviewDrafts: a.store,
		Translations: postgres.NewTranslations(pool),
		Shots:        a.shots, PreviewEnvs: previewEnvs,
		BuildEnvs: previewEnvs, Workspaces: a.workspaces,
		Accounts: a.claude, Capacity: a.budget, Credits: a.billing,
		SwaggerTests: postgres.NewSwaggerTests(pool, box),
		Documents:    a.docStore, DocumentHost: a.vcs,
	}, log.With("component", "orchestrator"))
	a.orch.SetSwaggerSuites(postgres.NewSwaggerSuites(pool, box))
	a.transcripts = postgres.NewTranscripts(pool)
	a.orch.SetRecorder(a.transcripts)
	a.billing.OnChange(a.orch.ForgetWorkspace)
	a.ci = ciwatch.New(postgres.NewCI(pool, box), a.store, a.orch, a.vcs, repos, a.settings, log.With("component", "ci"))
	a.orch.SetCIHook(a.ci)
	a.links = commitlink.New(a.store, a.vcs, log.With("component", "commit-links"))
	a.links.OnRevert(a.orch.Reverted)
	a.orch.SetCommitLinker(a.links)

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
	a.repos.OnAdd(a.links.RepositoryAdded)
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
		"openai":   admin.OpenAICheck(cfg.OpenAIAPI),
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
	a.notifier.SetCIFixer(a.ci)
	a.assistant = postgres.NewAssistant(pool, box)
	a.orch.SetAssistant(a.assistant, mcpserver.NewSnapshotter(a.mcpDeps()))
	a.orch.SetAssistantActions(&actions.Assistant{Deps: actions.Deps{Orch: a.orch, Store: a.store, Repos: a.repos}, Role: a.workspaces.Role})
	a.orch.SetCodeChat(a.assistant, a.workspaces.Role)
	a.orch.SetTranscriber(a.runner)
	a.meetStore = postgres.NewMeetings(pool)
	a.orch.SetMeetings(a.meetStore)
	a.orch.SetMeetingTranscriber(a.runner)
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

// commitAuthor is who agnts commits as: the author set in Settings, else
// the owner of the ticket being committed (whose account its name and
// email are), so a ticket never stops at the commit for want of one.
func (a *agent) commitAuthor(ctx context.Context) (gitrepo.Author, error) {
	s, err := a.settings.Get(ctx)
	if err != nil {
		return gitrepo.Author{}, err
	}
	if s.Git.AuthorName != "" && s.Git.AuthorEmail != "" {
		return gitrepo.Author{Name: s.Git.AuthorName, Email: s.Git.AuthorEmail}, nil
	}
	missing := errors.New("set the commit author name and email in Settings → Commits and PR so agnts can commit as you")
	key := domain.TicketOf(ctx)
	if key == "" {
		return gitrepo.Author{}, missing
	}
	owner, err := a.store.TicketOwner(ctx, domain.WorkspaceOf(ctx), key)
	if err != nil {
		return gitrepo.Author{}, err
	}
	if owner == 0 {
		return gitrepo.Author{}, missing
	}
	u, err := a.users.ByID(ctx, owner)
	if err != nil {
		return gitrepo.Author{}, err
	}
	return ownerAuthor(u, s.Git, missing)
}

// ownerAuthor fills what the settings leave empty from u's account. A
// name falls back to the username; an email cannot be made up.
func ownerAuthor(u domain.User, g domain.GitSettings, missing error) (gitrepo.Author, error) {
	out := gitrepo.Author{Name: g.AuthorName, Email: g.AuthorEmail}
	if out.Name == "" {
		out.Name = cmp.Or(strings.TrimSpace(u.DisplayName), u.Username)
	}
	if out.Email == "" {
		out.Email = u.Email
	}
	if out.Email == "" {
		return gitrepo.Author{}, missing
	}
	return out, nil
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

// auditKeep is how long the Admin audit log is kept.
const auditKeep = 365 * 24 * time.Hour

// pruneRunHistory deletes transcripts past the retention an Admin set,
// and audit rows past auditKeep.
func pruneRunHistory(ctx context.Context, s *postgres.Transcripts, log *slog.Logger) {
	set, err := s.RunHistorySettings(ctx)
	if err != nil {
		log.Warn("run history settings", "err", err)
		return
	}
	if set.RetentionDays > 0 {
		n, err := s.PruneTranscripts(ctx, time.Now().AddDate(0, 0, -set.RetentionDays))
		if err != nil && ctx.Err() == nil {
			log.Warn("prune run history", "err", err)
		} else if n > 0 {
			log.Info("pruned run history", "transcripts", n, "older_than_days", set.RetentionDays)
		}
	}
	if _, err := s.PruneAudit(ctx, time.Now().Add(-auditKeep)); err != nil && ctx.Err() == nil {
		log.Warn("prune admin audit log", "err", err)
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
	errs = append(errs, f.a.git.RemoveWorkspace(ws), f.a.homes.Delete(ws), f.a.progress.Delete(ws), f.a.shots.Delete(ws))
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
// Settings from /egress/allow, and asks about private network routes; the
// gateway reads the private networks (see network.Internal). Caddy only
// routes the main listener.
func internalHandler(allow func(ctx context.Context) ([]string, error), nets *network.Service) http.Handler {
	mux := http.NewServeMux()
	if nets != nil && nets.Enabled() {
		nets.Internal(mux)
	} else if nets != nil && nets.Grants() {
		nets.InternalRoutes(mux)
	}
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
	return toolchain.DetectFor(tree, toolchain.Repo{GitHosts: []string{toolchain.HostOf(repo.CloneURL)}, EnvNames: repo.BuildEnvNames}), nil
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

// evalBench replays every ticket in the benchmark, with the models given
// as stage=model; the running server works the replays.
func evalBench(ctx context.Context, cfg config.Config, pool postgresPool, log *slog.Logger, args []string, out io.Writer) error {
	models := map[string]string{}
	for _, a := range args {
		k, v, ok := strings.Cut(a, "=")
		if !ok {
			return fmt.Errorf("%q: give models as STAGE=MODEL, e.g. coding=opus", a)
		}
		models[strings.TrimSpace(k)] = strings.TrimSpace(v)
	}
	a, err := newAgent(cfg, pool, log)
	if err != nil {
		return err
	}
	runs, err := a.orch.RunBenchmark(ctx, models, domain.OriginSystem)
	if err != nil {
		return err
	}
	for _, r := range runs {
		if r.Replay != nil {
			_, _ = fmt.Fprintf(out, "%s replays %s from commit %.7s\n", r.Replay.Key, r.Original, r.Replay.BaseSHA)
		}
	}
	return orchestrator.BenchmarkError(runs)
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
	if len(rep.Benchmark) > 0 {
		_, _ = fmt.Fprintln(out, "Benchmark")
		printEvalVersions(out, rep.Benchmark)
		_, _ = fmt.Fprintln(out, "\nAll replays")
	}
	printEvalVersions(out, rep.Versions)
	_, _ = fmt.Fprintln(out)
	tw := tabwriter.NewWriter(out, 0, 0, 2, ' ', 0)
	_, _ = fmt.Fprintln(tw, "REPLAY\tOF\tSTATE\tPROMPTS\tMODEL\tCHECKS\tAGAINST\tFILES\tLINES (ORIG)\tREVIEW")
	for _, x := range rep.Replays {
		checks := "-"
		if x.HasChange {
			checks = map[bool]string{true: "pass", false: "fail"}[x.ChecksPassed]
		}
		_, _ = fmt.Fprintf(tw, "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%.0f%%\t%s (%s)\t%s\n", x.Key, x.Original, x.State, orDash(x.PromptVersion), orDash(x.Model),
			checks, x.Against, x.Overlap*100, pctOrDash(x.LineRecall), pctOrDash(x.OriginalLineRecall), orDash(x.Verdict))
	}
	return tw.Flush()
}

// printEvalVersions prints replays summed by prompt version and model.
func printEvalVersions(out io.Writer, vs []orchestrator.EvalVersion) {
	tw := tabwriter.NewWriter(out, 0, 0, 2, ' ', 0)
	_, _ = fmt.Fprintln(tw, "PROMPTS\tMODEL\tREPLAYS\tCHECKS PASS\tLOOKS GOOD\tFILE OVERLAP\tRECALL\tMERGED LINES (ORIG)\tTURNS (ORIG)\tCOST (ORIG)")
	for _, v := range vs {
		_, _ = fmt.Fprintf(tw, "%s\t%s\t%d\t%d\t%d/%d\t%.0f%%\t%.0f%%\t%s (%s) of %d\t%.0f (%.0f)\t$%.2f ($%.2f)\n", orDash(v.PromptVersion), orDash(v.Model),
			v.Replays, v.ChecksPassed, v.LooksGood, v.Reviewed, v.AvgOverlap*100, v.AvgRecall*100, pctOrDash(v.AvgLineRecall), pctOrDash(v.OriginalLineRecall),
			v.Merged, v.AvgTurns, v.OriginalTurns, v.AvgCostUSD, v.OriginalCostUSD)
	}
	_ = tw.Flush()
}

// pctOrDash is a share as a percentage, or "-" when it is negative (none).
func pctOrDash(v float64) string {
	if v < 0 {
		return "-"
	}
	return fmt.Sprintf("%.0f%%", v*100)
}

// evalAssistant answers the questions people shared (with their rating)
// again with the current prompts, from the snapshots their answers were
// made from, and prints the old and the new answer side by side. With
// --cases it answers the built-in cases instead and checks the actions
// each proposes.
func evalAssistant(ctx context.Context, cfg config.Config, pool postgresPool, log *slog.Logger, args []string, out io.Writer) error {
	limit := 20
	for i := 0; i < len(args); i++ {
		switch {
		case args[i] == "--cases" && len(args) == 1:
			return evalAssistantCases(ctx, cfg, pool, log, out)
		case args[i] == "--limit" && i+1 < len(args):
			n, err := strconv.Atoi(args[i+1])
			if err != nil || n <= 0 {
				return errors.New("--limit takes a positive number")
			}
			limit, i = n, i+1
		default:
			return fmt.Errorf("unknown argument %q; usage: agnts eval assistant [--limit N | --cases]", args[i])
		}
	}
	a, err := newAgent(cfg, pool, log)
	if err != nil {
		return err
	}
	cases, err := a.assistant.AssistantReplays(ctx, limit)
	if err != nil {
		return err
	}
	if len(cases) == 0 {
		_, _ = fmt.Fprintln(out, "No shared answers yet: people share one when they rate it in the app (\"Keep this question's data\").")
		return nil
	}
	p := func(format string, args ...any) { _, _ = fmt.Fprintf(out, format, args...) }
	p("# Assistant replay: %d questions, prompts %s\n\n", len(cases), orchestrator.PromptVersion)
	var failed int
	var tokens int64
	var took time.Duration
	for _, c := range cases {
		verdict := map[int]string{1: "helpful", -1: "not helpful"}[c.Rating]
		p("## #%d (%s, prompts %s)\n\n> %s\n\n### Then\n\n%s\n\n### Now\n\n", c.MessageID, verdict, orDash(c.PromptVersion),
			strings.ReplaceAll(c.Question, "\n", "\n> "), c.Answer)
		ans, res, err := a.orch.ReplayAnswer(ctx, c.Snapshot, c.Lang, c.UserID)
		tokens += res.Usage.Total()
		took += res.Duration
		if err != nil {
			failed++
			p("_No answer: %v_\n\n", err)
			continue
		}
		p("%s\n\n", ans.Answer)
		// Proposed actions are shown, never stored: nobody can confirm a replay.
		for _, x := range ans.Actions {
			p("- _would propose_ `%s` %s\n", x.Tool, x.Args)
		}
		if len(ans.Actions) > 0 {
			p("\n")
		}
	}
	p("---\n%d replayed, %d without an answer, %d tokens, %s of Claude time\n", len(cases), failed, tokens, took.Round(time.Second))
	return nil
}

// evalAssistantCases answers the built-in cases with the current prompt
// and checks the actions each proposes (acting when asked, not when the
// files only talk about acting) and its offers of Code mode. It fails
// when a case does.
func evalAssistantCases(ctx context.Context, cfg config.Config, pool postgresPool, log *slog.Logger, out io.Writer) error {
	cases, err := orchestrator.AssistantCases()
	if err != nil {
		return err
	}
	a, err := newAgent(cfg, pool, log)
	if err != nil {
		return err
	}
	p := func(format string, args ...any) { _, _ = fmt.Fprintf(out, format, args...) }
	p("# Assistant cases: %d, prompts %s\n\n", len(cases), orchestrator.PromptVersion)
	var failed int
	var tokens int64
	for _, c := range cases {
		ans, res, err := a.orch.ReplayAnswer(ctx, c.Snapshot(), c.Lang, 0)
		tokens += res.Usage.Total()
		problems := append(orchestrator.CheckProposals(ans.Actions, c.Want), orchestrator.CheckCode(ans.Code, c.Code)...)
		if err != nil {
			problems = []string{"no answer: " + err.Error()}
		}
		if len(problems) == 0 {
			p("- ✓ %s\n", c.Name)
			continue
		}
		failed++
		p("- ✗ %s\n", c.Name)
		for _, x := range problems {
			p("  - %s\n", x)
		}
		if ans.Answer != "" {
			p("  > %s\n", strings.ReplaceAll(truncateLine(ans.Answer, 300), "\n", " "))
		}
	}
	p("\n%d passed, %d failed, %d tokens\n", len(cases)-failed, failed, tokens)
	if failed > 0 {
		return fmt.Errorf("%d of %d assistant cases failed", failed, len(cases))
	}
	return nil
}

// truncateLine cuts s to at most n runes.
func truncateLine(s string, n int) string {
	r := []rune(s)
	if len(r) <= n {
		return s
	}
	return string(r[:n]) + "…"
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

// reservedHosts are hosts no private network route may cover: what the
// egress proxy reaches directly, and agnts's own domains.
func reservedHosts(cfg config.Config) []string {
	out := append([]string{}, egress.DefaultAllow...)
	out = append(out, cfg.EgressAllow...)
	for _, u := range []*url.URL{cfg.PublicURL, cfg.SiteURL} {
		if u != nil && u.Hostname() != "" {
			out = append(out, u.Hostname())
		}
	}
	if u, err := url.Parse(cfg.LinkURL); err == nil && u.Hostname() != "" {
		out = append(out, u.Hostname())
	}
	return out
}

// gitHooks receives the git hosts' webhooks: merges and closed pull
// requests go to the orchestrator, finished CI runs to CI watching, pushes
// to commit linking.
type gitHooks struct {
	*orchestrator.Orchestrator
	ci    *ciwatch.Service
	links *commitlink.Service
}

var (
	_ vcs.CloseSink = gitHooks{}
	_ vcs.PushSink  = gitHooks{}
)

func (h gitHooks) CommitsPushed(ctx context.Context, p domain.Push) error {
	return h.links.CommitsPushed(ctx, p)
}

func (h gitHooks) CIRunFinished(ctx context.Context, run domain.CIRun) error {
	return h.ci.CIRunFinished(ctx, run)
}

// museAPI serves the Muse operations: Meta sign-in and free credits.
type museAPI struct {
	*musecredits.Service
	logins *musecredits.Logins
}

func (m museAPI) StartLogin(ctx context.Context, ws, user int64) (musecredits.Login, error) {
	return m.logins.Start(ctx, ws, user)
}

func (m museAPI) LoginStatus(id string, ws, user int64) (musecredits.Login, bool) {
	return m.logins.Status(id, ws, user)
}

// newMeetings sets up video calls when a LiveKit server is configured;
// without one the service answers that meetings are off.
func newMeetings(cfg config.Config, a *agent, docSvc *documents.Service, broker *httpapi.Broker, mailer mail.Sender, log *slog.Logger) *meetings.Service {
	keys := livekit.Keys{Key: cfg.LiveKitKey, Secret: cfg.LiveKitSecret}
	mcfg := meetings.Config{LiveKitURL: cfg.LiveKitURL, Keys: keys, PublicURL: cfg.PublicURL.String(), MediaDir: cfg.MeetingsDir,
		EgressDir: cfg.MeetingsEgressDir, Egress: cfg.LiveKitEgress, MaxRecordings: cfg.MeetMaxRecordings, NotesAudio: cfg.MeetNotesAudio}
	deps := meetings.Deps{Store: a.meetStore, Workspaces: a.workspaces, Users: a.users, Settings: a.settings, Stream: broker,
		Pusher: a.notifier, Mailer: mailer, Notes: docSvc, Tickets: meetingTickets{a.orch, a.store}, Log: log}
	if cfg.LiveKitURL != "" {
		deps.LiveKit = livekit.NewClient(cfg.LiveKitInternalURL, keys)
		if cfg.AgentEnabled {
			deps.Hearer = a.orch
		}
		if cfg.LiveKitEgress {
			if err := meetingsDir(cfg.MeetingsDir); err != nil {
				log.Warn("recordings and notes are off: the meetings directory is not usable", "dir", cfg.MeetingsDir, "err", err)
				mcfg.Egress = false
			}
		}
		log.Info("meetings on", "livekit", cfg.LiveKitURL, "recording", mcfg.Egress, "notes", mcfg.Egress && deps.Hearer != nil, "notes_audio", cfg.MeetNotesAudio)
	} else {
		log.Info("meetings off: set AGNTS_LIVEKIT_URL, AGNTS_LIVEKIT_API_KEY and AGNTS_LIVEKIT_API_SECRET to enable video calls")
	}
	return meetings.New(mcfg, deps)
}

// meetingsDir makes the directory Egress writes recordings to and agnts
// reads them from. Egress runs as another user, so it may write here;
// files stay flat (no folders Egress would own) so agnts can delete them.
func meetingsDir(dir string) error {
	// Egress writes as its own user: the directory is open to it (it holds
	// only recordings, which agnts serves after an access check).
	if err := os.MkdirAll(dir, 0o777); err != nil { //nolint:gosec // G301: see above
		return err
	}
	// A volume made by Docker may belong to root: leave it alone when it
	// is already open.
	if fi, err := os.Stat(dir); err != nil {
		return err
	} else if fi.Mode().Perm() != 0o777 {
		if err := os.Chmod(dir, 0o777); err != nil { //nolint:gosec // G302: see above
			return err
		}
	}
	probe := filepath.Join(dir, ".agnts-probe")
	if err := os.WriteFile(probe, []byte("ok"), 0o600); err != nil {
		return err
	}
	return os.Remove(probe)
}

// meetingTickets makes tickets of action items (the orchestrator) and
// finds tickets by key (the store).
type meetingTickets struct {
	orch  *orchestrator.Orchestrator
	store *postgres.Agent
}

func (t meetingTickets) CreateTask(ctx context.Context, in orchestrator.TaskInput, origin domain.Origin) (domain.Ticket, error) {
	return t.orch.CreateTask(ctx, in, origin)
}

func (t meetingTickets) TicketByKey(ctx context.Context, key string) (domain.Ticket, error) {
	return t.store.TicketByKey(ctx, key)
}
