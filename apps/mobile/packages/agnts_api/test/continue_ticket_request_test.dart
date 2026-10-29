import 'package:test/test.dart';
import 'package:agnts_api/agnts_api.dart';

// tests for ContinueTicketRequest
void main() {
  final ContinueTicketRequest? instance = /* ContinueTicketRequest(...) */ null;
  // TODO add properties to the entity

  group(ContinueTicketRequest, () {
    // What to do differently. The next coding run gets it, like requested changes. Not allowed when the ticket goes back to answers or to a failed state, since no Claude run follows.
    // String note
    test('to test the property `note`', () async {
      // TODO
    });

    // Uploads that go with the note; the next coding run reads them. Same rule as note.
    // List<int> attachments
    test('to test the property `attachments`', () async {
      // TODO
    });

    // Throw away the unfinished change a stopped run left (the ticket's savedWork); the next coding run starts from the last commit instead.
    // bool discardWork
    test('to test the property `discardWork`', () async {
      // TODO
    });

  });
}
