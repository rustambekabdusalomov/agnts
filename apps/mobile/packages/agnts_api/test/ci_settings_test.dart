import 'package:test/test.dart';
import 'package:agnts_api/agnts_api.dart';

// tests for CISettings
void main() {
  final CISettings? instance = /* CISettings(...) */ null;
  // TODO add properties to the entity

  group(CISettings, () {
    // Open a ticket for every confirmed failure on a watched branch; off, failures wait for Fix it
    // bool autoFix
    test('to test the property `autoFix`', () async {
      // TODO
    });

    // Automatic CI tickets a day at most
    // int maxAutoPerDay
    test('to test the property `maxAutoPerDay`', () async {
      // TODO
    });

    // Re-run the failed jobs of a new failure once before believing it
    // bool retryFlaky
    test('to test the property `retryFlaky`', () async {
      // TODO
    });

    // How many times a red check sends one of agnts's pull requests back to coding; 0 turns it off
    // int feedbackRounds
    test('to test the property `feedbackRounds`', () async {
      // TODO
    });

    // Extra regular expressions that mark a failure as infra (not the code)
    // List<String> infraPatterns
    test('to test the property `infraPatterns`', () async {
      // TODO
    });

  });
}
