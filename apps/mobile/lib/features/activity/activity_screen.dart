import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:agnts_api/agnts_api.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../core/data.dart';
import '../../l10n/app_localizations.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import '../../widgets/ui.dart';

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
      onRefresh: () => ref.refresh(activityProvider(_type).future),
      builder: (list) => ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const _WeekStats(),
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
        ],
      ),
    );
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
