package main

import (
	"bufio"
	"context"
	"crypto/rand"
	"encoding/hex"
	"errors"
	"flag"
	"fmt"
	"io"
	"net/url"
	"os"
	"path/filepath"
	"slices"
	"strings"
	"text/tabwriter"

	"golang.org/x/term"

	"agnts/internal/admin"
	"agnts/internal/config"
	"agnts/internal/domain"
	"agnts/internal/secret"
	"agnts/internal/store/postgres"
	"agnts/internal/toolchain"
	"agnts/internal/tracker/jira"
	"agnts/internal/tracker/plane"
	"agnts/internal/vcs/github"
	"agnts/internal/vcs/gitrepo"
)

// Phase 1 manages repositories and integrations from the CLI; the admin
// pages for both arrive in phase 2.

// toolchainFlags collects repeated --toolchain tool@version flags.
type toolchainFlags []domain.Toolchain

func (f *toolchainFlags) String() string { return domain.StackOf(*f) }

func (f *toolchainFlags) Set(v string) error {
	t, err := domain.ParseToolchain(v)
	if err != nil {
		return err
	}
	*f = append(*f, t)
	return nil
}

// cliDetect clones (or fetches) a repository's default branch into the
// data dir, as the server does, and detects its toolchains.
func cliDetect(ctx context.Context, cfg config.Config, pool postgresPool, r domain.Repository) (toolchain.Detection, error) {
	box, err := secret.NewBox(cfg.EncKey)
	if err != nil {
		return toolchain.Detection{}, err
	}
	integ := postgres.NewIntegrations(pool, box)
	git := gitrepo.New(filepath.Join(cfg.DataDir, "repos"),
		func(ctx context.Context, provider string) (string, error) { return integ.Token(ctx, provider) },
		func(context.Context) (gitrepo.Author, error) { return gitrepo.Author{}, errors.New("not committing") })
	return repoDetector{git}.Detect(ctx, r)
}

func printDetection(out io.Writer, det toolchain.Detection) {
	_, _ = fmt.Fprintf(out, "Toolchains: %s\n", orNone(det.Toolchains))
	for _, c := range []struct{ name, cmd string }{{"Build", det.Build}, {"Lint", det.Lint}, {"Test", det.Test}} {
		if c.cmd != "" {
			_, _ = fmt.Fprintf(out, "%s: %s\n", c.name, c.cmd)
		}
	}
	for _, n := range det.Notes {
		_, _ = fmt.Fprintf(out, "Note: %s\n", n)
	}
}

func orNone(ts []domain.Toolchain) string {
	if len(ts) == 0 {
		return "none found"
	}
	parts := make([]string, len(ts))
	for i, t := range ts {
		parts[i] = t.Spec()
	}
	return strings.Join(parts, ", ")
}

