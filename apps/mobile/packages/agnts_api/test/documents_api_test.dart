import 'package:test/test.dart';
import 'package:agnts_api/agnts_api.dart';


/// tests for DocumentsApi
void main() {
  final instance = AgntsApi().getDocumentsApi();

  group(DocumentsApi, () {
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

    // Download a version as Markdown or PDF (view access)
    //
    // version 0 (the default) is the current one. The first PDF download of a version starts making it and answers 202 with Retry-After; ask again then. A made PDF is kept: later downloads are instant. 
    //
    //Future<Uint8List> downloadDocument(int id, { String format, int version }) async
    test('test downloadDocument', () async {
      // TODO
    });

    // Download a public document's current version
    //
    // The PDF is made ahead when the document is published or saved; until it is ready the answer is 202.
    //
    //Future<Uint8List> downloadPublicDocument(String token, { String format }) async
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

    // A public document, for anyone with its link
    //
    // Only the title, text, version and last update. Rate limited per address.
    //
    //Future<PublicDocument> getPublicDocument(String token) async
    test('test getPublicDocument', () async {
      // TODO
    });

    // Link a ticket to a document (edit access on the document)
    //
    //Future linkDocumentTicket(int id, String key) async
    test('test linkDocumentTicket', () async {
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
    //Future<List<DocumentSummary>> listDocuments({ String scope, String q, String ticket }) async
    test('test listDocuments', () async {
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

  });
}
