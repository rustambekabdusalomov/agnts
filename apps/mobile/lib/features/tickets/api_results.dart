import 'package:agnts_api/agnts_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/data.dart';
import '../../l10n/app_localizations.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import '../../widgets/ui.dart';

/// Tone per verdict, as in the admin panel.
Tone verdictTone(ApiCaseVerdictEnum v) => switch (v) {
  ApiCaseVerdictEnum.pass => Tone.ok,
  ApiCaseVerdictEnum.fail => Tone.bad,
  ApiCaseVerdictEnum.blocked => Tone.warn,
  ApiCaseVerdictEnum.skipped => Tone.gray,
};

String verdictLabel(AppLocalizations l, ApiCaseVerdictEnum v) => switch (v) {
  ApiCaseVerdictEnum.pass => l.swaggerVerdict_pass,
  ApiCaseVerdictEnum.fail => l.swaggerVerdict_fail,
  ApiCaseVerdictEnum.blocked => l.swaggerVerdict_blocked,
  ApiCaseVerdictEnum.skipped => l.swaggerVerdict_skipped,
};

/// Failures first, then blocked, passed and skipped.
const verdictOrder = [ApiCaseVerdictEnum.fail, ApiCaseVerdictEnum.blocked, ApiCaseVerdictEnum.pass, ApiCaseVerdictEnum.skipped];

/// The counts of a run as badges.
class ApiCountBadges extends StatelessWidget {
  const ApiCountBadges(this.counts, {super.key});
  final ApiCounts counts;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Wrap(spacing: 6, runSpacing: 6, children: [
      ToneBadge(l.swaggerCount_pass('${counts.passed}'), Tone.ok, small: true),
      ToneBadge(l.swaggerCount_fail('${counts.failed}'), Tone.bad, small: true),
      if (counts.skipped > 0) ToneBadge(l.swaggerCount_skipped('${counts.skipped}'), Tone.gray, small: true),
      if (counts.blocked > 0) ToneBadge(l.swaggerCount_blocked('${counts.blocked}'), Tone.warn, small: true),
    ]);
  }
}

/// A Swagger test's results on the ticket screen: the counts, what is new
/// since the last run, and the failures. Read-only: the details and the
/// follow-ups are in the admin panel.
class ApiResultsFold extends ConsumerWidget {
  const ApiResultsFold({super.key, required this.ticketKey});
  final String ticketKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final r = ref.watch(apiResultsProvider(ticketKey)).value;
    if (r == null || r.runId == null || r.counts == null) return const SizedBox.shrink();
    return Fold(
      title: l.swaggerTab,
      hint: '${r.counts!.passed}/${r.cases.length}',
      initiallyOpen: true,
      child: ApiResultsBody(results: r, limit: 5, onMore: () => context.push('/tickets/$ticketKey/api-results')),
    );
  }
}

/// The counts, new failures and failing cases.
class ApiResultsBody extends StatelessWidget {
  const ApiResultsBody({super.key, required this.results, this.limit, this.onMore});
  final SwaggerResults results;
  final int? limit;
  final VoidCallback? onMore;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final r = results;
    final hint = TextStyle(fontSize: 13, color: c.ink3, height: 1.4);
    final cases = [...r.cases]..sort((a, b) => verdictOrder.indexOf(a.verdict).compareTo(verdictOrder.indexOf(b.verdict)));
    final failing = cases.where((x) => x.verdict == ApiCaseVerdictEnum.fail || x.verdict == ApiCaseVerdictEnum.blocked).toList();
    final shown = limit == null ? cases : failing.take(limit!).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(r.test.baseUrl, style: const TextStyle(fontWeight: FontWeight.w700)),
      const SizedBox(height: 4),
      Text(r.test.writeEnabled ? l.swaggerModeWrite : l.swaggerModeRead, style: hint),
      const SizedBox(height: 10),
      if (r.counts != null) ApiCountBadges(r.counts!),
      if (r.summary != null) ...[const SizedBox(height: 8), Text(r.summary!)],
      if (r.previous != null) ...[
        const SizedBox(height: 8),
        Text(
          r.newFailures.isEmpty ? l.swaggerNoNewFailures : '${l.swaggerNewFailures(r.newFailures.length)}: ${r.newFailures.join('; ')}',
          style: hint.copyWith(color: r.newFailures.isEmpty ? c.ink3 : c.badInk),
        ),
      ],
      const SizedBox(height: 8),
      if (failing.isEmpty && limit != null) Text(l.swaggerAllPassed, style: hint),
      for (final x in shown) _CaseRow(x),
      if (onMore != null && limit != null && (failing.length > limit! || cases.length > failing.length))
        Align(alignment: Alignment.centerLeft, child: TextButton(onPressed: onMore, child: Text(l.swaggerTab))),
    ]);
  }
}

class _CaseRow extends StatelessWidget {
  const _CaseRow(this.x);
  final ApiCase x;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Wrap(spacing: 6, runSpacing: 4, crossAxisAlignment: WrapCrossAlignment.center, children: [
          ToneBadge(verdictLabel(l, x.verdict), verdictTone(x.verdict), small: true),
          if (x.source_ == ApiCaseSource_Enum.schema) ToneBadge(l.swaggerAgntsCheck, Tone.info, small: true),
          Text(x.operation, style: const TextStyle(fontFamily: 'monospace', fontSize: 12.5, fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 2),
        Text(x.case_, style: const TextStyle(fontWeight: FontWeight.w600)),
        if (x.expected != null) Text(l.swaggerExpected(x.expected!), style: TextStyle(fontSize: 13, color: c.ink3)),
        if (x.reason != null) Text(x.reason!, style: TextStyle(fontSize: 13, color: c.ink2)),
        if (x.requests.isNotEmpty) Text(x.requests.join(', '), style: TextStyle(fontSize: 12, color: c.ink3, fontFamily: 'monospace')),
      ]),
    );
  }
}

/// Every case of a Swagger test's latest run, failures first. Push
/// notifications about a finished test open here.
class ApiResultsScreen extends ConsumerWidget {
  const ApiResultsScreen({super.key, required this.ticketKey});
  final String ticketKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final res = ref.watch(apiResultsProvider(ticketKey));
    return Scaffold(
      backgroundColor: c.bg,
      appBar: DetailBar(
        backLabel: l.navBack,
        title: '$ticketKey · ${l.swaggerTab}',
        onBack: () => context.canPop() ? context.pop() : context.go('/tickets/$ticketKey'),
      ),
      body: AsyncBody<SwaggerResults>(
        value: res,
        onRefresh: () => ref.refresh(apiResultsProvider(ticketKey).future),
        builder: (r) => ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            if (r.runId == null)
              Text(l.swaggerNoRun, style: TextStyle(color: c.ink3))
            else
              HCard(child: ApiResultsBody(results: r)),
            const SizedBox(height: 12),
            TextButton(onPressed: () => context.push('/tickets/$ticketKey'), child: Text(ticketKey)),
          ],
        ),
      ),
    );
  }
}
