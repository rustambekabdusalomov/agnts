import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:agnts_api/agnts_api.dart';

import '../../core/api.dart';
import '../../core/data.dart';
import '../../l10n/app_localizations.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import '../../widgets/ui.dart';
import '../tasks/repo_pick.dart';

// Per-ticket controls of the detail screen, as the admin panel's ticket page
// has them: models, repositories, the pull request's assignees, taking a
// ticket over, a newer tracker version, the secrets check and replays.

/// A review of someone else's pull request.
bool isPullReview(Ticket t) => t.kind == TicketKind.review;

/// Whether the ticket must have a repository to run: a change of a kind
/// someone picked (not Auto, a report or a Swagger test).
bool needsRepo(Ticket t) => !t.kindAuto && !isReportKind(t.kind) && t.kind != TicketKind.swaggertest;

/// The server's rule for changing repositories: no pull request and no pending push.
bool canChangeRepo(Ticket t) => t.prUrl.isEmpty && t.resumeState != TicketState.pushing;

/// Whether approving opens a pull request (and so takes assignees).
bool opensPr(Ticket t) =>
    !isReportKind(t.kind) && !isPullReview(t) && !(t.source_ == TicketSource_Enum.local && t.afterApprove == TicketAfterApproveEnum.main);

/// Runs [action] for the ticket [key] and refreshes it; shows the error.
Future<bool> _act(BuildContext context, WidgetRef ref, String key, Future<void> Function() action, {String? done}) async {
  final l = AppLocalizations.of(context);
  try {
    await action();
    ref.invalidate(ticketProvider(key));
    ref.invalidate(ticketsProvider);
    if (done != null && context.mounted) showSnack(context, done);
    return true;
  } catch (e) {
    if (context.mounted) showSnack(context, errorMessage(e, l.commonError));
    return false;
  }
}

Future<bool> _confirm(BuildContext context, String text, String action) async {
  final l = AppLocalizations.of(context);
  final ok = await showDialog<bool>(
    context: context,
    builder: (c) => AlertDialog(
      content: Text(text),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c, false), child: Text(l.mobileCancel)),
        FilledButton(onPressed: () => Navigator.pop(c, true), child: Text(action)),
      ],
    ),
  );
  return ok ?? false;
}

Widget _title(Agnts c, String text) => Text(text, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: c.ink3));

Widget _hint(Agnts c, String text) => Padding(
      padding: const EdgeInsets.only(top: 2, bottom: 8),
      child: Text(text, style: TextStyle(fontSize: 13, height: 1.4, color: c.ink3)),
    );

// ---- Models ----

/// The stages a ticket's models can be set for.
enum ModelStage { analyze, coding, retry, review, preview }

const _models = ['haiku', 'sonnet', 'opus'];

String _modelName(String m) => m.isEmpty ? m : '${m[0].toUpperCase()}${m.substring(1)}';

/// Per-ticket model overrides; "Default" follows Settings.
class ModelPicker extends ConsumerStatefulWidget {
  const ModelPicker(this.ticket, {super.key, required this.stages});
  final Ticket ticket;
  final List<ModelStage> stages;

  @override
  ConsumerState<ModelPicker> createState() => _ModelPickerState();
}

class _ModelPickerState extends ConsumerState<ModelPicker> {
  bool _busy = false;

  String _label(AppLocalizations l, ModelStage s) => switch (s) {
        ModelStage.analyze => l.ticketStageAnalyze,
        ModelStage.coding => l.ticketStageCoding,
        ModelStage.retry => l.ticketStageRetry,
        ModelStage.review => l.ticketStageReview,
        ModelStage.preview => l.ticketStagePreview,
      };

  /// The Settings model of [s], as "Default (Sonnet)".
  String _defaultLabel(AppLocalizations l, StageModels? m, ModelStage s) {
    final v = switch (s) {
      ModelStage.analyze => m?.analyze,
      ModelStage.coding => m?.coding,
      ModelStage.retry => m?.retry,
      ModelStage.review => m?.review ?? 'auto',
      ModelStage.preview => m?.preview,
    };
    if (m == null || v == null) return l.ticketModelDefault('…');
    if (v == 'auto') return l.ticketModelAuto('Sonnet / Opus');
    return l.ticketModelDefault(_modelName(v));
  }

