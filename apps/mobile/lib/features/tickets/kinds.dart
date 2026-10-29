import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:agnts_api/agnts_api.dart';

import '../../core/api.dart';
import '../../core/data.dart';
import '../../l10n/app_localizations.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import '../../widgets/ui.dart';

/// States in which the kind can still change (the server's SetKind).
bool kindEditable(Ticket t) =>
    const [TicketState.new_, TicketState.waitingForAnswers, TicketState.failed, TicketState.rateLimited].contains(t.state) &&
    t.prUrl.isEmpty &&
    t.resumeState != TicketState.pushing &&
    t.kind != TicketKind.swaggertest; // a Swagger test's kind never changes

String kindChoiceLabel(AppLocalizations l, TicketKindChoice k) => switch (k) {
  TicketKindChoice.auto => l.kindAuto,
  TicketKindChoice.code => l.kindCode,
  TicketKindChoice.test => l.kindTest,
  TicketKindChoice.plan => l.kindPlan,
  TicketKindChoice.analysis => l.kindAnalysis,
  TicketKindChoice.bug => l.kindBug,
};

String kindChoiceHint(AppLocalizations l, TicketKindChoice k) => switch (k) {
  TicketKindChoice.auto => l.kindAutoHint,
  TicketKindChoice.code => l.kindCodeHint,
  TicketKindChoice.test => l.kindTestHint,
  TicketKindChoice.plan => l.kindPlanHint,
  TicketKindChoice.analysis => l.kindAnalysisHint,
  TicketKindChoice.bug => l.kindBugHint,
};

TicketKindChoice choiceOf(TicketKind k) => TicketKindChoice.values.firstWhere((c) => c.name == k.name);

/// Pills for Auto and the five kinds, with the picked one's hint below.
class KindChoices extends StatelessWidget {
  const KindChoices({super.key, required this.value, required this.onPick, this.enabled = true});
  final TicketKindChoice value;
  final ValueChanged<TicketKindChoice> onPick;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final k in TicketKindChoice.values)
              FilterChipH(label: kindChoiceLabel(l, k), selected: value == k, onTap: enabled ? () => onPick(k) : () {}),
          ],
        ),
        const SizedBox(height: 8),
        Text(kindChoiceHint(l, value), style: TextStyle(fontSize: 13.5, height: 1.4, color: c.ink3)),
      ],
    );
  }
}

/// Changes a ticket's kind on the server; Auto hands the choice back to agnts.
class KindPicker extends ConsumerStatefulWidget {
  const KindPicker(this.ticket, {super.key});
  final Ticket ticket;

  @override
  ConsumerState<KindPicker> createState() => _KindPickerState();
}

class _KindPickerState extends ConsumerState<KindPicker> {
  bool _busy = false;

  Future<void> _pick(TicketKindChoice k) async {
    final t = widget.ticket;
    if (k == (t.kindAuto ? TicketKindChoice.auto : choiceOf(t.kind))) return;
    final l = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      await ref
          .read(apiProvider)!
          .getTicketsApi()
          .setTicketKind(
            key: t.key,
            ticketKindInput: TicketKindInput(kind: k),
          );
      ref.invalidate(ticketProvider(t.key));
      ref.invalidate(ticketsProvider);
    } catch (e) {
      if (mounted) showSnack(context, errorMessage(e, l.commonError));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final t = widget.ticket;
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.kindTitle,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: c.ink3),
          ),
          const SizedBox(height: 8),
          KindChoices(value: t.kindAuto ? TicketKindChoice.auto : choiceOf(t.kind), onPick: _pick, enabled: !_busy),
        ],
      ),
    );
  }
}

/// A report Claude wrote, rendered from Markdown. Links are not followed:
/// the text is model output, and the admin panel is the place to act on it.
class ReportMarkdown extends StatelessWidget {
  const ReportMarkdown(this.markdown, {super.key});
  final String markdown;

