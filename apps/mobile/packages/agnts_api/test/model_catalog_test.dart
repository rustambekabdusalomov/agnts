import 'package:test/test.dart';
import 'package:agnts_api/agnts_api.dart';

// tests for ModelCatalog
void main() {
  final ModelCatalog? instance = /* ModelCatalog(...) */ null;
  // TODO add properties to the entity

  group(ModelCatalog, () {
    // The coding modules you may use (an Admin chooses them); empty when none
    // List<String> providers
    test('to test the property `providers`', () async {
      // TODO
    });

    // Your default module; settings naming a module you may not use run on its models
    // String primary
    test('to test the property `primary`', () async {
      // TODO
    });

    // List<ModelCatalogModelsInner> models
    test('to test the property `models`', () async {
      // TODO
    });

    // The modules you may use, in your order, each with its own light and strong model (absent when the module has none, like Codex without AGNTS_CODEX_MODELS)
    // List<ModelCatalogModulesInner> modules
    test('to test the property `modules`', () async {
      // TODO
    });

    // Tiers a setting may name instead of a model: the run lands on the light or strong model of whichever module can run it
    // List<ModelCatalogTiersInner> tiers
    test('to test the property `tiers`', () async {
      // TODO
    });

  });
}
