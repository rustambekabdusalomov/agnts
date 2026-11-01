# AI gateway — Plan

Nov 1, 2026 · @Rustam · revised Nov 1 after review

## Overview

Today every feature that uses a model (ticket stages, assistant, meetings, documents, translation, briefs, rules, reflection, detection, second opinion, usage refresh) decides on its own which module runs, which account pays, and what happens when that account is at its limit. This plan puts one service between the features and the AI providers:

- **Features say what they need**, not where it runs: the purpose, the person, and a model or just a tier ("strong", "light") or a capability ("hears audio").
- **The gateway decides where it runs:** which module, which account, and how it is paid for. It looks at the person's modules, their connections, usage limits, free credits and workspace credits.
- **Providers plug in behind it.** Muse Code, Claude Code and Codex are each one implementation of one interface. A new provider is one package plus a line in the registry; a new feature is one call to the gateway.

```
 features (orchestrator stages, assistant, meetings, documents, translate, …)
        │   1. gw.Route(Who, Purpose, Want)  → Route (provider, model, account, caps)
        │   2. build the request from the Route
        │   3. gw.Run(Route, Request, Box)    → Result
        ▼
 ai.Gateway ── access (modules.Service)
   │  router ─── funding (connections + usage limits, free credits, workspace credits)
   │  spend (claude_calls) + transcripts (run history)
        ▼
 ai.Provider registry:  muse │ claude │ codex      (Catalog, Caps, Accounts, Exec)
        ▼
 ai.Box (run container) and ai.Boxes (open one) — implemented by the runner
```

## What is in the way today

