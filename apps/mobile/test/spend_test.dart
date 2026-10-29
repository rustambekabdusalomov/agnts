import 'package:agnts_api/agnts_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agnts_mobile/features/tickets/spend.dart';
import 'package:agnts_mobile/l10n/app_localizations.dart';
import 'package:agnts_mobile/theme.dart';

Widget _app(Widget child) => MaterialApp(
  theme: agntsTheme(Brightness.light),
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: SingleChildScrollView(child: child)),
);

TokenSpend _sp(int input, int output, double cost, {int cacheRead = 0, int cacheWrite = 0}) => TokenSpend(
  input: input,
  output: output,
  cacheRead: cacheRead,
  cacheWrite: cacheWrite,
  total: input + output + cacheRead + cacheWrite,
  costUsd: cost,
);

final _stages = [
  StageSpend(
    stage: StageSpendStageEnum.analyze,
    model: 'claude-sonnet-5-5',
    calls: 1,
    turns: 5,
    partial: false,
    spend: _sp(1000, 500, 0.1, cacheRead: 20000),
  ),
  StageSpend(stage: StageSpendStageEnum.coding, model: 'claude-opus-5-5', calls: 1, turns: 12, partial: false, spend: _sp(2000, 4000, 0.5)),
  StageSpend(stage: StageSpendStageEnum.retry, model: 'opus', calls: 2, turns: 6, partial: true, spend: _sp(300, 200, 0)),
];
final _total = _sp(3300, 4700, 0.6, cacheRead: 20000);

void main() {
  test('formats tokens, cost and models', () {
    expect(fmtTokens(1234, 'en'), '1.2K');
    expect(fmtTokens(950, 'en'), '950');
    expect(fmtTokens(1250000, 'en'), '1.3M');
    expect(fmtTokens(8000, 'en'), '8K');
    expect(fmtUsd(0.5, 'en'), r'$0.50');
    expect(fmtUsd(0.001, 'en'), r'<$0.01');
    expect(ioTokens(_total), 8000);
    expect(ioTokens(null), 0);
    expect(modelLabel('claude-opus-5-5'), 'Opus');
    expect(modelLabel('custom'), 'custom');
  });

  testWidgets('a ticket without spend says nothing is recorded', (tester) async {
    await tester.pumpWidget(_app(const SpendFold(spend: null, stages: [])));
    await tester.tap(find.text('Token spend'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Nothing recorded yet'), findsOneWidget);
  });

  testWidgets('shows the total in the header and a row per stage when open', (tester) async {
    await tester.pumpWidget(_app(SpendFold(spend: _total, stages: _stages, report: true)));
    expect(find.text('8K'), findsOneWidget); // fold hint, closed
    await tester.tap(find.text('Token spend'));
    await tester.pumpAndSettle();
    expect(find.text(r'8K tokens in and out · about $0.60 at API prices'), findsOneWidget);
    expect(find.text('3.3K'), findsOneWidget);
    expect(find.text('4.7K'), findsOneWidget);
    expect(find.text('Analysis · Sonnet', findRichText: true), findsOneWidget);
    expect(find.text('Writing · Opus', findRichText: true), findsOneWidget); // coding on a report
    expect(find.textContaining('2 runs'), findsOneWidget);
    expect(find.textContaining('— '), findsNothing);
    expect(find.textContaining('· —'), findsOneWidget); // cut-off cost unknown
    expect(find.text('A run was cut off, so its cost is unknown'), findsOneWidget);
  });
}
