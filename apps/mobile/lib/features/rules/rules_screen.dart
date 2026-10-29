import 'dart:async';

import 'package:agnts_api/agnts_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api.dart';
import '../../core/data.dart';
import '../../l10n/app_localizations.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import '../../widgets/ui.dart';
import 'rule_card.dart';
import 'rule_sheet.dart';
import 'rules_logic.dart';
import 'starter_rules.dart';

/// Every rule, global and per repository.
final rulesProvider = FutureProvider<List<Rule>>((ref) async {
  return (await requireApi(ref).getRulesApi().listRules()).data ?? const [];
});

/// Global and per-repository rules: what needs answers first, then
/// suggestions, failed reviews and the rest; lessons agnts only watches
/// are folded apart. Opened from More.
class RulesScreen extends ConsumerStatefulWidget {
  const RulesScreen({super.key});

  @override
  ConsumerState<RulesScreen> createState() => _RulesScreenState();
}

class _RulesScreenState extends ConsumerState<RulesScreen> {
  int? _scope; // null: all, 0: global, else a repository id
  String _query = '';
  Timer? _poll;

  @override
  void initState() {
    super.initState();
    // While a review is queued or running the list refreshes on its own.
    _poll = Timer.periodic(const Duration(seconds: 5), (_) {
      final rules = ref.read(rulesProvider).value;
      if (rules != null && anyReviewing(rules)) ref.invalidate(rulesProvider);
    });
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  Future<void> _edit(Rule? rule) async {
    final repos = ref.read(reposProvider).value ?? const <Repository>[];
    final saved = await showRuleSheet(context, rule: rule, repos: repos, presetRepo: _scope != null && _scope! > 0 ? _scope : null);
    if (saved != null) ref.invalidate(rulesProvider);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final rules = ref.watch(rulesProvider);
    final repos = ref.watch(reposProvider).value ?? const <Repository>[];
    final canEdit = ref.watch(canEditProvider);
    return Scaffold(
      backgroundColor: c.bg,
      appBar: DetailBar(backLabel: l.navBack, onBack: () => context.canPop() ? context.pop() : context.go('/more')),
      floatingActionButton: canEdit ? HFab(onTap: () => _edit(null), tooltip: l.rulesAdd) : null,
      body: AsyncBody<List<Rule>>(
        value: rules,
        onRefresh: () => ref.refresh(rulesProvider.future),
        builder: (all) {
          final rows = visibleRules(all, scope: _scope, query: _query);
          final watching = all.where((r) => r.watching == true && ruleInScope(r, _scope)).toList();
          final waiting = all.where((r) => r.status == RuleStatus.questions).length;
          final suggested = all.where((r) => r.status == RuleStatus.suggested && r.watching != true).length;
          int count(int? scope) => all.where((r) => ruleInScope(r, scope)).length;
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 96),
            children: [
              PageHeader(title: l.rulesTitle, sub: l.rulesLede),
              if (waiting > 0)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                  child: HelpBox(l.rulesWaitingHelp(waiting), tone: Tone.warn),
                ),
              if (suggested > 0)
                Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 10), child: HelpBox(l.rulesSuggestedHelp(suggested))),
              if (canEdit)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                  child: ListGroup(
                    children: [
                      ListRow(
                        leading: HIcon('learn', size: 22, color: c.primary),
                        title: l.harnessRepoStarterTitle,
                        subtitle: l.harnessRepoStarterSub,
                        onTap: () async {
                          await showStarterRulesSheet(
                            context,
                            repos: repos.where((r) => r.archivedAt == null).toList(),
                            initialRepo: _scope,
                          );
                          ref.invalidate(rulesProvider);
                        },
                      ),
                    ],
                  ),
                ),
              if (all.isNotEmpty) ...[
                ChipRow(
                  children: [
                    FilterChipH(
                      label: l.rulesTitle,
                      count: all.length,
                      selected: _scope == null,
                      onTap: () => setState(() => _scope = null),
                    ),
                    FilterChipH(label: l.rulesGlobal, count: count(0), selected: _scope == 0, onTap: () => setState(() => _scope = 0)),
                    for (final r in repos)
                      FilterChipH(label: r.name, count: count(r.id), selected: _scope == r.id, onTap: () => setState(() => _scope = r.id)),
                  ],
                ),
                const SizedBox(height: 10),
                SearchBox(hint: l.mqualitySearchRules, onChanged: (v) => setState(() => _query = v)),
              ],
              if (all.isEmpty)
                EmptyState(title: l.rulesNone)
              else if (rows.isEmpty && watching.isEmpty)
                EmptyState(title: l.rulesNoMatch)
              else
                for (final r in rows)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                    child: RuleCard(rule: r, canEdit: canEdit, onEdit: () => _edit(r)),
                  ),
              if (watching.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
                  child: Fold(
                    title: l.harnessRulesWatching('${watching.length}'),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(l.harnessRulesWatchingHelp, style: TextStyle(fontSize: 13, color: c.ink3, height: 1.4)),
                        const SizedBox(height: 10),
                        for (final r in watching)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: RuleCard(rule: r, canEdit: canEdit, onEdit: () => _edit(r)),
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
