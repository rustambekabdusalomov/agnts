import 'package:test/test.dart';
import 'package:agnts_api/agnts_api.dart';

// tests for LogWatchSettings
void main() {
  final LogWatchSettings? instance = /* LogWatchSettings(...) */ null;
  // TODO add properties to the entity

  group(LogWatchSettings, () {
    // LogMode errors
    test('to test the property `errors`', () async {
      // TODO
    });

    // LogMode security
    test('to test the property `security`', () async {
      // TODO
    });

    // Notify a high-severity secret leak even when Security is off
    // bool alwaysNotifyLeaks
    test('to test the property `alwaysNotifyLeaks`', () async {
      // TODO
    });

    // LogSeverity minSeverity
    test('to test the property `minSeverity`', () async {
      // TODO
    });

    // Occurrences within the hour before a plain error acts
    // int threshold
    test('to test the property `threshold`', () async {
      // TODO
    });

    // Automatic log tickets a day at most
    // int maxAutoPerDay
    test('to test the property `maxAutoPerDay`', () async {
      // TODO
    });

    // Bursts of the same attack within 7 days before a hardening ticket; 0 never
    // int attackTicketAfter
    test('to test the property `attackTicketAfter`', () async {
      // TODO
    });

    // int resolveAfterDays
    test('to test the property `resolveAfterDays`', () async {
      // TODO
    });

    // One daily summary instead of a message per finding
    // bool digest
    test('to test the property `digest`', () async {
      // TODO
    });

    // Model triage calls a day for new findings; 0 off
    // int triagePerDay
    test('to test the property `triagePerDay`', () async {
      // TODO
    });

    // List<LogPattern> patterns
    test('to test the property `patterns`', () async {
      // TODO
    });

    // List<LogOverride> overrides
    test('to test the property `overrides`', () async {
      // TODO
    });

  });
}
