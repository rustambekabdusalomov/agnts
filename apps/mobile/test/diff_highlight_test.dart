import 'package:flutter_test/flutter_test.dart';
import 'package:agnts_mobile/features/tickets/diff_highlight.dart';
import 'package:agnts_mobile/features/tickets/diff_lines.dart';

List<List<CodeSpan>?>? hl(String diff, String path) => highlightDiff((lines: numberDiff(diff), path: path));

String text(List<CodeSpan>? spans) => spans!.map((s) => s.text).join();
Iterable<String?> scopes(List<CodeSpan>? spans) => spans!.map((s) => s.scope);

void main() {
  test('picks a language from the path', () {
    expect(languageFor('server/cmd/main.go'), 'go');
    expect(languageFor('apps/admin/src/App.vue'), 'xml');
    expect(languageFor('deploy/Dockerfile'), 'dockerfile');
    expect(languageFor('Makefile'), 'makefile');
    expect(languageFor('notes.unknownext'), isNull);
    expect(languageFor('LICENSE'), isNull);
  });

  test('colours a block comment across lines and keeps each side separate', () {
    final diff = ['@@ -1,3 +1,3 @@', ' /* start', '-old */ x := 1', '+new */ y := 2', ' z := "s"'].join('\n');
    final out = hl(diff, 'main.go')!;
    final [hunk, start, removed, added, last] = out;
    expect(hunk, isNull);
    expect(scopes(start), contains('comment'));
    expect(scopes(removed), contains('comment')); // still inside the comment on the old side
    expect(scopes(added), contains('comment')); // and on the new side
    expect(scopes(last), contains('string'));
    expect(text(removed), 'old */ x := 1'); // the +/-/space marker is left out
    expect(text(added), 'new */ y := 2'); // the new side never sees removed text
  });

  test('keeps every character of the code', () {
    final out = hl('@@ -0,0 +1,2 @@\n+final s = "a\\"b"; // x\n+', 'x.dart')!;
    expect(text(out[1]), 'final s = "a\\"b"; // x');
    expect(text(out[2]), '');
  });

  test('leaves unknown files to plain text', () {
    expect(hl('@@ -0,0 +1 @@\n+hi', 'README'), isNull);
  });
}
