import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:agnts_api/agnts_api.dart';
import 'package:intl/intl.dart';

import '../../core/api.dart';
import '../../core/data.dart';
import '../../l10n/app_localizations.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import '../../widgets/ui.dart';

final _repoProvider = FutureProvider.family<Repository, int>((ref, id) async {
  return (await requireApi(ref).getReposApi().getRepo(id: id)).data!;
});
final _branchesProvider = FutureProvider.family<List<Branch>, int>((ref, id) async {
  return (await requireApi(ref).getReposApi().listRepoBranches(id: id)).data ?? const [];
});
final _commitsProvider = FutureProvider.family<List<Commit>, int>((ref, id) async {
  return (await requireApi(ref).getReposApi().listRepoCommits(id: id)).data ?? const [];
});
final _pipelinesProvider = FutureProvider.family<List<Pipeline>, int>((ref, id) async {
  return (await requireApi(ref).getReposApi().listRepoPipelines(id: id)).data ?? const [];
});
final _envsProvider = FutureProvider.family<List<Environment>, int>((ref, id) async {
  return (await requireApi(ref).getReposApi().listRepoEnvironments(id: id)).data ?? const [];
});

enum _Tab { branches, commits, pipelines }

/// A repository's numbers, branches, commits and pipelines; manual deploy jobs can be started here.
class RepoScreen extends ConsumerStatefulWidget {
  const RepoScreen({super.key, required this.id, required this.name});
  final int id;
  final String name;

  @override
  ConsumerState<RepoScreen> createState() => _RepoScreenState();
}

class _RepoScreenState extends ConsumerState<RepoScreen> {
  _Tab _tab = _Tab.branches;

