package orchestrator

import (
	"context"
	"fmt"
	"slices"
	"strings"
	"time"

	"agnts/internal/ai"
	"agnts/internal/domain"
	"agnts/internal/skillpacks"
)

// MethodsSuffix marks the prompt version of coding runs that had method
// skills, so Analytics and the replay report compare them with runs that
// had none.
const MethodsSuffix = "+methods"

// methodSkills puts agnts's method skills that fit the repository into a
// coding run (Settings → Runs → Method skills), records them on the run
// and returns the line for the prompt (nil: none). contextFiles, which
// every run calls first, removes those of earlier runs.
// In a run of several repositories a skill fits when any repository has
// the files it is for.
func (o *Orchestrator) methodSkills(ctx context.Context, s domain.Settings, ws Workspace, run *domain.Run, rs []runRepo) *ContextFile {
	if !s.MethodSkills {
		return nil
	}
	var names []string
	for _, sk := range skillpacks.All() {
		if sk.Files != "" && !hasFiles(ctx, ws, rs, sk.Files) {
			continue
		}
		if err := ws.WriteFile(ctx, SkillsDir+"/"+sk.Name+"/SKILL.md", sk.Body); err != nil {
			o.log.Warn("write method skill", "skill", sk.Name, "err", err)
			continue
		}
		names = append(names, sk.Name)
	}
	run.Harness.MethodSkills = names
	if len(names) == 0 {
		return nil
	}
	run.PromptVersion = PromptVersion + MethodsSuffix
	return &ContextFile{Path: SkillsDir, What: fmt.Sprintf("agnts's method skills (%s), not team rules: how to do common kinds of work the way this repository already does them. Load one when its description matches what you are about to do; the rules, the brief and the business context win over it",
		strings.Join(names, ", "))}
}

// hasFiles reports whether a repository of the run tracks a file matching
// the extended regular expression re.
func hasFiles(ctx context.Context, ws Workspace, rs []runRepo, re string) bool {
	if len(rs) <= 1 {
		rs = []runRepo{{}} // /workspace itself
	}
	for _, r := range rs {
		res, err := ws.Exec(ctx, r.Cmd("git ls-files | grep -E -q -e "+shellArg(re)), time.Minute)
		if err == nil && res.ExitCode == 0 {
			return true
		}
	}
	return false
}

// noteSkill records a skill Claude loaded in a run, from its Skill tool
// call ("Skill: <name>").
func noteSkill(run *domain.Run, e ai.Event) {
	if e.Kind != ai.EventTool {
		return
	}
	if tool, _ := e.Data["tool"].(string); tool != "Skill" {
		return
	}
	_, name, _ := strings.Cut(e.Tool, ": ")
	if name = strings.TrimSpace(strings.TrimPrefix(name, "/")); name == "" {
		return
	}
	if slices.Contains(run.Harness.Skills, name) {
		return
	}
	run.Harness.Skills = append(run.Harness.Skills, name)
}
