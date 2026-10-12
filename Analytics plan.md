# agnts Analytics v2 (tabs + new sections) — Plan

Oct 12, 2026 · implemented (see Implementation notes)

## Overview

The analytics page is one long scroll of 6 KPI tiles and ~15 cards, with speed, cost, quality and repos mixed together and the insights at the very bottom. It also stops at "pushed": it never says whether agnts's pull requests get merged, and features that keep their own data (CI watcher, questions, follow-ups, lessons, rules, reviewer notes) have no analytics at all.

This plan splits the page into tabs, as the settings page now is, moves insights to the top, and adds sections built from tables we already have. The only new data is one column recording when an agnts pull request was closed without merging.

```
Analytics                                                    [7d|30d|90d]  [Export CSV]
 Overview   Delivery   Quality   Learning   Cost   Repos
┌──────────────────────────────────────────────────────────────────────────────────────┐
│ Insights: 3 tickets waited > 1 day on your answer · api has no CLAUDE.md             │
│ Pushed 42 ▲  Success 81% ▲  First try 64% ▼  Merged 35 ▲  Cost/ticket $1.90 ▼        │
│ [throughput bars ..................................]  [outcomes donut]               │
└──────────────────────────────────────────────────────────────────────────────────────┘
```

**Goals**

- Someone can answer each of these in one click: *Is agnts shipping? Do its PRs get merged? Where does time go? What does it cost? Is it getting better?*
- Every new section reads existing tables. The one migration adds `tickets.closed_at` (see PR outcomes).
- Tabs load their own data, so the overview stays fast at 90 days.

**Out of scope for v1:** the mobile app (admin only until the numbers settle), per-member analytics (who approves fastest), custom date ranges, charts on mobile, alerts on thresholds, and "did stops drop after this rule was added" (needs before/after attribution; see Later).

## Layout: tabs

Route `analytics/:tab?` (same pattern as `settings/:section?`); unknown or missing tab → `overview`. The period selector and CSV export stay in the header and apply to every tab.

| Tab | Cards (existing → **new**) |
|---|---|
| **Overview** | Insights (moved to top), KPI row (+ **Merged**, + **Cost per pushed ticket**), throughput, outcomes donut, busy hours |
| **Delivery** | **PR outcomes**, **Cycle time**, speed (agnts vs waiting), time per step, **Questions** |
| **Quality** | Turns, stop reasons, quality by prompt version, replay eval, **CI health** |
| **Learning** | **Learning loop** (lessons, rules, reflections), **Follow-ups**, **Reviewers** |
| **Cost** | Token spend, spend by stage, models table (+ **cost column**), plan usage |
| **Repos** | Repo table (+ **merge rate**, + **CI failures**, + **questions per ticket** columns) |

Learning is its own tab, because putting learning, follow-ups and reviewers into Quality would make it as long as the page is today.

## New sections

### 1. Cost per pushed ticket · cost per model (frontend only)
- Cost per pushed ticket = `current.spend.costUsd / current.pushed`, with a change vs. the previous period; `—` when nothing was pushed.
- Models table: add cost, summed from `spendByStage` grouped by model. No API change.

### 2. PR outcomes (Delivery)
Source: `tickets.pr_number`, `tickets.merged_at`, new `tickets.closed_at`, the `done` state event.

`merged_at` is already reliable: it is set by the merge webhook, by `CheckMerges` polling the git host for done tickets whose PR is not known to be merged, or by "mark merged" by hand.

**New: closed without merge.** Migration `00039_ticket_closed_at.sql` adds `tickets.closed_at timestamptz`. It is set when the PR webhook reports `state = closed` without a merge (`domain.PullClosed`), and by `CheckMerges`, which today asks `PRMerged` (a bool). That becomes `PRState` returning open / merged / closed, so closed PRs are found without a webhook too. A closed PR leaves `UnmergedPRs`, so it is not polled forever. Reopening clears `closed_at`.

- PRs opened in the period: **merged**, **closed without merge**, **still open**.
- **Merge rate** = merged ÷ (merged + closed). Open PRs are left out, so new ones do not drag it down.
- **Push → merge time**: typical and slow (p50 / p90).
- **Open longer than 7 days**: up to 5 tickets, linked.

