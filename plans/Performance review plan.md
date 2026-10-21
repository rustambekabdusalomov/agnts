# agnts Performance Review — Plan

Oct 21, 2026 · draft v3 (after second review), decisions settled, not started

## Overview

Counting closed tickets rewards volume, not difficulty. A developer who closes 10 simple CRUD tickets looks better than one who closes 3 tickets with hard logic, though the second did more. This plan gives every delivered ticket a **complexity score** and reports each developer's **delivered complexity** for a period.

For example, 10 CRUD tickets at 1 point each gives **10**, and 3 complex tickets at 8 points each gives **24**.

What exists today:
- Analysis already outputs `Complexity` = simple|complex (`orchestrator/prompts.go:43`). It's too coarse, and it's a guess made before any code exists. Today it only picks the review model.
- `ticket_commits` (`migrations/00056_ticket_commits.sql`) links people's and agnts's commits to tickets by number in branch or message, with `author_login`. It stores no line counts, no parents and no author email. `author` is a display name. `branch` is the branch a commit was *first seen on*, so a commit pushed to a feature branch and merged later still shows the feature branch. Merge commits link through their message.
- `domain.PushedCommit` (`domain/commitlink.go:17`) carries only `SHA, Message, Author, AuthorLogin, Date, URL`.
- Commit history scans stop at 90 days and 500 commits (`commitlink/commitlink.go:38`).
- `ticket_repos` (`migrations/00045_repo_groups.sql`) holds one row per repository of a ticket. `merged_at` is set only for pull requests agnts opened or tracks (`orchestrator/pullreview.go`).
- agnts's commits can be authored as a person (`AGNTS_GIT_AUTHOR_NAME`/`_EMAIL`, `config/config.go:40`). So commit authorship alone can't tell agent work from human work.
- Analytics (`httpapi/analytics.go`, `store/postgres/analytics_tabs.go`, `apps/admin/src/pages/AnalyticsPage.vue`) is workspace- or repo-wide. Nothing is broken down per developer.
- Tickets have no story points, estimates or labels.
- Kind `bug` means "find a bug's root cause, change nothing" (`domain/kind.go:13`), so the kind doesn't say whether code was delivered.

## Rules

### Which tickets are scored

- Any ticket with delivered linked commits, **except** kinds `review` and `swaggertest`, and `SourceGit` pull-request reviews. The kind isn't used beyond that: a `bug` ticket that a person fixed by hand is scored on the fix, and a `plan` ticket with no commits is never delivered.
- A ticket is **delivered** when it reaches `StateDone`, or its Jira or Plane issue closes, **and** at least one linked commit is on a repository's default branch (`on_default_at` is set, see Data). The pull request's `merged_at` is not required, because work people do by hand has no pull request agnts knows about.
- A ticket's **delivery date** is when the *last* of these conditions became true, which is when the ticket became delivered. It decides which period the ticket counts in.
- A ticket reopened after delivery keeps its score for that delivery. When it's delivered again, it gets a new delivery number and a new score, dated at the new delivery. The earlier delivery's row stays, so a closed period doesn't change.
- **Backfill reach**: only commits commitlink has linked count, and history scans go back 90 days and 500 commits. Older tickets show as not delivered. The backfill dialog says so.

### Commits that count

Before anything else, a ticket's linked commits are cleaned:
- **Revert commits are removed.** `Revert "AMANAT-12 …"` carries the ticket's number, so commitlink links it to the ticket it reverts. Left in, it would shrink the diff and give the person who reverted a share. Reverts are handled under Quality.
- **Merge commits** (two or more parents) are kept for finding the range but earn nothing.
- **Squash commits** are found through the host's commit→pull-request lookup (GitHub `commits/{sha}/pulls`, GitLab merge request commits). A single-parent commit on the default branch that belongs to a pull request with more than one commit is a squash. Squash commits are used for the diff but earn nothing. The branch commits they replace are what earn shares.
- **Rebase merges** rewrite shas, so the same change can be linked twice: once on the branch and once on the default branch. Duplicates are collapsed by (author email, author date, subject).

### Size: one diff per repository

Adding up line counts over linked commits would count changes twice, because merge and squash commits repeat their branch commits. A wide `Compare(base, head)` would pull in other people's changes to the same files. For each repository, the first available source wins:

