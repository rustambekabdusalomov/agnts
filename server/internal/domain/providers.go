package domain

import (
	"regexp"
	"slices"
	"strings"
	"sync"
)

// Providers are the coding tools agnts can run: Muse Code (Meta), Claude
// Code (Anthropic) and Codex CLI (OpenAI).
const (
	ProviderMuse   = "muse"
	ProviderClaude = "claude"
	ProviderCodex  = "codex"
)

// MusePrefix marks a model as one Muse Code runs ("muse:<model>").
const MusePrefix = "muse:"

// Muse models a setting may name. The short names map to Muse model ids
// in the runner.
const (
	MuseSpark  = "muse:spark"
	MuseWonder = "muse:wonder"
)

// museModel matches "muse:" and a model name or id.
var museModel = regexp.MustCompile(`^muse:[a-z0-9][a-z0-9._-]{0,63}$`)

// IsMuse reports whether m runs on Muse Code.
func IsMuse(m string) bool { return strings.HasPrefix(m, MusePrefix) }

// ProviderOf names the tool a model runs on.
func ProviderOf(m string) string {
	switch {
	case IsMuse(m):
		return ProviderMuse
	case IsCodex(m):
		return ProviderCodex
	}
	return ProviderClaude
}

var providers = struct {
	sync.RWMutex
	list []string
}{list: []string{ProviderMuse}}

// SetProviders sets the providers this server offers, the first being the
// default (AGNTS_PROVIDERS, "muse" unless set). Called once at startup.
func SetProviders(list []string) {
	var out []string
	for _, p := range list {
		p = strings.TrimSpace(strings.ToLower(p))
		if (p == ProviderMuse || p == ProviderClaude || p == ProviderCodex) && !slices.Contains(out, p) {
			out = append(out, p)
		}
	}
	if len(out) == 0 {
		out = []string{ProviderMuse}
	}
	providers.Lock()
	providers.list = out
	providers.Unlock()
}

// EnabledProviders returns the providers this server offers.
func EnabledProviders() []string {
	providers.RLock()
	defer providers.RUnlock()
	return slices.Clone(providers.list)
}

// PrimaryProvider is the default provider.
func PrimaryProvider() string { return EnabledProviders()[0] }

// ProviderEnabled reports whether p is offered here.
func ProviderEnabled(p string) bool { return slices.Contains(EnabledProviders(), p) }

// StrongModel and LightModel are the primary provider's models for hard
// and simple work: the review's auto choice, Swagger tests, helpers.
func StrongModel() string {
	if PrimaryProvider() == ProviderMuse {
		return MuseWonder
	}
	return "opus"
}

// LightModel is the primary provider's model for simple work.
func LightModel() string {
	if PrimaryProvider() == ProviderMuse {
		return MuseSpark
	}
	return "sonnet"
}

// IsStrong reports whether m is a top-tier model.
func IsStrong(m string) bool {
	return m == "opus" || m == MuseWonder || strings.HasPrefix(m, "muse:muse-wonder")
}

// AvailableModels lists the models settings may pick from on this server.
func AvailableModels() []string {
	var out []string
	for _, p := range EnabledProviders() {
		switch p {
		case ProviderMuse:
			out = append(out, MuseSpark, MuseWonder)
		case ProviderClaude:
			out = append(out, Models...)
		}
	}
	return out
}

// EffectiveModel maps a saved model whose provider is hidden on this
// server to the primary provider's model of the same weight, so settings
// saved before the switch keep working.
func EffectiveModel(m string) string {
	if m == "" || m == ModelAuto || ProviderEnabled(ProviderOf(m)) {
		return m
	}
	if m == "opus" || IsStrong(m) {
		return StrongModel()
	}
	return LightModel()
}
