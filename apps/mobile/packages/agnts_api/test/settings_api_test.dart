import 'package:test/test.dart';
import 'package:agnts_api/agnts_api.dart';


/// tests for SettingsApi
void main() {
  final instance = AgntsApi().getSettingsApi();

  group(SettingsApi, () {
    //Future<Settings> getSettings() async
    test('test getSettings', () async {
      // TODO
    });

    // The coding modules and models you may use
    //
    //Future<ModelCatalog> listModels() async
    test('test listModels', () async {
      // TODO
    });

    //Future<Settings> putSettings(Settings settings) async
    test('test putSettings', () async {
      // TODO
    });

  });
}
