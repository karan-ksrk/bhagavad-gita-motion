// Frame timing for the reader (Milestone 14).
//
// Run in profile mode on a real device:
//   flutter drive --profile --driver=test_driver/perf_driver.dart \
//     --target=integration_test/perf_test.dart -d <device>
// Writes frame build/raster stats to build/integration_response_data.json.
// Clears the app's settings, progress, and bookmarks on that device.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:moksharan/core/routing/app_router.dart';

import 'app_harness.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('reader frame timing', (tester) async {
    final container = await startApp(tester);
    final router = container.read(appRouterProvider);

    // Reader entry and swiping through chapter 1 (video, video, manga).
    await binding.watchPerformance(() async {
      router.go('/read/1');
      await pumpFor(tester, const Duration(seconds: 3));
      for (var i = 0; i < 2; i++) {
        await tester.fling(find.byType(PageView), const Offset(-300, 0), 1500);
        await pumpFor(tester, const Duration(seconds: 3));
      }
      for (var i = 0; i < 4; i++) {
        await tester.tapAt(tester.getCenter(find.byType(PageView)));
        await pumpFor(tester, const Duration(milliseconds: 800));
      }
    }, reportKey: 'reader_chapter1');

    // Layered scene: aura, particles, feather, drift running for 8 s.
    router.go('/read/2');
    await pumpFor(tester, const Duration(seconds: 1));
    await tester.tap(find.byTooltip('Next scene'));
    await pumpFor(tester, const Duration(seconds: 2));
    await binding.watchPerformance(() async {
      await pumpFor(tester, const Duration(seconds: 8));
    }, reportKey: 'layered_effects');
  });
}
