import 'package:test/test.dart';
import 'package:agnts_api/agnts_api.dart';

// tests for ReviewSync
void main() {
  final ReviewSync? instance = /* ReviewSync(...) */ null;
  // TODO add properties to the entity

  group(ReviewSync, () {
    // Repositories asked
    // int repos
    test('to test the property `repos`', () async {
      // TODO
    });

    // Pull requests waiting for you
    // int open
    test('to test the property `open`', () async {
      // TODO
    });

    // New reviews queued
    // int created
    test('to test the property `created`', () async {
      // TODO
    });

    // Reviews queued again for new commits
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
