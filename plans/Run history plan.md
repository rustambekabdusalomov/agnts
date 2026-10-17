# agnts Run History — Plan

Oct 17, 2026 · draft

## Overview

When a run goes wrong, for example it stalls, loops on a failing test, burns $4 on a one-line fix, or opens a PR that misses the point, the only record left is the ticket's event log. That log keeps Claude's text cut to 4000 characters and the *names* of the tools it called. The prompt agnts sent, the tool inputs and outputs, and the raw stream are thrown away. Claude calls made outside a ticket run leave no trace at all: the assistant, repository briefs, detect, reflect, rules, second opinion and translate.

This plan records a **full transcript for every Claude and Codex invocation** and gives Admins (the operator console, `/platform/*`) one place to find, filter and read them across all workspaces. Every time an Admin opens a transcript, that is written to an audit log.

```
Admin › Runs                                   [workspace ▾] [stage ▾] [status ▾] [last 7 days ▾]

Started        Workspace   Ticket   Stage    Model    Turns  Cost    Duration  Outcome
10:42 today    iman        API-71   code     opus     38     $1.84   6m 12s    ✓ done
10:31 today    iman        API-70   code     opus     120    $4.10   24m 03s   ✗ max turns · ⚠ 2 stalls
10:30 today    acme        —        brief    sonnet   9      $0.12   41s       ✓ done
…

Run #18342 · iman / API-70 · code · opus
[Timeline] [Prompt] [Result] [Download JSONL]
 00:00  prompt         12.4 KB  (ticket, brief, rules, harness)
 00:03  assistant      "I'll start by reading the order service…"
 00:04  Read           src/orders/service.go            ✓ 212 lines
 00:09  Bash           go test ./orders/...             ✗ exit 1 · 3.1 KB output
 …
 24:03  result         error_max_turns · 120 turns · $4.10
```

**Goals**

- Every invocation is recorded: ticket runs and background calls alike, Claude and Codex.
- A transcript holds enough to see *why*: the prompt, every message, tool inputs and outputs, errors, timings, tokens and cost.
- Admins can find a run in seconds: filter across workspaces by workspace, user, stage or purpose, model, outcome, cost and date.
- Customer secrets never land in the history. Every Admin read leaves an audit row.
- Storage stays bounded: compressed, with per-transcript caps and a retention window.

**Out of scope for v1:** showing transcripts to workspace members (phase 2; the API is shaped so the same reader serves both), live tail of a running transcript (phase 2; Logs/SSE already cover live progress), re-running from a transcript (Replay already does that from the ticket), full-text search inside transcripts, keeping Claude Code's raw stream-json lines (only the normalised stream is kept), and cost alerts ("a run passed $5"), which fit this table but belong in a later Analytics change.

## What exists today

| Piece | What it records | Gap |
|---|---|---|
| `runs` | One row per ticket stage: stage, model, session, turns, exit reason, harness, prompt version | Only ticket stages; no prompt, no content |
| `claude_calls` | Tokens and cost per invocation (`run_id`, `ticket_id` NOT NULL) | Written only by `recordSpend` (`orchestrator.go:719`) for ticket stages. Background calls (assistant, brief, detect, reflect, rules, second opinion, translate) record no cost anywhere |
| `events` | `claude_text` (cut to 4000 chars), `claude_tool` (name + short summary), `claude_result` | No tool input/output, no tool results, no prompt |
| `runner.ParseStream` | Parses stream-json and emits `ClaudeEvent`s | `ClaudeToolResult` carries only `id`, `is_error`; `contentBlock` has no field for a tool result's `content` |
| Codex parser (`codex.go`) | `command_execution` and `file_change` items | Command output is not parsed; file changes carry only the path |
| `o.redactors` | Masks credentials in streamed events | Set only for Swagger test runs (`swaggertest.go:124`); every other run, and every background call, is unmasked |
| Operator console | Overview (live runs), workspaces, users, admins, feedback | No run history |

