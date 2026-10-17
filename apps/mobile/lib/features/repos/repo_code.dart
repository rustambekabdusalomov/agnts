import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agnts_api/agnts_api.dart';

import '../../core/api.dart';
import '../../l10n/app_localizations.dart';
import '../../theme.dart';
import '../../widgets/ui.dart';
import '../tickets/kinds.dart' show ReportMarkdown;
import 'repo_diff.dart';
import '../account/account_widgets.dart' show openLink;

typedef _TreeKey = ({int id, String ref, String path});

final _treeProvider = FutureProvider.autoDispose.family<RepoTree, _TreeKey>((ref, k) async {
  final res = await requireApi(ref).getReposApi().listRepoTree(id: k.id, ref: k.ref, path: k.path.isEmpty ? null : k.path);
  return res.data!;
});
final _fileProvider = FutureProvider.autoDispose.family<RepoFile, _TreeKey>((ref, k) async {
  return (await requireApi(ref).getReposApi().getRepoFile(id: k.id, ref: k.ref, path: k.path)).data!;
});

/// The folders a path passes through, for the breadcrumbs:
/// "a/b/c" gives (a, a), (b, a/b), (c, a/b/c).
List<({String name, String path})> crumbsOf(String path) {
  final parts = path.split('/').where((p) => p.isNotEmpty).toList();
  return [for (var i = 0; i < parts.length; i++) (name: parts[i], path: parts.sublist(0, i + 1).join('/'))];
}

/// The folder holding [path] ("" for the root).
String parentOf(String path) {
  final parts = path.split('/').where((p) => p.isNotEmpty).toList();
  return parts.isEmpty ? '' : parts.sublist(0, parts.length - 1).join('/');
}

bool isReadme(String name) => RegExp(r'^readme(\.(md|markdown|txt|rst))?$', caseSensitive: false).hasMatch(name);
bool isMarkdown(String path) => RegExp(r'\.(md|markdown)$', caseSensitive: false).hasMatch(path);

/// "1.2 KB": a size as the admin panel's fmtBytes writes it.
String fmtBytes(int n) {
  if (n < 1024) return '$n B';
  if (n < 1024 * 1024) return '${(n / 1024).toStringAsFixed(1)} KB';
  return '${(n / (1024 * 1024)).toStringAsFixed(1)} MB';
}

/// The repository's files on a branch, read from the git host: a folder
/// listing with its README underneath, or one open file (CodeTab.vue).
class RepoCodeTab extends ConsumerStatefulWidget {
  const RepoCodeTab({super.key, required this.repoId, required this.defaultBranch, required this.branches});
  final int repoId;
  final String defaultBranch;
  final List<String> branches;

  @override
  ConsumerState<RepoCodeTab> createState() => _RepoCodeTabState();
}

class _RepoCodeTabState extends ConsumerState<RepoCodeTab> {
  String? _ref;
  String _dir = '';
  String? _file;
  bool _source = false;

  String get _branch => _ref ?? widget.defaultBranch;

  void _go({String dir = '', String? file}) => setState(() {
        _dir = file == null ? dir : parentOf(file);
        _file = file;
        _source = false;
      });

