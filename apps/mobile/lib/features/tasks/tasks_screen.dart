import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:agnts_api/agnts_api.dart';
import 'package:intl/intl.dart';

import '../../core/api.dart';
import '../../core/data.dart';
import '../../l10n/app_localizations.dart';
import '../../theme.dart';
import '../../widgets/attachments.dart';
import '../../widgets/common.dart';
import '../../widgets/ui.dart';
import '../admin/admin_widgets.dart' show confirmAction;
import '../tickets/kinds.dart';
import '../tickets/spend.dart';
import 'repo_pick.dart';

/// Side-project tasks (scrTasks in mobile.html): a repository filter, the
/// tasks as cards, and a "+" that opens the new-task sheet.
class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  /// The selected repository filter; null means all repositories.
  int? _repo;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final all = ref.watch(ticketsProvider('all'));
    final repos = ref.watch(reposProvider);
    final sideRepos = _taskRepos(repos.value ?? const []);
    return Scaffold(
      backgroundColor: c.bg,
      floatingActionButton: ref.watch(canEditProvider) ? HFab(onTap: _newTask, tooltip: l.mobileNewTask) : null,
      body: SafeArea(
        bottom: false,
        child: AsyncBody<List<Ticket>>(
          value: all,
          onRefresh: () {
            ref.invalidate(reposProvider);
            ref.invalidate(repoGroupsProvider);
            return ref.refresh(ticketsProvider('all').future);
          },
          builder: (list) {
            final tasks = list.where((t) => t.source_ == TicketSource_Enum.local).toList();
            // A filter on a repository that has gone away falls back to all.
            // Archived repositories keep a chip while they still have tasks.
            final chips = [
              for (final r in repos.value ?? const <Repository>[])
                if (r.archivedAt == null || tasks.any((t) => t.repoId == r.id)) r,
            ];
            final repo = chips.any((r) => r.id == _repo) ? _repo : null;
            final rows = repo == null ? tasks : tasks.where((t) => t.repoId == repo).toList();
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 96),
              children: [
                PageHeader(
                  title: l.navTasks,
                  actions: [RoundIconButton('info', tooltip: l.navGuide, onTap: () => _showGuide(context))],
                ),
                if (tasks.isNotEmpty || sideRepos.isNotEmpty)
                  ChipRow(children: [
                    FilterChipH(
                      label: l.tasksAllRepos('${tasks.length}'),
                      selected: repo == null,
                      onTap: () => setState(() => _repo = null),
                    ),
                    for (final r in chips)
                      FilterChipH(
                        label: r.name,
                        dot: _repoColor(r),
                        count: tasks.where((t) => t.repoId == r.id).length,
                        selected: repo == r.id,
                        onTap: () => setState(() => _repo = r.id),
                      ),
                  ]),
                const SizedBox(height: 12),
                if (tasks.isEmpty && sideRepos.isEmpty && repos.hasValue)
                  EmptyState(title: l.tasksNoRepos, text: l.mobileNoSideRepos)
                else if (tasks.isEmpty)
                  EmptyState(
                    title: l.mobileNoTasks,
                    text: l.tasksDrawerSub,
                    action: ref.watch(canEditProvider) ? FilledButton(onPressed: _newTask, child: Text(l.mobileNewTask)) : null,
                  )
                else if (rows.isEmpty)
                  EmptyState(title: l.tasksEmpty)
                else
                  Padding(
                    padding: screenPad,
                    child: Column(children: [
                      for (final (i, t) in rows.indexed) ...[
                        if (i > 0) const SizedBox(height: 10),
                        _TaskCard(t),
                      ],
                    ]),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  static List<Repository> _taskRepos(List<Repository> repos) =>
      repos.where((r) => r.archivedAt == null).toList();

  void _showGuide(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l.tasksTitle, style: Theme.of(ctx).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(l.tasksLede, style: TextStyle(color: c.ink2, fontSize: 15, height: 1.45)),
            const SizedBox(height: 12),
            Text(l.tasksHelp, style: TextStyle(color: c.ink2, fontSize: 15, height: 1.45)),
          ]),
        ),
      ),
    );
  }

  Future<void> _newTask() async {
    final l = AppLocalizations.of(context);
    List<Repository> repos;
    try {
      repos = _taskRepos(await ref.read(reposProvider.future));
    } catch (e) {
      if (mounted) showSnack(context, errorMessage(e, l.commonError));
      return;
    }
    // Groups are optional: without them the sheet offers repositories only.
    List<RepoGroup> groups;
    try {
      groups = await ref.read(repoGroupsProvider.future);
    } catch (_) {
      groups = const [];
    }
    if (!mounted) return;
    // Without repositories a task can still be a report (or let agnts pick).
    final initial = repos.any((r) => r.id == _repo) ? _repo! : (repos.firstOrNull?.id ?? 0);
    final key = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.9),
      builder: (_) => _NewTaskSheet(repos: repos, groups: groups, initialRepo: initial),
    );
    if (key != null && mounted) {
      ref.invalidate(ticketsProvider);
      context.push('/tickets/$key');
    }
  }
}

