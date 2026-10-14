# agnts pull request comments (read, write, edit, delete) — Plan

Oct 14, 2026 · draft, not started

## Overview

agnts already touches pull/merge requests in three places, but never their conversation:

- **Review tickets** (`orchestrator/pullreview.go`): PRs assigned to you become `KindReview` tickets, agnts reviews them, and "Post review" sends the whole review as **one** Markdown comment (`CommentPR`). Findings have `File`/`Line`, but they are not posted on those lines.
- **CI watcher** (`vcs.UpsertComment`): edits one status comment in place on agnts's own PRs.
- **agnts's own PRs** (tickets agnts pushed): the reviewers' comments on the host never come back to agnts. Feedback only comes from the agnts UI.

This plan adds the conversation: **fetch a PR's comments and threads from GitHub or GitLab, show them next to the diff, and let you add, reply to, edit, delete and resolve them from agnts.** Then it builds two things on top: posting review findings as inline comments, and turning reviewers' comments on agnts's own PRs into re-code feedback.

```
#412  Add coupon expiry                                   api · open · 3 threads (1 unresolved)
┌──────────────────────────────────────────────────────────────────────────────────────────┐
│ src/coupons/apply.go                                                                     │
│  41  if c.ExpiresAt.Before(now) {                                                        │
│  42 +    return ErrExpired                                                               │
│      ┌ alice · 2h  Shouldn't this compare in UTC?                                        │
│      │ you   · 1h  Good catch, fixed in a41c0de                       edit · delete      │
│      └ reply…                                                       resolve ✓          │
│  43  }                                                                                   │
│                                                                                          │
│ Conversation                                                                             │
│  bob · 1d   LGTM once the migration is split.                                            │
│  agnts review (posted as you) · 3 findings inline                    edit · delete      │
│  [ comment… ]                                                         Comment           │
└──────────────────────────────────────────────────────────────────────────────────────────┘
```

**Goals**

- Any open PR/MR in a connected repository can be opened in agnts with its description, diff and full conversation (general comments, inline threads, review summaries), and stays live through webhooks.
- From agnts you can comment, reply in a thread, comment on a diff line, edit or delete your comments, and resolve/unresolve threads. Same UI for GitHub and GitLab.
- "Post review" on a review ticket can post the chosen findings as **inline comments in one review** (GitHub review / GitLab draft notes, published together), and a re-review edits or replaces what agnts posted before instead of piling up duplicates.
- On agnts's own PRs, unresolved reviewer threads can be sent back to the ticket as feedback ("Address comments"). After the fix is pushed agnts replies in each thread with the commit, and optionally resolves it.

