import 'package:agnts_api/agnts_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agnts_mobile/features/tickets/file_diff.dart';
import 'package:agnts_mobile/features/tickets/repo_diffs.dart';
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
  home: Scaffold(
    body: ListView(padding: const EdgeInsets.all(16), children: [child]),
  ),
);

const _goDiff = '''diff --git a/api/handlers/v1/survey_result.go b/api/handlers/v1/survey_result.go
index ba433ce..4cd59a5 100644
--- a/api/handlers/v1/survey_result.go
+++ b/api/handlers/v1/survey_result.go
@@ -269,7 +269,11 @@ func (h *surveyResultsHandler) GetSurveyResultStats() http.HandlerFunc {
 			CreatedAtTo:   q.Get("created_at_to"),
 		})
 		if err != nil {
-			render.Render(w, r, errorapi.Error(errx.Wrap(err)))
+			// keeps the validation code and type content_service sets
+			_, err = errx.FromGRPCError(err)
+			render.Render(w, r, errorapi.Error(err))
 			return
 		}
 
''';

void main() {
  testWidgets('an opened Go file shows its code, highlighted, next to the line numbers', (tester) async {
    final f = FileChange(repo: 'gateway', path: 'api/handlers/v1/survey_result.go', add: 3, del: 1, diff: _goDiff);
    await tester.pumpWidget(
      _app(
        RepoDiffs(
          files: [f],
          openFirst: true,
          file: (f, open) => FileDiff(file: f, initiallyOpen: open),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.textContaining('errx.FromGRPCError', findRichText: true), findsOneWidget, reason: 'plain text before highlighting');
    // Highlighting runs on another isolate; let it finish, then rebuild.
    await tester.runAsync(() => Future<void>.delayed(const Duration(seconds: 2)));
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.textContaining('FromGRPCError', findRichText: true), findsOneWidget, reason: 'code after highlighting');
    expect(find.text('272'), findsWidgets); // a line number
  });

  testWidgets('an open file\'s path stays at the top while its diff scrolls under it, then gives way to the next file', (tester) async {
    tester.view.physicalSize = const Size(400, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    String long(String name) => 'diff --git a/$name b/$name\n@@ -1,1 +1,60 @@\n${[for (var i = 0; i < 60; i++) '+line $i'].join('\n')}\n';
    final a = FileChange(path: 'notes/a.txt', add: 60, del: 0, diff: long('notes/a.txt'));
    final b = FileChange(path: 'notes/b.txt', add: 60, del: 0, diff: long('notes/b.txt'));
    await tester.pumpWidget(
      _app(
        Column(
          children: [
            FileDiff(file: a, initiallyOpen: true),
            FileDiff(file: b, initiallyOpen: true),
          ],
        ),
      ),
    );
    await tester.pump();
    final list = tester.getTopLeft(find.byType(ListView)).dy;
    // The painted header is the last of the path's two texts (the first keeps its space, unseen).
    double headerTop(String path) => tester.getTopLeft(find.text(path).last).dy;
    final atRest = headerTop('notes/a.txt');

    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pump();
    expect(headerTop('notes/a.txt'), lessThan(list + 30), reason: 'a\'s path stays at the top of the page');
    expect(headerTop('notes/a.txt'), greaterThan(list));
    expect(atRest, greaterThan(headerTop('notes/a.txt') - 500 + 30));

    // Past a's diff: its path leaves with it, and b's takes the top.
    final aHeight = tester.getSize(find.byType(FileDiff).first).height;
    await tester.drag(find.byType(ListView), Offset(0, -(aHeight + 200)));
    await tester.pump();
    expect(headerTop('notes/a.txt'), lessThan(list), reason: 'a is gone above');
    expect(headerTop('notes/b.txt'), lessThan(list + 30), reason: 'b\'s path is stuck now');
    expect(headerTop('notes/b.txt'), greaterThan(list));
  });
}
