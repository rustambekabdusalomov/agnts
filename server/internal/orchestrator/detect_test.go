package orchestrator

import (
	"strings"
	"testing"

	"agnts/internal/domain"
	"agnts/internal/toolchain"
)

func TestMergeDetection(t *testing.T) {
	base := toolchain.Detection{Toolchains: []domain.Toolchain{{Tool: "node", Version: "20", Source: ".nvmrc"}}, Build: "npm ci"}
	got := mergeDetection(base, detectFile{
		Toolchains: []domain.Toolchain{{Tool: "Node", Version: "22"}, {Tool: "python", Version: ""}, {Tool: "asdf:x", Version: "1"}},
		Build:      "make all", Lint: "npm run lint", Test: "pytest\nrm -rf /", Notes: []string{"Tests need PostgreSQL."},
	})
	if s := domain.StackOf(got.Toolchains); s != "node,python" || got.Toolchains[0].Version != "20" || got.Toolchains[1].Spec() != "python@latest" {
		t.Fatalf("toolchains %+v: the scan's node@20 must win, python is added", got.Toolchains)
	}
	if got.Build != "npm ci" || got.Lint != "npm run lint" || got.Test != "" {
		t.Fatalf("commands: build=%q lint=%q test=%q", got.Build, got.Lint, got.Test)
	}
	if len(got.Notes) != 2 || !strings.Contains(got.Notes[0], "asdf:x") || got.Notes[1] != "Tests need PostgreSQL." {
		t.Fatalf("notes %v", got.Notes)
	}
}

func TestEnvironmentAndDetectPrompts(t *testing.T) {
	repo := domain.Repository{Name: "api", Toolchains: []domain.Toolchain{{Tool: "go", Version: "1.24"}, {Tool: "python", Version: "3.12", Dir: "ml"}}}
	p, err := render("code", promptData{T: domain.Ticket{Key: "PAY-1", Title: "x"}, Repo: repo})
	if err != nil {
		t.Fatal(err)
	}
	if !strings.Contains(p, "Installed and on PATH: go 1.24, python 3.12 (for ml/)") || !strings.Contains(p, "virtualenv is active") {
		t.Fatalf("code prompt has no environment section:\n%s", p)
	}
	p, _ = render("code", promptData{T: domain.Ticket{Key: "PAY-1"}, Repo: domain.Repository{Name: "api"}})
	if strings.Contains(p, "## Environment") {
		t.Fatal("environment section without toolchains")
	}
	p, err = render("detect", promptData{Repo: repo, Detected: toolchain.Detection{Toolchains: repo.Toolchains, Build: "go build ./..."}})
	if err != nil || !strings.Contains(p, "go@1.24, python@3.12") || !strings.Contains(p, "build: go build ./...") || !strings.Contains(p, DetectPath) {
		t.Fatalf("detect prompt (%v):\n%s", err, p)
	}
}
