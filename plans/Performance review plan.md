# agnts Performance Review — Plan

Nov 4, 2026 · draft v5 (after fourth review), decisions settled, not started

## Overview

Counting closed tickets rewards volume, not difficulty. A developer who closes 10 simple CRUD tickets looks better than one who closes 3 tickets with hard logic, though the second did more. This plan gives every delivered ticket a **complexity score** and reports each developer's **delivered complexity** for a period.

For example, 10 CRUD tickets at 1 point each gives **10**, and 3 complex tickets at 8 points each gives **24**.

The numbers are input to a review the owner makes. They are never the decision itself.

What exists today (paths under `server/internal/` unless they start with `migrations/` or `apps/`; checked against master on Nov 4, 2026):
- Analysis already outputs `Complexity` = simple|complex (`orchestrator/prompts.go:44`). It's too coarse, and it's a guess made before any code exists. Today it only picks the review model.
- `ticket_commits` (`migrations/00056_ticket_commits.sql`) links people's and agnts's commits to tickets by number in branch or message, with `author_login`. It stores no line counts, no parents and no author email. `author` is a display name. `branch` is the branch a commit was *first seen on*, so a commit pushed to a feature branch and merged later still shows the feature branch. Merge commits link through their message.
- `domain.PushedCommit` (`domain/commitlink.go:18`) carries only `SHA, Message, Author, AuthorLogin, Date, URL`.
- Commit history scans stop at 90 days and 500 commits (`commitlink/commitlink.go:38`).
- `ticket_repos` (`migrations/00045_repo_groups.sql`) holds one row per repository of a ticket. `merged_at` is set only for pull requests agnts opened or tracks (`orchestrator/pullreview.go`).
- agnts's commits can be authored as a person (`AGNTS_GIT_AUTHOR_NAME`/`_EMAIL`, `config/config.go:40`). So commit authorship alone can't tell agent work from human work.
- Analytics (`httpapi/analytics.go`, `store/postgres/analytics_tabs.go`, `apps/admin/src/pages/AnalyticsPage.vue`) is workspace- or repo-wide. Nothing is broken down per developer.
- Tickets have no story points, estimates or labels.
- Kind `bug` means "find a bug's root cause, change nothing" (`domain/kind.go:13`), so the kind doesn't say whether code was delivered.
- **Tickets have no state history.** Nothing records when a ticket reached `StateDone`, when its tracker issue closed, or when it was reopened. `tickets.closed_at` (`migrations/00039_ticket_closed_at.sql`) only means an agnts pull request was closed unmerged.
- **Tracker closes aren't read.** The Jira webhook (`tracker/jira/webhook.go`) only ingests issues that carry the agnts label, and doesn't look at status or resolution. Plane counts both `completed` and `cancelled` as closed (`tracker/plane/tracker.go:130`). Jira's `statusCategory = Done` also covers resolutions like "Won't Do".
- **Every Claude call belongs to a run or a document run.** Since `migrations/00060_documents.sql`, `claude_calls.run_id` and `ticket_id` are nullable, but `claude_calls_owner_check` requires exactly one of `run_id` and `document_run_id`. `RecordClaudeCall` (`store/postgres/spend.go:13`) takes the ticket from `runs`. `spendTo` (`orchestrator/orchestrator.go:231`) sends a call to the run or the document run. Credits are settled per run (`billing.Settle`) or per document run (`billing.SettleDocument`), with one `credit_ledger` row each (`reason` `run` or `document`). Calls outside both, like translation, record only rate-limit usage today.
- `ticket_relations` (`migrations/00018_ticket_relations.sql`) already holds relations between tickets with a source and a `proposed`/`active`/`dismissed` status, keyed by ticket `key`. The queue's queries (`blockersSQL`, `unblocksSQL` in `store/postgres/relations.go`) already filter to `depends_on` and `conflicts`. **`ReplaceFound` (`relations.go:122`) deletes every relation a ticket's analysis found with `source IN ('agnts', 'rule')` that isn't dismissed, and `DecideRelation` keeps the source.** So re-analysing a ticket today deletes agnts relations the owner already confirmed.
- The last migration is `00086_avatars.sql`.

## Rules

### Which tickets are scored

- Any ticket with delivered linked commits, **except** kinds `review` and `swaggertest`, and `SourceGit` pull-request reviews. The kind isn't used beyond that: a `bug` ticket that a person fixed by hand is scored on the fix, and a `plan` ticket with no commits is never delivered.
- A ticket is **delivered** when it reaches `StateDone`, or its Jira or Plane issue is **resolved as done**, **and** at least one linked commit is on a repository's default branch (`on_default_at` is set, see Data). The pull request's `merged_at` is not required, because work people do by hand has no pull request agnts knows about.
- **Resolved as done** means:
  - Plane: state group `completed`. `cancelled` never delivers.
  - Jira: `statusCategory = Done` **and** a resolution that isn't in the workspace's "not done" list. The list defaults to `Won't Do`, `Won't Fix`, `Duplicate`, `Cannot Reproduce`, `Declined` and `Incomplete`, and the owner can edit it in the feature's settings. An issue in a Done status with no resolution counts as done.
  - A ticket rejected in agnts (`StateRejected`) never delivers, even if its tracker issue closes as done.
