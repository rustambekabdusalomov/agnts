# agnts Team chat (members + agents in one room) — Plan

Nov 3, 2026 · draft, revised Nov 3 (answers below) · for the Muse hackathon, due **Nov 4** · builds on `Assistant actions plan.md` (action cards, the shared `actions` package),
`Log watcher plan.md` (findings), `AI gateway plan.md` (every model call) and the event stream (`httpapi/stream.go`)


> **Status (2026-11-03): implemented, phases 0–5** (branch `team-chat`). Where the build differs from the plan below:
>
> - **Migration** is `00079_chat.sql` (78 was taken). Chat events are ordinary `events` rows (`chat_message`, `chat_card`,
>   `chat_ref`, `chat_channel`) whose data is the whole message; the Logs page and the dashboard's feed leave them out.
>   `chat_thinking` is live only (`Broker.PublishWorkspace`).
> - **agnts's channel** is a flag on `chat_channels` (`agents`), not a setting; #general has it until another channel
>   takes it.
> - **Model calls:** one transcript purpose, `team_chat` (the subject says link, answer, ticket or code), on
>   `Models.TeamChat` (follows `Models.Chat` when unset; links on the light model of its provider). The answer is the
>   model's final text, parsed as JSON and checked; the gateway has no output-schema field yet, so Muse's
>   structured output (`--output-schema`) is not used.
> - **Warm box:** one empty container per workspace kept 10 minutes (`orchestrator.ChatModel`), reusing the assistant's
>   warm-container map; a call that fails closes it.
> - **Merge** is `orchestrator.MergeTicketPR`, a new function next to the pull-review merge (not extracted from it):
>   it merges a done ticket's open PRs at the head agnts pushed. CI comes from GitHub's check runs
>   (`vcs.Multi.CommitChecks`; GitLab shows "none") and is refreshed every 45 s on open PR cards.
> - **Deploy notes** ("Deployed ✅") are not built: agnts says "Merged ✅" only.
> - **Memory** (`internal/chat/memory.go`) answers `@agnts`, and AI Chat gets it as `memory.json` in its snapshot
>   (`mcpserver.Deps.Memory`, prompt `2026-11-03.1`), citing ids the same way.
> - **Viewers** may read, send, mark read and remove a link; buttons, Turn into ticket and new channels are for editors
>   (the API's role middleware).

## Overview

Workspace members talk in channels, and agnts sits in the same room as a teammate. It posts **cards** when work needs a
person (a change is ready, a PR can be merged, production is throwing errors), and a tap on a card does the real thing
through the same write path as the assistant and MCP. A model reads the conversation as it happens: it **links**
messages to tickets, PRs and findings, **turns a message into a ticket**, and **answers `@agnts` questions with
citations** you can click.

**Workspace memory, shared by both chats.** One module, `internal/memory`, knows the workspace: repositories,
tickets and their progress, CI, findings, and what the team said in chat, with the links between them. It answers
`@agnts` in the members' chat **and** feeds the existing AI Chat (the private assistant), so both can say where an
answer came from (`[msg:812] [pr:131] [ticket:LOG-9]`).

**Any connected model, picked in Settings.** Like review, documents and meeting notes, the team chat has its own model
setting (**Settings → Models → Team chat**). It can be any model the workspace has connected and the person may use:
Muse Code, Claude Code or Codex. Muse is the default for the hackathon demo, but nothing in the chat depends on it.
Everything goes through the AI gateway, which handles which account pays, usage limits and credits, as for every
other call.

```
# payments                                                              Ann, Bo, agnts · 3 online
┌──────────────────────────────────────────────────────────────────────────────────────────────┐
│ Bo     the CSV export on payments is timing out again for big merchants            10:02     │
│        [PAY-214 Payments CSV export] [finding #12]   ← chips fade in ~2 s later              │
│        hover: ✨ Linked by Muse · 1.2s — mentions payments CSV export                         │
│                                                                                              │
│ agnts  ┌ ● error in billing-worker ────────────────────────────── ✨ Muse · 0.9s ┐   10:03     │
│        │ panic: assignment to entry in nil map  ×37 in 4 min                     │             │
│        │ billing/coupon.go:88 · repo agnts · Loki (prod)                         │             │
│        │ [Fix it]  [Mute]  [Open finding]                                        │             │
│        └─────────────────────────────────────────────────────────────────────────┘             │
│ agnts  ┌ ✓ LOG-12 ready for review ─────────────────────────────────────────────┐   10:11     │
│        │ Guard nil map in coupon apply · 2 files +14 −3 · checks green · $0.31   │             │
│        │ [Approve → open PR]  [Request changes]  [View diff]                      │             │
│        └─────────────────────────────────────────────────────────────────────────┘             │
│ Ann    approved                                                                    10:12     │
│ agnts  ┌ PR #142 open ─────────────────────────────────────── [Merge] [View] ┐       10:12     │
│ agnts  Merged ✅ #142 (merge) by Ann                                               10:13     │
│                                                                                              │
│ Ann    @agnts why did the CSV export break last week?                              10:20     │
│ agnts  A query without a limit was added in the export rewrite [pr:131]; Bo reported the      │
│        timeout the next day [msg:812] and LOG-9 capped it at 10k rows [ticket:LOG-9].         │
│        ✨ Muse · 2.4s · 3 sources                                                            │
└──────────────────────────────────────────────────────────────────────────────────────────────┘
  [ message #payments … ]                                   ⋯ on any message: Turn into ticket
```

**Goals**

- Sending is instant and never lost or doubled: an offline message waits on the device and goes out once on reconnect.
- Every AI action shows a model badge with how long it took (`✨ Muse · 1.2s`), and every model
  output is checked by the server before anyone sees it.
- A card's button does the real thing (approve opens the PR, merge merges on GitHub), with the same checks as the
  ticket page.
- The demo's log-watcher scene ends in the chat: finding → fix → approve → merge, without leaving the room.

**Principles**

1. **The model proposes, the server decides, a person taps.** The model never builds a card's actions, never confirms, and
   only picks from candidates the server gave it. Ids it invents are dropped.
2. **One write path.** Card buttons call `actions.Deps` (Prepare, then Execute), the same code as the assistant and MCP.
   A tap on a card is the confirmation (`Assistant actions plan.md`, principle 3).
3. **AI work is never on the send path.** A message is committed with its jobs in one transaction (outbox); workers do
   the model calls afterwards and push the results as events.
4. **Provider-neutral.** Prompts, schemas and checks are the same whichever model runs; only the gateway knows the
   provider.
5. **Reuse the event stream.** Chat events are rows in `events`, so the SSE broker's Last-Event-ID replay already covers
   reconnects; a per-channel `after=` fetch closes anything older than the replay cap.

## Decisions

| Question | Decision (proposed) |
| --- | --- |
| Rooms | Workspace channels (`#general` made with the workspace, members create more). Every member sees every channel. No DMs in v1 |
| Who may do what | Everyone reads and posts. Card buttons, Turn into ticket and Assign: `role.CanEdit()` (owners, users), checked on the tap. Viewers can ask `@agnts` |
| Where agnts posts cards | In the channel the ticket came from (a ticketized message); otherwise the workspace's **agent channel** (`settings.chat.agentChannel`, default `#general`) |
| Message kinds | `text`, `agent_card`, `agent_text` (answers, "Merged ✅"), `system` (joined, renamed) |
| Card payload | JSON `{type, state, …}` built by the server from domain data. Types: `log_finding`, `review_ready`, `pr_opened`, `ticket_draft` |
| Which model | A new stage model, **Team chat** (`domain.ModelTeamChat = "team_chat"`, `StageModels.TeamChat`), in Settings → Models next to Review and Documents. Any connected model the person may use (`AllowedModel`). Unset, it follows the assistant's Chat model, like Documents follows Analyze. The existing `chat` stage stays the private assistant's |
| Which model for what | Answers and Turn into ticket run on the Team chat model. Linking runs on the light tier of the same provider (the gateway's `lightOf`: Muse Spark, Haiku, the Codex mini), so it stays cheap and fast whatever is picked |
| Model calls | All through the AI gateway: new purposes `chat_link`, `chat_ticket`, `chat_answer` (in the run history and spend like the others). The gateway's normal routing applies: the person's modules, connections, usage limits, free credits, then workspace credits |
| Latency | A warm box per workspace for chat calls, whatever the provider (see Design). Target: chips p50 ≤ 3 s, answers p50 ≤ 6 s; the first call after idle is slower (container start) |
| Retrieval | Postgres only: refs graph + full-text search (`tsvector`, `'simple'` config, like meetings, because EN/RU/UZ mix). No vector database |
| Cost | Linking runs only when a message has ≥ 4 words and no explicit refs; per-workspace daily caps (500 links, 200 answers, settable). Funded like other background calls, by the gateway |
| Surfaces | Admin web only (`ChatPage.vue`). No mobile in this plan |
| Merge and CI | Merge is offered whatever CI says. The `pr_opened` card shows the checks; when they are red or still running, it says so and the confirm dialog repeats it ("CI is failing: 2 checks red. Merge anyway?") |
| "Deploying" | agnts says "deploying" only when the repo has a deploy pipeline it watches (`EventDeploy`); then it posts "Deployed ✅" or the failure. Otherwise just "Merged ✅" |

## Design

### Data (`00078_chat.sql`)

```sql
chat_channels   (id, workspace_id, name, topic, created_by, created_at, archived_at)
                unique (workspace_id, lower(name))

chat_messages   (id bigserial, workspace_id, channel_id, reply_to,          -- reply_to: one level of threads
                 author_user_id null, author_agent text null,                -- exactly one is set
                 kind text check (kind in ('text','agent_card','agent_text','system')),
                 body text,                                                  -- ≤ 8 KB
                 card jsonb,                                                 -- agent_card only
                 ai jsonb,                                                   -- {provider, model, ms, cost_usd} on AI output
                 client_msg_id uuid null, created_at, edited_at,
                 search tsvector generated always as (to_tsvector('simple', coalesce(body,''))) stored)
                unique (workspace_id, author_user_id, client_msg_id)
                index (channel_id, id), gin (search)

chat_refs       (message_id, ref_type, ref_id, source, confidence, reason, ai jsonb, created_at)
                -- ref_type: ticket | pr | repo | finding | doc ; source: explicit | muse | card
                primary key (message_id, ref_type, ref_id), index (ref_type, ref_id)

chat_jobs       (id, workspace_id, message_id, kind, state, attempts, run_after, last_error, created_at)
                -- kind: link | answer | ticketize ; the outbox, taken with FOR UPDATE SKIP LOCKED

chat_reads      (user_id, channel_id, last_read_id)                         -- unread counts
```

Card state lives in `card.state` (`open`, `done`, `failed`, `expired`) with `card.by` and `card.at`, updated in place;
the change is an event, so every client redraws the card.

### Packages

Follows the existing layers: `domain/chat.go` (types, card types, ref parsing), `internal/chat` (use cases: send, list,
cards, jobs, the linker, ticketize, answer), `store/postgres/chat.go`, `httpapi/chat.go`, `apps/admin/src/pages/ChatPage.vue`
plus `components/chat/`. `internal/chat` declares the interfaces it needs (`Actions`, `Gateway`, `Reads`) and
`cmd/agnts` wires them.

### API

| Call | What |
| --- | --- |
| `GET /chat/channels`, `POST /chat/channels` | List (with unread counts), create |
| `GET /chat/channels/{id}/messages?before=&after=&limit=` | Page back, or fill a gap after `last_seen_id` |
| `POST /chat/channels/{id}/messages` | `{client_msg_id, body, reply_to}` → 201 new, 200 if that `client_msg_id` was already stored (same message back) |
| `POST /chat/messages/{id}/actions` | `{action, args}` on a card → runs it, returns the updated card |
| `POST /chat/messages/{id}/ticket` | Turn into ticket → 202; the draft card arrives as an event |
| `PUT /chat/channels/{id}/read` | `{last_read_id}` |

Events (stored, so replayed on reconnect): `chat_message`, `chat_card` (card state changed), `chat_ref` (chips added),
`chat_channel`. Live only (`Broker.PublishTo`-style, not stored): `chat_typing` and `chat_thinking` (agnts is working on
an answer).

### Sending, and nothing lost or doubled

```
client                                server (one transaction)                      workers
 ├ bubble shown at once (pending)      insert chat_messages                          take chat_jobs
 ├ outbox: {client_msg_id, body}  ──▶  on conflict (ws, author, client_msg_id)        SKIP LOCKED
 │  kept in IndexedDB until 2xx          → return the stored row                     ├ link → chat_ref event
 │                                     insert events (chat_message)                  ├ answer → agent_text
 └ on 2xx: pending → sent, by id       insert chat_jobs (link [, answer])  ── NOTIFY ┘
```

- **Idempotency:** `client_msg_id` (a UUID made on the device) is unique per author. A retry after a lost response
  returns the stored message; the client matches it by `client_msg_id` and never shows two.
- **Outbox (client):** unsent messages live in IndexedDB in order and are sent one by one when the connection is back.
  A message that fails with a 4xx (too long, channel archived) is marked failed with Retry and Delete.
- **Outbox (server):** jobs are committed with the message, so a crash between "saved" and "model called" loses
  nothing; a job that fails retries with backoff (3 tries), then is dropped with `last_error`.
- **Resume:** SSE reconnects with Last-Event-ID (already built, replays up to 1000 events). On reconnect the client
  also calls `messages?after=<last_seen_id>` for each open channel, so a long outage is filled too. Messages are keyed
  by id, so the overlap is harmless.

### Fast model calls, on any provider

Today each light call (log triage, for example) opens a fresh container (`runner.Open`) and runs a short agent session:
seconds to start before the model even thinks. Chips that arrive a second or two later need a warm path:

- **One warm chat box per workspace:** a container kept open while the workspace's chat is active (closed after 10
  minutes idle), like the assistant's warm container per person. It has no repo, no network beyond the model's API, no
  agnts tokens.
- **A fresh session per job**, so nothing leaks between messages or channels, on whichever provider the route picked:
  - **Muse:** a new MSP session on a running `muse serve`, with structured output (the job's JSON Schema). This is the
    fastest path and the Meta-tooling point for the write-up.
  - **Claude Code / Codex:** a new one-shot CLI call in the same box, no tools, writing its answer to
    `/agnts/out/<job>.json`, as triage does.
  - Either way the server validates the answer against the same JSON Schema; one retry on invalid JSON, then the job
    fails quietly (no chip, or "I couldn't answer that" for `@agnts`).
- If the Team chat model changes in Settings, the warm box is closed and the next job opens one for the new provider.
- Each result records `{provider, model, ms, cost_usd}` from the provider's usage report (MSP `tokenUsage` for Muse,
  the CLI's result for the others). The badge shows the time; its name is static for now (below).
- Fallback: when the warm box is down, the job opens a cold one, as triage does; the badge just shows the longer time.

This needs a small addition to the gateway: an `ai.Call` that runs on a reusable `Box` and carries an output schema,
with each provider deciding how to honour it (`Caps.Schema` for native structured output; otherwise write-file and
validate). For Muse, the provider also gains "start a session on an open `muse serve`".

### 1. Agents as teammates: action cards (build first)

A subscriber in `internal/chat` turns ticket and log events into cards:

| Event | Card | Buttons → what runs |
| --- | --- | --- |
| `log_finding` (new, mode report or ticket) | `log_finding`: service, title, count, file:line, repo, source | **Fix it** → the log watcher's open-ticket path; **Mute**; **Open** |
| `review_ready` | `review_ready`: title, summary, files +/−, checks, cost | **Approve** → `actions.ApproveTicket` (push + open PR); **Request changes** (asks for text); **View diff** |
| `pr_opened` | `pr_opened`: number, URL, CI state (green / running / red, with the failing check names) | **Merge** → new action `merge_pull` (below), never blocked by CI; **View** |
| `pr_merged`, `deploy` | `agent_text`: "Merged ✅ #142 (merge) by Ann", "Deployed ✅" / the failure | — |

- **Merge for agnts's own PRs is new.** Today only reviewed outside PRs are merged (`orchestrator/pullreview.go:650-690`).
  That block moves into one function, `MergeTicketPR`, used by both: it reads the PR, refuses when it is closed or the
  head moved since approval, merges with the workspace's method (`settings.PullReviews.MergeMethod`), and records
  `pr_merged`. `actions` gets `merge_pull` (destructive: the web asks once more, repeating the summary and, when CI is not
  green, which checks are red or running). The card's CI line updates live from `ci_failure` and check events.
- A tap: `POST /chat/messages/{id}/actions` checks the action is on the card and the card is `open`, checks the role,
  runs Prepare + Execute with `domain.OriginChat` ("by Ann via chat" in the ticket history), sets `card.state`.
  A second tap (another member, a double click) gets "Already approved by Ann" instead of a second run.
- Cards follow the ticket: when the ticket moves on elsewhere (approved on the ticket page), the card's state updates.

### 2. Live auto-linking

On each new `text` message, the `link` job:

1. **Explicit refs first, no model:** ticket keys (`PAY-214`), `#142`, PR and ticket URLs, repo names. Stored with
   `source: explicit`, confidence 1.
2. **The model only for the rest**, when the message has ≥ 4 words: the message, its thread parent, and candidates: open
   tickets (≤ 50, newest first), repos, the last 20 PRs, open findings (≤ 10). Asked for
   `[{ref_type, ref_id, confidence, reason}]` under a JSON Schema.
3. The server keeps refs that are **in the candidate list** with confidence ≥ 0.7, at most 3, and sends `chat_ref`.
   Chips fade in; hover shows `✨ Linked by Muse · 1.2s — <reason>` (the name is static "Muse" for now, see below). A member can remove a wrong chip (kept as a
   negative example in `chat_refs` with `source: removed`, for tuning later).

Message text is untrusted, but the output can only select from server-made candidates, so a prompt injection can at
worst attach a wrong chip.

### 3. Turn into ticket

`⋯ → Turn into ticket` on any message (editors). The `ticketize` job sends the Team chat model the message, its thread (≤ 10
replies), its refs and the repos, and asks for `{title, description, acceptance_criteria[], repo, kind}`. The server
checks the repo is one of the workspace's, then posts a `ticket_draft` card in the thread:

- **Create task** → `actions.CreateTask` (a local task, as today), the card becomes a link to the ticket.
- **Create and assign to agent** → `CreateTask`, then `StartRun`. From then on the ticket's cards (`review_ready`,
  `pr_opened`) come back to this thread: chat → ticket → coding agent → PR → merge in one place.
- **Edit** opens the fields inline before creating.

### 4. Workspace memory, and `@agnts` questions with citations

**What it is.** A retrieval layer (RAG: fetch the relevant pieces, give only those to the model, make it cite them),
in one package used by both chats:

```go
// internal/memory
type Query struct { Text string; Refs []domain.Ref; Asker int64; Channel int64 }
type Item  struct { ID string /* "msg:812", "ticket:LOG-9", "pr:131", "repo:agnts", "finding:12" */; Kind, Title, Text string; At time.Time; URL string }
func (m *Memory) Recall(ctx context.Context, q Query) ([]Item, error)   // ≤ 40 items, ≤ ~12k tokens, newest-first within rank
```

**Where its knowledge comes from** (nothing is copied into a second store; it reads the live tables):

| Source | How it is found |
| --- | --- |
| Tickets and progress (state, stage, summary, PR, cost, who is waiting) | Refs in the question; full-text over title + description + summary of the workspace's tickets; the inbox for "what is waiting on me" |
| Repositories (name, groups, brief, open tickets, recent merges) | Repo names in the question or its refs; the repo's brief (agnts's survey of its architecture, `domain.Brief`, ≤ 40 KB) and lessons |
| The code itself | Not in `Recall`: a question the brief can't answer goes to the code step (below) |
| PRs and CI | Refs; the last PRs and CI failures of the repos found |
| Log findings | Refs; open findings of the services and repos found |
| Team chat | Messages that share the question's refs (`chat_refs`, last 90 days); full-text over messages (`tsvector`, `'simple'`) |
| Facts that are not search results (usage, analytics, me) | The same reads as the assistant snapshot (`mcpserver.Snapshotter`), when the question is about them |

