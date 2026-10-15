# agnts Method Skills — Plan

Oct 13, 2026 · phases 1–2 implemented, phase 3 (replays) is run by a person; prompts version 2026-10-13.1

## Overview

agnts already gives runs Claude Code skills: team rules delivered as skills, business context, precedents and run tips are written to `$CLAUDE_CONFIG_DIR/skills/agnts-<slug>/SKILL.md` before each run (Harness plan, item 14; `orchestrator/rules_enforce.go`). All of them say **what** a team wants. None of them says **how** to do a recurring kind of work well, such as adding one more integration in the shape the repository already uses, or changing a database schema without locking a table.

ECC (github.com/affaan-m/ecc, MIT) ships 311 skills. A review of them (Oct 13, 2026) found that few fit agnts:

- About 270 are outside a coding run's job: ECC's own tooling (`configure-ecc`, `ecc-*`, `*-ops`), other business domains (freight, healthcare, energy, customs), content and social publishing, video, crypto, home networking.
- The language skills (`golang-patterns`, `vue-patterns`, …) are 450–950 lines of general practice Claude already knows. What can be checked in them is already in `orchestrator/review/<lang>.md` and `rulepacks/packs/<lang>.json`.
- Many assume an interactive session: slash commands, ECC agents and hooks, `~/.claude` state, "ask the user". 27 tell the agent to install things (`npx -y`, `pip install`, `curl | sh`), and several depend on Context7, Exa or Firecrawl MCP servers. A run has none of these and has egress rules.
- Several duplicate what agnts already does: `gateguard` (fact check, item 5), `safety-guard`, `delivery-gate` and `plankton-code-quality` (`agnts-guard`, stop gate, per-file checks), `continuous-learning-v2` (lessons and run tips, item 13), `verification-loop` (checks), the reviewer skills (review checklists, item 9), and `intent-driven-development` (the analysis already writes acceptance criteria, used by the acceptance check).
- Broad triggers would misfire. `tdd-workflow` describes itself for "a new feature, fixing a bug, refactoring", which is every ticket, and asks for 80% coverage and E2E tests on each.
- Every installed skill's description sits in the context of every run. All 311 would add about 10,000 tokens to each run before any work.

This plan adds a small set of **method skills**: four agnts-maintained skills, rewritten from ECC material for headless runs, written into runs only where they apply, and kept only if replays show they help.

**Goals**

- Fewer review findings of the kinds these skills target: a new integration or endpoint that does not follow the repository's existing shape, code that duplicates a helper the repository already has, and migrations that lock or break running code.
- No more tokens per approved ticket with method skills on than without, measured on replays.
- Each skill is short enough to read whole: 40–100 lines.

**Out of scope:** importing ECC's skills wholesale, a skill marketplace or upload, language pattern skills, skills for reviews or previews (the coding run only), and a repository's own `.claude/skills` (see Open questions).

**Principles**

1. **Adapted, not copied.** Same rule as the Harness plan: ECC material is rewritten and attributed under its MIT license. Nothing that needs a slash command, an MCP server, a network install or a person's answer survives the rewrite.
2. **Narrow triggers.** A description names a concrete situation ("adding one more integration, provider, endpoint, handler or command next to existing ones"), never a general one ("writing code").
3. **Written only where they apply.** The migrations skill only reaches runs in repositories that have migrations.
4. **Measured.** A skill that is not loaded, or is loaded without improving replays, is removed.

## The skills

| # | Skill | From ECC | Written when |
| --- | --- | --- | --- |
| 1 | `agnts-method-follow-existing-pattern` | `api-connector-builder` | always (coding runs) |
| 2 | `agnts-method-house-style` | `inherit-legacy-style` | always (coding runs) |
| 3 | `agnts-method-reuse-first` | `search-first` | always (coding runs) |
| 4 | `agnts-method-migrations` | `database-migrations` | the repository has migrations |

### 1. Follow the existing pattern

**Trigger:** the change adds one more of something the repository already has several of: an integration or provider, an API endpoint, a handler, a page, a CLI command, a job, a migration.

**Body:**

- Find the two closest siblings before writing anything. Prefer the most recently changed one when they differ (`git log -1 --format=%cs -- <path>`): the repository may have moved to a newer shape.
- Map what they have: file layout, config and validation, auth, error handling, retries and pagination, registration (routers, registries, DI wiring, menus, OpenAPI, i18n keys), tests, docs.
- Build the new one with the same layers and names. Stop only when every registration point the siblings use is wired; a handler that no router reaches is unfinished.
- Do not copy a sibling's bugs: reuse the structure, and mention a defect you see in the summary instead of repeating it.
- Do not invent a second architecture next to the existing one. If the ticket really needs a different shape, say why in the design notes.

