import 'package:test/test.dart';
import 'package:agnts_api/agnts_api.dart';

// tests for TicketRepoState
void main() {
  final TicketRepoState? instance = /* TicketRepoState(...) */ null;
  // TODO add properties to the entity

  group(TicketRepoState, () {
    // int repoId
    test('to test the property `repoId`', () async {
      // TODO
    });

    // String repoName
    test('to test the property `repoName`', () async {
      // TODO
    });

    // Its role in the group, as people named it (backend, web)
    // String role
    test('to test the property `role`', () async {
      // TODO
    });

    // Its folder in the run, /workspace/<folder>; empty when the ticket has one repository
    // String folder
    test('to test the property `folder`', () async {
      // TODO
    });

    // String branch
    test('to test the property `branch`', () async {
      // TODO
    });

    // String headSha
    test('to test the property `headSha`', () async {
      // TODO
    });

    // int prNumber
    test('to test the property `prNumber`', () async {
      // TODO
    });

    // String prUrl
    test('to test the property `prUrl`', () async {
      // TODO
    });

    // Rounds a red CI check on its pull request sent the ticket back to coding
    // int ciFixes
    test('to test the property `ciFixes`', () async {
      // TODO
    });

    // pending = not pushed yet; unchanged = the work did not change it (no pull request); pushed; merged; dropped = its pull request was closed without a merge
    // String state
    test('to test the property `state`', () async {
      // TODO
    });

    // DateTime mergedAt
    test('to test the property `mergedAt`', () async {
      // TODO
    });

    // DateTime closedAt
    test('to test the property `closedAt`', () async {
      // TODO
    });

    // Why its last push failed; a retry pushes it again
    // String pushError
    test('to test the property `pushError`', () async {
      // TODO
    });

    // Its branch was never pushed and can still be renamed (ticket detail only)
    // bool canRenameBranch
    test('to test the property `canRenameBranch`', () async {
      // TODO
    });

    // Files its change touches
    // int files
    test('to test the property `files`', () async {
      // TODO
    });

    // The repository is archived
    // bool archived
    test('to test the property `archived`', () async {
      // TODO
    });

  });
}
