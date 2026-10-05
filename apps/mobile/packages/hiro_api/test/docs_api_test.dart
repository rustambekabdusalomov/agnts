import 'package:test/test.dart';
import 'package:hiro_api/hiro_api.dart';


/// tests for DocsApi
void main() {
  final instance = HiroApi().getDocsApi();

  group(DocsApi, () {
    // The \"How this page works\" text, as Markdown
    //
    //Future<String> getPageDoc(String page, { String lang }) async
    test('test getPageDoc', () async {
      // TODO
    });

  });
}
