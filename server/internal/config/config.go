// Package config loads agnts's configuration from environment variables.
package config

import (
	"encoding/base64"
	"errors"
	"fmt"
	"net/url"
	"os"
	"strconv"
	"strings"
	"time"
)

// Config is the full server configuration.
type Config struct {
	Addr          string        // AGNTS_ADDR, listen address
	PublicURL     *url.URL      // AGNTS_PUBLIC_URL, e.g. https://agnts.example.com
	DatabaseURL   string        // AGNTS_DATABASE_URL
	EncKey        []byte        // AGNTS_ENC_KEY, base64 of 32 bytes, encrypts secrets at rest
	WebDir        string        // AGNTS_WEB_DIR, built admin panel; empty disables static serving
	LogLevel      string        // AGNTS_LOG_LEVEL: debug, info, warn, error
	LogFormat     string        // AGNTS_LOG_FORMAT: json or text
	SessionTTL    time.Duration // AGNTS_SESSION_TTL
	CookieSecure  bool          // AGNTS_COOKIE_SECURE, false only for local http development
	AutoMigrate   bool          // AGNTS_AUTO_MIGRATE, apply migrations on serve
	ShutdownGrace time.Duration // AGNTS_SHUTDOWN_GRACE

	// Agent loop (phase 1).
	AgentEnabled     bool           // AGNTS_AGENT_ENABLED, false runs only the API
	DataDir          string         // AGNTS_DATA_DIR, clones and Claude sessions
	DockerSocket     string         // AGNTS_DOCKER_SOCKET
	RunnerImage      string         // AGNTS_RUNNER_IMAGE
	RunNetwork       string         // AGNTS_RUN_NETWORK, Docker network for run containers
	Parallel         int            // AGNTS_PARALLEL, tickets worked on at once
	ModelAnalyze     string         // AGNTS_MODEL_ANALYZE
	ModelCode        string         // AGNTS_MODEL_CODE
	GitName          string         // AGNTS_GIT_AUTHOR_NAME, commits are authored as you
	GitEmail         string         // AGNTS_GIT_AUTHOR_EMAIL
	GitHubAPI        string         // AGNTS_GITHUB_API
	JiraSyncEach     time.Duration  // AGNTS_JIRA_SYNC_EVERY, reconcile interval
	PlaneSyncEach    time.Duration  // AGNTS_PLANE_SYNC_EVERY, reconcile interval
	DocsDir          string         // AGNTS_DOCS_DIR, overrides for page docs (<dir>/<lang>/<page>.md)
	TimeZone         *time.Location // AGNTS_TZ, for "today" on the dashboard
	UsageRefresh     time.Duration  // AGNTS_USAGE_REFRESH_EVERY, idle usage refresh (0 disables)
	FCMCredentials   string         // AGNTS_FCM_CREDENTIALS, Firebase service account JSON file (push)
	TelegramAPI      string         // AGNTS_TELEGRAM_API, Bot API base URL
	MCPRedirectHosts []string       // AGNTS_MCP_REDIRECT_HOSTS, hosts Claude connectors may redirect to
	RunProxy         string         // AGNTS_RUN_PROXY, egress proxy for run containers (e.g. http://egress:3128)
	EgressAllow      []string       // AGNTS_EGRESS_ALLOW, hosts run containers may reach
	MetricsAddr      string         // AGNTS_METRICS_ADDR, Prometheus listener (keep it private); empty disables
	// InternalAddr serves the egress proxy the hosts allowed in Settings
	// (AGNTS_INTERNAL_ADDR). Keep it private; empty disables.
	InternalAddr string

	// Toolchains (any-language runs).
	ToolchainVolume string // AGNTS_TOOLCHAIN_VOLUME, shared volume mise installs into
	RunMemoryMB     int    // AGNTS_RUN_MEMORY_MB, default memory of a run container
	RunMemoryMaxMB  int    // AGNTS_RUN_MEMORY_MAX_MB, highest per-repository memory override
	CacheMaxBytes   int64  // AGNTS_CACHE_MAX_GB, a repository's package cache is emptied above it (0 disables)
	// CacheIdleDays empties a repository's package cache nobody used for
	// that many days (AGNTS_CACHE_IDLE_DAYS, 0 disables).
	CacheIdleDays int

	// Workspaces and people.
	// Signup is who may register (AGNTS_SIGNUP): "open" for anyone,
	// "invite" for people with an invite link (the first account on a
	// fresh install can always register).
	Signup string
	// SMTPURL sends email (AGNTS_SMTP_URL, smtp://user:pass@host:587);
	// empty logs the messages instead.
	SMTPURL  string
	MailFrom string // AGNTS_MAIL_FROM
	// TrialDays is how long a new workspace's trial lasts (AGNTS_TRIAL_DAYS, 0: none).
	TrialDays int
	// Cloud turns on the hosted product's rules (AGNTS_CLOUD): billing,
	// API keys only for Claude (no subscription tokens), plan limits.
	Cloud bool

	// Capacity (the server queue).
	// RunMemoryBudgetMB is the memory all run containers together may
	// reserve (AGNTS_RUN_MEMORY_BUDGET_MB; 0: the host's memory less 2.5 GB).
	RunMemoryBudgetMB int64
	// MinFreeDiskMB holds runs back while the data disk has less free
	// (AGNTS_MIN_FREE_DISK_GB).
	MinFreeDiskMB int64
	// RunRuntime is the container runtime for runs (AGNTS_RUN_RUNTIME,
	// e.g. runsc for gVisor; empty: Docker's default).
	RunRuntime string
	// RunNetworkPerRun gives every run its own network
	// (AGNTS_RUN_NETWORK_PER_RUN), so runs cannot reach each other; the
	// egress proxy container (AGNTS_EGRESS_CONTAINER) joins each one.
	RunNetworkPerRun bool
	EgressContainer  string

	// Billing and credits.
	// AnthropicAPIKey is agnts's own key, used for runs paid with credits
	// (AGNTS_ANTHROPIC_API_KEY); empty disables credits.
	AnthropicAPIKey string
	// CreditMarkup multiplies API cost into credits (AGNTS_CREDIT_MARKUP).
	CreditMarkup float64
	// RunCreditCap is the most credits one run may spend (AGNTS_RUN_CREDIT_CAP).
	RunCreditCap int64
	// Prices in so'm (AGNTS_PRICE_*): a workspace a month, an extra slot,
	// a member above the included ones, one credit.
	PriceWorkspaceUZS, PriceSlotUZS, PriceMemberUZS, PriceCreditUZS int64
	IncludedMembers, MaxSlots                                       int
	// Payme and Click merchants (AGNTS_PAYME_*, AGNTS_CLICK_*); empty
	// disables that provider.
	PaymeMerchantID, PaymeKey                       string
	ClickServiceID, ClickMerchantID, ClickSecretKey string
}