  Future<void> _pick(ModelStage s, String defaultLabel) async {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final current = (widget.ticket.models?.toJson() ?? const {})[s.name] as String?;
    final picked = await showModalBottomSheet<(String?,)>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(_label(l, s), style: Theme.of(ctx).textTheme.titleLarge),
            const SizedBox(height: 10),
            ListGroup(children: [
              for (final (v, name) in [(null, defaultLabel), for (final m in _models) (m, _modelName(m))])
                ListRow(
                  title: name,
                  trailing: v == current ? HIcon('check', size: 20, color: c.primary, stroke: 2.4) : const SizedBox(width: 20),
                  onTap: () => Navigator.pop(ctx, (v,)),
                ),
            ]),
          ]),
        ),
      ),
    );
    if (picked == null || picked.$1 == current || !mounted) return;
    final next = Map<String, dynamic>.from(widget.ticket.models?.toJson() ?? const {});
    if (picked.$1 == null) {
      next.remove(s.name);
    } else {
      next[s.name] = picked.$1;
    }
    setState(() => _busy = true);
    await _act(context, ref, widget.ticket.key,
        () => ref.read(apiProvider)!.getTicketsApi().setTicketModels(key: widget.ticket.key, modelOverrides: ModelOverrides.fromJson(next)));
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final settings = ref.watch(settingsProvider).value?.models;
    final overrides = widget.ticket.models?.toJson() ?? const <String, dynamic>{};
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        _title(c, l.ticketModelsTitle),
        _hint(c, l.ticketModelsHint),
        ListGroup(children: [
          for (final s in widget.stages)
            ListRow(
              title: _label(l, s),
              value: overrides[s.name] is String ? _modelName(overrides[s.name] as String) : _defaultLabel(l, settings, s),
              onTap: _busy || !ref.watch(canEditProvider) ? null : () => _pick(s, _defaultLabel(l, settings, s)),
            ),
        ]),
      ]),
    );
  }
}

// ---- Repositories ----

/// The ticket's repositories in order (the first is the main one).
List<int> ticketRepoIds(Ticket t) {
  final rs = t.repos ?? const <TicketRepoState>[];
  if (rs.isNotEmpty) return [for (final r in rs) r.repoId];
  return t.repoId == null ? const [] : [t.repoId!];
}

/// Which repositories a ticket runs in: a group, or one or more
/// repositories. The server allows a change while nothing runs and nothing
/// was pushed; a stopped ticket then starts over from analysis, so that
/// case asks first.
class RepoPicker extends ConsumerStatefulWidget {
  const RepoPicker(this.ticket, {super.key});
  final Ticket ticket;

  @override
  ConsumerState<RepoPicker> createState() => _RepoPickerState();
}

class _RepoPickerState extends ConsumerState<RepoPicker> {
  bool _busy = false;

  Ticket get _t => widget.ticket;

  bool get _restarts => _t.repoId != null && _t.state != TicketState.new_ && _t.resumeState != TicketState.new_;

  String _names(List<int> ids, List<Repository> repos) =>
      ids.map((id) => repos.where((r) => r.id == id).firstOrNull?.name ?? '#$id').join(', ');

  Future<void> _open() async {
    final l = AppLocalizations.of(context);
    final repos = (await ref.read(reposProvider.future)).where((r) => r.archivedAt == null).toList();
    final groups = await ref.read(repoGroupsProvider.future).catchError((_) => const <RepoGroup>[]);
    if (!mounted) return;
    final group = _t.group == null ? null : groups.where((g) => g.id == _t.group!.id).firstOrNull;
    final current = group != null ? RepoPick(ids: ticketRepoIds(_t), group: group) : RepoPick(ids: ticketRepoIds(_t));
    final picked = await showModalBottomSheet<RepoPick>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => _RepoSheet(repos: repos, groups: groups, initial: current),
    );
    if (picked == null || picked.isEmpty || !mounted) return;
    final whole = picked.wholeGroup;
    final same = whole?.id == _t.group?.id && picked.ids.join(',') == current.ids.join(',');
    if (same) return;
    if (_restarts && !await _confirm(context, l.ticketRepoRestart(_names(current.ids, repos), _names(picked.ids, repos)), l.ticketRepoChange)) return;
    if (!mounted) return;
    setState(() => _busy = true);
    final input = whole != null ? TicketReposInput(groupId: whole.id) : TicketReposInput(repoIds: picked.ids);
    await _act(context, ref, _t.key, () => ref.read(apiProvider)!.getTicketsApi().setTicketRepos(key: _t.key, ticketReposInput: input),
        done: l.ticketRepoChanged(_names(picked.ids, repos)));
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final rs = _t.repos ?? const <TicketRepoState>[];
    final names = rs.isNotEmpty ? rs.map((r) => r.repoName).join(', ') : (_t.repoName ?? '');
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        _title(c, l.ticketRepoTitle),
        _hint(c, l.ticketRepoHint),
        if (_t.repoId == null) Padding(padding: const EdgeInsets.only(bottom: 8), child: HelpBox(l.ticketRepoMissing, tone: Tone.warn)),
        ListGroup(children: [
          ListRow(
            leading: HIcon('repos', size: 20, color: c.primary),
            title: names.isEmpty ? '—' : names,
            subtitle: _t.group == null ? null : l.mgroupsGroup(_t.group!.name),
            value: l.ticketRepoChange,
            onTap: _busy || !ref.watch(canEditProvider) ? null : _open,
          ),
        ]),
      ]),
    );
  }
}

