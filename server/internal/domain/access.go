package domain

import (
	"context"
	"errors"
	"fmt"
	"slices"
	"strings"
	"sync"
)

// Access is the coding modules a person may use: Muse Code, Claude Code,
// Codex. The first is their default module: settings that name a module
// they cannot use run on its models instead.
type Access struct {
	Modules []string
}

// Allows reports whether the person may use module p.
func (a Access) Allows(p string) bool { return slices.Contains(a.Modules, p) }

// Primary is the default module, "" when the person has none.
func (a Access) Primary() string {
	if len(a.Modules) == 0 {
		return ""
	}
	return a.Modules[0]
}

// None reports whether the person may use no module at all.
func (a Access) None() bool { return len(a.Modules) == 0 }

// ModulesConfig is the platform Admin's general choice: the modules this
// server offers (within the ceiling, AGNTS_PROVIDERS) and the ones a person
// gets unless an Admin set theirs.
type ModulesConfig struct {
	Enabled []string `json:"enabled"`
	Default []string `json:"default"`
}

// ResolveAccess is a person's access: their own list when an Admin set one
// (override non-nil), else the default; either kept to the modules the
// server can run and the Admin enabled, in its order.
func ResolveAccess(ceiling []string, cfg ModulesConfig, override []string) Access {
	list := cfg.Default
	if override != nil {
		list = override
	}
	out := []string{}
	for _, p := range list {
		if slices.Contains(ceiling, p) && slices.Contains(cfg.Enabled, p) && !slices.Contains(out, p) {
			out = append(out, p)
		}
	}
	return Access{Modules: out}
}

// knownModule reports whether p names a module agnts can run.
func knownModule(p string) bool {
	return p == ProviderMuse || p == ProviderClaude || p == ProviderCodex
}

// ValidateModuleList checks a person's modules or the default: known,
// enabled, no repeats, and not starting with Codex, which has no light and
// strong models to stand in for the others. An empty list is allowed (no
// modules).
func ValidateModuleList(list, enabled []string) error {
	seen := map[string]bool{}
	for i, p := range list {
		switch {
		case !knownModule(p):
			return fmt.Errorf("unknown module %q (want muse, claude or codex)", p)
		case seen[p]:
			return fmt.Errorf("module %q is listed twice", p)
		case !slices.Contains(enabled, p):
			return fmt.Errorf("module %q is not enabled on this server", p)
		case i == 0 && p == ProviderCodex:
			return errors.New("codex cannot be the default module: put muse or claude first")
		}
		seen[p] = true
	}
	return nil
}

// Validate checks the Admin's choice against the modules the server can
// run (ceiling).
func (c ModulesConfig) Validate(ceiling []string) error {
	if len(c.Enabled) == 0 {
		return errors.New("enable at least one module")
	}
	seen := map[string]bool{}
	for _, p := range c.Enabled {
		switch {
		case !knownModule(p):
			return fmt.Errorf("unknown module %q (want muse, claude or codex)", p)
		case seen[p]:
			return fmt.Errorf("module %q is listed twice", p)
		case !slices.Contains(ceiling, p):
			return fmt.Errorf("this server cannot run %s (AGNTS_PROVIDERS is %s)", p, strings.Join(ceiling, ","))
		}
		seen[p] = true
	}
	return ValidateModuleList(c.Default, c.Enabled)
}

var defaultAccess = struct {
	sync.RWMutex
	a Access
}{a: Access{Modules: []string{ProviderMuse}}}

// SetDefaultAccess records the access of a person no Admin set modules for
// (the modules service keeps it current). Messages and jobs that do not
// belong to a person use it.
func SetDefaultAccess(a Access) {
	defaultAccess.Lock()
	defaultAccess.a = Access{Modules: slices.Clone(a.Modules)}
	defaultAccess.Unlock()
}

// DefaultAccess is the access of a person no Admin set modules for.
func DefaultAccess() Access {
	defaultAccess.RLock()
	defer defaultAccess.RUnlock()
	return Access{Modules: slices.Clone(defaultAccess.a.Modules)}
}

type accessKey struct{}

// WithAccess returns ctx running for a person with access a: the run's
// person, or the one asking the assistant.
func WithAccess(ctx context.Context, a Access) context.Context {
	return context.WithValue(ctx, accessKey{}, a)
}

// AccessIn returns the access set on ctx; ok is false when none was.
func AccessIn(ctx context.Context) (Access, bool) {
	a, ok := ctx.Value(accessKey{}).(Access)
	return a, ok
}

// AccessOf returns the access set on ctx, else the default one. Model
// choices take the run's access explicitly; this is for wording messages.
func AccessOf(ctx context.Context) Access {
	if a, ok := AccessIn(ctx); ok {
		return a
	}
	return DefaultAccess()
}

// NotAllowedError is a run on a module its person may not use.
type NotAllowedError struct {
	Module string
}

func (e *NotAllowedError) Error() string {
	return ModuleName(e.Module) + " is not enabled for this person; ask an Admin, or pick another model"
}

// ModuleName names a module in messages people read.
func ModuleName(p string) string {
	switch p {
	case ProviderMuse:
		return "Muse"
	case ProviderCodex:
		return "Codex"
	case ProviderClaude:
		return "Claude"
	}
	return "the coding agent"
}
