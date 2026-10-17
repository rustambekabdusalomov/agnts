import 'package:flutter/material.dart';
import 'package:agnts_api/agnts_api.dart';

import '../../l10n/app_localizations.dart';
import '../../theme.dart';
import '../../widgets/ui.dart';

/// Whether a ticket works in more than one repository.
bool isMultiRepo(Ticket t) => (t.repos?.length ?? 0) > 1;

/// A changed file's path, with its repository in front on a multi-repo
/// ticket ("api/server/main.go").
String filePath(FileChange f) => (f.repo?.isNotEmpty ?? false) ? '${f.repo}/${f.path}' : f.path;

String repoStateLabel(AppLocalizations l, TicketRepoStateStateEnum s) => switch (s) {
      TicketRepoStateStateEnum.pending => l.mgroupsStatePending,
      TicketRepoStateStateEnum.unchanged => l.mgroupsStateUnchanged,
      TicketRepoStateStateEnum.pushed => l.mgroupsStatePushed,
      TicketRepoStateStateEnum.merged => l.mgroupsStateMerged,
      TicketRepoStateStateEnum.dropped => l.mgroupsStateDropped,
    };

Tone repoStateTone(TicketRepoStateStateEnum s) => switch (s) {
      TicketRepoStateStateEnum.pushed => Tone.info,
      TicketRepoStateStateEnum.merged => Tone.ok,
      TicketRepoStateStateEnum.dropped => Tone.bad,
      _ => Tone.gray,
    };

/// Every repository of a multi-repo ticket, the main one first: its role,
/// branch, pull request, state and why a push failed. Nothing for a
/// ticket with one repository. [onRename] renames a branch not pushed yet
/// (offered where the repository's canRenameBranch is set).
class TicketRepos extends StatelessWidget {
  const TicketRepos(this.ticket, {super.key, this.onRename});
  final Ticket ticket;
  final void Function(TicketRepoState)? onRename;

  @override
  Widget build(BuildContext context) {
    if (!isMultiRepo(ticket)) return const SizedBox.shrink();
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(l.mgroupsRepos, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: c.ink3)),
        ),
        ListGroup(children: [
          for (final (i, r) in ticket.repos!.indexed) _RepoRow(repo: r, primary: i == 0, onRename: r.canRenameBranch == true ? onRename : null),
        ]),
      ]),
    );
  }
}

class _RepoRow extends StatelessWidget {
  const _RepoRow({required this.repo, required this.primary, this.onRename});
  final TicketRepoState repo;
  final bool primary;
  final void Function(TicketRepoState)? onRename;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final r = repo;
    final mono = TextStyle(fontFamily: AgntsFonts.mono, fontSize: 12.5, color: c.ink3);
    final facts = [
      if (primary) l.mgroupsPrimary,
      if (r.role.isNotEmpty) r.role,
      if (r.archived == true) l.mgroupsArchived,
      if (r.files > 0) l.mgroupsFiles(r.files),
      if (r.ciFixes > 0) l.mgroupsCiFixes(r.ciFixes),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(r.repoName, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: c.ink))),
          const SizedBox(width: 8),
          ToneBadge(repoStateLabel(l, r.state), repoStateTone(r.state), small: true),
          const SizedBox(width: 8),
        ]),
        if (facts.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(facts.join(' · '), style: TextStyle(fontSize: 13, color: c.ink3)),
          ),
        if (r.branch.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(children: [
              Expanded(child: Text('${l.ticketBranch}: ${r.branch}', style: mono)),
              if (onRename != null) TextButton(onPressed: () => onRename!(r), child: Text(l.ticketBranchRename)),
            ]),
          ),
        if (r.prUrl.isNotEmpty)
          Row(children: [
            Expanded(child: SelectableText(r.prUrl, style: mono.copyWith(color: c.primary))),
            CopyButton(r.prUrl),
          ]),
        if (r.pushError?.isNotEmpty ?? false)
          Padding(
            padding: const EdgeInsets.only(top: 4, right: 8),
            child: Text(l.mgroupsPushError(r.pushError!), style: TextStyle(fontSize: 13, color: c.badInk, height: 1.35)),
          ),
      ]),
    );
  }
}
