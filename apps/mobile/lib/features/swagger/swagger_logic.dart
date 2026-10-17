import 'dart:convert';

import 'package:agnts_api/agnts_api.dart';

import '../../l10n/app_localizations.dart';
import '../../widgets/ui.dart' show Tone;

String _quote(String s) => "'${s.replaceAll("'", r"'\''")}'";

/// The exchange as a curl command; credentials stay masked as logged.
String curlOf(ApiExchange e) {
  final parts = ['curl', '-X', e.method, _quote(e.url)];
  for (final h in (e.requestHeaders ?? const <String, String>{}).entries) {
    if (RegExp(r'^(user-agent|accept-encoding|content-length)$', caseSensitive: false).hasMatch(h.key)) continue;
    parts.addAll(['-H', _quote('${h.key}: ${h.value}')]);
  }
  final body = e.requestBody;
  if (body != null && body.isNotEmpty) parts.addAll(['--data', _quote(body)]);
  return parts.join(' ');
}

/// JSON indented, anything else as it is.
String prettyBody(String? s) {
  if (s == null || s.isEmpty) return '';
  try {
    return const JsonEncoder.withIndent('  ').convert(jsonDecode(s));
  } catch (_) {
    return s;
  }
}

/// A response status's tone: none is bad, 2xx ok, 3xx/4xx warn, 5xx bad.
Tone statusTone(int s) => s == 0 ? Tone.bad : s < 300 ? Tone.ok : s < 500 ? Tone.warn : Tone.bad;

String opKey(SwaggerOperation o) => '${o.method} ${o.path}';

/// Whether an operation matches a search (path, summary, id or tag).
bool opMatches(SwaggerOperation o, String q) {
  q = q.trim().toLowerCase();
  if (q.isEmpty) return true;
  return [o.method, o.path, o.summary, o.operationId, ...?o.tags].any((s) => s != null && s.toLowerCase().contains(q));
}

/// Operations grouped by their first tag ("" when untagged), in spec order.
List<(String, List<SwaggerOperation>)> byTag(List<SwaggerOperation> ops) {
  final out = <String, List<SwaggerOperation>>{};
  for (final o in ops) {
    (out[(o.tags ?? const []).firstOrNull ?? ''] ??= []).add(o);
  }
  return [for (final e in out.entries) (e.key, e.value)];
}

String authKindLabel(AppLocalizations l, ApiAuthKind k) => switch (k) {
  ApiAuthKind.none => l.swaggerAuthKind_none,
  ApiAuthKind.bearer => l.swaggerAuthKind_bearer,
  ApiAuthKind.header => l.swaggerAuthKind_header,
  ApiAuthKind.query => l.swaggerAuthKind_query,
  ApiAuthKind.basic => l.swaggerAuthKind_basic,
};

String scheduleLabel(AppLocalizations l, String s) => switch (s) {
  'hourly' => l.swaggerSchedule_hourly,
  'daily' => l.swaggerSchedule_daily,
  'weekly' => l.swaggerSchedule_weekly,
  _ => l.swaggerSchedule_off,
};

/// The description of a Bug ticket for a test's failures.
String bugDescription(String intro, List<ApiCase> cases) {
  final lines = [intro, ''];
  for (final c in cases.where((x) => x.verdict == ApiCaseVerdictEnum.fail)) {
    final expected = c.expected != null ? ' (expected: ${c.expected})' : '';
    lines.add('- ${c.operation} — ${c.case_}$expected: ${c.reason ?? ''} [${c.requests.join(', ')}]');
  }
  return lines.join('\n');
}
