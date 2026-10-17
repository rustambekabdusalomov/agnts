import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agnts_api/agnts_api.dart';

import 'package:agnts_mobile/features/admin/admin_data.dart';
import 'package:agnts_mobile/features/admin/admin_run_screen.dart';
import 'package:agnts_mobile/features/admin/admin_runs_data.dart';
import 'package:agnts_mobile/features/admin/admin_runs_screen.dart';
import 'package:agnts_mobile/l10n/app_localizations.dart';
import 'package:agnts_mobile/theme.dart';

Widget _app(Widget child, {List overrides = const []}) => ProviderScope(
  overrides: [...overrides],
  child: MaterialApp(
    theme: agntsTheme(Brightness.light),
    locale: const Locale('en'),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: child,
  ),
);

final _now = DateTime.now();

RunTranscript _run(int id, {String status = 'done', String? ticket = 'API-70', String purpose = 'code', int stalls = 0, int? runId = 9}) =>
    RunTranscript(
      id: id,
      workspaceId: 4,
      workspace: 'Iman',
      workspaceSlug: 'iman',
      runId: runId,
      ticketKey: ticket,
      subject: ticket == null ? 'api' : null,
      purpose: purpose,
      background: ticket == null,
      modelStage: 'coding',
      engine: RunTranscriptEngineEnum.claude,
      model: 'opus',
      startedAt: _now.subtract(const Duration(minutes: 30)),
      finishedAt: _now.subtract(const Duration(minutes: 24)),
      status: RunTranscriptStatusEnum.values.byName(status),
      exitReason: status == 'error' ? 'stopped at the turn limit (120)' : 'success',
      turns: 38,
      toolCalls: 2,
      toolErrors: 1,
      stalls: stalls,
      inputTokens: 1200,
      outputTokens: 300,
      cacheReadTokens: 0,
      cacheWriteTokens: 0,
      costUsd: 1.84,
      rawBytes: 4096,
      storedBytes: 1024,
      truncated: false,
    );

RunTranscriptEvent _ev(
  String k,
  int t, {
  String? text,
  String? id,
  String? name,
  String? summary,
  Object? input,
  String? output,
  bool? error,
  int? cut,
  String? subtype,
}) => RunTranscriptEvent(
  k: k,
  t: t,
  text: text,
  id: id,
  name: name,
  summary: summary,
  input: input,
  output: output,
  error: error,
  cut: cut,
  subtype: subtype,
);

final _events = [
  _ev('text', 3000, text: "I'll start by reading the order service"),
  _ev('tool', 4000, id: 't1', name: 'Read', summary: 'Read: src/orders/service.go', input: {'file_path': 'src/orders/service.go'}),
  _ev('tool_result', 4100, id: 't1', error: false, output: 'package orders'),
  _ev('tool', 9000, id: 't2', name: 'Bash', summary: 'Bash: go test ./orders/...', input: {'command': 'go test ./orders/...'}),
  _ev('tool_result', 9200, id: 't2', error: true, output: '--- FAIL: TestRefund', cut: 20480),
  _ev('note', 9300, text: 'stall: the same test failed 6 times'),
  _ev('result', 1443000, subtype: 'error_max_turns', error: true, text: 'stopped'),
];

void main() {
  test('the timeline pairs results with their calls and marks failures', () {
    final items = runTimeline([..._events, _ev('tool_result', 9999, id: 'orphan', error: true, output: 'x')]);
    expect(items.length, 6); // text, 2 tools, note, result, the orphan result
    final tools = items.whereType<ToolItem>().toList();
    expect(tools.map((t) => t.result?.output), ['package orders', '--- FAIL: TestRefund']);
    expect(tools.map((t) => t.error), [false, true]);
    expect(items.where((i) => i.error).length, 3); // the failed tool, the result, the orphan
    expect(clock(1443000), '24:03');
    expect(clock(3723000), '1:02:03');
    expect(durText(const Duration(seconds: 42)), '42s');
    expect(inputText({'command': 'ls'}), '{\n  "command": "ls"\n}');
    expect(inputText('too big'), 'too big');
  });

  testWidgets('the runs list shows each invocation with its outcome', (tester) async {
    await tester.pumpWidget(
      _app(
        const AdminRunsScreen(),
        overrides: [
          platformWorkspacesProvider.overrideWith((_) async => <PlatformWorkspace>[]),
          platformRunsProvider.overrideWith(
            (ref, q) async => RunHistoryPage(
              items: [
                _run(2, status: 'error', stalls: 2),
                _run(1, ticket: null, purpose: 'brief'),
              ],
            ),
          ),
          platformRunSummaryProvider.overrideWith(
            (ref, q) async => RunHistorySummary(
              count: 2,
              errors: 1,
              stalled: 1,
              costUsd: 3.68,
              backgroundCostUsd: 1.84,
              inputTokens: 2400,
              outputTokens: 600,
              p50Ms: 360000,
              p95Ms: 360000,
            ),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('API-70'), findsOneWidget);
    expect(find.text('api'), findsOneWidget); // a background call shows its subject
    expect(find.textContaining('Repository brief'), findsOneWidget);
    expect(find.text('⚠ 2'), findsOneWidget);
    expect(find.text('50%'), findsOneWidget); // error rate
  });

  testWidgets('a transcript shows the banner and folds tool calls; the prompt loads only on its tab', (tester) async {
    var promptReads = 0;
    await tester.pumpWidget(
      _app(
        const AdminRunScreen(id: 2),
        overrides: [
          platformRunProvider.overrideWith(
            (ref, id) async => RunTranscriptDetail(
              transcript: _run(2, status: 'error'),
              events: _events,
              siblings: [_run(3, status: 'done')],
            ),
          ),
          platformRunPromptProvider.overrideWith((ref, id) async {
            promptReads++;
            return 'Fix API-70';
          }),
        ],
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Viewing customer content. This access is logged.'), findsOneWidget);
    expect(find.text('Bash: go test ./orders/...'), findsOneWidget);
    expect(find.textContaining('Failed'), findsOneWidget);
    expect(find.text('--- FAIL: TestRefund'), findsNothing); // folded

    await tester.ensureVisible(find.text('Bash: go test ./orders/...'));
    await tester.tap(find.text('Bash: go test ./orders/...'));
    await tester.pumpAndSettle();
    expect(find.text('--- FAIL: TestRefund'), findsOneWidget);
    expect(find.textContaining('cut, original 20.0 KB'), findsOneWidget);
    expect(promptReads, 0);

    await tester.ensureVisible(find.text('Prompt'));
    await tester.tap(find.text('Prompt'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Fix API-70'), 300, scrollable: find.byType(Scrollable).first);
    expect(find.text('Fix API-70'), findsOneWidget);
    await tester.ensureVisible(find.text('Timeline'));
    await tester.tap(find.text('Timeline'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Prompt'));
    await tester.tap(find.text('Prompt'));
    await tester.pumpAndSettle();
    expect(promptReads, 1); // switching tabs does not read it again
  });
}
