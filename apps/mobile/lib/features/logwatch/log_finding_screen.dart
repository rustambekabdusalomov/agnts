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
import '../ci/ci_screen.dart' show ciAgo;
import 'log_watcher_screen.dart' show logStatusBadge;

/// One log finding: what it is, how to fix it, the redacted excerpt, and
/// Fix it and Mute. A finding's push opens here.
class LogFindingScreen extends ConsumerStatefulWidget {
  const LogFindingScreen({super.key, required this.id});
  final int id;

  @override
  ConsumerState<LogFindingScreen> createState() => _LogFindingScreenState();
}

class _LogFindingScreenState extends ConsumerState<LogFindingScreen> {
  bool _busy = false;

  LogsApi get _logs => ref.read(apiProvider)!.getLogsApi();

  Future<bool> _run(Future<void> Function() action, {String? done}) async {
    final l = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      await action();
      ref.invalidate(logFindingProvider(widget.id));
      ref.invalidate(logFindingsProvider);
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
        content: Text(l.mlogsFixConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: Text(l.mobileCancel)),
          FilledButton(onPressed: () => Navigator.pop(c, true), child: Text(l.mlogsFix)),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    Ticket? t;
    final done = await _run(() async => t = (await _logs.fixLogFinding(findingId: widget.id)).data);
    if (!done || t == null || !mounted) return;
    ref.invalidate(ticketsProvider);
    ref.invalidate(dashboardProvider);
    context.push('/tickets/${t!.key}');
  }

  bool _canFix(LogFinding f) {
    final s = f.ticketState;
    final live = f.ticketKey.isNotEmpty && s != null && s != TicketState.done && s != TicketState.rejected;
    return f.repoIds.isNotEmpty && !live &&
        (f.status == LogFindingStatus.open || f.status == LogFindingStatus.reported || f.status == LogFindingStatus.regression);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final finding = ref.watch(logFindingProvider(widget.id));
    final f = finding.value;
    return Scaffold(
      backgroundColor: c.bg,
      appBar: DetailBar(backLabel: l.navBack, title: l.mlogsCardTitle, onBack: () => context.canPop() ? context.pop() : context.go('/log-watcher')),
      body: AsyncBody<LogFinding>(
        value: finding,
        onRefresh: () => ref.refresh(logFindingProvider(widget.id).future),
        builder: (f) => ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 24),
          children: [_header(context, f), _facts(context, f), if (f.remediation.isNotEmpty) _remediation(context, f), _excerpt(context, f)],
        ),
      ),
      bottomNavigationBar: f == null || !ref.watch(canEditProvider) ? null : _actionBar(context, f),
    );
  }

  Widget _header(BuildContext context, LogFinding f) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final (status, tone) = logStatusBadge(l, f.status);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DefaultTextStyle.merge(
            style: TextStyle(fontSize: 13, color: c.ink3),
            child: Wrap(
              spacing: 8,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [ToneBadge(status, tone), SourceChip(f.severity.value), Text(f.service)],
            ),
          ),
          const SizedBox(height: 8),
          SelectableText(f.title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(height: 1.15)),
          if (f.secretMask.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(l.mlogsMasked(f.secretMask), style: TextStyle(fontFamily: AgntsFonts.mono, fontSize: 12.5, color: c.ink3)),
            ),
          if (f.reason.isNotEmpty) ...[const SizedBox(height: 10), HelpBox(f.reason, tone: Tone.gray)],
          if (f.repoIds.isEmpty) ...[const SizedBox(height: 10), HelpBox(l.mlogsNoRepos, tone: Tone.gray)],
          if (f.ticketKey.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: GestureDetector(
                onTap: () => context.push('/tickets/${f.ticketKey}'),
                child: Text('${l.mlogsTicket} ${f.ticketKey}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: c.primary)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _facts(BuildContext context, LogFinding f) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Grid2(
        gap: 8,
        children: [
          Fact(l.mlogsFactCount, '×${f.count}'),
          Fact(l.mlogsFactLastHour, '${f.hourCount}'),
          Fact(l.mlogsFactFirstSeen, ciAgo(l, f.firstSeenAt)),
          Fact(l.mlogsFactLastSeen, ciAgo(l, f.lastSeenAt)),
        ],
      ),
    );
  }

  Widget _remediation(BuildContext context, LogFinding f) {
    final l = AppLocalizations.of(context);
    return Section(title: l.mlogsRemediation, child: Text(f.remediation));
  }

  /// The redacted excerpt; untrusted log text, only displayed.
  Widget _excerpt(BuildContext context, LogFinding f) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final sample = (f.sample ?? '').trimRight();
    if (sample.isEmpty) return Section(title: l.mlogsExcerpt, child: Text(l.mlogsNoExcerpt, style: TextStyle(color: c.ink3)));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(l.mlogsExcerpt, trailing: CopyButton(sample)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            constraints: const BoxConstraints(maxHeight: 360),
            decoration: BoxDecoration(color: c.code, borderRadius: BorderRadius.circular(14)),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SelectableText(sample, style: TextStyle(fontFamily: AgntsFonts.mono, fontSize: 12, height: 1.55, color: c.codeInk)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget? _actionBar(BuildContext context, LogFinding f) {
    final l = AppLocalizations.of(context);
    final muted = f.status == LogFindingStatus.muted;
    return ActionBar(
      children: [
        if (_canFix(f)) Expanded(child: FilledButton(onPressed: _busy ? null : _fix, child: Text(l.mlogsFix))),
        Expanded(
          child: OutlinedButton(
            onPressed: _busy
                ? null
                : () => _run(
                    () => muted ? _logs.unmuteLogFinding(findingId: f.id) : _logs.muteLogFinding(findingId: f.id),
                    done: muted ? l.mlogsUnmutedDone : l.mlogsMutedDone,
                  ),
            child: Text(muted ? l.mlogsUnmute : l.mlogsMute),
          ),
        ),
      ],
    );
  }
}