// Load reads the configuration from the environment.
func Load() (Config, error) {
	return load(os.LookupEnv)
}

func load(lookup func(string) (string, bool)) (Config, error) {
	get := func(key, def string) string {
		if v, ok := lookup(key); ok && strings.TrimSpace(v) != "" {
			return strings.TrimSpace(v)
		}
		return def
	}

	var errs []error
	var err error
	c := Config{
		Addr:        get("AGNTS_ADDR", ":8080"),
		DatabaseURL: get("AGNTS_DATABASE_URL", ""),
		WebDir:      get("AGNTS_WEB_DIR", ""),
		LogLevel:    strings.ToLower(get("AGNTS_LOG_LEVEL", "info")),
		LogFormat:   strings.ToLower(get("AGNTS_LOG_FORMAT", "json")),
	}

	c.DataDir = get("AGNTS_DATA_DIR", "/var/lib/agnts")
	c.DockerSocket = get("AGNTS_DOCKER_SOCKET", "/var/run/docker.sock")
	c.RunnerImage = get("AGNTS_RUNNER_IMAGE", "agnts-runner:latest")
	c.RunNetwork = get("AGNTS_RUN_NETWORK", "agnts-runs")
	c.ModelAnalyze = get("AGNTS_MODEL_ANALYZE", "opus")
	c.ModelCode = get("AGNTS_MODEL_CODE", "opus")
	c.GitName = get("AGNTS_GIT_AUTHOR_NAME", "")
	c.GitEmail = get("AGNTS_GIT_AUTHOR_EMAIL", "")
	c.GitHubAPI = get("AGNTS_GITHUB_API", "https://api.github.com")
	c.DocsDir = get("AGNTS_DOCS_DIR", "")
	c.FCMCredentials = get("AGNTS_FCM_CREDENTIALS", "")
	c.TelegramAPI = get("AGNTS_TELEGRAM_API", "https://api.telegram.org")
	c.RunProxy = get("AGNTS_RUN_PROXY", "")
	c.MetricsAddr = get("AGNTS_METRICS_ADDR", "")
	c.InternalAddr = get("AGNTS_INTERNAL_ADDR", ":8081")
	for _, h := range strings.Split(get("AGNTS_EGRESS_ALLOW", ""), ",") {
		if h = strings.TrimSpace(h); h != "" {
			c.EgressAllow = append(c.EgressAllow, h)
		}
	}
	for _, h := range strings.Split(get("AGNTS_MCP_REDIRECT_HOSTS", "claude.ai,claude.com"), ",") {
		if h = strings.TrimSpace(h); h != "" {
			c.MCPRedirectHosts = append(c.MCPRedirectHosts, h)
		}
	}
	if c.TimeZone, err = loadZone(get("AGNTS_TZ", "")); err != nil {
		errs = append(errs, fmt.Errorf("AGNTS_TZ: %w", err))
		c.TimeZone = time.UTC
	}
	if c.UsageRefresh, err = time.ParseDuration(get("AGNTS_USAGE_REFRESH_EVERY", "30m")); err != nil || c.UsageRefresh < 0 {
		errs = append(errs, errors.New("AGNTS_USAGE_REFRESH_EVERY must be a duration (0 disables)"))
	}

	if c.DatabaseURL == "" {
		errs = append(errs, errors.New("AGNTS_DATABASE_URL is required"))
	}

	pub, err := url.Parse(get("AGNTS_PUBLIC_URL", "http://localhost:8080"))
	if err != nil || pub.Scheme == "" || pub.Host == "" {
		errs = append(errs, errors.New("AGNTS_PUBLIC_URL must be an absolute URL"))
	}
	c.PublicURL = pub

	key, err := base64.StdEncoding.DecodeString(get("AGNTS_ENC_KEY", ""))
	if err != nil || len(key) != 32 {
		errs = append(errs, errors.New("AGNTS_ENC_KEY must be base64 of 32 bytes (run: agnts keygen)"))
	}
	c.EncKey = key

	c.SessionTTL, err = time.ParseDuration(get("AGNTS_SESSION_TTL", "720h"))
	if err != nil || c.SessionTTL <= 0 {
		errs = append(errs, errors.New("AGNTS_SESSION_TTL must be a positive duration"))
	}
	c.ShutdownGrace, err = time.ParseDuration(get("AGNTS_SHUTDOWN_GRACE", "15s"))
	if err != nil {
		errs = append(errs, errors.New("AGNTS_SHUTDOWN_GRACE must be a duration"))
	}
	if c.CookieSecure, err = strconv.ParseBool(get("AGNTS_COOKIE_SECURE", "true")); err != nil {
		errs = append(errs, errors.New("AGNTS_COOKIE_SECURE must be true or false"))
	}
	if c.AutoMigrate, err = strconv.ParseBool(get("AGNTS_AUTO_MIGRATE", "true")); err != nil {
		errs = append(errs, errors.New("AGNTS_AUTO_MIGRATE must be true or false"))
	}

	if c.AgentEnabled, err = strconv.ParseBool(get("AGNTS_AGENT_ENABLED", "true")); err != nil {
		errs = append(errs, errors.New("AGNTS_AGENT_ENABLED must be true or false"))
	}
	if c.Parallel, err = strconv.Atoi(get("AGNTS_PARALLEL", "1")); err != nil || c.Parallel < 1 || c.Parallel > 8 {
		errs = append(errs, errors.New("AGNTS_PARALLEL must be a number from 1 to 8"))
	}
	c.ToolchainVolume = get("AGNTS_TOOLCHAIN_VOLUME", "agnts-toolchains")
	if c.RunMemoryMB, err = strconv.Atoi(get("AGNTS_RUN_MEMORY_MB", "4096")); err != nil || c.RunMemoryMB < 512 {
		errs = append(errs, errors.New("AGNTS_RUN_MEMORY_MB must be a number of megabytes, at least 512"))
	}
	if c.RunMemoryMaxMB, err = strconv.Atoi(get("AGNTS_RUN_MEMORY_MAX_MB", "8192")); err != nil || c.RunMemoryMaxMB < 512 {
		errs = append(errs, errors.New("AGNTS_RUN_MEMORY_MAX_MB must be a number of megabytes, at least 512"))
	}
	if gb, err := strconv.ParseFloat(get("AGNTS_CACHE_MAX_GB", "5"), 64); err != nil || gb < 0 {
		errs = append(errs, errors.New("AGNTS_CACHE_MAX_GB must be a number of gigabytes (0 disables the limit)"))
	} else {
		c.CacheMaxBytes = int64(gb * (1 << 30))
	}
	if c.CacheIdleDays, err = strconv.Atoi(get("AGNTS_CACHE_IDLE_DAYS", "14")); err != nil || c.CacheIdleDays < 0 {
		errs = append(errs, errors.New("AGNTS_CACHE_IDLE_DAYS must be a number of days (0 disables)"))
	}

	c.Signup = strings.ToLower(get("AGNTS_SIGNUP", "invite"))
	if c.Signup != "open" && c.Signup != "invite" {
		errs = append(errs, errors.New("AGNTS_SIGNUP must be open or invite"))
	}
	c.SMTPURL = get("AGNTS_SMTP_URL", "")
	if c.SMTPURL != "" {
		if u, err := url.Parse(c.SMTPURL); err != nil || (u.Scheme != "smtp" && u.Scheme != "smtps") || u.Host == "" {
			errs = append(errs, errors.New("AGNTS_SMTP_URL must look like smtp://user:password@host:587 (or smtps:// for port 465)"))
		}
	}
	c.MailFrom = get("AGNTS_MAIL_FROM", "agnts <noreply@"+hostOf(get("AGNTS_PUBLIC_URL", "http://localhost"))+">")
	if c.TrialDays, err = strconv.Atoi(get("AGNTS_TRIAL_DAYS", "14")); err != nil || c.TrialDays < 0 {
		errs = append(errs, errors.New("AGNTS_TRIAL_DAYS must be a number of days"))
	}
	if c.Cloud, err = strconv.ParseBool(get("AGNTS_CLOUD", "false")); err != nil {
		errs = append(errs, errors.New("AGNTS_CLOUD must be true or false"))
	}
	if c.RunMemoryBudgetMB, err = strconv.ParseInt(get("AGNTS_RUN_MEMORY_BUDGET_MB", "0"), 10, 64); err != nil || c.RunMemoryBudgetMB < 0 {
		errs = append(errs, errors.New("AGNTS_RUN_MEMORY_BUDGET_MB must be a number of megabytes (0: the host's memory less 2.5 GB)"))
	}
	if gb, err := strconv.ParseFloat(get("AGNTS_MIN_FREE_DISK_GB", "10"), 64); err != nil || gb < 0 {
		errs = append(errs, errors.New("AGNTS_MIN_FREE_DISK_GB must be a number of gigabytes"))
	} else {
		c.MinFreeDiskMB = int64(gb * 1024)
	}
	c.RunRuntime = get("AGNTS_RUN_RUNTIME", "")
	if c.RunNetworkPerRun, err = strconv.ParseBool(get("AGNTS_RUN_NETWORK_PER_RUN", "false")); err != nil {
		errs = append(errs, errors.New("AGNTS_RUN_NETWORK_PER_RUN must be true or false"))
	}
	c.EgressContainer = get("AGNTS_EGRESS_CONTAINER", "")
	if c.RunNetworkPerRun && c.RunProxy != "" && c.EgressContainer == "" {
		errs = append(errs, errors.New("AGNTS_RUN_NETWORK_PER_RUN with AGNTS_RUN_PROXY needs AGNTS_EGRESS_CONTAINER (the egress proxy's container name)"))
	}
	c.AnthropicAPIKey = get("AGNTS_ANTHROPIC_API_KEY", "")
	if c.CreditMarkup, err = strconv.ParseFloat(get("AGNTS_CREDIT_MARKUP", "1.4"), 64); err != nil || c.CreditMarkup < 1 {
		errs = append(errs, errors.New("AGNTS_CREDIT_MARKUP must be a number of at least 1"))
	}
	if c.RunCreditCap, err = strconv.ParseInt(get("AGNTS_RUN_CREDIT_CAP", "2500"), 10, 64); err != nil || c.RunCreditCap < 1 {
		errs = append(errs, errors.New("AGNTS_RUN_CREDIT_CAP must be a positive number of credits"))
	}
	prices := []struct {
		key string
		def string
		dst *int64
	}{
		{"AGNTS_PRICE_WORKSPACE_UZS", "300000", &c.PriceWorkspaceUZS},
		{"AGNTS_PRICE_SLOT_UZS", "190000", &c.PriceSlotUZS},
		{"AGNTS_PRICE_MEMBER_UZS", "60000", &c.PriceMemberUZS},
		{"AGNTS_PRICE_CREDIT_UZS", "175", &c.PriceCreditUZS},
	}
	for _, p := range prices {
		if *p.dst, err = strconv.ParseInt(get(p.key, p.def), 10, 64); err != nil || *p.dst < 0 {
			errs = append(errs, fmt.Errorf("%s must be a number of so'm", p.key))
		}
	}
	if c.IncludedMembers, err = strconv.Atoi(get("AGNTS_INCLUDED_MEMBERS", "5")); err != nil || c.IncludedMembers < 1 {
		errs = append(errs, errors.New("AGNTS_INCLUDED_MEMBERS must be a positive number"))
	}
	if c.MaxSlots, err = strconv.Atoi(get("AGNTS_MAX_SLOTS", "5")); err != nil || c.MaxSlots < 1 || c.MaxSlots > 50 {
		errs = append(errs, errors.New("AGNTS_MAX_SLOTS must be a number from 1 to 50"))
	}
	c.PaymeMerchantID, c.PaymeKey = get("AGNTS_PAYME_MERCHANT_ID", ""), get("AGNTS_PAYME_KEY", "")
	c.ClickServiceID, c.ClickMerchantID, c.ClickSecretKey = get("AGNTS_CLICK_SERVICE_ID", ""), get("AGNTS_CLICK_MERCHANT_ID", ""), get("AGNTS_CLICK_SECRET_KEY", "")

	if c.JiraSyncEach, err = time.ParseDuration(get("AGNTS_JIRA_SYNC_EVERY", "1h")); err != nil || c.JiraSyncEach < time.Minute {
		errs = append(errs, errors.New("AGNTS_JIRA_SYNC_EVERY must be a duration of at least 1m"))
	}
	if c.PlaneSyncEach, err = time.ParseDuration(get("AGNTS_PLANE_SYNC_EVERY", "1h")); err != nil || c.PlaneSyncEach < 5*time.Minute {
		errs = append(errs, errors.New("AGNTS_PLANE_SYNC_EVERY must be a duration of at least 5m (Plane allows 60 API requests a minute)"))
	}

	switch c.LogLevel {
	case "debug", "info", "warn", "error":
	default:
		errs = append(errs, fmt.Errorf("AGNTS_LOG_LEVEL %q is not one of debug, info, warn, error", c.LogLevel))
	}
	switch c.LogFormat {
	case "json", "text":
	default:
		errs = append(errs, fmt.Errorf("AGNTS_LOG_FORMAT %q is not json or text", c.LogFormat))
	}

	return c, errors.Join(errs...)
}

// hostOf returns the host of a URL, or "localhost".
func hostOf(raw string) string {
	if u, err := url.Parse(raw); err == nil && u.Hostname() != "" {
		return u.Hostname()
	}
	return "localhost"
}

// loadZone loads a named time zone, or the machine's own when name is empty
// or "Local". The zone's name goes to PostgreSQL (AT TIME ZONE), which needs
// an IANA name such as Asia/Tashkent; Go's "Local" means nothing to it.
func loadZone(name string) (*time.Location, error) {
	if name == "" || name == "Local" {
		name = localZoneName()
	}
	return time.LoadLocation(name)
}

// localZoneName finds the machine's IANA zone name from $TZ or the
// /etc/localtime symlink, falling back to UTC.
func localZoneName() string {
	candidates := []string{strings.TrimPrefix(os.Getenv("TZ"), ":")}
	if target, err := os.Readlink("/etc/localtime"); err == nil {
		if _, zone, ok := strings.Cut(target, "zoneinfo/"); ok {
			candidates = append(candidates, zone)
		}
	}
	for _, c := range candidates {
		if c == "" || c == "Local" {
			continue
		}
		if _, err := time.LoadLocation(c); err == nil {
			return c
		}
	}
	return "UTC"
}
