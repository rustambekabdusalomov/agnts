import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agnts_mobile/features/repos/name_format_fields.dart';
import 'package:agnts_mobile/l10n/app_localizations.dart';
import 'package:agnts_mobile/theme.dart';

Widget _app(Widget child) => MaterialApp(
      theme: agntsTheme(Brightness.light),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );

void main() {
  testWidgets('a group\'s empty formats keep each repository\'s own; set, they show an example', (tester) async {
    final branch = TextEditingController(), commit = TextEditingController();
    await tester.pumpWidget(_app(NameFormatFields(branch: branch, commit: commit, taskPrefix: 'SHOP', group: true)));
    expect(find.textContaining('keep each repository'), findsNWidgets(2));
    expect(find.textContaining('Example:'), findsNothing);

    branch.text = '{number}';
    commit.text = '[{number}] {type}({scope}): {subject}';
    await tester.pumpWidget(_app(NameFormatFields(branch: branch, commit: commit, taskPrefix: 'SHOP', group: true)));
    expect(find.textContaining('Example: AMANAT-2288'), findsOneWidget);
    expect(find.textContaining('Example: [AMANAT-2288] chore(deps): bump protos to v1.63.0'), findsOneWidget);
  });

  testWidgets('a repository\'s empty branch format shows the default\'s example', (tester) async {
    final branch = TextEditingController(), commit = TextEditingController();
    await tester.pumpWidget(_app(NameFormatFields(branch: branch, commit: commit, taskPrefix: 'pay', branchPrefix: 'agnts/')));
    expect(find.textContaining('Example: agnts/PAY-42'), findsOneWidget);
  });
}
