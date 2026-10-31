import 'package:test/test.dart';
import 'package:agnts_api/agnts_api.dart';

// tests for ModulesSettings
void main() {
  final ModulesSettings? instance = /* ModulesSettings(...) */ null;
  // TODO add properties to the entity

  group(ModulesSettings, () {
    // What this server can run (AGNTS_PROVIDERS); enabled stays within it
    // List<Module> available
    test('to test the property `available`', () async {
      // TODO
    });

    // List<Module> enabled
    test('to test the property `enabled`', () async {
      // TODO
    });

    // What a person gets unless an Admin set theirs, the default module first; codex cannot be first
    // List<Module> default_
    test('to test the property `default_`', () async {
      // TODO
    });

  });
}
