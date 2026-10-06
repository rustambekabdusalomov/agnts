import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:agnts_api/agnts_api.dart';

import '../../core/api.dart';
import '../../core/data.dart';
import '../learn/ticket_lessons.dart';
import 'code_review.dart';
import 'diff_highlight.dart';
import 'diff_lines.dart';
import 'follow_ups.dart';
import 'kinds.dart';
import 'preview_shots.dart';
import 'relations.dart';
import 'spend.dart';
import '../../l10n/app_localizations.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import '../../widgets/ui.dart';

/// One ticket (scrDetail in mobile.html): header, the six-stop progress
/// track, a block for the current state, folds for answers and history, and
/// a sticky action bar with whatever the ticket needs from you.
class TicketScreen extends ConsumerStatefulWidget {
  const TicketScreen({super.key, required this.ticketKey});
  final String ticketKey;

  @override
  ConsumerState<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends ConsumerState<TicketScreen> {
  // Per question: the picked option pill, and the details / own answer text.
  final Map<int, String?> _picked = {};
  final Map<int, TextEditingController> _notes = {};
  final _feedback = TextEditingController();
  // Preview screenshots the feedback points at.
  final _feedbackShots = ValueNotifier<List<FeedbackShot>>(const []);
  bool _busy = false;
  bool _descOpen = false;
  // Reports reach the Jira issue only when the reviewer ticks this.
  bool _postReport = false;

  @override
  void dispose() {
    for (final c in _notes.values) {
      c.dispose();
    }
    _feedback.dispose();
    _feedbackShots.dispose();
    super.dispose();
  }

  TextEditingController _noteFor(Question q) => _notes.putIfAbsent(q.id, () {
        final a = q.answer;
        if (a != null && q.options.contains(a)) {
          _picked[q.id] = a;
          return TextEditingController(text: q.note);
        }
        return TextEditingController(text: a ?? '');
      });

  /// The answer sent for [q]: the picked option, else the typed text.
  String _answerOf(Question q) {
    final note = _noteFor(q).text.trim();
    return _picked[q.id] ?? note;
  }

  /// The details sent with a picked option (null when the text is the answer).
  String? _noteOf(Question q) {
    final note = _noteFor(q).text.trim();
    return _picked[q.id] != null && note.isNotEmpty ? note : null;
  }

  TicketsApi get _tickets => ref.read(apiProvider)!.getTicketsApi();

  /// Runs [action], then refreshes the ticket; false when it failed.
  Future<bool> _run(Future<void> Function() action) async {
    final l = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      await action();
      ref.invalidate(ticketProvider(widget.ticketKey));
      ref.invalidate(dashboardProvider);
      return true;
    } catch (e) {
      if (mounted) showSnack(context, errorMessage(e, l.ticketConflict));
      return false;
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// agnts's code review card; queues a (re-)review like the other actions.
  Widget _codeReview(TicketDetail d) => CodeReviewCard(
        detail: d,
        feedback: _feedback,
        busy: _busy,
        onRun: () => _run(() => _tickets.reviewTicket(key: d.ticket.key)),
        onFollowUp: (i) => _run(() async {
          await _tickets.followUpFromFinding(key: d.ticket.key, index: i);
          if (mounted) showSnack(context, AppLocalizations.of(context).followUpsFromFindingDone);
        }),
      );

  /// agnts's preview card (screenshots of the running app), for tickets
  /// whose repository can be previewed or that already have a preview.
  Widget _preview(TicketDetail d) {
    final t = d.ticket;
    final state = t.previewState ?? TicketPreviewStateEnum.none;
    if (d.preview == null && t.canPreview != true && state == TicketPreviewStateEnum.none) return const SizedBox.shrink();
    return PreviewCard(
      detail: d,
      feedback: _feedback,
      shots: _feedbackShots,
      busy: _busy,
      onRun: (compare) => _run(() => _tickets.previewTicket(key: t.key, previewInput: PreviewInput(compare: compare))),
    );
  }

  Future<bool> _confirm(String text) async {
    final l = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        content: Text(text),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: Text(l.mobileCancel)),
          FilledButton(onPressed: () => Navigator.pop(c, true), child: Text(l.mobileConfirm)),
        ],
      ),
    );
    return ok ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final detail = ref.watch(ticketProvider(widget.ticketKey));
    return Scaffold(
      backgroundColor: c.bg,
      appBar: DetailBar(
        backLabel: l.navBack,
        title: widget.ticketKey,
        onBack: () => context.canPop() ? context.pop() : context.go('/tickets'),
      ),
      body: AsyncBody<TicketDetail>(
        value: detail,
        onRefresh: () async {
          ref.invalidate(ticketEventsProvider(widget.ticketKey));
          ref.invalidate(ticketProvider(widget.ticketKey));
          await ref.read(ticketProvider(widget.ticketKey).future);
        },
        builder: (d) => ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            _header(context, d.ticket),
            _Track(ticket: d.ticket, history: d.history ?? const []),
            _stage(context, d),
            _folds(context, d),
          ],
        ),
      ),
      bottomNavigationBar: detail.value == null ? null : _actionBar(context, detail.value!),
    );
  }

  // ---- Header (.d-head) ----

  Widget _header(BuildContext context, Ticket t) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final isTask = t.source_ == TicketSource_Enum.local;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        DefaultTextStyle.merge(
          style: TextStyle(fontSize: 13, color: c.ink3),
          child: Wrap(spacing: 8, runSpacing: 6, crossAxisAlignment: WrapCrossAlignment.center, children: [
            StateBadge(t.state, kind: t.kind),
            SourceChip(isTask ? l.ticketsSourceTask : l.ticketsSourceJira, task: isTask),
            KindChip(t),
            if (t.repoName != null && t.repoName!.isNotEmpty) Text(t.repoName!),
            if (t.priority.isNotEmpty) Text(t.priority),
            if (t.revision > 0) Text(l.ticketRevision(t.revision.toString())),
          ]),
        ),
        const SizedBox(height: 8),
        Text(t.title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(height: 1.15)),
        if (t.description.isNotEmpty) ...[
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => setState(() => _descOpen = !_descOpen),
            child: Text(
              t.description,
              maxLines: _descOpen ? null : 6,
              overflow: _descOpen ? null : TextOverflow.ellipsis,
              style: TextStyle(fontSize: 15, color: c.ink2, height: 1.45),
            ),
          ),
        ],
        if (t.branch.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text('${l.ticketBranch}: ${t.branch}', style: TextStyle(fontFamily: AgntsFonts.mono, fontSize: 12.5, color: c.ink3)),
          ),
        if (t.prUrl.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: SelectableText(t.prUrl, style: TextStyle(fontFamily: AgntsFonts.mono, fontSize: 12.5, color: c.primary)),
          ),
        if (t.parentKey != null && t.parentKey!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: GestureDetector(
              onTap: () => context.push('/tickets/${t.parentKey}'),
              child: Text('${l.implementImplements} ${t.parentKey}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: c.primary)),
            ),
          ),
        if (t.followUpOf != null && t.followUpOf!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: GestureDetector(
              onTap: () => context.push('/tickets/${t.followUpOf}'),
              child: Text('${l.followUpsFollowUpOf} ${t.followUpOf}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: c.primary)),
            ),
          ),
      ]),
    );
  }

  // ---- The state's block (dStage) ----

  Widget _stage(BuildContext context, TicketDetail d) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final t = d.ticket;
    final report = isReportKind(t.kind);
    String rev(String title) => t.revision > 0 ? l.ticketRevisionSuffix(title, t.revision.toString()) : title;
    final children = <Widget>[];
    switch (t.state) {
      case TicketState.new_:
        children.addAll([
          _H2(l.ticketQueuedTitle),
          _Sub(t.held == true ? l.ticketHeldSub : (report ? l.ticketQueuedSubReport : l.ticketQueuedSub)),
          KindPicker(t),
        ]);
      case TicketState.analyzing:
        children.addAll([
          _H2(t.repoId == null ? l.ticketAnalyzingTitleNoRepo : l.ticketAnalyzingTitle),
          _Sub(t.repoId == null ? l.ticketAnalyzingSubNoRepo : l.ticketAnalyzingSub(t.repoName ?? '')),
          _H3(l.ticketLog),
          _liveLog(context, true),
        ]);
      case TicketState.waitingForAnswers:
        children.addAll([
          _H2(l.ticketQuestionsTitle(d.questions.length)),
          _Sub(l.ticketQuestionsSub),
          if (d.analysis != null) _analysisFold(context, d.analysis!),
          for (final q in d.questions) _questionCard(context, q),
          KindPicker(t),
        ]);
      case TicketState.coding when t.blockedBy?.isNotEmpty ?? false:
        children.addAll([
          _H2(l.relationsWaitingTitle),
          _Sub(l.relationsWaitingSub),
          const SizedBox(height: 8),
          WaitingBlock(t.blockedBy!.toList()),
        ]);
      case TicketState.coding:
      case TicketState.testing:
        children.addAll([
          _H2(rev(report ? l.ticketWritingTitle : t.state == TicketState.coding ? l.ticketCodingTitle : l.ticketTestingTitle)),
          _Sub(report ? l.ticketWritingSub : l.ticketCodingSub(t.branch)),
          const SizedBox(height: 8),
          _runFacts(context, d),
          _H3(l.ticketLog),
          _liveLog(context, true),
        ]);
      case TicketState.waitingForReview when report:
        children.addAll([_H2(rev(l.ticketReviewReportTitle)), ..._reviewReport(context, d)]);
      case TicketState.waitingForReview:
        children.addAll([_H2(rev(l.ticketReviewTitle)), ..._review(context, d)]);
      case TicketState.pushing:
        children.addAll([
          _H2(report ? l.ticketDeliveringTitle : l.ticketPushingTitle),
          _Sub(report ? l.ticketDeliveringSub : l.ticketPushingSub),
          _H3(l.ticketLog),
          _liveLog(context, true),
        ]);
      case TicketState.done when report:
        children.addAll([
          _H2(l.ticketDoneReportTitle),
          const SizedBox(height: 8),
          HelpBox(t.postReport == true ? l.ticketDoneReportPosted(t.key) : l.ticketDoneReport, tone: Tone.ok),
          if (t.kind == TicketKind.plan || t.kind == TicketKind.bug) ImplementReport(t, childKey: d.childKey),
          if (d.result?.report != null) ...[_H3(l.ticketReport), ReportMarkdown(d.result!.report!)],
        ]);
      case TicketState.done:
        final toMain = t.afterApprove == TicketAfterApproveEnum.main && t.source_ == TicketSource_Enum.local;
        final text = toMain
            ? l.ticketDoneMain(t.repoName ?? '')
            : t.prNumber != null
                ? l.ticketDonePr(t.prNumber.toString(), t.branch)
                : l.ticketDoneTitle;
        children.add(HelpBox(text, tone: Tone.ok));
        if (t.mergedAt != null) {
          children.add(Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(l.ticketMergedAt(_when(context, t.mergedAt!)), style: TextStyle(fontSize: 14, color: c.ink3)),
          ));
        } else if (t.prUrl.isNotEmpty) {
          children.addAll([
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: _busy ? null : () => _run(() => _tickets.markTicketMerged(key: t.key)),
              child: Text(l.relationsMarkMerged),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(l.relationsMarkMergedHint, style: TextStyle(fontSize: 13, color: c.ink3)),
            ),
          ]);
        }
        children.add(TicketLessons(t));
      case TicketState.rejected:
        children.addAll([_H2(l.ticketRejectedTitle), _Sub(l.ticketRejectedSub)]);
      case TicketState.failed:
        children.addAll([
          _H2(l.ticketFailedTitle),
          const SizedBox(height: 8),
          HelpBox(t.stopReason ?? l.ticketFailedUnknown, tone: Tone.bad),
          if (kindEditable(t)) KindPicker(t),
        ]);
      case TicketState.rateLimited:
        final u = ref.watch(usageProvider).value?.fiveHour.utilization;
        children.addAll([
          _H2(l.ticketRateTitle),
          if (t.stopReason != null) ...[const SizedBox(height: 8), HelpBox(t.stopReason!, tone: Tone.warn)],
          if (u != null) Padding(padding: const EdgeInsets.only(top: 10), child: _Sub(l.ticketRateHint('${(u * 100).round()}'))),
        ]);
    }
    if (t.stopReason != null && t.state != TicketState.failed && t.state != TicketState.rateLimited) {
      children.addAll([const SizedBox(height: 10), HelpBox(t.stopReason!, tone: Tone.gray)]);
    }
    final warning = _kindWarning(t);
    if (warning != null) children.insert(0, Padding(padding: const EdgeInsets.only(bottom: 12), child: warning));
    return _Block(children: children);
  }

  /// The analysis disagreed with a kind someone chose: say so, and offer
  /// the switch while the kind can still change.
  Widget? _kindWarning(Ticket t) {
    final l = AppLocalizations.of(context);
    final evs = ref.watch(ticketEventsProvider(widget.ticketKey)).value ?? const <Event>[];
    final ev = evs.where((e) => e.type == 'kind_changed').lastOrNull;
    if (ev == null || ev.level != EventLevelEnum.warn || ev.data['from'] != t.kind.name || ev.data['to'] == t.kind.name) return null;
    final to = TicketKindChoice.values.where((k) => k.name == ev.data['to']).firstOrNull;
    return HelpBox(
      ev.message,
      tone: Tone.warn,
      child: to == null || !kindEditable(t)
          ? null
          : Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton(
                onPressed: _busy ? null : () => _run(() => _tickets.setTicketKind(key: t.key, ticketKindInput: TicketKindInput(kind: to))),
                child: Text(l.kindSwitchTo(kindChoiceLabel(l, to))),
              ),
            ),
    );
  }

  /// A report under review: summary, notes, the report, and whether to post it.
  List<Widget> _reviewReport(BuildContext context, TicketDetail d) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final t = d.ticket;
    final r = d.result;
    final jira = t.source_ == TicketSource_Enum.jira;
    return [
      _Sub(jira ? l.ticketReviewReportSubJira : l.ticketReviewReportSub),
      if (r != null && r.summary.isNotEmpty) ...[const SizedBox(height: 8), Text(r.summary, style: const TextStyle(fontSize: 15, height: 1.45))],
      if (r != null && r.notes.isNotEmpty) ...[
        _H3(l.ticketNotes),
        for (final n in r.notes)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('•  ', style: TextStyle(color: c.ink3)),
              Expanded(child: Text(n, style: const TextStyle(fontSize: 15, height: 1.4))),
            ]),
          ),
      ],
      _codeReview(d),
      _H3(l.ticketReport),
      if (r?.report != null) ReportMarkdown(r!.report!) else Text(l.ticketReportMissing, style: TextStyle(color: c.ink3)),
      if (jira)
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: CheckboxListTile(
            value: _postReport,
            onChanged: _busy ? null : (v) => setState(() => _postReport = v ?? false),
            title: Text(l.ticketPostReport(t.key), style: const TextStyle(fontSize: 15)),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
        ),
    ];
  }

  /// Model, turns, turn limit and session usage of a running ticket (.facts).
  Widget _runFacts(BuildContext context, TicketDetail d) {
    final l = AppLocalizations.of(context);
    final t = d.ticket;
    final models = d.effectiveModels;
    final model = models == null ? null : (t.revision > 0 ? models.retry : models.coding);
    final u = ref.watch(usageProvider).value?.fiveHour.utilization;
    return Grid2(gap: 8, children: [
      if (model != null) Fact(l.ticketFactModel, _modelName(model)),
      Fact(l.ticketFactTurns, '${t.turns}'),
      if (d.maxTurns != null) Fact(l.ticketFactTurnLimit, '${d.maxTurns}'),
      if (u != null) Fact(l.ticketFactSession, '${(u * 100).round()}%'),
    ]);
  }

  List<Widget> _review(BuildContext context, TicketDetail d) {
    final l = AppLocalizations.of(context);
    final t = d.ticket;
    final toMain = t.afterApprove == TicketAfterApproveEnum.main && t.source_ == TicketSource_Enum.local;
    final sub = toMain
        ? l.ticketReviewSubMain
        : t.source_ == TicketSource_Enum.jira
            ? l.ticketReviewSubJira(t.branch)
            : l.ticketReviewSubPr(t.branch);
    final r = d.result;
    if (r == null) return [_Sub(sub), _codeReview(d), _preview(d)];
    final passed = r.checks.where((x) => x.exitCode == 0).length;
    final allOk = passed == r.checks.length;
    final time = _reviewTime(d);
    return [
      _Sub(sub),
      const SizedBox(height: 8),
      Grid2(gap: 8, children: [
        Fact(l.ticketFactTests, r.checks.isEmpty ? l.ticketNoChecks : l.ticketChecksPassed(passed),
            tone: r.checks.isEmpty ? null : (allOk ? Tone.ok : Tone.bad)),
        Fact(l.ticketFactChanged, _changed(l, r)),
        if (time != null) Fact(l.mdetailFactTime, shortDuration(time)),
        Fact(l.ticketFactTurns, '${t.turns}'),
      ]),
      _codeReview(d),
      _preview(d),
      ..._resultBody(context, r),
    ];
  }

  /// Summary, notes, checks and per-file diffs of a result.
  List<Widget> _resultBody(BuildContext context, Result r) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final paras = r.summary.split(RegExp(r'\n\s*\n')).map((p) => p.trim()).where((p) => p.isNotEmpty).toList();
    return [
      if (paras.isNotEmpty) ...[
        _H3(l.ticketWhatAgntsDid),
        for (final p in paras) Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(p, style: const TextStyle(fontSize: 15, height: 1.45))),
      ],
      if (r.notes.isNotEmpty) ...[
        _H3(l.ticketNotes),
        for (final n in r.notes)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('•  ', style: TextStyle(color: c.ink3)),
              Expanded(child: Text(n, style: const TextStyle(fontSize: 15, height: 1.4))),
            ]),
          ),
      ],
      if (r.checks.isNotEmpty) ...[
        _H3(l.ticketChecks),
        ListGroup(children: [
          for (final x in r.checks)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(children: [
                HIcon(x.exitCode == 0 ? 'check' : 'close', size: 16, stroke: 2.6, color: x.exitCode == 0 ? c.okInk : c.badInk),
                const SizedBox(width: 10),
                Expanded(child: Text(x.command, style: TextStyle(fontFamily: AgntsFonts.mono, fontSize: 12.5, color: c.ink))),
                Text(x.exitCode == 0 ? l.ticketPassed : l.ticketFailedCheck,
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: x.exitCode == 0 ? c.okInk : c.badInk)),
              ]),
            ),
        ]),
      ],
      if (r.files.isNotEmpty) ...[
        _H3(l.ticketDiff),
        for (final (i, f) in r.files.indexed) _FileDiff(file: f, initiallyOpen: i == 0),
      ],
    ];
  }

  String _changed(AppLocalizations l, Result r) {
    final add = r.files.fold<int>(0, (a, f) => a + f.add), del = r.files.fold<int>(0, (a, f) => a + f.del);
    return l.ticketChangedValue(r.files.length, add.toString(), del.toString());
  }

  /// From the last start of coding to the result.
  Duration? _reviewTime(TicketDetail d) {
    final r = d.result;
    if (r == null) return null;
    DateTime? start;
    for (final h in d.history ?? const <HistoryItem>[]) {
      if (h.state == TicketState.coding && !h.at.isAfter(r.createdAt) && (start == null || h.at.isAfter(start))) start = h.at;
    }
    if (start == null) return null;
    final dur = r.createdAt.difference(start);
    return dur.isNegative ? null : dur;
  }

  // ---- Questions (.q, .opts, .opt, textarea) ----

  Widget _questionCard(BuildContext context, Question q) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final note = _noteFor(q);
    final enabled = !_busy;
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: c.surface, border: Border.all(color: c.line), borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(q.text, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, height: 1.4, color: c.ink)),
        const SizedBox(height: 10),
        if (q.options.isNotEmpty) ...[
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final o in q.options)
              _OptionPill(
                label: o,
                selected: _picked[q.id] == o,
                onTap: enabled ? () => setState(() => _picked[q.id] = _picked[q.id] == o ? null : o) : null,
              ),
          ]),
          const SizedBox(height: 10),
        ],
        TextField(
          controller: note,
          enabled: enabled,
          minLines: 2,
          maxLines: 6,
          style: const TextStyle(fontSize: 16, height: 1.4),
          decoration: InputDecoration(
            hintText: q.options.isEmpty ? l.ticketYourAnswer : l.ticketAddDetails,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          ),
          onChanged: (_) => setState(() {}),
        ),
      ]),
    );
  }

  Widget _analysisFold(BuildContext context, Analysis a) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Fold(
        title: a.summary.isEmpty ? l.ticketPlan : l.ticketAnalysis,
        hint: a.plan.isEmpty ? null : '${a.plan.length}',
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (a.summary.isNotEmpty) Text(a.summary, style: const TextStyle(fontSize: 15, height: 1.45)),
          if (a.plan.isNotEmpty) ...[
            if (a.summary.isNotEmpty) _H3(l.ticketPlan),
            for (final (i, p) in a.plan.indexed)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  SizedBox(width: 22, child: Text('${i + 1}.', style: TextStyle(color: c.ink3, fontSize: 15))),
                  Expanded(child: Text(p, style: const TextStyle(fontSize: 15, height: 1.4))),
                ]),
              ),
          ],
        ]),
      ),
    );
  }

  // ---- Logs ----

  List<Event> _shown(List<Event> evs) => evs.where((e) => e.type != 'claude_text' || e.message.length < 400).toList();

  /// The live log of a running ticket on the dark code background (.log).
  Widget _liveLog(BuildContext context, bool live) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final events = ref.watch(ticketEventsProvider(widget.ticketKey));
    return events.when(
      data: (evs) {
        final shown = _shown(evs);
        final tail = shown.length > 80 ? shown.sublist(shown.length - 80) : shown;
        if (tail.isEmpty) return LogBox(lines: [('', l.ticketLogEmpty)], live: live);
        return LogBox(lines: [for (final e in tail) (_clock(context, e.createdAt), e.message)], live: live);
      },
      error: (_, _) => Text(l.commonError, style: TextStyle(color: c.badInk)),
      loading: () => const LinearProgressIndicator(),
    );
  }

  // ---- Folds at the bottom: answers, analysis, changes, history, run log ----

  Widget _folds(BuildContext context, TicketDetail d) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final t = d.ticket;
    final early = t.state == TicketState.new_ || t.state == TicketState.analyzing || t.state == TicketState.waitingForAnswers;
    final answered = d.questions.where((q) => (q.answer ?? '').isNotEmpty).toList();
    final history = (d.history ?? const <HistoryItem>[]).toList()..sort((a, b) => b.at.compareTo(a.at));
    final events = ref.watch(ticketEventsProvider(widget.ticketKey));
    final folds = <Widget>[
      if (answered.isNotEmpty && !early)
        Fold(
          title: l.ticketAnswersTitle,
          hint: '${answered.length}',
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            for (final q in answered)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text.rich(TextSpan(style: const TextStyle(fontSize: 15, height: 1.4), children: [
                  TextSpan(text: '${q.text}\n', style: TextStyle(color: c.ink3)),
                  TextSpan(text: q.answer, style: const TextStyle(fontWeight: FontWeight.w700)),
                  if (q.note.isNotEmpty) TextSpan(text: '. ${q.note}'),
                ])),
              ),
          ]),
        ),
      if (d.analysis != null && t.state != TicketState.waitingForAnswers) _analysisFold(context, d.analysis!),
      if (d.result?.report != null && t.state != TicketState.waitingForReview && t.state != TicketState.done)
        Fold(title: l.ticketReport, child: ReportMarkdown(d.result!.report!))
      else if (d.result != null && !isReportKind(t.kind) && t.state != TicketState.waitingForReview)
        Fold(
          title: l.ticketChanges,
          hint: _changed(l, d.result!),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: _resultBody(context, d.result!)),
        ),
      if (RelationsFold.shows(d)) RelationsFold(d),
      if (d.followUps != null) FollowUpsFold(d),
      SpendFold(spend: t.spend, stages: d.spendByStage ?? const [], report: isReportKind(t.kind)),
      Fold(
        title: l.ticketHistoryTitle,
        hint: '${history.length}',
        child: history.isEmpty
            ? Text(l.ticketHistoryEmpty, style: TextStyle(color: c.ink3))
            : Column(children: [
                for (final (i, h) in history.indexed)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    decoration: BoxDecoration(border: i == history.length - 1 ? null : Border(bottom: BorderSide(color: c.line2))),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      SizedBox(
                        width: 56,
                        child: Text(_when(context, h.at), style: TextStyle(fontSize: 13, color: c.ink3, fontFeatures: const [FontFeature.tabularFigures()])),
                      ),
                      Container(
                        width: 9,
                        height: 9,
                        margin: const EdgeInsets.only(top: 6, right: 10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: h.state == TicketState.done
                              ? c.ok
                              : h.origin == 'user'
                                  ? c.warn
                                  : c.line3,
                        ),
                      ),
                      Expanded(child: Text(h.message.isEmpty ? stateLabel(l, h.state, t.kind) : h.message, style: const TextStyle(fontSize: 14, height: 1.4))),
                    ]),
                  ),
              ]),
      ),
      Fold(
        title: l.ticketRunLog,
        hint: events.value == null ? null : '${_shown(events.value!).length}',
        child: events.when(
          data: (evs) {
            final shown = _shown(evs).reversed.take(40).toList();
            if (shown.isEmpty) return Text(l.ticketLogEmpty, style: TextStyle(color: c.ink3));
            return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              for (final e in shown)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    SizedBox(width: 48, child: Text(_clock(context, e.createdAt), style: TextStyle(fontSize: 12.5, color: c.ink3))),
                    Expanded(
                      child: Text(
                        e.message,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          fontFamily: e.type == 'claude_tool' ? AgntsFonts.mono : null,
                          color: e.level == EventLevelEnum.error
                              ? c.badInk
                              : e.level == EventLevelEnum.warn
                                  ? c.warnInk
                                  : c.ink,
                        ),
                      ),
                    ),
                  ]),
                ),
            ]);
          },
          error: (_, _) => Text(l.commonError, style: TextStyle(color: c.badInk)),
          loading: () => const LinearProgressIndicator(),
        ),
      ),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        for (final (i, f) in folds.indexed) Padding(padding: EdgeInsets.only(top: i == 0 ? 0 : 10), child: f),
      ]),
    );
  }

  String _clock(BuildContext context, DateTime at) =>
      MaterialLocalizations.of(context).formatTimeOfDay(TimeOfDay.fromDateTime(at.toLocal()), alwaysUse24HourFormat: true);

  /// Time today, otherwise the short date.
  String _when(BuildContext context, DateTime at) {
    final local = at.toLocal(), now = DateTime.now();
    if (local.year == now.year && local.month == now.month && local.day == now.day) return _clock(context, at);
    return MaterialLocalizations.of(context).formatShortMonthDay(local);
  }

  // ---- The sticky action bar (dBar) ----

  Widget? _actionBar(BuildContext context, TicketDetail d) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final t = d.ticket;
    final key = t.key;
    final danger = OutlinedButton.styleFrom(foregroundColor: c.badInk);
    Widget hint(String text) => Expanded(child: Text(text, style: TextStyle(fontSize: 13, color: c.ink3)));
    List<Widget> buttons;
    switch (t.state) {
      case TicketState.waitingForAnswers:
        final left = d.questions.where((q) => _answerOf(q).isEmpty).length;
        buttons = [
          hint(left > 0 ? l.ticketQuestionsLeft(left) : l.ticketAllAnswered),
          FilledButton(
            onPressed: _busy || left > 0
                ? null
                : () => _run(() => _tickets.answerQuestions(
                      key: key,
                      answersRequest: AnswersRequest(answers: [
                        for (final q in d.questions) AnswersRequestAnswersInner(questionId: q.id, answer: _answerOf(q), note: _noteOf(q)),
                      ]),
                    )),
            child: Text(isReportKind(t.kind) ? l.ticketStartWriting : l.ticketStartCoding),
          ),
        ];
      case TicketState.waitingForReview:
        final report = isReportKind(t.kind);
        final toMain = t.afterApprove == TicketAfterApproveEnum.main && t.source_ == TicketSource_Enum.local;
        final post = report && _postReport && t.source_ == TicketSource_Enum.jira;
        final confirm = report
            ? (post ? l.ticketApproveReportPostConfirm(key) : l.ticketApproveReportConfirm)
            : (toMain ? l.ticketApproveMainConfirm : l.ticketApproveConfirm(t.branch));
        buttons = [
          Tooltip(
            message: l.ticketReject,
            child: SizedBox(
              width: 48,
              child: OutlinedButton(
                style: danger.copyWith(padding: const WidgetStatePropertyAll(EdgeInsets.zero)),
                onPressed: _busy ? null : () => _reject(context, key),
                child: HIcon('close', size: 20, stroke: 2.2, color: _busy ? c.line3 : c.badInk),
              ),
            ),
          ),
          Expanded(
            child: OutlinedButton(
              onPressed: _busy ? null : () => _requestChanges(context, key),
              child: Text(l.ticketRequestChanges, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ),
          Expanded(
            child: FilledButton(
              onPressed: _busy
                  ? null
                  : () async {
                      if (await _confirm(confirm)) {
                        await _run(() => _tickets.approveTicket(
                              key: key,
                              approveTicketRequest: report ? ApproveTicketRequest(postReport: post) : null,
                            ));
                      }
                    },
              child: Text(report ? l.ticketApproveReport : l.mdetailApprove, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ),
        ];
      case TicketState.failed:
      case TicketState.rateLimited:
        final failed = t.state == TicketState.failed;
        buttons = [
          Expanded(
            child: OutlinedButton(
              style: danger,
              onPressed: _busy ? null : () => _reject(context, key),
              child: Text(failed ? l.ticketTakeItMyself : l.ticketReject, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ),
          Expanded(
            child: FilledButton(
              onPressed: _busy ? null : () => _run(() => _tickets.retryTicket(key: key)),
              child: Text(failed ? l.mobileRetry : l.ticketResume, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ),
        ];
      case TicketState.analyzing:
      case TicketState.coding:
      case TicketState.testing:
        buttons = [
          Expanded(
            child: OutlinedButton(
              style: danger,
              onPressed: _busy
                  ? null
                  : () async {
                      if (await _confirm(l.ticketStopConfirm(key))) await _run(() => _tickets.stopTicket(key: key));
                    },
              child: Text(l.ticketStopRun),
            ),
          ),
        ];
      case TicketState.pushing:
        buttons = [hint(l.mdetailWorking)];
      case TicketState.new_ when t.held == true:
        buttons = [
          Expanded(child: FilledButton(onPressed: _busy ? null : () => _run(() => _tickets.startTicket(key: key)), child: Text(l.ticketStart))),
        ];
      case TicketState.new_:
        buttons = [hint(l.ticketStartHint)];
      case TicketState.done when t.prUrl.isNotEmpty:
        buttons = [
          Expanded(
            child: OutlinedButton(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: t.prUrl));
                if (context.mounted) showSnack(context, l.mdetailCopied);
              },
              child: Text(l.mdetailCopyPr, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ),
        ];
      default:
        return null;
    }
    return ActionBar(children: buttons);
  }

  Future<void> _reject(BuildContext context, String key) async {
    final l = AppLocalizations.of(context);
    if (await _confirm(l.ticketRejectConfirm(key))) {
      await _run(() => _tickets.rejectTicket(key: key, rejectTicketRequest: RejectTicketRequest(reason: 'rejected from the phone')));
      if (context.mounted) context.pop();
    }
  }

  Future<void> _requestChanges(BuildContext context, String key) async {
    final l = AppLocalizations.of(context);
    final text = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (c) => Padding(
        padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.of(c).viewInsets.bottom + 20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(l.ticketRequestChanges, style: Theme.of(c).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(l.ticketFeedbackHint, style: TextStyle(fontSize: 14, color: Agnts.of(c).ink3)),
          const SizedBox(height: 12),
          TextField(
            controller: _feedback,
            autofocus: true,
            maxLines: 5,
            minLines: 3,
            style: const TextStyle(fontSize: 16, height: 1.4),
            decoration: InputDecoration(hintText: l.ticketFeedbackPlaceholder),
          ),
          FeedbackShotChips(shots: _feedbackShots),
          const SizedBox(height: 12),
          FilledButton(onPressed: () => Navigator.pop(c, _feedback.text.trim()), child: Text(l.ticketSend)),
        ]),
      ),
    );
    if (text == null || text.isEmpty) return;
    final shots = [for (final s in _feedbackShots.value) s.ref];
    final ok = await _run(() => _tickets.requestChanges(
        key: key, requestChangesRequest: RequestChangesRequest(feedback: text, shots: shots.isEmpty ? null : shots)));
    if (!ok) return;
    _feedback.clear();
    _feedbackShots.value = const [];
  }
}

String _modelName(Model m) => m.value.isEmpty ? m.value : '${m.value[0].toUpperCase()}${m.value.substring(1)}';

// ---- Small private pieces of the demo's detail page ----

/// A block under the track (.block).
class _Block extends StatelessWidget {
  const _Block({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
    );
  }
}

/// .block h2
class _H2 extends StatelessWidget {
  const _H2(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(text, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Agnts.of(context).ink)),
      );
}

/// .block .sub
class _Sub extends StatelessWidget {
  const _Sub(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(text, style: TextStyle(fontSize: 14, height: 1.45, color: Agnts.of(context).ink3)),
      );
}

/// .h3: a small grey heading inside a block.
class _H3 extends StatelessWidget {
  const _H3(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 18, bottom: 8),
        child: Text(text, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Agnts.of(context).ink3)),
      );
}

