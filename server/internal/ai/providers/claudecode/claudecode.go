// Package claudecode runs Claude Code (Anthropic) for the AI gateway:
// `claude -p` with stream-json output, in the run container.
package claudecode

import (
	"context"
	"errors"
	"fmt"
	"io"
	"maps"
	"slices"
	"strconv"
	"strings"
	"time"

	"agnts/internal/ai"
	"agnts/internal/domain"
)

// DefaultModels are the current Claude models for agnts's short names.
var DefaultModels = map[string]string{
	"opus":   "claude-opus-5-5",
	"sonnet": "claude-sonnet-5-5",
	"haiku":  "claude-haiku-5-5",
}

// Credential environment names.
const (
	EnvAPIKey = "ANTHROPIC_API_KEY"       //nolint:gosec // a variable name, not a credential
	EnvOAuth  = "CLAUDE_CODE_OAUTH_TOKEN" //nolint:gosec // a variable name, not a credential
)

// Provider is Claude Code.
type Provider struct {
	// models are the full model ids for agnts's short names (opus,
	// sonnet, haiku). Claude Code resolves a short name to the newest
	// model it knows, so a pinned older release would pick older models;
	// a full id does not depend on the release.
	models map[string]string
}

var _ ai.Provider = (*Provider)(nil)

// New returns Claude Code with these model ids over DefaultModels (an
// empty id passes the short name through).
func New(models map[string]string) *Provider {
	m := maps.Clone(DefaultModels)
	maps.Copy(m, models)
	return &Provider{models: m}
}

// ID implements ai.Provider.
func (p *Provider) ID() string { return ai.Claude }

// Name implements ai.Provider.
func (p *Provider) Name() string { return "Claude" }

// FreeCredits implements ai.Provider: free credits are Muse ledger money.
func (p *Provider) FreeCredits() bool { return false }

// Caps implements ai.Provider.
func (p *Provider) Caps() ai.Caps { return ai.Caps{ai.CapEffort, ai.CapResume, ai.CapInRunGuard} }

// Catalog implements ai.Provider.
func (p *Provider) Catalog() ai.Catalog { return catalog{} }

type catalog struct{}

func (catalog) Valid(name string) bool { return slices.Contains(domain.Models, name) }
func (catalog) Listed() []string       { return slices.Clone(domain.Models) }
func (catalog) Model(t ai.Tier) string {
	if t == ai.Strong {
		return "opus"
	}
	return "sonnet"
}
func (catalog) TierOf(name string) ai.Tier {
	if name == "opus" {
		return ai.Strong
	}
	return ai.Light
}

// modelID is the full id for a short model name; anything else (a full
// id already, or a name without a mapping) goes to Claude Code as is.
func modelID(models map[string]string, name string) string {
	if id := models[name]; id != "" {
		return id
	}
	return name
}

// modelEnv points Claude Code's own short names at the same models: it
// uses them for sub-agents and its quick background calls.
func modelEnv(models map[string]string) []string {
	var env []string
	for _, name := range []string{"opus", "sonnet", "haiku"} {
		if id := models[name]; id != "" {
			env = append(env, "ANTHROPIC_DEFAULT_"+strings.ToUpper(name)+"_MODEL="+id)
		}
	}
	return env
}

// Argv is the claude command line for a request.
func (p *Provider) argv(req ai.Request) []string {
	argv := []string{"claude", "-p", req.Prompt,
		"--output-format", "stream-json", "--verbose",
		"--permission-mode", "dontAsk"}
	if req.Model != "" {
		argv = append(argv, "--model", modelID(p.models, req.Model))
	}
	if req.MaxTurns > 0 {
		argv = append(argv, "--max-turns", strconv.Itoa(req.MaxTurns))
	}
	if req.Resume != "" {
		argv = append(argv, "--resume", req.Resume)
	}
	if req.Effort != "" {
		argv = append(argv, "--effort", req.Effort)
	}
	if req.Settings != "" {
		argv = append(argv, "--settings", req.Settings)
	}
	return argv
}

// Exec implements ai.Provider: one `claude -p` invocation.
func (p *Provider) Exec(ctx context.Context, box ai.Box, cred ai.Credential, req ai.Request, onEvent func(ai.Event)) (ai.Result, error) {
	if cred.Token == "" {
		return ai.Result{}, errors.New("claude is not connected: connect an account in Workspace settings → AI accounts")
	}
	if cred.Env == "" {
		cred.Env = EnvOAuth
	}
	// The token is in the agent's environment, so `env` in a tool call
	// would print it: nothing above the provider sees it, or req.Env's
	// values.
	onEvent = ai.MaskEvents(domain.NewSecretRedactor(append([]string{cred.Token}, ai.EnvValues(req.Env)...)...), onEvent)
	pr, pw := io.Pipe()
	var stderr ai.TailBuffer
	type execOut struct {
		code int
		err  error
	}
	done := make(chan execOut, 1)
	go func() {
		code, err := box.Run(ctx, ai.Cmd{
			Argv: ai.TimeoutArgv(req.Timeout, p.argv(req)...),
			Env: append(append([]string{
				cred.Env + "=" + cred.Token,
				"CLAUDE_CONFIG_DIR=" + ai.ClaudeHome,
				"DISABLE_AUTOUPDATER=1",
			}, modelEnv(p.models)...), req.Env...),
		}, pw, &stderr)
		_ = pw.CloseWithError(err)
		done <- execOut{code, err}
	}()

	start := time.Now()
	res, perr := ParseStream(pr, onEvent)
	_, _ = io.Copy(io.Discard, pr) // drain so the command can finish
	out := <-done
	if res.Duration == 0 {
		res.Duration = time.Since(start)
	}
	if oom := box.OOM(ctx, out.code); oom != nil {
		return res, oom
	}
	switch {
	case out.err != nil:
		return res, out.err
	case out.code == 124:
		return res, fmt.Errorf("claude timed out after %s", req.Timeout)
	case perr != nil:
		return res, fmt.Errorf("%w (exit %d): %s", perr, out.code, stderr.String())
	}
	return res, nil
}