func repoCmd(ctx context.Context, cfg config.Config, pool postgresPool, args []string, out io.Writer) error {
	store := postgres.NewAgent(pool)
	if len(args) == 0 {
		return errors.New("usage: agnts repo add|list|detect")
	}
	switch args[0] {
	case "detect":
		if len(args) != 2 {
			return errors.New("usage: agnts repo detect <name>")
		}
		repos, err := store.ListRepositories(ctx)
		if err != nil {
			return err
		}
		i := slices.IndexFunc(repos, func(r domain.Repository) bool { return r.Name == args[1] })
		if i < 0 {
			return fmt.Errorf("no repository named %q", args[1])
		}
		det, err := cliDetect(ctx, cfg, pool, repos[i])
		if err != nil {
			return err
		}
		printDetection(out, det)
		saved, err := store.SetDetectedToolchains(ctx, repos[i].ID, det.Toolchains, det.Notes, det.Build, det.Lint, det.Test)
		if err != nil {
			return err
		}
		if saved.ToolchainsOverride {
			_, _ = fmt.Fprintf(out, "Toolchains were set by hand and are kept: %s\n", orNone(saved.Toolchains))
		}
		_, _ = fmt.Fprintln(out, "Saved. Check commands are only filled in when the repository has none.")
		return nil
	case "list":
		repos, err := store.ListRepositories(ctx)
		if err != nil {
			return err
		}
		tw := tabwriter.NewWriter(out, 0, 4, 2, ' ', 0)
		_, _ = fmt.Fprintln(tw, "NAME\tKIND\tJIRA\tPLANE\tBRANCH\tTOOLCHAINS\tURL")
		for _, r := range repos {
			_, _ = fmt.Fprintf(tw, "%s\t%s\t%s\t%s\t%s\t%s\t%s\n", r.Name, r.Kind, r.JiraProject, r.PlaneProject, r.DefaultBranch, orNone(r.Toolchains), r.CloneURL)
		}
		return tw.Flush()
	case "add":
		fs := flag.NewFlagSet("repo add", flag.ContinueOnError)
		fs.SetOutput(out)
		r := domain.Repository{Provider: "github"}
		fs.StringVar(&r.Name, "name", "", "short name (required)")
		fs.StringVar(&r.CloneURL, "url", "", "https clone URL, e.g. https://github.com/acme/api.git (required)")
		fs.StringVar(&r.DefaultBranch, "branch", "main", "default branch PRs target")
		fs.String("kind", "", "deprecated: ignored, set by --jira and --plane")
		fs.StringVar(&r.JiraProject, "jira", "", "Jira project key whose tickets go to this repo, e.g. PAY")
		fs.StringVar(&r.PlaneProject, "plane", "", "Plane project identifier whose work items go to this repo, e.g. WEB")
		fs.StringVar(&r.BuildCmd, "build", "", "build command, run in the repo root")
		fs.StringVar(&r.LintCmd, "lint", "", "lint command")
		fs.StringVar(&r.TestCmd, "test", "", "test command")
		fs.StringVar(&r.BranchPrefix, "prefix", "agnts/", "branch prefix")
		claudeMD := fs.String("instructions", "", "file with extra instructions for Claude (optional)")
		var tcs toolchainFlags
		fs.Var(&tcs, "toolchain", "tool@version installed in runs, e.g. node@20 (repeatable; detected from the repository when absent)")
		noDetect := fs.Bool("no-detect", false, "do not clone the repository to detect toolchains and check commands now")
		if err := fs.Parse(args[1:]); err != nil {
			return err
		}
		r.Toolchains, r.ToolchainsOverride = tcs, len(tcs) > 0
		if r.Name == "" || r.CloneURL == "" {
			fs.Usage()
			return errors.New("--name and --url are required")
		}
		r.JiraProject = strings.ToUpper(strings.TrimSpace(r.JiraProject))
		r.PlaneProject = strings.ToUpper(strings.TrimSpace(r.PlaneProject))
		if r.PlaneProject != "" && r.PlaneProject == r.JiraProject {
			return errors.New("--jira and --plane must differ: both would number tickets " + r.PlaneProject + "-1, " + r.PlaneProject + "-2, …")
		}
		r.Kind = admin.RepoKind(r.JiraProject, r.PlaneProject)
		if u, err := url.Parse(r.CloneURL); err != nil || u.Scheme != "https" {
			return errors.New("--url must be an https clone URL (agnts authenticates with a token, not SSH keys)")
		}
		if _, _, err := github.OwnerRepo(r.CloneURL); err != nil {
			return fmt.Errorf("%w (GitLab arrives in phase 5)", err)
		}
		if *claudeMD != "" {
			b, err := os.ReadFile(*claudeMD)
			if err != nil {
				return err
			}
			r.ClaudeMD = string(b)
		}
		saved, err := store.SaveRepository(ctx, r)
		if err != nil {
			return err
		}
		_, _ = fmt.Fprintf(out, "Saved repository %q (id %d).\n", saved.Name, saved.ID)
		if *noDetect {
			_, _ = fmt.Fprintln(out, "Toolchains and missing check commands are detected on the first run.")
			return nil
		}
		det, err := cliDetect(ctx, cfg, pool, saved)
		if err != nil {
			_, _ = fmt.Fprintf(out, "Could not read the repository to detect toolchains (%v); the first run tries again.\n", err)
			return nil
		}
		printDetection(out, det)
		if saved, err = store.SetDetectedToolchains(ctx, saved.ID, det.Toolchains, det.Notes, det.Build, det.Lint, det.Test); err != nil {
			return err
		}
		_, _ = fmt.Fprintf(out, "Runs install: %s\n", orNone(saved.Toolchains))
		return nil
	default:
		return fmt.Errorf("unknown repo command %q", args[0])
	}
}

