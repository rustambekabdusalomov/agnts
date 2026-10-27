import 'package:test/test.dart';
import 'package:agnts_api/agnts_api.dart';


/// tests for PlatformApi
void main() {
  final instance = AgntsApi().getPlatformApi();

  group(PlatformApi, () {
    // Create an Admin account that signs in with a password (Admin)
    //
    //Future<User> createPlatformAdmin(CreatePlatformAdminRequest createPlatformAdminRequest) async
    test('test createPlatformAdmin', () async {
      // TODO
    });

    // Delete an Admin account; not your own (Admin)
    //
    //Future deletePlatformAdmin(int id) async
    test('test deletePlatformAdmin', () async {
      // TODO
    });

    // The transcript as JSON lines, the stored normalised events, not Claude Code's raw output (Admin). Audited.
    //
    //Future<String> downloadPlatformRun(int id) async
    test('test downloadPlatformRun', () async {
      // TODO
    });

    // Servers, runs and the queue across every workspace (Admin)
    //
    //Future<PlatformOverview> getPlatformOverview() async
    test('test getPlatformOverview', () async {
      // TODO
    });

    // One transcript with its whole timeline (Admin). Customer content; the read is written to the audit log first.
    //
    //Future<RunTranscriptDetail> getPlatformRun(int id) async
    test('test getPlatformRun', () async {
      // TODO
    });

    // The prompt agnts sent (Admin). Audited.
    //
    //Future<GetPlatformRunPrompt200Response> getPlatformRunPrompt(int id) async
    test('test getPlatformRunPrompt', () async {
      // TODO
    });

    // Totals of the run history matching the filters (Admin)
    //
    //Future<RunHistorySummary> getPlatformRunSummary({ int workspace, String purpose, String status, String engine, String model, String ticket, bool stalled, DateTime from, DateTime to, num minCost }) async
    test('test getPlatformRunSummary', () async {
      // TODO
    });

    // How long run history is kept, and its size limits (Admin)
    //
    //Future<RunHistorySettings> getRunHistorySettings() async
    test('test getRunHistorySettings', () async {
      // TODO
    });

    // Grant (or take back, when negative) credits (Admin)
    //
    //Future<PlatformWorkspace> grantCredits(int id, GrantCreditsRequest grantCreditsRequest) async
    test('test grantCredits', () async {
      // TODO
    });

    // What Admins read of customer content, newest first (Admin)
    //
    //Future<List<AdminAuditEntry>> listPlatformAudit({ int admin, String action, int workspace, int before, int limit }) async
    test('test listPlatformAudit', () async {
      // TODO
    });

    // Every feedback people sent, newest first (Admin)
    //
    //Future<List<Feedback>> listPlatformFeedback() async
    test('test listPlatformFeedback', () async {
      // TODO
    });

    // Run history across every workspace, newest first, without prompts or transcripts (Admin)
    //
    //Future<RunHistoryPage> listPlatformRuns({ int workspace, String purpose, String status, String engine, String model, String ticket, bool stalled, DateTime from, DateTime to, num minCost, String cursor, int limit }) async
    test('test listPlatformRuns', () async {
      // TODO
    });

    // Every user, with their workspaces and last sign-in (Admin)
    //
    //Future<List<PlatformUser>> listPlatformUsers() async
    test('test listPlatformUsers', () async {
      // TODO
    });

    // Every workspace, metadata only (Admin)
    //
    //Future<List<PlatformWorkspace>> listPlatformWorkspaces() async
    test('test listPlatformWorkspaces', () async {
      // TODO
    });

    // Set how many free credits a person may spend on agnts's Muse key (Admin); 0 gives none
    //
    //Future<FreeCredits> setFreeCredits(int id, SetFreeCreditsRequest setFreeCreditsRequest) async
    test('test setFreeCredits', () async {
      // TODO
    });

    // Change how long run history is kept, and its size limits (Admin)
    //
    //Future<RunHistorySettings> setRunHistorySettings(RunHistorySettings runHistorySettings) async
    test('test setRunHistorySettings', () async {
      // TODO
    });

    // Mark a feedback done, or new again (Admin)
    //
    //Future<Feedback> updatePlatformFeedback(int id, UpdatePlatformFeedbackRequest updatePlatformFeedbackRequest) async
    test('test updatePlatformFeedback', () async {
      // TODO
    });

    // Grant or remove the Admin role (Admin); refused when Admins and Users are separate accounts
    //
    //Future<User> updatePlatformUser(int id, UpdatePlatformUserRequest updatePlatformUserRequest) async
    test('test updatePlatformUser', () async {
      // TODO
    });

    // Change a workspace's plan, slots, member limit, or suspend it (Admin)
    //
    //Future<PlatformWorkspace> updatePlatformWorkspace(int id, UpdatePlatformWorkspaceRequest updatePlatformWorkspaceRequest) async
    test('test updatePlatformWorkspace', () async {
      // TODO
    });

  });
}
