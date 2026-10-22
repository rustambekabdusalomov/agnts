import 'dart:convert';

import 'package:agnts_api/agnts_api.dart';

/// The list's filter: every document you can open, your own, or others'
/// shared with you. Its value is the API's scope.
enum DocScope {
  all('all'),
  mine('mine'),
  shared('shared');

  const DocScope(this.api);
  final String api;
}

/// Whether agnts is writing (or about to write) the document.
bool docWriting(DocumentGeneration? g) =>
    g != null && (g.status == DocumentGenerationStatusEnum.queued || g.status == DocumentGenerationStatusEnum.writing);

/// Whether the latest generation failed.
bool docFailed(DocumentGeneration? g) => g != null && g.status == DocumentGenerationStatusEnum.failed;

/// The file name a download's Content-Disposition gives, preferring the
/// UTF-8 form; null without one.
String? fileNameFromDisposition(String? header) {
  if (header == null) return null;
  final star = RegExp(r"filename\*=UTF-8''([^;]+)", caseSensitive: false).firstMatch(header);
  if (star != null) {
    try {
      return _safe(Uri.decodeComponent(star.group(1)!.trim()));
    } catch (_) {}
  }
  final plain = RegExp(r'filename="?([^";]+)"?', caseSensitive: false).firstMatch(header);
  return plain == null ? null : _safe(plain.group(1)!.trim());
}

/// A file name without path separators, so it stays in the temp folder.
String? _safe(String name) {
  final n = name.replaceAll(RegExp(r'[/\\]'), '-').trim();
  return n.isEmpty || n == '.' || n == '..' ? null : n;
}

/// How long to wait before asking for a PDF again: Retry-After, kept
/// between 1 and 10 seconds.
Duration retryAfter(String? header) {
  final s = int.tryParse(header?.trim() ?? '') ?? 3;
  return Duration(seconds: s.clamp(1, 10));
}

/// The server's error message from a response body that arrived as bytes
/// (downloads ask for bytes, errors are JSON all the same).
String? messageFromBody(Object? data) {
  try {
    final Object? m = switch (data) {
      List<int> b => jsonDecode(utf8.decode(b)),
      String s => jsonDecode(s),
      _ => data,
    };
    if (m is Map && m['message'] is String) return m['message'] as String;
  } catch (_) {}
  return null;
}

/// The lines a 422 answer says hold secrets, as (line, excerpt).
List<(int, String)> secretLines(Object? data) {
  if (data is! Map) return const [];
  final f = data['findings'];
  if (f is! List) return const [];
  return [
    for (final x in f)
      if (x is Map && x['line'] is int) (x['line'] as int, (x['excerpt'] as String?) ?? ''),
  ];
}

/// The level a member may be given: viewers only view.
DocumentShareInputGrantsInnerLevelEnum grantLevelFor(WorkspaceRole role, DocumentShareInputGrantsInnerLevelEnum wanted) =>
    role == WorkspaceRole.viewer ? DocumentShareInputGrantsInnerLevelEnum.view : wanted;
