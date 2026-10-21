import 'package:test/test.dart';
import 'package:agnts_api/agnts_api.dart';

// tests for Analysis
void main() {
  final Analysis? instance = /* Analysis(...) */ null;
  // TODO add properties to the entity

  group(Analysis, () {
    // String summary
    test('to test the property `summary`', () async {
      // TODO
    });

    // List<String> plan
    test('to test the property `plan`', () async {
      // TODO
    });

    // The analysis's rating; picks the review model on auto
    // String complexity
    test('to test the property `complexity`', () async {
      // TODO
    });

    // Footprint footprint
    test('to test the property `footprint`', () async {
      // TODO
    });

    // Ways to do the work that the analysis weighed; exactly one is chosen
    // List<Approach> approaches
    test('to test the property `approaches`', () async {
      // TODO
    });

    // What the work will deliberately not do
    // List<String> outOfScope
    test('to test the property `outOfScope`', () async {
      // TODO
    });

    // ShipNotes ship
    test('to test the property `ship`', () async {
      // TODO
    });

    // The work fixes broken behaviour; with proveFixes on it must prove the fix
    // bool defect
    test('to test the property `defect`', () async {
      // TODO
    });

    // What the finished work must do, as checks
    // List<AnalysisAcceptanceInner> acceptance
    test('to test the property `acceptance`', () async {
      // TODO
    });

    // For each file the work changes, the existing code it follows (copy, adapt) or that it is new
    // List<Pattern> patterns
    test('to test the property `patterns`', () async {
      // TODO
    });

    // Existing helpers the work must use instead of writing its own
    // List<AnalysisReuseInner> reuse
    test('to test the property `reuse`', () async {
      // TODO
    });

    // Tests the work must add or change
    // List<AnalysisTestPlanInner> testPlan
    test('to test the property `testPlan`', () async {
      // TODO
    });

    // Inputs and failures the work must handle
    // List<String> edgeCases
    test('to test the property `edgeCases`', () async {
      // TODO
    });

    // AnalysisRepro repro
    test('to test the property `repro`', () async {
      // TODO
    });

    // SecondOpinion secondOpinion
    test('to test the property `secondOpinion`', () async {
      // TODO
    });

  });
}
