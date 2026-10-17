import 'package:agnts_api/agnts_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api.dart';
import '../../l10n/app_localizations.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import '../../widgets/ui.dart';

/// Adds a rule ([rule] null) or edits one; [presetRepo] presets the scope.
/// Saving queues Claude's review. Returns the saved rule.
Future<Rule?> showRuleSheet(BuildContext context, {Rule? rule, required List<Repository> repos, int? presetRepo}) {
  return showModalBottomSheet<Rule>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.92),
    builder: (_) => RuleSheet(rule: rule, repos: repos, presetRepo: presetRepo),
  );
}

/// A labelled form field with an optional help line.
class FormField2 extends StatelessWidget {
  const FormField2({super.key, required this.label, required this.child, this.help});
  final String label;
  final Widget child;
  final String? help;

  @override
  Widget build(BuildContext context) {
    final c = Agnts.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(label, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: c.ink2)),
        const SizedBox(height: 6),
        child,
        if (help != null) Padding(padding: const EdgeInsets.only(top: 6), child: Text(help!, style: TextStyle(fontSize: 13, color: c.ink3, height: 1.35))),
      ]),
    );
  }
}

/// A bottom sheet's header: title, subtitle and a close button (.sh-h).
class SheetHead extends StatelessWidget {
  const SheetHead({super.key, required this.title, this.sub});
  final String title;
  final String? sub;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            if (sub != null) ...[const SizedBox(height: 2), Text(sub!, style: TextStyle(color: c.ink3, fontSize: 14))],
          ]),
        ),
        const SizedBox(width: 12),
        RoundIconButton('close', tooltip: l.navClose, onTap: () => Navigator.pop(context)),
      ]),
    );
  }
}

class RuleSheet extends ConsumerStatefulWidget {
  const RuleSheet({super.key, this.rule, required this.repos, this.presetRepo});
  final Rule? rule;
  final List<Repository> repos;
  final int? presetRepo;

  @override
  ConsumerState<RuleSheet> createState() => _RuleSheetState();
}

class _RuleSheetState extends ConsumerState<RuleSheet> {
  late final Rule? r = widget.rule;
  late final _title = TextEditingController(text: r?.title ?? '');
  late final _body = TextEditingController(text: r?.body ?? '');
  late final _paths = TextEditingController(text: (r?.enforce?.paths ?? const []).join('\n'));
  late final _pattern = TextEditingController(text: r?.enforce?.pattern ?? '');
  late final _message = TextEditingController(text: r?.enforce?.message ?? '');
  late int? _repoId = r != null ? r!.repoId : widget.presetRepo;
  late bool _enabled = r?.enabled ?? true;
  late RuleKind _kind = r?.kind ?? RuleKind.rule;
  late RuleDeliveryEnum _delivery = r?.delivery ?? RuleDeliveryEnum.prompt;
  late bool _enforceOn = r?.enforce != null;
  late RuleEnforceOn_Enum _on = r?.enforce?.on_ ?? RuleEnforceOn_Enum.file;
  late RuleEnforceActionEnum _action = r?.enforce?.action ?? RuleEnforceActionEnum.block;
  TryEnforceResult? _tried;
  String? _error;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    for (final t in [_title, _body]) {
      t.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    for (final t in [_title, _body, _paths, _pattern, _message]) {
      t.dispose();
    }
    super.dispose();
  }

  RulesApi get _api => ref.read(apiProvider)!.getRulesApi();

  /// Editing what the rule says (or where) sends it back to review.
  bool get _rereview =>
      r != null && (r!.title != _title.text.trim() || r!.body != _body.text.trim() || r!.repoId != _repoId || r!.kind != _kind);

  /// The enforcement as the API takes it: empty fields left out.
  RuleEnforce _enforce() {
    final paths = _paths.text.split(RegExp(r'[\n,]')).map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    return RuleEnforce(
      on_: _on,
      action: _action,
      paths: _on != RuleEnforceOn_Enum.bash && paths.isNotEmpty ? paths : null,
      pattern: _pattern.text.trim().isEmpty ? null : _pattern.text.trim(),
      message: _message.text.trim().isEmpty ? null : _message.text.trim(),
    );
  }

