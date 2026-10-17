import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:agnts_api/agnts_api.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../core/api.dart';
import '../../core/data.dart';
import '../../l10n/app_localizations.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import '../../widgets/ui.dart';
import '../analytics/export.dart';

/// Run statistics and time per step over the last 30 days (the Logs page's summary).
final eventSummaryProvider = FutureProvider<EventSummary>((ref) async {
  return (await requireApi(ref).getLogsApi().getEventSummary()).data!;
});

/// The global event log as a standalone screen. The Analytics tab embeds
/// [ActivityFeed] directly under its "Events" switch.
class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          PageHeader(title: l.mobileActivity),
          const Expanded(child: ActivityFeed()),
        ]),
      ),
    );
  }
}

/// The event log, newest first (.stats + .chips + .feed): a seven-day
/// summary, the all / you / problems filters and the event rows.
class ActivityFeed extends ConsumerStatefulWidget {
  const ActivityFeed({super.key});

  @override
  ConsumerState<ActivityFeed> createState() => _ActivityFeedState();
}

class _ActivityFeedState extends ConsumerState<ActivityFeed> {
  String _type = 'all';

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final types = {'all': l.mobileFilterAll, 'user': l.mobileFilterYou, 'problems': l.mobileFilterProblems};
    final events = ref.watch(activityProvider(_type));

    final chips = ChipRow(children: [
      for (final e in types.entries) FilterChipH(label: e.value, selected: _type == e.key, onTap: () => setState(() => _type = e.key)),
    ]);

    return AsyncBody<List<Event>>(
      value: events,
      onRefresh: () {
        ref.invalidate(eventSummaryProvider);
        return ref.refresh(activityProvider(_type).future);
      },
      builder: (list) => ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const _WeekStats(),
          const _RunSummary(),
          SectionHeader(l.analyticsEvents, trailing: list.isEmpty ? null : Text('${list.length}')),
          chips,
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: list.isEmpty
                ? Container(
                    decoration: BoxDecoration(color: c.surface, border: Border.all(color: c.line), borderRadius: BorderRadius.circular(16)),
                    child: EmptyState(title: l.mobileNoEvents),
                  )
                : ListGroup(children: [for (final e in list) _EventRow(e)]),
          ),
          // The log's last 90 days as a file, like the Logs page's buttons.
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(children: [
              Expanded(child: OutlinedButton(onPressed: () => _export('json'), child: Text(l.logsExportJson))),
              const SizedBox(width: 10),
              Expanded(child: OutlinedButton(onPressed: () => _export('csv'), child: Text(l.logsExportCsv))),
            ]),
          ),
        ],
      ),
    );
  }

  Future<void> _export(String format) async {
    final l = AppLocalizations.of(context);
    String text;
    try {
      text = (await ref.read(apiProvider)!.getLogsApi().exportEvents(format: format)).data ?? '';
    } catch (e) {
      if (mounted) showSnack(context, errorMessage(e, l.commonError));
      return;
    }
    if (!mounted) return;
    final csv = format == 'csv';
    await saveTextFile(context, csv ? 'agnts-events.csv' : 'agnts-events.jsonl', text, csv ? 'text/csv' : 'application/x-ndjson');
  }
}

/// Run statistics and where the time goes, per step (the Logs page's cards).
class _RunSummary extends ConsumerWidget {
  const _RunSummary();

  static const _steps = [
    (TicketState.analyzing, false),
    (TicketState.waitingForAnswers, true),
    (TicketState.coding, false),
    (TicketState.testing, false),
    (TicketState.waitingForReview, true),
    (TicketState.pushing, false),
  ];

  /// "45s", "5m", "2h 3m".
  static String _dur(int ms) => ms < 60000 ? '${(ms / 1000).round()}s' : shortDuration(Duration(milliseconds: ms));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final s = ref.watch(eventSummaryProvider).value;
    if (s == null) return const SizedBox.shrink();
    final by = {for (final x in s.steps) x.state: x};
    final top = s.steps.fold<int>(1, (m, x) => (x.avgMs ?? 0) > m ? x.avgMs! : m);
    final rate = s.runsStarted == 0 ? 0 : (s.reachedReview * 100 / s.runsStarted).round();
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      SectionHeader(l.logsPeriod),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Grid2(children: [
          KpiCard(label: l.logsRunsStarted, value: '${s.runsStarted}', note: l.logsRunsNote),
          KpiCard(label: l.logsReached, value: '$rate%', note: l.logsReachedNote('${s.reachedReview}', '${s.runsStarted}')),
          KpiCard(label: l.logsAvgTurns, value: '${s.avgTurns}', note: l.logsAvgTurnsNote),
          KpiCard(label: l.logsStops, value: '${s.stops}', valueColor: s.stops > 0 ? c.badInk : null, note: l.logsStopsNote(s.errors)),
        ]),
      ),
      SectionHeader(l.logsWhereTime),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: HCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(l.logsWhereTimeSub, style: TextStyle(fontSize: 13.5, color: c.ink3)),
            const SizedBox(height: 6),
            for (final (state, you) in _steps)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  Row(children: [
                    Expanded(
                      child: Text.rich(TextSpan(children: [
                        TextSpan(text: stateLabelOf(l, state)),
                        if ((by[state]?.count ?? 0) > 0) TextSpan(text: ' (${by[state]!.count})', style: TextStyle(color: c.ink3)),
                      ]), style: TextStyle(fontSize: 13.5, color: c.ink)),
                    ),
                    Text(
                      by[state]?.avgMs == null ? l.logsNoData : _dur(by[state]!.avgMs!),
                      style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: c.ink),
                    ),
                  ]),
                  const SizedBox(height: 4),
                  Bar(value: (by[state]?.avgMs ?? 0) / top, tone: you ? Tone.warn : Tone.info),
                ]),
              ),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Wrap(spacing: 14, children: [
                for (final (tone, label) in [(Tone.info, l.logsLegendAgnts), (Tone.warn, l.logsLegendYou)])
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    Container(width: 10, height: 10, decoration: BoxDecoration(color: tone.solid(c), borderRadius: BorderRadius.circular(3))),
                    const SizedBox(width: 5),
                    Text(label, style: TextStyle(fontSize: 12.5, color: c.ink3)),
                  ]),
              ]),
            ),
          ]),
        ),
      ),
    ]);
  }
}

