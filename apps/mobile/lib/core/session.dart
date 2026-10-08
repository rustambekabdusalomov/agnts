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
  final String kind; // credentials, codeRequired, rateLimited, server
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
  /// sign-in on (the server answers code_required first).
  Future<void> signIn(String server, String username, String password, String code) async {
    server = server.trim().replaceAll(RegExp(r'/+$'), '');
    final api = AgntsApi(dio: Dio(BaseOptions(baseUrl: '$server/api', connectTimeout: const Duration(seconds: 15))), interceptors: []);
    try {
      final res = await api.getAuthApi().login(
            loginRequest: LoginRequest(
              username: username.trim(),
              password: password,
              code: code.trim().isEmpty ? null : code.trim(),
              client: LoginRequestClientEnum.mobile,
            ),
          );
      final token = res.data?.token;
      if (token == null) throw SignInError('server');
      await _storage.write(key: 'server', value: server);
      await _storage.write(key: 'token', value: token);
      final user = res.data!.user;
      await _storage.write(key: 'username', value: user.username);
      await _writeWorkspace(user.lastWorkspace);
      state = AsyncData(Session(server: server, token: token, username: user.username, workspace: user.lastWorkspace));
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final data = e.response?.data;
      final code = data is Map ? data['code'] : null;
      throw SignInError(status == 401 && code == 'code_required'
          ? 'codeRequired'
          : status == 401
              ? 'credentials'
              : status == 429
                  ? 'rateLimited'
                  : 'server');
    }
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
