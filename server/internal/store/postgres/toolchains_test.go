package postgres

import (
	"context"
	"slices"
	"testing"

	"agnts/internal/domain"
	"agnts/internal/secret"
)

func TestToolchainsAndBuildEnv(t *testing.T) {
	users, _ := testDB(t)
	ctx := context.Background()
	s := NewAgent(users.db)
	_, _ = s.db.Exec(ctx, `TRUNCATE tickets, runs, events, repositories RESTART IDENTITY CASCADE`)

	repo, err := s.SaveRepository(ctx, domain.Repository{Name: "api", Kind: "side", Provider: "github", CloneURL: "https://github.com/a/api.git", DefaultBranch: "main"})
	if err != nil {
		t.Fatal(err)
	}
	if len(repo.Toolchains) != 0 || repo.ToolchainsDetectedAt != nil || repo.MemoryMB != 0 {
		t.Fatalf("new repository: %+v", repo)
	}

	// Detection on a repository without commands fills them and the stack.
	tcs := []domain.Toolchain{{Tool: "go", Version: "1.24", Source: "go.mod"}, {Tool: "node", Version: "lts", Source: "default", Dir: "web"}}
	got, err := s.SetDetectedToolchains(ctx, repo.ID, tcs, []string{"a note"}, "go build ./...", "go vet ./...", "go test ./...")
	if err != nil {
		t.Fatal(err)
	}
	if !slices.Equal(got.Toolchains, tcs) || got.Stack != "go,node" || got.BuildCmd != "go build ./..." || got.TestCmd != "go test ./..." ||
		got.ToolchainsDetectedAt == nil || !slices.Equal(got.ToolchainNotes, []string{"a note"}) {
		t.Fatalf("after detection: %+v", got)
	}
	// Commands someone set are never replaced.
	got, _ = s.SetDetectedToolchains(ctx, repo.ID, tcs, nil, "make", "make lint", "make test")
	if got.BuildCmd != "go build ./..." || len(got.ToolchainNotes) != 0 {
		t.Fatalf("commands replaced: %+v", got)
	}

	// A person's toolchains (override) survive detection.
	got.Toolchains, got.ToolchainsOverride, got.MemoryMB, got.RunnerImage = []domain.Toolchain{{Tool: "python", Version: "3.11", Source: "manual"}}, true, 6144, "agnts-runner-x:1"
	if got, err = s.UpdateRepository(ctx, got); err != nil {
		t.Fatal(err)
	}
	got, _ = s.SetDetectedToolchains(ctx, repo.ID, tcs, nil, "", "", "")
	if len(got.Toolchains) != 1 || got.Toolchains[0].Spec() != "python@3.11" || !got.ToolchainsOverride || got.Stack != "python" ||
		got.MemoryMB != 6144 || got.RunnerImage != "agnts-runner-x:1" {
		t.Fatalf("override lost: %+v", got)
	}
	// The CLI's upsert without toolchains keeps them.
	again, err := s.SaveRepository(ctx, domain.Repository{Name: "api", Kind: "side", Provider: "github", CloneURL: "https://github.com/a/api.git", DefaultBranch: "main"})
	if err != nil || len(again.Toolchains) != 1 || !again.ToolchainsOverride {
		t.Fatalf("upsert: %+v %v", again, err)
	}

	box, _ := secret.NewBox(make([]byte, 32))
	envs := NewPreviewEnvs(users.db, box)
	if err := envs.SetBuildEnv(ctx, repo.ID, "NPM_TOKEN=abc\nexport PIP_INDEX_URL=https://u:p@pypi.example.com/simple"); err != nil {
		t.Fatal(err)
	}
	if err := envs.SetBuildEnv(ctx, repo.ID, "nope"); err == nil {
		t.Fatal("bad env stored")
	}
	env, err := envs.BuildEnv(ctx, repo.ID)
	if err != nil || len(domain.EnvLines(env)) != 2 || domain.EnvLines(env)[1] != "PIP_INDEX_URL=https://u:p@pypi.example.com/simple" {
		t.Fatalf("build env: %q %v", env, err)
	}
	r, _ := s.RepositoryByID(ctx, repo.ID)
	if !r.BuildEnvSet || !slices.Equal(r.BuildEnvNames, []string{"NPM_TOKEN", "PIP_INDEX_URL"}) {
		t.Fatalf("names: %+v", r)
	}
	if pv, _ := envs.PreviewEnv(ctx, repo.ID); pv != "" {
		t.Fatalf("build env leaked into the preview env: %q", pv)
	}
	_ = envs.SetBuildEnv(ctx, repo.ID, "")
	if r, _ := s.RepositoryByID(ctx, repo.ID); r.BuildEnvSet {
		t.Fatal("build env not cleared")
	}
}
