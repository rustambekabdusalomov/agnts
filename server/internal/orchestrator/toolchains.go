package orchestrator

import (
	"context"
	"fmt"
	"slices"
	"strconv"

	"agnts/internal/domain"
	"agnts/internal/toolchain"
)

// refreshToolchains detects what the repository needs from branch's
// checkout (prepared already) and stores it when it changed: a version
// file edited on the branch is picked up by the next run. Toolchains a
// person set by hand are kept; detection then only refreshes the notes.
// Repositories with no check commands at all get the suggested ones.
// Errors are logged, never fatal: the run goes on with what is stored.
func (o *Orchestrator) refreshToolchains(ctx context.Context, repo *domain.Repository, branch, ticketKey string, runID *int64) {
	tr, ok := o.git.(TreeReader)
	if !ok {
		return
	}
	tree, err := tr.Tree(ctx, *repo, branch)
	if err != nil {
		o.log.Warn("read repository for toolchains", "repo", repo.Name, "err", err)
		return
	}
	o.scanAgentConfig(ctx, repo, tree, ticketKey, runID)
	det := toolchain.Detect(tree)
	noCmds := repo.BuildCmd == "" && repo.LintCmd == "" && repo.TestCmd == ""
	fillCmds := noCmds && (det.Build != "" || det.Lint != "" || det.Test != "")
	changed := !repo.ToolchainsOverride && !sameToolchains(repo.Toolchains, det.Toolchains)
	if !changed && !fillCmds && repo.ToolchainsDetectedAt != nil && slices.Equal(repo.ToolchainNotes, det.Notes) {
		return
	}
	saved, err := o.store.SetDetectedToolchains(ctx, repo.ID, det.Toolchains, det.Notes, det.Build, det.Lint, det.Test)
	if err != nil {
		o.log.Warn("store detected toolchains", "repo", repo.Name, "err", err)
		return
	}
	saved.Harness.AgentConfig = repo.Harness.AgentConfig
	if changed || fillCmds {
		msg := fmt.Sprintf("%s: detected %s", repo.Name, toolchainList(saved.Toolchains))
		if fillCmds {
			msg += "; check commands filled in from the repository"
		}
		o.event(ctx, domain.Event{TicketKey: ticketKey, RunID: runID, Step: "toolchain", Type: domain.EventToolchain, Message: msg,
			Data: map[string]any{"repo": repo.Name, "toolchains": saved.Toolchains, "notes": det.Notes,
				"build": saved.BuildCmd, "lint": saved.LintCmd, "test": saved.TestCmd}})
	}
	*repo = saved
}

func sameToolchains(a, b []domain.Toolchain) bool {
	return slices.EqualFunc(a, b, func(x, y domain.Toolchain) bool { return x.Tool == y.Tool && x.Version == y.Version })
}

func toolchainList(ts []domain.Toolchain) string {
	if len(ts) == 0 {
		return "no toolchains"
	}
	s := ""
	for i, t := range ts {
		if i > 0 {
			s += ", "
		}
		s += t.Spec()
	}
	return s
}

// repoSpec adds a repository's run settings to a workspace spec:
// toolchains, its package cache, a custom image, memory and build env.
func (o *Orchestrator) repoSpec(ctx context.Context, spec *WorkspaceSpec, repo domain.Repository, ticketKey string, run *domain.Run) error {
	spec.Toolchains = repo.Toolchains
	spec.CacheKey = "repo-" + strconv.FormatInt(repo.ID, 10)
	spec.MemoryMB = repo.MemoryMB
	if repo.RunnerImage != "" {
		spec.Image = repo.RunnerImage
	}
	if repo.BuildEnvSet && o.builds != nil {
		env, err := o.builds.BuildEnv(ctx, repo.ID)
		if err != nil {
			return fmt.Errorf("load build environment: %w", err)
		}
		spec.Env = domain.EnvLines(env)
	}
	spec.Progress = func(msg string) {
		o.event(ctx, domain.Event{TicketKey: ticketKey, RunID: &run.ID, Step: "toolchain", Type: domain.EventToolchain, Message: msg})
	}
	return nil
}
