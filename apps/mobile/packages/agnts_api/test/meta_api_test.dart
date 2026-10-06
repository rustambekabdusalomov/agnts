import 'package:test/test.dart';
import 'package:agnts_api/agnts_api.dart';


/// tests for MetaApi
void main() {
  final instance = AgntsApi().getMetaApi();

  group(MetaApi, () {
    // Server version and build information
    //
    //Future<Meta> getMeta() async
    test('test getMeta', () async {
      // TODO
    });

  });
}
