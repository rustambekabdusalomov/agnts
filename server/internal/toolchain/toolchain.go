// Package toolchain works out what a repository needs to build: the
// language runtimes and build tools (as mise tool@version specs) and the
// build, lint and test commands to suggest. It reads only file names and a
// few small files, never runs anything, and has no I/O of its own: the
// caller hands it a Tree.
package toolchain

import (
	"path"
	"slices"
	"sort"
	"strings"

	"agnts/internal/domain"
)

// Tree is the part of a repository detection looks at: every file path
// up to MaxDepth segments ("a/b/c"), with the content of the files Wanted
// asks for (nil for the rest). Directories are keys ending in "/".
type Tree map[string][]byte

// MaxDepth is how many path segments a file may have; projects are found
// at the root and up to two directories down ("apps/admin/package.json").
const MaxDepth = 3

// MaxFileSize caps the content loaded for one wanted file.
const MaxFileSize = 256 << 10

// SkipDir reports whether a directory is never a project of its own:
// dependencies, build output, fixtures and examples.
func SkipDir(name string) bool {
	switch name {
	case "node_modules", "vendor", "testdata", "test-data", "fixtures", "__fixtures__", "examples", "example",
		"samples", "sample", "third_party", "third-party", "dist", "build", "target", "out", "venv", "__pycache__",
		"Pods", "bower_components", "coverage", "tmp", "docs":
		return true
	}
	return strings.HasPrefix(name, ".") && name != ".github" && name != ".config" && name != ".gitlab" && name != ".circleci"
}

var wantedNames = map[string]bool{
	"mise.toml": true, ".mise.toml": true, ".tool-versions": true,
	"go.mod": true, "go.work": true,
	"package.json": true, ".nvmrc": true, ".node-version": true, "deno.json": true, "deno.jsonc": true, ".dvmrc": true, ".bun-version": true,
	"pyproject.toml": true, ".python-version": true, "runtime.txt": true, "requirements.txt": true, "requirements-dev.txt": true,
	"dev-requirements.txt": true, "requirements_dev.txt": true, "setup.cfg": true, "Pipfile": true,
	"Cargo.toml": true, "rust-toolchain": true, "rust-toolchain.toml": true,
	"pom.xml": true, "build.gradle": true, "build.gradle.kts": true, ".java-version": true, ".sdkmanrc": true,
	"global.json": true,
	"Gemfile":     true, ".ruby-version": true,
	"composer.json": true,
	"mix.exs":       true, "gleam.toml": true,
	"pubspec.yaml":  true,
	"build.zig.zon": true, "Package.swift": true,
	"Makefile": true, "makefile": true, "GNUmakefile": true,
	".gitlab-ci.yml": true, "Jenkinsfile": true, "README.md": true,
}

// Wanted reports whether detection reads the file's content.
func Wanted(p string) bool {
	base := path.Base(p)
	if wantedNames[base] || strings.HasSuffix(base, ".csproj") || strings.HasSuffix(base, ".fsproj") || strings.HasSuffix(base, ".vbproj") {
		return true
	}
	return strings.HasPrefix(p, ".github/workflows/") || strings.HasPrefix(p, ".circleci/")
}

// Detection is what Detect found.
type Detection struct {
	Toolchains []domain.Toolchain
	Build      string
	Lint       string
	Test       string
	// Notes explain what was found and what could not be handled, for the
	// person setting the repository up.
	Notes []string
}

// Stack is the detected tool names, comma-separated.
func (d Detection) Stack() string { return domain.StackOf(d.Toolchains) }

// steps are one project's suggested commands, run from its directory.
type steps struct{ build, lint, test []string }

type detector struct {
	t     Tree
	pins  map[string]domain.Toolchain // from mise.toml / .tool-versions: they win
	order []string                    // tool names in the order found
	tools map[string]domain.Toolchain
	cmds  map[string]*steps // by project dir
	dirs  []string          // project dirs in the order commands were added
	notes []string
}

