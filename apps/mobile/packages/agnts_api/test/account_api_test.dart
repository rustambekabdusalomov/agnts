import 'package:test/test.dart';
import 'package:agnts_api/agnts_api.dart';


/// tests for AccountApi
void main() {
  final instance = AgntsApi().getAccountApi();

  group(AccountApi, () {
    // Start turning on two-factor sign-in (a new secret, not saved yet)
    //
    //Future<BeginTotp200Response> beginTotp() async
    test('test beginTotp', () async {
      // TODO
    });

    // Change the password
    //
    //Future changePassword(ChangePasswordRequest changePasswordRequest) async
    test('test changePassword', () async {
      // TODO
    });

    // Turn two-factor sign-in on with a code from the new secret
    //
    //Future confirmTotp(ConfirmTotpRequest confirmTotpRequest) async
    test('test confirmTotp', () async {
      // TODO
    });

    // Disconnect your Claude account
    //
    //Future deleteMyClaude() async
    test('test deleteMyClaude', () async {
      // TODO
    });

    // Turn two-factor sign-in off
    //
    //Future disableTotp(DisableTotpRequest disableTotpRequest) async
    test('test disableTotp', () async {
      // TODO
    });

    // Your personal Claude connection (used by workspaces in per-member mode)
    //
    //Future<ClaudeConnectionState> getMyClaude() async
    test('test getMyClaude', () async {
      // TODO
    });

    // Send the email verification link again
    //
    //Future resendVerification() async
    test('test resendVerification', () async {
      // TODO
    });

    // Connect your Claude account
    //
    //Future<ClaudeConnectionState> setMyClaude(ClaudeConnectionInput claudeConnectionInput) async
    test('test setMyClaude', () async {
      // TODO
    });

    // Change the display name or email
    //
    //Future<User> updateProfile(UpdateProfileRequest updateProfileRequest) async
    test('test updateProfile', () async {
      // TODO
    });

  });
}
