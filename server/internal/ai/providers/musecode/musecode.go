// Package musecode runs Muse Code (Meta) for the AI gateway. agnts-muse
// drives it over MSP (`muse serve`) inside the run container: it meters
// every model call as it happens, keeps a run on credits inside its budget
// (holding, steering, interrupting), escalates a stuck Spark session to
// Wonder and decides tool approvals with agnts's guard rules. This
// package adapts it to the gateway's contract, so the ticket log,
// transcripts, stall detection and spend work as they do for Claude Code.
// Muse also hears audio: meeting notes and spoken questions.
package musecode

import (
	"context"
	"errors"
	"fmt"
	"io"
	"regexp"
	"slices"
	"strings"
	"sync"
	"time"

	muse "github.com/rustambekabdusalomov/agnts-muse"
	"github.com/rustambekabdusalomov/agnts-muse/credential"
	"github.com/rustambekabdusalomov/agnts-muse/guard"
	"github.com/rustambekabdusalomov/agnts-muse/model"

	"agnts/internal/ai"
	"agnts/internal/domain"
)

// Environment names of Muse credentials.
const (
	// EnvKey carries a Meta Model API key.
	EnvKey = credential.EnvAPIKey
	// EnvLogin carries a Meta sign-in: Muse Code's credential file.
	EnvLogin = "MUSE_LOGIN"
)

// museHome keeps Muse Code's data (sessions) and credential file inside
// Claude Code's config dir, which agnts saves between a ticket's runs, so
// a later run can resume the session.
const (
	museHome = ai.ClaudeHome + "/muse"
	// authPath is the only place Muse Code reads its login from: the
	// agent's own ~/.config/muse (it ignores MUSE_AUTH_PATH, which only its
	// installer's launcher reads, and $HOME).
	authPath = ai.HomeDir + "/.config/muse/auth.json"
	// fileCredentials makes Muse keep its login in a file (its default
	// backend is the system keychain, which a container has none of), so
	// it reads the file it is given and writes a refreshed token back.
	fileCredentials = "TBH_CREDENTIAL_BACKEND=file" //nolint:gosec // a setting, not a credential
)

// Budgets decides what a Muse run on agnts's key may spend. It returns
// nil when the run is on the person's own Muse account (Meta bills them).
type Budgets interface {
	Budget(ctx context.Context, acct ai.Account, req ai.Request) (*muse.Budget, error)
}

// Config sets up Muse Code.
type Config struct {
	Engine *muse.Engine
	// Budgets limits runs on credits; nil enforces no budget in the run
	// (spend is still metered and settled afterwards).
	Budgets Budgets
	// KeepLogin saves a Meta sign-in Muse refreshed while it ran on acct;
	// nil drops it.
	KeepLogin func(ctx context.Context, acct ai.Account, file []byte) error
	// Boxes and Image open the throwaway containers audio is heard in;
	// nil Boxes: Muse does not hear audio here.
	Boxes ai.Boxes
	Image string
}

// Provider is Muse Code.
type Provider struct{ cfg Config }

var (
	_ ai.Provider = (*Provider)(nil)
	_ ai.Hearer   = (*Provider)(nil)
)

// New returns Muse Code.
func New(cfg Config) *Provider { return &Provider{cfg: cfg} }

func (p *Provider) ID() string        { return ai.Muse }
func (p *Provider) Name() string      { return "Muse" }
func (p *Provider) FreeCredits() bool { return true }

// Caps implements ai.Provider.
func (p *Provider) Caps() ai.Caps {
	c := ai.Caps{ai.CapEffort, ai.CapResume, ai.CapSteer, ai.CapAsk}
	if p.cfg.Boxes != nil {
		c = append(c, ai.CapAudio)
	}
	return c
}

// Catalog implements ai.Provider.
func (p *Provider) Catalog() ai.Catalog { return catalog{} }

// modelName matches a Muse model's name or id.
var modelName = regexp.MustCompile(`^[a-z0-9][a-z0-9._-]{0,63}$`)

type catalog struct{}

func (catalog) Valid(name string) bool { return modelName.MatchString(name) }
func (catalog) Listed() []string       { return []string{domain.MuseSpark, domain.MuseWonder} }
func (catalog) Model(t ai.Tier) string {
	if t == ai.Strong {
		return domain.MuseWonder
	}
	return domain.MuseSpark
}
func (catalog) TierOf(name string) ai.Tier {
	if name == "wonder" || strings.HasPrefix(name, "muse-wonder") {
		return ai.Strong
	}
	return ai.Light
}