// Detect looks at a repository tree.
func Detect(t Tree) Detection {
	d := &detector{t: t, pins: map[string]domain.Toolchain{}, tools: map[string]domain.Toolchain{}, cmds: map[string]*steps{}}
	dirs := t.projectDirs()
	for _, dir := range dirs {
		d.readPins(dir)
	}
	for _, dir := range dirs {
		d.project(dir)
	}
	if len(d.dirs) == 0 {
		d.makeProject("") // no known project anywhere: the root Makefile, if any
	}
	// Pinned tools no detector asked for (terraform in .tool-versions, ...).
	pinned := make([]string, 0, len(d.pins))
	for k := range d.pins {
		pinned = append(pinned, k)
	}
	sort.Strings(pinned)
	for _, k := range pinned {
		if _, ok := d.tools[k]; !ok {
			d.add(d.pins[k])
		}
	}
	out := Detection{Notes: d.notes}
	for _, k := range d.order {
		tc := d.tools[k]
		if err := tc.Validate(); err != nil {
			out.Notes = append(out.Notes, "skipped "+tc.Spec()+": "+err.Error())
			continue
		}
		out.Toolchains = append(out.Toolchains, tc)
		if len(out.Toolchains) == domain.MaxToolchains {
			break
		}
	}
	var b, l, ts []string
	for _, dir := range d.dirs {
		s := d.cmds[dir]
		b, l, ts = append(b, inDir(dir, s.build)...), append(l, inDir(dir, s.lint)...), append(ts, inDir(dir, s.test)...)
	}
	out.Build, out.Lint, out.Test = strings.Join(b, " && "), strings.Join(l, " && "), strings.Join(ts, " && ")
	return out
}

func inDir(dir string, cmds []string) []string {
	if len(cmds) == 0 {
		return nil
	}
	c := strings.Join(cmds, " && ")
	if dir == "" {
		return []string{c}
	}
	return []string{"(cd " + shellQuote(dir) + " && " + c + ")"}
}

func shellQuote(s string) string {
	if strings.IndexFunc(s, func(r rune) bool {
		return (r < 'a' || r > 'z') && (r < 'A' || r > 'Z') && (r < '0' || r > '9') && !strings.ContainsRune("-_./", r)
	}) < 0 {
		return s
	}
	return "'" + strings.ReplaceAll(s, "'", `'\''`) + "'"
}

// projectDirs lists the root and every directory (up to two levels down,
// outside skipped ones) that holds a file, root first.
func (t Tree) projectDirs() []string {
	set := map[string]bool{"": true}
	for p := range t {
		if strings.HasSuffix(p, "/") {
			continue
		}
		dir := path.Dir(p)
		if dir == "." {
			continue
		}
		parts := strings.Split(dir, "/")
		if len(parts) > MaxDepth-1 || slices.ContainsFunc(parts, SkipDir) {
			continue
		}
		set[dir] = true
	}
	out := make([]string, 0, len(set))
	for k := range set {
		out = append(out, k)
	}
	sort.Slice(out, func(i, j int) bool {
		di, dj := strings.Count(out[i], "/")+boolInt(out[i] != ""), strings.Count(out[j], "/")+boolInt(out[j] != "")
		if di != dj {
			return di < dj
		}
		return out[i] < out[j]
	})
	return out
}

func boolInt(b bool) int {
	if b {
		return 1
	}
	return 0
}

func join(dir, name string) string {
	if dir == "" {
		return name
	}
	return dir + "/" + name
}

func (t Tree) has(dir, name string) bool {
	_, ok := t[join(dir, name)]
	return ok
}

func (t Tree) hasDir(dir, name string) bool {
	_, ok := t[join(dir, name)+"/"]
	return ok
}

func (t Tree) read(dir, name string) string { return string(t[join(dir, name)]) }

// glob returns the files directly in dir whose name has the suffix.
func (t Tree) glob(dir, suffix string) []string {
	var out []string
	for p := range t {
		if strings.HasSuffix(p, "/") || !strings.HasSuffix(p, suffix) {
			continue
		}
		d := path.Dir(p)
		if d == "." {
			d = ""
		}
		if d == dir {
			out = append(out, path.Base(p))
		}
	}
	sort.Strings(out)
	return out
}

// add records a toolchain unless the tool is already there; a pin
// replaces the version found in the language's own files.
func (d *detector) add(tc domain.Toolchain) {
	if _, ok := d.tools[tc.Tool]; ok {
		return
	}
	if p, ok := d.pins[tc.Tool]; ok {
		tc.Version, tc.Source = p.Version, p.Source
	}
	if tc.Version == "" {
		tc.Version = "latest"
	}
	d.tools[tc.Tool] = tc
	d.order = append(d.order, tc.Tool)
}

func (d *detector) steps(dir string) *steps {
	s, ok := d.cmds[dir]
	if !ok {
		s = &steps{}
		d.cmds[dir] = s
		d.dirs = append(d.dirs, dir)
	}
	return s
}

func (d *detector) note(format string) { d.notes = append(d.notes, format) }

// project runs every language detector on one directory.
func (d *detector) project(dir string) {
	for _, f := range []func(string) bool{
		d.goProject, d.nodeProject, d.denoProject, d.pythonProject, d.rustProject, d.javaProject, d.dotnetProject,
		d.rubyProject, d.phpProject, d.elixirProject, d.gleamProject, d.dartProject, d.zigProject, d.swiftProject,
		d.otherProject,
	} {
		f(dir)
	}
}
