import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:moksharan/domain/entities/asset_pack.dart';

import '../helpers/fake_asset_pack_service.dart';
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

  testWidgets('missing media files fall back without errors', (tester) async {
    // Pack reported installed, but its files are gone (e.g. cleared).
    final service = FakeAssetPackService(
      initial: {
        'chapter_02': const PackState(
          name: 'chapter_02',
          status: PackStatus.completed,
          assetsPath: 'build/no_such_pack',
        ),
      },
    );
    await pumpApp(tester, location: '/read/2', packs: service);
    expect(find.text('1 / 2'), findsOneWidget);
    await tester.tap(find.byType(PageView));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('going from one chapter reader to another starts fresh', (
    tester,
  ) async {
    final container = await pumpApp(tester, location: '/read/1');
    await tester.tap(find.byTooltip('Next scene'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Next scene'));
    await tester.pumpAndSettle();
    expect(find.text('3 / 3'), findsOneWidget);

    container.router.go('/read/2');
    await tester.pumpAndSettle();
    expect(find.text('1 / 2'), findsOneWidget);
    expect(find.byTooltip('Next scene'), findsOneWidget);
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
