import 'package:test/test.dart';
import 'package:agnts_api/agnts_api.dart';

// tests for RetryTicketRequest
void main() {
  final RetryTicketRequest? instance = /* RetryTicketRequest(...) */ null;
  // TODO add properties to the entity

  group(RetryTicketRequest, () {
    // How to get past the failure. The next coding run gets it with the error, like requested changes. Not allowed when the ticket resumes at pushing, since no Claude run follows.
    // String note
    test('to test the property `note`', () async {
      // TODO
    });

    // Uploads that help get past the failure; the next coding run reads them. Same rule as note.
    // List<int> attachments
    test('to test the property `attachments`', () async {
      // TODO
    });

    // Skip the build, lint and test checks (and the proof and coverage that run tests) in this and later coding runs of the ticket, going to review on the code alone; false turns them back on. Left out, the ticket keeps its setting.
    // bool skipChecks
    test('to test the property `skipChecks`', () async {
      // TODO
    });

    // Throw away the unfinished change a stopped run left (the ticket's savedWork); the next coding run starts from the last commit instead.
    // bool discardWork
    test('to test the property `discardWork`', () async {
      // TODO
    });

  });
}
