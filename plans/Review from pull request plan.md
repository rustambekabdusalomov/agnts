# agnts review from a pull request page, with draft comments — Plan

Oct 15, 2026 · implemented (see Implementation notes)

## Overview

Developers often get a task that just says "Review pull request !412". Today agnts reviews a pull request only when the sync finds it **assigned to** (or review-requested from) the git host token's user. A pull request that waits for someone else, or that the sync skipped (draft, sync off), cannot get an agnts review at all.

And when a review exists, posting it is all-or-nothing per commit: "Post review" sends the summary and the ticked findings in one go, the rest are gone from view, and the review cannot be posted again until new commits arrive and a new review runs.

This plan does two things:

1. **Review with agnts** on any open pull request page (and pull request list row) creates a review ticket for it on the spot. The ticket goes through the existing review pipeline (fetch → review → waiting for you).
2. **Draft comments.** Every comment the agents write (the summary and each finding) becomes a **draft stored in agnts**, shown on the diff next to the real host threads. You accept, edit or dismiss each one. Only accepted drafts are **published** to GitHub/GitLab, as real comments in one review. Everything else stays in agnts as a draft (or dismissed), visible to the workspace and never sent.

```
!412  Add coupon expiry                       api · open · review API-PR412 · 5 drafts
┌────────────────────────────────────────────────────────────────────────────────────┐
│ src/coupons/apply.go                                                               │
│  41  if c.ExpiresAt.Before(now) {                                                  │
│  42 +    return ErrExpired                                                         │
│      ┌ alice · 2h  Shouldn't this compare in UTC?                (on GitLab)       │
│      └ reply…                                                                      │
│      ┌ ◇ agnts draft · major · correctness                                         │
│      │ `now` is local time; ExpiresAt is stored in UTC…                            │
│      └ Accept ✓   Edit   Dismiss                                                   │
│  43  }                                                                             │
│                                                                                    │
│ Review drafts: 2 accepted · 2 drafts · 1 dismissed     [Publish 2 to GitLab]       │
└────────────────────────────────────────────────────────────────────────────────────┘
```

**Goals**

- From any open pull request in a connected repository, one click starts an agnts review, owned by the person who clicked.
- Agent comments never reach the git host without a person accepting them. Accept is per comment; text can be edited before publishing.
- Accepted comments go out together as one review (GitHub review / GitLab draft notes published at once), so the author gets one notification.
- Drafts not accepted stay in agnts with their state, survive re-reviews (matched by finding key), and teach the reviewer profile what this person considers noise.
- Publishing is repeatable: accept more later, publish again; a re-review does not re-ask about what you already published or dismissed.

**Out of scope for v1:** your own hand-written draft comments batched with agnts's (phase 3), approving / requesting changes on the host from the drafts bar beyond what Post review already does, drafts on agnts's own pull requests (they have "Address comments"), suggestion blocks, multi-line ranges on GitLab.

## What already exists (reuse)

| Piece | Where | Used for |
|---|---|---|
| Review tickets (`KindReview`, key `API-PR42`) | `orchestrator/pullreview.go` `createPullTicket`, `workPull` | The ticket a click creates; unchanged pipeline |
| Pull request page with diff and host threads | `apps/admin/src/pages/PullPage.vue`, `components/pulls/*` | Where the button and the drafts live |
| `ticketOfPull` | `orchestrator/prthreads.go` | Page already knows if a review ticket exists |
| Inline posting, still-present / no-longer-found replies | `postReviewInline` | Publish = this, fed with accepted drafts instead of indexes |
| `pr_posts` | migration 00046 | What was published, unchanged |
| `FindingKey` (file + title) | `domain/prcomments.go` | Matching drafts across re-reviews |
| Reviewer notes / profile | `NoteDismissed` etc. | Learning from dismissed drafts |

## Part 1 — Review with agnts from a pull request

### UI

