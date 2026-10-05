import 'package:test/test.dart';
import 'package:hiro_api/hiro_api.dart';


/// tests for McpApi
void main() {
  final instance = HiroApi().getMcpApi();

  group(McpApi, () {
    // Approve or deny a Claude connection; returns where to send the browser
    //
    //Future<DecideConsent200Response> decideConsent(DecideConsentRequest decideConsentRequest) async
    test('test decideConsent', () async {
      // TODO
    });

    // Details of a pending Claude connection request, for the consent page
    //
    //Future<GetConsent200Response> getConsent(String clientId, String redirectUri, String codeChallenge, String codeChallengeMethod, { String resource }) async
    test('test getConsent', () async {
      // TODO
    });

    // The MCP connector URL and current connections
    //
    //Future<McpStatus> getMcpSettings() async
    test('test getMcpSettings', () async {
      // TODO
    });

    // Disconnect every Claude connection and delete the static token
    //
    //Future revokeMcp() async
    test('test revokeMcp', () async {
      // TODO
    });

    // Create a new static MCP bearer token (shown once; the old one stops working)
    //
    //Future<RotateMcpToken200Response> rotateMcpToken() async
    test('test rotateMcpToken', () async {
      // TODO
    });

  });
}
