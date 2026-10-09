import 'package:test/test.dart';
import 'package:agnts_api/agnts_api.dart';


/// tests for AuthApi
void main() {
  final instance = AgntsApi().getAuthApi();

  group(AuthApi, () {
    // Start the two-factor setup an Admin without it does at sign-in
    //
    // Two-factor sign-in is mandatory for Admins. When login answers 401 totp_setup_required, this returns a new secret (after checking the password again); signing in with it as totpSecret and a matching code saves it and starts the session.
    //
    //Future<BeginLoginTotp200Response> beginLoginTotp(BeginLoginTotpRequest beginLoginTotpRequest) async
    test('test beginLoginTotp', () async {
      // TODO
    });

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

    // Sign in with a Google ID token (the mobile app)
    //
    // The phone signs in with Google itself and sends the ID token here. Like \"Continue with Google\" on the website, a new account starts as a solo developer with a workspace of its own, or joins the workspace of an invite. Always a mobile session: the token comes back in the body. 
    //
    //Future<LoginResponse> signInWithGoogle(GoogleSignInRequest googleSignInRequest) async
    test('test signInWithGoogle', () async {
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