**No embeddings, no vector database (v1).** The questions are about named things (a ticket, a repo, a service, a
person, last week), which ids, links and keyword search find exactly, and the facts change every minute (ticket
state, CI), which an embedding index would have to keep re-embedding. Postgres full-text plus the links graph is
exact, always current, needs no new service and no embedding model. `Recall` hides how it searches, so semantic
search (pgvector, embeddings from the connected provider) can be added behind it later, for questions phrased with
none of the words of the answer.

**Who sees what.** Everything memory reads is already visible to every member of the workspace (all channels are
public to members). The private assistant's own conversations are **not** read by memory, so nothing one person asked
privately shows up in a shared answer.

**`@agnts` in the members' chat.** A message that mentions `@agnts` gets an `answer` job (after its `link` job, so its
refs exist):

1. `memory.Recall` with the question and its refs.
2. The items go to the Team chat model with their ids. The prompt says to answer only from them and cite every
   claim. Schema: `{answer_md, citations[], insufficient, needs_code: {repo} | null}`. `needs_code` means the question
   is about how code works and the brief does not say; the server then runs the code step instead of posting.
3. The server removes citations that were not in the items. If none are left and `insufficient` is false, the reply
   becomes "I can't find that in this workspace's chat, tickets or PRs." The answer posts as `agent_text` with the
   badge and "3 sources"; each citation renders as a chip that jumps to the message or opens the ticket, PR or repo.