/// Groups and repositories to pick from, as in the new-task sheet.
class _RepoSheet extends StatefulWidget {
  const _RepoSheet({required this.repos, required this.groups, required this.initial});
  final List<Repository> repos;
  final List<RepoGroup> groups;
  final RepoPick initial;

  @override
  State<_RepoSheet> createState() => _RepoSheetState();
}

class _RepoSheetState extends State<_RepoSheet> {
  late var _pick = widget.initial;

  String _name(int id) => widget.repos.where((r) => r.id == id).firstOrNull?.name ?? '#$id';

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final groups = widget.groups.where((g) => RepoPick.members(g).isNotEmpty).toList();
    final sub = TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: c.ink3);
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.8),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(l.ticketRepoTitle, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            if (groups.isNotEmpty) ...[
              Text(l.mgroupsGroups, style: sub),
              const SizedBox(height: 6),
              Wrap(spacing: 8, runSpacing: 8, children: [
                for (final g in groups)
                  FilterChipH(
                    label: g.name,
                    count: RepoPick.members(g).length,
                    selected: _pick.wholeGroup?.id == g.id,
                    onTap: () => setState(() => _pick = _pick.wholeGroup?.id == g.id ? const RepoPick() : _pick.pickGroup(g)),
                  ),
              ]),
              const SizedBox(height: 12),
              Text(l.mgroupsRepos, style: sub),
              const SizedBox(height: 6),
            ],
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final r in widget.repos) FilterChipH(label: r.name, selected: _pick.contains(r.id), onTap: () => setState(() => _pick = _pick.toggle(r.id))),
            ]),
            if (widget.repos.length > 1) Padding(padding: const EdgeInsets.only(top: 6), child: Text(l.mgroupsPickHint, style: TextStyle(fontSize: 13, color: c.ink3))),
            if (_pick.ids.length > 1) ...[
              const SizedBox(height: 12),
              Text(l.mgroupsInTask, style: sub),
              const SizedBox(height: 4),
              Text([for (final (i, id) in _pick.ids.indexed) i == 0 ? '${_name(id)} (${l.mgroupsPrimary})' : _name(id)].join(', '),
                  style: const TextStyle(fontSize: 14)),
            ],
            const SizedBox(height: 16),
            FilledButton(onPressed: _pick.isEmpty ? null : () => Navigator.pop(context, _pick), child: Text(l.ticketRepoChange)),
          ]),
        ),
      ),
    );
  }
}

// ---- Assignees of the pull request agnts opens ----

final repoMembersProvider = FutureProvider.autoDispose.family<List<RepoMember>, int>((ref, id) async {
  return (await requireApi(ref).getReposApi().listRepoMembers(id: id)).data ?? const [];
});

