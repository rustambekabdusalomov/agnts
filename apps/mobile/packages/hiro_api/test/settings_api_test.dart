import 'package:test/test.dart';
import 'package:hiro_api/hiro_api.dart';


/// tests for SettingsApi
void main() {
  final instance = HiroApi().getSettingsApi();

  group(SettingsApi, () {
    //Future<Settings> getSettings() async
    test('test getSettings', () async {
      // TODO
    });

    //Future<Settings> putSettings(Settings settings) async
    test('test putSettings', () async {
      // TODO
    });

  });
}
