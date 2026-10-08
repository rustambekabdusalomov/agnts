import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agnts_api/agnts_api.dart';

import 'session.dart';

/// The generated API client for the signed-in server, or null when signed out.
final apiProvider = Provider<AgntsApi?>((ref) {
  final s = ref.watch(sessionProvider).value;
  if (s == null) return null;
  final dio = Dio(BaseOptions(
    baseUrl: '${s.server}/api',
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 30),
    // Array query parameters are comma-separated (?state=a,b), as the spec
    // declares them (explode: false); Dio repeats them by default.
    listFormat: ListFormat.csv,
  ));
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (o, h) {
      o.headers['Authorization'] = 'Bearer ${s.token}';
      // Workspace routes act in this workspace; account routes ignore it.
      if (s.workspace != null) o.headers['X-Workspace'] = s.workspace;
      h.next(o);
    },
    onError: (e, h) {
      if (e.response?.statusCode == 401) {
        ref.read(sessionProvider.notifier).signedOut();
      }
      h.next(e);
    },
  ));
  return AgntsApi(dio: dio, interceptors: []);
});

/// The API client, for providers that only run while signed in.
AgntsApi requireApi(Ref ref) {
  final api = ref.watch(apiProvider);
  if (api == null) throw StateError('not signed in');
  return api;
}

/// A short message for a failed call: the server's own message when it sent one.
String errorMessage(Object e, String fallback) {
  if (e is DioException) {
    final data = e.response?.data;
    if (data is Map && data['message'] is String) return data['message'] as String;
    if (e.response?.statusCode == 409) return fallback;
  }
  return fallback;
}
