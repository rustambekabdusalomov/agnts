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
import '../admin/admin_data.dart' show agoText;
import '../tickets/spend.dart';

/// The tickets that used most of the plan over [days] days (top ten).
final ticketSpendProvider = FutureProvider.family<TicketSpendList, int>((ref, days) async {
  return (await requireApi(ref).getUsageApi().getTicketSpend(days: days, limit: 10)).data!;
});

String _stageLabel(AppLocalizations l, TicketSpendRowTopStageEnum s) => switch (s) {
  TicketSpendRowTopStageEnum.analyze => l.spendStageAnalyze,
  TicketSpendRowTopStageEnum.coding => l.spendStageCoding,
  TicketSpendRowTopStageEnum.retry => l.spendStageRetry,
  TicketSpendRowTopStageEnum.review => l.spendStageReview,
  TicketSpendRowTopStageEnum.preview => l.spendStagePreview,
  TicketSpendRowTopStageEnum.learn => l.spendStageLearn,
  TicketSpendRowTopStageEnum.helper => l.spendStageHelper,
};

String _status(AppLocalizations l, UsageStatusEnum? s) => switch (s) {
  UsageStatusEnum.allowed => l.usageStatus_allowed,
  UsageStatusEnum.allowedWarning => l.usageStatus_allowed_warning,
  UsageStatusEnum.rejected => l.usageStatus_rejected,
  _ => l.usageStatus_unknown,
};

/// Plan usage (the admin panel's Usage page): the session and week limits,
/// the tickets that spent the most, and what agnts does near a limit.
class UsageScreen extends ConsumerStatefulWidget {
  const UsageScreen({super.key});

  @override
  ConsumerState<UsageScreen> createState() => _UsageScreenState();
}

class _UsageScreenState extends ConsumerState<UsageScreen> {
  int _days = 30;
  bool _refreshing = false;

