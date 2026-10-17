import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:agnts_api/agnts_api.dart';

import '../../core/api.dart';
import '../../l10n/app_localizations.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import '../../widgets/ui.dart';
import '../tickets/spend.dart' show fmtTokens, fmtUsd;
import 'admin_data.dart';
import 'admin_runs_data.dart';

/// Run history across workspaces: totals for the filters, then each
/// invocation, newest first. The list itself is not customer content (no
/// prompts or transcripts), so it is not audited.
class AdminRunsScreen extends ConsumerStatefulWidget {
  const AdminRunsScreen({super.key});

  @override
  ConsumerState<AdminRunsScreen> createState() => _AdminRunsScreenState();
}

class _AdminRunsScreenState extends ConsumerState<AdminRunsScreen> {
  RunQuery _q = defaultRunQuery;
  // Older pages below the provider's first one; cleared when the filters
  // change or on refresh.
  final _older = <RunTranscript>[];
  String? _cursor;
  bool _loading = false;

  void _set(RunQuery q) => setState(() {
    _q = q;
    _older.clear();
    _cursor = null;
  });

  Future<void> _refresh() async {
    setState(() {
      _older.clear();
      _cursor = null;
    });
    ref.invalidate(platformRunsProvider(_q));
    ref.invalidate(platformRunSummaryProvider(_q));
    await ref.read(platformRunsProvider(_q).future);
  }

  Future<void> _more(String cursor) async {
    final l = AppLocalizations.of(context);
    setState(() => _loading = true);
    try {
      final page = await fetchRuns(ref.read(apiProvider)!, _q, cursor: cursor);
      if (!mounted) return;
      setState(() {
        _older.addAll(page.items);
        _cursor = page.nextCursor ?? '';
      });
    } catch (e) {
      if (mounted) showSnack(context, errorMessage(e, l.commonError));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pickWorkspace() async {
    final l = AppLocalizations.of(context);
    final ws = ref.read(platformWorkspacesProvider).value ?? const <PlatformWorkspace>[];
    final picked = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            ListTile(title: Text(l.runsAllWorkspaces), selected: _q.workspace == null, onTap: () => Navigator.pop(ctx, 0)),
            for (final w in ws)
              ListTile(title: Text(w.name), subtitle: Text(w.slug), selected: _q.workspace == w.id, onTap: () => Navigator.pop(ctx, w.id)),
          ],
        ),
      ),
    );
    if (picked == null) return;
    _set((workspace: picked == 0 ? null : picked, purpose: _q.purpose, status: _q.status, stalled: _q.stalled, period: _q.period));
  }

  Future<void> _pickPurpose() async {
    final l = AppLocalizations.of(context);
    final picked = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final p in ['', 'stages', 'background', ...runStages, ...runBackground])
              ListTile(title: Text(purposeLabel(l, p)), selected: _q.purpose == p, onTap: () => Navigator.pop(ctx, p)),
          ],
        ),
      ),
    );
    if (picked == null) return;
    _set((workspace: _q.workspace, purpose: picked, status: _q.status, stalled: _q.stalled, period: _q.period));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final ws = ref.watch(platformWorkspacesProvider).value ?? const <PlatformWorkspace>[];
    final wsName = _q.workspace == null
        ? l.runsAllWorkspaces
        : ws.where((w) => w.id == _q.workspace).firstOrNull?.name ?? '#${_q.workspace}';
    return Scaffold(
      backgroundColor: c.bg,
      appBar: DetailBar(backLabel: l.navBack, onBack: () => context.canPop() ? context.pop() : context.go('/admin/more')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            PageHeader(title: l.runsTitle, sub: l.runsLede),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Segmented<RunPeriod>(
                full: true,
                options: [(RunPeriod.day, '24h'), (RunPeriod.week, '7d'), (RunPeriod.month, '30d'), (RunPeriod.all, l.runsPer_all)],
                value: _q.period,
                onChanged: (p) => _set((workspace: _q.workspace, purpose: _q.purpose, status: _q.status, stalled: _q.stalled, period: p)),
              ),
            ),
            ChipRow(
              children: [
                for (final s in const ['', 'running', 'error', 'timeout', 'oom', 'cancelled', 'done'])
                  FilterChipH(
                    label: statusLabel(l, s),
                    selected: _q.status == s,
                    onTap: () => _set((workspace: _q.workspace, purpose: _q.purpose, status: s, stalled: _q.stalled, period: _q.period)),
                  ),
              ],
            ),
            ChipRow(
              children: [
                FilterChipH(label: wsName, selected: _q.workspace != null, onTap: _pickWorkspace),
                FilterChipH(label: purposeLabel(l, _q.purpose), selected: _q.purpose.isNotEmpty, onTap: _pickPurpose),
                FilterChipH(
                  label: l.runsFStalled,
                  selected: _q.stalled,
                  onTap: () =>
                      _set((workspace: _q.workspace, purpose: _q.purpose, status: _q.status, stalled: !_q.stalled, period: _q.period)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            _Summary(_q),
            const SizedBox(height: 14),
            switch (ref.watch(platformRunsProvider(_q))) {
              AsyncData(:final value) => _list(context, value),
              AsyncError(:final error) => Padding(
                padding: const EdgeInsets.all(16),
                child: HelpBox(errorMessage(error, l.commonError), tone: Tone.bad),
              ),
              _ => const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              ),
            },
          ],
        ),
      ),
    );
  }

  Widget _list(BuildContext context, RunHistoryPage first) {
    final l = AppLocalizations.of(context);
    final all = [...first.items, ..._older];
    final next = _older.isEmpty && _cursor == null ? first.nextCursor : (_cursor?.isEmpty ?? true ? null : _cursor);
    if (all.isEmpty) return EmptyState(title: l.runsNone);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListGroup(children: [for (final r in all) RunRow(r, onTap: () => context.push('/admin/runs/${r.id}'))]),
        ),
        if (next != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _loading ? null : () => _more(next),
                child: _loading
                    ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(l.runsLoadMore),
              ),
            ),
          ),
      ],
    );
  }
}

