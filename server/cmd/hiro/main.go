// Command hiro is the hiro server and its admin CLI.
package main

import (
	"bufio"
	"context"
	"crypto/rand"
	"encoding/base64"
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

	"hiro/internal/auth"
	"hiro/internal/config"
	"hiro/internal/egress"
	"hiro/internal/logging"
	"hiro/internal/oauth"
	"hiro/internal/secret"
	"hiro/internal/store/postgres"
)

// Set at build time with -ldflags "-X main.version=... -X main.commit=...".
var (
	version = "dev"
	commit  = "unknown"
)

const usageText = `hiro: autonomous coding agent with human gates

Usage:
  hiro serve                    run the server
  hiro migrate [up|down|status|version]
                                manage the database schema (default: up)
  hiro user create <username>   create the admin user (password + TOTP)
  hiro repo add [flags]         add or update a repository (see hiro repo add -h)
  hiro repo list                list repositories
  hiro integration set <jira|github|claude>
                                connect a service (secrets are read from the terminal)
  hiro jira sync                pick up labelled Jira issues now
  hiro mcp token                create a new static MCP bearer token
  hiro keygen                   print a new HIRO_ENC_KEY
  hiro version                  print the version
  hiro healthcheck              exit 0 if the local server is healthy (for Docker)
  hiro egress-proxy             run the allowlist proxy for run containers (HIRO_EGRESS_ALLOW)

Configuration is read from HIRO_* environment variables; see deploy/.env.example.
`

func main() {
	ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer stop()
	if err := run(ctx, os.Args[1:]); err != nil {
		fmt.Fprintln(os.Stderr, "hiro:", err)
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
		fmt.Printf("hiro %s (%s)\n", version, commit)
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
		return repoCmd(ctx, pool, args[1:], os.Stdout)
	case "integration":
		return integrationCmd(ctx, cfg, pool, args[1:], os.Stdin, os.Stdout)
	case "mcp":
		if len(args) != 2 || args[1] != "token" {
			return errors.New("usage: hiro mcp token")
		}
		tok, err := oauth.New(pool, cfg.PublicURL.String(), cfg.MCPRedirectHosts, log).RotateStatic(ctx)
		if err != nil {
			return err
		}
		fmt.Printf("New MCP token (shown once; the previous one stops working):\n\n  %s\n\nUse it as `Authorization: Bearer <token>` for %s/mcp\n", tok, strings.TrimRight(cfg.PublicURL.String(), "/"))
		return nil
	case "jira":
		if len(args) != 2 || args[1] != "sync" {
			return errors.New("usage: hiro jira sync")
		}
		return jiraSync(ctx, cfg, pool, log)
	case "user":
		if len(args) != 3 || args[1] != "create" {
			return errors.New("usage: hiro user create <username>")
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
	addr := os.Getenv("HIRO_ADDR")
	if addr == "" {
		addr = ":8080"
	}
	if strings.HasPrefix(addr, ":") {
		addr = "127.0.0.1" + addr
	}
	ctx, cancel := context.WithTimeout(ctx, 4*time.Second)
	defer cancel()
	//nolint:gosec // G704: addr is our own HIRO_ADDR, always a local listener
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
	addr := os.Getenv("HIRO_EGRESS_ADDR")
	if addr == "" {
		addr = ":3128"
	}
	allow := egress.DefaultAllow
	if v := strings.TrimSpace(os.Getenv("HIRO_EGRESS_ALLOW")); v != "" {
		allow = strings.Split(v, ",")
	}
	srv := &http.Server{Addr: addr, Handler: egress.New(allow, log), ReadHeaderTimeout: 10 * time.Second}
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
