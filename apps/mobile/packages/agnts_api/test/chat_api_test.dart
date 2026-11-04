import 'package:test/test.dart';
import 'package:agnts_api/agnts_api.dart';


/// tests for ChatApi
void main() {
  final instance = AgntsApi().getChatApi();

  group(ChatApi, () {
    // Press a button on agnts's card; it runs the real action (approve, merge, fix, …) and returns the card
    //
    //Future<ChatMessage> actOnChatCard(int messageId, ChatActionRequest chatActionRequest) async
    test('test actOnChatCard', () async {
      // TODO
    });

    // Turn a message into a ticket draft; the draft card arrives in the thread as an event
    //
    //Future chatMessageToTicket(int messageId) async
    test('test chatMessageToTicket', () async {
      // TODO
    });

    // Make a channel
    //
    //Future<ChatChannel> createChatChannel(ChatChannelInput chatChannelInput) async
    test('test createChatChannel', () async {
      // TODO
    });

    // A voice message's recording, to play
    //
    //Future<Uint8List> getChatAudio(int messageId) async
    test('test getChatAudio', () async {
      // TODO
    });

    // One message with its refs (opens a citation in its channel)
    //
    //Future<ChatMessage> getChatMessage(int messageId) async
    test('test getChatMessage', () async {
      // TODO
    });

    // What the model did in the team chat today (links, answers, drafts) and its median time
    //
    //Future<ChatStats> getChatStats() async
    test('test getChatStats', () async {
      // TODO
    });

    // The workspace's team chat channels, with your unread counts (makes
    //
    //Future<List<ChatChannel>> listChatChannels() async
    test('test listChatChannels', () async {
      // TODO
    });

    // A page of a channel, oldest first (the newest, the ones before `before`, or the ones after `after` to fill a gap after a reconnect)
    //
    //Future<List<ChatMessage>> listChatMessages(int channelId, { int before, int after, int limit }) async
    test('test listChatMessages', () async {
      // TODO
    });

    // Save how far you have read a channel
    //
    //Future markChatRead(int channelId, MarkChatReadRequest markChatReadRequest) async
    test('test markChatRead', () async {
      // TODO
    });

    // Remove a wrong link under a message (the linker will not add it back)
    //
    //Future<ChatMessage> removeChatRef(int messageId, RemoveChatRefRequest removeChatRefRequest) async
    test('test removeChatRef', () async {
      // TODO
    });

    // Send a message. The same clientMsgId sent again returns the stored message (200) instead of a second one (201)
    //
    //Future<ChatMessage> sendChatMessage(int channelId, ChatSendRequest chatSendRequest) async
    test('test sendChatMessage', () async {
      // TODO
    });

    // Send a voice message. Muse hears it after it is stored; its words become the message's text (an event brings them)
    //
    //Future<ChatMessage> sendChatVoice(int channelId, String clientMsgId, int durationMs, MultipartFile audio, MultipartFile wav, { int replyTo }) async
    test('test sendChatVoice', () async {
      // TODO
    });

    // Change a channel's topic, make it agnts's channel, or archive it
    //
    //Future<ChatChannel> updateChatChannel(int channelId, ChatChannelUpdate chatChannelUpdate) async
    test('test updateChatChannel', () async {
      // TODO
    });

  });
}
