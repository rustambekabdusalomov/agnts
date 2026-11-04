import 'package:test/test.dart';
import 'package:agnts_api/agnts_api.dart';

// tests for MeetingActionItem
void main() {
  final MeetingActionItem? instance = /* MeetingActionItem(...) */ null;
  // TODO add properties to the entity

  group(MeetingActionItem, () {
    // int id
    test('to test the property `id`', () async {
      // TODO
    });

    // int position
    test('to test the property `position`', () async {
      // TODO
    });

    // String text
    test('to test the property `text`', () async {
      // TODO
    });

    // As named in the meeting
    // String who
    test('to test the property `who`', () async {
      // TODO
    });

    // As said
    // String due
    test('to test the property `due`', () async {
      // TODO
    });

    // When it was said, from the start of the call
    // int atMs
    test('to test the property `atMs`', () async {
      // TODO
    });

    // String quote
    test('to test the property `quote`', () async {
      // TODO
    });

    // Who said the line where it was taken, as the transcript names them; empty when it does not say
    // String speaker
    test('to test the property `speaker`', () async {
      // TODO
    });

    // The member who takes it: matched from the name as said, or picked by hand; absent when nobody matched
    // int memberId
    test('to test the property `memberId`', () async {
      // TODO
    });

    // String memberName
    test('to test the property `memberName`', () async {
      // TODO
    });

    // The member was picked by hand, not matched
    // bool memberByHand
    test('to test the property `memberByHand`', () async {
      // TODO
    });

    // Its draft ticket was made when the notes were written
    // bool drafted
    test('to test the property `drafted`', () async {
      // TODO
    });

    // The ticket made from it
    // String ticketKey
    test('to test the property `ticketKey`', () async {
      // TODO
    });

  });
}
