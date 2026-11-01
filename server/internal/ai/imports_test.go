package ai_test

import (
	"go/parser"
	"go/token"
	"io/fs"
	"path/filepath"
	"strconv"
	"strings"
	"testing"
)

// imports lists the agnts imports of every Go file under root, by file
// (relative to the server module), test files included.
func imports(t *testing.T, root string) map[string][]string {
	t.Helper()
	out := map[string][]string{}
	module, err := filepath.Abs("../..")
	if err != nil {
		t.Fatal(err)
	}
	err = filepath.WalkDir(root, func(p string, d fs.DirEntry, err error) error {
		if err != nil || d.IsDir() || !strings.HasSuffix(p, ".go") {
			return err
		}
		f, err := parser.ParseFile(token.NewFileSet(), p, nil, parser.ImportsOnly)
		if err != nil {
			return err
		}
		abs, err := filepath.Abs(p)
		if err != nil {
			return err
		}
		rel, err := filepath.Rel(module, abs)
		if err != nil {
			return err
		}
		for _, im := range f.Imports {
			path, _ := strconv.Unquote(im.Path.Value)
			if strings.HasPrefix(path, "agnts/") {
				out[filepath.ToSlash(rel)] = append(out[filepath.ToSlash(rel)], path)
			}
		}
		return nil
	})
	if err != nil {
		t.Fatal(err)
	}
	return out
}

// Features reach the providers through the gateway only: nothing outside
// internal/ai and the server's wiring (cmd/agnts) imports a provider. The
// gateway itself depends on no feature: internal/ai imports domain alone.
func TestImportBoundaries(t *testing.T) {
	all := imports(t, "..")
	for file, ims := range imports(t, "../../cmd") {
		all[file] = ims
	}
	for file, ims := range all {
		inAI := strings.HasPrefix(file, "internal/ai/")
		for _, im := range ims {
			if strings.HasPrefix(im, "agnts/internal/ai/providers/") && !inAI && !strings.HasPrefix(file, "cmd/agnts/") &&
				(!strings.HasSuffix(file, "_test.go") || !strings.HasPrefix(file, "internal/runner/")) {
				t.Errorf("%s imports %s: features use the gateway (internal/ai), not a provider", file, im)
			}
			if strings.HasPrefix(file, "internal/ai/") && !strings.Contains(strings.TrimPrefix(file, "internal/ai/"), "/") &&
				!strings.HasSuffix(file, "_test.go") && im != "agnts/internal/domain" {
				t.Errorf("%s imports %s: internal/ai depends on domain alone", file, im)
			}
		}
	}
}
