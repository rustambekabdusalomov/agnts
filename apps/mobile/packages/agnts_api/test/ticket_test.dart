import 'package:test/test.dart';
import 'package:agnts_api/agnts_api.dart';

// tests for Ticket
void main() {
  final Ticket? instance = /* Ticket(...) */ null;
  // TODO add properties to the entity

  group(Ticket, () {
    // String key
    test('to test the property `key`', () async {
      // TODO
    });

    // The team's number for the work (AMANAT-2288), used in branch and commit names; absent uses key
    // String ticketNumber
    test('to test the property `ticketNumber`', () async {
      // TODO
    });

    // String source_
    test('to test the property `source_`', () async {
      // TODO
    });

    // The primary repository; repos lists all of them
    // int repoId
    test('to test the property `repoId`', () async {
      // TODO
    });

    // Every repository the ticket works in, the primary first, with its branch and pull request
    // List<TicketRepoState> repos
    test('to test the property `repos`', () async {
      // TODO
    });

    // RepoGroupRef group
    test('to test the property `group`', () async {
      // TODO
    });

    // Some pull requests merged and at least one closed without a merge
    // bool partlyMerged
    test('to test the property `partlyMerged`', () async {
      // TODO
    });

    // String title
    test('to test the property `title`', () async {
      // TODO
    });

    // String description
    test('to test the property `description`', () async {
      // TODO
    });

    // String priority
    test('to test the property `priority`', () async {
      // TODO
    });

    // TicketState state
    test('to test the property `state`', () async {
      // TODO
    });

    // TicketState resumeState
    test('to test the property `resumeState`', () async {
      // TODO
    });

    // int revision
    test('to test the property `revision`', () async {
      // TODO
    });

    // For a replay: the done ticket it re-runs. Replays are never pushed.
    // String replayOf
    test('to test the property `replayOf`', () async {
      // TODO
    });

    // int turns
    test('to test the property `turns`', () async {
      // TODO
    });

    // The primary repository's branch (see repos)
    // String branch
    test('to test the property `branch`', () async {
      // TODO
    });

    // The reviewed commit: the branch head agnts committed (in the primary repository; see repos), or for a pull request review the head agnts reviewed
    // String headSha
    test('to test the property `headSha`', () async {
      // TODO
    });

    // The primary repository's pull request (see repos)
    // int prNumber
    test('to test the property `prNumber`', () async {
      // TODO
    });

    // The primary repository's pull request (see repos)
    // String prUrl
    test('to test the property `prUrl`', () async {
      // TODO
    });

    // Rounds a red CI check sent the pull request back to coding
    // int ciFixes
    test('to test the property `ciFixes`', () async {
      // TODO
    });

    // Git host usernames the pull request is (or will be) assigned to
    // List<String> assignees
    test('to test the property `assignees`', () async {
      // TODO
    });

    // pr: open a pull request (a review: merge it); main: push to the default branch; none: a review asked for from the pull request page, which approving finishes without merging
    // String afterApprove
    test('to test the property `afterApprove`', () async {
      // TODO
    });

    // Kept in the queue until started
    // bool held
    test('to test the property `held`', () async {
      // TODO
    });

    // bool askFirst
    test('to test the property `askFirst`', () async {
      // TODO
    });

    // TicketKind kind
    test('to test the property `kind`', () async {
      // TODO
    });

    // agnts picks the kind; the analysis may still change it
    // bool kindAuto
    test('to test the property `kindAuto`', () async {
      // TODO
    });

    // coding runs skip the checks and go to review on the code alone (set with retryTicket or requestChanges)
    // bool skipChecks
    test('to test the property `skipChecks`', () async {
      // TODO
    });

    // A merged ticket in the benchmark that changes to agnts are replayed against (setTicketBenchmark)
    // bool benchmark
    test('to test the property `benchmark`', () async {
      // TODO
    });

    // The approved report is posted to the tracker issue
    // bool postReport
    test('to test the property `postReport`', () async {
      // TODO
    });

    // The plan or bug investigation this ticket implements
    // String parentKey
    test('to test the property `parentKey`', () async {
      // TODO
    });

    // The ticket that suggested this one as a follow-up
    // String followUpOf
    test('to test the property `followUpOf`', () async {
      // TODO
    });

    // FollowUpsMode suggestFollowUps
    test('to test the property `suggestFollowUps`', () async {
      // TODO
    });

    // Follow-up suggestions waiting for a decision
    // int openSuggestions
    test('to test the property `openSuggestions`', () async {
      // TODO
    });

    // The tickets holding this one's coding back right now (it is in coding with no commit yet). Absent when nothing does.
    // List<Blocker> blockedBy
    test('to test the property `blockedBy`', () async {
      // TODO
    });

    // String repoName
    test('to test the property `repoName`', () async {
      // TODO
    });

    // ModelOverrides models
    test('to test the property `models`', () async {
      // TODO
    });

    // When the ticket entered its current state
    // DateTime since
    test('to test the property `since`', () async {
      // TODO
    });

    // Why it failed or paused
    // String stopReason
    test('to test the property `stopReason`', () async {
      // TODO
    });

    // DateTime mergedAt
    test('to test the property `mergedAt`', () async {
      // TODO
    });

    // PullRequest pull
    test('to test the property `pull`', () async {
      // TODO
    });

    // TrackerUpdate trackerUpdate
    test('to test the property `trackerUpdate`', () async {
      // TODO
    });

    // The learn run after push; pending also while it runs
    // String learnState
    test('to test the property `learnState`', () async {
      // TODO
    });

    // The code review agnts runs beside the human review
    // String reviewState
    test('to test the property `reviewState`', () async {
      // TODO
    });

    // The screenshots agnts takes beside the human review
    // String previewState
    test('to test the property `previewState`', () async {
      // TODO
    });

    // Previews of this ticket also capture the default branch (before shots)
    // bool previewCompare
    test('to test the property `previewCompare`', () async {
      // TODO
    });

    // The ticket's repository has a preview command
    // bool canPreview
    test('to test the property `canPreview`', () async {
      // TODO
    });

    // TicketState continueTo
    test('to test the property `continueTo`', () async {
      // TODO
    });

    // This rejected ticket can start over from scratch (nothing of it was pushed); continueTo, when set, is where Continue sends it without a note
    // bool canStartOver
    test('to test the property `canStartOver`', () async {
      // TODO
    });

    // TokenSpend spend
    test('to test the property `spend`', () async {
      // TODO
    });

    // WaitReason waitReason
    test('to test the property `waitReason`', () async {
      // TODO
    });

    // Why it waits, in a sentence
    // String waitMessage
    test('to test the property `waitMessage`', () async {
      // TODO
    });

    // When it started waiting for a worker
    // DateTime queuedAt
    test('to test the property `queuedAt`', () async {
      // TODO
    });

    // Whose ticket it is (per-member Claude mode runs on their account)
    // int memberId
    test('to test the property `memberId`', () async {
      // TODO
    });

    // The member's username
    // String member
    test('to test the property `member`', () async {
      // TODO
    });

    // Who created it; absent for webhooks and agnts
    // String createdBy
    test('to test the property `createdBy`', () async {
      // TODO
    });

    // DateTime createdAt
    test('to test the property `createdAt`', () async {
      // TODO
    });

    // DateTime updatedAt
    test('to test the property `updatedAt`', () async {
      // TODO
    });

  });
}
