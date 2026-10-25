# agnts Server Architecture — Plan

Oct 24, 2026 · v1, nothing built yet; decisions and open questions at the end

## Overview

The server works well on one machine today. This plan does two things:

1. **Makes it safe to run on many machines** (API replicas, several workers, a fleet of runner hosts) for the cloud product, while self-hosted stays a single binary installed by `agnts install`.
2. **Stops the growth pattern** where every new feature lands in `orchestrator` and brings its own copy of the job queue.

It is **not** a move to microservices. The server stays a **modular monolith**: one codebase, one binary, run in different roles. Exactly one part becomes a separate service: the **runner-agent**, which owns Docker and runs the agents.

Target shape:

```
                ┌───────────── one codebase, one binary: agnts ─────────────┐
                │                                                            │
 clients ──► [ api ×N ]   stateless: HTTP, SSE, webhook ingress, MCP         │
                │  writes state + jobs + outbox in one transaction           │
                ▼                                                            │
           [ Postgres ]  data · jobs (leases) · outbox · LISTEN/NOTIFY       │
                ▲                                                            │
 [ worker ×N ]  scheduler + stage handlers + outbox dispatcher               │
                │  Session.Start / Exec / Stream / Cancel                    │
                └────────────────────────────────────────────────────────────┘
                ▼
 [ runner-agent ×M ]  the one separate service: Docker, sandbox, egress,
                      toolchains, warm workspaces; one per execution host
                ▼
 [ blob store ]  local disk (self-hosted) | S3 / MinIO (cloud)
```

- **Self-hosted:** `agnts serve --role=all`, with the runner in the same process. Nothing changes for customers.
- **Cloud:** API replicas behind Caddy, 2+ workers, and runner hosts added as demand grows.

## Why not microservices

| Goal | Would microservices help? |
|---|---|
| **Scaling** | Mostly no. The bottleneck is runner capacity (containers, memory, disk) and Claude rate limits, not the API. We need more runner machines, not more services. |
| **Fault tolerance** | Only for the runner. It runs untrusted code, gets OOM-killed and can hang on Docker. Everything else shares one Postgres, so splitting tickets from documents into services doesn't isolate any failure. |
| **Debugging** | Worse. One ticket would cross 5+ services and need distributed tracing, versioned contracts between services and correlated logs. Today one stack trace shows the whole path. Tracing inside the monolith (phase 6) gives the "follow one ticket" view without the cost. |
| **Self-hosted** | Big cost. Ten services means ten things every customer has to upgrade, match versions of and back up. |
| **Team size** | A small team can't own the network contracts, retries, deploy pipelines and monitoring of many services. |

A part becomes its own service only when it has **its own scaling curve, its own failure or security isolation need, or its own team**. Only the runner passes today. Later candidates: an LLM gateway (shared rate limits and cost control across workspaces) and webhook ingress (if delivery volume spikes). Neither is justified now.

## What exists today

Kept as they are, they're the foundation:
- **Explicit ticket state machine**: `transitions` in `domain/ticket.go:178`. Every change goes through `Store.Transition`, which writes the state and its event in one transaction.
- **Ports at the edges**: `orchestrator/ports.go` declares `Runner`, `Workspace`, `Git`, `Host`, `Tracker`. GitHub/GitLab and Jira/Plane plug in behind them, and tests use fakes.
- **Tenancy enforced by Postgres RLS**: `scopeConn` sets `app.workspace_id` and the role per connection (`store/postgres/postgres.go:62`), with the scope carried in `ctx` (`domain/workspace.go:165`).
- **Claiming with `FOR UPDATE SKIP LOCKED`** and recovery on start.
- **Contract-first API**: `shared/openapi/openapi.yaml` → `oapi-codegen` on the server, generated TypeScript and Dart clients.
- **The `documents` module** (`internal/documents`): its own service, a `Caller`, typed errors mapped in one handler function (`httpapi/documents.go`). This is the pattern new modules follow.

Problems this plan fixes:

