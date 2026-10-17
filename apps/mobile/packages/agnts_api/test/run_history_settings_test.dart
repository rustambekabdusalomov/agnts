import 'package:test/test.dart';
import 'package:agnts_api/agnts_api.dart';

// tests for RunHistorySettings
void main() {
  final RunHistorySettings? instance = /* RunHistorySettings(...) */ null;
  // TODO add properties to the entity

  group(RunHistorySettings, () {
    // Transcripts older than this are deleted daily; 0 keeps them
    // int retentionDays
    test('to test the property `retentionDays`', () async {
      // TODO
    });

    // Cap of one tool output; its start and end are kept
    // int toolOutputKB
    test('to test the property `toolOutputKB`', () async {
      // TODO
    });

    // Cap of one text block or tool input
    // int textKB
    test('to test the property `textKB`', () async {
      // TODO
    });

    // Cap of one transcript; past it only tool calls and the result are kept
    // int transcriptMB
    test('to test the property `transcriptMB`', () async {
      // TODO
    });

  });
}