Every invocation goes through one method, `Workspace.Claude(ctx, ClaudeRequest, onEvent)` (`server/internal/runner/runner.go:450`), and Codex goes through it too (`codex.go`). That is the single place to record. There are 9 call sites: 8 in the orchestrator (`orchestrator.go:663` for ticket stages, plus `assistant.go`, `brief.go`, `detect.go`, `reflect.go`, `rules.go`, `secondopinion.go`, `translate.go`) and the usage refresh in `usage/usage.go:438`. The usage refresh is a one-turn "reply OK" probe in a throwaway container with no workspace, used to read plan limits, so it is **deliberately not recorded**.

## Data model

Migration `00052_run_history.sql`.

```sql
-- One row per Claude Code / Codex invocation: ticket stages and
-- background calls (assistant, brief, detect, reflect, rules, second
-- opinion, translate). body is the normalised event stream as gzipped
-- JSONL; the prompt is kept apart so lists never load it.
CREATE TABLE transcripts (
    id            bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    workspace_id  bigint      NOT NULL REFERENCES workspaces (id) ON DELETE CASCADE,
    run_id        bigint      REFERENCES runs (id) ON DELETE SET NULL,
    ticket_key    text        NOT NULL DEFAULT '',   -- no FK: history outlives deleted tasks, like events
    claude_user_id bigint     REFERENCES users (id) ON DELETE SET NULL, -- whose Claude account paid (per-member mode); NULL = the workspace's shared account
    purpose       text        NOT NULL,              -- the call site: code, analyze, review, assistant, brief, detect, reflect, rules, second_opinion, translate
    model_stage   text        NOT NULL DEFAULT '',   -- first pass, fix attempt n (matches claude_calls)
    engine        text        NOT NULL CHECK (engine IN ('claude', 'codex')),
    model         text        NOT NULL DEFAULT '',
    session_id    text        NOT NULL DEFAULT '',
    started_at    timestamptz NOT NULL DEFAULT now(),
    finished_at   timestamptz,
    -- How the invocation ended. A stall is not an ending: the run goes on
    -- after agnts nudges Claude, so stalls are counted below instead.
    status        text        NOT NULL DEFAULT 'running' CHECK (status IN ('running', 'done', 'error', 'timeout', 'cancelled', 'oom')),
    exit_reason   text        NOT NULL DEFAULT '',   -- result subtype (error_max_turns, …) or the error text
    turns         integer     NOT NULL DEFAULT 0,
    tool_calls    integer     NOT NULL DEFAULT 0,
    tool_errors   integer     NOT NULL DEFAULT 0,
    stalls        integer     NOT NULL DEFAULT 0,    -- stalls detected during this invocation (from run.Harness.Stalls)
    input_tokens  bigint      NOT NULL DEFAULT 0,
    output_tokens bigint      NOT NULL DEFAULT 0,
    cost_usd      numeric(12,6) NOT NULL DEFAULT 0,
    prompt        bytea       NOT NULL DEFAULT '',   -- gzip
    body          bytea       NOT NULL DEFAULT '',   -- gzip JSONL, see "Event format"; appended in chunks while running
    raw_bytes     integer     NOT NULL DEFAULT 0,    -- uncompressed size so far
    truncated     boolean     NOT NULL DEFAULT false
);
CREATE INDEX transcripts_started_idx   ON transcripts (started_at DESC);
CREATE INDEX transcripts_ws_idx        ON transcripts (workspace_id, started_at DESC);
CREATE INDEX transcripts_run_idx       ON transcripts (run_id) WHERE run_id IS NOT NULL;
CREATE INDEX transcripts_ticket_idx    ON transcripts (workspace_id, ticket_key) WHERE ticket_key <> '';

ALTER TABLE claude_calls ADD COLUMN transcript_id bigint REFERENCES transcripts (id) ON DELETE SET NULL;

-- Who on the operator side read what. admin_name is copied so the log
-- still says who it was after the Admin account is deleted.
CREATE TABLE admin_audit (
    id         bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    admin_id   bigint      REFERENCES users (id) ON DELETE SET NULL,
    admin_name text        NOT NULL,
    action     text        NOT NULL,   -- transcript.view, transcript.prompt, transcript.download
    target     text        NOT NULL,   -- "transcript:18342"
    workspace_id bigint    REFERENCES workspaces (id) ON DELETE SET NULL,
    ip         inet,
    created_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX admin_audit_created_idx ON admin_audit (created_at DESC);
```