4. It does not take actions; asked to, it says which card or page does it.

**The code step (phase 2b): "How is auth implemented on api_gateway?"** When the fast answer sets `needs_code`, or
the question names a repo and asks how or where something is done in it and that repo has no brief yet:

1. agnts posts `🔍 Looking at api_gateway's code…` (an `agent_text` that the answer later replaces).
2. A `code_answer` job opens a **read-only box** with the repo checked out at the default branch's head, the same
   checkout path tickets use (`runner.Open` with the repo). No push credentials, no agnts tokens, no network beyond
   the model's API; the guard's rules apply as on any run, and its tools are limited to reading and searching
   (`grep`, `find`, reading files).
3. The Team chat model searches and reads the code itself, the way it does on a ticket's analysis, with the brief
   and the `Recall` items as a starting point. It writes `{answer_md, citations[]}` to `/agnts/out/answer.json`, where
   a citation can also be `file:<path>:<line>`.
4. The server checks every `file:` citation against the checkout (the file exists, the line is in range) and drops
   the rest, then turns each into a link to that line on the git host at the checked-out commit
   (`…/blob/<sha>/<path>#L42`).
5. The answer replaces the "Looking at…" message, with the badge (`✨ Muse · 41s · 5 sources`).

**Why the model searches the code instead of an embedding index of it:** it follows calls across files to config,
reads the current commit (nothing to re-index after merges), and that is what coding models do best.

