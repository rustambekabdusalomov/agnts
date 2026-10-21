# agnts Agent Intelligence — Plan

Oct 8, 2026 · implemented (phases 0–6), prompts version 2026-10-08.1

## Overview

Every run starts from almost nothing: the ticket, `Repo.ClaudeMD`, team rules, and (for coding) the analysis plan and the author's answers. The agent rediscovers the architecture by grepping, picks the first approach that works, and never hears what the humans told it on earlier tickets. That is what makes it feel like vibecoding.

A senior engineer working with Claude differs in judgment, not typing: they load the right context, weigh approaches against the architecture and the business, cut scope, read the diff for red flags, stop Claude when it drifts, think about shipping, and remember what reviewers said last time. This plan gives agnts those habits, each one reviewable by a person.

**Principles**

1. Every piece of knowledge that reaches a prompt was approved by a person (the brief, business context, suggested rules), or comes from work a person approved (precedents and their reviewer feedback). agnts proposes; people decide.
2. Measure first: every change below is judged by the quality numbers of Phase 0, per prompt version.
3. Reuse what exists: rules, questions, the review run, the event log. No vector database, no new services.
4. Context goes to the agent as files under `/agnts/context/`, named in the prompt; prompts stay short (they go through argv).

## Phases

| # | Phase | What it adds |
| --- | --- | --- |
| 0 | Quality metrics | `prompt_version` and fix attempts on runs; an "Agent quality" table on Analytics: first-pass approvals, change-request rounds, fix attempts, review blockers, footprint recall, red flags, per prompt version |
| 1 | Repository brief | A `survey` run writes a brief per repository (architecture, layers and allowed dependencies, recipes, golden examples, conventions, pitfalls). A person approves or edits it; analyze, code and review read it. Refreshed after merges. |
| 3 | Design step | Complex tickets get 2–3 approaches with trade-offs (fit with the brief, reversibility, blast radius, compatibility); one is chosen with a reason. With "ask first", the author picks. |
| 3b | Scope and ship notes | The analysis says what it will **not** do, and how the change ships: migrations, compatibility, rollout order, rollback. The code run follows both. |
| 4 | Self-review loop | The review run gets an `architecture` category. When it finds a blocker or major problem, agnts sends it back to the coder once, before a person looks (setting, on by default). |
| 4b | Red flags and drift checkpoint | A deterministic scan of the diff for skipped tests, removed assertions, silenced linters, empty catches, new TODOs, new dependencies. A checkpoint partway through coding compares the files touched so far with the footprint and the chosen approach. |
| 5 | Learning from feedback | After a change request or a rejection with a reason, a `reflect` step distils durable conventions and proposes them as suggested rules; a person accepts (they go through the normal rule review) or dismisses them. |
| 2 | Business context | Workspace and repository context notes (glossary, invariants, roles) written by people; precedents: the most similar done tickets, with their approved summary, files and reviewer feedback. |
| 6 | Replay evaluation | Replay done tickets against a new prompt version and score them against the approved change. |

Order of work: 0 → 1 → 3/3b → 4/4b → 5 → 2 → 6.

## Phase 0 — Quality metrics

