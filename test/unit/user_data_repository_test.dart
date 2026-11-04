import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moksharan/core/settings/app_settings.dart';
import 'package:moksharan/data/repositories/prefs_user_data_repository.dart';
import 'package:moksharan/data/repositories/user_data_providers.dart';
import 'package:moksharan/domain/entities/user_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/prefs.dart';

Future<PrefsUserDataRepository> _repo([
  Map<String, Object> initial = const {},
]) async {
  SharedPreferences.setMockInitialValues(initial);
  return PrefsUserDataRepository(await SharedPreferences.getInstance());
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PrefsUserDataRepository', () {
    test('fresh install: defaults and version recorded', () async {
      final repo = await _repo();
      expect(repo.loadSettings(), isNull);
      expect(repo.loadProgress().byChapter, isEmpty);
      expect(repo.loadBookmarks(), isEmpty);

      await repo.migrate();
      final prefs = await SharedPreferences.getInstance();
      expect(
        prefs.getInt(PrefsUserDataRepository.versionKey),
        PrefsUserDataRepository.currentVersion,
      );
    });

    test('progress and bookmarks round-trip', () async {
      final repo = await _repo();
      final when = DateTime.utc(2026, 11, 4, 12);
      await repo.saveProgress(
        ReadingState(
          lastChapterId: 'chapter_01',
          byChapter: {
            'chapter_01': ReadingProgress(
              chapterId: 'chapter_01',
              sceneId: 'ch01_scene_002',
              visitedSceneIds: const {'ch01_scene_001', 'ch01_scene_002'},
              updatedAt: when,
            ),
          },
        ),
      );
      await repo.saveBookmarks([
        Bookmark(
          bookmarkId: Bookmark.idForVerse('BG.1.1'),
          verseId: 'BG.1.1',
          createdAt: when,
        ),
      ]);

      final progress = repo.loadProgress();
      expect(progress.last?.sceneId, 'ch01_scene_002');
      expect(progress.last?.visitedSceneIds, hasLength(2));
      expect(progress.last?.updatedAt, when);
      expect(repo.loadBookmarks().single.verseId, 'BG.1.1');

      await repo.clearProgress();
      expect(repo.loadProgress().byChapter, isEmpty);
      expect(repo.loadBookmarks(), hasLength(1)); // Bookmarks kept.
    });

    test('corrupt stored data falls back to defaults', () async {
      final repo = await _repo({
        PrefsUserDataRepository.settingsKey: '{not json',
        PrefsUserDataRepository.progressKey: '{"chapters": 5}',
        PrefsUserDataRepository.bookmarksKey: '"oops"',
      });
      expect(repo.loadSettings(), isNull);
      expect(repo.loadProgress().byChapter, isEmpty);
      expect(repo.loadBookmarks(), isEmpty);
    });

    test('malformed bookmark entries are skipped, valid ones kept', () async {
      final repo = await _repo({
        PrefsUserDataRepository.bookmarksKey:
            '[{"id":"verse:BG.1.1","verse_id":"BG.1.1",'
            '"created_at":"2026-11-04T00:00:00.000"},'
            '{"id":"bad","verse_id":"BG.1.2","scene_id":"x",'
            '"created_at":"2026-11-04T00:00:00.000"},'
            '{"id":"bad2"}, 7]',
      });
      expect(repo.loadBookmarks().map((b) => b.bookmarkId), ['verse:BG.1.1']);
    });
  });

  group('controllers persist', () {
    test('settings survive a restart', () async {
      final first = ProviderContainer(overrides: [await prefsOverride()]);
      first.read(settingsProvider.notifier)
        ..setLanguage(AppLanguage.hindi)
        ..setReducedMotion(value: true);
      await Future<void>.delayed(Duration.zero);
      first.dispose();

      // New container on the same stored values, as after relaunch.
      final prefs = await SharedPreferences.getInstance();
      final second = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(second.dispose);
      final s = second.read(settingsProvider);
      expect(s.language, AppLanguage.hindi);
      expect(s.reducedMotion, isTrue);
      expect(s.showTransliteration, isTrue);
    });

    test('unknown stored language falls back to default', () {
      expect(
        AppSettings.fromJson(const {'language': 'xx'}).language,
        AppLanguage.english,
      );
    });

    test('progress records visits and last chapter', () async {
      final c = ProviderContainer(overrides: [await prefsOverride()]);
      addTearDown(c.dispose);
      c.read(progressProvider.notifier)
        ..recordScene(chapterId: 'chapter_01', sceneId: 'ch01_scene_001')
        ..recordScene(chapterId: 'chapter_01', sceneId: 'ch01_scene_002')
        ..recordScene(chapterId: 'chapter_02', sceneId: 'ch02_scene_001');

      final s = c.read(progressProvider);
      expect(s.lastChapterId, 'chapter_02');
      expect(s.byChapter['chapter_01']?.sceneId, 'ch01_scene_002');
      expect(s.byChapter['chapter_01']?.visitedSceneIds, hasLength(2));
    });

    test('bookmark toggle adds then removes', () async {
      final c = ProviderContainer(overrides: [await prefsOverride()]);
      addTearDown(c.dispose);
      final b = c.read(bookmarksProvider.notifier)..toggleVerse('BG.1.1');
      expect(c.read(bookmarksProvider), hasLength(1));
      b.toggleScene('ch01_scene_002');
      expect(c.read(bookmarksProvider).first.sceneId, 'ch01_scene_002');
      b.toggleVerse('BG.1.1');
      expect(c.read(bookmarksProvider).single.sceneId, 'ch01_scene_002');
    });
  });
}