  Future<void> _pickBranch() async {
    final l = AppLocalizations.of(context);
    final names = [
      if (!widget.branches.contains(widget.defaultBranch)) widget.defaultBranch,
      ...widget.branches,
      if (!widget.branches.contains(_branch) && _branch != widget.defaultBranch) _branch,
    ];
    final picked = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(ctx).height * 0.7),
          child: ListView(shrinkWrap: true, padding: const EdgeInsets.fromLTRB(16, 0, 16, 16), children: [
            Padding(padding: const EdgeInsets.only(left: 4, bottom: 8), child: Text(l.repoCodeBranch, style: Theme.of(ctx).textTheme.titleLarge)),
            ListGroup(children: [
              for (final b in names)
                ListRow(
                  title: b,
                  subtitle: b == widget.defaultBranch ? l.repoDefault : null,
                  trailing: b == _branch ? HIcon('check', size: 18, color: Agnts.of(ctx).primary, stroke: 2.4) : const SizedBox.shrink(),
                  onTap: () => Navigator.pop(ctx, b),
                ),
            ]),
          ]),
        ),
      ),
    );
    // Another branch may not have this folder: start again at its root.
    if (picked != null && picked != _branch) {
      setState(() {
        _ref = picked;
        _dir = '';
        _file = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final crumbs = crumbsOf(_file ?? _dir);
    final link = TextStyle(fontFamily: AgntsFonts.mono, fontSize: 13.5, color: c.primaryInk);
    final cur = TextStyle(fontFamily: AgntsFonts.mono, fontSize: 13.5, fontWeight: FontWeight.w700, color: c.ink);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(l.repoCodeSub, style: TextStyle(fontSize: 13.5, color: c.ink3)),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: _pickBranch,
            icon: HIcon('down', size: 16, color: c.ink2, stroke: 2.2),
            label: Text(_branch, style: const TextStyle(fontFamily: AgntsFonts.mono, fontSize: 13)),
          ),
        ),
        const SizedBox(height: 10),
        // Breadcrumbs: Root / a / b
        Wrap(spacing: 4, runSpacing: 4, crossAxisAlignment: WrapCrossAlignment.center, children: [
          InkWell(onTap: crumbs.isEmpty ? null : () => _go(), child: Text(l.repoCodeRoot, style: crumbs.isEmpty ? cur : link)),
          for (final (i, cr) in crumbs.indexed) ...[
            Text('/', style: TextStyle(color: c.ink3)),
            if (i == crumbs.length - 1)
              Text(cr.name, style: cur)
            else
              InkWell(onTap: () => _go(dir: cr.path), child: Text(cr.name, style: link)),
          ],
        ]),
        const SizedBox(height: 12),
        if (_file != null) _fileView(context, _file!) else _folderView(context),
      ]),
    );
  }

  Widget _folderView(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final tree = ref.watch(_treeProvider((id: widget.repoId, ref: _branch, path: _dir)));
    return switch (tree) {
      AsyncData(:final value) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          if (value.entries.isEmpty && _dir.isEmpty)
            EmptyState(title: l.repoCodeEmpty)
          else
            ListGroup(children: [
              if (_dir.isNotEmpty) _EntryRow(name: '..', dir: true, onTap: () => _go(dir: parentOf(_dir))),
              for (final e in value.entries)
                _EntryRow(
                  name: e.name,
                  dir: e.type == TreeEntryTypeEnum.dir,
                  badge: switch (e.type) {
                    TreeEntryTypeEnum.submodule => l.repoCodeSubmodule,
                    TreeEntryTypeEnum.symlink => l.repoCodeSymlink,
                    _ => null,
                  },
                  size: e.size,
                  onTap: switch (e.type) {
                    TreeEntryTypeEnum.dir => () => _go(dir: e.path),
                    TreeEntryTypeEnum.submodule => null,
                    _ => () => _go(file: e.path),
                  },
                ),
            ]),
          if (value.capped == true)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(l.repoCodeCapped('${value.entries.length}'), style: TextStyle(fontSize: 13, color: c.ink3)),
            ),
          if (value.entries.where((e) => e.type == TreeEntryTypeEnum.file && isReadme(e.name)).firstOrNull case final readme?)
            _Readme(repoId: widget.repoId, branch: _branch, entry: readme),
        ]),
      AsyncError(:final error) => HelpBox(errorMessage(error, l.commonError), tone: Tone.bad),
      _ => const Padding(padding: EdgeInsets.all(32), child: Center(child: CircularProgressIndicator())),
    };
  }

  Widget _fileView(BuildContext context, String path) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final blob = ref.watch(_fileProvider((id: widget.repoId, ref: _branch, path: path)));
    return switch (blob) {
      AsyncData(:final value) => () {
          final content = value.content;
          final lines = content == null ? null : codeLines(content);
          final md = isMarkdown(path) && content != null && content.isNotEmpty;
          final Widget body;
          if (value.binary) {
            body = _note(context, l.repoCodeBinary);
          } else if (value.tooLarge) {
            body = _note(context, l.repoCodeTooLarge);
          } else if (content == null || content.isEmpty) {
            body = _note(context, l.repoCodeEmptyFile);
          } else if (md && !_source) {
            body = Padding(padding: const EdgeInsets.all(14), child: ReportMarkdown(content));
          } else {
            body = CodeBlock(lines: lines!, path: path);
          }
          return Container(
            decoration: BoxDecoration(color: c.surface, border: Border.all(color: c.line), borderRadius: BorderRadius.circular(14)),
            clipBehavior: Clip.antiAlias,
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Container(
                color: c.graySoft,
                padding: const EdgeInsets.fromLTRB(12, 6, 4, 6),
                child: Row(children: [
                  Expanded(
                    child: Text(
                      [if (lines != null) l.repoCodeLines(lines.length), fmtBytes(value.size)].join(' · '),
                      style: TextStyle(fontSize: 13, color: c.ink2),
                    ),
                  ),
                  if (md)
                    Segmented<bool>(
                      options: [(false, l.repoCodePreview), (true, l.repoCodeSource)],
                      value: _source,
                      onChanged: (v) => setState(() => _source = v),
                    ),
                  if (value.url.isNotEmpty)
                    IconButton(
                      tooltip: l.repoOpenRun,
                      icon: Icon(Icons.open_in_new_rounded, size: 18, color: c.ink2),
                      onPressed: () => openLink(context, value.url),
                    ),
                ]),
              ),
              body,
              if (lines != null && lines.length > maxCodeLines && (!md || _source))
                _note(context, l.mrepodetailLinesCapped('$maxCodeLines')),
            ]),
          );
        }(),
      AsyncError(:final error) => HelpBox(errorMessage(error, l.commonError), tone: Tone.bad),
      _ => const Padding(padding: EdgeInsets.all(32), child: Center(child: CircularProgressIndicator())),
    };
  }

  Widget _note(BuildContext context, String text) =>
      Padding(padding: const EdgeInsets.all(16), child: Text(text, style: TextStyle(color: Agnts.of(context).ink3)));
}