  Future<void> _try() async {
    final l = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      final res = await _api.tryEnforce(tryEnforceInput: TryEnforceInput(enforce: _enforce(), repoId: _repoId));
      setState(() {
        _tried = res.data;
        _error = null;
      });
    } catch (e) {
      setState(() => _error = errorMessage(e, l.commonError));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _save() async {
    final l = AppLocalizations.of(context);
    if (_title.text.trim().isEmpty || _body.text.trim().isEmpty) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final enforce = _enforceOn && _kind == RuleKind.rule;
    final input = RuleInput(
      title: _title.text.trim(),
      body: _body.text.trim(),
      repoId: _repoId,
      enabled: _enabled,
      kind: _kind,
      delivery: _delivery == RuleDeliveryEnum.skill ? RuleInputDeliveryEnum.skill : RuleInputDeliveryEnum.prompt,
      enforce: enforce ? _enforce() : null,
      removeEnforce: !enforce && r?.enforce != null ? true : null,
    );
    try {
      final res = r == null ? await _api.createRule(ruleInput: input) : await _api.updateRule(id: r!.id, ruleInput: input);
      final saved = res.data;
      if (!mounted) return;
      showSnack(context, saved?.status == RuleStatus.pending ? l.rulesSavedReview : l.rulesSaved);
      Navigator.pop(context, saved);
    } catch (e) {
      if (mounted) setState(() => _error = errorMessage(e, l.commonError));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final hint = TextStyle(fontSize: 13, color: c.ink3, height: 1.35);
    final repos = widget.repos.where((x) => x.archivedAt == null || x.id == r?.repoId).toList();
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        SheetHead(title: r?.title ?? l.rulesAdd, sub: l.rulesDrawerSub),
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              FormField2(
                label: l.rulesRuleTitle,
                child: TextField(controller: _title, maxLength: 200, decoration: InputDecoration(hintText: l.rulesTitlePlaceholder, counterText: '')),
              ),
              FormField2(
                label: l.rulesKind,
                help: _kind == RuleKind.context ? l.rulesKindContextHelp : l.rulesKindRuleHelp,
                child: Segmented<RuleKind>(
                  full: true,
                  options: [
                    (RuleKind.rule, l.rulesKindRule),
                    (RuleKind.context, l.rulesKindContext),
                    if (_kind == RuleKind.tip) (RuleKind.tip, l.harnessRulesBadgeTip),
                  ],
                  value: _kind,
                  onChanged: (v) => setState(() => _kind = v),
                ),
              ),
              FormField2(
                label: l.rulesScope,
                help: l.rulesScopeHelp,
                child: DropdownButtonFormField<int?>(
                  initialValue: _repoId,
                  isExpanded: true,
                  items: [
                    DropdownMenuItem<int?>(value: null, child: Text('${l.rulesGlobal} · ${l.rulesGlobalHint}')),
                    for (final x in repos) DropdownMenuItem<int?>(value: x.id, child: Text(x.name)),
                  ],
                  onChanged: (v) => setState(() => _repoId = v),
                ),
              ),
              FormField2(
                label: l.rulesBody,
                help: l.rulesBodyHelp,
                child: TextField(
                  controller: _body,
                  minLines: 5,
                  maxLines: 12,
                  maxLength: 10000,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(hintText: l.rulesBodyPlaceholder, counterText: ''),
                ),
              ),
              FormField2(
                label: l.harnessRulesDelivery,
                help: _delivery == RuleDeliveryEnum.skill ? l.harnessRulesDeliveryHelp_skill : l.harnessRulesDeliveryHelp_prompt,
                child: Segmented<RuleDeliveryEnum>(
                  full: true,
                  options: [(RuleDeliveryEnum.prompt, l.harnessRulesDelivery_prompt), (RuleDeliveryEnum.skill, l.harnessRulesDelivery_skill)],
                  value: _delivery,
                  onChanged: (v) => setState(() => _delivery = v),
                ),
              ),
              if (_kind == RuleKind.rule) _enforceBox(l, c, hint),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: Text(l.rulesEnabled),
                value: _enabled,
                onChanged: (v) => setState(() => _enabled = v),
              ),
              if (_rereview) Padding(padding: const EdgeInsets.only(top: 6), child: HelpBox(l.rulesRereviewHelp)),
              if (_error != null) Padding(padding: const EdgeInsets.only(top: 10), child: HelpBox(_error!, tone: Tone.bad)),
              const SizedBox(height: 14),
              FilledButton(
                onPressed: _busy || _title.text.trim().isEmpty || _body.text.trim().isEmpty ? null : _save,
                child: Text(r != null ? l.formSave : l.rulesAddSubmit),
              ),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _enforceBox(AppLocalizations l, Agnts c, TextStyle hint) {
    final onHelp = switch (_on) {
      RuleEnforceOn_Enum.file => l.harnessRulesOnHelp_file,
      RuleEnforceOn_Enum.bash => l.harnessRulesOnHelp_bash,
      RuleEnforceOn_Enum.diff => l.harnessRulesOnHelp_diff,
    };
    final t = _tried;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(border: Border.all(color: c.line2), borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Expanded(child: Text(l.harnessRulesEnforce, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: c.ink2))),
          Switch.adaptive(value: _enforceOn, onChanged: (v) => setState(() => _enforceOn = v)),
        ]),
        Text(l.harnessRulesEnforceHelp, style: hint),
        if (_enforceOn) ...[
          const SizedBox(height: 12),
          FormField2(
            label: l.harnessRulesOn,
            help: onHelp,
            child: Segmented<RuleEnforceOn_Enum>(
              full: true,
              options: [
                (RuleEnforceOn_Enum.file, l.harnessRulesOn_file),
                (RuleEnforceOn_Enum.bash, l.harnessRulesOn_bash),
                (RuleEnforceOn_Enum.diff, l.harnessRulesOn_diff),
              ],
              value: _on,
              onChanged: (v) => setState(() => _on = v),
            ),
          ),
          if (_on != RuleEnforceOn_Enum.bash)
            FormField2(
              label: l.harnessRulesPaths,
              child: TextField(
                controller: _paths,
                minLines: 1,
                maxLines: 5,
                style: const TextStyle(fontFamily: AgntsFonts.mono, fontSize: 13),
                decoration: InputDecoration(hintText: l.harnessRulesPathsPlaceholder),
              ),
            ),
          FormField2(
            label: l.harnessRulesPattern,
            child: TextField(
              controller: _pattern,
              maxLength: 500,
              style: const TextStyle(fontFamily: AgntsFonts.mono, fontSize: 13),
              decoration: const InputDecoration(hintText: r'(?i)\bselect\b.+\bfrom\b', counterText: ''),
            ),
          ),
          FormField2(
            label: l.harnessRulesAction,
            child: Segmented<RuleEnforceActionEnum>(
              full: true,
              options: [(RuleEnforceActionEnum.block, l.harnessRulesAction_block), (RuleEnforceActionEnum.warn, l.harnessRulesAction_warn)],
              value: _action,
              onChanged: (v) => setState(() => _action = v),
            ),
          ),
          FormField2(
            label: l.harnessRulesMessage,
            child: TextField(controller: _message, maxLength: 1000, decoration: InputDecoration(hintText: l.harnessRulesMessagePlaceholder, counterText: '')),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton(onPressed: _busy ? null : _try, child: Text(_busy ? l.harnessRulesTrying : l.harnessRulesTry)),
          ),
          if (t != null) ...[
            const SizedBox(height: 10),
            HelpBox(
              t.note ?? '${l.harnessRulesTryChecked(t.checked)} ${t.hits.isEmpty ? l.harnessRulesTryNone : l.harnessRulesTryHits(t.tickets.length)}',
              child: t.note != null || t.hits.isEmpty
                  ? null
                  : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      for (final h in t.hits)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text.rich(TextSpan(children: [
                            TextSpan(text: '${h.ticket} ', style: const TextStyle(fontWeight: FontWeight.w700)),
                            TextSpan(
                              text: h.line != null ? '${h.path}:${h.line} ' : '${h.path} ',
                              style: const TextStyle(fontFamily: AgntsFonts.mono, fontSize: 12),
                            ),
                            TextSpan(text: h.text),
                          ])),
                        ),
                    ]),
            ),
          ],
        ],
      ]),
    );
  }
}