  Future<void> _refresh() async {
    final id = widget.id;
    ref.invalidate(_repoProvider(id));
    ref.invalidate(_envsProvider(id));
    await Future.wait([
      ref.refresh(_branchesProvider(id).future),
      ref.refresh(_commitsProvider(id).future),
      ref.refresh(_pipelinesProvider(id).future),
    ].map((f) => f.then((_) {}, onError: (_) {})));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final id = widget.id;
    final repo = ref.watch(_repoProvider(id)).value;
    final branches = ref.watch(_branchesProvider(id));
    final commits = ref.watch(_commitsProvider(id));
    final pipelines = ref.watch(_pipelinesProvider(id));
    final envs = ref.watch(_envsProvider(id)).value ?? const <Environment>[];
    final name = widget.name.isNotEmpty ? widget.name : (repo?.name ?? '');

    // The four numbers, worked out as the admin panel does.
    final bs = branches.value, cs = commits.value, ps = pipelines.value;
    final week = cs?.where((x) => x.date != null && DateTime.now().difference(x.date!).inDays < 7).toList();
    final done = ps?.where((p) => p.status == CI.ok || p.status == CI.fail).toList();
    final okPct = done == null || done.isEmpty ? null : (done.where((p) => p.status == CI.ok).length * 100 / done.length).round();
    Environment? prod;
    for (final e in envs) {
      if (RegExp('prod', caseSensitive: false).hasMatch(e.name)) {
        prod = e;
        break;
      }
    }
    prod ??= envs.isEmpty ? null : envs.first;

    return Scaffold(
      appBar: DetailBar(backLabel: l.mobileMore),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(padding: const EdgeInsets.only(bottom: 32), children: [
          // .d-head
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name, style: Theme.of(context).textTheme.headlineSmall),
              if (repo != null && repo.cloneUrl.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: SelectableText(repo.cloneUrl, style: TextStyle(fontFamily: AgntsFonts.mono, fontSize: 12.5, color: c.ink2)),
                ),
            ]),
          ),
          if (repo?.archivedAt != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: HelpBox(l.repoArchivedBanner(_ago(l, repo!.archivedAt!)), tone: Tone.warn),
            ),
          // .kgrid
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Grid2(children: [
              KpiCard(
                label: l.repoKpiBranches,
                value: bs == null ? '—' : '${bs.length}',
                note: bs == null ? null : l.repoKpiBranchesNote('${bs.where((b) => b.ticketKey != null).length}'),
              ),
              KpiCard(
                label: l.repoKpiCommits,
                value: week == null ? '—' : '${week.length}',
                note: week == null ? null : l.repoKpiCommitsNote('${week.where((x) => x.ticketKey != null).length}'),
              ),
              KpiCard(
                label: l.repoKpiPipelines,
                value: okPct == null ? '—' : '$okPct%',
                note: done == null ? null : l.repoKpiPipelinesNote('${done.length}'),
              ),
              KpiCard(
                label: prod?.name ?? l.repoKpiProd,
                value: prod == null || prod.sha.isEmpty ? '—' : _short(prod.sha),
                mono: true,
                note: prod?.deployedAt == null ? l.repoNotDeployed : l.repoDeployedAgo(_ago(l, prod!.deployedAt!)),
              ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Segmented<_Tab>(
              full: true,
              options: [
                (_Tab.branches, l.mobileBranches),
                (_Tab.commits, l.mobileCommits),
                (_Tab.pipelines, l.mobilePipelines),
              ],
              value: _tab,
              onChanged: (t) => setState(() => _tab = t),
            ),
          ),
          ...switch (_tab) {
            _Tab.branches => _async(context, branches, (list) => [_pad(ListGroup(children: [for (final b in list) _BranchRow(b)]))]),
            _Tab.commits => _async(context, commits, (list) => _commitGroups(context, list)),
            _Tab.pipelines => _async(context, pipelines, (list) => _pipelinesBody(context, list, envs), emptyOk: envs.isNotEmpty),
          },
        ]),
      ),
    );
  }

  /// Loading, git-host error and empty states around a tab's list.
  List<Widget> _async<T>(BuildContext context, AsyncValue<List<T>> v, List<Widget> Function(List<T>) build, {bool emptyOk = false}) {
    final l = AppLocalizations.of(context);
    return switch (v) {
      AsyncData(:final value) when value.isEmpty && !emptyOk => [EmptyState(title: l.mobileNoEvents)],
      AsyncData(:final value) => build(value),
      AsyncError() => [_pad(HelpBox(l.mobileGitHostError, tone: Tone.bad))],
      _ => [const Padding(padding: EdgeInsets.all(32), child: Center(child: CircularProgressIndicator()))],
    };
  }

  /// Commits grouped by day, each day under a grey heading.
  List<Widget> _commitGroups(BuildContext context, List<Commit> list) {
    final loc = Localizations.localeOf(context).toLanguageTag();
    final groups = <DateTime?, List<Commit>>{};
    for (final x in list) {
      final d = x.date?.toLocal();
      groups.putIfAbsent(d == null ? null : DateTime(d.year, d.month, d.day), () => []).add(x);
    }
    return [
      for (final (i, e) in groups.entries.indexed) ...[
        if (e.key != null)
          SectionHeader(toBeginningOfSentenceCase(DateFormat.MMMMEEEEd(loc).format(e.key!)),
              padding: EdgeInsets.fromLTRB(20, i == 0 ? 0 : 18, 20, 8))
        else if (i > 0)
          const SizedBox(height: 18),
        _pad(ListGroup(children: [for (final x in e.value) _CommitRow(x)])),
      ],
    ];
  }

  List<Widget> _pipelinesBody(BuildContext context, List<Pipeline> list, List<Environment> envs) {
    final l = AppLocalizations.of(context);
    return [
      if (envs.isNotEmpty)
        _pad(Grid2(children: [
          for (final e in envs)
            KpiCard(
              label: e.name,
              value: e.sha.isEmpty ? '—' : _short(e.sha),
              mono: true,
              note: e.deployedAt == null ? l.repoNotDeployed : l.repoDeployedAgo(_ago(l, e.deployedAt!)),
            ),
        ])),
      Padding(padding: EdgeInsets.fromLTRB(16, envs.isEmpty ? 0 : 12, 16, 0), child: HelpBox(l.repoDeployHelp)),
      SectionHeader(l.mmorePipelineRuns),
      if (list.isEmpty) EmptyState(title: l.mobileNoEvents),
      for (final (i, p) in list.indexed)
        Padding(padding: EdgeInsets.fromLTRB(16, i == 0 ? 0 : 10, 16, 0), child: _PipelineCard(repoId: widget.id, p: p)),
    ];
  }
}

Widget _pad(Widget child) => Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: child);

String _short(String sha) => sha.substring(0, sha.length < 7 ? sha.length : 7);

/// "2h 5m ago" / "just now".
String _ago(AppLocalizations l, DateTime at) {
  final d = DateTime.now().difference(at);
  return d.inMinutes < 1 ? l.mmoreJustNow : l.mmoreAgo(shortDuration(d));
}

/// The linked ticket's key and state badge, when agnts knows the ticket.
class _TicketTag extends ConsumerWidget {
  const _TicketTag(this.ticketKey);
  final String ticketKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    Ticket? t;
    for (final x in ref.watch(ticketsProvider('all')).value ?? const <Ticket>[]) {
      if (x.key == ticketKey) {
        t = x;
        break;
      }
    }
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Wrap(spacing: 6, crossAxisAlignment: WrapCrossAlignment.center, children: [
        Text(ticketKey, style: TextStyle(fontFamily: AgntsFonts.mono, fontSize: 12, color: c.ink3)),
        if (t != null) ToneBadge(stateLabelOf(l, t.state), stateTone(t.state), small: true),
      ]),
    );
  }
}

