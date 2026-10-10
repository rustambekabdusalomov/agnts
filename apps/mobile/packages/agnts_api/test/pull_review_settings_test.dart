import 'package:test/test.dart';
import 'package:agnts_api/agnts_api.dart';

// tests for PullReviewSettings
void main() {
  final PullReviewSettings? instance = /* PullReviewSettings(...) */ null;
  // TODO add properties to the entity

  group(PullReviewSettings, () {
    // Sync the pull requests waiting for you every few minutes and review the new ones
    // bool enabled
    test('to test the property `enabled`', () async {
      // TODO
    });

    // Also take pull requests whose review is requested from you, not only those assigned to you
    // bool reviewRequested
    test('to test the property `reviewRequested`', () async {
      // TODO
    });

    // Leave draft pull requests alone until they are ready
    // bool skipDrafts
    test('to test the property `skipDrafts`', () async {
      // TODO
    });

    // Review again when the author pushes new commits while agnts's review waits for you
    // bool rereview
    test('to test the property `rereview`', () async {
      // TODO
    });

    // How an accepted pull request is merged
    // String mergeMethod
    test('to test the property `mergeMethod`', () async {
      // TODO
    });

  });
}
