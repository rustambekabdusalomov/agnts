import 'package:agnts_api/agnts_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agnts_mobile/core/data.dart';
import 'package:agnts_mobile/features/pulls/pull_screen.dart';
import 'package:agnts_mobile/features/pulls/pulls_data.dart';
import 'package:agnts_mobile/features/pulls/repo_pulls.dart';
import 'package:agnts_mobile/features/tickets/diff_lines.dart';
import 'package:agnts_mobile/features/tickets/pull_comments.dart' show pullThreadsProvider, reviewDraftsProvider;
import 'package:agnts_mobile/l10n/app_localizations.dart';
import 'package:agnts_mobile/theme.dart';

const _diff = '''diff --git a/refund.go b/refund.go
@@ -10,3 +10,3 @@
 func refund() {
-  return round(x)
+  return roundHalfUp(x)
 }''';

PullThread _th(String id, {int? line, int? oldLine, bool outdated = false, bool resolved = false, bool system = false}) => PullThread(
  id: id,
  kind: PullThreadKindEnum.inline,
  path: 'refund.go',
  line: line,
  oldLine: oldLine,
  outdated: outdated,
  resolvable: true,
  resolved: resolved,
  comments: [
    PullComment(
      id: 'c$id',
      author: 'bob',
      body: 'x',
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
      mine: false,
      system: system,
      agnts: false,
    ),
  ],
);

ReviewDraft _d(
  int id, {
  int? line = 11,
  String headSha = 'h1',
  ReviewDraftKindEnum kind = ReviewDraftKindEnum.finding,
  ReviewDraftStateEnum state = ReviewDraftStateEnum.draft,
}) => ReviewDraft(
  id: id,
  kind: kind,
  key: 'k$id',
  path: 'refund.go',
  line: line,
  headSha: headSha,
  body: 'b',
  edited: false,
  state: state,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);

PullItem _item(int n, {PullItemStateEnum state = PullItemStateEnum.open, String? ticketKey, bool own = false}) => PullItem(
  number: n,
  url: 'https://github.com/acme/api/pull/$n',
  title: 'Fix refunds $n',
  author: 'bob',
  headRef: 'fix',
  headSha: 'h1',
  baseRef: 'main',
  draft: false,
  state: state,
  why: 'review_requested',
  updatedAt: DateTime.now(),
  ticketKey: ticketKey,
  own: own,
);

PullDetail _detail({PullItemStateEnum state = PullItemStateEnum.open, String? ticketKey, TicketState? ticketState, bool own = false}) =>
    PullDetail(
      repoId: 3,
      repoName: 'api',
      provider: PullDetailProviderEnum.github,
      pull: _item(7, state: state),
      files: const [],
      ticketKey: ticketKey,
      ticketState: ticketState,
      own: own,
    );

