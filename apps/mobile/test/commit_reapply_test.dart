import 'package:agnts_api/agnts_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agnts_mobile/features/tickets/commit_reapply.dart';
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
      home: Scaffold(body: child),
    );

final _ticket = Ticket(
  key: 'SHOP-3',
  source_: TicketSource_Enum.local,
  title: 'Login',
  description: '',
  priority: 'medium',
  state: TicketState.waitingForReview,
  revision: 1,
  turns: 3,
  branch: 'agnts/SHOP-3',
  prUrl: '',
  kind: TicketKind.code,
  kindAuto: false,
  skipChecks: false,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);

final _changes = [
  CommitReapplyChange(repoId: 1, repoName: 'api', sha: 'bbbbbbb2222', from: 'feat(auth): my own words', to: '[AMANAT-2677] feat: Login', suggested: false),
  CommitReapplyChange(repoId: 1, repoName: 'api', sha: 'aaaaaaa1111', from: 'SHOP-3: Login', to: '[AMANAT-2677] feat: Login', suggested: true),
];

void main() {
  testWidgets('previews with the number, ticks the suggested changes, applies only the ticked ones', (tester) async {
    final calls = <(String?, bool, List<String>?)>[];
    await tester.pumpWidget(_app(CommitReapplySheet(
      ticket: _ticket,
      call: (number, dryRun, only) async {
        calls.add((number, dryRun, only));
        return _changes;
      },
    )));
    expect(find.text('Ticket number for {number}'), findsOneWidget);
    await tester.enterText(find.byType(TextField), ' AMANAT-2677 ');
    await tester.tap(find.text('Preview'));
    await tester.pumpAndSettle();
    expect(calls.single, ('AMANAT-2677', true, null));

    final boxes = tester.widgetList<CheckboxListTile>(find.byType(CheckboxListTile)).toList();
    expect([for (final b in boxes) b.value], [false, true]); // the hand-written one is not ticked
    expect(find.textContaining('written by hand'), findsOneWidget);
    expect(find.text('Apply 1 change'), findsOneWidget);

    await tester.tap(find.text('Apply 1 change'));
    await tester.pumpAndSettle();
    expect(calls.last.$1, 'AMANAT-2677');
    expect(calls.last.$2, isFalse);
    expect(calls.last.$3, ['aaaaaaa1111']);
  });

  testWidgets('unticking every change leaves nothing to apply', (tester) async {
    await tester.pumpWidget(_app(CommitReapplySheet(ticket: _ticket, call: (_, _, _) async => _changes)));
    await tester.tap(find.text('Preview'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('SHOP-3: Login'));
    await tester.pump();
    final apply = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(apply.onPressed, isNull);
  });

  testWidgets('says so when the messages already match', (tester) async {
    await tester.pumpWidget(_app(CommitReapplySheet(ticket: _ticket, call: (_, _, _) async => const [])));
    await tester.tap(find.text('Preview'));
    await tester.pumpAndSettle();
    expect(find.text('The messages already match the format.'), findsOneWidget);
    expect(find.byType(FilledButton), findsNothing);
  });
}
