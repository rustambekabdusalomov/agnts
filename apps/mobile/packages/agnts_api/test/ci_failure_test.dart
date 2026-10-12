import 'package:test/test.dart';
import 'package:agnts_api/agnts_api.dart';

// tests for CIFailure
void main() {
  final CIFailure? instance = /* CIFailure(...) */ null;
  // TODO add properties to the entity

  group(CIFailure, () {
    // int id
    test('to test the property `id`', () async {
      // TODO
    });

    // int repoId
    test('to test the property `repoId`', () async {
      // TODO
    });

    // String repo
    test('to test the property `repo`', () async {
      // TODO
    });

    // The branch, or pr/<number> for a failure on someone else's pull request
    // String branch
    test('to test the property `branch`', () async {
      // TODO
    });

    // String workflow
    test('to test the property `workflow`', () async {
      // TODO
    });

    // String job
    test('to test the property `job`', () async {
      // TODO
    });

    // String title
    test('to test the property `title`', () async {
      // TODO
    });

    // code, test, config, dependency, infra, flaky, report, or empty while unknown
    // String class_
    test('to test the property `class_`', () async {
      // TODO
    });

    // CIStatus status
    test('to test the property `status`', () async {
      // TODO
    });

    // int count
    test('to test the property `count`', () async {
      // TODO
    });

    // int flakyCount
    test('to test the property `flakyCount`', () async {
      // TODO
    });

    // DateTime firstSeenAt
    test('to test the property `firstSeenAt`', () async {
      // TODO
    });

    // DateTime lastSeenAt
    test('to test the property `lastSeenAt`', () async {
      // TODO
    });

    // String firstSha
    test('to test the property `firstSha`', () async {
      // TODO
    });

    // String lastSha
    test('to test the property `lastSha`', () async {
      // TODO
    });

    // List<CIOccurrence> occurrences
    test('to test the property `occurrences`', () async {
      // TODO
    });

    // The ticket fixing it, or empty
    // String ticketKey
    test('to test the property `ticketKey`', () async {
      // TODO
    });

    // TicketState ticketState
    test('to test the property `ticketState`', () async {
      // TODO
    });

    // String fixedSha
    test('to test the property `fixedSha`', () async {
      // TODO
    });

    // DateTime fixedAt
    test('to test the property `fixedAt`', () async {
      // TODO
    });

    // Someone else's pull request (diagnosis comment only), 0 otherwise
    // int prNumber
    test('to test the property `prNumber`', () async {
      // TODO
    });

    // Redacted log excerpt (single reads only)
    // String sample
    test('to test the property `sample`', () async {
      // TODO
    });

  });
}
