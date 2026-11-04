import 'package:test/test.dart';
import 'package:agnts_api/agnts_api.dart';


/// tests for MeetingsApi
void main() {
  final instance = AgntsApi().getMeetingsApi();

  group(MeetingsApi, () {
    // Hosts: mute someone (source: microphone, camera or screen_share), ask them to unmute, remove them, lower their hand, make them co-host
    //
    //Future actOnMeetingPerson(String code, String person, String action, { String xMeetingSeat, ActOnMeetingPersonRequest actOnMeetingPersonRequest }) async
    test('test actOnMeetingPerson', () async {
      // TODO
    });

    // Let everyone waiting in
    //
    //Future admitAllMeetingKnocks(String code, { String xMeetingSeat }) async
    test('test admitAllMeetingKnocks', () async {
      // TODO
    });

    // Answer an invitation
    //
    //Future answerMeeting(int meetingId, AnswerMeetingRequest answerMeetingRequest) async
    test('test answerMeeting', () async {
      // TODO
    });

    // Cancel a meeting; invitees get the cancellation in their calendar
    //
    //Future cancelMeeting(int meetingId) async
    test('test cancelMeeting', () async {
      // TODO
    });

    // Invite more people, or uninvite (the meeting's hosts)
    //
    //Future<MeetingDetail> changeMeetingInvitees(int meetingId, MeetingInviteesInput meetingInviteesInput) async
    test('test changeMeetingInvitees', () async {
      // TODO
    });

    // Make a ticket of an action item, with the words of the meeting that show it
    //
    //Future<Ticket> createActionItemTicket(int meetingId, int sessionId, int itemId, { ActionItemTicketInput actionItemTicketInput }) async
    test('test createActionItemTicket', () async {
      // TODO
    });

    // Make a meeting you host (instant or scheduled) and invite people
    //
    // Scheduled meetings' invitees get an email with the calendar event; members are told in agnts too.
    //
    //Future<MeetingDetail> createMeeting(MeetingInput meetingInput) async
    test('test createMeeting', () async {
      // TODO
    });

    // Let someone in, or turn them away
    //
    //Future decideMeetingKnock(String code, int knockId, String decision, { String xMeetingSeat }) async
    test('test decideMeetingKnock', () async {
      // TODO
    });

    // Delete a meeting with its calls, recordings and transcripts (the host or the owner); notes documents stay
    //
    //Future deleteMeeting(int meetingId) async
    test('test deleteMeeting', () async {
      // TODO
    });

    // Delete a recording now (the host or the owner)
    //
    //Future deleteMeetingRecording(int meetingId, int sessionId, int mediaId) async
    test('test deleteMeetingRecording', () async {
      // TODO
    });

    // End the call for everyone (the host)
    //
    //Future endMeetingCall(String code, { String xMeetingSeat }) async
    test('test endMeetingCall', () async {
      // TODO
    });

    // A meeting with its invitees
    //
    //Future<MeetingDetail> getMeeting(int meetingId) async
    test('test getMeeting', () async {
      // TODO
    });

    // The call as you see it in it - people, waiting room, what you may do
    //
    //Future<MeetingCall> getMeetingCall(String code, { String xMeetingSeat }) async
    test('test getMeetingCall', () async {
      // TODO
    });

    // Your meeting reminders
    //
    //Future<MeetingPrefs> getMeetingPrefs() async
    test('test getMeetingPrefs', () async {
      // TODO
    });

    // Watch or download a call's recording (MP4; ranges for seeking)
    //
    //Future<Uint8List> getMeetingRecording(int meetingId, int sessionId, int mediaId, { bool download }) async
    test('test getMeetingRecording', () async {
      // TODO
    });

    // A call's attendance, recordings, notes and action items
    //
    // For the people who were in it, the meeting's invitees, its hosts and the owner.
    //
    //Future<MeetingSessionDetail> getMeetingSession(int meetingId, int sessionId) async
    test('test getMeetingSession', () async {
      // TODO
    });

    // The workspace's rules for meetings, and what this server can do
    //
    //Future<MeetingSettings> getMeetingSettings() async
    test('test getMeetingSettings', () async {
      // TODO
    });

    // What was said, as Muse heard it
    //
    //Future<MeetingTranscript> getMeetingTranscript(int meetingId, int sessionId, { String format }) async
    test('test getMeetingTranscript', () async {
      // TODO
    });

    // The workspace's use of meetings per day (people-minutes, recordings, transcribed audio)
    //
    //Future<List<MeetingUsageDay>> getMeetingUsage({ int days }) async
    test('test getMeetingUsage', () async {
      // TODO
    });

    // What anyone with the link sees before joining
    //
    // Title, host, times and whether it is live. Says whether the signed-in person is a member of its workspace.
    //
    //Future<PublicMeeting> getPublicMeeting(String code) async
    test('test getPublicMeeting', () async {
      // TODO
    });

    // Join a meeting, or knock to be let in
    //
    // Members of the meeting's workspace are recognised by their session; everyone else is a guest: by the name they type, Google, their agnts account, or an invitation link's token. A returning guest sends their guest token (X-Guest-Token) to stay the same guest. joined hands out the LiveKit grant and the seat for in-call requests; waiting hands out a knock to poll. Refusals are 403 with the reason as the code (locked, full, removed, guests_off, not_started, cancelled, denied). 
    //
    //Future<MeetingJoin> joinMeeting(String code, MeetingJoinInput meetingJoinInput, { String xGuestToken }) async
    test('test joinMeeting', () async {
      // TODO
    });

    // The call's chat after a message
    //
    //Future<List<MeetingMessage>> listMeetingCallMessages(String code, { String xMeetingSeat, int after }) async
    test('test listMeetingCallMessages', () async {
      // TODO
    });

    // A call's chat
    //
    //Future<List<MeetingMessage>> listMeetingSessionMessages(int meetingId, int sessionId) async
    test('test listMeetingSessionMessages', () async {
      // TODO
    });

    // The times a meeting was live, newest first
    //
    //Future<List<MeetingSessionBrief>> listMeetingSessions(int meetingId) async
    test('test listMeetingSessions', () async {
      // TODO
    });

    // The meetings you see
    //
    // upcoming: live ones first, then scheduled ones that have not ended; live: the live ones; mine: the ones you host; agenda: your own (you host, co-host, or are invited and have not declined) that are live or start within 36 hours and have not ended.
    //
    //Future<List<Meeting>> listMeetings({ String view }) async
    test('test listMeetings', () async {
      // TODO
    });

    // Calls that happened, newest first, of the meetings you see
    //
    //Future<List<MeetingSessionSummary>> listPastMeetingSessions({ DateTime before, int limit }) async
    test('test listPastMeetingSessions', () async {
      // TODO
    });

    // The meetings a ticket was discussed in or made from
    //
    //Future<List<MeetingTicketLink>> listTicketMeetings(String key) async
    test('test listTicketMeetings', () async {
      // TODO
    });

    // Mute everyone's microphone but yours (hosts)
    //
    //Future muteAllInMeeting(String code, { String xMeetingSeat }) async
    test('test muteAllInMeeting', () async {
      // TODO
    });

    // Change your meeting reminders
    //
    //Future<MeetingPrefs> putMeetingPrefs(MeetingPrefs meetingPrefs) async
    test('test putMeetingPrefs', () async {
      // TODO
    });

    // Change the workspace's rules for meetings (the owner)
    //
    //Future<MeetingSettings> putMeetingSettings(MeetingSettingsInput meetingSettingsInput) async
    test('test putMeetingSettings', () async {
      // TODO
    });

    // A new LiveKit token for your seat (to reconnect)
    //
    //Future<MeetingGrant> refreshMeetingToken(String code, { String xMeetingSeat }) async
    test('test refreshMeetingToken', () async {
      // TODO
    });

    // Have Muse write a call's notes again (the meeting's hosts)
    //
    //Future regenerateMeetingNotes(int meetingId, int sessionId) async
    test('test regenerateMeetingNotes', () async {
      // TODO
    });

    // Ring members into the meeting now (their phone and open agnts pages, for 30 seconds)
    //
    //Future ringMeeting(int meetingId, RingMeetingRequest ringMeetingRequest) async
    test('test ringMeeting', () async {
      // TODO
    });

    // Find what was said in the meetings you see
    //
    //Future<List<MeetingTranscriptHit>> searchMeetingTranscripts(String q) async
    test('test searchMeetingTranscripts', () async {
      // TODO
    });

    // Send a chat message to the call (no secrets; at most 30 a minute)
    //
    //Future<MeetingMessage> sendMeetingMessage(String code, SendMeetingMessageRequest sendMeetingMessageRequest, { String xMeetingSeat }) async
    test('test sendMeetingMessage', () async {
      // TODO
    });

    // Hosts: lock the meeting, change who may come in, quiet guests, record, take notes
    //
    //Future setMeetingCallSettings(String code, MeetingCallSettings meetingCallSettings, { String xMeetingSeat }) async
    test('test setMeetingCallSettings', () async {
      // TODO
    });

    // Choose a meeting's co-hosts (the host)
    //
    //Future<MeetingDetail> setMeetingCohosts(int meetingId, SetMeetingCohostsRequest setMeetingCohostsRequest) async
    test('test setMeetingCohosts', () async {
      // TODO
    });

    // Hand a meeting to another member (the host or the owner)
    //
    //Future<MeetingDetail> setMeetingHost(int meetingId, TransferWorkspaceRequest transferWorkspaceRequest) async
    test('test setMeetingHost', () async {
      // TODO
    });

    // Change a meeting (its hosts and the owner); a new time sends the invitees an update
    //
    //Future<MeetingDetail> updateMeeting(int meetingId, MeetingInput meetingInput) async
    test('test updateMeeting', () async {
      // TODO
    });

    // Wait (up to 25 seconds) for a knock to be answered
    //
    // joined with the grant once let in, waiting while nobody answered, 403 denied or expired.
    //
    //Future<MeetingJoin> waitMeetingKnock(String code, int knockId, { String xKnockToken }) async
    test('test waitMeetingKnock', () async {
      // TODO
    });

  });
}
