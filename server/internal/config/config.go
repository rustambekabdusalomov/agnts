// Package config loads hiro's configuration from environment variables.
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
	Addr          string        // HIRO_ADDR, listen address
	PublicURL     *url.URL      // HIRO_PUBLIC_URL, e.g. https://hiro.example.com
	DatabaseURL   string        // HIRO_DATABASE_URL
	EncKey        []byte        // HIRO_ENC_KEY, base64 of 32 bytes, encrypts secrets at rest
	WebDir        string        // HIRO_WEB_DIR, built admin panel; empty disables static serving
	LogLevel      string        // HIRO_LOG_LEVEL: debug, info, warn, error
	LogFormat     string        // HIRO_LOG_FORMAT: json or text
	SessionTTL    time.Duration // HIRO_SESSION_TTL
	CookieSecure  bool          // HIRO_COOKIE_SECURE, false only for local http development
	AutoMigrate   bool          // HIRO_AUTO_MIGRATE, apply migrations on serve
	ShutdownGrace time.Duration // HIRO_SHUTDOWN_GRACE

	// Agent loop (phase 1).
	AgentEnabled     bool           // HIRO_AGENT_ENABLED, false runs only the API
	DataDir          string         // HIRO_DATA_DIR, clones and Claude sessions
	DockerSocket     string         // HIRO_DOCKER_SOCKET
	RunnerImage      string         // HIRO_RUNNER_IMAGE
	RunNetwork       string         // HIRO_RUN_NETWORK, Docker network for run containers
	Parallel         int            // HIRO_PARALLEL, tickets worked on at once
	ModelAnalyze     string         // HIRO_MODEL_ANALYZE
	ModelCode        string         // HIRO_MODEL_CODE
	GitName          string         // HIRO_GIT_AUTHOR_NAME, commits are authored as you
	GitEmail         string         // HIRO_GIT_AUTHOR_EMAIL
	GitHubAPI        string         // HIRO_GITHUB_API
	JiraSyncEach     time.Duration  // HIRO_JIRA_SYNC_EVERY, reconcile interval
	DocsDir          string         // HIRO_DOCS_DIR, overrides for page docs (<dir>/<lang>/<page>.md)
	TimeZone         *time.Location // HIRO_TZ, for "today" on the dashboard
	UsageRefresh     time.Duration  // HIRO_USAGE_REFRESH_EVERY, idle usage refresh (0 disables)
	FCMCredentials   string         // HIRO_FCM_CREDENTIALS, Firebase service account JSON file (push)
	TelegramAPI      string         // HIRO_TELEGRAM_API, Bot API base URL
	MCPRedirectHosts []string       // HIRO_MCP_REDIRECT_HOSTS, hosts Claude connectors may redirect to
	RunProxy         string         // HIRO_RUN_PROXY, egress proxy for run containers (e.g. http://egress:3128)
	EgressAllow      []string       // HIRO_EGRESS_ALLOW, hosts run containers may reach
	MetricsAddr      string         // HIRO_METRICS_ADDR, Prometheus listener (keep it private); empty disables
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
		Addr:        get("HIRO_ADDR", ":8080"),
		DatabaseURL: get("HIRO_DATABASE_URL", ""),
		WebDir:      get("HIRO_WEB_DIR", ""),
		LogLevel:    strings.ToLower(get("HIRO_LOG_LEVEL", "info")),
		LogFormat:   strings.ToLower(get("HIRO_LOG_FORMAT", "json")),
	}

	c.DataDir = get("HIRO_DATA_DIR", "/var/lib/hiro")
	c.DockerSocket = get("HIRO_DOCKER_SOCKET", "/var/run/docker.sock")
	c.RunnerImage = get("HIRO_RUNNER_IMAGE", "hiro-runner:latest")
	c.RunNetwork = get("HIRO_RUN_NETWORK", "hiro-runs")
	c.ModelAnalyze = get("HIRO_MODEL_ANALYZE", "opus")
	c.ModelCode = get("HIRO_MODEL_CODE", "opus")
	c.GitName = get("HIRO_GIT_AUTHOR_NAME", "")
	c.GitEmail = get("HIRO_GIT_AUTHOR_EMAIL", "")
	c.GitHubAPI = get("HIRO_GITHUB_API", "https://api.github.com")
	c.DocsDir = get("HIRO_DOCS_DIR", "")
	c.FCMCredentials = get("HIRO_FCM_CREDENTIALS", "")
	c.TelegramAPI = get("HIRO_TELEGRAM_API", "https://api.telegram.org")
	c.RunProxy = get("HIRO_RUN_PROXY", "")
	c.MetricsAddr = get("HIRO_METRICS_ADDR", "")
	for _, h := range strings.Split(get("HIRO_EGRESS_ALLOW", ""), ",") {
		if h = strings.TrimSpace(h); h != "" {
			c.EgressAllow = append(c.EgressAllow, h)
		}
	}
	for _, h := range strings.Split(get("HIRO_MCP_REDIRECT_HOSTS", "claude.ai,claude.com"), ",") {
		if h = strings.TrimSpace(h); h != "" {
			c.MCPRedirectHosts = append(c.MCPRedirectHosts, h)
		}
	}
	if c.TimeZone, err = loadZone(get("HIRO_TZ", "")); err != nil {
		errs = append(errs, fmt.Errorf("HIRO_TZ: %w", err))
		c.TimeZone = time.UTC
	}
	if c.UsageRefresh, err = time.ParseDuration(get("HIRO_USAGE_REFRESH_EVERY", "30m")); err != nil || c.UsageRefresh < 0 {
		errs = append(errs, errors.New("HIRO_USAGE_REFRESH_EVERY must be a duration (0 disables)"))
	}

	if c.DatabaseURL == "" {
		errs = append(errs, errors.New("HIRO_DATABASE_URL is required"))
	}

	pub, err := url.Parse(get("HIRO_PUBLIC_URL", "http://localhost:8080"))
	if err != nil || pub.Scheme == "" || pub.Host == "" {
		errs = append(errs, errors.New("HIRO_PUBLIC_URL must be an absolute URL"))
	}
	c.PublicURL = pub

	key, err := base64.StdEncoding.DecodeString(get("HIRO_ENC_KEY", ""))
	if err != nil || len(key) != 32 {
		errs = append(errs, errors.New("HIRO_ENC_KEY must be base64 of 32 bytes (run: hiro keygen)"))
	}
	c.EncKey = key

	c.SessionTTL, err = time.ParseDuration(get("HIRO_SESSION_TTL", "720h"))
	if err != nil || c.SessionTTL <= 0 {
		errs = append(errs, errors.New("HIRO_SESSION_TTL must be a positive duration"))
	}
	c.ShutdownGrace, err = time.ParseDuration(get("HIRO_SHUTDOWN_GRACE", "15s"))
	if err != nil {
		errs = append(errs, errors.New("HIRO_SHUTDOWN_GRACE must be a duration"))
	}
	if c.CookieSecure, err = strconv.ParseBool(get("HIRO_COOKIE_SECURE", "true")); err != nil {
		errs = append(errs, errors.New("HIRO_COOKIE_SECURE must be true or false"))
	}
	if c.AutoMigrate, err = strconv.ParseBool(get("HIRO_AUTO_MIGRATE", "true")); err != nil {
		errs = append(errs, errors.New("HIRO_AUTO_MIGRATE must be true or false"))
	}

	if c.AgentEnabled, err = strconv.ParseBool(get("HIRO_AGENT_ENABLED", "true")); err != nil {
		errs = append(errs, errors.New("HIRO_AGENT_ENABLED must be true or false"))
	}
	if c.Parallel, err = strconv.Atoi(get("HIRO_PARALLEL", "1")); err != nil || c.Parallel < 1 || c.Parallel > 8 {
		errs = append(errs, errors.New("HIRO_PARALLEL must be a number from 1 to 8"))
	}
	if c.JiraSyncEach, err = time.ParseDuration(get("HIRO_JIRA_SYNC_EVERY", "1h")); err != nil || c.JiraSyncEach < time.Minute {
		errs = append(errs, errors.New("HIRO_JIRA_SYNC_EVERY must be a duration of at least 1m"))
	}

	switch c.LogLevel {
	case "debug", "info", "warn", "error":
	default:
		errs = append(errs, fmt.Errorf("HIRO_LOG_LEVEL %q is not one of debug, info, warn, error", c.LogLevel))
	}
	switch c.LogFormat {
	case "json", "text":
	default:
		errs = append(errs, fmt.Errorf("HIRO_LOG_FORMAT %q is not json or text", c.LogFormat))
	}

	return c, errors.Join(errs...)
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
