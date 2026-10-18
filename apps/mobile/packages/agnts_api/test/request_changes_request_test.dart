import 'package:test/test.dart';
import 'package:agnts_api/agnts_api.dart';

// tests for RequestChangesRequest
void main() {
  final RequestChangesRequest? instance = /* RequestChangesRequest(...) */ null;
  // TODO add properties to the entity

  group(RequestChangesRequest, () {
    // String feedback
    test('to test the property `feedback`', () async {
      // TODO
    });

    // Preview screenshots the feedback points at; the coding run gets them
    // List<ShotRef> shots
    test('to test the property `shots`', () async {
      // TODO
    });

    // Uploads that go with the feedback (mockups, logs, screenshots); the coding run reads them
    // List<int> attachments
    test('to test the property `attachments`', () async {
      // TODO
    });

    // Skip the build, lint and test checks (and the proof and coverage that run tests) in this and later coding runs of the ticket, going to review on the code alone; false turns them back on. Left out, the ticket keeps its setting.
    // bool skipChecks
    test('to test the property `skipChecks`', () async {
      // TODO
    });

  });
}
