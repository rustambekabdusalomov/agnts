import 'package:test/test.dart';
import 'package:agnts_api/agnts_api.dart';

// tests for Toolchain
void main() {
  final Toolchain? instance = /* Toolchain(...) */ null;
  // TODO add properties to the entity

  group(Toolchain, () {
    // mise tool name: go, node, python, rust, java, dotnet, ruby, ...
    // String tool
    test('to test the property `tool`', () async {
      // TODO
    });

    // Exact, a prefix (20, 3.12), latest, lts or system
    // String version
    test('to test the property `version`', () async {
      // TODO
    });

    // Where it was found: go.mod, .nvmrc, default, manual
    // String source_
    test('to test the property `source_`', () async {
      // TODO
    });

    // Subdirectory it was found in
    // String dir
    test('to test the property `dir`', () async {
      // TODO
    });

  });
}