/// An answer option (.opt): black when picked.
class _OptionPill extends StatelessWidget {
  const _OptionPill({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = Agnts.of(context);
    return Material(
      color: selected ? c.ink : c.surface,
      shape: StadiumBorder(side: BorderSide(color: selected ? c.ink : c.line4)),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap == null
            ? null
            : () {
                HapticFeedback.selectionClick();
                onTap!();
              },
        child: Container(
          constraints: const BoxConstraints(minHeight: 38),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, height: 1.3, color: selected ? c.surface : c.ink2)),
        ),
      ),
    );
  }
}

// ---- The progress track (mtrack: .track, .stop, .mark) ----

enum _Stop { none, done, active, error }

class _Track extends StatelessWidget {
  const _Track({required this.ticket, required this.history});
  final Ticket ticket;
  final List<HistoryItem> history;

  bool get _report => isReportKind(ticket.kind);

  /// A report has no tests and nothing to push: five stops.
  int? _indexOf(TicketState s) {
    final i = _index(s);
    if (!_report || i == null || i < 3) return i;
    return switch (s) {
      TicketState.testing => 2,
      _ => i - 1,
    };
  }

  static int? _index(TicketState s) => switch (s) {
        TicketState.new_ => -1,
        TicketState.analyzing => 0,
        TicketState.waitingForAnswers => 1,
        TicketState.coding => 2,
        TicketState.testing => 3,
        TicketState.waitingForReview => 4,
        TicketState.pushing => 5,
        TicketState.done => 6,
        TicketState.rejected => -2,
        TicketState.failed || TicketState.rateLimited => null,
      };

