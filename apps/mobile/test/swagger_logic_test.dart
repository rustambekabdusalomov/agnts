import 'package:agnts_api/agnts_api.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agnts_mobile/features/swagger/swagger_logic.dart';
import 'package:agnts_mobile/widgets/ui.dart' show Tone;

SwaggerOperation _op(String method, String path, {List<String>? tags, String? summary}) =>
    SwaggerOperation(method: method, path: path, tags: tags, summary: summary, default_: true);

void main() {
  test('curl leaves out noise headers and quotes the body', () {
    final e = ApiExchange(
      id: 'r-001',
      method: 'POST',
      url: 'https://staging.test/users',
      status: 201,
      ms: 12,
      requestHeaders: const {'Authorization': 'Bearer ***', 'User-Agent': 'agnts', 'Content-Length': '9'},
      requestBody: "{\"a\":\"it's\"}",
    );
    expect(curlOf(e), "curl -X POST 'https://staging.test/users' -H 'Authorization: Bearer ***' --data '{\"a\":\"it'\\''s\"}'");
  });

  test('groups operations by their first tag in spec order and searches them', () {
    final ops = [_op('GET', '/users', tags: ['users']), _op('GET', '/health'), _op('POST', '/users', tags: ['users'], summary: 'Create user')];
    final groups = byTag(ops);
    expect(groups.map((g) => g.$1), ['users', '']);
    expect(groups.first.$2.length, 2);
    expect(ops.where((o) => opMatches(o, 'create')).map(opKey), ['POST /users']);
    expect(ops.where((o) => opMatches(o, '')).length, 3);
  });

  test('pretty-prints JSON bodies and status tones', () {
    expect(prettyBody('{"a":1}'), '{\n  "a": 1\n}');
    expect(prettyBody('plain'), 'plain');
    expect([0, 200, 404, 503].map(statusTone), [Tone.bad, Tone.ok, Tone.warn, Tone.bad]);
  });

  test('a bug description lists the failures only', () {
    final cases = [
      ApiCase(id: '1', operation: 'GET /a', case_: 'ok', verdict: ApiCaseVerdictEnum.pass, requests: const ['r-1'], source_: ApiCaseSource_Enum.claude),
      ApiCase(id: '2', operation: 'GET /b', case_: 'bad id', verdict: ApiCaseVerdictEnum.fail, reason: '500', requests: const ['r-2'], source_: ApiCaseSource_Enum.claude),
    ];
    expect(bugDescription('Intro', cases), 'Intro\n\n- GET /b — bad id: 500 [r-2]');
  });
}
