import 'package:test/test.dart';
import 'package:hiro_api/hiro_api.dart';


/// tests for MetaApi
void main() {
  final instance = HiroApi().getMetaApi();

  group(MetaApi, () {
    // Server version and build information
    //
    //Future<Meta> getMeta() async
    test('test getMeta', () async {
      // TODO
    });

  });
}
