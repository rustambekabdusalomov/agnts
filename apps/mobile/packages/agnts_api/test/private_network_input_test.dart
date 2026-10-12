import 'package:test/test.dart';
import 'package:agnts_api/agnts_api.dart';

// tests for PrivateNetworkInput
void main() {
  final PrivateNetworkInput? instance = /* PrivateNetworkInput(...) */ null;
  // TODO add properties to the entity

  group(PrivateNetworkInput, () {
    // Unique in the workspace, e.g. the company or office it reaches
    // String name
    test('to test the property `name`', () async {
      // TODO
    });

    // String kind
    test('to test the property `kind`', () async {
      // TODO
    });

    // bool enabled
    test('to test the property `enabled`', () async {
      // TODO
    });

    // The WireGuard or OpenVPN config; left out keeps the saved one
    // String config
    test('to test the property `config`', () async {
      // TODO
    });

    // OpenVPN auth-user-pass
    // String username
    test('to test the property `username`', () async {
      // TODO
    });

    // OpenVPN auth-user-pass; left out or empty keeps the saved one
    // String password
    test('to test the property `password`', () async {
      // TODO
    });

    // List<NetworkRoute> routes
    test('to test the property `routes`', () async {
      // TODO
    });

    // Company CA certificates (PEM); \"\" removes them, left out keeps them
    // String caPem
    test('to test the property `caPem`', () async {
      // TODO
    });

  });
}
