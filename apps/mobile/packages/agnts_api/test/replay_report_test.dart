import 'package:test/test.dart';
import 'package:agnts_api/agnts_api.dart';

// tests for ReplayReport
void main() {
  final ReplayReport? instance = /* ReplayReport(...) */ null;
  // TODO add properties to the entity

  group(ReplayReport, () {
    // Replays with a change, summed by the prompt version and coding model they ran with
    // List<ReplayVersion> versions
    test('to test the property `versions`', () async {
      // TODO
    });

    // The same, for the replays of tickets in the benchmark only
    // List<ReplayVersion> benchmark
    test('to test the property `benchmark`', () async {
      // TODO
    });

    // The newest replays first
    // List<ReplayResult> replays
    test('to test the property `replays`', () async {
      // TODO
    });

  });
}