- `runs.prompt_version` (the orchestrator's `PromptVersion` constant, bumped whenever prompts change meaningfully) and `runs.fix_attempts`.
- Analytics gains `quality`: one row per prompt version over the period, counting tickets whose first coding run used that version:
  reached review, approved first time, average change-request rounds, average fix attempts, rejected, reviews with blockers or majors, average footprint recall, red flags, self-fixes.

## Phase 1 — Repository brief

- Table `repo_briefs` (one per repository): `body` (approved, used by prompts), `draft` (the latest survey, waiting for approval), `status` (idle, pending, surveying, failed), `commit_sha`, `merges_since`, `error`.
- The survey is a queue class like rule reviews. Triggers: "Survey" on the repository page, the first ticket analysed in a repository without a brief, and every 10 merged tickets (an update, not a rewrite: the prompt gives the old brief and the commit it was written at).
- Approve copies the draft into `body`; a person may edit the body at any time.
- Runs get `/agnts/context/brief.md`; the analyze, code, report and review prompts tell Claude to read it first and to follow it, or say why not.

## Phase 3/3b — Design step, scope and ship notes

`analysis.json` gains:

```json
"approaches": [{"title": "...", "sketch": "...", "pros": ["..."], "cons": ["..."], "fit": "how it fits the brief and rules", "chosen": true, "why": "..."}],
"outOfScope": ["what this ticket will not do"],
"ship": {"migrations": "...", "compatibility": "...", "rollout": "...", "rollback": "..."}
```

- Approaches are required for complex tickets; simple ones may give one.
- With "ask first", a complex ticket with two or more approaches asks "Which approach?" (the chosen one first, marked recommended).
- The code prompt gets the chosen approach, out-of-scope list and ship notes, and must report deviations in `summary.json` (`deviations`).
- The ticket page shows them under the analysis.

## Phase 4/4b — Self-review, red flags, drift checkpoint

- Review category `architecture`: layer and dependency violations against the brief, files outside the footprint without a reason.
- Setting `selfReview` (default on): a review with a blocker or major finding sends the findings back to the coder once per change request by a person (`tickets.self_fixes`), origin system. While that review may still send it back, the ticket reaches review quietly (`quiet_review`: no "needs you" notification); it is announced with a `review_ready` event once the review lets it through, fails, or waits for the Claude limit.
- Red flags (`domain/redflag.go`): added lines that skip or focus tests, removed assertions in test files, deleted test files, `eslint-disable`/`nolint`/`@ts-ignore`/`type: ignore`, empty catch blocks, new TODO/FIXME, new dependencies in manifests. Stored with the code result, shown on the ticket, and given to the reviewer to confirm.
- Drift checkpoint: the first coding invocation is capped at a third of the turns. If it hits the cap, agnts lists the files changed so far, flags those outside the footprint, and resumes with a checkpoint prompt: compare with the chosen approach, re-plan if drifting, then continue.

## Phase 5 — Learning from feedback

- Rules gain `source_ticket` and the status `suggested`. A suggested rule never reaches prompts.
- After a person requests changes or rejects with a reason, the next learn-class run of that ticket (`reflect`) reads the feedback, the diff and the rules, and proposes at most two general conventions not already covered.
- Accept moves a suggestion to pending (the normal rule review); dismiss deletes it.

## Phase 2 — Business context

- Rules gain `kind`: `rule` (an instruction) or `context` (business knowledge: glossary, invariants, roles). Context notes go through the same review and reach prompts as `/agnts/context/business.md`.
- Precedents: up to 5 done tickets in the same repository with the most footprint overlap and text similarity, with their approved summary, changed files and the feedback they got, in `/agnts/context/precedents.md`.

## Phase 6 — Replay evaluation

- `agnts server -- eval replay KEY...` (and the API) creates a local replay ticket per done ticket, pinned to the commit the original started from, with the same text and answers, no questions.
- `agnts server -- eval report` scores replays against the originals: checks passed, file overlap with the approved change, reviewer verdict, turns and cost, per prompt version.

## Known gaps (Oct 21, 2026)

A review of the pipeline on real tickets found these gaps in what this plan built; `Code quality plan.md` fixes them:

- **Metrics:** change-request rounds count CI failures as human feedback, so the Agent quality table and precedents are skewed (Code quality Phase 0, B1).
- **Reflect:** review threads on the pull request never reach it (Phase 0, B2). Rules are deduplicated by exact title and their effect is not measured (Phase 7).
- **Drift checkpoint:** drops the extra turns of tickets in several repositories (Phase 0, B3) and interrupts the run mid-step (Phase 4).
- **Brief:** layers and examples are free text, so nothing can check against them, and cited paths are not verified (Phase 5, `architecture.json`).
- **Precedents and replay:** use done tickets and agnts's own last commit instead of what merged; no diffs, no negative examples, no model comparison (Phases 1 and 6).
- **Self-review:** runs once and the fix is not reviewed again (Phase 4).

## Manual testing

Run the stack as usual (`make dev-db`, `make dev-server`, `make dev-admin`); migrations 00027–00031 apply on start. Settings → Runs has the new switches: *Fix review findings first* (selfReview), *Learn from your feedback* (reflect) and *Survey repositories* (autoBrief), all on by default.

1. **Brief.** Repository → Brief tab → Survey. When the draft appears, read it, then Approve (or Edit/Write it yourself). Create a task in that repository: its live log and prompt mention `/agnts/context/brief.md`. A repository's first analysed ticket queues a survey by itself.
2. **Design step.** Create a complex task with "ask first" (e.g. "add soft delete to tickets, with an API flag and a migration"). The ticket page shows Approach, alternatives, Out of scope and Shipping, and asks "Which approach…?" when there are real alternatives. After coding, the review step shows the same plus "Departed from the plan".
3. **Red flags.** Ask for a change that tempts skipping (e.g. "make the failing test pass" in a repo with a broken test). The Review tab lists red flags; the log shows a `red_flags` event; agnts's review gets them to verify.
4. **Self-review.** With auto review and self-review on, a review with a blocker/major finding moves the ticket back to coding with the findings as feedback (log: "agnts's code review found N serious problems…"); you get the "needs you" notification only once it comes back clean or after the one round.
5. **Drift checkpoint.** With a footprint in the analysis and max turns ≥ 45, a long coding run logs `checkpoint after N turns: …` and resumes with the checkpoint prompt.
6. **Learning from feedback.** Request changes with a general remark ("we never put SQL in handlers; use internal/store"). A reflect run follows; Rules shows a *Suggested* rule linked to the ticket: Adopt (review), Adopt as written, Edit, or Dismiss (never suggested again).
7. **Business context.** Rules → Add → Kind: Business context (e.g. "a payment is refunded at most once; amounts are in tiyin"). After its review, runs get `/agnts/context/business.md`. Done tickets of the same repository reach new runs as `/agnts/context/precedents.md`.
8. **Metrics and replays.** Analytics → Agent quality compares prompt versions (old tickets show "before tracking"). On a done code ticket press Replay (or `agnts server -- eval replay KEY`); when it reaches review, Analytics → Replay evaluation (or `agnts server -- eval report`) compares it with the original. Reject replays when done; they can't be approved.
