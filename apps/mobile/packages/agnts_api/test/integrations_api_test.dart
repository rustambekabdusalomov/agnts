import 'package:test/test.dart';
import 'package:agnts_api/agnts_api.dart';


/// tests for IntegrationsApi
void main() {
  final instance = AgntsApi().getIntegrationsApi();

  group(IntegrationsApi, () {
    // Save a token (and settings), check it against the provider, and connect
    //
    //Future<ConnectResult> connectIntegration(String provider, ConnectIntegrationRequest connectIntegrationRequest) async
    test('test connectIntegration', () async {
      // TODO
    });

    // Forget the token
    //
    //Future<Integration> disconnectIntegration(String provider) async
    test('test disconnectIntegration', () async {
      // TODO
    });

    //Future<List<Integration>> listIntegrations() async
    test('test listIntegrations', () async {
      // TODO
    });

    // Repositories the connected GitHub or GitLab token can reach, for import
    //
    //Future<List<RemoteRepository>> listRemoteRepos(String provider) async
    test('test listRemoteRepos', () async {
      // TODO
    });

    // Pick up labelled Jira issues now
    //
    //Future<SyncJira200Response> syncJira() async
    test('test syncJira', () async {
      // TODO
    });

    //Future<Integration> testIntegration(String provider) async
    test('test testIntegration', () async {
      // TODO
    });

    // Change an integration's settings (never its token)
    //
    //Future<Integration> updateIntegration(String provider, UpdateIntegrationRequest updateIntegrationRequest) async
    test('test updateIntegration', () async {
      // TODO
    });

  });
}
