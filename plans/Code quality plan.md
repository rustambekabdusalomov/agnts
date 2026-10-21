# agnts Code Quality — Plan

Oct 21, 2026 · implemented (phases 0–6, prompt size from phase 7; see "Left out" below), prompts version 2026-10-21.1, migrations 00057–00059; not committed

## Overview

agnts now works real tickets, and the code it writes does not always fit the project: it reinvents helpers that already exist and puts logic in the wrong layer. A review of the whole pipeline found that this is one symptom of three wider gaps:

1. **It thinks too little before coding.** The analysis runs on Sonnet with no thinking budget, never runs the code, gets thin ticket data (no comments, images or parent), and spends its effort filling a 13-field JSON instead of investigating.
2. **It checks late instead of guiding early.** Guard hooks, red flags, proof, self-review and CI watching are strong, but the coder is never told up front what good looks like: tests for new behaviour, edge cases, which helpers to reuse, which layer owns what.
3. **It learns from the wrong signals.** CI failures are counted as human feedback, PR review comments never become rules, and what developers change in agnts's code before merging is never looked at.

This plan fixes the bugs first, sets up a benchmark so every later change is measured, then works through thinking, evidence, tests, architecture fit and learning.

**Principles** (from the Agent intelligence plan)

1. Knowledge that reaches a prompt is approved by a person, or comes from work a person approved (precedents). agnts proposes; people decide.
2. Measure first: each phase is judged on the Phase 1 benchmark and the quality table, per prompt version.
3. Reuse what exists: briefs, rules, reflect, replay, the event log. No vector database.
4. Context goes to runs as files under `/agnts/context/`; prompts stay short.
5. Bump `PromptVersion` with every prompt change.

## Phases

| # | Phase | What it adds | Size |
| --- | --- | --- | --- |
| 0 | Bugs | CI feedback not counted as human; PR threads feed reflect; checkpoint keeps turn scaling; second opinion reaches the coder; low coverage can send work back | S |
| 1 | Benchmark | A fixed set of merged tickets, replayed and scored against the merged diff; model as a dimension; quality score and cost per merged ticket | M |
| 2 | Thinking | Thinking/effort settings; stronger analysis model for complex tickets; plan validation; test plan and edge cases in the analysis; reviewer sees everything | S–M |
| 3 | Evidence | Analysis can run the code and reproduce bugs; reads git history; ticket comments, images, parent and links; library versions | M |
| 4 | Tests and checks | Tests required for new behaviour; edge cases handled; checklists for the coder; baseline checks on the base commit; re-review after self-fix; less wasted effort | M |
| 5 | Architecture fit | Patterns and reuse (built); copy/adapt/new; `architecture.json` (layers, helpers, recipes); layer check; conformance review pass | M–L |
| 6 | Learning from outcomes | Merged diff vs agnts diff → reflect; reverts and later CI failures traced to agnts PRs; precedents with diffs and negative examples; rebase and re-check before push | M |
| 7 | Later | Rule effectiveness and retirement, API acceptance without preview, diff hygiene, docs server, reviewer preferences, subagent exploration | — |

Order of work: 0 → 1 → 2 → 3 → 4 → 5 → 6. Phase 5 step 1 is already built and ships with Phase 0.

## Phase 0 — Bugs

Each is small and confirmed in the code. B1 also cleans the analytics that Phase 1 relies on.