  /// Where a stopped run stopped: its resume state, else the last state it reached.
  int _failedAt() {
    final last = _report ? 4 : 5;
    final r = ticket.resumeState == null ? null : _indexOf(ticket.resumeState!);
    if (r != null && r >= 0) return r.clamp(0, last);
    final h = history.toList()..sort((a, b) => b.at.compareTo(a.at));
    for (final x in h) {
      final i = _indexOf(x.state);
      if (i != null && i >= 0) return i.clamp(0, last);
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final labels = _report
        ? [l.ticketStopAnalyze, l.ticketStopAnswers, l.ticketStopWriting, l.ticketStopReview, l.ticketStopDone]
        : [l.ticketStopAnalyze, l.ticketStopAnswers, l.ticketStopCoding, l.ticketStopTests, l.ticketStopReview, l.ticketStopPushed];
    final gates = _report ? const [false, true, false, true, false] : const [false, true, false, false, true, false];
    final n = labels.length;
    var idx = _indexOf(ticket.state);
    var err = false;
    if (idx == null) {
      idx = _failedAt();
      err = true;
    }
    _Stop kind(int i) {
      if (idx == -2) return i == 0 ? _Stop.done : _Stop.none;
      if (i < idx! || idx == n) return _Stop.done;
      if (i == idx) return err ? _Stop.error : _Stop.active;
      return _Stop.none;
    }

    final kinds = [for (var i = 0; i < n; i++) kind(i)];
    bool lit(int i) => kinds[i] != _Stop.none;
    return Semantics(
      label: l.ticketProgress,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 18, 16, 4),
        padding: const EdgeInsets.fromLTRB(6, 14, 6, 12),
        decoration: BoxDecoration(color: c.surface, border: Border.all(color: c.line), borderRadius: BorderRadius.circular(18)),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          for (var i = 0; i < n; i++)
            Expanded(
              child: Column(children: [
                SizedBox(
                  height: 22,
                  child: Stack(alignment: Alignment.center, children: [
                    // The connector: left half belongs to this stop, right half to the next.
                    Positioned(
                      top: 10,
                      left: 0,
                      right: 0,
                      child: Row(children: [
                        Expanded(child: Container(height: 2, color: i == 0 ? Colors.transparent : (lit(i) ? c.primary : c.line))),
                        Expanded(child: Container(height: 2, color: i == n - 1 ? Colors.transparent : (lit(i + 1) ? c.primary : c.line))),
                      ]),
                    ),
                    _Mark(kind: kinds[i], gate: gates[i]),
                  ]),
                ),
                const SizedBox(height: 6),
                Text(
                  labels[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10.5,
                    height: 1.15,
                    fontWeight: FontWeight.w700,
                    color: kinds[i] == _Stop.active && gates[i]
                        ? c.warnInk
                        : (kinds[i] == _Stop.active || kinds[i] == _Stop.error)
                            ? c.ink
                            : c.ink3,
                  ),
                ),
              ]),
            ),
        ]),
      ),
    );
  }
}