func integrationCmd(ctx context.Context, cfg config.Config, pool postgresPool, args []string, in *os.File, out io.Writer) error {
	if len(args) != 2 || args[0] != "set" {
		return errors.New("usage: agnts integration set jira|plane|github|claude")
	}
	box, err := secret.NewBox(cfg.EncKey)
	if err != nil {
		return err
	}
	store := postgres.NewIntegrations(pool, box)
	p := &prompter{in: in, r: bufio.NewReader(in), out: out}
	hookURL := func(provider string) string {
		u := strings.TrimRight(cfg.PublicURL.String(), "/") + "/webhooks/" + provider
		if w, err := postgres.NewWorkspaces(pool).ByID(domain.System(ctx), domain.WorkspaceOf(ctx)); err == nil {
			u += "/" + w.HookID
		}
		return u
	}

	switch args[1] {
	case "claude":
		_, _ = fmt.Fprintln(out, "Run `claude setup-token` on a machine where you are signed in to your Claude plan and paste the token.")
		tok, err := p.secret("Token: ")
		if err != nil {
			return err
		}
		if !strings.HasPrefix(tok, "sk-ant-") {
			return errors.New("that does not look like a Claude OAuth token (expected sk-ant-...)")
		}
		ws, err := domain.MustWorkspace(ctx)
		if err != nil {
			return err
		}
		kind := postgres.ClaudeSubscription
		if strings.HasPrefix(tok, "sk-ant-api") {
			kind = postgres.ClaudeAPIKey
		}
		_, err = postgres.NewClaudeConnections(pool, box).Put(ctx, ws, 0, kind, tok, map[string]string{
			postgres.ClaudeSubscription: "Claude subscription", postgres.ClaudeAPIKey: "Anthropic API key"}[kind])
		return p.done(err, "Claude (the workspace's shared account)")

	case "github":
		_, _ = fmt.Fprintln(out, "Create a fine-grained token with Contents and Pull requests: read and write, for the repositories agnts works on.")
		tok, err := p.secret("Token: ")
		if err != nil {
			return err
		}
		return p.done(store.Put(ctx, postgres.Integration{Provider: "github", Token: tok, Settings: map[string]string{}}), "GitHub")

	case "jira":
		site, err := p.line("Site URL (https://your-team.atlassian.net): ", "")
		if err != nil {
			return err
		}
		if u, err := url.Parse(site); err != nil || u.Scheme != "https" || u.Host == "" {
			return errors.New("site must be an https URL")
		}
		email, err := p.line("Account email: ", "")
		if err != nil {
			return err
		}
		apiToken, err := p.secret("API token (id.atlassian.com → Security → API tokens): ")
		if err != nil {
			return err
		}
		label, err := p.line("Label agnts picks up [agnts]: ", "agnts")
		if err != nil {
			return err
		}
		started, err := p.line("Status to move issues to when agnts starts (empty: don't move): ", "")
		if err != nil {
			return err
		}
		review, err := p.line("Status when ready for review (empty: don't move): ", "")
		if err != nil {
			return err
		}
		whSecret := make([]byte, 24)
		_, _ = rand.Read(whSecret)
		jc := jira.Config{
			Site: strings.TrimRight(site, "/"), Email: email, APIToken: apiToken, Label: label,
			WebhookSecret: hex.EncodeToString(whSecret),
			Statuses:      map[string]string{"started": started, "in_review": review},
		}
		enc, err := encodeJiraConfig(jc)
		if err != nil {
			return err
		}
		if err := p.done(store.Put(ctx, enc), "Jira"); err != nil {
			return err
		}
		_, _ = fmt.Fprintf(out, "\nIn Jira, go to Settings → System → WebHooks → Create:\n  URL:    %s\n  Secret: %s\n  Events: Issue created, Issue updated\n  JQL:    labels = %q\n",
			hookURL("jira"), jc.WebhookSecret, jc.Label)
		return nil
	case "plane":
		base, err := p.line("Plane API URL [https://api.plane.so] (self-hosted: your Plane's address): ", plane.DefaultBaseURL)
		if err != nil {
			return err
		}
		workspace, err := p.line("Workspace slug (acme in app.plane.so/acme): ", "")
		if err != nil {
			return err
		}
		key, err := p.secret("API key (Profile settings → Personal access tokens): ")
		if err != nil {
			return err
		}
		label, err := p.line("Label agnts picks up [agnts]: ", "agnts")
		if err != nil {
			return err
		}
		settings := map[string]string{"base_url": strings.TrimRight(base, "/"), "workspace": workspace, "label": label}
		account, err := admin.PlaneCheck(ctx, key, settings)
		if err != nil {
			return fmt.Errorf("plane rejected the key: %w", err)
		}
		hook := hookURL("plane")
		_, _ = fmt.Fprintf(out, "Connected as %s.\n\nIn Plane, go to Workspace settings → Webhooks → Add webhook:\n  URL:    %s\n  Events: Work items (Issues)\nPlane then shows a secret once.\n", account, hook)
		whSecret, err := p.secret("Webhook secret from Plane (empty: add it later on the Integrations page): ")
		if err != nil {
			return err
		}
		if err := p.done(store.Put(ctx, postgres.Integration{Provider: "plane", Token: plane.SecretsToken(key, whSecret),
			Settings: settings, Account: account}), "Plane"); err != nil {
			return err
		}
		_, _ = fmt.Fprintln(out, "Link a repository with `agnts repo add ... --plane WEB`, then label a work item agnts.")
		return nil
	default:
		return fmt.Errorf("unknown integration %q", args[1])
	}
}

