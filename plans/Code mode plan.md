# agnts Chat: Code mode — Plan

Oct 28, 2026 · implemented, all five phases

## As built

Where the code differs from the plan below, the code wins:

- **Endpoints:** Code mode has its own endpoints, so the Chat ones stay open to viewers and the Code ones are not (viewers get 403 from the middleware, and `StartCode` checks the role too): `POST /assistant/code` starts a conversation, `POST /assistant/conversations/{id}/code` sends a message. Also `GET …/timeline`, `PUT …/repos`, `PUT …/ticket`, `POST …/send-now`, `POST /assistant/approvals/{id}`, `GET /tickets/{key}/chat`, and `?mode=` on the list.
- **Origin:** every ticket action from the chat has origin `assistant`, so a ticket's history says "via assistant".
- **Queued messages:** these are `assistant_messages` rows with `routed = 'queued'`. There is no separate table. `FlushCodeQueues` runs on every poll of the loop. It sends a ticket's waiting messages as one when its stage ends, and marks them `sent`, or `failed` with the reason in `error`.
- **One chat per ticket, per person:** `code_conversation_tickets` has `user_id`, and the unique index is on (ticket, person). Two people can each follow a ticket in their own chat; attaching it elsewhere moves only your own.
- **Running limit:** 3 of a person's *current* Code tickets in new, analyzing, coding, testing or pushing.
- **The timeline** keeps the newest 600 events of the conversation's tickets (`domain.CodeTimelineTypes`). It hides budget, rate-limit and ticket-created events, and the `feedback`/`answered` events that repeat the person's own message. Events from before a ticket was attached are left out.
- **Phase 4:** the assistant's answer file has an optional `code: {request, repositories}`. It becomes the message's `handoff`, with repository names resolved and nothing for viewers. Prompt version `2026-10-28.1`. There are two new eval cases (`"code": true` in `assistant_cases.json`, checked by `CheckCode`). Clients open Code mode with `?text=…&repos=1,2`. The ticket page links "Discussed in chat" or "Continue in chat" (`?ticket=KEY`).
- **Phase 5 (agnts-muse):** `Request.Steer` sends the person's messages in with `turn/steer`. `Request.Ask` and `guard.Verdict.Ask` handle calls left to a person (`guard.AskBeforeInstalls`). A call left to a person is vetoed at once and asked about. When allowed, it goes on the run's allow-list and Muse is steered to run it (ADR 0005). In agnts, `codeLiveFor` makes a Muse analyze or coding run live when someone follows the ticket in a chat. Questions are asked only while coding. Live runs and questions are in memory for the length of the run, and `code_approval` events tell the chat. Claude Code and Codex runs are never live; messages to them are queued.
- **Mobile localization:** the committed `app_localizations*.dart` files were older than the ARB files: 65 `{agent}` placeholders were never regenerated, and about 45 call sites rely on the old signatures. Only the new `codechat*` and `navAssistantCode` entries were added to them. A full `flutter gen-l10n` still needs those call sites updated first.

## Overview

The chat (the assistant in the mobile app and on the admin web `AssistantPage.vue`) gets two modes, chosen in the composer:

- **Chat**: what exists today. Answers about the workspace from a read-only snapshot, and proposes actions as cards to confirm.
- **Code**: the person picks repositories (one, several or a group, like on a new ticket), writes what they want, and agnts changes the code. The work runs in the chat: progress, the agent's text, questions, the diff, checks, and **Approve** to push and open the pull request. Follow-up messages ask for changes on the same branch. Code mode can also pick up an existing ticket ("continue PAY-214") and work on it from the chat.

Many people now work in a chat. Today in agnts they leave it to create a task, then follow the ticket screen. Code mode keeps them in the chat.

**Principles**

1. **A Code conversation drives a ticket. It is not a second pipeline.** Every change runs as an ordinary ticket: same container, branch, guard, checks, self-review, billing (account, credits or Muse), approve → push → PR, history and Spend. The chat is another front end for the ticket, and the ticket screen shows the same work.
2. **Routing is code, not a model.** What a message does (start, answer, request changes, continue, retry) depends on the ticket's state, decided by a `switch`. The model never decides to push, approve or reject. Those are buttons.
3. **Chat mode stays read-only.** The snapshot run and its permissions don't change. Code mode runs in ticket containers with the ticket's permissions, never in the assistant's container.
4. **One timeline, from stored events.** Progress in the chat is the ticket's own events (`claude_text`, `claude_tool`, `check`, `state_changed`, `pr_opened` …), merged with the person's messages. Nothing is copied into the chat tables.

## Decisions

