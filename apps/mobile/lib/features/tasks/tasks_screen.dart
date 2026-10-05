import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hiro_api/hiro_api.dart';
import 'package:intl/intl.dart';

import '../../core/api.dart';
import '../../core/data.dart';
import '../../l10n/app_localizations.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import '../../widgets/ui.dart';
import '../tickets/kinds.dart';

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
    final c = Hiro.of(context);
    final all = ref.watch(ticketsProvider('all'));
    final repos = ref.watch(reposProvider);
    final sideRepos = _taskRepos(repos.value ?? const []);
    return Scaffold(
      backgroundColor: c.bg,
      floatingActionButton: HFab(onTap: _newTask, tooltip: l.mobileNewTask),
      body: SafeArea(
        bottom: false,
        child: AsyncBody<List<Ticket>>(
          value: all,
          onRefresh: () {
            ref.invalidate(reposProvider);
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
                    action: FilledButton(onPressed: _newTask, child: Text(l.mobileNewTask)),
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
    final c = Hiro.of(context);
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
    if (!mounted) return;
    // Without repositories a task can still be a report (or let hiro pick).
    final initial = repos.any((r) => r.id == _repo) ? _repo! : (repos.firstOrNull?.id ?? 0);
    final key = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.9),
      builder: (_) => _NewTaskSheet(repos: repos, initialRepo: initial),
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

/// A task as a card, with its next step when it needs you.
class _TaskCard extends StatelessWidget {
  const _TaskCard(this.t);
  final Ticket t;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final (String? action, Tone tone) = switch (t.state) {
      TicketState.waitingForAnswers => (l.mtasksActAnswers, Tone.warn),
      TicketState.waitingForReview => (l.mtasksActReview, Tone.warn),
      TicketState.failed => (l.mtasksActFailed, Tone.bad),
      TicketState.rateLimited => (l.mtasksActResume, Tone.bad),
      TicketState.new_ => (t.held == true ? l.mtasksActHeld : l.mtasksActAnalyze, Tone.info),
      _ => (null, Tone.info),
    };
    return TicketCard(
      ticket: t,
      onTap: () => context.push('/tickets/${t.key}'),
      meta: [Text(_when(context, t.updatedAt))],
      action: action,
      actionTone: tone,
    );
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
  const _NewTaskSheet({required this.repos, required this.initialRepo});
  final List<Repository> repos;
  final int initialRepo; // 0: no repository

  @override
  ConsumerState<_NewTaskSheet> createState() => _NewTaskSheetState();
}

class _NewTaskSheetState extends ConsumerState<_NewTaskSheet> {
  late int _repo = widget.initialRepo;
  final _title = TextEditingController();
  final _desc = TextEditingController();
  var _priority = TaskCreatePriorityEnum.medium;
  var _after = TaskCreateAfterApproveEnum.pr;
  var _start = TaskCreateStartEnum.ask;
  var _kind = TicketKindChoice.auto;
  bool _busy = false;

  bool get _changeKind => _kind == TicketKindChoice.code || _kind == TicketKindChoice.test;
  bool get _reportKind => _kind == TicketKindChoice.plan || _kind == TicketKindChoice.analysis || _kind == TicketKindChoice.bug;

  void _pickKind(TicketKindChoice k) => setState(() {
        _kind = k;
        // Code and tests need a repository: pick the first rather than show an error.
        if (_changeKind && _repo == 0 && widget.repos.isNotEmpty) _repo = widget.repos.first.id;
      });
  String? _err;

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final l = AppLocalizations.of(context);
    if (_title.text.trim().isEmpty) {
      setState(() => _err = l.tasksTitleRequired);
      return;
    }
    if (_changeKind && _repo == 0) {
      setState(() => _err = l.tasksRepoNeeded);
      return;
    }
    setState(() {
      _busy = true;
      _err = null;
    });
    try {
      final res = await ref.read(apiProvider)!.getTasksApi().createTask(
            taskCreate: TaskCreate(
              repoId: _repo == 0 ? null : _repo,
              kind: _kind,
              title: _title.text.trim(),
              description: _desc.text.trim(),
              priority: _priority,
              afterApprove: _after,
              start: _start,
            ),
          );
      if (mounted) Navigator.pop(context, res.data?.key);
    } catch (e) {
      if (mounted) showSnack(context, errorMessage(e, l.commonError));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Hiro.of(context);
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
              _Field(
                label: l.mobileTaskRepo,
                child: Wrap(spacing: 8, runSpacing: 8, children: [
                  if (!_changeKind) FilterChipH(label: l.tasksNoRepo, selected: _repo == 0, onTap: () => setState(() => _repo = 0)),
                  for (final r in widget.repos)
                    FilterChipH(label: r.name, dot: _repoColor(r), selected: _repo == r.id, onTap: () => setState(() => _repo = r.id)),
                ]),
              ),
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
          child: Row(children: [
            Expanded(child: OutlinedButton(onPressed: _busy ? null : () => Navigator.pop(context), child: Text(l.mobileCancel))),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton(
                onPressed: _busy ? null : _create,
                child: _busy
                    ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: c.onPrimary))
                    : Text(_start == TaskCreateStartEnum.queue ? l.tasksCreate : l.tasksCreateStart, maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ),
          ]),
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
    final c = Hiro.of(context);
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
    final c = Hiro.of(context);
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
