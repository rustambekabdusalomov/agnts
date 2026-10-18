import 'package:flutter/material.dart';
import 'package:agnts_api/agnts_api.dart';

import '../../l10n/app_localizations.dart';
import '../../widgets/ui.dart';
import 'ticket_repos.dart';

/// A change's diffs. In a ticket of several repositories each gets a chip,
/// with its file count and lines added and removed, and only the picked
/// one's files show; the first until another is picked. [file] builds one
/// file's diff, [open] telling it to start opened (the first file of the
/// first repository, when [openFirst]).
class RepoDiffs extends StatefulWidget {
  const RepoDiffs({super.key, required this.files, required this.file, this.openFirst = false});
  final List<FileChange> files;
  final Widget Function(FileChange f, bool open) file;
  final bool openFirst;

  @override
  State<RepoDiffs> createState() => _RepoDiffsState();
}

class _RepoDiffsState extends State<RepoDiffs> {
  String _repo = '';

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final groups = filesByRepo(widget.files);
    if (groups.isEmpty) return const SizedBox.shrink();
    final shown = groups.firstWhere((g) => g.repo == _repo, orElse: () => groups.first);
    final first = shown.repo == groups.first.repo;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (groups.length > 1)
          Semantics(
            label: l.ticketDiffReposLabel,
            container: true,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(top: 2, bottom: 4),
              child: Row(
                children: [
                  for (final (i, g) in groups.indexed)
                    Padding(
                      padding: EdgeInsets.only(left: i == 0 ? 0 : 8),
                      child: FilterChipH(
                        label: g.repo.isEmpty ? l.ticketDiffOtherRepo : g.repo,
                        count: g.files.length,
                        selected: g.repo == shown.repo,
                        onTap: () => setState(() => _repo = g.repo),
                      ),
                    ),
                ],
              ),
            ),
          ),
        for (final (i, f) in shown.files.indexed)
          KeyedSubtree(key: ValueKey(filePath(f)), child: widget.file(f, widget.openFirst && first && i == 0)),
      ],
    );
  }
}
