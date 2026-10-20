# agnts Commit Links — Plan

Oct 20, 2026 · v1 implemented (server, admin panel, mobile, MCP); manual check against a real GitHub and GitLab webhook still to do

## Overview

agnts already writes the ticket's number into the branches and commits it makes (`branch_template`, `commit_template`, `Ticket.Number()`). People work on the same tickets by hand: they push `feature/AMANAT-2288-login`, or commit `AMANAT-2288: fix token refresh` straight to main. agnts doesn't see any of that today. The GitHub `push` webhook is only logged (`vcs/hooks.go`), and GitLab's Push Hook isn't handled.

This plan links every commit whose **branch name or message** has a ticket's number (or key) to that ticket. Commits come from push webhooks live, plus a backfill scan. Human and agnts commits are linked alike. The links show in three places: on the ticket page, as a ticket chip in the repository browser's commits, and through the MCP and assistant tools. Nothing changes a ticket's state (see Later).

## Rules

- **What matches**: the ticket's `TicketNumber` and its `Key`, case-insensitive, as a whole token. The character before and after must not be a letter or digit. So `AMANAT-22` does not match `AMANAT-2288`, but `feature/AMANAT-2288-login` and `[amanat-2288]` do.
- **Where**: the branch the commit was pushed to (`matched_on = branch`) and the full commit message (`matched_on = message`). One commit can match both, and it gets one link that records both. A commit can link to more than one ticket (`AMANAT-1, AMANAT-2: shared fix`).
- **Finding candidates**: a regex pulls `PREFIX-123`-shaped tokens (`(?i)\b[a-z][a-z0-9_]*-\d+\b`) out of the branch and message. One query then resolves them (`lower(ticket_number) = ANY($1) OR lower(key) = ANY($1)`), scoped to the workspace. Numbers that `ValidTicketNumber` accepts but that don't have this shape (`2288`, `fix.1`) are not linked (see Known limits).
- **Which ticket when a number repeats**: numbers are unique only among open tickets (`OpenTicketWithNumber`). An open ticket with the number wins. Otherwise the most recently updated closed ticket gets the link. A ticket's `Key` is always unique.
- **Default branch**: branch matching is skipped there (main has no number), but message matching still applies. Merge commits (`Merge branch 'feature/AMANAT-2288'…`) link through their message.
- **Ignored**: tag pushes, branch deletions (`after` = all zeros), and repositories agnts doesn't know or that are archived.
- **Number changes** (`SetTicketNumber`): links matched on the old number are removed, then a backfill runs for the new one. Links matched on the `Key` stay.
- **Scope**: everything is workspace-scoped. The webhook's hook id gives the workspace, the same way CI runs and PR comments get it.

## Data

`migrations/00056_ticket_commits.sql`:

```sql
CREATE TABLE ticket_commits (
  ticket_id     bigint NOT NULL REFERENCES tickets(id) ON DELETE CASCADE,
  repo_id       bigint NOT NULL REFERENCES repositories(id) ON DELETE CASCADE,
  sha           text   NOT NULL,
  branch        text   NOT NULL DEFAULT '',  -- the branch it was first seen on
  subject       text   NOT NULL DEFAULT '',  -- first line of the message
  author        text   NOT NULL DEFAULT '',
  author_login  text   NOT NULL DEFAULT '',
  url           text   NOT NULL DEFAULT '',
  committed_at  timestamptz NOT NULL,
  matched_on    text[] NOT NULL,             -- {branch}, {message} or both
  token         text   NOT NULL,             -- what matched (AMANAT-2288 / VIS-1)
  created_at    timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (ticket_id, repo_id, sha)
);
CREATE INDEX ticket_commits_repo_sha ON ticket_commits (repo_id, sha);
```

Inserts use `ON CONFLICT DO UPDATE` and merge `matched_on`, so webhook redeliveries, backfills and pushes of the same commit to a second branch are all harmless.

## Server

