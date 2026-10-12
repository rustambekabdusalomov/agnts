import 'package:test/test.dart';
import 'package:agnts_api/agnts_api.dart';

// tests for AnalyticsCI
void main() {
  final AnalyticsCI? instance = /* AnalyticsCI(...) */ null;
  // TODO add properties to the entity

  group(AnalyticsCI, () {
    // int days
    test('to test the property `days`', () async {
      // TODO
    });

    // CI watching is set up for at least one repository
    // bool watching
    test('to test the property `watching`', () async {
      // TODO
    });

    // CIPeriod current
    test('to test the property `current`', () async {
      // TODO
    });

    // CIPeriod previous
    test('to test the property `previous`', () async {
      // TODO
    });

    // Failure groups seen in the period by class: code, test, config, dependency, infra, flaky, unknown
    // Map<String, int> byClass
    test('to test the property `byClass`', () async {
      // TODO
    });

    // List<CIDay> perDay
    test('to test the property `perDay`', () async {
      // TODO
    });

    // List<FlakyJob> flakiest
    test('to test the property `flakiest`', () async {
      // TODO
    });

    // Failure groups that need attention now
    // int open
    test('to test the property `open`', () async {
      // TODO
    });

  });
}