- A ticket's **delivery date** is when the *last* of these conditions became true, which is when the ticket became delivered. It decides which period the ticket counts in. Deliveries are recorded in `ticket_deliveries` as they happen, since tickets have no state history to read them from later.
- A ticket reopened after delivery keeps its score for that delivery, and its `ticket_deliveries` row gets `undelivered_at`. When it's delivered again, it gets a new delivery number and a new score, dated at the new delivery. **A delivery's commits are those whose `on_default_at` is later than the previous delivery's `delivered_at`** (all of them for the first delivery). The time a commit was *linked* is never used, because a late history scan or the backfill can link old commits after a delivery. The same rule picks the diff sources (see Size), so the same work never earns twice. A redelivery with no new commits gets a row with 0 points. The earlier delivery's row stays, so a closed period doesn't change.
- **Backfill reach**: only commits commitlink has linked count, and history scans go back 90 days and 500 commits. Older tickets show as not delivered. The backfill dialog says so. The same reach applies when a missed webhook is made up by a later history scan, so a long webhook outage can leave tickets undelivered. The Developers tab says so when commitlink reports a gap.

### Linking default-branch commits

A squash or rebase commit on the default branch may not carry the ticket's number. Its pull request title may lack it too, even when the branch commits were linked by branch name (`feature/AMANAT-12`). Left alone, nothing linked would ever get `on_default_at`, and the ticket would never be delivered.

So for every commit on the default branch, commitlink also runs the host's commit→pull-request lookup (GitHub `commits/{sha}/pulls`, GitLab merge request commits). When the pull request's head branch or title matches a ticket, the commit is linked to that ticket with `matched_on = {'pull_request'}`. Results are cached per sha.

### Commits that count

Before anything else, a ticket's linked commits are cleaned:
- **Revert commits are removed.** `Revert "AMANAT-12 …"` carries the ticket's number, so commitlink links it to the ticket it reverts. Left in, it would shrink the diff and give the person who reverted a share. Reverts are handled under Quality.
- **Merge commits** (two or more parents) are kept for finding the range but earn nothing.
- **Squash commits** are found through the commit→pull-request lookup. A single-parent commit on the default branch whose pull request was merged by squash is a squash commit: either its pull request had more than one commit, or its one commit's sha differs from the default-branch sha. That rule includes a squash of a one-commit pull request. Squash commits are used for the diff but earn nothing.
- **A squash's pull-request commits are what earn shares**, and they're read from the host (GitHub `pulls/{n}/commits`, GitLab merge request commits), not from `ticket_commits`. Only the squash commit may be linked: when the ticket's number is only in the pull request title, none of the branch commits carry it. Left to `ticket_commits`, such a ticket would have no one to credit. The pull-request commits are stored in `pull_request_commits` (see Data), with author email, author date and parents, and cached per pull request. They count for authorship only; the diff still comes from the pull request (see Size).
- **Rebase merges** rewrite shas, so the same change can be linked twice: once on the branch and once on the default branch. Duplicates are collapsed by (author email, author date, subject), including against `pull_request_commits`. A squash of a one-commit pull request isn't caught by this, because the host appends ` (#123)` to the subject and changes the date. The squash rule above catches it.

### Size: one diff per repository

Adding up line counts over linked commits would count changes twice, because merge and squash commits repeat their branch commits. A wide `Compare(base, head)` would pull in other people's changes to the same files. For each repository, the first available source wins:

1. **Pull request diff**: the pull request's own diff from merge base to head, when the ticket's work reached the default branch through a pull request.
2. **Squash commit diff**: the squash commit against its parent.
3. **Commit diffs**: the per-commit diffs of the ticket's own non-merge commits on the default branch, combined. A line changed twice within the ticket counts twice. That's accepted, and it's rare for hand work without a pull request.

On a redelivery, only pull requests, squash commits and commits whose `on_default_at` is later than the previous delivery are used.

A ticket spanning several repositories gets **one score**, from all its repositories' diffs together.

Noise is removed from the diff before anything else: lock files, generated code (`// Code generated`, `*.pb.go`, `*.gen.*`), vendored code, snapshots and pure renames.

### Score

- **Inputs**:
  - Facts the code computes, which carry most of the weight:
    - lines changed and files and packages touched (after filtering)
    - new logic vs. modified logic
    - tests added
    - risky areas touched: concurrency, auth, money, migrations with backfill. These are found by the code (paths, imports and patterns such as `sync.`, `go func`, `FOR UPDATE`, auth and billing packages, migrations with `UPDATE`/`INSERT … SELECT`), never by the LLM.
    - number of repositories
  - The filtered diff.
  - The ticket's title and description, **as context only**. The developer often writes this text, so the prompt says to score the diff and to ignore claims about difficulty in the description, and in comments or strings in the diff.
- **Scale**: 1, 2, 3, 5, 8 or 13.

  | Points | Typical work |
  |---|---|
  | 1–2 | CRUD endpoint, field addition, copy or style change |
  | 3–5 | New feature spanning several layers, non-trivial validation, integration with an external API |
  | 8–13 | Complex domain logic, concurrency, a performance fix, a data migration with backfill, an architecture change |

