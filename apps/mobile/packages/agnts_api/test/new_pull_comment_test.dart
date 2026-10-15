import 'package:test/test.dart';
import 'package:agnts_api/agnts_api.dart';

// tests for NewPullComment
void main() {
  final NewPullComment? instance = /* NewPullComment(...) */ null;
  // TODO add properties to the entity

  group(NewPullComment, () {
    // String body
    test('to test the property `body`', () async {
      // TODO
    });

    // The file, for a comment on a line
    // String path
    test('to test the property `path`', () async {
      // TODO
    });

    // Line in the new file (an added or unchanged line)
    // int line
    test('to test the property `line`', () async {
      // TODO
    });

    // Line in the old file: a removed line, or with line an unchanged one
    // int oldLine
    test('to test the property `oldLine`', () async {
      // TODO
    });

    // First line of a range (GitHub)
    // int startLine
    test('to test the property `startLine`', () async {
      // TODO
    });

    // The commit the line is in; the newest when empty
    // String headSha
    test('to test the property `headSha`', () async {
      // TODO
    });

  });
}
