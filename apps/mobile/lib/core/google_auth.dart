import 'dart:async';

import 'package:google_sign_in/google_sign_in.dart';

import 'session.dart';

/// Google Sign-In on the phone, for the user app. The phone signs in with
/// Google itself and hands the ID token to the server (signInWithGoogle).
///
/// The token is issued for the server's OAuth web client on Android
/// ([serverClientId]), and for the app's own iOS client on iOS: its id is
/// GIDClientID in Info.plist, set from ios/Flutter/Google.xcconfig.
class GoogleAuth {
  GoogleAuth._();

  static Future<void>? _init;
  static String? _serverClientId;

  /// Asks the person to pick a Google account and returns its ID token, or
  /// null when they backed out. Throws [SignInError] googleSetup when this
  /// build is not set up for Google, or googleFailed.
  static Future<String?> idToken(String serverClientId) async {
    // The plugin is set up once per launch, for one server's client.
    if (_init != null && _serverClientId != serverClientId) throw SignInError('googleSetup');
    _serverClientId = serverClientId;
    try {
      await (_init ??= GoogleSignIn.instance.initialize(serverClientId: serverClientId));
      final account = await GoogleSignIn.instance.authenticate();
      final token = account.authentication.idToken;
      if (token == null) throw SignInError('googleFailed');
      return token;
    } on GoogleSignInException catch (e) {
      return switch (e.code) {
        GoogleSignInExceptionCode.canceled || GoogleSignInExceptionCode.interrupted => null,
        GoogleSignInExceptionCode.clientConfigurationError ||
        GoogleSignInExceptionCode.providerConfigurationError => throw SignInError('googleSetup'),
        _ => throw SignInError('googleFailed'),
      };
    } catch (e) {
      if (e is SignInError) rethrow;
      // A failed set-up (no client id in this build) can be retried after a fix.
      _init = null;
      throw SignInError('googleSetup');
    }
  }

  /// Forgets the Google account on this phone, so the next sign-in asks
  /// which account to use. Best effort: never blocks signing out.
  static Future<void> signOut() async {
    if (_init == null) return;
    try {
      await GoogleSignIn.instance.signOut().timeout(const Duration(seconds: 5));
    } catch (_) {}
  }
}
