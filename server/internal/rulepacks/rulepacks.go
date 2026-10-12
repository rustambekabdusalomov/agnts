// Package rulepacks holds agnts's starter rules: a few specific, checkable
// conventions per language that a team can adopt when it adds a
// repository. They are adapted from ECC's language rules (packs/NOTICE)
// and only ever offered as suggestions: nothing applies until a person
// adopts it.
package rulepacks

import (
	"embed"
	"encoding/json"
	"fmt"
	"slices"
	"sort"

	"agnts/internal/domain"
)

//go:embed packs/*.json
var files embed.FS

// Rule is one starter rule.
type Rule struct {
	Title   string              `json:"title"`
	Body    string              `json:"body"`
	Enforce *domain.RuleEnforce `json:"enforce,omitempty"`
}

// Pack is a language's starter rules.
type Pack struct {
	ID    string `json:"-"` // go, typescript, ...
	Name  string `json:"name"`
	Rules []Rule `json:"rules"`
}

// Source is what rules created from pack id carry as their source.
func Source(id string) string { return "pack:" + id }

// Get returns the pack with this id.
func Get(id string) (Pack, error) {
	b, err := files.ReadFile("packs/" + id + ".json")
	if err != nil {
		return Pack{}, fmt.Errorf("no starter pack %q", id)
	}
	var p Pack
	if err := json.Unmarshal(b, &p); err != nil {
		return Pack{}, fmt.Errorf("starter pack %s: %w", id, err)
	}
	p.ID = id
	return p, nil
}

// toolPacks maps toolchain tools to the packs that fit them.
var toolPacks = map[string][]string{
	"go": {"go"}, "node": {"typescript"}, "bun": {"typescript"}, "deno": {"typescript"},
	"python": {"python"}, "uv": {"python"}, "java": {"java"}, "maven": {"java"}, "gradle": {"java", "kotlin"},
	"kotlin": {"kotlin"}, "rust": {"rust"}, "ruby": {"ruby"}, "php": {"php"}, "dotnet": {"csharp"},
	"swift": {"swift"}, "dart": {"dart"}, "flutter": {"dart"},
}

// For returns the ids of the packs that fit a repository's toolchains.
func For(tcs []domain.Toolchain) []string {
	var out []string
	for _, tc := range tcs {
		for _, id := range toolPacks[tc.Tool] {
			if !slices.Contains(out, id) {
				out = append(out, id)
			}
		}
	}
	sort.Strings(out)
	return out
}
