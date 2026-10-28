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

    // Make an existing ticket the one a Code conversation works on
    //
    // The next message goes to it. Another of your conversations that had it lets it go.
    //
    //Future<AssistantConversation> attachCodeTicket(int conversationId, AttachCodeTicketRequest attachCodeTicketRequest) async
    test('test attachCodeTicket', () async {
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

    // Allow or deny a tool call the agent asked you about
    //
    // A Muse run in one of your Code conversations wants to run a command a rule says to ask about (installing a dependency, say). It waits for your answer; with none in 5 minutes the call is denied.
    //
    //Future<CodeApproval> decideCodeApproval(String approvalId, DecideCodeApprovalRequest decideCodeApprovalRequest) async
    test('test decideCodeApproval', () async {
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

    // A Code conversation with its timeline
    //
    // Your messages and its tickets' events (the newest 600), oldest first, and the tool calls waiting for your decision. Live updates come on the event stream: the tickets' own events, code_message and code_approval.
    //
    //Future<CodeTimeline> getCodeTimeline(int conversationId) async
    test('test getCodeTimeline', () async {
      // TODO
    });

    // Your Code conversation that works on this ticket
    //
    //Future<GetTicketChat200Response> getTicketChat(String key) async
    test('test getTicketChat', () async {
      // TODO
    });

    // Your assistant conversations, newest first, each with its last message
    //
    // A conversation belongs to the person who started it; nobody else sees it. Kept for 30 days after its last message; a Code conversation stays while one of its tickets is open.
    //
    //Future<List<AssistantConversation>> listAssistantConversations({ ChatMode mode }) async
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

    // Send a message in a Code conversation
    //
    // What it does depends on the current ticket's state, shown as routed: a new ticket when there is none or it is done; answers while it waits for answers; requested changes while it waits for review; continue or retry when it stopped. While a stage runs the message is queued and sent when the stage ends (a Muse run takes it at once: steered). Approve and reject are the ticket's own endpoints.
    //
    //Future<AssistantMessage> sendCodeMessage(int conversationId, CodeSend codeSend) async
    test('test sendCodeMessage', () async {
      // TODO
    });

    // Stop the running stage and send the queued messages now
    //
    //Future<AssistantConversation> sendCodeQueuedNow(int conversationId) async
    test('test sendCodeQueuedNow', () async {
      // TODO
    });

    // Change the repositories of a Code conversation
    //
    // The next ticket works in them; the current one moves too while it has not started on code.
    //
    //Future<AssistantConversation> setCodeRepos(int conversationId, RepoChoice repoChoice) async
    test('test setCodeRepos', () async {
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

    // Start a Code conversation
    //
    // Code mode: pick the repositories (or an existing ticket with ticketKey) and say what you want done. The work runs as an ordinary ticket the conversation drives; its progress is the ticket's events (see getCodeTimeline). Owners and editors only.
    //
    //Future<AssistantConversation> startCodeConversation(CodeStart codeStart) async
    test('test startCodeConversation', () async {
      // TODO
    });

    // Turn a spoken question into text
    //
    // Muse Code hears the recording (`muse voice transcribe`) on the account your answers run on, and returns its words; ask them with startAssistantConversation or askAssistant as you would typed ones. The recording is 16-bit PCM WAV (16 kHz mono is plenty), at most 2 minutes; it is not kept. One recording at a time per person.
    //
    //Future<AssistantTranscript> transcribeAssistantQuestion(MultipartFile file) async
    test('test transcribeAssistantQuestion', () async {
      // TODO
    });

  });
}