### 3. Cycle time (Delivery)
Source: `events` (first `state_changed` → `done`), `tickets.merged_at`.
- Both end points: **picked → pushed** (agnts's speed) and **picked → merged** (real delivery), p50 / p90, per day as two lines. Tickets not merged yet count only in the first.
- **Slowest 5 tickets** in the period with where the time went (agnts / waiting on you / waiting for review), using the existing step data.

### 4. Questions (Delivery)
Source: `questions`.
- Questions asked, share of tickets that asked anything, **time until you answer** (p50 / p90 of `answered_at − created_at`), unanswered now.
- Per repo in the Repos table: questions per ticket (a high number points to a missing CLAUDE.md or rules).

### 5. CI health (Quality)
Source: `ci_failures`, `tickets.ci_fixes`.
- Failures seen in the period by type (code, test, config, dependency, infra, flaky): stacked bar.
- **Auto-fixed** (`ticket_key ≠ ''` and `fixed_at` set) vs open, and **time to fix** (`fixed_at − first_seen_at`).
- **Flakiest jobs**: top 5 by `flaky_count`, linked to the CI page.
- agnts's own PRs: red checks fixed before review (`tickets.ci_fixes`).
- Hidden when the workspace has no CI watcher data.

### 6. Learning loop (Learning)
Source: `lessons`, `rules`, `reflections`.
- Lessons created vs learned (`learned_at`), by category.
- Rules added in the period, split by **learned from a ticket** (`source_ticket ≠ ''`) vs written by hand.
- Reflections run on rejected or changed tickets, and how many rules they suggested (`suggested`).

### 7. Follow-ups (Learning)
Source: `ticket_suggestions`.
- Suggested / accepted / dismissed / open, by type (prerequisite, split, unfinished, gap) and by source (analyze, work, review).
- **Accept rate** = accepted ÷ (accepted + dismissed). A low rate means the suggestions are noise.

### 8. Reviewers (Learning)
Source: `reviewer_notes`.
- Per reviewer login: re-review requests, dismissed findings, manual notes. Top 10, with repo.

## API

Keep `GET /analytics` as is (Overview, Quality minus CI, Cost and Repos already come from it), plus the new repo columns. Add one endpoint per new tab so the heavy queries run only when that tab is open:

| Endpoint | Returns | Store function |
|---|---|---|
| `GET /analytics/delivery?days=` | PR outcomes, cycle time, questions | `postgres.DeliveryStats` |
| `GET /analytics/ci?days=` | CI health | `postgres.CIStats` |
| `GET /analytics/learning?days=` | lessons, rules, reflections, follow-ups, reviewers | `postgres.LearningStats` |

Each returns `current` and `previous` periods like `/analytics`, so `DeltaTag` works unchanged. Schemas go in `shared/openapi/openapi.yaml`, then `make gen` (the mobile client regenerates too, but the mobile app shows none of it in v1). `Ticket` also gets `closedAt`. `Merged` for the Overview KPI is added to `PeriodStats`.

New insights (in `admin/insights.go`): "merge rate below 50%", "you take over N h to answer questions", "follow-up accept rate under 20%", "the same flaky job failed N times".

## Phases

1. **Tabs + quick wins**: route param, tab bar, move cards, insights on top, cost per ticket, cost per model. Frontend only.
2. **Delivery**: `closed_at` migration, webhook + `PRState` for GitHub and GitLab, `/analytics/delivery`, PR outcomes, cycle time, questions, Merged KPI, repo merge-rate column.
3. **CI health**: `/analytics/ci`, CI card, repo CI column.
4. **Learning**: `/analytics/learning`, learning loop, follow-ups, reviewers.
5. **Insights + docs**: new insight kinds, `docs/content/*/analytics.md`, i18n (en, ru, uz), CSV export per tab.

Each phase ships on its own.

## Decisions

- **Learning** is a separate, 6th tab.
- Closed-without-merge PRs are recorded (`tickets.closed_at`), so merge rate is real.
- Cycle time shows both end points: pushed and merged.
- Admin only for v1; mobile later.

## Open questions

None left: CSV export saves the open tab's main table.

## Implementation notes

- **Closed pull requests**: migration `00039_ticket_closed_at.sql`; `vcs.CloseSink` (GitHub `closed`/`reopened`, GitLab `close`/`reopen`) → `Orchestrator.MarkPRClosed` → `store.SetPRClosed`, event `pr_closed`. `MergeChecker.PRMerged` became `PRState` (open / merged / closed); `CheckMerges` records closes too, and `UnmergedPRs` skips closed pull requests, so neither merge checks nor CI polling ask about them again.
- **Store**: `postgres/analytics_tabs.go` (`Delivery`, `CIHealth`, `Learning`); `Analytics` gained `Period.Merged/Closed`, repo merged/closed/asked/analyzed/CI columns, and follow-up and flaky-job figures for the insights. Medians and 90th percentiles use `percentile_cont`.
- **API**: `GET /analytics/delivery`, `/analytics/ci`, `/analytics/learning` (`httpapi/analytics.go`); insight kinds `mergeRate`, `slowAnswers`, `followUpsNoise`, `flakyJob` (`admin/insights.go`).
- **Admin**: route `analytics/:tab?`; `pages/AnalyticsPage.vue` is the shell (period, CSV, tab bar, one query per tab); tabs in `components/analytics/`. Agnts time per ticket moved to Delivery and average turns to Quality, so each tab's top row is about that tab. `LineChart` leaves gaps for days without a value.
- **Mobile**: the Dart client and ARB files were regenerated; the analytics screen words the four new insights. It shows no new sections (admin only for v1).
- **Tests**: `postgres/analytics_tabs_test.go`, `admin/insights_test.go`, webhook and `CheckMerges` closed-PR tests, `PRState` tests for GitHub and GitLab, `AnalyticsPage.test.ts`, `LineChart.test.ts`, `analytics.test.ts`.

## Later

- Rule impact: stops and change rounds on a repo before vs after a rule was added.
- Per-member view: who answers questions and approves fastest.
- Custom date range and weekly email digest of the Overview tab.
