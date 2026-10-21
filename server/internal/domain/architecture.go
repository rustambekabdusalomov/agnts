package domain

import (
	"encoding/json"
	"fmt"
	"path"
	"slices"
	"strings"
)

// Architecture is the part of a repository's brief that agnts can check
// work against: its layers and which may import which, the shared helpers
// to reuse, and the recipes for common changes with the files to copy. A
// survey drafts it with the brief; a person approves or edits both.
type Architecture struct {
	Layers  []Layer  `json:"layers"`
	Helpers []Helper `json:"helpers"`
	Recipes []Recipe `json:"recipes"`
}

// Layer is a part of the code base and the rules around it.
type Layer struct {
	Name string `json:"name"`
	// Paths are globs of the files in it ("internal/httpapi/**").
	Paths []string `json:"paths"`
	// Owns is what logic belongs in it.
	Owns string `json:"owns"`
	// MayImport are the layers its files may import; nil means any.
	MayImport []string `json:"mayImport"`
}

// Helper is a shared function, type or component work should reuse.
type Helper struct {
	Name string `json:"name"`
	Path string `json:"path"`
	For  string `json:"for"`
}

// Recipe is how a common kind of change is made here.
type Recipe struct {
	Kind  string   `json:"kind"`
	Copy  []string `json:"copy"`
	Steps []string `json:"steps"`
}

// Limits of an architecture.
const (
	archMaxLayers  = 40
	archMaxHelpers = 300
	archMaxRecipes = 40
)

// Empty reports whether there is nothing in it.
func (a Architecture) Empty() bool {
	return len(a.Layers) == 0 && len(a.Helpers) == 0 && len(a.Recipes) == 0
}

// ParseArchitecture reads an architecture from JSON and cleans it: paths
// relative to the repository, empty entries dropped, lists capped, layer
// names in mayImport that name no layer dropped. Empty text is no
// architecture (nil).
func ParseArchitecture(text string) (*Architecture, error) {
	if strings.TrimSpace(text) == "" {
		return nil, nil
	}
	var a Architecture
	if err := json.Unmarshal([]byte(text), &a); err != nil {
		return nil, fmt.Errorf("architecture.json is not valid JSON: %w", err)
	}
	a = a.Clean()
	if a.Empty() {
		return nil, nil
	}
	return &a, nil
}

// Clean returns a cleaned copy (see ParseArchitecture).
func (a Architecture) Clean() Architecture {
	var out Architecture
	names := map[string]bool{}
	for _, l := range a.Layers {
		l.Name, l.Owns = strings.TrimSpace(l.Name), strings.TrimSpace(l.Owns)
		var ps []string
		for _, p := range l.Paths {
			if p = cleanGlob(p); p != "" && !slices.Contains(ps, p) {
				ps = append(ps, p)
			}
		}
		l.Paths = ps
		if l.Name == "" || len(ps) == 0 || names[l.Name] || len(out.Layers) == archMaxLayers {
			continue
		}
		names[l.Name] = true
		out.Layers = append(out.Layers, l)
	}
	for i := range out.Layers {
		if out.Layers[i].MayImport == nil {
			continue
		}
		var mi []string
		for _, n := range out.Layers[i].MayImport {
			if n = strings.TrimSpace(n); names[n] && !slices.Contains(mi, n) {
				mi = append(mi, n)
			}
		}
		out.Layers[i].MayImport = mi
		if mi == nil {
			out.Layers[i].MayImport = []string{}
		}
	}
	for _, h := range a.Helpers {
		h.Name, h.Path, h.For = strings.TrimSpace(h.Name), CleanPath(h.Path), strings.TrimSpace(h.For)
		if h.Name != "" && h.Path != "" && len(out.Helpers) < archMaxHelpers {
			out.Helpers = append(out.Helpers, h)
		}
	}
	for _, r := range a.Recipes {
		r.Kind = strings.TrimSpace(r.Kind)
		var cp []string
		for _, p := range r.Copy {
			if p = CleanPath(p); p != "" {
				cp = append(cp, p)
			}
		}
		var st []string
		for _, s := range r.Steps {
			if s = strings.TrimSpace(s); s != "" {
				st = append(st, s)
			}
		}
		r.Copy, r.Steps = cp, st
		if r.Kind != "" && len(out.Recipes) < archMaxRecipes {
			out.Recipes = append(out.Recipes, r)
		}
	}
	return out
}

// Files are the files it names: helpers' and recipes' files to copy.
func (a Architecture) Files() []string {
	var out []string
	add := func(p string) {
		if p != "" && !slices.Contains(out, p) {
			out = append(out, p)
		}
	}
	for _, h := range a.Helpers {
		add(h.Path)
	}
	for _, r := range a.Recipes {
		for _, p := range r.Copy {
			add(p)
		}
	}
	return out
}

// Without returns a copy without the helpers and files to copy at the
// given paths (files that do not exist).
func (a Architecture) Without(missing []string) Architecture {
	if len(missing) == 0 {
		return a
	}
	out := a
	out.Helpers = slices.DeleteFunc(slices.Clone(a.Helpers), func(h Helper) bool { return slices.Contains(missing, h.Path) })
	out.Recipes = nil
	for _, r := range a.Recipes {
		r.Copy = slices.DeleteFunc(slices.Clone(r.Copy), func(p string) bool { return slices.Contains(missing, p) })
		out.Recipes = append(out.Recipes, r)
	}
	return out
}

// LayerOf returns the layer a file belongs to: the one whose glob matches
// it most specifically (the longest pattern), or nil.
func (a Architecture) LayerOf(file string) *Layer {
	var best *Layer
	bestLen := -1
	for i := range a.Layers {
		for _, g := range a.Layers[i].Paths {
			if MatchGlob(g, file) && len(g) > bestLen {
				best, bestLen = &a.Layers[i], len(g)
			}
		}
	}
	return best
}

// LayerOfDir is LayerOf for a directory (an imported package): it matches
// a file in it.
func (a Architecture) LayerOfDir(dir string) *Layer {
	return a.LayerOf(strings.TrimSuffix(dir, "/") + "/x")
}

// Allows reports whether a file in layer from may import one in to.
func (l Layer) Allows(to string) bool {
	return l.MayImport == nil || l.Name == to || slices.Contains(l.MayImport, to)
}

func cleanGlob(g string) string {
	g = strings.TrimSpace(strings.Trim(strings.TrimSpace(g), "`"))
	g = strings.TrimPrefix(g, "/workspace/")
	g = strings.TrimPrefix(g, "./")
	return strings.TrimLeft(g, "/")
}

// MatchGlob matches a path against a glob where * matches within one
// directory and ** any number of them ("internal/**", "src/*/api/*.ts").
// A glob ending in "/" or naming a directory matches everything under it.
func MatchGlob(glob, p string) bool {
	glob = strings.TrimSuffix(glob, "/")
	if !strings.ContainsAny(glob, "*?[") {
		return p == glob || strings.HasPrefix(p, glob+"/")
	}
	return matchParts(strings.Split(glob, "/"), strings.Split(p, "/"))
}

func matchParts(g, p []string) bool {
	for len(g) > 0 {
		if g[0] == "**" {
			if len(g) == 1 {
				return true
			}
			for i := 0; i <= len(p); i++ {
				if matchParts(g[1:], p[i:]) {
					return true
				}
			}
			return false
		}
		if len(p) == 0 {
			return false
		}
		if ok, err := path.Match(g[0], p[0]); err != nil || !ok {
			return false
		}
		g, p = g[1:], p[1:]
	}
	return len(p) == 0
}
