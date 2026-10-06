import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:agnts_api/agnts_api.dart';

/// A signed-in session: which server, and the bearer token for it.
class Session {
  const Session({required this.server, required this.token, required this.username});
  final String server;
  final String token;
  final String username;
}

const _storage = FlutterSecureStorage();

/// Thrown by [SessionNotifier.signIn] with a message to show.
class SignInError implements Exception {
  SignInError(this.kind);
  final String kind; // credentials, rateLimited, server
}

/// Holds the session; the token lives in the platform's secure storage.
class SessionNotifier extends AsyncNotifier<Session?> {
  @override
  Future<Session?> build() async {
    final server = await _storage.read(key: 'server');
    final token = await _storage.read(key: 'token');
    final user = await _storage.read(key: 'username');
    if (server == null || token == null) return null;
    return Session(server: server, token: token, username: user ?? '');
  }

  Future<void> signIn(String server, String username, String password, String code) async {
    server = server.trim().replaceAll(RegExp(r'/+$'), '');
    final api = AgntsApi(dio: Dio(BaseOptions(baseUrl: '$server/api', connectTimeout: const Duration(seconds: 15))), interceptors: []);
    try {
      final res = await api.getAuthApi().login(
            loginRequest: LoginRequest(
              username: username.trim(),
              password: password,
              code: code.trim(),
              client: LoginRequestClientEnum.mobile,
            ),
          );
      final token = res.data?.token;
      if (token == null) throw SignInError('server');
      await _storage.write(key: 'server', value: server);
      await _storage.write(key: 'token', value: token);
      await _storage.write(key: 'username', value: res.data!.user.username);
      state = AsyncData(Session(server: server, token: token, username: res.data!.user.username));
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      throw SignInError(status == 401
          ? 'credentials'
          : status == 429
              ? 'rateLimited'
              : 'server');
    }
  }

  /// Forgets the session locally (the server session is ended by [signOut]).
  Future<void> signedOut() async {
    await _storage.delete(key: 'token');
    state = const AsyncData(null);
  }
}

final sessionProvider = AsyncNotifierProvider<SessionNotifier, Session?>(SessionNotifier.new);
