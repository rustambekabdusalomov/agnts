import 'package:agnts_api/agnts_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agnts_mobile/core/data.dart';
import 'package:agnts_mobile/features/assistant/assistant_data.dart';
import 'package:agnts_mobile/features/assistant/assistant_screen.dart';
import 'package:agnts_mobile/features/assistant/code_data.dart';
import 'package:agnts_mobile/features/assistant/code_screen.dart';
import 'package:agnts_mobile/l10n/app_localizations.dart';
import 'package:agnts_mobile/l10n/app_localizations_en.dart';
import 'package:agnts_mobile/theme.dart';

final _at = DateTime.utc(2026, 10, 28, 9);

Repository _repo(int id, String name) => Repository(
  id: id,
  name: name,
  kind: RepositoryKindEnum.side,
  provider: RepositoryProviderEnum.github,
  cloneUrl: 'https://github.com/acme/$name.git',
  defaultBranch: 'main',
  buildCmd: '',
  lintCmd: '',
  testCmd: '',
  branchPrefix: 'agnts/',
  taskPrefix: 'VIS',
  instructions: '',
  jiraProject: '',
  claudeMd: RepositoryClaudeMdEnum.found,
  openTickets: 0,
);

Event _e(
  int id,
  String type,
  String message, {
  String key = 'VIS-1',
  EventOriginEnum origin = EventOriginEnum.system,
  Map<String, Object>? data,
}) => Event(
  id: id,
  ticketKey: key,
  step: 'code',
  type: type,
  level: EventLevelEnum.info,
  origin: origin,
  message: message,
  data: data ?? const {},
  createdAt: _at.add(Duration(seconds: id)),
);

AssistantMessage _m(int id, String text, CodeRouted routed, {String key = 'VIS-1'}) => AssistantMessage(
  id: id,
  role: AssistantMessageRoleEnum.user,
  text: text,
  speech: '',
  links: const [],
  status: AssistantMessageStatusEnum.done,
  lang: AssistantLanguage.en,
  rating: AssistantMessageRatingEnum.number0,
  shared: false,
  createdAt: _at.add(Duration(seconds: id)),
  routed: routed,
  ticketKey: key,
);

TimelineItem _ev(Event e) => TimelineItem(at: e.createdAt, event: e);
TimelineItem _msg(AssistantMessage m) => TimelineItem(at: m.createdAt, message: m);

AssistantConversation _conv(TicketState state, List<AssistantMessage> messages) => AssistantConversation(
  id: 9,
  title: 'Add a rest timer',
  mode: ChatMode.code,
  createdAt: _at,
  updatedAt: _at,
  messages: messages,
  repos: RepoChoice(repoId: 3),
  quick: false,
  tickets: [
    CodeTicket(
      key: 'VIS-1',
      title: 'Add a rest timer',
      state: state,
      kind: TicketKind.code,
      repos: const ['visper'],
      current: true,
      moved: false,
      attachedAt: _at,
    ),
  ],
);