/// A stable colour for a repository's dot, picked from its id so it stays the
/// same across launches. Mid-tone colours that read on light and dark.
Color _repoColor(Repository r) {
  const palette = [
    Color(0xFFD9541E), // orange
    Color(0xFF16829A), // teal
    Color(0xFF7C3AED), // violet
    Color(0xFF2F9E44), // green
    Color(0xFFD6336C), // pink
    Color(0xFF3B6FE0), // blue
    Color(0xFFC08A0A), // amber
    Color(0xFF8D6E63), // brown
  ];
  return palette[r.id.abs() % palette.length];
}

/// A task as a card, with its next step when it needs you. A task that
/// has not started can be edited or deleted: long-press it, or tap "⋯".
class _TaskCard extends ConsumerWidget {
  const _TaskCard(this.t);
  final Ticket t;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final editable = t.state == TicketState.new_ && ref.watch(canEditProvider);
    final (String? action, Tone tone) = switch (t.state) {
      TicketState.waitingForAnswers => (l.mtasksActAnswers, Tone.warn),
      TicketState.waitingForReview => (l.mtasksActReview, Tone.warn),
      TicketState.failed => (l.mtasksActFailed, Tone.bad),
      TicketState.rateLimited => (l.mtasksActResume, Tone.bad),
      TicketState.new_ => (t.held == true ? l.mtasksActHeld : l.mtasksActAnalyze, Tone.info),
      _ => (null, Tone.info),
    };
    final card = TicketCard(
      ticket: t,
      onTap: () => context.push('/tickets/${t.key}'),
      meta: [
        Text(_when(context, t.updatedAt)),
        if (t.spend != null) Text(l.spendTokens(fmtTokens(ioTokens(t.spend), Localizations.localeOf(context).toLanguageTag()))),
        if (editable)
          Semantics(
            button: true,
            label: l.minsightsTaskActions,
            child: InkResponse(
              onTap: () => showTaskActions(context, ref, t),
              radius: 20,
              child: Padding(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), child: HIcon('more', size: 18, color: c.ink3)),
            ),
          ),
      ],
      action: action,
      actionTone: tone,
    );
    if (!editable) return card;
    return GestureDetector(onLongPress: () => showTaskActions(context, ref, t), child: card);
  }

  static String _when(BuildContext context, DateTime at) {
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final local = at.toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(local.year, local.month, local.day);
    final diff = today.difference(day).inDays;
    if (diff == 0) return DateFormat.Hm(locale).format(local);
    if (diff == 1) return l.mtasksYesterday;
    return local.year == now.year ? DateFormat.MMMd(locale).format(local) : DateFormat.yMMMd(locale).format(local);
  }
}

