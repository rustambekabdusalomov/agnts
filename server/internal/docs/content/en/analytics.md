# Analytics

How well agnts works for you over time. Pick 7, 30 or 90 days; every number is compared with the period before it, and green changes are improvements. The page has six tabs, and **Export CSV** saves the open tab's main table.

## Overview

Insights first: short conclusions drawn from the numbers, with what to change. Then the key numbers (tickets pushed, success rate, approval on the first try, pull requests merged, time waiting on you, cost per pushed ticket), tickets per day and how they ended, and when agnts works during the day.

## Delivery

What happens after agnts pushes. **Pull request outcomes**: pull requests opened in the period, merged, closed without merging or still open, and the merge rate (merged out of merged or closed). Pull requests open for more than a week are listed. **Cycle time**: typical time from picking a ticket up to pushing, and to merging. **Questions**: how many tickets asked something before coding, and how long answers take. The **slowest tickets** show where their time went: agnts working, waiting for answers, waiting for review, or queued. Times are medians; the slow figure is the slowest one in ten.

Merges and closes come from the git host's webhook. Without one, agnts checks open pull requests on the git host itself.

## Quality

Turns per ticket, why runs stop, agent quality by prompt version and replay results. **CI health** (when CI watching is on): failures per day by cause, how many agnts fixed itself and how fast, the flakiest jobs, and red checks on agnts's own pull requests fixed before your review.

**Guardrails by prompt version**: actions agnts-guard refused, tickets the stop gate saved, stalls, bug fixes proven, the share of review findings people adopted, tokens per done ticket, and the fact check group's first-try rate next to everyone's.

## Learning

Whether agnts learns from your feedback: lessons written and learned, rules suggested from tickets and adopted, rules you wrote, reflections on changed or rejected tickets, how many suggested follow-ups you accept (by type and by the step that found them), and which reviewers send the most notes.

## Cost

Tokens Claude used in the period, input and output per day, with cache traffic listed apart; spend by stage and by model; cost per pushed ticket; and peak plan usage per day. The dollar figure is Claude Code's estimate at API prices; on a Claude plan you are not charged it.

## Repositories

How each repository performs: tickets, success rate, merge rate, turns, agnts's time, questions per ticket, CI failures and whether it has a CLAUDE.md.

## Developers

Only the workspace's owner sees this tab, and only when **Settings → Performance reviews** is on. It is off by default: automated scoring of employees falls under GDPR Article 22 and, in some countries, needs a works council's agreement. The numbers are input to your review, not a verdict.

Every delivered ticket gets a complexity score of 1, 2, 3, 5, 8 or 13. A ticket is delivered when it is done in agnts, or its Jira or Plane issue is resolved as done, and one of its commits is on a default branch. The score comes from the diff: the model reads it, and facts the code computes (changed lines, risky areas such as concurrency, auth, money and data migrations) cap how high it may go. Each author's share follows the distinct days they committed, with at least 20% each when two to four people share a ticket. agnts's own commits count for its own row, never for the person who reviewed them.

A month closes on the 3rd of the next month, or later while scores are still coming in (up to the 10th). A closed month keeps its numbers; later changes (an override, a mapped git identity, a confirmed regression) show in brackets until you close it again. Reverts take away the reverted share of a ticket's lines, and each confirmed regression 30% of its points. Open an author for their deliveries, to override a score, or to export everything held about them for a request to see their data.