void main() {
  test('tool calls between texts fold into steps; notes stay on their own lines', () {
    final blocks = codeBlocks([
      _msg(_m(1, 'Add a rest timer', CodeRouted.created)),
      _ev(_e(2, 'ticket_created', 'Add a rest timer')),
      _ev(_e(3, 'claude_text', 'Reading the code.')),
      _ev(_e(4, 'claude_tool', 'Read · timer.go')),
      _ev(_e(5, 'claude_tool', 'Edit · timer.go')),
      _ev(_e(6, 'budget', 'model call 1')),
      _ev(_e(7, 'claude_text', 'Done.')),
      _ev(_e(8, 'check', 'go test ./... passed')),
      _ev(_e(9, 'feedback', 'show seconds', origin: EventOriginEnum.assistant)),
    ]);
    expect(blocks.map((b) => b.runtimeType.toString()), ['CodeMessageBlock', 'CodeRunBlock', 'CodeLineBlock']);
    final run = blocks[1] as CodeRunBlock;
    expect(run.parts.length, 3);
    expect((run.parts[1] as List<Event>).length, 2);
  });

  test('live events are added once, for the conversation’s tickets only', () {
    final base = [_ev(_e(5, 'claude_text', 'old'))];
    final live = [
      _e(5, 'claude_text', ''),
      _e(6, 'claude_tool', ''),
      _e(6, 'claude_tool', ''),
      _e(7, 'claude_text', '', key: 'PAY-1'),
      _e(8, 'usage_updated', ''),
    ];
    expect(codeLiveItems(base, live, {'VIS-1'}).map((i) => i.event!.id), [6]);
  });

  test('routes and the composer read by state', () {
    final l = AppLocalizationsEn();
    expect(routedLabel(l, _m(1, 'x', CodeRouted.changes)), 'Asked VIS-1 for changes');
    expect(routedLabel(l, _m(1, 'x', CodeRouted.queued)), "Waits for VIS-1's run to end");
    expect(codePlaceholder(l, null), 'Describe the change…');
    expect(codePlaceholder(l, TicketState.coding), startsWith('Add to the request'));
    final conv = _conv(TicketState.coding, [_m(1, 'a', CodeRouted.created), _m(2, 'b', CodeRouted.queued)]);
    expect(currentTicket(conv)?.key, 'VIS-1');
    expect(codeQueued(conv).map((m) => m.text), ['b']);
    expect(codeRunning(TicketState.testing), isTrue);
    expect(codeRunning(TicketState.waitingForReview), isFalse);
  });

  testWidgets('a conversation shows its run and the result to review', (tester) async {
    final conv = _conv(TicketState.waitingForReview, [_m(1, 'Add a rest timer', CodeRouted.created)]);
    final timeline = CodeTimeline(
      conversation: conv,
      approvals: const [],
      items: [_msg(conv.messages.first), _ev(_e(2, 'claude_text', 'Adding the timer.')), _ev(_e(3, 'claude_tool', 'Edit · timer.go'))],
    );
    final detail = TicketDetail(
      ticket: Ticket(
        key: 'VIS-1',
        source_: TicketSource_Enum.local,
        title: 'Add a rest timer',
        description: '',
        priority: 'medium',
        state: TicketState.waitingForReview,
        revision: 1,
        turns: 3,
        branch: 'agnts/VIS-1',
        prUrl: '',
        kind: TicketKind.code,
        kindAuto: true,
        skipChecks: false,
        createdAt: _at,
        updatedAt: _at,
      ),
      questions: const [],
      attachments: const [],
      result: Result(
        summary: 'Adds a rest timer.',
        notes: const [],
        createdAt: _at,
        checks: [CheckStep(name: 'test', command: 'go test', exitCode: 0, durationMs: 10)],
        files: [FileChange(path: 'timer.go', add: 12, del: 2, diff: '')],
      ),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          codeTimelineProvider(9).overrideWith((ref) async => timeline),
          ticketProvider('VIS-1').overrideWith((ref) async => detail),
          canEditProvider.overrideWithValue(true),
        ],
        child: MaterialApp(
          theme: agntsTheme(Brightness.light),
          locale: const Locale('en'),
          localizationsDelegates: const [AppLocalizations.delegate, ...GlobalMaterialLocalizations.delegates],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const CodeScreen(conversationId: 9),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Started VIS-1'), findsOneWidget);
    expect(find.textContaining('Adding the timer.'), findsOneWidget);
    expect(find.textContaining('1 step'), findsOneWidget);
    expect(find.text('VIS-1 is ready for your review'), findsOneWidget);
    expect(find.text('Checks passed'), findsOneWidget);
    expect(find.text('Approve'), findsOneWidget);
    expect(find.text('Reject'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('a Chat answer offers the change in Code mode', (tester) async {
    final answer = AssistantMessage(
      id: 2,
      role: AssistantMessageRoleEnum.assistant,
      text: 'I can do this in Code mode.',
      speech: '',
      links: const [],
      status: AssistantMessageStatusEnum.done,
      lang: AssistantLanguage.en,
      rating: AssistantMessageRatingEnum.number0,
      shared: false,
      createdAt: _at,
      handoff: CodeHandoff(request: 'Round refunds half up', repoIds: const [3], repos: const ['api']),
    );
    final conv = AssistantConversation(
      id: 7,
      title: 'Fix rounding',
      mode: ChatMode.chat,
      createdAt: _at,
      updatedAt: _at,
      messages: [answer],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [assistantConversationProvider(7).overrideWith((ref) async => conv), canEditProvider.overrideWithValue(true)],
        child: MaterialApp(
          theme: agntsTheme(Brightness.light),
          locale: const Locale('en'),
          localizationsDelegates: const [AppLocalizations.delegate, ...GlobalMaterialLocalizations.delegates],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const AssistantScreen(conversationId: 7),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
    expect(find.text('Do this in Code'), findsOneWidget);
    expect(find.text('Round refunds half up'), findsOneWidget);
    expect(find.text('Repositories: api'), findsOneWidget);
    expect(find.text('Open in Code'), findsOneWidget);
    expect(find.byTooltip('Code'), findsOneWidget); // the switch to Code mode
    await tester.pumpWidget(const SizedBox());
  });
  group('mentions', () {
    final repos = [_repo(1, 'api'), _repo(2, 'web-admin'), _repo(3, 'acme/mobile')];
    test('reads the repositories a message names, as the server does', () {
      expect(mentionedRepos('fix login in @api', repos, plain: false), [1]);
      expect(mentionedRepos('fix login in the api', repos, plain: false), isEmpty);
      expect(mentionedRepos('fix login in the api', repos, plain: true), [1]);
      expect(mentionedRepos('@WEB-ADMIN and @api: rename it', repos, plain: false), [1, 2]);
      expect(mentionedRepos('update @mobile.', repos, plain: false), [3]);
      expect(mentionedRepos('see src/api/handler.go', repos, plain: true), isEmpty);
      expect(mentionedRepos('mail me at x@api.dev', repos, plain: false), isEmpty);
    });
    test('finds the mention being typed and inserts the pick', () {
      expect(mentionAt('fix @we', 7), (start: 4, query: 'we'));
      expect(mentionAt('me@ap', 5), isNull);
      expect(mentionAt('', 12), isNull);
      expect(mentionOptions('a', repos).map((r) => r.id), [1, 3, 2]);
      expect(insertMention('fix @we in it', 4, 7, 'web-admin'), (text: 'fix @web-admin in it', caret: 15));
    });
  });

  testWidgets('typing @ offers the repositories, and the pick shows where it works', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          reposProvider.overrideWith((ref) async => [_repo(3, 'visper'), _repo(4, 'gymlog')]),
          repoGroupsProvider.overrideWith((ref) async => const <RepoGroup>[]),
          canEditProvider.overrideWithValue(true),
        ],
        child: MaterialApp(
          theme: agntsTheme(Brightness.light),
          locale: const Locale('en'),
          localizationsDelegates: const [AppLocalizations.delegate, ...GlobalMaterialLocalizations.delegates],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const CodeScreen(),
        ),
      ),
    );
    await tester.pump();
    final field = find.byWidgetPredicate((w) => w is TextField && w.minLines == 1 && w.maxLines == 6);
    await tester.enterText(field, 'Add a timer to @vi');
    await tester.pump();
    expect(find.text('@visper'), findsOneWidget);
    expect(find.text('@gymlog'), findsNothing);
    await tester.tap(find.text('@visper'));
    await tester.pump();
    expect(tester.widget<TextField>(field).controller!.text, 'Add a timer to @visper ');
    expect(find.text('Works in visper'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
}
