import 'package:test/test.dart';
import 'package:agnts_api/agnts_api.dart';

// tests for SkillStat
void main() {
  final SkillStat? instance = /* SkillStat(...) */ null;
  // TODO add properties to the entity

  group(SkillStat, () {
    // A method skill (agnts-method-…); empty for the tickets whose coding runs had no method skills
    // String skill
    test('to test the property `skill`', () async {
      // TODO
    });

    // Tickets with a coding run that had the skill
    // int tickets
    test('to test the property `tickets`', () async {
      // TODO
    });

    // Of those, tickets where Claude loaded it
    // int loaded
    test('to test the property `loaded`', () async {
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

    // Done, of the tickets where Claude loaded it
    // int loadedDone
    test('to test the property `loadedDone`', () async {
      // TODO
    });

    // Done first try, of the tickets where Claude loaded it
    // int loadedFirstTry
    test('to test the property `loadedFirstTry`', () async {
      // TODO
    });

    // Review findings the method skills target: architecture and maintainability, or any on a migration file
    // int findings
    test('to test the property `findings`', () async {
      // TODO
    });

    // Average tokens of a done ticket, all stages
    // num tokens
    test('to test the property `tokens`', () async {
      // TODO
    });

  });
}
