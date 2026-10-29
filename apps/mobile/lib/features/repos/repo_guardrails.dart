import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:agnts_api/agnts_api.dart';

import '../../core/api.dart';
import '../../core/data.dart';
import '../../l10n/app_localizations.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import '../../widgets/ui.dart';

final _packsProvider = FutureProvider.autoDispose.family<List<StarterPack>, int>((ref, id) async {
  return (await requireApi(ref).getRulesApi().listStarterPacks(id: id)).data ?? const [];
});

/// One per-file check being edited.
class CheckRow {
  CheckRow({this.name = '', this.globs = '', this.cmd = '', this.every = 0});
  CheckRow.of(EditCheck c) : this(name: c.name, globs: c.globs.join(', '), cmd: c.cmd, every: c.every ?? 0);
  String name;
  String globs;
  String cmd;
  int every;
}

/// The guardrails form, as GuardrailsTab.vue keeps it.
class HarnessForm {
  HarnessForm.of(RepoHarness h)
    : profile = h.guardProfile?.name == 'empty' || h.guardProfile == null ? '' : h.guardProfile!.name,
      secretAllow = [...?h.secretAllow],
      ownChecks = h.editChecks != null,
      checks = [for (final c in h.editChecks ?? const <EditCheck>[]) CheckRow.of(c)],
      editChecksOff = h.editChecksOff ?? false,
      coverage = h.coverage?.enabled ?? false,
      coverageCmd = h.coverage?.command ?? '',
      coverageReport = h.coverage?.report ?? '',
      threshold = h.coverage?.threshold ?? 0,
      acceptance = h.acceptance ?? false;

  String profile; // '', minimal, standard, strict
  List<String> secretAllow;
  bool ownChecks;
  List<CheckRow> checks;
  bool editChecksOff;
  bool coverage;
  String coverageCmd;
  String coverageReport;
  int threshold;
  bool acceptance;

  /// The request body: without own checks, editChecks is left out (null)
  /// so agnts derives them from the toolchains.
  RepoHarnessInput body() => RepoHarnessInput(
    guardProfile: switch (profile) {
      'minimal' => RepoHarnessInputGuardProfileEnum.minimal,
      'standard' => RepoHarnessInputGuardProfileEnum.standard,
      'strict' => RepoHarnessInputGuardProfileEnum.strict,
      _ => RepoHarnessInputGuardProfileEnum.empty,
    },
    secretAllow: secretAllow,
    editChecks: ownChecks
        ? [
            for (final c in checks)
              EditCheck(
                name: c.name.trim(),
                globs: c.globs.split(',').map((g) => g.trim()).where((g) => g.isNotEmpty).toList(),
                cmd: c.cmd.trim(),
                every: c.every,
              ),
          ]
        : null,
    editChecksOff: editChecksOff,
    coverage: CoverageConfig(enabled: coverage, command: coverageCmd.trim(), report: coverageReport.trim(), threshold: threshold),
    acceptance: acceptance,
  );
}

/// The repository's guardrails (GuardrailsTab.vue): what the scan of its
/// agent files found, what agnts-guard enforces while Claude works here,
/// per-file checks, coverage of changed lines, the acceptance check, and
/// starter rules for its languages.
class RepoGuardrailsTab extends ConsumerStatefulWidget {
  const RepoGuardrailsTab({super.key, required this.repo, required this.onSaved});
  final Repository repo;
  final ValueChanged<Repository> onSaved;

  @override
  ConsumerState<RepoGuardrailsTab> createState() => _RepoGuardrailsTabState();
}

class _RepoGuardrailsTabState extends ConsumerState<RepoGuardrailsTab> {
  late HarnessForm _f;
  late String _saved;
  bool _saving = false;
  bool _offered = false;
  // Rebuilt with the form so text fields pick up a reset (a save, a new repo).
  int _gen = 0;

  @override
  void initState() {
    super.initState();
    _f = HarnessForm.of(_harness);
    _saved = _fingerprint();
  }

  RepoHarness get _harness => widget.repo.harness ?? RepoHarness();

  String _fingerprint() => _f.body().toJson().toString();
  bool get _dirty => _fingerprint() != _saved;

  @override
  void didUpdateWidget(RepoGuardrailsTab old) {
    super.didUpdateWidget(old);
    if (old.repo.harness != widget.repo.harness && !_dirty) _reset();
  }

  void _reset() {
    _f = HarnessForm.of(_harness);
    _saved = _fingerprint();
    _gen++;
  }

  void _edit(void Function() f) => setState(f);

