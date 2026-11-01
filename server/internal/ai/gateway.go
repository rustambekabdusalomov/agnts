package ai

import (
	"context"
	"errors"
	"fmt"
	"log/slog"
	"regexp"

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

// accessOf is who's modules: the access the caller read, else the
// admitted run's, else the person's, else the default.
func (g *Gateway) accessOf(ctx context.Context, who Who) (domain.Access, error) {
	if who.Access != nil {
		return *who.Access, nil
	}
	if adm, ok := AdmissionOf(ctx); ok {
		return adm.Access, nil
	}
	a, err := g.Access(ctx, who.Person)
	if err != nil {
		return a, fmt.Errorf("read modules: %w", err)
	}
	return a, nil
}

// allowed checks that who may use provider id.
func (g *Gateway) allowed(ctx context.Context, who Who, id string) error {
	a, err := g.accessOf(ctx, who)
	if err != nil {
		return err
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
		// A route the admission moved to another module serves only
		// purposes that may switch (not a second opinion).
		if r, ok := adm.route(p.ID()); ok && (!r.Moved() || PolicyOf(c.Purpose).Reroute) {
			if err := g.allowed(ctx, adm.Who, r.Provider); err != nil {
				return Route{}, &Hold{Why: err.Error(), Err: err}
			}
			r.Purpose = c.Purpose
			r.Model = MapModel(g.d.Providers, c.Req.Model, r.Provider)
			if c.Req.Model == "" && r.Provider != p.ID() {
				r.Model = g.lightOf(r.Provider)
			}
			return r, nil
		}
		if who == (Who{}) {
			who = adm.Who
			who.Access = &adm.Access
		}
	}
	return g.Route(ctx, who, c.Purpose, Want{Model: c.Req.Model})
}

// maxAttempts is how often a call runs at most: once, and again on the
// next route after each early failure.
const maxAttempts = 3

// Run makes one call: it routes it (or takes its route), opens the
// credential of the route's account, runs it through the provider,
// records its usage readings and its spend. A call that cannot run
// returns the *Hold.
//
// A call that fails early (its account at its limit or refusing its
// credential, before it changed anything) runs again at once on the next
// route: another account of its module (credits, when its purpose may use
// them), then, when the workspace switches modules, the person's next
// module. An admitted run's later calls go straight to the new route.
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
	model, resume := c.Req.Model, c.Req.Resume
	var avoid []Account
	var res Result
	var err error
	var spent []Result // each attempt's, recorded once the transcript is closed
	for attempt := 1; ; attempt++ {
		var why string
		var tools int
		res, tools, err = g.attempt(ctx, c, r, on)
		spent = append(spent, res)
		if attempt >= maxAttempts || c.Purpose == PurposeUsageProbe || ctx.Err() != nil {
			break
		}
		if why = earlyFailure(res, err, tools, c.Req.ReadOnly); why == "" {
			break
		}
		avoid = append(avoid, r.Account)
		who := r.Who
		next, hold := g.Route(ctx, who, c.Purpose, Want{Model: model, Avoid: avoid})
		if hold != nil {
			break // nowhere else to go: the failure stands
		}
		from := describe(r)
		next.Rerouted = why
		if next.Provider != r.Provider {
			c.Req.Resume = "" // sessions do not move between tools
		} else {
			c.Req.Resume = resume
		}
		if on != nil {
			on(Event{Kind: EventRetry, Text: fmt.Sprintf("%s failed (%s); running again on %s", from, why, describe(next)),
				Data: map[string]any{"from": from, "to": describe(next), "why": why}})
		}
		if adm, ok := AdmissionOf(ctx); ok {
			adm.move(r.Asked, next)
		}
		r = next
	}
	if c.Record != nil {
		if id := c.Record.Finish(ctx, res, err); id > 0 {
			res.TranscriptID = id
		}
	}
	for _, s := range spent {
		s.TranscriptID = res.TranscriptID // every attempt is in the one transcript
		g.spend(ctx, c, s.Account, s)
	}
	return res, err
}

// attempt runs c once on r. tools counts the tool calls it made.
func (g *Gateway) attempt(ctx context.Context, c Call, r Route, on func(Event)) (Result, int, error) {
	p, ok := g.d.Providers.Get(r.Provider)
	if !ok {
		return Result{}, 0, fmt.Errorf("%s is not available on this server", ModuleName(r.Provider))
	}
	if r.Model != "" {
		c.Req.Model = r.Model // a moved call runs its route's model
	}
	if !r.Caps.Has(CapResume) {
		c.Req.Resume = ""
	}
	cred, err := g.credential(ctx, r.Account)
	if err != nil {
		return Result{Provider: r.Provider, Account: r.Account}, 0, &credentialError{err}
	}
	acct := r.Account
	tools := 0
	wrapped := func(e Event) {
		switch e.Kind {
		case EventRateLimit:
			if g.d.Limits != nil {
				g.d.Limits.Record(ctx, acct, e.Data)
			}
		case EventTool:
			tools++
		}
		if c.Record != nil {
			c.Record.Event(e)
		}
		if on != nil {
			on(e)
		}
	}
	res, err := p.Exec(ctx, c.Box, cred, c.Req, wrapped)
	res.Provider, res.Account = r.Provider, acct
	if res.RateLimited && g.d.Limits != nil {
		g.d.Limits.RecordLimited(ctx, acct)
	}
	return res, tools, err
}

// credentialError is an account whose secret could not be opened.
type credentialError struct{ err error }

func (e *credentialError) Error() string { return e.err.Error() }
func (e *credentialError) Unwrap() error { return e.err }

// authText matches a provider refusing a credential.
var authText = regexp.MustCompile(`(?i)(invalid (x-)?api[ _-]?key|authentication[ _](error|failed)|unauthori[sz]ed|\b401\b|oauth token (has )?expired|token (has )?expired|invalid bearer token|permission_error|not connected)`)

// earlyFailure says why a call failed before it did anything worth
// keeping (its account at its limit, or refusing its credential), or ""
// when it did not fail so, or its work could have changed files.
func earlyFailure(res Result, err error, tools int, readOnly bool) string {
	if !readOnly && tools > 0 {
		return "" // it already worked on the code
	}
	var ce *credentialError
	switch {
	case errors.As(err, &ce):
		return "its credential could not be opened: " + ce.err.Error()
	case res.RateLimited:
		return ModuleName(res.Provider) + " limit reached on " + accountName(res.Account)
	case err != nil && authText.MatchString(err.Error()):
		return ModuleName(res.Provider) + " refused " + accountName(res.Account)
	case res.IsError && authText.MatchString(res.Text):
		return ModuleName(res.Provider) + " refused " + accountName(res.Account)
	}
	return ""
}

// accountName names an account in messages.
func accountName(a Account) string {
	switch {
	case a.Label != "":
		return a.Label
	case a.Credits:
		return "credits"
	}
	return "its account"
}

// describe names where a route runs: "Claude (Acme's account)".
func describe(r Route) string {
	return ModuleName(r.Provider) + " (" + accountName(r.Account) + ")"
}

// lightOf is provider id's light model.
func (g *Gateway) lightOf(id string) string {
	if p, ok := g.d.Providers.Get(id); ok {
		return p.Catalog().Model(Light)
	}
	return ""
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