1. **Pull request diff**: the pull request's own diff from merge base to head, when the ticket's work reached the default branch through a pull request.
2. **Squash commit diff**: the squash commit against its parent.
3. **Commit diffs**: the per-commit diffs of the ticket's own non-merge commits on the default branch, combined. A line changed twice within the ticket counts twice. That's accepted, and it's rare for hand work without a pull request.

A ticket spanning several repositories gets **one score**, from all its repositories' diffs together.

Noise is removed from the diff before anything else: lock files, generated code (`// Code generated`, `*.pb.go`, `*.gen.*`), vendored code, snapshots and pure renames.

### Score

- **Inputs**:
  - Facts the code computes, which carry most of the weight:
    - lines changed and files and packages touched (after filtering)
    - new logic vs. modified logic
    - tests added
    - risky areas touched: concurrency, auth, money, migrations with backfill
    - number of repositories
  - The filtered diff.
  - The ticket's title and description, **as context only**. The developer often writes this text, so the prompt says to score the diff and to ignore claims in the description about difficulty.
- **Scale**: 1, 2, 3, 5, 8 or 13.

  | Points | Typical work |
  |---|---|
  | 1–2 | CRUD endpoint, field addition, copy or style change |
  | 3–5 | New feature spanning several layers, non-trivial validation, integration with an external API |
  | 8–13 | Complex domain logic, concurrency, a performance fix, a data migration with backfill, an architecture change |

- **Lines of code** are an input to the score, never the score itself, so verbose code earns nothing.
- **Large diffs**: above a budget (for example 60k characters), the prompt gets the 30 files with the most changed lines in full, plus a one-line summary per remaining file. Above a hard limit, the LLM is skipped and the score comes from the facts-only formula. The score is marked `from_facts_only`.
- **Facts-only formula**, deterministic and table-tested. A starting point, to be tuned against LLM scores once there are enough:

  | Changed lines (after filtering) | Points |
  |---|---|
  | ≤ 50 | 1 |
  | ≤ 200 | 2 |
  | ≤ 500 | 3 |
  | ≤ 1500 | 5 |
  | more | 8 |

  One step up the scale if a risky area is touched, and one step up for three or more repositories. Capped at 13. The formula is part of `prompt_version`.
- **Failures**: two retries. After that the ticket is shown as **unscored**, with the reason, and is left out of totals until it's scored.
- **Consistency**:
  - Pin the model and `prompt_version`.
  - Include a few anchor examples from the workspace's own scored history in the prompt, so scores are relative to the team. **The anchor set is frozen per version**: it's picked once, when the version is created, and stored with it. A growing history doesn't change what an existing version scores.

### Periods and rubric changes don't rewrite history

- Periods are **calendar months**. Quarters and years are sums of months.
- When a month ends, its per-developer totals are written to `period_snapshots`. The Developers tab shows the snapshot for closed months, so a review someone has already seen doesn't change under them.
- Anything that lands after a month is closed, such as an override, an identity mapping, a regression, a late score or a rescore, changes only the live view. A closed month shows **"changed since closed"** with the difference, and the owner can re-close it to take the new numbers.
- A custom `from`/`to` range that isn't whole months is always live, and is marked as such.
- Scores are stored per `prompt_version`. `prompt_versions` records when each version became current. A month is closed with the version that was current when it ended.
- After a rubric change, the owner can rescore history on demand. The new scores show next to the old ones and don't replace them.

### Who gets the points

- **agnts's commits are recognised by sha, not by author.** A new `agent_commits` table records every sha agnts pushes. Today only the last one is kept, as `ticket_repos.head_sha`.
- **Agent commits** earn points for an **agnts** row of their own (`author_key = 'agent'`). They never count toward the person who assigned or reviewed the ticket. agnts's share is worked out with the same rule and floor as people's.
- **Human commits**: the ticket's points are split between the people who wrote the ticket's cleaned commits (see Commits that count). Merge and squash commits belong to whoever merged, and earn nothing.
- **How the split works**: each author gets a share in proportion to the number of **distinct days on which they committed** to the ticket. Raw commit counts are not used, because many tiny commits would game them just as lines would. There's a floor of 20% per author for up to 4 authors, and no floor from 5 authors up, where a 20% floor would make everyone equal. Shares are normalised to 1.
- **Unknown authors**: commits whose `author_login` is empty, or whose email matches no member, go to an **Unmapped** row. The owner resolves it by mapping the identity, and the points then move to that member. In a closed month, the move shows as "changed since closed" (see Periods).

### Quality

