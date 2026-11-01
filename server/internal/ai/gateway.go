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

// Spend records what a call cost: in a ticket's run (RunID) or a
// document's generation (DocumentRunID).
type Spend func(ctx context.Context, c domain.ClaudeCall) error

// Deps are what the gateway works with.
type Deps struct {
	Providers *Registry
	// Access says which modules a person may use; nil: the default
	// access for everyone.
	Access AccessSource
	// Accounts and Workspaces pick each call's account; nil: one account
	// for everything (no credentials: tests and bare installs).
	Accounts   Accounts
	Workspaces Workspaces
	// Limits keeps the accounts' usage limits; nil: none.
	Limits   Limits
	Settings Settings
	Spend    Spend // nil: spend is not recorded
	Log      *slog.Logger
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

// ErrLimit is a call held at its account's usage limit.
var ErrLimit = errors.New("the plan limit is reached; try again after it resets")

// Call is one invocation a feature asks for.
type Call struct {
	Who     Who
	Purpose Purpose
	// Route is where it runs, when the caller routed it (Route); nil:
	// the run's admission on ctx, else routed now.
	Route *Route
	Box   Box
	Req   Request
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

// allowed checks that who may use provider id: the access the caller
// read, else the admitted run's, else the person's, else the default.
func (g *Gateway) allowed(ctx context.Context, who Who, id string) error {
	var a domain.Access
	switch adm, admitted := AdmissionOf(ctx); {
	case who.Access != nil:
		a = *who.Access
	case admitted:
		a = adm.Access
	default:
		var err error
		if a, err = g.Access(ctx, who.Person); err != nil {
			return fmt.Errorf("read modules: %w", err)
		}
	}
	if !a.Allows(id) {
		return &domain.NotAllowedError{Module: id}
	}
	return nil
}

// RouteCall decides where c runs: on the admitted run's route for its
// model's provider, else routed now for c.Who (or the run's person).
func (g *Gateway) RouteCall(ctx context.Context, c Call) (Route, *Hold) {
	who := c.Who
	if adm, ok := AdmissionOf(ctx); ok {
		p, err := g.providerFor(c.Req.Model)
		if err != nil {
			return Route{}, &Hold{Why: err.Error(), Err: err}
		}
		if r, ok := adm.Routes[p.ID()]; ok {
			if err := g.allowed(ctx, adm.Who, p.ID()); err != nil {
				return Route{}, &Hold{Why: err.Error(), Err: err}
			}
			r.Purpose = c.Purpose
			return r, nil
		}
		if who == (Who{}) {
			who = adm.Who
			who.Access = &adm.Access
		}
	}
	return g.Route(ctx, who, c.Purpose, Want{Model: c.Req.Model})
}

// Run makes one call: it routes it (or takes its route), opens the
// credential of the route's account, runs it through the provider,
// records its usage readings and its spend. A call that cannot run
// returns the *Hold.
func (g *Gateway) Run(ctx context.Context, c Call, on func(Event)) (Result, error) {
	var r Route
	if c.Route != nil {
		r = *c.Route
	} else {
		var h *Hold
		if r, h = g.RouteCall(ctx, c); h != nil {
			return Result{}, h
		}
	}
	p, ok := g.d.Providers.Get(r.Provider)
	if !ok {
		return Result{}, fmt.Errorf("%s is not available on this server", ModuleName(r.Provider))
	}
	cred, err := g.credential(ctx, r.Account)
	if err != nil {
		return Result{}, err
	}
	acct := r.Account
	inner := on
	on = func(e Event) {
		if e.Kind == EventRateLimit && g.d.Limits != nil {
			g.d.Limits.Record(ctx, acct, e.Data)
		}
		if c.Record != nil {
			c.Record.Event(e)
		}
		if inner != nil {
			inner(e)
		}
	}
	res, err := p.Exec(ctx, c.Box, cred, c.Req, on)
	res.Provider, res.Account = r.Provider, acct
	if res.RateLimited && g.d.Limits != nil {
		g.d.Limits.RecordLimited(ctx, acct)
	}
	if c.Record != nil {
		if id := c.Record.Finish(ctx, res, err); id > 0 {
			res.TranscriptID = id
		}
	}
	g.spend(ctx, c, acct, res)
	return res, err
}

// credential opens acct's secret.
func (g *Gateway) credential(ctx context.Context, acct Account) (Credential, error) {
	if g.d.Accounts == nil {
		return Credential{Account: acct}, nil // providers refuse to run without one
	}
	c, err := g.d.Accounts.Credential(ctx, acct)
	if err != nil {
		return Credential{}, fmt.Errorf("%s credential: %w", ModuleName(acct.Provider), err)
	}
	c.Account = acct
	return c, nil
}

// spend records a call's tokens, failed and rate-limited ones included:
// they were spent all the same. A call that never reached the model (no
// turns, no tokens) is not recorded.
func (g *Gateway) spend(ctx context.Context, c Call, acct Account, res Result) {
	if g.d.Spend == nil || (c.RunID == 0 && c.DocumentRunID == 0) || (res.Usage.IsZero() && res.Turns == 0) {
		return
	}
	model := c.Req.Model
	if res.Model != "" {
		model = res.Model
	}
	call := domain.ClaudeCall{
		RunID: c.RunID, DocumentRunID: c.DocumentRunID, ModelStage: c.ModelStage, Model: model, Usage: res.Usage,
		Turns: res.Turns, Duration: res.Duration, Partial: res.Partial, TranscriptID: res.TranscriptID, Provider: acct.Provider,
		ConnectionID: acct.ConnectionID, OnCredits: acct.Credits,
	}
	// The call may have been stopped; the spend is recorded regardless.
	if err := g.d.Spend(context.WithoutCancel(ctx), call); err != nil {
		g.d.Log.Error("record spend", "run_id", c.RunID, "document_run_id", c.DocumentRunID, "err", err)
	}
}

// Hear returns what was said in a meeting's audio, heard by a provider
// that hears audio, on the account who's runs use for it.
func (g *Gateway) Hear(ctx context.Context, who Who, audio []byte, ext string) ([]Segment, error) {
	h, cred, err := g.hearing(ctx, who, PurposeMeeting)
	if err != nil {
		return nil, err
	}
	return h.Hear(ctx, cred, audio, ext)
}

// HearClip returns the words of a short spoken WAV clip.
func (g *Gateway) HearClip(ctx context.Context, who Who, wav []byte) (string, error) {
	h, cred, err := g.hearing(ctx, who, PurposeVoice)
	if err != nil {
		return "", err
	}
	return h.HearClip(ctx, cred, wav)
}

// hearing routes a call that hears audio.
func (g *Gateway) hearing(ctx context.Context, who Who, purpose Purpose) (Hearer, Credential, error) {
	r, hold := g.Route(ctx, who, purpose, Want{Needs: Caps{CapAudio}})
	if hold != nil {
		return nil, Credential{}, hold
	}
	p, _ := g.d.Providers.Get(r.Provider)
	h, ok := p.(Hearer)
	if !ok {
		return nil, Credential{}, fmt.Errorf("%s does not hear audio", ModuleName(r.Provider))
	}
	cred, err := g.credential(ctx, r.Account)
	if err != nil {
		return nil, Credential{}, err
	}
	return h, cred, nil
}

// CanHear reports whether a provider here hears audio.
func (g *Gateway) CanHear() bool {
	_, err := g.provider(Want{Needs: Caps{CapAudio}})
	return err == nil
}
