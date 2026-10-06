import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agnts_api/agnts_api.dart';

import 'package:agnts_mobile/features/tickets/kinds.dart';
import 'package:agnts_mobile/l10n/app_localizations.dart';
import 'package:agnts_mobile/theme.dart';
import 'package:agnts_mobile/widgets/common.dart';
import 'package:agnts_mobile/widgets/ui.dart';

Widget _app(Widget child) => ProviderScope(
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

Ticket _ticket(TicketKind kind, {bool auto = false, TicketState state = TicketState.new_}) => Ticket(
      key: 'PAY-1',
      source_: TicketSource_Enum.jira,
      title: 't',
      description: '',
      priority: 'medium',
      state: state,
      revision: 0,
      turns: 0,
      branch: '',
      prUrl: '',
      kind: kind,
      kindAuto: auto,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );

void main() {
  testWidgets('a report reads Writing, a change reads Coding', (tester) async {
    await tester.pumpWidget(_app(const Column(children: [
      StateBadge(TicketState.coding, kind: TicketKind.plan),
      StateBadge(TicketState.coding, kind: TicketKind.code),
      StateBadge(TicketState.done, kind: TicketKind.bug),
    ])));
    await tester.pumpAndSettle();
    expect(find.text('Writing'), findsOneWidget);
    expect(find.text('Coding'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);
  });

  testWidgets('the kind chip marks a kind agnts picked', (tester) async {
    await tester.pumpWidget(_app(Column(children: [
      KindChip(_ticket(TicketKind.analysis)),
      KindChip(_ticket(TicketKind.code, auto: true)),
    ])));
    await tester.pumpAndSettle();
    expect(find.text('Analysis'), findsOneWidget);
    expect(find.text('Code · Auto'), findsOneWidget);
  });

  testWidgets('reports render as Markdown', (tester) async {
    await tester.pumpWidget(_app(const ReportMarkdown('# Token expiry\n\n- Add an expiry\n\n`refund.go:42`')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Token expiry'), findsOneWidget);
    expect(find.textContaining('Add an expiry'), findsOneWidget);
    expect(find.textContaining('#'), findsNothing);
  });

  test('the kind can change only before work it would waste', () {
    expect(kindEditable(_ticket(TicketKind.plan)), isTrue);
    expect(kindEditable(_ticket(TicketKind.plan, state: TicketState.waitingForReview)), isFalse);
    expect(isReportKind(TicketKind.bug), isTrue);
    expect(isReportKind(TicketKind.test), isFalse);
  });
}
