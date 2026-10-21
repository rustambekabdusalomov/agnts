import 'package:test/test.dart';
import 'package:agnts_api/agnts_api.dart';

// tests for RepoHarnessInput
void main() {
  final RepoHarnessInput? instance = /* RepoHarnessInput(...) */ null;
  // TODO add properties to the entity

  group(RepoHarnessInput, () {
    // Empty follows the workspace
    // String guardProfile
    test('to test the property `guardProfile`', () async {
      // TODO
    });

    // Path globs where example credentials are expected, besides testdata/, fixtures/ and *.example
    // List<String> secretAllow
    test('to test the property `secretAllow`', () async {
      // TODO
    });

    // Per-file checks after each edit; null uses the ones agnts derives from the toolchains
    // List<EditCheck> editChecks
    test('to test the property `editChecks`', () async {
      // TODO
    });

    // bool editChecksOff
    test('to test the property `editChecksOff`', () async {
      // TODO
    });

    // An import the approved architecture does not allow is a blocker agnts's review sends back, not only a red flag
    // bool layersBlock
    test('to test the property `layersBlock`', () async {
      // TODO
    });

    // CoverageConfig coverage
    test('to test the property `coverage`', () async {
      // TODO
    });

    // Check the ticket's acceptance criteria in the running app after the preview
    // bool acceptance
    test('to test the property `acceptance`', () async {
      // TODO
    });

  });
}