// museModel resolves "muse:spark" or "muse:muse-spark-1.3" to a Muse id.
func museModel(name string) model.ID {
	name = strings.TrimPrefix(name, ai.MusePrefix)
	if m, err := model.Default.Resolve(name); err == nil {
		return m.ID
	}
	return model.ID(name)
}

// museCredential turns the gateway's credential into Muse's.
func museCredential(c ai.Credential) (credential.Credential, error) {
	switch {
	case c.Token == "":
		return credential.Credential{}, errors.New("muse is not connected: connect your Meta account in Workspace settings → AI accounts")
	case c.Env == EnvLogin:
		return credential.LoginFile([]byte(c.Token), "")
	case c.Env == EnvKey:
		return credential.APIKey(c.Token)
	}
	return credential.Credential{}, fmt.Errorf("this account is not a Muse account (%s); connect Muse in Workspace settings", c.Env)
}

// Exec implements ai.Provider: one Muse run over MSP.
func (p *Provider) Exec(ctx context.Context, box ai.Box, c ai.Credential, req ai.Request, onEvent func(ai.Event)) (ai.Result, error) {
	if p.cfg.Engine == nil {
		return ai.Result{}, errors.New("muse is not available on this server")
	}
	cred, err := museCredential(c)
	if err != nil {
		return ai.Result{}, err
	}
	var b *muse.Budget
	if p.cfg.Budgets != nil {
		if b, err = p.cfg.Budgets.Budget(ctx, c.Account, req); err != nil {
			return ai.Result{}, fmt.Errorf("muse budget: %w", err)
		}
	}
	g := guard.Policy(guard.Defaults())
	if req.ReadOnly {
		// Read-only for the code, but its result goes to /agnts/out
		// (analysis.json, review.json), which agnts reads back.
		g = guard.Chain{guard.Defaults(), guard.ReadOnlyExcept(ai.OutDir)}
	}
	var ask func(muse.Approval) <-chan bool
	if req.Ask != nil {
		// Someone follows the run in a chat: adding a dependency waits for
		// their answer instead of going ahead.
		g = guard.Chain{g, guard.AskBeforeInstalls()}
		ask = func(a muse.Approval) <-chan bool {
			return req.Ask(ai.ToolQuestion{Tool: museTool(a.Tool), Command: a.Command, Path: a.Path, Reason: a.Reason})
		}
	}
	if req.Timeout > 0 {
		var cancel context.CancelFunc
		ctx, cancel = context.WithTimeout(ctx, req.Timeout)
		defer cancel()
	}
	id := museModel(req.Model)
	onEvent = ai.MaskEvents(domain.NewSecretRedactor(append(cred.Secrets(), ai.EnvValues(req.Env)...)...), onEvent)
	limit := 0.0
	if b != nil {
		limit = b.Limit.Float()
	}
	res, err := p.cfg.Engine.Run(ctx, muse.Request{
		Prompt: req.Prompt, Workdir: ai.WorkDir, Model: id, Effort: req.Effort, SessionID: req.Resume,
		Budget: b, AnnounceBudget: b != nil && b.Limit > 0, Credential: &cred, AuthPath: authPath,
		Env: req.Env, Guard: g, MaxCalls: req.MaxTurns, ExtraRoots: []string{ai.OutDir}, Steer: req.Steer, Ask: ask,
	}, &boxExecutor{box: box, keep: p.cfg.KeepLogin, acct: c.Account, ctx: ctx}, func(e muse.Event) { museEvent(e, limit, onEvent) })
	out := ai.Result{
		SessionID: res.SessionID, Turns: res.Usage.Calls, Text: res.Text, Duration: res.Duration,
		Model: ai.MusePrefix + string(res.Model),
		Usage: domain.TokenUsage{Input: res.Usage.Usage.Input - res.Usage.Usage.Cached, CacheRead: res.Usage.Usage.Cached,
			Output: res.Usage.Usage.Output, CostUSD: res.Cost().Float()},
	}
	if res.Model == "" {
		out.Model = ai.MusePrefix + string(id)
	}
	var rl *muse.RateLimitError
	switch {
	case err == nil:
		out.Subtype = "success"
	case errors.As(err, &rl):
		out.RateLimited, out.IsError, out.Subtype = true, true, "rate_limited"
		onEvent(ai.Event{Kind: ai.EventRateLimit, Data: map[string]any{
			"type": "rate_limit_event", "rate_limit_info": map[string]any{"status": "rejected", "resetsAt": float64(rl.Until.Unix())}}})
		return out, nil
	case errors.Is(err, muse.ErrStepLimit):
		out.IsError, out.Subtype = true, "error_max_turns"
		return out, nil
	case errors.Is(err, muse.ErrRunLimit), errors.Is(err, muse.ErrBudget):
		out.IsError, out.Subtype = true, "error_budget"
		return out, fmt.Errorf("stopped inside its credit budget: %w", err)
	case errors.Is(err, context.DeadlineExceeded):
		return out, fmt.Errorf("muse timed out after %s", req.Timeout)
	}
	if err != nil {
		var oom *ai.OOMError
		if errors.As(err, &oom) {
			return out, oom
		}
		return out, fmt.Errorf("muse: %w", err)
	}
	return out, nil
}

