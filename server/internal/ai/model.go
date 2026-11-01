package ai

import (
	"strings"

	"agnts/internal/domain"
)

// Model prefixes: "muse:<model>" runs on Muse Code, "codex:<model>" on
// Codex; any other model is Claude Code's.
const (
	MusePrefix  = domain.MusePrefix
	CodexPrefix = "codex:"
)

// Provider ids.
const (
	Muse   = domain.ProviderMuse
	Claude = domain.ProviderClaude
	Codex  = domain.ProviderCodex
)

// Tier is how capable a model is, across providers: a feature that needs
// a strong model gets the strong model of whichever provider runs it.
type Tier string

const (
	Light  Tier = "light"
	Strong Tier = "strong"
	// Auto picks from the work: the review's choice by complexity.
	Auto Tier = "auto"
)

// TierPrefix marks a setting that names a tier instead of a model
// ("tier:strong"): the gateway picks the provider.
const TierPrefix = "tier:"

// ModelRef is a model of a provider. Settings store it as a string:
// "muse:spark", "codex:gpt-5", "opus".
type ModelRef struct {
	Provider string
	Name     string // the model as its provider names it, without a prefix
}

// ParseModel reads a stored model. A tier ("tier:strong", or "auto", the
// review's old name for tier:auto) has no provider.
func ParseModel(s string) (ModelRef, Tier) {
	switch {
	case s == "":
		return ModelRef{}, ""
	case s == domain.ModelAuto:
		return ModelRef{}, Auto
	case strings.HasPrefix(s, TierPrefix):
		return ModelRef{}, Tier(strings.TrimPrefix(s, TierPrefix))
	case strings.HasPrefix(s, MusePrefix):
		return ModelRef{Provider: Muse, Name: strings.TrimPrefix(s, MusePrefix)}, ""
	case strings.HasPrefix(s, CodexPrefix):
		return ModelRef{Provider: Codex, Name: strings.TrimPrefix(s, CodexPrefix)}, ""
	}
	return ModelRef{Provider: Claude, Name: s}, ""
}

// String is the model as settings store it.
func (m ModelRef) String() string {
	switch m.Provider {
	case "":
		return ""
	case Muse:
		return MusePrefix + m.Name
	case Codex:
		return CodexPrefix + m.Name
	}
	return m.Name
}

// IsZero reports whether m names no model.
func (m ModelRef) IsZero() bool { return m.Provider == "" }

// ProviderOf names the provider a stored model runs on, "" for a tier or
// nothing.
func ProviderOf(s string) string {
	m, _ := ParseModel(s)
	return m.Provider
}
