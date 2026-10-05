import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hiro_api/hiro_api.dart';

import '../l10n/app_localizations.dart';
import '../theme.dart';
import 'ui.dart';

/// Label for a ticket state, from the shared dictionaries.
String stateLabel(AppLocalizations l, TicketState s) => stateLabelOf(l, s);

/// A state's text colour (its tone's ink), as in the demo.
Color stateColor(BuildContext context, TicketState s) => stateTone(s).ink(Hiro.of(context));

/// A state as a dotted pill (.badge).
class StateBadge extends StatelessWidget {
  const StateBadge(this.state, {super.key});
  final TicketState state;

  @override
  Widget build(BuildContext context) => ToneBadge(stateLabel(AppLocalizations.of(context), state), stateTone(state));
}

/// A titled card section: grey heading above a card (.sec-h + .card).
class Section extends StatelessWidget {
  const Section({super.key, required this.title, required this.child, this.trailing});
  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      SectionHeader(title, trailing: trailing),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: HCard(child: child)),
    ]);
  }
}

/// Renders an AsyncValue with loading and error states and pull-to-refresh.
class AsyncBody<T> extends StatelessWidget {
  const AsyncBody({super.key, required this.value, required this.onRefresh, required this.builder});
  final AsyncValue<T> value;
  final Future<void> Function() onRefresh;
  final Widget Function(T data) builder;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: switch (value) {
        AsyncData(:final value) => builder(value),
        AsyncError() => ListView(children: [
            Padding(padding: const EdgeInsets.all(24), child: Text(l.mobileOffline, textAlign: TextAlign.center)),
          ]),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

/// A usage row (.u-row + .bar + .u-foot): label and big percentage, the
/// bar (amber from 80%, red at 100%), and a note underneath.
class UsageBar extends StatelessWidget {
  const UsageBar({super.key, required this.label, required this.utilization, this.note, this.noteRight});
  final String label;
  final double? utilization;
  final String? note;
  final String? noteRight;

  @override
  Widget build(BuildContext context) {
    final c = Hiro.of(context);
    final u = utilization;
    final tone = u == null ? Tone.gray : u >= 1 ? Tone.bad : u >= 0.8 ? Tone.warn : Tone.info;
    final pctColor = tone == Tone.bad ? c.badInk : tone == Tone.warn ? c.warnInk : c.ink;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Expanded(child: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: c.ink2))),
          Text(u == null ? '—' : '${(u * 100).round().clamp(0, 100)}%',
              style: TextStyle(fontFamily: HiroFonts.display, fontSize: 22, fontWeight: FontWeight.w700, color: pctColor)),
        ]),
        Padding(padding: const EdgeInsets.only(top: 8, bottom: 6), child: Bar(value: u ?? 0, tone: tone)),
        if (note != null || noteRight != null)
          DefaultTextStyle.merge(
            style: TextStyle(fontSize: 13, color: c.ink3),
            child: Row(children: [Expanded(child: Text(note ?? '')), if (noteRight != null) Text(noteRight!)]),
          ),
      ]),
    );
  }
}

/// "Resets in 2h 5m" for a reset time.
String resetText(AppLocalizations l, DateTime? at) {
  if (at == null) return l.navUsageUnknown;
  final d = at.difference(DateTime.now());
  if (d.isNegative) return l.navResettingNow;
  final h = d.inHours, m = d.inMinutes % 60;
  return l.navResetsIn(h > 0 ? '${h}h ${m}m' : '${m}m');
}

/// "5m", "2h 3m", "1d 4h".
String shortDuration(Duration d) {
  if (d.inDays > 0) return '${d.inDays}d ${d.inHours % 24}h';
  if (d.inHours > 0) return '${d.inHours}h ${d.inMinutes % 60}m';
  return '${d.inMinutes.clamp(1, 59)}m';
}

void showSnack(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
}