- **Lines of code** are an input to the score, never the score itself. Verbose code earns nothing: the LLM may score a large diff as low as it judges.
- **The facts bound the LLM from above only.** Line count says little about how hard a change was, so it can't be both the floor and the ceiling:
  - **Down**: the LLM may go as low as 1, whatever the facts say. 1,500 lines of boilerplate can score 1.
  - **Up**: the LLM may go at most **one** scale step above `FactsScore(facts)`, or **three** steps when a risky area is touched. A 40-line concurrency fix has a facts score of 2 (1 for its size, plus one step for the risky area), so it can reach 8. A small change with no risky area can reach only one step above its size.
  - When the LLM wanted to go higher, the score is marked `clamped`, and the LLM's own answer is kept in `factors`.
  - The upper bound is what makes gaming the text, or a prompt injection in the diff, limited: text alone can't lift a score past what the code's facts allow, and the risky-area facts come from code the developer actually changed.
- **Large diffs**: above a budget (for example 60k characters), the prompt gets the 30 files with the most changed lines in full, plus a one-line summary per remaining file. Above a hard limit, the LLM is skipped and the score comes from the facts-only formula. The score is marked `from_facts_only`.
- **Facts-only formula**, deterministic and table-tested. It's the score when the LLM is skipped, and the base of the LLM's upper bound. A starting point, to be tuned against LLM scores once there are enough:

  | Changed lines (after filtering) | Points |
  |---|---|
  | ≤ 50 | 1 |
  | ≤ 200 | 2 |
  | ≤ 500 | 3 |
  | ≤ 1500 | 5 |
  | more | 8 |

  One step up the scale if a risky area is touched, and one step up for three or more repositories. Capped at 13. The formula and the clamp's step counts are part of `prompt_version`.
- **Failures**: two retries. After that the ticket is shown as **unscored**, with the reason, and is left out of totals until it's scored.
- **Consistency**:
  - Pin the model and `prompt_version`.
  - Include a few anchor examples in the prompt, so scores are relative to the team. **The anchor set is frozen per version**: it's picked once, when the version is created, and stored with it. A growing history doesn't change what an existing version scores.
  - **The first version uses built-in seed anchors**: about six synthetic examples spanning the scale, shipped with the prompt, because a new workspace has no scored history. The seeds include a small risky change scored high and a large boilerplate change scored low, so the LLM sees both ends of the clamp. Later versions pick anchors from the workspace's own scored, non-overridden tickets, one or two per scale step, and fall back to the seeds for steps with none.

### Periods and rubric changes don't rewrite history

- Periods are **calendar months**. Quarters and years are sums of months.
- When a month ends, its per-developer totals are written to `period_snapshots`. The Developers tab shows the snapshot for closed months, so a review someone has already seen doesn't change under them.
- **A month closes automatically after a grace period**: on the 3rd day of the next month (workspace timezone), or later while any of the month's deliveries are still waiting to be scored or retried, up to the 10th. Deliveries late in the month are often scored after midnight, and closing on the 1st would mark most months "changed since closed" straight away. A month that reaches the 10th with unscored tickets closes anyway, and shows them as unscored. Until it closes, the month is shown as live and "closing on …". The owner can close a month early.
- Anything that lands after a month is closed, such as an override, an identity mapping, a regression, a late score or a rescore, changes only the live view. A closed month shows **"changed since closed"** with the difference, and the owner can re-close it to take the new numbers.
- **Re-closing adds a snapshot and keeps the earlier ones** (`closing` 1, 2, …). The tab shows the latest, and the drill-down can show what an earlier closing said.
- A custom `from`/`to` range that isn't whole months is always live, and is marked as such.
- Scores are stored per `prompt_version`. `prompt_versions` records when each version became current. A month is closed with the version that was current when it ended.
- After a rubric change, the owner can rescore history on demand. The new scores show next to the old ones and don't replace them.
- **Months, delivery dates and commit days use the workspace's timezone** (see Who gets the points).

### Who gets the points

- **agnts's commits are recognised by sha, not by author.** A new `agent_commits` table records every sha agnts pushes. Today only the last one is kept, as `ticket_repos.head_sha`.
- **Agent commits** earn points for an **agnts** row of their own (`author_key = 'agent'`). They never count toward the person who assigned or reviewed the ticket. agnts's share is worked out with the same rule and floor as people's.
- **Human commits**: the ticket's points are split between the people who wrote the ticket's cleaned commits (see Commits that count), including a squash's pull-request commits. Merge and squash commits earn nothing. On GitHub a squash commit's author is the pull request's author, not whoever merged; it makes no difference, because the commit earns nothing.
- **How the split works**: each author's weight is the number of **distinct days on which they committed** to the ticket. Raw commit counts are not used, because many tiny commits would game them just as lines would.
  - A day is a calendar day in the **workspace's timezone**, from the commit's author date. The author's own offset in the commit isn't used: it's set by the developer's machine, and two people on the same day in different zones would otherwise split it differently. Rebases keep the author date, so they don't move a day.
  - With 2 to 4 authors there's a **floor of 20%** per author. Normalising after raising someone to the floor would push them back under it (9 days and 1 day gives 0.9/0.1; raising to 0.2 and normalising gives 0.18). So the floor is applied like this:
    1. Compute proportional shares.
    2. Every author under 20% gets exactly 20%.
    3. The remainder is split in proportion between the other authors.
    4. Repeat until no one is under the floor.
  - From 5 authors up there's no floor, because a 20% floor would make everyone equal.
