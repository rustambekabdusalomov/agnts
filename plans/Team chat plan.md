# agnts Team chat (members + agents in one room) — Plan

Nov 3, 2026 · draft · builds on `Assistant actions plan.md` (action cards, the shared `actions` package),
`Log watcher plan.md` (findings), `AI gateway plan.md` (every model call) and the event stream (`httpapi/stream.go`)

## Overview

Workspace members talk in channels, and agnts sits in the same room as a teammate. It posts **cards** when work needs a
person (a change is ready, a PR can be merged, production is throwing errors), and a tap on a card does the real thing
through the same write path as the assistant and MCP. Muse reads the conversation as it happens: it **links** messages to
tickets, PRs and findings, **turns a message into a ticket**, and **answers `@agnts` questions with citations** you can
click.

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
- Every AI action is visibly Muse's, with its latency (`✨ Muse · 1.2s`), and every model output is checked by the
  server before anyone sees it.
- A card's button does the real thing (approve opens the PR, merge merges on GitHub), with the same checks as the
  ticket page.
- The demo's log-watcher scene ends in the chat: finding → fix → approve → merge, without leaving the room.

**Principles**

1. **The model proposes, the server decides, a person taps.** Muse never builds a card's actions, never confirms, and
   only picks from candidates the server gave it. Ids it invents are dropped.
2. **One write path.** Card buttons call `actions.Deps` (Prepare, then Execute), the same code as the assistant and MCP.
   A tap on a card is the confirmation (`Assistant actions plan.md`, principle 3).
3. **AI work is never on the send path.** A message is committed with its jobs in one transaction (outbox); workers do
   the Muse calls afterwards and push the results as events.
4. **Reuse the event stream.** Chat events are rows in `events`, so the SSE broker's Last-Event-ID replay already covers
   reconnects; a per-channel `after=` fetch closes anything older than the replay cap.

## Decisions

| Question | Decision (proposed) |
| --- | --- |
| Rooms | Workspace channels (`#general` made with the workspace, members add more). Every member sees every channel. No DMs in v1 |
| Who may do what | Everyone reads and posts. Card buttons, Turn into ticket and Assign: `role.CanEdit()` (owners, users), checked on the tap. Viewers can ask `@agnts` |
| Where agnts posts cards | In the channel the ticket came from (a ticketized message); otherwise the workspace's **agent channel** (`settings.chat.agentChannel`, default `#general`) |
| Message kinds | `text`, `agent_card`, `agent_text` (answers, "Merged ✅"), `system` (joined, renamed) |
| Card payload | JSON `{type, state, …}` built by the server from domain data. Types: `log_finding`, `review_ready`, `pr_opened`, `ticket_draft` |
| Model calls | All through the AI gateway, new purposes `chat_link`, `chat_ticket`, `chat_answer`, light tier for linking, the default tier for answers |
| Latency | A warm Muse session per workspace for chat calls (see Design). Target: chips p50 ≤ 3 s, answers p50 ≤ 6 s; the first call after idle is slower (container start) |
| Retrieval | Postgres only: refs graph + full-text search (`tsvector`, `'simple'` config, like meetings, because EN/RU/UZ mix). No vector database |
| Cost | Linking runs only when a message has ≥ 4 words and no explicit refs; per-workspace daily caps (500 links, 200 answers, settable). Funded like other background calls (free credits, then workspace credits) |
| Surfaces | Admin web (`ChatPage.vue`) first; mobile later (cut first) |
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
- **Outbox (server):** jobs are committed with the message, so a crash between "saved" and "Muse called" loses
  nothing; a job that fails retries with backoff (3 tries), then is dropped with `last_error`.
- **Resume:** SSE reconnects with Last-Event-ID (already built, replays up to 1000 events). On reconnect the client
  also calls `messages?after=<last_seen_id>` for each open channel, so a long outage is filled too. Messages are keyed
  by id, so the overlap is harmless.

### Fast Muse calls

Today each light call (log triage, for example) opens a fresh container (`runner.Open`) and runs a short agent session:
seconds to start before Muse even thinks. Chips that arrive a second later need a warm path:

- **One warm chat box per workspace:** a container with `muse serve` kept open while the workspace's chat is active
  (closed after 10 minutes idle), like the assistant's warm container per person.
