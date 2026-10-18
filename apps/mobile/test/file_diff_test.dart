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
      home: Scaffold(body: ListView(padding: const EdgeInsets.all(16), children: [child])),
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
    await tester.pumpWidget(_app(RepoDiffs(files: [f], openFirst: true, file: (f, open) => FileDiff(file: f, initiallyOpen: open))));
    expect(tester.takeException(), isNull);
    expect(find.textContaining('errx.FromGRPCError', findRichText: true), findsOneWidget, reason: 'plain text before highlighting');
    // Highlighting runs on another isolate; let it finish, then rebuild.
    await tester.runAsync(() => Future<void>.delayed(const Duration(seconds: 2)));
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.textContaining('FromGRPCError', findRichText: true), findsOneWidget, reason: 'code after highlighting');
    expect(find.text('272'), findsWidgets); // a line number
  });
}
