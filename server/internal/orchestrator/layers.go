package orchestrator

import (
	"context"
	"fmt"
	"path"
	"regexp"
	"slices"
	"strings"

	"agnts/internal/domain"
)

// The layer check reads the imports a change adds and flags the ones its
// repository's approved architecture does not allow: a handler that starts
// importing the store, a component that reaches into the API client. It
// reads only added lines, so code that was already there is not blamed.

var (
	goImportRe = regexp.MustCompile(`^\s*(?:import\s+)?(?:[\w.]+\s+)?"([^"\s]+)"\s*$`)
	jsImportRe = regexp.MustCompile(`(?:\bfrom\s+|\bimport\s+|\brequire\(\s*|\bimport\(\s*)['"]([^'"]+)['"]`)
	pyFromRe   = regexp.MustCompile(`^\s*from\s+(\.*[\w.]*)\s+import\b`)
	pyImportRe = regexp.MustCompile(`^\s*import\s+([\w.]+)`)
	jvImportRe = regexp.MustCompile(`^\s*import\s+(?:static\s+)?([\w.]+?)(?:\.\*)?\s*;?\s*$`)
)

// importTargets are the repository paths (directories or files without
// their extension) the added imports of file p point to; imports of
// outside packages are left out.
func importTargets(p, line, goModule string) []string {
	dir := path.Dir(p)
	switch ext := path.Ext(p); ext {
	case ".go":
		m := goImportRe.FindStringSubmatch(line)
		if m == nil || goModule == "" || !strings.HasPrefix(m[1], goModule+"/") {
			return nil
		}
		return []string{strings.TrimPrefix(m[1], goModule+"/")}
	case ".ts", ".tsx", ".js", ".jsx", ".mjs", ".cjs", ".mts", ".cts", ".vue", ".svelte":
		var out []string
		for _, m := range jsImportRe.FindAllStringSubmatch(line, -1) {
			spec := m[1]
			switch {
			case strings.HasPrefix(spec, "./"), strings.HasPrefix(spec, "../"):
				out = append(out, path.Join(dir, spec))
			case strings.HasPrefix(spec, "@/"), strings.HasPrefix(spec, "~/"):
				out = append(out, path.Join("src", spec[2:]))
			}
		}
		return out
	case ".py":
		if m := pyFromRe.FindStringSubmatch(line); m != nil {
			mod := m[1]
			if dots := len(mod) - len(strings.TrimLeft(mod, ".")); dots > 0 {
				base := dir
				for range dots - 1 {
					base = path.Dir(base)
				}
				return []string{path.Join(base, strings.ReplaceAll(mod[dots:], ".", "/"))}
			}
			return []string{strings.ReplaceAll(mod, ".", "/")}
		}
		if m := pyImportRe.FindStringSubmatch(line); m != nil {
			return []string{strings.ReplaceAll(m[1], ".", "/")}
		}
	case ".java", ".kt", ".kts":
		m := jvImportRe.FindStringSubmatch(line)
		if m == nil {
			return nil
		}
		root := ""
		for _, marker := range []string{"/java/", "/kotlin/"} {
			if i := strings.Index("/"+p, marker); i >= 0 {
				root = p[:i+len(marker)-1]
				break
			}
		}
		pkg := m[1]
		if i := strings.LastIndex(pkg, "."); i > 0 && ext == ".java" || i > 0 && len(pkg) > i+1 && pkg[i+1] >= 'A' && pkg[i+1] <= 'Z' {
			pkg = pkg[:i] // a class, not a package
		}
		return []string{path.Join(root, strings.ReplaceAll(pkg, ".", "/"))}
	}
	return nil
}

// layerFlags flags the imports files add that arch does not allow. Paths
// are relative to the repository.
func layerFlags(files []domain.FileChange, arch *domain.Architecture, goModule string) []domain.RedFlag {
	if arch == nil || len(arch.Layers) == 0 {
		return nil
	}
	var out []domain.RedFlag
	for _, f := range files {
		from := arch.LayerOf(f.Path)
		if from == nil || from.MayImport == nil || f.Diff == "" {
			continue
		}
		for _, l := range domain.AddedLines(f.Diff) {
			for _, target := range importTargets(f.Path, l.Text, goModule) {
				to := arch.LayerOfDir(target)
				if to == nil || from.Allows(to.Name) {
					continue
				}
				allowed := "nothing else"
				if len(from.MayImport) > 0 {
					allowed = strings.Join(from.MayImport, ", ")
				}
				out = append(out, domain.RedFlag{Kind: domain.FlagRuleViolation, Path: f.Path, Line: l.N,
					Text: truncate(fmt.Sprintf("layer: %s (%s) imports %s (%s); %s may import %s", f.Path, from.Name, target, to.Name, from.Name, allowed), 300)})
			}
		}
	}
	return out
}

