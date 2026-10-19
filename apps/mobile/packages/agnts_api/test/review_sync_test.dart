import 'package:test/test.dart';
import 'package:agnts_api/agnts_api.dart';

// tests for ReviewSync
void main() {
  final ReviewSync? instance = /* ReviewSync(...) */ null;
  // TODO add properties to the entity

  group(ReviewSync, () {
    // Repositories with an open review
    // int repos
    test('to test the property `repos`', () async {
      // TODO
    });

    // Open reviews checked
    // int open
    test('to test the property `open`', () async {
      // TODO
    });

    // Always 0; reviews start from the pull request
    // int created
    test('to test the property `created`', () async {
      // TODO
    });

    // Always 0; reviewing again is your call
    // int rereview
    test('to test the property `rereview`', () async {
      // TODO
    });

    // Reviews ended because the pull request was merged or closed on the git host
    // int closed
    test('to test the property `closed`', () async {
      // TODO
    });

    // Repositories or pull requests that could not be read
    // List<String> errors
    test('to test the property `errors`', () async {
      // TODO
    });

  });
}
