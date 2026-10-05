import 'package:test/test.dart';
import 'package:hiro_api/hiro_api.dart';


/// tests for DashboardApi
void main() {
  final instance = HiroApi().getDashboardApi();

  group(DashboardApi, () {
    // Everything the dashboard shows, in one call
    //
    //Future<Dashboard> getDashboard() async
    test('test getDashboard', () async {
      // TODO
    });

  });
}
