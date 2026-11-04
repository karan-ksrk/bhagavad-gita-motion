import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_app.dart';

void main() {
  testWidgets('swipes through chapter 1 scenes', (tester) async {
    await pumpApp(tester, location: '/read/1');

    expect(find.text('1 / 3'), findsOneWidget);
    await tester.fling(find.byType(PageView), const Offset(-400, 0), 1000);
    await tester.pumpAndSettle();
    expect(find.text('2 / 3'), findsOneWidget);
    expect(find.text('[Pilot] Between the two armies'), findsOneWidget);

    await tester.fling(find.byType(PageView), const Offset(-400, 0), 1000);
    await tester.pumpAndSettle();
    expect(find.text('3 / 3'), findsOneWidget);
    expect(find.text("[Pilot] Arjuna's despair"), findsOneWidget);
  });

  testWidgets('chapter 2 signature scene uses layered motion', (tester) async {
    await pumpApp(tester, location: '/read/2');
    expect(find.text('1 / 2'), findsOneWidget);

    await tester.fling(find.byType(PageView), const Offset(-400, 0), 1000);
    // Effects animate forever, so pump a fixed time instead of settling.
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('2 / 2'), findsOneWidget);
    expect(find.byKey(const Key('effect-aura_1')), findsOneWidget);
    expect(find.byKey(const Key('effect-particles_1')), findsOneWidget);
    expect(find.byKey(const Key('effect-feather_1')), findsOneWidget);
  });

  testWidgets('chapter without scenes shows placeholder', (tester) async {
    await pumpApp(tester, location: '/read/5');
    expect(find.text('READER PLACEHOLDER'), findsOneWidget);
  });

  testWidgets('invalid chapter shows error', (tester) async {
    await pumpApp(tester, location: '/read/42');
    expect(find.text('Chapter not found'), findsOneWidget);
  });
}