ECC's reference trees for Python and TypeScript connectors are dropped: the repository is the reference.

### 2. House style

**Trigger:** writing new code in a part of the repository the run has not edited before, or a new file.

**Body:**

- Read two or three neighbouring files in the same directory or layer before writing. Note four things: in-file order (imports, types, main logic, helpers), naming (files, functions, flags, async state), where cross-cutting code lives (errors, logging, formatting, middleware), and how errors are handled (returned, thrown, wrapped, global handler).
- Follow the majority in the nearest scope: directory over package, package over repository.
- When neighbours disagree evenly, follow the more recently changed file and record the choice in the summary in one line, so a person can correct it with a rule.
- Change style only where the ticket asks for it. Do not reformat lines the change does not touch.

ECC's version asks the user one question per conflict, writes `.ai-style-rules.md` and installs hooks. A run can do none of that. The persistent version of a style decision is already an agnts rule, and reflect proposes those from review feedback.

### 3. Reuse first

**Trigger:** about to write a helper, utility, wrapper, validator, formatter, client or other small abstraction.

**Body:**

- Search the repository first (`rg` for the verb and the noun, and the obvious file names: `util`, `helpers`, `lib`, `common`, `shared`, `pkg`). Use what exists, extending it if needed, rather than writing a second one.
- Then check the dependencies the repository already has: the standard library and the packages in its manifest often do it already.
- Add a new dependency only when neither covers it and the ticket's scope allows it. Name it, its license and why in the summary; the person approving the change decides.
- Never install global tools or change lock files only to try something.

ECC's registry, GitHub and MCP searches and its researcher agent are dropped. A run searches what it has, and a new dependency is a person's decision.

### 4. Migrations

**Trigger:** creating or changing a database migration, or a model change that will need one.

**Written when** the repository's detected toolchains or files include migrations: a `migrations/` or `db/migrate/` directory, `prisma/schema.prisma`, `alembic.ini`, Django `*/migrations/`, Laravel `database/migrations/`, golang-migrate, goose, Flyway or Liquibase files.

**Body (about 90 lines):**

- Rules: applied migrations are never edited; schema and data changes are separate migrations; each migration must be safe on production-sized tables; the running code keeps working during the deploy (expand, migrate, contract).
- PostgreSQL recipes: add a column nullable or with a constant default; `CREATE INDEX CONCURRENTLY`, outside a transaction where the tool wraps one; rename by add, backfill, switch reads, then drop in a later change; batched, idempotent backfills; `NOT VALID` then `VALIDATE CONSTRAINT` for new constraints. Short MySQL notes for the locking differences.
- How to create a migration with the repository's tool: one line each for golang-migrate, goose, Prisma, Drizzle, Django, Alembic, Rails, Laravel, Flyway. Always the repository's own command when it has one (Makefile, package scripts).
- Before finishing: the migration runs on the dev database the repository sets up, and its down step or written rollback matches.

`orchestrator/review/sql-migrations.md` stays as the review side of the same rules. Kysely's programmatic migrator, schema examples and the "set up migration tooling" section are dropped.

### Not taken, and why

| ECC skill | Reason |
| --- | --- |
| `intent-driven-development`, `product-capability` | The analysis already writes acceptance criteria |
| `tdd-workflow` | Fires on every ticket; Proof of fix (item 8) covers the part that matters |
| `verification-loop`, `delivery-gate`, `safety-guard`, `gateguard` | agnts-guard, stop gate, checks and fact check do this, deterministically |
| `continuous-learning-v2`, `ck`, `unified-memory` | Lessons, run tips and the progress file do this, and people approve them |
| Language `*-patterns`, `*-testing` | Covered by review checklists and rule packs; long and general |
| `e2e-testing` | Possible later for repositories with Playwright, once the preview and acceptance work shows the need |

Two small "known trap" rules go into the TypeScript rule pack instead of a skill: Prisma's `updateMany` and `deleteMany` return a count, not records; Node's `sha3-256` is not Ethereum's Keccak-256.

## Architecture

```text
server/internal/skillpacks/
  skillpacks.go            Skill{Name, When, Body}; For(repo, toolchains, files) []Skill
  skills/
    follow-existing-pattern/SKILL.md
    house-style/SKILL.md
    reuse-first/SKILL.md
    migrations/SKILL.md
  NOTICE                   ECC's MIT notice, like rulepacks/packs/NOTICE
```

