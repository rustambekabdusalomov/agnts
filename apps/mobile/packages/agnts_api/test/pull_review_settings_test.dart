import 'package:test/test.dart';
import 'package:agnts_api/agnts_api.dart';

// tests for PullReviewSettings
void main() {
  final PullReviewSettings? instance = /* PullReviewSettings(...) */ null;
  // TODO add properties to the entity

  group(PullReviewSettings, () {
    // Unused: reviews start from the pull request, and open reviews are kept up to date always
    // bool enabled
    test('to test the property `enabled`', () async {
      // TODO
    });

    // Also take pull requests whose review is requested from you, not only those assigned to you
    // bool reviewRequested
    test('to test the property `reviewRequested`', () async {
      // TODO
    });

    // Take every open pull request in your repositories, yours included, whether or not it waits for you; left out, it stays as it is
    // bool all
    test('to test the property `all`', () async {
      // TODO
    });

    // Leave draft pull requests alone until they are ready
    // bool skipDrafts
    test('to test the property `skipDrafts`', () async {
      // TODO
    });

    // Unused: reviewing again after new commits is your call, from the pull request
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
