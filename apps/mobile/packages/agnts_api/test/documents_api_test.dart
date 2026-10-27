import 'package:test/test.dart';
import 'package:agnts_api/agnts_api.dart';


/// tests for DocumentsApi
void main() {
  final instance = AgntsApi().getDocumentsApi();

  group(DocumentsApi, () {
    // Comment on selected text, or reply to a comment (view access is enough)
    //
    //Future<DocumentComment> addDocumentComment(int id, DocumentCommentInput documentCommentInput) async
    test('test addDocumentComment', () async {
      // TODO
    });

    // A guest comments on selected text, or replies
    //
    //Future<DocumentComment> addPublicDocumentComment(String token, DocumentCommentInput documentCommentInput, { String xGuestToken }) async
    test('test addPublicDocumentComment', () async {
      // TODO
    });

    // Create a document, written by you or by agnts from a source
    //
    // Without a source the body is yours and becomes version 1. With a source, agnts gathers the facts (a ticket's report, tickets, commits, pull requests or a repository) and writes the body; the document starts at version 0 and its generation shows the progress. Workspace viewers may create documents; they own what they create. 
    //
    //Future<Document> createDocument(DocumentInput documentInput) async
    test('test createDocument', () async {
      // TODO
    });

    // Have agnts make a document from the ticket's report, linked to the ticket
    //
    //Future<Document> createTicketDocument(String key, { CreateTicketDocumentRequest createTicketDocumentRequest }) async
    test('test createTicketDocument', () async {
      // TODO
    });

    // Move a document to the trash (its owner); restorable for 30 days
    //
    //Future deleteDocument(int id) async
    test('test deleteDocument', () async {
      // TODO
    });

    // Delete a comment, and a thread's replies with it (its author, or the document's owner)
    //
    //Future deleteDocumentComment(int id, int commentId) async
    test('test deleteDocumentComment', () async {
      // TODO
    });

    // A guest deletes their comment
    //
    //Future deletePublicDocumentComment(String token, int commentId, { String xGuestToken }) async
    test('test deletePublicDocumentComment', () async {
      // TODO
    });

    // Say you have the document open (every 10 seconds) or are leaving; answers who is viewing it now
    //
    //Future<DocumentPresence> documentPresence(int id, { PresenceInput presenceInput }) async
    test('test documentPresence', () async {
      // TODO
    });

    // Download a version as Markdown or PDF (view access)
    //
    // version 0 (the default) is the current one. The first PDF download of a version starts making it and answers 202 with Retry-After; ask again then. A made PDF is kept: later downloads are instant. 
    //
    //Future<Uint8List> downloadDocument(int id, { String format, int version, TranslationLanguage lang }) async
    test('test downloadDocument', () async {
      // TODO
    });

    // Download a public document's current version
    //
    // The PDF is made ahead when the document is published or saved; until it is ready the answer is 202. Needs the guest's token.
    //
    //Future<Uint8List> downloadPublicDocument(String token, { String format, String xGuestToken }) async
    test('test downloadPublicDocument', () async {
      // TODO
    });

    // A document with your access to it; 404 when you cannot open it
    //
    //Future<Document> getDocument(int id) async
    test('test getDocument', () async {
      // TODO
    });

    // Who can open a document, and its public link
    //
    //Future<DocumentSharing> getDocumentSharing(int id) async
    test('test getDocumentSharing', () async {
      // TODO
    });

    // One version with its text
    //
    //Future<DocumentVersion> getDocumentVersion(int id, int version) async
    test('test getDocumentVersion', () async {
      // TODO
    });

    // A public document, for a guest of its link
    //
    // Only the kind, title, text, version and last update. Needs the guest's token (401 guest_required without). Rate limited per address.
    //
    //Future<PublicDocument> getPublicDocument(String token, { String xGuestToken }) async
    test('test getPublicDocument', () async {
      // TODO
    });

    // What a public link opens, before the reader says who they are
    //
    // The kind and title only, and Google's client id when \"Continue with Google\" is on.
    //
    //Future<PublicDocumentInfo> getPublicDocumentInfo(String token) async
    test('test getPublicDocumentInfo', () async {
      // TODO
    });

    // Say who you are to open a public document; signed in, your account says it
    //
    // Answers the guest's secret token, sent afterwards as X-Guest-Token. It works only on this document, and only while it is public.
    //
    //Future<GuestSession> joinPublicDocument(String token, GuestJoin guestJoin) async
    test('test joinPublicDocument', () async {
      // TODO
    });

    // Link a ticket to a document (edit access on the document)
    //
    //Future linkDocumentTicket(int id, String key) async
    test('test linkDocumentTicket', () async {
      // TODO
    });

    // The comments on a document, oldest first (view access)
    //
    //Future<List<DocumentComment>> listDocumentComments(int id) async
    test('test listDocumentComments', () async {
      // TODO
    });

    // The tickets linked to a document
    //
    //Future<List<DocumentTicket>> listDocumentTickets(int id) async
    test('test listDocumentTickets', () async {
      // TODO
    });

    // Every version of a document, newest first, without their text
    //
    //Future<List<DocumentVersion>> listDocumentVersions(int id) async
    test('test listDocumentVersions', () async {
      // TODO
    });

    // The documents you can open, most recently changed first
    //
    // Your own documents, the ones shared with you (by a grant or the workspace default), and for the workspace owner every document. scope=deleted lists the trash: your own deleted documents (all of them for the workspace owner), restorable for 30 days. 
    //
    //Future<List<DocumentSummary>> listDocuments({ String scope, String q, String ticket, DocumentKind kind, int derivedFrom }) async
    test('test listDocuments', () async {
      // TODO
    });

    // The comments on a public document, for its guests
    //
    //Future<List<DocumentComment>> listPublicDocumentComments(String token, { String xGuestToken }) async
    test('test listPublicDocumentComments', () async {
      // TODO
    });

    // The documents linked to the ticket that you can open
    //
    // Documents you cannot open are neither listed nor counted.
    //
    //Future<List<DocumentSummary>> listTicketDocuments(String key) async
    test('test listTicketDocuments', () async {
      // TODO
    });

    // A guest says they have the document open, or are leaving; answers who is viewing it now
    //
    //Future<DocumentPresence> publicDocumentPresence(String token, { String xGuestToken, PresenceInput presenceInput }) async
    test('test publicDocumentPresence', () async {
      // TODO
    });

    // Have agnts write the document again (edit access); the result is a new version
    //
    //Future<Document> regenerateDocument(int id, { DocumentRegenerate documentRegenerate }) async
    test('test regenerateDocument', () async {
      // TODO
    });

    // Give a public document a new link; the old one stops working (its owner)
    //
    //Future<DocumentSharing> resetDocumentLink(int id) async
    test('test resetDocumentLink', () async {
      // TODO
    });

    // Make an earlier version the current one, as a new version (edit access)
    //
    //Future<Document> restoreDocumentVersion(int id, int version) async
    test('test restoreDocumentVersion', () async {
      // TODO
    });

    // Save an edit as a new version (edit access)
    //
    // baseVersion is the version the edit started from. When someone saved in between, the answer is 409 with the document as it is now, so the editor can show both texts. While agnts writes the body only the title changes. 
    //
    //Future<Document> saveDocument(int id, DocumentSave documentSave) async
    test('test saveDocument', () async {
      // TODO
    });

    // Give a document to another member (its owner); the old owner keeps edit access
    //
    //Future<Document> setDocumentOwner(int id, TransferWorkspaceRequest transferWorkspaceRequest) async
    test('test setDocumentOwner', () async {
      // TODO
    });

    // Set a document's type, workspace access and grants (its owner)
    //
    // Grants replace the current ones. Workspace viewers can only be given view. Going public needs public documents on in Settings and a text without secrets: when the scan finds some, the answer is 422 with the lines. A document that goes public gets a new link; one made private loses its link at once. 
    //
    //Future<DocumentSharing> shareDocument(int id, DocumentShareInput documentShareInput) async
    test('test shareDocument', () async {
      // TODO
    });

    // The current version translated into a language (view access)
    //
    // The title and each Markdown block are translated and stored on their own, so a later version only sends the blocks that changed. Blocks not yet translated are translated in this request, which can take a minute for a long document.
    //
    //Future<DocumentTranslation> translateDocument(int id, TranslateInput translateInput) async
    test('test translateDocument', () async {
      // TODO
    });

    // Take a document out of the trash (its owner or the workspace owner)
    //
    //Future<Document> undeleteDocument(int id) async
    test('test undeleteDocument', () async {
      // TODO
    });

    // Remove a link between a ticket and a document
    //
    //Future unlinkDocumentTicket(int id, String key) async
    test('test unlinkDocumentTicket', () async {
      // TODO
    });

    // Edit your comment, or resolve or reopen a thread (its author, or edit access)
    //
    //Future<DocumentComment> updateDocumentComment(int id, int commentId, DocumentCommentPatch documentCommentPatch) async
    test('test updateDocumentComment', () async {
      // TODO
    });

    // A guest edits their comment, or resolves or reopens their thread
    //
    //Future<DocumentComment> updatePublicDocumentComment(String token, int commentId, DocumentCommentPatch documentCommentPatch, { String xGuestToken }) async
    test('test updatePublicDocumentComment', () async {
      // TODO
    });

  });
}
