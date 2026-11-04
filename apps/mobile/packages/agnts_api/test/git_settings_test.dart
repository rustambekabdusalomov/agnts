import 'package:test/test.dart';
import 'package:agnts_api/agnts_api.dart';

// tests for GitSettings
void main() {
  final GitSettings? instance = /* GitSettings(...) */ null;
  // TODO add properties to the entity

  group(GitSettings, () {
    // String authorName
    test('to test the property `authorName`', () async {
      // TODO
    });

    // String authorEmail
    test('to test the property `authorEmail`', () async {
      // TODO
    });

    // Add a Co-authored-by agnts line
    // bool coAuthor
    test('to test the property `coAuthor`', () async {
      // TODO
    });

    // Pull request title template, with the commit template's placeholders {number} {key} {type} {scope} {subject} {title}; must contain {subject} or {title}. A repository's or group's own replaces it
    // String prTitle
    test('to test the property `prTitle`', () async {
      // TODO
    });

    // bool draft
    test('to test the property `draft`', () async {
      // TODO
    });

  });
}
