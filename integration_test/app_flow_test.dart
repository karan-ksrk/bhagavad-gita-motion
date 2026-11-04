// On-device flow through the real app (Milestone 14).
//
// Run: flutter test integration_test/app_flow_test.dart -d <device>
// Clears the app's settings, progress, and bookmarks on that device.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:moksharan/core/routing/app_router.dart';
import 'package:moksharan/core/settings/app_settings.dart';
import 'package:moksharan/data/repositories/user_data_providers.dart';

import 'app_harness.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('read, bookmark, switch language, and resume', (tester) async {
    final container = await startApp(tester);
    expect(find.text('No reading progress yet.'), findsOneWidget);

    // Home -> chapters -> chapter 1 -> reader.
    await tester.tap(find.text('Chapters').last);
    await tester.pumpAndSettle();
    debugPrint('STEP 1');
    await tester.tap(find.text('Chapter 1').first);
    await tester.pumpAndSettle();
    debugPrint('STEP 2');
    await tester.tap(find.text('Open reader'));
    await pumpFor(tester, const Duration(seconds: 2));
    debugPrint('STEP 3');
    expect(find.text('1 / 3'), findsOneWidget);

    // Real video plugin: scene 1 plays its clip (poster hidden once ready).
    await pumpFor(tester, const Duration(seconds: 3));
    debugPrint('STEP 4');
    expect(tester.takeException(), isNull);

    // Through all three scenes, bookmarking the second.
    await tester.tap(find.byTooltip('Next scene'));
    await pumpFor(tester, const Duration(seconds: 2));
    debugPrint('STEP 5');
    expect(find.text('2 / 3'), findsOneWidget);
    await tester.tap(find.byTooltip('Bookmark scene'));
    await tester.pump();
    await tester.tap(find.byTooltip('Next scene'));
    await pumpFor(tester, const Duration(seconds: 2));
    debugPrint('STEP 6');
    expect(find.text('3 / 3'), findsOneWidget);

    // Manga scene: tap through dialogue.
    for (var i = 0; i < 4; i++) {
      await tester.tapAt(tester.getCenter(find.byType(PageView)));
      await pumpFor(tester, const Duration(milliseconds: 500));
    }
    expect(tester.takeException(), isNull);

    final progress = container.read(progressProvider);
    expect(progress.last?.sceneId, 'ch01_scene_003');
    expect(container.read(bookmarksProvider), hasLength(1));

    // Close and resume from Home.
    await tester.tap(find.byTooltip('Close reader'));
    await tester.pumpAndSettle();
    debugPrint('STEP 7');
    await tester.tap(find.text('Home').last);
    await tester.pumpAndSettle();
    debugPrint('STEP 8');
    expect(find.text('Chapter 1 · Scene 3 of 3'), findsOneWidget);

    // Hindi UI language, then a verse.
    await tester.tap(find.text('Settings').last);
    await tester.pumpAndSettle();
    debugPrint('STEP 9');
    await tester.tap(find.text('हिन्दी'));
    await tester.pumpAndSettle();
    debugPrint('STEP 10');
    expect(container.read(settingsProvider).language.name, 'hindi');

    // Chapter 2 layered scene with motion effects.
    container.read(appRouterProvider).go('/read/2');
    await pumpFor(tester, const Duration(seconds: 1));
    debugPrint('STEP 11');
    await tester.tap(find.byTooltip('Next scene'));
    await pumpFor(tester, const Duration(seconds: 3));
    debugPrint('STEP 12');
    expect(find.byKey(const Key('effect-aura_1')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
