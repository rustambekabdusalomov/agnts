import 'package:flutter/material.dart';
import 'package:agnts_api/agnts_api.dart';

import '../../l10n/app_localizations.dart';
import '../../theme.dart';
import '../../widgets/ui.dart';

/// agnts's own code review of a result waiting for review: advice beside the
/// human review that never blocks approval. Findings with a suggestion can be
/// added to [feedback], the text the "Request changes" sheet starts with.
class CodeReviewCard extends StatelessWidget {
  const CodeReviewCard({super.key, required this.detail, required this.feedback, required this.busy, required this.onRun, this.onFollowUp});
  final TicketDetail detail;
  final TextEditingController feedback;
  final bool busy;

  /// Queues a (re-)review.
  final VoidCallback onRun;

  /// Suggests finding [index] as a follow-up ticket, for work outside this change.
  final void Function(int index)? onFollowUp;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final t = detail.ticket;
    final state = t.reviewState ?? TicketReviewStateEnum.none;
    final review = detail.review;
    final current = review != null && review.revision == t.revision;
    final showReview = current && state != TicketReviewStateEnum.pending && state != TicketReviewStateEnum.running;

    Widget status(String text, {Widget? lead, Tone? tone}) => Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (lead != null) Padding(padding: const EdgeInsets.only(top: 2, right: 8), child: lead),
            Expanded(child: Text(text, style: TextStyle(fontSize: 14, height: 1.4, color: tone == null ? c.ink3 : tone.ink(c)))),
          ]),
        );
    Widget runButton(String label) => Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 4), minimumSize: const Size(0, 36)),
            onPressed: busy ? null : onRun,
            child: Text(label),
          ),
        );

    final body = <Widget>[];
    if (showReview) {
      body.addAll(_review(context, review));
    } else {
      switch (state) {
        case TicketReviewStateEnum.pending:
          body.add(status(l.reviewPending));
        case TicketReviewStateEnum.running:
          body.add(status(l.reviewRunning,
              lead: SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: c.primary))));
        case TicketReviewStateEnum.failed:
          body.addAll([status(l.reviewFailed, tone: Tone.bad), runButton(l.reviewRunAgain)]);
        case TicketReviewStateEnum.none:
        case TicketReviewStateEnum.done:
          if (review != null) {
            body.addAll([status(l.reviewStale(review.revision.toString())), runButton(l.reviewRunAgain)]);
          } else {
            body.add(runButton(l.reviewRun));
          }
      }
    }

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: HCard(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
        radius: 16,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
              child: Text(isReportKind(t.kind) ? l.reviewReportTitle : l.reviewTitle,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: c.ink)),
            ),
            if (showReview) ToneBadge(_verdictLabel(l, review.verdict), _verdictTone(review.verdict), small: true),
          ]),
          const SizedBox(height: 2),
          Text(l.reviewSub, style: TextStyle(fontSize: 12.5, height: 1.4, color: c.ink3)),
          ...body,
        ]),
      ),
    );
  }

  List<Widget> _review(BuildContext context, CodeReview r) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final withSuggestion = [for (final f in r.findings) if (_line(f) != null) _line(f)!];
    return [
      if (r.summary.isNotEmpty)
        Padding(padding: const EdgeInsets.only(top: 10), child: Text(r.summary, style: TextStyle(fontSize: 15, height: 1.45, color: c.ink))),
      Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Text(l.reviewModel(_modelName(r.model), r.modelReason), style: TextStyle(fontSize: 12.5, height: 1.4, color: c.ink3)),
      ),
      if (r.findings.isEmpty)
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Row(children: [
            HIcon('check', size: 16, stroke: 2.6, color: c.okInk),
            const SizedBox(width: 8),
            Expanded(child: Text(l.reviewNoFindings, style: TextStyle(fontSize: 14, color: c.okInk, fontWeight: FontWeight.w700))),
          ]),
        )
      else ...[
        Padding(
          padding: const EdgeInsets.only(top: 14, bottom: 2),
          child: Row(children: [
            Expanded(child: Text(l.reviewFindings(r.findings.length), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: c.ink3))),
            if (withSuggestion.length > 1)
              ListenableBuilder(
                listenable: feedback,
                builder: (context, _) {
                  final left = withSuggestion.where((x) => !feedback.text.contains(x)).toList();
                  if (left.isEmpty) return const SizedBox.shrink();
                  return TextButton(
                    style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 4), minimumSize: const Size(0, 32)),
                    onPressed: busy ? null : () => _append(left),
                    child: Text(l.reviewAddAll),
                  );
                },
              ),
          ]),
        ),
        for (final (i, f) in r.findings.indexed) _finding(context, f, index: i),
      ],
      if (r.strengths.isNotEmpty) ...[
        Padding(
          padding: const EdgeInsets.only(top: 14, bottom: 6),
          child: Text(l.reviewStrengths, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: c.ink3)),
        ),
        for (final s in r.strengths)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('•  ', style: TextStyle(color: c.ink3)),
              Expanded(child: Text(s, style: TextStyle(fontSize: 14, height: 1.4, color: c.ink2))),
            ]),
          ),
      ],
      Align(
        alignment: Alignment.centerLeft,
        child: TextButton(
          style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 4), minimumSize: const Size(0, 36)),
          onPressed: busy ? null : onRun,
          child: Text(l.reviewRunAgain),
        ),
      ),
    ];
  }

  Widget _finding(BuildContext context, Finding f, {required int index}) {
    final first = index == 0;
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final loc = _location(f);
    final line = _line(f);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(border: first ? null : Border(top: BorderSide(color: c.line2))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Wrap(spacing: 8, runSpacing: 4, crossAxisAlignment: WrapCrossAlignment.center, children: [
          ToneBadge(_severityLabel(l, f.severity), _severityTone(f.severity), small: true),
          Text(_categoryLabel(l, f.category), style: TextStyle(fontSize: 12.5, color: c.ink3)),
        ]),
        const SizedBox(height: 6),
        Text(f.title, style: TextStyle(fontSize: 14.5, height: 1.35, fontWeight: FontWeight.w700, color: c.ink)),
        if (loc.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(loc, style: TextStyle(fontFamily: AgntsFonts.mono, fontSize: 12, color: c.ink3)),
          ),
        if ((f.detail ?? '').isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(f.detail!, style: TextStyle(fontSize: 14, height: 1.4, color: c.ink2)),
          ),
        if ((f.suggestion ?? '').isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text.rich(TextSpan(style: TextStyle(fontSize: 14, height: 1.4, color: c.ink2), children: [
              TextSpan(text: '${l.reviewSuggestion}: ', style: TextStyle(fontWeight: FontWeight.w700, color: c.ink)),
              TextSpan(text: f.suggestion),
            ])),
          ),
        if (line != null)
          ListenableBuilder(
            listenable: feedback,
            builder: (context, _) {
              if (feedback.text.contains(line)) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(children: [
                    HIcon('check', size: 15, stroke: 2.6, color: c.okInk),
                    const SizedBox(width: 6),
                    Text(l.reviewAdded, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: c.okInk)),
                  ]),
                );
              }
              return Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 4), minimumSize: const Size(0, 32)),
                  onPressed: busy ? null : () => _append([line]),
                  child: Text(l.reviewAddToFeedback),
                ),
              );
            },
          ),
        if (onFollowUp != null)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 4), minimumSize: const Size(0, 32)),
              onPressed: busy ? null : () => onFollowUp!(index),
              child: Text(l.followUpsFromFinding),
            ),
          ),
      ]),
    );
  }

  /// Appends [lines] to the feedback, each on its own line.
  void _append(List<String> lines) {
    var text = feedback.text;
    for (final x in lines) {
      if (text.contains(x)) continue;
      if (text.isNotEmpty && !text.endsWith('\n')) text += '\n';
      text += x;
    }
    feedback.value = TextEditingValue(text: text, selection: TextSelection.collapsed(offset: text.length));
  }
}

