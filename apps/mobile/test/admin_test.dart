import 'package:flutter/material.dart' hide Feedback;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agnts_api/agnts_api.dart';

import 'package:agnts_mobile/app_router.dart';
import 'package:agnts_mobile/core/data.dart';
import 'package:agnts_mobile/core/flavor.dart';
import 'package:agnts_mobile/core/session.dart';
import 'package:agnts_mobile/features/admin/admin_data.dart';
import 'package:agnts_mobile/features/admin/admin_feedback_screen.dart';
import 'package:agnts_mobile/features/admin/admin_users_screen.dart';
import 'package:agnts_mobile/features/admin/admin_workspaces_screen.dart';
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

PlatformUser _user(int id, String name, {bool admin = false, bool password = false, int daysAgo = 1, List<WorkspaceSummary> ws = const []}) =>
    PlatformUser(
      user: User(id: id, username: name, email: '$name@x.uz', isAdmin: admin, createdAt: _now.subtract(Duration(days: daysAgo))),
      hasPassword: password,
      lastSignInAt: _now.subtract(Duration(days: daysAgo)),
      workspaces: ws,
    );

PlatformWorkspace _ws(int id, String name, {bool suspended = false, DateTime? deletedAt}) => PlatformWorkspace(
      id: id,
      slug: name.toLowerCase(),
      name: name,
      owner: 'ali',
      plan: 'base',
      slots: 2,
      memberLimit: 0,
      members: 1,
      creditsBalance: 500,
      running: 0,
      suspended: suspended,
      deletedAt: deletedAt,
      createdAt: _now,
    );

Feedback _fb(int id, String title, FeedbackStatusEnum status) =>
    Feedback(id: id, kind: FeedbackKindEnum.feedback, title: title, description: 'details', status: status, sender: 'ali', createdAt: _now);

void main() {
  routingTests();

  test('perDay counts by calendar day, oldest first', () {
    final today = DateTime.now();
    final out = perDay([today, today, today.subtract(const Duration(days: 2)), today.subtract(const Duration(days: 40)), null], 7);
    expect(out.length, 7);
    expect(out.last, 2);
    expect(out[4], 1);
    expect(out.reduce((a, b) => a + b), 3);
  });

  test('an Admin with no workspaces is a cabinet-only account', () async {
    Future<({bool admin, bool only})?> read(User me) async {
      final c = ProviderContainer(overrides: [meProvider.overrideWith((_) async => me)]);
      addTearDown(c.dispose);
      await c.read(meProvider.future);
      return c.read(adminProvider);
    }

    final ws = WorkspaceSummary(id: 1, slug: 'a', name: 'A', role: WorkspaceRole.owner, members: 1, plan: 'base', slots: 1);
    expect(await read(User(id: 1, username: 'root', isAdmin: true)), (admin: true, only: true));
    expect(await read(User(id: 1, username: 'root', isAdmin: true, workspaces: [ws])), (admin: true, only: false));
    expect(await read(User(id: 2, username: 'ali', workspaces: [ws])), (admin: false, only: false));
  });

  testWidgets('Users lists people, not Admins, and filters by sign-in', (tester) async {
    await tester.pumpWidget(_app(const AdminUsersScreen(), overrides: [
      platformUsersProvider.overrideWith((_) async => [
            _user(1, 'root', admin: true, password: true),
            _user(2, 'ali'),
            _user(3, 'vali', password: true, daysAgo: 20),
          ]),
    ]));
    await tester.pumpAndSettle();
    expect(find.text('ali'), findsOneWidget);
    expect(find.text('vali'), findsOneWidget);
    expect(find.text('root'), findsNothing);

    await tester.tap(find.text('Google').first);
    await tester.pumpAndSettle();
    expect(find.text('ali'), findsOneWidget);
    expect(find.text('vali'), findsNothing);
  });

  testWidgets('Workspaces filters by state', (tester) async {
    await tester.pumpWidget(_app(const AdminWorkspacesScreen(), overrides: [
      platformWorkspacesProvider.overrideWith((_) async => [_ws(1, 'Acme'), _ws(2, 'Beta', suspended: true), _ws(3, 'Gone', deletedAt: _now)]),
      platformUsersProvider.overrideWith((_) async => <PlatformUser>[]),
    ]));
    await tester.pumpAndSettle();
    expect(find.text('Acme'), findsOneWidget);
    expect(find.text('Gone'), findsOneWidget);

    await tester.tap(find.text('Suspended').first);
    await tester.pumpAndSettle();
    expect(find.text('Beta'), findsOneWidget);
    expect(find.text('Acme'), findsNothing);
  });

  testWidgets('Feedback opens on the new ones', (tester) async {
    await tester.pumpWidget(_app(const AdminFeedbackScreen(), overrides: [
      platformFeedbackProvider.overrideWith((_) async => [_fb(1, 'Dark mode', FeedbackStatusEnum.new_), _fb(2, 'Old bug', FeedbackStatusEnum.done)]),
    ]));
    await tester.pumpAndSettle();
    expect(find.text('Dark mode'), findsOneWidget);
    expect(find.text('Old bug'), findsNothing);
    expect(find.text('Mark done'), findsOneWidget);
  });
}

/// A signed-in session, without secure storage.
class _Signed extends SessionNotifier {
  @override
  Future<Session?> build() async => const Session(server: 'https://x', token: 't', username: 'u');
}

Future<void> _openApp(WidgetTester tester, {required bool adminApp, required User me}) async {
  await tester.pumpWidget(ProviderScope(
    overrides: [
      adminAppProvider.overrideWithValue(adminApp),
      sessionProvider.overrideWith(_Signed.new),
      meProvider.overrideWith((_) async => me),
      platformUsersProvider.overrideWith((_) async => <PlatformUser>[]),
      platformWorkspacesProvider.overrideWith((_) async => <PlatformWorkspace>[]),
      platformFeedbackProvider.overrideWith((_) async => <Feedback>[]),
      platformOverviewProvider.overrideWith((_) async => throw StateError('offline')),
    ],
    child: Consumer(
      builder: (_, ref, _) => MaterialApp.router(
        locale: const Locale('en'),
        theme: agntsTheme(Brightness.light),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: ref.watch(routerProvider),
      ),
    ),
  ));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
}

void routingTests() {
  testWidgets('the admin app turns away an account that is not an Admin', (tester) async {
    await _openApp(tester, adminApp: true, me: User(id: 2, username: 'ali'));
    expect(find.text('Only an Admin can open the operator console.'), findsOneWidget);
    expect(find.text('Sign out'), findsOneWidget);
  });

  testWidgets('the admin app opens an Admin on the cabinet', (tester) async {
    await _openApp(tester, adminApp: true, me: User(id: 1, username: 'root', isAdmin: true));
    expect(find.text('Admin cabinet'), findsOneWidget);
    expect(find.text('Feedback'), findsOneWidget);
  });

  testWidgets('the user app sends an Admin-only account to the admin app', (tester) async {
    await _openApp(tester, adminApp: false, me: User(id: 1, username: 'root', isAdmin: true));
    expect(find.text('This is an Admin account. Open it in the agnts admin app.'), findsOneWidget);
  });
}