class _Mark extends StatelessWidget {
  const _Mark({required this.kind, required this.gate});
  final _Stop kind;
  final bool gate;

  @override
  Widget build(BuildContext context) {
    final c = Agnts.of(context);
    final (bg, border) = switch (kind) {
      _Stop.done => (c.primary, c.primary),
      _Stop.active => gate ? (c.warn, c.warn) : (c.primarySoft, c.primary),
      _Stop.error => (c.badSoft, c.bad),
      _Stop.none => (c.surface, c.line3),
    };
    Widget? inner;
    if (kind == _Stop.done) {
      inner = HIcon('check', size: 11, stroke: 3.2, color: c.onPrimary);
      if (gate) inner = Transform.rotate(angle: -0.785398, child: inner);
    } else if (kind == _Stop.active && !gate) {
      inner = const Pulse(size: 7);
    }
    final size = gate ? 18.0 : 22.0;
    final box = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border, width: 2),
        borderRadius: BorderRadius.circular(gate ? 5 : 11),
      ),
      child: inner,
    );
    return gate ? Transform.rotate(angle: 0.785398, child: box) : box;
  }
}

// ---- One changed file with its diff (.file, .diff) ----

const _codeAdd = Color(0x382EA067); // rgba(46,160,103,.22)
const _codeDel = Color(0x3DD64034); // rgba(214,64,52,.24)
const _codeHunk = Color(0x2E7D96EB); // rgba(125,150,235,.18)
const _hunkInk = Color(0xFFB9C6F5);

class _FileDiff extends StatefulWidget {
  const _FileDiff({required this.file, this.initiallyOpen = false});
  final FileChange file;
  final bool initiallyOpen;

  @override
  State<_FileDiff> createState() => _FileDiffState();
}

class _FileDiffState extends State<_FileDiff> {
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
                child: Text(f.path, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: AgntsFonts.mono, fontSize: 12.5, color: c.ink)),
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
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
            for (final l in lines)
              Container(
                color: _bg(l.kind),
                padding: const EdgeInsets.only(left: 4, right: 8),
                child: Row(mainAxisSize: MainAxisSize.min, children: [num(l.old), const SizedBox(width: 6), num(l.neu)]),
              ),
          ]),
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
