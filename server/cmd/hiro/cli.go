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
	"strings"
	"text/tabwriter"

	"golang.org/x/term"

	"hiro/internal/admin"
	"hiro/internal/config"
	"hiro/internal/domain"
	"hiro/internal/secret"
	"hiro/internal/store/postgres"
	"hiro/internal/tracker/jira"
	"hiro/internal/vcs/github"
)

// Phase 1 manages repositories and integrations from the CLI; the admin
// pages for both arrive in phase 2.

func repoCmd(ctx context.Context, pool postgresPool, args []string, out io.Writer) error {
	store := postgres.NewAgent(pool)
	if len(args) == 0 {
		return errors.New("usage: hiro repo add|list")
	}
	switch args[0] {
	case "list":
		repos, err := store.ListRepositories(ctx)
		if err != nil {
			return err
		}
		tw := tabwriter.NewWriter(out, 0, 4, 2, ' ', 0)
		_, _ = fmt.Fprintln(tw, "NAME\tKIND\tJIRA\tBRANCH\tURL")
		for _, r := range repos {
			_, _ = fmt.Fprintf(tw, "%s\t%s\t%s\t%s\t%s\n", r.Name, r.Kind, r.JiraProject, r.DefaultBranch, r.CloneURL)
		}
		return tw.Flush()
	case "add":
		fs := flag.NewFlagSet("repo add", flag.ContinueOnError)
		fs.SetOutput(out)
		r := domain.Repository{Provider: "github"}
		fs.StringVar(&r.Name, "name", "", "short name (required)")
		fs.StringVar(&r.CloneURL, "url", "", "https clone URL, e.g. https://github.com/acme/api.git (required)")
		fs.StringVar(&r.DefaultBranch, "branch", "main", "default branch PRs target")
		fs.String("kind", "", "deprecated: ignored, set by --jira")
		fs.StringVar(&r.JiraProject, "jira", "", "Jira project key whose tickets go to this repo, e.g. PAY")
		fs.StringVar(&r.BuildCmd, "build", "", "build command, run in the repo root")
		fs.StringVar(&r.LintCmd, "lint", "", "lint command")
		fs.StringVar(&r.TestCmd, "test", "", "test command")
		fs.StringVar(&r.BranchPrefix, "prefix", "hiro/", "branch prefix")
		claudeMD := fs.String("instructions", "", "file with extra instructions for Claude (optional)")
		if err := fs.Parse(args[1:]); err != nil {
			return err
		}
		if r.Name == "" || r.CloneURL == "" {
			fs.Usage()
			return errors.New("--name and --url are required")
		}
		r.JiraProject = strings.ToUpper(strings.TrimSpace(r.JiraProject))
		r.Kind = admin.RepoKind(r.JiraProject)
		if u, err := url.Parse(r.CloneURL); err != nil || u.Scheme != "https" {
			return errors.New("--url must be an https clone URL (hiro authenticates with a token, not SSH keys)")
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
		return nil
	default:
		return fmt.Errorf("unknown repo command %q", args[0])
	}
}

func integrationCmd(ctx context.Context, cfg config.Config, pool postgresPool, args []string, in *os.File, out io.Writer) error {
	if len(args) != 2 || args[0] != "set" {
		return errors.New("usage: hiro integration set jira|github|claude")
	}
	box, err := secret.NewBox(cfg.EncKey)
	if err != nil {
		return err
	}
	store := postgres.NewIntegrations(pool, box)
	p := &prompter{in: in, r: bufio.NewReader(in), out: out}

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
		return p.done(store.Put(ctx, postgres.Integration{Provider: "claude", Token: tok, Settings: map[string]string{}}), "Claude")

	case "github":
		_, _ = fmt.Fprintln(out, "Create a fine-grained token with Contents and Pull requests: read and write, for the repositories hiro works on.")
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
		label, err := p.line("Label hiro picks up [hiro]: ", "hiro")
		if err != nil {
			return err
		}
		started, err := p.line("Status to move issues to when hiro starts (empty: don't move): ", "")
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
		_, _ = fmt.Fprintf(out, "\nIn Jira, go to Settings → System → WebHooks → Create:\n  URL:    %s/webhooks/jira\n  Secret: %s\n  Events: Issue created, Issue updated\n  JQL:    labels = %q\n",
			strings.TrimRight(cfg.PublicURL.String(), "/"), jc.WebhookSecret, jc.Label)
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