/// The new-task sheet (renderSheet "newtask" in mobile.html): repository,
/// title, description, priority, what happens after approval, how to start.
class _NewTaskSheet extends ConsumerStatefulWidget {
  const _NewTaskSheet({required this.repos, required this.initialRepo, this.groups = const []});
  final List<Repository> repos;
  final List<RepoGroup> groups;
  final int initialRepo; // 0: no repository

  @override
  ConsumerState<_NewTaskSheet> createState() => _NewTaskSheetState();
}

class _NewTaskSheetState extends ConsumerState<_NewTaskSheet> {
  late var _pick = RepoPick.single(widget.initialRepo);
  final _title = TextEditingController();
  // The team's own number for the work (AMANAT-2677): branch and commit
  // names use it; empty uses the ticket key.
  final _number = TextEditingController();
  final _desc = TextEditingController();
  late final _files = AttachmentsController()..addListener(_filesChanged);
  var _priority = TaskCreatePriorityEnum.medium;
  var _after = TaskCreateAfterApproveEnum.pr;
  var _start = TaskCreateStartEnum.ask;
  var _followUps = FollowUpsMode.inherit;
  var _kind = TicketKindChoice.auto;
  bool _busy = false;

  bool get _changeKind => _kind == TicketKindChoice.code || _kind == TicketKindChoice.test;
  bool get _reportKind => _kind == TicketKindChoice.plan || _kind == TicketKindChoice.analysis || _kind == TicketKindChoice.bug;

  void _pickKind(TicketKindChoice k) => setState(() {
        _kind = k;
        // Code and tests need a repository: pick the first rather than show an error.
        if (_changeKind && _pick.isEmpty && widget.repos.isNotEmpty) _pick = RepoPick.single(widget.repos.first.id);
      });
  String? _err;

  @override
  void dispose() {
    _title.dispose();
    _number.dispose();
    _desc.dispose();
    _files.dispose();
    super.dispose();
  }

