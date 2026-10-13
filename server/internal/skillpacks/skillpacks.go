// Package skillpacks holds agnts's method skills: short Claude Code
// skills on how to do a recurring kind of work well (add one more of
// something the repository has, follow its style, reuse before writing,
// change a database schema safely). They are agnts's own prompts, adapted
// from ECC's skills (NOTICE), and reach coding runs when Settings →
// Runs → Method skills is on. Team rules win over them.
package skillpacks

import (
	"embed"
	"io/fs"
	"path"
	"sort"
)

//go:embed skills/*/SKILL.md
var files embed.FS

// Prefix starts every method skill's name, so runs and Analytics can tell
// them from the team's rule skills (agnts-<rule>-<id>).
const Prefix = "agnts-method-"

// MigrationFiles matches the tracked paths of a repository that has
// database migrations (grep -E and RE2 syntax): migration directories of
// golang-migrate, goose, Django, Laravel, Rails (db/migrate), Flyway
// (db/migration), Liquibase (db/changelog), Alembic and Prisma, and the
// config files of Prisma, Alembic and Drizzle.
const MigrationFiles = `(^|/)(migrations|migrate|migration|alembic/versions|db/changelog)/|(^|/)(schema\.prisma|alembic\.ini|drizzle\.config\.(ts|js|mjs))$`

// only limits a skill to repositories with a tracked path matching the
// pattern; skills not listed apply to every coding run.
var only = map[string]string{
	"migrations": MigrationFiles,
}

// Skill is one method skill.
type Skill struct {
	Name string // agnts-method-<dir>, also the name in its frontmatter
	Body []byte // the whole SKILL.md
	// Files, when set, is a pattern over the repository's tracked paths:
	// the skill applies only when one matches.
	Files string
}

// All returns every method skill, by name.
func All() []Skill {
	dirs, err := fs.Glob(files, "skills/*/SKILL.md")
	if err != nil {
		panic(err) // the pattern is constant
	}
	out := make([]Skill, 0, len(dirs))
	for _, p := range dirs {
		body, err := files.ReadFile(p)
		if err != nil {
			panic(err) // embedded
		}
		dir := path.Base(path.Dir(p))
		out = append(out, Skill{Name: Prefix + dir, Body: body, Files: only[dir]})
	}
	sort.Slice(out, func(i, j int) bool { return out[i].Name < out[j].Name })
	return out
}