  Future<void> _save() async {
    final l = AppLocalizations.of(context);
    setState(() => _saving = true);
    try {
      final r = (await ref.read(apiProvider)!.getReposApi().saveRepoHarness(id: widget.repo.id, repoHarnessInput: _f.body())).data!;
      if (!mounted) return;
      setState(() {
        _f = HarnessForm.of(r.harness ?? RepoHarness());
        _saved = _fingerprint();
        _gen++;
      });
      widget.onSaved(r);
      showSnack(context, l.harnessRepoSaved);
    } catch (e) {
      if (mounted) showSnack(context, errorMessage(e, l.commonError));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _offer(String pack) async {
    final l = AppLocalizations.of(context);
    try {
      final rs =
          (await ref
                  .read(apiProvider)!
                  .getRulesApi()
                  .offerStarterRules(
                    id: widget.repo.id,
                    offerStarterRulesRequest: OfferStarterRulesRequest(pack: pack),
                  ))
              .data;
      ref.invalidate(_packsProvider(widget.repo.id));
      if (!mounted) return;
      setState(() => _offered = true);
      showSnack(context, l.harnessRepoStarterAdded(rs?.length ?? 0));
    } catch (e) {
      if (mounted) showSnack(context, errorMessage(e, l.commonError));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final h = _harness;
    final canEdit = ref.watch(canEditProvider) && !_saving;
    final hint = TextStyle(fontSize: 13, color: c.ink3);
    final lbl = TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: c.ink);
    final f = _f;

    Widget toggle(String label, String help, bool value, ValueChanged<bool>? onChanged) => SwitchListTile.adaptive(
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: lbl),
      subtitle: Text(help, style: hint),
      value: value,
      onChanged: canEdit ? onChanged : null,
    );
    Widget text(
      String label,
      String? help,
      String value,
      ValueChanged<String> onChanged, {
      String? placeholder,
      bool mono = true,
      int lines = 1,
      Object? id,
    }) => Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: lbl),
          if (help != null)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(help, style: hint),
            ),
          const SizedBox(height: 6),
          TextFormField(
            key: ValueKey('$_gen/$label/$id'),
            initialValue: value,
            enabled: canEdit,
            minLines: lines,
            maxLines: lines == 1 ? 1 : lines + 3,
            autocorrect: false,
            style: TextStyle(fontFamily: mono ? AgntsFonts.mono : null, fontSize: 13),
            decoration: InputDecoration(hintText: placeholder),
            onChanged: (v) => _edit(() => onChanged(v)),
          ),
        ],
      ),
    );
    Widget title(String t, String sub) => Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t,
            style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700, color: c.ink),
          ),
          const SizedBox(height: 2),
          Text(sub, style: hint),
        ],
      ),
    );

    final derived = h.derivedEditChecks ?? const <EditCheck>[];
    final hasPreview = (widget.repo.preview?.command.trim() ?? '').isNotEmpty;
    final scan = h.agentConfig;
    final serious = scan?.findings.where((x) => x.severity != AgentConfigFindingSeverityEnum.info).toList() ?? const [];
    final info = scan?.findings.where((x) => x.severity == AgentConfigFindingSeverityEnum.info).toList() ?? const [];
    final packs = ref.watch(_packsProvider(widget.repo.id));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // What the scan of the agent files found.
          HCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l.harnessRepoAgentTitle, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(l.harnessRepoAgentSub, style: hint),
                const SizedBox(height: 10),
                if (scan == null)
                  Text(l.harnessRepoAgentNotScanned, style: hint)
                else ...[
                  if (serious.isNotEmpty)
                    HelpBox(
                      l.harnessRepoAgentWarn(serious.length),
                      tone: Tone.warn,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final x in serious)
                            _Finding(x, tone: x.severity == AgentConfigFindingSeverityEnum.high ? Tone.bad : Tone.warn),
                        ],
                      ),
                    )
                  else if (info.isEmpty)
                    Text(l.harnessRepoAgentNothing, style: hint),
                  if (info.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(l.harnessRepoAgentInfo, style: lbl),
                    for (final x in info) _Finding(x, tone: Tone.gray),
                  ],
                  const SizedBox(height: 8),
                  Text(l.harnessRepoAgentScanned(_ago(l, scan.scannedAt)), style: hint),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          HCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l.harnessRepoTitle, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(l.harnessRepoSub, style: hint),
                const SizedBox(height: 12),
                Text(l.harnessRepoProfile, style: lbl),
                const SizedBox(height: 8),
                Segmented<String>(
                  full: true,
                  options: [
                    ('', l.harnessRepoProfile_),
                    ('minimal', l.harnessRepoProfile_minimal),
                    ('standard', l.harnessRepoProfile_standard),
                    ('strict', l.harnessRepoProfile_strict),
                  ],
                  value: f.profile,
                  onChanged: (v) => canEdit ? _edit(() => f.profile = v) : null,
                ),
                const SizedBox(height: 6),
                Text(switch (f.profile) {
                  'minimal' => l.harnessRepoProfileHelp_minimal,
                  'standard' => l.harnessRepoProfileHelp_standard,
                  'strict' => l.harnessRepoProfileHelp_strict,
                  _ => l.harnessRepoProfileHelp_,
                }, style: hint),
                text(
                  l.harnessRepoSecretAllow,
                  '${l.harnessRepoSecretAllowHelp} ${l.mrepodetailOnePerLine}',
                  f.secretAllow.join('\n'),
                  (v) => f.secretAllow = v.split('\n').map((s) => s.trim()).where((s) => s.isNotEmpty).toList(),
                  placeholder: 'docs/examples/**',
                  lines: 2,
                ),

                title(l.harnessRepoChecksTitle, l.harnessRepoChecksSub),
                toggle(l.harnessRepoChecksOff, l.harnessRepoChecksOffHelp, f.editChecksOff, (v) => _edit(() => f.editChecksOff = v)),
                if (!f.editChecksOff) ...[
                  toggle(
                    l.harnessRepoOwnChecks,
                    l.harnessRepoOwnChecksHelp,
                    f.ownChecks,
                    (v) => _edit(() {
                      f.ownChecks = v;
                      if (v && f.checks.isEmpty) f.checks = [for (final x in derived) CheckRow.of(x)];
                      _gen++;
                    }),
                  ),
                  if (!f.ownChecks) ...[
                    Text(l.harnessRepoDerivedTitle, style: lbl),
                    const SizedBox(height: 4),
                    if (derived.isEmpty) Text(l.harnessRepoDerivedNone, style: hint) else for (final x in derived) _DerivedCheck(x),
                  ] else ...[
                    for (final (i, ch) in f.checks.indexed)
                      Container(
                        margin: const EdgeInsets.only(top: 10),
                        padding: const EdgeInsets.fromLTRB(12, 2, 12, 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: c.line2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Expanded(child: text(l.harnessRepoCheckName, null, ch.name, (v) => ch.name = v, mono: false, id: i)),
                                IconButton(
                                  tooltip: l.harnessRepoRemoveCheck(ch.name.isEmpty ? '${i + 1}' : ch.name),
                                  onPressed: canEdit
                                      ? () => _edit(() {
                                          f.checks.removeAt(i);
                                          _gen++;
                                        })
                                      : null,
                                  icon: HIcon('close', size: 18, color: c.ink3),
                                ),
                              ],
                            ),
                            text(l.harnessRepoCheckGlobs, null, ch.globs, (v) => ch.globs = v, placeholder: '**/*.go', id: i),
                            text(l.harnessRepoCheckCmd, l.harnessRepoCheckCmdHelp('{file}', '{dir}'), ch.cmd, (v) => ch.cmd = v, id: i),
                            const SizedBox(height: 10),
                            Text(l.harnessRepoCheckEvery, style: lbl),
                            const SizedBox(height: 6),
                            NumberStepper(
                              value: ch.every,
                              min: 0,
                              max: 3600,
                              step: 30,
                              enabled: canEdit,
                              onChanged: (v) => _edit(() => ch.every = v),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: OutlinedButton.icon(
                        onPressed: canEdit ? () => _edit(() => f.checks.add(CheckRow())) : null,
                        icon: HIcon('plus', size: 16, color: c.ink2),
                        label: Text(l.harnessRepoAddCheck),
                      ),
                    ),
                  ],
                ],

                title(l.harnessRepoCoverageTitle, l.harnessRepoCoverageSub),
                toggle(l.harnessRepoCoverage, l.harnessRepoCoverageHelp, f.coverage, (v) => _edit(() => f.coverage = v)),
                if (f.coverage) ...[
                  Text(l.harnessRepoThreshold, style: lbl),
                  Text(l.harnessRepoThresholdHelp, style: hint),
                  const SizedBox(height: 6),
                  NumberStepper(
                    value: f.threshold,
                    min: 0,
                    max: 100,
                    step: 5,
                    enabled: canEdit,
                    format: (n) => '$n%',
                    onChanged: (v) => _edit(() => f.threshold = v),
                  ),
                  text(
                    l.harnessRepoCoverageCmd,
                    (h.derivedCoverage?.command ?? '').isNotEmpty ? l.harnessRepoCoverageCmdHelp : l.harnessRepoCoverageNoDerived,
                    f.coverageCmd,
                    (v) => f.coverageCmd = v,
                    placeholder: h.derivedCoverage?.command,
                  ),
                  text(
                    l.harnessRepoCoverageReport,
                    l.harnessRepoCoverageReportHelp,
                    f.coverageReport,
                    (v) => f.coverageReport = v,
                    placeholder: h.derivedCoverage?.report,
                  ),
                ],
                const SizedBox(height: 8),
                toggle(
                  l.harnessRepoAcceptance,
                  hasPreview ? l.harnessRepoAcceptanceHelp : l.harnessRepoAcceptanceNoPreview,
                  f.acceptance,
                  !hasPreview && !f.acceptance ? null : (v) => _edit(() => f.acceptance = v),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: FilledButton(onPressed: canEdit && _dirty ? _save : null, child: Text(l.harnessRepoSave)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Starter rules for the repository's languages.
          HCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l.harnessRepoStarterTitle, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(l.harnessRepoStarterSub, style: hint),
                const SizedBox(height: 10),
                ...switch (packs) {
                  AsyncData(:final value) when value.isEmpty => [Text(l.harnessRepoStarterNone, style: hint)],
                  AsyncData(:final value) => [
                    for (final p in value)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(p.name, style: lbl),
                                  Text(l.harnessRepoStarterRules(p.rules), style: hint),
                                ],
                              ),
                            ),
                            if (p.offered)
                              ToneBadge(l.harnessRepoStarterOffered, Tone.gray, small: true)
                            else
                              OutlinedButton(
                                onPressed: ref.watch(canEditProvider) ? () => _offer(p.pack) : null,
                                child: Text(l.harnessRepoStarterOffer(p.rules)),
                              ),
                          ],
                        ),
                      ),
                    if (_offered || value.any((p) => p.offered))
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(onPressed: () => context.push('/rules'), child: Text(l.harnessRepoStarterOpenRules)),
                      ),
                  ],
                  AsyncError() => [Text(l.commonError, style: TextStyle(color: c.badInk))],
                  _ => [const LinearProgressIndicator()],
                },
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A finding of the agent-file scan: its kind, where, and the text.
class _Finding extends StatelessWidget {
  const _Finding(this.f, {required this.tone});
  final AgentConfigFinding f;
  final Tone tone;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final kind = switch (f.kind) {
      AgentConfigFindingKindEnum.hiddenUnicode => l.harnessRepoKind_hidden_unicode,
      AgentConfigFindingKindEnum.agentInstruction => l.harnessRepoKind_agent_instruction,
      AgentConfigFindingKindEnum.exfiltration => l.harnessRepoKind_exfiltration,
      AgentConfigFindingKindEnum.encodedBlob => l.harnessRepoKind_encoded_blob,
      AgentConfigFindingKindEnum.hooks => l.harnessRepoKind_hooks,
      AgentConfigFindingKindEnum.mcpServer => l.harnessRepoKind_mcp_server,
    };
    final where = f.line != null ? '${f.path}:${f.line}' : f.path;
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Wrap(
        spacing: 6,
        runSpacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          ToneBadge(kind, tone, small: true),
          Text(
            where,
            style: TextStyle(fontFamily: AgntsFonts.mono, fontSize: 12, color: c.ink2),
          ),
          Text(f.text, style: TextStyle(fontSize: 13, color: c.ink)),
        ],
      ),
    );
  }
}

