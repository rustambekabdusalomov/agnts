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

  });
}
