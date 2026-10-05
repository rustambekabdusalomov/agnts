/// Kind of one unified-diff line: plain (headers, context, notes), hunk header, added or removed.
enum DiffKind { plain, hunk, add, del }

/// One line of a unified diff with its old and new line numbers, if any.
typedef DiffLine = ({String text, DiffKind kind, int? old, int? neu});

final _hunk = RegExp(r'^@@ -(\d+)(?:,\d+)? \+(\d+)(?:,\d+)? @@');

/// Splits a git unified diff into lines and numbers them from the hunk
/// headers: added lines get a new number, removed lines an old one, context
/// lines both. Headers, hunk lines and notes ("\ No newline…") get none.
/// Same as numberDiff in the admin panel (diffLines.ts).
List<DiffLine> numberDiff(String diff) {
  var oldN = 0;
  var newN = 0;
  var inHunk = false;
  return diff.split('\n').map((text) {
    final h = _hunk.firstMatch(text);
    if (h != null) {
      oldN = int.parse(h[1]!);
      newN = int.parse(h[2]!);
      inHunk = true;
      return (text: text, kind: DiffKind.hunk, old: null, neu: null);
    }
    if (text.startsWith('diff ')) inHunk = false;
    if (!inHunk || text.isEmpty) return (text: text.isEmpty ? ' ' : text, kind: DiffKind.plain, old: null, neu: null);
    return switch (text[0]) {
      '+' => (text: text, kind: DiffKind.add, old: null, neu: newN++),
      '-' => (text: text, kind: DiffKind.del, old: oldN++, neu: null),
      ' ' => (text: text, kind: DiffKind.plain, old: oldN++, neu: newN++),
      _ => (text: text, kind: DiffKind.plain, old: null, neu: null), // "\ No newline at end of file", "… diff truncated …"
    };
  }).toList();
}
