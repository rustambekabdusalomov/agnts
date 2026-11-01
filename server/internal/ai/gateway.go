package ai

import (
	"context"
	"errors"
	"fmt"
	"log/slog"

	"agnts/internal/domain"
)

// Purpose is what a call is for: a ticket stage ("analyze", "code", …),
// or one of domain's background purposes (assistant, translate, …).
type Purpose = domain.TranscriptPurpose

// PurposeUsageProbe is a one-turn call that reads an account's usage.
const PurposeUsageProbe Purpose = "usage_probe"

// AccessSource says which modules a person may use.
type AccessSource interface {
	For(ctx context.Context, user int64) (domain.Access, error)
}

// Credentials gives the secret a call on provider uses, from the account
// ctx runs on for it.
type Credentials interface {
	Credential(ctx context.Context, provider string) (Credential, error)
}

// Spend records what a call cost: in a ticket's run (RunID) or a
// document's generation (DocumentRunID).
type Spend func(ctx context.Context, c domain.ClaudeCall) error

// Deps are what the gateway works with.
type Deps struct {
	Providers   *Registry
	Access      AccessSource // nil: only the access on ctx is checked
	Credentials Credentials
	Spend       Spend // nil: spend is not recorded
	Log         *slog.Logger
}

// Gateway is the one way features reach an AI provider.
type Gateway struct{ d Deps }

// New returns the gateway.
func New(d Deps) *Gateway {
	if d.Log == nil {
		d.Log = slog.New(slog.DiscardHandler)
	}
	return &Gateway{d: d}
}

// Call is one invocation a feature asks for.
type Call struct {
	Purpose Purpose
	// Person is whose modules the call may use (0: the access on ctx).
	Person int64
	Box    Box
	Req    Request
	// RunID or DocumentRunID, with ModelStage, say where the call's spend
	// is recorded; neither: it is not.
	RunID         int64
	DocumentRunID int64
	ModelStage    string
	// Record keeps the call's transcript; nil: none.
	Record Recording
}

// Recording keeps a call's transcript: it sees every event, and Finish
// closes it once the call ended, returning the transcript's id (0: not
// recorded).
type Recording interface {
	Event(e Event)
	Finish(ctx context.Context, res Result, err error) int64
}

// Providers returns the registry.
func (g *Gateway) Providers() *Registry { return g.d.Providers }

// providerFor returns the provider of model ("" is Claude Code's default
// model).
func (g *Gateway) providerFor(model string) (Provider, error) {
	if g.d.Providers == nil {
		return nil, errors.New("no coding agent is set up on this server")
	}
	id := ProviderOf(model)
	if id == "" {
		id = Claude
	}
	p, ok := g.d.Providers.Get(id)
	if !ok {
		return nil, fmt.Errorf("%s is not available on this server", ModuleName(id))
	}
	return p, nil
}

// allowed checks that the call's person may use provider id.
func (g *Gateway) allowed(ctx context.Context, person int64, id string) error {
	a, ok := domain.AccessIn(ctx)
	if !ok && person > 0 && g.d.Access != nil {
		var err error
		if a, err = g.d.Access.For(ctx, person); err != nil {
			return fmt.Errorf("read modules: %w", err)
		}
		ok = true
	}
	if ok && !a.Allows(id) {
		return &domain.NotAllowedError{Module: id}
	}
	return nil
}

// credential returns the secret a call on p uses.
func (g *Gateway) credential(ctx context.Context, p Provider) (Credential, error) {
	if g.d.Credentials == nil {
		return Credential{}, nil // providers refuse to run without one
	}
	c, err := g.d.Credentials.Credential(ctx, p.ID())
	if err != nil {
		return Credential{}, fmt.Errorf("%s credential: %w", ModuleName(p.ID()), err)
	}
	return c, nil
}

