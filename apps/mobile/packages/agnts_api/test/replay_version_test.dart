import 'package:test/test.dart';
import 'package:agnts_api/agnts_api.dart';

// tests for ReplayVersion
void main() {
  final ReplayVersion? instance = /* ReplayVersion(...) */ null;
  // TODO add properties to the entity

  group(ReplayVersion, () {
    // String promptVersion
    test('to test the property `promptVersion`', () async {
      // TODO
    });

    // The coding model of the replays
    // String model
    test('to test the property `model`', () async {
      // TODO
    });

    // int replays
    test('to test the property `replays`', () async {
      // TODO
    });

    // Replays scored against what the original merged as
    // int merged
    test('to test the property `merged`', () async {
      // TODO
    });

    // Average share of the merged change's added lines the replays add too; absent when none was scored against a merge
    // num avgLineRecall
    test('to test the property `avgLineRecall`', () async {
      // TODO
    });

    // The same for the originals' own changes, to compare with
    // num originalLineRecall
    test('to test the property `originalLineRecall`', () async {
      // TODO
    });

    // int checksPassed
    test('to test the property `checksPassed`', () async {
      // TODO
    });

    // Replays agnts's code review read
    // int reviewed
    test('to test the property `reviewed`', () async {
      // TODO
    });

    // Reviews that found nothing to block
    // int looksGood
    test('to test the property `looksGood`', () async {
      // TODO
    });

    // Average Jaccard index of the changed files, replay against original
    // num avgOverlap
    test('to test the property `avgOverlap`', () async {
      // TODO
    });

    // Average share of the original's files the replay changed too
    // num avgRecall
    test('to test the property `avgRecall`', () async {
      // TODO
    });

    // num avgTurns
    test('to test the property `avgTurns`', () async {
      // TODO
    });

    // num avgCostUsd
    test('to test the property `avgCostUsd`', () async {
      // TODO
    });

    // Average turns of the originals, for comparison
    // num originalTurns
    test('to test the property `originalTurns`', () async {
      // TODO
    });

    // num originalCostUsd
    test('to test the property `originalCostUsd`', () async {
      // TODO
    });

  });
}