- **A new MSP session per job**, so no conversation leaks between messages or channels, with **structured output**
  (the JSON Schema of the job's answer) and no tools: the box has no repo, no network beyond Muse, no tokens.
- Each result records `{provider, model, ms, cost_usd}` from MSP's `tokenUsage`; that is what the badge shows. If the
  gateway routes to another module (Muse turned off for the person), the badge shows that module, honestly.
- Fallback: when the warm box is down, the job opens a cold one, as triage does; the badge just shows the longer time.

This needs a small addition to the gateway (`ai.Call` with a reusable `Box` and a schema) and to the Muse provider
(start a session on an open `muse serve`). It is also a Meta-tooling point for the write-up: MSP sessions as cheap
structured-output workers, not only as coding sessions.

### 1. Agents as teammates: action cards (build first)

A subscriber in `internal/chat` turns ticket and log events into cards:

| Event | Card | Buttons → what runs |
| --- | --- | --- |
| `log_finding` (new, mode report or ticket) | `log_finding`: service, title, count, file:line, repo, source | **Fix it** → the log watcher's open-ticket path; **Mute**; **Open** |
| `review_ready` | `review_ready`: title, summary, files +/−, checks, cost | **Approve** → `actions.ApproveTicket` (push + open PR); **Request changes** (asks for text); **View diff** |
| `pr_opened` | `pr_opened`: number, URL, checks | **Merge** → new action `merge_pull` (below); **View** |
| `pr_merged`, `deploy` | `agent_text`: "Merged ✅ #142 (merge) by Ann", "Deployed ✅" / the failure | — |

- **Merge for agnts's own PRs is new.** Today only reviewed outside PRs are merged (`orchestrator/pullreview.go:650-690`).
  That block moves into one function, `MergeTicketPR`, used by both: it reads the PR, refuses when it is closed or the
  head moved since approval, merges with the workspace's method (`settings.PullReviews.MergeMethod`), and records
  `pr_merged`. `actions` gets `merge_pull` (destructive: the web asks once more, repeating the summary).
- A tap: `POST /chat/messages/{id}/actions` checks the action is on the card and the card is `open`, checks the role,
  runs Prepare + Execute with `domain.OriginChat` ("by Ann via chat" in the ticket history), sets `card.state`.
  A second tap (another member, a double click) gets "Already approved by Ann" instead of a second run.
- Cards follow the ticket: when the ticket moves on elsewhere (approved on the ticket page), the card's state updates.

### 2. Live auto-linking by Muse

On each new `text` message, the `link` job:

1. **Explicit refs first, no model:** ticket keys (`PAY-214`), `#142`, PR and ticket URLs, repo names. Stored with
   `source: explicit`, confidence 1.
2. **Muse only for the rest**, when the message has ≥ 4 words: the message, its thread parent, and candidates: open
   tickets (≤ 50, newest first), repos, the last 20 PRs, open findings (≤ 10). Asked for
   `[{ref_type, ref_id, confidence, reason}]` under a JSON Schema.
3. The server keeps refs that are **in the candidate list** with confidence ≥ 0.7, at most 3, and sends `chat_ref`.
   Chips fade in; hover shows `✨ Linked by Muse · 1.2s — <reason>`. A member can remove a wrong chip (kept as a
   negative example in `chat_refs` with `source: removed`, for tuning later).

Message text is untrusted, but the output can only select from server-made candidates, so a prompt injection can at
worst attach a wrong chip.

### 3. Turn into ticket

`⋯ → Turn into ticket` on any message (editors). The `ticketize` job sends Muse the message, its thread (≤ 10
replies), its refs and the repos, and asks for `{title, description, acceptance_criteria[], repo, kind}`. The server
checks the repo is one of the workspace's, then posts a `ticket_draft` card in the thread:

- **Create task** → `actions.CreateTask` (a local task, as today), the card becomes a link to the ticket.
- **Create and assign to agent** → `CreateTask`, then `StartRun`. From then on the ticket's cards (`review_ready`,
  `pr_opened`) come back to this thread: chat → ticket → coding agent → PR → merge in one place.
- **Edit** opens the fields inline before creating.

### 4. `@agnts` questions with citations

A message that mentions `@agnts` gets an `answer` job (after its `link` job, so its refs exist):

