package runner

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"strings"
	"sync"
	"time"

	muse "github.com/rustambekabdusalomov/agnts-muse"
	"github.com/rustambekabdusalomov/agnts-muse/credential"
	"github.com/rustambekabdusalomov/agnts-muse/guard"
	"github.com/rustambekabdusalomov/agnts-muse/model"

	"agnts/internal/domain"
	"agnts/internal/orchestrator"
)

// Muse Code (Meta) is agnts's primary coding tool. agnts-muse drives it
// over MSP (`muse serve`) inside the run container: it meters every model
// call as it happens, keeps a run on credits inside its budget (holding,
// steering, interrupting), escalates a stuck Spark session to Wonder and
// decides tool approvals with agnts's guard rules. This file adapts it to
// the orchestrator's contract, so the ticket log, transcripts, stall
// detection and spend work as they do for Claude Code.

// Environment names the token source uses for Muse credentials.
const (
	// MuseKeyEnv carries a Meta Model API key.
	MuseKeyEnv = credential.EnvAPIKey
	// MuseLoginEnv carries a Meta sign-in: Muse Code's credential file.
	MuseLoginEnv = "MUSE_LOGIN"
)

// museHome keeps Muse Code's data (sessions) and credential file inside
// Claude Code's config dir, which agnts saves between a ticket's runs, so
// a later run can resume the session.
const (
	museHome = claudeHome + "/muse"
	// museAuthPath is the only place Muse Code reads its login from: the
	// agent's own ~/.config/muse (it ignores MUSE_AUTH_PATH, which only its
	// installer's launcher reads, and $HOME).
	museAuthPath = homeDir + "/.config/muse/auth.json"
)

// MuseBudgets decides what a Muse run on agnts's key may spend. It returns
// nil when the run is on the person's own Muse account (Meta bills them).
type MuseBudgets interface {
	Budget(ctx context.Context, req orchestrator.ClaudeRequest) (*muse.Budget, error)
}

// SetMuse enables Muse runs: eng runs them and budgets limits those on
// agnts's credits (nil: no budget is enforced in the run; spend is still
// metered and settled afterwards).
func (r *Runner) SetMuse(eng *muse.Engine, budgets MuseBudgets) {
	r.muse, r.museBudgets = eng, budgets
}

// SetMuseFailover moves runs on agnts's credits to f's fallback provider
// while agnts's Meta account is out, or as an Admin chose (nil: they stay
// on agnts's key). Runs on a person's own Meta account never move: Meta
// bills and limits those for them.
func (r *Runner) SetMuseFailover(f *muse.Failover) { r.museFail = f }

// SetMuseLoginKeeper sets what saves a Muse login that Muse refreshed
// during a run (the account is in ctx).
func (r *Runner) SetMuseLoginKeeper(fn func(ctx context.Context, file []byte) error) {
	r.keepLogin = fn
}

// museModel resolves "muse:spark" or "muse:muse-spark-1.3" to a Muse id.
func museModel(name string) model.ID {
	name = strings.TrimPrefix(name, orchestrator.MusePrefix)
	if m, err := model.Default.Resolve(name); err == nil {
		return m.ID
	}
	return model.ID(name)
}

