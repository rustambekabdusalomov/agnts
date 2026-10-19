import 'package:agnts_api/agnts_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agnts_mobile/features/assistant/assistant_data.dart';
import 'package:agnts_mobile/features/assistant/assistant_screen.dart';
import 'package:agnts_mobile/l10n/app_localizations.dart';
import 'package:agnts_mobile/l10n/app_localizations_en.dart';
import 'package:agnts_mobile/theme.dart';

final _at = DateTime.now().subtract(const Duration(seconds: 5));

AssistantMessage _m(int id, AssistantMessageRoleEnum role, String text,
        {AssistantMessageStatusEnum status = AssistantMessageStatusEnum.done,
        List<AssistantLink> links = const [],
        String? error,
        List<AssistantAction>? actions,
        List<String>? actionErrors}) =>
    AssistantMessage(
      id: id,
      role: role,
      text: text,
      speech: '',
      links: links,
      status: status,
      error: error,
      lang: AssistantLanguage.en,
      rating: AssistantMessageRatingEnum.number0,
      shared: false,
      createdAt: _at,
      actions: actions,
      actionErrors: actionErrors,
      durationMs: status == AssistantMessageStatusEnum.done && role == AssistantMessageRoleEnum.assistant ? 12000 : null,
    );

const _q = AssistantMessageRoleEnum.user;
const _a = AssistantMessageRoleEnum.assistant;