/// A branch name in a grey mono chip (.br).
class _BrChip extends StatelessWidget {
  const _BrChip(this.name);
  final String name;

  @override
  Widget build(BuildContext context) {
    final c = Agnts.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(color: c.graySoft, borderRadius: BorderRadius.circular(6)),
      child: Text(name, style: TextStyle(fontFamily: AgntsFonts.mono, fontSize: 12, color: c.ink)),
    );
  }
}

/// A tappable list row with a CI dot on the left, like the demo's branch and commit rows (.li).
class _GitRow extends StatelessWidget {
  const _GitRow({required this.ci, required this.children, this.onTap});
  final CI ci;
  final List<Widget> children;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = Agnts.of(context);
    final row = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      child: Row(children: [
        CiDot(ci),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children)),
        if (onTap != null) Padding(padding: const EdgeInsets.only(left: 8), child: HIcon('chevron', size: 16, color: c.line3, stroke: 2.4)),
      ]),
    );
    return onTap == null ? row : InkWell(onTap: onTap, child: row);
  }
}

class _BranchRow extends StatelessWidget {
  const _BranchRow(this.b);
  final Branch b;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final small = TextStyle(fontSize: 13, color: c.ink3);
    final meta = [
      if (b.author.isNotEmpty) b.author,
      if (b.date != null) _ago(l, b.date!),
    ].join(', ');
    return _GitRow(
      ci: b.ci,
      onTap: b.ticketKey == null ? null : () => context.push('/tickets/${b.ticketKey}'),
      children: [
        Wrap(spacing: 6, runSpacing: 4, crossAxisAlignment: WrapCrossAlignment.center, children: [
          _BrChip(b.name),
          if (b.default_) ToneBadge(l.repoDefault, Tone.info, small: true),
        ]),
        if (b.message.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Text(b.message, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, color: c.ink2)),
          ),
        Text(
          [if (meta.isNotEmpty) meta, if (!b.default_) l.mobileAheadBehind(b.ahead.toString(), b.behind.toString())].join(', '),
          style: small,
        ),
        if (b.ticketKey != null) _TicketTag(b.ticketKey!),
      ],
    );
  }
}

class _CommitRow extends StatelessWidget {
  const _CommitRow(this.x);
  final Commit x;

  @override
  Widget build(BuildContext context) {
    final c = Agnts.of(context);
    final loc = Localizations.localeOf(context).toLanguageTag();
    final small = TextStyle(fontSize: 13, color: c.ink3);
    return _GitRow(
      ci: x.ci,
      onTap: x.ticketKey == null ? null : () => context.push('/tickets/${x.ticketKey}'),
      children: [
        Text(x.message, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: c.ink)),
        const SizedBox(height: 2),
        Text.rich(
          TextSpan(style: small, children: [
            TextSpan(text: _short(x.sha), style: TextStyle(fontFamily: AgntsFonts.mono, fontSize: 12, color: c.ink3)),
            TextSpan(text: ' ${[if (x.author.isNotEmpty) x.author, if (x.date != null) DateFormat.Hm(loc).format(x.date!.toLocal())].join(', ')}'),
          ]),
        ),
        if (x.add > 0 || x.del > 0)
          Text.rich(TextSpan(style: small.copyWith(fontWeight: FontWeight.w700), children: [
            TextSpan(text: '+${x.add}', style: TextStyle(color: c.okInk)),
            TextSpan(text: '  −${x.del}', style: TextStyle(color: c.badInk)),
          ])),
        if (x.ticketKey != null) _TicketTag(x.ticketKey!),
      ],
    );
  }
}

/// A pipeline run as a card (.pp-m-card): status, message, branch and sha, then its stages.
class _PipelineCard extends ConsumerWidget {
  const _PipelineCard({required this.repoId, required this.p});
  final int repoId;
  final Pipeline p;

