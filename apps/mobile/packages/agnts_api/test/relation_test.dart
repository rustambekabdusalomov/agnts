import 'package:test/test.dart';
import 'package:agnts_api/agnts_api.dart';

// tests for Relation
void main() {
  final Relation? instance = /* Relation(...) */ null;
  // TODO add properties to the entity

  group(Relation, () {
    // int id
    test('to test the property `id`', () async {
      // TODO
    });

    // RelationType type
    test('to test the property `type`', () async {
      // TODO
    });

    // From the ticket asked about: it waits for other, other waits for it, or they conflict
    // String direction
    test('to test the property `direction`', () async {
      // TODO
    });

    // Who found it: a Jira link, a person, the analysis, overlapping footprints, or the finished diffs (when nobody predicted it)
    // String source_
    test('to test the property `source_`', () async {
      // TODO
    });

    // Only active relations hold the queue; proposed ones wait for a person
    // String status
    test('to test the property `status`', () async {
      // TODO
    });

    // double confidence
    test('to test the property `confidence`', () async {
      // TODO
    });

    // String reason
    test('to test the property `reason`', () async {
      // TODO
    });

    // For rule and git relations: files, migrations, lockfile, codegen, i18n or diff
    // String basis
    test('to test the property `basis`', () async {
      // TODO
    });

    // Files both tickets change, when known
    // List<String> files
    test('to test the property `files`', () async {
      // TODO
    });

    // RelatedTicket other
    test('to test the property `other`', () async {
      // TODO
    });

    // When the finished changes proved the conflict real
    // DateTime confirmedAt
    test('to test the property `confirmedAt`', () async {
      // TODO
    });

    // DateTime decidedAt
    test('to test the property `decidedAt`', () async {
      // TODO
    });

    // DateTime createdAt
    test('to test the property `createdAt`', () async {
      // TODO
    });

  });
}
