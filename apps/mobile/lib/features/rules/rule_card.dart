import 'package:agnts_api/agnts_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api.dart';
import '../../l10n/app_localizations.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import '../../widgets/ui.dart';
import 'rules_logic.dart';
import 'rules_screen.dart' show rulesProvider;

/// One rule: its text, where Claude's review stands, and what to do next
/// (answer its questions, adopt a suggestion, retry a failed review, edit,
/// turn off, delete).
class RuleCard extends ConsumerStatefulWidget {
  const RuleCard({super.key, required this.rule, required this.canEdit, required this.onEdit});
  final Rule rule;
  final bool canEdit;
  final VoidCallback onEdit;

  @override
  ConsumerState<RuleCard> createState() => _RuleCardState();
}

class _RuleCardState extends ConsumerState<RuleCard> {
  // Draft answers per question index, kept while the list refreshes.
  final _answers = <int, TextEditingController>{};
  final _notes = <int, TextEditingController>{};
  bool _busy = false;

  Rule get r => widget.rule;
  List<RuleQuestion> get _open => r.questions.where((q) => q.answer == null || q.answer!.isEmpty).toList();
  List<RuleQuestion> get _answered => r.questions.where((q) => q.answer != null && q.answer!.isNotEmpty).toList();

  TextEditingController _answer(int i) => _answers.putIfAbsent(i, () => TextEditingController()..addListener(() => setState(() {})));
  TextEditingController _note(int i) => _notes.putIfAbsent(i, TextEditingController.new);

  @override
  void dispose() {
    for (final c in [..._answers.values, ..._notes.values]) {
      c.dispose();
    }
    super.dispose();
  }

  RulesApi get _api => ref.read(apiProvider)!.getRulesApi();

