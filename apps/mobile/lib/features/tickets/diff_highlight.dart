import 'package:flutter/painting.dart';
import 'package:highlighting/highlighting.dart';

import 'diff_lines.dart';

// Syntax highlighting for diffs, as highlight.ts does it in the admin panel:
// the same languages, the same per-hunk sides and the same colours.

/// A run of code text and the highlight.js scope that colours it, if any.
typedef CodeSpan = ({String text, String? scope});

const _byExt = {
  'go': 'go', 'ts': 'typescript', 'tsx': 'typescript', 'mts': 'typescript', 'cts': 'typescript',
  'js': 'javascript', 'jsx': 'javascript', 'mjs': 'javascript', 'cjs': 'javascript',
  'vue': 'xml', 'html': 'xml', 'htm': 'xml', 'xml': 'xml', 'svg': 'xml', 'arb': 'json',
  'json': 'json', 'yml': 'yaml', 'yaml': 'yaml', 'css': 'css', 'scss': 'scss', 'less': 'less',
  'sql': 'sql', 'sh': 'bash', 'bash': 'bash', 'zsh': 'bash', 'dart': 'dart', 'py': 'python',
  'md': 'markdown', 'java': 'java', 'kt': 'kotlin', 'kts': 'kotlin', 'rs': 'rust', 'php': 'php',
  'rb': 'ruby', 'c': 'c', 'h': 'c', 'cc': 'cpp', 'cpp': 'cpp', 'hpp': 'cpp', 'cs': 'csharp',
  'swift': 'swift', 'ini': 'ini', 'toml': 'ini', 'env': 'ini', 'graphql': 'graphql', 'gql': 'graphql', 'proto': 'protobuf',
};

/// The highlight.js language for a file path, or null when there is none.
String? languageFor(String path) {
  final name = path.split('/').last;
  if (RegExp(r'^dockerfile', caseSensitive: false).hasMatch(name) || name.toLowerCase().endsWith('.dockerfile')) return 'dockerfile';
  if (RegExp(r'^(gnu)?makefile$', caseSensitive: false).hasMatch(name) || name.endsWith('.mk')) return 'makefile';
  final ext = name.contains('.') ? name.split('.').last.toLowerCase() : '';
  return _byExt[ext];
}

// Colours of the admin panel's diff theme (app.css), by highlight.js scope.
const _comment = TextStyle(color: Color(0xFF8B949E), fontStyle: FontStyle.italic);
const _keyword = TextStyle(color: Color(0xFFFF7B72));
const _string = TextStyle(color: Color(0xFFA5D6FF));
const _number = TextStyle(color: Color(0xFF79C0FF));
const _title = TextStyle(color: Color(0xFFD2A8FF));
const _type = TextStyle(color: Color(0xFFFFA657));
const _tag = TextStyle(color: Color(0xFF7EE787));
const _plain = TextStyle(color: Color(0xFFE6EDF3));
const _styles = <String, TextStyle>{
  'comment': _comment, 'quote': _comment,
  'keyword': _keyword, 'selector-tag': _keyword, 'literal': _keyword, 'doctag': _keyword,
  'string': _string, 'regexp': _string, 'template-tag': _string,
  'number': _number, 'symbol': _number, 'bullet': _number, 'variable.constant_': _number, 'attr': _number, 'attribute': _number,
  'title': _title, 'title.function_': _title, 'section': _title,
  'title.class_': _type, 'type': _type, 'built_in': _type, 'selector-class': _type, 'selector-id': _type,
  'name': _tag, 'tag': _tag, 'selector-pseudo': _tag,
  'meta': _plain, 'params': _plain, 'subst': _plain, 'variable': _plain, 'property': _plain,
  'emphasis': TextStyle(fontStyle: FontStyle.italic),
  'strong': TextStyle(fontWeight: FontWeight.w700),
  'addition': TextStyle(color: Color(0xFFAFF5B4)),
  'deletion': TextStyle(color: Color(0xFFFFDCD7)),
};

/// The style for a scope that [highlightDiff] returned, or null for none.
TextStyle? styleFor(String? scope) => scope == null ? null : _styles[scope];

/// Splits highlighted code into lines of spans. Each span takes the
/// innermost scope around it that has a colour, as nested CSS rules would.
List<List<CodeSpan>> _splitLines(Result r) {
  final out = <List<CodeSpan>>[[]];
  void walk(Node n, String? scope) {
    final own = n.className;
    if (own != null && (_styles.containsKey(own) || _styles.containsKey(own.split('.').first))) {
      scope = _styles.containsKey(own) ? own : own.split('.').first;
    }
    final v = n.value;
    if (v != null) {
      final parts = v.split('\n');
      for (final (i, p) in parts.indexed) {
        if (i > 0) out.add([]);
        if (p.isNotEmpty) out.last.add((text: p, scope: scope));
      }
    }
    for (final c in n.children) {
      walk(c, scope);
    }
  }

  walk(r.rootNode, null);
  return out;
}

/// Highlights a numbered diff: within each hunk, the old side (context and
/// removed lines) and the new side (context and added lines) are highlighted
/// as code, so comments and strings spanning lines colour correctly. Returns
/// the spans of each line's code (without the +/-/space marker), or null for
/// lines that are not code; null overall when the language is unknown.
/// Pure, so it can run in another isolate.
List<List<CodeSpan>?>? highlightDiff(({List<DiffLine> lines, String path}) a) {
  final lang = languageFor(a.path);
  if (lang == null) return null;
  final lines = a.lines;
  final out = List<List<CodeSpan>?>.filled(lines.length, null);
  List<List<CodeSpan>> render(List<int> idx) {
    if (idx.isEmpty) return const [];
    final code = idx.map((i) => lines[i].text.substring(1)).join('\n');
    return _splitLines(highlight.parse(code, languageId: lang));
  }

  void flush(List<int> oldIdx, List<int> newIdx) {
    final oldSpans = render(oldIdx);
    final newSpans = render(newIdx);
    for (final (k, i) in oldIdx.indexed) {
      out[i] = k < oldSpans.length ? oldSpans[k] : null;
    }
    for (final (k, i) in newIdx.indexed) {
      out[i] = k < newSpans.length ? newSpans[k] : null; // context lines take the new side
    }
  }

  var oldIdx = <int>[];
  var newIdx = <int>[];
  for (final (i, l) in lines.indexed) {
    if (l.kind == DiffKind.hunk) {
      flush(oldIdx, newIdx);
      oldIdx = [];
      newIdx = [];
    }
    if (l.old != null) oldIdx.add(i);
    if (l.neu != null) newIdx.add(i);
  }
  flush(oldIdx, newIdx);
  return out;
}