`transcripts` gets the same row-level policies as `runs`, so a workspace-scoped connection can only ever see its own rows. That matters for phase 2. Admin reads go through `domain.System(ctx)`, the way `GetPlatformOverview` does. `admin_audit` is server-level, with no workspace policy.

**The workspace id is always passed in, never inferred.** Background loops (brief, reflect and rules recovery) run under `domain.System(ctx)`. There `agnts_fill_ws` falls back to `agnts_ws()`, which returns NULL, so a `NOT NULL` insert would fail. The recorder therefore takes `WorkspaceID` as a required field of `TranscriptStart`, and each call site supplies it from the ticket or the workspace it acts in. A zero id is a programming error: the recorder logs it and skips recording. It never fails the run.

**Why bytea in Postgres, not files in `AGNTS_DATA_DIR`:** attachments set the precedent. One store, row-level security applies, transactional deletes, and the nightly backup covers it. Expected size is 30–150 KB gzipped for a code run and a few KB for background calls. With retention (below) that stays at a few GB even on a busy install. If it outgrows that, `body` can move to object storage behind the same store interface without changing the API.

## Event format

`body` holds one JSON object per line, normalised so Claude and Codex read the same way:

```jsonc
{"t": 3120, "k": "text",        "text": "I'll start by reading…"}
{"t": 4010, "k": "tool",        "id": "tu_1", "name": "Bash", "input": {"command": "go test ./orders/..."}}
{"t": 9220, "k": "tool_result", "id": "tu_1", "error": true, "output": "--- FAIL: …", "cut": 18234}
{"t": 9300, "k": "rate_limit",  "status": "allowed_warning"}
{"t": 1443000, "k": "result",   "subtype": "error_max_turns", "text": "…", "turns": 120, "cost": 4.10}
{"t": 1443010, "k": "note",     "text": "stall detected: same failing test 6 times"}   // agnts-side markers
{"t": 5100, "k": "file_change", "id": "it_4", "path": "src/orders/service.go", "diff": "@@ …"}   // Codex only
```

`t` is milliseconds since `started_at`. `cut` gives the original length when an output was shortened.

**Caps:**

| Limit | Value |
|---|---|
| One tool output | 16 KB, first 12 KB + last 4 KB, so the error at the end survives |
| One text block | 32 KB |
| One transcript | 8 MB uncompressed; after that only `tool` and `result` lines, no content, and `truncated = true` |

All three are system settings, so an operator can raise them.

## Recording

1. **Claude parser.** `contentBlock` gains a `Content json.RawMessage` field. `runner.ParseStream` fills `ClaudeToolResult.Data["output"]` from the `content` of the `tool_result` block, which is either a string or an array of text parts (joined). `ClaudeTool` already carries the full input as `json.RawMessage`; expose it in `Data["input"]`.
2. **Codex parser.** `codex.go` reads two fields it ignores today:
   - the `command_execution` item's `aggregated_output`, which goes into `ClaudeToolResult.Data["output"]` together with `exit_code`;
   - the per-change diff on `file_change` items, which is emitted as a `file_change` line.

   Codex stores no file content, so a change without a diff is recorded with its path only. Confirm the field names against the Codex CLI version in the runner image, and add a fixture from a real run.
3. **Masking happens in the runner, first.** Every container gets the Claude login token as an environment variable (`CLAUDE_CODE_OAUTH_TOKEN`, `runner.go:462`). Once tool outputs are stored, a Bash call to `env` or `printenv`, or a test that dumps its environment, would write the token into the transcript. `workspace.Claude` is the only layer that knows the token and the `req.Env` values, so it builds a `domain.Redactor` from:
   - `cred.Token`;
   - every value in `req.Env`, `modelEnv(w.models)` and the container's own spec env that is longer than 8 characters.

   It masks each event's `Text` and `Data` before calling `onEvent`. Nothing above the runner ever sees those values, events included, which also closes the same leak in today's `claude_text` events.