  Future<void> _run(Future<void> Function() action, String done) async {
    final l = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      await action();
      ref.invalidate(rulesProvider);
      if (mounted) showSnack(context, done);
    } catch (e) {
      if (mounted) showSnack(context, errorMessage(e, l.commonError));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<bool> _confirm(String title, String body, String action, {bool danger = false}) async {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.mobileCancel)),
          FilledButton(
            style: danger ? FilledButton.styleFrom(backgroundColor: c.bad) : null,
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(action),
          ),
        ],
      ),
    );
    return ok == true;
  }

  void _review() {
    final l = AppLocalizations.of(context);
    _run(() => _api.reviewRule(id: r.id), l.rulesQueued);
  }

  Future<void> _accept() async {
    final l = AppLocalizations.of(context);
    if (await _confirm(l.rulesAcceptTitle, l.rulesAcceptBody, l.rulesAccept)) _run(() => _api.acceptRule(id: r.id), l.rulesAccepted);
  }

  Future<void> _delete({bool dismiss = false}) async {
    final l = AppLocalizations.of(context);
    final ok = dismiss
        ? await _confirm(l.rulesDismiss, l.rulesDismissBody(r.title), l.rulesDismiss)
        : await _confirm(l.rulesDelete, l.rulesDeleteBody(r.title), l.rulesDelete, danger: true);
    if (ok) _run(() => _api.deleteRule(id: r.id), dismiss ? l.rulesDismissed : l.rulesDeleted);
  }

  void _enable(bool on) {
    final l = AppLocalizations.of(context);
    _run(
      () => _api.updateRule(
        id: r.id,
        ruleInput: RuleInput(title: r.title, body: r.body, repoId: r.repoId, enabled: on, kind: r.kind),
      ),
      on ? l.rulesTurnedOn : l.rulesTurnedOff,
    );
  }

  void _sendAnswers() {
    final l = AppLocalizations.of(context);
    final answers = [
      for (final q in _open)
        RuleAnswersAnswersInner(
          index: q.index,
          answer: _answer(q.index).text.trim(),
          note: _note(q.index).text.trim().isEmpty ? null : _note(q.index).text.trim(),
        ),
    ];
    _run(
      () => _api.answerRule(
        id: r.id,
        ruleAnswers: RuleAnswers(answers: answers),
      ),
      l.rulesAnswered,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final hint = TextStyle(fontSize: 13, color: c.ink3, height: 1.4);
    final h3 = TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: c.ink);
    final locked = _busy || !widget.canEdit;
    final reviewing = r.status == RuleStatus.pending || r.status == RuleStatus.analyzing;

    final body = <Widget>[
      // Head: title, scope and badges, the on/off switch.
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              r.title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: c.ink, height: 1.3),
            ),
          ),
          Switch.adaptive(value: r.enabled, onChanged: locked || r.status == RuleStatus.suggested ? null : _enable),
        ],
      ),
      const SizedBox(height: 6),
      Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          SourceChip(r.repoName ?? l.rulesGlobal),
          ToneBadge(ruleStatusLabel(l, r.status), ruleTone(r.status), small: true),
          if (r.kind == RuleKind.context) ToneBadge(l.rulesKindContext, Tone.gray, small: true),
          for (final (label, tone) in ruleBadges(l, r)) ToneBadge(label, tone, small: true),
          if (!r.enabled) ToneBadge(l.rulesOff, Tone.gray, small: true),
        ],
      ),
      const SizedBox(height: 10),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: c.bg,
          border: Border.all(color: c.line2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: SelectableText(r.body, style: TextStyle(fontSize: 14, color: c.ink2, height: 1.45)),
      ),
      const SizedBox(height: 10),
    ];

    if (r.status == RuleStatus.suggested) {
      body.addAll([
        HelpBox(
          r.sourceTicket == null && (r.reason ?? '').isNotEmpty ? '${l.rulesSuggestedFrom}: ${r.reason}' : l.rulesSuggestedFrom,
          child: r.sourceTicket == null
              ? null
              : GestureDetector(
                  onTap: () => context.push('/tickets/${r.sourceTicket}'),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: r.sourceTicket,
                          style: TextStyle(fontWeight: FontWeight.w700, color: c.primary),
                        ),
                        if ((r.reason ?? '').isNotEmpty)
                          TextSpan(
                            text: ': ${r.reason}',
                            style: TextStyle(color: c.ink2),
                          ),
                      ],
                    ),
                  ),
                ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton(onPressed: locked ? null : _review, child: Text(l.rulesAdopt)),
            OutlinedButton(
              onPressed: locked ? null : () => _run(() => _api.acceptRule(id: r.id), l.rulesAccepted),
              child: Text(l.rulesAdoptAsWritten),
            ),
            OutlinedButton(onPressed: locked ? null : () => _delete(dismiss: true), child: Text(l.rulesDismiss)),
          ],
        ),
        const SizedBox(height: 6),
        Text(l.rulesSuggestedHint, style: hint),
      ]);
    } else if (reviewing) {
      body.add(HelpBox(r.status == RuleStatus.analyzing ? l.rulesAnalyzing : l.rulesPending));
    } else if (r.status == RuleStatus.questions) {
      final open = _open;
      final left = open.where((q) => _answer(q.index).text.trim().isEmpty).length;
      body.addAll([
        Text(l.rulesQuestionsTitle(open.length), style: h3),
        const SizedBox(height: 2),
        Text(l.rulesQuestionsSub, style: hint),
        for (final (i, q) in open.indexed) ...[
          const SizedBox(height: 12),
          Text(q.text, style: TextStyle(fontSize: 14.5, color: c.ink, height: 1.4)),
          if (q.options.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final o in q.options)
                  FilterChipH(label: o, selected: _answer(q.index).text == o, onTap: () => _answer(q.index).text = o),
              ],
            ),
          ],
          const SizedBox(height: 8),
          TextField(
            controller: _answer(q.index),
            enabled: !locked,
            decoration: InputDecoration(hintText: l.rulesYourAnswer, labelText: l.rulesAnswerFor('${i + 1}')),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _note(q.index),
            enabled: !locked,
            minLines: 1,
            maxLines: 4,
            decoration: InputDecoration(hintText: l.rulesAddDetails),
          ),
        ],
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            FilledButton(onPressed: locked || left > 0 ? null : _sendAnswers, child: Text(l.rulesSendAnswers)),
            OutlinedButton(onPressed: locked ? null : _accept, child: Text(l.rulesAccept)),
          ],
        ),
        const SizedBox(height: 6),
        Text(left > 0 ? l.rulesQuestionsLeft(left) : l.rulesAllAnswered, style: hint),
      ]);
    } else if (r.status == RuleStatus.failed) {
      body.addAll([
        HelpBox(l.rulesFailed(r.error), tone: Tone.bad, copyable: r.error.isNotEmpty),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton(onPressed: locked ? null : _review, child: Text(l.rulesReviewAgain)),
            OutlinedButton(onPressed: locked ? null : _accept, child: Text(l.rulesAccept)),
          ],
        ),
      ]);
    } else if (r.status == RuleStatus.ready) {
      if (r.interpretation.isNotEmpty) {
        body.addAll([
          Text(l.rulesInterpretation, style: h3),
          const SizedBox(height: 4),
          SelectableText(r.interpretation),
          const SizedBox(height: 10),
        ]);
      }
      if (r.text != r.body) {
        body.addAll([Text(l.rulesClarified, style: h3), const SizedBox(height: 4), SelectableText(r.text), const SizedBox(height: 10)]);
      }
      if (r.interpretation.isEmpty) body.add(Text(l.rulesAsWritten, style: hint));
    }

    final answered = _answered;
    if (answered.isNotEmpty && r.status != RuleStatus.questions) {
      body.addAll([
        const SizedBox(height: 10),
        Fold(
          title: l.rulesAnswersTitle(answered.length),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final q in answered)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(q.text, style: hint),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: q.answer,
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                            if (q.note != null && q.note!.isNotEmpty) TextSpan(text: '. ${q.note}'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ]);
    }

    // Foot: when, and the tools.
    final when = r.analyzedAt != null ? l.rulesReviewedAgo(_ago(l, r.analyzedAt!)) : l.rulesAddedAgo(_ago(l, r.createdAt));
    body.addAll([
      const SizedBox(height: 10),
      Row(
        children: [
          Expanded(child: Text(when, style: hint)),
          if (widget.canEdit) ...[
            if (r.status == RuleStatus.ready || r.status == RuleStatus.questions)
              TextButton(onPressed: _busy ? null : _review, child: Text(l.rulesReviewAgain)),
            TextButton(onPressed: _busy ? null : widget.onEdit, child: Text(l.rulesEdit)),
            if (r.status != RuleStatus.suggested)
              TextButton(
                onPressed: _busy ? null : () => _delete(),
                style: TextButton.styleFrom(foregroundColor: c.badInk),
                child: Text(l.rulesDelete),
              ),
          ],
        ],
      ),
    ]);

    return Opacity(
      opacity: r.enabled ? 1 : 0.72,
      child: HCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: body),
      ),
    );
  }
}

String _ago(AppLocalizations l, DateTime at) {
  final d = DateTime.now().difference(at);
  return d.inMinutes < 1 ? l.mmoreJustNow : l.mmoreAgo(shortDuration(d));
}
