import 'package:test/test.dart';
import 'package:agnts_api/agnts_api.dart';

// tests for SecurityWorkspaceSettings
void main() {
  final SecurityWorkspaceSettings? instance = /* SecurityWorkspaceSettings(...) */ null;
  // TODO add properties to the entity

  group(SecurityWorkspaceSettings, () {
    // Check agnts's own changes for security issues while they wait for review (advice, never a gate)
    // bool autoCheck
    test('to test the property `autoCheck`', () async {
      // TODO
    });

    // Scheduled scans a day that may run the agent; later ones run the scanners only (0: no limit)
    // int dailyBudget
    test('to test the property `dailyBudget`', () async {
      // TODO
    });

  });
}
