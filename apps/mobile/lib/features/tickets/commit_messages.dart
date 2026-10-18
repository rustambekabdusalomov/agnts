import 'package:flutter/material.dart';
import 'package:agnts_api/agnts_api.dart';

import '../../theme.dart';
import '../../widgets/ui.dart';
import 'ticket_repos.dart';

/// Whether any repository of [t] has commits whose messages can still
/// change before agnts pushes them.
bool hasEditableCommits(Ticket t) => (t.repos ?? const []).any((r) => r.commits?.isNotEmpty ?? false);

/// The commits agnts made on a ticket's branches and has not pushed yet,
/// newest first: the short sha and subject line of each, a tap on one
/// editing its message ([onEdit]; null: read only). In a ticket of several
/// repositories each gets a heading with its name and branch.
class CommitMessages extends StatelessWidget {
  const CommitMessages(this.ticket, {super.key, this.onEdit});
  final Ticket ticket;
  final void Function(TicketRepoState r, BranchCommit c)? onEdit;

  @override
  Widget build(BuildContext context) {
    final c = Agnts.of(context);
    final multi = isMultiRepo(ticket);
    final repos = [for (final r in ticket.repos ?? const <TicketRepoState>[]) if (r.commits?.isNotEmpty ?? false) r];
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      for (final (i, r) in repos.indexed) ...[
        if (multi)
          Padding(
            padding: EdgeInsets.only(top: i == 0 ? 0 : 12, bottom: 6),
            child: Text.rich(TextSpan(children: [
              TextSpan(text: r.repoName, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: c.ink)),
              TextSpan(text: '  ${r.branch}', style: TextStyle(fontFamily: AgntsFonts.mono, fontSize: 12, color: c.ink3)),
            ])),
          ),
        ListGroup(children: [
          for (final x in r.commits!)
            InkWell(
              onTap: onEdit == null ? null : () => onEdit!(r, x),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(x.sha.length > 7 ? x.sha.substring(0, 7) : x.sha, style: TextStyle(fontFamily: AgntsFonts.mono, fontSize: 12.5, color: c.ink3)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${x.message.split('\n').first}${x.message.contains('\n') ? ' …' : ''}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontFamily: AgntsFonts.mono, fontSize: 12.5, color: c.ink),
                    ),
                  ),
                  if (onEdit != null) ...[const SizedBox(width: 8), HIcon('chevron', size: 16, color: c.ink3)],
                ]),
              ),
            ),
        ]),
      ],
    ]);
  }
}