v1 uses only signals about the developer's own work. agnts's `CIFixes`, `pr_thread_feedback` revisions and `FollowUpOf` are about the agent's work, or about follow-up ideas, and are **not used**. `FollowUpOf` means "suggested by", not "caused by".

- **Revert**: a commit on the default branch that reverts one of the ticket's commits (`This reverts commit <sha>`, or a `Revert "…"` subject that matches). The ticket's points go to 0 and the revert is shown.
- **Regression**: a new ticket relation `regression_of`.
  - Only the owner sets it. The bug's analysis can **suggest** the origin ticket, and the suggestion counts only once the owner confirms it.
  - It counts only if the bug was filed within 90 days of the origin ticket's delivery.
  - Each confirmed regression takes back 30% of the original ticket's points, down to a floor of 0.
- Both are shown as separate lines next to the points. They are never folded into the points silently.

CI failures on a developer's own pushes are left for Later. They need CI runs to be matched to the people who pushed, which the CI webhook data doesn't give yet.

### Overrides and display

- **Only the workspace owner** (and the platform admin) can see performance reviews: the Developers tab, its API and the drill-down. Members and viewers can't, and that includes their own numbers.
- The owner can override a score. The change is logged with who made it and why.
- **No single ranked leaderboard.** People optimize toward whatever is ranked.

## Data

All tables follow the workspace convention: `workspace_id … DEFAULT agnts_ws()` and the `workspace_isolation` policy, as in `00056_ticket_commits.sql`.

`migrations/00057_commit_facts.sql` (Phase 0):

```sql
ALTER TABLE ticket_commits
  ADD COLUMN author_email   text        NOT NULL DEFAULT '',
  ADD COLUMN parents        text[]      NOT NULL DEFAULT '{}',
  ADD COLUMN on_default_at  timestamptz,           -- when it was first seen on the default branch
  ADD COLUMN merge_kind     text        NOT NULL DEFAULT ''
    CHECK (merge_kind IN ('', 'merge', 'squash')),  -- '' = an ordinary commit
  ADD COLUMN pr_number      int,                   -- the pull request it reached the default branch through
  ADD COLUMN reverts        text        NOT NULL DEFAULT '';  -- sha this commit reverts, if any

CREATE TABLE agent_commits (
  workspace_id bigint NOT NULL DEFAULT agnts_ws() REFERENCES workspaces (id) ON DELETE CASCADE,
  repo_id      bigint NOT NULL REFERENCES repositories (id) ON DELETE CASCADE,
  sha          text   NOT NULL,
  ticket_id    bigint REFERENCES tickets (id) ON DELETE SET NULL,
  pushed_at    timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (repo_id, sha)
);
```

`migrations/00058_performance_review.sql`:

