import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agnts_api/agnts_api.dart';

import 'package:agnts_mobile/core/data.dart';
import 'package:agnts_mobile/core/flavor.dart';
import 'package:agnts_mobile/core/session.dart';
import 'package:agnts_mobile/features/auth/login_screen.dart';
import 'package:agnts_mobile/l10n/app_localizations.dart';
import 'package:agnts_mobile/theme.dart';
import 'package:agnts_mobile/widgets/workspace.dart';

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
        home: Scaffold(body: child),
      ),
    );

Ticket _ticket(WaitReason? reason, {String? message}) => Ticket(
      key: 'PAY-7',
      source_: TicketSource_Enum.jira,
      title: 't',
      description: '',
      priority: 'medium',
      state: TicketState.new_,
      revision: 0,
      turns: 0,
      branch: '',
      prUrl: '',
      kind: TicketKind.code,
      kindAuto: false,
      skipChecks: false,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
      waitReason: reason,
      waitMessage: message,
    );

QueueStatus _queue() => QueueStatus(
      running: 2,
      slots: 2,
      waiting: QueueStatusWaiting(server: 1),
      serverQueue: [QueueStatusServerQueueInner(key: 'PAY-7', position: 3, others: 2, estimateSec: 240)],
      serverQueueLength: 3,
      capacity: Capacity(budgetMb: 8192, reservedMb: 8192, runs: 4, full: true),
    );

WorkspaceSummary _ws(int id, String slug) =>
    WorkspaceSummary(id: id, slug: slug, name: slug.toUpperCase(), role: WorkspaceRole.user, members: 2, plan: 'base', slots: 2);

/// A signed-in session whose workspace can be switched, without secure storage.
class _FakeSession extends SessionNotifier {
  _FakeSession(this.initial);
  final Session initial;

  @override
  Future<Session?> build() async => initial;

  @override
  Future<void> setWorkspace(String? slug) async => state = AsyncData(state.value!.withWorkspace(slug));
}

void main() {
  testWidgets('a ticket in the server queue shows its place and the wait', (tester) async {
    await tester.pumpWidget(_app(
      WaitBanner(_ticket(WaitReason.server, message: 'The server is busy.')),
      overrides: [queueProvider.overrideWith((_) async => _queue())],
    ));
    await tester.pumpAndSettle();
    expect(find.text('In the server queue'), findsOneWidget);
    final body = tester.widget<Text>(find.textContaining('#3 in the server queue')).data!;
    expect(body, contains('The server is busy.'));
    expect(body, contains('2 tickets of other workspaces ahead.'));
    expect(body, contains('about 4 minutes'));
  });

  testWidgets('a ticket that does not wait shows no banner', (tester) async {
    await tester.pumpWidget(_app(WaitBanner(_ticket(null)), overrides: [queueProvider.overrideWith((_) async => _queue())]));
    await tester.pumpAndSettle();
    expect(find.byType(Text), findsNothing);
  });

  test('wait badges name the reason', () async {
    final l = await AppLocalizations.delegate.load(const Locale('en'));
    expect(waitBadge(l, WaitReason.claude).$1, 'Paused · Muse');
    expect(waitBadge(l, WaitReason.slots).$1, 'Queued · slots');
  });

  test('the current workspace is the chosen one, else the server\'s last one', () async {
    final me = User(id: 1, username: 'ali', lastWorkspace: 'b', workspaces: [_ws(1, 'a'), _ws(2, 'b')]);
    final c = ProviderContainer(overrides: [
      meProvider.overrideWith((_) async => me),
      sessionProvider.overrideWith(() => _FakeSession(const Session(server: 'https://x', token: 't', username: 'ali'))),
    ]);
    addTearDown(c.dispose);
    await c.read(sessionProvider.future);
    await c.read(meProvider.future);
    expect(c.read(currentWorkspaceProvider)?.slug, 'b');

    await c.read(sessionProvider.notifier).setWorkspace('a');
    expect(c.read(currentWorkspaceProvider)?.slug, 'a');

    // A workspace the person left falls back to one they are in.
    await c.read(sessionProvider.notifier).setWorkspace('gone');
    expect(c.read(currentWorkspaceProvider)?.slug, 'a');
  });

  testWidgets('the switcher appears with more than one workspace', (tester) async {
    final me = User(id: 1, username: 'ali', lastWorkspace: 'a', workspaces: [_ws(1, 'a'), _ws(2, 'b')]);
    await tester.pumpWidget(_app(const WorkspaceChip(), overrides: [
      meProvider.overrideWith((_) async => me),
      sessionProvider.overrideWith(() => _FakeSession(const Session(server: 'https://x', token: 't', username: 'ali'))),
    ]));
    await tester.pumpAndSettle();
    expect(find.text('A'), findsOneWidget);
    await tester.tap(find.text('A'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('B'));
    await tester.pumpAndSettle();
    expect(find.text('B'), findsOneWidget);
    expect(find.text('Switched to B'), findsOneWidget);
  });

  testWidgets('the admin app signs in with a password, and asks for the code only when needed', (tester) async {
    await tester.pumpWidget(_app(const LoginScreen(), overrides: [adminAppProvider.overrideWithValue(true)]));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsNWidgets(3));
    expect(find.text('Continue with Google'), findsNothing);
  });

  testWidgets('the user app signs in with Google only', (tester) async {
    await tester.pumpWidget(_app(const LoginScreen()));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget); // the server address
    expect(find.text('https://api.agnts.uz'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
  });
}
