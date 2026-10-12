import 'package:test/test.dart';
import 'package:agnts_api/agnts_api.dart';


/// tests for NetworkApi
void main() {
  final instance = AgntsApi().getNetworkApi();

  group(NetworkApi, () {
    // Add a private network
    //
    // Its routes may not claim a host, domain or range another of the workspace's networks has (on a common port); a route nested inside another network's is fine. A connector's token is returned once. 
    //
    //Future<PrivateNetworkSaved> createPrivateNetwork(PrivateNetworkInput privateNetworkInput) async
    test('test createPrivateNetwork', () async {
      // TODO
    });

    // Remove a private network
    //
    //Future deletePrivateNetwork(int networkId) async
    test('test deletePrivateNetwork', () async {
      // TODO
    });

    // Connections made through private networks (the last 100, and the day's counts)
    //
    //Future<NetworkActivity> getNetworkActivity({ int network }) async
    test('test getNetworkActivity', () async {
      // TODO
    });

    // One private network
    //
    //Future<PrivateNetwork> getPrivateNetwork(int networkId) async
    test('test getPrivateNetwork', () async {
      // TODO
    });

    // The workspace's private networks (VPNs and agnts-link connectors)
    //
    // Tunnels into the team's own networks and the routes (hosts, domains, private ranges) that go through each: agnts's calls to a self-hosted GitLab, Jira or Plane, git, and run containers' connections to those hosts. A connection goes through the network whose route matches it most closely. Secrets are never returned. 
    //
    //Future<PrivateNetworkList> listPrivateNetworks() async
    test('test listPrivateNetworks', () async {
      // TODO
    });

    // Restart the tunnel (a new OpenVPN sidecar, a new WireGuard handshake, agnts-link reconnects)
    //
    //Future<PrivateNetwork> reconnectPrivateNetwork(int networkId) async
    test('test reconnectPrivateNetwork', () async {
      // TODO
    });

    // Make a new agnts-link token for a connector network (shown once; the old one stops working)
    //
    //Future<RotateMcpToken200Response> rotateLinkToken(int networkId) async
    test('test rotateLinkToken', () async {
      // TODO
    });

    // Connect to host:port through the network its routes pick, and check its TLS certificate
    //
    //Future<NetworkTest> testPrivateNetwork(TestPrivateNetworkRequest testPrivateNetworkRequest) async
    test('test testPrivateNetwork', () async {
      // TODO
    });

    // Change a private network
    //
    // Left-out secrets (config, password) keep the stored ones. Switching to a connector makes its token, returned once. 
    //
    //Future<PrivateNetworkSaved> updatePrivateNetwork(int networkId, PrivateNetworkInput privateNetworkInput) async
    test('test updatePrivateNetwork', () async {
      // TODO
    });

  });
}
