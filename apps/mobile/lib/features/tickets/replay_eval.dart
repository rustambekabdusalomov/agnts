import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:agnts_api/agnts_api.dart';

import '../../core/api.dart';
import '../../widgets/common.dart';
import '../../l10n/app_localizations.dart';
import '../../theme.dart';
import '../../widgets/ui.dart';
import 'spend.dart';

final replayReportProvider = FutureProvider.autoDispose<ReplayReport>((ref) async {
  return (await requireApi(ref).getAnalyticsApi().getReplayReport()).data!;
});

String _pct(num v) => '${(v * 100).round()}%';

String _verdict(AppLocalizations l, ReplayResultVerdictEnum v) => switch (v) {
      ReplayResultVerdictEnum.looksGood => l.replayVerdict_looks_good,
      ReplayResultVerdictEnum.hasConcerns => l.replayVerdict_has_concerns,
      ReplayResultVerdictEnum.needsChanges => l.replayVerdict_needs_changes,
    };

/// Replays re-run done tickets with the current agnts, from the commit each
/// started from; this compares them with the work people approved. Per
/// prompt version, then the recent replays.
class ReplayEvalCard extends ConsumerWidget {
  const ReplayEvalCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final q = ref.watch(replayReportProvider);
    final hint = TextStyle(fontSize: 13, height: 1.4, color: c.ink3);
    return HCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(l.replayEvalTitle, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: c.ink)),
        const SizedBox(height: 2),
        Text(l.replayEvalSub, style: hint),
        const SizedBox(height: 10),
        ...q.when(
          loading: () => [const LinearProgressIndicator()],
          error: (e, _) => [Text(errorMessage(e, l.commonError), style: TextStyle(color: c.badInk))],
          data: (r) => r.replays.isEmpty
              ? [Text(l.replayNone, style: hint)]
              : [
                  for (final v in r.versions)
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(border: Border.all(color: c.line), borderRadius: BorderRadius.circular(12)),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(v.promptVersion.isEmpty ? l.analyticsVersionUnknown : v.promptVersion,
                            style: TextStyle(fontFamily: AgntsFonts.mono, fontSize: 13, fontWeight: FontWeight.w700, color: c.ink)),
                        const SizedBox(height: 6),
                        Grid2(gap: 6, children: [
                          Fact(l.replayColReplays, '${v.replays}'),
                          Fact(l.replayColChecks, v.replays == 0 ? '—' : _pct(v.checksPassed / v.replays)),
                          Fact(l.replayColLooksGood, v.reviewed == 0 ? '—' : '${v.looksGood}/${v.reviewed}'),
                          Fact(l.replayColOverlap, _pct(v.avgOverlap)),
                          Fact(l.replayColRecall, _pct(v.avgRecall)),
                          Fact(l.replayColTurns, '${v.avgTurns.round()} (${v.originalTurns.round()})'),
                          Fact(l.replayColCost, '${fmtUsd(v.avgCostUsd.toDouble(), locale)} (${fmtUsd(v.originalCostUsd.toDouble(), locale)})'),
                        ]),
                      ]),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 6),
                    child: Text(l.replayRecent, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: c.ink3)),
                  ),
                  ListGroup(children: [
                    for (final x in r.replays.take(20))
                      ListRow(
                        title: '${x.key} · ${l.replayColOf} ${x.original}',
                        subtitle: [
                          stateLabel(l, x.state),
                          if (x.hasChange) '${l.replayColChecks}: ${x.checksPassed ? l.replayPass : l.replayFail}',
                          if (x.hasChange) '${l.replayColOverlap}: ${_pct(x.overlap)}',
                          if (x.verdict != null) '${l.replayColReview}: ${_verdict(l, x.verdict!)}',
                        ].join(' · '),
                        onTap: () => context.push('/tickets/${x.key}'),
                      ),
                  ]),
                ],
        ),
      ]),
    );
  }
}
