import 'package:test/test.dart';
import 'package:agnts_api/agnts_api.dart';

// tests for PullThread
void main() {
  final PullThread? instance = /* PullThread(...) */ null;
  // TODO add properties to the entity

  group(PullThread, () {
    // Opaque: pass it back to reply or resolve
    // String id
    test('to test the property `id`', () async {
      // TODO
    });

    // String kind
    test('to test the property `kind`', () async {
      // TODO
    });

    // String path
    test('to test the property `path`', () async {
      // TODO
    });

    // Line in the new file
    // int line
    test('to test the property `line`', () async {
      // TODO
    });

    // Line in the old file, for a removed line
    // int oldLine
    test('to test the property `oldLine`', () async {
      // TODO
    });

    // First line of a range
    // int startLine
    test('to test the property `startLine`', () async {
      // TODO
    });

    // String diffHunk
    test('to test the property `diffHunk`', () async {
      // TODO
    });

    // String commitSha
    test('to test the property `commitSha`', () async {
      // TODO
    });

    // The line changed since the thread started
    // bool outdated
    test('to test the property `outdated`', () async {
      // TODO
    });

    // bool resolvable
    test('to test the property `resolvable`', () async {
      // TODO
    });

    // bool resolved
    test('to test the property `resolved`', () async {
      // TODO
    });

    // A review's verdict: APPROVED, CHANGES_REQUESTED or COMMENTED
    // String reviewState
    test('to test the property `reviewState`', () async {
      // TODO
    });

    // On agnts's own pull request: sent back to the ticket as feedback, with no newer comment since
    // bool sent
    test('to test the property `sent`', () async {
      // TODO
    });

    // agnts answered it after pushing the fix
    // bool replied
    test('to test the property `replied`', () async {
      // TODO
    });

    // List<PullComment> comments
    test('to test the property `comments`', () async {
      // TODO
    });

  });
}