**Blockers for running more than one machine** (each confirmed in code):
1. **Recovery assumes one process.** `RecoverInterrupted` (`store/postgres/tickets.go:555`) runs `UPDATE runs ... WHERE finished_at IS NULL` on start. With two workers, restarting one marks **every other worker's live runs** interrupted and re-queues them: duplicate Claude runs, duplicate commits. `RecoverRules`, `RecoverBriefs`, `RecoverDocumentRuns`, `RecoverReflections` and `RecoverTranscripts` have the same shape.
2. **Coordination state lives in process memory:**
   - `cancels` (`orchestrator/orchestrator.go:174`): Stop on API machine A can't cancel a run on machine B.
   - `transcripts`, `redactors` (`sync.Map`), `translating` (`singleflight`), `sched` (`schedState`).
   - `Broker.PublishTo` (`httpapi/stream.go:48`) sends unstored events only to streams in this process.
   - `ipLimiter` login, mail, feedback and public limits (`httpapi/server.go:144`) count per process, so N machines allow N× the attempts.
3. **State on local disk** (`cmd/agnts/serve.go:431-457`): `repos/`, `sessions/` (Claude homes), `previews/` (screenshots), `cache-stamps/`. A ticket that resumes on another machine loses its Claude session and screenshots.
4. **Attachments are `bytea` in Postgres** (`store/postgres/attachments.go:25`). That bloats backups and the shared buffer cache.
5. **Session-level `set_config`** (`postgres.go:85`, `is_local = false`). It works with our own pool, but a pooler in transaction mode (PgBouncer) would leak one workspace's setting into another tenant's queries.

**Structure problems:**

6. **`orchestrator` is a god package**: about 60 files, 156 exported methods, about 35 dependencies on one struct (`orchestrator.go:122`). Documents, swagger tests, assistant, translations, PR reviews, CI, previews and learning live next to the ticket pipeline, wired as nil-able fields.
7. **The `Store` interface is too wide**: `orchestrator.Store` has about 60 methods plus embedded interfaces, and `postgres.Agent` implements 162. Every fake has to implement all of it.
8. **The job queue is written five times**: tickets, rules, briefs, reflections and documents each have their own `Claim*`, `Recover*`, `Pending*Workspaces` and SKIP LOCKED query.
9. **Side effects run inline after the commit**: tracker `MoveTo` (`orchestrator.go:1888`), comments, notifications, PR creation. If the process dies between the commit and the call, or the provider is down, the effect is lost.
10. **The layering in the README isn't enforced.** `httpapi`, `admin`, `billing`, `accounts`, `documents`, `usage`, `notify`, `actions`, `mcpserver` and `claude` import `store/postgres` directly (`postgres.Payment`, `postgres.Integration`, `postgres.Feedback`…), and `store/postgres` imports `orchestrator` for its filter types.
11. **`cmd/agnts/serve.go` is about 1,200 lines**: composition root, background loops (`checkRepos`, `pruneDeliveries`, `sweepCaches`) and the eval CLI together.
12. **One global worker loop**: a burst of long `learn`/`reflect` runs can starve work someone is waiting on. A slow Jira or Telegram call holds a worker slot.

## Rules

These hold for all new code from now on, and for old code as it's moved:

- **Modules own their slice**: domain types, use cases, store, HTTP handlers. A module talks to another only through that module's small public API or through events, **never through another module's store**.
- **Interfaces are small and declared where they're used.** A use case declares the 2–5 methods it needs. One Postgres type may implement many small interfaces, but each module gets its own store type.
- **Every external side effect goes through the outbox.** No tracker, git host, Telegram or FCM call right after a commit.
- **Every background run is a job** in `platform/jobs`. No new `Claim*`/`Recover*` pair.
- **No coordination state in process memory.** Anything that must be seen by another process lives in Postgres (or the blob store). In-memory caches are fine if losing them is harmless.
- **No workspace data on local disk** except caches that can be rebuilt (repo clones, toolchains, package caches).
- **Every log line and span carries** `workspace_id`, and where they apply `ticket_key`, `job_id`, `run_id`.
- **Self-hosted stays one binary** with local-disk and in-process defaults. Cloud-only backends (S3, remote runners) are adapters behind the same interfaces.

## Target layout

```
server/
  cmd/agnts/            main: flags → app.Build(role); roles: api | worker | runner | all
  internal/
    platform/           cross-cutting, no business rules
      db/               pgx pool, tx helper, RLS scoping
      jobs/             the one durable queue: enqueue, claim, lease, heartbeat,
                        retry with backoff, cancel, per-workspace fairness, class pools
      outbox/           rows written in the business transaction; dispatcher delivers them
      events/           LISTEN/NOTIFY fan-out for the live stream
      blob/             local | s3
      httpx/ authz/ log/ metrics/ trace/
    kernel/             shared types: Workspace, User, Scope, errors, Event (today's domain core)
    modules/
      tickets/          the core pipeline
        domain/         Ticket, state machine, rules: pure
        app/            use cases: Approve, Answer, Reject, Continue… one file each
        stages/         analyze.go, code.go, test.go, push.go: each a job handler
        ports.go        small interfaces this module needs
        store/          Postgres implementation of those ports only
        http/           handlers for the tickets part of the OpenAPI
      execution/        Runner/Workspace port, local Docker adapter, remote adapter
      scm/              github, gitlab, local git repos
      trackers/         jira, plane, webhook ingestion → tickets.app.Ingest
      reviews/ documents/ swagger/ assistant/ learning/ billing/ accounts/ notify/ network/
    app/                composition root: builds modules, wires ports, registers job
                        handlers, outbox handlers and routes
```

