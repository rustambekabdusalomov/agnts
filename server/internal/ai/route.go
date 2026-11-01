package ai

import (
	"context"
	"fmt"
	"time"

	"agnts/internal/domain"
)

// More purposes, besides ticket stages and domain's background ones.
const (
	PurposeMeeting    Purpose = "meeting"
	PurposeVoice      Purpose = "voice"
	PurposeAutoResume Purpose = "auto_resume"
)

// Policy is what a purpose may run on.
type Policy struct {
	// Credits: it may run on agnts's key, paid with free credits (for
	// providers that take them) or the workspace's credits.
	Credits bool
}

// PolicyOf is the policy of purpose p. Work the scheduler runs (ticket
// stages, second opinions, documents, reflection, rule reviews, briefs)
// and meeting notes may run on credits; answers, spoken questions,
// translation, detection and the usage probe run on connected accounts
// only, as they always have.
func PolicyOf(p Purpose) Policy {
	switch p {
	case domain.PurposeAssistant, PurposeVoice, domain.PurposeTranslate, domain.PurposeDetect, PurposeUsageProbe:
		return Policy{}
	}
	return Policy{Credits: true}
}

// Who a call is for.
type Who struct {
	// Workspace is the workspace it runs in; 0: the one ctx acts in.
	Workspace int64
	// Person is whose modules it may use (the ticket's member, else the
	// workspace's default member, else the owner; or the person asking).
	// 0: the workspace's default person.
	Person int64
	// Member is whose account it runs on in per-member mode; nil: the
	// person's.
	Member *int64
	// Access is the person's modules when the caller already read them.
	Access *domain.Access
}

// Want is what a call needs.
type Want struct {
	// Model is the model as settings store it ("" for the provider's
	// default); Provider names the provider instead.
	Model    string
	Provider string
	// Needs are capabilities the provider must have.
	Needs Caps
	// Pin runs on exactly this account (the usage probe).
	Pin *Account
}

// Route is where a call runs.
type Route struct {
	Who      Who
	Purpose  Purpose
	Provider string
	Account  Account
	Caps     Caps
}

// Hold says why a call cannot run now, and until when if known.
type Hold struct {
	Why   string
	Until time.Time
	// Err is the cause when it is an error, not a wait (a module the
	// person may not use, a failure to read).
	Err error
	// Limited: the account is at its usage limit (errors.Is ErrLimit).
	Limited bool
}

func (h *Hold) Error() string {
	if h.Err != nil {
		return h.Err.Error()
	}
	return h.Why
}

func (h *Hold) Unwrap() error { return h.Err }

// Is makes a hold at a usage limit ErrLimit.
func (h *Hold) Is(target error) bool { return target == ErrLimit && h.Limited }

// Accounts picks and opens the accounts calls run on.
type Accounts interface {
	// Pick returns the account a call of member (nil: the workspace's
	// default member) in w uses now on provider; credits says whether it
	// may run on agnts's key. ok is false when none is usable: why says
	// so, until when it may be (zero when unknown).
	Pick(ctx context.Context, w domain.Workspace, member *int64, provider string, credits bool) (acct Account, ok bool, why string, until time.Time)
	// Credential returns acct's secret.
	Credential(ctx context.Context, acct Account) (Credential, error)
}

// Workspaces reads workspaces' account choices.
type Workspaces interface {
	ByID(ctx context.Context, id int64) (domain.Workspace, error)
}

// Limits keeps the accounts' usage limits.
type Limits interface {
	// Paused reports whether acct is at its limit, and until when.
	Paused(ctx context.Context, acct Account, s domain.Settings) (bool, time.Time)
	// Record stores a rate-limit reading of acct (data is the raw event).
	Record(ctx context.Context, acct Account, data map[string]any)
	// RecordLimited notes that acct refused a call at its limit.
	RecordLimited(ctx context.Context, acct Account)
}

// Settings reads the settings of the workspace ctx acts in.
type Settings interface {
	Get(ctx context.Context) (domain.Settings, error)
}

// Access returns person's modules.
func (g *Gateway) Access(ctx context.Context, person int64) (domain.Access, error) {
	if g.d.Access == nil || person <= 0 {
		return domain.DefaultAccess(), nil
	}
	return g.d.Access.For(ctx, person)
}

// provider resolves which provider want names.
func (g *Gateway) provider(want Want) (Provider, error) {
	if len(want.Needs) > 0 && want.Model == "" && want.Provider == "" {
		if g.d.Providers != nil {
			for _, id := range g.d.Providers.IDs() {
				p, _ := g.d.Providers.Get(id)
				if p.Caps().Has(want.Needs...) {
					return p, nil
				}
			}
		}
		return nil, fmt.Errorf("no provider here can %v", want.Needs)
	}
	if want.Provider != "" {
		if g.d.Providers == nil {
			return nil, fmt.Errorf("%s is not available on this server", ModuleName(want.Provider))
		}
		p, ok := g.d.Providers.Get(want.Provider)
		if !ok {
			return nil, fmt.Errorf("%s is not available on this server", ModuleName(want.Provider))
		}
		return p, nil
	}
	return g.providerFor(want.Model)
}

