// Command agnts is the agnts server and its admin CLI.
package main

import (
	"bufio"
	"context"
	"crypto/rand"
	"encoding/base64"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"log/slog"
	"net"
	"net/http"
	"os"
	"os/signal"
	"strings"
	"syscall"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"
	"golang.org/x/term"

	"agnts/internal/auth"
	"agnts/internal/config"
	"agnts/internal/domain"
	"agnts/internal/egress"
	"agnts/internal/gateway"
	"agnts/internal/logging"
	"agnts/internal/oauth"
	"agnts/internal/ovpnside"
	"agnts/internal/privnet"
	"agnts/internal/secret"
	"agnts/internal/store/postgres"
	"agnts/internal/watch"
)

// Set at build time with -ldflags "-X main.version=... -X main.commit=...".
var (
	version = "dev"
	commit  = "unknown"
)

const usageText = `agnts: autonomous coding agent with human gates

Usage:
  agnts serve                    run the server
  agnts migrate [up|down|status|version]
                                manage the database schema (default: up)
  agnts user create <username>   create a user (password + TOTP); the first one is Admin
  agnts user add <username>      create a User who signs in with just a password
  agnts workspace list|create|add|slots|members|suspend|resume
                                manage workspaces (see agnts workspace)
  agnts admin grant|revoke <username>
                                grant or remove the Admin role
  agnts credits grant <slug> <amount> [note]
                                add (or take back) a workspace's credits

Workspace commands act in --workspace <slug> (or AGNTS_WORKSPACE), else the
install's default workspace:
  agnts repo add [flags]         add or update a repository (see agnts repo add -h)
  agnts repo list                list repositories
  agnts repo group list|add|members|rm
                                 repository groups: tickets that change several repositories
  agnts integration set <jira|plane|github|claude>
                                connect a service (secrets are read from the terminal)
  agnts jira sync                pick up labelled Jira issues now
  agnts plane sync               pick up labelled Plane work items now
  agnts eval relations           score the queue's predictions (footprints, conflicts) against the real diffs
  agnts eval replay KEY...       re-run done tickets with today's prompts, from the commit each started from
  agnts eval bench [STAGE=MODEL...]
                                replay every benchmark ticket with today's prompts (and these models, e.g. coding=opus)
  agnts eval report              compare the replays with what their tickets merged as, by prompt version and model
  agnts eval assistant [--limit N]
                                answer shared assistant questions again with today's prompts, old and new side by side
  agnts mcp token                create a new static MCP bearer token (the owner's)
  agnts keygen                   print a new AGNTS_ENC_KEY
  agnts version [--json]         print the version
  agnts healthcheck              exit 0 if the local server is healthy (for Docker)
  agnts egress-proxy             run the allowlist proxy for run containers (AGNTS_EGRESS_ALLOW)
  agnts watch                    run agnts-watch on a project server: push Docker and file logs to the
                                 log watcher (AGNTS_URL, AGNTS_WATCH_TOKEN, AGNTS_WATCH_DOCKER, AGNTS_WATCH_FILES)
  agnts gateway                  run the private network gateway (WireGuard, OpenVPN, agnts-link)
  agnts ovpn-sidecar             run a workspace's OpenVPN client (inside its sidecar container)

Configuration is read from AGNTS_* environment variables; see deploy/.env.example.
`

func main() {
	ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer stop()
	if err := run(ctx, os.Args[1:]); err != nil {
		fmt.Fprintln(os.Stderr, "agnts:", err)
		os.Exit(1)
	}
}