class _DerivedCheck extends StatelessWidget {
  const _DerivedCheck(this.x);
  final EditCheck x;

  @override
  Widget build(BuildContext context) {
    final c = Agnts.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: x.name,
                  style: TextStyle(fontWeight: FontWeight.w700, color: c.ink),
                ),
                TextSpan(
                  text: '  ${x.globs.join(', ')}',
                  style: TextStyle(fontFamily: AgntsFonts.mono, fontSize: 12, color: c.ink2),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(color: c.graySoft, borderRadius: BorderRadius.circular(8)),
            child: SelectableText(
              x.cmd,
              style: TextStyle(fontFamily: AgntsFonts.mono, fontSize: 12, color: c.ink),
            ),
          ),
        ],
      ),
    );
  }
}

/// − value + buttons for a whole number within [min]..[max].
class NumberStepper extends StatelessWidget {
  const NumberStepper({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.step,
    required this.onChanged,
    this.enabled = true,
    this.format,
  });
  final int value;
  final int min;
  final int max;
  final int step;
  final bool enabled;
  final ValueChanged<int> onChanged;
  final String Function(int)? format;

  @override
  Widget build(BuildContext context) {
    final c = Agnts.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton.outlined(
          onPressed: enabled && value > min ? () => onChanged((value - step).clamp(min, max)) : null,
          icon: const Icon(Icons.remove_rounded, size: 18),
        ),
        SizedBox(
          width: 64,
          child: Text(
            format?.call(value) ?? '$value',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: c.ink),
          ),
        ),
        IconButton.outlined(
          onPressed: enabled && value < max ? () => onChanged((value + step).clamp(min, max)) : null,
          icon: const Icon(Icons.add_rounded, size: 18),
        ),
      ],
    );
  }
}

String _ago(AppLocalizations l, DateTime at) {
  final d = DateTime.now().difference(at);
  return d.inMinutes < 1 ? l.mmoreJustNow : l.mmoreAgo(shortDuration(d));
}