// Route decides where a call runs: the provider of its model, the
// person may use it, and the account it runs on (the workspace's or the
// member's connection, else credits when the purpose allows them).
func (g *Gateway) Route(ctx context.Context, who Who, purpose Purpose, want Want) (Route, *Hold) {
	p, err := g.provider(want)
	if err != nil {
		return Route{}, &Hold{Why: err.Error(), Err: err}
	}
	r := Route{Who: who, Purpose: purpose, Provider: p.ID(), Caps: p.Caps()}
	if want.Pin != nil {
		r.Account = *want.Pin
		r.Account.Provider = p.ID()
		return r, nil
	}
	if r.Who.Workspace == 0 {
		r.Who.Workspace = domain.WorkspaceOf(ctx)
	}
	perAccount := g.d.Accounts != nil && g.d.Workspaces != nil
	var w domain.Workspace
	if perAccount {
		var err error
		if w, err = g.d.Workspaces.ByID(ctx, r.Who.Workspace); err != nil {
			return Route{}, &Hold{Why: "could not read the workspace: " + err.Error(), Err: err}
		}
		if r.Who.Person == 0 {
			r.Who.Person = w.RunPerson(nil) // the workspace's default member, else its owner
		}
	}
	// Hearing is not coding: the person's modules do not limit it.
	if !want.Needs.Has(CapAudio) {
		if err := g.allowed(ctx, r.Who, p.ID()); err != nil {
			return Route{}, &Hold{Why: err.Error(), Err: err}
		}
	}
	if !perAccount {
		// One account for everything (installs without per-workspace
		// accounts): only its limit can hold a call.
		r.Account = Account{Provider: p.ID()}
		if g.d.Limits != nil && p.ID() != Codex {
			if paused, until := g.d.Limits.Paused(ctx, r.Account, g.settings(ctx)); paused {
				return Route{}, limitHold(p.ID(), until)
			}
		}
		return r, nil
	}
	member := who.Member
	if member == nil && who.Person > 0 && w.ClaudeMode == domain.ClaudePerMember {
		person := who.Person
		member = &person
	}
	acct, ok, why, until := g.d.Accounts.Pick(ctx, w, member, p.ID(), PolicyOf(purpose).Credits)
	if !ok {
		return Route{}, &Hold{Why: why, Until: until}
	}
	acct.Provider = p.ID()
	r.Account = acct
	return r, nil
}

// limitHold is a call held at its account's limit.
func limitHold(provider string, until time.Time) *Hold {
	why := ModuleName(provider) + " limit reached"
	if !until.IsZero() {
		why += "; resumes at " + until.Format("15:04")
	}
	return &Hold{Why: why, Until: until, Limited: true}
}

// settings reads the workspace's settings (usage limits), defaults when
// they cannot be read.
func (g *Gateway) settings(ctx context.Context) domain.Settings {
	if g.d.Settings != nil {
		if s, err := g.d.Settings.Get(ctx); err == nil {
			return s
		}
	}
	return domain.DefaultSettings()
}

// Admission is where a run's calls go: one route per provider its stages
// use, decided before it starts.
type Admission struct {
	Who     Who
	Purpose Purpose
	Access  domain.Access
	// Primary is the person's default module: the run's main account is
	// its route's.
	Primary string
	Routes  map[string]Route
}

// Main is the route of the run's default module.
func (a Admission) Main() (Route, bool) {
	r, ok := a.Routes[a.Primary]
	return r, ok
}

// OnCredits reports whether any of the run's routes runs on credits.
func (a Admission) OnCredits() bool {
	for _, r := range a.Routes {
		if r.Account.Credits {
			return true
		}
	}
	return false
}

// AdmitCache keeps routes between the admissions of one scheduling turn,
// so items of the same person and member are decided once.
type AdmitCache map[admitKey]admitted

type admitKey struct {
	ws, person, member int64
	purpose            Purpose
	provider           string
}

type admitted struct {
	r Route
	h *Hold
}

// Admit decides, before a run starts, where every call it will make runs:
// one route per provider in providers. It fails with the first provider
// that cannot run.
func (g *Gateway) Admit(ctx context.Context, who Who, purpose Purpose, access domain.Access, providers []string, cache AdmitCache) (Admission, *Hold) {
	who.Access = &access
	if who.Workspace == 0 {
		who.Workspace = domain.WorkspaceOf(ctx)
	}
	a := Admission{Who: who, Purpose: purpose, Access: access, Primary: access.Primary(), Routes: map[string]Route{}}
	var member int64
	if who.Member != nil {
		member = *who.Member
	}
	for _, id := range providers {
		k := admitKey{ws: who.Workspace, person: who.Person, member: member, purpose: purpose, provider: id}
		got, ok := cache[k]
		if !ok {
			got.r, got.h = g.Route(ctx, who, purpose, Want{Provider: id})
			if cache != nil {
				cache[k] = got
			}
		}
		if got.h != nil {
			return a, got.h
		}
		a.Routes[id] = got.r
	}
	return a, nil
}

type admissionKey struct{}

// WithAdmission returns ctx running a run admitted as a: its calls go on
// a's routes.
func WithAdmission(ctx context.Context, a Admission) context.Context {
	return context.WithValue(ctx, admissionKey{}, a)
}

// AdmissionOf returns the admission of the run ctx belongs to.
func AdmissionOf(ctx context.Context) (Admission, bool) {
	a, ok := ctx.Value(admissionKey{}).(Admission)
	return a, ok
}

// AccountFor returns the account the run in ctx uses on the provider of
// model; ok is false outside an admitted run, or for a provider it did
// not admit.
func AccountFor(ctx context.Context, model string) (Account, bool) {
	a, ok := AdmissionOf(ctx)
	if !ok {
		return Account{}, false
	}
	id := ProviderOf(model)
	if id == "" {
		id = Claude
	}
	r, ok := a.Routes[id]
	return r.Account, ok
}