1. **Entities:** the question's refs (explicit + Muse).
2. **Graph walk:** messages that share those refs (`chat_refs` join, last 90 days, ≤ 30), and the refs' own facts
   (ticket state and summary, PR state, finding) through the read functions the assistant snapshot already uses
   (`mcpserver.Snapshotter`).
3. **Full-text:** `websearch_to_tsquery('simple', question)` over the workspace's messages, ranked, ≤ 20.
4. The context goes to Muse with ids: `[msg:812]`, `[pr:142]`, `[ticket:LOG-9]`, `[finding:12]`. The prompt says to
   answer only from it and cite every claim. Schema: `{answer_md, citations[], insufficient}`.
5. The server removes citations that were not in the context. If none are left and `insufficient` is false, the reply
   becomes "I can't find that in this workspace's chat, tickets or PRs." The answer posts as `agent_text` with the
   badge and "3 sources"; each citation renders as a chip that jumps to the message or opens the ticket or PR.

This differs from the existing Assistant (private, one person, snapshot files): it is shared in the channel and reads
the chat itself. It does not take actions; asked to, it says which card or page does it.

### Making Muse visible

Every AI output (chip, draft card, answer, card summaries Muse wrote) carries `ai` and shows a `✨ Muse · 1.2s` badge;
hover adds the model and cost (`Muse Spark · 1.2s · $0.0004`). The channel header has a small counter for the day
("✨ 41 links · 6 answers · $0.09") so judges see it without looking for it.

## Phases

Ordered by what the demo needs first. Hours are rough, for ~40 hours in total.

| # | Phase | What | Hours |
| --- | --- | --- | --- |
| 0 | Foundation | Migration, `domain/chat.go`, store, send/list/channels API (OpenAPI + generated clients), `chat_message` events, `ChatPage.vue` with channels, pending bubbles, `client_msg_id`. Go tests for idempotent send | 8 |
| 1 | Cards | Subscriber for `log_finding`, `review_ready`, `pr_opened`, `pr_merged`, `deploy`; card components; `/actions`; `OriginChat`; `MergeTicketPR` extracted + `merge_pull` action; tests (double tap, head moved, viewer refused) | 7 |
| 2 | Fast Muse + linker | Warm chat box, MSP session per job with schema, `ai` meta; `chat_jobs` worker; explicit refs; Muse linker; chips with hover | 8 |
| 3 | Turn into ticket | Job, `ticket_draft` card, Create / Create and assign, cards routed back to the thread | 4 |
| 4 | `@agnts` | Retrieval (refs walk + FTS), prompt template `chatanswer`, citation check, citation chips, thinking indicator | 7 |
| 5 | Offline proof | IndexedDB outbox, `after=` gap fill on reconnect, an e2e test (send while the stream is down, reconnect, one copy each) | 3 |
| 6 | Demo | Seed `#payments` with history for the `@agnts` question, warm the box, record | 3 |
| — | Later (cut first) | Mobile chat, DMs, Telegram mirroring of cards, editing/deleting messages, reactions | — |

**Demo order (≈ 90 s of the video):** Bo complains in `#payments` → chips fade in (Muse · 1.2s) → the log watcher's
card arrives → **Fix it** → `review_ready` card → **Approve** → **Merge** → "Merged ✅" → Wi-Fi off, send, Wi-Fi on,
nothing lost or doubled → `@agnts why did the CSV export break?` → click `[pr:131]`.

## Risks

- **Latency.** The second-scale chips depend on the warm box. If MSP can't start a fresh session on a running
  `muse serve` cheaply, fall back to one long session with a reset instruction per job, and say "~3 s" in the demo
  rather than "1 s".
- **Merging from chat** is the most dangerous button. It keeps every check the review merge has (head SHA, PR state)
  and asks once more on the web.
- **Cost of linking every message** in a busy workspace: the word minimum, explicit-first, and daily caps bound it.

## Open questions

1. **Time and deadline:** the Muse hackathon deadline in my notes was Oct 30. Is this for a later round (pitch day),
   and is ~40 hours the real budget?
2. **Channels or one room:** is one `#team` room per workspace enough for the demo (saves ~2 hours), or are channels
   needed?
3. **Merge from chat:** should Merge be offered only when CI is green, or always with the checks shown on the card?
4. **Mobile:** is the admin web enough for the video, or does the chat need to be on the phone too?