func encodeJiraConfig(c jira.Config) (postgres.Integration, error) {
	return postgres.Integration{Provider: "jira", Token: jira.SecretsToken(c.APIToken, c.WebhookSecret), Settings: map[string]string{
		"site": c.Site, "email": c.Email, "label": c.Label,
		"status_started": c.Statuses["started"], "status_in_review": c.Statuses["in_review"],
	}}, nil
}

type prompter struct {
	in  *os.File
	r   *bufio.Reader
	out io.Writer
}

func (p *prompter) line(prompt, def string) (string, error) {
	_, _ = fmt.Fprint(p.out, prompt)
	s, err := p.r.ReadString('\n')
	if err != nil && !errors.Is(err, io.EOF) {
		return "", err
	}
	if s = strings.TrimSpace(s); s == "" {
		s = def
	}
	return s, nil
}

func (p *prompter) secret(prompt string) (string, error) {
	_, _ = fmt.Fprint(p.out, prompt)
	if term.IsTerminal(int(p.in.Fd())) { //nolint:gosec // fd fits in int
		b, err := term.ReadPassword(int(p.in.Fd())) //nolint:gosec // fd fits in int
		_, _ = fmt.Fprintln(p.out)
		if err != nil {
			return "", err
		}
		if s := strings.TrimSpace(string(b)); s != "" {
			return s, nil
		}
		return "", errors.New("empty value")
	}
	s, err := p.line("", "")
	if err == nil && s == "" {
		err = errors.New("empty value")
	}
	return s, err
}

func (p *prompter) done(err error, name string) error {
	if err == nil {
		_, _ = fmt.Fprintf(p.out, "%s connected. The token is stored encrypted.\n", name)
	}
	return err
}
