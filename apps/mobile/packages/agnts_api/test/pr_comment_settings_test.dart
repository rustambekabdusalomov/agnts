import 'package:test/test.dart';
import 'package:agnts_api/agnts_api.dart';

// tests for PRCommentSettings
void main() {
  final PRCommentSettings? instance = /* PRCommentSettings(...) */ null;
  // TODO add properties to the entity

  group(PRCommentSettings, () {
    // Add \"via agnts · <person>\" to comments written through agnts (they all go out as the git host token's user)
    // bool attribution
    test('to test the property `attribution`', () async {
      // TODO
    });

    // Keep the comments you write on others' pull requests on the git host as notes on how you review
    // bool learnFromComments
    test('to test the property `learnFromComments`', () async {
      // TODO
    });

    // Resolve a reviewer's thread once agnts pushed the fix and answered it
    // bool resolveFixed
    test('to test the property `resolveFixed`', () async {
      // TODO
    });

    // Send the unresolved threads back to the ticket when a reviewer requests changes on agnts's pull request (the fix still waits for your approval)
    // bool autoAddress
    test('to test the property `autoAddress`', () async {
      // TODO
    });

  });
}
