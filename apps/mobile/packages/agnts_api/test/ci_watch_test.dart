import 'package:test/test.dart';
import 'package:agnts_api/agnts_api.dart';

// tests for CIWatch
void main() {
  final CIWatch? instance = /* CIWatch(...) */ null;
  // TODO add properties to the entity

  group(CIWatch, () {
    // bool enabled
    test('to test the property `enabled`', () async {
      // TODO
    });

    // Globs of extra watched branches; the default branch is always watched
    // List<String> branches
    test('to test the property `branches`', () async {
      // TODO
    });

    // Globs of workflow or job names never watched
    // List<String> ignore
    test('to test the property `ignore`', () async {
      // TODO
    });

    // Failures on other people's pull requests: off (ignore) or comment (post one diagnosis comment)
    // String prs
    test('to test the property `prs`', () async {
      // TODO
    });

    // Overrides the workspace setting for this repository; null follows it
    // bool autoFix
    test('to test the property `autoFix`', () async {
      // TODO
    });

    // Why agnts cannot read this repository's CI with the current token, or empty
    // String problem
    test('to test the property `problem`', () async {
      // TODO
    });

  });
}