Module boundaries are enforced with `depguard` in `.golangci.yml`, e.g. `modules/*/` may not import another module's `store` or `http`, and nothing outside `app/` and a module's own `store/` imports `platform/db` directly.

## Design

### Jobs with leases

One table replaces the five queues:

```sql
CREATE TABLE jobs (
  id            bigserial PRIMARY KEY,
  workspace_id  bigint NOT NULL,
  kind          text NOT NULL,        -- 'ticket.analyze', 'document.generate', …
  class         text NOT NULL,        -- 'rule', 'main', 'document', 'brief', 'review', …
  subject       text NOT NULL,        -- ticket key, document id, rule id…
  priority      int  NOT NULL DEFAULT 0,
  payload       jsonb NOT NULL DEFAULT '{}',
  state         text NOT NULL,        -- queued | running | done | failed | cancelled
  attempts      int  NOT NULL DEFAULT 0,
  run_after     timestamptz NOT NULL DEFAULT now(),
  locked_by     text,                 -- worker id
  lease_until   timestamptz,
  cancel_requested boolean NOT NULL DEFAULT false,
  wait_reason   text, wait_message text,
  created_at    timestamptz NOT NULL DEFAULT now(),
  finished_at   timestamptz,
  error         text
);
CREATE UNIQUE INDEX jobs_one_active ON jobs (kind, subject) WHERE state IN ('queued','running');
CREATE INDEX jobs_ready ON jobs (class, priority DESC, run_after) WHERE state = 'queued';
```

```go
jobs.Register("ticket.analyze", jobs.Handler{Class: ClassMain, Run: tickets.Analyze, MaxAttempts: 3})
jobs.Register("document.generate", jobs.Handler{Class: ClassDocument, Run: documents.Generate})
```