  /// The create button waits for the uploads.
  void _filesChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _create() async {
    final l = AppLocalizations.of(context);
    if (_title.text.trim().isEmpty) {
      setState(() => _err = l.tasksTitleRequired);
      return;
    }
    if (_changeKind && _pick.isEmpty) {
      setState(() => _err = l.tasksRepoNeeded);
      return;
    }
    setState(() {
      _busy = true;
      _err = null;
    });
    final repo = _pick.payload;
    try {
      final res = await ref.read(apiProvider)!.getTasksApi().createTask(
            taskCreate: TaskCreate(
              repoId: repo.repoId,
              repoIds: repo.repoIds,
              groupId: repo.groupId,
              kind: _kind,
              title: _title.text.trim(),
              ticketNumber: _number.text.trim().isEmpty ? null : _number.text.trim(),
              description: _desc.text.trim(),
              priority: _priority,
              afterApprove: _after,
              start: _start,
              followUps: _followUps,
              attachments: _files.ids.isEmpty ? null : _files.ids,
            ),
          );
      if (mounted) Navigator.pop(context, res.data?.key);
    } catch (e) {
      if (mounted) showSnack(context, errorMessage(e, l.commonError));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// The repository choice: groups, then repositories (several can be
  /// picked), then what the task will work in when it is more than one.
  Widget _repoChoice(AppLocalizations l, Agnts c) {
    final groups = widget.groups.where((g) => RepoPick.members(g).isNotEmpty || _pick.group?.id == g.id).toList();
    final sub = TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: c.ink3);
    final hint = TextStyle(fontSize: 13, color: c.ink3, height: 1.35);
    final group = _pick.group;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
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
        if (!_changeKind) FilterChipH(label: l.tasksNoRepo, selected: _pick.isEmpty, onTap: () => setState(() => _pick = const RepoPick())),
        for (final r in widget.repos)
          FilterChipH(label: r.name, dot: _repoColor(r), selected: _pick.contains(r.id), onTap: () => setState(() => _pick = _pick.toggle(r.id))),
      ]),
      if (widget.repos.length > 1) ...[
        const SizedBox(height: 6),
        Text(l.mgroupsPickHint, style: hint),
      ],
      if (group != null || _pick.ids.length > 1) ...[
        const SizedBox(height: 12),
        Text(l.mgroupsInTask, style: sub),
        if (group != null) ...[
          const SizedBox(height: 2),
          Text(_pick.edited ? l.mgroupsFromGroupEdited(group.name) : l.mgroupsFromGroup(group.name), style: hint),
        ],
        const SizedBox(height: 6),
        if (_pick.isEmpty)
          Text(l.mgroupsNoMembers, style: hint)
        else
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final (i, id) in _pick.ids.indexed)
              _RepoTag(
                name: _repoName(id),
                primary: i == 0 ? l.mgroupsPrimary : null,
                removeLabel: l.mgroupsRemove(_repoName(id)),
                onRemove: _busy ? null : () => setState(() => _pick = _pick.remove(id)),
              ),
          ]),
      ],
    ]);
  }

  String _repoName(int id) {
    for (final r in widget.repos) {
      if (r.id == id) return r.name;
    }
    for (final m in _pick.group?.members ?? const <RepoGroupMember>[]) {
      if (m.repoId == id) return m.repoName;
    }
    return '#$id';
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final t = Theme.of(context).textTheme;
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: keyboard),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        // .sh-h
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(l.mobileNewTask, style: t.titleLarge),
                const SizedBox(height: 2),
                Text(l.tasksDrawerSub, style: TextStyle(color: c.ink3, fontSize: 14)),
              ]),
            ),
            const SizedBox(width: 12),
            RoundIconButton('close', tooltip: l.navClose, onTap: () => Navigator.pop(context)),
          ]),
        ),
        // .sh-b
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              _Field(label: l.kindTitle, child: KindChoices(value: _kind, onPick: _pickKind, enabled: !_busy)),
              _Field(label: l.mobileTaskRepo, child: _repoChoice(l, c)),
              _Field(
                label: l.mobileTaskTitle,
                child: TextField(
                  controller: _title,
                  autofocus: true,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.sentences,
                  onChanged: (_) {
                    if (_err != null) setState(() => _err = null);
                  },
                  decoration: InputDecoration(hintText: l.tasksTitlePh),
                ),
              ),
              _Field(
                label: l.tasksTicketNumber,
                child: TextField(
                  controller: _number,
                  enabled: !_busy,
                  maxLength: 64,
                  autocorrect: false,
                  enableSuggestions: false,
                  textInputAction: TextInputAction.next,
                  style: TextStyle(fontFamily: AgntsFonts.mono),
                  decoration: InputDecoration(hintText: l.tasksTicketNumberPh, helperText: l.tasksTicketNumberHelp, helperMaxLines: 3, counterText: ''),
                ),
              ),
              _Field(
                label: l.mobileTaskDescription,
                child: TextField(
                  controller: _desc,
                  minLines: 4,
                  maxLines: 8,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(hintText: l.tasksDescPh),
                ),
              ),
              _Field(label: l.filesTitle, child: AttachmentPicker(controller: _files, enabled: !_busy)),
              _Field(
                label: l.mobileTaskPriority,
                child: Segmented<TaskCreatePriorityEnum>(
                  full: true,
                  options: [
                    (TaskCreatePriorityEnum.low, l.mobilePriorityLow),
                    (TaskCreatePriorityEnum.medium, l.mobilePriorityMedium),
                    (TaskCreatePriorityEnum.high, l.mobilePriorityHigh),
                  ],
                  value: _priority,
                  onChanged: (v) => setState(() => _priority = v),
                ),
              ),
              if (!_reportKind)
                _Field(
                  label: l.mobileAfterApprove,
                  child: Segmented<TaskCreateAfterApproveEnum>(
                    full: true,
                    options: [
                      (TaskCreateAfterApproveEnum.main, l.mobileAfterMain),
                      (TaskCreateAfterApproveEnum.pr, l.mobileAfterPr),
                    ],
                    value: _after,
                    onChanged: (v) => setState(() => _after = v),
                  ),
                ),
              _Field(
                label: l.followUpsMode,
                child: Segmented<FollowUpsMode>(
                  full: true,
                  options: [
                    (FollowUpsMode.inherit, l.followUpsModeInherit),
                    (FollowUpsMode.on_, l.followUpsModeOn),
                    (FollowUpsMode.off, l.followUpsModeOff),
                  ],
                  value: _followUps,
                  onChanged: (v) => setState(() => _followUps = v),
                ),
              ),
              _Field(
                label: l.mobileStart,
                last: true,
                child: Column(children: [
                  for (final (v, title, hint) in [
                    (TaskCreateStartEnum.ask, l.mobileStartAsk, l.tasksStartAskHint),
                    (TaskCreateStartEnum.code, l.mobileStartCode, l.tasksStartCodeHint),
                    (TaskCreateStartEnum.queue, l.mobileStartQueue, l.tasksStartQueueHint),
                  ]) ...[
                    if (v != TaskCreateStartEnum.ask) const SizedBox(height: 8),
                    _Choice(title: title, hint: hint, selected: _start == v, onTap: () => setState(() => _start = v)),
                  ],
                ]),
              ),
              if (_err != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(_err!, style: TextStyle(color: c.badInk, fontSize: 13.5, fontWeight: FontWeight.w700)),
                ),
            ]),
          ),
        ),
        // .sh-f
        Container(
          decoration: BoxDecoration(border: Border(top: BorderSide(color: c.line))),
          padding: EdgeInsets.fromLTRB(20, 10, 20, 12 + (keyboard > 0 ? 0 : MediaQuery.paddingOf(context).bottom)),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            if (_files.uploading)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(l.filesWait, style: TextStyle(fontSize: 13, color: c.ink3)),
              ),
            Row(children: [
              Expanded(child: OutlinedButton(onPressed: _busy ? null : () => Navigator.pop(context), child: Text(l.mobileCancel))),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  onPressed: _busy || _files.uploading ? null : _create,
                  child: _busy
                      ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: c.onPrimary))
                      : Text(_start == TaskCreateStartEnum.queue ? l.tasksCreate : l.tasksCreateStart, maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
              ),
            ]),
          ]),
        ),
      ]),
    );
  }
}