/// Who the pull request agnts opens on approval is assigned to on the git host.
class AssigneePicker extends ConsumerWidget {
  const AssigneePicker({super.key, required this.repoId, required this.selected, required this.onToggle});
  final int repoId;
  final Set<String> selected;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final members = ref.watch(repoMembersProvider(repoId));
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        _title(c, l.ticketAssignTitle),
        _hint(c, l.ticketAssignSub),
        members.when(
          data: (ms) => ms.isEmpty
              ? Text(l.ticketAssignNone, style: TextStyle(fontSize: 13.5, color: c.ink3))
              : Wrap(spacing: 8, runSpacing: 8, children: [
                  for (final m in ms)
                    FilterChipH(
                      label: (m.name ?? '').isEmpty ? m.username : m.name!,
                      selected: selected.contains(m.username),
                      onTap: () => onToggle(m.username),
                    ),
                ]),
          error: (e, _) => Text(l.ticketAssignError(errorMessage(e, l.commonError)), style: TextStyle(fontSize: 13.5, color: c.ink3)),
          loading: () => const LinearProgressIndicator(),
        ),
      ]),
    );
  }
}

// ---- Member: take the ticket over ----

/// The member a ticket runs for, with "Take over" for someone else's open
/// ticket: per-member Claude mode then runs it on your account.
class TicketMemberRow extends ConsumerStatefulWidget {
  const TicketMemberRow(this.ticket, {super.key});
  final Ticket ticket;

  @override
  ConsumerState<TicketMemberRow> createState() => _TicketMemberRowState();
}

class _TicketMemberRowState extends ConsumerState<TicketMemberRow> {
  bool _busy = false;

  Future<void> _takeOver() async {
    final l = AppLocalizations.of(context);
    setState(() => _busy = true);
    await _act(context, ref, widget.ticket.key,
        () => ref.read(apiProvider)!.getTicketsApi().setTicketMember(key: widget.ticket.key, setTicketMemberRequest: SetTicketMemberRequest(userId: 0)),
        done: l.queueTakenOver);
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final t = widget.ticket;
    final me = ref.watch(meProvider).value?.id;
    final open = t.state != TicketState.done && t.state != TicketState.rejected;
    final canTake = ref.watch(canEditProvider) && me != null && t.memberId != me && open;
    if (t.member == null && !canTake && t.createdBy == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Wrap(spacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
        Text('${l.queueMember}: ${t.member ?? '—'}', style: TextStyle(fontSize: 13, color: c.ink3)),
        if (t.createdBy != null) Text(l.queueCreatedBy(t.createdBy!), style: TextStyle(fontSize: 13, color: c.ink3)),
        if (canTake)
          TextButton(
            style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 4), minimumSize: const Size(0, 30)),
            onPressed: _busy ? null : _takeOver,
            child: Text(l.queueTakeOver),
          ),
      ]),
    );
  }
}

// ---- A newer version from the tracker ----

/// The issue changed in Jira or Plane after agnts started: restart with the
/// new version, or keep working on the current one.
class TrackerUpdateCard extends ConsumerStatefulWidget {
  const TrackerUpdateCard(this.ticket, {super.key});
  final Ticket ticket;

  @override
  ConsumerState<TrackerUpdateCard> createState() => _TrackerUpdateCardState();
}

class _TrackerUpdateCardState extends ConsumerState<TrackerUpdateCard> {
  bool _busy = false;

  Future<void> _go(bool restart) async {
    final l = AppLocalizations.of(context);
    final t = widget.ticket;
    final source = t.source_ == TicketSource_Enum.plane ? 'Plane' : 'Jira';
    if (restart && !await _confirm(context, l.ticketUpdateRestartConfirm(t.key, source), l.ticketUpdateRestart)) return;
    if (!mounted) return;
    setState(() => _busy = true);
    final api = ref.read(apiProvider)!.getTicketsApi();
    await _act(context, ref, t.key, () => restart ? api.restartWithUpdate(key: t.key) : api.keepCurrentVersion(key: t.key),
        done: restart ? l.ticketUpdateRestarted(t.key) : l.ticketUpdateKept);
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final t = widget.ticket;
    final u = t.trackerUpdate;
    if (u == null) return const SizedBox.shrink();
    final source = t.source_ == TicketSource_Enum.plane ? 'Plane' : 'Jira';
    final when = MaterialLocalizations.of(context).formatShortDate(u.at.toLocal());
    final time = MaterialLocalizations.of(context).formatTimeOfDay(TimeOfDay.fromDateTime(u.at.toLocal()), alwaysUse24HourFormat: true);
    return HelpBox(
      l.ticketUpdateTitle(source),
      tone: Tone.warn,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(l.ticketUpdateSub, style: TextStyle(fontSize: 13.5, height: 1.4, color: c.ink2)),
        const SizedBox(height: 10),
        Text(l.ticketUpdateNow('$when $time'), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: c.ink3)),
        const SizedBox(height: 4),
        Text(u.title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: c.ink)),
        const SizedBox(height: 4),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 200),
          child: SingleChildScrollView(child: Text(u.description.isEmpty ? '—' : u.description, style: TextStyle(fontSize: 14, height: 1.4, color: c.ink))),
        ),
        if (t.prUrl.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 8), child: Text(l.ticketUpdatePushed, style: TextStyle(fontSize: 13, color: c.ink3))),
        if (ref.watch(canEditProvider))
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Wrap(spacing: 8, runSpacing: 8, children: [
              FilledButton(onPressed: _busy || t.prUrl.isNotEmpty ? null : () => _go(true), child: Text(l.ticketUpdateRestart)),
              OutlinedButton(onPressed: _busy ? null : () => _go(false), child: Text(l.ticketUpdateKeep)),
            ]),
          ),
      ]),
    );
  }
}

