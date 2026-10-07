import 'package:agnts_api/agnts_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agnts_mobile/core/data.dart';
import 'package:agnts_mobile/features/tickets/follow_ups.dart';
import 'package:agnts_mobile/l10n/app_localizations.dart';
import 'package:agnts_mobile/theme.dart';

Widget _app(Widget child) => ProviderScope(
      overrides: [integrationsProvider.overrideWith((ref) async => const <Integration>[])],
      child: MaterialApp(
        theme: agntsTheme(Brightness.light),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: SingleChildScrollView(child: child)),
      ),
    );

FollowUpSuggestion _s(int id, String title, {bool ready = true, FollowUpSuggestionStatusEnum status = FollowUpSuggestionStatusEnum.open}) =>
    FollowUpSuggestion(
      id: id,
      source_: ready ? FollowUpSuggestionSource_Enum.analyze : FollowUpSuggestionSource_Enum.work,
      type: ready ? FollowUpSuggestionTypeEnum.prerequisite : FollowUpSuggestionTypeEnum.unfinished,
      revision: 0,
      title: title,
      description: '',
      serves: 'Needed to finish PAY-1',
      kind: TicketKind.code,
      priority: FollowUpSuggestionPriorityEnum.high,
      status: status,
      ready: ready,
      createdAt: DateTime(2026),
    );

TicketDetail _detail(FollowUps f) => TicketDetail(
      ticket: Ticket(
        key: 'PAY-1',
        source_: TicketSource_Enum.jira,
        title: 'Fix refunds',
        description: '',
        priority: 'high',
        state: TicketState.waitingForReview,
        revision: 0,
        turns: 3,
        branch: '',
        prUrl: '',
        kind: TicketKind.code,
        kindAuto: false,
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
        suggestFollowUps: FollowUpsMode.on_,
      ),
      questions: const [],
      attachments: const [],
      followUps: f,
    );

void main() {
  testWidgets('lists suggestions; only ready ones can be picked', (tester) async {
    await tester.pumpWidget(_app(FollowUpsFold(_detail(FollowUps(
      enabled: true,
      suggestions: [
        _s(1, 'Add refund_cents'),
        _s(2, 'Test negatives', ready: false),
        _s(3, 'Old idea', status: FollowUpSuggestionStatusEnum.dismissed),
      ],
      children: [FollowUpTicket(key: 'VIS-4', title: 'Earlier', state: TicketState.new_, kind: TicketKind.code, source_: FollowUpTicketSource_Enum.local)],
    )))));
    await tester.pumpAndSettle();

    expect(find.text('Add refund_cents'), findsOneWidget);
    expect(find.text('Test negatives'), findsOneWidget);
    expect(find.text('Old idea'), findsNothing);
    expect(find.textContaining('once this ticket is done'), findsOneWidget);
    expect(find.text('VIS-4'), findsOneWidget);
    expect(find.text('1 dismissed suggestion'), findsOneWidget);

    final boxes = tester.widgetList<Checkbox>(find.byType(Checkbox)).toList();
    expect(boxes[0].onChanged, isNotNull);
    expect(boxes[1].onChanged, isNull);
    expect(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed, isNull);

    await tester.tap(find.byType(Checkbox).first);
    await tester.pumpAndSettle();
    expect(find.text('Create 1 ticket'), findsOneWidget);
    expect(find.text('Jira issue'), findsOneWidget);
    expect(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed, isNotNull);
  });

  testWidgets('says when suggestions are off', (tester) async {
    await tester.pumpWidget(_app(FollowUpsFold(_detail(FollowUps(enabled: false, suggestions: const [], children: const [])))));
    await tester.tap(find.text('Follow-up tickets'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Follow-up suggestions are off'), findsOneWidget);
  });
}
