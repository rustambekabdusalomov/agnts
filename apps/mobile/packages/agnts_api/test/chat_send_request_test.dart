import 'package:test/test.dart';
import 'package:agnts_api/agnts_api.dart';

// tests for ChatSendRequest
void main() {
  final ChatSendRequest? instance = /* ChatSendRequest(...) */ null;
  // TODO add properties to the entity

  group(ChatSendRequest, () {
    // Made on the device; a resend with the same id returns the stored message
    // String clientMsgId
    test('to test the property `clientMsgId`', () async {
      // TODO
    });

    // May be empty when files are sent
    // String body
    test('to test the property `body`', () async {
      // TODO
    });

    // The sender's pending uploads (uploadAttachment) to send with it
    // List<int> files
    test('to test the property `files`', () async {
      // TODO
    });

    // int replyTo
    test('to test the property `replyTo`', () async {
      // TODO
    });

  });
}
