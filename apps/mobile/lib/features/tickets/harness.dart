import 'package:flutter/material.dart';
import 'package:agnts_api/agnts_api.dart';

import '../../l10n/app_localizations.dart';
import '../../theme.dart';
import '../../widgets/ui.dart';

/// Lines flagged as possible credentials: approving needs a person to say
/// they are not real ones, once per revision.
int secretFlagCount(Result? r) =>
    (r?.redFlags ?? const <RedFlag>[]).where((f) => f.kind == RedFlagKindEnum.secret || f.kind == RedFlagKindEnum.envFile).length;

/// The order the server lists kinds in (domain.FlagKinds): the most serious first.
const _flagOrder = [
  RedFlagKindEnum.secret,
  RedFlagKindEnum.envFile,
  RedFlagKindEnum.skippedTest,
  RedFlagKindEnum.removedAssertion,
  RedFlagKindEnum.deletedTest,
  RedFlagKindEnum.silencedLint,
  RedFlagKindEnum.checkConfig,
  RedFlagKindEnum.swallowedError,
  RedFlagKindEnum.ruleViolation,
  RedFlagKindEnum.debugLeftover,
  RedFlagKindEnum.todo,
  RedFlagKindEnum.newDependency,
];

String redFlagLabel(AppLocalizations l, RedFlagKindEnum k) => switch (k) {
      RedFlagKindEnum.secret => l.harnessTicketFlag_secret,
      RedFlagKindEnum.envFile => l.harnessTicketFlag_env_file,
      RedFlagKindEnum.debugLeftover => l.harnessTicketFlag_debug_leftover,
      RedFlagKindEnum.checkConfig => l.harnessTicketFlag_check_config,
      RedFlagKindEnum.ruleViolation => l.harnessTicketFlag_rule_violation,
      RedFlagKindEnum.skippedTest => l.redFlagsKind_skipped_test,
      RedFlagKindEnum.removedAssertion => l.redFlagsKind_removed_assertion,
      RedFlagKindEnum.deletedTest => l.redFlagsKind_deleted_test,
      RedFlagKindEnum.silencedLint => l.redFlagsKind_silenced_lint,
      RedFlagKindEnum.swallowedError => l.redFlagsKind_swallowed_error,
      RedFlagKindEnum.todo => l.redFlagsKind_todo,
      RedFlagKindEnum.newDependency => l.redFlagsKind_new_dependency,
    };

Widget _h3(Agnts c, String text) => Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 6),
      child: Text(text, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: c.ink3)),
    );

Widget _bullet(Agnts c, String text, {Color? color}) => Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('•  ', style: TextStyle(color: c.ink3)),
        Expanded(child: Text(text, style: TextStyle(fontSize: 14, height: 1.4, color: color ?? c.ink))),
      ]),
    );

/// What agnts's scan of the change flagged: skipped tests, removed
/// assertions, silenced linters, possible secrets and the like.
class RedFlagsList extends StatelessWidget {
  const RedFlagsList(this.flags, {super.key});
  final List<RedFlag> flags;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final sorted = [...flags]..sort((a, b) => _flagOrder.indexOf(a.kind).compareTo(_flagOrder.indexOf(b.kind)));
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _h3(c, l.redFlagsTitle(flags.length)),
      Text(l.redFlagsSub, style: TextStyle(fontSize: 13, height: 1.4, color: c.ink3)),
      const SizedBox(height: 8),
      for (final f in sorted)
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(border: Border.all(color: c.line), borderRadius: BorderRadius.circular(12)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Wrap(spacing: 8, runSpacing: 4, crossAxisAlignment: WrapCrossAlignment.center, children: [
              ToneBadge(redFlagLabel(l, f.kind), f.kind == RedFlagKindEnum.secret || f.kind == RedFlagKindEnum.envFile ? Tone.bad : Tone.warn, small: true),
              Text(f.line == null ? f.path : '${f.path}:${f.line}', style: TextStyle(fontFamily: AgntsFonts.mono, fontSize: 12, color: c.ink2)),
            ]),
            if (f.text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: SelectableText(f.text, style: TextStyle(fontFamily: AgntsFonts.mono, fontSize: 12, color: c.ink)),
              ),
          ]),
        ),
    ]);
  }
}

