// Package aitest helps tests run features through the AI gateway without
// real agents: a box that scripts its answers (Scripted) gets them back
// through providers that stand in for Muse, Claude and Codex.
package aitest

import (
	"context"
	"errors"

	"agnts/internal/ai"
	"agnts/internal/ai/providers/claudecode"
	"agnts/internal/ai/providers/codex"
	"agnts/internal/ai/providers/musecode"
)

// Scripted is a box that answers agent calls itself: a test's fake
// workspace.
type Scripted interface {
	Claude(ctx context.Context, req ai.Request, on func(ai.Event)) (ai.Result, error)
}

// Provider stands in for a real provider: same id, catalog and
// capabilities, but Exec asks the box (a Scripted) for the answer.
type Provider struct {
	real ai.Provider
	// Ears, when set, hears spoken clips (and gives the provider
	// ai.CapAudio).
	Ears func(ctx context.Context, cred ai.Credential, wav []byte) (string, error)
	// Meeting, when set, hears meetings.
	Meeting func(ctx context.Context, cred ai.Credential, audio []byte, ext string) ([]ai.Segment, error)
}

var (
	_ ai.Provider = (*Provider)(nil)
	_ ai.Hearer   = (*Provider)(nil)
)

// Muse, Claude and Codex return stand-ins for the three providers.
func Muse() *Provider   { return &Provider{real: musecode.New(musecode.Config{})} }
func Claude() *Provider { return &Provider{real: claudecode.New(nil)} }
func Codex() *Provider {
	return &Provider{real: codex.New(map[ai.Tier]string{ai.Light: "gpt-5-mini", ai.Strong: "gpt-5"})}
}

// Providers returns a registry of the three stand-ins.
func Providers() *ai.Registry { return ai.NewRegistry(Muse(), Claude(), Codex()) }

func (p *Provider) ID() string          { return p.real.ID() }
func (p *Provider) Name() string        { return p.real.Name() }
func (p *Provider) Catalog() ai.Catalog { return p.real.Catalog() }
func (p *Provider) FreeCredits() bool   { return p.real.FreeCredits() }

// Caps implements ai.Provider.
func (p *Provider) Caps() ai.Caps {
	c := p.real.Caps()
	if p.Ears != nil || p.Meeting != nil {
		c = append(c, ai.CapAudio)
	}
	return c
}

// Exec implements ai.Provider: the box answers.
func (p *Provider) Exec(ctx context.Context, box ai.Box, _ ai.Credential, req ai.Request, on func(ai.Event)) (ai.Result, error) {
	s, ok := box.(Scripted)
	if !ok {
		return ai.Result{}, errors.New("aitest: the box does not script agent calls")
	}
	if on == nil {
		on = func(ai.Event) {}
	}
	return s.Claude(ctx, req, on)
}

// HearClip implements ai.Hearer.
func (p *Provider) HearClip(ctx context.Context, cred ai.Credential, wav []byte) (string, error) {
	if p.Ears == nil {
		return "", errors.New("aitest: no ears")
	}
	return p.Ears(ctx, cred, wav)
}

// Hear implements ai.Hearer.
func (p *Provider) Hear(ctx context.Context, cred ai.Credential, audio []byte, ext string) ([]ai.Segment, error) {
	if p.Meeting == nil {
		return nil, errors.New("aitest: no meeting ears")
	}
	return p.Meeting(ctx, cred, audio, ext)
}