void main() {
  test('snapshot files read as words', () {
    final l = AppLocalizationsEn();
    expect(fileLabel(l, 'ci-12.json'), 'CI failures');
    expect(fileLabel(l, 'ticket-PAY-214.json'), 'PAY-214');
    expect(fileLabel(l, 'inbox.json'), 'your inbox');
    expect(fileLabel(l, 'weird.bin'), 'the workspace');
  });

  test('live events track what an answer reads until it is answered', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final n = c.read(assistantLiveProvider.notifier);
    n.apply({'type': 'assistant_progress', 'data': {'message_id': 2, 'conversation_id': 1, 'file': 'ci.json'}});
    n.apply({'type': 'assistant_partial', 'data': {'message_id': 2, 'conversation_id': 1, 'text': 'Looking at CI'}});
    expect(c.read(assistantLiveProvider)[2]?.file, 'ci.json');
    expect(c.read(assistantLiveProvider)[2]?.text, 'Looking at CI');
    n.apply({'type': 'assistant_answered', 'data': {'message_id': 2, 'conversation_id': 1}});
    expect(c.read(assistantLiveProvider)[2], isNull);
  });

  testWidgets('a conversation shows answers with links, failures and a thinking bubble', (tester) async {
    final conv = AssistantConversation(id: 7, title: 'What waits on me?', createdAt: _at, updatedAt: _at, messages: [
      _m(1, _q, 'What waits on me?'),
      _m(2, _a, '**PAY-214** waits for your review.', links: [
        AssistantLink(kind: AssistantLinkKindEnum.ticket, key: 'PAY-214'),
        AssistantLink(kind: AssistantLinkKindEnum.ci, id: 12),
      ]),
      _m(3, _q, 'Why is CI red?'),
      _m(4, _a, '', status: AssistantMessageStatusEnum.failed, error: 'Claude plan limit reached; ask again after it resets.'),
      _m(5, _q, 'And now?'),
      _m(6, _a, '', status: AssistantMessageStatusEnum.answering),
    ]);
    await tester.pumpWidget(ProviderScope(
      overrides: [assistantConversationProvider(7).overrideWith((ref) async => conv)],
      child: MaterialApp(
        theme: agntsTheme(Brightness.light),
        locale: const Locale('en'),
        localizationsDelegates: const [AppLocalizations.delegate, ...GlobalMaterialLocalizations.delegates],
        supportedLocales: AppLocalizations.supportedLocales,
        home: const AssistantScreen(conversationId: 7),
      ),
    ));
    await tester.pump();
    await tester.pump();

    expect(find.text('What waits on me?'), findsOneWidget);
    expect(find.textContaining('waits for your review'), findsOneWidget);
    expect(find.text('PAY-214'), findsOneWidget);
    expect(find.text('CI #12'), findsOneWidget);
    expect(find.text('12s'), findsOneWidget);
    expect(find.text('No answer'), findsOneWidget);
    expect(find.text('Ask again'), findsOneWidget);
    expect(find.textContaining('Thinking…'), findsOneWidget);
    expect(find.byTooltip('Helpful'), findsOneWidget);

    // Leaving the screen stops its timers.
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('a new conversation offers questions to tap', (tester) async {
    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(
        theme: agntsTheme(Brightness.light),
        locale: const Locale('ru'),
        localizationsDelegates: const [AppLocalizations.delegate, ...GlobalMaterialLocalizations.delegates],
        supportedLocales: AppLocalizations.supportedLocales,
        home: const AssistantScreen(),
      ),
    ));
    await tester.pump();
    expect(find.text('Что ждёт меня?'), findsOneWidget);
    expect(find.text('Почему CI красный?'), findsOneWidget);
  });

  testWidgets('an answer shows the actions it proposes, and approve asks once more', (tester) async {
    AssistantAction act(String id, AssistantActionToolEnum tool, String summary, AssistantActionStatusEnum status,
            {bool destructive = false, String? result, String? key, Duration expires = const Duration(minutes: 20)}) =>
        AssistantAction(
          id: id,
          messageId: 2,
          conversationId: 7,
          tool: tool,
          summary: summary,
          destructive: destructive,
          status: status,
          result: result,
          ticketKey: key,
          expiresAt: DateTime.now().add(expires),
        );
    final answer = _m(2, _a, 'PAY-214 passed review.',
      actions: [
        act('a1', AssistantActionToolEnum.approveTicket, 'Approve PAY-214 (Fix rounding): agnts will push it.', AssistantActionStatusEnum.proposed,
            destructive: true, key: 'PAY-214'),
        act('a2', AssistantActionToolEnum.rejectTicket, 'Reject PAY-1 (Old) and stop all work on it.', AssistantActionStatusEnum.done,
            destructive: true, result: 'PAY-1 is now rejected.', key: 'PAY-1'),
        act('a3', AssistantActionToolEnum.startRun, 'Start PAY-9 now.', AssistantActionStatusEnum.proposed, expires: const Duration(minutes: -1)),
      ],
      actionErrors: ['start_run: no ticket "PAY-404"'],
    );
    final conv = AssistantConversation(id: 7, title: 'Approve', createdAt: _at, updatedAt: _at, messages: [_m(1, _q, 'Approve PAY-214'), answer]);
    await tester.pumpWidget(ProviderScope(
      overrides: [assistantConversationProvider(7).overrideWith((ref) async => conv)],
      child: MaterialApp(
        theme: agntsTheme(Brightness.light),
        locale: const Locale('en'),
        localizationsDelegates: const [AppLocalizations.delegate, ...GlobalMaterialLocalizations.delegates],
        supportedLocales: AppLocalizations.supportedLocales,
        home: const AssistantScreen(conversationId: 7),
      ),
    ));
    await tester.pump();
    await tester.pump();

    expect(find.text('Approve PAY-214 (Fix rounding): agnts will push it.'), findsOneWidget);
    expect(find.text('Confirm'), findsOneWidget); // only the one still waiting
    expect(find.text('Decline'), findsOneWidget);
    expect(find.text('Nothing happens until you confirm.'), findsOneWidget);
    expect(find.textContaining('PAY-1 is now rejected.'), findsOneWidget);
    expect(find.text('PAY-1'), findsOneWidget); // the done action links its ticket
    expect(find.text('Expired. Ask again for a new one.'), findsOneWidget);
    expect(find.text('Not offered: start_run: no ticket "PAY-404"'), findsOneWidget);

    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();
    expect(find.text('Confirm this?'), findsOneWidget);
    expect(find.textContaining('This cannot be undone.'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Confirm this?'), findsNothing);
    expect(find.text('Confirm'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });
}
