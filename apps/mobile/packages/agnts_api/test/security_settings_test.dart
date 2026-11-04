import 'package:test/test.dart';
import 'package:agnts_api/agnts_api.dart';

// tests for SecuritySettings
void main() {
  final SecuritySettings? instance = /* SecuritySettings(...) */ null;
  // TODO add properties to the entity

  group(SecuritySettings, () {
    // Scan on its own at a quiet hour (03:00 UTC)
    // String schedule
    test('to test the property `schedule`', () async {
      // TODO
    });

    // Path patterns no tool reports on, besides vendor, node_modules, dist, build and *.min.js
    // List<String> exclude
    test('to test the property `exclude`', () async {
      // TODO
    });

    // SecSeverity minNotify
    test('to test the property `minNotify`', () async {
      // TODO
    });

    // When the next scheduled scan is due
    // DateTime nextAt
    test('to test the property `nextAt`', () async {
      // TODO
    });

  });
}