/// What the harness checked in a result: the proof that a bug fix fixes the
/// bug, and how much of the change the tests ran. Advice for the reviewer.
class HarnessChecks extends StatelessWidget {
  const HarnessChecks(this.result, {super.key});
  final Result? result;

  static bool shows(Result? r) => r?.proof != null || r?.coverage != null;

  @override
  Widget build(BuildContext context) {
    final proof = result?.proof;
    final coverage = result?.coverage;
    if (proof == null && coverage == null) return const SizedBox.shrink();
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      if (proof != null) _proof(context, proof),
      if (coverage != null) _coverage(context, coverage),
    ]);
  }

  Widget _card(Agnts c, List<Widget> children) => Container(
        margin: const EdgeInsets.only(top: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(border: Border.all(color: c.line), borderRadius: BorderRadius.circular(12)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
      );

  Widget _head(Agnts c, String title, Widget? badge) => Row(children: [
        Expanded(child: Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: c.ink))),
        ?badge,
      ]);

  Widget _proof(BuildContext context, Proof p) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final (label, help, tone) = switch (p.status) {
      ProofStatusEnum.proven => (l.harnessTicketProof_proven, l.harnessTicketProofHelp_proven, Tone.ok),
      ProofStatusEnum.notReproduced => (l.harnessTicketProof_not_reproduced, l.harnessTicketProofHelp_not_reproduced, Tone.warn),
      ProofStatusEnum.stillFailing => (l.harnessTicketProof_still_failing, l.harnessTicketProofHelp_still_failing, Tone.bad),
      ProofStatusEnum.inconclusive => (l.harnessTicketProof_inconclusive, l.harnessTicketProofHelp_inconclusive, Tone.gray),
      ProofStatusEnum.noTest => (l.harnessTicketProof_no_test, l.harnessTicketProofHelp_no_test, Tone.gray),
      ProofStatusEnum.error => (l.harnessTicketProof_error, l.harnessTicketProofHelp_error, Tone.warn),
    };
    final mono = TextStyle(fontFamily: AgntsFonts.mono, fontSize: 12, color: c.ink2);
    return _card(c, [
      _head(c, l.harnessTicketProofTitle, ToneBadge(label, tone, small: true)),
      const SizedBox(height: 4),
      Text(help, style: TextStyle(fontSize: 13, height: 1.4, color: c.ink3)),
      if ((p.why ?? '').isNotEmpty) Padding(padding: const EdgeInsets.only(top: 6), child: Text(p.why!, style: const TextStyle(fontSize: 14, height: 1.4))),
      if ((p.base_ ?? '').isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(l.harnessTicketProofBase(p.base_!.length > 10 ? p.base_!.substring(0, 10) : p.base_!), style: mono),
        ),
      for (final x in p.tests)
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text.rich(TextSpan(children: [
              TextSpan(text: x.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
              TextSpan(text: '  ${x.file}', style: mono),
            ])),
            Padding(padding: const EdgeInsets.only(top: 4), child: SelectableText('\$ ${x.command}', style: mono)),
            _RunOutput(title: l.harnessTicketProofBefore('${x.before.exit}'), output: x.before.output),
            _RunOutput(title: l.harnessTicketProofAfter('${x.after.exit}'), output: x.after.output),
          ]),
        ),
    ]);
  }

  Widget _coverage(BuildContext context, Coverage cov) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final below = cov.threshold != null && cov.threshold! > 0 && cov.total > 0 && cov.percent < cov.threshold!;
    final pct = _pct(cov.percent);
    String ranges(List<CoverageFilesInnerUncoveredInner> us) => us.map((u) => u.from == u.to ? '${u.from}' : '${u.from}–${u.to}').join(', ');
    final error = cov.error;
    return _card(c, [
      _head(c, l.harnessTicketCoverageTitle,
          (error == null || error.isEmpty) && cov.total > 0 ? ToneBadge('$pct%', below ? Tone.warn : Tone.ok, small: true) : null),
      const SizedBox(height: 6),
      if (error != null && error.isNotEmpty)
        HelpBox(l.harnessTicketCoverageError(error), tone: Tone.warn)
      else if (cov.total == 0)
        Text(l.harnessTicketCoverageNone, style: TextStyle(fontSize: 13, color: c.ink3))
      else ...[
        Text(l.harnessTicketCoveragePct(pct, '${cov.covered}', '${cov.total}'), style: const TextStyle(fontSize: 14, height: 1.4)),
        if (below)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(l.harnessTicketCoverageBelow('${cov.threshold}'), style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: c.warnInk)),
          ),
        for (final f in cov.files.where((x) => x.uncovered.isNotEmpty))
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text.rich(TextSpan(children: [
                TextSpan(text: f.path, style: TextStyle(fontFamily: AgntsFonts.mono, fontSize: 12, color: c.ink)),
                TextSpan(text: '  ${f.covered}/${f.total}', style: TextStyle(fontSize: 12.5, color: c.ink3)),
              ])),
              Text(l.harnessTicketCoverageLines(ranges(f.uncovered)), style: TextStyle(fontSize: 12.5, color: c.ink3)),
            ]),
          ),
      ],
    ]);
  }
}

