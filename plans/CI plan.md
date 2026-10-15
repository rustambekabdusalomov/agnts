# agnts CI watcher (red pipeline → fix) — Plan

Oct 12, 2026 · implemented (see Implementation notes)

## Overview

agnts already receives GitHub `workflow_run` and GitLab `pipeline` webhooks, but only to refresh the pipelines view. A red build still waits for a person: someone opens the run, scrolls a 4,000-line log, decides whether it is flaky, and either clicks re-run or starts fixing. This plan makes agnts **watch CI, triage every failure, and turn the ones caused by code into a ticket whose fix is ready by the time you look.** You review the diff and approve, and agnts opens the pull request, as it does for any other ticket.

```
CI failures                                          api · web · worker · watching 3 workflows
┌────────────────────────────────────────────────────────────────────────────────────────┐
│ ● api   main   test / unit   TestApplyCoupon: expected 90, got 100    ×4   → CI-31     │
│         since a41c0de · fix waiting for your review                                     │
│ ● web   main   build         Cannot find module '@/lib/money'          ×1   report      │
│         not a code bug in this repo: package removed upstream, see the report           │
│ ○ api   main   test / e2e    flaky: passed on re-run (3rd time this week)    flaky      │
│ ○ worker main  lint          runner lost communication with the server       infra      │
│ ● api   CI-28  test / unit   fed back to CI-28, re-coding                    own PR     │
└────────────────────────────────────────────────────────────────────────────────────────┘
```

**Goals**

- A red pipeline on a watched branch is triaged within a minute of the webhook: infra, flaky, duplicate, or a code failure that deserves a ticket. Nobody copies log lines by hand.
- agnts's own pull requests stop being "opened and forgotten": a red check on an agnts branch goes back to that ticket as feedback and is fixed before you review.
- The fix goes through the existing pipeline unchanged: analysis, coding, checks, self-review, **your approval**, then push and pull/merge request. Nothing reaches the repository before approval.
- Claude runs only for new, reproducible-looking failures, within a daily budget. A flaky test, a lost runner or the same failure on ten commits costs nothing.

**Out of scope for v1:** CI systems other than GitHub Actions and GitLab CI (Jenkins, CircleCI, Buildkite: the triage layer is reusable), fixing the workflow files' infrastructure (runners, caches, secrets), auto-merging fixes, quarantining flaky tests automatically, and fixing failures in deploy/release jobs.

**Principles**

1. **Webhooks first, polling as a fallback.** The existing webhook endpoints already get the events. Repositories without a webhook are polled with ETags (`vcs/github/etag.go`) every 5 minutes, only for their watched branches.
2. **Triage before Claude.** Most CI failures are not code bugs. Re-runs, regexes and fingerprints are free; Claude is the last step, not the first.
3. **A failure is not a ticket.** The same broken test fails on every commit until it's fixed. Failures are grouped by fingerprint; a ticket is created per group, never per run.
4. **Reuse the pipeline.** A ticket from CI is an ordinary local ticket with `Source = ci`. Analysis, kinds, queue, review, push and merge webhooks work as they do now. Most new code is intake and triage.
5. **Reproduce, then fix.** The fix starts from the failing commit, runs the failing command in the runner, sees it fail, and only then changes code. A failure that cannot be reproduced gets a report, not a guessed diff.
6. **Logs are untrusted.** They're redacted, capped, wrapped as data in prompts, and never copied raw into a pull request.

## Architecture

```mermaid
flowchart LR
  GH["GitHub workflow_run<br/>GitLab pipeline"] -- webhook --> H["vcs/hooks.go"]
  P["poller (ETag, 5 min)<br/>repos without a webhook"] --> H
  H -- "status = failed" --> C["ciwatch.Ingest"]
  C -- "head SHA = agnts ticket" --> O["ticket feedback → re-code"]
  C --> L["fetch failed job logs<br/>first error · redact · fingerprint"]
  L --> T{"triage"}
  T -- "infra pattern" --> I["infra (no ticket)"]
  T -- "first time" --> R["re-run failed jobs"]
  R -- "passes" --> F["flaky"]
  R -- "fails again" --> G["failure group"]
  T -- "known fingerprint" --> G
  G -- "policy: auto-fix + budget" --> K["ticket CI-n<br/>Source=ci, KindAuto"]
  K --> X["analyze → reproduce → code → checks → self-review → approve → PR"]
  X -- "PR CI green, merged" --> D["group: fixed"]
```