func (w *workspace) muse(ctx context.Context, req orchestrator.ClaudeRequest, onEvent func(orchestrator.ClaudeEvent)) (orchestrator.ClaudeResult, error) {
	if w.museEng == nil {
		return orchestrator.ClaudeResult{}, errors.New("muse is not available on this server")
	}
	c, err := w.token(ctx)
	if err != nil {
		return orchestrator.ClaudeResult{}, fmt.Errorf("muse credential: %w", err)
	}
	cred, err := museCredential(c)
	if err != nil {
		return orchestrator.ClaudeResult{}, err
	}
	var b *muse.Budget
	if w.museBudgets != nil {
		if b, err = w.museBudgets.Budget(ctx, req); err != nil {
			return orchestrator.ClaudeResult{}, fmt.Errorf("muse budget: %w", err)
		}
	}
	g := guard.Policy(guard.Defaults())
	if req.ReadOnly {
		// Read-only for the code, but its result goes to /agnts/out
		// (analysis.json, review.json), which agnts reads back.
		g = guard.Chain{guard.Defaults(), guard.ReadOnlyExcept(outDir)}
	}
	var ask func(muse.Approval) <-chan bool
	if req.Ask != nil {
		// Someone follows the run in a chat: adding a dependency waits for
		// their answer instead of going ahead.
		g = guard.Chain{g, guard.AskBeforeInstalls()}
		ask = func(a muse.Approval) <-chan bool {
			return req.Ask(orchestrator.ToolQuestion{Tool: museTool(a.Tool), Command: a.Command, Path: a.Path, Reason: a.Reason})
		}
	}
	if req.Timeout > 0 {
		var cancel context.CancelFunc
		ctx, cancel = context.WithTimeout(ctx, req.Timeout)
		defer cancel()
	}
	id := museModel(req.Model)
	run := w.museEng.Run
	secrets := append(cred.Secrets(), envValues(req.Env)...)
	if b != nil && w.museFail != nil { // on agnts's credits: may move to the fallback
		run = w.museFail.Run
		secrets = append(secrets, w.museFail.Fallback.Credential.Secrets()...)
	}
	onEvent = maskEvents(domain.NewSecretRedactor(secrets...), onEvent)
	limit := 0.0
	if b != nil {
		limit = b.Limit.Float()
	}
	res, err := run(ctx, muse.Request{
		Prompt: req.Prompt, Workdir: workDir, Model: id, Effort: req.Effort, SessionID: req.Resume,
		Budget: b, AnnounceBudget: b != nil && b.Limit > 0, Credential: &cred, AuthPath: museAuthPath,
		Env: req.Env, Guard: g, MaxCalls: req.MaxTurns, ExtraRoots: []string{outDir}, Steer: req.Steer, Ask: ask,
	}, &dockerExecutor{w: w, ctx: ctx}, func(e muse.Event) { museEvent(e, limit, onEvent) })
	out := orchestrator.ClaudeResult{
		SessionID: res.SessionID, Turns: res.Usage.Calls, Text: res.Text, Duration: res.Duration,
		Model: orchestrator.MusePrefix + string(res.Model),
		Usage: domain.TokenUsage{Input: res.Usage.Usage.Input - res.Usage.Usage.Cached, CacheRead: res.Usage.Usage.Cached,
			Output: res.Usage.Usage.Output, CostUSD: res.Cost().Float()},
	}
	if res.Model == "" {
		out.Model = orchestrator.MusePrefix + string(id)
	}
	if errors.Is(err, muse.ErrFallbackLimit) {
		onEvent(orchestrator.ClaudeEvent{Kind: orchestrator.ClaudeBudget, Text: "the fallback provider is not available to this run: " +
			"its monthly limit there (or the server's total) is used up", Data: map[string]any{"kind": "failover", "level": "warn"}})
	}
	var rl *muse.RateLimitError
	switch {
	case err == nil:
		out.Subtype = "success"
	case errors.As(err, &rl):
		out.RateLimited, out.IsError, out.Subtype = true, true, "rate_limited"
		onEvent(orchestrator.ClaudeEvent{Kind: orchestrator.ClaudeRateLimit, Data: map[string]any{
			"type": "rate_limit_event", "rate_limit_info": map[string]any{"status": "rejected", "resetsAt": float64(rl.Until.Unix())}}})
		return out, nil
	case errors.Is(err, muse.ErrStepLimit):
		out.IsError, out.Subtype = true, "error_max_turns"
		return out, nil
	case errors.Is(err, muse.ErrRunLimit), errors.Is(err, muse.ErrBudget), errors.Is(err, muse.ErrFallbackLimit):
		out.IsError, out.Subtype = true, "error_budget"
		return out, fmt.Errorf("stopped inside its credit budget: %w", err)
	case errors.Is(err, context.DeadlineExceeded):
		return out, fmt.Errorf("muse timed out after %s", req.Timeout)
	}
	if err != nil {
		var oom *orchestrator.OOMError
		if errors.As(err, &oom) {
			return out, oom
		}
		return out, fmt.Errorf("muse: %w", err)
	}
	return out, nil
}

// museCredential turns the token source's credential into Muse's.
func museCredential(c Credential) (credential.Credential, error) {
	switch {
	case c.Token == "":
		return credential.Credential{}, errors.New("muse is not connected: connect your Meta account in Workspace settings → Muse")
	case c.Env == MuseLoginEnv:
		return credential.LoginFile([]byte(c.Token), "")
	case c.Env == MuseKeyEnv:
		return credential.APIKey(c.Token)
	}
	return credential.Credential{}, fmt.Errorf("this account is not a Muse account (%s); connect Muse in Workspace settings", c.Env)
}