```sql
CREATE TABLE prompt_versions (
  workspace_id bigint NOT NULL DEFAULT agnts_ws() REFERENCES workspaces (id) ON DELETE CASCADE,
  version      text   NOT NULL,
  model        text   NOT NULL,
  anchors      jsonb  NOT NULL DEFAULT '[]',  -- frozen anchor examples
  current_from timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (workspace_id, version)
);

CREATE TABLE ticket_scores (
  workspace_id    bigint NOT NULL DEFAULT agnts_ws() REFERENCES workspaces (id) ON DELETE CASCADE,
  ticket_id       bigint NOT NULL REFERENCES tickets (id) ON DELETE CASCADE,
  delivery        int    NOT NULL DEFAULT 1,  -- 2, 3, … after a reopen
  prompt_version  text   NOT NULL,
  status          text   NOT NULL CHECK (status IN ('scored', 'unscored')),
  points          int    CHECK (points IN (1, 2, 3, 5, 8, 13)),
  from_facts_only bool   NOT NULL DEFAULT false,
  rationale       text   NOT NULL DEFAULT '',
  factors         jsonb  NOT NULL DEFAULT '{}',  -- computed diff facts + LLM factors
  error           text   NOT NULL DEFAULT '',
  model           text   NOT NULL DEFAULT '',
  delivered_at    timestamptz NOT NULL,
  scored_at       timestamptz NOT NULL DEFAULT now(),
  override_points int    CHECK (override_points IN (1, 2, 3, 5, 8, 13)),
  overridden_by   bigint REFERENCES users (id),
  override_reason text   NOT NULL DEFAULT '',
  PRIMARY KEY (ticket_id, delivery, prompt_version)
);
CREATE INDEX ticket_scores_period_idx ON ticket_scores (workspace_id, prompt_version, delivered_at);

CREATE TABLE ticket_score_authors (
  workspace_id bigint  NOT NULL DEFAULT agnts_ws() REFERENCES workspaces (id) ON DELETE CASCADE,
  ticket_id    bigint  NOT NULL REFERENCES tickets (id) ON DELETE CASCADE,
  delivery     int     NOT NULL DEFAULT 1,
  author_key   text    NOT NULL,  -- 'user:<id>', 'agent', or 'unmapped:<login or email>'
  share        numeric NOT NULL CHECK (share > 0 AND share <= 1),
  PRIMARY KEY (ticket_id, delivery, author_key)
);

CREATE TABLE member_git_identities (
  workspace_id bigint NOT NULL DEFAULT agnts_ws() REFERENCES workspaces (id) ON DELETE CASCADE,
  user_id      bigint NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  provider     text   NOT NULL,
  login        text   NOT NULL DEFAULT '',
  email        text   NOT NULL DEFAULT '',
  auto_matched bool   NOT NULL DEFAULT true,
  PRIMARY KEY (workspace_id, provider, login, email)
);
CREATE INDEX member_git_identities_login_idx ON member_git_identities (workspace_id, provider, lower(login)) WHERE login <> '';
CREATE INDEX member_git_identities_email_idx ON member_git_identities (workspace_id, lower(email)) WHERE email <> '';

CREATE TABLE ticket_regressions (
  workspace_id     bigint NOT NULL DEFAULT agnts_ws() REFERENCES workspaces (id) ON DELETE CASCADE,
  bug_ticket_id    bigint NOT NULL REFERENCES tickets (id) ON DELETE CASCADE,
  origin_ticket_id bigint NOT NULL REFERENCES tickets (id) ON DELETE CASCADE,
  status           text   NOT NULL CHECK (status IN ('suggested', 'confirmed')),
  suggested_by     text   NOT NULL DEFAULT '',  -- 'analysis' or 'user:<id>'
  confirmed_by     bigint REFERENCES users (id),
  PRIMARY KEY (bug_ticket_id, origin_ticket_id)
);

CREATE TABLE period_snapshots (
  workspace_id   bigint NOT NULL DEFAULT agnts_ws() REFERENCES workspaces (id) ON DELETE CASCADE,
  month          date   NOT NULL,  -- first day of the month
  prompt_version text   NOT NULL,
  author_key     text   NOT NULL,
  points         numeric NOT NULL,
  tickets        int    NOT NULL,
  reverts        int    NOT NULL,
  regressions    int    NOT NULL,
  unscored       int    NOT NULL,
  closed_at      timestamptz NOT NULL DEFAULT now(),
  closed_by      bigint REFERENCES users (id),  -- null when closed automatically
  PRIMARY KEY (workspace_id, month, author_key)
);

-- workspace_isolation policy on every table above
```

## Server

0. **Commit facts** (Phase 0, in `commitlink` and `vcs`):
   - `PushedCommit` gains `AuthorEmail` and `Parents`. GitHub and GitLab fill them from push webhooks and from history reads.
   - A push to the default branch sets `on_default_at` on every commit it brings, reading the rest through `Ahead(before, after)` when the payload is truncated, as `Push` already does. History scans of the default branch set it too.
   - For a single-parent commit on the default branch, the commit→pull-request lookup sets `pr_number` and decides `merge_kind = 'squash'`. Results are cached per sha. Two or more parents means `merge`.
   - `reverts` is parsed from `This reverts commit <sha>`.
   - A one-off backfill fills the new columns for links that already exist, within the same 90-day / 500-commit reach.
1. **Record agent commits**: every push agnts makes (the pushing step and CI fixes) writes its new shas to `agent_commits`.
2. **`internal/perfreview`** (its own small service, like `commitlink`):
   - `Delivered(ticket)`: is the ticket delivered, which delivery it is, and when (see Rules).
   - `Clean(commits)`: drops reverts, marks merge and squash commits, collapses rebase duplicates.
   - `Diff(ticket)`: per repository, the pull request diff, else the squash diff, else the combined commit diffs, with noise removed. It needs `Provider.PullDiff` and `Provider.CommitDiff` in `vcs`.
   - `Facts(diff)`, `FactsScore(facts)` and `Shares(commits, agentShas, identities)`: pure functions with table tests. Tests must cover squash merges, merge commits, rebase merges, a revert linked to its own ticket, a ticket spanning two repositories, five or more authors and unknown authors.
   - `Reverts(ticket)`: finds revert commits of the ticket's shas.
   - `CloseMonth(workspace, month)`: writes `period_snapshots`. Runs automatically on the first day of each month, and on demand when the owner re-closes.
