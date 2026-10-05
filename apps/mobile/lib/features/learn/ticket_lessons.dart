import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hiro_api/hiro_api.dart';

import '../../core/api.dart';
import '../../core/data.dart';
import '../../l10n/app_localizations.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import 'learn_screen.dart';

/// What a pushed ticket taught: its lessons, or where its learn run stands.
class TicketLessons extends ConsumerStatefulWidget {
  const TicketLessons(this.ticket, {super.key});
  final Ticket ticket;

  @override
  ConsumerState<TicketLessons> createState() => _TicketLessonsState();
}

class _TicketLessonsState extends ConsumerState<TicketLessons> {
  bool _busy = false;

  Future<void> _learn() async {
    final l = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      await ref.read(apiProvider)!.getLearnApi().learnFromTicket(key: widget.ticket.key);
      ref.invalidate(ticketProvider(widget.ticket.key));
      if (mounted) showSnack(context, l.learnQueued);
    } catch (e) {
      if (mounted) showSnack(context, errorMessage(e, l.commonError));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Hiro.of(context);
    final state = widget.ticket.learnState ?? TicketLearnStateEnum.none;
    final items = ref.watch(ticketLessonsProvider(widget.ticket.key)).value?.items ?? const <LessonBrief>[];
    final text = switch (state) {
      TicketLearnStateEnum.pending => l.learnTicketPending,
      TicketLearnStateEnum.done => l.learnTicketNone,
      TicketLearnStateEnum.failed => l.learnTicketFailed,
      TicketLearnStateEnum.none => l.learnTicketIdle,
    };
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Padding(
        padding: const EdgeInsets.only(top: 18, bottom: 8),
        child: Text(l.learnTicketTitle, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: c.ink3)),
      ),
      if (items.isNotEmpty)
        for (final x in items) LessonTile(x, compact: true)
      else
        Text(text, style: TextStyle(fontSize: 14, height: 1.45, color: state == TicketLearnStateEnum.failed ? c.badInk : c.ink3)),
      if (state != TicketLearnStateEnum.pending)
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: _busy ? null : _learn,
            child: Text(state == TicketLearnStateEnum.none ? l.learnLearnNow : l.learnLearnAgain),
          ),
        ),
    ]);
  }
}
