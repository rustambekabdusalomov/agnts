import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:agnts_api/agnts_api.dart';
import 'package:intl/intl.dart';

import '../../core/data.dart';
import '../../core/session.dart';
import '../../l10n/app_localizations.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import '../../widgets/ui.dart';
import '../tickets/tickets_screen.dart';

/// The Home tab (scrHome): greeting and date, four KPI tiles, what waits on
/// the user, the live runs and plan usage.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final user = ref.watch(sessionProvider).value?.username ?? '';
    final dash = ref.watch(dashboardProvider);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(children: [
          PageHeader(title: user.isEmpty ? l.mobileHome : _greeting(l, user), sub: _today(context)),
          Expanded(
            child: AsyncBody<Dashboard>(
              value: dash,
              onRefresh: () => ref.refresh(dashboardProvider.future),
              builder: (d) => _HomeBody(d),
            ),
          ),
        ]),
      ),
    );
  }

  String _greeting(AppLocalizations l, String name) {
    final h = DateTime.now().hour;
    if (h < 5) return l.dashboardGreetNight(name);
    if (h < 12) return l.dashboardGreetMorning(name);
    if (h < 18) return l.dashboardGreetAfternoon(name);
    return l.dashboardGreetEvening(name);
  }

  String _today(BuildContext context) {
    final now = DateTime.now();
    try {
      return toBeginningOfSentenceCase(DateFormat.MMMMEEEEd(Localizations.localeOf(context).toLanguageTag()).format(now));
    } catch (_) {
      return DateFormat.MMMMEEEEd().format(now);
    }
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody(this.d);
  final Dashboard d;

  // Opens the Tickets tab on a filter; the stamp makes each tap re-apply it.
  void _goTickets(BuildContext context, String filter) =>
      context.go(Uri(path: '/tickets', queryParameters: {'filter': filter, 'at': '${DateTime.now().millisecondsSinceEpoch}'}).toString());

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final n = d.counts;
    final session = d.usage.fiveHour.utilization;
    final sessionTone = session == null ? Tone.gray : session >= 1 ? Tone.bad : session >= 0.8 ? Tone.warn : Tone.info;
    final pushed = d.week.pushed, prev = d.lastWeek.pushed;
    final waiting = [...d.waiting]..sort((a, b) => (a.since ?? a.updatedAt).compareTo(b.since ?? b.updatedAt));

    return ListView(padding: const EdgeInsets.only(bottom: 24), children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Grid2(children: [
          KpiCard(
            label: l.mobileNeedsYou,
            value: '${n.needs}',
            valueColor: n.needs > 0 ? c.warnInk : null,
            note: l.dashboardNeedsNote('${n.answers}', '${n.reviews}', '${n.stopped}'),
            onTap: () => _goTickets(context, 'needs'),
          ),
          KpiCard(
            label: l.mobileRunningNow,
            value: '${n.running}',
            note: l.mhomeRunningNote('${d.parallel}', '${n.queued}'),
            onTap: () => _goTickets(context, n.running == 0 && n.queued > 0 ? 'queue' : 'running'),
          ),
          KpiCard(
            label: l.dashboardPushedWeek,
            value: '$pushed',
            delta: prev == 0 || pushed == prev ? null : Delta(_pct(pushed, prev), better: pushed > prev),
            note: l.dashboardPushedNote('$prev'),
            onTap: () => context.go('/analytics'),
          ),
          KpiCard(
            label: l.dashboardPlanSession,
            value: session == null ? '—' : '${(session * 100).round().clamp(0, 100)}%',
            valueColor: sessionTone == Tone.bad ? c.badInk : sessionTone == Tone.warn ? c.warnInk : null,
            bar: session ?? 0,
            barTone: sessionTone,
            note: resetText(l, d.usage.fiveHour.resetsAt),
            onTap: () => context.go('/more'),
          ),
        ]),
      ),
      if (d.usage.paused) Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 0), child: HelpBox(l.mobilePaused, tone: Tone.bad)),
      SectionHeader(l.dashboardWaitingTitle, trailing: Text('${waiting.length}')),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: waiting.isEmpty
            ? HelpBox(l.dashboardNothingWaiting, tone: Tone.ok)
            : _Stack([for (final t in waiting) ticketCardFor(context, t)]),
      ),
      SectionHeader(l.mobileLiveRuns, trailing: Text('${d.live.length}')),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: d.live.isEmpty
            ? HCard(child: Text(l.mobileNoRuns, style: TextStyle(color: c.ink3)))
            : _Stack([for (final r in d.live) ticketCardFor(context, r.ticket, live: r, showTurns: true)]),
      ),
      SectionHeader(l.mobileUsage),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: HCard(
          onTap: () => context.go('/more'),
          child: Column(children: [
            UsageBar(label: l.mobileSession, utilization: d.usage.fiveHour.utilization, note: resetText(l, d.usage.fiveHour.resetsAt)),
            const SizedBox(height: 6),
            UsageBar(label: l.mobileWeek, utilization: d.usage.sevenDay.utilization, note: resetText(l, d.usage.sevenDay.resetsAt)),
          ]),
        ),
      ),
    ]);
  }

  /// "+12%" / "−4%" change against last week.
  static String _pct(int cur, int prev) {
    final p = ((cur - prev) / prev * 100).round();
    return p > 0 ? '+$p%' : '−${p.abs()}%';
  }
}

/// Cards stacked with the demo's 10px gap (.stack).
class _Stack extends StatelessWidget {
  const _Stack(this.children);
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [for (final (i, w) in children.indexed) ...[if (i > 0) const SizedBox(height: 10), w]],
      );
}
