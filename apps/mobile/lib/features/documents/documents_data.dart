import 'package:agnts_api/agnts_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api.dart';
import '../../core/data.dart';
import 'documents_logic.dart';

/// The documents you can open, by scope. The live stream refreshes it on
/// document_updated events.
final documentsProvider = FutureProvider.autoDispose.family<List<DocumentSummary>, DocScope>((ref, scope) async {
  ref.watch(currentWorkspaceProvider.select((w) => w?.slug));
  return (await requireApi(ref).getDocumentsApi().listDocuments(scope: scope.api)).data ?? const [];
});

/// One document with its text.
final documentProvider = FutureProvider.autoDispose.family<Document, int>((ref, id) async {
  final res = await requireApi(ref).getDocumentsApi().getDocument(id: id);
  return res.data!;
});

/// A document's version [version] translated into [lang].
final documentTranslationProvider =
    FutureProvider.family<DocumentTranslation, ({int id, TranslationLanguage lang, int version})>((ref, a) async {
  final res = await requireApi(ref).getDocumentsApi().translateDocument(id: a.id, translateInput: TranslateInput(lang: a.lang));
  return res.data!;
});

/// The tickets linked to a document.
final documentTicketsProvider = FutureProvider.autoDispose.family<List<DocumentTicket>, int>((ref, id) async {
  return (await requireApi(ref).getDocumentsApi().listDocumentTickets(id: id)).data ?? const [];
});

/// The documents linked to a ticket that you can open.
final ticketDocumentsProvider = FutureProvider.autoDispose.family<List<DocumentSummary>, String>((ref, key) async {
  return (await requireApi(ref).getDocumentsApi().listTicketDocuments(key: key)).data ?? const [];
});

/// Refreshes everything showing documents (a document_updated event).
void invalidateDocuments(Ref ref) {
  ref.invalidate(documentsProvider);
  ref.invalidate(documentProvider);
  ref.invalidate(documentTicketsProvider);
  ref.invalidate(ticketDocumentsProvider);
}
