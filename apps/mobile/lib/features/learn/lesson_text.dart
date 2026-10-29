import 'package:flutter/material.dart';
import 'package:agnts_api/agnts_api.dart';

import '../../l10n/app_localizations.dart';
import '../../theme.dart';

/// A lesson's category in the user's language.
String categoryLabel(AppLocalizations l, LessonCategory c) => switch (c) {
  LessonCategory.pattern => l.learnCategory_pattern,
  LessonCategory.architecture => l.learnCategory_architecture,
  LessonCategory.algorithm => l.learnCategory_algorithm,
  LessonCategory.library_ => l.learnCategory_library,
  LessonCategory.language => l.learnCategory_language,
  LessonCategory.testing => l.learnCategory_testing,
  LessonCategory.security => l.learnCategory_security,
  LessonCategory.performance => l.learnCategory_performance,
  LessonCategory.tooling => l.learnCategory_tooling,
  LessonCategory.other => l.learnCategory_other,
};

String levelLabel(AppLocalizations l, LessonLevel v) => switch (v) {
  LessonLevel.beginner => l.learnLevel_beginner,
  LessonLevel.intermediate => l.learnLevel_intermediate,
  LessonLevel.advanced => l.learnLevel_advanced,
};

/// Splits a lesson's plain text into paragraphs and code blocks (fenced
/// with ``` or indented as a whole), as the admin panel does.
List<({bool code, String text})> lessonBlocks(String text) {
  final out = <({bool code, String text})>[];
  void prose(String s) {
    for (final p in s.split(RegExp(r'\n\s*\n'))) {
      if (p.trim().isEmpty) continue;
      final code = p.split('\n').every((l) => l.trim().isEmpty || RegExp(r'^( {4}|\t)').hasMatch(l));
      out.add((code: code, text: code ? p.replaceAll(RegExp(r'^( {4}|\t)', multiLine: true), '') : p.trim()));
    }
  }

  var last = 0;
  for (final m in RegExp(r'```[^\n]*\n([\s\S]*?)```').allMatches(text)) {
    prose(text.substring(last, m.start));
    out.add((code: true, text: m.group(1)!.replaceFirst(RegExp(r'\n$'), '')));
    last = m.end;
  }
  prose(text.substring(last));
  return out;
}

/// Paragraphs and code blocks of a lesson's text.
class LessonText extends StatelessWidget {
  const LessonText(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    final c = Agnts.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final b in lessonBlocks(text))
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: b.code
                ? Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: c.code, borderRadius: BorderRadius.circular(12)),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Text(
                        b.text,
                        style: TextStyle(fontFamily: AgntsFonts.mono, fontSize: 12.5, height: 1.5, color: c.codeInk),
                      ),
                    ),
                  )
                : Text(b.text, style: TextStyle(fontSize: 15, height: 1.5, color: c.ink)),
          ),
      ],
    );
  }
}