- **Unknown authors**: commits whose `author_login` is empty, or whose email matches no member, go to an **Unmapped** row. The owner resolves it by mapping the identity, and the points then move to that member. In a closed month, the move shows as "changed since closed" (see Periods).

### Quality

v1 uses only signals about the developer's own work. agnts's `CIFixes`, `pr_thread_feedback` revisions and `FollowUpOf` are about the agent's work, or about follow-up ideas, and are **not used**. `FollowUpOf` means "suggested by", not "caused by".

Penalties are kept as decimals, like shares. Only a ticket's score is on the scale; the points left after penalties aren't rounded to it. Totals are already decimal because of shares.

- **Revert**: a commit on the default branch that reverts one of the ticket's commits (`This reverts commit <sha>`, or a `Revert "…"` subject that matches).
  - The ticket loses the same share of its points as the share of its scored changed lines that were reverted, with no rounding. Reverting one small commit out of twelve (1/12 of the lines) on an 8-point ticket leaves 7.33. A full revert takes it to 0.
  - A **revert of a revert** (a re-land) cancels the first revert. The ticket gets its points back, and both commits are shown.
  - The penalty is applied to the ticket's own delivery, so a revert in a later month shows in the delivery month as "changed since closed".
- **Regression**: a `regression_of` type in `ticket_relations`, from the bug ticket to the origin ticket. It doesn't hold the queue.
  - Only the owner sets it. The bug's analysis can **propose** the origin ticket (`source = 'agnts'`, always `status = 'proposed'`, never inserted as `active` whatever its confidence), and the suggestion counts only once the owner makes it `active`.
  - **A confirmed regression survives re-analysis.** `ReplaceFound` skips relations of type `regression_of` that are `active` or `dismissed`, so analysing the bug again neither deletes a confirmed regression nor brings back a dismissed one. Confirming records `decided_by` and keeps `source = 'agnts'`, so it's still clear the suggestion came from analysis.
  - It counts only if the bug was filed within 90 days of the origin ticket's delivery, read from `ticket_deliveries`.
  - Each confirmed regression takes back 30% of the original ticket's points, down to a floor of 0. An 8-point ticket with one regression keeps 5.6.
  - When a ticket has both, the revert is applied first and each regression takes 30% of the points that are left.
- Both are shown as separate lines next to the points. They are never folded into the points silently.

CI failures on a developer's own pushes are left for Later. They need CI runs to be matched to the people who pushed, which the CI webhook data doesn't give yet.

### Overrides and display

- **Only the workspace owner** (and the platform admin) can see performance reviews: the Developers tab, its API and the drill-down. Members and viewers can't see them in the app, and that includes their own numbers.
- **A developer's right of access is still met.** Under GDPR Article 15 a developer may ask for the data held about them. The owner can export one member's data from the drill-down: their per-ticket points, shares, rationales, factors, penalties and overrides, and their rows in every month snapshot, as JSON and CSV. The tab says the export exists, and that the owner must answer such requests.
- The owner can override a score. The change is logged with who made it and why.
- **No single ranked leaderboard.** People optimize toward whatever is ranked.
- The tab says the numbers are input to the owner's review, not a verdict. Automated scoring of employees falls under GDPR Article 22 and, in some countries, needs a works council's agreement, so a workspace should check before turning the feature on. It's **off by default** in workspace settings.

### Spend

Scoring is a Claude call with no run and no document, so it gets an owner of its own: a **score run**, one per scoring attempt, recorded in `score_runs`.

- `claude_calls` gains `score_run_id`, and `claude_calls_owner_check` becomes "exactly one of `run_id`, `document_run_id` and `score_run_id`". The call's `ticket_id` is set from the score run.
- A score run uses the workspace's own Claude connection when it has one, and the workspace's credits otherwise, chosen the way a run's helper stages choose today. It never uses a member's personal connection, because no member asked for it. The connection and `on_credits` are recorded on the score run.
- When a score run on credits ends (scored or failed), `billing.SettleScore` writes one `credit_ledger` row with `reason = 'score'` and the score run's id, like `SettleDocument` does for documents.
- The backfill's cost estimate uses the same price as one score run, and the backfill is refused when the workspace's credits can't cover the estimate.

## Data

All tables follow the workspace convention: `workspace_id … DEFAULT agnts_ws()` and the `workspace_isolation` policy, as in `00056_ticket_commits.sql`. Migration numbers are the next free ones when work starts. 00087 and 00088 are free today.

`migrations/00087_commit_facts.sql` (Phase 0):

