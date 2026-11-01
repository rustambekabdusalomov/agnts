package ai

import (
	"context"
	"fmt"
	"slices"
	"sync"
)

// Cap is something a provider can do.
type Cap string

const (
	// CapEffort means it takes Request.Effort.
	CapEffort Cap = "effort"
	// CapResume means it continues a session (Request.Resume).
	CapResume Cap = "resume"
	// CapInRunGuard means agnts-guard's hooks check its tool calls during
	// the run (agnts's checks after a run apply to every provider).
	CapInRunGuard Cap = "in_run_guard"
	// CapSteer means it takes messages from the people following a run
	// (Request.Steer).
	CapSteer Cap = "steer"
	// CapAsk means it asks them about tool calls (Request.Ask).
	CapAsk Cap = "ask"
	// CapAudio means it hears audio (Hearer).
	CapAudio Cap = "audio"
)

// Caps is a set of capabilities.
type Caps []Cap

// Has reports whether c holds every one of want.
func (c Caps) Has(want ...Cap) bool {
	for _, w := range want {
		if !slices.Contains(c, w) {
			return false
		}
	}
	return true
}

// Catalog is a provider's models.
type Catalog interface {
	// Valid reports whether name (without the provider's prefix) is a
	// model it runs.
	Valid(name string) bool
	// Listed is the models people pick from, as stored ("muse:spark",
	// "opus"); a provider whose models are free-form lists its tiers'.
	Listed() []string
	// Model is the provider's model for tier as stored, "" when it has
	// none.
	Model(t Tier) string
	// TierOf is the tier of one of its models (name without prefix).
	TierOf(name string) Tier
}

// Provider is one AI coding tool behind the gateway.
type Provider interface {
	// ID is its module id: muse, claude or codex.
	ID() string
	// Name names it in messages people read.
	Name() string
	Catalog() Catalog
	Caps() Caps
	// FreeCredits reports whether free credits (an Admin's grant, Muse
	// ledger money) may pay for it.
	FreeCredits() bool
	// Exec runs one invocation in box with cred, calling on for each
	// step of its stream.
	Exec(ctx context.Context, box Box, cred Credential, req Request, on func(Event)) (Result, error)
}

// Hearer is a provider that hears audio: a meeting's recording, or a
// spoken question.
type Hearer interface {
	// Hear returns what was said in a meeting's audio (an Ogg or MP4
	// file), with times from the file's start.
	Hear(ctx context.Context, cred Credential, audio []byte, ext string) ([]Segment, error)
	// HearClip returns what was said in a short WAV recording.
	HearClip(ctx context.Context, cred Credential, wav []byte) (string, error)
}

// Registry holds the providers this server has.
type Registry struct {
	mu    sync.RWMutex
	order []string
	by    map[string]Provider
}

// NewRegistry returns a registry of ps, in their order.
func NewRegistry(ps ...Provider) *Registry {
	r := &Registry{by: map[string]Provider{}}
	for _, p := range ps {
		r.Register(p)
	}
	return r
}

// Register adds p, replacing a provider with its id.
func (r *Registry) Register(p Provider) {
	r.mu.Lock()
	defer r.mu.Unlock()
	if _, ok := r.by[p.ID()]; !ok {
		r.order = append(r.order, p.ID())
	}
	r.by[p.ID()] = p
}

// Get returns the provider with id.
func (r *Registry) Get(id string) (Provider, bool) {
	r.mu.RLock()
	defer r.mu.RUnlock()
	p, ok := r.by[id]
	return p, ok
}

// For returns the provider a stored model runs on.
func (r *Registry) For(model string) (Provider, error) {
	id := ProviderOf(model)
	if id == "" {
		return nil, fmt.Errorf("model %q names no provider", model)
	}
	p, ok := r.Get(id)
	if !ok {
		return nil, fmt.Errorf("%s is not available on this server", ModuleName(id))
	}
	return p, nil
}

// IDs lists the providers, in registration order.
func (r *Registry) IDs() []string {
	r.mu.RLock()
	defer r.mu.RUnlock()
	return slices.Clone(r.order)
}

// ModuleName names a module in messages people read.
func ModuleName(id string) string {
	switch id {
	case Muse:
		return "Muse"
	case Codex:
		return "Codex"
	case Claude:
		return "Claude"
	}
	return "the coding agent"
}
