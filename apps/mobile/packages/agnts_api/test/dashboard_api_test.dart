import 'package:test/test.dart';
import 'package:agnts_api/agnts_api.dart';


/// tests for DashboardApi
void main() {
  final instance = AgntsApi().getDashboardApi();

  group(DashboardApi, () {
    // Everything the dashboard shows, in one call
    //
    //Future<Dashboard> getDashboard() async
    test('test getDashboard', () async {
      // TODO
    });

  });
}
