# agnts Continue Rejected Tickets — Plan

Oct 17, 2026 · v1 implemented (server, admin panel, mobile); manual check on a real ticket still to do

## Overview

Today **rejected** is a dead end: `domain/ticket.go` gives it no transitions, and both clients only show "Rejected" with no buttons. A person who rejected by mistake, or who changed their mind ("take it myself" on a failed ticket, then had no time), has to create the work again from scratch.

This plan adds a **Continue** action to rejected tickets, on the admin panel's ticket page and on the phone's ticket screen. It picks the work up where it stopped. An optional note (and files) tells agnts what to do differently, the same way a retry note does.

What a reject does today (`orchestrator/actions.go` `Reject`), and what Continue has to undo or work around:

| Reject does | Continue does |
|---|---|
| State → `rejected`, review and preview runs dropped, running stage cancelled | Moves to the resume state (below) and wakes the queue |
| Tracker issue → the `rejected` status | Moves it back to `started`, or to `in_review` when resuming at review |
| Queues a reflection on the reason (when Reflect is on) | Nothing: the lesson still stands |
| Notes "dismissed" on the reviewer's profile | Nothing |
| **Deletes the local branch** when no PR was opened | Puts the branch ref back at the saved head (see "The branch") |
| Releases tickets that wait for it (`Releases()` is true for rejected) | Tickets that already started keep going; ones that have not started wait for it again |

## Decisions

- **Who can continue**: the same people who can reject (`canEdit`). Not for a review of someone else's pull request (`KindReview`: Dismiss is final there, the decision went to the git host), not for replays (`ReplayOf != ""`), and not when the repository is archived.
- **Where it resumes**: from the stage it was rejected at, saved on reject in the existing `ResumeState` column (no migration):

  | Rejected while | Resumes at |
  |---|---|
  | `new`, `analyzing` | `new` (queued for analysis) |
  | `waiting_for_answers` | `waiting_for_answers` (questions and answers kept) |
  | `coding`, `testing` | `coding` |
  | `waiting_for_review` | `waiting_for_review` with no note, `coding` with one (the note is a requested change) |
  | `failed`, `rate_limited` | `failed`, keeping its own `ResumeState`, so the person sees the error again and picks Retry |

  Tickets rejected before this ships have no saved stage. They fall back to the `from` of their last `state_changed` event into `rejected`; if there is none, they go to `new`.
- **The note**: optional, up to 4000 characters, plus up to 10 uploads. When it resumes at `coding` it becomes `Feedback` (like Request changes: `Revision++`, `SelfFixes` reset). When it resumes at `new` it goes into the analysis prompt the way a retry note does. At `waiting_for_answers` or `failed` a note is refused (no Claude run follows), the same as Retry's rule for `pushing`.
- **Start over** is a second, smaller button: it does what `RestartWithUpdate` does without the tracker update (`ResetWork(true)`, questions dropped, back to `new`). It is only offered when nothing was pushed (`!Pushed()`).
- **No new push kind.** The person who continues is the actor, so `kindFor` stays silent for `rejected → *`. The steps after it push as usual.
- **Telegram and MCP**: out of scope for v1.

## The branch

`Reject` calls `dropBranch` when no PR was opened. It removes only the ref (`gitrepo.DeleteBranch`); the commits stay in the mirror, because nothing runs `git gc` on it. Every repository's `HeadSHA` is still on the ticket.

- New `BranchRestorer` port (next to `BranchCleaner`) with `RestoreBranch(ctx, repo, branch, sha)`: it sets the ref back if the commit object exists, and returns `ErrNotFound` if it does not.
- Continue restores every repository's branch before the transition. If any one is missing (mirror re-cloned, or never had commits), that repository's work is reset (`ResetWork` for it) and the ticket resumes at `new` instead, with a warning event: "the earlier commits are gone; agnts starts over".
- Tickets with a PR never lost their branch (Reject keeps it), so there is nothing to restore. If the PR was **closed** on the host meanwhile, Continue is still allowed. Pushing then opens a new PR the way it does for any closed one today. Check this in step 1; if push does not handle it, refuse Continue with "the pull request was closed on <host>: reopen it first".

## Phase 1 — Server

1. **domain** (`ticket.go`): transitions `StateRejected: {StateNew, StateWaitingForAnswers, StateCoding, StateWaitingForReview, StateFailed}`. `Terminal()` stays true for rejected; only the new action uses these edges. Add `CanContinue(t Ticket) bool` (not a review, not a replay) next to `CanReopenForCI` and a `ContinueState(from TicketState) TicketState` mapping, with table tests.
2. **orchestrator** (`actions.go`):
   - `Reject` saves `x.ResumeState = domain.ContinueState(x.State)` in its mutation; for `failed`/`rate_limited` it saves the state itself and keeps the old resume state in a new `ResumeAfter` field. Alternatively, store both in the event `Data` and read them back; pick whichever reads cleaner after looking at `saveTicket`.
   - New `Continue(ctx, key, note, files, origin)` and `StartOver(ctx, key, origin)`:
     check `CanContinue`, archived repository, and that no other open ticket has the same ticket number (`OpenTicketWithNumber`, the same check `ticketNumber` does);
     restore branches; link attachments first (as `RequestChanges` does);
     `Transition` with event "continued" / "continued: <note>" / "started over";
     `trackerMove(started | in_review)`; `Wake()`.
   - Tests in `actions_test.go`: each row of the resume table, a note at review → coding with feedback, a note refused at answers, a review/replay refused, a missing branch → new with a warning, a tracker move, a duplicate ticket number refused, a ticket rejected before this change (event fallback).
