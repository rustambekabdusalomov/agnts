// Package codex runs Codex CLI (OpenAI) for the AI gateway: `codex exec
// --json` in the run container, on the workspace's OpenAI key.
package codex

import (
	"context"
	"errors"
	"fmt"
	"io"
	"regexp"
	"time"

	"agnts/internal/ai"
	"agnts/internal/domain"
)

// codexHome keeps Codex's sessions inside Claude Code's config dir, which
// agnts saves between a ticket's runs: a later run can resume them.
const codexHome = ai.ClaudeHome + "/codex"

// model matches a Codex model's name.
var model = regexp.MustCompile(`^[a-z0-9][a-z0-9._-]{0,63}$`)

// Provider is Codex CLI.
type Provider struct {
	// tiers are the Codex models for light and strong work
	// (AGNTS_CODEX_MODELS); without them Codex has no tiers and runs only
	// models a setting names.
	tiers map[ai.Tier]string
}

var _ ai.Provider = (*Provider)(nil)

// New returns Codex with these models for light and strong work (names
// without the codex: prefix; either may be missing).
func New(tiers map[ai.Tier]string) *Provider {
	t := map[ai.Tier]string{}
	for k, v := range tiers {
		if model.MatchString(v) {
			t[k] = v
		}
	}
	return &Provider{tiers: t}
}

// ID implements ai.Provider.
func (p *Provider) ID() string { return ai.Codex }

// Name implements ai.Provider.
func (p *Provider) Name() string { return "Codex" }

// FreeCredits implements ai.Provider: free credits are Muse ledger money.
func (p *Provider) FreeCredits() bool { return false }

// Caps implements ai.Provider.
func (p *Provider) Caps() ai.Caps { return ai.Caps{ai.CapResume} }

// Catalog implements ai.Provider.
func (p *Provider) Catalog() ai.Catalog { return catalog{p.tiers} }

type catalog struct{ tiers map[ai.Tier]string }

func (c catalog) Valid(name string) bool { return model.MatchString(name) }

func (c catalog) Listed() []string {
	var out []string
	for _, t := range []ai.Tier{ai.Light, ai.Strong} {
		if m := c.Model(t); m != "" && (len(out) == 0 || out[0] != m) {
			out = append(out, m)
		}
	}
	return out
}

func (c catalog) Model(t ai.Tier) string {
	if t == ai.Auto {
		t = ai.Light
	}
	if m := c.tiers[t]; m != "" {
		return ai.CodexPrefix + m
	}
	return ""
}

func (c catalog) TierOf(name string) ai.Tier {
	if name != "" && name == c.tiers[ai.Strong] {
		return ai.Strong
	}
	return ai.Light
}

// Exec implements ai.Provider: one `codex exec` invocation.
func (p *Provider) Exec(ctx context.Context, box ai.Box, cred ai.Credential, req ai.Request, onEvent func(ai.Event)) (ai.Result, error) {
	if cred.Token == "" {
		return ai.Result{}, errors.New("codex runs need an OpenAI API key: connect OpenAI under Integrations")
	}
	ref, _ := ai.ParseModel(req.Model)
	name := ref.Name
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
			Argv: ai.TimeoutArgv(req.Timeout, append([]string{"sh", "-c", `mkdir -p "$CODEX_HOME" && exec "$@"`, "codex"}, codexArgv(req, name)...)...),
			Env:  append([]string{"OPENAI_API_KEY=" + cred.Token, "CODEX_API_KEY=" + cred.Token, "CODEX_HOME=" + codexHome}, req.Env...),
		}, pw, &stderr)
		_ = pw.CloseWithError(err)
		done <- execOut{code, err}
	}()
	start := time.Now()
	res, perr := ParseCodexStream(pr, onEvent)
	_, _ = io.Copy(io.Discard, pr)
	out := <-done
	res.Duration = time.Since(start)
	res.Model = ai.CodexPrefix + name
	if oom := box.OOM(ctx, out.code); oom != nil {
		return res, oom
	}
	switch {
	case out.err != nil:
		return res, out.err
	case out.code == 124:
		return res, fmt.Errorf("codex timed out after %s", req.Timeout)
	case out.code == 127:
		return res, errors.New("codex is not installed in the runner image: build it with --build-arg CODEX_VERSION=<version>")
	case perr != nil:
		return res, fmt.Errorf("%w (exit %d): %s", perr, out.code, stderr.String())
	}
	return res, nil
}