**Out of scope for v1:** Bitbucket/Gitea, suggestion blocks applied from agnts ("Apply suggestion"), reactions/emoji, multi-line ranges on GitLab (GitHub only, see Decisions), editing the PR title/description, review approval from the comments UI (approve stays the ticket's Approve), images/attachments in comments.

**Principles**

1. **The git host is the source of truth.** agnts does not copy the conversation into Postgres. It fetches live with a short cache and invalidates on webhooks and after its own writes. It stores only what it needs to remember: which host comments **agnts** posted, and which reviewer threads were already turned into feedback.
2. **One neutral shape.** GitHub has three comment APIs (issue comments, review comments, reviews) and GitLab has one (discussions/notes). Both are mapped to `PRThread`/`PRComment` in `vcs`, and nothing above `vcs` knows the difference.
3. **Writing to the host is outward-facing.** Every write is an explicit user action (never automatic in v1, except replies after an approved fix, which are opt-in), is recorded as a ticket/repo event with its origin, and is attributed (see Identity).
4. **Comments are untrusted.** A reviewer's comment reaches Claude only as wrapped, capped data (same treatment as CI logs), never as instructions.
5. **Reuse the pipeline.** "Address comments" is the existing request-changes feedback path with the threads attached. No new ticket state.

## What the hosts give us

| | GitHub (REST, + GraphQL for threads) | GitLab (REST v4) |
|---|---|---|
| List general comments | `GET /repos/{o}/{r}/issues/{n}/comments` | `GET /projects/:id/merge_requests/:iid/discussions` (one call returns everything, `individual_note=true` for plain comments) |
| List inline comments | `GET /repos/{o}/{r}/pulls/{n}/comments` (grouped by `in_reply_to_id`) | same call; notes have `position` |
| Review summaries | `GET /pulls/{n}/reviews` | n/a (approvals are separate, not comments) |
| Thread resolved state | **GraphQL only**: `pullRequest.reviewThreads { isResolved, isOutdated, comments }` | `discussion.notes[].resolved`, `resolvable` |
| New general comment | `POST /issues/{n}/comments` (exists: `CommentPR`) | `POST /merge_requests/:iid/notes` |
| New inline comment | `POST /pulls/{n}/comments` `{commit_id, path, line, side, start_line?}` | `POST /discussions` `{body, position{base_sha,start_sha,head_sha,position_type:"text",new_path,old_path,new_line|old_line}}` (shas from the MR's `diff_refs`) |
| Reply | `POST /pulls/{n}/comments/{id}/replies` | `POST /discussions/:did/notes` |
| Batch (one review) | `POST /pulls/{n}/reviews` `{event: COMMENT, body, comments[]}` | `POST /draft_notes` × n, then `POST /draft_notes/bulk_publish` |
| Edit | `PATCH /issues/comments/{id}` or `/pulls/comments/{id}` | `PUT /notes/:nid` (exists in `UpsertComment`) |
| Delete | `DELETE` on the same paths | `DELETE /notes/:nid` |
| Resolve | GraphQL `resolveReviewThread` / `unresolveReviewThread` | `PUT /discussions/:did?resolved=true|false` |
| Webhooks | `issue_comment`, `pull_request_review`, `pull_request_review_comment`, `pull_request_review_thread` | `Note Hook` (`object_kind: note`, `noteable_type: MergeRequest`); create and update, **no delete event** |
| Token permission | fine-grained "Pull requests: Read and write" (already required for `CommentPR`); GraphQL thread resolve needs the same | `api` scope (already required) |

Permissions on the host: you can edit/delete **your own** comments. Repo admins (GitHub) and Maintainers (GitLab) can also delete others'. agnts shows edit/delete only on comments by the token's user (`Mine`). If the host refuses something else, its error is shown through `needs(...)` as it is today.

So yes, everything asked for is possible on both hosts. The only asymmetries are GitHub's thread state living in GraphQL (agnts already has `github/graphql.go`) and GitLab not sending delete webhooks (covered by the cache TTL and a refetch when the page opens).

## Model

### `vcs` (provider-neutral)

```go
// PRComment is one comment on a pull/merge request.
type PRComment struct {
    ID        string    // opaque: "ic:123" GitHub issue comment, "rc:456" review comment,
                        // "rv:789" review body, "n:321" GitLab note
    Author    string
    AvatarURL string
    Body      string    // Markdown, as the host stores it
    CreatedAt time.Time
    UpdatedAt time.Time
    URL       string
    Mine      bool      // written by the token's user: can edit/delete
    System    bool      // GitLab system note ("added 2 commits"): shown collapsed, read-only
    Agnts     bool      // posted by agnts (matched against pr_posts, see below)
}

// PRThread is a conversation: a general comment (one comment, no Path),
// a review summary, or an inline thread on a diff line.
type PRThread struct {
    ID         string // "gh:<graphql thread node id>" / "ic:123" / "gl:<discussion id>"
    Kind       string // general | inline | review
    Path       string
    Line       int    // line in the new file; 0 with OldLine for deleted lines
    OldLine    int
    StartLine  int    // multi-line (GitHub)
    CommitSHA  string // the commit it was written on
    Outdated   bool   // the line moved or vanished since
    Resolvable bool
    Resolved   bool
    ReviewState string // review kind: APPROVED, CHANGES_REQUESTED, COMMENTED
    Comments   []PRComment // oldest first
}

// NewComment is a comment to post. With Path it is inline on Line (or
// OldLine for a removed line), on the commit HeadSHA.
type NewComment struct {
    Body      string
    Path      string
    Line      int
    OldLine   int
    StartLine int
    HeadSHA   string
}

// Conversation is the host side of PR comments.
type Conversation interface {
    PullRequests(ctx, repo, state string, page, perPage int) ([]domain.PullRequest, error) // all, not only yours
    Threads(ctx, repo, number int) ([]PRThread, error)
    AddComment(ctx, repo, number int, c NewComment) (PRThread, error)
    Reply(ctx, repo, number int, threadID, body string) (PRComment, error)
    EditComment(ctx, repo, number int, commentID, body string) (PRComment, error)
    DeleteComment(ctx, repo, number int, commentID string) error
    ResolveThread(ctx, repo, number int, threadID string, resolved bool) error
    // PostReview posts body and the inline comments as one review/batch.
    PostReview(ctx, repo, number int, headSHA, body string, cs []NewComment) (reviewID string, ids []string, err error)
}
```

`Multi` routes and caches as it does for `Pipelines` (`remember`, ~15 s, key `threads:<n>`), and `Forget`s the key after every write and on every comment webhook. `UpsertComment` (CI) and `CommentPR` stay as they are; on GitHub/GitLab they become thin wrappers around the new calls.

Mapping notes:
- **GitHub threads**: one GraphQL query (`reviewThreads(first:100){ id isResolved isOutdated path line originalLine startLine diffSide comments(first:100){ databaseId author body createdAt lastEditedAt url } }`) plus REST issue comments plus reviews with a non-empty body. Paginate past 100. `Mine` = `author.login == viewer.login` (the login is already cached for `ReviewQueue`).
- **GitLab**: `GET /discussions?per_page=100` paginated. `individual_note && !position` → general; `position` → inline; `system` notes kept but flagged. `Outdated` = `position.head_sha != mr.diff_refs.head_sha` and the line is not in the current diff (GitLab doesn't say it directly).
- **Inline on GitLab** needs `diff_refs`; `PullRequest` gains `BaseSHA`/`StartSHA` so the client doesn't send them.
- A comment on a line outside the diff hunk is rejected by both hosts (422 / 400). `AddComment` returns `ErrNotInDiff` and the UI only offers lines that are in the diff.

### Domain and store — migration `00046_pr_comments.sql`

The conversation is not stored. Two small tables:

```sql
-- What agnts posted on a pull request, so a re-review can edit or remove
-- its own comments instead of posting them again.
CREATE TABLE pr_posts (
  id          bigserial PRIMARY KEY,
  repo_id     bigint NOT NULL REFERENCES repositories(id) ON DELETE CASCADE,
  number      int    NOT NULL,
  ticket_id   bigint REFERENCES tickets(id) ON DELETE SET NULL,
  comment_id  text   NOT NULL,          -- vcs PRComment.ID
  kind        text   NOT NULL,          -- review_summary | finding | reply | status (CI)
  finding_key text   NOT NULL DEFAULT '', -- hash(file, title) of the finding it carries
  head_sha    text   NOT NULL DEFAULT '',
  posted_by   bigint REFERENCES users(id) ON DELETE SET NULL,    -- who pressed the button in agnts
  created_at  timestamptz NOT NULL DEFAULT now(),
  UNIQUE (repo_id, number, comment_id)
);

-- Reviewer threads on agnts's own PRs that were sent back as feedback.
CREATE TABLE pr_thread_feedback (
  ticket_id   bigint NOT NULL REFERENCES tickets(id) ON DELETE CASCADE,
  thread_id   text   NOT NULL,
  last_comment_id text NOT NULL,        -- a newer comment in the thread makes it "new" again
  run_id      bigint,                   -- the re-code run that addressed it
  replied     boolean NOT NULL DEFAULT false,
  PRIMARY KEY (ticket_id, thread_id)
);
```

`domain.Pull.PostedSHA`/`PostedAt` stay as they are; `pr_posts` adds the per-comment detail.

## Features, in the order they ship

### 1. Conversation view (read)

- New page **`/repos/:id/pulls/:number`** in admin: header (title, author, branches, state, CI), the description, and two tabs: **Files** (existing `DiffView`, with threads rendered under their lines and outdated threads in a list above) and **Conversation** (general comments, review summaries and threads in time order).
- A **Pull requests** tab on `RepoPage` lists open PRs/MRs (`Conversation.PullRequests`), with unresolved-thread counts, "assigned to you" and a link to the review ticket when one exists.
- `TicketPage` for `KindReview` tickets and for agnts's own tickets with a `PRNumber` embeds the same `PullConversation` component, so you never have to leave the ticket.
- Live: hooks for `issue_comment`, `pull_request_review*` (GitHub) and `note` (GitLab) call `Forget(repo, "threads:<n>")` and publish a `pull.comments` stream event `{repoId, number}`. `useLive.ts` / `live.dart` refetch when the open page matches. Repos without webhooks rely on the cache TTL and refetch on focus.
- Mobile: read-only conversation on the ticket screen in phase 1, posting in phase 2.

### 2. Write: comment, reply, edit, delete, resolve

- General comment box, "reply" in every thread, "+" on diff lines (shift-click a second line for a range on GitHub), edit/delete on `Mine` comments, resolve/unresolve on resolvable threads.
- Optimistic UI with rollback on error. Delete asks for confirmation. Edits show "edited" from `UpdatedAt`.
- Every write emits a `domain.Event` (`pr.comment.added|edited|deleted`, `pr.thread.resolved`) on the ticket when there is one, otherwise on the repository activity feed, with `Origin` = the agnts account.
- Markdown preview in the composer (the admin already renders Markdown; add sanitizing if it isn't there yet, since comment bodies are other people's HTML-capable Markdown).

### 3. Post review findings inline

Extend `PostPullReview` (and the "Post review" button) into a dialog:

```
Post review on #412                                     head a41c0de
 ☑ Summary comment
 ☑ high   apply.go:42   Expiry compared in local time       (inline)
 ☑ medium apply.go:77   Error swallowed                     (inline)
 ☐ low    README.md     Typo                                (summary only: line not in diff)
 Post as:  ● Comment   ○ Request changes          [ Post 2 inline + summary ]
```

- Findings whose `File`/`Line` are in the diff become inline comments; the rest go into the summary body. Everything is sent with **one** `PostReview` call (GitHub review / GitLab draft notes + bulk publish), so reviewers get one notification.
- Each posted comment is recorded in `pr_posts` with its `finding_key`.
- **Re-review on a new head**: findings with the same `finding_key` that are still present → reply "still present at <sha>" (or skip); findings that disappeared → reply "resolved at <sha>" and resolve the thread; new findings → new inline comments. The summary comment is **edited** in place (`EditComment`) rather than reposted. This replaces the `PostedSHA` "already posted" guard with something finer.
- "Request changes" maps to GitHub `REQUEST_CHANGES`; GitLab has no such event, so it posts the comments and leaves the approval untouched (stated in the dialog).
- Your edits to agnts's posted comments on the host are kept (agnts edits only the summary, and only when you press Post again).
- Reviewer learning: comments **you** write on others' PRs (seen through the webhook, author = token user, not in `pr_posts`) are added as `ReviewerNote`s with kind `host_comment`, so `learnReviewer` folds them into your profile. Can be turned off in Settings.

### 4. Address reviewers' comments on agnts's own PRs

- Agnts tickets in `pushed`/PR-open state show unresolved threads by other people as **"N new review comments"** (new = not in `pr_thread_feedback`, or a newer comment since).
- **Address comments** (select threads or all) → the existing request-changes path with an attachment: the threads as wrapped data (`<review_threads>` with path, line, diff hunk, comments; each body capped at 4 KB, total 40 KB). The run's prompt says to address each thread or explain why not, per thread id, in its result (`threads: [{id, action: fixed|answered|declined, note}]`).
- After **you approve** the new diff and it is pushed, agnts replies in each thread ("Fixed in a41c0de: …" or the answer) and, if the repository setting **Resolve threads agnts fixed** is on, resolves them. Replies are recorded in `pr_posts` (`kind=reply`) and `pr_thread_feedback.replied`.
- Optional, off by default: **auto-address** in repository settings, which starts the feedback run when a reviewer submits a review with changes requested (`pull_request_review` webhook / GitLab note with an unresolved discussion). It still stops at your approval; nothing is pushed or replied until then.

## API (`shared/openapi/openapi.yaml`, then `make gen`)

```
GET    /repos/{id}/pulls?state=open&page=                     → PullRequest[]
GET    /repos/{id}/pulls/{number}                             → PullRequest + files
GET    /repos/{id}/pulls/{number}/threads                     → PRThread[]
POST   /repos/{id}/pulls/{number}/comments                    NewComment → PRThread
POST   /repos/{id}/pulls/{number}/threads/{threadId}/replies  {body} → PRComment
PATCH  /repos/{id}/pulls/{number}/comments/{commentId}        {body} → PRComment
DELETE /repos/{id}/pulls/{number}/comments/{commentId}
PUT    /repos/{id}/pulls/{number}/threads/{threadId}/resolved {resolved}
POST   /tickets/{key}/review/post        {summary, findings: [i], event: comment|request_changes}   (extends today's endpoint)
POST   /tickets/{key}/address-comments   {threadIds?: []}
```

`threadId`/`commentId` are the opaque ids from `vcs` (URL-escaped). The handler checks that the repository is in the caller's workspace before calling the host.

## Changes by package

| Where | What |
|---|---|
| `server/internal/vcs/vcs.go` | `PRThread`, `PRComment`, `NewComment`, `Conversation`, `Multi` routing + cache keys, `ErrNotInDiff` |
| `server/internal/vcs/github/comments.go` (new) | REST + GraphQL mapping, review batch, resolve via GraphQL, id prefixes |
| `server/internal/vcs/gitlab/comments.go` (new) | discussions/notes/draft_notes, `diff_refs`, resolve |
| `server/internal/vcs/hooks.go` | GitHub `issue_comment`, `pull_request_review`, `pull_request_review_comment`, `pull_request_review_thread`; GitLab `note` → forget + stream event (+ reviewer note, + auto-address trigger) |
| `server/internal/domain/` | `PullRequest.BaseSHA/StartSHA`, events, `ReviewerNote` kind `host_comment` |
| `server/migrations/00046_pr_comments.sql` | `pr_posts`, `pr_thread_feedback` |
| `server/internal/store/postgres/` | CRUD for the two tables |
| `server/internal/orchestrator/pullreview.go` | inline `PostPullReview`, re-review reconciliation |
| `server/internal/orchestrator/` (new `prthreads.go`) | address-comments feedback, replies + resolve after push |
| `server/internal/httpapi/pulls.go` (new) | the endpoints above |
| `server/internal/mcpserver/` | tools `pr_threads`, `pr_comment` (read + comment), so the assistant and MCP clients can use it |
| `apps/admin/` | `PullPage.vue`, `PullConversation.vue`, `CommentThread.vue`, `CommentComposer.vue`; `DiffView` line slots; `RepoPage` PR tab; `TicketPage` embedding; post-review dialog; `useLive` event |
| `apps/mobile/` | conversation on ticket screen (read, then write), l10n en/ru/uz |
| `server/internal/notify/` | optional push: "alice commented on #412" for PRs you're on |

## Phases

1. **Read** (vcs mapping both hosts, threads endpoint, webhooks + live, admin page and ticket embed, mobile read). Highest-risk part is mapping correctness; most of the tests go here.
2. **Write** (add/reply/edit/delete/resolve, events, mobile write).
3. **Inline review posting** (dialog, batch post, `pr_posts`, re-review reconciliation, reviewer notes from host comments).
4. **Address comments on own PRs** (feedback attachment, prompt, replies/resolve after push, optional auto-address).

Each phase is shippable on its own; 1+2 already answer "fetch MRs with comments and add/edit/delete".

## Testing

- `vcs/github` and `vcs/gitlab`: recorded JSON fixtures (as `reviews_test.go` does) for threads with replies, outdated threads, multi-line, system notes, deleted lines, pagination; request-shape tests for every write (paths, bodies, GraphQL variables).
- Hook tests for each new event type: correct cache key forgotten, stream event published, own-comment → reviewer note, not for agnts's posts.
- Orchestrator: re-review reconciliation table test (kept / gone / new findings → reply / resolve / post); address-comments prompt wraps and caps bodies; replies only after approval + push.
- Manual against a real GitHub repo and a GitLab (gitlab.com and a self-managed instance, since `draft_notes` needs GitLab ≥ 13.2 and bulk publish ≥ 14.x).

## Security

- Comment bodies are untrusted: sanitized when rendered (admin, mobile Markdown), wrapped as data and capped in prompts, never executed or followed.
- Everything posted goes out as the **token's user**. The UI says so next to every Post button ("Posts as @rustam on GitHub").
- Workspace isolation: every endpoint resolves the repo through the caller's workspace; comment/thread ids are only used together with that repo and number, never alone.
- No automatic writes in v1 except opt-in replies after an approved push. Deletes need confirmation and are logged.

## Costs and limits

- Reading is host API calls only: about 3 calls per refresh on GitHub (GraphQL threads, issue comments, reviews) and 1–2 on GitLab, cached ~15 s and invalidated by webhooks. Within rate limits even for busy repos. The `etag.go` conditional requests can be reused for REST lists.
- Claude runs only in phase 3 (existing review, no extra cost) and phase 4 (one feedback run per "Address comments", same budget as request changes).
- Caps: 100 threads × 100 comments per page fetched, paginated up to 1,000 comments. Larger PRs show "open on GitHub" for the rest.

## Decisions

- **No local copy of the conversation**: avoids sync bugs, deletions on GitLab (no webhook), and storing other people's text. The cost is a host call per open, which is acceptable.
- **Opaque prefixed ids** instead of a union type in the API: GitHub issue and review comment ids live in different endpoints, and the prefix keeps that inside `vcs`.
- **Multi-line comments GitHub-only in v1**: GitLab's `line_range` position works but is fiddly to get right with `line_code`s; later.
- **Edit/delete only own comments in the UI**, even when the token could delete others' (admin). Fewer surprises.

## Open questions

1. **Identity.** One host token per workspace means every comment from agnts appears as that token's user, whoever pressed the button. Options: (a) accept it and add a footer "— via agnts by <name>" (default proposal), (b) per-member host tokens or OAuth apps so comments come from each person. (b) is the right long-term answer for teams but is a separate project.
2. Should agnts's own posted comments carry a visible marker (`<!-- agnts:finding:<key> -->` HTML comment) so they can also be found when `pr_posts` is lost or the comment was edited? Proposal: yes, invisible marker plus the table.
3. Should the Pull requests tab list **all** open PRs, or only those you're assigned/requested plus agnts's own? (All is simple with paging; it's a question of noise.)
4. Phase 4 auto-address: trigger on any new reviewer comment, or only on "changes requested"? Proposal: changes requested only.
