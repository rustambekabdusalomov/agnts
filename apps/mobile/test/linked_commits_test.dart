import 'package:agnts_api/agnts_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agnts_mobile/features/tickets/linked_commits.dart';
import 'package:agnts_mobile/l10n/app_localizations.dart';
import 'package:agnts_mobile/theme.dart';

Widget _app(Widget child, Map<int, LinkedCommits> pages) => ProviderScope(
      overrides: [
        for (final e in pages.entries) linkedCommitsProvider(('PAY-40', e.key)).overrideWith((ref) async => e.value),
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
        home: Scaffold(body: SingleChildScrollView(child: child)),
      ),
    );

final _ticket = Ticket(
  key: 'PAY-40',
  ticketNumber: 'AMANAT-2288',
  source_: TicketSource_Enum.jira,
  title: 'Fix refunds',
  description: '',
  priority: 'high',
  state: TicketState.coding,
  revision: 1,
  turns: 3,
  branch: 'agnts/PAY-40',
  prUrl: '',
  kind: TicketKind.code,
  kindAuto: false,
  skipChecks: false,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);

LinkedCommit _c(int i) => LinkedCommit(
      sha: 'abcdef$i',
      shortSha: 'abcdef$i',
      subject: 'AMANAT-2288: step $i',
      author: 'Alice',
      authorLogin: i == 0 ? 'alice' : null,
      branch: 'feature/AMANAT-2288',
      repoId: 3,
      repo: 'api',
      url: 'https://github.com/acme/api/commit/abcdef$i',
      committedAt: DateTime.now().subtract(const Duration(hours: 2)),
      matchedOn: i == 0 ? [LinkedCommitMatchedOnEnum.branch, LinkedCommitMatchedOnEnum.message] : [LinkedCommitMatchedOnEnum.branch],
    );

void main() {
  testWidgets('nothing shows until a commit is linked', (tester) async {
    await tester.pumpWidget(_app(LinkedCommitsFold(ticket: _ticket), {20: LinkedCommits(commits: const [], total: 0)}));
    await tester.pumpAndSettle();
    expect(find.text('Commits'), findsNothing);
  });

  testWidgets('the commits, where the number was found, and more', (tester) async {
    await tester.pumpWidget(_app(LinkedCommitsFold(ticket: _ticket), {
      20: LinkedCommits(commits: [for (var i = 0; i < 20; i++) _c(i)], total: 23),
      40: LinkedCommits(commits: [for (var i = 0; i < 23; i++) _c(i)], total: 23),
    }));
    await tester.pumpAndSettle();
    expect(find.text('Commits'), findsOneWidget);
    expect(find.text('23'), findsOneWidget);
    await tester.tap(find.text('Commits'));
    await tester.pumpAndSettle();
    expect(find.textContaining('AMANAT-2288, from pushes'), findsOneWidget);
    expect(find.text('@alice · api · feature/AMANAT-2288'), findsOneWidget);
    expect(find.text('Alice · api · feature/AMANAT-2288'), findsNWidgets(19));
    expect(find.text('message'), findsOneWidget);
    expect(find.text('branch'), findsNWidgets(20));

    await tester.ensureVisible(find.text('Show more (3 left)'));
    await tester.tap(find.text('Show more (3 left)'));
    await tester.pumpAndSettle();
    expect(find.text('AMANAT-2288: step 22'), findsOneWidget);
    expect(find.textContaining('Show more'), findsNothing);
  });
}