func run(ctx context.Context, args []string) error {
	if len(args) == 0 {
		fmt.Print(usageText)
		return nil
	}
	switch args[0] {
	case "keygen":
		key := make([]byte, 32)
		if _, err := rand.Read(key); err != nil {
			return err
		}
		fmt.Println(base64.StdEncoding.EncodeToString(key))
		return nil
	case "version":
		if len(args) > 1 && args[1] == "--json" {
			return json.NewEncoder(os.Stdout).Encode(map[string]string{"version": version, "commit": commit})
		}
		fmt.Printf("agnts %s (%s)\n", version, commit)
		return nil
	case "healthcheck":
		return healthcheck(ctx)
	case "egress-proxy":
		return egressProxy(ctx)
	case "watch":
		cfg, err := watch.FromEnv(os.Getenv)
		if err != nil {
			return err
		}
		return watch.New(cfg, logging.New(os.Stdout, os.Getenv("AGNTS_LOG_FORMAT"), os.Getenv("AGNTS_LOG_LEVEL"))).Run(ctx)
	case "gateway":
		return gatewayCmd(ctx)
	case "ovpn-sidecar":
		return ovpnSidecar(ctx)
	case "help", "-h", "--help":
		fmt.Print(usageText)
		return nil
	}

	cfg, err := config.Load()
	if err != nil {
		return fmt.Errorf("config:\n%w", err)
	}
	log := logging.New(os.Stdout, cfg.LogFormat, cfg.LogLevel)
	slog.SetDefault(log)

	pool, err := postgres.Open(ctx, cfg.DatabaseURL)
	if err != nil {
		return err
	}
	defer pool.Close()

	switch args[0] {
	case "repo", "integration", "mcp", "jira", "plane", "eval":
		wctx, w, rest, err := cliWorkspace(ctx, pool, args)
		if err != nil {
			return err
		}
		return workspaceCommand(wctx, cfg, log, pool, w, rest)
	case "workspace":
		return workspaceCmd(ctx, pool, args[1:], os.Stdout)
	case "admin":
		return adminCmd(ctx, pool, args[1:], os.Stdout)
	case "credits":
		return creditsCmd(ctx, pool, args[1:], os.Stdout)
	}
	switch args[0] {
	case "serve":
		return serve(ctx, cfg, log, pool)
	case "migrate":
		cmd := "up"
		if len(args) > 1 {
			cmd = args[1]
		}
		return postgres.Migrate(ctx, pool, postgres.MigrateCommand(cmd), log)
	case "user":
		if len(args) != 3 || (args[1] != "create" && args[1] != "add") {
			return errors.New("usage: agnts user create|add <username>")
		}
		svc, err := newAuth(cfg, pool)
		if err != nil {
			return err
		}
		if args[1] == "add" {
			return addUser(ctx, svc, args[2], os.Stdin, os.Stdout)
		}
		return createUser(ctx, svc, postgres.NewWorkspaces(pool), args[2], os.Stdin, os.Stdout)
	default:
		return fmt.Errorf("unknown command %q\n\n%s", args[0], usageText)
	}
}

// workspaceCommand runs a command that acts in workspace w (ctx acts in it).
func workspaceCommand(ctx context.Context, cfg config.Config, log *slog.Logger, pool postgresPool, w domain.Workspace, args []string) error {
	switch args[0] {
	case "repo":
		return repoCmd(ctx, cfg, pool, args[1:], os.Stdout)
	case "integration":
		return integrationCmd(ctx, cfg, pool, args[1:], os.Stdin, os.Stdout)
	case "mcp":
		if len(args) != 2 || args[1] != "token" {
			return errors.New("usage: agnts mcp token")
		}
		if w.OwnerID == 0 {
			return errors.New("the workspace has no owner yet")
		}
		tok, err := oauth.New(pool, cfg.PublicURL.String(), cfg.MCPRedirectHosts, log).RotateStatic(ctx, w.OwnerID)
		if err != nil {
			return err
		}
		fmt.Printf("New MCP token for %s, acting as its owner (shown once; the previous one stops working):\n\n  %s\n\nUse it as `Authorization: Bearer <token>` for %s/mcp\n", w.Slug, tok, strings.TrimRight(cfg.PublicURL.String(), "/"))
		return nil
	case "jira":
		if len(args) != 2 || args[1] != "sync" {
			return errors.New("usage: agnts jira sync")
		}
		return jiraSync(ctx, cfg, pool, log)
	case "plane":
		if len(args) != 2 || args[1] != "sync" {
			return errors.New("usage: agnts plane sync")
		}
		return planeSync(ctx, cfg, pool, log)
	case "eval":
		switch {
		case len(args) == 2 && args[1] == "relations":
			return evalRelations(ctx, pool, os.Stdout)
		case len(args) >= 3 && args[1] == "replay":
			return evalReplay(ctx, cfg, pool, log, args[2:], os.Stdout)
		case len(args) >= 2 && args[1] == "bench":
			return evalBench(ctx, cfg, pool, log, args[2:], os.Stdout)
		case len(args) == 2 && args[1] == "report":
			return evalReport(ctx, cfg, pool, log, os.Stdout)
		case len(args) >= 2 && args[1] == "assistant":
			return evalAssistant(ctx, cfg, pool, log, args[2:], os.Stdout)
		}
		return errors.New("usage: agnts eval relations | eval replay KEY... | eval bench [STAGE=MODEL...] | eval report | eval assistant [--limit N | --cases]")
	}
	return fmt.Errorf("unknown command %q", args[0])
}

