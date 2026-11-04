import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moksharan/data/repositories/prefs_user_data_repository.dart';
import 'package:moksharan/domain/entities/user_data.dart';
import 'package:moksharan/domain/repositories/user_data_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Loaded in `main` before `runApp` and injected with an override.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError(
    'sharedPreferencesProvider must be overridden at startup',
  ),
);

final userDataRepositoryProvider = Provider<UserDataRepository>(
  (ref) => PrefsUserDataRepository(ref.watch(sharedPreferencesProvider)),
);

/// Reading progress: last chapter and per-chapter position.
class ProgressController extends Notifier<ReadingState> {
  @override
  ReadingState build() => ref.watch(userDataRepositoryProvider).loadProgress();

  /// Records that [sceneId] in [chapterId] is on screen.
  void recordScene({required String chapterId, required String sceneId}) {
    final previous = state.byChapter[chapterId];
    if (state.lastChapterId == chapterId && previous?.sceneId == sceneId) {
      return;
    }
    final updated = ReadingProgress(
      chapterId: chapterId,
      sceneId: sceneId,
      visitedSceneIds: {...?previous?.visitedSceneIds, sceneId},
      updatedAt: DateTime.now(),
    );
    state = ReadingState(
      lastChapterId: chapterId,
      byChapter: {...state.byChapter, chapterId: updated},
    );
    unawaited(ref.read(userDataRepositoryProvider).saveProgress(state));
  }

  /// Deletes all reading progress. Bookmarks are kept.
  Future<void> clear() async {
    state = ReadingState.empty;
    await ref.read(userDataRepositoryProvider).clearProgress();
  }
}

final progressProvider = NotifierProvider<ProgressController, ReadingState>(
  ProgressController.new,
);

/// Bookmarks, newest first.
class BookmarksController extends Notifier<List<Bookmark>> {
  @override
  List<Bookmark> build() {
    final list = [...ref.watch(userDataRepositoryProvider).loadBookmarks()]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List.unmodifiable(list);
  }

  bool contains(String bookmarkId) =>
      state.any((b) => b.bookmarkId == bookmarkId);

  void toggleVerse(String verseId) => _toggle(
    Bookmark(
      bookmarkId: Bookmark.idForVerse(verseId),
      verseId: verseId,
      createdAt: DateTime.now(),
    ),
  );

  void toggleScene(String sceneId) => _toggle(
    Bookmark(
      bookmarkId: Bookmark.idForScene(sceneId),
      sceneId: sceneId,
      createdAt: DateTime.now(),
    ),
  );

  void remove(String bookmarkId) {
    _set(state.where((b) => b.bookmarkId != bookmarkId).toList());
  }

  void _toggle(Bookmark bookmark) {
    if (contains(bookmark.bookmarkId)) {
      remove(bookmark.bookmarkId);
    } else {
      _set([bookmark, ...state]);
    }
  }

  void _set(List<Bookmark> list) {
    state = List.unmodifiable(list);
    unawaited(ref.read(userDataRepositoryProvider).saveBookmarks(state));
  }
}

final bookmarksProvider = NotifierProvider<BookmarksController, List<Bookmark>>(
  BookmarksController.new,
);
