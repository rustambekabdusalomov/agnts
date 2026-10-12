import 'package:test/test.dart';
import 'package:agnts_api/agnts_api.dart';


/// tests for CiApi
void main() {
  final instance = AgntsApi().getCiApi();

  group(CiApi, () {
    // Open a ticket that fixes the failure now (ignores the auto-fix setting and the daily budget)
    //
    //Future<Ticket> fixCIFailure(int failureId) async
    test('test fixCIFailure', () async {
      // TODO
    });

    // One CI failure group with its redacted log excerpt
    //
    //Future<CIFailure> getCIFailure(int failureId) async
    test('test getCIFailure', () async {
      // TODO
    });

    // How agnts watches this repository's CI, and whether the git token can read it
    //
    //Future<CIWatch> getRepoCIWatch(int id) async
    test('test getRepoCIWatch', () async {
      // TODO
    });

    // The CI failure a CI ticket fixes (404 for other tickets)
    //
    //Future<CIFailure> getTicketCIFailure(String key) async
    test('test getTicketCIFailure', () async {
      // TODO
    });

    // CI failure groups, newest occurrence first
    //
    //Future<List<CIFailure>> listCIFailures({ int repoId, String status }) async
    test('test listCIFailures', () async {
      // TODO
    });

    // Ignore this failure (no tickets, no notifications)
    //
    //Future<CIFailure> muteCIFailure(int failureId) async
    test('test muteCIFailure', () async {
      // TODO
    });

    // Change how agnts watches this repository's CI
    //
    //Future<CIWatch> putRepoCIWatch(int id, CIWatch cIWatch) async
    test('test putRepoCIWatch', () async {
      // TODO
    });

    // Re-run the failed jobs of the newest failing run on the git host
    //
    //Future rerunCIFailure(int failureId) async
    test('test rerunCIFailure', () async {
      // TODO
    });

    // Watch a muted failure again
    //
    //Future<CIFailure> unmuteCIFailure(int failureId) async
    test('test unmuteCIFailure', () async {
      // TODO
    });

  });
}
