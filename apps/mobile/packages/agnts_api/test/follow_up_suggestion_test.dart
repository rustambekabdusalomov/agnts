import 'package:test/test.dart';
import 'package:agnts_api/agnts_api.dart';

// tests for FollowUpSuggestion
void main() {
  final FollowUpSuggestion? instance = /* FollowUpSuggestion(...) */ null;
  // TODO add properties to the entity

  group(FollowUpSuggestion, () {
    // int id
    test('to test the property `id`', () async {
      // TODO
    });

    // The run that suggested it; manual = made from a review finding
    // String source_
    test('to test the property `source_`', () async {
      // TODO
    });

    // How it serves the parent ticket
    // String type
    test('to test the property `type`', () async {
      // TODO
    });

    // The parent's revision when it was suggested
    // int revision
    test('to test the property `revision`', () async {
      // TODO
    });

    // String title
    test('to test the property `title`', () async {
      // TODO
    });

    // String description
    test('to test the property `description`', () async {
      // TODO
    });

    // How it helps finish the parent ticket
    // String serves
    test('to test the property `serves`', () async {
      // TODO
    });

    // TicketKind kind
    test('to test the property `kind`', () async {
      // TODO
    });

    // String priority
    test('to test the property `priority`', () async {
      // TODO
    });

    // String status
    test('to test the property `status`', () async {
      // TODO
    });

    // A ticket can be made from it now (open, and the parent is done unless the analysis suggested it)
    // bool ready
    test('to test the property `ready`', () async {
      // TODO
    });

    // Ids of sibling suggestions that must land first; once both are tickets, this one depends on them
    // List<int> after
    test('to test the property `after`', () async {
      // TODO
    });

    // The ticket made from it
    // String childKey
    test('to test the property `childKey`', () async {
      // TODO
    });

    // DateTime decidedAt
    test('to test the property `decidedAt`', () async {
      // TODO
    });

    // DateTime createdAt
    test('to test the property `createdAt`', () async {
      // TODO
    });

  });
}
