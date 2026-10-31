# Coding modules per person — Plan

Oct 29, 2026 · @Rustam · revised Oct 31 after review

## Overview

agnts runs three coding modules: **Muse Code** (Meta), **Claude Code** (Anthropic) and **Codex** (OpenAI). Today the choice is a single, server-wide setting, `AGNTS_PROVIDERS`, read once at startup. This plan makes it something the platform admin controls while the server runs:

- **In general:** which modules the server offers, and which ones a person gets by default.
- **Per person:** an override for each user. It can grant or remove modules, and it sets their default module.

The intended setup:

| Who | Modules | Pays with |
| --- | --- | --- |
| Hackathon judges | Muse only | Free credits the admin gives them (already built) |
| Everyone else | Claude Code and Codex | Their own Anthropic account or OpenAI key, or workspace credits on Claude |

`AGNTS_PROVIDERS` becomes the **ceiling**: what this server can run, which depends on what the runner image installs. The admin chooses within it, and can't turn on a module whose binary isn't there.

## What is in the way today

1. **The module is global.** `domain.SetProviders` is set once (`cmd/agnts/serve.go:408`). `PrimaryProvider`, `ToolName`, `StrongModel`, `LightModel`, `AvailableModels`, `EffectiveModel` and `AllowedModel` all read that one list. Code outside `domain` calls them in **65 places**.
2. **Accounts follow the global switch.** `claude.Service` uses `muse()` (`internal/claude/claude.go:105`) to decide whether connections are Meta or Anthropic. `Pick` rejects a connection for "a tool this server does not run", and `CredentialFor` picks the Muse key or the Anthropic platform key from the same switch.
3. **One connection per person.** `claude_connections` has unique indexes on `user_id` and on `workspace_id` (migration 00024). Muse connections reuse the same table (`muse_api_key`, `muse_login`), so a person can't hold a Claude account and a Muse account at once.
4. **One account per ticket.** The scheduler's `pickAccount` (`orchestrator/scheduler.go:503`) picks one account per member, before any stage runs, and caches it for the tick. A ticket's stages can be on different modules (analysis on Claude, coding on Codex: `orchestrator.go:727-742`). Codex doesn't use a connection, but its runs still need a Claude or Muse account to be picked, so a Codex-only person is blocked.
5. **Free credits ignore the module.** When no connection works, `Pick` uses the person's free credits whatever the module (`claude.go:174`). Free credits are Muse ledger money. With modules picked per run, they would pay for Claude runs on the Anthropic platform key.
6. **Codex has no tiers.** Codex models are free-form `codex:<name>`. There is no light or strong Codex model, and `AvailableModels` doesn't list Codex.
7. **Settings are per workspace, access is per person.** Stage models (`StageModels`) and the second-opinion model live in workspace settings, but a workspace can have members with different access.

## Design

### The access rule

```go
// domain/access.go
type Access struct {
    Modules []string // allowed, in order; the first is the default
}

func (a Access) Allows(p string) bool
func (a Access) Primary() string
```

It is resolved in this order:

1. **Server ceiling:** `AGNTS_PROVIDERS`.
2. **Admin default:** `system_settings['modules']`: `{"enabled": [...], "default": [...]}`. `enabled` must be a subset of the ceiling.
3. **Per-user override:** `users.modules text[]`. `NULL` follows the default. An empty array means no coding modules.

The effective access is `override ?? default`, intersected with `enabled`.

**The default module must be Muse or Claude.** Codex has no light and strong models (point 6), so it can only come after one of them in a list. The admin endpoints refuse a list that starts with `codex`. A Codex-only team needs Codex light and strong defaults first, which this plan leaves out.

### Passing access explicitly

`Access` is an argument, not a value read from `ctx`. The ctx-free versions of the global functions are removed, so the compiler finds all 65 callers and none of them quietly falls back to the admin default.

- `a.Primary()`, `ToolName(a)`, `StrongModel(a)`, `LightModel(a)`, `AvailableModels(a)`, `AllowedModel(a, m)`
- `EffectiveModel(a, m)`: a model of a module the person can't use maps to **the same tier** in their default module (Wonder ↔ opus, Spark ↔ sonnet; haiku → Spark). A `codex:*` model maps to the default module's light model. Today it always maps to the light model. That made sense for a one-way migration, but now both directions happen every day.

Jobs that don't belong to a person (startup, usage refresh, translation without an actor) call `access.Default(ctx)` explicitly. `SetProviders` stays only to set the ceiling.

This is the largest step. It is mostly mechanical, but it touches the orchestrator, assistant, meetings, documents, notifications and HTTP handlers.

### Whose access a run uses

**Access goes with the person; payment goes with the account.**

- **Ticket runs:** the ticket's member, else the workspace's default member, else the owner. This is the same order `whose()` uses, but it applies **in both account modes**. In workspace-account mode, the scheduler ignores the member when it picks the account (`scheduler.go:505`). For access it must not: a judge's ticket in a workspace that shares one account still runs on Muse only.
- **Assistant, meetings, documents, translation:** the actor.