4. **Masking above the runner, second.** The recorder then applies:
   - the run's `o.redactors` entry when there is one, which today is only for Swagger test credentials (`swaggertest.go:124`);
   - a generic pass for the usual token shapes: `ghp_…`, `github_pat_…`, `glpat-…`, `sk-…`, `sk-ant-…`, `xox[abpr]-…`, `AKIA…`, `Bearer …`, `Authorization:` headers, and PEM private-key blocks. This catches a secret Claude read out of a repo's `.env`.

   The prompt passes through both steps too.
5. **Recorder.** A new `orchestrator.Recorder` port, implemented by `store/postgres`:
   - `Start(ctx, TranscriptStart) (id, error)` inserts the row with `status = running` and the gzipped prompt. `WorkspaceID`, `Purpose` and `Engine` are required.
   - `Append(ctx, id, chunk []byte, counts)` appends a gzip chunk: `body = body || $2`, along with the running counts.
   - `Finish(ctx, id, TranscriptEnd)` writes the last chunk, tokens, cost, status, exit reason and `stalls`.

   Lines go through a gzip writer in memory. The buffer is flushed as its own gzip member every **256 KB of input or 60 seconds**, whichever comes first. Concatenated gzip members are one valid gzip stream, and Go's `gzip.Reader` reads them as one. A 24-minute run therefore loses at most its last minute on a crash, not the whole transcript. At most one write a minute per running call keeps database load negligible.
6. **One wrap point.** A `recording(ws Workspace, meta TranscriptStart) Workspace` decorator in the orchestrator wraps `Claude(...)`. It calls `Start`, tees `onEvent` into the buffer (then calls the original handler), and calls `Finish` with the result or error. Recording problems are logged and never fail the run. Each of the 8 orchestrator call sites passes its workspace id, `purpose`, and `run`/`ticket` when it has them. The ticket stage path (`orchestrator.go:663`) also passes the stall count, read from `run.Harness.Stalls` before and after the call. The usage refresh (`usage/usage.go:438`) is not wrapped.
7. **Crash safety.** A transcript still `running` when the server starts is closed as `error`, with exit reason `server restarted`. Its appended chunks are kept. This runs next to the existing start-up recoveries (`RecoverInterrupted` in `store/postgres/tickets.go:551`, `RecoverBriefs`, `RecoverReflections`, `RecoverRules`).
8. **Link.** `claude_calls.transcript_id` is set in `recordSpend` (`orchestrator.go:719`), the only place `claude_calls` is written. That covers ticket stages only. Background calls have never had a `claude_calls` row, so for them the transcript's own `input_tokens`, `output_tokens` and `cost_usd` are the **first record of what they cost**. The Admin summary shows that spend as a separate "background" line, so it doesn't look like it came from nowhere.

## Retention

- System setting `run_history.retention_days`, default **30**, editable in the Admin console (0 = keep forever).
- A new daily loop in `cmd/agnts/serve.go` deletes in batches of 1000: `DELETE … WHERE started_at < now() - interval`. It sits next to the existing 24-hour ticker (`serve.go:609`) and `pruneDeliveries`, and follows the same pattern.
- `admin_audit` is kept for 365 days, separately.
- Deleting a workspace cascades to its transcripts. Deleting a ticket does not, which matches `events`.

## API (OpenAPI, `x-scope: admin`)

