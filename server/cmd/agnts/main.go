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
	"agnts/internal/egress"
	"agnts/internal/logging"
	"agnts/internal/oauth"
	"agnts/internal/secret"
	"agnts/internal/store/postgres"
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
  agnts user create <username>   create the admin user (password + TOTP)
  agnts repo add [flags]         add or update a repository (see agnts repo add -h)
  agnts repo list                list repositories
  agnts integration set <jira|plane|github|claude>
                                connect a service (secrets are read from the terminal)
  agnts jira sync                pick up labelled Jira issues now
  agnts plane sync               pick up labelled Plane work items now
  agnts eval relations           score the queue's predictions (footprints, conflicts) against the real diffs
  agnts mcp token                create a new static MCP bearer token
  agnts keygen                   print a new AGNTS_ENC_KEY
  agnts version [--json]         print the version
  agnts healthcheck              exit 0 if the local server is healthy (for Docker)
  agnts egress-proxy             run the allowlist proxy for run containers (AGNTS_EGRESS_ALLOW)

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
	case "serve":
		return serve(ctx, cfg, log, pool)
	case "migrate":
		cmd := "up"
		if len(args) > 1 {
			cmd = args[1]
		}
		return postgres.Migrate(ctx, pool, postgres.MigrateCommand(cmd), log)
	case "repo":
		return repoCmd(ctx, cfg, pool, args[1:], os.Stdout)
	case "integration":
		return integrationCmd(ctx, cfg, pool, args[1:], os.Stdin, os.Stdout)
	case "mcp":
		if len(args) != 2 || args[1] != "token" {
			return errors.New("usage: agnts mcp token")
		}
		tok, err := oauth.New(pool, cfg.PublicURL.String(), cfg.MCPRedirectHosts, log).RotateStatic(ctx)
		if err != nil {
			return err
		}
		fmt.Printf("New MCP token (shown once; the previous one stops working):\n\n  %s\n\nUse it as `Authorization: Bearer <token>` for %s/mcp\n", tok, strings.TrimRight(cfg.PublicURL.String(), "/"))
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
		if len(args) != 2 || args[1] != "relations" {
			return errors.New("usage: agnts eval relations")
		}
		return evalRelations(ctx, pool, os.Stdout)
	case "user":
		if len(args) != 3 || args[1] != "create" {
			return errors.New("usage: agnts user create <username>")
		}
		svc, err := newAuth(cfg, pool)
		if err != nil {
			return err
		}
		return createUser(ctx, svc, args[2], os.Stdin, os.Stdout)
	default:
		return fmt.Errorf("unknown command %q\n\n%s", args[0], usageText)
	}
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

func createUser(ctx context.Context, svc *auth.Service, username string, in *os.File, out io.Writer) error {
	reader := bufio.NewReader(in)
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
		return err
	}
	again, err := readSecret("Repeat password: ")
	if err != nil {
		return err
	}
	if pw != again {
		return errors.New("passwords do not match")
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
	return nil
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
	// Hosts added in Settings (a staging API for previews) come from agnts's
	// internal listener, which Caddy does not route and run containers
	// cannot reach.
	if u := strings.TrimSpace(os.Getenv("AGNTS_EGRESS_EXTRA_URL")); u != "" {
		go proxy.Follow(ctx, u, 30*time.Second)
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
