package toolchain

import (
	"strings"
	"testing"

	"agnts/internal/domain"
	"agnts/internal/guard"
)

func TestEditChecks(t *testing.T) {
	cs := EditChecks([]domain.Toolchain{{Tool: "go", Version: "1.26"}, {Tool: "node", Version: "22", Dir: "apps/web"}, {Tool: "python", Version: "3.12"}})
	byName := map[string]domain.EditCheck{}
	for _, c := range cs {
		byName[c.Name] = c
	}
	for _, name := range []string{"gofmt", "go vet", "eslint (apps/web)", "prettier (apps/web)", "ruff"} {
		if _, ok := byName[name]; !ok {
			t.Fatalf("no %s check in %+v", name, cs)
		}
	}
	if byName["go vet"].Every == 0 {
		t.Error("go vet runs after every edit")
	}
	es := byName["eslint (apps/web)"]
	if !guard.MatchGlob(es.Globs[0], "apps/web/src/App.vue") && !anyGlob(es.Globs, "apps/web/src/App.vue") {
		t.Errorf("eslint globs %v miss apps/web/src/App.vue", es.Globs)
	}
	if anyGlob(es.Globs, "server/main.go") || !strings.HasPrefix(es.Cmd, "cd 'apps/web' && ") && !strings.HasPrefix(es.Cmd, "cd apps/web && ") {
		t.Errorf("eslint: %+v", es)
	}
	if !anyGlob(byName["gofmt"].Globs, "server/internal/x/y.go") {
		t.Errorf("gofmt globs %v", byName["gofmt"].Globs)
	}
}

func anyGlob(gs []string, p string) bool {
	for _, g := range gs {
		if guard.MatchGlob(g, p) {
			return true
		}
	}
	return false
}
