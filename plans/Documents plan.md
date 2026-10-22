# agnts Documents — Plan

Oct 22, 2026 · v3, phases 0–7 built (not yet tested by hand); decisions at the end

## Overview

A **document** is a Markdown page that lives in a workspace. People write it by hand, or agnts writes it for them from what the workspace already knows: ticket reports, commits, pull requests, repositories and tickets. It's meant for project managers in particular: "what shipped this sprint", "review the open pull requests of `billing-api`", "state of the AMANAT-40..60 tickets", "health review of the mobile repository".

Each document:
- is **Private** or **Public**. A public document also has a link anyone can open, read-only, without signing in.
- has **access control**: its owner shares it with other workspace members as **View** or **Edit**.
- can be **linked to many tickets**, and a ticket can have many documents (many-to-many).
- keeps **versions**, so an AI regeneration or someone's edit never loses earlier text.

What exists today:
- Report kinds (`plan`, `analysis`, `bug`, `review`) already end in a Markdown report: `domain.Result.Report` (`domain/ticket.go:412`), `OutputReport` (`domain/kind.go:34`). It lives on a run's result, can't be edited after review, and belongs to one ticket.
- Workspace roles are `owner`, `user`, `viewer` (`domain/workspace.go:62`). Viewers are read-only through the API: the middleware rejects their writes unless an operation is marked `x-viewer` (`httpapi/middleware.go:173`). Reads need no mark.
- Public API operations already exist: an operation with `security: []` needs no session (`httpapi/middleware.go:69`).
- The repository survey (`orchestrator/brief.go`) is the model for a long read-only Claude run: a queue (`ClaimBrief`, `RecoverBriefs`), a run in the sandbox with the repository checked out, a file written to `/agnts/out/`, limits on turns and time.
- `vcs.Multi` already reads what a report needs: `Commits`, `CommitDetail`, `History`, `Ahead`, `PullRequests`, `PullRequest`, `PullFiles`, `Tree`, `File` (`vcs/vcs.go`, `vcs/history.go`, `vcs/comments.go`).
- `ticket_commits` links commits to tickets (`migrations/00056_ticket_commits.sql`).
- Which Claude account pays for a run is decided by `claude` (`claude/claude.go`): shared, per member, or credits fallback.
- Secrets are masked with `domain.Redactor` (`domain/mask.go`).
- Admin renders Markdown with `marked` + `dompurify`; mobile with `flutter_markdown_plus`.

## Rules

### Types: Private and Public

