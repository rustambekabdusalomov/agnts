import 'package:test/test.dart';
import 'package:agnts_api/agnts_api.dart';


/// tests for AssistantApi
void main() {
  final instance = AgntsApi().getAssistantApi();

  group(AssistantApi, () {
    // Ask a follow-up question in one of your conversations
    //
    // Answered after the conversation's earlier questions, with the last 6 messages as context.
    //
    //Future<AssistantConversation> askAssistant(int conversationId, AssistantAsk assistantAsk) async
    test('test askAssistant', () async {
      // TODO
    });

    // Decline an action the assistant proposed
    //
    //Future<AssistantAction> cancelAssistantAction(String actionId) async
    test('test cancelAssistantAction', () async {
      // TODO
    });

    // Do an action the assistant proposed on one of your answers
    //
    // Runs the action once, as you. When agnts cannot do it now (the ticket moved on), the action comes back failed with the reason. Proposed actions expire after 30 minutes.
    //
    //Future<AssistantAction> confirmAssistantAction(String actionId) async
    test('test confirmAssistantAction', () async {
      // TODO
    });

    // Delete one of your conversations
    //
    //Future deleteAssistantConversation(int conversationId) async
    test('test deleteAssistantConversation', () async {
      // TODO
    });

    // One of your conversations with all its messages
    //
    //Future<AssistantConversation> getAssistantConversation(int conversationId) async
    test('test getAssistantConversation', () async {
      // TODO
    });

    // How the workspace's assistant did (questions, answer rate, time, ratings, tokens, per prompt version)
    //
    //Future<AssistantStats> getAssistantStats({ int days }) async
    test('test getAssistantStats', () async {
      // TODO
    });

    // Your assistant conversations, newest first, each with its last message
    //
    // A conversation belongs to the person who started it; nobody else sees it. Kept for 30 days after its last message.
    //
    //Future<List<AssistantConversation>> listAssistantConversations() async
    test('test listAssistantConversations', () async {
      // TODO
    });

    // Rated answers with their questions, newest rating first
    //
    //Future<List<AssistantRated>> listAssistantRated({ String rating }) async
    test('test listAssistantRated', () async {
      // TODO
    });

    // Rate one of your answers (helpful or not), or take the rating back
    //
    // A rating, its comment, the answer and its question are shown to the workspace's owner. With share, the snapshot the answer was made from is kept with it so new prompts can be tried on the question.
    //
    //Future<AssistantMessage> rateAssistantAnswer(int messageId, AssistantRating assistantRating) async
    test('test rateAssistantAnswer', () async {
      // TODO
    });

    // Ask the assistant a question in a new conversation
    //
    // Stores the question and starts answering it from a read-only snapshot of the workspace. Answers take 10-30 seconds: the response has the answer pending; fetch the conversation again, or wait for the assistant_answered (or assistant_failed) event on the event stream. The assistant takes no actions itself: when asked to act it proposes them as actions on its answer, which you confirm.
    //
    //Future<AssistantConversation> startAssistantConversation(AssistantAsk assistantAsk) async
    test('test startAssistantConversation', () async {
      // TODO
    });

  });
}
