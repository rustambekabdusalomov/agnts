import 'package:test/test.dart';
import 'package:agnts_api/agnts_api.dart';

// tests for SignupInfo
void main() {
  final SignupInfo? instance = /* SignupInfo(...) */ null;
  // TODO add properties to the entity

  group(SignupInfo, () {
    // Anyone can register; otherwise only with an invite link
    // bool open
    test('to test the property `open`', () async {
      // TODO
    });

    // No account exists yet; the first one becomes Admin
    // bool firstUser
    test('to test the property `firstUser`', () async {
      // TODO
    });

    // The server can send email (verification, invites, resets)
    // bool emailEnabled
    test('to test the property `emailEnabled`', () async {
      // TODO
    });

    // OAuth client id for \"Continue with Google\" (a form post to /auth/google); absent when it is off
    // String googleClientId
    test('to test the property `googleClientId`', () async {
      // TODO
    });

    // Registering with a password works; when only Admins sign in with one, only for the first account
    // bool passwordSignup
    test('to test the property `passwordSignup`', () async {
      // TODO
    });

  });
}