type postgresPool = *pgxpool.Pool

func newAuth(cfg config.Config, pool postgresPool) (*auth.Service, error) {
	box, err := secret.NewBox(cfg.EncKey)
	if err != nil {
		return nil, err
	}
	return auth.New(postgres.NewUsers(pool), postgres.NewSessions(pool), box, cfg.SessionTTL)
}

// healthcheck calls /healthz on the local server. The runtime image has no
// shell or curl, so Docker's HEALTHCHECK runs this instead.
func healthcheck(ctx context.Context) error {
	addr := os.Getenv("AGNTS_ADDR")
	if addr == "" {
		addr = ":8080"
	}
	if strings.HasPrefix(addr, ":") {
		addr = "127.0.0.1" + addr
	}
	ctx, cancel := context.WithTimeout(ctx, 4*time.Second)
	defer cancel()
	//nolint:gosec // G704: addr is our own AGNTS_ADDR, always a local listener
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, "http://"+addr+"/healthz", nil)
	if err != nil {
		return err
	}
	resp, err := http.DefaultClient.Do(req) //nolint:gosec // G704: see above
	if err != nil {
		return err
	}
	defer func() { _ = resp.Body.Close() }()
	if resp.StatusCode != http.StatusOK {
		return fmt.Errorf("unhealthy: %s", resp.Status)
	}
	return nil
}

func purgeSessions(ctx context.Context, svc *auth.Service, log *slog.Logger) {
	t := time.NewTicker(time.Hour)
	defer t.Stop()
	for {
		if n, err := svc.PurgeExpired(ctx); err != nil && ctx.Err() == nil {
			log.Warn("purge expired sessions", "err", err)
		} else if n > 0 {
			log.Info("purged expired sessions", "count", n)
		}
		select {
		case <-ctx.Done():
			return
		case <-t.C:
		}
	}
}

func createUser(ctx context.Context, svc *auth.Service, ws *postgres.Workspaces, username string, in *os.File, out io.Writer) error {
	reader := bufio.NewReader(in)
	pw, err := readNewPassword(reader, in, out)
	if err != nil {
		return err
	}

	e, err := svc.BeginEnrollment(username)
	if err != nil {
		return err
	}
	_, _ = fmt.Fprintf(out, "\nAdd this account to your authenticator app.\n\n  Secret: %s\n  URL:    %s\n\n", e.Secret, e.URL)
	_, _ = fmt.Fprintln(out, "Tip: paste the URL into a QR generator you trust offline, or type the secret by hand.")

	_, _ = fmt.Fprint(out, "\nEnter the 6-digit code it shows: ")
	code, err := reader.ReadString('\n')
	if err != nil {
		return err
	}
	u, err := svc.CreateUser(ctx, e, pw, strings.TrimSpace(code))
	if err != nil {
		return err
	}
	_, _ = fmt.Fprintf(out, "Created user %q (id %d). You can sign in now.\n", u.Username, u.ID)
	// The first user takes over an install migrated without one; everyone
	// gets a workspace of their own to start in.
	if u.IsAdmin {
		if err := ws.ClaimOwnerless(ctx, u.ID); err != nil {
			return err
		}
	}
	if mine, err := ws.Of(ctx, u.ID); err == nil && len(mine) == 0 {
		w, err := ws.Create(ctx, postgres.NewWorkspace{Name: u.Username + "'s workspace", OwnerID: u.ID, Plan: "self-hosted", Slots: 1})
		if err != nil {
			return err
		}
		_, _ = fmt.Fprintf(out, "Created the workspace %q (address %s).\n", w.Name, w.Slug)
	}
	if u.IsAdmin {
		_, _ = fmt.Fprintln(out, "This is the first user, so it is the platform's Admin.")
	}
	return nil
}