| Question | Decision (proposed) |
| --- | --- |
| What backs a Code conversation | Tickets. A conversation has one *current* ticket. When it is done or rejected, the next message starts a new ticket in the same repositories, linked as a follow-up |
| Who can use Code mode | Owners and editors (`role.CanEdit()`). Viewers see only Chat |
| Repository choice | `domain.RepoChoice`: one repository, several, or a group. Picked before the first message; changeable while the ticket hasn't started coding (`SetRepos`) |
| Ticket kind | `auto` by default (agnts picks code / test / plan / analysis / bug). The composer can force one |
| Start | `Start: "code"`: no ask-first, since the person is right there. Analysis can still raise questions; they show in the chat |
| Checks | On, as for any ticket. A "Quick" toggle uses the existing `SetSkipChecks` |
| Working on an existing ticket | Allowed: "Attach ticket" in the composer, or a ticket key in the first message (exact match on the existing key regexp). The conversation becomes that ticket's chat |
| One ticket, several chats | A ticket belongs to at most one Code conversation at a time. Attaching it elsewhere moves it (the old chat shows "Moved to another conversation") |
| Mid-run messages | Queued and sent as the next feedback when the run stops. Later: Muse `turn/steer` delivers them into the running turn (phase 5) |
| Audit origin | The client's own (`web`, `mobile`), since a person's message acts directly. Tickets made from the chat keep `SourceLocal`; the link to the chat is in the new table |
| Billing | The ticket's. Unlike Chat mode, Code mode works on credits and Muse |
| Limits | Message ≤ 4,000 characters; at most 3 running Code tickets per person (on top of the workspace's slots) |

## How it works

1. The person switches the composer to **Code**, picks `payments-api`, and writes: "refunds should round half up, add a test".
2. `POST /assistant/conversations` with `{mode: "code", repos: {repo_id: 12}, text}`. The server calls `CreateTask` (title from the first line, description from the message, `Start: "code"`, kind `auto`) and stores the link. It returns the conversation with its `ticket`.
3. The chat subscribes to the ticket's events on the existing stream. The timeline shows "Analyzing", the agent's text as it writes, compact tool lines ("Edited `refund.go`", "Ran `go test ./...`"), and checks.
4. Analysis asks a question → a **question card** in the chat. The person types an answer. With one open question it is that answer; with several the card shows a field per question (no model guesses which text answers which question).
5. The ticket reaches `waiting_for_review` → a **result card**: the summary, files changed (+/−), checks, self-review notes, a **View diff** sheet, and **Approve** (push + PR) / **Reject**. Approve and reject call the existing ticket endpoints.
6. The person writes "also log the old value" → `RequestChanges(feedback)`: coding again, resuming the same Claude session.
7. After Approve the timeline shows the push and the PR link. The next message starts a new ticket in the same repositories, linked to the last one.

### Routing a message (`orchestrator/codechat.go`)

| Current ticket state | A new message does |
| --- | --- |
| none, `done`, or the ticket was moved | `CreateTask` with the conversation's repositories (linked as a follow-up of the last one) |
| `new`, `analyzing`, `coding`, `testing` | Queued as a note; sent with `RequestChanges` / `Continue` when the run stops. The chat shows "Will send when this run ends" with **Stop and send now** (`Stop` then send) |
| `waiting_for_answers` | `Answer` (see step 4) |
| `waiting_for_review` | `RequestChanges(feedback, files)` |
| `rejected` | `Continue(note)` when `CanContinue`, else a new ticket |
| `failed`, `rate_limited` | `RetryWithNote(note)` |
| `pushing` | Refused with "Pushing now, write again in a moment" (409) |

Attachments (screenshots, files) go through the existing upload flow and are passed as `files` to these calls.

## Phases

| # | Phase | What it adds |
| --- | --- | --- |
| 1 | Server: modes and routing | Migration, conversation mode and repositories, ticket link, router, timeline API, events |
| 2 | Admin web | Mode switch, repository and ticket pickers, timeline, question and result cards, diff sheet |
| 3 | Mobile | The same in `features/assistant/` |
| 4 | Chat ↔ Code | Chat mode offers "Do this in Code" with the repositories filled in; Code conversations show in the ticket screen |
| 5 | Live (Muse) | Mid-run messages through `turn/steer`; guard "ask" decisions as approval cards in the chat |

Order: 1 → 2 → 3, then 4 and 5 in either order. After phase 2 Code mode is usable on the web. Ship 1 and 2 together.

## Phase 1: Server

### Data

Migration `00067_code_mode.sql`:

- `assistant_conversations`: add `mode text NOT NULL DEFAULT 'chat' CHECK (mode IN ('chat','code'))`, `repo_choice jsonb` (`{"repo_id":12}` | `{"repo_ids":[…]}` | `{"group_id":3}`), `kind text` (null for auto), `quick boolean NOT NULL DEFAULT false`.
- New `code_conversation_tickets`: `conversation_id bigint REFERENCES assistant_conversations ON DELETE CASCADE`, `ticket_id bigint REFERENCES tickets`, `attached_at`, `detached_at` (set when the ticket moves to another chat). Unique partial index on `ticket_id WHERE detached_at IS NULL` (one live chat per ticket).
- `assistant_messages`: add `ticket_id bigint` (the ticket the message went to), `routed text` (`created` | `answered` | `changes` | `continued` | `retried` | `queued`), `files jsonb` (attachment ids). Code-mode person messages are stored here; the agent's side comes from ticket events.
- New `code_queued_notes`: `conversation_id`, `ticket_id`, `message_id`, `created_at`, `sent_at`. Sent in order when the run stops.

The 30-day prune skips Code conversations whose ticket isn't terminal. Deleting a Code conversation never deletes its tickets.

### Domain

- `domain.ChatMode` (`chat` | `code`) on `AssistantConversation`, plus `Repos RepoChoice`, `Kind`, `Quick`, `Ticket *TicketBrief` (the current ticket: key, title, state, repositories).
- `AssistantMessage` gains `TicketKey`, `Routed`, `Files`.
- `domain.TimelineItem{At, Kind, Message *AssistantMessage, Event *Event}`: one list for the screen.
- Update the `domain/assistant.go` header comment.

### Orchestrator

`internal/orchestrator/codechat.go`:

- `StartCode(ctx, in CodeStart) (AssistantConversation, error)`: checks `CanEdit`, the repositories (`resolveRepos`), the per-person limit; creates the conversation, then the ticket, or attaches the named ticket.
- `SendCode(ctx, conversationID, text string, files []int64) (AssistantMessage, error)`: the routing table above. Uses the per-person lock the assistant already has (`personLock`), so two quick messages don't both create a ticket.
- `AttachTicket(ctx, conversationID, key)`, `SetCodeRepos(ctx, conversationID, choice)` (calls `SetRepos` on the current ticket when its state allows it).
- `CodeTimeline(ctx, conversationID, before time.Time, limit int)`: person messages + the events of every ticket the conversation had, filtered to the types the chat shows, oldest first, paged.
- `flushQueued(ctx, ticket)`: called from the place that publishes `state_changed`, when a ticket of a Code conversation stops (`waiting_for_review`, `failed`, `rejected`, `waiting_for_answers`). Sends the queued notes as one feedback, joined in order.
- `Ask` refuses Code conversations and `SendCode` refuses Chat ones (400). A conversation's mode never changes.

Events shown in the timeline: `state_changed`, `claude_text`, `claude_tool` (collapsed per run), `check`, `review_done`, `review_ready`, `pushed`, `pr_opened`, `pr_merged`, `error`, `rate_limit`, `queued`, `guard`, `checkpoint`. A new live event `code_message` (`{conversation_id, message_id, routed, ticket_key}`) goes to the person's streams, like `assistant_action`.

### API (`shared/openapi/openapi.yaml`)

| Method | Path | Does |
| --- | --- | --- |
| POST | `/assistant/conversations` | Body gains `mode`, `repos`, `kind`, `quick`, `ticket_key`, `files`. In Code mode returns the conversation with its `ticket` (201) |
| POST | `/assistant/conversations/{id}/messages` | Same path; in a Code conversation it routes to the ticket and returns the message with `routed` |
| GET | `/assistant/conversations/{id}/timeline?before=&limit=` | Code conversations: the merged timeline |
| PUT | `/assistant/conversations/{id}/repos` | Change repositories (409 once coding started) |
| PUT | `/assistant/conversations/{id}/ticket` | Attach a ticket `{key}` |
| POST | `/assistant/conversations/{id}/send-now` | Stop the run and send the queued notes |
| GET | `/assistant/conversations?mode=code` | Filter the list |

Approve, reject, the diff and the files use the existing ticket endpoints. No new write path for them.

Regenerate `gen`, the Dart client `apps/mobile/packages/agnts_api` and the admin types.

### Tests

- Routing: one table test per state (including `pushing` → 409 and `done` → new linked ticket).
- Two messages at once create one ticket.
- A viewer gets 403 on `StartCode` and `SendCode`.
- Someone else's Code conversation is 404, even in the same workspace.
- Attaching a ticket that lives in another chat moves it; the old chat's timeline says so.
- Queued notes are sent once, in order, when the run stops; `send-now` stops and sends.
- The timeline merges and pages correctly across two tickets.
- Chat-mode `Ask` on a Code conversation is 400, and the assistant's permissions test still passes unchanged.
- The prune keeps Code conversations with a live ticket.

## Phase 2: Admin web (`apps/admin/src/pages/AssistantPage.vue`)

- **Composer:** a `Chat | Code` segmented switch (Code hidden for viewers). In Code: a repository chip that opens the existing repository/group picker from the new-task dialog, a kind chip (Auto by default), a Quick toggle, attachments, and "Attach ticket" (search by key or title).
- **Timeline** (`components/codechat/`):
  - `CodeMessage.vue`: the person's message, with a small "→ requested changes on PAY-214" line from `routed`.
  - `CodeProgress.vue`: the run's agent text streamed, tool calls collapsed into one expandable line per run ("12 steps: edited 3 files, ran tests").
  - `CodeQuestions.vue`: the questions card (one field each; a single question takes the composer's text).
  - `CodeResult.vue`: summary, files +/−, checks, review notes, **View diff** (the ticket's diff component in a side sheet), **Approve** and **Reject** (the shared `askConfirm` dialog), and **Open ticket**.
  - `CodeQueued.vue`: "Will send when this run ends · Stop and send now".
- The header shows the ticket chip (key, state) and the repositories.
- `applyLive` handles the ticket's events for the current tickets and `code_message`.
- The conversation list shows a code icon and the ticket state for Code conversations.
- Texts in `shared/i18n/*/massistant.json` (`mode*`, `code*`), in English, Russian and Uzbek.
- Tests next to `AssistantPage.test.ts`: mode switch hidden for viewers, routing labels, result card buttons.

## Phase 3: Mobile (`apps/mobile/lib/features/assistant/`)

- The same switch and chips in `assistant_screen.dart`; the repository picker reuses the new-task screen's picker.
- `code_timeline.dart` with the same cards. The diff opens the ticket's existing diff screen; Approve and Reject open the confirm dialog.
- `assistant_data.dart`: `startCode`, `sendCode`, `timeline` providers; handle the ticket's events and `code_message` on `core/live.dart`.
- After Approve, invalidate the ticket, inbox and tickets providers, as after an assistant action.
- Texts in `app_en.arb`, `app_ru.arb`, `app_uz.arb`.

## Phase 4: Chat ↔ Code

- In Chat mode, a request to change code ("fix the rounding in refunds") gets a **"Do this in Code"** card instead of a `create_task` card: the repositories the answer picked and the text, prefilled. Tapping it opens a new Code conversation with them; the person still presses Send. Prompt rule and an eval case in `assistant_cases.json`.
- The ticket screen shows "Discussed in chat" with a link when the ticket has a Code conversation (owner of that chat only).
- A ticket screen action "Continue in chat" attaches the ticket to a new Code conversation.

## Phase 5: Live (Muse)

Needs the MSP session from the Muse plan (`code.Session` with steer and interrupt).

- **Steer:** a message sent while a Muse run is coding is delivered with `turn/steer` instead of being queued. The chat marks it "Delivered to the running agent". Claude Code and Codex runs keep the queue.
- **Approvals in the chat:** a guard rule with the `ask` verdict (`approval/requested`) shows an approval card ("Allow `npm install left-pad`?") to the person who owns the chat, with a 5-minute timeout that denies. The decision goes back with `approval/decide`.
- **Live cost:** the result card and the header show the run's cost from `session/tokenUsage` while it runs.

## Risks

| Risk | Mitigation |
| --- | --- |
| Two front ends for one ticket get out of step | The chat stores nothing about the run; it reads ticket events. The ticket stays the source of truth |
| A message is sent to the wrong action | Routing is a `switch` on state, shown under each message (`routed`). Approve, reject and push are buttons only |
| The person expects chat speed; a ticket run takes minutes | The agent's text is streamed. Quick mode skips checks. Queued notes show clearly |
| Prompt injection from ticket or CI text pushes code | Nothing reaches the git host without the Approve button, as today. Guard rules still apply in the container |
| Many parallel Code chats use up the slots | Per-person limit of 3, plus the workspace's slots and queue (`WaitSlots` shows in the chat) |
| Chat mode loses its read-only guarantee | Code mode never uses the assistant's container or `AssistantPermissions()`; a test keeps them read-only |

## Open questions

1. Should a Code conversation keep one ticket for its whole life (follow-ups go into the same branch even after it is pushed), instead of a new linked ticket after `done`? This plan starts a new one, since a pushed branch already has its PR.
2. Should the timeline also show the agent's plan from analysis as its own card, or is the streamed text enough?
3. Is 3 running Code tickets per person right, or should it follow the plan's slots only?
4. Does Code mode come to the CLI (`agnts chat --code`) too, or only the web and mobile?
5. Which other calls should ask a person? Only adding a dependency does today (`guard.AskBeforeInstalls`); migrations or deleting files are candidates.