/// A folder or file row: icon, mono name, a badge for links and submodules, the size.
class _EntryRow extends StatelessWidget {
  const _EntryRow({required this.name, required this.dir, this.badge, this.size, this.onTap});
  final String name;
  final bool dir;
  final String? badge;
  final int? size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = Agnts.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        child: Row(children: [
          dir ? Icon(Icons.folder_outlined, size: 19, color: c.primary) : HIcon('file', size: 18, color: c.ink3),
          const SizedBox(width: 10),
          Expanded(
            child: Text(name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontFamily: AgntsFonts.mono, fontSize: 13.5, color: onTap == null ? c.ink3 : c.ink)),
          ),
          if (badge != null) Padding(padding: const EdgeInsets.only(left: 6), child: ToneBadge(badge!, Tone.gray, small: true)),
          if (size != null) Padding(padding: const EdgeInsets.only(left: 8), child: Text(fmtBytes(size!), style: TextStyle(fontSize: 12.5, color: c.ink3))),
        ]),
      ),
    );
  }
}

/// The folder's README under the listing, as GitHub and GitLab show it.
class _Readme extends ConsumerWidget {
  const _Readme({required this.repoId, required this.branch, required this.entry});
  final int repoId;
  final String branch;
  final TreeEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = Agnts.of(context);
    final content = ref.watch(_fileProvider((id: repoId, ref: branch, path: entry.path))).value?.content;
    if (content == null || content.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(top: 14),
      decoration: BoxDecoration(color: c.surface, border: Border.all(color: c.line), borderRadius: BorderRadius.circular(14)),
      clipBehavior: Clip.antiAlias,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Container(
          color: c.graySoft,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          child: Row(children: [
            HIcon('file', size: 15, color: c.ink2),
            const SizedBox(width: 6),
            Text(entry.name, style: TextStyle(fontSize: 13, color: c.ink2)),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.all(14),
          child: isMarkdown(entry.name)
              ? ReportMarkdown(content)
              : SelectableText(content, style: TextStyle(fontFamily: AgntsFonts.mono, fontSize: 13, color: c.ink)),
        ),
      ]),
    );
  }
}
