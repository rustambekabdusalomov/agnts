import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:agnts_api/agnts_api.dart';

import '../../theme.dart';
import '../tickets/diff_highlight.dart';
import '../tickets/diff_lines.dart';

// Code and diffs for the repository screens: a commit's changed files and
// the code browser's open file, highlighted as the admin panel's DiffView.vue
// and CodeTab.vue do.

const _codeAdd = Color(0x382EA067); // rgba(46,160,103,.22)
const _codeDel = Color(0x3DD64034); // rgba(214,64,52,.24)
const _codeHunk = Color(0x2E7D96EB); // rgba(125,150,235,.18)
const _hunkInk = Color(0xFFB9C6F5);

/// Lines shown at most, so a huge file or diff stays quick to lay out.
const maxCodeLines = 2000;

/// A file's lines as numbered context lines (a leading space, as in a diff),
/// so [highlightDiff] can colour them. A trailing newline adds no line.
List<DiffLine> codeLines(String content) {
  final ls = content.split('\n');
  if (ls.length > 1 && ls.last.isEmpty) ls.removeLast();
  return [for (final (i, t) in ls.indexed) (text: ' $t', kind: DiffKind.plain, old: null, neu: i + 1)];
}

/// One changed file: its path and counts, opening to its diff.
class RepoFileDiff extends StatefulWidget {
  const RepoFileDiff({super.key, required this.file, this.initiallyOpen = false});
  final FileChange file;
  final bool initiallyOpen;

  @override
  State<RepoFileDiff> createState() => _RepoFileDiffState();
}

class _RepoFileDiffState extends State<RepoFileDiff> {
  late bool _open = widget.initiallyOpen;

  @override
  Widget build(BuildContext context) {
    final c = Agnts.of(context);
    final f = widget.file;
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: c.surface,
        border: Border.all(color: c.line),
        borderRadius: BorderRadius.circular(14),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: f.diff.isEmpty ? null : () => setState(() => _open = !_open),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      f.path,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontFamily: AgntsFonts.mono, fontSize: 12.5, color: c.ink),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '+${f.add}',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: c.okInk),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '−${f.del}',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: c.badInk),
                  ),
                ],
              ),
            ),
          ),
          if (_open && f.diff.isNotEmpty) CodeBlock(lines: numberDiff(f.diff), path: f.path, diff: true),
        ],
      ),
    );
  }
}

/// Numbered, highlighted lines on the dark code background. For a diff
/// both the old and new numbers show and rows are tinted by kind; for a
/// file only its line numbers. Long lines scroll sideways while the
/// numbers stay put.
class CodeBlock extends StatefulWidget {
  const CodeBlock({super.key, required this.lines, required this.path, this.diff = false});
  final List<DiffLine> lines;
  final String path;
  final bool diff;

  @override
  State<CodeBlock> createState() => _CodeBlockState();
}

class _CodeBlockState extends State<CodeBlock> {
  late List<DiffLine> _lines;
  // Highlighted spans per line (null: plain text), once ready.
  List<List<CodeSpan>?>? _spans;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(CodeBlock old) {
    super.didUpdateWidget(old);
    if (!identical(old.lines, widget.lines) || old.path != widget.path) _load();
  }

  Future<void> _load() async {
    final lines = _lines = widget.lines.take(maxCodeLines).toList();
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
    final diff = widget.diff;
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
    return Container(
      color: c.code,
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border(right: BorderSide(color: const Color(0xFF7F7F7F).withValues(alpha: 0.25))),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final l in lines)
                  Container(
                    color: _bg(l.kind),
                    padding: const EdgeInsets.only(left: 4, right: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (diff) ...[num(l.old), const SizedBox(width: 6)],
                        num(l.neu),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, box) => SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: box.maxWidth),
                  child: IntrinsicWidth(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (final (i, l) in lines.indexed)
                          Container(
                            padding: const EdgeInsets.only(left: 10, right: 14),
                            color: _bg(l.kind),
                            child: _line(l, _spans?[i], style.copyWith(color: c.codeInk)),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _line(DiffLine l, List<CodeSpan>? spans, TextStyle style) {
    // A file's lines carry a leading space only for the highlighter.
    final lead = widget.diff ? l.text[0] : '';
    final text = widget.diff ? l.text : l.text.substring(1);
    if (spans == null) {
      return Text(text.isEmpty ? ' ' : text, softWrap: false, style: l.kind == DiffKind.hunk ? style.copyWith(color: _hunkInk) : style);
    }
    return Text.rich(
      TextSpan(
        text: lead,
        children: [for (final sp in spans) TextSpan(text: sp.text, style: styleFor(sp.scope))],
      ),
      softWrap: false,
      style: style,
    );
  }
}
