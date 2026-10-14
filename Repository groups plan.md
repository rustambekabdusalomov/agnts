# agnts: Repository groups and multi-repo tickets — Plan

Oct 13, 2026 · draft

## Overview

Today a ticket has one repository. `tickets.repo_id` is a single nullable column. Next to it on the same row sit about a dozen per-repo values: `branch`, `head_sha`, `base_sha`, `pr_number`, `pr_url`, `merged_at`, `closed_at`, `ci_fixes`, `preview_state`, `assignees`. Every stage loads that one repo with `repoFor` (`orchestrator.go:687`), unpacks it at `/workspace`, runs Claude there, and pushes one branch and one PR.

Real work often spans repositories: a backend and its frontend, a service and its shared library, an API and its mobile app. This plan adds:

1. **Repository groups.** A named set of repositories in a workspace. The relation is many-to-many: a group has many repositories, and a repository can be in many groups.
2. **Multi-repo tickets.** When creating a ticket, the user picks **one repository**, **several repositories**, or **a group**. The agent works on all of them in one run. It sees every repo, makes one coherent change across them, and agnts opens one PR per changed repository, cross-linked.

**Goals**

- Group CRUD with members, plus group-level instructions ("how these repos fit together").
- Ticket creation with one repo, several repos, or a group, from admin, mobile, MCP, trackers (labels) and the server CLI.
- One run, one container and one Claude session per ticket. Each repo gets its own subfolder, branch, checks, commit, PR, CI loop and merge state.
- No behaviour change for single-repo tickets.

**Out of scope for v1:** previews that start several repos together (e.g. frontend plus a live backend). Also out: mapping a Jira/Plane project to a group, ordered or dependent merges across repos, and multi-repo PR review tickets (`kind=review` stays one PR).

**Principles**

1. **A single-repo ticket is a multi-repo ticket with N=1.** There is one code path. The only layout difference is the folder: N=1 keeps the repo at `/workspace`, and N>1 puts each repo at `/workspace/<repo-name>/`. Everything asks `ws.Dir(repo)` instead of hard-coding `/workspace`.
2. **The ticket stays the unit of work; the repo is the unit of git.** States (analyzing, coding, review, pushing, done) stay ticket-level. Branch, sha, PR, CI, merge and preview become per ticket-repo.
3. **A group is a shortcut, not a live link.** At creation the group's members are copied into the ticket's repo list. Editing the group later never changes running or finished tickets. `group_id` is kept on the ticket only for display and filtering.
4. **A repo with no changes gets no PR.** The agent may only need to read some repos. The run fails only when *no* repo changed.

## Repository groups

### What a group has

| Field | Notes |
| --- | --- |
| `name` | Unique per workspace, e.g. "Shop" |
| `description` | Optional, shown in pickers |
| `instructions` | Optional markdown injected into prompts: how the repos relate, contracts, order of changes ("API first, then the web client; the client's types are generated from `api/openapi.yaml`") |
| `task_prefix`, `task_seq` | Key prefix for tickets created from the group (e.g. `SHOP-12`), same validation as repos |
| members | Repositories, each with an optional `role` label (e.g. "backend", "web") and a position for display order |

### Rules

- Only non-archived repos can be added. Archiving a repo keeps it in its groups but greys it out; creating a ticket from the group skips it, with a notice.
- A group needs at least 1 member, and has at most `max_ticket_repos` members (a workspace setting, default 6; see Capacity).
- Owners manage groups, the same as `createRepo` (`x-role: owner`). Viewers can see them.
- Deleting a group never touches tickets. Their `group_id` is set to NULL and the repo list stays.
- **Compatibility check** on save, since the repos share one container (see Runner):
  - repos with different `runner_image` values → error;
  - toolchains with conflicting versions of the same tool → error naming both;
  - build env keys set to different values → warning, last one wins, listed.

## Tickets with several repositories

### Choosing repos at creation

`TaskCreate` takes exactly one of:

- `repoId` (today, kept),
- `repoIds: [..]` (1..max, distinct, first one is the **primary**),
- `groupId`.