  Future<void> _refresh() async {
    final l = AppLocalizations.of(context);
    setState(() => _refreshing = true);
    try {
      await ref.read(apiProvider)!.getUsageApi().refreshUsage();
      ref.invalidate(usageProvider);
      if (mounted) showSnack(context, l.usageRefreshStarted);
    } catch (e) {
      if (mounted) showSnack(context, errorMessage(e, l.commonError));
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  /// "Resets in 2h 5m", or the weekday and time when more than a day away.
  String _reset(AppLocalizations l, String locale, DateTime? at) {
    if (at == null) return l.usageNoReset;
    final d = at.difference(DateTime.now());
    if (d.isNegative) return l.usageResettingNow;
    if (d.inHours >= 24) return l.usageResetsAt(DateFormat('E HH:mm', locale).format(at.toLocal()));
    final h = d.inHours, m = d.inMinutes % 60;
    return l.usageResetsIn(h > 0 ? '${h}h ${m}m' : '${m}m');
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final locale = Localizations.localeOf(context).toString();
    final usage = ref.watch(usageProvider);
    final settings = ref.watch(settingsProvider).value;
    final u = usage.value;
    Widget pad(Widget w) => Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: w);

    return Scaffold(
      appBar: DetailBar(backLabel: l.navBack, onBack: () => context.canPop() ? context.pop() : context.go('/more')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(settingsProvider);
          ref.invalidate(ticketSpendProvider(_days));
          ref.invalidate(usageProvider);
          await ref.read(usageProvider.future);
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 28),
          children: [
            PageHeader(title: l.usageTitle, sub: l.usageLede),
            SectionHeader(
              l.usageCard,
              trailing: TextButton(
                onPressed: u?.refreshing == true || _refreshing ? null : _refresh,
                child: Text(u?.refreshing == true ? l.usageRefreshing : l.usageRefresh),
              ),
            ),
            pad(
              HCard(
                child: usage.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (e, _) => Text(errorMessage(e, l.commonError), style: TextStyle(color: c.badInk)),
                  data: (u) => Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        u.updatedAt == null ? l.usageNoReading : l.usageUpdated(agoText(context, u.updatedAt)),
                        style: TextStyle(fontSize: 13.5, color: c.ink3),
                      ),
                      const SizedBox(height: 6),
                      UsageBar(label: l.usageSession, utilization: u.fiveHour.utilization, note: _reset(l, locale, u.fiveHour.resetsAt)),
                      const SizedBox(height: 6),
                      UsageBar(label: l.usageWeek, utilization: u.sevenDay.utilization, note: _reset(l, locale, u.sevenDay.resetsAt)),
                      const SizedBox(height: 6),
                      Fact(l.usageStatus, _status(l, u.status)),
                      if (u.paused) ...[
                        const SizedBox(height: 10),
                        HelpBox(
                          u.pausedUntil == null
                              ? l.usagePausedNoTime
                              : l.usagePaused(DateFormat('E HH:mm', locale).format(u.pausedUntil!.toLocal())),
                          tone: Tone.bad,
                        ),
                      ] else if ((u.fiveHour.utilization ?? 0) >= 0.8) ...[
                        const SizedBox(height: 10),
                        HelpBox(l.usageWarn80, tone: Tone.warn),
                      ],
                      const SizedBox(height: 10),
                      Text(l.usageSource, style: TextStyle(fontSize: 12.5, color: c.ink3)),
                    ],
                  ),
                ),
              ),
            ),
            ..._spend(context),
            SectionHeader(l.usageLimitTitle),
            pad(
              HCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(l.usageLimitSub, style: TextStyle(fontSize: 13.5, color: c.ink3)),
                    const SizedBox(height: 8),
                    for (final (k, v) in [
                      (l.usageAbove('${u?.pauseAbove ?? settings?.pauseAbove ?? 90}'), l.usageAboveDo),
                      (l.usageMidRun, l.usageMidRunDo),
                      (l.usageAfterReset, settings?.autoResume == false ? l.usageResumeManual : l.usageResumeAuto),
                      (l.usageIdle, l.usageIdleDo),
                    ])
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              k,
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: c.ink),
                            ),
                            const SizedBox(height: 2),
                            Text(v, style: TextStyle(fontSize: 14, color: c.ink2)),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Padding(padding: const EdgeInsets.fromLTRB(16, 14, 16, 0), child: HelpBox(l.usageHelp)),
          ],
        ),
      ),
    );
  }

  /// The tickets by spend (the admin panel's TicketSpendCard).
  List<Widget> _spend(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final loc = Localizations.localeOf(context).toLanguageTag();
    final value = ref.watch(ticketSpendProvider(_days));
    final v = value.value;
    final total = v?.total.costUsd ?? 0;
    int share(double cost) => total > 0 ? (100 * cost / total).round() : 0;
    return [
      SectionHeader(l.spendTopTitle),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        child: Segmented<int>(
          full: true,
          options: [
            for (final d in const [7, 30, 90]) (d, l.analyticsDays(d)),
          ],
          value: _days,
          onChanged: (d) => setState(() => _days = d),
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
        child: Text(
          v != null && v.tickets.isNotEmpty
              ? l.spendTopSub(fmtTokens(ioTokens(v.total), loc), fmtUsd(v.total.costUsd, loc))
              : l.spendTopSubEmpty,
          style: TextStyle(fontSize: 13.5, color: c.ink3),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: switch (value) {
          AsyncError() => HCard(
            child: Text(l.commonError, style: TextStyle(color: c.badInk)),
          ),
          AsyncData(:final value) when value.tickets.isEmpty => HCard(
            child: Text(l.spendTopEmpty, style: TextStyle(color: c.ink3)),
          ),
          AsyncData(:final value) => ListGroup(
            children: [
              for (final x in value.tickets)
                InkWell(
                  onTap: () => context.push('/tickets/${x.key}'),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                x.key,
                                style: TextStyle(fontFamily: AgntsFonts.mono, fontSize: 12.5, color: c.ink3),
                              ),
                            ),
                            ToneBadge(stateLabelOf(l, x.state, x.kind), stateTone(x.state), small: true),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          x.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: c.ink),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          [
                            '${l.spendColStage}: ${_stageLabel(l, x.topStage)}',
                            l.spendCalls(x.calls),
                            fmtTokens(ioTokens(x.spend), loc),
                            fmtUsd(x.spend.costUsd, loc),
                          ].join(' · '),
                          style: TextStyle(fontSize: 13, color: c.ink3),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(child: Bar(value: share(x.spend.costUsd) / 100)),
                            const SizedBox(width: 10),
                            Text(
                              '${share(x.spend.costUsd)}%',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: c.ink2),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          _ => const LinearProgressIndicator(),
        },
      ),
      if (v != null && v.tickets.isNotEmpty)
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          child: Text(l.spendTopNote, style: TextStyle(fontSize: 12.5, color: c.ink3)),
        ),
    ];
  }
}
