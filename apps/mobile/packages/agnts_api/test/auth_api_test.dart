import 'package:test/test.dart';
import 'package:agnts_api/agnts_api.dart';


/// tests for AuthApi
void main() {
  final instance = AgntsApi().getAuthApi();

  group(AuthApi, () {
    // Email a password reset link (always answers 204)
    //
    //Future forgotPassword(ForgotPasswordRequest forgotPasswordRequest) async
    test('test forgotPassword', () async {
      // TODO
    });

    // The signed-in user
    //
    //Future<User> getMe() async
    test('test getMe', () async {
      // TODO
    });

    // Whether people can register, and whether this install has no user yet
    //
    //Future<SignupInfo> getSignupInfo() async
    test('test getSignupInfo', () async {
      // TODO
    });

    // Sign in with password and TOTP code
    //
    //Future<LoginResponse> login(LoginRequest loginRequest) async
    test('test login', () async {
      // TODO
    });

    // End the current session
    //
    //Future logout() async
    test('test logout', () async {
      // TODO
    });

    // Create an account (and its first workspace, unless joining by invite)
    //
    //Future<LoginResponse> register(RegisterRequest registerRequest) async
    test('test register', () async {
      // TODO
    });

    // Set a new password with a reset link's token
    //
    //Future resetPassword(ResetPasswordRequest resetPasswordRequest) async
    test('test resetPassword', () async {
      // TODO
    });

    // Confirm an email address with the link's token
    //
    //Future verifyEmail(TokenRequest tokenRequest) async
    test('test verifyEmail', () async {
      // TODO
    });

  });
}
