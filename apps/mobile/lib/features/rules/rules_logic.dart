import 'package:agnts_api/agnts_api.dart';

import '../../l10n/app_localizations.dart';
import '../../widgets/ui.dart' show Tone;

/// Tone per review status, as in the admin panel.
Tone ruleTone(RuleStatus s) => switch (s) {
  RuleStatus.pending || RuleStatus.analyzing || RuleStatus.suggested => Tone.info,
  RuleStatus.questions => Tone.warn,
  RuleStatus.ready => Tone.ok,
  RuleStatus.failed => Tone.bad,
};

String ruleStatusLabel(AppLocalizations l, RuleStatus s) => switch (s) {
  RuleStatus.pending => l.rulesStatus_pending,
  RuleStatus.analyzing => l.rulesStatus_analyzing,
  RuleStatus.questions => l.rulesStatus_questions,
  RuleStatus.ready => l.rulesStatus_ready,
  RuleStatus.failed => l.rulesStatus_failed,
  RuleStatus.suggested => l.rulesStatus_suggested,
};

/// Starter pack names, for "Starter: Go" (pack:go).
const _packName = {
  'go': 'Go',
  'typescript': 'TypeScript',
  'python': 'Python',
  'java': 'Java',
  'kotlin': 'Kotlin',
  'rust': 'Rust',
  'ruby': 'Ruby',
  'php': 'PHP',
  'csharp': 'C#',
  'swift': 'Swift',
  'dart': 'Dart',
};

/// The harness badges of a rule: how it is enforced and delivered, its kind
/// when a tip, where it came from, and what a learned one has earned.
List<(String, Tone)> ruleBadges(AppLocalizations l, Rule r) {
  final out = <(String, Tone)>[];
  final e = r.enforce;
  if (e != null) {
    out.add(e.action == RuleEnforceActionEnum.block ? (l.harnessRulesBadgeBlock, Tone.bad) : (l.harnessRulesBadgeWarn, Tone.warn));
  }
  if (r.delivery == RuleDeliveryEnum.skill) out.add((l.harnessRulesBadgeSkill, Tone.info));
  if (r.kind == RuleKind.tip) out.add((l.harnessRulesBadgeTip, Tone.gray));
  final src = r.source_ ?? '';
  if (src.startsWith('pack:')) {
    final id = src.substring(5);
    out.add((l.harnessRulesSourceStarter(_packName[id] ?? id), Tone.gray));
  } else if (src == 'reflect') {
    out.add((l.harnessRulesSource_reflect, Tone.gray));
  } else if (src == 'run') {
    out.add((l.harnessRulesSource_run, Tone.gray));
  } else if (src == 'promoted') {
    out.add((l.harnessRulesSource_promoted, Tone.gray));
  }
  final suggested = r.status == RuleStatus.suggested;
  if (suggested && (r.confidence ?? 0) > 0) out.add((l.harnessRulesConfidence('${((r.confidence ?? 0) * 100).round()}'), Tone.info));
  if (suggested && (r.evidence ?? 0) > 1) out.add((l.harnessRulesSeen(r.evidence!), Tone.gray));
  return out;
}

/// The scope filter: every rule (null), global ones (0), or a repository's.
bool ruleInScope(Rule r, int? scope) => scope == null || (scope == 0 ? r.repoId == null : r.repoId == scope);

/// The rules to list: not the watched ones, in scope, matching the search;
/// rules that need you first, then failed reviews, then the rest in order.
List<Rule> visibleRules(List<Rule> all, {int? scope, String query = ''}) {
  int rank(Rule r) => switch (r.status) {
    RuleStatus.questions => 0,
    RuleStatus.suggested => 1,
    RuleStatus.failed => 2,
    _ => 3,
  };
  final q = query.trim().toLowerCase();
  final rows = [
    for (final (i, r) in all.indexed)
      if (r.watching != true &&
          ruleInScope(r, scope) &&
          (q.isEmpty || [r.title, r.body, r.repoName ?? ''].any((s) => s.toLowerCase().contains(q))))
        (i, r),
  ];
  rows.sort((a, b) {
    final d = rank(a.$2) - rank(b.$2);
    return d != 0 ? d : a.$1 - b.$1;
  });
  return [for (final (_, r) in rows) r];
}

/// Whether a review is queued or running, so the list should refresh itself.
bool anyReviewing(List<Rule> rules) => rules.any((r) => r.status == RuleStatus.pending || r.status == RuleStatus.analyzing);
