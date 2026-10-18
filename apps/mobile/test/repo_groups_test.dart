import 'package:agnts_api/agnts_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agnts_mobile/features/tasks/repo_pick.dart';
import 'package:agnts_mobile/features/tickets/ticket_repos.dart';
import 'package:agnts_mobile/l10n/app_localizations.dart';
import 'package:agnts_mobile/theme.dart';
import 'package:agnts_mobile/widgets/ui.dart';

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

RepoGroupMember _m(int id, String name, {bool archived = false}) => RepoGroupMember(repoId: id, repoName: name, role: '', archived: archived);

final _group = RepoGroup(
  id: 7,
  name: 'shop',
  description: '',
  instructions: '',
  taskPrefix: 'SHOP',
  members: [_m(1, 'api'), _m(2, 'web'), _m(3, 'old', archived: true), _m(4, 'admin')],
  warnings: const [],
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);

TicketRepoState _rs(int id, String name, TicketRepoStateStateEnum state, {String role = '', String prUrl = '', String? pushError}) => TicketRepoState(
      repoId: id,
      repoName: name,
      role: role,
      folder: name,
      branch: 'agnts/SHOP-1',
      headSha: '',
      prUrl: prUrl,
      ciFixes: 0,
      state: state,
      files: 2,
      pushError: pushError,
    );

Ticket _ticket({List<TicketRepoState>? repos}) => Ticket(
      key: 'SHOP-1',
      source_: TicketSource_Enum.local,
      title: 'Checkout',
      description: '',
      priority: 'high',
      state: TicketState.waitingForReview,
      revision: 0,
      turns: 0,
      branch: 'agnts/SHOP-1',
      prUrl: '',
      kind: TicketKind.code,
      kindAuto: false,
      skipChecks: false,
      repoId: 1,
      repoName: 'api',
      repos: repos,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );

/// The payload as [repoId, repoIds, groupId], to compare deeply.
List<Object?> _payload(RepoPick p) => [p.payload.repoId, p.payload.repoIds, p.payload.groupId];

void main() {
  group('RepoPick payload', () {
    test('no repository sends nothing', () {
      expect(_payload(RepoPick.single(0)), [null, null, null]);
    });

    test('one repository sends repoId', () {
      expect(_payload(RepoPick.single(4)), [4, null, null]);
      expect(_payload(const RepoPick().toggle(2)), [2, null, null]);
    });

    test('several repositories send repoIds in pick order', () {
      final p = RepoPick.single(2).toggle(1).toggle(4);
      expect(_payload(p), [null, [2, 1, 4], null]);
      expect(_payload(p.toggle(2)), [null, [1, 4], null]);
    });

    test('an untouched group sends groupId and skips archived members', () {
      final p = RepoPick.single(2).pickGroup(_group);
      expect(p.ids, [1, 2, 4]);
      expect(p.wholeGroup, _group);
      expect(_payload(p), [null, null, 7]);
    });

    test('editing a group switches to repoIds', () {
      final removed = const RepoPick().pickGroup(_group).remove(2);
      expect(removed.edited, isTrue);
      expect(removed.group, _group);
      expect(_payload(removed), [null, [1, 4], null]);

      final added = const RepoPick().pickGroup(_group).toggle(9);
      expect(_payload(added), [null, [1, 2, 4, 9], null]);

      // Down to one repository: a plain repoId.
      expect(_payload(removed.remove(4)), [1, null, null]);
      // Down to none: no repository at all.
      expect(_payload(removed.remove(4).remove(1)), [null, null, null]);
    });
  });

  test('lists add +N for the other repositories', () {
    expect(repoLabel(_ticket()), 'api');
    expect(repoLabel(_ticket(repos: [_rs(1, 'api', TicketRepoStateStateEnum.pending)])), 'api');
    expect(
      repoLabel(_ticket(repos: [
        _rs(1, 'api', TicketRepoStateStateEnum.pending),
        _rs(2, 'web', TicketRepoStateStateEnum.pending),
        _rs(4, 'admin', TicketRepoStateStateEnum.pending),
      ])),
      'api +2',
    );
  });

  test('changed files name their repository when set', () {
    expect(filePath(FileChange(path: 'main.go', add: 1, del: 0, diff: '')), 'main.go');
    expect(filePath(FileChange(repo: 'api', repoId: 1, path: 'main.go', add: 1, del: 0, diff: '')), 'api/main.go');
  });

  testWidgets('a multi-repo ticket lists each repository', (tester) async {
    final t = _ticket(repos: [
      _rs(1, 'api', TicketRepoStateStateEnum.merged, role: 'backend', prUrl: 'https://git.example/api/pull/3'),
      _rs(2, 'web', TicketRepoStateStateEnum.pushed, pushError: 'remote rejected'),
      _rs(4, 'admin', TicketRepoStateStateEnum.unchanged),
    ]);
    await tester.pumpWidget(_app(TicketRepos(t)));
    await tester.pumpAndSettle();
    expect(find.text('Repositories'), findsOneWidget);
    expect(find.text('api'), findsOneWidget);
    expect(find.text('web'), findsOneWidget);
    expect(find.text('admin'), findsOneWidget);
    expect(find.text('main · backend · 2 files'), findsOneWidget);
    expect(find.text('Merged'), findsOneWidget);
    expect(find.text('Pushed'), findsOneWidget);
    expect(find.text('No changes'), findsOneWidget);
    expect(find.text('https://git.example/api/pull/3'), findsOneWidget);
    expect(find.text('Push failed: remote rejected'), findsOneWidget);
    expect(find.text('Branch: agnts/SHOP-1'), findsNWidgets(3));
  });

  testWidgets('a single-repo ticket shows no repository list', (tester) async {
    await tester.pumpWidget(_app(TicketRepos(_ticket(repos: [_rs(1, 'api', TicketRepoStateStateEnum.pending)]))));
    expect(find.text('Repositories'), findsNothing);
  });
}