- Skills are embedded with `//go:embed`, like rule packs and review checklists. Their frontmatter is `name` and `description` only.
- `writeSkills` (`orchestrator/rules_enforce.go`) also writes the method skills that `skillpacks.For` returns for the repository, under `SkillsDir/agnts-method-<name>/`. The existing `rm -rf SkillsDir/agnts-*` already clears them between runs.
- `For` decides `When`: `always`, or a check against the repository's detected toolchains and a file list from the work tree (one `git ls-files` per run, run while the brief is written).
- Coding runs only. Analysis, review, preview, acceptance and learn runs do not get method skills.
- The brief's line about skills (`orchestrator/brief.go:266`) also counts method skills, and says they describe how to do the work, not team rules.
- `PromptVersion` is bumped, so Analytics and replays can tell runs with method skills apart.

### Recording which skills a run used

- The run's event stream already carries tool calls (`ClaudeTool` events, used by the stall detector). A `Skill` tool call names the skill.
- `domain.RunHarness` gains `Skills []string`: the method and rule skills Claude loaded in the run. It is stored in the run's existing harness jsonb, so there is no migration.
- Analytics → Agent quality gains a small table: per method skill, how often it was written to a run, how often it was loaded, and first-pass approvals and review findings with and without it.

## Settings

| Setting | Where | Default |
| --- | --- | --- |
| Method skills | Settings → Runs | off until the replays pass, then on |

One switch for all four. A skill that does not help is removed from the code, not given its own switch (Harness plan principle 4: few switches).

## Phases

| Phase | Work | Estimate | Done when |
| --- | --- | --- | --- |
| 1 | `skillpacks` package, the four skills, `NOTICE`, the `writeSkills` and brief changes, the setting, two TypeScript pack rules | 3–4 days | skills reach a run's `SkillsDir` in the runner docker test; the migrations skill only where migrations exist |
| 2 | `RunHarness.Skills` from the stream, Analytics table | 2 days | a run that loads a skill shows it on the run and in Analytics |
| 3 | Replays: the same set of done tickets with method skills off and on | 1–2 days plus run time | the decision below is made |

**Phase 3 decision.** Method skills turn on by default only if, on replays: first-pass approvals do not drop, tokens per approved ticket do not rise by more than 5%, and review findings in the targeted categories (`architecture` and `maintainability` for skills 1–3; findings on migration files for 4) drop. A skill loaded in fewer than 10% of the runs where its trigger applies gets a better description or is removed.

## Testing

- **`skillpacks`:** each embedded skill parses, has `name` and `description`, has a body under 100 lines, and contains no slash commands, MCP tool names, `npx`, `pip install` or `curl`. `For` returns the migrations skill for each listed migration layout and not for a repository without one.
- **Orchestrator:** `writeSkills` writes the method skills with the setting on and none with it off, and never in non-coding runs; rule skills and tips keep working (the existing `rules_harness_test.go`).
- **Stream:** `RunHarness.Skills` from a recorded stream with a `Skill` tool call (`runner/testdata`).
- **Runner docker test:** the files appear under `/home/agent/.claude/skills/agnts-method-*/SKILL.md` (extend the check in `runner/harness_test.go`).
- **Replays:** Phase 3.

## Costs

| Item | Server | Claude tokens |
| --- | --- | --- |
| Descriptions in every coding run | none | about 200 tokens for four descriptions |
| A loaded skill | none | 1,000–2,500 tokens each, only when its trigger applies |
| Replays | runner time for the replay set twice | one replay set's worth |

## Decided

- Four method skills, not a general skill import. More are added one at a time, with the same rewrite and replay rules.
- Method skills are agnts's own prompts, versioned with `PromptVersion`, not team rules: teams do not edit them. A team that wants a different method writes a rule, which wins.
- ECC material is adapted and attributed in `skillpacks/NOTICE`.

## Open questions

- **A repository's own `.claude/skills`.** Checked: they still load in runs. `managed-settings.json` only keeps repository *hooks* out (`allowManagedHooksOnly`); project skills under `/workspace/.claude/skills` are found by Claude Code like any other. Their text is covered by the agent-config injection scan (Harness plan, item 1). Decide whether to keep them (they are the team's own) or exclude them like hooks.
- **Two skills or one?** Skills 1 and 2 are both about matching the repository. They have different triggers (adding a sibling, writing in a new area), so the plan keeps them apart. If replays show they always load together, merge them.
- **`e2e-testing`** for repositories with Playwright: worth a fifth skill after the acceptance check has a few weeks of data?