```sql
ALTER TABLE ticket_commits
  ADD COLUMN author_email   text        NOT NULL DEFAULT '',
  ADD COLUMN parents        text[]      NOT NULL DEFAULT '{}',
  ADD COLUMN on_default_at  timestamptz,           -- when it was first seen on the default branch
  ADD COLUMN merge_kind     text        NOT NULL DEFAULT ''
    CHECK (merge_kind IN ('', 'merge', 'squash')),  -- '' = an ordinary commit
  ADD COLUMN pr_number      int,                   -- the pull request it reached the default branch through
  ADD COLUMN reverts        text        NOT NULL DEFAULT '';  -- sha this commit reverts, if any
-- matched_on may now also hold 'pull_request' (see Linking default-branch commits)

-- The commits of a squashed pull request, read from the host: they earn
-- the shares, and may not be linked to the ticket themselves.
CREATE TABLE pull_request_commits (
  workspace_id bigint NOT NULL DEFAULT agnts_ws() REFERENCES workspaces (id) ON DELETE CASCADE,
  repo_id      bigint NOT NULL REFERENCES repositories (id) ON DELETE CASCADE,
  pr_number    int    NOT NULL,
  sha          text   NOT NULL,
  author_email text   NOT NULL DEFAULT '',
  author_login text   NOT NULL DEFAULT '',
  authored_at  timestamptz NOT NULL,
  parents      text[] NOT NULL DEFAULT '{}',
  subject      text   NOT NULL DEFAULT '',
  PRIMARY KEY (repo_id, pr_number, sha)
);

CREATE TABLE agent_commits (
  workspace_id bigint NOT NULL DEFAULT agnts_ws() REFERENCES workspaces (id) ON DELETE CASCADE,
  repo_id      bigint NOT NULL REFERENCES repositories (id) ON DELETE CASCADE,
  sha          text   NOT NULL,
  ticket_id    bigint REFERENCES tickets (id) ON DELETE SET NULL,
  pushed_at    timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (repo_id, sha)
);

-- When each delivery happened; tickets have no state history to read it from.
CREATE TABLE ticket_deliveries (
  workspace_id   bigint NOT NULL DEFAULT agnts_ws() REFERENCES workspaces (id) ON DELETE CASCADE,
  ticket_id      bigint NOT NULL REFERENCES tickets (id) ON DELETE CASCADE,
  delivery       int    NOT NULL,             -- 1, then 2, 3, … after a reopen
  delivered_at   timestamptz NOT NULL,        -- when the last condition became true
  undelivered_at timestamptz,                 -- set when the ticket is reopened
  PRIMARY KEY (ticket_id, delivery)
);
CREATE INDEX ticket_deliveries_period_idx ON ticket_deliveries (workspace_id, delivered_at);

-- How a ticket's tracker issue was last resolved, so "resolved as done" can be read.
ALTER TABLE tickets
  ADD COLUMN tracker_done_at timestamptz,  -- set when the issue is resolved as done, cleared on reopen
  ADD COLUMN tracker_resolution text NOT NULL DEFAULT '';
```

`migrations/00088_performance_review.sql`:

```sql
CREATE TABLE prompt_versions (
  workspace_id bigint NOT NULL DEFAULT agnts_ws() REFERENCES workspaces (id) ON DELETE CASCADE,
  version      text   NOT NULL,
  model        text   NOT NULL,
  anchors      jsonb  NOT NULL DEFAULT '[]',  -- frozen anchor examples (seeds for the first version)
  current_from timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (workspace_id, version)
);

-- One scoring attempt: the owner of its Claude calls and of its credit charge.
CREATE TABLE score_runs (
  id             bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  workspace_id   bigint NOT NULL DEFAULT agnts_ws() REFERENCES workspaces (id) ON DELETE CASCADE,
  ticket_id      bigint NOT NULL REFERENCES tickets (id) ON DELETE CASCADE,
  delivery       int    NOT NULL,
  prompt_version text   NOT NULL,
  status         text   NOT NULL DEFAULT 'queued' CHECK (status IN ('queued', 'scoring', 'done', 'failed')),
  connection_id  bigint REFERENCES claude_connections (id) ON DELETE SET NULL,
  on_credits     bool   NOT NULL DEFAULT false,
  created_at     timestamptz NOT NULL DEFAULT now(),
  finished_at    timestamptz,
  FOREIGN KEY (ticket_id, delivery) REFERENCES ticket_deliveries (ticket_id, delivery) ON DELETE CASCADE
);

ALTER TABLE claude_calls
  ADD COLUMN score_run_id bigint REFERENCES score_runs (id) ON DELETE CASCADE,
  DROP CONSTRAINT claude_calls_owner_check,
  ADD CONSTRAINT claude_calls_owner_check
    CHECK (num_nonnulls(run_id, document_run_id, score_run_id) = 1);
CREATE INDEX claude_calls_score_run_idx ON claude_calls (score_run_id) WHERE score_run_id IS NOT NULL;

ALTER TABLE credit_ledger
  ADD COLUMN score_run_id bigint REFERENCES score_runs (id) ON DELETE SET NULL,
  DROP CONSTRAINT credit_ledger_reason_check,
  ADD CONSTRAINT credit_ledger_reason_check CHECK (reason IN ('purchase', 'run', 'document', 'score', 'refund', 'grant'));
CREATE UNIQUE INDEX credit_ledger_score_run_idx ON credit_ledger (score_run_id) WHERE reason = 'score';

CREATE TABLE ticket_scores (
  workspace_id    bigint NOT NULL DEFAULT agnts_ws() REFERENCES workspaces (id) ON DELETE CASCADE,
  ticket_id       bigint NOT NULL,
  delivery        int    NOT NULL,
  prompt_version  text   NOT NULL,
  status          text   NOT NULL CHECK (status IN ('scored', 'unscored')),
  points          int    CHECK (points IN (0, 1, 2, 3, 5, 8, 13)),  -- 0: a redelivery with no new commits
  from_facts_only bool   NOT NULL DEFAULT false,
  clamped         bool   NOT NULL DEFAULT false,  -- the LLM's answer was above the facts' upper bound
  rationale       text   NOT NULL DEFAULT '',
  factors         jsonb  NOT NULL DEFAULT '{}',   -- computed diff facts, LLM factors and its unclamped answer
  error           text   NOT NULL DEFAULT '',
  model           text   NOT NULL DEFAULT '',
  score_run_id    bigint REFERENCES score_runs (id) ON DELETE SET NULL,  -- the attempt that produced it
  scored_at       timestamptz NOT NULL DEFAULT now(),
  override_points int    CHECK (override_points IN (0, 1, 2, 3, 5, 8, 13)),
  overridden_by   bigint REFERENCES users (id),
  override_reason text   NOT NULL DEFAULT '',
  PRIMARY KEY (ticket_id, delivery, prompt_version),
  FOREIGN KEY (ticket_id, delivery) REFERENCES ticket_deliveries (ticket_id, delivery) ON DELETE CASCADE
);
CREATE INDEX ticket_scores_version_idx ON ticket_scores (workspace_id, prompt_version);

CREATE TABLE ticket_score_authors (
  workspace_id bigint  NOT NULL DEFAULT agnts_ws() REFERENCES workspaces (id) ON DELETE CASCADE,
  ticket_id    bigint  NOT NULL,
  delivery     int     NOT NULL,
  author_key   text    NOT NULL,  -- 'user:<id>', 'agent', or 'unmapped:<login or email>'
  share        numeric NOT NULL CHECK (share > 0 AND share <= 1),
  PRIMARY KEY (ticket_id, delivery, author_key),
  FOREIGN KEY (ticket_id, delivery) REFERENCES ticket_deliveries (ticket_id, delivery) ON DELETE CASCADE
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
-- One login or email belongs to one member.
CREATE UNIQUE INDEX member_git_identities_login_idx ON member_git_identities (workspace_id, provider, lower(login)) WHERE login <> '';
CREATE UNIQUE INDEX member_git_identities_email_idx ON member_git_identities (workspace_id, lower(email)) WHERE email <> '';

-- Regressions are a relation type; proposed = suggested by analysis, active = confirmed by the owner.
ALTER TABLE ticket_relations DROP CONSTRAINT ticket_relations_type_check,
  ADD CONSTRAINT ticket_relations_type_check CHECK (type IN ('depends_on', 'conflicts', 'regression_of'));
ALTER TABLE ticket_relations ADD COLUMN decided_by bigint REFERENCES users (id) ON DELETE SET NULL;

CREATE TABLE period_snapshots (
  workspace_id   bigint NOT NULL DEFAULT agnts_ws() REFERENCES workspaces (id) ON DELETE CASCADE,
  month          date   NOT NULL,  -- first day of the month, in the workspace's timezone
  closing        int    NOT NULL DEFAULT 1,  -- 2, 3, … after a re-close; earlier closings are kept
  prompt_version text   NOT NULL,
  author_key     text   NOT NULL,
  points         numeric NOT NULL,
  tickets        int    NOT NULL,
  reverts        int    NOT NULL,
  regressions    int    NOT NULL,
  unscored       int    NOT NULL,
  closed_at      timestamptz NOT NULL DEFAULT now(),
  closed_by      bigint REFERENCES users (id),  -- null when closed automatically
  PRIMARY KEY (workspace_id, month, closing, author_key)
);

-- workspace_isolation policy on every new table above; claude_calls' agnts_fill_ws
-- already takes the workspace from ticket_id, which score runs set.
```

The feature's settings (on/off, the Jira "not done" resolutions) live in workspace settings, next to the other feature switches.

## Server

0. **Commit facts and tracker resolution** (Phase 0, in `commitlink`, `vcs` and `tracker`):
   - `PushedCommit` gains `AuthorEmail` and `Parents`. GitHub and GitLab fill them from push webhooks and from history reads.
   - A push to the default branch sets `on_default_at` on every commit it brings, reading the rest through `Ahead(before, after)` when the payload is truncated, as `Push` already does. History scans of the default branch set it too.
   - For every single-parent commit on the default branch, the commit→pull-request lookup (`Provider.CommitPulls` in `vcs`, cached per sha) sets `pr_number`, decides `merge_kind = 'squash'` (see Commits that count), and links the commit to the ticket of the pull request's head branch or title when the commit isn't linked yet. Two or more parents means `merge`.
   - For a squash commit, `Provider.PullCommits` reads the pull request's commits into `pull_request_commits`, once per pull request.
   - `reverts` is parsed from `This reverts commit <sha>`.
   - **Tracker resolution**: the Jira webhook and reconcile read `status.statusCategory` and `resolution` of every issue agnts already has a ticket for, not only labelled ones (an issue whose label was removed after it was ingested still counts). Plane reads the state group. Both set `tickets.tracker_done_at` and `tracker_resolution` when the issue is resolved as done (see Which tickets are scored), and clear `tracker_done_at` when it's reopened or resolved otherwise. For the backfill, the close date is Jira's `resolutiondate` and Plane's `completed_at`.
   - A one-off backfill fills the new columns for links that already exist, within the same 90-day / 500-commit reach, and fills `tracker_done_at` for tickets whose issue is resolved as done today.
