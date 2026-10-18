import 'package:agnts_api/agnts_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:agnts_mobile/features/tickets/file_diff.dart';
import 'package:agnts_mobile/features/tickets/ticket_section.dart';
import 'package:agnts_mobile/l10n/app_localizations.dart';
import 'package:agnts_mobile/theme.dart';

Widget _app(List<Widget> children) => ProviderScope(
      child: MaterialApp(
        theme: agntsTheme(Brightness.light),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: ListView(padding: const EdgeInsets.symmetric(horizontal: 16), children: children)),
      ),
    );

String _long(String name, int n) => 'diff --git a/$name b/$name\n@@ -1,1 +1,$n @@\n${[for (var i = 0; i < n; i++) '+line $i'].join('\n')}\n';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('tapping a section\'s title closes it, and it stays closed on the next ticket', (tester) async {
    await tester.pumpWidget(_app([
      const TicketSection(id: 'notes', title: 'Notes', hint: '2', children: [Text('first note'), Text('second note')]),
    ]));
    expect(find.text('first note'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    await tester.tap(find.text('Notes'));
    await tester.pumpAndSettle();
    expect(find.text('first note'), findsNothing);
    expect(find.text('2'), findsOneWidget, reason: 'a closed section still says what is in it');
    expect((await SharedPreferences.getInstance()).getStringList('ticketSectionsClosed'), ['notes']);

    // Another ticket page (a new scope reads the saved choice).
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(_app([
      const TicketSection(id: 'notes', title: 'Notes', children: [Text('other note')]),
    ]));
    await tester.pumpAndSettle();
    expect(find.text('other note'), findsNothing);
    await tester.tap(find.text('Notes'));
    await tester.pumpAndSettle();
    expect(find.text('other note'), findsOneWidget);
  });

  testWidgets('inside the Diff section a file\'s path sticks just under the section\'s title', (tester) async {
    tester.view.physicalSize = const Size(400, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final f = FileChange(path: 'notes/a.txt', add: 80, del: 0, diff: _long('notes/a.txt', 80));
    await tester.pumpWidget(_app([
      const SizedBox(height: 100),
      TicketSection(id: 'diff', title: 'Diff', children: [FileDiff(file: f, initiallyOpen: true)]),
    ]));
    await tester.pumpAndSettle();
    final list = tester.getTopLeft(find.byType(ListView)).dy;
    await tester.drag(find.byType(ListView), const Offset(0, -600));
    await tester.pump();
    final title = tester.getRect(find.text('Diff'));
    final path = tester.getRect(find.text('notes/a.txt'));
    expect(title.top, inInclusiveRange(list, list + 30), reason: 'the section title is at the top');
    expect(path.top, greaterThan(title.bottom), reason: 'the path is under the title, not over it');
    expect(path.top, lessThan(title.bottom + 40));

    // The stuck title still closes the section.
    await tester.tap(find.text('Diff'));
    await tester.pumpAndSettle();
    expect(find.text('notes/a.txt'), findsNothing);
  });
}
