import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agnts_mobile/core/api.dart';

void main() {
  final req = RequestOptions(path: '/repos/6/pulls/289');

  test('a server that answered is not asked again', () {
    final e = DioException(requestOptions: req, response: Response(requestOptions: req, statusCode: 502, data: {'message': 'the git host refused'}));
    expect(apiRetry(0, e), isNull);
    expect(errorMessage(e, 'offline'), 'the git host refused');
  });

  test('a network failure is tried again a few times', () {
    final e = DioException(requestOptions: req, type: DioExceptionType.connectionTimeout);
    expect(apiRetry(0, e), isNotNull);
    expect(apiRetry(4, e), isNull);
  });

  test('a provider that fails with an answer is an error at once', () async {
    final c = ProviderContainer(retry: apiRetry);
    addTearDown(c.dispose);
    final p = FutureProvider<int>((ref) async => throw DioException(requestOptions: req, response: Response(requestOptions: req, statusCode: 502)));
    c.listen(p, (_, _) {});
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(c.read(p), isA<AsyncError<int>>());
  });
}
