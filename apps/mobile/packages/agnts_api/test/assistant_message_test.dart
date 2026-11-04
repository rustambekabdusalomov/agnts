import 'package:test/test.dart';
import 'package:agnts_api/agnts_api.dart';

// tests for AssistantMessage
void main() {
  final AssistantMessage? instance = /* AssistantMessage(...) */ null;
  // TODO add properties to the entity

  group(AssistantMessage, () {
    // int id
    test('to test the property `id`', () async {
      // TODO
    });

    // String role
    test('to test the property `role`', () async {
      // TODO
    });

    // The question, or the answer in Markdown
    // String text
    test('to test the property `text`', () async {
      // TODO
    });

    // The answer in 1-3 plain sentences (empty for questions)
    // String speech
    test('to test the property `speech`', () async {
      // TODO
    });

    // List<AssistantLink> links
    test('to test the property `links`', () async {
      // TODO
    });

    // String status
    test('to test the property `status`', () async {
      // TODO
    });

    // Why the answer failed
    // String error
    test('to test the property `error`', () async {
      // TODO
    });

    // AssistantLanguage lang
    test('to test the property `lang`', () async {
      // TODO
    });

    // int durationMs
    test('to test the property `durationMs`', () async {
      // TODO
    });

    // The snapshot files the answer was made from
    // List<String> files
    test('to test the property `files`', () async {
      // TODO
    });

    // Your rating: 1 helpful, -1 not, 0 none
    // int rating
    test('to test the property `rating`', () async {
      // TODO
    });

    // String ratingComment
    test('to test the property `ratingComment`', () async {
      // TODO
    });

    // The answer's snapshot is kept for prompt tests
    // bool shared
    test('to test the property `shared`', () async {
      // TODO
    });

    // Actions the answer proposes, each waiting for you to confirm
    // List<AssistantAction> actions
    test('to test the property `actions`', () async {
      // TODO
    });

    // Actions the assistant tried to propose that agnts could not prepare, and why
    // List<String> actionErrors
    test('to test the property `actionErrors`', () async {
      // TODO
    });

    // CodeHandoff handoff
    test('to test the property `handoff`', () async {
      // TODO
    });

    // Code mode: the ticket the message went to
    // String ticketKey
    test('to test the property `ticketKey`', () async {
      // TODO
    });

    // CodeRouted routed
    test('to test the property `routed`', () async {
      // TODO
    });

    // Uploads that went with the message (ids)
    // List<int> attachments
    test('to test the property `attachments`', () async {
      // TODO
    });

    // The uploads of attachments still there, to show
    // List<AttachedFile> attachedFiles
    test('to test the property `attachedFiles`', () async {
      // TODO
    });

    // DateTime createdAt
    test('to test the property `createdAt`', () async {
      // TODO
    });

  });
}
