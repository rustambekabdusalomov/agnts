import 'package:test/test.dart';
import 'package:agnts_api/agnts_api.dart';

// tests for QualityStat
void main() {
  final QualityStat? instance = /* QualityStat(...) */ null;
  // TODO add properties to the entity

  group(QualityStat, () {
    // Empty for runs from before versions were recorded
    // String promptVersion
    test('to test the property `promptVersion`', () async {
      // TODO
    });

    // First coding run in the period
    // int tickets
    test('to test the property `tickets`', () async {
      // TODO
    });

    // int reachedReview
    test('to test the property `reachedReview`', () async {
      // TODO
    });

    // int done
    test('to test the property `done`', () async {
      // TODO
    });

    // Done without a person asking for changes
    // int firstTry
    test('to test the property `firstTry`', () async {
      // TODO
    });

    // int rejected
    test('to test the property `rejected`', () async {
      // TODO
    });

    // Average change requests by a person, over the tickets that reached review
    // num changeRounds
    test('to test the property `changeRounds`', () async {
      // TODO
    });

    // Average failing checks sent back to Claude
    // num fixAttempts
    test('to test the property `fixAttempts`', () async {
      // TODO
    });

    // Reviewed with a blocker or major finding at least once
    // int serious
    test('to test the property `serious`', () async {
      // TODO
    });

    // Average share of the changed files the analysis predicted; absent when none was measured
    // num footprintHit
    test('to test the property `footprintHit`', () async {
      // TODO
    });

    // Red flags found in the diffs
    // int redFlags
    test('to test the property `redFlags`', () async {
      // TODO
    });

    // Findings of agnts's own review sent back to the coder
    // int selfFixes
    test('to test the property `selfFixes`', () async {
      // TODO
    });

  });
}
