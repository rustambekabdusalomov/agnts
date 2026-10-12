import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:agnts_api/agnts_api.dart';

import '../../core/data.dart';
import '../../l10n/app_localizations.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import '../../widgets/ui.dart';
import 'ci_sample.dart';

/// CI failures on watched branches, one group per error: red ones first,
/// or the flaky ones, or all. Opened from More.
class CIFailuresScreen extends ConsumerStatefulWidget {
  const CIFailuresScreen({super.key});

  @override
  ConsumerState<CIFailuresScreen> createState() => _CIFailuresScreenState();
}

class _CIFailuresScreenState extends ConsumerState<CIFailuresScreen> {
  String _filter = 'red';

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final failures = ref.watch(ciFailuresProvider(_filter));
    return Scaffold(
      backgroundColor: c.bg,
      appBar: DetailBar(backLabel: l.navBack, onBack: () => context.canPop() ? context.pop() : context.go('/more')),
      body: AsyncBody<List<CIFailure>>(
        value: failures,
        onRefresh: () => ref.refresh(ciFailuresProvider(_filter).future),
        builder: (list) => ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            PageHeader(title: l.mciTitle, sub: l.mciLede),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Segmented<String>(
                full: true,
                options: [('red', l.mciFilterRed), ('flaky', l.mciFilterFlaky), ('all', l.mciFilterAll)],
                value: _filter,
                onChanged: (v) => setState(() => _filter = v),
              ),
            ),
            if (list.isEmpty)
              EmptyState(title: _filter == 'red' ? l.mciEmptyRed : l.mciEmpty)
            else
              for (final f in list) Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 10), child: CIFailureCard(f)),
          ],
        ),
      ),
    );
  }
}

/// "just now" / "5m ago".
String ciAgo(AppLocalizations l, DateTime at) {
  final d = DateTime.now().difference(at);
  return d.inMinutes < 1 ? l.mmoreJustNow : l.mmoreAgo(shortDuration(d));
}

/// A failure group as a card: status and how often it failed, repository
/// and branch, the error, then the job, when it last failed and its ticket.
class CIFailureCard extends StatelessWidget {
  const CIFailureCard(this.f, {super.key});
  final CIFailure f;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final (status, tone) = ciStatusBadge(l, f.status);
    return HCard(
      onTap: () => context.push('/ci/${f.id}'),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          ToneBadge(status, tone),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${f.repo} · ${f.branch}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontFamily: AgntsFonts.mono, fontSize: 12.5, color: c.ink3),
            ),
          ),
          Text('×${f.count}', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: c.ink2)),
        ]),
        const SizedBox(height: 6),
        Text(
          f.title,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, height: 1.3, color: c.ink),
        ),
        const SizedBox(height: 8),
        DefaultTextStyle.merge(
          style: TextStyle(fontSize: 13, color: c.ink3),
          child: Wrap(spacing: 8, runSpacing: 4, crossAxisAlignment: WrapCrossAlignment.center, children: [
            if (f.job.isNotEmpty) SourceChip(f.job),
            Text(l.mciLastSeen(ciAgo(l, f.lastSeenAt))),
            if (f.ticketKey.isNotEmpty) ...[
              Text(f.ticketKey, style: TextStyle(fontFamily: AgntsFonts.mono, fontSize: 12.5, color: c.ink2)),
              if (f.ticketState != null) ToneBadge(stateLabel(l, f.ticketState!), stateTone(f.ticketState!), small: true),
            ],
          ]),
        ),
      ]),
    );
  }
}
