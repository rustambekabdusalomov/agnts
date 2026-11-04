import 'package:test/test.dart';
import 'package:agnts_api/agnts_api.dart';

// tests for MeetingSettings
void main() {
  final MeetingSettings? instance = /* MeetingSettings(...) */ null;
  // TODO add properties to the entity

  group(MeetingSettings, () {
    // bool allowRecording
    test('to test the property `allowRecording`', () async {
      // TODO
    });

    // Recordings, notes audio and transcripts are deleted after; 0 keeps them
    // int retentionDays
    test('to test the property `retentionDays`', () async {
      // TODO
    });

    // Keep the audio of notes after it is heard
    // bool keepAudio
    test('to test the property `keepAudio`', () async {
      // TODO
    });

    // int maxParticipants
    test('to test the property `maxParticipants`', () async {
      // TODO
    });

    // Every action item becomes a held draft ticket on the member who took it when the notes are written
    // bool draftTickets
    test('to test the property `draftTickets`', () async {
      // TODO
    });

    // MeetingSettingsAvailable available
    test('to test the property `available`', () async {
      // TODO
    });

  });
}