3. **vcs/gitrepo**: `RestoreBranch` plus a test (delete a branch, restore it, resolve the head; unknown SHA → `ErrNotFound`).
4. **API** (`shared/openapi/openapi.yaml`): `POST /tickets/{key}/continue` with an optional body `{ note, attachments }` (same schema as retry), and `POST /tickets/{key}/start-over`. Both return `TicketOK`; 409 when the ticket is not rejected or cannot continue. Then regenerate `httpapi/gen`, the admin's `schema.gen.ts` and the Dart `agnts_api` package. Handlers in `httpapi/tickets.go` next to `RetryTicket`.
5. **Ticket view**: add `canContinue` and `canStartOver` booleans to the ticket response, so neither client duplicates the rules.
6. **Side effects to check, not change**: `ciwatch/triage.go:403` (a rejected CI-fix ticket gives up its failure group; a continued one does not get it back, which is acceptable), insights (the ticket stays counted in that day's Rejected), `preview.go:554` cleanup (only terminal tickets; fine).

## Phase 2 — Admin panel

`apps/admin/src/pages/TicketPage.vue`, the `<!-- rejected -->` block (and the `pull && tk.state === 'rejected'` block, which only applies to reviews, so it stays as is):

- Show the reject reason (`stopReason`), then a "Continue" section: a note textarea + `FileAttach` (the same pair the failed block uses), and a hint saying where it will resume ("Goes back to review", "Goes back to coding with your note", and so on).
- Buttons: **Continue** (primary) and **Start over** (only when `canStartOver`, behind a confirm: "Drops the analysis, answers and commits").
- New `Action` values `'continue' | 'start-over'` in the `act` mutation.
- i18n keys in `shared/i18n/{en,ru,uz}/` (ticket namespace): `continueBtn`, `continueNote`, `continueNoteHint`, `continueTo.*`, `startOver`, `startOverConfirm`, `rejectedReason`.
- `TicketsPage`/list filters: nothing changes, the ticket simply leaves the rejected filter.

## Phase 3 — Mobile

`apps/mobile/lib/features/tickets/ticket_screen.dart`:

- `case TicketState.rejected` (around line 467): the reason in a `HelpBox`, the note field + files (reuse the `_retryNote`/`_retryFiles` controllers' pattern, with their own instances), and the "will resume at" hint.
- Bottom buttons (the switch around line 1054): **Continue** (filled) and, when `canStartOver`, **Start over** (outlined, confirm dialog). Hidden when `!canEditProvider`.
- `_continue(t)` calls `continueTicket` like `_retry` calls `retryTicket`.
- Strings in `app_en.arb`, `app_ru.arb`, `app_uz.arb` (and regenerate `app_localizations*.dart`), plus `shared/i18n/*/mobile.json` if those keys are mirrored there.
- `ticket_controls.dart:396` (`open` = not done and not rejected) needs no change: after Continue the state is no longer rejected.

## Phase 4 — Tests and rollout

- Server: the tests above, `go test ./...`.
- Admin: a `TicketPage` test for the rejected block (buttons shown by `canContinue`/`canStartOver`, the request body).
- Mobile: a widget test for the rejected state (buttons, disabled while uploading).
- Manual: reject a ticket at each stage (new, answers, coding, review, failed), continue it, and check the branch, the tracker status and the phone screen. Then reject one with no PR, restart the server and continue it to check the branch restore.
- Deploy as usual (`deploy.md`); there is no migration.

## As built

Where the code differs from the phases above:

- **No change to `Reject`.** Every transition already records `data.from` on its event, so `StateSince` now returns `From` and Continue reads the stage the ticket was rejected at from there. Tickets rejected before this release work the same way.
- **Continue into `failed`/`rate_limited`** reuses the message of the ticket's last move into that state, so the page shows the original error again (it comes from that event).
- **The ticket response** carries `continueTo` (where Continue goes without a note; absent when it cannot continue) and `canStartOver`. Start over is also hidden for Swagger tests (no analysis to redo).
- **Push notifications**: `kindFor` stays silent for any move out of `rejected`.
- **The reject confirmation** now says the work can be continued later.
- **Tests**: `domain/ticket_test.go` (matrix, `ContinueState`, `CanContinue`), `orchestrator/continue_test.go` (review with and without a note, answers refuse a note, failed shows its error and retries, lost commits start over, start over), `gitrepo` `TestRestoreBranch`, `httpapi` routes, `notify` `TestContinueIsQuiet`. There are no widget tests for the admin page or the mobile screen: neither has a harness that renders the whole ticket page.

## Decided

1. A ticket rejected at review with no note goes straight back to review.
2. No time limit on Continue.
3. No Telegram button.
