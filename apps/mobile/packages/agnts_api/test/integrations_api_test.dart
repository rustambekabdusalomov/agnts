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

    // States of the Plane projects linked to repositories, for the status mapping
    //
    //Future<List<PlaneState>> listPlaneStates() async
    test('test listPlaneStates', () async {
      // TODO
    });

    // Repositories the connected GitHub or GitLab token can reach, for import
    //
    //Future<List<RemoteRepository>> listRemoteRepos(String provider) async
    test('test listRemoteRepos', () async {
      // TODO
    });

    // Store the secret Plane generated for the agnts webhook
    //
    //Future<Integration> setPlaneWebhookSecret(SetPlaneWebhookSecretRequest setPlaneWebhookSecretRequest) async
    test('test setPlaneWebhookSecret', () async {
      // TODO
    });

    // Pick up labelled Jira issues now
    //
    //Future<SyncJira200Response> syncJira() async
    test('test syncJira', () async {
      // TODO
    });

    // Pick up labelled Plane work items now
    //
    //Future<SyncJira200Response> syncPlane() async
    test('test syncPlane', () async {
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