/// The totals strip: invocations, error rate, cost, duration.
class _Summary extends ConsumerWidget {
  const _Summary(this.q);
  final RunQuery q;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final loc = Localizations.localeOf(context).toLanguageTag();
    final s = ref.watch(platformRunSummaryProvider(q)).value;
    if (s == null) return const SizedBox.shrink();
    final rate = s.count == 0 ? 0 : (s.errors * 100 / s.count).round();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Grid2(
        children: [
          KpiCard(
            label: l.runsSumCount,
            value: fmtTokens(s.count, loc),
            note: '${l.runsSumTokens}: ${fmtTokens(s.inputTokens, loc)} / ${fmtTokens(s.outputTokens, loc)}',
          ),
          KpiCard(
            label: l.runsSumErrors,
            value: '$rate%',
            note: l.runsSumErrorsNote('${s.errors}'),
            valueColor: s.errors > 0 ? Agnts.of(context).badInk : null,
          ),
          KpiCard(
            label: l.runsSumCost,
            value: fmtUsd(s.costUsd.toDouble(), loc),
            note: l.runsSumCostNote(fmtUsd(s.backgroundCostUsd.toDouble(), loc)),
          ),
          KpiCard(
            label: l.runsSumDuration,
            value: '${durText(Duration(milliseconds: s.p50Ms))} / ${durText(Duration(milliseconds: s.p95Ms))}',
            note: s.stalled > 0 ? '⚠ ${l.runsStallsTitle(s.stalled)}' : l.runsSumDurationNote,
          ),
        ],
      ),
    );
  }
}

/// One invocation: what it was about, purpose and model, when, and how it ended.
class RunRow extends StatelessWidget {
  const RunRow(this.r, {super.key, this.onTap, this.current = false});
  final RunTranscript r;
  final VoidCallback? onTap;
  final bool current;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final loc = Localizations.localeOf(context).toLanguageTag();
    final status = r.status.value;
    final purpose = purposeLabel(l, r.purpose);
    final stage = (r.modelStage?.isNotEmpty ?? false) && r.modelStage != r.purpose ? ' · ${r.modelStage}' : '';
    final row = Container(
      color: runFailed(status) ? c.badSoft.withValues(alpha: 0.35) : null,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  current ? '$purpose$stage · ${l.runsThisOne}' : runTitle(r),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: c.ink,
                    fontFamily: (r.ticketKey?.isNotEmpty ?? false) && !current ? AgntsFonts.mono : null,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  [
                    if (!current) '$purpose$stage',
                    if (r.engine == RunTranscriptEngineEnum.codex) l.runsE_codex,
                    r.model,
                    if (!current) r.workspace,
                  ].where((s) => s.isNotEmpty).join(' · '),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, color: c.ink2),
                ),
                const SizedBox(height: 2),
                Text(
                  [
                    agoText(context, r.startedAt),
                    durText(runDuration(r)),
                    l.runsTurnsN(r.turns),
                    if (r.toolCalls > 0) l.runsToolsTitle('${r.toolCalls}', '${r.toolErrors}'),
                  ].join(' · '),
                  style: TextStyle(fontSize: 12.5, color: c.ink3),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ToneBadge(statusLabel(l, status), statusTone(status), small: true),
              const SizedBox(height: 6),
              Text(
                fmtUsd(r.costUsd.toDouble(), loc),
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: c.ink),
              ),
              if (r.stalls > 0)
                Text(
                  '⚠ ${r.stalls}',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: c.warnInk),
                ),
            ],
          ),
        ],
      ),
    );
    return onTap == null ? row : InkWell(onTap: onTap, child: row);
  }
}
