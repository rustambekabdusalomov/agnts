import 'package:test/test.dart';
import 'package:agnts_api/agnts_api.dart';


/// tests for SecurityApi
void main() {
  final instance = AgntsApi().getSecurityApi();

  group(SecurityApi, () {
    // Cancel a queued or running scan (a running one saves nothing)
    //
    //Future<SecurityScan> cancelSecurityScan(int scanId) async
    test('test cancelSecurityScan', () async {
      // TODO
    });

    // Dismiss findings with a reason; they stay dismissed while their fingerprint matches
    //
    //Future<List<SecurityFinding>> dismissSecurityFindings(DismissSecurityFindingsRequest dismissSecurityFindingsRequest) async
    test('test dismissSecurityFindings', () async {
      // TODO
    });

    // Open one ticket that fixes findings of one repository (Fix this, Fix together)
    //
    //Future<Ticket> fixSecurityFindings(FixSecurityFindingsRequest fixSecurityFindingsRequest) async
    test('test fixSecurityFindings', () async {
      // TODO
    });

    // One finding
    //
    //Future<SecurityFinding> getSecurityFinding(int findingId) async
    test('test getSecurityFinding', () async {
      // TODO
    });

    // One scan, with what ran and the hits the agent rejected
    //
    //Future<SecurityScan> getSecurityScan(int scanId) async
    test('test getSecurityScan', () async {
      // TODO
    });

    // A repository's security settings: schedule, exclusions, lowest severity that notifies
    //
    //Future<SecuritySettings> getSecuritySettings(int id) async
    test('test getSecuritySettings', () async {
      // TODO
    });

    // Open security findings by repository and severity, with each repository's last scan
    //
    //Future<List<SecurityRepoSummary>> getSecuritySummary() async
    test('test getSecuritySummary', () async {
      // TODO
    });

    // The security findings a fix ticket works on
    //
    //Future<List<SecurityFinding>> getTicketSecurityFindings(String key) async
    test('test getTicketSecurityFindings', () async {
      // TODO
    });

    // Security findings, worst first
    //
    //Future<List<SecurityFinding>> listSecurityFindings({ int repoId, SecFindingStatus status, SecSeverity severity, bool active }) async
    test('test listSecurityFindings', () async {
      // TODO
    });

    // A repository's security scans, newest first
    //
    //Future<List<SecurityScan>> listSecurityScans(int id) async
    test('test listSecurityScans', () async {
      // TODO
    });

    // Open a dismissed or fixed finding again
    //
    //Future<SecurityFinding> reopenSecurityFinding(int findingId) async
    test('test reopenSecurityFinding', () async {
      // TODO
    });

    // Save a repository's security settings and schedule its next scan
    //
    //Future<SecuritySettings> setSecuritySettings(int id, SecuritySettings securitySettings) async
    test('test setSecuritySettings', () async {
      // TODO
    });

    // Scan the repository's default branch (a scan already queued or running is returned instead)
    //
    //Future<StartSecurityScan200Response> startSecurityScan(int id) async
    test('test startSecurityScan', () async {
      // TODO
    });

  });
}
