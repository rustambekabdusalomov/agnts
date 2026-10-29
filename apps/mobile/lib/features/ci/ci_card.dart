import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:agnts_api/agnts_api.dart';

import '../../core/data.dart';
import '../../l10n/app_localizations.dart';
import '../../theme.dart';
import '../../widgets/ui.dart';
import 'ci_sample.dart';
import 'ci_screen.dart' show ciAgo;

/// The ticket's CI: for a ticket opened to fix a CI failure, a card with
/// the job, branch, status and failing runs that opens the failure; for any
/// ticket, how often CI sent its pull request back.
class TicketCICard extends ConsumerWidget {
  const TicketCICard(this.ticket, {super.key});
  final Ticket ticket;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final fixes = ticket.ciFixes ?? 0;
    // Hidden while loading, on 404 (no failure) and on errors.
    final f = ticket.source_ == TicketSource_Enum.ci ? ref.watch(ticketCIProvider(ticket.key)).value : null;
    if (f == null && fixes == 0) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (f != null) _card(context, l, c, f),
          if (fixes > 0)
            Padding(
              padding: EdgeInsets.only(top: f == null ? 0 : 8, left: 4),
              child: Row(
                children: [
                  HIcon('running', size: 16, color: c.warnInk),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(l.mciCiFixes(fixes), style: TextStyle(fontSize: 13.5, color: c.ink2)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _card(BuildContext context, AppLocalizations l, Agnts c, CIFailure f) {
    final (status, tone) = ciStatusBadge(l, f.status);
    Widget fact(String label, String value, {bool mono = false}) => Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text.rich(
        TextSpan(
          style: TextStyle(fontSize: 13.5, color: c.ink3),
          children: [
            TextSpan(text: '$label: '),
            TextSpan(
              text: value,
              style: TextStyle(color: c.ink, fontFamily: mono ? AgntsFonts.mono : null),
            ),
          ],
        ),
      ),
    );
    return HCard(
      onTap: () => context.push('/ci/${f.id}'),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l.mciCardTitle,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: c.ink),
                ),
              ),
              ToneBadge(status, tone),
            ],
          ),
          const SizedBox(height: 6),
          if (f.job.isNotEmpty) fact(l.mciJob, f.job, mono: true),
          fact(l.mciBranch, f.branch, mono: true),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '${l.mciRunsCount(f.count)} · ${l.mciLastSeen(ciAgo(l, f.lastSeenAt))}',
              style: TextStyle(fontSize: 13.5, color: c.ink3),
            ),
          ),
          const SizedBox(height: 10),
          Divider(height: 1, color: c.line2),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  l.mciCardOpen,
                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: c.primaryInk),
                ),
              ),
              HIcon('chevron', size: 16, color: c.primaryInk, stroke: 2.2),
            ],
          ),
        ],
      ),
    );
  }
}
