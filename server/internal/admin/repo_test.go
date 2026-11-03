package admin

import (
	"context"
	"errors"
	"io"
	"log/slog"
	"strings"
	"testing"

	"agnts/internal/domain"
	"agnts/internal/store/postgres"
	"agnts/internal/store/postgres/pgtest"
	"agnts/internal/vcs/github"
)

func TestValidateDerivesKind(t *testing.T) {
	cases := []struct {
		name, jira, prefix, wantKind, wantErr string
	}{
		{name: "side only", wantKind: "side"},
		{name: "jira and tasks", jira: " kan ", prefix: "mka", wantKind: "jira"},
		{name: "same prefix as jira key", jira: "MKA", prefix: "mka", wantErr: "task prefix must differ"},
		{name: "derived prefix clashes", jira: "MKAC", wantErr: "task prefix must differ"}, // name "mkacademy" → MKAC
		{name: "bad jira key", jira: "KA-N", wantErr: "jira project key"},
	}
	for _, c := range cases {
		t.Run(c.name, func(t *testing.T) {
			x := domain.Repository{Name: "mkacademy", Kind: "side", CloneURL: "https://github.com/me/mkacademy.git",
				JiraProject: c.jira, TaskPrefix: c.prefix}
			err := Validate(&x, "")
			if c.wantErr != "" {
				if err == nil || !strings.Contains(err.Error(), c.wantErr) {
					t.Fatalf("err = %v, want %q", err, c.wantErr)
				}
				return
			}
			if err != nil {
				t.Fatal(err)
			}
			if x.Kind != c.wantKind {
				t.Fatalf("kind = %q, want %q", x.Kind, c.wantKind)
			}
			if c.jira != "" && x.JiraProject != "KAN" {
				t.Fatalf("jira project = %q, want KAN", x.JiraProject)
			}
		})
	}
}

func TestValidateRunSettings(t *testing.T) {
	cases := []struct {
		name    string
		mut     func(*domain.Repository)
		wantErr string
	}{
		{name: "defaults"},
		{name: "toolchains deduplicated", mut: func(x *domain.Repository) {
			x.Toolchains = []domain.Toolchain{{Tool: "Node", Version: "20"}, {Tool: "node", Version: "22"}, {Tool: "go"}}
		}},
		{name: "plugin backend", mut: func(x *domain.Repository) { x.Toolchains = []domain.Toolchain{{Tool: "asdf:php", Version: "8"}} }, wantErr: "toolchain name"},
		{name: "shell in version", mut: func(x *domain.Repository) { x.Toolchains = []domain.Toolchain{{Tool: "node", Version: "20;id"}} }, wantErr: "valid version"},
		{name: "image", mut: func(x *domain.Repository) { x.RunnerImage = " registry.example.com/agnts-runner-android:1 " }},
		{name: "bad image", mut: func(x *domain.Repository) { x.RunnerImage = "--privileged" }, wantErr: "Docker image"},
		{name: "memory too low", mut: func(x *domain.Repository) { x.MemoryMB = 100 }, wantErr: "memory"},
		{name: "branch template", mut: func(x *domain.Repository) { x.BranchTemplate = " {type}/{key}-{slug} " }},
		{name: "branch template without key", mut: func(x *domain.Repository) { x.BranchTemplate = "{type}/{slug}" }, wantErr: "must contain {key}"},
		{name: "branch template unknown placeholder", mut: func(x *domain.Repository) { x.BranchTemplate = "{key}-{title}" }, wantErr: "unknown placeholder"},
	}
	for _, c := range cases {
		t.Run(c.name, func(t *testing.T) {
			x := domain.Repository{Name: "api", CloneURL: "https://github.com/me/api.git"}
			if c.mut != nil {
				c.mut(&x)
			}
			err := Validate(&x, "")
			if c.wantErr != "" {
				if err == nil || !strings.Contains(err.Error(), c.wantErr) {
					t.Fatalf("err = %v, want %q", err, c.wantErr)
				}
				return
			}
			if err != nil {
				t.Fatal(err)
			}
			if c.name == "toolchains deduplicated" && (domain.StackOf(x.Toolchains) != "node,go" || x.Toolchains[0].Version != "20" || x.Toolchains[1].Version != "latest") {
				t.Fatalf("toolchains %+v", x.Toolchains)
			}
			if c.name == "image" && x.RunnerImage != "registry.example.com/agnts-runner-android:1" {
				t.Fatalf("image %q", x.RunnerImage)
			}
		})
	}
}

// A repository's pull request title format is checked like its commit
// format, and a client that does not send it (an older one) keeps it.
func TestRepoPRTemplate(t *testing.T) {
	pool := pgtest.Open(t)
	ctx, _ := pgtest.Workspace(t, pool, "admin-pr-template")
	gh := github.New("http://127.0.0.1:1", func(context.Context) (string, error) { return "", nil }) // the instructions check after a save fails quietly
	repos := NewRepos(postgres.NewAgent(pool), gh, nil, nil, slog.New(slog.NewTextHandler(io.Discard, nil)))
	x := domain.Repository{Name: "shop-api", CloneURL: "https://github.com/me/shop-api.git", PRTemplate: "{key} only"}
	if _, err := repos.SaveRun(ctx, x, SaveOptions{}); !errors.Is(err, ErrInvalid) {
		t.Fatalf("a format without {subject} or {title}: %v", err)
	}
	x.PRTemplate = " [{number}] {type}: {subject} "
	v, err := repos.SaveRun(ctx, x, SaveOptions{})
	if err != nil || v.PRTemplate != "[{number}] {type}: {subject}" {
		t.Fatalf("save: %q %v", v.PRTemplate, err)
	}
	x.ID, x.PRTemplate = v.ID, ""
	if v, err = repos.SaveRun(ctx, x, SaveOptions{KeepPRTemplate: true}); err != nil || v.PRTemplate != "[{number}] {type}: {subject}" {
		t.Fatalf("kept: %q %v", v.PRTemplate, err)
	}
	if v, err = repos.SaveRun(ctx, x, SaveOptions{}); err != nil || v.PRTemplate != "" {
		t.Fatalf("cleared: %q %v", v.PRTemplate, err)
	}
}