/// A picked repository with a remove button; the main one says so.
class _RepoTag extends StatelessWidget {
  const _RepoTag({required this.name, required this.removeLabel, this.primary, this.onRemove});
  final String name;
  final String? primary;
  final String removeLabel;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final c = Agnts.of(context);
    return Container(
      constraints: const BoxConstraints(minHeight: 36),
      padding: const EdgeInsets.only(left: 14, right: 2),
      decoration: ShapeDecoration(color: c.surface, shape: StadiumBorder(side: BorderSide(color: c.line4))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: c.ink)),
        if (primary != null) ...[
          const SizedBox(width: 6),
          Text(primary!, style: TextStyle(fontSize: 12.5, color: c.ink3)),
        ],
        IconButton(
          tooltip: removeLabel,
          visualDensity: VisualDensity.compact,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          padding: EdgeInsets.zero,
          onPressed: onRemove,
          icon: HIcon('close', size: 14, color: c.ink3, stroke: 2.4),
        ),
      ]),
    );
  }
}

/// A labelled form field (.fld).
class _Field extends StatelessWidget {
  const _Field({required this.label, required this.child, this.last = false});
  final String label;
  final Widget child;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final c = Agnts.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: last ? 0 : 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5, color: c.ink)),
        const SizedBox(height: 7),
        child,
      ]),
    );
  }
}