/// A percent as the server sends it (may carry decimals), without a trailing ".0".
String _pct(num v) => v == v.roundToDouble() ? '${v.round()}' : v.toStringAsFixed(1);

/// A proof run's output, folded.
class _RunOutput extends StatelessWidget {
  const _RunOutput({required this.title, required this.output});
  final String title;
  final String output;

  @override
  Widget build(BuildContext context) {
    final c = Agnts.of(context);
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: EdgeInsets.zero,
        dense: true,
        title: Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: c.ink2)),
        children: [
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxHeight: 260),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: c.graySoft, borderRadius: BorderRadius.circular(8)),
            child: SingleChildScrollView(
              child: SelectableText(output.isEmpty ? '—' : output, style: TextStyle(fontFamily: AgntsFonts.mono, fontSize: 11.5, color: c.ink)),
            ),
          ),
        ],
      ),
    );
  }
}

/// The decisions behind a ticket's work: the approach the analysis chose and
/// the ones it rejected, what it leaves out, how the change ships, and where
/// the coding run departed from all that.
class DesignRecord extends StatelessWidget {
  const DesignRecord({super.key, this.analysis, this.deviations, this.tr = _same});
  final Analysis? analysis;
  final List<String>? deviations;

  /// The ticket's translation (texts as written when none).
  final String Function(String) tr;

  static String _same(String s) => s;

  static bool shows(Analysis? a, [List<String>? deviations]) {
    if ((deviations ?? const []).isNotEmpty) return true;
    if (a == null) return false;
    final s = a.ship;
    return (a.approaches ?? const []).any((x) => x.chosen) ||
        (a.outOfScope ?? const []).isNotEmpty ||
        (s != null && [s.migrations, s.compatibility, s.rollout, s.rollback].any((x) => (x ?? '').isNotEmpty)) ||
        a.defect == true ||
        (a.acceptance ?? const []).isNotEmpty ||
        a.secondOpinion != null;
  }

