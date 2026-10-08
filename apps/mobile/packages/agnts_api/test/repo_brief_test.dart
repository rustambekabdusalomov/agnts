import 'package:test/test.dart';
import 'package:agnts_api/agnts_api.dart';

// tests for RepoBrief
void main() {
  final RepoBrief? instance = /* RepoBrief(...) */ null;
  // TODO add properties to the entity

  group(RepoBrief, () {
    // int repoId
    test('to test the property `repoId`', () async {
      // TODO
    });

    // String repoName
    test('to test the property `repoName`', () async {
      // TODO
    });

    // The approved brief, Markdown; empty when there is none
    // String body
    test('to test the property `body`', () async {
      // TODO
    });

    // The commit the approved brief describes
    // String bodySha
    test('to test the property `bodySha`', () async {
      // TODO
    });

    // The latest survey, waiting for approval; empty when there is none
    // String draft
    test('to test the property `draft`', () async {
      // TODO
    });

    // String draftSha
    test('to test the property `draftSha`', () async {
      // TODO
    });

    // String status
    test('to test the property `status`', () async {
      // TODO
    });

    // Tickets merged since the brief was approved
    // int mergesSince
    test('to test the property `mergesSince`', () async {
      // TODO
    });

    // Merges after which agnts surveys again, when Settings allow
    // int refreshAfter
    test('to test the property `refreshAfter`', () async {
      // TODO
    });

    // Why the last survey failed
    // String error
    test('to test the property `error`', () async {
      // TODO
    });

    // DateTime surveyedAt
    test('to test the property `surveyedAt`', () async {
      // TODO
    });

    // DateTime approvedAt
    test('to test the property `approvedAt`', () async {
      // TODO
    });

    // DateTime updatedAt
    test('to test the property `updatedAt`', () async {
      // TODO
    });

  });
}
