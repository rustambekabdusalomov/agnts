import 'package:agnts_api/agnts_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agnts_mobile/features/tickets/api_results.dart';
import 'package:agnts_mobile/l10n/app_localizations.dart';
import 'package:agnts_mobile/theme.dart';

ApiCase _case(String id, ApiCaseVerdictEnum v, {String? reason, ApiCaseSource_Enum source = ApiCaseSource_Enum.claude}) => ApiCase(
  id: id,
  operation: 'GET /users/{id}',
  case_: id,
  verdict: v,
  reason: reason,
  requests: v == ApiCaseVerdictEnum.pass || v == ApiCaseVerdictEnum.fail ? const ['r-001'] : const [],
  source_: source,
);

void main() {
  testWidgets('shows the counts, what is new and the failures first', (tester) async {
    final r = SwaggerResults(
      test: SwaggerTestView(baseUrl: 'https://staging.test', operations: const ['GET /users/{id}'], writeEnabled: false,
          authKind: ApiAuthKind.bearer, hasToken: true, rateLimit: 5, maxRequests: 300),
      runId: 3,
      counts: ApiCounts(passed: 1, failed: 1, skipped: 1, blocked: 0),
      cases: [
        _case('known id', ApiCaseVerdictEnum.pass),
        _case('schema mismatch', ApiCaseVerdictEnum.fail, reason: 'total is a string', source: ApiCaseSource_Enum.schema),
        _case('create', ApiCaseVerdictEnum.skipped, reason: 'write requests are off'),
      ],
      requests: const [],
      notes: const [],
      newFailures: const ['GET /users/{id} · schema mismatch'],
      previous: ApiCounts(passed: 2, failed: 0, skipped: 1, blocked: 0),
    );
    await tester.pumpWidget(MaterialApp(
      theme: agntsTheme(Brightness.light),
      localizationsDelegates: const [AppLocalizations.delegate, GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: SingleChildScrollView(child: ApiResultsBody(results: r, limit: 5))),
    ));
    expect(find.text('1 passed'), findsOneWidget);
    expect(find.text('1 failed'), findsOneWidget);
    expect(find.textContaining('1 new failure since the last run'), findsOneWidget);
    expect(find.text('agnts check'), findsOneWidget);
    expect(find.text('total is a string'), findsOneWidget);
    // The fold lists failures only; the passed and skipped cases are behind "more".
    expect(find.text('known id'), findsNothing);
  });
}