  @override
  Widget build(BuildContext context) {
    if (!shows(analysis, deviations)) return const SizedBox.shrink();
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final a = analysis;
    final approaches = a?.approaches ?? const <Approach>[];
    final chosen = approaches.where((x) => x.chosen).firstOrNull;
    final others = approaches.where((x) => !x.chosen).toList();
    final scope = a?.outOfScope ?? const <String>[];
    final s = a?.ship;
    final ship = s == null
        ? const <(String, String)>[]
        : [
            if ((s.migrations ?? '').isNotEmpty) (l.designShip_migrations, s.migrations!),
            if ((s.compatibility ?? '').isNotEmpty) (l.designShip_compatibility, s.compatibility!),
            if ((s.rollout ?? '').isNotEmpty) (l.designShip_rollout, s.rollout!),
            if ((s.rollback ?? '').isNotEmpty) (l.designShip_rollback, s.rollback!),
          ];
    final criteria = a?.acceptance ?? const <AnalysisAcceptanceInner>[];
    final second = a?.secondOpinion;
    final devs = deviations ?? const <String>[];
    final hint = TextStyle(fontSize: 13.5, height: 1.4, color: c.ink3);
    final body = const TextStyle(fontSize: 14.5, height: 1.45);

    Widget approach(Approach x, {bool alt = false}) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text.rich(TextSpan(style: body, children: [
            TextSpan(text: tr(x.title), style: const TextStyle(fontWeight: FontWeight.w700)),
            TextSpan(text: ' — ${tr(x.sketch)}'),
          ])),
          if ((x.why ?? '').isNotEmpty)
            Padding(padding: const EdgeInsets.only(top: 4), child: Text(alt ? '${l.designWhyNot}: ${tr(x.why!)}' : tr(x.why!), style: hint)),
          if (!alt && (x.fit ?? '').isNotEmpty) Padding(padding: const EdgeInsets.only(top: 4), child: Text('${l.designFit}: ${tr(x.fit!)}', style: hint)),
          if (alt) ...[
            for (final p in x.pros) Text('+ ${tr(p)}', style: TextStyle(fontSize: 13.5, height: 1.4, color: c.okInk)),
            for (final p in x.cons) Text('− ${tr(p)}', style: TextStyle(fontSize: 13.5, height: 1.4, color: c.badInk)),
          ],
        ]);

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (a?.defect == true) Padding(padding: const EdgeInsets.only(top: 12), child: ToneBadge(l.harnessTicketDefect, Tone.warn, small: true)),
      if (chosen != null) ...[
        _h3(c, l.designApproach),
        approach(chosen),
        if (others.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Fold(
              title: l.designAlternatives(others.length),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                for (final (i, x) in others.indexed) Padding(padding: EdgeInsets.only(top: i == 0 ? 0 : 10), child: approach(x, alt: true)),
              ]),
            ),
          ),
      ],
      if (scope.isNotEmpty) ...[_h3(c, l.designOutOfScope), for (final x in scope) _bullet(c, tr(x))],
      if (ship.isNotEmpty) ...[
        _h3(c, l.designShipping),
        for (final (k, v) in ship)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(k, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: c.ink2)),
              Text(tr(v), style: body),
            ]),
          ),
      ],
      if (criteria.isNotEmpty) ...[
        _h3(c, l.harnessTicketAcceptanceTitle),
        for (final x in criteria)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Wrap(spacing: 6, runSpacing: 4, crossAxisAlignment: WrapCrossAlignment.center, children: [
              Text(x.id, style: TextStyle(fontFamily: AgntsFonts.mono, fontSize: 12, color: c.ink3)),
              Text(tr(x.criterion), style: body),
              ToneBadge(_checkLabel(l, x.check), Tone.gray, small: true),
            ]),
          ),
      ],
      if (second != null) ...[
        _h3(c, l.harnessTicketSecondTitle),
        if ((second.error ?? '').isNotEmpty)
          Text(l.harnessTicketSecondError(second.error!), style: hint)
        else ...[
          Wrap(spacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
            ToneBadge(second.agrees ? l.harnessTicketSecondAgrees : l.harnessTicketSecondConcerns, second.agrees ? Tone.ok : Tone.warn, small: true),
            Text(l.harnessTicketSecondBy(second.model), style: hint),
          ]),
          if (second.summary.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 6), child: Text(tr(second.summary), style: body)),
          for (final x in second.concerns ?? const <String>[]) _bullet(c, tr(x)),
          if ((second.alternative ?? '').isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text.rich(TextSpan(style: body, children: [
                TextSpan(text: '${l.harnessTicketSecondAlternative}: ', style: const TextStyle(fontWeight: FontWeight.w700)),
                TextSpan(text: tr(second.alternative!)),
              ])),
            ),
        ],
      ],
      if (devs.isNotEmpty) ...[
        _h3(c, l.designDeviations),
        HelpBox(devs.map((d) => '•  ${tr(d)}').join('\n'), tone: Tone.warn),
      ],
    ]);
  }
}

String _checkLabel(AppLocalizations l, AnalysisAcceptanceInnerCheckEnum k) => switch (k) {
      AnalysisAcceptanceInnerCheckEnum.ui => l.harnessTicketCheck_ui,
      AnalysisAcceptanceInnerCheckEnum.api => l.harnessTicketCheck_api,
      AnalysisAcceptanceInnerCheckEnum.test => l.harnessTicketCheck_test,
      AnalysisAcceptanceInnerCheckEnum.manual => l.harnessTicketCheck_manual,
    };
