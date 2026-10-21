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

    // Average times red CI on the pull request sent the work back, over the tickets that reached review
    // num ciRounds
    test('to test the property `ciRounds`', () async {
      // TODO
    });

    // Their pull requests merged
    // int merged
    test('to test the property `merged`', () async {
      // TODO
    });

    // What all their runs cost
    // num costUsd
    test('to test the property `costUsd`', () async {
      // TODO
    });

    // Cost over merged tickets; absent when none merged
    // num costPerMerged
    test('to test the property `costPerMerged`', () async {
      // TODO
    });

    // 0–100: done first time 35%, merged 25%, no serious finding 20%, few change rounds 20%
    // num score
    test('to test the property `score`', () async {
      // TODO
    });

    // Average share of agnts's lines people changed before merging; absent when no merge was recorded
    // num peopleEdited
    test('to test the property `peopleEdited`', () async {
      // TODO
    });

    // Tickets whose merged work people reverted
    // int reverted
    test('to test the property `reverted`', () async {
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

    // Actions agnts-guard refused in their coding runs
    // int guardBlocks
    test('to test the property `guardBlocks`', () async {
      // TODO
    });

    // Tickets whose stop gate sent failing checks back and whose checks then passed first time
    // int stopSaves
    test('to test the property `stopSaves`', () async {
      // TODO
    });

    // Times their runs looked stuck
    // int stalls
    test('to test the property `stalls`', () async {
      // TODO
    });

    // Tickets with a proof of fix
    // int proofDue
    test('to test the property `proofDue`', () async {
      // TODO
    });

    // Of those, proven
    // int proven
    test('to test the property `proven`', () async {
      // TODO
    });

    // Review findings shown on them
    // int findings
    test('to test the property `findings`', () async {
      // TODO
    });

    // Of those, put into a person's feedback
    // int adopted
    test('to test the property `adopted`', () async {
      // TODO
    });

    // Average tokens of a done ticket, all stages
    // num tokens
    test('to test the property `tokens`', () async {
      // TODO
    });

    // Tickets in the fact check group (A/B)
    // int factCheck
    test('to test the property `factCheck`', () async {
      // TODO
    });

    // Of those, done without a person asking for changes
    // int factCheckFirst
    test('to test the property `factCheckFirst`', () async {
      // TODO
    });

  });
}