1. **Record agent commits**: every push agnts makes (the pushing step and CI fixes) writes its new shas to `agent_commits`.
2. **Record deliveries**: when a ticket reaches `StateDone`, its `tracker_done_at` is set, or one of its commits gets `on_default_at`, check the conditions. When all of them hold and there's no open delivery, insert the next `ticket_deliveries` row, dated at the event that completed them. A reopen (leaving `StateDone`, or `tracker_done_at` being cleared) sets `undelivered_at` on the open delivery. A ticket that reaches `StateRejected` is never delivered. The Phase 1 backfill derives first deliveries for existing tickets from the latest of `on_default_at` and `tracker_done_at`, which is the best available.
3. **`internal/perfreview`** (its own small service, like `commitlink`):
   - `Delivered(ticket)`: the ticket's open delivery from `ticket_deliveries`, and which commits belong to it: those with `on_default_at` later than the previous delivery's `delivered_at`.
   - `Clean(commits, prCommits)`: drops reverts, marks merge and squash commits, swaps each squash for its pull-request commits as earners, and collapses rebase duplicates.
   - `Diff(ticket, delivery)`: per repository, the pull request diff, else the squash diff, else the combined commit diffs, limited to the delivery's commits, with noise removed. It needs `Provider.PullDiff` and `Provider.CommitDiff` in `vcs`.
   - `Facts(diff)`, `FactsScore(facts)`, `Clamp(llm, facts)`, `Shares(commits, agentShas, identities, tz)` and `Penalties(points, revertedShare, regressions)`: pure functions with table tests. Tests must cover:
     - squash merges, including one-commit pull requests
     - a squash whose branch commits aren't linked to the ticket (number only in the pull request title)
     - merge commits and rebase merges
     - a revert linked to its own ticket
     - a ticket spanning two repositories
     - a redelivery after a reopen, including an old commit linked late by a history scan
     - the floor, including 9 days against 1
     - five or more authors, and unknown authors
     - commit days across a timezone boundary
     - the clamp: a large diff scored low, a small risky diff scored 8, a small non-risky diff clamped
     - a 1/12 revert on an 8-point ticket (7.33), and a revert plus a regression
     - Jira "Won't Do" and Plane `cancelled` never delivering
   - `Reverts(ticket)`: finds revert commits of the ticket's shas, and the share of the ticket's scored lines they undo, with re-lands cancelling them.
   - `CloseMonth(workspace, month)`: writes the next `closing` of `period_snapshots`. Runs automatically once the grace period ends (see Periods), checked daily, and on demand when the owner closes early or re-closes.
   - `Export(workspace, member)`: one member's data for a right-of-access request (see Overrides and display).
4. **Scorer**: `orchestrator/score.go`, modeled on `translateBatch` (`orchestrator/translate.go:259`). It creates a `score_runs` row, picks the connection (see Spend), and uses the helper model, read-only permissions and a low turn cap. Like translation, it writes its input (facts, filtered diff, ticket text and anchors) to a file in the workspace and reads its JSON answer `{points, rationale, factors[]}` from another, parsed like `parseAnalysis` (`orchestrator/prompts.go:1675`). The anchors come from `prompt_versions.anchors`. Spend goes to `claude_calls` with `score_run_id` and `model_stage = 'score'`: `domain.ClaudeCall` gains `ScoreRunID`, `spendTo` sends such calls to a new `RecordScoreCall`, and the score run is settled when it ends.
5. **Triggers**:
   - When a delivery is recorded, enqueue a score through a bounded worker, like the commit-link backfill.
   - `BackfillScores(workspace, since)` scores historical delivered tickets. Before it runs, it shows the estimated cost (tickets × one score run) and the 90-day reach limit, and needs the owner to confirm. It's refused when the workspace's credits can't cover the estimate and the workspace has no connection of its own.
6. **Identity mapping**: auto-match git logins and emails to workspace members. The owner fixes mismatches and resolves the Unmapped row in settings. A login or email already mapped to another member can't be mapped again until it's moved.
7. **Relations**: `ReplaceFound` leaves out relations of type `regression_of` that are `active` or `dismissed`. Analysis always inserts `regression_of` as `proposed`. Confirming sets `decided_by`.
8. **Store**:
   - `RecordDelivery`, `RecordUndelivery`
   - `CreateScoreRun`, `FinishScoreRun`, `RecordScoreCall`
   - `UpsertTicketScore`, `SetScoreOverride`, `ProposeRegression`, `ConfirmRegression` (on `ticket_relations`)
   - `DeveloperTotals(workspace, from, to, promptVersion)`: points after penalties, ticket count, average points per ticket, reverts, regressions. For whole closed months it reads the latest closing in `period_snapshots` and reports the live difference.
   - `DeveloperTickets(workspace, author, from, to)`
   - `MemberExport(workspace, member)`
9. **Billing**: `billing.SettleScore(ws, scoreRunID)`, like `SettleDocument`, writes one `credit_ledger` row with `reason = 'score'` for a score run on credits.
10. **API**:
    - `GET /analytics/developers?from&to` (owner only)
    - `GET /analytics/developers/{author}/tickets` (owner only)
    - `GET /analytics/developers/{author}/export?format=json|csv` (owner only, right of access)
    - `POST /analytics/developers/months/{month}/close` (owner only, close early or re-close)
    - `PUT /tickets/{key}/score` (owner only)
    - `PUT /tickets/{key}/regression-of` (owner only, confirms or sets)
    - `POST /analytics/developers/backfill` (owner only, returns the cost estimate first)

## Admin panel