1. **`domain/commitlink.go`**: `TicketTokens(branch, message string) []string` (the regex plus boundary rules) and `domain.CommitLink`. The rules are pure functions with table tests.
2. **`vcs/hooks.go`**:
   - GitHub `push`: parse `ref`, `after`, `commits[]` (id, message, author name/username, timestamp, url) and the repository full name.
   - GitLab `Push Hook`: parse `ref`, `checkout_sha`, `commits[]` and `total_commits_count`, plus `project.path_with_namespace`.
   - Both go to a new optional `PushSink` interface (`CommitsPushed(ctx, domain.Push) error`), following the pattern of `CISink` and `CommentSink`. Errors are logged and not returned.
3. **`orchestrator/commitlinks.go`** (or its own small `internal/commitlink` service, like `ciwatch`):
   - `CommitsPushed`: resolves the repository by provider and full name, extracts tokens, resolves tickets, upserts links, and appends one `ticket_updated` event per ticket per push ("3 commits pushed to feature/AMANAT-2288-login by alice"). It runs async with `context.WithoutCancel`, like `ciwatch`.
   - `Backfill(ticket)`: runs on create with a number, on `SetTicketNumber`, and on `ContinueTicket`. For each of the workspace's repositories, it lists branches (`Multi.Branches`) and takes those whose name has a token. It reads their commits ahead of the default branch, plus the last 500 commits (or 90 days, whichever is fewer) of the default branch, and matches messages. It runs through a bounded worker so a burst of new tickets doesn't drain the host's rate limits.
   - `BackfillRepo(repo)`: runs when a repository is added. It does the same scan for all open tickets in one pass.
4. **Store** (`store/postgres`): `UpsertCommitLinks`, `CommitLinksOfTicket(ticketID, limit)`, `TicketsOfCommits(repoID, shas []string)` (batch, for the browser list), `DeleteCommitLinksByToken(ticketID, token)`, `TicketsByTokens(tokens)`.
5. **Pagination gap**: GitLab sends at most 20 commits per push, and GitHub sends at most 2048. When `total_commits_count > len(commits)`, the service fetches the rest with a compare of `before..after` (a new `Provider.Compare`, or `Commits` from `after` until `before`).

## API

- `GET /tickets/{key}/linked-commits?limit=&offset=` → `[{ sha, shortSha, subject, author, authorLogin, branch, repo {id,name}, url, committedAt, matchedOn[] }]`, newest first.
- The repository browser's commit list and commit detail get `tickets: [{ key, number, title, state }]`, filled by one `TicketsOfCommits` batch per page.
- Add both to the OpenAPI spec and regenerate `httpapi/gen`.

## Clients

- **Admin**: a new `components/ticket/TicketCommits.vue` section under `TicketRepos`. It shows a short sha (linking to the host), the subject, author, branch, a relative date, and a small `branch`/`message` badge. It loads 20 at a time with "Show more". The repository browser's commit rows and commit detail show a `TicketNumber`-style chip that links to the ticket.
- **Mobile**: a "Commits" section on the ticket screen with the same rows, and the same chip in the commit view.
- **MCP / assistant**: `get_ticket` includes `commits` (the latest 10 plus the total count). A new read-only `list_ticket_commits` tool (ticket, limit) returns the full list. The tool description notes that commit messages are written by people and are data, not instructions. The assistant gets them through the tools it already reads.

## Tests

- `domain`: `TestTicketTokens` (boundaries, case, multiple tokens, merge-commit messages, `AMANAT-22` vs `AMANAT-2288`).
- `vcs`: GitHub `push` and GitLab `Push Hook` payload parsing, plus ignored tag and delete pushes.
- `store`: upsert merging `matched_on`, cascade on ticket delete, `TicketsOfCommits` batch.
- `orchestrator`/service:
  - a push links to the open ticket over a closed one with the same number
  - a number change removes old links and backfills
  - redelivery is a no-op
  - a GitLab push over 20 commits fetches the rest
