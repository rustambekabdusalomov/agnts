import 'package:test/test.dart';
import 'package:agnts_api/agnts_api.dart';


/// tests for LogsApi
void main() {
  final instance = AgntsApi().getLogsApi();

  group(LogsApi, () {
    // Make a push source's token (again); it is shown once
    //
    //Future<LogPushToken> createLogPushToken(int sourceId) async
    test('test createLogPushToken', () async {
      // TODO
    });

    // Add a log source; a pulling source must pass the connection test
    //
    //Future<LogSource> createLogSource(LogSourceInput logSourceInput) async
    test('test createLogSource', () async {
      // TODO
    });

    // Remove a log source (its findings stay)
    //
    //Future deleteLogSource(int sourceId) async
    test('test deleteLogSource', () async {
      // TODO
    });

    // The services the source's logs hold (watched ones as saved, new ones with a suggested repository)
    //
    //Future<List<LogService>> discoverLogServices(int sourceId) async
    test('test discoverLogServices', () async {
      // TODO
    });

    // Download the log (last 90 days) as JSON lines or CSV
    //
    //Future<String> exportEvents({ String format }) async
    test('test exportEvents', () async {
      // TODO
    });

    // Open a ticket for the finding now, on the service's repositories (ignores the mode and the daily budget)
    //
    //Future<Ticket> fixLogFinding(int findingId) async
    test('test fixLogFinding', () async {
      // TODO
    });

    // Run statistics and time per step, for the Logs page
    //
    //Future<EventSummary> getEventSummary() async
    test('test getEventSummary', () async {
      // TODO
    });

    // One finding with its redacted log excerpt
    //
    //Future<LogFinding> getLogFinding(int findingId) async
    test('test getLogFinding', () async {
      // TODO
    });

    // One log source
    //
    //Future<LogSource> getLogSource(int sourceId) async
    test('test getLogSource', () async {
      // TODO
    });

    // The log finding a log ticket fixes (404 for other tickets)
    //
    //Future<LogFinding> getTicketLogFinding(String key) async
    test('test getTicketLogFinding', () async {
      // TODO
    });

    // The global log, newest first, with filters and a cursor
    //
    //Future<EventPage> listEvents({ String type, String key, bool errors, int before, int limit }) async
    test('test listEvents', () async {
      // TODO
    });

    // Findings of the log watcher, newest sighting first
    //
    //Future<List<LogFinding>> listLogFindings({ String category, LogFindingStatus status, LogSeverity severity, int repoId, int sourceId, bool active }) async
    test('test listLogFindings', () async {
      // TODO
    });

    // The logging systems agnts reads, and the push sources, with their services and health
    //
    //Future<List<LogSource>> listLogSources() async
    test('test listLogSources', () async {
      // TODO
    });

    // Ignore this finding (no tickets, no notifications)
    //
    //Future<LogFinding> muteLogFinding(int findingId) async
    test('test muteLogFinding', () async {
      // TODO
    });

    // Send the finding's notification now, whatever the mode
    //
    //Future<LogFinding> notifyLogFinding(int findingId) async
    test('test notifyLogFinding', () async {
      // TODO
    });

    // Replace the key that hashes secrets found in logs (findings of one secret before and after are then two)
    //
    //Future rotateLogKey() async
    test('test rotateLogKey', () async {
      // TODO
    });

    // Replace the services agnts watches in this source and the repositories each runs on
    //
    //Future<List<LogService>> setLogServices(int sourceId, List<LogService> logService) async
    test('test setLogServices', () async {
      // TODO
    });

    // Server-Sent Events with every new event row (resume with Last-Event-ID)
    //
    //Future<String> streamEvents() async
    test('test streamEvents', () async {
      // TODO
    });

    // Test a log source as the form has it (with id and no auth, the saved credentials)
    //
    //Future<LogSourceTest> testLogSource(LogSourceInput logSourceInput) async
    test('test testLogSource', () async {
      // TODO
    });

    // Watch a muted finding again
    //
    //Future<LogFinding> unmuteLogFinding(int findingId) async
    test('test unmuteLogFinding', () async {
      // TODO
    });

    // Change a log source; auth left out keeps the saved credentials
    //
    //Future<LogSource> updateLogSource(int sourceId, LogSourceInput logSourceInput) async
    test('test updateLogSource', () async {
      // TODO
    });

  });
}
