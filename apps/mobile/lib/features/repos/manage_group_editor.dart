import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agnts_api/agnts_api.dart';

import '../../core/api.dart';
import '../../core/data.dart';
import '../../l10n/app_localizations.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import '../../widgets/ui.dart';
import 'manage_logic.dart';
import 'manage_widgets.dart';
import 'name_format_fields.dart';

/// Add or edit a repository group: repositories that change together, in
/// order (the first is the primary of the group's tickets), each with a
/// role. Saving may come back with warnings; the sheet then stays open to
/// show them (GroupDrawer).
class GroupEditor extends ConsumerStatefulWidget {
  const GroupEditor({super.key, required this.group, required this.repos});
  final RepoGroup? group;
  final List<Repository> repos;

  @override
  ConsumerState<GroupEditor> createState() => _GroupEditorState();
}

class _Member {
  _Member(this.repoId, String role) : role = TextEditingController(text: role);
  final int repoId;
  final TextEditingController role;
}

class _GroupEditorState extends ConsumerState<GroupEditor> {
  late final _name = TextEditingController(text: widget.group?.name ?? '');
  late final _desc = TextEditingController(text: widget.group?.description ?? '');
  late final _prefix = TextEditingController(text: widget.group?.taskPrefix ?? '');
  late final _branchTmpl = TextEditingController(text: widget.group?.branchTemplate ?? '');
  late final _commitTmpl = TextEditingController(text: widget.group?.commitTemplate ?? '');
  late final _instructions = TextEditingController(text: widget.group?.instructions ?? '');
  late var _members = [for (final m in widget.group?.members ?? const <RepoGroupMember>[]) _Member(m.repoId, m.role)];
  // The group as last saved here, while its warnings are shown.
  RepoGroup? _saved;
  String _error = '';
  bool _busy = false;

  RepoGroup? get _current => _saved ?? widget.group;

  @override
  void dispose() {
    for (final c in [_name, _desc, _prefix, _branchTmpl, _commitTmpl, _instructions, for (final m in _members) m.role]) {
      c.dispose();
    }
    super.dispose();
  }

  Repository? _repo(int id) => widget.repos.where((r) => r.id == id).firstOrNull;
  String _nameOf(int id) => _repo(id)?.name ?? widget.group?.members.where((m) => m.repoId == id).firstOrNull?.repoName ?? '#$id';
  bool _archived(int id) =>
      _repo(id)?.archivedAt != null || (widget.group?.members.where((m) => m.repoId == id).firstOrNull?.archived ?? false);

