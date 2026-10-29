import 'dart:math' as math;

import 'package:agnts_api/agnts_api.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../../theme.dart';
import '../../widgets/ui.dart';

/// The tokens shown as "spent": input and output. Cache reads are cheap and
/// would dwarf them, so they are shown apart (as in the admin panel).
int ioTokens(TokenSpend? s) => s == null ? 0 : s.input + s.output;

/// 1234 → "1.2K", in the reader's locale.
String fmtTokens(int n, String locale) {
  NumberFormat f;
  try {
    f = NumberFormat.compact(locale: locale);
  } catch (_) {
    f = NumberFormat.compact();
  }
  // One decimal, like the admin panel ("1.2K", not "1.23K").
  return (f
        ..significantDigitsInUse = false
        ..maximumFractionDigits = 1)
      .format(n);
}

/// An API-price estimate in dollars; tiny non-zero amounts read "<$0.01".
String fmtUsd(double usd, String locale) {
  NumberFormat f;
  try {
    f = NumberFormat.currency(locale: locale, name: 'USD', symbol: r'$', decimalDigits: 2);
  } catch (_) {
    f = NumberFormat.currency(name: 'USD', symbol: r'$', decimalDigits: 2);
  }
  return usd > 0 && usd < 0.005 ? '<${f.format(0.01)}' : f.format(usd);
}

/// "claude-opus-5-5" or "opus" → "Opus"; anything else as given.
String modelLabel(String id) {
  final lower = id.toLowerCase();
  for (final m in const ['haiku', 'sonnet', 'opus']) {
    if (lower.contains(m)) return '${m[0].toUpperCase()}${m.substring(1)}';
  }
  return id;
}

String _stageLabel(AppLocalizations l, StageSpendStageEnum s, bool report) => switch (s) {
  StageSpendStageEnum.analyze => l.spendStageAnalyze,
  StageSpendStageEnum.coding => report ? l.spendStageWriting : l.spendStageCoding,
  StageSpendStageEnum.retry => l.spendStageRetry,
  StageSpendStageEnum.review => l.spendStageReview,
  StageSpendStageEnum.learn => l.spendStageLearn,
  StageSpendStageEnum.helper => l.spendStageHelper,
  StageSpendStageEnum.preview => l.spendStagePreview,
};

/// A ticket's token spend: totals, then a row per stage with its model.
class SpendFold extends StatelessWidget {
  const SpendFold({super.key, required this.spend, required this.stages, this.report = false});
  final TokenSpend? spend;
  final List<StageSpend> stages;
  final bool report;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final loc = Localizations.localeOf(context).toLanguageTag();
    String tok(int n) => fmtTokens(n, loc);
    final s = spend;
    final hint = TextStyle(fontSize: 13, color: c.ink3, height: 1.4);
    return Fold(
      title: l.spendTitle,
      hint: s == null ? null : tok(ioTokens(s)),
      child: s == null
          ? Text(l.spendEmpty, style: TextStyle(color: c.ink3))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.spendSub(tok(ioTokens(s)), fmtUsd(s.costUsd, loc)), style: TextStyle(fontSize: 14, color: c.ink2, height: 1.4)),
                const SizedBox(height: 10),
                Grid2(gap: 8, children: [Fact(l.spendInput, tok(s.input)), Fact(l.spendOutput, tok(s.output))]),
                const SizedBox(height: 8),
                Text(l.spendCache(tok(s.cacheRead), tok(s.cacheWrite)), style: hint),
                for (final st in stages) _StageRow(stage: st, top: stages.map((x) => ioTokens(x.spend)).fold(1, math.max), report: report),
                if (stages.any((x) => x.partial)) ...[const SizedBox(height: 8), Text(l.spendPartial, style: hint)],
                const SizedBox(height: 10),
                Text(l.spendCostNote, style: hint.copyWith(fontSize: 12.5)),
              ],
            ),
    );
  }
}

class _StageRow extends StatelessWidget {
  const _StageRow({required this.stage, required this.top, required this.report});
  final StageSpend stage;
  final int top;
  final bool report;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final loc = Localizations.localeOf(context).toLanguageTag();
    final sp = stage.spend;
    final n = ioTokens(sp);
    final cost = stage.partial && sp.costUsd == 0 ? '—' : fmtUsd(sp.costUsd, loc);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: c.line2)),
      ),
      margin: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: _stageLabel(l, stage.stage, report)),
                      TextSpan(
                        text: ' · ${modelLabel(stage.model)}',
                        style: TextStyle(color: c.ink3),
                      ),
                    ],
                  ),
                ),
              ),
              Text(
                fmtTokens(n, loc),
                style: const TextStyle(fontWeight: FontWeight.w700, fontFeatures: [FontFeature.tabularFigures()]),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Bar(value: n / top),
          const SizedBox(height: 6),
          Text(
            '${l.spendCalls(stage.calls)} · ${l.spendCache(fmtTokens(sp.cacheRead, loc), fmtTokens(sp.cacheWrite, loc))} · $cost',
            style: TextStyle(fontSize: 13, color: c.ink3, height: 1.4),
          ),
        ],
      ),
    );
  }
}