- **PullPage header**: when `ticketKey` is empty and the pull request is open and not agnts's own: **Review with agnts** button (editors only). A small dialog: optional focus note ("focus on the migration") and a deep review choice (workspace default / on / off).
- When a review ticket exists: the existing "Review API-PR412" link. When that ticket is terminal (dismissed, or closed earlier): **Review again**, which creates a fresh ticket (`createPullTicket` already falls back to `-2`, `-3` keys).
- **Pull requests tab** rows get the same action in their menu.
- Mobile: a "Review with agnts" action on the pull request card (no dialog, defaults).

### API

`POST /repos/{id}/pulls/{number}/review` `{focus?, deep?: "off"|"always"}` → `201 {ticketKey}`; `409` if an open review ticket already exists (body carries its key); `422` for closed/merged pull requests or agnts's own.

### Server

- `Orchestrator.ReviewPull(ctx, repoID, number, opt, origin)`:
  - `rh.PullRequest` for the current state; reject unless open.
  - `ticketOfPull`: own → reject; open review → conflict with its key.
  - `pr.Why = domain.PullManual` (new constant, `"manual"`), `pr.Login` = the token's user (the conversation already resolves it for `PullView.login`), so the reviewer profile the run reads is the same one as for synced reviews.
  - `createPullTicket` with `CreatedBy` and `MemberID` = the clicking user (per-member Claude mode runs on their account), and `AfterApprove` set as below.
  - **Focus note**: a new ticket field `ReviewFocus` (text, capped like a reviewer note), passed to the `pull-review` prompt as its own block. It is **not** a reviewer note: those are per host login, get folded into the reviewer profile and would steer every later review. It is **not** `t.Feedback` either: `reviewPull` treats Feedback as "re-review with your note" and copies the previous review next to it.
  - **Deep review**: there is no per-ticket switch today (`deepReview(s, model)` reads `Settings.DeepReview`). Add a ticket field `DeepReview` (`""` = follow Settings, `off`, `always`) that `deepReview` checks first.
  - `o.Wake()`.
- **Approve must not merge.** A review ticket today has `AfterApprove: "pr"` and its push stage calls `MergePR`. That is acceptable for pull requests assigned to the token's user, but a manual review can be on anyone's pull request, so Approve must not merge it. Manual tickets get `AfterApprove: "none"` (new value): Approve moves the ticket to done with event "review accepted". It never merges, and it approves on the host only if we add that later. The ticket page shows "Finish review" instead of "Merge" for them. If the pull request later shows up in the token user's queue (assigned), `syncPull` leaves `AfterApprove` as it is: the person asked for a review, not a merge.
- **Manual reviews in sync.** The second loop of `SyncReviews` only ends tickets whose pull request was closed or merged, and leaves an open one that is not in the queue alone, so manual tickets survive it. What it does not do is refresh them or re-review them on new commits. Add `syncManualReviews`: for each open manual review ticket, `rh.PullRequest` → `syncPull` (title and body, re-review on new commits when `Rereview` is on) or `endPull` if it was closed. `autoSyncReviews` returns early when `PullReviews.Enabled` is off, so this needs its own path in that function: when sync is off, call `syncManualReviews` only. That keeps the cost to the tickets someone asked for.
- Event: `ticket_created` with message "review of #412 by @bob asked by <user>".

## Part 2 — Draft comments

### Data

New table `review_drafts` (migration `00049_review_drafts.sql`, since 00047 and 00048 are the swagger migrations; workspace RLS like `pr_posts`). The same migration adds `review_focus`, `deep_review` and the `none` value of `after_approve` to `tickets`.

