import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agnts_mobile/main.dart' show tapOutsideUnfocuses;

void main() {
  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    testWidgets('a tap outside a text field closes the keyboard on ${platform.name}', (tester) async {
      debugDefaultTargetPlatformOverride = platform;
      var retried = 0;
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => Actions(actions: tapOutsideUnfocuses, child: child!),
          home: Scaffold(
            body: Column(
              children: [
                const TextField(key: Key('note')),
                const SizedBox(height: 200, width: 300),
                ElevatedButton(onPressed: () => retried++, child: const Text('Retry')),
              ],
            ),
          ),
        ),
      );
      await tester.tap(find.byKey(const Key('note')));
      await tester.pump();
      expect(tester.testTextInput.isVisible, isTrue);

      // Typing and tapping inside keeps it open.
      await tester.enterText(find.byKey(const Key('note')), 'Use the v2 endpoint');
      await tester.tap(find.byKey(const Key('note')));
      await tester.pump();
      expect(tester.testTextInput.isVisible, isTrue);

      // A tap on empty space closes it and keeps the text.
      await tester.tapAt(const Offset(150, 150));
      await tester.pump();
      expect(tester.testTextInput.isVisible, isFalse);
      expect(find.text('Use the v2 endpoint'), findsOneWidget);

      // A tap on a button while typing closes it and still presses it.
      await tester.tap(find.byKey(const Key('note')));
      await tester.pump();
      await tester.tap(find.text('Retry'));
      await tester.pump();
      expect(tester.testTextInput.isVisible, isFalse);
      expect(retried, 1);
      debugDefaultTargetPlatformOverride = null;
    });
  }
}
