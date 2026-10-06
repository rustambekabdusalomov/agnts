import 'package:test/test.dart';
import 'package:agnts_api/agnts_api.dart';


/// tests for UsageApi
void main() {
  final instance = AgntsApi().getUsageApi();

  group(UsageApi, () {
    // Tickets that used the most of the plan in a period, by Claude Code's cost estimate
    //
    //Future<TicketSpendList> getTicketSpend({ int days, int limit }) async
    test('test getTicketSpend', () async {
      // TODO
    });

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