// Run makes one call: it checks the person may use the model's provider,
// takes the credential of the account the call runs on, runs it through
// the provider and records its spend.
func (g *Gateway) Run(ctx context.Context, c Call, on func(Event)) (Result, error) {
	p, err := g.providerFor(c.Req.Model)
	if err != nil {
		return Result{}, err
	}
	if err := g.allowed(ctx, c.Person, p.ID()); err != nil {
		return Result{}, err
	}
	ctx = domain.UseProvider(ctx, p.ID())
	cred, err := g.credential(ctx, p)
	if err != nil {
		return Result{}, err
	}
	if c.Record != nil {
		inner := on
		on = func(e Event) {
			c.Record.Event(e)
			if inner != nil {
				inner(e)
			}
		}
	}
	res, err := p.Exec(ctx, c.Box, cred, c.Req, on)
	if c.Record != nil {
		if id := c.Record.Finish(ctx, res, err); id > 0 {
			res.TranscriptID = id
		}
	}
	g.spend(ctx, c, p.ID(), res)
	return res, err
}

// spend records a call's tokens, failed and rate-limited ones included:
// they were spent all the same. A call that never reached the model (no
// turns, no tokens) is not recorded.
func (g *Gateway) spend(ctx context.Context, c Call, provider string, res Result) {
	if g.d.Spend == nil || (c.RunID == 0 && c.DocumentRunID == 0) || (res.Usage.IsZero() && res.Turns == 0) {
		return
	}
	model := c.Req.Model
	if res.Model != "" {
		model = res.Model
	}
	call := domain.ClaudeCall{
		RunID: c.RunID, DocumentRunID: c.DocumentRunID, ModelStage: c.ModelStage, Model: model, Usage: res.Usage,
		Turns: res.Turns, Duration: res.Duration, Partial: res.Partial, TranscriptID: res.TranscriptID, Provider: provider,
	}
	if a, ok := domain.ClaudeOf(ctx); ok {
		call.ConnectionID, call.OnCredits = a.ConnectionID, a.Credits
	}
	// The call may have been stopped; the spend is recorded regardless.
	if err := g.d.Spend(context.WithoutCancel(ctx), call); err != nil {
		g.d.Log.Error("record spend", "run_id", c.RunID, "document_run_id", c.DocumentRunID, "err", err)
	}
}

// Hear returns what was said in a meeting's audio, heard by a provider
// that hears audio, on the account ctx runs on for it.
func (g *Gateway) Hear(ctx context.Context, person int64, audio []byte, ext string) ([]Segment, error) {
	h, p, err := g.hearer(ctx, person)
	if err != nil {
		return nil, err
	}
	ctx = domain.UseProvider(ctx, p.ID())
	cred, err := g.credential(ctx, p)
	if err != nil {
		return nil, err
	}
	return h.Hear(ctx, cred, audio, ext)
}

// HearClip returns the words of a short spoken WAV clip.
func (g *Gateway) HearClip(ctx context.Context, person int64, wav []byte) (string, error) {
	h, p, err := g.hearer(ctx, person)
	if err != nil {
		return "", err
	}
	ctx = domain.UseProvider(ctx, p.ID())
	cred, err := g.credential(ctx, p)
	if err != nil {
		return "", err
	}
	return h.HearClip(ctx, cred, wav)
}

// CanHear reports whether a provider here hears audio.
func (g *Gateway) CanHear() bool {
	_, _, err := g.hearer(context.Background(), 0)
	return err == nil
}

// hearer finds the provider that hears audio. Hearing is not coding: the
// person's modules do not limit it.
func (g *Gateway) hearer(_ context.Context, _ int64) (Hearer, Provider, error) {
	if g.d.Providers != nil {
		for _, id := range g.d.Providers.IDs() {
			p, _ := g.d.Providers.Get(id)
			if h, ok := p.(Hearer); ok && p.Caps().Has(CapAudio) {
				return h, p, nil
			}
		}
	}
	return nil, nil, errors.New("no provider here hears audio")
}
