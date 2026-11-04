import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moksharan/app.dart';
import 'package:moksharan/data/asset_packs/asset_pack_providers.dart';
import 'package:moksharan/data/repositories/prefs_user_data_repository.dart';
import 'package:moksharan/data/repositories/user_data_providers.dart';
import 'package:moksharan/domain/entities/asset_pack.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../test/helpers/fake_asset_pack_service.dart';

/// Starts the real app on a device with empty user data.
///
/// Uses the real content bundle, media, and video player. A plain APK
/// carries no asset packs, so chapter 2 is reported installed at a
/// missing folder: its scenes run with image fallbacks, which still
/// exercises layout, dialogue, and motion effects.
Future<ProviderContainer> startApp(WidgetTester tester) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
  await PrefsUserDataRepository(prefs).migrate();

  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      assetPackServiceProvider.overrideWithValue(
        FakeAssetPackService(
          initial: {
            'chapter_02': const PackState(
              name: 'chapter_02',
              status: PackStatus.completed,
              assetsPath: '/nonexistent/chapter_02',
            ),
          },
        ),
      ),
    ],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const MoksharanApp(),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

/// Pumps frames for [duration] without waiting to settle (videos and
/// effects animate forever).
Future<void> pumpFor(WidgetTester tester, Duration duration) async {
  final end = DateTime.now().add(duration);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 16));
  }
}
