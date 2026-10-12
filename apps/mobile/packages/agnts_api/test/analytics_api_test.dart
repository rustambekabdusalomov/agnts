import 'package:test/test.dart';
import 'package:agnts_api/agnts_api.dart';


/// tests for AnalyticsApi
void main() {
  final instance = AgntsApi().getAnalyticsApi();

  group(AnalyticsApi, () {
    // Throughput, quality, time and plan statistics for a period
    //
    //Future<Analytics> getAnalytics({ int days }) async
    test('test getAnalytics', () async {
      // TODO
    });

    // CI failures, fixes and flaky jobs for a period
    //
    //Future<AnalyticsCI> getAnalyticsCi({ int days }) async
    test('test getAnalyticsCi', () async {
      // TODO
    });

    // What happened to agnts pull requests, cycle time and questions for a period
    //
    //Future<AnalyticsDelivery> getAnalyticsDelivery({ int days }) async
    test('test getAnalyticsDelivery', () async {
      // TODO
    });

    // Lessons, rules, follow-ups and reviewer notes for a period
    //
    //Future<AnalyticsLearning> getAnalyticsLearning({ int days }) async
    test('test getAnalyticsLearning', () async {
      // TODO
    });

    // How the newest replays compare with the tickets they re-ran, by prompt version
    //
    //Future<ReplayReport> getReplayReport() async
    test('test getReplayReport', () async {
      // TODO
    });

  });
}
