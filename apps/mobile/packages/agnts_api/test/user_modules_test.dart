import 'package:test/test.dart';
import 'package:agnts_api/agnts_api.dart';

// tests for UserModules
void main() {
  final UserModules? instance = /* UserModules(...) */ null;
  // TODO add properties to the entity

  group(UserModules, () {
    // The list an Admin set; absent or null follows the default
    // List<Module> own
    test('to test the property `own`', () async {
      // TODO
    });

    // What the person may use now, in their order, the default module first
    // List<Module> effective
    test('to test the property `effective`', () async {
      // TODO
    });

    // The order the person put their modules in themselves; absent or null keeps the Admin's
    // List<Module> order
    test('to test the property `order`', () async {
      // TODO
    });

    // DateTime setAt
    test('to test the property `setAt`', () async {
      // TODO
    });

  });
}
