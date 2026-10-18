import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:agnts_api/agnts_api.dart';

import '../../theme.dart';
import 'diff_highlight.dart';
import 'diff_lines.dart';
import 'ticket_repos.dart';

// ---- One changed file with its diff (.file, .diff) ----

const _codeAdd = Color(0x382EA067); // rgba(46,160,103,.22)
const _codeDel = Color(0x3DD64034); // rgba(214,64,52,.24)
const _codeHunk = Color(0x2E7D96EB); // rgba(125,150,235,.18)
const _hunkInk = Color(0xFFB9C6F5);

class FileDiff extends StatefulWidget {
  const FileDiff({super.key, required this.file, this.initiallyOpen = false});
  final FileChange file;
  final bool initiallyOpen;

  @override
  State<FileDiff> createState() => _FileDiffState();
}

class _FileDiffState extends State<FileDiff> {
  late bool _open = widget.initiallyOpen;

  @override
  Widget build(BuildContext context) {
    final c = Agnts.of(context);
    final f = widget.file;
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(color: c.surface, border: Border.all(color: c.line), borderRadius: BorderRadius.circular(14)),
      clipBehavior: Clip.antiAlias,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        InkWell(
          onTap: () => setState(() => _open = !_open),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                child: Text(filePath(f), maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: AgntsFonts.mono, fontSize: 12.5, color: c.ink)),
              ),
              const SizedBox(width: 10),
              Text('+${f.add}', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: c.okInk)),
              const SizedBox(width: 5),
              Text('−${f.del}', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: c.badInk)),
            ]),
          ),
        ),
        if (_open) _Diff(f.diff, path: f.path),
      ]),
    );
  }
}

class _Diff extends StatefulWidget {
  const _Diff(this.diff, {required this.path});
  final String diff;
  final String path;

  @override
  State<_Diff> createState() => _DiffState();
}

class _DiffState extends State<_Diff> {
  late List<DiffLine> _lines;
  // Highlighted spans per line (null: show as plain text). Until they are
  // ready, or for files with no known language, the diff shows as plain text.
  List<List<CodeSpan>?>? _spans;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(_Diff old) {
    super.didUpdateWidget(old);
    if (old.diff != widget.diff || old.path != widget.path) _load();
  }

  Future<void> _load() async {
    final lines = _lines = numberDiff(widget.diff).take(400).toList();
    _spans = null;
    if (languageFor(widget.path) == null) return;
    try {
      final spans = await compute(highlightDiff, (lines: lines, path: widget.path));
      if (mounted && identical(lines, _lines)) setState(() => _spans = spans);
    } catch (_) {
      // highlighting is a nicety; plain text still works
    }
  }

  static Color? _bg(DiffKind k) => switch (k) {
        DiffKind.add => _codeAdd,
        DiffKind.del => _codeDel,
        DiffKind.hunk => _codeHunk,
        DiffKind.plain => null,
      };

  @override
  Widget build(BuildContext context) {
    final c = Agnts.of(context);
    const style = TextStyle(fontFamily: AgntsFonts.mono, fontSize: 11.5, height: 1.6);
    final lines = _lines;
    // Gutter wide enough for the largest line number in the file.
    final digits = lines.fold(2, (w, l) => math.max(w, '${l.old ?? l.neu ?? ''}'.length));
    final numStyle = style.copyWith(color: c.codeDim);
    final tp = TextPainter(
      text: TextSpan(text: '0' * digits, style: numStyle),
      textDirection: TextDirection.ltr,
      textScaler: MediaQuery.textScalerOf(context),
    )..layout();
    final numWidth = tp.width;
    tp.dispose();
    Widget num(int? n) => SizedBox(
          width: numWidth.ceilToDouble() + 1,
          child: Text(n?.toString() ?? '', textAlign: TextAlign.right, softWrap: false, style: numStyle),
        );
    // Old and new numbers stay put while long lines scroll sideways, as in
    // the admin panel's DiffView.vue. Every row is one line of the same
    // style, so the gutter and code rows line up.
    return Container(
      color: c.code,
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          decoration: BoxDecoration(border: Border(right: BorderSide(color: const Color(0xFF7F7F7F).withValues(alpha: 0.25)))),
          // As wide as its rows: in the Row it has no width to stretch them to.
          child: IntrinsicWidth(
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
              for (final l in lines)
                Container(
                  color: _bg(l.kind),
                  padding: const EdgeInsets.only(left: 4, right: 8),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [num(l.old), const SizedBox(width: 6), num(l.neu)]),
                ),
            ]),
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, box) => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: box.maxWidth),
                child: IntrinsicWidth(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    for (final (i, l) in lines.indexed)
                      Container(
                        padding: const EdgeInsets.only(left: 10, right: 14),
                        color: _bg(l.kind),
                        child: switch (_spans?[i]) {
                          final spans? => Text.rich(
                              TextSpan(text: l.text[0], children: [
                                for (final sp in spans) TextSpan(text: sp.text, style: styleFor(sp.scope)),
                              ]),
                              softWrap: false,
                              style: style.copyWith(color: c.codeInk),
                            ),
                          null => Text(l.text, softWrap: false, style: style.copyWith(color: l.kind == DiffKind.hunk ? _hunkInk : c.codeInk)),
                        },
                      ),
                  ]),
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