/// A radio card with a bold title and a hint line (.choice).
class _Choice extends StatelessWidget {
  const _Choice({required this.title, required this.hint, required this.selected, required this.onTap});
  final String title;
  final String hint;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = Agnts.of(context);
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
      side: BorderSide(color: selected ? c.primary : c.line, width: selected ? 2 : 1),
    );
    return Semantics(
      selected: selected,
      inMutuallyExclusiveGroup: true,
      button: true,
      child: Material(
        color: selected ? c.help : c.surface,
        shape: shape,
        child: InkWell(
          customBorder: shape,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                width: 20,
                height: 20,
                margin: const EdgeInsets.only(top: 1),
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: selected ? c.primary : c.line3, width: 2)),
                alignment: Alignment.center,
                child: selected
                    ? Container(width: 10, height: 10, decoration: BoxDecoration(color: c.primary, shape: BoxShape.circle))
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: c.ink)),
                  const SizedBox(height: 2),
                  Text(hint, style: TextStyle(fontSize: 13.5, color: c.ink2, height: 1.35)),
                ]),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

/// Edit or delete a task that has not started (PUT and DELETE /tasks/{key}).
Future<void> showTaskActions(BuildContext context, WidgetRef ref, Ticket t) async {
  final l = AppLocalizations.of(context);
  final c = Agnts.of(context);
  final pick = await showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    builder: (ctx) => SafeArea(
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          child: Text('${t.key} · ${t.title}', maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(ctx).textTheme.titleMedium),
        ),
        ListTile(leading: HIcon('tasks', size: 22, color: c.primary), title: Text(l.minsightsEditTask), onTap: () => Navigator.pop(ctx, 'edit')),
        ListTile(
          leading: HIcon('close', size: 22, color: c.badInk),
          title: Text(l.ticketDelete, style: TextStyle(color: c.badInk)),
          onTap: () => Navigator.pop(ctx, 'delete'),
        ),
        const SizedBox(height: 8),
      ]),
    ),
  );
  if (!context.mounted) return;
  if (pick == 'edit') {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.9),
      builder: (_) => _EditTaskSheet(t),
    );
    if (saved == true && context.mounted) {
      ref.invalidate(ticketsProvider);
      ref.invalidate(ticketProvider(t.key));
      showSnack(context, l.minsightsTaskSaved);
    }
  } else if (pick == 'delete') {
    final ok = await confirmAction(context, title: l.ticketDelete, body: l.ticketDeleteConfirm(t.key), action: l.ticketDelete, danger: true);
    if (!ok || !context.mounted) return;
    try {
      await ref.read(apiProvider)!.getTasksApi().deleteTask(key: t.key);
      ref.invalidate(ticketsProvider);
      if (context.mounted) showSnack(context, l.minsightsTaskDeleted(t.key));
    } catch (e) {
      if (context.mounted) showSnack(context, errorMessage(e, l.commonError));
    }
  }
}

/// The edit sheet: kind, title, ticket number, description, priority and
/// what happens after approval. The repository is fixed once created.
class _EditTaskSheet extends ConsumerStatefulWidget {
  const _EditTaskSheet(this.t);
  final Ticket t;

  @override
  ConsumerState<_EditTaskSheet> createState() => _EditTaskSheetState();
}

class _EditTaskSheetState extends ConsumerState<_EditTaskSheet> {
  late final _title = TextEditingController(text: widget.t.title);
  late final _number = TextEditingController(text: widget.t.ticketNumber ?? '');
  late final _desc = TextEditingController(text: widget.t.description);
  late var _priority = TaskUpdatePriorityEnum.values.firstWhere((p) => p.value == widget.t.priority, orElse: () => TaskUpdatePriorityEnum.medium);
  late var _after = widget.t.afterApprove == TicketAfterApproveEnum.main ? TaskUpdateAfterApproveEnum.main : TaskUpdateAfterApproveEnum.pr;
  late var _kind = TicketKindChoice.values.firstWhere((k) => k.value == widget.t.kind.value, orElse: () => TicketKindChoice.auto);
  bool _busy = false;
  String? _err;

  bool get _reportKind => _kind == TicketKindChoice.plan || _kind == TicketKindChoice.analysis || _kind == TicketKindChoice.bug;