Access is resolved when a run starts and again at each stage. That's one indexed row, so when the admin removes a module, it takes effect at the next stage.

### Accounts: one per module, picked per module

- **Migration 00072:** add `claude_connections.provider text NOT NULL`, backfilled from `kind` (`muse_*` → `muse`, `subscription` and `api_key` → `claude`). Replace the two unique indexes with `(user_id, provider)` and `(workspace_id, provider)`.
- `ConnStore.ForUser(ctx, user, provider)` and `ForWorkspace(ctx, ws, provider)`. Every caller names its module: `Pick`, `CredentialFor` without an account (`claude.go:244`) and the lookups at `claude.go:355`, `360` and `394`.
- **`Pick(ctx, w, member, provider)`** replaces the `isMuseKind(...) != muse()` check:
  - `muse`: the Muse connection, else **free credits**, else workspace credits on `MusePlatformKey`.
  - `claude`: the Claude connection, else workspace credits on `PlatformKey`. **Free credits never fund Claude.**
  - `codex`: no connection. It checks that the workspace's OpenAI integration is set (`runner.go:570`) and returns an account with no credits.
- **The monthly limit** (`credit_limit_monthly`, a cap account in the Muse ledger) also applies only to Muse.
- **Scheduler:** `pickAccount` becomes `pickAccounts(q, it) map[provider]accountPick`. It takes the modules the ticket's stages resolve to (`EffectiveModels(a)` over the stages that will run) and picks one account for each. The cache key is `(member, provider)`. A ticket is held back with the first failing module's reason. Each stage runs with the account of its own module.
- `CreditsEnabled(provider)`: Muse needs `MusePlatformKey`, Claude needs `PlatformKey`, and Codex never uses credits.
- `CredentialFor` picks the platform key by the account's provider, not by `muse()`.
- Profile → Integrations shows one card per module the person may use.

### Workspace settings with mixed members

Stage models and the second-opinion model stay per workspace, and nothing is rewritten in storage. When a run starts, `EffectiveModels(a)` and `EffectiveModel(a, secondOpinion)` map them to what the run's person may use. `store/postgres/settings.go:57` changes from dropping a disabled second opinion to mapping it.

Pickers show the modules the **viewer** may use. Saving checks `AllowedModel(viewer, m)` **only for the fields that changed**. A stored value the viewer can't use is kept, so a Claude-only member can save an unrelated setting in a workspace that has a Muse stage.

### Enforcement points (server, not just UI)

- **Scheduler:** a stage whose module isn't allowed fails with a clear reason (`"Codex is not enabled for <name>"`). Normally `EffectiveModel` remaps it, so this only happens when access changed mid-run.
- **Settings API:** checks the changed fields, as described above.
- **Connect endpoints:** connecting Claude, Muse or the OpenAI integration is refused for a module the person can't use.
- **CLI:** `integration set claude|codex` asks the server and gets the same refusal.
- **Model catalog** (`httpapi/muse.go:201`): returns the viewer's modules and primary module, so the web app, mobile app and CLI hide the rest without special cases.
- **`GET /me`:** adds `modules: [...]`.

### Admin

- **Modules settings:** the modules the server can run (the ceiling, read-only), checkboxes for **enabled**, and an ordered **default for new users**. `GET` and `PUT /admin/modules`. A default that starts with `codex` is refused.
- **Users page:** a "Modules" column ("Default", or the list), and a "Set modules" action with "Follow default" or a custom ordered list. `PUT /admin/users/{id}/modules` records `modules_set_by` and `modules_set_at`, as free credits do.
- OpenAPI changes, then `make gen`.

The judges are set one at a time on the Users page; there are few of them, so there is no bulk action.

### Runner image

All three binaries must be in the image the server can offer. `claude` and `codex` must stay installed: the Muse plan made the Claude Code install optional, so make sure the hosted image still has it. Pin the versions next to `MUSE_CODE_VERSION`, and have the image build run `--version` for each one.

## Steps

1. **Domain:** `Access`, resolving it, `EffectiveModel(a, m)` with tier mapping, and validating the default module. Table tests cover the ceiling, the default, overrides, the Codex rules and tier mapping in every direction.
2. **Migration 00072:** `users.modules`, `modules_set_by`, `modules_set_at`, `claude_connections.provider` and the new unique indexes. Seed `system_settings['modules']` with **what the server offers today**, `{"enabled": ["muse"], "default": ["muse"]}`, so deploying changes nothing until the admin acts.
3. **Store:** `ModulesStore` (default and per user), and connection queries keyed by provider.
4. **Pass access everywhere:** remove the ctx-free global functions and fix the 65 callers.
5. **`claude.Service`:** remove `muse()`. `Pick` and `CredentialFor` work per provider. Free credits and the monthly limit become Muse-only. Codex gets its own account check.
6. **Scheduler and orchestrator:** `pickAccounts` per module, access resolved for the ticket's member in both account modes, and each stage on its own module's account.
7. **Settings:** check only changed fields, and map the second opinion instead of dropping it.
8. **HTTP:** the admin endpoints, the per-viewer model catalog, `/me.modules`, and refusals on the connect endpoints. Then OpenAPI and `make gen`.
9. **Admin UI:** the Modules settings, the Users column and the action.
10. **Web, mobile and CLI:** drive pickers and integration cards from the catalog and `/me.modules`.
11. **Runner image:** confirm the three binaries are installed and pinned.