// museEvent maps agnts-muse's events onto Claude Code's, which the ticket
// log, transcripts and stall detection read.
func museEvent(e muse.Event, limit float64, on func(orchestrator.ClaudeEvent)) {
	budget := func(kind, text, level string, data map[string]any) {
		if data == nil {
			data = map[string]any{}
		}
		data["kind"], data["level"] = kind, level
		on(orchestrator.ClaudeEvent{Kind: orchestrator.ClaudeBudget, Text: text, Data: data})
	}
	switch e.Kind {
	case muse.EventStarted:
		on(orchestrator.ClaudeEvent{Kind: orchestrator.ClaudeInit, Data: map[string]any{
			"session_id": e.SessionID, "model": orchestrator.MusePrefix + string(e.Model)}})
	case muse.EventMessage:
		on(orchestrator.ClaudeEvent{Kind: orchestrator.ClaudeText, Text: e.Text})
	case muse.EventToolStart:
		data := map[string]any{"input": e.Args}
		if t := toolTarget(e.Args); t != "" {
			data["target"] = t
		}
		on(orchestrator.ClaudeEvent{Kind: orchestrator.ClaudeTool, Tool: museTool(e.Tool), Data: data})
	case muse.EventToolEnd:
		on(orchestrator.ClaudeEvent{Kind: orchestrator.ClaudeToolResult, Tool: museTool(e.Tool), Data: map[string]any{"is_error": e.Failed, "output": e.Output}})
	case muse.EventUsage:
		c := e.Charge
		text := fmt.Sprintf("model call %d on %s: %s (total %s)", c.Calls, e.Model, c.Cost, c.Total)
		budget("usage", text, "info", map[string]any{"cost_usd": c.Cost.Float(), "total_usd": c.Total.Float(), "held_usd": e.Held.Float(),
			"limit_usd": limit, "calls": c.Calls, "model": string(e.Model),
			"input_tokens": c.Usage.Input, "cached_tokens": c.Usage.Cached, "output_tokens": c.Usage.Output})
	case muse.EventSteer:
		switch e.Reason {
		case "person":
			budget("message", "a message from the chat went to the running agent", "info", nil)
		case "approval":
			budget("approval", "told the agent the chat's answer", "info", nil)
		case "steps":
			budget("steer", "model calls running low: told Muse to wrap up", "warn", nil)
		default:
			budget("steer", "budget running low: told Muse to wrap up", "warn", nil)
		}
	case muse.EventEscalate:
		budget("escalate", "moved to "+string(e.Model)+": "+e.Reason, "info", map[string]any{"model": string(e.Model)})
	case muse.EventContinue:
		budget("continue", e.Reason, "warn", nil)
	case muse.EventFailover:
		budget("failover", "continuing on the fallback provider ("+string(e.Model)+"): "+e.Reason, "warn", map[string]any{"model": string(e.Model)})
	case muse.EventInterrupt:
		budget("stop", "stopped: "+e.Reason, "warn", nil)
	case muse.EventApproval:
		a := e.Approval
		what := ""
		if a != nil {
			what = firstNonEmpty(a.Command, a.Path, a.Tool)
		}
		switch {
		case a == nil:
		case a.Pending:
			budget("ask", fmt.Sprintf("waiting for the chat to allow %s (%s)", what, a.Reason), "warn", map[string]any{"rule": a.Rule})
		case a.Ask && a.Allow:
			budget("ask", "the chat allowed "+what, "info", map[string]any{"rule": a.Rule})
		case a.Ask:
			budget("ask", "the chat did not allow "+what, "warn", map[string]any{"rule": a.Rule})
		case !a.Allow:
			budget("guard", fmt.Sprintf("guard refused %s (%s): %s", what, a.Rule, a.Reason), "warn", map[string]any{"rule": a.Rule})
		}
	case muse.EventSettled:
		if r := e.Receipt; r != nil {
			budget("settled", fmt.Sprintf("charged %s, released %s", r.Charged, r.Released), "info",
				map[string]any{"charged_usd": r.Charged.Float(), "released_usd": r.Released.Float(), "unbilled_usd": r.Unbilled.Float()})
		}
	}
}

