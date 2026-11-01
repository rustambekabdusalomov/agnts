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

    // Plan usage of one module's account (Claude or Muse), from the limit events its runs report
    //
    //Future<Usage> getUsage({ String provider }) async
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
