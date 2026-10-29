import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:agnts_api/agnts_api.dart';

import '../../core/api.dart';
import '../../core/data.dart';
import '../../l10n/app_localizations.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import '../../widgets/ui.dart';
import 'lesson_text.dart';

/// One lesson: what it is, why the change needed it, where to look, a quiz
/// and further reading, with "Mark as learned" at the bottom.
class LessonScreen extends ConsumerStatefulWidget {
  const LessonScreen({super.key, required this.id});
  final int id;

  @override
  ConsumerState<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends ConsumerState<LessonScreen> {
  bool _busy = false;

  Future<void> _toggle(Lesson x) async {
    final l = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      final api = ref.read(apiProvider)!.getLearnApi();
      x.learnedAt == null ? await api.markLessonLearned(id: x.id) : await api.unmarkLessonLearned(id: x.id);
      ref.invalidate(lessonProvider(x.id));
      ref.invalidate(lessonsProvider);
      ref.invalidate(ticketLessonsProvider(x.ticketKey));
      if (mounted && x.learnedAt == null) showSnack(context, l.learnMarkedLearned);
    } catch (e) {
      if (mounted) showSnack(context, errorMessage(e, l.commonError));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final lesson = ref.watch(lessonProvider(widget.id));
    final x = lesson.value;
    return Scaffold(
      backgroundColor: c.bg,
      appBar: DetailBar(backLabel: l.navBack, onBack: () => context.canPop() ? context.pop() : context.go('/learn')),
      body: AsyncBody<Lesson>(
        value: lesson,
        onRefresh: () async {
          ref.invalidate(lessonProvider(widget.id));
          await ref.read(lessonProvider(widget.id).future);
        },
        builder: (x) => ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      SourceChip(categoryLabel(l, x.category)),
                      SourceChip(levelLabel(l, x.level), task: true),
                      Text(l.learnReadTime(x.readMinutes), style: TextStyle(fontSize: 13, color: c.ink3)),
                      if (x.learnedAt != null) ToneBadge(l.learnLearned, Tone.ok, small: true),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(x.title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(height: 1.15)),
                  const SizedBox(height: 8),
                  Text(x.summary, style: TextStyle(fontSize: 15, height: 1.45, color: c.ink2)),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => context.push('/tickets/${x.ticketKey}'),
                    child: Text('${x.repoName} · ${l.learnFromTicket(x.ticketKey)}', style: TextStyle(fontSize: 13.5, color: c.primary)),
                  ),
                ],
              ),
            ),
            if (x.explanation.isNotEmpty) Section(title: l.learnWhatTitle, child: LessonText(x.explanation)),
            if (x.whyHere.isNotEmpty) Section(title: l.learnWhyTitle, child: LessonText(x.whyHere)),
            if (x.refs.isNotEmpty)
              Section(
                title: l.learnWhereTitle,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final r in x.refs)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SelectableText(
                              r.line == null ? r.path : '${r.path}:${r.line}',
                              style: TextStyle(fontFamily: AgntsFonts.mono, fontSize: 12.5, color: c.ink),
                            ),
                            if (r.note != null && r.note!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(r.note!, style: TextStyle(fontSize: 14, color: c.ink2)),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            if (x.quiz.isNotEmpty)
              Section(
                title: l.learnQuizTitle,
                child: _Quiz(key: ValueKey(x.id), quiz: x.quiz),
              ),
            if (x.reading.isNotEmpty)
              Section(
                title: l.learnReadingTitle,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final k in x.reading)
                      InkWell(
                        // No browser plugin in the app: copy the link to open it elsewhere.
                        onTap: () async {
                          await Clipboard.setData(ClipboardData(text: k.url));
                          if (context.mounted) showSnack(context, l.mdetailCopied);
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                k.title,
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: c.primary),
                              ),
                              Text(
                                k.url,
                                style: TextStyle(fontFamily: AgntsFonts.mono, fontSize: 12, color: c.ink3),
                              ),
                            ],
                          ),
                        ),
                      ),
                    Text(l.learnReadingNote, style: TextStyle(fontSize: 13, color: c.ink3)),
                  ],
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: x == null
          ? null
          : ActionBar(
              children: [
                Expanded(
                  child: x.learnedAt == null
                      ? FilledButton(onPressed: _busy ? null : () => _toggle(x), child: Text(l.learnMarkLearned))
                      : OutlinedButton(onPressed: _busy ? null : () => _toggle(x), child: Text(l.learnMarkUnlearned)),
                ),
              ],
            ),
    );
  }
}

/// The quiz: one pick per question, then right or wrong with why.
class _Quiz extends StatefulWidget {
  const _Quiz({super.key, required this.quiz});
  final List<QuizQuestion> quiz;

  @override
  State<_Quiz> createState() => _QuizState();
}

class _QuizState extends State<_Quiz> {
  final Map<int, int> _picked = {};

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final right = [
      for (final (i, q) in widget.quiz.indexed)
        if (_picked[i] == q.answer) i,
    ].length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l.learnQuizSub, style: TextStyle(fontSize: 14, color: c.ink3)),
        for (final (qi, q) in widget.quiz.indexed) ...[
          const SizedBox(height: 14),
          Text(
            '${qi + 1}. ${q.question}',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, height: 1.4, color: c.ink),
          ),
          const SizedBox(height: 8),
          for (final (oi, o) in q.options.indexed) _option(context, qi, oi, o, q.answer),
          if (_picked.containsKey(qi))
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                [if (_picked[qi] == q.answer) l.learnCorrect else l.learnWrong, if (q.explanation != null) q.explanation!].join(' '),
                style: TextStyle(fontSize: 14, height: 1.4, color: _picked[qi] == q.answer ? c.okInk : c.badInk),
              ),
            ),
        ],
        if (_picked.length == widget.quiz.length) ...[
          const SizedBox(height: 14),
          Row(
            children: [
              ToneBadge(l.learnScore('$right', '${widget.quiz.length}'), right == widget.quiz.length ? Tone.ok : Tone.warn),
              const Spacer(),
              TextButton(onPressed: () => setState(_picked.clear), child: Text(l.learnRetry)),
            ],
          ),
        ],
      ],
    );
  }

  Widget _option(BuildContext context, int qi, int oi, String text, int answer) {
    final c = Agnts.of(context);
    final picked = _picked[qi];
    final done = picked != null;
    final (Color bg, Color fg, Color border) = !done
        ? (c.surface, c.ink, c.line)
        : oi == answer
        ? (c.okSoft, c.okInk, c.ok)
        : picked == oi
        ? (c.badSoft, c.badInk, c.bad)
        : (c.surface, c.ink3, c.line);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Semantics(
        button: true,
        selected: picked == oi,
        child: Material(
          color: bg,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: border),
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: done ? null : () => setState(() => _picked[qi] = oi),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Text(text, style: TextStyle(fontSize: 14.5, color: fg)),
            ),
          ),
        ),
      ),
    );
  }
}
