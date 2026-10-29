import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:agnts_mobile/app_router.dart';
import 'package:agnts_mobile/theme.dart';

// A screen pushed over the tabs swipes back on iOS from the middle of the
// page, not only from the edge. go_router's default page has no transition,
// so no gesture: screenRoute's MaterialPage gets the theme's swipeable one.
void main() {
  testWidgets('a pushed screen swipes back from the middle of the page on iOS', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    final router = GoRouter(
      initialLocation: '/home',
      routes: [
        screenRoute(
          '/detail',
          (_, _) => Scaffold(
            body: ListView(
              children: [
                const Text('detail'),
                for (var i = 0; i < 40; i++) ListTile(title: Text('$i')),
              ],
            ),
          ),
        ),
        StatefulShellRoute.indexedStack(
          builder: (_, _, shell) => Scaffold(body: shell),
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/home',
                  builder: (c, _) => Center(
                    child: TextButton(onPressed: () => c.push('/detail'), child: const Text('open')),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
    await tester.pumpWidget(MaterialApp.router(theme: agntsTheme(Brightness.light), routerConfig: router));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('detail'), findsOneWidget);

    final g = await tester.startGesture(const Offset(300, 300));
    for (var i = 0; i < 30; i++) {
      await g.moveBy(const Offset(20, 0));
      await tester.pump(const Duration(milliseconds: 16));
    }
    await g.up();
    await tester.pumpAndSettle();
    expect(find.text('detail'), findsNothing);
    expect(find.text('open'), findsOneWidget);
    debugDefaultTargetPlatformOverride = null;
  });
}
