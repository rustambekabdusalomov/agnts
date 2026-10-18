package orchestrator

import (
	"context"
	"regexp"
	"slices"
	"strconv"
	"strings"

	"agnts/internal/domain"
	"agnts/internal/toolchain"
)

// In a ticket of several repositories, one Go module may require another
// of the same ticket (an API gateway and its protos). go build in the first
// would fetch the released version of the second and never see the change
// next to it, so the checks could not pass until it was released. A
// go.work in /workspace, outside every repository and so never committed,
// makes go use the local folders instead, as a replace would without
// touching go.mod.

var (
	goModuleLineRe = regexp.MustCompile(`(?m)^module\s+"?([^"\s]+)"?`)
	goVersionRe    = regexp.MustCompile(`(?m)^go\s+(\d+(?:\.\d+){1,2})`)
	goRequiredRe   = regexp.MustCompile(`(?m)^\s*(?:require\s+)?"?([a-z0-9.-]+\.[a-z]{2,}/[^"\s]+)"?\s+v\d\S*`)
)

// goWork reads the run's repositories and returns their go.work (see
// goWork), noting on the ticket which build against which; "" when none
// does, or a tree cannot be read (the run goes on without one).
func (o *Orchestrator) goWork(ctx context.Context, t domain.Ticket, rs []runRepo, run *domain.Run) string {
	tr, ok := o.git.(TreeReader)
	if !ok || len(rs) < 2 {
		return ""
	}
	trees := make([]toolchain.Tree, len(rs))
	for i, r := range rs {
		tree, err := tr.Tree(ctx, r.Repository, r.Branch)
		if err != nil {
			o.log.Warn("read repository for go.work", "repo", r.Name, "err", err)
			return ""
		}
		trees[i] = tree
	}
	gowork := goWorkFor(rs, trees)
	for _, r := range rs {
		if len(r.GoLocal) > 0 {
			o.event(ctx, domain.Event{TicketKey: t.Key, RunID: &run.ID, Step: "toolchain", Type: domain.EventToolchain,
				Message: r.Name + " builds against the local " + strings.Join(r.GoLocal, ", ") + " (/workspace/go.work, not committed): " +
					"merge and tag those first, then bump them in " + r.Name + "'s go.mod"})
		}
	}
	return gowork
}

// goWorkFor returns the go.work for a run of several repositories, trees[i]
// being rs[i]'s, and sets GoLocal on each repository that builds against
// another's folder; "" when none requires another. A repository with its
// own go.work or vendor directory is left out (a closer go.work wins, and
// vendoring does not mix with a workspace), as is a module its requirer
// replaces already.
func goWorkFor(rs []runRepo, trees []toolchain.Tree) string {
	if len(rs) < 2 {
		return ""
	}
	type mod struct {
		path, gomod string
	}
	mods := make([]*mod, len(rs))
	byPath := map[string]int{}
	for i, t := range trees {
		gomod := string(t["go.mod"])
		m := goModuleLineRe.FindStringSubmatch(gomod)
		if m == nil || hasKey(t, "go.work") || hasKey(t, "vendor/") {
			continue
		}
		mods[i] = &mod{path: m[1], gomod: gomod}
		byPath[m[1]] = i
	}
	used := make([]bool, len(rs))
	for i, m := range mods {
		if m == nil {
			continue
		}
		for _, req := range goRequiredRe.FindAllStringSubmatch(m.gomod, -1) {
			j, ok := byPath[req[1]]
			if !ok || j == i || replaces(m.gomod, req[1]) {
				continue
			}
			used[i], used[j] = true, true
			if !slices.Contains(rs[i].GoLocal, rs[j].Name) {
				rs[i].GoLocal = append(rs[i].GoLocal, rs[j].Name)
			}
		}
	}
	version := ""
	var uses []string
	for i, u := range used {
		if !u {
			continue
		}
		uses = append(uses, "\t./"+rs[i].Folder())
		if m := goVersionRe.FindStringSubmatch(mods[i].gomod); m != nil && newerGo(m[1], version) {
			version = m[1]
		}
	}
	if len(uses) == 0 {
		return ""
	}
	if version == "" {
		version = "1.21"
	}
	return "// Written by agnts for this run, outside every repository: Go builds\n" +
		"// use the folders below, not their released versions.\n\n" +
		"go " + version + "\n\nuse (\n" + strings.Join(uses, "\n") + "\n)\n"
}

// replaces reports whether go.mod replaces the module path (at every
// version or one): a workspace may not use a module its go.mod replaces.
func replaces(gomod, path string) bool {
	re := regexp.MustCompile(`(?m)^\s*(?:replace\s+)?"?` + regexp.QuoteMeta(path) + `"?(?:\s+v\S+)?\s+=>`)
	return re.MatchString(gomod)
}

func hasKey(t toolchain.Tree, k string) bool {
	_, ok := t[k]
	return ok
}

// newerGo reports whether Go version a is after b ("" is before all).
func newerGo(a, b string) bool {
	if b == "" {
		return true
	}
	pa, pb := strings.Split(a, "."), strings.Split(b, ".")
	for i := range max(len(pa), len(pb)) {
		var x, y int
		if i < len(pa) {
			x, _ = strconv.Atoi(pa[i])
		}
		if i < len(pb) {
			y, _ = strconv.Atoi(pb[i])
		}
		if x != y {
			return x > y
		}
	}
	return false
}