**Limits:** 30–90 s and about $0.05–0.30 an answer, so a daily cap per workspace (30 code answers, settable). It
runs on the Team chat model through the gateway like the rest, and needs a member who may use code (viewers get the
fast answer only, as in Code mode). AI Chat gets the same step for its Chat mode questions; Code mode is unchanged.

**AI Chat (the existing assistant).** Its snapshot gains one file, `memory.json`: the `Recall` items for the
question, with ids. Its prompt (`assistant` template, new `PromptVersion`) asks it to cite them the same way, and
`AssistantPage.vue` renders the same citation chips. The rest of the assistant (private, its own Chat model, action
cards) is unchanged.

### Showing which model did it

Every AI output (chip, draft card, answer, card summaries a model wrote) shows a badge with the model name and the
latency: `✨ Muse · 1.2s`.

- **For now the name is static: always "Muse"**, whichever provider the Team chat setting picked. One constant in the
  web app (`components/chat/AiBadge.vue`), no provider lookup.
- The latency is real (`ai.ms`), and the server still stores the real `{provider, model, ms, cost_usd}` in `ai` on
  each message and ref, so switching the badge to the actual provider later (`Claude · 2.0s`, `Codex · 1.8s`, hover
  with model and cost) is a change to that one component.
- The channel header has a small counter for the day ("✨ Muse · 41 links · 6 answers").

