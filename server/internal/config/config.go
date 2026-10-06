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
	DocsDir          string         // AGNTS_DOCS_DIR, overrides for page docs (<dir>/<lang>/<page>.md)
	TimeZone         *time.Location // AGNTS_TZ, for "today" on the dashboard
	UsageRefresh     time.Duration  // AGNTS_USAGE_REFRESH_EVERY, idle usage refresh (0 disables)
	FCMCredentials   string         // AGNTS_FCM_CREDENTIALS, Firebase service account JSON file (push)
	TelegramAPI      string         // AGNTS_TELEGRAM_API, Bot API base URL
	MCPRedirectHosts []string       // AGNTS_MCP_REDIRECT_HOSTS, hosts Claude connectors may redirect to
	RunProxy         string         // AGNTS_RUN_PROXY, egress proxy for run containers (e.g. http://egress:3128)
	EgressAllow      []string       // AGNTS_EGRESS_ALLOW, hosts run containers may reach
	MetricsAddr      string         // AGNTS_METRICS_ADDR, Prometheus listener (keep it private); empty disables
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
	if c.JiraSyncEach, err = time.ParseDuration(get("AGNTS_JIRA_SYNC_EVERY", "1h")); err != nil || c.JiraSyncEach < time.Minute {
		errs = append(errs, errors.New("AGNTS_JIRA_SYNC_EVERY must be a duration of at least 1m"))
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
