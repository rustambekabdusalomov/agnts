import 'package:test/test.dart';
import 'package:hiro_api/hiro_api.dart';


/// tests for LogsApi
void main() {
  final instance = HiroApi().getLogsApi();

  group(LogsApi, () {
    // Download the log (last 90 days) as JSON lines or CSV
    //
    //Future<String> exportEvents({ String format }) async
    test('test exportEvents', () async {
      // TODO
    });

    // Run statistics and time per step, for the Logs page
    //
    //Future<EventSummary> getEventSummary() async
    test('test getEventSummary', () async {
      // TODO
    });

    // The global log, newest first, with filters and a cursor
    //
    //Future<EventPage> listEvents({ String type, String key, bool errors, int before, int limit }) async
    test('test listEvents', () async {
      // TODO
    });

    // Server-Sent Events with every new event row (resume with Last-Event-ID)
    //
    //Future<String> streamEvents() async
    test('test streamEvents', () async {
      // TODO
    });

  });
}