## Phases

Ordered by what the demo needs first. The deadline is **Nov 4**, so the phases run in this order and the bottom ones are
cut first if time runs out (cut order: 5 offline proof's IndexedDB part, then 4 Turn into ticket, then 2b code questions (the brief still answers
at a high level), then 3 model linker (explicit refs stay), then the
warm box for Claude and Codex (Muse keeps it), which falls back to cold containers and a slower badge). Hours are rough.

| # | Phase | What | Hours |
| --- | --- | --- | --- |
| 0 | Foundation | Migration, `domain/chat.go`, store, send/list/channels API (OpenAPI + generated clients), `chat_message` events, `ChatPage.vue` with channels, pending bubbles, `client_msg_id`. Go tests for idempotent send | 8 |
| 1 | Cards | Subscriber for `log_finding`, `review_ready`, `pr_opened`, `pr_merged`, `deploy`; card components; `/actions`; `OriginChat`; `MergeTicketPR` extracted + `merge_pull` action; tests (double tap, head moved, viewer refused) | 7 |
| 2 | Model setting + fast calls + memory | `StageModels.TeamChat` (domain, OpenAPI, Settings → Models row, i18n); gateway call with schema on a reusable box; warm chat box (Muse MSP sessions, CLI path for Claude/Codex); `ai` meta; `chat_jobs` worker; explicit refs (no model). `internal/memory` with `Recall` over tickets, repos, PRs, CI, findings and chat; `@agnts` answers with citation check and chips; `memory.json` + citations in AI Chat. Tests with the fake provider (`ai/aitest`) and a seeded workspace | 12 |
| 2b | Code questions | `needs_code` in the answer schema; `code_answer` job on a read-only checkout; `file:` citations checked and linked to the git host at the commit; "Looking at…" message replaced by the answer; daily cap; same step in AI Chat. Tests with the fake provider and a fixture repo | 4 |
| 3 | Model linker | Linking by the light model, candidates, confidence ≥ 0.7, chips with hover; memory gets more links to walk | 4 |
| 4 | Turn into ticket | Job, `ticket_draft` card, Create / Create and assign, cards routed back to the thread | 4 |
| 5 | Offline proof | IndexedDB outbox, `after=` gap fill on reconnect, an e2e test (send while the stream is down, reconnect, one copy each) | 3 |
| 6 | Demo | Seed `#payments` with history for the `@agnts` question, warm the box, record | 3 |
| — | Not in this plan | Mobile chat, DMs, Telegram mirroring of cards, editing/deleting messages, reactions | — |