| Column | Notes |
|---|---|
| `id`, `workspace_id`, `ticket_id`, `repo_id`, `number` | |
| `kind` | `summary` or `finding` |
| `finding_key` | `FindingKey(f)`; `''` for the summary |
| `severity`, `category`, `title`, `confidence`, `pass` | copied from the finding, for display and sorting |
| `path`, `line` | anchor; `line` may be outside the diff |
| `head_sha`, `base_sha`, `start_sha` | the diff the anchor belongs to: the reviewed commit and, for GitLab inline notes, the merge request's diff refs at that commit. `PullRequest.BaseSHA/StartSHA` are `json:"-"` and fetched live today, so the review run must record them when it fetches the head |
| `body` | Markdown that will be published (`findingComment` / `postedReview` output, minus the marker) |
| `edited` | a person changed `body`; re-reviews keep their text |
| `state` | `draft`, `accepted`, `publishing`, `dismissed`, `published`, `outdated` |
| `dismiss_reason` | optional |
| `post_id` | → `pr_posts.id` once published |
| `decided_by`, `decided_at`, `created_at`, `updated_at` | |
| `UNIQUE (ticket_id, kind, finding_key)` | one draft per finding per ticket |

The review run result (`domain.Review`) stays as it is: the drafts are agnts's working copy of it, not a replacement. Ticket page Review tab keeps reading the result for verdict/strengths.

### Lifecycle

When a review run finishes (`reviewPull` writes its result), `syncDrafts(ticket, review)` upserts by `finding_key`:

| Existing draft state | Finding still in the new review | Finding gone |
|---|---|---|
| none | insert `draft` | — |
| `draft` | refresh body (unless `edited`), anchor, severity, `head_sha` | → `outdated` |
| `accepted` (not yet published) | refresh anchor; keep accepted; body kept if `edited` | → `outdated` (and un-accepted) |
| `dismissed` | stay dismissed (don't ask again), refresh anchor quietly | stays dismissed |
| `published` | stays published; on next Publish the existing "Still present at …" reply logic runs | on next Publish: "No longer found" + resolve (existing logic) |
| `outdated` | back to `draft` | stays |

The summary draft:

| Summary draft state | On a new review |
|---|---|
| `draft` / `accepted` | body replaced unless `edited`; an accepted one stays accepted |
| `dismissed` | back to `draft` (a new commit has a new verdict) |
| `published` | back to `draft`, remembering its `post_id`; publishing it again **edits** the summary comment on the host instead of posting another (the existing `EditComment` path) |

**Races.** `syncDrafts` runs from the review run while people may be editing drafts in the UI. It writes in one transaction. Its upsert leaves `body` alone when `edited` is set, inside the SQL (`body = CASE WHEN review_drafts.edited THEN review_drafts.body ELSE excluded.body END`), so a person's edit made mid-run is never overwritten. It never touches rows in `publishing`.

### Publishing

`POST /tickets/{key}/drafts/publish` `{requestChanges?}` posts every `accepted` draft.

**Claim first.** One statement moves the ticket's `accepted` drafts to `publishing` and returns them (`UPDATE … SET state='publishing' WHERE ticket_id=$1 AND state='accepted' RETURNING *`). A second publish at the same time, from a double click or another person, gets no rows and answers "nothing to publish". After the host calls, each draft becomes `published` or goes back to `accepted` with the error. A `publishing` row older than 10 minutes, left behind by a crash, goes back to `accepted` on the next publish or sync.

**Head moved.** The drafts are anchored to the reviewed commit (`head_sha`). If the pull request's head is no longer that commit:
- GitHub: inline comments are posted with `commit_id = head_sha` and the commentable lines are worked out from the diff **at that commit** (the review result's stored files), not from `conv.PullFiles` at the current head. GitHub shows them as outdated, on the right lines.
- GitLab: positions use the draft's stored `base_sha/start_sha/head_sha`. If GitLab refuses an old position, those drafts go back to `accepted`, and the answer says "new commits since this review: review again to publish these on the current lines".
- The publish confirm warns: "!412 has new commits since agnts reviewed it (a41c0de → 9f2e11b). Comments go on the reviewed version." Its buttons are **Publish anyway** and **Review again first**.

**What goes out:**
- Inline findings whose line is in the reviewed diff → `conv.PostReview` comments (one review).
- Accepted findings whose line is **not** in the diff → appended to the review body as a "Not on a changed line" list with `file:line` (today they can only ride in the summary).
- Accepted summary → review body; if it has a `post_id` (published before), edit that comment instead (existing logic).
- **Reconciliation of what was published before.** `postReviewInline` runs "Still present at …" only for the indexes in `chosen`, so the publish passes the drafts in `published` state that are still in the current review as well as the accepted ones. Inside `postReviewInline`, a published draft only triggers the reply (never a new comment), as today through `earlier[k]`. The "No longer found" loop already walks every earlier post and needs no change. Both are idempotent per commit (`p.HeadSHA == sha` skips), so publishing several times on one commit replies at most once.
- Each posted comment → `pr_posts` row; its draft → `published` with `post_id`.
- Drop the "already posted for this commit" lock (`PostedSHA == HeadSHA` in `PostPullReview`): publishing is incremental now. `PostedSHA/PostedAt` keep meaning "last publish". `canPost` on `TicketPage.vue` (which hides the button once `posted`) changes to "there are accepted drafts", and the mobile ticket screen gets the same change.
- Event `review_posted` with counts, as today.

`requestChanges` stays GitHub-only. GitLab without draft notes falls back as today.

**When publishing is refused:** the pull request is closed or merged, or the ticket is rejected (dismissed). Drafts of such tickets stay readable on the ticket and pull request pages, marked "not published", and cannot be changed.

**Old clients.** `POST /tickets/{key}/post-review` `{summary, findings: [indexes], requestChanges}` is used by the released mobile app and today's admin. It stays and becomes a thin wrapper: it accepts the drafts of those finding indexes (and the summary if `summary`), then publishes. With no body it accepts every draft on a diff line, as the old default did.

### Other endpoints

- `GET /tickets/{key}/drafts` and, for the page, drafts embedded in `GET /repos/{id}/pulls/{number}` (`drafts: [...]`, `ticketKey`) so the diff renders them without a second call.
- `PATCH /tickets/{key}/drafts/{id}` `{state?: accepted|draft|dismissed, body?, dismissReason?}`. Editing a `published` draft is refused (edit the host comment instead, existing UI).
- `POST /tickets/{key}/drafts/accept-all` `{minSeverity?}` — "Accept all majors and above".

### Learning

- Dismissing a draft with a reason adds a reviewer note (`NoteDismissed`, with the finding title and reason) for the pull request's `login`, so the profile learns what this person calls noise. Dismiss without a reason: a lighter note "dismissed: <title>" — batched into one note per publish to avoid flooding.
- Accepting (especially after editing) marks `Finding.Adopted` and the edit diff can go into a note ("rewrote finding X as …"). Phase 2.
- **Whose profile learns.** Notes go to the pull request's `login`, which is the git host token's user, not the person who clicked. There is one token per workspace, so every member's dismissals teach one shared profile. The note records `UserID` so the Reviews page shows who said it. Per-person profiles depend on per-member host tokens, which are already a separate project.

### UI (admin)

- **PullConversation / PullDiffFile**: drafts render at their line like host threads but visibly different (dashed border, "agnts draft" chip, not on GitLab/GitHub yet). Actions: Accept / Edit (inline composer, same `CommentComposer`) / Dismiss (optional reason). Accepted ones show a check and "Undo". Published ones disappear as drafts and appear as normal host threads (they're real now). Outdated and dismissed drafts are hidden behind a "Show N dismissed/outdated" toggle.
- Drafts whose line isn't in the diff: listed in a "Not on changed lines" block above the files.
- **Drafts bar** (sticky, bottom of PullPage and on the ticket's Review tab): counts by state, "Accept all major+", summary checkbox, request-changes (GitHub), **Publish N to GitHub/GitLab** with a confirm listing what goes out.
- **Ticket page Review tab**: findings list gets the same per-row states/actions; `PostReviewDialog` is replaced by the drafts bar (it becomes the publish confirm).
- While the review run is still going, the page shows "agnts is reviewing…" where the bar will be.

### Mobile

Ticket screen: drafts list with Accept / Dismiss and Publish. No inline editing on the diff (as with the conversation today). Phase 2 if it gets heavy.

### MCP

`get_pull_request_comments` also returns drafts flagged as such (read only). No write tools.

## Phases

1. **Review with agnts**: button, endpoint, `PullManual`, `AfterApprove: none` (no merge) with the "Finish review" UI, `ReviewFocus` and `DeepReview` ticket fields (migration `00049` starts here with those columns), `syncManualReviews`. It ships alone and works right away with the existing Post review dialog.
2. **Drafts**: the `review_drafts` table (in `00049` if phase 1 has not shipped yet, otherwise `00050`), diff refs recorded by the review run, `syncDrafts` on review completion, PATCH/publish endpoints with the publishing claim, publish rewired through `postReviewInline` (reconciliation of published drafts, anchoring to the reviewed commit), `post-review` kept as a wrapper, admin diff + bar + ticket tab, removal of the once-per-commit lock and the `canPost` change (admin and mobile), backfill: for open review tickets, create drafts from their latest result (published ones matched through `pr_posts.finding_key`).

Every phase also: `shared/openapi/openapi.yaml` → regenerate `apps/admin/src/api/schema.gen.ts`, `server/internal/httpapi/gen` and the Dart `agnts_api` package; strings in `shared/i18n/{en,ru,uz}/pulls.json` (and `reviews.json`) and the mobile `app_{en,ru,uz}.arb`.
3. Learning from dismiss/edit, mobile, MCP read, your own draft comments batched with agnts's in the same publish (a real "pending review" in agnts).

## Testing

- Orchestrator: `ReviewPull` (open/closed/own/existing-ticket/terminal-ticket), manual tickets surviving sync and re-reviewing on new commits, with sync off too; Approve on a manual ticket never calls `MergePR`; the focus note reaches the prompt and never reaches `reviewer_notes`; `DeepReview` overrides Settings.
- `syncDrafts` table-driven over the lifecycle matrix above across three review rounds (edited body kept, dismissed not resurrected, outdated → draft, published summary back to draft and edited in place), and an edit that lands during a run is kept.
- Publish: only accepted go out; off-diff accepted go in the body; second publish after accepting more posts only the new ones; two publishes at once post once; a crashed `publishing` row is recovered; published drafts get "Still present" once per commit; still-present/no-longer-found still work; head moved (GitHub posts on the reviewed commit, GitLab refusal sends drafts back to accepted); refused on closed/merged/dismissed; old `post-review` with indexes still works; GitLab without draft notes.
- Postgres: `review_drafts` upsert by key, RLS isolation.
- Admin component tests: draft rendering at lines, accept/edit/dismiss, bar counts, publish confirm.
- Manual run on a real GitHub and GitLab pull request.

## Decisions (defaults, change if you disagree)

- **Manual reviews never merge.** Approve finishes the review; merging stays with the tickets the sync created for pull requests assigned to the token's user.
- **Drafts are anchored to the commit agnts reviewed.** Publishing after new commits posts on that version (GitHub) or asks for a re-review (GitLab when refused). It never guesses new line numbers.

- **Accept marks, Publish sends.** Accept does not post immediately; it queues the comment so the author gets one review, as GitHub/GitLab "pending review" does.
- **Drafts are workspace-visible**, not private to the clicker: any editor on the ticket can accept/dismiss.
- **Comments still post as the token's user** with the existing "via agnts · <username>" attribution (per-member host tokens stay a separate project).
- **One draft per finding key per ticket.** A second review ticket for the same pull request ("Review again") starts fresh drafts but sees the first ticket's published posts through `pr_posts`, so it never re-posts them.

## Open questions

1. Should "Review with agnts" also link a tracker issue (the Jira/Plane "Review PR !412" task) so approving or publishing moves that issue? Useful for the case that started this, but needs the tracker transition mapping per workspace.
2. Who can click it: any editor, or only people with a linked git host account? (Default: any editor.)
3. Should dismissed drafts be visible to everyone in the workspace, or only to the person who dismissed them plus admins?
4. When the pull request author pushes new commits, re-review automatically for manual tickets (follow `PullReviews.Rereview`) or only on "Review again"? (Default: follow the setting.)

## Implementation notes

All three phases shipped. What differs from the plan above:

- **Open questions, decided by default.** (1) No tracker link yet. (2) Any editor can ask for a review; viewers only read (the API's usual role rule). (3) Dismissed drafts are visible to the whole workspace, folded away by default. (4) Manual reviews follow `PullReviews.Rereview` on new commits.
- **Focus and deep choice live on the ticket's pull request** (`PullRequest.Focus`, `PullRequest.Deep`, agnts's own fields carried over by `Keep`, like `PostedSHA`), not as new ticket columns. `Keep` also keeps `Why = manual` when the pull request later appears in the queue.
- **One migration**, `00049_review_drafts.sql`: the `review_drafts` table, `after_approve` accepts `none`, reviewer notes accept the kind `draft`.
- **Approve on a manual review** still goes through the push stage, which finishes it (`done`) without calling `MergePR`; the state machine is unchanged.
- **The summary draft no longer lists every finding.** It holds the verdict, summary and strengths; findings are published only as accepted comments (on their lines, or under "Not on a changed line" in the review's text). This is what keeps dismissed findings off the git host.
- **`POST /tickets/{key}/post-review`** is a wrapper: `summary` accepts the summary and the findings not on a changed line, `findings` (or every finding when left out) accepts those on a changed line, dismissed ones stay dismissed; then it publishes. The once-per-commit lock is gone; posting with nothing new to accept answers "nothing to publish".
- **Publishing** claims accepted drafts in one statement (`accepted → publishing`, stale after 10 minutes), groups comments by the commit they are about (one review per commit, nearly always one), and uses the reviewed diff (from the review run's result) for line checks when the head moved. GitLab gets the stored `base_sha/start_sha` for an older head through `NewPRComment.BaseSHA/StartSHA`.
- **People's own drafts (phase 3)** are in the admin diff: the line composer has "Add to review" next to "Comment". They are accepted on creation, published with attribution ("via agnts · <author>"), and can be deleted until published.
- **Learning**: a dismissal with a reason is a `draft` note at once; dismissals without a reason and findings rewritten before publishing go into one note per publish.
- **Admin**: "Review with agnts" on the pull request page and on open, ticket-less rows of the Pull requests tab; drafts on the diff (dashed cards) and a drafts panel with counts, Accept major+, Accept all and Publish (warns when the head moved); the ticket page shows the same panel and "Finish review" for manual reviews. `PostReviewDialog` was removed.
- **Mobile** has no pull request list, so no "Review with agnts" button there. The ticket screen got a drafts fold (accept, dismiss with reason, undo, reopen, Accept major+, Publish) and "Finish review" for manual reviews; no editing of draft text or own drafts on mobile.
- **MCP**: `get_pull_request_comments` also returns the drafts, marked with their state.
- **Known caveat (unchanged from before)**: GitLab's `bulk_publish` publishes every pending draft note of the token's user on that merge request, including ones written on GitLab itself.
- **Testing**: domain table test of the merge rules; Postgres test of the store (claims, stale claims, finish, isolation, unique key); orchestrator tests for manual reviews (closed, conflict, focus/deep in the prompt, sync with the setting off, edit kept across a re-review, approve never merges, review again) and publishing (only accepted, dismissed nit stays off the host, own comments with attribution, incremental publish, concurrent publish posts once, head moved, refused when merged); the existing inline-review test now runs through drafts; admin component tests; Flutter widget tests. A manual run against real GitHub and GitLab is still to do.

