import 'package:agnts_api/agnts_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api.dart';
import '../../l10n/app_localizations.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import '../../widgets/ui.dart';
import 'documents_data.dart';
import 'documents_screen.dart' show DocumentRow;

/// The documents linked to a ticket that you can open (others are neither
/// shown nor counted), and, for a ticket with a report, a button to have
/// agnts make a document from it. Hidden when there is neither.
class TicketDocumentsFold extends ConsumerStatefulWidget {
  const TicketDocumentsFold({super.key, required this.ticket, required this.hasReport});
  final Ticket ticket;
  final bool hasReport;

  @override
  ConsumerState<TicketDocumentsFold> createState() => _TicketDocumentsFoldState();
}

class _TicketDocumentsFoldState extends ConsumerState<TicketDocumentsFold> {
  bool _busy = false;

  Future<void> _fromReport() async {
    final l = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      final lang = Localizations.localeOf(context).languageCode;
      final res = await ref.read(apiProvider)!.getDocumentsApi().createTicketDocument(
            key: widget.ticket.key,
            createTicketDocumentRequest: CreateTicketDocumentRequest(
              language: CreateTicketDocumentRequestLanguageEnum.values.where((x) => x.value == lang).firstOrNull,
            ),
          );
      ref.invalidate(ticketDocumentsProvider(widget.ticket.key));
      ref.invalidate(documentsProvider);
      if (!mounted) return;
      showSnack(context, l.mdocumentsFromReportStarted);
      final id = res.data?.id;
      if (id != null) await context.push('/documents/$id');
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
    final docs = ref.watch(ticketDocumentsProvider(widget.ticket.key)).value ?? const <DocumentSummary>[];
    if (docs.isEmpty && !widget.hasReport) return const SizedBox.shrink();
    return Fold(
      title: l.mdocumentsTicketSection,
      hint: docs.isEmpty ? null : '${docs.length}',
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        if (docs.isEmpty) Text(l.mdocumentsTicketNone, style: TextStyle(color: c.ink3)),
        for (final d in docs) DocumentRow(d),
        if (widget.hasReport)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: OutlinedButton(onPressed: _busy ? null : _fromReport, child: Text(l.mdocumentsFromReport)),
          ),
      ]),
    );
  }
}