// ---- Possible secrets ----

/// Lines flagged as possible credentials: agnts does not push the change
/// until someone confirms they are not real ones.
class SecretsAck extends ConsumerStatefulWidget {
  const SecretsAck({super.key, required this.ticket, required this.count});
  final Ticket ticket;
  final int count;

  @override
  ConsumerState<SecretsAck> createState() => _SecretsAckState();
}

class _SecretsAckState extends ConsumerState<SecretsAck> {
  bool _busy = false;
  // The ticket and revision confirmed on this screen.
  String _acked = '';

  String get _ackKey => '${widget.ticket.key}@${widget.ticket.revision}';

  Future<void> _ack() async {
    final l = AppLocalizations.of(context);
    setState(() => _busy = true);
    final ok = await _act(context, ref, widget.ticket.key, () => ref.read(apiProvider)!.getTicketsApi().acknowledgeSecrets(key: widget.ticket.key),
        done: l.harnessTicketSecretsDone);
    if (mounted) {
      setState(() {
        _busy = false;
        if (ok) _acked = _ackKey;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final needs = _acked != _ackKey;
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: HelpBox(
        l.harnessTicketSecretsTitle,
        tone: needs ? Tone.bad : Tone.ok,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(needs ? l.harnessTicketSecretsBody(widget.count) : l.harnessTicketSecretsDone, style: const TextStyle(fontSize: 14, height: 1.4)),
          if (needs && ref.watch(canEditProvider))
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton(onPressed: _busy ? null : _ack, child: Text(l.harnessTicketSecretsConfirm)),
              ),
            ),
        ]),
      ),
    );
  }
}

// ---- Replays ----

/// Re-runs a done ticket with today's agnts, from the commit it started
/// from, to see whether a change to the agent made it better.
class ReplayButton extends ConsumerStatefulWidget {
  const ReplayButton(this.ticket, {super.key});
  final Ticket ticket;

  @override
  ConsumerState<ReplayButton> createState() => _ReplayButtonState();
}

class _ReplayButtonState extends ConsumerState<ReplayButton> {
  bool _busy = false;

  Future<void> _start() async {
    final l = AppLocalizations.of(context);
    final t = widget.ticket;
    if (!await _confirm(context, l.replayConfirm(t.key), l.replayStart) || !mounted) return;
    setState(() => _busy = true);
    try {
      final r = await ref.read(apiProvider)!.getTicketsApi().replayTicket(key: t.key);
      ref.invalidate(ticketsProvider);
      final key = r.data?.key;
      if (key != null && mounted) {
        showSnack(context, l.replayCreated(key));
        context.push('/tickets/$key');
      }
    } catch (e) {
      if (mounted) showSnack(context, errorMessage(e, l.commonError));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        _title(c, l.replayTitle),
        _hint(c, l.replaySub),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton(onPressed: _busy || !ref.watch(canEditProvider) ? null : _start, child: Text(l.replayStart)),
        ),
      ]),
    );
  }
}

/// A replay says so, and links the ticket it re-does.
class ReplayBanner extends StatelessWidget {
  const ReplayBanner(this.original, {super.key});
  final String original;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    return HelpBox(
      l.replayBanner,
      child: Align(
        alignment: Alignment.centerLeft,
        child: GestureDetector(
          onTap: () => context.push('/tickets/$original'),
          child: Text(original, style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: c.primary)),
        ),
      ),
    );
  }
}
