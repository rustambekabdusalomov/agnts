# agnts Cloud: Workspaces — Plan

Oct 8, 2026 · draft

## Overview

Today agnts is **single-tenant**: one install is one team. Everyone who logs in sees the same repositories, tickets, settings and integrations, and every run uses the one Claude connection. None of the 24 tables says who a row belongs to.

This plan turns agnts into a multi-tenant cloud product. People **register**, **own workspaces**, and **invite members** into them. A workspace is one project: its own repositories, tickets, integrations, Claude connection, slots and credits. A solo developer is a workspace with one member; a team is a workspace with several. The same build still runs self-hosted, where an install simply has one or a few workspaces.

**Goals**

- Register, create workspaces, invite members, switch between workspaces.
- Two role levels: system roles (Admin, User) and workspace roles (Owner, User).
- Per-workspace members, integrations, settings, rules, and Claude connection, with the owner choosing whether the workspace runs on **one shared subscription** or on **each member's own**.
- A server-wide queue: when the server has no memory left for another run, the ticket waits, and users see that it is waiting for the server, its position and an estimate.
- Strict isolation between workspaces: in the database, on disk, and between run containers.
- Billing per workspace: base plan, extra parallel slots, prepaid credits.

**Out of scope for v1:** organizations above workspaces, SSO/SAML, custom roles, moving repositories between workspaces, multiple run servers (designed for, built later), per-workspace runner images beyond today's per-repository override.

**Principles**

1. **The workspace is today's install.** Everything that is global today (settings, integrations, rules, the queue limit) becomes per workspace. The orchestrator's flow does not change; it learns which workspace a ticket belongs to.
2. **Isolation is enforced twice.** Every query filters by workspace in code, and Postgres row-level security refuses rows of other workspaces even if a query forgets.
3. **Containers stay one per run**, created and destroyed per stage. Workspaces share the runner image and toolchains (read-only), never working folders, caches or networks.
4. **Capacity is the platform's problem, slots are the workspace's.** A workspace limits its own parallel runs; the server limits total memory. The UI always says which one a ticket waits for.

## Roles

### System roles

| Role | Who | Can |
| --- | --- | --- |
| **Admin** | The platform operator (you) | Everything a User can, plus the operator console: all servers, the global queue, all workspaces (metadata only, not their code), suspend or delete a workspace, grant credits, see billing. Admin does **not** see a workspace's tickets unless they are a member of it. |
| **User** | Everyone who registers | Create workspaces (they become Owner), accept invites, manage their profile, 2FA, devices, personal Claude connection, notifications. |

The first account on a fresh install becomes Admin (as the first user is created today). Admin is a flag on `users`, granted only by another Admin or the CLI.

### Workspace roles

| Can | Owner | User |
| --- | --- | --- |
| See tickets, runs, diffs, logs | ✅ | ✅ |
| Create tickets, answer questions, request changes, approve, reject, retry | ✅ | ✅ |
| Edit repositories, rules, workspace settings | ✅ | — |
| Connect integrations (GitHub, GitLab, Jira, Plane, Telegram) | ✅ | — |
| Choose the Claude mode and connect the workspace subscription | ✅ | — |
| Invite and remove members | ✅ | — |
| Billing: plan, slots, credits | ✅ | — |
| Rename, transfer ownership, delete the workspace | ✅ | — |
| Leave the workspace | (transfer first) | ✅ |

A workspace has exactly **one Owner**. Ownership can be transferred to another member. Every action already records its origin; it now also records **which user** did it, so a team sees who approved, who asked for changes and who is reviewing which ticket.

If an Admin role inside a workspace is needed later (settings without billing), it slots in between the two without changing the model.

## Workspaces

### What belongs where

| Per user (global) | Per workspace |
| --- | --- |
| Login, password, 2FA, sessions, devices | Members and invites |
| Language, Telegram link, notification choices | Repositories, tickets, runs, results, events |
| **Personal Claude connection** (used in per-member mode) | Rules, lessons, follow-ups, relations |
| System role | Settings (models, review, preview, auto-resume …) |
| | Integrations: GitHub/GitLab, Jira/Plane, webhooks |
| | Claude mode and the **workspace Claude connection** |
| | Plan, slots, credits, usage |
| | Repo checkouts on disk, package caches |

### Lifecycle

- **Register** (email + password, email verification, 2FA optional at first, required for Owners of paid workspaces) → a personal workspace is created and opened.
- **Create** more workspaces from the switcher; each starts on the base plan's trial.
- **Invite** by email or by a link that expires; the invitee registers or logs in and joins as User.
- **Switch** with the workspace picker in the top bar; the last used workspace opens on login.
- **Delete** (Owner): stops runs, deletes repo checkouts, caches, screenshots and sessions, and the rows; the workspace is kept 7 days in a deleted state for undo, then purged.