## Deploy order

Follow `deploy.md`. The order matters because judges may still be using the hosted server.

1. Deploy with `AGNTS_PROVIDERS=muse` unchanged. The migration seeds a Muse-only default, so nothing changes.
2. On the Users page, set every judge account to `["muse"]` and check their free credits.
3. Change the ceiling to `AGNTS_PROVIDERS=muse,claude,codex` and redeploy. Nothing changes yet, because `enabled` is still `["muse"]`.
4. In Modules settings, enable all three and set the default to `["claude", "codex"]`.
5. Check: a judge sees only Muse, and a normal account sees Claude and Codex and runs a ticket.

Undo: set the default back to `["muse"]`. It takes effect at the next stage, with no redeploy.

## Tests

- **Domain:** the access matrix, `EffectiveModel` tier mapping, and refusing a default that starts with Codex.
- **Postgres (pgtest):** the backfill on `provider`, a person holding a Muse and a Claude connection at once, and the admin audit columns.
- **`Pick`:**
  - A judge gets the Muse connection, else free credits.
  - A Claude-only member gets their Claude connection, else workspace credits. **They never get free credits,** even with a free-credit balance.
  - A Codex stage needs only the workspace's OpenAI key, with no Claude account.
- **Scheduler:**
  - A ticket with analysis on Claude and coding on Codex picks two accounts and runs each stage on its own.
  - In workspace-account mode, a judge's ticket runs on Muse.
  - Removing a module mid-run takes effect at the next stage.
- **HTTP:**
  - A non-admin can't change modules.
  - Saving a changed field with a forbidden model returns 422.
  - Saving an unrelated field next to a stored forbidden model succeeds.
  - The catalog differs by viewer.
- **End to end:** a judge account and a normal account in one workspace run the same ticket settings on Muse and on Claude.

## Open questions

1. **Claude credits:** can people without their own Anthropic account run Claude on workspace credits (`PlatformKey`), or is it bring-your-own only? The plan assumes credits are allowed when `PlatformKey` is set.
2. **Codex:** is the workspace OpenAI key enough, or should a person also be able to connect their own key?
3. **Granularity:** is per person enough, or do you also want a per-workspace override (for example, a whole team that is Codex only)? A Codex-only team also needs Codex light and strong defaults.

## Implementation notes (Nov 1)

Built on branch `modules-access`. Where the code differs from the design above:

- **Access is explicit where it picks a model, from `ctx` only for wording.** Model choices take the person's access: `Settings.For(access)`, `ModelFor`, the review's auto choice and `SwaggerModel(access)`. The scheduler, assistant and meeting notes put the person's access on `ctx` (`domain.WithAccess`). Messages that name the tool read `domain.AccessOf(ctx)`, which falls back to the Admin's default. This keeps the compile-time check without threading `Access` through every message.
- **The orchestrator reads settings for the run's person** (`personSettings`, which applies `Settings.For`). The scheduler reads them as stored and maps them per queue item. The store never rewrites models.
- **Mapping to Muse is always Spark.** It is not tier for tier: the existing reason holds (Claude settings name opus a lot, and Wonder for every run costs about three times as much). Mapping to Claude keeps the tier (Wonder → opus, Spark → sonnet).
- **No "unsaved settings use the person's defaults".** Unsaved workspaces use the defaults of the Admin's default access as it was at server start, mapped like any other settings. A flag for this broke every hand-built `Settings`, so it was dropped.
- **Accounts on `ctx` are a set, one per module** (`domain.WithAccounts`). `callClaude` switches to the call's module (`domain.UseProvider`) and refuses a module the person may not use (`domain.NotAllowedError`). The run row records the default module's account. A run is settled on credits when any of its accounts is on credits.
- **The schema's `provider` column is generated from `kind`**, so nothing that inserts connections had to change.
- **Meeting notes always pick a Muse account:** only Muse transcribes audio. The assistant picks the module of the helper model.
- **The Admin's general choice** is written at start from `AGNTS_PROVIDERS` when missing (`modules.Service.Ensure`), not by the migration. It is cached for 15 s, and so is each person's access.
- **API:** `GET/PUT /platform/settings/modules`, `PUT /platform/users/{id}/modules`, `User.modules` on `/auth/me`, `PlatformUser.modules`, and `?provider=muse|claude` on the account and workspace connection GET/DELETE endpoints. `/models` is per viewer.
- **Codex in the run image** is still installed only with `--build-arg CODEX_VERSION=…`. Include `codex` in `AGNTS_PROVIDERS` only for an image built that way.
