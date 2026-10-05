import 'package:test/test.dart';
import 'package:hiro_api/hiro_api.dart';

// tests for LocalBranch
void main() {
  final LocalBranch? instance = /* LocalBranch(...) */ null;
  // TODO add properties to the entity

  group(LocalBranch, () {
    // String name
    test('to test the property `name`', () async {
      // TODO
    });

    // String sha
    test('to test the property `sha`', () async {
      // TODO
    });

    // String message
    test('to test the property `message`', () async {
      // TODO
    });

    // String author
    test('to test the property `author`', () async {
      // TODO
    });

    // DateTime date
    test('to test the property `date`', () async {
      // TODO
    });

    // Commits not on the default branch
    // int ahead
    test('to test the property `ahead`', () async {
      // TODO
    });

    // Default branch commits the branch lacks
    // int behind
    test('to test the property `behind`', () async {
      // TODO
    });

    // local: not on origin; pushed: origin has the same commit; unpushed: origin is behind; differs: origin has commits the local branch lacks
    // String status
    test('to test the property `status`', () async {
      // TODO
    });

    // Commits origin lacks (status unpushed)
    // int unpushed
    test('to test the property `unpushed`', () async {
      // TODO
    });

    // String ticketKey
    test('to test the property `ticketKey`', () async {
      // TODO
    });

  });
}