### Ticket keys

Keys stay human (`AGNT-12`) and are **unique per workspace**, not globally. `tickets.key` is used as a foreign key today (`ticket_relations`), so the migration moves those references to `(workspace_id, key)` or to ticket ids.

## Claude in a workspace

The Owner picks the mode in **Workspace settings → Claude**:

| Mode | Which Claude account a run uses |
| --- | --- |
| **Shared** | The workspace's connection, set by the Owner. Every run in the workspace uses it. |
| **Per member** | The connection of the **ticket's member**: whoever created it, or whoever it was assigned to later. Each member connects their own Claude account in their profile. |

Plus one switch for both modes:

| Fallback | What happens when the chosen account is at its limit or missing |
| --- | --- |
| Off | The ticket pauses (`rate_limited`) and resumes when the limit resets (today's auto-resume). |
| **Use workspace credits** | The run continues on agnts's API key and deducts credits. |

**Rules for choosing the account of a run**

1. Shared mode → the workspace connection.
2. Per-member mode → the ticket's member. Tickets that arrive without a person (Jira or Plane webhook, follow-ups, incidents) get the workspace's **default member**, which is the Owner unless changed; a member can take a ticket over by assigning it to themselves.
3. If that account is missing, disconnected or paused at its limit → fallback (credits) if on, otherwise the ticket waits with reason `claude`.
4. A resumed session keeps the account it started on where possible, since a Claude session cannot move between accounts; if it must switch (fallback), the next stage starts a fresh session with the summary so far.

**Usage limits per account.** Usage readings (`usage_snapshots`) and the pause rule are global today. They become **per Claude account**, so one member's limit pauses only the tickets running on that member's account.

**Connection type.** Each connection is either a Claude subscription token (as today, `CLAUDE_CODE_OAUTH_TOKEN`) or an Anthropic **API key**. Credits always use agnts's API key.

## Server queue and capacity

### Why a ticket waits

| `wait_reason` | Shown as | Fixed by |
| --- | --- | --- |
| `blocked` | "Waiting for AGNT-2 to merge", held, waiting for answers (exists today) | The team |
| `slots` | "1 of 1 slots in use; starts when AGNT-7 finishes" + **Add a slot** | The workspace |
| `server` | "In server queue: #3, about 10 min" | The platform (add capacity) |
| `claude` | "Claude limit reached; resumes at 14:00" or "turn on credits" (today's `rate_limited`) | The workspace |

### Admission: when a run may start

All of these, in order:

1. The ticket is ready (not held, not blocked).
2. The workspace has a free slot: its running runs < its slots.
3. Its Claude account is usable (or fallback to credits is on and the balance covers the per-run cap).
4. The server has room:
   - **reserved memory**: the sum of the memory limits of running containers + this run's limit ≤ `AGNTS_RUN_MEMORY_BUDGET_MB` (default: total RAM − 2.5 GB);
   - **available memory** on the host ≥ this run's limit (a second guard against anything outside agnts);
   - **free disk** ≥ `AGNTS_MIN_FREE_DISK_GB` (default 10).

Admission counts **limits, not current usage**, because usage rises during a build. Checking and reserving happen under one lock (one server); with several servers, a `run_nodes` table holds each server's reserved memory and the reservation is taken in a transaction.

### Who goes next

1. **Fair between workspaces:** the workspace using the smallest share of its slots goes first (round-robin among equals), then that workspace's next ticket.
2. **Inside a workspace:** today's order (priority, then tickets that unblock others, then oldest).
3. **Main stages before side runs:** analysis and coding, then review and preview, then learn and rule reviews (these only when there is room to spare).
4. **No starvation:** a run that does not fit (an 8 GB repository) and has waited more than 10 minutes stops smaller runs from being admitted until it fits.

### What users see

- **Ticket page:** a banner with the reason, position and estimate ("In server queue: #3. The server is at capacity (4 runs, 12 of 13 GB). Estimated start in ~10 min."). The estimate comes from the average remaining time of the running runs.
- **Task list and board:** a badge per ticket: `Queued · server`, `Queued · slots 1/1`, `Paused · Claude limit`.
- **Workspace header:** `Running 1/1 · 2 queued (1 waiting for server)`.
- **Privacy:** other workspaces appear only as a count ("2 tasks from other workspaces ahead").
- **Notifications:** "AGNT-7 started" when it leaves the queue (Telegram, mobile push); optionally "still queued after 30 min".

### Operator console (Admin)

Per server: memory reserved and used, CPU, disk, running runs. Global: queue length, longest and average wait, waits over the day, top workspaces by usage. An alert fires when the server-queue wait passes N minutes or the server is full more than X% of working hours: the signal to add a server.

### Edge cases

- A run killed for running out of memory fails with a clear reason ("ran out of memory at 4 GB") and offers a retry with more memory for that repository.
- On restart, reservations are rebuilt from the runs still marked running (`RecoverInterrupted` already resets them).
- Cancelling or rejecting a queued ticket just removes it; nothing was reserved.
- Events are written only when `wait_reason` changes, not on every scheduler tick.

## Isolation

| Layer | Today | Workspaces |
| --- | --- | --- |
| Database | No owner column | `workspace_id` on every workspace table + row-level security; each request sets `app.workspace_id` on its connection |
| Repo checkouts | `repos/<repo name>/<branch>` (two workspaces with a repo named `backend` would share a folder) | `repos/<workspace id>/<repo id>/…`, one history per repo with worktrees per branch; deleted with the repo, branch folders deleted after merge or reject |
| Package caches | `agnts-cache-repo-<id>` | Same (repo ids are unique), plus deletion with the repo and after 14 idle days |
| Run network | Every run on `agnts-runs`, can reach other runs | One network per run (or inter-container traffic off on `agnts-runs`), egress only through the proxy |
| Kernel | Plain Docker | gVisor (`runsc`) as the run runtime; ~10–20% slower builds |
| Secrets | Sealed per install | Sealed per workspace (integration tokens, Claude tokens, preview and build env) |

## Billing and pricing

Billing is **per workspace**: the Owner pays; members do not pay for being members of someone else's workspace.

| Item | Price | Cost to agnts | Margin |
| --- | --- | --- | --- |
| Workspace (1 slot, up to 5 members) | $25 (≈300k so'm)/month | ~$10 hardware | ~60% |
| Extra member above 5 | $5 (≈60k so'm)/month | ~$0 | ~100% |
| Extra parallel slot (max 5 per workspace) | $15 (≈190k so'm)/month | ~$9–10 | ~35–40% |
| Credits | 1.4× API cost, prepaid | API cost + ~3% fees | ~26% |

Credits: 1 credit = $0.01 of API cost × markup. Each run has a cap (default $25); a run stops cleanly when the balance runs out. No post-paid usage.

Example, 100 workspaces (1.5 slots average, 30 extra members, 30 workspaces buying 40 tickets of credits a month at $7.80 API cost each): platform revenue $3,400 against ~$1,775 cost (~48%), credits $13,100 against ~$9,750 (~26%), about **$4,975/month profit** before salaries and tax. Hardware assumes Eskiz VPS 8 (64 GB, 3.04M so'm) at ~14 concurrent runs.

## Changes by layer

### 1. Data (migration `00023_workspaces.sql`)

New tables:

- `workspaces` (id, slug, name, owner_id, plan, slots, claude_mode `shared|member`, claude_fallback bool, default_member_id, credits_balance, created_at, deleted_at)
- `memberships` (workspace_id, user_id, role `owner|user`, created_at; unique pair)
- `invites` (id, workspace_id, email, token_hash, invited_by, expires_at, accepted_at)
- `claude_connections` (id, owner_kind `workspace|user`, owner_id, kind `subscription|api_key`, token_enc, account label, checked_at)
- `credit_ledger` (id, workspace_id, amount, reason `purchase|run|refund|grant`, run_id, created_at)
- `run_nodes` (later, with several servers)

Changed:

- `users`: add `email`, `email_verified_at`, `is_admin`.
- `workspace_id NOT NULL` on: `tickets`, `repositories`, `runs`, `results`, `questions`, `events`, `claude_calls`, `attachments`, `rules`, `lessons`, `ticket_relations`, `ticket_suggestions`, `translations`, `integrations`, `settings`, `webhook_deliveries`, `pending_actions`, `telegram_messages`.
- `usage_snapshots`: keyed by Claude connection instead of global.
- `integrations`: primary key `(workspace_id, provider)`; `settings`: `(workspace_id, key)`.
- `tickets`: unique `(workspace_id, key)`; add `member_id` (whose Claude in per-member mode), `queued_at`, `wait_reason`; `ticket_relations` references move to ticket ids.
- `oauth_*` (MCP): tokens bound to user **and** workspace.
- Row-level security on every workspace table: `USING (workspace_id = current_setting('app.workspace_id')::bigint)`.

Migrating an existing install: create workspace 1 ("Default"), make the oldest user its Owner and Admin, add every other user as User, set `workspace_id = 1` everywhere, move the install's Claude integration into a shared `claude_connections` row.

### 2. Auth and API

- Register, verify email, reset password; invites; workspace CRUD; members; transfer ownership.
- Workspace in the path: `/api/w/{slug}/…` for everything workspace-scoped; `/api/me`, `/api/workspaces`, `/api/admin/…` outside it.
- Middleware resolves the workspace, checks membership and role, and sets `app.workspace_id` on the request's database connection.
- OpenAPI regenerated; the admin TS client and the Dart client follow.

### 3. Orchestrator

- Settings, rules, trackers and the VCS host are looked up **per workspace** (today they are loaded once).
- Claude account resolution per run (rules above); usage pause per Claude account.
- The scheduler replaces `mayStart` (global `active < parallel`) with the admission checks and the fair order; `ClaimNext` gains the workspace slot rule. `wait_reason` and `queued_at` are maintained.
- Credits: reserve the per-run cap before a credits run, settle from `claude_calls.cost_usd` after.
- The merge poller (`CheckMerges`) and auto-resume run per workspace.

### 4. Runner

- Memory reservation and the budget; available-memory and free-disk checks.
- Network per run; gVisor runtime option (`AGNTS_RUN_RUNTIME=runsc`).
- Workspace-scoped checkout paths, worktrees, and cleanup (repo deleted, branch merged or rejected, cache idle 14 days).
- Out-of-memory detection from the container's exit state.

### 5. Integrations and webhooks

- Each workspace gets its own webhook URLs with a random id: `/webhooks/jira/{hook_id}`, `/webhooks/github/{hook_id}`, `/webhooks/plane/{hook_id}`, so a delivery maps to exactly one workspace before its signature is checked with that workspace's secret.
- Telegram: one bot, chats linked to a user; commands act in the user's current workspace and name it in replies.
- MCP: the OAuth consent screen picks the workspace.

### 6. Admin panel and mobile

- Sign up, verify, invite accept pages; workspace switcher in the top bar; "New workspace".
- Workspace settings: General, Members (invite, remove, roles, transfer), Claude (mode, workspace connection, fallback, default member), Billing (plan, slots, credits, history).
- Profile: personal Claude connection, Telegram, devices.
- Queue badges, ticket banner, workspace header counts; "who did what" names in history.
- Operator console for Admins.
- Mobile: workspace switcher, queue status, the same badges.

## Delivery

| Phase | Contents | Estimate |
| --- | --- | --- |
| 1. Foundation | Tables, `workspace_id` everywhere, RLS, migration of existing data, workspace in API paths and middleware | 2.5–3.5 weeks |
| 2. People | Register, verify, invites, roles, switcher, members page, actor names in history | 1.5–2 weeks |
| 3. Per-workspace config | Settings, integrations, per-workspace webhooks, Telegram, MCP | 1–2 weeks |
| 4. Claude modes | Workspace and personal connections, shared/per-member modes, usage per account | 1–1.5 weeks |
| 5. Capacity | Memory budget, admission, fair order, `wait_reason`, queue UI, operator console | 1–1.5 weeks |
| 6. Isolation | Checkout paths and cleanup, network per run, gVisor | ~1 week |
| 7. Billing | Plans, slots, credits ledger, payments (Payme/Click), invoices | 2–3 weeks |
| **Total** | | **~10–14 weeks** |

Phases 1–3 are needed before a second customer signs up. Phase 5's memory budget and `wait_reason` are useful on a single-team install too and can ship first.

## Open questions

1. **Claude subscriptions in a hosted product.** Anthropic's Agent SDK docs have said third-party products may not offer Claude.ai login or subscription limits without approval, and a team sharing one person's Pro/Max plan is the kind of shared-seat use the consumer terms forbid (Anthropic's Team plan exists for that). Shared mode on the cloud needs Anthropic's written approval; until then the cloud offers API keys (workspace or personal) and credits, and subscription mode stays available for self-hosted installs. Confirm before launch.
2. Anthropic API availability and billing for a company in Uzbekistan (needed for credits).
3. Payments: Payme and Click for so'm; a card processor for USD.
4. Does per-member mode need a per-member spending cap on workspace credits?
5. Free tier: a trial (14 days) or a permanent free workspace with tight limits (1 slot, no preview)?
6. When to add a second run server, and whether to build `run_nodes` before or after the first paying teams.
