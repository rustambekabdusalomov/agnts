import 'package:test/test.dart';
import 'package:agnts_api/agnts_api.dart';

// tests for PostReviewInput
void main() {
  final PostReviewInput? instance = /* PostReviewInput(...) */ null;
  // TODO add properties to the entity

  group(PostReviewInput, () {
    // Post the summary (verdict and every finding)
    // bool summary (default value: true)
    test('to test the property `summary`', () async {
      // TODO
    });

    // Indexes of the findings to post on their lines; left out, every finding on a line of the diff
    // List<int> findings
    test('to test the property `findings`', () async {
      // TODO
    });

    // Post it as a request for changes (GitHub)
    // bool requestChanges
    test('to test the property `requestChanges`', () async {
      // TODO
    });

  });
}
