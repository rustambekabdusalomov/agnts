import 'package:test/test.dart';
import 'package:agnts_api/agnts_api.dart';


/// tests for RulesApi
void main() {
  final instance = AgntsApi().getRulesApi();

  group(RulesApi, () {
    // Apply a rule as written, skipping its open questions or a failed review
    //
    //Future<Rule> acceptRule(int id) async
    test('test acceptRule', () async {
      // TODO
    });

    // Answer every open question of a rule; Claude then reviews it again
    //
    //Future<Rule> answerRule(int id, RuleAnswers ruleAnswers) async
    test('test answerRule', () async {
      // TODO
    });

    // Add a rule; Claude reviews it before tickets follow it
    //
    //Future<Rule> createRule(RuleInput ruleInput) async
    test('test createRule', () async {
      // TODO
    });

    //Future deleteRule(int id) async
    test('test deleteRule', () async {
      // TODO
    });

    //Future<Rule> getRule(int id) async
    test('test getRule', () async {
      // TODO
    });

    // Every rule, global ones first, then by repository
    //
    //Future<List<Rule>> listRules() async
    test('test listRules', () async {
      // TODO
    });

    // Starter rule packs that fit the repository's toolchains
    //
    //Future<List<StarterPack>> listStarterPacks(int id) async
    test('test listStarterPacks', () async {
      // TODO
    });

    // Add a starter pack's rules to the repository as suggestions
    //
    // Nothing applies until someone adopts a suggestion (with a review or as written). Rules whose title the repository already has are skipped.
    //
    //Future<List<Rule>> offerStarterRules(int id, OfferStarterRulesRequest offerStarterRulesRequest) async
    test('test offerStarterRules', () async {
      // TODO
    });

    // Have Claude review a rule again, keeping its answers
    //
    //Future<Rule> reviewRule(int id) async
    test('test reviewRule', () async {
      // TODO
    });

    // Check an enforcement against agnts's last changes before turning it on
    //
    //Future<TryEnforceResult> tryEnforce(TryEnforceInput tryEnforceInput) async
    test('test tryEnforce', () async {
      // TODO
    });

    // Edit a rule. Changing its text or repository starts a new review; turning it on or off does not.
    //
    //Future<Rule> updateRule(int id, RuleInput ruleInput) async
    test('test updateRule', () async {
      // TODO
    });

  });
}