No field means a task without a repository, as today. The server resolves the choice to an ordered repo list and writes `ticket_repos` rows. The primary repo is the first one picked, or the group's first member.

**Key prefix:** a group ticket uses the group's prefix. Otherwise the primary repo's prefix is used (unchanged for single-repo tickets).

**Which kinds may be multi-repo:**

| Kind | Multi-repo | Notes |
| --- | --- | --- |
| code, test | yes | the main case |
| plan, bug, analysis | yes | read-only across repos; the plan's implement tickets inherit the repo list |
| review (PR review) | no | one PR by nature |
| ci (from CI watch) | no | a failure belongs to one repo |
| replay | inherits | base sha per repo |

**Changing repos later** (today `PUT /tickets/{key}/repo`) becomes `PUT /tickets/{key}/repos {repoIds | groupId}`. It is allowed under the same conditions as today (`SetRepo`, `actions.go:569`: new, or failed/rate-limited with no PR open). It resets per-repo state for removed repos and creates fresh rows for added ones.

### Trackers and other sources

- **Jira/Plane labels:** `RepoFromLabels` (`domain/ticket.go:562`) returns *all* `repo:<name>` labels, not only the first, and a new `group:<name>` label selects a group. Precedence: group label, then repo labels, then the project mapping (today's behaviour). The relabel rule is unchanged: labels move repos only while the ticket is `new` with no PR.
- **MCP:** `create_task` / `implement_ticket` accept `repositories: [names]` or `group: name` next to `repository`. There is a new `list_repository_groups` tool, and `get_ticket` returns the repo list.
- **Follow-ups** inherit the parent's repo list. The analysis may narrow it to the repos the follow-up is about (`ticket_suggestions` gets `repo_ids`).
- **Implement from plan/bug** inherits the parent's list unless the request gives one.

## How a multi-repo run works

### Workspace layout

```
/workspace/                 ← Claude's cwd (unchanged)
  api/        (.git, branch agnts/SHOP-12)
  web/        (.git, branch agnts/SHOP-12)
  shared-lib/ (.git, branch agnts/SHOP-12)
/agnts/context/
  group.md                  ← group instructions
  brief-api.md, brief-web.md, …
  precedents-api.md, …
```

- One container per stage, as today. One Claude session per ticket (`Homes`, `--resume`) keeps working because the cwd stays `/workspace`.
- The folder name is a slug of the repo name. Clashes inside one ticket get a `-2` suffix.
- The branch name is the same in every repo (`branchFor(repo, key)`, with each repo's own `branch_prefix`).

### Stage by stage

| Stage | Change |
| --- | --- |
| **analyze** | `Prepare` and `Archive` per repo into its subfolder. The prompt lists every repo (name, role, folder, default branch, CLAUDE.md, checks, toolchains) and the group instructions. The analysis output's footprint paths become `repo/path`. The analysis may say which repos it expects to touch. |
| **code** | Same workspace. `checkAndFix` runs each touched repo's build/lint/test in its own folder. Fix prompts name the repo. `ExportRepo` exports one tar per repo. `Commit` runs per repo with changes. Red flags, coverage and collision checks run per repo. The run fails with "no changes" only if every repo is untouched. |
| **review** (side) | One review over the whole change, with the diff grouped by repo, so the reviewer sees the contract between repos. Findings carry `repo/path`. |
| **preview** (side) | Per repo with a preview command whose UI paths changed, one after another in the same container; shots are labelled by repo. Previews that start several repos together are v2. |
| **push** | Per changed repo: drift check, push, open PR, assign. PR bodies cross-link sibling PRs ("Part of SHOP-12 · also: web#88, shared-lib#14"). A push failure in one repo leaves the others pushed. The ticket stays in `pushing`, shows which repo failed, and Retry pushes only the missing ones. |
| **CI loop** | `ciwatch` matches a run to a `ticket_repos` row by (repo, branch). Red CI reopens the ticket to coding with feedback naming the repo. Fix rounds are counted per repo. The head-sha check uses that repo's sha. |
| **merge** | Each PR's merge or close is recorded on its row. The ticket counts as **merged** when every opened PR is merged. A PR closed without merging marks its row `dropped`, and the ticket shows "partially merged". The tracker "merged" move, dependency unblocking and post-merge CI hooks wait for the ticket-level merge. |
| **learn** | Runs per merged repo (lessons are `UNIQUE(repo_id, slug)` already), in one container like the other stages. |
| **reflect, follow-ups, replay** | Reflections get a repo list. A replay stores `base_sha` per repo. |

### Context and rules

- Briefs, precedents and business notes are written per repo (`brief-<folder>.md`).
- Team rules are the union of global rules and every repo's rules. Skills are named `agnts-<folder>-<rule>` to avoid clashes.
- **Guard:** `guard.Command` and `EditCheck` get a `Dir`. The stop hook runs each touched repo's checks in its folder, and edit-check globs are prefixed with the folder.
- Prompts: `promptData.Repo` becomes `Repos []RepoView` (repo plus folder plus role), with a `.Primary` helper. Templates that say "the repository at /workspace" render a per-repo section instead. For N=1 the text stays as it is today.

### Container and capacity

- **Toolchains:** the union of all repos' toolchains (validated as compatible at group save and ticket create).
- **Cache:** one volume per repo (`agnts-cache-repo-<id>`), each mounted at its own path.
- **Image:** the shared `runner_image` (conflicts are refused earlier).
- **Memory:** the maximum of the repos' `memory_mb`, because checks run one repo at a time. The scheduler's `RunMemory` uses this.
- **Env:** merged build env; the preview env is written per repo.
- **Time and cost:** max-turns and the cost cap scale with repo count (×1.5 for 2–3 repos, ×2 for more), configurable. `max_ticket_repos` (default 6) bounds checkout size and prompt length.

## Changes by layer

### 1. Data (migration `00044_repo_groups.sql`)

New tables, all following the 00023+ template (`workspace_id DEFAULT agnts_ws()`, index, `ENABLE`/`FORCE ROW LEVEL SECURITY`, `workspace_isolation` policy):

- `repository_groups` (id, workspace_id, name, description, instructions, task_prefix, task_seq, created_at, updated_at; `UNIQUE (workspace_id, name)`, `UNIQUE (workspace_id, task_prefix)`)
- `repository_group_members` (group_id FK CASCADE, repo_id FK CASCADE, role, position; PK `(group_id, repo_id)`; index on `repo_id` for "groups of this repo")
- `ticket_repos` (ticket_id FK CASCADE, repo_id FK, position, folder, branch, head_sha, base_sha, pr_number, pr_url, assignees, ci_fixes, preview_state, merged_at, closed_at, state `pending|unchanged|pushed|merged|dropped`, push_error; PK `(ticket_id, repo_id)`; `UNIQUE (repo_id, branch)`; `UNIQUE (repo_id, pr_number)`)

`agnts_fill_ws()` gains `repository_group_members` (from the group) and `ticket_repos` (from the ticket), with triggers.

Changed:

- `tickets`: add `group_id` (FK SET NULL). Keep `repo_id` as the **primary repo**: key prefix, filters, `agnts_fill_ws`, PR-review and CI tickets keep working. Backfill one `ticket_repos` row per ticket with a repo, copying `branch`, `head_sha`, `base_sha`, `pr_number`, `pr_url`, `assignees`, `ci_fixes`, `preview_state`, `merged_at`, `closed_at`. Drop those columns from `tickets` in a follow-up migration once reads are cut over (one release later).
- `results.files` entries get `repo_id` (null means the primary repo, which covers old rows).
- `ticket_suggestions`: add `repo_ids bigint[]`.
- `reflections`: keep `repo_id`, add `repo_ids`.
- `pgtest.Reset` truncate list; `TestWorkspaceIsolation` covers the new tables.

### 2. Domain and store

- `domain.RepoGroup`, `domain.TicketRepo` (per-repo state). `Ticket.Repos []TicketRepo` is loaded with the ticket (one extra query, or `json_agg` in `ticketCols`). Helpers: `Primary()`, `Repo(id)`, `Changed()`, `AllMerged()`.
- `saveTicket` writes changed `ticket_repos` rows in the same transaction.
- Fix `TicketByPR` (`tickets.go:936`). It matches on branch alone, which is ambiguous once every repo has `agnts/KEY` (and is fragile even today). Replace it with `TicketRepoByPR(repoID, prURL, branch)`.
- `UnmergedPRs`, `OpenTicketCounts`, `InFlightResults`, `RelationCandidates`, the learn queue and `followups`/`precedents`/`spend`/`analytics` queries: switch from `t.repo_id = $1` to `EXISTS (ticket_repos …)` where "touches repo X" is meant, and keep `t.repo_id` where "primary repo" is meant. Each query gets a one-line decision in the PR.
- Group store: CRUD, members, `GroupsOfRepo`, `NextGroupTaskNumber`.

### 3. API (`shared/openapi/openapi.yaml`)

- `GET/POST /repo-groups`, `GET/PUT/DELETE /repo-groups/{id}` (`x-role: owner` for writes). Body: name, description, instructions, taskPrefix, members `[{repoId, role}]`. The response includes a `warnings` list from the compatibility check.
- `Repository` gets `groups: [{id, name}]`.
- `TaskCreate`, `ImplementInput` and the follow-up accept call get `repoIds` and `groupId`. A 400 error is returned if more than one of `repoId`/`repoIds`/`groupId` is given.
- `Ticket` gets `repos: [TicketRepoState]` (repoId, repoName, role, folder, branch, headSha, prNumber, prUrl, ciFixes, previewState, state, mergedAt, pushError) and `group: {id, name}`. The scalar `repoId`/`repoName`/`branch`/`prUrl`/`prNumber`/`headSha` fields stay as the **primary repo's** values for one release (marked deprecated), so older mobile builds keep working.
- `PUT /tickets/{key}/repos` replaces `PUT /tickets/{key}/repo`; the old endpoint stays as a one-repo alias.
- `make gen` regenerates the Go server, the admin TS client and the Dart client.

### 4. Orchestrator

- `repoFor` → `reposFor(t) []domain.Repository`. `optionalRepo` → `primaryRepo`.
- `openWorkspace` prepares and archives each repo with its folder prefix. `gitrepo.Archive`/`gitDir` take a `prefix`, and `ExportRepo` takes a folder.
- The stage loops described above: checks, commit, push, PR, assign, drift, `dropBranch`, CI feedback, `markMerged`, `countMerge` and learn are all per repo. Ticket-level transitions use `AllMerged()`.
- `CreateTask` resolves `repoIds`/`groupId`, validates (exists, not archived, compatible, ≤ max, kind allows multi-repo), and snapshots group members.
- `SetRepo` → `SetRepos`. `IngestDetail` handles multiple repo labels and the group label.
- Scheduler: `QueueItem.MemoryMB` is the maximum over the ticket's repos.
- Webhooks (`vcs/hooks.go`): `MarkMerged`/`prClosed` pass the repo (clone URL or full name) so the lookup hits the right `ticket_repos` row. The same goes for `ciwatch.ownTicket`.

### 5. Runner and guard

- `WorkspaceSpec.Repos []RepoMount{Folder, Tar, CacheKey}` replaces `Repo`/`CacheKey`. `Open` puts each tar at `/workspace/<folder>` (or `/workspace` when N=1) and mounts one cache per repo.
- `Exec` gets a `Dir`. `ExportRepo(folder)` runs `git ls-files` in that folder.
- `checkpoint.changedFiles`, `proof` (worktree per repo) and `coverage` run per folder.
- `agnts-preview` reads a `dir` from its config and `cd`s into it; `preview-config.json` is written per preview run.
- Guard: `Dir` on `Command`/`EditCheck`, and prefixed globs.

### 6. Admin panel, mobile, CLI, MCP

- **Admin:**
  - Repos page: a **Groups** tab (list, drawer with members picker, roles, instructions, prefix, compatibility warnings). The repo detail page shows its groups.
  - **TaskDrawer:** the single-select repo tabs become one picker with groups at the top and repos below with checkboxes. Picking a group shows its members as removable chips, and the payload sends `groupId`, or `repoIds` once edited. With one repo checked it sends `repoId`, as today.
  - **TicketPage:** the side panel shows a per-repo list (repo, role, branch, PR link, CI, state, push error with a Retry action). "Open PR" becomes a list when N>1. `RepoPicker` becomes multi-select. Analyzing and done texts name the repos ("in api, web").
  - Ticket list and board: a "api +2" chip, and the repo filter matches any repo of a ticket. Add a group filter.
- **Mobile:** the same picker in `_NewTaskSheet` (groups section plus multi-select chips), a per-repo list on the ticket screen, and "+N" in lists.
- **Server CLI** (`server/cmd/agnts/cli.go`): `agnts repo group add|list|members|rm`.
- **MCP:** as described in "Trackers and other sources".

## Edge cases

- **The same repo twice** (picked directly and through a group): de-duplicated, keeping the first position.
- **A repo archived while a multi-repo ticket runs:** the run continues. New tickets from the group skip it.
- **A repo deleted:** its `ticket_repos` rows go with it via CASCADE. If it was the primary, the next repo becomes primary. A ticket left with no repos fails with a clear reason.
- **One PR merged, another rejected by a human:** the ticket is "partially merged". The user can reopen it to fix the rejected repo (only that repo's branch restarts) or close it as done.
- **CI red in one repo after another repo merged:** reopen only if the red repo is unmerged (`CanReopenForCI` per row).
- **Conflict prediction** between tickets compares `(repo, path)`, so tickets in different repos never conflict on the same relative path.
- **Ticket keys:** a group prefix must not collide with repo prefixes or Jira/Plane keys (extend `checkKeySpace`).

## Delivery

| Phase | Contents | Estimate |
| --- | --- | --- |
| 1. Groups | Tables, RLS, store, API, admin Groups tab, server CLI, MCP list | 3–4 days |
| 2. Ticket repo model | `ticket_repos` with backfill, `Ticket.Repos`, store cut-over, `TicketByPR` fix, API `repos[]` with deprecated scalars | 1–1.5 weeks |
| 3. Multi-repo workspace | Folder layout, archive/export per folder, `Exec` dir, guard dirs, prompts with `Repos`, context per repo, container spec merge | 1.5–2 weeks |
| 4. Push, CI, merge | Per-repo commit/push/PR, cross-links, partial push retry, CI loop per repo, merge aggregation, webhooks with repo | 1–1.5 weeks |
| 5. Creation everywhere | TaskCreate `repoIds`/`groupId`, admin and mobile pickers, ticket page per-repo panel, tracker labels, MCP, follow-ups and implement inheritance | 1 week |
| 6. Side stages | Review over all repos, preview per repo, learn per repo, replays with per-repo base sha | 4–5 days |
| **Total** | | **~5–7 weeks** |

Phases 1–2 ship on their own with no behaviour change (groups exist, and every ticket has one `ticket_repos` row). Phase 3 is the risky one. Behind a workspace flag `multi_repo_tickets` it can be tested on N=1 first: the layout stays `/workspace`, but all code goes through `ws.Dir(repo)`.

## Open questions

1. **Folder layout for N=1:** keep `/workspace` (no prompt or guard regressions, recommended) or always use `/workspace/<name>` (one layout, but every existing prompt, preview script and lesson that assumes the root changes)?
2. **Group membership: snapshot or live?** This plan snapshots at creation. Should a *new* ticket (still in `new`) pick up repos added to its group before it starts?
3. **Merge policy:** is "all opened PRs merged" the right definition of done, or should a group be able to name required repos?
4. **Order of pushes:** does any team need "merge the library before the app" ordering (e.g. a version bump), or is cross-linking enough for v1?
5. **Tracker projects → groups:** should a Jira/Plane project map to a group as well as to a repo, or are labels enough?
6. **Per-repo member access:** repos have members (`/repos/{id}/members`). Must the ticket creator have access to every repo in the group, or does group access imply it?
7. **Pricing:** does a multi-repo ticket count as one ticket or as N for plans and credits? The cost cap scales with repo count either way.
