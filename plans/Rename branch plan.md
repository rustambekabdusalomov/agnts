# agnts Rename Branch Before Push — Plan

Oct 17, 2026 · v1 implemented (server, admin panel, mobile); manual check on a real ticket still to do

## Overview

agnts names a ticket's branch from the repository's branch template (`domain.BranchName`) when the work starts. Teams sometimes want a different name on the pull request (their own convention, a typo in the title slug, a ticket number added later). Until now the only way was to change the template and start over.

A person can now rename the branch on the ticket page before agnts pushes it. The pull request opens from the new name, and later coding runs (requested changes, CI fixes) keep it.

## Rules

- **When**: the ticket waits for review, or stopped on an error (`failed`, `rate_limited`). Not while a run writes code.
- **Which branches**: per repository, only one that was never pushed (no pull request, row state not `pushed`/`merged`/`dropped`) and that has commits (`HeadSHA`). A multi-repo ticket whose push half failed can still rename the repositories that were not pushed.
- **Not for**: reviews of someone else's pull request, replays and reports (never pushed), tasks that push straight to the default branch, archived repositories.
- **Names**: typed names are not cleaned up silently. `domain.ValidateBranchName` refuses anything `cleanRef` would change (spaces, `..`, `//`, leading or trailing `-`/`.`, `.lock`), `HEAD`, `refs/...`, and names over 200 bytes.
- **Taken names** (409): the default branch, a branch agnts already has in the mirror, a branch on the git host (checked after a fetch), or one that clashes as a folder (`a` and `a/b`). Pushing onto an existing host branch could fast-forward someone else's work.
- **Who**: anyone who can edit (viewers are refused by the API middleware, and neither client shows the button).

## As built

- `gitrepo.RenameBranch`: fetches, checks the clashes above, points the new ref at the old head and removes the old ref. Commits are untouched.
- `orchestrator.RenameBranch` (`actions.go`) checks `cannotRename`, renames the ref, then saves the new name on the ticket's repository row with a `ticket_updated` event ("branch renamed from X to Y"). If saving fails it renames the ref back.
- New `BranchRenamer` port next to `BranchCleaner` / `BranchRestorer`.
- API: `PUT /tickets/{key}/branch` `{ branch, repoId? }` (no repoId = the primary). The ticket detail sets `canRenameBranch` on each repository it applies to.
- Admin: `components/ticket/BranchName.vue` shows the branch with a Rename link that opens an inline field. Used on the review card, the sidebar and `TicketRepos`.
- Mobile: a Rename button next to the branch (header, and each row of `TicketRepos`) opens a bottom sheet.
- Tests: `domain` `TestValidateBranchName`, `gitrepo` `TestRenameBranch` (clashes, then a push under the new name), `orchestrator` `TestRenameBranchBeforePush` (rename, approve, the push and PR use the new name, refused after push), `httpapi` routes, admin `TicketRepos.test.ts`.

## Known limits

- A code review or preview that starts in the same instant as a rename may fail to read the branch; running it again fixes it.
- A rejected ticket's branch that was deleted (no PR) is not seen as taken by a rename on another ticket. If both are later continued, `RestoreBranch` leaves the existing branch alone, and the continued ticket would pick up the other ticket's branch. This is rare enough to leave for now.