3. **Scorer**: `orchestrator/score.go`, modeled on `translate.go:163`. It uses the helper model, read-only permissions, an empty container and a low turn cap. The prompt template goes in `prompts.go` with its own version, and the JSON `{points, rationale, factors[]}` is parsed like `parseAnalysis`. The anchors come from `prompt_versions.anchors`. Spend is recorded through `recordSpend`.
4. **Triggers**:
   - When a ticket becomes delivered (`StateDone`, a tracker close, or a linked commit getting `on_default_at`), enqueue a score through a bounded worker, like the commit-link backfill.
   - `BackfillScores(workspace, since)` scores historical delivered tickets. Before it runs, it shows the estimated cost (tickets × one helper call) and the 90-day reach limit, and needs the owner to confirm.
5. **Identity mapping**: auto-match git logins and emails to workspace members. The owner fixes mismatches and resolves the Unmapped row in settings.
6. **Store**:
   - `UpsertTicketScore`, `SetScoreOverride`, `SuggestRegression`, `ConfirmRegression`
   - `DeveloperTotals(workspace, from, to, promptVersion)`: points, ticket count, average points per ticket, reverts, regressions. For whole months it reads `period_snapshots` and reports the live difference.
   - `DeveloperTickets(workspace, author, from, to)`
7. **API**:
   - `GET /analytics/developers?from&to` (owner only)
   - `GET /analytics/developers/{author}/tickets` (owner only)
   - `POST /analytics/developers/months/{month}/close` (owner only, re-close)
   - `PUT /tickets/{key}/score` (owner only)
   - `PUT /tickets/{key}/regression-of` (owner only, confirms or sets)
   - `POST /analytics/developers/backfill` (owner only, returns the cost estimate first)

## Admin panel

A new **Developers** tab in `AnalyticsPage.vue` with one row per developer for the chosen month or range, plus the Unmapped row and the agnts row. Each row shows:
- delivered points (the main number)
- ticket count, kept as context only
- average points per ticket, which separates "many small" from "few hard"
- reverts and regressions, as separate numbers
- the number of unscored tickets, if there are any

A closed month shows its snapshot and, when there is one, the "changed since closed" difference with a re-close button. A custom range is marked live.

A drill-down shows each ticket's points, rationale, factors, diff source (pull request, squash or commits), author shares and any override. Suggested regressions wait for the owner to confirm them. A settings section maps git identities to members.

## Phases

0. Commit facts: author email, parents, `on_default_at`, squash detection, revert parsing and their backfill. `agent_commits` recording.
1. Delivery, cleaning, the diff, the scorer, `ticket_scores` and `prompt_versions`, delivery triggers and the backfill with a cost estimate.
2. Git identity mapping, author shares, per-developer totals, month snapshots and the Developers tab.
3. Reverts, regressions and owner overrides.

## Decisions

Settled Oct 21, 2026:

1. **Agent-written commits**: they count toward their own agnts row, not toward any person.
2. **Visibility**: only the owner, plus the platform admin. Developers don't see their own numbers in v1.
3. **When to score**: only on delivery. There is no estimate before work starts.

Settled in the second review (draft v3):

4. **Scored tickets**: by delivered commits, not by kind, except `review` and `swaggertest`.
5. **Diff source**: pull request diff, then squash diff, then combined commit diffs. No wide `Compare` across the range.
6. **Split**: by distinct commit days, with a 20% floor for up to 4 authors.
7. **Periods**: calendar months, frozen through `period_snapshots`. Later changes show as a difference and need a re-close.
8. **Regressions**: owner-confirmed only, within 90 days of delivery.

## Later

- CI failures on a developer's own pushes, once CI runs can be matched to whoever pushed.
- Credit for work outside tickets: code reviews given (`pr_posts`, git-host reviews), incident firefighting.
- Score trends per developer over time.
- Developers seeing their own numbers.
- An estimate before work starts, for sprint planning.
- Credit to people for directing the agent, such as assigning, answering its questions or reviewing its pull requests.
- Scoring tickets older than commitlink's 90-day reach, through a deeper one-off history scan.
