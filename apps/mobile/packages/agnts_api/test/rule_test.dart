import 'package:test/test.dart';
import 'package:agnts_api/agnts_api.dart';

// tests for Rule
void main() {
  final Rule? instance = /* Rule(...) */ null;
  // TODO add properties to the entity

  group(Rule, () {
    // int id
    test('to test the property `id`', () async {
      // TODO
    });

    // RuleKind kind
    test('to test the property `kind`', () async {
      // TODO
    });

    // For a rule agnts suggested: the ticket whose feedback taught it
    // String sourceTicket
    test('to test the property `sourceTicket`', () async {
      // TODO
    });

    // For a rule agnts learned: what kind of lesson it is
    // String tag
    test('to test the property `tag`', () async {
      // TODO
    });

    // For a rule agnts suggested: which feedback shows it
    // String reason
    test('to test the property `reason`', () async {
      // TODO
    });

    // Absent for a global rule
    // int repoId
    test('to test the property `repoId`', () async {
      // TODO
    });

    // String repoName
    test('to test the property `repoName`', () async {
      // TODO
    });

    // String title
    test('to test the property `title`', () async {
      // TODO
    });

    // The rule as written
    // String body
    test('to test the property `body`', () async {
      // TODO
    });

    // bool enabled
    test('to test the property `enabled`', () async {
      // TODO
    });

    // RuleStatus status
    test('to test the property `status`', () async {
      // TODO
    });

    // What Claude will do because of the rule
    // String interpretation
    test('to test the property `interpretation`', () async {
      // TODO
    });

    // The rule rewritten with what the answers settled; empty when used as written
    // String clarified
    test('to test the property `clarified`', () async {
      // TODO
    });

    // What tickets are given
    // String text
    test('to test the property `text`', () async {
      // TODO
    });

    // List<RuleQuestion> questions
    test('to test the property `questions`', () async {
      // TODO
    });

    // Question rounds so far
    // int rounds
    test('to test the property `rounds`', () async {
      // TODO
    });

    // Why the last review failed
    // String error
    test('to test the property `error`', () async {
      // TODO
    });

    // RuleEnforce enforce
    test('to test the property `enforce`', () async {
      // TODO
    });

    // prompt: in every prompt; skill: a skill Claude loads when its description matches the work
    // String delivery
    test('to test the property `delivery`', () async {
      // TODO
    });

    // When the rule applies, for its skill
    // String skillDescription
    test('to test the property `skillDescription`', () async {
      // TODO
    });

    // Where it came from: empty (a person), reflect, run, promoted or pack:<language>
    // String source_
    test('to test the property `source_`', () async {
      // TODO
    });

    // For a learned suggestion: 0.3 to 0.9, earned each time it is seen again
    // num confidence
    test('to test the property `confidence`', () async {
      // TODO
    });

    // How many times a learned suggestion was seen
    // int evidence
    test('to test the property `evidence`', () async {
      // TODO
    });

    // DateTime lastSeen
    test('to test the property `lastSeen`', () async {
      // TODO
    });

    // A learned suggestion with too little evidence to show yet
    // bool watching
    test('to test the property `watching`', () async {
      // TODO
    });

    // DateTime analyzedAt
    test('to test the property `analyzedAt`', () async {
      // TODO
    });

    // DateTime createdAt
    test('to test the property `createdAt`', () async {
      // TODO
    });

    // DateTime updatedAt
    test('to test the property `updatedAt`', () async {
      // TODO
    });

  });
}