## Where the build differs from the draft

- **Two lists on the run, not one.** `RunHarness.MethodSkills` is what agnts gave a coding run and `RunHarness.Skills` what Claude loaded (method and team rule skills alike, from the `Skill` tool calls in the stream). Analytics needs both to say "loaded in N% of the runs that had it".
- **Prompt version suffix.** Coding runs that had method skills record `PromptVersion + "+methods"` (`2026-10-13.1+methods`). The Quality table and the replay report already group by prompt version, so "off" and "on" show up as two rows with no new comparison UI.
- **Seen on the run through the activity log.** A loaded skill appears in the ticket's log as `Skill: agnts-method-…` (the runner now names the skill in the tool line); there is no separate ticket-page card.
- **The Analytics table counts replays.** Unlike the Quality table, the method skills table includes replays, because replays are how the skills are judged. Its "targeted findings" are review findings of category `architecture` or `maintainability`, or any finding on a path matching `skillpacks.MigrationFiles`.
- **Cleanup moved.** `writeSkills` now removes `agnts-*` skills of earlier runs before anything else, even on a server without a rule store, so method skills never linger into analysis, review or preview runs.
- **Repository detection** is one `git ls-files | grep -E -q` per run in the work tree, with the pattern in `skillpacks.MigrationFiles` (shared with the Analytics query).
- **Rule pack.** The two TypeScript rules say "where the project uses Prisma" and "where the code hashes for Ethereum", so a team without either can skip them on adoption.

## How to test

### Automated

```sh
cd server && go test ./internal/skillpacks ./internal/rulepacks ./internal/runner
AGNTS_TEST_DATABASE_URL=postgres://hiro:hiro@localhost:5442/hiro_test?sslmode=disable go test -p 1 ./internal/orchestrator -run TestMethodSkills
cd apps/admin && npx vitest run src/pages/AnalyticsPage.test.ts
```

`TestMethodSkills` runs three tickets through analysis and coding: setting off, on in a repository without migrations, and on with migrations while Claude loads the migrations skill. It checks the files written, the prompts, the Analytics counts and the prompt versions.

### Manual

1. **The setting.** `make dev-db dev-server dev-admin`, then Settings → Guardrails: **Method skills** is off. Turn it on and save; reload the page and it is still on.
2. **Skills reach a coding run.** With the setting on, give agnts a ticket on a repository that has a `migrations/` (or `db/migrate/`, `prisma/schema.prisma`, …) directory. While it codes, in the run container:
   `docker exec <run container> ls /home/agent/.claude/skills` shows `agnts-method-follow-existing-pattern`, `-house-style`, `-reuse-first` and `-migrations`. On a repository without migrations, the last one is missing.
3. **The prompt.** The coding prompt lists them under "Team knowledge" as "agnts's method skills …, not team rules".
4. **Loaded skills.** When Claude uses one, the ticket's activity log shows a tool line `Skill: agnts-method-…`.
5. **No lingering.** After the coding run, the review run's container has no `agnts-method-*` directory.
6. **Analytics.** Analytics → Quality shows a **Method skills** table once a coding run had one, with a "none (baseline)" row, and the Quality table shows the prompt version `2026-10-13.1+methods` next to `2026-10-13.1`.
7. **Setting off again.** Turn it off: the next coding run has no `agnts-method-*` skills and records the plain prompt version.

### Phase 3: the replay comparison

This spends Claude usage, so a person runs it.

1. Pick 10–20 done code tickets across your repositories, including some that touched migrations and some that added an endpoint, integration or page next to existing ones.
2. With **Method skills off**, replay each (Replay on the done ticket's page, `agnts eval replay KEY`, or `POST /tickets/{key}/replay`). Let them finish; reject each replay when it is done (replays are never pushed).
3. Turn **Method skills on** and replay the same tickets again.
4. Compare in Analytics → Quality → Replay evaluation: the rows `2026-10-13.1` and `2026-10-13.1+methods` (checks passed, reviews without blockers, file overlap and recall with the original, turns, cost). Then the Method skills table: loaded rate per skill and targeted findings per ticket against the baseline row.
5. Decide, by the rule in Phases: keep the setting on by default (change `DefaultSettings`) only if first-pass results do not drop, cost per replay rises by no more than 5%, and targeted findings drop. Rewrite the description of a skill loaded in under 10% of the runs where it applies, or remove the skill.