- **Private**: only people with access can open it (see Access).
- **Public**: the same, plus a **public link** `https://<host>/d/<token>` that anyone can open read-only, without an account. The page shows the title, the body and the last update date. It shows no member names, emails, ticket links or versions.
- The token is 32 random bytes, base62. It's stored as is (it only grants reading one document, and owners need to copy the link again later), and found through the unique index.
- Turning a document Private makes the link stop working at once. Turning it Public again **makes a new token**, so an old link that leaked stays dead. "Reset link" does the same without going private.
- **Who can make a document public**: its owner and the workspace owner. Edit access isn't enough, since publishing takes text outside the workspace.
- **Before a document goes public**, the body is scanned with the workspace's secret redactor and for common secret shapes (keys, tokens, connection strings). A hit blocks publishing and shows where. The owner can fix the text and try again. There's no "publish anyway".
- A workspace setting **"Allow public documents"** (default on, owner only) turns the feature off for teams that must not publish anything. Turning it off makes every public link stop working, without changing the documents' type.
- The public page sends `X-Robots-Tag: noindex` and `Referrer-Policy: no-referrer` (so the token doesn't leak to sites the document links to), has no third-party scripts, and is rate limited per IP.

### Access

Access levels, from least to most:

| Level | Can |
|---|---|
| **View** | read, see versions, see linked tickets they can see |
| **Edit** | View, plus edit the body and title, regenerate with AI, link and unlink tickets |
| **Owner** | Edit, plus share, change type, reset the link, transfer ownership, delete |

- The person who creates a document is its **owner**. There is one owner per document.
- The owner grants View or Edit to individual workspace members. Grants are listed on the document's Share dialog, with who granted them and when.
- **Workspace access**: each document also has a default for everyone in the workspace: `none` (default), `view` or `edit`. A person gets the higher of their own grant and the workspace default. This covers "everyone in the team can read the sprint reports" without granting people one by one.
- **The workspace owner always has Owner access** to every document in the workspace. Without this, a document whose owner left could never be reached again. The Share dialog says so: "The workspace owner can always open this".
- **Workspace viewers are capped at View**, whatever they're granted. The grant dialog doesn't offer Edit for them.
- **When a member leaves the workspace** (removed by the owner through `Accounts.RemoveMember`, or leaving on their own through `Accounts.Leave`), their grants are deleted and documents they owned move to the workspace owner, **in the same transaction as the removal**. Both are logged as events on the document.
- **When a user's account is deleted** (`users.Delete`, a hard delete), the same transfer runs first for every workspace they're in, in the same transaction. `documents.owner_id` has no `ON DELETE` on purpose: a deletion path that forgets the transfer fails instead of leaving documents without an owner.
- **Workspace viewers and creating documents**: undecided, see open question 6. Until then, viewers can't create documents, because `POST /documents` is a write and the middleware blocks viewers' writes.
- **Platform admin** reaches documents only the way they reach other workspace data today (support access), not through the documents UI.
- Everything is checked on the server. A document someone can't open answers 404, not 403, so its existence and title don't leak.

### Linking to tickets

- `document_tickets` is many-to-many: a document can be linked to many tickets, a ticket to many documents.
- Linking needs **Edit on the document** and a workspace role that can edit tickets (`user` or `owner`).
- The ticket page has a **Documents** section listing the linked documents **the viewer can open**. Documents they can't open aren't shown, and aren't counted.
- The document page lists its linked tickets, with key, title and state.
- A document made from a ticket's report, or about a set of tickets, is linked to those tickets automatically. Unlinking later is allowed.
- Deleting a ticket removes its links; deleting a document removes its links. Neither deletes the other.

### Making a document with AI

A document is made from a **source** and an optional **instruction** ("for the client, no technical detail", "focus on risks"). The source decides what agnts gathers. Every source works the same way afterwards: agnts gathers facts in code, then Claude writes the document from them.

| Source | What agnts gathers | Typical use |
|---|---|---|
| **Ticket report** | One ticket's approved report, its description, state, linked commits and pull request | Turn a plan or analysis into a page for the client or the team |
| **Tickets** | A chosen list of tickets, or a filter (state, kind, period, assignee, repository): title, state, dates, reports, linked commits | Status report, sprint summary |
| **Commits** | A repository (or group), a branch, a period, optional author: commits with messages, linked tickets, diff stats | "What changed in `billing-api` last week" |
| **Pull requests** | A repository (or group), state (open/merged), a period, or chosen numbers: title, description, author, review state, changed files, diff | Review digest, release notes |
| **Repository** | One repository at a ref, read in the sandbox like a survey, plus its approved brief and architecture | Health review, onboarding doc, tech debt review |

- **Templates** set the shape of the output: *Status report*, *Release notes*, *Pull request review*, *Repository review*, *Ticket summary*, *Blank (instruction only)*. A template is a prompt section plus a skeleton of headings. Templates are code, versioned with `prompt_version`, not editable per workspace in v1.
- **Language**: the document's language is picked on the form, defaulting to the person's language (see `Languages plan.md`).
- **How it runs**: like a survey (`orchestrator/brief.go`): a `document_runs` queue, a read-only Claude run in the sandbox, the gathered facts written to `/agnts/context/sources/`, the document written to `/agnts/out/document.md`. The Repository source also checks out the repository. The other sources don't need a checkout but use the same run so there's one path, one set of limits and one place for usage.
  - Limits: 40 turns and 15 minutes; 80 turns and 30 minutes for the Repository source.
  - Large inputs are trimmed before the run, as in the performance review plan: diffs above a budget keep the files with the most changed lines in full and a one-line summary for the rest. The document says what was left out.
- **Who pays**: the run uses the Claude account `claude` picks for the person who asked, the same as their tickets.
- **Recording spend**: today spend is tied to tickets. `claude_calls.run_id` → `runs.ticket_id` are both `NOT NULL` (`00015_claude_calls.sql`, `00001_init.sql`), and credits are charged per run (`credit_ledger.reason = 'run'`, `00024_claude_and_credits.sql`). Document runs have no ticket, so:
  - a new transcript purpose `PurposeDocument` (`domain/transcript.go`), like `PurposeBrief` for surveys;
  - `claude_calls` gets a nullable `document_run_id`, and `run_id` / `ticket_id` become nullable, with a check that exactly one of `run_id` and `document_run_id` is set;
  - `credit_ledger` gets a `document_run_id` and the reason `'document'`, charged when the run ends, the same way runs settle from `claude_calls.cost_usd`;
  - the Usage and spend pages show document spend on its own line.
  - Check first whether surveys on credits are charged at all. If they aren't, that's an existing gap, and this fix should cover `PurposeBrief` too.
- **Facts are cited**: the prompt asks for ticket keys, commit shas and pull request numbers next to every claim. On the admin page these become links. On the public page they stay plain text.
- **Secrets**: the output goes through the workspace's redactor before it's saved, the same as run logs.
- **Status** of a document's generation is the status of its latest `document_runs` row: `queued`, `writing`, `done`, `failed` (with the reason). It's stored only there. People can edit the title while it's writing, not the body.
- **Regenerate** (Edit access): runs again with the same source and instruction, or changed ones. Each run keeps the source it used, so an older AI version still says what it was made from. The result is a **new version**. It never overwrites edits in place, and the page shows "Regenerated, replacing edits by Aziz from 2 hours ago — restore" when the previous version was a person's edit.
- **Freshness**: sources are captured when the document is made. The document shows "Based on data up to Oct 22, 14:05". Nothing updates by itself in v1.

### Editing and versions

- The body is **Markdown**, edited in a textarea with a live preview on admin. No real-time co-editing in v1.
- Every save makes a version: who, when, `source` (`human`, `ai`, `restore`), and a short note for AI versions (template + instruction).
- Saves carry the version they started from. If someone saved in between, the save is refused with 409 and the editor shows both texts so the person can merge by hand.
- Any version can be restored. Restoring makes a new version; history is never rewritten.
- Body limit: 200 KB. Versions kept: all of them in v1, since text is small. Revisit if a workspace passes 10k versions.

### Downloading

- Any document can be downloaded as **Markdown (`.md`)** or **PDF (`.pdf`)**. Downloading counts as reading, so **View** access is enough. A public document can also be downloaded from its public page.
- Any version can be downloaded, not only the current one. The default is the current one.
- **File name**: the title, slugified, plus the version: `sprint-42-status-report-v7.md`. Titles in Cyrillic are transliterated, and if nothing is left the name falls back to `document-<id>-v<version>`.
- **Markdown**: the version's body, preceded by `# <title>` when the body doesn't already start with that heading. UTF-8, LF line endings, no front matter. Ticket keys, shas and pull request numbers stay as plain text, so the file means the same thing outside agnts.
- **PDF**: the same rendering as the document page, with print styles: A4, title, a "Version 7 · Oct 22, 2026" line, page numbers in the footer, code blocks wrapped rather than cut, tables split across pages with repeated headers. Fonts must cover Latin, Cyrillic and Uzbek Latin (`oʻ`, `gʻ`), so the PDF embeds Noto Sans and Noto Sans Mono.
  - **How it's made**: the server converts the Markdown to HTML with the same sanitising rules as the page, then Chromium prints it. Chromium already ships in the runner image for previews (`deploy/runner/Dockerfile:71`), so the PDF is a short job in the sandbox: no network, no repository, 30 seconds at most. The server image doesn't grow.
  - **Cached per version**: a version's text never changes, so its PDF is made once and kept (`document_exports`). For signed-in people, the first download of a version waits for the job (the client shows "Preparing PDF…"); later ones are instant. When the sweeper removes a deleted document for good, its exports go with it.
  - **Public documents are rendered ahead**: the PDF of the current version is made when the document is published and after each save while it's public. The public download only serves that cached file, and answers 202 with `Retry-After` while it's being made. A visitor without an account can never start a render, so the public page can't be used to fill the runners and hold back ticket runs (PDF jobs take memory from the same budget, `orchestrator/capacity.go`).
  - A PDF that fails to render answers 503 with a retry hint. The Markdown download keeps working.
  - Images in the body are only fetched from the document's own attachments, never from the internet, so a public PDF can't be used to make the sandbox call out.
- Downloads from the public page are rate limited like the page itself and show no member names, the same as the page.

### Deleting

- Only the owner (and the workspace owner) can delete. A deleted document is soft-deleted for 30 days: hidden everywhere, public link dead, ticket links hidden. The document's owner and the workspace owner can restore it from a "Deleted documents" list. After 30 days a sweeper removes it for good.

## Data

All tables follow the workspace convention: `workspace_id … DEFAULT agnts_ws()` and the `workspace_isolation` policy.

`migrations/00060_documents.sql`:

```sql
CREATE TABLE documents (
  id               bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  workspace_id     bigint NOT NULL DEFAULT agnts_ws() REFERENCES workspaces (id) ON DELETE CASCADE,
  title            text   NOT NULL,
  body             text   NOT NULL DEFAULT '',     -- the current version, copied for reads
  version          int    NOT NULL DEFAULT 0,      -- current version number, for 409 on saves
  type             text   NOT NULL DEFAULT 'private' CHECK (type IN ('private', 'public')),
  public_token     text   UNIQUE,                  -- set only while public
  workspace_access text   NOT NULL DEFAULT 'none' CHECK (workspace_access IN ('none', 'view', 'edit')),
  owner_id         bigint NOT NULL REFERENCES users (id),  -- no ON DELETE: ownership is moved before a user goes
  language         text   NOT NULL DEFAULT 'en',
  -- What it was made from; NULL for a hand-written document.
  -- The latest run's source, for the Regenerate form; each run keeps its own.
  source           jsonb,                          -- {kind, template, instruction, repo_ids, tickets, from, to, ...}
  data_as_of       timestamptz,
  deleted_at       timestamptz,
  created_at       timestamptz NOT NULL DEFAULT now(),
  updated_at       timestamptz NOT NULL DEFAULT now(),
  CHECK ((type = 'public') = (public_token IS NOT NULL))
);
CREATE INDEX documents_ws_idx ON documents (workspace_id, updated_at DESC) WHERE deleted_at IS NULL;

CREATE TABLE document_runs (
  id           bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  workspace_id bigint NOT NULL DEFAULT agnts_ws() REFERENCES workspaces (id) ON DELETE CASCADE,
  document_id  bigint NOT NULL REFERENCES documents (id) ON DELETE CASCADE,
  requested_by bigint REFERENCES users (id) ON DELETE SET NULL,
  status       text   NOT NULL DEFAULT 'queued' CHECK (status IN ('queued', 'writing', 'done', 'failed')),
  source       jsonb  NOT NULL,                    -- what this run was made from
  prompt_version text NOT NULL,
  error        text   NOT NULL DEFAULT '',
  started_at   timestamptz,
  finished_at  timestamptz,
  created_at   timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX document_runs_queue_idx ON document_runs (created_at) WHERE status = 'queued';
CREATE INDEX document_runs_doc_idx ON document_runs (document_id, created_at DESC);

CREATE TABLE document_versions (
  document_id  bigint NOT NULL REFERENCES documents (id) ON DELETE CASCADE,
  workspace_id bigint NOT NULL DEFAULT agnts_ws() REFERENCES workspaces (id) ON DELETE CASCADE,
  version      int    NOT NULL,
  title        text   NOT NULL,
  body         text   NOT NULL,
  source       text   NOT NULL CHECK (source IN ('human', 'ai', 'restore')),
  note         text   NOT NULL DEFAULT '',
  author_id    bigint REFERENCES users (id) ON DELETE SET NULL,
  run_id       bigint REFERENCES document_runs (id) ON DELETE SET NULL,  -- for ai versions
  created_at   timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (document_id, version)
);

CREATE TABLE document_access (
  document_id  bigint NOT NULL REFERENCES documents (id) ON DELETE CASCADE,
  workspace_id bigint NOT NULL DEFAULT agnts_ws() REFERENCES workspaces (id) ON DELETE CASCADE,
  user_id      bigint NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  level        text   NOT NULL CHECK (level IN ('view', 'edit')),
  granted_by   bigint REFERENCES users (id) ON DELETE SET NULL,
  created_at   timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (document_id, user_id)
);
CREATE INDEX document_access_user_idx ON document_access (user_id);

CREATE TABLE document_tickets (
  document_id  bigint NOT NULL REFERENCES documents (id) ON DELETE CASCADE,
  ticket_id    bigint NOT NULL REFERENCES tickets (id) ON DELETE CASCADE,
  workspace_id bigint NOT NULL DEFAULT agnts_ws() REFERENCES workspaces (id) ON DELETE CASCADE,
  linked_by    bigint REFERENCES users (id) ON DELETE SET NULL,  -- NULL when agnts linked it
  created_at   timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (document_id, ticket_id)
);
CREATE INDEX document_tickets_ticket_idx ON document_tickets (ticket_id);

-- A PDF made from one version, kept because a version never changes.
CREATE TABLE document_exports (
  document_id  bigint NOT NULL,
  version      int    NOT NULL,
  workspace_id bigint NOT NULL DEFAULT agnts_ws() REFERENCES workspaces (id) ON DELETE CASCADE,
  format       text   NOT NULL CHECK (format IN ('pdf')),
  status       text   NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'done', 'failed')),
  data         bytea,                              -- the file, when done
  size         int    NOT NULL DEFAULT 0,
  error        text   NOT NULL DEFAULT '',
  created_at   timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (document_id, version, format),
  FOREIGN KEY (document_id, version) REFERENCES document_versions (document_id, version) ON DELETE CASCADE
);
```

Spend of document runs (see Recording spend):

```sql
ALTER TABLE claude_calls
  ALTER COLUMN run_id DROP NOT NULL,
  ALTER COLUMN ticket_id DROP NOT NULL,
  ADD COLUMN document_run_id bigint REFERENCES document_runs (id) ON DELETE CASCADE,
  ADD CONSTRAINT claude_calls_owner_check CHECK ((run_id IS NULL) <> (document_run_id IS NULL));

ALTER TABLE credit_ledger
  ADD COLUMN document_run_id bigint REFERENCES document_runs (id) ON DELETE SET NULL,
  DROP CONSTRAINT credit_ledger_reason_check,
  ADD CONSTRAINT credit_ledger_reason_check CHECK (reason IN ('purchase', 'run', 'document', 'refund', 'grant'));
CREATE UNIQUE INDEX credit_ledger_document_run_idx ON credit_ledger (document_run_id) WHERE reason = 'document';
```

Every query that reads `claude_calls` by ticket keeps working, since document rows have no ticket. Queries that sum workspace spend must include them.

Markdown downloads aren't stored: they're the version's body, served as is.

Workspace setting `documents.public_allowed` (bool, default true) goes in the existing settings.

The public lookup by token runs as system work (`app.workspace_id = 'all'`) in one store method that returns only `title, body, updated_at` and checks `type = 'public' AND deleted_at IS NULL` and the workspace setting. Nothing else in the public path touches workspace data.

## Code

- `domain/document.go`: `Document`, `DocumentVersion`, `AccessLevel` (`none < view < edit < owner`), `DocumentSource`, and **`EffectiveAccess(doc, user, role, grant) AccessLevel`**: the single rule for owner, workspace owner, grant, workspace default and the viewer cap. Table-tested.
- `domain/document_scan.go`: the pre-publish secret scan. Table-tested with real-looking keys.
- `store/postgres/documents.go`: CRUD, `SaveVersion` (checks `version`, 409 on mismatch), `ListForUser` (filters by effective access in SQL), access grants, ticket links, `PublicDocument(token)`, the run queue (`ClaimDocumentRun`, `RecoverDocumentRuns`), the 30-day sweeper.
- `orchestrator/documents.go`: gatherers per source (tickets, commits, pull requests, repository), trimming, the run, saving the result as an `ai` version, auto-linking tickets. Templates and the prompt in `orchestrator/document_prompts.go` with `documentPromptVersion`.
- `DocumentStore.HandOver(tx, ws, userID)`: delete grants, move ownership to the workspace owner, write events. Called inside the transactions of `Accounts.RemoveMember`, `Accounts.Leave` and `users.Delete`.
- `orchestrator/document_export.go`: Markdown → sanitised HTML with print CSS and embedded fonts, the Chromium print job in the sandbox, the `document_exports` cache.
- `domain/filename.go`: the slug and transliteration for download names. Table-tested with Russian and Uzbek titles.
- `httpapi/documents.go`.
- Document events go only to people who can open the document, through `Broker.PublishTo` per person (`httpapi/stream.go`), never as stored workspace events.

## API

In `shared/openapi/openapi.yaml`, tag `documents`:

| Method | Path | Access |
|---|---|---|
| GET | `/documents?q=&ticket=&mine=` | lists what the caller can open |
| POST | `/documents` | create, blank or with `source` (starts a run); `x-viewer` only if open question 6 says viewers may create |
| GET | `/documents/{id}` | View; includes the caller's level |
| PUT | `/documents/{id}` | Edit; `{title, body, base_version}` |
| DELETE | `/documents/{id}` | Owner |
| POST | `/documents/{id}/regenerate` | Edit |
| GET | `/documents/{id}/versions`, `/versions/{v}` | View |
| POST | `/documents/{id}/versions/{v}/restore` | Edit |
| PUT | `/documents/{id}/sharing` | Owner; `{type, workspace_access, grants[]}`; answers the public URL or the scan's findings |
| POST | `/documents/{id}/reset-link` | Owner |
| PUT | `/documents/{id}/owner` | Owner |
| POST/DELETE | `/documents/{id}/tickets/{key}` | Edit + ticket edit |
| GET | `/tickets/{key}/documents` | the linked documents the caller can open |
| POST | `/tickets/{key}/documents` | shortcut: make a document from this ticket's report |
| GET | `/documents/{id}/download?format=md\|pdf&version=` | View; `Content-Disposition: attachment`; 202 + `Retry-After` while a PDF is being made |
| GET | `/public/documents/{token}` | `security: []`, rate limited |
| GET | `/public/documents/{token}/download?format=md\|pdf` | `security: []`, rate limited, current version only, served from the cache (202 + `Retry-After` until it's ready) |

Regeneration status and other changes reach clients through the event stream as `document.updated`, carrying only the document id. They're **not stored events**: the broker sends stored events to everyone in the workspace (`httpapi/stream.go`), which would leak private titles. They go through `PublishTo` to each person who can open the document, and clients refetch through the access check.

## Clients

### Admin (`apps/admin`)

- **Documents** in the nav: a list with title, type badge, owner, linked ticket count, updated date; filters *Mine / Shared with me / All I can open*.
- **New document** dialog: Blank, or a source with its pickers (tickets / repository + period / pull requests / repository), template, instruction, language.
- **Document page**: rendered view, Edit (textarea + preview), versions drawer with diff, linked tickets, generation status, Regenerate.
- **Share dialog**: type switch with the public link and Copy / Reset, workspace access, member grants, owner transfer. Scan findings show here when publishing is blocked.
- **Ticket page** (`pages/TicketPage.vue`): a Documents section with linked documents, "Link document", and on tickets with a report, "Make a document from this report".
- **Download** menu on the document page (Markdown / PDF) and on each row of the versions drawer.
- **Public page**: route `/d/:token` outside the signed-in shell, using `marked` + `dompurify`, no app chrome, no tracking, with the same Download menu.
- Translations in `shared/i18n/{en,ru,uz}/documents.json`.

### Mobile (`apps/mobile`)

- v1: the documents list, the read-only view, linked documents on the ticket screen, "Make a document from this report", copying the public link, the Share dialog, and **Download as .md / .pdf**, which saves the file and opens the system share sheet. That needs `share_plus` and `path_provider`, which aren't in `pubspec.yaml` yet. Editing Markdown on a phone is left for Later.
- Regenerate the API client and translations, as in `47ae7db`.

## Phases

0. **Data and access rule**: migration, `domain/document.go` with `EffectiveAccess` and its tests, store with tests. No UI.
1. **Hand-written documents**: API for create/read/edit/versions/delete, admin list and page, Markdown editor, 409 handling, **Markdown download**.
   - Then **PDF download**: print CSS, fonts, the Chromium job, the export cache.
2. **Sharing**: grants, workspace access, viewer cap, owner transfer, member-leaves hook. Share dialog.
3. **Public links**: token, scan, workspace setting, public API and `/d/:token` page, rate limit, PDF rendered ahead for public documents.
4. **Ticket links**: `document_tickets`, ticket page section, document page section.
5. **AI from a ticket report**: the run queue, spend recording and credits, the Ticket report source, Regenerate. This proves the generation path on the simplest source.
6. **AI for project managers**: Tickets, Commits, Pull requests and Repository sources, templates, trimming, citations as links.
7. **Mobile**: the v1 screens above.

Each phase ships on its own and is tested by hand before the next, as in `Code quality plan.md`.

## Tests

- `EffectiveAccess` table: owner, workspace owner, grant view/edit, workspace default, viewer capped, no access, removed member.
- Store: `ListForUser` never returns a document the rule denies (property test against `EffectiveAccess` over random grants).
- API: 404 (not 403) for documents the caller can't open; viewer can't save even with an Edit grant; only owner can publish; 409 on stale `base_version`.
- Events: a person without access gets no `document.updated` for a private document.
- Membership: removing a member, a member leaving, and deleting an account each move ownership and drop grants; a delete that skips the hand-over fails on the foreign key.
- Spend: a document run's calls land in `claude_calls` with no ticket; on credits it's charged once with reason `document`.
- Public: dead after going private, after reset, after delete, after the workspace setting is turned off; returns no names, emails or ticket keys beyond the body.
- Scan blocks a body with an AWS key, a GitHub token, a Postgres URL with a password.
- Download: View access is enough and no access is 404; an old version downloads its own text; file names for Latin, Cyrillic, Uzbek and empty-after-slug titles; the public download dies with the link.
- PDF: a fixture with a wide table, a long code block, Cyrillic and `oʻ` renders with no missing glyphs (checked by extracting the text back); a second download of a version is served from the cache; a public download never starts a render; an image URL to the internet isn't fetched.
- Generation: gatherers on fixture data; trimming keeps the biggest files; the redactor runs on the output; tickets get auto-linked.

## Later

- Linked documents as **context for ticket runs** (a spec document linked to a ticket reaches `/agnts/context/documents/`). Needs a rule for documents the ticket's member can't open.
- Scheduled documents: "every Friday, a status report of the week", with the result as a new version.
- Ask AI to revise a selection, not the whole document.
- Real-time co-editing and comments.
- Documents through the MCP server (`mcpserver`) and as an assistant action ("write a report of last week's merged pull requests").
- Export to `.docx`, and posting to Jira / Plane / Confluence.
- Workspace branding on PDFs (logo, colours).
- Public links with an expiry date or a password.
- Per-workspace templates.
- Editing on mobile.

## Decisions taken when building

The open questions were settled with the recommendations, to be revisited if they turn out wrong:

1. **The workspace owner has Owner access to every document.** The Share dialog says so.
2. **The per-document "everyone in the workspace" access is kept.**
3. **The requester's Claude account pays**, as for tickets. Spend lands in `claude_calls` with `model_stage = 'document'`, so it has its own line on the Usage page.
4. **PDFs are printed in a short runner container** with the Playwright Chromium the image already has (`orchestrator/document_pdf.mjs`), taking 1 GB from the run memory budget and giving up when there is none. A dedicated renderer is left for Later. Fonts: DejaVu (already in the image) covers Latin, Cyrillic and `oʻ`; `fonts-noto-core` and `fonts-noto-mono` are added to the runner Dockerfile for the next build.
5. **Documents as context for ticket runs** stays in Later.
6. **Workspace viewers may create documents** and own them; they cannot link tickets by hand (agnts still links the ticket a report document comes from).

Not done from the plan:
- The pre-publish scan uses the credential shapes `domain.MaskCredentials` knows; no workspace-specific secret values are fed to it yet.
