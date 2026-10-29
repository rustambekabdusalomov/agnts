import 'package:agnts_api/agnts_api.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agnts_mobile/features/rules/rules_logic.dart';
import 'package:agnts_mobile/l10n/app_localizations_en.dart';
import 'package:agnts_mobile/widgets/ui.dart' show Tone;

Rule _rule(
  int id,
  RuleStatus status, {
  int? repoId,
  String title = 'r',
  bool? watching,
  RuleEnforce? enforce,
  String? source,
  num? confidence,
  int? evidence,
}) => Rule(
  id: id,
  kind: RuleKind.rule,
  repoId: repoId,
  repoName: repoId == null ? null : 'api',
  title: title,
  body: 'body $id',
  enabled: true,
  status: status,
  interpretation: '',
  clarified: '',
  text: '',
  questions: const [],
  rounds: 0,
  error: '',
  enforce: enforce,
  source_: source,
  confidence: confidence,
  evidence: evidence,
  watching: watching,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);

void main() {
  final l = AppLocalizationsEn();

  test('lists questions first, then suggestions, failures and the rest in order', () {
    final all = [
      _rule(1, RuleStatus.ready),
      _rule(2, RuleStatus.failed),
      _rule(3, RuleStatus.questions),
      _rule(4, RuleStatus.suggested),
      _rule(5, RuleStatus.ready),
      _rule(6, RuleStatus.suggested, watching: true),
    ];
    expect(visibleRules(all).map((r) => r.id), [3, 4, 2, 1, 5]);
  });

  test('filters by scope and search', () {
    final all = [_rule(1, RuleStatus.ready, title: 'Tests'), _rule(2, RuleStatus.ready, repoId: 7, title: 'Logging')];
    expect(visibleRules(all, scope: 0).map((r) => r.id), [1]);
    expect(visibleRules(all, scope: 7).map((r) => r.id), [2]);
    expect(visibleRules(all, query: 'LOG').map((r) => r.id), [2]);
    expect(visibleRules(all, query: 'api').map((r) => r.id), [2]);
  });

  test('badges say how a rule is enforced and where it came from', () {
    final r = _rule(
      1,
      RuleStatus.suggested,
      enforce: RuleEnforce(on_: RuleEnforceOn_Enum.file, action: RuleEnforceActionEnum.block),
      source: 'pack:go',
      confidence: 0.84,
      evidence: 3,
    );
    expect(ruleBadges(l, r), [
      (l.harnessRulesBadgeBlock, Tone.bad),
      ('Starter: Go', Tone.gray),
      ('Confidence 84%', Tone.info),
      ('Seen 3 times', Tone.gray),
    ]);
  });

  test('a queued or running review keeps the list refreshing', () {
    expect(anyReviewing([_rule(1, RuleStatus.ready)]), isFalse);
    expect(anyReviewing([_rule(1, RuleStatus.analyzing)]), isTrue);
  });
}
