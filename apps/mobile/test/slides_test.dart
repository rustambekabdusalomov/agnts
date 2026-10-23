import 'package:agnts_mobile/features/documents/slides.dart';
import 'package:flutter_test/flutter_test.dart';

// The same cases as the server's TestSplitSlides and the web's
// slides.test.ts: every place must cut a deck the same way.
void main() {
  const lead = SlideLayout.lead;
  const normal = SlideLayout.normal;
  final cases = <(String, String, List<Slide>)>[
    ('one slide', '# Hello\n\nWorld', [const Slide('# Hello\n\nWorld', lead)]),
    ('separators', '# A\n\n---\n\n# B\n  ---  \n# C', [const Slide('# A', lead), const Slide('# B', lead), const Slide('# C', lead)]),
    ('empty slides dropped', '---\n\n# A\n---\n\n---\n# B\n---\n', [const Slide('# A', lead), const Slide('# B', lead)]),
    ('--- inside a fence', '## Code\n\n```yaml\na: 1\n---\nb: 2\n```\n---\n# Next',
        [const Slide('## Code\n\n```yaml\na: 1\n---\nb: 2\n```', normal), const Slide('# Next', lead)]),
    ('longer fence', '````\n```\n---\n```\n````\n---\n# B', [const Slide('````\n```\n---\n```\n````', normal), const Slide('# B', lead)]),
    ('notes', '## Plan\n\n- one\n- two\n\nNotes: say it slowly\nand smile\n---\n# End\nNOTES:\nthanks', [
      const Slide('## Plan\n\n- one\n- two', normal, notes: 'say it slowly\nand smile'),
      const Slide('# End', lead, notes: 'thanks'),
    ]),
    ('notes: in a fence is text', '```\nnotes: x\n```', [const Slide('```\nnotes: x\n```', normal)]),
    ('front matter', '---\nmarp: true\ntheme: default\n---\n\n# Title\n---\n# Two', [const Slide('# Title', lead), const Slide('# Two', lead)]),
    ('not front matter', '---\n# A\n---\n# B', [const Slide('# A', lead), const Slide('# B', lead)]),
    ('lead with a subtitle', '# Sprint 42\n\nWhat shipped, Oct 22', [const Slide('# Sprint 42\n\nWhat shipped, Oct 22', lead)]),
    ('a list is not lead', '# Sprint 42\n\n- one', [const Slide('# Sprint 42\n\n- one', normal)]),
    ('CRLF', '# A\r\n---\r\n# B', [const Slide('# A', lead), const Slide('# B', lead)]),
    ('nothing', '\n\n---\n', const <Slide>[]),
  ];
  for (final (name, text, want) in cases) {
    test(name, () => expect(splitSlides(text), want));
  }

  test('a smaller font for more text', () {
    String bullets(int n) => '## Points\n${'- a point of ordinary length\n' * n}';
    expect(splitSlides(bullets(5)).single.layout, SlideLayout.normal);
    expect(splitSlides(bullets(13)).single.layout, SlideLayout.dense);
    expect(splitSlides(bullets(20)).single.layout, SlideLayout.denser);
  });
}
