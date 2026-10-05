import 'package:test/test.dart';
import 'package:hiro_api/hiro_api.dart';


/// tests for UsageApi
void main() {
  final instance = HiroApi().getUsageApi();

  group(UsageApi, () {
    // Plan usage from Claude Code's rate limit events
    //
    //Future<Usage> getUsage() async
    test('test getUsage', () async {
      // TODO
    });

    // Start a tiny Claude run to read fresh limits; a usage_updated event follows
    //
    //Future<Usage> refreshUsage() async
    test('test refreshUsage', () async {
      // TODO
    });

  });
}