- **Claim**: `FOR UPDATE SKIP LOCKED`, set `locked_by`, `lease_until = now() + 60s`. Fairness across workspaces, slots, server memory and the Claude account limit (today's `WaitReason`, `domain/ticket.go:170`) are decided in the scheduler, once.
- **Heartbeat**: every 20s the worker extends `lease_until` for its running jobs and reads `cancel_requested`. If it's set, the worker cancels the run's context. This replaces the `cancels` map.
- **Recovery**: any worker may reclaim a job whose `lease_until` has passed. Nothing is recovered just because a process started, which fixes blocker 1.
- **Class pools**: each class has its own concurrency limit per worker and per workspace, so `learn`/`reflect` can't starve `main` or `document`.
- **Idempotency**: handlers must be safe to run again after a lost lease. Stages check the ticket's state and the run row before acting, and git pushes are guarded by the expected base SHA.
- **Unique active job** per `(kind, subject)`, so a double click or a duplicate webhook can't queue the same stage twice.
- `runs` keeps recording Claude invocations as today; `runs.job_id` links them.

### Transactional outbox

```sql
CREATE TABLE outbox (
  id bigserial PRIMARY KEY,
  workspace_id bigint NOT NULL,
  kind text NOT NULL,             -- 'tracker.move', 'tracker.comment', 'pr.open', 'notify.push', …
  dedupe_key text NOT NULL UNIQUE,-- e.g. 'tracker.move:<ticket>:<event id>'
  payload jsonb NOT NULL,
  attempts int NOT NULL DEFAULT 0,
  run_after timestamptz NOT NULL DEFAULT now(),
  delivered_at timestamptz,
  error text
);
```

- `Store.Transition` takes the outbox rows its use case produces and writes them in the same transaction as the state and event.
- A dispatcher (a job class of its own) delivers them with exponential backoff and a **circuit breaker per provider and workspace**. A Jira outage then means delayed comments, not lost ones and not stuck workers.
- Webhook **ingestion** is the mirror image: store the raw delivery (deliveries are already kept), dedupe on the provider's delivery id, then process it as a job.

### Blob storage

```go
type Store interface {
    Put(ctx context.Context, key string, r io.Reader, size int64, contentType string) error
    Get(ctx context.Context, key string) (io.ReadCloser, error)
    Delete(ctx context.Context, prefix string) error
}
```

- Backends: `local` (default, under `DataDir`) and `s3` (any S3-compatible: AWS, MinIO, R2).
- Moved to blob: Claude session homes (`gitrepo.NewHomes`), preview screenshots (`gitrepo.NewShots`), attachments (out of `bytea`, metadata stays in Postgres), document exports.
- Keys always start with `ws/<workspace id>/` so deleting a workspace (`workspaceFiles.RemoveWorkspace`, `serve.go:761`) is one prefix delete.
- Stay on local disk as **per-machine caches**, rebuilt when missing: repo clones, toolchains, package caches, `cache-stamps`.

### Cross-process state

| Today | Change to |
|---|---|
| `cancels` map | `jobs.cancel_requested`, read on heartbeat |
| `Broker` in-memory fan-out | `pg_notify` on event insert (stored events) and for `PublishTo` (unstored, small payload or id only); each API process `LISTEN`s and fans out to its own SSE streams |
| `ipLimiter` | a Postgres fixed-window counter table (`rate_limits(key, window, count)`), or Redis if one is added later |
| `schedState` | derived from `jobs` on each scheduling pass |
| `translating` singleflight | the unique active job per `(kind, subject)` |
| `transcripts`, `redactors` `sync.Map` | stay in memory, owned by the worker running the job; a stall note reads the transcript through the run row |

### Tenancy with a pooler

- Change `scopeConn` to set `app.workspace_id` and the role with `is_local = true`, at the start of every transaction. Reads outside a transaction run in a short one.
- Add a test that runs two workspaces' queries interleaved through PgBouncer in transaction mode and checks RLS still separates them.
- Until that test passes, the cloud deploy doesn't use a transaction-mode pooler.

### Observability

- OpenTelemetry tracing: one trace per HTTP request, one per job; the trace context travels in `jobs.payload` and `outbox.payload`, so a ticket's analyze → code → test → push is linked.
- Attributes on every span and `slog` record: `workspace_id`, `ticket_key`, `job_id`, `run_id`, `stage`.
- Metrics: queue depth and wait time per class, lease expiries, outbox backlog and failures per provider, runner capacity per host, Claude spend per workspace.
- Self-hosted: tracing off by default; logs carry the same attributes.

### Process roles

`agnts serve --role=api|worker|runner|all`:

| Role | Runs |
|---|---|
| `api` | HTTP, SSE, webhook ingestion, MCP. Never runs jobs. Stateless. |
| `worker` | scheduler, stage handlers, outbox dispatcher, periodic jobs (`checkRepos`, pruning, cache sweeps become scheduled jobs). |
| `runner` | runner-agent only (see below). |
| `all` | everything in one process with the in-process runner: today's behavior, the self-hosted default. |

### runner-agent

The one separate service.

- **Why**: different failure profile (untrusted code, OOM kills, Docker hangs), different security profile (root access to the Docker socket shouldn't sit next to the database credentials and secret key), and it's the dimension that needs to scale.
- **Boundary**: the existing `Runner`/`Workspace` port (`orchestrator/ports.go:203-284`). A remote adapter implements it over gRPC (or HTTP + a streaming endpoint): `Open`, `Claude` (streamed events), `Exec`, `ReadFile`, `WriteFile`, `ExportRepo`, `ExportClaudeHome`, `Close`, plus `Cancel` and `Capacity`.
- **Auth**: mTLS between workers and runner-agents; credentials (Claude token, git token) are sent per session and never stored on the runner host.
- **Placement**: runner-agents register their capacity (memory, disk, slots) in Postgres. The scheduler places a job on a host with room, **preferring the host that already holds the ticket's warm workspace**, falling back to a cold start.
- **Failure**: a runner host that stops heartbeating has its sessions' jobs' leases expire; they're reclaimed elsewhere and resume from the Claude home in the blob store.
- **Self-hosted**: the local Docker adapter stays in-process, unchanged.

## Phases

Order matters: phase 1 has to land before anything runs on two machines.

### Phase 1 — Leases and cancel through the database
- Add `locked_by`, `lease_until`, `cancel_requested` to `runs` (and to the rule, brief, document and reflection queues) as a bridge before the generic table.
- Workers heartbeat; recovery reclaims expired leases only. Delete the startup-time blanket `UPDATE`s.
- Stop/Reject set `cancel_requested`; the `cancels` map goes.
- **Done when**: two `serve` processes against one database, killing and restarting one, never interrupts the other's runs (integration test with `pgtest`).

### Phase 2 — `platform/jobs`
- Build the generic queue with class pools, fairness, wait reasons and unique active jobs.
- Migrate in order of risk: reflections → briefs → rules → documents → ticket stages.
- Each migration deletes its `Claim*`/`Recover*`/`Pending*Workspaces`.
- **Done when**: one claim query exists, and `orchestrator/scheduler.go` reads from `jobs`.

### Phase 3 — Outbox
- Add the table, the dispatcher and per-provider circuit breakers.
- Move tracker `MoveTo`/`Comment` first, then notifications (Telegram, FCM), then PR open/assign.
- Webhook deliveries become jobs, deduped on delivery id.
- **Done when**: no external call follows a commit directly in `orchestrator`; a test with a failing fake tracker shows the comment delivered after it recovers.

### Phase 4 — Blob storage
- Add `platform/blob` with `local` and `s3`.
- Move Claude homes, screenshots, then attachments (migration copies `bytea` out in batches, then drops the column).
- **Done when**: deleting `DataDir` on a worker loses only caches.

### Phase 5 — Cross-process state and tenancy
- LISTEN/NOTIFY broker, database rate limits, `schedState` from `jobs`.
- `set_config(..., true)` per transaction, plus the PgBouncer RLS test.
- **Done when**: an SSE client on API process A sees events produced by a worker on another machine, and login limits hold across two API processes.

### Phase 6 — Observability
- OpenTelemetry tracing and metrics, attributes on logs, trace context through jobs and the outbox.
- **Done when**: one ticket's whole life opens as one linked trace.

### Phase 7 — Process roles
- `--role` flag; `serve.go` shrinks into `app.Build(role)`; background loops become scheduled jobs; eval commands move to their own file.
- Staging runs 2 API + 2 workers.
- **Done when**: staging runs a week of normal load on 2+2 with no duplicate runs or lost events.

### Phase 8 — runner-agent
- Remote adapter behind `Runner`, mTLS, host registration and placement, warm-workspace affinity.
- **Done when**: a cloud worker drives runs on a separate runner host, and killing that host mid-run resumes the ticket on another.

### Alongside every phase — module boundaries
- `depguard` rules in warn mode from day one, error mode after the last move.
- Peel modules out of `orchestrator`, least coupled first: swagger → documents runs → assistant → translations → reviews/CI → previews → learning. Ticket stages move into `modules/tickets/stages` once they're jobs (phase 2).
- Move types like `postgres.Payment`, `postgres.Integration`, `postgres.Feedback` into their modules; only `app/` and a module's own `store/` import Postgres.
- Split `orchestrator.Store` into per-use-case interfaces as code moves. The orchestrator test fakes get smaller with each move.

## Not changing

- Postgres stays the backbone, including as the queue. A queue with `SKIP LOCKED`, leases and partial indexes handles thousands of concurrent jobs. Revisit NATS or Redis Streams only when measurements show the queue is the bottleneck.
- The OpenAPI contract, generated clients, goose migrations and RLS.
- The self-hosted install: one binary, Docker Compose, `agnts install`.

## Decisions

1. **Modular monolith, not microservices.** One codebase and binary, run in roles. Reasons in "Why not microservices".
2. **The runner is the only separate service**, behind the existing `Runner` port.
3. **Leases before roles.** No multi-machine deploy until phase 1 is done.
4. **Postgres for queue, outbox and events** until measured otherwise.
5. **Local defaults for self-hosted** (disk blob store, in-process runner, tracing off); cloud backends are adapters.

## Open questions

1. **gRPC or HTTP for runner-agent?** gRPC gives streaming and typed contracts; HTTP + SSE keeps one toolchain. Leaning gRPC.
2. **Redis or Postgres for rate limits?** Postgres avoids a new dependency for self-hosted; Redis is cheaper per check at high request rates.
3. **Does the assistant become a job class or stay request-scoped?** Today it answers inside the request path with its own recovery (`recoverAssistant`).
4. **Lease length** for long Claude runs: a fixed 60s with heartbeats, or per class?
5. **Should webhook ingress get its own role** (`--role=ingress`) so a delivery flood can't touch the API's capacity? Not needed yet; decide when volume is measured.
