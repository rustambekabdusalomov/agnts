import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agnts_api/agnts_api.dart';

import 'package:agnts_mobile/features/auth/login_screen.dart';
import 'package:agnts_mobile/l10n/app_localizations.dart';
import 'package:agnts_mobile/theme.dart';
import 'package:agnts_mobile/widgets/common.dart';
import 'package:agnts_mobile/widgets/ui.dart';

Widget _app(Widget child, {Locale locale = const Locale('en')}) => ProviderScope(
      child: MaterialApp(
        theme: agntsTheme(Brightness.light),
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
    await tester.tap(find.text('Continue with Google'));
    await tester.pumpAndSettle();
    expect(find.text('Enter the https address of your agnts server.'), findsOneWidget);
  });

  testWidgets('an error box copies its whole text', (tester) async {
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') copied = (call.arguments as Map)['text'] as String;
      return null;
    });
    const err = 'claude exited without a result (exit 1)\nError: claude native binary not installed.';
    await tester.pumpWidget(_app(const HelpBox(err, tone: Tone.bad, copyable: true)));
    await tester.tap(find.byTooltip('Copy'));
    await tester.pump();
    expect(copied, err);
    expect(find.text('Copied'), findsOneWidget);
  });

  test('reset text', () {
    expect(shortDuration(const Duration(hours: 2, minutes: 5)), '2h 5m');
    expect(shortDuration(const Duration(days: 1, hours: 3)), '1d 3h');
  });
}
