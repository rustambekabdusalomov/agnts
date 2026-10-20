import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:agnts_api/agnts_api.dart';

import '../../core/api.dart';
import '../../l10n/app_localizations.dart';
import '../../theme.dart';
import '../../widgets/ui.dart';
import '../ci/ci_screen.dart' show ciAgo;

/// The newest [limit] commits linked to a ticket by its number, by ticket
/// key and limit. The live stream refreshes it on commits_linked events.
final linkedCommitsProvider = FutureProvider.family<LinkedCommits, (String, int)>((ref, k) async {
  final res = await requireApi(ref).getTicketsApi().listTicketLinkedCommits(key: k.$1, limit: k.$2);
  return res.data ?? LinkedCommits(commits: const [], total: 0);
});

/// Commits on the git host whose branch or message has the ticket's
/// number (or key): anyone's, from pushes and the repositories' recent
/// history. Shown once there is one.
class LinkedCommitsFold extends ConsumerStatefulWidget {
  const LinkedCommitsFold({super.key, required this.ticket});
  final Ticket ticket;

  @override
  ConsumerState<LinkedCommitsFold> createState() => _LinkedCommitsFoldState();
}

class _LinkedCommitsFoldState extends ConsumerState<LinkedCommitsFold> {
  static const _page = 20, _max = 100;
  int _limit = _page;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final res = ref.watch(linkedCommitsProvider((widget.ticket.key, _limit)));
    // Keep what was shown while a longer page loads.
    final data = res.value ?? (_limit > _page ? ref.read(linkedCommitsProvider((widget.ticket.key, _limit - _page))).value : null);
    if (data == null || data.total == 0) return const SizedBox.shrink();
    final number = (widget.ticket.ticketNumber?.isNotEmpty ?? false) ? widget.ticket.ticketNumber! : widget.ticket.key;
    final left = data.total - data.commits.length;
    return Fold(
      title: l.linkedCommitsTitle,
      hint: '${data.total}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.linkedCommitsSub(number), style: TextStyle(fontSize: 14, height: 1.45, color: c.ink3)),
          const SizedBox(height: 10),
          for (final x in data.commits) _row(context, x),
          if (left > 0 && _limit < _max)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: res.isLoading ? null : () => setState(() => _limit = (_limit + _page).clamp(_page, _max)),
                child: Text(l.linkedCommitsMore('$left')),
              ),
            ),
          if (res.hasError && !res.hasValue) Text(errorMessage(res.error!, l.linkedCommitsLoadError), style: TextStyle(color: c.badInk)),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, LinkedCommit x) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final author = x.authorLogin != null ? '@${x.authorLogin}' : x.author;
    return InkWell(
      onTap: () => context.push('/repos/${x.repoId}/commits/${x.sha}'),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: c.line2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              x.subject.isEmpty ? x.shortSha : x.subject,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: c.ink),
            ),
            const SizedBox(height: 3),
            Text(l.linkedCommitsMeta(author, x.repo, x.branch), style: TextStyle(fontSize: 13, color: c.ink3)),
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  x.shortSha.length > 7 ? x.shortSha.substring(0, 7) : x.shortSha,
                  style: TextStyle(fontFamily: AgntsFonts.mono, fontSize: 12, color: c.ink3),
                ),
                Text(ciAgo(l, x.committedAt.toLocal()), style: TextStyle(fontSize: 12.5, color: c.ink3)),
                if (x.matchedOn.contains(LinkedCommitMatchedOnEnum.branch)) ToneBadge(l.linkedCommitsOnBranch, Tone.info, small: true),
                if (x.matchedOn.contains(LinkedCommitMatchedOnEnum.message)) ToneBadge(l.linkedCommitsOnMessage, Tone.gray, small: true),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