| Operation | Notes |
|---|---|
| `GET /platform/runs` | List transcripts. Filters: `workspace`, `claudeUser`, `purpose`, `status`, `stalled` (stalls > 0), `model`, `engine`, `ticket`, `from`, `to`, `minCost`. Keyset pagination on `(started_at, id)`, 50 per page. Returns metadata only, never body or prompt. |
| `GET /platform/runs/summary` | Totals for the current filter: count, cost, tokens, error rate, stall rate, p50/p95 duration. Cost is split into ticket stages and background calls. Drives the strip above the table. |
| `GET /platform/runs/{id}` | Metadata plus the whole timeline in one response (`body` decoded; at most 8 MB, so no paging) and sibling transcripts of the same run (first pass and fix attempts). The UI virtualises the list. Writes `transcript.view` to the audit log. |
| `GET /platform/runs/{id}/prompt` | The decoded prompt. Audited as `transcript.prompt`. |
| `GET /platform/runs/{id}/download` | The normalised JSONL (the stored event lines, not Claude Code's raw stream-json). Audited as `transcript.download`. |
| `GET /platform/audit` | The audit log, filterable by admin, action and workspace. |
| `GET/PUT /platform/settings/run-history` | Retention and caps. |

Audit rows are written before the response, in the same handler. If the audit insert fails, the read fails too, so no content is ever served without its audit row. Run `make gen` after the spec change.

## Admin console

New pages under `apps/admin/src/pages/admin/`, with routes and nav next to Workspaces and Feedback:

- **`AdminRunsPage.vue`:** the summary strip, the filter bar (filters kept in the URL query), and a table with the columns shown in the Overview. Timeout, error and OOM rows are tinted, and runs that had stalls show a ⚠ count next to the outcome. A workspace name links to that workspace's admin page. The workspace admin page also gains a "Runs" link with its filter set.
- **`AdminRunPage.vue`:** a header with run facts (workspace, ticket, stage, model, engine, Claude account, prompt version, harness, cost, tokens), then tabs:
  - **Timeline:** a virtualised list. Tool calls are collapsible, showing input as formatted JSON and output in a monospace block. Errors are red, and a "jump to next error" button skips between them.
  - **Prompt:** the decoded prompt.
  - **Result:** the result text plus the `results` row (summary, tests, lint, files) when there is one.
  - **Download JSONL:** a button, not a tab.

  A banner states "Viewing customer content. This access is logged."
- **`AdminAuditPage.vue`:** a plain table of audit rows.
- Strings go in `shared/i18n/*.json` (EN/RU/UZ), then `make gen`.

## Rollout

1. **Parser + recorder + migration.** Tool outputs reach `ClaudeEvent`, transcripts are written for every call site, and retention runs. Nothing is visible yet; check row sizes on the dev and prod databases for a few days.
2. **Platform API + audit log + Admin pages.**
3. **Phase 2 (separate plan):** a "Transcript" tab on the ticket page for workspace owners, through the workspace-scoped path and row-level policies, with no audit needed; live tail over the existing SSE stream; full-text search.

## Tests

- **Stream fixtures:** `stream_test.go` gains fixtures with `tool_result` blocks (string content, array content, `is_error`). `codex_test.go` gains a `command_execution` item with `aggregated_output` and a `file_change` item with a diff, taken from a real Codex run.
- **Runner masking:** a fixture where a Bash tool result contains the output of `env` (with `CLAUDE_CODE_OAUTH_TOKEN=<token>` and a `req.Env` value). The events passed to `onEvent` contain neither value. This applies to Claude and Codex alike.
- **Decorator:**
  - records start, appends and finish on success, error, timeout, OOM and cancelled contexts;
  - flushes on size and on time, and the concatenated body decodes as one stream;
  - applies caps (a 20 KB output keeps its head and tail);
  - applies the second masking step (a Swagger credential and a `ghp_` string in a tool output come out masked);
  - a failing recorder does not fail the run;
  - the ticket stage records the stalls counted during the call.
- **Coverage guard:** a test that scans all of `server/internal/` (not just the orchestrator) for `.Claude(ctx` calls. It fails on any call not wrapped by `recording(...)` with a purpose, except the usage refresh in `usage/usage.go`, which is listed by name.
- **Postgres (`AGNTS_TEST_DATABASE_URL`):**
  - row-level security: a workspace-scoped connection sees no other workspace's transcripts;
  - an insert under `domain.System(ctx)` with an explicit workspace id succeeds;
  - retention deletes only rows older than the window;
  - the restart sweep closes `running` rows and keeps their appended chunks;
  - deleting an Admin who has audit rows succeeds, and the rows keep `admin_name`.
- **HTTP:**
  - a non-admin session gets 403 on every `/platform/runs*` route;
  - every content read writes exactly one audit row;
  - a failing audit insert makes the read fail;
  - the list never returns `body` or `prompt`.
- **Admin UI:** a page test for filters reflected in the URL and for the timeline rendering a tool error.

## Open questions

- Should the Claude Code session directory (`ExportClaudeHome`) also be archived for a run, so a transcript could be resumed? It is larger and duplicates most of `body`. Not proposed for v1.
- Should the GitHub/GitLab token be added to the runner's mask list as well? That depends on whether it ever reaches the container's environment or git config, or only the egress proxy. Check before step 1 ships.
