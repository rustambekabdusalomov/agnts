package skillpacks

import (
	"bytes"
	"regexp"
	"strings"
	"testing"
)

func TestSkillsAreShortHeadlessAndNamed(t *testing.T) {
	all := All()
	if len(all) != 4 {
		t.Fatalf("%d skills", len(all))
	}
	// What a headless run cannot do, or must not be told to do.
	forbidden := []string{"npx -y", "npm install -g", "pip install", "curl ", "wget ", "AskUserQuestion", "mcp__", "~/.claude", "ask the user"}
	for _, s := range all {
		body := string(s.Body)
		front, rest, ok := strings.Cut(strings.TrimPrefix(body, "---\n"), "\n---\n")
		if !strings.HasPrefix(body, "---\n") || !ok {
			t.Fatalf("%s: no frontmatter", s.Name)
		}
		var name, desc string
		for l := range strings.SplitSeq(front, "\n") {
			k, v, _ := strings.Cut(l, ": ")
			switch k {
			case "name":
				name = v
			case "description":
				desc = v
			default:
				t.Errorf("%s: unexpected frontmatter line %q", s.Name, l)
			}
		}
		if name != s.Name || !strings.HasPrefix(name, Prefix) {
			t.Errorf("%s: frontmatter name %q", s.Name, name)
		}
		if !strings.HasPrefix(desc, "Use when") && !strings.HasPrefix(desc, "Use before") || len(desc) > 400 {
			t.Errorf("%s: description %q", s.Name, desc)
		}
		if n := bytes.Count(s.Body, []byte("\n")); n > 100 {
			t.Errorf("%s: %d lines", s.Name, n)
		}
		for _, f := range forbidden {
			if strings.Contains(rest, f) {
				t.Errorf("%s: contains %q", s.Name, f)
			}
		}
		if strings.Contains(rest, "\n/") {
			t.Errorf("%s: a line starts with a slash command", s.Name)
		}
	}
}

func TestMigrationFiles(t *testing.T) {
	re := regexp.MustCompile(MigrationFiles)
	yes := []string{
		"server/migrations/00001_init.sql", "app/orders/migrations/0001_initial.py", "database/migrations/2024_01_01_create_users.php",
		"db/migrate/20240101_create_users.rb", "src/main/resources/db/migration/V1__init.sql", "src/main/resources/db/changelog/master.xml",
		"alembic/versions/abc_init.py", "alembic.ini", "prisma/schema.prisma", "drizzle.config.ts", "migrations/0001.sql",
	}
	no := []string{"README.md", "src/migrator.go", "docs/migrating.md", "web/src/app.ts", "prisma.ts"}
	for _, p := range yes {
		if !re.MatchString(p) {
			t.Errorf("no match: %s", p)
		}
	}
	for _, p := range no {
		if re.MatchString(p) {
			t.Errorf("match: %s", p)
		}
	}
	for _, s := range All() {
		if (s.Files != "") != (s.Name == Prefix+"migrations") {
			t.Errorf("%s: files %q", s.Name, s.Files)
		}
	}
}
