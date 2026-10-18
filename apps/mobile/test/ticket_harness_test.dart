import 'package:agnts_api/agnts_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agnts_mobile/features/tickets/harness.dart';
import 'package:agnts_mobile/features/tickets/relations.dart';
import 'package:agnts_mobile/features/tickets/ticket_controls.dart';
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

Ticket _ticket({
  TicketKind kind = TicketKind.code,
  TicketSource_Enum source = TicketSource_Enum.jira,
  TicketAfterApproveEnum? after,
  int? repoId,
  List<TicketRepoState>? repos,
  String prUrl = '',
  bool kindAuto = false,
}) =>
    Ticket(
      key: 'PAY-1',
      source_: source,
      repoId: repoId,
      repos: repos,
      title: 'Show tasks',
      description: '',
      priority: 'high',
      state: TicketState.waitingForReview,
      revision: 0,
      turns: 0,
      branch: '',
      prUrl: prUrl,
      afterApprove: after,
      kind: kind,
      kindAuto: kindAuto,
      skipChecks: false,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );

Result _result({List<RedFlag>? flags, Proof? proof, Coverage? coverage}) =>
    Result(summary: '', notes: const [], checks: const [], files: const [], redFlags: flags, proof: proof, coverage: coverage, createdAt: DateTime(2026));

void main() {
  test('predicates follow the admin panel', () {
    expect(opensPr(_ticket()), isTrue);
    expect(opensPr(_ticket(kind: TicketKind.plan)), isFalse);
    expect(opensPr(_ticket(kind: TicketKind.review)), isFalse);
    expect(opensPr(_ticket(source: TicketSource_Enum.local, after: TicketAfterApproveEnum.main)), isFalse);
    expect(needsRepo(_ticket()), isTrue);
    expect(needsRepo(_ticket(kindAuto: true)), isFalse);
    expect(needsRepo(_ticket(kind: TicketKind.bug)), isFalse);
    expect(canChangeRepo(_ticket(prUrl: 'https://x/pr/1')), isFalse);
    expect(ticketRepoIds(_ticket(repoId: 4)), [4]);
    expect(secretFlagCount(_result(flags: [
      RedFlag(kind: RedFlagKindEnum.todo, path: 'a.go', text: ''),
      RedFlag(kind: RedFlagKindEnum.secret, path: 'b.go', text: ''),
      RedFlag(kind: RedFlagKindEnum.envFile, path: '.env', text: ''),
    ])), 2);
  });

  test('relations show for a ticket with a repository, not for a pull request review', () {
    TicketDetail d(Ticket t) => TicketDetail(ticket: t, questions: const [], attachments: const []);
    expect(RelationsFold.shows(d(_ticket(repoId: 3))), isTrue);
    expect(RelationsFold.shows(d(_ticket())), isFalse);
    expect(RelationsFold.shows(d(_ticket(kind: TicketKind.review, repoId: 3))), isFalse);
  });

  testWidgets('red flags list the most serious first', (tester) async {
    await tester.pumpWidget(_app(RedFlagsList([
      RedFlag(kind: RedFlagKindEnum.todo, path: 'a.go', line: 3, text: '// TODO'),
      RedFlag(kind: RedFlagKindEnum.secret, path: 'cfg.go', line: 9, text: 'key = "sk-1"'),
    ])));
    expect(find.text('2 red flags'), findsOneWidget);
    final secret = tester.getTopLeft(find.text('Possible secret'));
    final todo = tester.getTopLeft(find.text('TODO left'));
    expect(secret.dy < todo.dy, isTrue);
    expect(find.text('cfg.go:9'), findsOneWidget);
  });

  testWidgets('harness checks show the proof and uncovered lines', (tester) async {
    final r = _result(
      proof: Proof(status: ProofStatusEnum.proven, tests: [
        ProofTest(
          file: 'x_test.go',
          name: 'TestX',
          command: 'go test ./...',
          status: 'proven',
          before: ProofRun(exit: 1, output: 'FAIL', ms: 10),
          after: ProofRun(exit: 0, output: 'ok', ms: 10),
        ),
      ]),
      coverage: Coverage(covered: 3, total: 4, percent: 75, threshold: 80, files: [
        CoverageFilesInner(path: 'x.go', covered: 3, total: 4, uncovered: [CoverageFilesInnerUncoveredInner(from: 7, to: 7)]),
      ]),
    );
    expect(HarnessChecks.shows(r), isTrue);
    await tester.pumpWidget(_app(HarnessChecks(r)));
    expect(find.text('Proof of the fix'), findsOneWidget);
    expect(find.text('Proven'), findsOneWidget);
    expect(find.text('Before the change (exit 1)'), findsOneWidget);
    expect(find.text('75%'), findsOneWidget);
    expect(find.text("Below the repository's 80%"), findsOneWidget);
    expect(find.text('Not run: lines 7'), findsOneWidget);
  });

  testWidgets('the design record shows the approach and the departures', (tester) async {
    final a = Analysis(
      summary: '',
      plan: const [],
      approaches: [
        Approach(title: 'Cache', sketch: 'keep it in memory', pros: const [], cons: const [], chosen: true),
        Approach(title: 'Index', sketch: 'add an index', pros: const ['fast'], cons: const ['migration'], chosen: false, why: 'too slow to ship'),
      ],
      outOfScope: const ['the admin page'],
    );
    expect(DesignRecord.shows(a), isTrue);
    expect(DesignRecord.shows(Analysis(summary: '', plan: const [])), isFalse);
    await tester.pumpWidget(_app(DesignRecord(analysis: a, deviations: const ['skipped the cache'])));
    expect(find.text('Approach'), findsOneWidget);
    expect(find.text('1 alternative considered'), findsOneWidget);
    expect(find.text('the admin page'), findsOneWidget);
    expect(find.textContaining('skipped the cache'), findsOneWidget);
  });
}
