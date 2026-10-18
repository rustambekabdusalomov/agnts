import 'package:agnts_api/agnts_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agnts_mobile/features/tickets/commit_messages.dart';
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

TicketRepoState _rs(int id, String name, {List<BranchCommit>? commits}) => TicketRepoState(
      repoId: id,
      repoName: name,
      role: '',
      folder: name,
      branch: 'agnts/SHOP-3',
      headSha: '',
      prUrl: '',
      ciFixes: 0,
      state: TicketRepoStateStateEnum.pending,
      files: 1,
      commits: commits,
    );

Ticket _ticket(List<TicketRepoState> repos) => Ticket(
      key: 'SHOP-3',
      source_: TicketSource_Enum.local,
      title: 't',
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
      repos: repos,
    );

final _two = [
  _rs(1, 'api', commits: [
    BranchCommit(sha: 'bbbbbbb2222', message: 'SHOP-3: Login (revision 1)'),
    BranchCommit(sha: 'aaaaaaa1111', message: 'SHOP-3: Login\n\nWhy it changed'),
  ]),
  _rs(2, 'web'),
];

void main() {
  test('hasEditableCommits', () {
    expect(hasEditableCommits(_ticket(_two)), isTrue);
    expect(hasEditableCommits(_ticket([_rs(1, 'api')])), isFalse);
  });

  testWidgets('lists each repository\'s commits, newest first, with its heading', (tester) async {
    await tester.pumpWidget(_app(CommitMessages(_ticket(_two))));
    expect(find.textContaining('agnts/SHOP-3', findRichText: true), findsOneWidget); // api only: web has none
    expect(find.text('bbbbbbb'), findsOneWidget);
    expect(find.text('SHOP-3: Login (revision 1)'), findsOneWidget);
    expect(find.text('SHOP-3: Login …'), findsOneWidget);
  });

  testWidgets('a tap edits that commit; read only without onEdit', (tester) async {
    (TicketRepoState, BranchCommit)? picked;
    await tester.pumpWidget(_app(CommitMessages(_ticket(_two), onEdit: (r, c) => picked = (r, c))));
    await tester.tap(find.text('SHOP-3: Login …'));
    expect(picked?.$1.repoId, 1);
    expect(picked?.$2.sha, 'aaaaaaa1111');

    picked = null;
    await tester.pumpWidget(_app(CommitMessages(_ticket(_two))));
    await tester.tap(find.text('SHOP-3: Login …'));
    expect(picked, isNull);
  });

  testWidgets('one repository: no heading', (tester) async {
    final one = [_rs(1, 'api', commits: [BranchCommit(sha: 'aaaaaaa1111', message: 'SHOP-3: Login')])];
    await tester.pumpWidget(_app(CommitMessages(_ticket(one))));
    expect(find.textContaining('agnts/SHOP-3', findRichText: true), findsNothing);
    expect(find.text('SHOP-3: Login'), findsOneWidget);
  });
}