// boxExecutor runs `muse serve` in the box.
type boxExecutor struct {
	box  ai.Box
	keep func(ctx context.Context, acct ai.Account, file []byte) error
	acct ai.Account      // whose refreshed login is kept
	ctx  context.Context // the run's
}

// Start implements muse.Executor.
func (d *boxExecutor) Start(ctx context.Context, cmd muse.Command) (muse.Process, error) {
	for _, f := range cmd.Files {
		if err := d.box.WriteFile(ctx, f.Path, f.Data); err != nil {
			return nil, fmt.Errorf("muse credential file: %w", err)
		}
	}
	var stderr ai.TailBuffer
	a, err := d.box.Attach(ctx, ai.Cmd{
		Argv: append([]string{"sh", "-c", `mkdir -p "$XDG_DATA_HOME" && exec "$@"`, "muse", cmd.Path}, cmd.Args...),
		Env: append([]string{"XDG_DATA_HOME=" + museHome + "/data", "XDG_STATE_HOME=" + museHome + "/state",
			"MUSE_UPDATE_INTERVAL_SECONDS=31536000", "NO_COLOR=1", fileCredentials}, cmd.Env...),
	}, &stderr)
	if err != nil {
		return nil, err
	}
	return &museProcess{p: a, box: d.box, keep: d.keep, acct: d.acct, files: cmd.Files, stderr: &stderr, ctx: d.ctx}, nil
}

type museProcess struct {
	p      ai.Process
	box    ai.Box
	keep   func(ctx context.Context, acct ai.Account, file []byte) error
	acct   ai.Account
	files  []credential.File
	stderr *ai.TailBuffer
	ctx    context.Context

	once sync.Once
	err  error
}

func (p *museProcess) Read(b []byte) (int, error)  { return p.p.Read(b) }
func (p *museProcess) Write(b []byte) (int, error) { return p.p.Write(b) }
func (p *museProcess) Close() error                { return p.p.Close() }
func (p *museProcess) Kill() error                 { return p.p.Kill() }

// Wait waits for `muse serve` to exit and removes the credential file.
func (p *museProcess) Wait() error {
	p.once.Do(func() {
		ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
		defer cancel()
		code, err := p.p.Wait(ctx)
		keepLogin(ctx, p.ctx, p.box, p.keep, p.acct, p.files)
		for _, f := range p.files {
			_, _ = p.box.Run(ctx, ai.Cmd{Argv: []string{"rm", "-f", f.Path}}, io.Discard, io.Discard)
		}
		switch {
		case err != nil:
			p.err = err
		case code == 127:
			p.err = errors.New("muse is not installed in the runner image: build it with --build-arg MUSE_VERSION=<version>")
		case code == 137:
			if oom := p.box.OOM(ctx, code); oom != nil {
				p.err = oom
			}
		case code != 0:
			p.err = fmt.Errorf("muse exited %d: %s", code, p.stderr.String())
		}
	})
	return p.err
}

// keepLogin saves the credential file back when Muse refreshed it while
// it ran (it rewrites the file it was given), for acct. runCtx is the
// run's.
func keepLogin(ctx, runCtx context.Context, box ai.Box, keep func(ctx context.Context, acct ai.Account, file []byte) error, acct ai.Account, files []credential.File) {
	if keep == nil || runCtx == nil {
		return
	}
	for _, f := range files {
		if f.Path != authPath {
			continue
		}
		now, err := box.ReadFile(ctx, f.Path)
		if err != nil || len(now) == 0 || slices.Equal(now, f.Data) {
			return
		}
		_ = keep(context.WithoutCancel(runCtx), acct, now)
	}
}
