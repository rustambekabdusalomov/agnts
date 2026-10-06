import 'package:test/test.dart';
import 'package:agnts_api/agnts_api.dart';


/// tests for DocsApi
void main() {
  final instance = AgntsApi().getDocsApi();

  group(DocsApi, () {
    // The \"How this page works\" text, as Markdown
    //
    //Future<String> getPageDoc(String page, { String lang }) async
    test('test getPageDoc', () async {
      // TODO
    });

  });
}
