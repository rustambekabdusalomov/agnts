import 'package:agnts_api/agnts_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agnts_mobile/features/tickets/relations.dart';
import 'package:agnts_mobile/l10n/app_localizations.dart';
import 'package:agnts_mobile/theme.dart';

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

Relation _r(int id, RelationDirectionEnum dir, RelationStatusEnum status, {String basis = '', List<String> files = const [], String reason = ''}) => Relation(
      id: id,
      type: dir == RelationDirectionEnum.conflicts ? RelationType.conflicts : RelationType.dependsOn,
      direction: dir,
      source_: basis.isEmpty ? RelationSource_Enum.agnts : RelationSource_Enum.rule,
      status: status,
      confidence: 0.4,
      reason: reason,
      basis: basis,
      files: files,
      other: RelatedTicket(key: 'PAY-$id', title: 'Other $id', state: TicketState.waitingForReview, landed: false),
      createdAt: DateTime(2026),
    );

TicketDetail _detail(List<Relation> items) => TicketDetail(
      ticket: Ticket(
        key: 'PAY-1',
        source_: TicketSource_Enum.jira,
        title: 'Show tasks',
        description: '',
        priority: 'high',
        state: TicketState.coding,
        revision: 0,
        turns: 0,
        branch: '',
        prUrl: '',
        kind: TicketKind.code,
        kindAuto: false,
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      ),
      questions: const [],
      attachments: const [],
      analysis: Analysis(summary: 's', plan: const [], footprint: Footprint(files: const ['server/tasks.go'], migrations: true)),
      relations: Relations(items: items, blockedBy: const []),
    );

void main() {
  testWidgets('proposals offer accept and dismiss; active ones say why', (tester) async {
    final d = _detail([
      _r(2, RelationDirectionEnum.waitsFor, RelationStatusEnum.proposed, reason: 'uses the endpoint PAY-2 adds'),
      _r(3, RelationDirectionEnum.conflicts, RelationStatusEnum.active, basis: 'files', files: const ['main.go']),
    ]);
    expect(RelationsFold.shows(d), isTrue);
    await tester.pumpWidget(_app(RelationsFold(d)));
    await tester.pumpAndSettle();
    expect(find.text('Suggested by agnts'), findsOneWidget); // open: a proposal waits
    expect(find.text('uses the endpoint PAY-2 adds'), findsOneWidget);
    expect(find.text('Accept'), findsOneWidget);
    expect(find.text('Dismiss'), findsOneWidget);
    expect(find.text('Both change main.go'), findsOneWidget);
    expect(find.text('Run anyway'), findsOneWidget);
    expect(find.text('server/tasks.go'), findsOneWidget);
    expect(find.text('Adds a database migration'), findsOneWidget);
  });

  testWidgets('the waiting block lists the blockers', (tester) async {
    await tester.pumpWidget(_app(WaitingBlock([
      Blocker(key: 'PAY-7', title: 'Add the endpoint', state: TicketState.done, type: RelationType.dependsOn),
    ])));
    expect(find.text('PAY-7'), findsOneWidget);
    expect(find.text('Waits for'), findsOneWidget);
  });
}
