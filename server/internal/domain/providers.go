package domain

import (
	"regexp"
	"slices"
	"strings"
	"sync"
)

// Providers are the coding tools agnts can run: Muse Code (Meta), Claude
// Code (Anthropic) and Codex CLI (OpenAI). Which of them a person may use
// is their Access.
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

var ceiling = struct {
	sync.RWMutex
	list []string
}{list: []string{ProviderMuse}}

// SetProviders sets the modules this server can run (AGNTS_PROVIDERS, "muse"
// unless set): the ceiling the Admin's choice stays within. It also makes
// them the default access until the modules service loads the Admin's
// choice. Called once at startup.
func SetProviders(list []string) {
	var out []string
	for _, p := range list {
		p = strings.TrimSpace(strings.ToLower(p))
		if knownModule(p) && !slices.Contains(out, p) {
			out = append(out, p)
		}
	}
	if len(out) == 0 {
		out = []string{ProviderMuse}
	}
	ceiling.Lock()
	ceiling.list = out
	ceiling.Unlock()
	SetDefaultAccess(Access{Modules: out})
}

// Ceiling returns the modules this server can run.
func Ceiling() []string {
	ceiling.RLock()
	defer ceiling.RUnlock()
	return slices.Clone(ceiling.list)
}

// ToolName names a's default tool in messages people read: "Muse" when
// Muse Code is the default, else "Claude".
func ToolName(a Access) string {
	if a.Primary() == ProviderMuse {
		return "Muse"
	}
	return "Claude"
}

// AgentName names the agent that runs model in messages people read:
// "Muse", "Codex" or "Claude"; with no model, the default tool.
func AgentName(model string) string {
	switch {
	case model == "":
		return ToolName(DefaultAccess())
	case IsMuse(model):
		return "Muse"
	case IsCodex(model):
		return "Codex"
	}
	return "Claude"
}

// StrongModel and LightModel are a's default module's models for hard and
// simple work: the review's auto choice, Swagger tests, helpers.
func StrongModel(a Access) string {
	if a.Primary() == ProviderMuse {
		return MuseWonder
	}
	return "opus"
}

// LightModel is a's default module's model for simple work.
func LightModel(a Access) string {
	if a.Primary() == ProviderMuse {
		return MuseSpark
	}
	return "sonnet"
}

// IsStrong reports whether m is a top-tier model.
func IsStrong(m string) bool {
	return m == "opus" || m == MuseWonder || strings.HasPrefix(m, "muse:muse-wonder")
}

// AvailableModels lists the models settings may pick from for a. Codex
// models are free-form (codex:<model>), so they are not listed.
func AvailableModels(a Access) []string {
	var out []string
	for _, p := range a.Modules {
		switch p {
		case ProviderMuse:
			out = append(out, MuseSpark, MuseWonder)
		case ProviderClaude:
			out = append(out, Models...)
		}
	}
	return out
}

// EffectiveModel maps a model of a module a may not use to a's default
// module, so settings saved for one person keep working for another and
// nothing is rewritten in storage. On Claude it keeps the tier (Wonder
// becomes opus, the rest sonnet). On Muse it is always Spark: Claude
// settings often name opus for analysis and coding, and Wonder for every
// run would cost about three times as much; hard work still reaches Wonder
// through the review's auto choice and a stuck session's escalation. A
// Codex model maps to the light model.
//
// A tier is the default module's model of that tier.
func EffectiveModel(a Access, m string) string {
	switch {
	case m == TierStrong && !a.None():
		return StrongModel(a)
	case m == TierLight && !a.None():
		return LightModel(a)
	}
	if m == "" || m == ModelAuto || a.Allows(ProviderOf(m)) || a.None() {
		return m
	}
	if IsStrong(m) && a.Primary() != ProviderMuse {
		return StrongModel(a)
	}
	return LightModel(a)
}

// EffectiveModels applies EffectiveModel to every stage.
func (m StageModels) EffectiveModels(a Access) StageModels {
	return StageModels{Analyze: EffectiveModel(a, m.Analyze), Coding: EffectiveModel(a, m.Coding), Retry: EffectiveModel(a, m.Retry),
		Helper: EffectiveModel(a, m.Helper), Learn: EffectiveModel(a, m.Learn), Review: EffectiveModel(a, m.Review), Preview: EffectiveModel(a, m.Preview)}
}
