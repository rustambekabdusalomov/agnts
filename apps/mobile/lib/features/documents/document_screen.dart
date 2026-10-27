import 'dart:async';

import 'package:agnts_api/agnts_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import '../../widgets/ui.dart';
import '../tickets/kinds.dart' show ReportMarkdown;
import '../tickets/translation.dart';
import 'document_download.dart';
import 'document_share_sheet.dart';
import 'slide_deck.dart';
import 'documents_data.dart';
import 'documents_logic.dart';

/// A document, read-only: its text, version, what it was made from, its
/// linked tickets, and a menu to copy its public link, change who can
/// open it (its owner) and download it; a deck reads as slides and can be
/// presented. It can be read in another language, as a ticket can.
/// Editing and comments are on the web.
class DocumentScreen extends ConsumerStatefulWidget {
  const DocumentScreen({super.key, required this.id});
  final int id;

  @override
  ConsumerState<DocumentScreen> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends ConsumerState<DocumentScreen> {
  Timer? _poll;

  @override
  void initState() {
    super.initState();
    // While agnts writes it the page refreshes on its own, besides events.
    _poll = Timer.periodic(const Duration(seconds: 5), (_) {
      final d = ref.read(documentProvider(widget.id)).value;
      if (d != null && docWriting(d.generation)) ref.invalidate(documentProvider(widget.id));
    });
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  Future<void> _menu(String action, Document d, DocumentTranslation? tr) async {
    final l = AppLocalizations.of(context);
    switch (action) {
      case 'copy':
        await Clipboard.setData(ClipboardData(text: d.publicUrl ?? ''));
        if (mounted) showSnack(context, l.mdocumentsLinkCopied);
      case 'share':
        await showDocumentShareSheet(context, d.id);
        ref.invalidate(documentProvider(widget.id));
      case 'present':
        await presentSlides(context, tr?.body ?? d.body);
      case 'md':
      case 'pdf':
        await downloadDocument(context, ref, d.id, action, lang: tr?.lang.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final doc = ref.watch(documentProvider(widget.id));
    final d = doc.value;
    // The language it is read in, and the translation once it arrives.
    final lang = ref.watch(ticketLangProvider('doc:${widget.id}'));
    final trState = lang == null || d == null || d.version == 0
        ? null
        : ref.watch(documentTranslationProvider((id: d.id, lang: lang, version: d.version)));
    final tr = trState?.value?.lang == lang ? trState?.value : null;
    return Scaffold(
      backgroundColor: c.bg,
      appBar: DetailBar(
        backLabel: l.navBack,
        onBack: () => context.canPop() ? context.pop() : context.go('/documents'),
        actions: [
          if (d != null && d.version > 0) TranslateButton('doc:${d.id}'),
          if (d != null)
            PopupMenuButton<String>(
              icon: Icon(Icons.more_horiz_rounded, color: c.primary),
              onSelected: (a) => _menu(a, d, tr),
              itemBuilder: (_) => [
                if (d.kind == DocumentKind.slides && d.version > 0) PopupMenuItem(value: 'present', child: Text(l.mdocumentsPresent)),
                if (d.publicUrl != null) PopupMenuItem(value: 'copy', child: Text(l.mdocumentsCopyLink)),
                if (d.access == DocumentAccess.owner) PopupMenuItem(value: 'share', child: Text(l.mdocumentsSharing)),
                if (d.version > 0) PopupMenuItem(value: 'md', child: Text(l.mdocumentsDownloadMd)),
                if (d.version > 0) PopupMenuItem(value: 'pdf', child: Text(l.mdocumentsDownloadPdf)),
              ],
            ),
        ],
      ),
      body: AsyncBody<Document>(
        value: doc,
        onRefresh: () {
          ref.invalidate(documentTicketsProvider(widget.id));
          return ref.refresh(documentProvider(widget.id).future);
        },
        builder: (d) => ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: screenPad,
          children: [
            Text(tr?.title ?? d.title, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, height: 1.2, color: c.ink)),
            const SizedBox(height: 6),
            Wrap(spacing: 6, runSpacing: 4, crossAxisAlignment: WrapCrossAlignment.center, children: [
              if (d.kind == DocumentKind.slides) ToneBadge(l.mdocumentsSlides, Tone.gray, small: true),
              d.type == DocumentTypeEnum.public
                  ? ToneBadge(l.mdocumentsTypePublic, Tone.info, small: true)
                  : ToneBadge(l.mdocumentsTypePrivate, Tone.gray, small: true),
              if (d.version > 0) Text(l.mdocumentsVersion('${d.version}'), style: TextStyle(fontSize: 13, color: c.ink3)),
              Text(d.ownerName, style: TextStyle(fontSize: 13, color: c.ink3)),
            ]),
            if (d.dataAsOf != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  l.mdocumentsAsOf(DateFormat.yMMMd(Localizations.localeOf(context).toString()).add_Hm().format(d.dataAsOf!.toLocal())),
                  style: TextStyle(fontSize: 13, color: c.ink3),
                ),
              ),
            if (d.derivedFrom != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: GestureDetector(
                  onTap: () => context.push('/documents/${d.derivedFrom!.id}'),
                  child: Text(l.mdocumentsMadeFrom(d.derivedFrom!.title), style: TextStyle(fontSize: 13, color: c.primaryInk)),
                ),
              ),
            if (docWriting(d.generation)) ...[
              const SizedBox(height: 12),
              HelpBox(l.mdocumentsWriting, tone: Tone.warn),
            ],
            if (docFailed(d.generation)) ...[
              const SizedBox(height: 12),
              HelpBox(l.mdocumentsFailedText(d.generation!.error), tone: Tone.bad, copyable: true),
            ],
            if (trState != null && (trState.isLoading || trState.hasError))
              TranslationStatus(trState)
            else if (tr != null && !tr.complete)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(l.documentsTranslatedIncomplete, style: TextStyle(fontSize: 13, color: c.ink3)),
              ),
            const SizedBox(height: 14),
            if (d.body.trim().isEmpty)
              HCard(child: Text(l.mdocumentsNoBody, style: TextStyle(color: c.ink3)))
            else if (d.kind == DocumentKind.slides)
              SlideDeck(tr?.body ?? d.body)
            else
              HCard(child: ReportMarkdown(tr?.body ?? d.body)),
            const SizedBox(height: 14),
            _LinkedTickets(id: d.id),
          ],
        ),
      ),
    );
  }
}

class _LinkedTickets extends ConsumerWidget {
  const _LinkedTickets({required this.id});
  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final ts = ref.watch(documentTicketsProvider(id)).value ?? const <DocumentTicket>[];
    if (ts.isEmpty) return const SizedBox.shrink();
    return Fold(
      title: l.mdocumentsLinkedTickets,
      hint: '${ts.length}',
      initiallyOpen: true,
      child: Column(children: [
        for (final t in ts)
          ListRow(
            title: t.title,
            subtitle: t.number,
            titleColor: c.ink,
            onTap: () => context.push('/tickets/${t.key}'),
          ),
      ]),
    );
  }
}
