import 'package:flutter_test/flutter_test.dart';
import 'package:hiro_mobile/features/tickets/diff_lines.dart';

void main() {
  test('numbers added, removed and context lines from the hunk headers', () {
    final diff = [
      'diff --git a/x.go b/x.go',
      '--- a/x.go',
      '+++ b/x.go',
      '@@ -10,4 +10,5 @@ func main() {',
      ' a',
      '-b',
      '+B',
      '+C',
      ' d',
      r'\ No newline at end of file',
      '@@ -40 +41 @@',
      '-old',
      '+new',
      '',
    ].join('\n');
    final got = numberDiff(diff).map((l) => (l.kind, l.old, l.neu)).toList();
    expect(got, [
      (DiffKind.plain, null, null), // diff --git
      (DiffKind.plain, null, null), // --- a/x.go is a header, not a removal
      (DiffKind.plain, null, null), // +++ b/x.go is a header, not an addition
      (DiffKind.hunk, null, null),
      (DiffKind.plain, 10, 10),
      (DiffKind.del, 11, null),
      (DiffKind.add, null, 11),
      (DiffKind.add, null, 12),
      (DiffKind.plain, 12, 13),
      (DiffKind.plain, null, null), // \ No newline
      (DiffKind.hunk, null, null),
      (DiffKind.del, 40, null),
      (DiffKind.add, null, 41),
      (DiffKind.plain, null, null), // trailing newline
    ]);
  });

  test('numbers a new file from 1', () {
    final got = numberDiff('--- /dev/null\n+++ b/n.md\n@@ -0,0 +1,2 @@\n+one\n+two');
    expect(got.where((l) => l.kind == DiffKind.add).map((l) => l.neu), [1, 2]);
  });
}