/// One feed row (.fe): mono time on the left; ticket key, kind badge and
/// origin on top; the message underneath, red and bold for errors.
class _EventRow extends StatelessWidget {
  const _EventRow(this.e);
  final Event e;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final (label, tone) = _kind(l, e);
    final error = e.level == EventLevelEnum.error;
    final warn = e.level == EventLevelEnum.warn;
    final mono = TextStyle(fontFamily: AgntsFonts.mono, fontSize: 12.5, color: c.ink3);
    final row = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Text(_time(context, e.createdAt.toLocal()), style: mono.copyWith(fontSize: 12)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Wrap(spacing: 8, runSpacing: 4, crossAxisAlignment: WrapCrossAlignment.center, children: [
              if (e.ticketKey.isNotEmpty) Text(e.ticketKey, style: mono),
              ToneBadge(label, tone, small: true),
              Text(e.origin.value, style: mono.copyWith(fontSize: 11.5)),
            ]),
            const SizedBox(height: 4),
            Text(
              e.message,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                color: error ? c.badInk : warn ? c.warnInk : c.ink,
                fontWeight: error ? FontWeight.w700 : null,
              ),
            ),
          ]),
        ),
      ]),
    );
    if (e.ticketKey.isEmpty) return row;
    return InkWell(onTap: () => context.push('/tickets/${e.ticketKey}'), child: row);
  }
}

/// The event's kind badge, grouped like the admin's Logs page.
(String, Tone) _kind(AppLocalizations l, Event e) {
  const userOrigins = {EventOriginEnum.web, EventOriginEnum.mobile, EventOriginEnum.mcp, EventOriginEnum.telegram};
  if (e.level == EventLevelEnum.error) return (l.logsTypeError, Tone.bad);
  if (userOrigins.contains(e.origin)) return (l.logsTypeYou, Tone.warn);
  return switch (e.type) {
    'state_changed' => (l.logsTypeState, Tone.info),
    'claude_tool' || 'claude_text' || 'claude_result' => (l.logsTypeTool, Tone.gray),
    'check' || 'pushed' || 'pr_opened' || 'tracker_comment' => (l.logsTypeCommand, Tone.gray),
    'rate_limit' || 'usage_updated' => (l.logsTypeLimit, e.level == EventLevelEnum.warn ? Tone.warn : Tone.ok),
    _ => (l.logsTypeEvent, Tone.gray),
  };
}

/// Today: HH:mm:ss; yesterday: HH:mm; older: weekday and HH:mm.
String _time(BuildContext context, DateTime t) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final hm = DateFormat.Hm(Localizations.localeOf(context).toString());
  if (!t.isBefore(today)) return DateFormat.Hms(Localizations.localeOf(context).toString()).format(t);
  if (!t.isBefore(today.subtract(const Duration(days: 1)))) return hm.format(t);
  return '${DateFormat.E(Localizations.localeOf(context).toString()).format(t)} ${hm.format(t)}';
}

/// Seven-day summary from the analytics endpoint (.stats).
class _WeekStats extends ConsumerWidget {
  const _WeekStats();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final a = ref.watch(analyticsProvider).value;
    if (a == null) return const SizedBox.shrink();
    final cur = a.current;
    final firstTry = cur.pushed == 0 ? 0 : (cur.firstTry * 100 / cur.pushed).round();
    Widget stat(String label, String value) => Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(color: c.surface, border: Border.all(color: c.line), borderRadius: BorderRadius.circular(14)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12.5, color: c.ink3)),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(value, style: TextStyle(fontFamily: AgntsFonts.display, fontSize: 22, fontWeight: FontWeight.w700, color: c.ink)),
              ),
            ]),
          ),
        );
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      SectionHeader(l.mobileLastDays, padding: const EdgeInsets.fromLTRB(20, 4, 20, 8)),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            stat(l.mobilePushed, '${cur.pushed}'),
            const SizedBox(width: 10),
            stat(l.mobileFirstTry, '$firstTry%'),
            const SizedBox(width: 10),
            stat(l.mobileWaitingAvg, l.mobileMinutes(cur.waitMin.round().toString())),
          ]),
        ),
      ),
    ]);
  }
}
