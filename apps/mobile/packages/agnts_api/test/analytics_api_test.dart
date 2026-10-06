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

  });
}