// IsLayerFlag reports whether a red flag is the layer check's.
func IsLayerFlag(f domain.RedFlag) bool {
	return f.Kind == domain.FlagRuleViolation && strings.HasPrefix(f.Text, "layer: ")
}

var (
	goExportRe = regexp.MustCompile(`^func (?:\([^)]*\) )?([A-Z]\w*)|^type ([A-Z]\w*)|^(?:var|const) ([A-Z]\w*)`)
	jsExportRe = regexp.MustCompile(`^export\s+(?:default\s+)?(?:async\s+)?(?:function\*?|const|let|class|interface|type|enum)\s+(\w+)`)
	pyDefRe    = regexp.MustCompile(`^(?:async\s+)?def ([a-zA-Z]\w*)|^class ([A-Z]\w*)`)
	ktFunRe    = regexp.MustCompile(`^(?:public\s+)?(?:fun|class|object|interface)\s+(?:<[^>]*>\s*)?([A-Za-z]\w*)`)
	rbDefRe    = regexp.MustCompile(`^\s{0,2}def (?:self\.)?([a-z]\w*[?!]?)|^\s{0,2}(?:class|module) ([A-Z]\w*)`)
)

// newNames lists the top-level names a change adds that other code could
// call (exported functions, types, components), as "name (path)", for the
// reviewer to compare with what the code base already has.
func newNames(files []domain.FileChange, max int) []string {
	var out []string
	for _, f := range files {
		var re *regexp.Regexp
		switch path.Ext(f.Path) {
		case ".go":
			if strings.HasSuffix(f.Path, "_test.go") {
				continue
			}
			re = goExportRe
		case ".ts", ".tsx", ".js", ".jsx", ".mjs", ".mts", ".vue":
			re = jsExportRe
		case ".py":
			if strings.Contains(f.Path, "test") {
				continue
			}
			re = pyDefRe
		case ".kt", ".swift":
			re = ktFunRe
		case ".rb":
			re = rbDefRe
		default:
			continue
		}
		for _, l := range domain.AddedLines(f.Diff) {
			m := re.FindStringSubmatch(l.Text)
			if m == nil {
				continue
			}
			for _, name := range m[1:] {
				if name == "" || strings.HasPrefix(name, "Test") || name == "main" || name == "init" {
					continue
				}
				if s := name + " (" + f.Where() + ")"; !slices.Contains(out, s) && len(out) < max {
					out = append(out, s)
				}
				break
			}
		}
	}
	return out
}

// approvedArch is a repository's approved architecture, or nil.
func (o *Orchestrator) approvedArch(ctx context.Context, repoID int64) *domain.Architecture {
	if o.briefs == nil {
		return nil
	}
	b, err := o.briefs.Brief(ctx, repoID)
	if err != nil {
		return nil
	}
	return b.Arch
}

// goModule is the module path in a repository's root go.mod, or "".
func (o *Orchestrator) goModule(ctx context.Context, ws Workspace, r runRepo) string {
	b, err := ws.ReadFile(ctx, path.Join(r.Dir(), "go.mod"))
	if err != nil {
		return ""
	}
	for _, l := range strings.Split(string(b), "\n") {
		if m, ok := strings.CutPrefix(strings.TrimSpace(l), "module "); ok {
			return strings.Trim(strings.TrimSpace(m), `"`)
		}
	}
	return ""
}

// layerFindings are the layer check's flags as blocker findings, for a
// repository that blocks on them.
func layerFindings(flags []domain.RedFlag) []domain.Finding {
	var out []domain.Finding
	for _, f := range flags {
		if !IsLayerFlag(f) {
			continue
		}
		out = append(out, domain.Finding{Severity: "blocker", Category: "architecture", File: f.Path, Line: f.Line, Confidence: 1,
			Title:      "An import the repository's architecture does not allow",
			Detail:     strings.TrimPrefix(f.Text, "layer: "),
			Suggestion: "Move the logic to the layer that owns it, or go through a layer this one may import (see architecture.json)."})
	}
	return out
}
