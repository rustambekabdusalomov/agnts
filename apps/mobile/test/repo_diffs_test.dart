import 'package:agnts_api/agnts_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agnts_mobile/features/tickets/repo_diffs.dart';
import 'package:agnts_mobile/features/tickets/ticket_repos.dart';
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

FileChange _f(String? repo, String path, int add, int del) =>
    FileChange(repo: repo, path: path, add: add, del: del, diff: '@@ -1 +1 @@\n-a\n+b');

final _files = [_f('gateway', 'api/a.go', 3, 1), _f('gateway', 'api/b.go', 2, 0), _f('protos', 'content.proto', 10, 4)];

// One file's diff as the test sees it: its path, and whether it starts open.
Widget _file(FileChange f, bool open) => Text('${f.path}${open ? ' (open)' : ''}');

void main() {
  test('filesByRepo groups files in order, with each repository\'s lines', () {
    final g = filesByRepo(_files);
    expect([for (final x in g) '${x.repo} ${x.files.length} +${x.add} -${x.del}'], ['gateway 2 +5 -1', 'protos 1 +10 -4']);
    expect(filesByRepo([_f(null, 'a.go', 1, 0)]).single.repo, '');
  });

  testWidgets('a chip per repository; the first is shown, its first file open', (tester) async {
    await tester.pumpWidget(_app(RepoDiffs(files: _files, openFirst: true, file: _file)));
    // Each chip: the repository and its file count.
    expect(find.text('gateway'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('protos'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('api/a.go (open)'), findsOneWidget);
    expect(find.text('api/b.go'), findsOneWidget);
    expect(find.text('content.proto'), findsNothing);
  });

  testWidgets('picking a repository shows only its files, none opened', (tester) async {
    await tester.pumpWidget(_app(RepoDiffs(files: _files, openFirst: true, file: _file)));
    await tester.tap(find.text('protos'));
    await tester.pump();
    expect(find.text('content.proto'), findsOneWidget);
    expect(find.text('api/a.go (open)'), findsNothing);
    expect(find.text('api/a.go'), findsNothing);
  });

  testWidgets('one repository: no chips, every file', (tester) async {
    await tester.pumpWidget(_app(RepoDiffs(files: [_f(null, 'a.go', 1, 0), _f(null, 'b.go', 1, 1)], file: _file)));
    expect(find.byType(SingleChildScrollView), findsOneWidget); // the page's, no chip row
    expect(find.text('a.go'), findsOneWidget);
    expect(find.text('b.go'), findsOneWidget);
  });
}
