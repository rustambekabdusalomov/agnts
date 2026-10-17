import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agnts_api/agnts_api.dart';

import 'package:agnts_mobile/core/flavor.dart';
import 'package:agnts_mobile/features/account/account_widgets.dart';
import 'package:agnts_mobile/features/account/workspaces_screen.dart';
import 'package:agnts_mobile/features/auth/login_screen.dart';
import 'package:agnts_mobile/features/workspace/workspace_screen.dart';
import 'package:agnts_mobile/l10n/app_localizations.dart';
import 'package:agnts_mobile/theme.dart';

Widget _app(Widget child, {List overrides = const [], bool scroll = false}) => ProviderScope(
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
        home: Scaffold(body: scroll ? SingleChildScrollView(child: child) : child),
      ),
    );

void main() {
  test('an invite link or bare token gives the token', () {
    expect(inviteToken('https://agnts.uz/invite/abc_123'), 'abc_123');
    expect(inviteToken('https://agnts.uz/invite/abc?x=1'), 'abc');
    expect(inviteToken('  abc-DEF '), 'abc-DEF');
    expect(inviteToken('not a link'), isNull);
    expect(inviteToken(''), isNull);
  });

  test('billing amounts read like the web', () {
    expect(usd(15), r'$15');
    expect(usd(2.5), r'$2.50');
    expect(usd(0.012), r'$0.012');
    expect(som(1250000), '1 250 000');
  });

  testWidgets('the user app can sign in with a password, with links to reset and sign up', (tester) async {
    await tester.pumpWidget(_app(const LoginScreen()));
    await tester.pumpAndSettle();
    expect(find.text('Create one'), findsOneWidget);
    expect(find.text('Forgot password?'), findsNothing);
    await tester.tap(find.text('Sign in with a password'));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsNWidgets(3));
    expect(find.text('Forgot password?'), findsOneWidget);
    expect(find.text('Continue with Google'), findsNothing);
    await tester.tap(find.text('Continue with Google instead'));
    await tester.pumpAndSettle();
    expect(find.text('Continue with Google'), findsOneWidget);
  });

  testWidgets('the admin app links to password reset but not to sign-up', (tester) async {
    await tester.pumpWidget(_app(const LoginScreen(), overrides: [adminAppProvider.overrideWithValue(true)]));
    await tester.pumpAndSettle();
    expect(find.text('Forgot password?'), findsOneWidget);
    expect(find.text('Create one'), findsNothing);
    expect(find.text('Sign in with a password'), findsNothing);
  });

  testWidgets('a two-factor secret shows with a way to open it', (tester) async {
    await tester.pumpWidget(_app(const TotpSecret(secret: 'JBSWY3DP', url: 'otpauth://totp/agnts?secret=JBSWY3DP'), scroll: true));
    await tester.pumpAndSettle();
    expect(find.text('JBSWY3DP'), findsOneWidget);
    expect(find.text('Open in authenticator app'), findsOneWidget);
  });

  testWidgets('a connected Claude account shows its kind and hint, and the form opens on Replace', (tester) async {
    await tester.pumpWidget(_app(ClaudeConnect(
      state: ClaudeConnectionState(connected: true, kind: ClaudeConnectionStateKindEnum.apiKey, tokenHint: 'a1b2'),
      subscriptions: false,
      onConnect: (_, _) async => true,
      onDisconnect: () {},
    ), scroll: true));
    await tester.pumpAndSettle();
    expect(find.text('Anthropic API key · …a1b2'), findsOneWidget);
    await tester.tap(find.text('Replace'));
    await tester.pumpAndSettle();
    expect(find.text('This server takes Anthropic API keys only.'), findsOneWidget);
    expect(find.text('Claude subscription'), findsNothing);
  });
}
