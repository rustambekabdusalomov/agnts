import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:agnts_api/agnts_api.dart';

import '../../core/api.dart';
import '../../core/data.dart';
import '../../l10n/app_localizations.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import '../../widgets/ui.dart';
import 'ci_sample.dart';
import 'ci_screen.dart' show ciAgo;

/// One CI failure group: where it fails, how often, the first error from
/// the log, the failing runs, and Fix it, Mute and Re-run. CI pushes with
/// no ticket fixing the failure open here.
class CIFailureScreen extends ConsumerStatefulWidget {
  const CIFailureScreen({super.key, required this.id});
  final int id;

  @override
  ConsumerState<CIFailureScreen> createState() => _CIFailureScreenState();
}

class _CIFailureScreenState extends ConsumerState<CIFailureScreen> {
  bool _busy = false;

  CiApi get _ci => ref.read(apiProvider)!.getCiApi();

  /// Runs [action] and refreshes the failure and the lists; false when it failed.
  Future<bool> _run(Future<void> Function() action, {String? done}) async {
    final l = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      await action();
      ref.invalidate(ciFailureProvider(widget.id));
      ref.invalidate(ciFailuresProvider);
      if (done != null && mounted) showSnack(context, done);
      return true;
    } catch (e) {
      if (mounted) showSnack(context, errorMessage(e, l.commonError));
      return false;
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _fix() async {
    final l = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        content: Text(l.mciFixConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: Text(l.mobileCancel)),
          FilledButton(onPressed: () => Navigator.pop(c, true), child: Text(l.mciFix)),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    Ticket? t;
    final done = await _run(() async => t = (await _ci.fixCIFailure(failureId: widget.id)).data);
    if (!done || t == null || !mounted) return;
    ref.invalidate(ticketsProvider);
    ref.invalidate(dashboardProvider);
    context.push('/tickets/${t!.key}');
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final failure = ref.watch(ciFailureProvider(widget.id));
    final f = failure.value;
    return Scaffold(
      backgroundColor: c.bg,
      appBar: DetailBar(
        backLabel: l.navBack,
        title: l.mciCardTitle,
        onBack: () => context.canPop() ? context.pop() : context.go('/ci'),
      ),
      body: AsyncBody<CIFailure>(
        value: failure,
        onRefresh: () => ref.refresh(ciFailureProvider(widget.id).future),
        builder: (f) => ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            _header(context, f),
            _facts(context, f),
            _log(context, f),
            _runs(context, f),
          ],
        ),
      ),
      // Viewers read the failure but cannot act on it.
      bottomNavigationBar: f == null || !ref.watch(canEditProvider) ? null : _actionBar(context, f),
    );
  }

  Widget _header(BuildContext context, CIFailure f) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final (status, tone) = ciStatusBadge(l, f.status);
    final job = [f.workflow, f.job].where((x) => x.isNotEmpty).join(' / ');
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        DefaultTextStyle.merge(
          style: TextStyle(fontSize: 13, color: c.ink3),
          child: Wrap(spacing: 8, runSpacing: 6, crossAxisAlignment: WrapCrossAlignment.center, children: [
            ToneBadge(status, tone),
            Text(f.repo),
            Text(f.branch, style: TextStyle(fontFamily: AgntsFonts.mono, fontSize: 12.5, color: c.ink3)),
          ]),
        ),
        const SizedBox(height: 8),
        SelectableText(f.title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(height: 1.15)),
        if (job.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text('${l.mciJob}: $job', style: TextStyle(fontFamily: AgntsFonts.mono, fontSize: 12.5, color: c.ink3)),
          ),
        if (f.ticketKey.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: GestureDetector(
              onTap: () => context.push('/tickets/${f.ticketKey}'),
              child: Wrap(spacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
                Text('${l.mciTicket} ${f.ticketKey}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: c.primary)),
                if (f.ticketState != null) ToneBadge(stateLabel(l, f.ticketState!), stateTone(f.ticketState!), small: true),
              ]),
            ),
          ),
        if (f.prNumber > 0) ...[
          const SizedBox(height: 10),
          HelpBox(l.mciForeignPr('${f.prNumber}'), tone: Tone.gray),
        ],
      ]),
    );
  }

  /// First failing commit, how often, when last (.facts).
  Widget _facts(BuildContext context, CIFailure f) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Grid2(gap: 8, children: [
        Fact(l.mciFactFirstCommit, shortSha(f.firstSha)),
        Fact(l.mciFactCount, l.mciTimes(f.count)),
        Fact(l.mciFactLastSeen, ciAgo(l, f.lastSeenAt)),
        if (f.flakyCount > 0) Fact(l.mciFactFlaky, l.mciTimes(f.flakyCount)),
      ]),
    );
  }

  /// The first error block of the redacted excerpt, else its last lines.
  Widget _log(BuildContext context, CIFailure f) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final sample = f.sample ?? '';
    if (sample.trim().isEmpty) {
      return Section(title: l.mciFirstError, child: Text(l.mciNoSample, style: TextStyle(color: c.ink3)));
    }
    final x = sampleExcerpt(sample);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      SectionHeader(x.first ? l.mciFirstError : l.mciLogTail, trailing: CopyButton(x.text)),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 360),
          decoration: BoxDecoration(color: c.code, borderRadius: BorderRadius.circular(14)),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SelectableText(x.text, style: TextStyle(fontFamily: AgntsFonts.mono, fontSize: 12, height: 1.55, color: c.codeInk)),
            ),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
        child: Text(l.mciLogNote, style: TextStyle(fontSize: 12.5, color: c.ink3)),
      ),
    ]);
  }

  /// The latest failing runs: when, the commit, and the run's link to copy.
  Widget _runs(BuildContext context, CIFailure f) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final runs = f.occurrences.toList()..sort((a, b) => b.at.compareTo(a.at));
    if (runs.isEmpty) return const SizedBox.shrink();
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      SectionHeader(l.mciRuns, trailing: Text('${runs.length}')),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListGroup(children: [
          for (final o in runs)
            ListRow(
              title: '${_when(context, o.at)} · ${shortSha(o.sha)}',
              subtitle: [if (o.job.isNotEmpty && o.job != f.job) o.job, if (o.flaky == true) l.mciRunFlaky, if (o.url.isNotEmpty) o.url].join(' · '),
              trailing: o.url.isEmpty ? const SizedBox.shrink() : CopyButton(o.url, color: c.ink3),
            ),
        ]),
      ),
    ]);
  }

  /// Time today, otherwise the short date and time.
  String _when(BuildContext context, DateTime at) {
    final m = MaterialLocalizations.of(context);
    final local = at.toLocal(), now = DateTime.now();
    final time = m.formatTimeOfDay(TimeOfDay.fromDateTime(local), alwaysUse24HourFormat: true);
    if (local.year == now.year && local.month == now.month && local.day == now.day) return time;
    return '${m.formatShortMonthDay(local)} $time';
  }

  // ---- The sticky action bar ----

  Widget? _actionBar(BuildContext context, CIFailure f) {
    final l = AppLocalizations.of(context);
    final muted = f.status == CIStatus.muted;
    return ActionBar(children: [
      if (canFixCI(f)) Expanded(child: FilledButton(onPressed: _busy ? null : _fix, child: Text(l.mciFix))),
      Expanded(
        child: OutlinedButton(
          onPressed: _busy
              ? null
              : () => _run(
                    () => muted ? _ci.unmuteCIFailure(failureId: f.id) : _ci.muteCIFailure(failureId: f.id),
                    done: muted ? l.mciUnmutedDone : l.mciMutedDone,
                  ),
          child: Text(muted ? l.mciUnmute : l.mciMute),
        ),
      ),
      Expanded(
        child: OutlinedButton(
          onPressed: _busy ? null : () => _run(() => _ci.rerunCIFailure(failureId: f.id), done: l.mciRerunDone),
          child: Text(l.mciRerun, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      ),
    ]);
  }
}
