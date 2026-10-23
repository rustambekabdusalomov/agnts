/// A slide deck's text cut into slides, by the same rule as the server's
/// domain.SplitSlides (which prints the PDF) and the web's slides.ts: a
/// line that is exactly --- outside a code fence separates slides, a line
/// starting with "Notes:" begins the speaker notes, empty slides are
/// dropped and Marp's front matter is skipped.
library;

enum SlideLayout { lead, normal, dense, denser }

class Slide {
  const Slide(this.body, this.layout, {this.notes = ''});
  final String body;
  final String notes;
  final SlideLayout layout;

  @override
  bool operator ==(Object other) => other is Slide && other.body == body && other.notes == notes && other.layout == layout;

  @override
  int get hashCode => Object.hash(body, notes, layout);

  @override
  String toString() => 'Slide(${layout.name}, ${body.length} chars, notes ${notes.length})';
}

final _frontMatterLine = RegExp(r'^[A-Za-z_][A-Za-z0-9_-]*:');
final _listOrBlock = RegExp(r'^([-*+] |\d+[.)] |\||```|~~~|>)');

/// The fence a line opens (``` or ~~~, three or more), '' when none.
String _fenceOf(String t) {
  for (final c in ['`', '~']) {
    if (t.startsWith(c * 3)) {
      var n = 0;
      while (n < t.length && t[n] == c) {
        n++;
      }
      return c * n;
    }
  }
  return '';
}

List<String> _skipFrontMatter(List<String> lines) {
  if (lines.length < 3 || lines[0].trim() != '---') return lines;
  for (var i = 1; i < lines.length; i++) {
    final t = lines[i].trim();
    if (t == '---') return i == 1 ? lines : lines.sublist(i + 1);
    if (t.isNotEmpty && !_frontMatterLine.hasMatch(t)) return lines;
  }
  return lines;
}

int _runes(String s) => s.runes.length;

/// A slide's layout from its text: lead for headings and at most two
/// short lines, then by how much text there is.
SlideLayout slideLayout(String body) {
  final lines = [for (final l in body.split('\n')) if (l.trim().isNotEmpty) l.trim()];
  final chars = lines.fold<int>(0, (n, l) => n + _runes(l));
  var heading = false;
  var others = 0;
  var plain = true;
  for (final l in lines) {
    if (l.startsWith('#')) {
      heading = true;
      continue;
    }
    others++;
    if (_listOrBlock.hasMatch(l) || _runes(l) > 160) plain = false;
  }
  if (heading && plain && others <= 2) return SlideLayout.lead;
  final w = lines.length + chars ~/ 90;
  if (w > 18) return SlideLayout.denser;
  if (w > 12) return SlideLayout.dense;
  return SlideLayout.normal;
}

/// The slides of a deck.
List<Slide> splitSlides(String text) {
  final lines = _skipFrontMatter(text.replaceAll('\r\n', '\n').split('\n'));
  final out = <Slide>[];
  var cur = <String>[];
  var notes = <String>[];
  var inNotes = false;
  var fence = '';
  void flush() {
    final body = cur.join('\n').trim();
    if (body.isNotEmpty) out.add(Slide(body, slideLayout(body), notes: notes.join('\n').trim()));
    cur = [];
    notes = [];
    inNotes = false;
  }

  for (final line in lines) {
    final t = line.trim();
    if (fence.isNotEmpty) {
      if (t.startsWith(fence) && t.replaceAll(fence[0], '').isEmpty) fence = '';
    } else if (_fenceOf(t).isNotEmpty) {
      fence = _fenceOf(t);
    } else if (t == '---') {
      flush();
      continue;
    } else if (!inNotes && t.toLowerCase().startsWith('notes:')) {
      inNotes = true;
      notes.add(t.substring('notes:'.length).trim());
      continue;
    }
    (inNotes ? notes : cur).add(line);
  }
  flush();
  return out;
}