  Future<void> _deploy(BuildContext context, WidgetRef ref, Stage s) async {
    final l = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        content: Text(l.mobileDeployConfirm(s.name)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: Text(l.mobileCancel)),
          FilledButton(onPressed: () => Navigator.pop(c, true), child: Text(l.mobileDeploy)),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(apiProvider)!.getReposApi().deployRepo(id: repoId, deployRepoRequest: DeployRepoRequest(jobId: s.id));
      if (context.mounted) showSnack(context, l.mobileDeployStarted);
      ref.invalidate(_pipelinesProvider(repoId));
    } on DioException catch (e) {
      if (context.mounted) showSnack(context, errorMessage(e, l.commonError));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final hint = TextStyle(fontSize: 13, color: c.ink3);
    return HCard(
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // .pp-top
        Row(children: [
          CiDot(p.status),
          const SizedBox(width: 8),
          Text('#${p.id}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: c.ink)),
          const SizedBox(width: 8),
          Expanded(child: Text(ciLabel(l, p.status), style: hint, maxLines: 1, overflow: TextOverflow.ellipsis)),
          if (p.created != null) Text(_ago(l, p.created!), style: hint),
        ]),
        Padding(
          padding: const EdgeInsets.only(top: 6, bottom: 4),
          child: Text(p.message.isEmpty ? p.name : p.message,
              maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: c.ink)),
        ),
        // .pp-sub
        DefaultTextStyle.merge(
          style: TextStyle(fontSize: 12.5, color: c.ink3),
          child: Wrap(spacing: 10, runSpacing: 6, crossAxisAlignment: WrapCrossAlignment.center, children: [
            if (p.branch.isNotEmpty) _BrChip(p.branch),
            if (p.sha.isNotEmpty) Text(_short(p.sha), style: TextStyle(fontFamily: AgntsFonts.mono, fontSize: 12, color: c.ink3)),
            if (p.trigger.isNotEmpty) Text(p.trigger),
            if (p.durationMs > 0) Text(shortDuration(Duration(milliseconds: p.durationMs))),
          ]),
        ),
        // .stg
        if (p.stages.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Wrap(spacing: 6, runSpacing: 6, children: [
              for (final s in p.stages) _StageChip(s, onDeploy: s.manual ? () => _deploy(context, ref, s) : null),
            ]),
          ),
      ]),
    );
  }
}

/// One stage pill (.stg-i), coloured by status; a manual stage carries a Deploy button.
class _StageChip extends StatelessWidget {
  const _StageChip(this.s, {this.onDeploy});
  final Stage s;
  final VoidCallback? onDeploy;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final tone = switch (s.status) {
      CI.ok => Tone.ok,
      CI.fail => Tone.bad,
      CI.run => Tone.info,
      CI.manual => Tone.warn,
      _ => Tone.gray,
    };
    final ink = tone.ink(c);
    final lead = switch (s.status) {
      CI.ok => HIcon('check', size: 13, color: ink, stroke: 3),
      CI.fail => HIcon('close', size: 13, color: ink, stroke: 3),
      CI.run => SizedBox(width: 11, height: 11, child: CircularProgressIndicator(strokeWidth: 2, color: ink)),
      _ => Container(width: 12, height: 12, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: ink, width: 2))),
    };
    final text = s.durationMs > 0 ? '${s.name} · ${shortDuration(Duration(milliseconds: s.durationMs))}' : s.name;
    return Semantics(
      label: ciLabel(l, s.status),
      child: Container(
        padding: EdgeInsets.fromLTRB(6, 4, onDeploy == null ? 9 : 4, 4),
        decoration: BoxDecoration(color: tone.soft(c), borderRadius: BorderRadius.circular(13)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          lead,
          const SizedBox(width: 5),
          Flexible(child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: ink))),
          if (onDeploy != null) ...[
            const SizedBox(width: 6),
            OutlinedButton(
              onPressed: onDeploy,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 26),
                padding: const EdgeInsets.symmetric(horizontal: 9),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                textStyle: const TextStyle(fontFamily: AgntsFonts.sans, fontSize: 12, fontWeight: FontWeight.w700),
              ),
              child: Text(l.mobileDeploy),
            ),
          ],
        ]),
      ),
    );
  }
}

String ciLabel(AppLocalizations l, CI s) => switch (s) {
      CI.ok => l.mobileCiOk,
      CI.fail => l.mobileCiFail,
      CI.run => l.mobileCiRun,
      CI.pending => l.mobileCiWaiting,
      CI.manual => l.mobileCiManual,
      CI.skip => l.repoCi_skip,
      CI.canceled => l.repoCi_canceled,
      _ => l.mobileCiNone,
    };

/// A CI status dot (.ci): green passed, red failed, pulsing blue running,
/// amber waiting for you, an empty ring otherwise.
class CiDot extends StatelessWidget {
  const CiDot(this.s, {super.key});
  final CI s;

  @override
  Widget build(BuildContext context) {
    final c = Agnts.of(context);
    final Widget dot = switch (s) {
      CI.run => Pulse(size: 10, color: c.primary),
      CI.ok || CI.fail || CI.manual => Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(shape: BoxShape.circle, color: s == CI.ok ? c.ok : s == CI.fail ? c.bad : c.warn),
        ),
      _ => Container(width: 10, height: 10, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: c.line3, width: 2))),
    };
    return Semantics(label: ciLabel(AppLocalizations.of(context), s), child: SizedBox(width: 10, height: 10, child: dot));
  }
}
