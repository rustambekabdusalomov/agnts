import 'package:agnts_api/agnts_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agnts_mobile/core/data.dart';
import 'package:agnts_mobile/features/tickets/pull_comments.dart';
import 'package:agnts_mobile/l10n/app_localizations.dart';
import 'package:agnts_mobile/theme.dart';

Widget _app(Widget child, List<PullThread> threads, {bool canEdit = true}) => ProviderScope(
      overrides: [
        canEditProvider.overrideWith((ref) => canEdit),
        pullThreadsProvider((3, 7)).overrideWith((ref) async => threads),
        reviewDraftsProvider('PAY-40').overrideWith((ref) async => _drafts),
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

Ticket _ticket({TicketKind kind = TicketKind.code, TicketState state = TicketState.done}) => Ticket(
      key: 'PAY-40',
      source_: TicketSource_Enum.jira,
      title: 'Fix refunds',
      description: '',
      priority: 'high',
      state: state,
      revision: 1,
      turns: 3,
      branch: 'agnts/PAY-40',
      prUrl: 'https://github.com/acme/api/pull/7',
      prNumber: 7,
      repoId: 3,
      kind: kind,
      kindAuto: false,
      skipChecks: false,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );

PullComment _c(String id, String author, String body, {bool mine = false}) => PullComment(
      id: id, author: author, body: body, createdAt: DateTime(2026), updatedAt: DateTime(2026), mine: mine, system: false, agnts: false);

final _threads = [
  PullThread(id: 'th:A:1', kind: PullThreadKindEnum.inline, path: 'refund.go', line: 12, outdated: false, resolvable: true, resolved: false,
      comments: [_c('rc:1', 'bob', 'Round half up here, please.')]),
  PullThread(id: 'ic:2', kind: PullThreadKindEnum.general, outdated: false, resolvable: false, resolved: false,
      comments: [_c('ic:2', 'me', 'Thanks!', mine: true)]),
  PullThread(id: 'th:B:3', kind: PullThreadKindEnum.inline, path: 'a.go', line: 1, outdated: false, resolvable: true, resolved: true,
      comments: [_c('rc:3', 'bob', 'Settled long ago')]),
];

ReviewDraft _d(int id, ReviewDraftStateEnum state, String title, {ReviewDraftKindEnum kind = ReviewDraftKindEnum.finding}) => ReviewDraft(
      id: id, kind: kind, key: 'k$id', severity: 'major', title: title, path: 'refund.go', line: 12, headSha: 'h1',
      body: '**[major] $title**', edited: false, state: state, createdAt: DateTime(2026), updatedAt: DateTime(2026));

final _drafts = [
  _d(1, ReviewDraftStateEnum.accepted, 'Rounds down'),
  _d(2, ReviewDraftStateEnum.draft, 'No test'),
  _d(3, ReviewDraftStateEnum.dismissed, 'Naming'),
];

void main() {
  test('a ticket shows the pull request it opened, or the one it reviews', () {
    expect(ticketPulls(_ticket()).single, (repoId: 3, number: 7, url: 'https://github.com/acme/api/pull/7', repoName: null));
    expect(ticketPulls(_ticket(kind: TicketKind.review)), isEmpty); // a review without its pull request yet
  });

  testWidgets("agnts's own pull request: comments, edit on yours, and Address", (tester) async {
    final t = _ticket();
    await tester.pumpWidget(_app(PullCommentsFold(ticket: t, repoId: 3, number: 7, url: t.prUrl), _threads));
    await tester.pumpAndSettle();
    expect(find.text('Comments on #7 (GitHub)'), findsOneWidget);
    expect(find.text('refund.go:12'), findsOneWidget);
    expect(find.textContaining('Round half up here'), findsOneWidget);
    expect(find.textContaining('Settled long ago'), findsNothing); // resolved: folded away
    expect(find.text('Show resolved (1)'), findsOneWidget);
    expect(find.text('Address 1 comment'), findsOneWidget);
    expect(find.text('Edit'), findsOneWidget); // only on your own comment
  });

  testWidgets('a viewer only reads', (tester) async {
    final t = _ticket();
    await tester.pumpWidget(_app(PullCommentsFold(ticket: t, repoId: 3, number: 7, url: t.prUrl), _threads, canEdit: false));
    await tester.pumpAndSettle();
    expect(find.textContaining('Round half up here'), findsOneWidget);
    expect(find.text('Reply'), findsNothing);
    expect(find.text('Address 1 comment'), findsNothing);
  });

  testWidgets("a review's drafts: decide on each, publish the accepted ones", (tester) async {
    final t = _ticket(kind: TicketKind.review, state: TicketState.waitingForReview);
    await tester.pumpWidget(_app(ReviewDraftsFold(ticket: t), const []));
    await tester.pumpAndSettle();
    expect(find.text('Review comments'), findsOneWidget);
    expect(find.text('Publish 1 to GitHub'), findsOneWidget);
    expect(find.textContaining('No test'), findsOneWidget);
    expect(find.textContaining('Naming'), findsNothing); // dismissed: folded away
    expect(find.text('Accept'), findsOneWidget); // only on the open draft
    expect(find.text('Undo'), findsOneWidget);
  });

  testWidgets('a viewer reads the drafts only', (tester) async {
    final t = _ticket(kind: TicketKind.review, state: TicketState.waitingForReview);
    await tester.pumpWidget(_app(ReviewDraftsFold(ticket: t), const [], canEdit: false));
    await tester.pumpAndSettle();
    expect(find.textContaining('No test'), findsOneWidget);
    expect(find.text('Accept'), findsNothing);
    expect(find.text('Publish 1 to GitHub'), findsNothing);
  });
}