1. **Provider knowledge is spread out.** Tiers and names live in `domain/providers.go`; account choice in `claude.Service.Pick`; credentials in `claude.CredentialFor`; execution in `runner.workspace.Claude`, which switches on the model's prefix (`runner.go:459`); effort, harness and live-chat choices in `claudeTurns` (`orchestrator.go:742-783`); key checks in `claude.Check` and `admin/openai.go`; wiring in `serve.go:446-537`.
2. **Every feature picks its own account, with its own rules.** The scheduler (`scheduler.go:528`, every module of the run), the assistant (`assistant.go:651`, the helper's module, never credits), meeting notes (`meetings.go:227`, always Muse). The usage refresher calls `ws.Claude` directly and skips transcripts and spend (`usage.go:438`).
3. **The account picked and the credential used are found separately.** The runner's `TokenSource` calls `CredentialFor(ctx)`, which reads the account back from `ctx` and, when there is none, falls back to the workspace's connection, then the actor's. Codex ignores the picked account and reads the OpenAI integration directly (`runner.go:170`, `serve.go:514`).
4. **Run state travels in `ctx`, with silent fallbacks.** `WithAccess`, `WithAccounts`, `UseProvider`, `CurrentProvider`, `ClaudeOf` (`set[""]` serves any module), `AccessOf` (falls back to the global default). Calls started from HTTP (translation, briefs, detection) carry no access and no account: access is not checked, and the credential comes from `CredentialFor`'s fallback, so they never run on credits. Readers of the account in `ctx` besides the runner: `musecredits.Budget`, the usage tracker, `KeepMuseLogin`, `LastSessionID`.
5. **No fallback between modules.** When a person's Claude account is at its limit the ticket waits, even when the same person may use Muse and has free credits.
6. **Credits overcharge mixed runs.** `billing.Settle` charges the run's whole `claude_calls` cost (less Muse free credits) whenever any of its accounts is on credits (`scheduler.go:700`, `billing.go:309`). A run with analysis on the member's own Claude account and coding on workspace credits is charged for both.
7. **Spend is recorded by each caller.** `recordSpend` (`orchestrator.go:850`) and the documents store write `claude_calls`; a call whose caller forgets is never charged and never shows in analytics.
8. **Model choices are made before the call, from the model name.** `claudeTurns` sets `run.Model`, drops effort for Codex, sets `Harness.Tool` and its guard event, and attaches live-chat steering (Muse only) before `callClaude`. Anything that changes the model after that leaves them wrong.
9. **Globals in `domain`:** the ceiling and the default access (`domain.SetProviders`, `SetDefaultAccess`) that 56 wording calls (`ToolName`, `AgentName`) read implicitly.

## Design

### Package layout

```
internal/ai/            types, registry, gateway, router, policy, funding
internal/ai/claude/     Claude Code provider
internal/ai/muse/       Muse Code provider (wraps agnts-muse)
internal/ai/codex/      Codex provider
internal/ai/aitest/     fake provider + fake box for tests
```

**`internal/ai` is a leaf.** It imports `domain` and nothing from `orchestrator`, `runner`, `musecredits`, `billing` or `usage`; those import `ai`, and `cmd/agnts` wires them together. The orchestrator's `ClaudeRequest`, `ClaudeResult` and `ClaudeEvent` become aliases of `ai.Request`, `ai.Result` and `ai.Event` while callers move over, then go.

`internal/claude` (accounts and connections) moves into `internal/ai` as `ai.Accounts`. `ClaudeAccount` becomes `ai.Account`. The `claude_connections` and `claude_calls` tables keep their names.

### Types

```go
// Who a call is for.
type Who struct {
    Workspace int64
    Person    int64  // whose modules (ticket's member, else default member, else owner; or the actor)
    Member    *int64 // whose account in per-member mode
    Actor     int64  // who asked, for messages; 0 for system work
}

// What a feature asks for.
type Want struct {
    Model ModelRef // an explicit model ("muse:wonder", "opus", "codex:gpt-5"); zero: any
    Tier  Tier     // Strong, Light or Auto when Model is zero, or when the router must replace it
    Needs Caps     // Audio, …
    Session *Session // a session to resume: its module and account; nil for none
    Pin   *Account // usage probe: this exact account, no routing
}

type ModelRef struct{ Provider, Name string } // stored as today: "muse:spark", "codex:x", "opus"

type Account struct {
    Provider     string
    ConnectionID int64   // 0 for platform keys and integrations
    Source       Source  // Connection | PlatformKey | Integration
    Payer        Payer   // Own | FreeCredits | WorkspaceCredits
    PayerUser    int64   // whose free credits
    Label        string
}

// Where a call will run: the router's answer.
type Route struct {
    Who      Who
    Purpose  Purpose
    Provider string
    Model    ModelRef
    Account  Account
    Caps     Caps   // the chosen provider's: Effort, Resume, InRunGuard, Steer, Ask, Audio
    Resume   string // the session id to resume, "" when the call starts fresh
    Rerouted string // why it does not run where asked, "" when it does
}

type Request struct { Prompt, MaxTurns, Timeout, Settings, Env, ReadOnly, Effort, Steer, Ask, RunID, WorkspaceID, … }
type Result  struct { today's ClaudeResult fields, plus Route }
```

### The provider interface

```go
type Provider interface {
    ID() string
    Name() string                       // "Muse", "Claude", "Codex"
    Catalog() Catalog                   // Parse, Valid, Models(), Model(Tier), TierOf(name)
    Caps() Caps
    Kinds() []AccountKind               // connection kinds it accepts, each with Check(ctx, token)
    PlatformKey() bool                  // agnts has its own key for it (credits possible)
    FreeCredits() bool                  // free credits may pay for it (Muse only)
    Credential(ctx, Account) (Credential, error)
    Exec(ctx, Box, Credential, Request, func(Event)) (Result, error)
    // AfterRun keeps what a run changed in its credential (Muse login refresh).
    AfterRun(ctx, Box, Account) error
}

// Optional: providers that hear audio.
type Transcriber interface {
    Transcribe(ctx, Box, Credential, audio []byte, ext string) ([]domain.MeetingSegment, error)
}
```

- **Claude:** today's `claude -p` path, `ParseStream`, model ids from `runner.Config.Models`, `CLAUDE_CODE_OAUTH_TOKEN` / `ANTHROPIC_API_KEY`.
- **Muse:** today's `workspace.muse`, the Muse engine, login keeping (`AfterRun`, from `KeepMuseLogin`), budgets from `Funding`, and `Transcribe` (from `runner/meetvoice.go`).
- **Codex:** today's `codex exec` path. Its account is the workspace's OpenAI integration (`Source: Integration`), so it goes through the same route and credential path as the others. Its light and strong models come from configuration, `AGNTS_CODEX_MODELS=light=<model>,strong=<model>`; until it is set Codex has no tiers and stays out of tier routing (the "Codex cannot be first" rules in `domain/access.go` stay until then).

`ai.Box` is what a provider needs from a container: `Exec(ctx, ExecSpec, stdout, stderr) (code, err)`, `Attach` (Muse's stdio), `ReadFile`, `WriteFile`, `OOM(code)`. `ai.Boxes` opens one from an image for calls that have no run container (meeting notes, the usage probe): `Open(ctx, BoxSpec) (Box, error)`. The runner implements both and keeps no provider code.

### The gateway

```go
type Gateway interface {
    // Admit decides, before a run starts, whether every call it will make
    // can run somewhere. Hold says why not and until when.
    Admit(ctx context.Context, who Who, purpose Purpose, wants []Want) (Admission, *Hold)
    // Route decides where one call runs: module, model, account, resume.
    Route(ctx context.Context, who Who, purpose Purpose, want Want) (Route, *Hold)
    // Run makes a routed call: enforce, fund, execute, record spend and
    // transcript, learn limits.
    Run(ctx context.Context, r Route, box Box, req Request, meta Meta, on func(Event)) (Result, error)
    // Transcribe routes a call that needs Audio, opens a box and hears it.
    Transcribe(ctx context.Context, who Who, audio []byte, ext string) ([]domain.MeetingSegment, error)
    // Catalog is what a person may pick from (settings pickers, /models).
    Catalog(ctx context.Context, person int64) (PersonCatalog, error)
}
```

**Route, then request, then run.** The caller asks for a route, builds the request from it, then runs it. This keeps model-specific choices correct when the router picks another module: `claudeTurns` sets `run.Model` from `Route.Model`, sets effort only when `Route.Caps.Effort`, the harness tool and guard event from `Route.Provider`, and live-chat steering only when `Route.Caps.Steer`. Features that need none of this can call a helper, `ai.Do(ctx, gw, who, purpose, want, box, req, meta, on)`, which routes and runs in one go.

`Run` does, in order:

1. **Access.** The person's modules from `modules.Service` (not from `ctx`), checked for every purpose. A route older than the admin's last change is checked again here.
2. **Funding gate.** On credits: `Within` (run cap, balance) and, for Muse, the ledger budget.
3. **Credential** from the route's account, through its provider. This is the only place a credential is made.
4. **Execute** through the provider with the box; then `AfterRun`.
5. **Record spend** into `claude_calls` with the route's provider, account and payer, for every call (it replaces `recordSpend` and the documents store's insert). **Record the transcript** when run history is on (today's `callClaude` recorder).
6. **Learn limits.** A rate-limited result marks the account paused (today `usage.OnPaused`).

The gateway's dependencies: `modules.Service` (access), `ai.Accounts` (connections), workspace settings (usage-limit thresholds for `usage.Paused`), `ai.Funding`, `ai.Boxes`, the store for spend and transcripts, and the registry.

### The router

Candidates are the person's modules, in their order. A call with an explicit model puts that model's module first; a call with only a tier or capabilities keeps the person's order. Modules without the needed capabilities, or not allowed for the purpose, are dropped.

For each candidate, in order, the first fundable account wins:

1. **Own connection:** the workspace's (shared mode) or the member's (per-member mode), when it is not paused at its limit.
2. **Free credits:** when the provider takes them, the purpose allows them, and the person has some left.
3. **Workspace credits:** when the purpose allows them, the workspace turned on continuing with credits, the provider has a platform key, and the balance is at least `MinCredits`.

The model on the chosen module is the explicit model when that module won, else the same tier on the chosen module (`Catalog.Model(TierOf(asked))`). If nothing is fundable, the call is held with the first candidate's reason (the same messages as today's `Pick`).

**Sessions.** A call with `Want.Session` prefers the session's module and account: when they can run, the route resumes it. When they cannot, the router moves on like any other call and the route starts fresh (`Resume` empty). This is what happens today when the account differs (`LastSessionID`, `tickets.go:550`): the stage prompt already carries the analysis, so a fresh session loses only the transcript.

**Admission.** `Admit` succeeds when every want has some fundable candidate, not only its first. The scheduler caches admissions per (person, member, purpose) for the tick, as `pickAccounts` caches accounts today. Each call still routes at its start, so a limit reached mid-run moves the next stage, not the current one.

**Mid-call limits.** A rate limit in the middle of a call ends it as today (the run pauses). The next call is routed again.

**Policy table** (data, in `ai/policy.go`), replacing the rules spread across callers:

| Purpose | Free credits | Workspace credits | May reroute | Needs |
| --- | --- | --- | --- | --- |
| ticket stages | yes | yes | yes | — |
| second opinion | yes | yes | no: on hold or failure it is recorded and skipped, as today | — |
| assistant | no | no | yes | — |
| meeting notes | yes | yes | yes | Audio |
| reflect, documents (run by the scheduler) | yes | yes | yes | — |
| translate, brief, detect, rules (started from HTTP) | no | no | yes | — |
| usage probe | no | no | no | Pin |

Free credits still pay only for providers that take them (`Provider.FreeCredits`, Muse). The HTTP-started purposes stay off credits, as today; turning them on is a separate decision. The second opinion runs nothing that waits on it (`secondopinion.go`), so it never holds a review.

A workspace setting **"Switch modules when one is unavailable"** (default on for new workspaces) turns rerouting off for teams that want a ticket to wait for its chosen model.

### Funding and spend

`ai.Funding` wraps what exists today, with the account passed in, not read from `ctx`:

- `billing.Service`: workspace credits (`Within`, `Settle`).
- `musecredits.Service`: free credits (`FreeAvailable`) and the Muse ledger budgets. `Budget(ctx, req)` becomes `Budget(ctx, acct, req)`.
- `usage.Tracker`: whether a connection is paused, and until when. `Paused` and `Current` take the account instead of reading `ClaudeOf`.

**Migration 00074** adds `provider`, `connection_id` and `payer` to `claude_calls`, backfilled from the run's account (`runs.claude_connection_id`, `runs.on_credits`) and the model's prefix. `RunCostUSD` then sums only calls paid by workspace credits, and `Settle` and `Within` charge that. `runs.claude_connection_id` and `on_credits` stay for display and for `LastSessionID`, which takes the session's account from `claude_calls` instead.

### What features call

The orchestrator gets one dependency, `AI ai.Gateway`, instead of `ClaudeAccounts`, `AccessSource` and `Credits` for model calls.

- `callClaude` becomes `gw.Route` + `gw.Run`. Its orchestrator work (fitting the prompt, setting the run ID) stays in a small helper.
- `claudeTurns` builds its request from the route (above).
- `pickAccounts` becomes `gw.Admit`.
- `assistantAccount` and the meeting pick are deleted: the policy table covers them; meetings call `gw.Transcribe`.
- The usage refresher calls `gw.Run` with `Pin` on a box from `Boxes`.
- Messages that name the tool use the route's provider, not `AccessOf(ctx)`.

**Tier settings.** Stage models keep their stored values. `ModelAuto` (`"auto"`, the review's choice by complexity) becomes `tier:auto`, and two values join it: `tier:strong` and `tier:light`, meaning "the router picks the module". `"auto"` still parses as `tier:auto`. New workspaces default to tiers, so they follow each person's modules without mapping. Explicit models still work and map through `EffectiveModel` until someone changes them.

### API

- `Settings` model fields accept `tier:auto|strong|light`.
- `/models` (per viewer) lists tiers and each module's models, from `gw.Catalog`.
- A ticket event type `rerouted`: "analysis ran on Muse Wonder: Claude limit reached on Acme's account, resumes at 15:00".
- The run page's spend lists each call's module, account and payer (from `claude_calls`), replacing the single account.
- The workspace setting for switching modules.

OpenAPI changes, then `make gen`.

### What goes away

- `domain/providers.go` tier and model helpers (`StrongModel`, `LightModel`, `IsStrong`, `AvailableModels`, `ProviderOf`, `IsMuse`, `IsCodex`): replaced by the registry's catalogs.
- `domain.WithAccounts`, `UseProvider`, `CurrentProvider`, `ClaudeOf`, `AccountsOf`, `WithAccess`, `AccessIn`, `AccessOf`, `SetDefaultAccess`, `DefaultAccess`, and the ceiling global. The ceiling is a `modules.Service` field.
- `runner.TokenSource`, `SetCodexKey`, `SetMuse`, `SetMuseLoginKeeper`, `TranscribeMeeting`, `workspace.Claude`'s prefix switch.
- `claude.Service.Pick`, `CredentialFor`, `CreditsEnabled`, `connProvider`; `recordSpend`.

A test in `internal/ai` lists the packages that may import `internal/ai/claude`, `ai/muse`, `ai/codex`: only `internal/ai` and `cmd/agnts`. Features cannot reach a provider around the gateway.

## Steps

Each step builds, passes tests and can be deployed alone.

0. **Fix the overcharge now.** Migration 00074 (`claude_calls.provider`, `connection_id`, `payer`, backfilled). The scheduler already knows each call's account (`ClaudeOf` after `UseProvider` in `callClaude`); `recordSpend` writes it. `RunCostUSD` sums only calls paid by workspace credits. Small, independent of the rest, and fixes a live bug.
1. **Types and registry.** `internal/ai` as a leaf, with `ModelRef`, `Tier`, `Caps`, `Account`, `Route`, `Request`/`Result`/`Event`, `Provider`, the registry, and catalogs for the three providers. The orchestrator's `Claude*` types become aliases of `ai`'s; `musecredits.Budget` and the runner take `ai.Request`. `domain/providers.go` functions become thin wrappers over the registry. No behaviour change.
2. **Providers own execution.** `ai.Box` and `ai.Boxes`; the runner implements them. Move the three exec paths into `ai/claude`, `ai/muse`, `ai/codex`, and meeting transcription into `ai/muse` as `Transcriber`. `workspace.Claude` delegates to the registry. No behaviour change.
3. **Gateway with today's routing.** `Route` and `Run` with access from `modules.Service`, account choice moved from `claude.Pick`, credentials from the route's account (Codex included), spend and transcripts recorded in `Run`. Every `callClaude` call site and the usage refresher switch to it; `claudeTurns` builds its request from the route. Delete `CredentialFor`, `TokenSource`, `codexKey`, `recordSpend`. The router never reroutes yet: the same results as today.
4. **Admission, policy, no `ctx` carriers.** `Admit` replaces `pickAccounts`; the policy table replaces `assistantAccount` and the meeting pick. Change the remaining readers of the account in `ctx`: `musecredits.Budget`, the usage tracker (`Paused`, `Current`, the resolver in `serve.go`), `KeepMuseLogin` (now `AfterRun`), `LastSessionID`. Then delete the `ctx` carriers, `ClaudeAccounts` and `AccessSource`, and move about 25 `AccessOf` call sites to the route. This is the largest step.
5. **Rerouting.** The router tries the next module and the next payer, at the same tier; sessions prefer their module and start fresh when they move; `Admit` counts fallbacks; the workspace setting; the `rerouted` event; Codex tiers from `AGNTS_CODEX_MODELS`.
6. **Tier settings.** `tier:auto|strong|light` in settings, pickers, the catalog, OpenAPI and `make gen`; new workspaces default to them.
7. **Clean up.** Remove the globals in `domain`, the wrappers from step 1, the orchestrator's aliases, and `internal/claude`. Add the import test.

## Deploy order

Follow `deploy.md`. Steps 0–4 change no routing decision, so they deploy as usual; check after step 0 that a mixed run charges only its credit-paid calls. Step 5 changes where runs go:

1. Deploy step 5 with the workspace setting **off** for existing workspaces (on for new ones).
2. Turn it on for the agnts workspace; check the `rerouted` event on a ticket whose Claude account is paused.
3. Turn it on by default.

Undo: turn the setting off. Nothing is rewritten in storage.

## Tests

- **Billing (step 0):** a run with one call on a connection and one on workspace credits charges only the second; the backfill sets payer from the run's account.
- **Router (table tests, fake providers):** each person × connection state × free credits × workspace credits × purpose → the chosen provider, model, account and payer, or the hold reason. Includes:
  - A judge (Muse only) with free credits and no connection runs on free credits.
  - A Claude-only member never gets free credits.
  - A Claude limit reroutes a `tier:strong` analysis to Muse Wonder for a person with both, and holds it for a Claude-only person.
  - A session resumes on its module when it can, and moves and starts fresh when it cannot.
  - The assistant and HTTP-started purposes never run on credits; meeting notes need Audio; the second opinion never reroutes.
  - `Admit` succeeds when only a fallback module is fundable.
- **Gateway:** access is checked for every purpose; the credential comes from the route's account; every call writes `claude_calls` once with its provider, account and payer, with run history on and off.
- **Route-then-request:** a rerouted Codex stage sends no effort; a stage rerouted off Muse gets no live-chat steering; `run.Model` and the harness tool match the route.
- **Providers:** each exec path against a fake box, with the existing stream, Muse and meeting tests moved over.
- **Scheduler:** `Admit` holds a ticket with the right reason; a limit reached between stages reroutes the next stage.
- **Import tests:** `internal/ai` imports no feature package; no package outside `internal/ai` and `cmd/agnts` imports a provider package.
- **End to end:** the Modules plan's judge and normal accounts in one workspace, plus a paused Claude account rerouting to Muse.

## Open questions

1. **Cost-based routing.** The router picks by the person's order, then funding. Should it also prefer the cheaper module when both are fundable on credits (for example Muse Spark over Claude sonnet for helper calls)?
2. **Credits for HTTP-started work.** Translation, briefs, detection and rules stay off credits, as today. Should a workspace with credits on pay for them when no connection works?

## Implementation notes (Nov 1)

Built on branch `ai-gateway`, one commit per step. Where the code differs from the design above:

- **Packages.** The gateway is `internal/ai` (it imports `domain` alone). The providers are `internal/ai/providers/claudecode`, `musecode` and `codex`; `internal/ai/aitest` has stand-ins for tests. `internal/claude` became `internal/ai/connections` (its package name would have clashed with `internal/accounts`). `TestImportBoundaries` fails when anything outside `internal/ai` and `cmd/agnts` imports a provider, or when `internal/ai` imports a feature.
- **The run's admission travels on `ctx`, as one typed value** (`ai.WithAdmission`). The account carriers are gone: `WithAccounts`, `WithClaude`, `UseProvider`, `CurrentProvider`, `ClaudeOf`, `AccountsOf`, and with them the "an account without a module serves any call" and "no account: the workspace's, then the actor's connection" fallbacks. Threading the admission through every orchestrator function as a parameter was not worth the churn. A call outside an admitted run is routed when it is made, for its person.
- **Access on `ctx` stays** (`domain.WithAccess`/`AccessOf`): settings map models through it, and about 25 messages name the tool with it. The gateway does not trust it alone: it reads the person's modules from `modules.Service`, and a call with no person uses the workspace's default member. `DefaultAccess` and the ceiling stay in `domain` as the Admin's default and `AGNTS_PROVIDERS`.
- **Transcripts stay in the orchestrator** and attach to the call through a hook (`ai.Recording`). The gateway finishes the transcript before it records spend, so the spend row still points at it.
- **Spend.** Migration 00074 adds `provider`, `connection_id` and `on_credits` to `claude_calls` (a flag, not a payer column: free and workspace credits are told apart by the Muse ledger, as before). The gateway records every call of a ticket run or a document generation. It also records every rate-limit reading and refusal on the call's account, which nine callers used to do by hand.
- **Policy.** Briefs and rule reviews are scheduled work and may run on credits, as they did before; the table above had them off credits. Answers, spoken questions, translation, detection and the usage probe never run on credits. A second opinion and the usage probe never switch modules.
- **Switching modules** (`Settings.switchModules`) is on for new workspaces, and for workspaces that never saved their settings. Migration 00075 turns it off for the ones that did. A route the admission moved serves the run's calls at their own tier; a second opinion routes on its own and is skipped when its module cannot run.
- **Codex tiers** come from `AGNTS_CODEX_MODELS=light=<model>,strong=<model>`. Without it Codex runs only the models settings name, and calls never switch to it.
- **Tiers.** Settings and ticket overrides may name `tier:light` or `tier:strong`. Defaults stay concrete models: haiku, the helper's default, has no tier of its own. `auto` (the review's choice by complexity) is unchanged rather than renamed `tier:auto`.
- **Hearing.** Meeting notes and spoken questions route through the gateway (`Hear`, `HearClip`) to the provider that hears audio. Spoken questions used to pick the account of the helper model's module: with a Claude helper, Muse got a Claude credential.
- **The usage probe** runs only for Claude accounts (Muse reports its limits after every run); it used to send `haiku` to paused Muse accounts too.
