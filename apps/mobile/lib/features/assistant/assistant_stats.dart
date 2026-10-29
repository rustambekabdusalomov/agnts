import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:agnts_api/agnts_api.dart';

import '../../l10n/app_localizations.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import '../../widgets/ui.dart';
import '../tickets/kinds.dart' show ReportMarkdown;
import 'assistant_data.dart';

String _secs(int ms) => '${(ms / 1000).toStringAsFixed(ms < 10000 ? 1 : 0)}s';

/// The Assistant section of Analytics, for the workspace's owner: how many
/// questions, how many got an answer, how fast, how they were rated, what
/// became of the actions answers proposed, and the same per prompt version.
class AssistantStatsSection extends ConsumerWidget {
  const AssistantStatsSection({super.key, required this.days});
  final int days;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final value = ref.watch(assistantStatsProvider(days));
    final st = value.value;
    // Not on this server, or not loaded: no section rather than an error.
    if (st == null) return const SizedBox.shrink();
    final pad = const EdgeInsets.symmetric(horizontal: 16);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(l.massistantStatsTitle, trailing: st.questions == 0 ? null : Text(l.massistantStatsPeople(st.people))),
        if (st.questions == 0)
          Padding(
            padding: pad,
            child: HCard(
              child: Text(l.massistantStatsNone, style: TextStyle(color: c.ink3)),
            ),
          )
        else ...[
          Padding(
            padding: pad,
            child: Grid2(
              children: [
                KpiCard(label: l.massistantStatsQuestions, value: '${st.questions}'),
                KpiCard(
                  label: l.massistantStatsAnswered,
                  value: '${(st.answered * 100 / st.questions).round()}%',
                  note: '${st.answered} / ${st.questions}',
                ),
                KpiCard(label: l.massistantStatsMedian, value: _secs(st.medianMs), note: 'p90 ${_secs(st.p90Ms)}'),
                KpiCard(
                  label: l.massistantStatsHelpful,
                  value: st.up + st.down == 0 ? '—' : '${(st.up * 100 / (st.up + st.down)).round()}%',
                  note: '${st.up} 👍  ${st.down} 👎',
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: pad,
            child: HCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.massistantStatsParts(_secs(st.medianStartMs), _secs(st.medianSnapshotMs), _secs(st.medianClaudeMs)),
                    style: TextStyle(fontSize: 14, color: c.ink2),
                  ),
                  const SizedBox(height: 4),
                  Text(l.massistantStatsWarm('${st.warm}', '${st.answered}'), style: TextStyle(fontSize: 13, color: c.ink3)),
                  const SizedBox(height: 4),
                  Text(
                    '${l.massistantStatsTokens}: ${st.tokens} · \$${st.costUsd.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 13, color: c.ink3),
                  ),
                  if (st.actions.proposed + st.actions.notOffered > 0) ...[
                    const SizedBox(height: 12),
                    Text(
                      '${l.massistantStatsActions}: '
                      '${st.actions.proposed == 0 ? '—' : '${(st.actions.done * 100 / st.actions.proposed).round()}%'}',
                      style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: c.ink2),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l.massistantStatsActionsLine(
                        '${st.actions.proposed}',
                        '${st.actions.done}',
                        '${st.actions.failed}',
                        '${st.actions.cancelled}',
                        '${st.actions.expired}',
                        '${st.actions.notOffered}',
                      ),
                      style: TextStyle(fontSize: 13, color: c.ink3),
                    ),
                  ],
                  if (st.versions.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      l.massistantStatsVersions,
                      style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: c.ink3),
                    ),
                    for (final v in st.versions)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              v.promptVersion.isEmpty ? '—' : v.promptVersion,
                              style: TextStyle(fontFamily: AgntsFonts.mono, fontSize: 12.5, color: c.ink2),
                            ),
                            Text(
                              l.massistantStatsVersionRow('${v.answered}', '${v.failed}', '${v.up}', '${v.down}', _secs(v.medianMs)),
                              style: TextStyle(fontSize: 13, color: c.ink3),
                            ),
                            if (v.proposed > 0)
                              Text(
                                l.massistantStatsVersionActions('${v.proposed}', '${v.done}'),
                                style: TextStyle(fontSize: 13, color: c.ink3),
                              ),
                          ],
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: pad,
            child: ListGroup(
              children: [
                ListRow(
                  leading: HIcon('feedback', size: 22, color: c.primary),
                  title: l.massistantStatsSeeRated,
                  value: '${st.up + st.down}',
                  onTap: () => context.push('/assistant-rated'),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// Rated answers with their questions and comments (the workspace's owner).
class AssistantRatedScreen extends ConsumerWidget {
  const AssistantRatedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    return Scaffold(
      backgroundColor: c.bg,
      appBar: DetailBar(backLabel: l.navBack, onBack: () => context.canPop() ? context.pop() : context.go('/analytics')),
      body: AsyncBody<List<AssistantRated>>(
        value: ref.watch(assistantRatedProvider),
        onRefresh: () => ref.refresh(assistantRatedProvider.future),
        builder: (list) => ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            PageHeader(title: l.massistantStatsRated),
            if (list.isEmpty) EmptyState(title: l.massistantRatedEmpty),
            for (final r in list)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: HCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            r.rating == AssistantRatedRatingEnum.number1 ? Icons.thumb_up_alt : Icons.thumb_down_alt,
                            size: 18,
                            color: r.rating == AssistantRatedRatingEnum.number1 ? c.okInk : c.badInk,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              r.user,
                              style: TextStyle(fontWeight: FontWeight.w700, color: c.ink),
                            ),
                          ),
                          Text(
                            r.promptVersion,
                            style: TextStyle(fontFamily: AgntsFonts.mono, fontSize: 12, color: c.ink3),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        r.question,
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: c.ink),
                      ),
                      const SizedBox(height: 6),
                      ReportMarkdown(r.answer),
                      for (final a in r.actions ?? const <AssistantAction>[]) _RatedAction(a),
                      if (r.comment.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          '“${r.comment}”',
                          style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: c.ink2),
                        ),
                      ],
                      if (r.shared) ...[const SizedBox(height: 6), ToneBadge(l.massistantRatedShared, Tone.info, small: true)],
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// An action a rated answer proposed, with what became of it.
class _RatedAction extends StatelessWidget {
  const _RatedAction(this.a);
  final AssistantAction a;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final status = a.status == AssistantActionStatusEnum.proposed && !actionWaits(a) ? AssistantActionStatusEnum.expired : a.status;
    final (label, color) = switch (status) {
      AssistantActionStatusEnum.proposed => (l.massistantStatsActionsOffered, c.ink3),
      AssistantActionStatusEnum.running => (l.massistantActionRunning, c.ink3),
      AssistantActionStatusEnum.done => (l.massistantActionDone, c.okInk),
      AssistantActionStatusEnum.failed => (l.massistantActionFailed, c.badInk),
      AssistantActionStatusEnum.cancelled => (l.massistantActionCancelled, c.ink3),
      AssistantActionStatusEnum.expired => (l.massistantActionExpired, c.ink3),
    };
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: c.bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: c.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(a.summary, style: TextStyle(fontSize: 13.5, color: c.ink)),
          const SizedBox(height: 4),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: label,
                  style: TextStyle(fontWeight: FontWeight.w700, color: color),
                ),
                if (a.result != null && a.result!.isNotEmpty)
                  TextSpan(
                    text: ' · ${a.result}',
                    style: TextStyle(color: c.ink2),
                  ),
              ],
            ),
            style: const TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }
}

/// Whether the person owns the workspace (sees the assistant's stats).
bool isOwner(WorkspaceSummary? w) => w?.role == WorkspaceRole.owner;
