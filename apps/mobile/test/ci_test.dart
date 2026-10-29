import 'package:agnts_api/agnts_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agnts_mobile/features/ci/ci_sample.dart';
import 'package:agnts_mobile/features/ci/ci_screen.dart';
import 'package:agnts_mobile/l10n/app_localizations.dart';
import 'package:agnts_mobile/theme.dart';

final _now = DateTime.now();

CIFailure _f({CIStatus status = CIStatus.open, String ticketKey = '', TicketState? ticketState, int prNumber = 0}) => CIFailure(
  id: 7,
  repoId: 1,
  repo: 'shop',
  branch: 'main',
  workflow: 'CI',
  job: 'test (1.22)',
  title: 'TestCheckout: expected 3, got 2',
  class_: 'test',
  status: status,
  count: 4,
  flakyCount: 0,
  firstSeenAt: _now,
  lastSeenAt: _now,
  firstSha: 'abcdef1234567',
  lastSha: '1234567abcdef',
  occurrences: const [],
  ticketKey: ticketKey,
  ticketState: ticketState,
  prNumber: prNumber,
);

void main() {
  test('the first error block between the markers', () {
    const sample = '=== first error ===\n--- FAIL: TestCheckout\n    want 3, got 2\n\n=== end of the log ===\nok  other\nexit status 1';
    final x = sampleExcerpt(sample);
    expect(x.first, isTrue);
    expect(x.text, '--- FAIL: TestCheckout\n    want 3, got 2');
  });

  test('an excerpt cut in the middle keeps the block before the cut', () {
    const sample = '=== first error ===\nerror: boom\nmore\n…\ntail line';
    final x = sampleExcerpt(sample);
    expect(x.first, isTrue);
    expect(x.text, 'error: boom\nmore');
  });

  test('no markers: the last 40 lines', () {
    final sample = [for (var i = 1; i <= 100; i++) 'line $i'].join('\r\n');
    final x = sampleExcerpt('$sample\n');
    expect(x.first, isFalse);
    final lines = x.text.split('\n');
    expect(lines.length, 40);
    expect(lines.first, 'line 61');
    expect(lines.last, 'line 100');
  });

  test('an empty first error block falls back to the tail', () {
    final x = sampleExcerpt('=== first error ===\n\n\n=== end of the log ===\nlast');
    expect(x.first, isFalse);
    expect(x.text.endsWith('last'), isTrue);
  });

  test('Fix it only for red groups of own branches with no live ticket', () {
    expect(canFixCI(_f()), isTrue);
    expect(canFixCI(_f(status: CIStatus.regression)), isTrue);
    expect(canFixCI(_f(status: CIStatus.triage)), isFalse);
    expect(canFixCI(_f(status: CIStatus.muted)), isFalse);
    expect(canFixCI(_f(prNumber: 12)), isFalse);
    expect(canFixCI(_f(ticketKey: 'CI-1', ticketState: TicketState.coding)), isFalse);
    // A finished ticket does not block a new fix.
    expect(canFixCI(_f(ticketKey: 'CI-1', ticketState: TicketState.done)), isTrue);
    expect(shortSha('abcdef1234567'), 'abcdef1');
  });

  testWidgets('a failure card shows status, place, count and ticket', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: agntsTheme(Brightness.light),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: CIFailureCard(_f(status: CIStatus.fixing, ticketKey: 'CI-3', ticketState: TicketState.coding)),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Fixing'), findsOneWidget);
    expect(find.text('shop · main'), findsOneWidget);
    expect(find.text('×4'), findsOneWidget);
    expect(find.text('TestCheckout: expected 3, got 2'), findsOneWidget);
    expect(find.text('CI-3'), findsOneWidget);
  });
}
