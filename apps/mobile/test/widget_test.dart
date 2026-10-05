import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hiro_api/hiro_api.dart';

import 'package:hiro_mobile/features/auth/login_screen.dart';
import 'package:hiro_mobile/l10n/app_localizations.dart';
import 'package:hiro_mobile/theme.dart';
import 'package:hiro_mobile/widgets/common.dart';

Widget _app(Widget child, {Locale locale = const Locale('en')}) => ProviderScope(
      child: MaterialApp(
        theme: hiroTheme(Brightness.light),
        locale: locale,
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

void main() {
  testWidgets('state badges use the shared translations', (tester) async {
    await tester.pumpWidget(_app(const StateBadge(TicketState.waitingForReview)));
    await tester.pumpAndSettle();
    expect(find.text('Ready for review'), findsOneWidget);

    await tester.pumpWidget(_app(const StateBadge(TicketState.waitingForReview), locale: const Locale('ru')));
    await tester.pumpAndSettle();
    expect(find.text('Готово к ревью'), findsOneWidget);
  });

  testWidgets('login rejects a non-https server address', (tester) async {
    await tester.pumpWidget(_app(const LoginScreen()));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'http://insecure.example');
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
    expect(find.text('Enter the https address of your hiro server.'), findsOneWidget);
  });

  test('reset text', () {
    expect(shortDuration(const Duration(hours: 2, minutes: 5)), '2h 5m');
    expect(shortDuration(const Duration(days: 1, hours: 3)), '1d 3h');
  });
}
