# agnts on Muse — Plan

Oct 27, 2026 · @Rustam · Meta hackathon, Startup track · due Oct 30 (4 days)

## Overview

Muse Code (Meta's coding agent, `muse`) becomes agnts's only AI. Every model stage (analyze, coding, retry, helper, learn, review, preview, recheck), the assistant, documents and translation run on Muse. Claude Code and Codex are **hidden**: their code stays, but no page, endpoint or setting offers them while `AGNTS_PROVIDERS=muse`, which is the hosted default.

A run reaches Muse in one of two ways:

1. **The person's own Muse account.** A member or the workspace connects Muse the way Claude is connected today. Muse signs in with a Meta account through a device code (`muse login`): agnts shows the code, the person approves it in the browser, and agnts keeps the resulting token. An API key (`LLM_…`, `META_API_KEY`) also works. Usage is billed to their Meta account, so agnts only records it.
2. **agnts credits on the platform Muse key.** Runs use agnts's own Muse key and draw from:
   - **Free credits, per user, set by an admin.** Every user's limit is **0** by default. An admin raises it by hand for chosen accounts, such as the hackathon judges.
   - **Bought credits**, per workspace, through Payme or Click as today.

The Muse integration is a separate Go module, **`agnts-muse`** (`github.com/rustambekabdusalomov/agnts-muse`, folder `../agnts-muse`). **Judges review this module**, so it is the centrepiece: a library that drives Muse Code through its native session protocol, under a hard credit budget enforced live.

## How this scores

| Criterion | Weight | What we show |
| --- | --- | --- |
| Impact (Startup) | 30% | **An AI engineer that teams in emerging markets can afford and trust.** They pay in local currency (Payme, Click in so'm) for prepaid credits, the product speaks EN/RU/UZ, and there is never a surprise bill. agnts is already a working product (Jira and Plane, GitHub and GitLab, admin panel, mobile app). The business model: a margin on credits plus seat plans. Next step: the same budget engine as an API for any company putting agents into production. |
| Use of Meta AI tooling | 25% | We drive Muse Code through **MSP**, its native session protocol (`muse serve`), not by scraping CLI output. That lets us use what most integrations never reach:<br>• **Live cost** after every model call (`session/tokenUsage`).<br>• **Budget steering:** Muse is told mid-turn when its budget is low (`turn/steer`), and is stopped at the cap (`turn/interrupt`).<br>• **Escalating inside one session:** Spark becomes Wonder with the context kept (`session/setModel`).<br>• **agnts as the approval authority:** guard rules decide every tool call (`approval/requested` → `approval/decide`).<br>• **A model catalog read from Muse** (`model/list`).<br>• **Structured quotes** (`--output-schema`).<br>• **Visual review** of UI screenshots (images in a turn). |
| Technical depth | 20% | `agnts-muse`: a typed MSP client generated from Muse's own JSON Schema, card-style holds that never overspend under concurrency, integer money, typed errors, a fuzzed parser, a race-tested ledger, Postgres holds that expire, benchmarks, design decision records (ADRs) and CI. |
| Demo | 25% | Judge accounts with free credits, and a 3-minute video (script below). |

**Demo script (3 min):**
1. A Jira ticket gets the `agnts` label.
2. Muse quotes $0.40 and the person approves.
3. The live credit meter ticks after each model call.
4. Spark fails a check and the run escalates to Wonder in the same session.
5. A guard rule rejects `rm -rf` through an approval decision.
6. Muse reviews the UI screenshot and the PR is approved.
7. Second scene: three runs share a $1 budget. Muse is told to wrap up at 80%, and the third run is stopped at the cap. The receipt shows exactly $1.00.
8. Closing: Payme checkout in so'm, and the `agnts-muse` README with its benchmarks.

## What the CLI test found (Oct 27)

Tested with Muse Code 1.4.13. The recordings are in the scratchpad and move to `agnts-muse/testdata`, with local paths removed.

- **Headless runs:** `muse exec --json` prints an event log: envelopes with a `payload_type`, such as `run.output.delta`, `tool.result`, `task.lifecycle.*`, `run.usage` and `run.terminal.completed`. **Usage arrives only once, at the end**, so live enforcement can't be built on `exec`.
- **`muse serve`** is the session protocol (MSP): JSON-RPC 2.0, one message per line on stdio. It has 70 methods and 45 notifications, all described in a JSON Schema the binary exports (`muse schema generate-json-schema`, fingerprint `sha256:7fddaf64…`).
  - The ones we use: `initialize`, `model/list`, `session/start`, `turn/start`, `turn/steer`, `turn/interrupt`, `turn/cancel`, `session/setModel`, `approval/decide` and `usage/read`.
  - Notifications we listen to: `session/tokenUsage` (after every model call, with running totals and an estimated `cost.usd`), `item/*`, `turn/completed`, `approval/requested` and `usage/changed`.
  - `clientInfo.name` must match `^[a-z0-9_]+$`.
- **Models:** `muse-wonder-1.0` (the default), `muse-wonder-full-1.0`, `muse-spark-1.3` and `muse-spark-1.2`, with a context of about 1M tokens and 128k output. Effort levels run from minimal to max. `model/list` returns `cost: null` on a subscription, so the module keeps its own price table and prefers the server's cost whenever it is present.
- **Auth:** `META_API_KEY` always wins over a login. `muse login` is an OAuth device code, stored in the macOS keychain. **Still to test:** where a Linux container stores the login (day 2).
- **Other flags:** `--max-model-steps`, `--reasoning-effort`, `--output-schema`, `--image`, `--approval-mode never`, `--disable-web-tools`, `--no-session-log` and `--session-id`.
- **Allowance:** `run.usage.allowance` and `usage/read` report subscription use (a 5-hour window and weekly), like Claude's `rate_limit_event`.

## `agnts-muse`

A Go library that **runs Muse Code under a hard, live-enforced credit budget**. It works on its own, and agnts is its first user.

**How the budget works.** Charging after a run lets concurrent runs overspend: ten runs each see $5 left and each spend $5. The module treats credits like a card payment instead:

1. **Hold:** reserve an estimate before the turn starts.
2. **Extend:** grow the hold on every `session/tokenUsage` notification.
3. **Steer:** at 80% of the budget, tell Muse to wrap up (`turn/steer`).
4. **Interrupt:** when the hold can't grow, stop the turn (`turn/interrupt`).
5. **Commit:** charge the exact cost at the end.
6. **Release:** return whatever was reserved but not spent.

Every hold is one atomic conditional update, so the module stays correct with many servers sharing one database.

```
agnts-muse/
  muse.go               package muse: Engine, the façade that wires the parts below
  msp/                  MSP client: JSON-RPC 2.0 over stdio lines, request/response correlation,
                        typed notifications (iter.Seq), backpressure, graceful shutdown;
                        types generated from `muse schema` (go:generate), checked against the fingerprint
  code/                 Muse Code sessions:
    executor.go           Executor: starts `muse serve` and gives back its stdio. LocalExecutor
                          (os/exec) is included; agnts supplies a DockerExecutor
    session.go            Run(ctx, Request): start → turn → events; wires meter, budget, router and guard
    exec.go               fallback for one-shot `muse exec --json` runs (event-log parser)
  model/                catalog (from model/list plus local prices), versioned price tables, Cost(Usage)
  meter/                tokenUsage → cost deltas in Micros (int64 millionths of a credit)
  budget/               Ledger interface; Hold/Extend/Commit/Release with idempotency keys;
                        Payers chain (free → bought) and Limits (per-run cap, global cap)
    memledger/            in-memory Ledger: tests, examples, the demo CLI
  route/                Policy: Spark or Wonder from complexity, budget left and failed checks;
                        escalates with session/setModel and logs why
  guard/                Policy for approval/requested: allow, deny or ask, from rules (commands, paths)
  quote/                pre-run estimate with --output-schema: {low, expected, high} and reasons
  credential/           API key or device-code login: Kind, Check, Redactor (masks secrets in every event)
  observe/              Hooks (slog and OpenTelemetry): spend, holds, steers, interrupts, latency
  ledger/pgledger/      nested module: PostgreSQL Ledger (pgx), embedded migrations, expiring holds
  cmd/muse-budget/      demo CLI: `muse-budget run --budget 0.50 "fix the failing test"`, with a live meter
  examples/             a minimal budgeted run, a shared budget across goroutines, the guard policy
  testdata/             MSP and exec recordings (golden), the schema snapshot
  docs/adr/             0001 MSP over exec · 0002 holds over settling afterwards · 0003 Micros · 0004 nested modules
```

**Key interfaces** (sketch):

```go
type Ledger interface {
    Hold(ctx context.Context, h HoldRequest) (Hold, error)          // atomic; ErrInsufficient, ErrLimit
    Extend(ctx context.Context, id HoldID, by Micros) (Hold, error)
    Commit(ctx context.Context, id HoldID, actual Micros) (Receipt, error) // idempotent
    Release(ctx context.Context, id HoldID) error
}

type Executor interface {
    Start(ctx context.Context, argv []string, env []string) (io.ReadWriteCloser, error)
}

eng := muse.New(muse.Config{Ledger: led, Prices: model.Default, Router: route.Default, Guard: g, Hooks: observe.Slog(log)})
res, err := eng.Run(ctx, code.Request{Prompt: p, Workdir: "/workspace", Budget: budget.Spec{
    Payers: []budget.Account{user, ws}, RunCap: budget.Credits(25)}}, exec, onEvent)
```

**Quality bar:**
- **Money is integers.** All amounts are int64 `Micros`, and rounding happens once, at commit.
- **Errors are typed:** `ErrInsufficient`, `ErrLimit`, `ErrAuth`, `ErrRateLimited{Until}`, `ErrInterrupted{Reason}`, `ErrSchemaMismatch`.
- **Every call takes a context**, so cancellation works everywhere.
- **The core uses only the standard library.** pgx lives only in `pgledger`.
- **Tests:**
  - Golden tests on the recordings.
  - A fuzz test on the MSP and exec decoders.
  - A fake MSP server, so session tests run without Muse.
  - `-race`.
  - A concurrency test: 100 goroutines share one $1 budget and never overspend.
  - The same ledger tests against `pgledger` with testcontainers.
- **Benchmarks** for decoding events and for holds per second (memory and Postgres), with the numbers in the README.
- **CI** (GitHub Actions): `golangci-lint`, test with `-race`, a short fuzz, coverage, `govulncheck`, and a check that the generated MSP types match the schema snapshot.
- **Docs:** a README with diagrams and the benchmark numbers, godoc on every exported name, runnable `Example`s, ADRs, and the `v0.1.0` tag.

## agnts changes

- **Wiring.** `server/go.mod` requires `github.com/rustambekabdusalomov/agnts-muse`, with `replace … => ../../agnts-muse` until `v0.1.0` is pushed. The Docker build copies both directories.
- **Provider switch.** `AGNTS_PROVIDERS=muse` by default.
  - `domain.ValidModel`, the settings API, the model pickers, Integrations and onboarding offer only enabled providers.
  - Saved settings that name a hidden provider are read as the Muse default.
  - The `integration set claude` and `codex` commands refuse while their provider is hidden.
- **Models.** Add `MusePrefix = "muse:"`. Every stage defaults to `muse:spark`, and complex analysis, recheck and review default to `muse:wonder`. A migration rewrites existing workspaces' stage models.
- **Runner.** `runner/muse.go` adds a `DockerExecutor` (`docker exec -i` of `muse serve` in the run container) and calls `eng.Run`. It maps the module's events to `orchestrator.ClaudeEvent` and `ClaudeResult`, and records each model call as a `claude_calls` row with `cost_usd`, so analytics and the run history need no changes.
- **Runner image.** Pin `ARG MUSE_CODE_VERSION=1.4.13`, install `muse` and run `muse --version` in the build. Muse's home (`/home/agent/.local/share/muse`) is saved between a ticket's runs so sessions can resume. The Claude Code install becomes optional.
- **Connections.** A `muse_connections` table holds a workspace's or member's connection: `kind` (`login` or `api_key`), the credential encrypted like Claude's, the account label, `paused_until` and `last_error`.
  - `Pick` resolves the Muse connection first, then falls back to credits when they are available.
  - A paused connection (allowance used up, from `usage/changed`) also falls back.
  - **Device-code connect:** agnts runs `muse login` in a throwaway container, shows the code and link in the UI, then stores the credential file the login writes.
- **Free credits, per user.**
  - Migration: `users.free_credits_limit` (default 0).
  - The module's `pgledger` holds the accounts: `user:<id>:free` and `ws:<id>:paid`. Bought credits and admin grants post to it, so balances have one source of truth.
  - A platform run's payers are the ticket's member (the same person `whose()` picks today), then the workspace.
  - Limits are `RunCap` and `AGNTS_MUSE_GLOBAL_CAP_USD` a month.
  - `billing.Within` and `Settle` become thin wrappers.
- **Admin.** The platform admin's Users page gets free credits (limit, used, remaining) and a "Set free credits" action that records who set it. The billing page shows the user's free credits next to the workspace balance. OpenAPI changes, then `make gen`.
- **Guard.** agnts-guard's rules become an `agnts-muse` `guard.Policy`, so Muse runs keep the in-run checks that Claude Code's hooks gave. The checks after the run stay as a backstop.
- **Prompts and copy.** Prompts that name Claude say Muse, or name no tool. Bump `PromptVersion`. Update the README, website, admin panel and i18n (EN/RU/UZ).

## Schedule

**Day 1 — Oct 27: module core**
- Scaffold `agnts-muse`: go.mod, CI, lint, the README skeleton and the ADRs.
- `msp` (the generated types, the client, the fake server) with golden and fuzz tests.
- `model` and `meter`.
- `budget` and `memledger` with the concurrency test.

**Day 2 — Oct 28: sessions and wiring**
- `code.Session` with live holds, steer and interrupt.
- `route`, `guard`, `credential`, `observe`, and `cmd/muse-budget`.
- `pgledger`.
- agnts: `runner/muse.go`, the runner image, and an end-to-end local ticket on Muse.
- Find where a Linux container keeps the `muse login` credential.

**Day 3 — Oct 29: product**
- Connections, including device-code connect.
- Free credits and the admin action.
- The provider switch, with Claude and Codex hidden.
- The stage-model migration and prompts.
- A live credit meter on the run page (SSE).
- The quote step.

**Day 4 — Oct 30: demo**
- Visual review (if time allows).
- Seed judge accounts and deploy.
- Benchmarks and README polish, then tag `v0.1.0`.
- Record the video and submit.

**Cut first if late:** visual review, then the quote step (route and live budget stay), then the OpenTelemetry adapter (slog stays), then mobile screens (the admin panel only).

**Out of scope:** Llama and other open-weight models (no GPU), deleting the Claude Code or Codex code, auto-buying credits, a markup on runs that use the person's own token, and free credits that reset every month.

## Open questions

1. **Markup:** should bought Muse credits keep the 1.4× markup? (Free credits are counted at cost.)
2. **Device-code connect** depends on where Muse keeps the login on Linux. If it only uses a keyring the container can't reach, connections take API keys only.