A new **Developers** tab in `AnalyticsPage.vue`, shown only when the feature is on. It has one row per developer for the chosen month or range, plus the Unmapped row and the agnts row. Each row shows:
- delivered points after penalties (the main number)
- ticket count, kept as context only
- average points per ticket, which separates "many small" from "few hard"
- reverts and regressions, as separate numbers
- the number of unscored tickets, if there are any

A closed month shows its latest snapshot and, when there is one, the "changed since closed" difference with a re-close button. Earlier closings can be opened from there. A month in its grace period shows as live, with the date it will close and a "close now" button. A custom range is marked live. A note says the numbers are input to a review, not a verdict, and warns when commitlink reports a gap in webhooks.

A drill-down shows each ticket's points, rationale, factors, diff source (pull request, squash or commits), delivery number, whether the score was clamped, author shares, revert and regression penalties, and any override. It also has the member's export. Proposed regressions wait for the owner to confirm them. A settings section turns the feature on, edits the Jira "not done" resolutions and maps git identities to members.

## Phases

0. Commit facts: author email, parents, `on_default_at`, squash detection, pull-request commits, linking default-branch commits through their pull request, revert parsing and their backfill. Tracker resolution (`tracker_done_at`) for Jira and Plane. `agent_commits` recording. `ticket_deliveries` recording, so deliveries are dated from the start.
1. Delivery, cleaning, the diff, the scorer with the upper-bound clamp and seed anchors, score runs with their spend and credit settlement, `ticket_scores` and `prompt_versions`, delivery triggers and the backfill with a cost estimate.
2. Git identity mapping, author shares in the workspace's timezone, per-developer totals, month snapshots with the grace period, the feature setting, the Developers tab and the member export.
3. Reverts, regressions (including the `ReplaceFound` change) and owner overrides.

## Decisions

Settled Oct 21, 2026:

1. **Agent-written commits**: they count toward their own agnts row, not toward any person.
2. **Visibility**: only the owner, plus the platform admin. Developers don't see their own numbers in the app in v1.
3. **When to score**: only on delivery. There is no estimate before work starts.

Settled in the second review (draft v3):

4. **Scored tickets**: by delivered commits, not by kind, except `review` and `swaggertest`.
5. **Diff source**: pull request diff, then squash diff, then combined commit diffs. No wide `Compare` across the range.
6. **Split**: by distinct commit days, with a 20% floor for up to 4 authors.
7. **Periods**: calendar months, frozen through `period_snapshots`. Later changes show as a difference and need a re-close.
8. **Regressions**: owner-confirmed only, within 90 days of delivery.

Settled in the third review (draft v4, Oct 28, 2026):

9. **Deliveries are recorded as they happen** in `ticket_deliveries`, because tickets have no state history. A redelivery scores only the commits since the previous delivery.
10. **Default-branch commits are linked through their pull request** too, so a squash without the ticket's number still delivers the ticket.
11. **The floor is applied without normalising it away**: authors under it get exactly 20%, and the rest is split between the others.
12. ~~The LLM's score is clamped to one scale step of the facts-only score.~~ Replaced by 19.
13. **The first prompt version uses built-in seed anchors.**
14. **Reverts cost points in proportion** to the reverted share of the ticket's lines, and re-lands cancel them. (No rounding to the scale since 22.)
15. **Regressions live in `ticket_relations`** as `regression_of`, not in a table of their own.
16. ~~Scoring spend is recorded without a run (`claude_calls.run_id` becomes nullable).~~ Replaced by 20: `run_id` was already nullable, and the owner check and billing need an owner.
17. **Re-closing a month keeps earlier closings.** One git identity maps to at most one member.
18. **The feature is off by default**, and the tab says the numbers are input to a review, not a verdict.

Settled in the fourth review (draft v5, Nov 4, 2026):

19. **The facts bound the LLM from above only**: it may score as low as 1, and at most one step above the facts score, or three with a risky area touched.
20. **Scoring has its own owner, `score_runs`**, for its Claude calls and for a `credit_ledger` row with `reason = 'score'`. It uses the workspace's connection or credits, never a member's.
21. **A squash's pull-request commits earn the shares**, read from the host, because they may not be linked to the ticket.
22. **Penalties are decimals**: reverts in proportion with no rounding, regressions 30% each, revert first.
23. **A delivery's commits are picked by `on_default_at`**, never by when they were linked.
24. **Only "resolved as done" delivers**: Plane `completed`, Jira Done without a "not done" resolution. Rejected tickets never deliver.
25. **Confirmed and dismissed regressions survive re-analysis** (`ReplaceFound` skips them).
26. **Months close after a grace period** (the 3rd, or up to the 10th while scores are pending).
27. **Days and months use the workspace's timezone.**
28. **The owner can export one member's data** for a right-of-access request, though members don't see it in the app.

## Later

- CI failures on a developer's own pushes, once CI runs can be matched to whoever pushed.
- Credit for work outside tickets: code reviews given (`pr_posts`, git-host reviews), incident firefighting.
- Score trends per developer over time.
- Developers seeing their own numbers in the app.
- An estimate before work starts, for sprint planning.
- Credit to people for directing the agent, such as assigning, answering its questions or reviewing its pull requests.
- Scoring tickets older than commitlink's 90-day reach, through a deeper one-off history scan.
- Tuning the facts-only formula and the clamp's step counts against owner overrides, once there are enough.