**Demo order (≈ 90 s of the video):** Bo complains in `#payments` → chips fade in (Muse · 1.2s) → the log watcher's
card arrives → **Fix it** → `review_ready` card → **Approve** → **Merge** → "Merged ✅" → Wi-Fi off, send, Wi-Fi on,
nothing lost or doubled → `@agnts why did the CSV export break?` → click `[pr:131]`.

## Risks

- **Latency.** The second-scale chips depend on the warm box; Claude Code and Codex start a CLI process per job, so
  they will be slower than Muse's MSP sessions. If MSP can't start a fresh session on a running `muse serve` cheaply, fall back to one long session with a reset instruction per job, and say "~3 s" in the demo
  rather than "1 s".
- **Merging from chat** is the most dangerous button. It keeps every check the review merge has (head SHA, PR state),
  shows CI's state on the card and asks once more on the web; CI being red warns but does not block.
- **Memory answers are only as good as the links.** Before the model linker (phase 3), only explicit refs and full-text
  connect chat to tickets; the demo's seeded history uses ticket keys and repo names so it works either way.
- **Code answers are slow** (30–90 s). The "Looking at…" message makes the wait visible; the demo asks it once.
- **Cost of linking every message** in a busy workspace: the word minimum, explicit-first, and daily caps bound it.

## Answered (Nov 3)

1. **Deadline:** Nov 4. Phases run in the order above; the cut order says what goes if time runs short.
2. **Channels:** yes, channels (not one room).
3. **Merge and CI:** Merge does not require green CI; the card and the confirm dialog show when CI is not green.
4. **Surfaces:** admin web only.
5. **Models:** any connected model, chosen in Settings → Models → Team chat (like review, documents and meeting
   notes); Muse is the default for the demo.
6. **Badge:** every AI answer shows a model badge; for now it always says "Muse" (static), with the real latency.
7. **Memory:** built third, as one module used by `@agnts` and AI Chat; retrieval is Postgres full-text and links,
   no embeddings in v1.
8. **Code questions** ("how is auth implemented on api_gateway?"): the repo's brief answers first; when it can't, a
   read-only box with the repo checked out lets the model search the code and cite files and lines (phase 2b).