  @override
  Widget build(BuildContext context) {
    final c = Agnts.of(context);
    final base = TextStyle(fontSize: 15, height: 1.5, color: c.ink);
    return MarkdownBody(
      data: markdown,
      selectable: true,
      styleSheet: MarkdownStyleSheet(
        p: base,
        listBullet: base,
        tableBody: base.copyWith(fontSize: 13.5),
        tableHead: base.copyWith(fontSize: 13.5, fontWeight: FontWeight.w700),
        tableBorder: TableBorder.all(color: c.line),
        h1: TextStyle(fontSize: 21, fontWeight: FontWeight.w700, height: 1.25, color: c.ink),
        h2: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, height: 1.25, color: c.ink),
        h3: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, height: 1.3, color: c.ink),
        h4: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: c.ink),
        a: base.copyWith(color: c.primaryInk),
        // One style serves inline code and code blocks, so blocks share its light background.
        code: TextStyle(fontFamily: AgntsFonts.mono, fontSize: 12.5, color: c.ink, backgroundColor: c.graySoft),
        codeblockPadding: const EdgeInsets.all(12),
        codeblockDecoration: BoxDecoration(color: c.graySoft, borderRadius: BorderRadius.circular(12)),
        blockquoteDecoration: BoxDecoration(
          border: Border(left: BorderSide(color: c.line3, width: 3)),
        ),
        blockquotePadding: const EdgeInsets.only(left: 12),
      ),
    );
  }
}

/// The step after an approved plan or bug investigation: a code task that
/// carries it out, linked back. Once made, a link to it.
class ImplementReport extends ConsumerStatefulWidget {
  const ImplementReport(this.ticket, {super.key, this.childKey});
  final Ticket ticket;
  final String? childKey;

  @override
  ConsumerState<ImplementReport> createState() => _ImplementReportState();
}

class _ImplementReportState extends ConsumerState<ImplementReport> {
  bool _busy = false;

  /// The repository to implement in: the report's own, or one the user picks.
  Future<int?> _repo() async {
    if (widget.ticket.repoId != null) return widget.ticket.repoId;
    final l = AppLocalizations.of(context);
    final repos = (await ref.read(reposProvider.future)).where((r) => r.archivedAt == null).toList();
    if (!mounted) return null;
    if (repos.isEmpty) {
      showSnack(context, l.mobileNoSideRepos);
      return null;
    }
    return showModalBottomSheet<int>(
      context: context,
      useSafeArea: true,
      builder: (c) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text(l.implementPickRepo, style: Theme.of(c).textTheme.titleMedium),
            ),
            for (final r in repos) ListTile(title: Text(r.name), onTap: () => Navigator.pop(c, r.id)),
          ],
        ),
      ),
    );
  }

  Future<void> _implement() async {
    final l = AppLocalizations.of(context);
    final repo = await _repo();
    if (repo == null || !mounted) return;
    setState(() => _busy = true);
    try {
      final res = await ref
          .read(apiProvider)!
          .getTicketsApi()
          .implementTicket(
            key: widget.ticket.key,
            implementInput: ImplementInput(repoId: widget.ticket.repoId == null ? repo : null),
          );
      ref.invalidate(ticketProvider(widget.ticket.key));
      ref.invalidate(ticketsProvider);
      final key = res.data?.key;
      if (key != null && mounted) context.push('/tickets/$key');
    } catch (e) {
      if (mounted) showSnack(context, errorMessage(e, l.commonError));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final bug = widget.ticket.kind == TicketKind.bug;
    final child = widget.childKey;
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l.implementTitle,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: c.ink3),
          ),
          const SizedBox(height: 8),
          if (child != null)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(onPressed: () => context.push('/tickets/$child'), child: Text('${l.implementDoneBy} $child')),
            )
          else ...[
            Text(bug ? l.implementSubBug : l.implementSubPlan, style: TextStyle(fontSize: 14, height: 1.45, color: c.ink3)),
            const SizedBox(height: 10),
            FilledButton(onPressed: _busy ? null : _implement, child: Text(bug ? l.implementFix : l.implementImplement)),
          ],
        ],
      ),
    );
  }
}