/// `file:line`, `file`, or empty.
String _location(Finding f) {
  final file = f.file ?? '';
  if (file.isEmpty) return '';
  return f.line == null ? file : '$file:${f.line}';
}

/// The feedback line for a finding with a suggestion, as the admin panel
/// writes it: `- file:line: title. suggestion`.
String? _line(Finding f) {
  final s = (f.suggestion ?? '').trim();
  if (s.isEmpty) return null;
  final loc = _location(f);
  return '- ${loc.isEmpty ? '' : '$loc: '}${f.title.trim()}. $s';
}

String _modelName(Model m) => switch (m) {
      Model.haiku => 'Haiku',
      Model.sonnet => 'Sonnet',
      Model.opus => 'Opus',
    };

String _verdictLabel(AppLocalizations l, CodeReviewVerdictEnum v) => switch (v) {
      CodeReviewVerdictEnum.looksGood => l.reviewVerdict_looks_good,
      CodeReviewVerdictEnum.hasConcerns => l.reviewVerdict_has_concerns,
      CodeReviewVerdictEnum.needsChanges => l.reviewVerdict_needs_changes,
    };

Tone _verdictTone(CodeReviewVerdictEnum v) => switch (v) {
      CodeReviewVerdictEnum.looksGood => Tone.ok,
      CodeReviewVerdictEnum.hasConcerns => Tone.warn,
      CodeReviewVerdictEnum.needsChanges => Tone.bad,
    };

String _severityLabel(AppLocalizations l, FindingSeverityEnum s) => switch (s) {
      FindingSeverityEnum.blocker => l.reviewSev_blocker,
      FindingSeverityEnum.major => l.reviewSev_major,
      FindingSeverityEnum.minor => l.reviewSev_minor,
      FindingSeverityEnum.nit => l.reviewSev_nit,
    };

Tone _severityTone(FindingSeverityEnum s) => switch (s) {
      FindingSeverityEnum.blocker => Tone.bad,
      FindingSeverityEnum.major => Tone.warn,
      FindingSeverityEnum.minor => Tone.info,
      FindingSeverityEnum.nit => Tone.gray,
    };

String _categoryLabel(AppLocalizations l, FindingCategoryEnum c) => switch (c) {
      FindingCategoryEnum.correctness => l.reviewCat_correctness,
      FindingCategoryEnum.security => l.reviewCat_security,
      FindingCategoryEnum.performance => l.reviewCat_performance,
      FindingCategoryEnum.tests => l.reviewCat_tests,
      FindingCategoryEnum.rules => l.reviewCat_rules,
      FindingCategoryEnum.architecture => l.reviewCat_architecture,
      FindingCategoryEnum.scope => l.reviewCat_scope,
      FindingCategoryEnum.maintainability => l.reviewCat_maintainability,
      FindingCategoryEnum.accuracy => l.reviewCat_accuracy,
      FindingCategoryEnum.completeness => l.reviewCat_completeness,
      FindingCategoryEnum.other => l.reviewCat_other,
    };