// toolTarget is the short subject of a tool call for the ticket log: the
// file read or edited, the pattern searched, the command run. The full
// input stays in the run history only.
func toolTarget(args string) string {
	var in map[string]any
	if json.Unmarshal([]byte(args), &in) != nil {
		return ""
	}
	for _, k := range []string{"path", "file_path", "pattern", "query", "command", "url"} {
		if v, ok := in[k].(string); ok && strings.TrimSpace(v) != "" {
			v = strings.Join(strings.Fields(v), " ")
			if len(v) > 120 {
				v = v[:117] + "..."
			}
			return v
		}
	}
	return ""
}

// museTool names Muse's tools the way the ticket log and stall detection
// know Claude Code's.
func museTool(t string) string {
	switch t {
	case "bash", "shell":
		return "Bash"
	case "read_file":
		return "Read"
	case "edit_file", "apply_patch":
		return "Edit"
	case "write_file":
		return "Write"
	case "grep", "search":
		return "Grep"
	}
	return t
}

func firstNonEmpty(s ...string) string {
	for _, v := range s {
		if v != "" {
			return v
		}
	}
	return ""
}

// dockerExecutor runs `muse serve` in the run container.
type dockerExecutor struct {
	w   *workspace
	ctx context.Context // the run's: whose account a refreshed login is kept for
}

// Start implements muse.Executor.
func (d *dockerExecutor) Start(ctx context.Context, cmd muse.Command) (muse.Process, error) {
	for _, f := range cmd.Files {
		if err := d.w.WriteFile(ctx, f.Path, f.Data); err != nil {
			return nil, fmt.Errorf("muse credential file: %w", err)
		}
	}
	var stderr tailBuffer
	a, err := d.w.docker.ExecAttach(ctx, d.w.id, ExecConfig{
		Cmd:        append([]string{"sh", "-c", `mkdir -p "$XDG_DATA_HOME" && exec "$@"`, "muse", cmd.Path}, cmd.Args...),
		User:       agentUser,
		WorkingDir: workDir,
		Env: append([]string{"XDG_DATA_HOME=" + museHome + "/data", "XDG_STATE_HOME=" + museHome + "/state",
			"MUSE_UPDATE_INTERVAL_SECONDS=31536000", "NO_COLOR=1", museFileCredentials}, cmd.Env...),
	}, &stderr)
	if err != nil {
		return nil, err
	}
	return &museProcess{a: a, w: d.w, files: cmd.Files, stderr: &stderr, ctx: d.ctx}, nil
}

type museProcess struct {
	a      *Attached
	w      *workspace
	files  []credential.File
	stderr *tailBuffer
	ctx    context.Context

	once sync.Once
	err  error
}

func (p *museProcess) Read(b []byte) (int, error)  { return p.a.Read(b) }
func (p *museProcess) Write(b []byte) (int, error) { return p.a.Write(b) }
func (p *museProcess) Close() error                { return p.a.Close() }
func (p *museProcess) Kill() error                 { return p.a.Kill() }

// Wait waits for `muse serve` to exit and removes the credential file.
func (p *museProcess) Wait() error {
	p.once.Do(func() {
		ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
		defer cancel()
		code, err := p.a.Wait(ctx)
		p.keepLogin(ctx)
		for _, f := range p.files {
			_, _ = p.w.docker.Exec(ctx, p.w.id, ExecConfig{Cmd: []string{"rm", "-f", f.Path}, User: agentUser}, io.Discard, io.Discard)
		}
		switch {
		case err != nil:
			p.err = err
		case code == 127:
			p.err = errors.New("muse is not installed in the runner image: build it with --build-arg MUSE_VERSION=<version>")
		case code == 137:
			if oom := p.w.errOOM(ctx, code); oom != nil {
				p.err = oom
			}
		case code != 0:
			p.err = fmt.Errorf("muse exited %d: %s", code, p.stderr.String())
		}
	})
	return p.err
}

// keepLogin saves the credential file back when Muse refreshed it during
// the run (it rewrites the file at MUSE_AUTH_PATH).
func (p *museProcess) keepLogin(ctx context.Context) {
	if p.w.keepLogin == nil || p.ctx == nil {
		return
	}
	for _, f := range p.files {
		if f.Path != museAuthPath {
			continue
		}
		now, err := p.w.ReadFile(ctx, f.Path)
		if err != nil || len(now) == 0 || string(now) == string(f.Data) {
			return
		}
		_ = p.w.keepLogin(context.WithoutCancel(p.ctx), now)
	}
}