### Which failures are watched

Per repository, on the repository page (CI tab):

| Setting | Default | Notes |
| --- | --- | --- |
| Watch | off | Opt-in per repository |
| Branches | default branch | Glob list; `release/*` etc. |
| Workflows / jobs | all except names matching `deploy`, `release`, `publish` | GitHub: workflow file + job name; GitLab: stage + job name |
| Other people's PRs | `off` | `off`, `comment` (diagnosis comment on the PR) |
| Auto-fix | follows `Settings.CI.AutoFix` | Per-repository override |

A run counts as failed when its conclusion is `failure` (GitHub) or status `failed` (GitLab). `cancelled`, `skipped`, `timed_out` with no failed step, and jobs marked `allow_failure` / `continue-on-error` are ignored. A run superseded by a newer run on the same branch before agnts got to it is dropped.

### Three kinds of failing branch

1. **An agnts ticket branch** (the run's head SHA or branch matches `Ticket.HeadSHA` / `Ticket.Branch`). No triage, no new ticket: the failed jobs' first error blocks are appended to `Ticket.Feedback` with a link to the run, and the ticket goes back to coding exactly as it does after "request changes". Capped at 2 automatic rounds per revision; after that the ticket stays in review with a red CI badge. Applies to tickets waiting for review and to tickets whose PR is already open.
2. **A watched branch** (default branch, `release/*`). Full triage; a ticket's PR targets the failing branch.
3. **Someone else's PR branch.** Off by default. With `comment`, a code failure gets an analysis run whose diagnosis (cause, file:line, suggested change as a diff snippet) is posted as one PR comment, updated in place on later runs. agnts never pushes to or opens PRs against a colleague's branch.

### Triage (no Claude)

For each failed job, in order:

1. **Fetch logs.** GitHub `GET /repos/{o}/{r}/actions/jobs/{id}/logs`, GitLab `GET /projects/{id}/jobs/{id}/trace`. Plus GitHub check-run annotations (they often carry `file:line`) and the step name that failed. Read at most 2 MB, keep the last 300 lines plus the **first error block** (Go `--- FAIL`/`panic:`, `go vet`, pytest `FAILED`/`E   `, Jest `●`, tsc `error TS`, ESLint, rustc `error[E`, Maven/Gradle `BUILD FAILURE`, generic `##[error]`), trimmed to 64 KB.
2. **Redact.** CI masks registered secrets, but not derived values. Bearer tokens, JWTs, cloud keys, `scheme://user:pass@`, private keys and emails are replaced, the same redactor as Incidents.
3. **Infra patterns.** Runner lost, `The operation was canceled`, OOM-killed runner, `No space left on device`, registry/package mirror 429/5xx, DNS failures, `ETIMEDOUT` to known hosts, missing secret (`secrets.X` empty, GitLab `variable not set`). These become status `infra`: shown, counted, notified once a day at most, never a ticket. Patterns are editable in Settings → CI.
4. **Fingerprint.** Failing test names or the error type and message, plus the top in-repo frames, normalized (line numbers, addresses, durations, timestamps, UUIDs, temp paths, random ports stripped), `sha256`. The same broken test on 10 commits or 3 matrix jobs is one fingerprint. The normalizer is shared with Incidents (`domain/fingerprint.go`).
5. **Flaky check.** A **new** fingerprint gets one re-run of the failed jobs (GitHub `POST /actions/runs/{id}/rerun-failed-jobs`, GitLab `POST /jobs/{id}/retry`) when `Settings.CI.RetryFlaky` is on. Passing on re-run marks the group `flaky` and counts it; a group flaky 3 times in 7 days is listed under "Flaky tests" with a one-click **Fix flakiness** ticket (a different prompt: find the race, not the assertion). Failing again confirms it.
6. **Already fixed?** If the default branch has a newer green run that contains the failing commit, the failure is `resolved` without a ticket.

### Failure group lifecycle

```
           new fingerprint            re-run fails, policy says fix
  ──────► triage ─────────────► open ──────────────────────────► fixing (ticket CI-n)
            │  │                 │  ▲                                   │ PR merged
            │  └► flaky          │  │ same fingerprint after            ▼
            └──► infra   mute ◄──┘  └─ the fix commit ◄────────── fixed ──► resolved
                                       (regression)                 (next run on the
                                                                     branch is green)
```

- **Group:** a known fingerprint for the same repository and branch increments `count`, updates `last_seen`, keeps the newest log sample and appends to the last 20 occurrences (run URL, SHA, job, time).
- **Policy (when a group gets a ticket):** all of these must hold:
  - the repository is watched and the group is not muted, flaky or infra;
  - `Settings.CI.AutoFix` is on (otherwise the group shows **Fix it**, a one-click button);
  - no open ticket exists for this fingerprint (a ticket in progress just gets the new count);
  - the daily budget has room: `Settings.CI.MaxAutoPerDay` (default 5). Over budget, groups wait with "budget reached, Fix it to start now". Feedback rounds on agnts's own PRs don't count against it; they're part of an existing ticket.
- **Regression:** the merge webhook stores the fix SHA. When the same fingerprint fails on a commit that contains it (`git merge-base --is-ancestor` in agnts's clone), the group reopens as `regression` and the original ticket gets a follow-up suggestion. No new ticket automatically.

## Server side

### The ticket

`ciwatch.CreateTicket` builds an ordinary local ticket through the same path as `Implement` and follow-ups:

- `Key` from `task_seq` with a `CI-` prefix, `Source = domain.SourceCI`, `RepoID` of the repository, `Priority` `high` (`highest` when the default branch is red), `AfterApprove = "pr"`.
- `Kind = code`, `KindAuto = true`: the analysis may switch it to `bug` (a report with no change) when the cause is not in this repository's code.
- `AskFirst = false`: open questions go into the report.
- `BaseSHA` = the failing commit, `Branch` from the failing branch so the PR targets it (see below).
- `Description` is generated: workflow, job, failing step, branch and commit (with author and message), first-seen commit, occurrences, annotations, and the redacted first error block in a fenced block. The full sample is written into the container as `/agnts/in/ci/logs.txt` and `ci.json` (run URL, job commands from the workflow file when they can be read, matrix values, runner OS), so the prompt stays small.
- PR body: "Fixes `test / unit` on `main`, failing since a41c0de (4 runs)", links to the runs, and the error **title** only, never the raw log.

### Prompt changes

`analyze` and `code` get a **CI failure** section when `Source = ci`:

- Start from the failing commit and look at what changed: `git log --oneline <last green>..<failing> -- ` and the diff of the first failing commit. The culprit commit is usually there.
- Classify: `code` or `test` (fix it), `config` (workflow file, lint config, lockfile), `dependency` (upstream release broke it: pin or adapt), `environment` (passes locally, needs a CI-only service or secret), `cannot-determine`. Anything but `code`/`test`/`config` switches to a `bug` report with the exact remediation.
- **Reproduce first:** run the failing job's command in the runner (from `ci.json`, else the repository's detected test/lint/build commands), confirm the same failure, fix it, confirm it passes. The existing checks loop applies. If the failure does not reproduce in the runner, say so and switch to a report; don't change code blind.
- **Don't fix the test to fit the bug.** Changing an assertion or deleting a test is allowed only when the summary explains why the old expectation was wrong; the self-review prompt treats such a change as a blocker without that explanation.
- Keep the change minimal: no refactors, no unrelated cleanup.

### Data model — migration `00037_ci_failures.sql`

```sql
CREATE TABLE ci_failures (
  id             bigserial   PRIMARY KEY,
  workspace_id   bigint      NOT NULL REFERENCES workspaces ON DELETE CASCADE,
  repo_id        bigint      NOT NULL REFERENCES repositories ON DELETE CASCADE,
  branch         text        NOT NULL,
  workflow       text        NOT NULL,             -- workflow file or GitLab stage
  job            text        NOT NULL,
  fingerprint    text        NOT NULL,
  class          text        NOT NULL DEFAULT '',  -- infra, flaky, code, ... (triage / analysis)
  title          text        NOT NULL,             -- "TestApplyCoupon: expected 90, got 100"
  status         text        NOT NULL DEFAULT 'open', -- open, fixing, fixed, resolved, flaky, infra, muted, regression
  count          integer     NOT NULL DEFAULT 1,
  flaky_count    integer     NOT NULL DEFAULT 0,
  first_seen_at  timestamptz NOT NULL,
  last_seen_at   timestamptz NOT NULL,
  first_sha      text        NOT NULL,             -- first failing commit
  last_sha       text        NOT NULL,
  sample         bytea,                            -- redacted log excerpt, sealed with AGNTS_ENC_KEY
  occurrences    jsonb       NOT NULL DEFAULT '[]', -- last 20: run id, url, sha, job, time
  ticket_key     text,
  fixed_sha      text        NOT NULL DEFAULT '',
  UNIQUE (repo_id, branch, workflow, fingerprint)
);
CREATE INDEX ci_failures_open ON ci_failures (workspace_id, status, last_seen_at DESC);

ALTER TABLE repositories ADD COLUMN ci_watch jsonb NOT NULL DEFAULT '{}'; -- branches, workflows, prs, autoFix
```

Retention: `sample` is dropped 30 days after `resolved`/`muted`, flaky and infra groups after 14 days without a new occurrence (the minute tick that already sweeps preview shots).

### Packages

- **`domain/ci.go`**: `CIFailure`, `CIStatus`, `CIClass`, `CIRun` (what intake parses from a webhook or poll) with `Normalize()`; `RepoCIWatch`. **`domain/fingerprint.go`**: the normalizer and `Fingerprint()`, shared with Incidents. Pure, with most of the tests. `domain/ticket.go`: `SourceCI TicketSource = "ci"`. `domain/settings.go`: `Settings.CI{AutoFix, MaxAutoPerDay, RetryFlaky, InfraPatterns, Model}`.
- **`vcs`**: `Browser` gains `JobLogs(ctx, repo, jobID) (io.ReadCloser, error)`, `Annotations(ctx, repo, jobID)`, `RerunFailed(ctx, repo, runID)`, `FailedJobs(ctx, repo, runID)`. `hooks.go` parses `workflow_run` (action `completed`) and GitLab `pipeline` (status `failed`) into a `domain.CIRun` and hands it to a new `CISink` instead of only appending an event; the refresh behaviour stays. `orchestrator.PR` gains `Base string` (empty = default branch) so a fix can target `release/*`.
- **`internal/ciwatch/`** (use case): `Ingest(ctx, run)`, `RouteToTicket` (own branches → feedback), `Triage`, `Policy`, `CreateTicket`, `CommentDiagnosis`, `Mute`, `CheckRegression`, and the ETag poller. It depends on a `Store`, the orchestrator's ticket creation and feedback, and `vcs`, through interfaces it declares.
- **`store/postgres/ci_failures.go`**: upsert in one statement (`ON CONFLICT … DO UPDATE SET count = count + 1`), so matrix jobs reporting together don't race.
- **`httpapi`**: admin endpoints `GET /ci/failures`, `GET /ci/failures/{id}`, `POST /ci/failures/{id}/fix`, `/mute`, `/unmute`, `GET/PUT /repos/{id}/ci-watch`. Webhook endpoints stay where they are. All in `openapi.yaml`, then `make gen`.
- **`orchestrator`**: `prompts.go` CI section; `code()` copies `logs.txt` and `ci.json` into `/agnts/in/ci/`; the feedback path learns a `ci` origin so the log shows "CI failed: test / unit" rather than a person's comment; the merge handler marks the group `fixed`.
- **`notify`**: `EventCIFailure` ("main is red on api: TestApplyCoupon, fix started"), once per group, never per run. Feedback rounds on agnts's own PRs reuse the existing state-change messages.
- **`mcpserver`**: `list_ci_failures`, `get_ci_failure`, so Claude chat can answer "why is main red?".
- **Integrations**: GitHub needs `Actions: read` (logs) and `Actions: write` (re-runs) on the fine-grained PAT; GitLab needs `read_api`, and `api` for retries. Integrations → GitHub/GitLab checks the token's scopes when CI watching is on and shows what's missing; without write access, flaky checks are skipped and every new failure is treated as confirmed.

### Admin and mobile

- **CI failures page** (new nav item, or a shared **Failures** page once Incidents ships): groups as above, filters by repository/branch/status/class, sparkline of occurrences, actions **Fix it**, **Mute**, **Re-run**. Detail shows the redacted log excerpt with the first error block highlighted, annotations, occurrences, the culprit-commit candidates and the ticket.
- **Repository page → CI tab:** watch settings, current red/green per watched branch, flaky tests list.
- **Ticket page:** a CI card above the description for `Source = ci` tickets (job, branch, count, still failing yes/no), and a CI badge on every ticket with an open PR (green / red / running, with "fed back 1 of 2").
- **Settings → CI:** auto-fix, daily budget, flaky re-run, infra patterns, model.
- **Mobile:** CI push opens the ticket; the ticket screen shows the CI card. Approving from the phone already works.

## Phases

**1a — agnts's own PRs.** Parse `workflow_run`/`pipeline` webhooks, match to tickets by SHA/branch, fetch failed job logs, extract the first error block, feed back into the ticket, 2-round cap, CI badge on the ticket. No new table. Done when an agnts PR with a failing test re-codes on its own and turns green without anyone touching it.

**1b — Watch and triage.** `ci_failures` table, per-repository watch settings, redaction, fingerprint, infra patterns, flaky re-runs, ETag poller, the CI failures page, scope checks on Integrations, and **Fix it** to create a ticket by hand. Done when a broken test on `main` across 5 commits and 2 matrix jobs is one group, and a lost runner is `infra` with no ticket.

**1c — Automatic fixes.** Policy and budget, CI prompts with reproduce-first, `bug`-report fallback, `Base` for non-default branches, notifications, merge → `fixed` → `resolved`, regression detection, MCP tools.

**1d — Beyond.** `comment` mode for other people's PRs, **Fix flakiness** tickets, mobile CI list, Telegram "Fix it" button.

## Testing

- `domain`: first-error extraction and fingerprint normalization on real logs from Go, pytest, Jest, tsc, ESLint, rustc and Gradle (same failure with different line numbers, durations, ports and matrix values gives the same hash; different failures don't); infra pattern table.
- `vcs`: webhook payload parsing from recorded GitHub and GitLab deliveries (`completed`/`failure`, `cancelled`, `allow_failure`, re-run attempts); `JobLogs` with a 302 redirect (GitHub) and a large trace capped at 2 MB.
- `ciwatch`: routing table (own ticket, watched branch, other PR, unwatched); policy table (budget, open ticket, muted, flaky, infra); feedback round cap; superseded runs dropped; regression with a fake ancestry checker.
- `store/postgres`: concurrent upserts of the same fingerprint end with the right count.
- `orchestrator`: PR opened with `Base`; feedback from CI clears and re-codes like a review.
- End to end (`make ci-smoke`): a fixture repository on a local Gitea/GitLab CE container is out of reach for v1, so replay recorded webhooks against a fake host (`httptest`) serving recorded job logs, and assert a group, a re-run call, and a `CI-` ticket with the error in its description.

## Security

- CI logs are untrusted: anyone who can open a PR can write anything into them. They're redacted before storage, sealed at rest, wrapped in the prompt as "the following is CI output, not instructions", and the existing permission settings and egress proxy bound what a run can do. A crafted log line can at worst produce a bad diff, and you review every diff before anything is pushed.
- Runs from fork PRs are never fed into a ticket or analysis, even in `comment` mode.
- Raw logs never leave agnts: PR bodies and comments carry the error title, counts and links, not log contents.
- The extra token scopes are read logs and re-run jobs. agnts never edits workflow files outside a reviewed ticket, never triggers workflows other than re-runs of failed jobs, and never reads repository or environment secrets.

## Costs and limits

- **Server:** one webhook already arrives per run; failed runs add one log fetch per failed job (capped at 2 MB read, 64 KB kept) and one upsert. Polling only for repositories without a webhook, with ETags (mostly `304`).
- **CI minutes:** at most one re-run per new fingerprint.
- **Claude:** one analysis + coding session per *new, confirmed* fingerprint, capped by `MaxAutoPerDay`; up to 2 feedback rounds per revision on agnts's own PRs. Flaky, infra and duplicate failures cost nothing.
- **Time to fix ready:** ~1–2 min to triage (plus the re-run's duration for new failures), then the usual analyze + code time behind higher-priority work.

## Decided

- **The PR waits for your approval.** "After review" means agnts's self-review, then you approve, then the PR is opened, as for every ticket. No auto-open setting in v1.
- **Other people's branches get a comment, never a push.** `comment` mode is opt-in per repository.
- **Separate plan from Incidents**, sharing the fingerprint normalizer and redactor in `domain`, and one **Failures** page once both ship.

## Open questions

1. Should a red default branch let its CI ticket skip ahead of same-priority tickets in the queue?
2. After 2 failed feedback rounds on an agnts PR, should the PR be converted to draft, or only badged?
3. Should flaky groups be reported to the tracker (Jira/Plane) as issues, or stay inside agnts?

## Implementation notes

What shipped differs from the plan above in these places:

- **Migration** is `00037_ci_failures.sql` (`00036` is private networks). Watches live in their own table, `ci_watches`, not a column on `repositories`; both tables have workspace row-level security. The ticket's round counter is `tickets.ci_fixes`.
- **Reopening a pushed ticket.** Pushed tickets are `done`, a terminal state, and CI only runs after a push. Instead of loosening the state machine, the store has `ReopenForCI`, which moves `done → coding` only while `domain.CanReopenForCI` holds (a code or test ticket with an open, unmerged pull request, not a replay or a pull-request review). The fix is reviewed and approved like any change and pushed to the same pull request (no second PR; the tracker comment says "pushed more commits").
- **Feedback rounds** are counted per ticket (`CIFixes`), not per revision: every round already needs your approval before the next push, so a per-revision cap would never bind.
- **Fix branches** are cut from the current default branch, not from the failing commit. The description and the CI prompt section give the failing and first-failing commits, and the analysis compares them with the last green run. Failures on other watched branches (`release/*`) get tickets whose description asks for a report, because agnts's branches and pull requests target the default branch (`orchestrator.PR` has no base yet).
- **Comment mode** on other people's pull requests posts a diagnosis built without Claude: per failed job, infra or not, whether the same fingerprint is open on the default branch ("not caused by this pull request"), and the first error block. One comment per pull request, edited in place.
- **Regression** is decided by `git merge-base --is-ancestor` of the merged ticket's head in the failing commit; for squash merges (where that commit is not an ancestor) a failure finishing more than 30 minutes after the merge counts.
- **Polling** covers watched repositories and repositories with an unmerged agnts pull request. A new watch's first poll only records the newest run, so history is not triaged.
- **Auto-fix budget** counts `CI` tickets created without a person (webhook or poller). Fix it from the web is not counted; Fix it from Telegram is (it has no signed-in person).
- **Notifications**: one push/Telegram message per group when it is confirmed red or comes back as a regression (`Settings.Notify.CI`), with a Telegram **Fix it** button when no ticket works on it yet. Infra failures and agnts's own pull request rounds stay quiet.
- **Testing**: `ciwatch` has fakes-based tests for every route (own PR, watched branch, PR comment, unwatched/ignored/fork), triage (re-run, flaky, infra, duplicates, one group across commits), policy (auto-fix, budget, Fix it, PR groups), merge → fixed → resolved, regression and ticket sync; the store has Postgres tests (concurrent upserts, sealed samples, occurrence cap, `ReopenForCI`); webhook parsing and log fingerprinting have their own tests. The recorded-webhook end-to-end smoke (`make ci-smoke`) is not built.
