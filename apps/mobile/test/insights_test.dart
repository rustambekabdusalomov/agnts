import 'package:agnts_api/agnts_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agnts_mobile/core/data.dart';
import 'package:agnts_mobile/features/analytics/analytics_screen.dart';
import 'package:agnts_mobile/features/analytics/export.dart';
import 'package:agnts_mobile/features/usage/usage_screen.dart';
import 'package:agnts_mobile/l10n/app_localizations.dart';
import 'package:agnts_mobile/theme.dart';

TokenSpend _sp(int input, int output, double cost) =>
    TokenSpend(input: input, output: output, cacheRead: 0, cacheWrite: 0, total: input + output, costUsd: cost);

void main() {
  test('CSV quotes fields with commas, quotes and new lines', () {
    expect(csvField('plain'), 'plain');
    expect(csvField('a,b'), '"a,b"');
    expect(csvField('say "hi"'), '"say ""hi"""');
    expect(csvField(null), '');
    expect(toCsv([
      ['a', 1],
      ['b,c', null],
    ]), 'a,1\n"b,c",\n');
  });

  test('delivery and learning CSVs have one row per day or item', () {
    expect(deliveryCsv(null), isNull);
    final d = AnalyticsDelivery(
      days: 7,
      current: _period(),
      previous: _period(),
      perDay: [DeliveryDay(date: DateTime(2026, 10, 1), merged: 2, closed: 1, pushedMin: 12.34)],
      slowest: const [],
      stale: const [],
      unanswered: 0,
    );
    final rows = deliveryCsv(d)!;
    expect(rows.first.first, 'date');
    expect(rows[1], ['2026-10-01', 2, 1, '12.3', null]);

    final l = AnalyticsLearning(
      days: 30,
      current: _learning(),
      previous: _learning(),
      lessons: const [],
      followUpTypes: [FollowUpCount(name: 'gap', suggested: 3, accepted: 1, dismissed: 1)],
      followUpSources: [FollowUpCount(name: 'review', suggested: 3, accepted: 1, dismissed: 1)],
      reviewers: const [],
    );
    expect(learningCsv(l)!.skip(1).map((r) => r.first), ['follow_up_type', 'follow_up_source']);
  });

  testWidgets('usage screen shows the limits and the tickets by spend', (tester) async {
    final usage = Usage(
      fiveHour: UsageWindow(utilization: 0.85),
      sevenDay: UsageWindow(utilization: 0.3),
      status: UsageStatusEnum.allowedWarning,
      paused: false,
      pauseAbove: 90,
      refreshing: false,
    );
    final spend = TicketSpendList(days: 30, total: _sp(10000, 5000, 2.0), tickets: [
      TicketSpendRow(
        key: 'TASK-7',
        title: 'Speed up the importer',
        kind: TicketKind.code,
        state: TicketState.done,
        calls: 3,
        topStage: TicketSpendRowTopStageEnum.coding,
        spend: _sp(8000, 4000, 1.5),
      ),
    ]);
    await tester.pumpWidget(ProviderScope(
      overrides: [
        usageProvider.overrideWith((_) async => usage),
        settingsProvider.overrideWith((_) => Future<Settings>.error('offline')),
        ticketSpendProvider.overrideWith((_, _) async => spend),
      ],
      child: MaterialApp(
        theme: agntsTheme(Brightness.light),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: const UsageScreen(),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('85%'), findsOneWidget);
    expect(find.text('Close to the limit'), findsOneWidget);
    expect(find.textContaining('above 80%'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Speed up the importer'), 200);
    expect(find.text('TASK-7'), findsOneWidget);
    expect(find.text('75%'), findsOneWidget); // $1.50 of $2.00
  });
}

DeliveryPeriod _period() => DeliveryPeriod(
      opened: 0,
      merged: 0,
      closed: 0,
      mergeMin: Spread(),
      pushed: 0,
      pushedMin: Spread(),
      mergedTickets: 0,
      mergedMin: Spread(),
      questions: 0,
      askedTickets: 0,
      analyzedTickets: 0,
      answerMin: Spread(),
    );

LearningPeriod _learning() => LearningPeriod(
      lessons: 0,
      lessonsLearned: 0,
      rulesSuggested: 0,
      rulesAdopted: 0,
      rulesManual: 0,
      reflections: 0,
      reflectionRules: 0,
      followUps: 0,
      accepted: 0,
      dismissed: 0,
      reviewerNotes: 0,
    );