void main() {
  final lines = numberDiff(_diff);

  test('threads sit under their line: removed by old number, others by new', () {
    final del = lines.indexWhere((l) => l.kind == DiffKind.del);
    final add = lines.indexWhere((l) => l.kind == DiffKind.add);
    final p = placeThreads(lines, [_th('a', oldLine: 11), _th('b', line: 11), _th('c', line: 11, outdated: true), _th('d', line: 99)]);
    expect(p.at[del]!.single.id, 'a');
    expect(p.at[add]!.single.id, 'b');
    expect(p.left.map((t) => t.id), ['c', 'd']);
  });

  test('drafts on another commit or off the diff are left over', () {
    final add = lines.indexWhere((l) => l.kind == DiffKind.add);
    final p = placeDrafts(lines, [_d(1), _d(2, headSha: 'old'), _d(3, line: 50)], 'h1');
    expect(p.at[add]!.single.id, 1);
    expect(p.left.map((d) => d.id), [2, 3]);
  });

  test('listed drafts: the summary, off-diff, other commits and published ones', () {
    final files = [FileChange(path: 'refund.go', add: 1, del: 1, diff: _diff)];
    final ds = [
      _d(1),
      _d(2, kind: ReviewDraftKindEnum.summary, line: null),
      _d(3, headSha: 'old'),
      _d(4, line: 50),
      _d(5, state: ReviewDraftStateEnum.published),
    ];
    expect(listedDrafts(ds, files, 'h1').map((d) => d.id), [2, 3, 4, 5]);
    expect(draftsOnFile(ds, 'refund.go').map((d) => d.id), [1, 3, 4]);
  });

  test('line comments name the right side', () {
    final del = lines.firstWhere((l) => l.kind == DiffKind.del);
    final add = lines.firstWhere((l) => l.kind == DiffKind.add);
    final ctx = lines.firstWhere((l) => l.kind == DiffKind.plain && l.neu != null);
    final hunk = lines.firstWhere((l) => l.kind == DiffKind.hunk);
    expect(lineComment(del, body: 'x', path: 'p').oldLine, 11);
    expect(lineComment(del, body: 'x', path: 'p').line, isNull);
    expect(lineComment(add, body: 'x', path: 'p').line, 11);
    expect(lineComment(ctx, body: 'x', path: 'p').oldLine, 10);
    expect(lineComment(ctx, body: 'x', path: 'p').line, 10);
    expect(lineCommentable(hunk), isFalse);
    expect([del, add, ctx].every(lineCommentable), isTrue);
  });

  test('a review can be asked for on an open pull request with none in progress', () {
    expect(pullCanAsk(_detail()), isTrue);
    expect(pullCanAsk(_detail(own: true, ticketKey: 'PAY-1')), isFalse);
    expect(pullCanAsk(_detail(state: PullItemStateEnum.merged)), isFalse);
    expect(pullCanAsk(_detail(ticketKey: 'PAY-2', ticketState: TicketState.analyzing)), isFalse);
    expect(pullCanAsk(_detail(ticketKey: 'PAY-2', ticketState: TicketState.done)), isTrue);
    expect(pullReviewing(_detail(ticketKey: 'PAY-2', ticketState: TicketState.coding)), isTrue);
    expect(pullDraftsLocked(_detail(ticketKey: 'PAY-2', ticketState: TicketState.rejected)), isTrue);
  });

  test('system notes and resolved threads fold away', () {
    final all = [_th('a', line: 1), _th('b', line: 1, resolved: true), _th('c', line: 1, system: true)];
    expect(shownThreads(all, resolved: false).map((t) => t.id), ['a']);
    expect(shownThreads(all, resolved: true).map((t) => t.id), ['a', 'b']);
  });

  testWidgets('the list shows each pull request, its ticket, and Review with agnts when it has none', (tester) async {
    final page = [_item(7), _item(8, ticketKey: 'PAY-9', own: true)];
    await tester.pumpWidget(
      ProviderScope(
        overrides: [canEditProvider.overrideWith((ref) => true), repoPullsPageProvider((3, 'open', 1)).overrideWith((ref) async => page)],
        child: MaterialApp(
          theme: agntsTheme(Brightness.light),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: SingleChildScrollView(child: RepoPullsList(repoId: 3))),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Fix refunds 7'), findsOneWidget);
    expect(find.text("agnts's change · PAY-9"), findsOneWidget);
    expect(find.text('Review with agnts'), findsOneWidget);
    expect(find.text('That is all of them.'), findsOneWidget);
  });

  testWidgets('the pull request screen: conversation, then the diff with threads and drafts under their lines', (tester) async {
    final d = PullDetail(
      repoId: 3,
      repoName: 'api',
      provider: PullDetailProviderEnum.github,
      pull: _item(7),
      body: 'Fixes **rounding**.',
      files: [FileChange(path: 'refund.go', add: 1, del: 1, diff: _diff)],
      ticketKey: 'PAY-2',
      ticketState: TicketState.waitingForReview,
      own: false,
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          canEditProvider.overrideWith((ref) => true),
          pullDetailProvider((3, 7)).overrideWith((ref) async => d),
          pullThreadsProvider((3, 7)).overrideWith((ref) async => [_th('a', line: 11)]),
          reviewDraftsProvider('PAY-2').overrideWith((ref) async => [_d(1), _d(2, kind: ReviewDraftKindEnum.summary, line: null)]),
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
          home: const PullScreen(repoId: 3, number: 7),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Fix refunds 7'), findsOneWidget);
    expect(find.text('Review comments'), findsOneWidget);
    // A draft waits for a decision: it opens on the diff, with the thread and the draft under line 11.
    expect(find.text('Accept'), findsWidgets); // the summary, in the review panel
    await tester.scrollUntilVisible(find.text('Reply'), 200, scrollable: find.byType(Scrollable).first);
    expect(find.text('Tap a line to comment on it.'), findsOneWidget);
    expect(find.text('Accept'), findsNWidgets(2)); // and the finding, under its line
    await tester.pumpWidget(const SizedBox()); // stops the refresh timer
  });
}