// addUser creates a User who signs in with a password and no two-factor
// code, for an account made on someone's behalf. It joins no workspace:
// agnts workspace create --owner or agnts workspace add does that.
func addUser(ctx context.Context, svc *auth.Service, username string, in *os.File, out io.Writer) error {
	pw, err := readNewPassword(bufio.NewReader(in), in, out)
	if err != nil {
		return err
	}
	u, err := svc.CreatePasswordUser(ctx, username, pw)
	if err != nil {
		return err
	}
	_, _ = fmt.Fprintf(out, "Created user %q (id %d). They sign in with this password.\n", u.Username, u.ID)
	return nil
}

// readNewPassword asks for a password twice, without echo on a terminal.
func readNewPassword(reader *bufio.Reader, in *os.File, out io.Writer) (string, error) {
	readSecret := func(prompt string) (string, error) {
		_, _ = fmt.Fprint(out, prompt)
		if term.IsTerminal(int(in.Fd())) { //nolint:gosec // fd fits in int
			b, err := term.ReadPassword(int(in.Fd())) //nolint:gosec // fd fits in int
			_, _ = fmt.Fprintln(out)
			return string(b), err
		}
		line, err := reader.ReadString('\n')
		return strings.TrimRight(line, "\r\n"), err
	}
	pw, err := readSecret(fmt.Sprintf("Password (at least %d characters): ", auth.MinPasswordLength))
	if err != nil {
		return "", err
	}
	again, err := readSecret("Repeat password: ")
	if err != nil {
		return "", err
	}
	if pw != again {
		return "", errors.New("passwords do not match")
	}
	return pw, nil
}

// egressProxy runs the forward proxy that run containers use to reach the
// Claude API, git hosts and package registries, and nothing else.
func egressProxy(ctx context.Context) error {
	log := logging.New(os.Stdout, "json", "info")
	addr := os.Getenv("AGNTS_EGRESS_ADDR")
	if addr == "" {
		addr = ":3128"
	}
	allow := egress.DefaultAllow
	if v := strings.TrimSpace(os.Getenv("AGNTS_EGRESS_ALLOW")); v != "" {
		allow = strings.Split(v, ",")
	}
	proxy := egress.New(allow, log)
	// Hosts whose service refuses this server's network (Meta's models)
	// go through another proxy.
	if v := strings.TrimSpace(os.Getenv("AGNTS_EGRESS_UPSTREAM")); v != "" {
		up, err := egress.ParseUpstream(v, os.Getenv("AGNTS_EGRESS_UPSTREAM_HOSTS"))
		if err != nil {
			return err
		}
		proxy.SetUpstream(up)
		log.Info("egress proxy: upstream proxy", "via", up.String())
	}
	// Hosts added in Settings (a staging API for previews) come from agnts's
	// internal listener, which Caddy does not route and run containers
	// cannot reach.
	if u := strings.TrimSpace(os.Getenv("AGNTS_EGRESS_EXTRA_URL")); u != "" {
		go proxy.Follow(ctx, u, 30*time.Second)
	}
	// Private networks: a run's connection to a host on its workspace's
	// routes goes through the gateway. agnts says which workspace a run
	// container's address belongs to.
	// The same lookup answers grants: a host one run container alone may
	// reach (a Swagger test's base URL), which needs the secret but no
	// gateway.
	if gw, secret := strings.TrimSpace(os.Getenv("AGNTS_GATEWAY")), strings.TrimSpace(os.Getenv("AGNTS_GATEWAY_SECRET")); secret != "" {
		routeURL := strings.TrimSpace(os.Getenv("AGNTS_EGRESS_ROUTE_URL"))
		if routeURL == "" {
			routeURL = "http://agnts:8081/egress/route"
		}
		var dial egress.GatewayDial
		if gw != "" {
			dial = func(ctx context.Context, p egress.Private, target string) (net.Conn, error) {
				c, _, err := privnet.DialGateway(ctx, gw, secret, privnet.DialRequest{Workspace: p.Workspace, Network: p.Network, Ticket: p.Ticket, Target: target, Source: "run"})
				return c, err
			}
			log.Info("egress proxy: private networks through the gateway", "gateway", gw)
		}
		proxy.SetPrivate(egress.HTTPRouter{URL: routeURL, Secret: secret, Client: &http.Client{Timeout: 5 * time.Second}}, dial)
		log.Info("egress proxy: per-run grants on", "route", routeURL)
	}
	srv := &http.Server{Addr: addr, Handler: proxy, ReadHeaderTimeout: 10 * time.Second}
	go func() {
		<-ctx.Done()
		_ = srv.Close()
	}()
	log.Info("egress proxy listening", "addr", addr, "allow", strings.Join(allow, ","))
	if err := srv.ListenAndServe(); err != nil && !errors.Is(err, http.ErrServerClosed) {
		return err
	}
	return nil
}

