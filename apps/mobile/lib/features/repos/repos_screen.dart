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
import 'manage_group_editor.dart';
import 'manage_import.dart';
import 'manage_logic.dart';
import 'manage_repo_editor.dart';
import 'manage_widgets.dart';

enum _View { active, archived, groups }

/// The workspace's repositories: active and archived ones, and the groups
/// of repositories that change together. Add, import, edit, archive and
/// restore repositories; the owner makes and edits groups (ReposPage).
class ReposScreen extends ConsumerStatefulWidget {
  const ReposScreen({super.key});

  @override
  ConsumerState<ReposScreen> createState() => _ReposScreenState();
}

class _ReposScreenState extends ConsumerState<ReposScreen> {
  var _view = _View.active;
  String _q = '';
  bool _busy = false;

  Future<void> _archive(Repository r) async {
    final l = AppLocalizations.of(context);
    final archive = r.archivedAt == null;
    if (archive &&
        !await confirmAction(context, title: l.reposArchive, message: l.reposArchiveConfirm(r.name), confirmLabel: l.reposArchive)) {
      return;
    }
    setState(() => _busy = true);
    try {
      final api = ref.read(apiProvider)!.getReposApi();
      final v = (archive ? await api.archiveRepo(id: r.id) : await api.unarchiveRepo(id: r.id)).data!;
      ref.invalidate(reposProvider);
      ref.invalidate(repoGroupsProvider);
      if (mounted) showSnack(context, v.archivedAt != null ? l.reposArchived(v.name) : l.reposRestored(v.name));
    } catch (e) {
      if (mounted) showSnack(context, errorMessage(e, l.commonError));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _deleteGroup(RepoGroup g) async {
    final l = AppLocalizations.of(context);
    if (!await confirmAction(
      context,
      title: l.groupsDelete,
      message: l.groupsDeleteConfirm(g.name),
      confirmLabel: l.groupsDelete,
      danger: true,
    )) {
      return;
    }
    setState(() => _busy = true);
    try {
      await ref.read(apiProvider)!.getReposApi().deleteRepoGroup(id: g.id);
      ref.invalidate(repoGroupsProvider);
      ref.invalidate(reposProvider);
      if (mounted) showSnack(context, l.groupsDeleted(g.name));
    } catch (e) {
      if (mounted) showSnack(context, errorMessage(e, l.commonError));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _import() async {
    final picked = await showManageSheet<RemoteRepository>(context, const ImportSheet());
    if (picked == null || !mounted) return;
    await openRepoEditor(
      context,
      preset: (name: picked.fullName.split('/').last, cloneUrl: picked.cloneUrl, defaultBranch: picked.defaultBranch),
    );
  }

  void _editGroup(RepoGroup? g, List<Repository> repos) => showManageSheet<void>(context, GroupEditor(group: g, repos: repos));

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final owner = ref.watch(currentWorkspaceProvider)?.role == WorkspaceRole.owner;
    final repos = ref.watch(reposProvider);
    final groups = ref.watch(repoGroupsProvider);
    final all = repos.value ?? const <Repository>[];
    final active = all.where((r) => r.archivedAt == null).toList();
    final archived = all.where((r) => r.archivedAt != null).toList();
    final q = _q.trim().toLowerCase();

    return Scaffold(
      appBar: DetailBar(backLabel: l.mobileMore),
      floatingActionButton: _view == _View.groups
          ? (owner ? HFab(tooltip: l.groupsAdd, onTap: () => _editGroup(null, all)) : null)
          : HFab(tooltip: l.reposAdd, onTap: () => openRepoEditor(context)),
      body: AsyncBody<List<Repository>>(
        value: repos,
        onRefresh: () async {
          ref.invalidate(reposProvider);
          ref.invalidate(repoGroupsProvider);
        },
        builder: (_) {
          final list = (_view == _View.archived ? archived : active).where((r) => q.isEmpty || repoHaystack(r).contains(q)).toList();
          final missing = active.where((r) => r.claudeMd == RepositoryClaudeMdEnum.missing).length;
          return ListView(
            padding: const EdgeInsets.only(bottom: 96),
            children: [
              PageHeader(
                title: l.reposTitle,
                sub: l.reposLede,
                long: true,
                actions: [if (_view != _View.groups) RoundIconButton('repos', tooltip: l.reposImport, onTap: _import)],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Segmented<_View>(
                  full: true,
                  options: [
                    (_View.active, l.reposViewActive('${active.length}')),
                    (_View.archived, l.reposViewArchived('${archived.length}')),
                    (_View.groups, l.groupsView('${groups.value?.length ?? 0}')),
                  ],
                  value: _view,
                  onChanged: (v) => setState(() => _view = v),
                ),
              ),
              SearchBox(hint: l.reposSearch, onChanged: (v) => setState(() => _q = v)),
              if (_view == _View.active && missing > 0)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: HelpBox(l.reposMissingHelp(missing), tone: Tone.warn),
                ),
              if (_view == _View.archived)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: Text(l.reposArchivedSub, style: TextStyle(fontSize: 13, color: c.ink3)),
                ),
              if (_view == _View.groups)
                ..._groups(l, c, groups, all, owner, q)
              else if (all.isEmpty)
                EmptyState(title: l.reposNone)
              else if (list.isEmpty)
                EmptyState(
                  title: q.isNotEmpty
                      ? l.reposNoMatch
                      : _view == _View.archived
                      ? l.reposNoArchived
                      : l.reposNone,
                )
              else
                for (final r in list) _repoCard(l, c, r),
            ],
          );
        },
      ),
    );
  }

  Widget _repoCard(AppLocalizations l, Agnts c, Repository r) {
    final hint = TextStyle(fontSize: 13, color: c.ink3);
    final (claude, tone) = switch (r.claudeMd) {
      RepositoryClaudeMdEnum.found => (l.reposFound, Tone.ok),
      RepositoryClaudeMdEnum.missing => (l.reposMissing, Tone.warn),
      _ => (l.reposUnknown, Tone.gray),
    };
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: HCard(
        onTap: () => context.push(Uri(path: '/repos/${r.id}', queryParameters: {'name': r.name}).toString()),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        r.name,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: c.ink),
                      ),
                      Text(
                        r.cloneUrl,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontFamily: AgntsFonts.mono, fontSize: 12, color: c.ink3),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  enabled: !_busy,
                  onSelected: (a) => a == 'edit' ? openRepoEditor(context, repo: r) : _archive(r),
                  itemBuilder: (_) => [
                    if (r.archivedAt == null) PopupMenuItem(value: 'edit', child: Text(l.reposEdit)),
                    PopupMenuItem(value: 'archive', child: Text(r.archivedAt == null ? l.reposArchive : l.reposRestore)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                if (r.jiraProject.isNotEmpty) ToneBadge(l.reposJira(r.jiraProject), Tone.info, small: true),
                if ((r.planeProject ?? '').isNotEmpty) ToneBadge(l.reposPlane(r.planeProject!), Tone.info, small: true),
                ToneBadge(l.reposSide, Tone.gray, small: true),
                ToneBadge('CLAUDE.md · $claude', tone, small: true),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              [
                r.defaultBranch,
                if ((r.toolchains ?? const []).isNotEmpty) r.toolchains!.map((t) => '${t.tool} ${t.version}').join(', '),
                r.testCmd.isEmpty ? '—' : r.testCmd,
                '${l.reposColOpen}: ${r.openTickets}',
              ].join(' · '),
              style: hint,
            ),
            if ((r.groups ?? const []).isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(l.groupsInGroups(r.groups!.map((g) => g.name).join(', ')), style: hint),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _groups(AppLocalizations l, Agnts c, AsyncValue<List<RepoGroup>> value, List<Repository> repos, bool owner, String q) {
    final hint = TextStyle(fontSize: 13, color: c.ink3);
    return switch (value) {
      AsyncError() => [EmptyState(title: l.commonError)],
      AsyncData(:final value) when value.isEmpty => [EmptyState(title: l.groupsNone)],
      AsyncData(:final value) => [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Text(l.groupsSub, style: hint),
        ),
        for (final g in value.where(
          (g) => q.isEmpty || g.name.toLowerCase().contains(q) || g.members.any((m) => m.repoName.toLowerCase().contains(q)),
        ))
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: HCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              g.name,
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: c.ink),
                            ),
                            if (g.description.isNotEmpty) Text(g.description, style: hint),
                          ],
                        ),
                      ),
                      if (g.taskPrefix.isNotEmpty)
                        Text(
                          g.taskPrefix,
                          style: TextStyle(fontFamily: AgntsFonts.mono, fontSize: 12.5, color: c.ink2),
                        ),
                      if (owner)
                        PopupMenuButton<String>(
                          enabled: !_busy,
                          onSelected: (a) => a == 'edit' ? _editGroup(g, repos) : _deleteGroup(g),
                          itemBuilder: (_) => [
                            PopupMenuItem(value: 'edit', child: Text(l.reposEdit)),
                            PopupMenuItem(value: 'delete', child: Text(l.groupsDelete)),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final (i, m) in g.members.indexed)
                        ToneBadge(
                          [
                            m.repoName,
                            if (m.role.isNotEmpty) m.role,
                            if (i == 0) l.groupsPrimary,
                            if (m.archived) l.groupsArchived,
                          ].join(' · '),
                          m.archived ? Tone.gray : Tone.info,
                          small: true,
                        ),
                    ],
                  ),
                  if (g.warnings.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: HelpBox(
                        l.groupsWarningsBadge(g.warnings.length),
                        tone: Tone.warn,
                        child: Text(g.warnings.map((w) => '• $w').join('\n')),
                      ),
                    ),
                ],
              ),
            ),
          ),
      ],
      _ => [
        const Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator()),
        ),
      ],
    };
  }
}
