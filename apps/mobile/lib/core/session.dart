import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:agnts_api/agnts_api.dart';

/// A signed-in session: which server, the bearer token for it, and the
/// workspace the app acts in.
class Session {
  const Session({required this.server, required this.token, required this.username, this.workspace});
  final String server;
  final String token;
  final String username;

  /// The workspace's slug, sent as X-Workspace. Null leaves the choice to the
  /// server: the workspace the person opened last.
  final String? workspace;

  Session withWorkspace(String? slug) => Session(server: server, token: token, username: username, workspace: slug);
}

const _storage = FlutterSecureStorage();

/// Thrown by [SessionNotifier.signIn] with a message to show.
class SignInError implements Exception {
  SignInError(this.kind);
  final String kind; // credentials, codeRequired, totpSetup, useGoogle, rateLimited, server, or a Google reason (signInWithGoogle)
}

/// Holds the session; the token lives in the platform's secure storage.
class SessionNotifier extends AsyncNotifier<Session?> {
  @override
  Future<Session?> build() async {
    final server = await _storage.read(key: 'server');
    final token = await _storage.read(key: 'token');
    final user = await _storage.read(key: 'username');
    final workspace = await _storage.read(key: 'workspace');
    if (server == null || token == null) return null;
    return Session(server: server, token: token, username: user ?? '', workspace: workspace);
  }

  /// Signs in; [code] is asked for only when the account has two-factor
  /// sign-in on (the server answers code_required first). An Admin without
  /// it sets it up while signing in: [totpSecret] from [beginLoginTotp].
  Future<void> signIn(String server, String username, String password, String code, {String? totpSecret}) async {
    server = _trim(server);
    try {
      final res = await _client(server).getAuthApi().login(
        loginRequest: LoginRequest(
          username: username.trim(),
          password: password,
          code: code.trim().isEmpty ? null : code.trim(),
          totpSecret: totpSecret,
          client: LoginRequestClientEnum.mobile,
        ),
      );
      await _signedIn(server, res.data);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final data = e.response?.data;
      final code = data is Map ? data['code'] : null;
      throw SignInError(
        status == 401 && code == 'code_required'
            ? 'codeRequired'
            : code == 'totp_setup_required'
            ? 'totpSetup'
            : status == 403 && code == 'use_google'
            ? 'useGoogle'
            : status == 401
            ? 'credentials'
            : status == 429
            ? 'rateLimited'
            : 'server',
      );
    }
  }

  /// A new two-factor secret for an Admin who signs in without one yet.
  Future<BeginLoginTotp200Response> beginLoginTotp(String server, String username, String password) async {
    final res = await client(server).getAuthApi().beginLoginTotp(
      beginLoginTotpRequest: BeginLoginTotpRequest(username: username.trim(), password: password),
    );
    return res.data!;
  }

  /// Creates an account with a password and signs in to it.
  Future<void> register(String server, RegisterRequest request) async {
    server = _trim(server);
    final res = await client(server).getAuthApi().register(registerRequest: request);
    await _signedIn(server, res.data);
  }

  /// The server's OAuth web client id for Google sign-in, or null when
  /// Google sign-in is off there.
  Future<String?> googleClientId(String server) async {
    try {
      final id = (await _client(_trim(server)).getAuthApi().getSignupInfo()).data?.googleClientId;
      return id == null || id.isEmpty ? null : id;
    } on DioException {
      throw SignInError('server');
    }
  }

  /// Signs in with the ID token Google Sign-In gave the app. Errors carry
  /// the server's reason: googleInvalid, signupClosed, admin, invite,
  /// googleOff, rateLimited or server.
  Future<void> signInWithGoogle(String server, String idToken, {String? invite}) async {
    server = _trim(server);
    try {
      final res = await _client(server).getAuthApi().signInWithGoogle(
        googleSignInRequest: GoogleSignInRequest(idToken: idToken, invite: invite),
      );
      await _signedIn(server, res.data);
    } on DioException catch (e) {
      final data = e.response?.data;
      throw SignInError(switch ((e.response?.statusCode, data is Map ? data['code'] : null)) {
        (_, 'google_invalid') => 'googleInvalid',
        (_, 'signup_closed') => 'signupClosed',
        (_, 'admin_password') => 'admin',
        (_, 'invite') => 'invite',
        (_, 'google_off') => 'googleOff',
        (429, _) => 'rateLimited',
        _ => 'server',
      });
    }
  }

  static String _trim(String server) => server.trim().replaceAll(RegExp(r'/+$'), '');

  /// A client for the account calls made signed out (sign-up, password
  /// reset, email confirmation, invite preview).
  static AgntsApi client(String server) => _client(_trim(server));

  static AgntsApi _client(String server) => AgntsApi(
    dio: Dio(BaseOptions(baseUrl: '$server/api', connectTimeout: const Duration(seconds: 15))),
    interceptors: [],
  );

  Future<void> _signedIn(String server, LoginResponse? res) async {
    final token = res?.token;
    if (token == null) throw SignInError('server');
    await _storage.write(key: 'server', value: server);
    await _storage.write(key: 'token', value: token);
    final user = res!.user;
    await _storage.write(key: 'username', value: user.username);
    await _writeWorkspace(user.lastWorkspace);
    state = AsyncData(Session(server: server, token: token, username: user.username, workspace: user.lastWorkspace));
  }

  /// Switches the workspace the app acts in; every screen reloads for it.
  Future<void> setWorkspace(String? slug) async {
    final s = state.value;
    if (s == null || s.workspace == slug) return;
    await _writeWorkspace(slug);
    state = AsyncData(s.withWorkspace(slug));
  }

  Future<void> _writeWorkspace(String? slug) =>
      slug == null || slug.isEmpty ? _storage.delete(key: 'workspace') : _storage.write(key: 'workspace', value: slug);

  /// Forgets the session locally (the server session is ended by [signOut]).
  Future<void> signedOut() async {
    await _storage.delete(key: 'token');
    state = const AsyncData(null);
  }
}

final sessionProvider = AsyncNotifierProvider<SessionNotifier, Session?>(SessionNotifier.new);
