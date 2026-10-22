import 'dart:convert';

import 'package:agnts_api/agnts_api.dart';
import 'package:agnts_mobile/features/documents/documents_logic.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('file name from Content-Disposition', () {
    expect(fileNameFromDisposition(r'''attachment; filename="report-v2.pdf"; filename*=UTF-8''report-v2.pdf'''), 'report-v2.pdf');
    expect(fileNameFromDisposition('attachment; filename="plain-v1.md"'), 'plain-v1.md');
    expect(fileNameFromDisposition(r'''attachment; filename*=UTF-8''..%2F..%2Fetc%2Fpasswd'''), '..-..-etc-passwd');
    expect(fileNameFromDisposition(null), isNull);
    expect(fileNameFromDisposition('attachment'), isNull);
  });

  test('retry after is kept between 1 and 10 seconds', () {
    expect(retryAfter('3'), const Duration(seconds: 3));
    expect(retryAfter(null), const Duration(seconds: 3));
    expect(retryAfter('120'), const Duration(seconds: 10));
    expect(retryAfter('0'), const Duration(seconds: 1));
  });

  test('error message from a byte body', () {
    expect(messageFromBody(utf8.encode('{"code":"not_found","message":"no such document"}')), 'no such document');
    expect(messageFromBody({'message': 'x'}), 'x');
    expect(messageFromBody(utf8.encode('%PDF')), isNull);
  });

  test('secret lines from a 422 answer', () {
    expect(secretLines({
      'findings': [
        {'line': 3, 'excerpt': 'Token: •••'},
        {'line': 'bad'},
      ],
    }), [(3, 'Token: •••')]);
    expect(secretLines('nope'), isEmpty);
  });

  test('generation states', () {
    DocumentGeneration g(DocumentGenerationStatusEnum s) => DocumentGeneration(id: 1, status: s, error: '', createdAt: DateTime(2026));
    expect(docWriting(g(DocumentGenerationStatusEnum.queued)), isTrue);
    expect(docWriting(g(DocumentGenerationStatusEnum.writing)), isTrue);
    expect(docWriting(g(DocumentGenerationStatusEnum.done)), isFalse);
    expect(docWriting(null), isFalse);
    expect(docFailed(g(DocumentGenerationStatusEnum.failed)), isTrue);
  });

  test('viewers are only given view', () {
    expect(grantLevelFor(WorkspaceRole.viewer, DocumentShareInputGrantsInnerLevelEnum.edit), DocumentShareInputGrantsInnerLevelEnum.view);
    expect(grantLevelFor(WorkspaceRole.user, DocumentShareInputGrantsInnerLevelEnum.edit), DocumentShareInputGrantsInnerLevelEnum.edit);
  });
}