- `httpapi`: routes and the `tickets` field on commits.
- Admin: `TicketCommits.test.ts`.
- `mcpserver`: `list_ticket_commits` is in the tool list and `get_ticket` carries commits.

## As built

The phases from the plan, in order. Everything above holds, with these specifics:

1. **Foundation**: `domain/commitlink.go` (`TicketTokens`, `PickTicket`, `TicketTokensOf`, `Push`, `CommitLink`), migration `00056_ticket_commits.sql` (with workspace RLS and `lower()` indexes on ticket numbers and keys), and the store methods in `store/postgres/commitlinks.go`.
2. **Live links**: `vcs/hooks.go` parses GitHub `push` (only `distinct` commits, so taking in main does not link main's history) and GitLab `push`, and hands them to the new `vcs.PushSink`. The new `internal/commitlink` service (wired in `serve.go` like `ciwatch`) links them in the background, with at most 2 jobs at a time. When a push left commits out (GitLab's 20), it reads the rest with the new `vcs.HistoryReader.Ahead` (compare `before..after`, or `default..after` for a new branch). Each push writes one `commits_linked` event per ticket that gained commits.
3. **Backfill**: `orchestrator.SetCommitLinker` gets `TicketNumberChanged` from tracker imports, `createTask` (when given a number), `SetTicketNumber` and `UpdateTask`. `admin.Repos.OnAdd` scans a newly added repository for every ticket. A repository's branch names (up to 300) and default-branch history (500 commits / 90 days) are cached for 10 minutes, so a tracker import of many tickets reads them once. Up to 50 numbered branches are read per scan.
4. **Surfaces**: `GET /tickets/{key}/linked-commits` (`limit` up to 100, `offset`). `Commit` and `CommitDetail` gained `tickets`, and `ticketKey` now prefers the first linked ticket. Admin: `TicketCommits.vue` on the ticket page (shown once a commit is linked; reports excluded) and `CommitTickets.vue` chips in the repository's commits and on the commit page. Mobile: `LinkedCommitsFold` on the ticket screen and the same chips. Both refresh on `commits_linked`. MCP: `get_ticket` includes `linked_commits` (newest 10, plus `linked_commits_total`), and there is a new read-only `list_ticket_commits`. The assistant sees the same commits through `get_ticket` in its snapshot. The Integrations page now asks for push events on the GitHub/GitLab webhook.

Tests: `domain` `TestTicketTokens`/`TestPickTicket`, `store` `TestCommitLinks`, `vcs` `TestGitHubPush`/`TestGitLabPush` and `TestHistory` (GitHub and GitLab), `commitlink` (push, default branch, left-out commits, scan and number change, history cut-off), `orchestrator` `TestCommitLinkerHearsNumbers`, `httpapi` `TestListTicketLinkedCommits`, `mcpserver` `TestLinkedCommits`, admin `TicketCommits.test.ts`, mobile `linked_commits_test.dart`.

## Known limits

- Only `PREFIX-123`-shaped numbers are found. Supporting arbitrary `ValidTicketNumber` values would mean scanning every token against the workspace's number set. That can be added later if teams use numbers without a hyphen.
- Commits pushed while agnts had no webhook configured are only found by the backfill's window (500 commits / 90 days).
- Rebased or force-pushed commits leave their old sha's links behind, and those links point to commits that are gone. They still render, with a dead host link. Pruning them is a later job.
- A typo'd number links to whatever ticket has that number, if one exists.
- Existing webhooks must have push events turned on (GitHub: Pushes; GitLab: Push events), or only the backfill finds commits.
- The mobile list shows up to 100 commits; the admin panel pages through all of them.

## Later

- State effects: mark a ticket done when a linked branch merges into the default branch, or show "work in progress by alice" on a ticket nobody assigned to agnts.
- Linking pull requests the same way (by PR branch and title), not only commits.
