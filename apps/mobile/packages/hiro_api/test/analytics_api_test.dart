import 'package:test/test.dart';
import 'package:hiro_api/hiro_api.dart';


/// tests for AnalyticsApi
void main() {
  final instance = HiroApi().getAnalyticsApi();

  group(AnalyticsApi, () {
    // Throughput, quality, time and plan statistics for a period
    //
    //Future<Analytics> getAnalytics({ int days }) async
    test('test getAnalytics', () async {
      // TODO
    });

  });
}
