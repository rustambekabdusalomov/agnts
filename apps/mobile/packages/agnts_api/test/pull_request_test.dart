import 'package:test/test.dart';
import 'package:agnts_api/agnts_api.dart';

// tests for PullRequest
void main() {
  final PullRequest? instance = /* PullRequest(...) */ null;
  // TODO add properties to the entity

  group(PullRequest, () {
    // The pull request number (GitLab: the IID)
    // int number
    test('to test the property `number`', () async {
      // TODO
    });

    // String url
    test('to test the property `url`', () async {
      // TODO
    });

    // String title
    test('to test the property `title`', () async {
      // TODO
    });

    // Git host username of the author
    // String author
    test('to test the property `author`', () async {
      // TODO
    });

    // The branch it comes from
    // String headRef
    test('to test the property `headRef`', () async {
      // TODO
    });

    // Its newest commit on the git host
    // String headSha
    test('to test the property `headSha`', () async {
      // TODO
    });

    // The branch it goes into
    // String baseRef
    test('to test the property `baseRef`', () async {
      // TODO
    });

    // bool draft
    test('to test the property `draft`', () async {
      // TODO
    });

    // String state
    test('to test the property `state`', () async {
      // TODO
    });

    // The git host user it waits for; their reviewer profile shapes its reviews
    // String login
    test('to test the property `login`', () async {
      // TODO
    });

    // String why
    test('to test the property `why`', () async {
      // TODO
    });

    // int additions
    test('to test the property `additions`', () async {
      // TODO
    });

    // int deletions
    test('to test the property `deletions`', () async {
      // TODO
    });

    // DateTime updatedAt
    test('to test the property `updatedAt`', () async {
      // TODO
    });

    // The reviewed commit whose review agnts last posted on the pull request
    // String postedSha
    test('to test the property `postedSha`', () async {
      // TODO
    });

    // When agnts last posted its review on the pull request
    // DateTime postedAt
    test('to test the property `postedAt`', () async {
      // TODO
    });

  });
}