// gatewayCmd runs the private network gateway: the tunnels of every
// workspace, a CONNECT listener for agnts and the egress proxy, and the
// listener agnts-link connects to (through Caddy).
func gatewayCmd(ctx context.Context) error {
	log := logging.New(os.Stdout, envOr("AGNTS_LOG_FORMAT", "json"), envOr("AGNTS_LOG_LEVEL", "info"))
	secretVal := strings.TrimSpace(os.Getenv("AGNTS_GATEWAY_SECRET"))
	if len(secretVal) < 24 {
		return errors.New("AGNTS_GATEWAY_SECRET must be set (at least 24 characters, the same as agnts and the egress proxy)")
	}
	key, err := base64.StdEncoding.DecodeString(strings.TrimSpace(os.Getenv("AGNTS_ENC_KEY")))
	if err != nil || len(key) != 32 {
		return errors.New("AGNTS_ENC_KEY must be agnts's key: the gateway opens the VPN configs")
	}
	box, err := secret.NewBox(key)
	if err != nil {
		return err
	}
	g := gateway.New(gateway.Config{
		Secret:   secretVal,
		AgntsURL: strings.TrimRight(envOr("AGNTS_GATEWAY_AGNTS_URL", "http://agnts:8081"), "/"),
		HooksURL: strings.TrimRight(envOr("AGNTS_GATEWAY_HOOKS_URL", "http://agnts:8080"), "/"),
	}, box, log)
	addr, linkAddr := envOr("AGNTS_GATEWAY_ADDR", ":3129"), envOr("AGNTS_GATEWAY_LINK_ADDR", ":3130")
	srv := &http.Server{Addr: addr, Handler: g, ReadHeaderTimeout: 10 * time.Second}
	link := &http.Server{Addr: linkAddr, Handler: g.LinkHandler(), ReadHeaderTimeout: 10 * time.Second}
	go g.Run(ctx)
	go func() {
		<-ctx.Done()
		_ = srv.Close()
		_ = link.Close()
	}()
	errc := make(chan error, 2)
	go func() { errc <- link.ListenAndServe() }()
	go func() { errc <- srv.ListenAndServe() }()
	log.Info("gateway listening", "addr", addr, "link", linkAddr)
	if err := <-errc; err != nil && !errors.Is(err, http.ErrServerClosed) {
		return err
	}
	return nil
}

// ovpnSidecar runs inside a workspace's OpenVPN sidecar container; agnts
// starts it with the config and the SOCKS password in its environment.
func ovpnSidecar(ctx context.Context) error {
	log := logging.New(os.Stdout, "json", envOr("AGNTS_LOG_LEVEL", "info"))
	sec, err := ovpnside.ReadSecret(os.Getenv("AGNTS_OVPN_SECRET"))
	if err != nil {
		return errors.New("AGNTS_OVPN_SECRET is missing or broken: agnts starts this container itself")
	}
	pw := os.Getenv("AGNTS_OVPN_SOCKS_PASSWORD")
	if pw == "" {
		return errors.New("AGNTS_OVPN_SOCKS_PASSWORD is missing")
	}
	_ = os.Unsetenv("AGNTS_OVPN_SECRET")
	_ = os.Unsetenv("AGNTS_OVPN_SOCKS_PASSWORD")
	return ovpnside.New(ovpnside.Config{Secret: sec, SocksPassword: pw, Dir: envOr("AGNTS_OVPN_DIR", "/tmp")}, log).Run(ctx)
}

func envOr(k, def string) string {
	if v := strings.TrimSpace(os.Getenv(k)); v != "" {
		return v
	}
	return def
}
