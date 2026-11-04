import 'package:test/test.dart';
import 'package:agnts_api/agnts_api.dart';


/// tests for AttachmentsApi
void main() {
  final instance = AgntsApi().getAttachmentsApi();

  group(AttachmentsApi, () {
    // Delete an upload that nothing uses yet
    //
    // Viewers delete only their own uploads; editors any pending one.
    //
    //Future deleteAttachment(int id) async
    test('test deleteAttachment', () async {
      // TODO
    });

    // An attached file's bytes
    //
    // An AI chat (Ask) question's file is only its asker's; anyone else gets 404.
    //
    //Future<Uint8List> getAttachment(int id) async
    test('test getAttachment', () async {
      // TODO
    });

    // Upload a file to attach to a task, an answer, a retry note or a chat message
    //
    // The upload stays pending until the request that uses it (createTask, updateTask, answerQuestions, retryTicket, requestChanges, sendChatMessage, askAssistant, Code mode) lists its id; pending uploads nobody used are deleted after a day. Pictures (PNG, JPEG, GIF, WebP) are shown in place; other files download. Claude reads every attached file, pictures and PDFs included. Viewers may upload too, for the chats.
    //
    //Future<Attachment> uploadAttachment(MultipartFile file) async
    test('test uploadAttachment', () async {
      // TODO
    });

  });
}