  Future<void> _save() async {
    final l = AppLocalizations.of(context);
    if (_members.isEmpty) {
      setState(() => _error = l.groupsMembersNeeded);
      return;
    }
    if (_name.text.trim().isEmpty) {
      setState(() => _error = l.mmanageFillAll);
      return;
    }
    final body = RepoGroupInput(
      name: _name.text.trim(),
      description: _desc.text.trim(),
      taskPrefix: _prefix.text.trim().toUpperCase(),
      instructions: _instructions.text,
      branchTemplate: _branchTmpl.text.trim(),
      commitTemplate: _commitTmpl.text.trim(),
      members: [
        for (final m in _members)
          RepoGroupInputMembersInner(repoId: m.repoId, role: m.role.text.trim().isEmpty ? null : m.role.text.trim()),
      ],
    );
    setState(() {
      _busy = true;
      _error = '';
    });
    try {
      final api = ref.read(apiProvider)!.getReposApi();
      final id = _current?.id;
      final g =
          (id == null ? await api.createRepoGroup(repoGroupInput: body) : await api.updateRepoGroup(id: id, repoGroupInput: body)).data!;
      ref.invalidate(repoGroupsProvider);
      ref.invalidate(reposProvider);
      if (!mounted) return;
      showSnack(context, l.groupsSaved(g.name));
      if (g.warnings.isNotEmpty) {
        setState(() => _saved = g);
      } else {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) setState(() => _error = errorMessage(e, l.commonError));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final warnings = _current?.warnings ?? const <String>[];
    // Archived repositories stay if already members, but cannot be added.
    final addable = widget.repos.where((r) => r.archivedAt == null && !_members.any((m) => m.repoId == r.id)).toList();
    final firstPrefix = _members.isEmpty ? '' : _repo(_members.first.repoId)?.taskPrefix ?? '';
    final prefix = (_prefix.text.isNotEmpty ? _prefix.text : (firstPrefix.isNotEmpty ? firstPrefix : 'VIS')).toUpperCase();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SheetTitle(_current?.name ?? l.groupsAdd, sub: l.groupsDrawerSub),
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (warnings.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: HelpBox(l.groupsWarningsTitle, tone: Tone.warn, child: Text(warnings.map((w) => '• $w').join('\n'))),
                  ),
                ManageField(
                  label: l.groupsName,
                  child: ManageInput(controller: _name, hint: l.groupsNamePh, maxLength: 100),
                ),
                ManageField(
                  label: l.groupsDescription,
                  child: ManageInput(controller: _desc, maxLength: 500),
                ),
                ManageField(
                  label: l.groupsMembers,
                  help: l.groupsMembersHelp,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_members.isEmpty) Text(l.groupsNoMembers, style: TextStyle(fontSize: 13, color: c.ink3)),
                      for (final (i, m) in _members.indexed)
                        Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: c.line),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Wrap(
                                      spacing: 6,
                                      crossAxisAlignment: WrapCrossAlignment.center,
                                      children: [
                                        Text(
                                          _nameOf(m.repoId),
                                          style: TextStyle(fontWeight: FontWeight.w700, color: c.ink),
                                        ),
                                        if (i == 0) ToneBadge(l.groupsPrimary, Tone.info, small: true),
                                        if (_archived(m.repoId)) ToneBadge(l.groupsArchived, Tone.gray, small: true),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: l.groupsMoveUp(_nameOf(m.repoId)),
                                    visualDensity: VisualDensity.compact,
                                    onPressed: i == 0 ? null : () => setState(() => _members = moved(_members, i, -1)),
                                    icon: const Icon(Icons.arrow_upward_rounded, size: 18),
                                  ),
                                  IconButton(
                                    tooltip: l.groupsMoveDown(_nameOf(m.repoId)),
                                    visualDensity: VisualDensity.compact,
                                    onPressed: i == _members.length - 1 ? null : () => setState(() => _members = moved(_members, i, 1)),
                                    icon: const Icon(Icons.arrow_downward_rounded, size: 18),
                                  ),
                                  IconButton(
                                    tooltip: l.formRemove(_nameOf(m.repoId)),
                                    visualDensity: VisualDensity.compact,
                                    onPressed: () => setState(() => _members = [..._members]..removeAt(i)),
                                    icon: const Icon(Icons.close_rounded, size: 18),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 8, top: 4),
                                child: ManageInput(controller: m.role, hint: l.groupsRolePh, maxLength: 40),
                              ),
                            ],
                          ),
                        ),
                      DropdownButtonFormField<int>(
                        key: ValueKey(_members.length),
                        isExpanded: true,
                        hint: Text(addable.isEmpty ? l.groupsNoMoreRepos : l.groupsAddMember),
                        items: [for (final r in addable) DropdownMenuItem(value: r.id, child: Text(r.name))],
                        onChanged: addable.isEmpty
                            ? null
                            : (id) {
                                if (id != null) setState(() => _members = [..._members, _Member(id, '')]);
                              },
                      ),
                    ],
                  ),
                ),
                ManageField(
                  label: l.reposTaskPrefix,
                  help: l.groupsPrefixHelp(prefix),
                  child: ManageInput(controller: _prefix, mono: true, hint: 'SHOP', maxLength: 8, onChanged: (_) => setState(() {})),
                ),
                NameFormatFields(
                  branch: _branchTmpl,
                  commit: _commitTmpl,
                  taskPrefix: prefix,
                  group: true,
                  onChanged: (_) => setState(() {}),
                ),
                ManageField(
                  label: l.groupsInstructions,
                  help: l.groupsInstructionsHelp,
                  child: ManageInput(controller: _instructions, minLines: 3, maxLines: 10, hint: l.groupsInstructionsPh, maxLength: 20000),
                ),
                if (_error.isNotEmpty) ErrorLine(_error),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(onPressed: () => Navigator.pop(context), child: Text(_saved != null ? l.formClose : l.formCancel)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton(onPressed: _busy ? null : _save, child: Text(_current != null ? l.formSave : l.groupsAdd)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