- **B1 CI failures counted as human change requests.** `CIFeedback` logs `EventFeedback` with `OriginWebhook` (`orchestrator/ci.go:68`); the quality queries (`store/postgres/analytics.go:475`, `:559`) and precedents (`store/postgres/precedents.go:92`) count every feedback whose origin is not `system`. Exclude `data->>'ci' = 'true'` in all three and add a separate CI rounds column to the quality table. Precedents no longer show "A reviewer asked: CI failed…".
- **B2 PR review comments never reach reflect.** `reopenWithThreads` (`orchestrator/prfeedback.go:203`) reopens the ticket but never calls `queueReflection`, unlike `RequestChanges` and `Reject` (`orchestrator/actions.go:653`, `:675`). Queue a reflection with the thread texts as the feedback, for human threads only (not agnts's own or bot comments).
- **B3 Checkpoint drops turn scaling.** `codeWithCheckpoint` uses unscaled `s.MaxTurns` for the stop point and the remaining budget (`orchestrator/checkpoint.go:25`, `:52`), while `claudeTurns` scales by `TurnScale(len(t.Repos))` (`orchestrator/orchestrator.go:673`). Compute the scaled total once and use it for both.
- **B4 Second opinion never reaches the coder.** It is saved and shown (`orchestrator/orchestrator.go:947`) but not in the code prompt. Add a short "Second opinion" block to the code prompt: its verdict and concerns; the coder addresses each or says why not under `deviations`.
- **B5 Coverage can never send work back.** Below-threshold coverage is a `minor` finding (`orchestrator/coverage.go:167`) and self-review acts only on blocker and major (`orchestrator/selfreview.go:22`). Make it `major` when the repository turned coverage on with a threshold.

**Done when:** tests cover each fix; the quality table shows CI rounds separately; a PR thread change request produces a reflect run.

## Phase 1 — Benchmark

Without this, no later phase can be judged. Replay already exists (`orchestrator/replay.go`); it is picked by hand and scored only by file overlap.

- **Benchmark set.** A per-workspace list of tickets marked "benchmark": merged code tickets with a clear outcome, 20–30 to start, mixed sizes and repositories. Admin: "Add to benchmark" on a done ticket; `agnts server -- eval bench` replays the whole set.
- **Score against the merged diff**, not agnts's last commit: file overlap with what landed, checks passed, review verdict, conformance findings (from Phase 5), red flags, turns and cost. Store the merged diff when the PR merges (it is needed again in Phase 6).
- **Model as a dimension.** A replay can override the per-stage models, so the report compares prompt version × model.
- **Quality score and cost.** One score per prompt version and model (weighted first-try approval, change rounds, serious findings, merged rate), plus cost per merged ticket. Show a sample-size warning under 10 tickets.

**Done when:** `eval bench` runs the set and the report shows prompt version × model with the score and cost.

## Phase 2 — Thinking

- **Thinking budget.** No thinking or effort setting reaches Claude Code today (`runner/runner.go:467-481`). Add a per-stage `effort` setting (analyze, code, review) and pass it the way the pinned CLI version supports (`--effort`, or `MAX_THINKING_TOKENS` in the env); check which one before building. Default: high for analyze and review, medium for code, high for complex tickets.
- **Stronger analysis for complex tickets.** The analysis decides the plan, the approach and the complexity that picks the review model, yet runs on Sonnet with 60 turns. Default to the coding model for analysis of complex tickets (re-run the analysis on it when Sonnet rates a ticket complex, or let the triage step decide first).
- **Plan validation.** After analysis, the server checks that every footprint file (except new ones), every `patterns[].like` and every `reuse[].where` exists at the base commit (git tree lookup in `vcs/gitrepo`). If any are wrong, resume the analysis session once with the list; if still wrong, drop the bad entries and log it.
- **Test plan and edge cases.** `analysis.json` gains `testPlan` (tests to add or change, by file and what they check) and `edgeCases` (inputs and failures the change must handle). Both go to the coder and the reviewer.
- **Reviewer sees everything.** Today it gets pass/fail only. Add the output of failed checks, coverage of added lines, proof results, the acceptance criteria and their results, and the test plan.
- **Criteria check.** `summary.json` gains `criteria`: for each acceptance criterion, how it is met (test name, file, or "not met: why"). The reviewer checks it.

**Measure:** first-try approval and serious findings per prompt version on the benchmark; cost per merged ticket.

## Phase 3 — Evidence before planning

- **The analysis can run things.** Give the analyze prompt the environment block and the check commands it already gives coding (`orchestrator/prompts.go:513`). Analysis still must not change `/workspace`; it may use `/tmp/agnts-scratch` for experiments.
- **Reproduce first.** For a defect, the analysis tries to reproduce it (a failing test or command in the scratch folder) and records `repro` (command, output, or why it could not). The coder starts from it.
- **Git history.** The analyze prompt asks for `git log` and `git blame` on the footprint files: recent changes, the PRs and tickets behind them (commit links already map commits to tickets).
- **Richer tickets.**
  - Jira: fetch comments, attachments, parent/epic, subtasks and linked issue summaries (`tracker/jira/jira.go:338` fetches only six fields). Keep images and links in the rich-text conversion (`jira.go:515`).
  - Plane: keep images (`tracker/plane/html.go:69`).
  - Images are downloaded into `/agnts/context/ticket/` for Claude to read; all tracker text stays in `<untrusted-data>`.
- **Library versions.** The coding prompt tells the agent to check the installed version (lockfile, `node_modules`, `go doc`, `pip show`) and read the package's code before calling an API it is unsure of. agnts lists the main dependency versions in the environment block.

**Measure:** rejected and change-requested tickets with "misunderstood the ticket" feedback; bug proofs that fail on the first try.

## Phase 4 — Tests and checks

- **Tests required for new behaviour.** Code tickets must add or update tests for what they change, following `testPlan`, unless the repository has no tests where the change is (the analysis says so). The reviewer marks a missing test as `major`.
- **Edge cases.** The coder handles each `edgeCases` entry and says how in the summary.
- **Checklists for the coder.** Give the coder the short "do" part of the language checklists (`orchestrator/review/*.md`) that apply to the files it will change, as a skill: prevent rather than find.
- **Baseline checks.** Run build, lint and tests on the base commit once, cached by commit SHA and command. Failures that already exist on the base are reported to the coder as "already failing; leave them" and do not use up fix attempts or fail the ticket.
- **Re-review after self-fix.** After the self-fix round, review again; allow two rounds (`maxSelfFixes`) when the second review still has blockers.
- **Less wasted effort.**
  - Checks inside the run only at the stop gate, not also "yourself before finishing" (`orchestrator/prompts.go:561`).
  - Read the fact-check A/B result on Analytics; drop the hook if it does not help.
  - Make the drift checkpoint a hook nudge at a third of the turns instead of stopping and resuming the session.

**Measure:** change rounds about tests; CI failures after push; `checks_failed` caused by failures already on main (should drop to zero).

## Phase 5 — Architecture fit

Targets the two problems seen on real tickets: reinvented helpers and logic in the wrong layer.

**Step 1 (built, uncommitted).** `analysis.json` has `patterns` (each footprint file → the existing file it is modelled on, and its layer) and `reuse` (existing helpers to use, with their file). The code prompt has a "Follow the existing code" section: read the file to copy first, use the listed helpers, search before adding any function, keep logic in its layer, and explain exceptions under `deviations`. The checkpoint and the reviewer see them too. Files: `orchestrator/prompts.go`, `orchestrator/design.go`, `orchestrator/design_test.go`.

**Step 2. Copy, adapt or new.** Each pattern gets `kind`:
- `copy`: an existing file does the same job; follow it.
- `adapt`: same layer, new job; follow its conventions (wiring, errors, logging, tests), not its logic.
- `new`: nothing like it exists; `like` names the file to take conventions from, `why` says what was searched, `place` says the directory and why that layer owns it.

A `new` pattern that adds a layer, a dependency or a kind of component other code will copy makes the analysis ask the author first, even for simple tickets (with questions off it proceeds and the review flags it). The code prompt tells `new` files to build only what the ticket needs, with no framework for later. The analysis view in admin and mobile shows patterns with a "new pattern" badge (OpenAPI, generated code, both apps).

**Step 3. `architecture.json`.** The survey writes it next to `brief.md`; it is approved with the brief and editable in admin.

```json
{
  "layers": [{"name": "handler", "paths": ["internal/httpapi/**"], "owns": "parsing, auth, mapping", "mayImport": ["service", "domain"]}],
  "helpers": [{"name": "domain.CleanPath", "path": "internal/domain/relation.go", "for": "normalize a repo-relative path"}],
  "recipes": [{"kind": "API endpoint", "copy": ["internal/httpapi/tickets.go"], "steps": ["..."]}]
}
```

- `helpers` is filled by a cheap scan of exported names in shared folders (util, lib, pkg, domain, common components), described by Claude, capped at about 200.
- The server checks every path at the brief's commit before approval.
- Runs get `/agnts/context/architecture.json`; the analysis fills `layer` from it.

**Step 4. Checks.**
- **Layer check:** after commit, read the imports of changed files (Go, TS/JS, Python, Java, Kotlin), map each file to its layer and flag imports `mayImport` does not allow. Warn by default; a repository can make it block.
- **New helper scan:** list new exported functions, types and components in the diff for the reviewer.
- **Conformance review pass:** every code change gets a pass with the diff, patterns, `architecture.json` and the new helper list. Findings: duplicates an existing helper (named), wrong layer, departs from the file it copies, unapproved new pattern. It feeds the self-review loop.

**Step 5. Learning.** A merged `new` pattern becomes a suggested `architecture.json` entry ("background job → copy `jobs/email.go`") that a person adopts like a suggested rule.

**Measure:** conformance findings per run; change requests tagged reuse or layer (from Phase 6 tagging).

## Phase 6 — Learning from outcomes

- **Merged diff vs agnts diff.** When a PR merges, compare agnts's last commit with what landed, including later commits by people on the branch. If people changed it, queue a reflect run with that diff: "moved X from handler to service", "replaced the hand-written retry with `pkg/retry`". Lessons become suggested rules, tips, or `helpers` and `layers` entries. Reflect tags each lesson: `reuse`, `layer`, `tests`, `style`, `logic`, `other`.
- **Reverts and later failures.** Detect revert commits of agnts commits on the default branch; trace CI failures on the default branch to the agnts commit that introduced them (`CIFailure.FirstSHA` against agnts head SHAs). Both are events on the original ticket, count in the quality score and feed reflect.
- **Better precedents.**
  - Use merged tickets only (done but closed unmerged ones drop out).
  - Include short excerpts of the merged diff (the key hunks, a few hundred lines at most).
  - Add one or two rejected tickets with similar footprints as "what not to do", with the reason.
- **Rebase and re-check before push.** Rebase the branch onto the current default branch, re-run the checks, then push. A conflict goes back to coding with the conflict as feedback.

**Measure:** share of agnts diff lines changed by people before merge (should fall); reverts per merged ticket.

## Phase 7 — Later

- Rule effectiveness: count when a rule is given, applied and violated; flag rules with no effect for retirement; merge near-duplicate suggestions.
- Prompt size: team rules go into the prompt in full and prompts travel through argv. Measure the rendered size, warn near the limit, and move long rule text to a file under `/agnts/context/` (or deliver it as skills) past a threshold.
- API acceptance criteria run without a UI preview; `test` criteria mapped to named tests.
- Diff hygiene red flags: lockfile churn, hand edits to generated files, commented-out code, very large diffs.
- Read-only library docs server for runs, if the security posture allows it.
- Preferences of the people who review agnts's own PRs.
- Parallel subagent exploration in the analysis of complex tickets.

Team intelligence features (review with fixes, knowledge index, onboarding assistant, sprint insights) are a separate plan, to come after this one; they build on Phases 5 and 6.

## Open decisions

| Decision | Default until decided |
| --- | --- |
| Cost: thinking and a stronger analysis model raise cost per ticket by roughly 20–40% | Complex tickets only |
| Read-only docs server for runs | No; read installed packages instead |
| Tests required for every code ticket | Only where the repository already has tests near the change |
| Which tracker first for richer tickets | Jira, then Plane |
| Layer violations | Warn; blocking is a per-repository switch |
| When a `new` pattern needs approval | Only for a new layer, dependency or kind of component |

## Left out, and why

- **Rebase and re-check before push (Phase 6).** The coding container cannot make merge commits (agnts commits the exported tree), and go-git, which the mirrors use, has no merge. Doing it safely needs its own design: a merge step in the runner, conflict feedback to the coder, then the checks again. agnts still warns when the default branch changed the same lines.
- **Drift checkpoint as a hook nudge (Phase 4).** It needs a new agnts-guard hook; the checkpoint keeps stopping and resuming, now with the right turn budget.
- **CI failures on the default branch traced to agnts's merges (Phase 6).** agnts does not record the merge commit a pull request becomes; reverts are traced instead, through commit links.
- **Plane images (Phase 3).** Plane's asset URLs need their own auth; Plane comments are read.
- **Model × prompt version in the quality table (Phase 1).** The benchmark compares models; the live table stays by prompt version.
- **Counts by lesson tag on Analytics (Phase 6).** Lessons are tagged and the tag shows on each suggestion; the Learning tab does not sum them yet.
- **Effort levels xhigh and max.** Only low, medium and high are offered until the runner image's Claude Code is checked for the others (`runner/harness_test.go` sends `--effort low` to the real image).

## Manual testing

Run the stack as usual (`make dev-db`, `make dev-server`, `make dev-admin`); migrations 00057–00059 apply on start. New settings are on Settings → Guardrails: *Thinking effort* (default: high for complex tickets only), *Re-check complex analyses* and *Check the starting commit first* (both on). Repositories → Guardrails has *Block imports across layers*.

1. **CI is not a change request (B1).** On a ticket whose pull request went red in CI, Analytics → Quality shows the round under *CI rounds*, not *Change rounds*, and the ticket can still count as first try.
2. **PR review threads teach (B2).** On a merged-to-be pull request, leave a review comment on the git host and press *Address comments* (or let auto-address do it). Rules → Suggested gets a suggestion from it once the reflect run ends.
3. **Second opinion reaches the coder (B4).** Set Settings → *Second opinion* to a model and run a complex ticket. The coding prompt (ticket → run → transcript) has a *Second opinion* section with its concerns.
4. **Benchmark (Phase 1).** Merge a code ticket's pull request (or *Mark merged*), open it and press *Add to benchmark*. Analytics → Quality → Benchmark: pick a coding model and *Run benchmark* (or `agnts server -- eval bench coding=opus`). When the replays reach review, the Benchmark table shows *Merged lines*: how much of what people merged the replay wrote, next to agnts's original in brackets. `agnts server -- eval report` prints the same.
5. **Score and cost (Phase 1).** Analytics → Quality shows *Score* (with a warning under 10 tickets) and *$/merged* per prompt version.
6. **Thinking and the re-check (Phase 2).** Run a ticket the analysis rates complex. Its log shows "opus re-checked the analysis of this complex ticket…"; the transcripts of the re-check, coding and review runs show `--effort high`.
7. **Paths that do not exist (Phase 2).** When an analysis names a file to copy that is not there, the log says so and the analysis is asked once to fix it; what is still missing is dropped.
8. **Done when (Phase 2).** The analysis view shows *Tests to add or change* and *Edge cases*; the coding prompt has a *Done when* section; the review prompt lists the criteria and what the coder said about each.
9. **Evidence first (Phase 3).** Report a bug as a Jira issue with a comment and a screenshot attached. The analysis prompt has *Investigate before you plan*; the run gets `/agnts/context/ticket/issue.md` (the comment, parent, links) and the image; the analysis view shows *The bug, reproduced* with the command and output, and the coding prompt starts from it.
10. **Baseline (Phase 4).** In a repository with a test that already fails on main, start a ticket. The log shows "test already fails on the commit the work starts from"; the coding prompt has *Already failing before your change*; the ticket reaches review without fix attempts, and the review says the check failed before.
11. **Second self-fix round (Phase 4).** With self-review on, a blocker in the review of a fixed revision sends it back once more; a major does not.
12. **Patterns (Phase 5).** The analysis view lists each file as *copy*, *adapt* or *new pattern*, with the file to follow and the helpers to reuse. A new pattern marked as a precedent asks "agnts will add … Should it?" before coding.
13. **Architecture (Phase 5).** Repositories → Brief → *Update*. The draft comes with an architecture.json (layers, helpers, recipes; files that do not exist are dropped); *Approve* approves both. Edit it under *Architecture*. Runs list `/agnts/context/architecture.json` under Team knowledge.
14. **Layer check (Phase 5).** Ask for a change that makes a handler import the store (with the architecture saying it may not). The review page shows a *Team rule broken* red flag starting with "layer:". Turn on *Block imports across layers* and it becomes a blocker that agnts's own review sends back. The review prompt has *Fit with the code base* listing the new exported names.
15. **Merged patterns (Phase 5).** Merge a ticket whose analysis added a new pattern: Rules → Suggested gets "Copy … for new …".
16. **Learning from merges (Phase 6).** Edit agnts's branch on the git host (swap in a helper), then merge. The ticket log shows "before merging, people added N and removed M of agnts's lines"; a reflect run follows and its suggestions carry a tag (reuse, layer, tests, …). Analytics → Quality shows *People edits*.
17. **Reverts (Phase 6).** Revert a merged agnts pull request on the default branch. The ticket log shows "people reverted this work", a reflect run follows, and Analytics → Quality counts it under *Reverted*.
18. **Precedents (Phase 6).** A new ticket touching the same files as a merged one gets `/agnts/context/precedents.md` with "From what merged" diff excerpts, and a rejected one under "Rejected: what not to do".

