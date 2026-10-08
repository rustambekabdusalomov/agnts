import 'package:test/test.dart';
import 'package:agnts_api/agnts_api.dart';

// tests for LoginRequest
void main() {
  final LoginRequest? instance = /* LoginRequest(...) */ null;
  // TODO add properties to the entity

  group(LoginRequest, () {
    // Username or email
    // String username
    test('to test the property `username`', () async {
      // TODO
    });

    // String password
    test('to test the property `password`', () async {
      // TODO
    });

    // Six-digit code from the authenticator app, when two-factor sign-in is on
    // String code
    test('to test the property `code`', () async {
      // TODO
    });

    // An Admin finishing two-factor setup at sign-in (beginLoginTotp's secret); code must match it
    // String totpSecret
    test('to test the property `totpSecret`', () async {
      // TODO
    });

    // String client
    test('to test the property `client`', () async {
      // TODO
    });

  });
}