  @override
  void dispose() {
    _title.dispose();
    _number.dispose();
    _desc.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l = AppLocalizations.of(context);
    if (_title.text.trim().isEmpty) {
      setState(() => _err = l.tasksTitleRequired);
      return;
    }
    setState(() {
      _busy = true;
      _err = null;
    });
    try {
      await ref.read(apiProvider)!.getTasksApi().updateTask(
            key: widget.t.key,
            taskUpdate: TaskUpdate(
              title: _title.text.trim(),
              ticketNumber: _number.text.trim(),
              description: _desc.text.trim(),
              priority: _priority,
              afterApprove: _reportKind ? null : _after,
              kind: _kind,
            ),
          );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) setState(() => _err = errorMessage(e, l.commonError));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: keyboard),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(l.minsightsEditTask, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 2),
                Text(l.minsightsEditTaskSub, style: TextStyle(color: c.ink3, fontSize: 14)),
              ]),
            ),
            const SizedBox(width: 12),
            RoundIconButton('close', tooltip: l.navClose, onTap: () => Navigator.pop(context)),
          ]),
        ),
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              _Field(label: l.kindTitle, child: KindChoices(value: _kind, onPick: (k) => setState(() => _kind = k), enabled: !_busy)),
              _Field(
                label: l.mobileTaskTitle,
                child: TextField(
                  controller: _title,
                  textCapitalization: TextCapitalization.sentences,
                  maxLength: 300,
                  decoration: InputDecoration(hintText: l.tasksTitlePh, counterText: ''),
                ),
              ),
              _Field(
                label: l.tasksTicketNumber,
                child: TextField(
                  controller: _number,
                  maxLength: 64,
                  autocorrect: false,
                  style: TextStyle(fontFamily: AgntsFonts.mono),
                  decoration: InputDecoration(hintText: l.tasksTicketNumberPh, helperText: l.tasksTicketNumberHelp, helperMaxLines: 3, counterText: ''),
                ),
              ),
              _Field(
                label: l.mobileTaskDescription,
                child: TextField(
                  controller: _desc,
                  minLines: 4,
                  maxLines: 8,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(hintText: l.tasksDescPh),
                ),
              ),
              _Field(
                label: l.mobileTaskPriority,
                last: _reportKind,
                child: Segmented<TaskUpdatePriorityEnum>(
                  full: true,
                  options: [
                    (TaskUpdatePriorityEnum.low, l.mobilePriorityLow),
                    (TaskUpdatePriorityEnum.medium, l.mobilePriorityMedium),
                    (TaskUpdatePriorityEnum.high, l.mobilePriorityHigh),
                  ],
                  value: _priority,
                  onChanged: (v) => setState(() => _priority = v),
                ),
              ),
              if (!_reportKind)
                _Field(
                  label: l.mobileAfterApprove,
                  last: true,
                  child: Segmented<TaskUpdateAfterApproveEnum>(
                    full: true,
                    options: [
                      (TaskUpdateAfterApproveEnum.main, l.mobileAfterMain),
                      (TaskUpdateAfterApproveEnum.pr, l.mobileAfterPr),
                    ],
                    value: _after,
                    onChanged: (v) => setState(() => _after = v),
                  ),
                ),
              if (_err != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(_err!, style: TextStyle(color: c.badInk, fontSize: 13.5, fontWeight: FontWeight.w700)),
                ),
            ]),
          ),
        ),
        Container(
          decoration: BoxDecoration(border: Border(top: BorderSide(color: c.line))),
          padding: EdgeInsets.fromLTRB(20, 10, 20, 12 + (keyboard > 0 ? 0 : MediaQuery.paddingOf(context).bottom)),
          child: Row(children: [
            Expanded(child: OutlinedButton(onPressed: _busy ? null : () => Navigator.pop(context), child: Text(l.mobileCancel))),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton(
                onPressed: _busy ? null : _save,
                child: _busy
                    ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: c.onPrimary))
                    : Text(l.minsightsSave),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}
