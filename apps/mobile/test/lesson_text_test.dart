import 'package:flutter_test/flutter_test.dart';
import 'package:hiro_mobile/features/learn/lesson_text.dart';

void main() {
  test('splits paragraphs and fenced code', () {
    final b = lessonBlocks('First paragraph\nstill first.\n\n```go\nfunc f() {}\n```\nAfter the code.');
    expect(b, [
      (code: false, text: 'First paragraph\nstill first.'),
      (code: true, text: 'func f() {}'),
      (code: false, text: 'After the code.'),
    ]);
  });

  test('treats an indented paragraph as code', () {
    final b = lessonBlocks('Intro\n\n    if x {\n        y()\n    }');
    expect(b, [(code: false, text: 'Intro'), (code: true, text: 'if x {\n    y()\n}')]);
  });
}
