import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:agnts_api/agnts_api.dart';

import '../../core/data.dart';
import '../../l10n/app_localizations.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import '../../widgets/ui.dart';
import '../ci/ci_screen.dart' show ciAgo;

/// What the log watcher found in the projects' logs: errors or security
/// problems that need attention, or all. Opened from More and from a
/// finding's push.
class LogWatcherScreen extends ConsumerStatefulWidget {
  const LogWatcherScreen({super.key});

  @override
  ConsumerState<LogWatcherScreen> createState() => _LogWatcherScreenState();
}

class _LogWatcherScreenState extends ConsumerState<LogWatcherScreen> {
  String _category = 'error';

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final findings = ref.watch(logFindingsProvider(_category));
    return Scaffold(
      backgroundColor: c.bg,
      appBar: DetailBar(backLabel: l.navBack, onBack: () => context.canPop() ? context.pop() : context.go('/more')),
      body: AsyncBody<List<LogFinding>>(
        value: findings,
        onRefresh: () => ref.refresh(logFindingsProvider(_category).future),
        builder: (list) => ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            PageHeader(title: l.mlogsTitle, sub: l.mlogsLede),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Segmented<String>(
                full: true,
                options: [('error', l.mlogsErrors), ('security', l.mlogsSecurity)],
                value: _category,
                onChanged: (v) => setState(() => _category = v),
              ),
            ),
            if (list.isEmpty)
              EmptyState(title: l.mlogsEmpty)
            else
              for (final f in list) Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 10), child: LogFindingCard(f)),
          ],
        ),
      ),
    );
  }
}

/// A finding's status label and tone.
(String, Tone) logStatusBadge(AppLocalizations l, LogFindingStatus s) => switch (s) {
  LogFindingStatus.open => (l.mlogsStatusOpen, Tone.warn),
  LogFindingStatus.reported => (l.mlogsStatusReported, Tone.bad),
  LogFindingStatus.fixing => (l.mlogsStatusFixing, Tone.info),
  LogFindingStatus.fixed => (l.mlogsStatusFixed, Tone.ok),
  LogFindingStatus.resolved => (l.mlogsStatusResolved, Tone.ok),
  LogFindingStatus.muted => (l.mlogsStatusMuted, Tone.gray),
  LogFindingStatus.regression => (l.mlogsStatusRegression, Tone.bad),
};

/// A finding as a card: status, service and how often, the title, then the
/// severity, when last seen and its ticket. The title is log text: shown,
/// never acted on.
class LogFindingCard extends StatelessWidget {
  const LogFindingCard(this.f, {super.key});
  final LogFinding f;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final (status, tone) = logStatusBadge(l, f.status);
    return HCard(
      onTap: () => context.push('/log-watcher/${f.id}'),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ToneBadge(status, tone),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  f.repos.isEmpty ? f.service : '${f.service} · ${f.repos.join(', ')}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontFamily: AgntsFonts.mono, fontSize: 12.5, color: c.ink3),
                ),
              ),
              Text('×${f.count}', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: c.ink2)),
            ],
          ),
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
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SourceChip(f.severity.value),
                Text(l.mlogsLastSeen(ciAgo(l, f.lastSeenAt))),
                if (f.ticketKey.isNotEmpty) ...[
                  Text(f.ticketKey, style: TextStyle(fontFamily: AgntsFonts.mono, fontSize: 12.5, color: c.ink2)),
                  if (f.ticketState != null) ToneBadge(stateLabel(l, f.ticketState!), stateTone(f.ticketState!), small: true),
                ] else if (f.repoIds.isEmpty)
                  Text(l.mlogsReportOnly),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
