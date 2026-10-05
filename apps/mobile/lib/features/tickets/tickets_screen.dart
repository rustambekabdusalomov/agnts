import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hiro_api/hiro_api.dart';
import 'package:intl/intl.dart';

import '../../core/data.dart';
import '../../l10n/app_localizations.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import '../../widgets/ui.dart';

/// The Tickets tab (scrTickets): big title, search, filter chips with counts
/// and a stack of ticket cards. `/tickets?filter=running` opens on a filter.
class TicketsScreen extends ConsumerStatefulWidget {
  const TicketsScreen({super.key});

  @override
  ConsumerState<TicketsScreen> createState() => _TicketsScreenState();
}

class _TicketsScreenState extends ConsumerState<TicketsScreen> {
  String _filter = 'needs';
  String _query = '';
  String? _appliedUri;
  final _search = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Another screen can link here with ?filter=; apply it once per link.
    final uri = GoRouterState.of(context).uri;
    if (uri.toString() == _appliedUri) return;
    _appliedUri = uri.toString();
    final f = uri.queryParameters['filter'];
    if (f != null && filterStates.containsKey(f)) _filter = f;
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  bool _inFilter(Ticket t, String f) {
    final states = filterStates[f] ?? const <TicketState>[];
    return states.isEmpty || states.contains(t.state);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final labels = {'needs': l.navNeeds, 'running': l.navRunning, 'queue': l.navQueue, 'done': l.navDone, 'all': l.navAll};
    final tickets = ref.watch(ticketsProvider('all'));
    // Live log lines of running tickets, when the dashboard has them.
    final live = {for (final r in ref.watch(dashboardProvider).value?.live ?? const <LiveRun>[]) r.ticket.key: r};
    final all = tickets.value ?? const <Ticket>[];
    final q = _query.trim().toLowerCase();

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(children: [
          PageHeader(title: l.navAll),
          SearchBox(hint: l.navSearch, controller: _search, onChanged: (v) => setState(() => _query = v)),
          ChipRow(children: [
            for (final e in labels.entries)
              FilterChipH(
                label: e.value,
                selected: _filter == e.key,
                count: tickets.hasValue ? all.where((t) => _inFilter(t, e.key)).length : null,
                onTap: () => setState(() => _filter = e.key),
              ),
          ]),
          const SizedBox(height: 8),
          Expanded(
            child: AsyncBody<List<Ticket>>(
              value: tickets,
              onRefresh: () {
                ref.invalidate(dashboardProvider);
                return ref.refresh(ticketsProvider('all').future);
              },
              builder: (list) {
                final rows = list.where((t) => _inFilter(t, _filter) && (q.isEmpty || '${t.key} ${t.title}'.toLowerCase().contains(q))).toList();
                if (rows.isEmpty) {
                  return ListView(children: [
                    EmptyState(title: q.isNotEmpty ? l.mhomeSearchEmpty : _filter == 'needs' ? l.ticketsEmptyNeeds : l.ticketsEmpty),
                  ]);
                }
                return ListView.separated(
                  padding: screenPad.copyWith(top: 4),
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  itemCount: rows.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, i) => ticketCardFor(context, rows[i], live: live[rows[i].key]),
                );
              },
            ),
          ),
        ]),
      ),
    );
  }
}

/// The next step for a ticket that waits on the user, and its tone (actionLine).
(String, Tone)? ticketAction(AppLocalizations l, Ticket t) => switch (t.state) {
      TicketState.waitingForAnswers => (l.mhomeActAnswers, Tone.warn),
      TicketState.waitingForReview => (l.mhomeActReview, Tone.warn),
      TicketState.failed => (l.mhomeActStopped, Tone.bad),
      TicketState.rateLimited => (l.mhomeActResume, Tone.bad),
      TicketState.new_ when t.held == true => (l.mhomeActStart, Tone.info),
      _ => null,
    };

bool _isRunning(TicketState s) => filterStates['running']!.contains(s);

/// "10:25" today, "5 Oct" otherwise.
String _when(BuildContext context, DateTime at) {
  final loc = Localizations.localeOf(context).toLanguageTag();
  final local = at.toLocal(), now = DateTime.now();
  final today = local.year == now.year && local.month == now.month && local.day == now.day;
  try {
    return today ? DateFormat.Hm(loc).format(local) : DateFormat.MMMd(loc).format(local);
  } catch (_) {
    return today ? DateFormat.Hm().format(local) : DateFormat.MMMd().format(local);
  }
}

/// A ticket as a card (tcard): waiting time and the next step when it needs
/// the user, a live log line when it runs, otherwise the last update time.
Widget ticketCardFor(BuildContext context, Ticket t, {LiveRun? live, bool showTurns = false}) {
  final l = AppLocalizations.of(context);
  final c = Hiro.of(context);
  final since = t.since;
  final needs = filterStates['needs']!.contains(t.state);
  final action = ticketAction(l, t);
  final running = _isRunning(t.state);
  final meta = <Widget>[
    if (needs && since != null)
      Text(l.mhomeWaiting(shortDuration(DateTime.now().difference(since))))
    else
      Text(_when(context, t.updatedAt)),
    if (showTurns && live != null) ...[
      Text(live.model, style: TextStyle(fontFamily: HiroFonts.mono, fontSize: 12, color: c.ink3)),
      Text(l.mobileTurnsOf(live.turns.toString(), live.maxTurns.toString())),
      SizedBox(width: 48, child: Bar(value: live.maxTurns == 0 ? 0 : live.turns / live.maxTurns, height: 4)),
    ],
  ];
  return TicketCard(
    ticket: t,
    onTap: () => context.push('/tickets/${t.key}'),
    meta: meta,
    action: action?.$1,
    actionTone: action?.$2 ?? Tone.info,
    live: running ? (live == null ? null : live.lastMessage.isNotEmpty ? live.lastMessage : l.mhomeLiveFallback) : null,
  );
}

/// A plain list row for a ticket, kept for screens that list tickets in rows.
class TicketTile extends StatelessWidget {
  const TicketTile(this.t, {super.key});
  final Ticket t;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return ListTile(
      title: Text(t.title, maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: Text([
        t.key,
        t.source_ == TicketSource_Enum.local ? l.ticketsSourceTask : l.ticketsSourceJira,
        if (t.repoName != null) t.repoName!,
      ].join(' · ')),
      trailing: StateBadge(t.state, kind: t.kind),
      onTap: () => context.push('/tickets/${t.key}'),
    );
  }
}
